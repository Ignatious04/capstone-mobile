import 'package:capstone/core/enums/report_status_enum.dart';
import 'package:capstone/core/shared/models/attachment_model.dart';
import 'package:capstone/core/shared/models/report_model.dart';
import 'package:capstone/core/shared/models/responder_note_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReportRepository {
  final FirebaseFirestore firestore;
  ReportRepository(this.firestore);

  Future<void> createReport(ReportModel report) async {
    await firestore.collection('reports').doc(report.reportID).set(report.toMap());
  }

  String getReportID() {
    final docRef = firestore.collection('reports').doc();
    return docRef.id;
  }

  /// Fetches a single report by ID — used when navigating from a push
  /// notification or notification-history entry that only carries the ID.
  Future<ReportModel?> getReportByID(String reportID) async {
    final doc = await firestore.collection('reports').doc(reportID).get();
    if (!doc.exists) return null;
    return ReportModel.fromMap(doc.data()!);
  }

  Stream<List<ReportModel>> getReports(String userID) {
    return firestore
        .collection("reports")
        .where("userID", isEqualTo: userID)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) {
          debugPrint('reports: ${snapshot.docs.length} docs, fromCache=${snapshot.metadata.isFromCache}');
          return snapshot.docs.map((doc) => ReportModel.fromMap(doc.data())).toList();
        });
  }

  Future<void> refreshReports(String userID) async {
    await firestore.disableNetwork();
    await firestore.enableNetwork();
    await firestore
        .collection('reports')
        .where('userID', isEqualTo: userID)
        .limit(1)
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 10));
  }

  /// Watches the responder's single active case: the most recent report
  /// assigned to them that hasn't been resolved yet. By the time a report
  /// reaches the responder, the operator has already reviewed it and
  /// confirmed the assignment on the dashboard, so status here starts at
  /// `accepted` and only moves forward through `dispatched` → `onScene` →
  /// `resolved`.
  Stream<ReportModel?> watchAssignedReport(String responderID) {
    return firestore
        .collection("reports")
        .where("assignedTo", isEqualTo: responderID)
        .where("status", isNotEqualTo: ReportStatusEnum.resolved.name)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          return ReportModel.fromMap(snapshot.docs.first.data());
        });
  }

  Stream<List<ReportModel>> watchResolvedReports(String responderID) {
    return firestore
        .collection('reports')
        .where('assignedTo', isEqualTo: responderID)
        .where('status', isEqualTo: ReportStatusEnum.resolved.name)
        .orderBy('resolvedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ReportModel.fromMap(doc.data())).toList());
  }

  Future<void> updateReportStatus(
    String reportID,
    ReportStatusEnum status, {
    String? responderID,
    int? etaSeconds,
    double? etaDistanceMeters,
  }) async {
    final batch = firestore.batch();

    batch.update(firestore.collection('reports').doc(reportID), {
      'status': status.name,
      if (status == ReportStatusEnum.dispatched) ...{
        'dispatchedAt': FieldValue.serverTimestamp(),
        'etaSeconds': ?etaSeconds,
        'etaDistanceMeters': ?etaDistanceMeters,
      },
      if (status == ReportStatusEnum.onScene) 'arrivedAt': FieldValue.serverTimestamp(),
      if (status == ReportStatusEnum.resolved) 'resolvedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Stream<ReportModel?> watchReport(String reportID) {
    return firestore.collection('reports').doc(reportID).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return null;
      return ReportModel.fromMap(data);
    });
  }

  Future<void> addResponderAttachment(String reportID, AttachmentModel attachment) {
    return firestore.collection('reports').doc(reportID).update({
      'responderAttachments': FieldValue.arrayUnion([attachment.toMap()]),
    });
  }

  /// Append-only on purpose: notes are part of the incident record, so there
  /// is no edit/delete path from the app.
  Future<void> addResponderNote(String reportID, ResponderNoteModel note) {
    return firestore.collection('reports').doc(reportID).update({
      'responderNotes': FieldValue.arrayUnion([note.toMap()]),
    });
  }
}

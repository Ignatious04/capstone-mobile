import 'package:capstone/core/enums/report_status_enum.dart';
import 'package:capstone/core/shared/models/report_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
          return snapshot.docs.map((doc) => ReportModel.fromMap(doc.data())).toList();
        });
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

  Future<void> updateReportStatus(String reportID, ReportStatusEnum status, {String? responderID}) async {
    final batch = firestore.batch();

    batch.update(firestore.collection('reports').doc(reportID), {
      'status': status.name,
      if (status == ReportStatusEnum.dispatched) 'dispatchedAt': FieldValue.serverTimestamp(),
      if (status == ReportStatusEnum.onScene) 'arrivedAt': FieldValue.serverTimestamp(),
      if (status == ReportStatusEnum.resolved) 'resolvedAt': FieldValue.serverTimestamp(),
    });

    if (status == ReportStatusEnum.resolved && responderID != null && responderID.isNotEmpty) {
      batch.update(firestore.collection("responders").doc(responderID), {"isAvailable": true});
    }

    await batch.commit();
  }
}

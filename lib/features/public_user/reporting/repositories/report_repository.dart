import 'package:capstone/core/enums/report_status_enum.dart';
import 'package:capstone/features/public_user/reporting/models/report_model.dart';
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
  /// assigned to them that hasn't been resolved yet. Covers both the
  /// "awaiting confirmation" state (status still `pending`, responderID set)
  /// and every state after acceptance.
  Stream<ReportModel?> watchAssignedReport(String responderID) {
    return firestore
        .collection("reports")
        .where("responderID", isEqualTo: responderID)
        .where("status", isNotEqualTo: ReportStatusEnum.resolved.name)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          return ReportModel.fromMap(snapshot.docs.first.data());
        });
  }

  Future<void> updateReportStatus(String reportID, ReportStatusEnum status) async {
    await firestore.collection('reports').doc(reportID).update({
      'status': status.name,
      if (status == ReportStatusEnum.resolved) 'resolvedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Responder declines an assigned case: frees it back up for the operator
  /// to reassign.
  Future<void> declineAssignment(String reportID) async {
    await firestore.collection('reports').doc(reportID).update({
      'responderID': '',
      'status': ReportStatusEnum.pending.name,
    });
  }
}

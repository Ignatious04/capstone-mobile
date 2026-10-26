import 'package:capstone/core/shared/models/report_model.dart';
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

  Stream<ReportModel?> watchReport(String reportID) {
    return firestore.collection('reports').doc(reportID).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return null;
      return ReportModel.fromMap(data);
    });
  }
}

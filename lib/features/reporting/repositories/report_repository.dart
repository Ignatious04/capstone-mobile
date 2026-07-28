import 'package:capstone/features/reporting/models/report_model.dart';
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
}

import 'package:capstone/core/shared/models/responder_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResponderRepository {
  final FirebaseFirestore firestore;

  ResponderRepository(this.firestore);

  Future<ResponderModel?> getResponder(String uid) async {
    final snapshot = await firestore.collection('responders').doc(uid).get();
    if (!snapshot.exists) return null;
    return ResponderModel.fromMap(snapshot.data()!);
  }

  Stream<ResponderModel?> watchResponder(String uid) {
    return firestore.collection('responders').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return ResponderModel.fromMap(snapshot.data()!);
    });
  }
}
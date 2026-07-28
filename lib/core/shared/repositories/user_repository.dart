import 'package:capstone/core/shared/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  final FirebaseFirestore firestore;

  UserRepository(this.firestore);

  Future<void> createUser(UserModel user) async {
    await firestore.collection('users').doc(user.userID).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    final snapshot = await firestore.collection('users').doc(uid).get();

    if (!snapshot.exists) {
      return null;
    }

    return UserModel.fromMap(snapshot.data()!);
  }

  Stream<UserModel?> watchUser(String uid) {
    return firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }

      return UserModel.fromMap(snapshot.data()!);
    });
  }

  Future<void> updateUser(
    String uid,
    Map<String, dynamic> data,
  ) async {
    await firestore.collection('users').doc(uid).update(data);
  }
}

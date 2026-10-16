import 'package:capstone/core/shared/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  final FirebaseFirestore firestore;

  UserRepository(this.firestore);

  Future<void> createUser(UserModel user) async {
    await firestore.collection('users').doc(user.userID).set(user.toMap(), SetOptions(merge: true));
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
    await firestore.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  Future<bool> isIdNumberTaken(String idNumber, {required String excludeUserID}) async {
    final query = await firestore.collection('users').where('idNumber', isEqualTo: idNumber).get();

    return query.docs.any((doc) => doc.id != excludeUserID);
  }

  Future<void> updateFcmToken(String uid, String token) async {
    try {
      await firestore.collection('users').doc(uid).update({'fcmToken': token});
    } on FirebaseException catch (e) {
      // User doc not created yet; the token is saved on the next registerToken call.
      if (e.code != 'not-found') rethrow;
    }
  }

  /// Saved so Cloud Functions can send push text in the user's language.
  Future<void> updateLanguage(String uid, String languageCode) async {
    try {
      await firestore.collection('users').doc(uid).update({'languageCode': languageCode});
    } on FirebaseException catch (e) {
      // User doc not created yet; it is saved on the next login or language change.
      if (e.code != 'not-found') rethrow;
    }
  }

  Future<void> clearFcmToken(String uid) async {
    await firestore.collection('users').doc(uid).update({
      'fcmToken': FieldValue.delete(),
    });
  }

  Future<void> setDeactivated(String uid, {required bool isDeactivated}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await firestore.collection('users').doc(uid).update({
      'isDeactivated': isDeactivated,
      'deactivatedAt': isDeactivated ? now : null,
      'updatedAt': now,
    });
  }

  Future<void> resubmitVerification(
    String uid,
    Map<String, dynamic> data, {
    required Map<String, dynamic> previousRejection,
  }) async {
    final userRef = firestore.collection('users').doc(uid);
    final batch = firestore.batch();

    // Keep the old rejection so reviewers can see what was asked before.
    batch.set(userRef.collection('verificationHistory').doc(), {
      ...previousRejection,
      'archivedAt': DateTime.now().millisecondsSinceEpoch,
    });

    batch.set(userRef, {
      ...data,
      'verificationStatus': 'pending',
      'rejectionCode': FieldValue.delete(),
      'rejectionReason': FieldValue.delete(),
      'reviewedAt': FieldValue.delete(),
      'reviewedBy': FieldValue.delete(),
      'canResubmit': true,
      'resubmissionCount': FieldValue.increment(1),
    }, SetOptions(merge: true));

    await batch.commit();
  }
}

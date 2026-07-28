import 'package:firebase_database/firebase_database.dart';

class RealtimeDatabaseRepository {
  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;

  Future<void> create({
    required String path,
    required Object? data,
  }) async {
    await _firebaseDatabase.ref(path).set(data);
  }

  Future<DataSnapshot?> read({
    required String path,
  }) async {
    final snapshot = await _firebaseDatabase.ref(path).get();
    return snapshot.exists ? snapshot : null;
  }

  Future<void> update({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    await _firebaseDatabase.ref(path).update(data);
  }

  Future<void> delete({
    required String path,
  }) async {
    await _firebaseDatabase.ref(path).remove();
  }

  Future<bool> getSetupStatus(String userID) async {
    final snapshot = await read(
      path: 'users/$userID/isSetup',
    );

    return snapshot?.value == true;
  }
}

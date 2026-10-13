import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef RemoteSession = ({bool exists, bool fromCache, String? sessionId});

class SessionRepository {
  SessionRepository(this._firestore);

  final FirebaseFirestore _firestore;

  static const _kUid = 'session_uid';
  static const _kId = 'session_id';

  DocumentReference<Map<String, dynamic>> _doc(String uid) => _firestore.collection('sessions').doc(uid);

  String _newSessionId() {
    final rnd = Random.secure();
    return List.generate(16, (_) => rnd.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
  }

  /// The id this device holds for [uid], or null if it hasn't claimed one.
  Future<String?> readLocal(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUid) == uid ? prefs.getString(_kId) : null;
  }

  Future<void> clearLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUid);
    await prefs.remove(_kId);
  }

  /// Makes this device the active one. Any other device will see the change and sign out.
  Future<String> claim(String uid) async {
    final id = _newSessionId();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUid, uid);
    await prefs.setString(_kId, id);

    try {
      await _doc(uid)
          .set({
            'sessionId': id,
            'platform': defaultTargetPlatform.name,
            'updatedAt': FieldValue.serverTimestamp(),
          })
          .timeout(const Duration(seconds: 10));
    } on TimeoutException {
      // The write stays queued in Firestore and syncs when the connection returns.
    }
    return id;
  }

  Stream<RemoteSession> watch(String uid) {
    return _doc(uid).snapshots().map(
      (s) => (
        exists: s.exists,
        fromCache: s.metadata.isFromCache,
        sessionId: s.data()?['sessionId'] as String?,
      ),
    );
  }
}

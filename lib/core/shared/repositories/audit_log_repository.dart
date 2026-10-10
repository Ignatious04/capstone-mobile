import 'dart:async';

import 'package:capstone/core/enums/audit_action_enum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuditLogRepository {
  AuditLogRepository(this.firestore, this.auth);

  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  /// Fire-and-forget on purpose: never await this, and it never throws.
  /// Offline, Firestore queues the write and syncs it later.
  Future<void> _write(
  AuditAction action, {
  String? targetType,
  String? targetId,
  Map<String, dynamic>? metadata,
}) {
  final uid = auth.currentUser?.uid;
  if (uid == null) return Future.value();

  final doc = firestore.collection('audit_logs').doc();
  return doc.set({
    'eventId': doc.id,
    'action': action.code,
    'category': action.code.split('.').first,
    'actorId': uid,
    'actorType': 'user',
    'authType': 'client',
    'targetType': targetType,
    'targetId': targetId,
    'metadata': metadata ?? <String, dynamic>{},
    'source': 'client',
    'createdAt': FieldValue.serverTimestamp(),
  }).then<void>(
    (_) {},
    onError: (Object e) => debugPrint('Audit log failed (${action.code}): $e'),
  );
}

void log(AuditAction action,
    {String? targetType, String? targetId, Map<String, dynamic>? metadata}) {
  unawaited(_write(action,
      targetType: targetType, targetId: targetId, metadata: metadata));
}

/// Use only right before signOut, so the write is authorised before the token goes.
Future<void> logAndWait(AuditAction action) async {
  try {
    await _write(action).timeout(const Duration(seconds: 3));
  } catch (_) {}
}

  Future<T> trackFailure<T>(String reportType, Future<T> Function() action) async {
    try {
      return await action();
    } catch (e) {
      log(
        AuditAction.reportSubmitFailed,
        targetType: 'report',
        metadata: {'reportType': reportType, 'errorType': e.runtimeType.toString()},
      );
      rethrow;
    }
  }
}

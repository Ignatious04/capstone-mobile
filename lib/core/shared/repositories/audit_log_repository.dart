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
  void log(
    AuditAction action, {
    String? targetType,
    String? targetId,
    Map<String, dynamic>? metadata,
  }) {
    final uid = auth.currentUser?.uid;
    if (uid == null) return;

    // Pre-generate the ID so eventId can match the document ID (the rules require it).
    final doc = firestore.collection('audit_logs').doc();

    unawaited(
      doc
          .set({
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
          })
          .then<void>(
            (_) {},
            onError: (Object e) => debugPrint('Audit log failed: $e'),
          ),
    );
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

import 'dart:async';

import 'package:capstone/core/enums/audit_action_enum.dart';
import 'package:capstone/core/services/push_notification_service.dart';
import 'package:capstone/core/shared/models/responder_model.dart';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/providers/navigator_key_provider.dart';
import 'package:capstone/core/shared/providers/responder_provider.dart';
import 'package:capstone/features/responder/active_case/providers/responder_location_sharing_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// true while the "your account was set to inactive" screen should be showing.
final responderDeactivatedProvider = NotifierProvider<ResponderDeactivatedNotifier, bool>(
  ResponderDeactivatedNotifier.new,
);

class ResponderDeactivatedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void markDeactivated() => state = true;
  void dismiss() => state = false;
}

/// Watch once (AuthWrapper does) to keep the guard alive.
final responderActiveGuardProvider = Provider<ResponderActiveGuard>((ref) {
  final guard = ResponderActiveGuard(ref);
  ref.listen<AsyncValue<ResponderModel?>>(
    currentAuthenticatedResponderProvider,
    (_, next) {
      final responder = next.asData?.value;
      // Only act on real data: null = not a responder, loading/error = unknown.
      if (responder != null && !responder.isActive) guard.kick();
    },
    fireImmediately: true,
  );
  return guard;
});

class ResponderActiveGuard {
  ResponderActiveGuard(this._ref);

  final Ref _ref;
  bool _kicking = false;

  Future<void> kick() async {
    if (_kicking) return;
    _kicking = true;
    try {
      // Close pushed routes/dialogs and show the notice first.
      _ref.read(navigatorKeyProvider).currentState?.popUntil((r) => r.isFirst);
      _ref.read(responderDeactivatedProvider.notifier).markDeactivated();

      // Same teardown as the manual logout button, and in the same order:
      // these writes need the auth token, so they must happen before signOut.
      await _ref.read(responderLocationSharingProvider).stopSharing();
      final uid = _ref.read(firebaseAuthProvider).currentUser?.uid;
      if (uid != null) {
        await _ref.read(pushNotificationServiceProvider).clearToken(uid);
      }

      await _ref.read(firebaseAuthRepositoryProvider).signOut(auditAction: AuditAction.responderDeactivated);
    } catch (e) {
      debugPrint('Forced responder sign-out failed: $e');
    } finally {
      _kicking = false;
    }
  }
}
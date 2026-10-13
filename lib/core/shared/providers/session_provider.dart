import 'dart:async';

import 'package:capstone/core/enums/audit_action_enum.dart';
import 'package:capstone/core/services/push_notification_service.dart';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/providers/firestore_provider.dart';
import 'package:capstone/core/shared/providers/navigator_key_provider.dart';
import 'package:capstone/core/shared/repositories/session_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository(ref.watch(firestoreProvider));
});

/// true while the "signed in on another device" screen should be showing.
final sessionReplacedProvider = NotifierProvider<SessionReplacedNotifier, bool>(
  SessionReplacedNotifier.new,
);

class SessionReplacedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void markReplaced() => state = true;
  void dismiss() => state = false;
}

/// Watch this once (AuthWrapper does) to keep the guard alive.
final sessionGuardProvider = Provider<SessionGuard>((ref) {
  final guard = SessionGuard(ref);
  ref.onDispose(guard.dispose);
  ref.listen<AsyncValue<User?>>(authStateProvider, (_, next) {
    if (!next.hasValue) return;
    guard.onAuthChanged(next.value);
  }, fireImmediately: true);
  return guard;
});

class SessionGuard {
  SessionGuard(this._ref);

  final Ref _ref;
  StreamSubscription<RemoteSession>? _sub;
  String? _uid;
  bool _kicking = false;

  SessionRepository get _repo => _ref.read(sessionRepositoryProvider);

  void dispose() => _sub?.cancel();

  Future<void> onAuthChanged(User? user) async {
    final uid = user?.uid;
    if (uid == _uid && (uid == null || _sub != null)) return;

    _uid = uid;
    await _sub?.cancel();
    _sub = null;

    // Logged out (manually or kicked): forget the id so the next login claims a fresh one.
    if (uid == null) {
      await _repo.clearLocal();
      return;
    }

    // No local id means a fresh login on this device (or an app update on an
    // already logged-in device), so this device takes over the session.
    var localId = await _repo.readLocal(uid);
    if (_uid != uid) return;
    localId ??= await _repo.claim(uid);
    if (_uid != uid) return;

    final myId = localId;
    _sub = _repo.watch(uid).listen(
      (snap) {
        // Missing doc or stale cache: not proof that we were replaced.
        if (!snap.exists || snap.sessionId == null) return;
        if (snap.sessionId != myId) _kick();
      },
      onError: (Object e) => debugPrint('Session watch failed: $e'),
    );
  }

  Future<void> _kick() async {
    if (_kicking) return;
    _kicking = true;
    try {
      await _sub?.cancel();
      _sub = null;

      // Close pushed routes and dialogs so the screen below isn't hidden.
      _ref.read(navigatorKeyProvider).currentState?.popUntil((r) => r.isFirst);
      _ref.read(sessionReplacedProvider.notifier).markReplaced();

      // Do NOT call clearToken(): the FCM token lives on the shared user doc
      // and now belongs to the new device. Just stop this device's listeners.
      await _ref.read(pushNotificationServiceProvider).dispose();

      await _ref.read(firebaseAuthRepositoryProvider).signOut(auditAction: AuditAction.sessionReplaced);
    } catch (e) {
      debugPrint('Forced sign-out failed: $e');
    } finally {
      _kicking = false;
    }
  }
}
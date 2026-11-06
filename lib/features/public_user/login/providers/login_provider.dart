import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/providers/responder_repository_provider.dart';
import 'package:capstone/core/shared/providers/user_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// data = true means the login went through and the success snackbar is appropriate.
final loginProvider = NotifierProvider<LoginNotifier, AsyncValue<bool>>(
  LoginNotifier.new,
);

class LoginNotifier extends Notifier<AsyncValue<bool>> {
  static const responderEmailDomain = 'responders.saupangeles.app';

  @override
  AsyncValue<bool> build() => const AsyncData(false);

  /// "medi0001" / "MEDI0001" -> medi0001@responders.saupangeles.app
  /// Anything containing "@" is treated as a normal email.
  static String resolveIdentifier(String input) {
    final value = input.trim();
    if (value.contains('@')) return value;
    return '${value.toLowerCase()}@$responderEmailDomain';
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final credential = await ref
          .read(firebaseAuthRepositoryProvider)
          .signIn(
            email: resolveIdentifier(email), // was: email.trim()
            password: password,
          );
          return _canEnter(credential.user?.uid);
    });
  }

  /// false when the account is deactivated, i.e. the app is about to
  /// show the deactivated screen instead of the home screen.
  Future<bool> _canEnter(String? uid) async {
    if (uid == null) return false;
    try {
      final responder = await ref.read(responderRepositoryProvider).getResponder(uid);
      if (responder != null) return responder.isActive;

      final user = await ref.read(userRepositoryProvider).getUser(uid);
      return user == null || !user.isDeactivated;
    } catch (_) {
      return false; // if we can't tell, skip the snackbar rather than risk a wrong one
    }
  }
}

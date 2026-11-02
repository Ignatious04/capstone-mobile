import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final loginProvider = NotifierProvider<LoginNotifier, AsyncValue<void>>(
  LoginNotifier.new,
);

class LoginNotifier extends Notifier<AsyncValue<void>> {
  static const responderEmailDomain = 'responders.saupangeles.app';

  @override
  AsyncValue<void> build() => const AsyncData(null);

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
      await ref
          .read(firebaseAuthRepositoryProvider)
          .signIn(
            email: resolveIdentifier(email), // was: email.trim()
            password: password,
          );
    });
  }
}

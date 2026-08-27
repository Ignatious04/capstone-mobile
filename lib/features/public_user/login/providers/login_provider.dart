import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final loginProvider = NotifierProvider<LoginNotifier, AsyncValue<void>>(
  LoginNotifier.new,
);

class LoginNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(firebaseAuthRepositoryProvider).signIn(
        email: email.trim(),
        password: password,
      );
    });
  }
}
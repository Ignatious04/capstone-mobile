import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final resetPasswordProvider = NotifierProvider<ResetPasswordNotifier, AsyncValue<void>>(
  ResetPasswordNotifier.new,
);

class ResetPasswordNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> resetPassword({required String email}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(firebaseAuthRepositoryProvider).resetPassword(email: email);
    });
  }
}

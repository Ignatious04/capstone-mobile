import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final changePasswordProvider = NotifierProvider<ChangePasswordNotifier, AsyncValue<void>>(
  ChangePasswordNotifier.new,
);

class ChangePasswordNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(firebaseAuthRepositoryProvider)
          .changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
          );
    });
  }
}

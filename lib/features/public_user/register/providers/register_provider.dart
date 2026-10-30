import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/providers/user_provider.dart';
import 'package:capstone/core/shared/providers/user_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final registerProvider = NotifierProvider<RegisterNotifier, AsyncValue<void>>(RegisterNotifier.new);

class RegisterNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> register({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final firebaseAuthRepository = ref.read(firebaseAuthRepositoryProvider);
      final userNotifier = ref.read(userProvider.notifier);
      final credential = await firebaseAuthRepository.createAccount(email: email, password: password);
      final userID = credential.user!.uid;
      await firebaseAuthRepository.sendEmailVerification();
      userNotifier.reset();
      userNotifier.setUserID(userID);
      userNotifier.setEmail(email);
      final now = DateTime.now().millisecondsSinceEpoch;
      userNotifier.setCreatedAt(now);
      userNotifier.setUpdatedAt(now);
      final user = ref.read(userProvider);

      await ref.read(userRepositoryProvider).createUser(user);
    });
  }
}

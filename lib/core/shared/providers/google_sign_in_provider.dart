import 'package:capstone/core/services/push_notification_service.dart';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/providers/user_provider.dart';
import 'package:capstone/core/shared/providers/user_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final googleSignInProvider = NotifierProvider<GoogleSignInNotifier, AsyncValue<void>>(
  GoogleSignInNotifier.new,
);

class GoogleSignInNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// true = signed in, false = cancelled or failed (check state for the error).
  Future<bool> signIn() async {
    state = const AsyncLoading();
    var signedIn = false;

    state = await AsyncValue.guard(() async {
      final credential = await ref.read(firebaseAuthRepositoryProvider).signInWithGoogle();
      if (credential == null) return; // user cancelled

      signedIn = true;
      final authUser = credential.user!;
      ref.read(userProvider.notifier).reset(); // drop any leftover state from a previous account
      final userRepository = ref.read(userRepositoryProvider);
      final existing = await userRepository.getUser(authUser.uid);

      // Only create the Firestore doc the first time. createUser() writes every
      // field in toMap(), so calling it for a returning user would reset their
      // setup data (isSetup, names, ID, etc.) to empty defaults.
      if (existing == null || existing.userID.isEmpty) {
        final userNotifier = ref.read(userProvider.notifier);
        userNotifier.setUserID(authUser.uid);
        userNotifier.setEmail(authUser.email ?? '');
        final now = DateTime.now().millisecondsSinceEpoch;
        userNotifier.setCreatedAt(now);
        userNotifier.setUpdatedAt(now);
        await userRepository.createUser(ref.read(userProvider));
        await ref.read(pushNotificationServiceProvider).registerToken(authUser.uid);
      }

      // Seed the setup form (in memory only; updateUserSetup() writes it to Firestore).
      if (existing == null || !existing.isSetup) {
        final profile = credential.additionalUserInfo?.profile;
        ref
            .read(userProvider.notifier)
            .prefillFromGoogle(
              givenName: profile?['given_name'] as String?,
              familyName: profile?['family_name'] as String?,
              displayName: authUser.displayName,
            );
      }
    });

    return signedIn && !state.hasError;
  }
}

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
      final userRepository = ref.read(userRepositoryProvider);

      // Only create the Firestore doc the first time. createUser() writes every
      // field in toMap(), so calling it for a returning user would reset their
      // setup data (isSetup, names, ID, etc.) to empty defaults.
      if (await userRepository.getUser(authUser.uid) == null) {
        final userNotifier = ref.read(userProvider.notifier);
        userNotifier.setUserID(authUser.uid);
        userNotifier.setEmail(authUser.email ?? '');
        final now = DateTime.now().millisecondsSinceEpoch;
        userNotifier.setCreatedAt(now);
        userNotifier.setUpdatedAt(now);
        await userRepository.createUser(ref.read(userProvider));
      }
    });

    return signedIn && !state.hasError;
  }
}

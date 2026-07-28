import 'package:capstone/core/shared/providers/user_provider.dart';
import 'package:capstone/features/login/views/login_screen.dart';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/features/main/main_screen.dart';
import 'package:capstone/features/setup/views/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final firebaseAuthRepository = ref.read(
    //   firebaseAuthRepositoryProvider,
    // );

    // firebaseAuthRepository.signOut();
    final authState = ref.watch(authStateProvider);
    debugPrint(authState.toString());

    return authState.when(
      data: (user) {
        if (user == null) {
          return const LoginScreen();
        }

        final userAsync = ref.watch(currentAuthenticatedUserProvider);

        return userAsync.when(
          data: (user) {
            if (user == null) {
              return const LoginScreen();
            }

            if (!user.isSetup) {
              return const WelcomeScreen();
            }

            return const MainScreen();
          },
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Scaffold(
            body: Center(child: Text(e.toString())),
          ),
        );
      },
      loading: () => Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.deepOrange,
          ),
        ),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}

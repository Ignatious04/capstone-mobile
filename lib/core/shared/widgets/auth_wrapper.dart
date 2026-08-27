import 'package:capstone/core/shared/providers/responder_provider.dart';
import 'package:capstone/core/shared/providers/user_provider.dart';
import 'package:capstone/core/shared/widgets/custom_circular_progress_indicator.dart';
import 'package:capstone/core/shared/widgets/location_gate.dart';
import 'package:capstone/features/public_user/login/views/login_screen.dart';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/features/public_user/setup/views/welcome_screen.dart';
import 'package:capstone/features/responder/main/views/responder_main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (authUser) {
        if (authUser == null) {
          return const LoginScreen();
        }

        final responderAsync = ref.watch(currentAuthenticatedResponderProvider);

        return responderAsync.when(
          data: (responder) {
            if (responder != null) {
              return const ResponderMainScreen();
            }

            final userAsync = ref.watch(currentAuthenticatedUserProvider);

            return userAsync.when(
              data: (user) {
                if (user == null || !user.isSetup) {
                  return const WelcomeScreen();
                }
                return const LocationGate();
              },
              loading: () => const Scaffold(body: Center(child: CustomCircularProgressIndicator())),
              error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
            );
          },
          loading: () => const Scaffold(body: Center(child: CustomCircularProgressIndicator())),
          error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
        );
      },
      loading: () => const Scaffold(body: Center(child: CustomCircularProgressIndicator())),
      error: (error, stack) => Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }
}

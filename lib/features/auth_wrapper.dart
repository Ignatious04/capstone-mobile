import 'package:capstone/core/enums/verification_status_enum.dart';
import 'package:capstone/core/shared/providers/responder_provider.dart';
import 'package:capstone/core/shared/providers/session_provider.dart';
import 'package:capstone/core/shared/providers/user_provider.dart';
import 'package:capstone/core/shared/widgets/custom_circular_progress_indicator.dart';
import 'package:capstone/features/location_gate.dart';
import 'package:capstone/features/deactivated_screen.dart';
import 'package:capstone/features/public_user/login/views/login_screen.dart';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/features/public_user/register/views/email_verification_screen.dart';
import 'package:capstone/features/public_user/setup/views/welcome_screen.dart';
import 'package:capstone/features/rejected_screen.dart';
import 'package:capstone/features/responder/main/views/responder_main_screen.dart';
import 'package:capstone/features/session_replaced_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //FirebaseAuth.instance.signOut();

    ref.watch(sessionGuardProvider); // starts the single-session guard
    if (ref.watch(sessionReplacedProvider)) {
      return const SessionReplacedScreen();
    }

    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (authUser) {
        if (authUser == null) {
          return const LoginScreen();
        }

        debugPrint('Email: ${authUser.email}');
        debugPrint('Email verified: ${authUser.emailVerified}');

        if (!authUser.emailVerified) {
          return const EmailVerificationScreen();
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
                if (user != null && user.isDeactivated) {
                  return DeactivatedScreen(user: user);
                }

                if (user == null || !user.isSetup) {
                  return const WelcomeScreen();
                }

                if (user.verificationStatus == VerificationStatusEnum.rejected) {
                  return RejectedScreen(user: user); // reason, resubmit button, hotline buttons, logout
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

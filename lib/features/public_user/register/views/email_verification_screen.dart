// lib/features/register/views/email_verification_screen.dart
import 'package:capstone/core/exceptions/auth_exception.dart';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/custom_snackbar_helper.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/title_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends ConsumerState<EmailVerificationScreen> {
  bool isChecking = false;
  bool isResending = false;
  DateTime? lastResentAt;

  @override
  Widget build(BuildContext context) {
    final email = ref.watch(firebaseAuthProvider).currentUser?.email ?? "";
    final canResend = lastResentAt == null || DateTime.now().difference(lastResentAt!) > const Duration(seconds: 30);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.mark_email_unread_outlined, size: 50, color: Colors.deepOrange),
              const SizedBox(height: 10),
              const TitleText(
                value: "Verify your email",
                alignment: TextAlign.center,
              ),
              const SizedBox(height: 10),
              BodyText(
                value:
                    "We sent a verification link to $email. "
                    "Tap the link, then come back and press Continue.",
                color: Colors.black54,
                alignment: TextAlign.center,
              ),
              const SizedBox(height: 10),
              CustomElevatedButton(
                value: isChecking ? "Checking..." : "I've verified, continue",
                onPressed: isChecking
                    ? null
                    : () async {
                        setState(() => isChecking = true);
                        try {
                          final repo = ref.read(firebaseAuthRepositoryProvider);
                          await repo.reloadUser();

                          if (repo.currentUser?.emailVerified == true) {
                            ref.invalidate(authStateProvider);
                          } else if (context.mounted) {
                            CustomSnackbarHelper.show(
                              context,
                              text: "Still not verified yet — check your inbox.",
                            );
                          }
                        } on AuthException catch (e) {
                          if (context.mounted) {
                            CustomSnackbarHelper.show(context, text: e.message);
                          }
                        } finally {
                          if (mounted) setState(() => isChecking = false);
                        }
                      },
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: !canResend || isResending
                    ? null
                    : () async {
                        setState(() => isResending = true);
                        try {
                          await ref.read(firebaseAuthRepositoryProvider).sendEmailVerification();
                          setState(() => lastResentAt = DateTime.now());
                          if (context.mounted) {
                            CustomSnackbarHelper.show(context, text: "Verification email resent.");
                          }
                        } on AuthException catch (e) {
                          if (context.mounted) {
                            CustomSnackbarHelper.show(context, text: e.message);
                          }
                        } finally {
                          if (mounted) setState(() => isResending = false);
                        }
                      },
                child: Text(canResend ? "Resend email" : "Resend available shortly"),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () async {
                  await ref.read(firebaseAuthRepositoryProvider).signOut();
                },
                child: const Text("Sign out"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

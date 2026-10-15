// lib/features/register/views/email_verification_screen.dart
import 'package:capstone/core/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
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
              TitleText(
                value: l10n.verifyEmailTitle,
                alignment: TextAlign.center,
              ),
              const SizedBox(height: 10),
              BodyText(
                value: l10n.verifyEmailBody(email),
                color: Colors.black54,
                alignment: TextAlign.center,
              ),
              const SizedBox(height: 10),
              CustomElevatedButton(
                value: isChecking ? l10n.checking : l10n.verifiedContinue,
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
                              text: l10n.stillNotVerified,
                            );
                          }
                        } on AuthException catch (e) {
                          if (context.mounted) {
                            CustomSnackbarHelper.show(context, text: e.localized(l10n));
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
                            CustomSnackbarHelper.show(context, text: l10n.verificationEmailResent);
                          }
                        } on AuthException catch (e) {
                          if (context.mounted) {
                            CustomSnackbarHelper.show(context, text: e.localized(l10n));
                          }
                        } finally {
                          if (mounted) setState(() => isResending = false);
                        }
                      },
                child: Text(canResend ? l10n.resendEmail : l10n.resendAvailableShortly),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () async {
                  await ref.read(firebaseAuthRepositoryProvider).signOut();
                },
                child: Text(l10n.signOut),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

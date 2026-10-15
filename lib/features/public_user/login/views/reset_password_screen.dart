import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/exceptions/auth_exception.dart';
import 'package:capstone/core/shared/widgets/custom_app_bar.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/custom_snackbar_helper.dart';
import 'package:capstone/core/shared/widgets/custom_text_field.dart';
import 'package:capstone/core/shared/providers/user_provider.dart';
import 'package:capstone/features/public_user/login/providers/reset_password_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final resetScreenKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  String? errorMessage = "";

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    ref.listen(resetPasswordProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          setState(() {
            errorMessage = error is AuthException ? error.localized(l10n) : l10n.somethingWentWrong;
          });
        },
        data: (_) {
          if (previous is AsyncLoading) {
            if (!context.mounted) return;
            CustomSnackbarHelper.show(context, text: l10n.resetEmailSent);
            Navigator.pop(context);
          }
        },
      );
    });

    return Scaffold(
      appBar: CustomAppBar(value: l10n.resetPassword),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: resetScreenKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        title: l10n.emailAddress.toUpperCase(),
                        controller: emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.fieldRequired(l10n.emailAddress);
                          }

                          return null;
                        },
                        hideErrorText: false,
                        onChanged: (value) {
                          ref.read(userProvider.notifier).setEmail(value);
                        },
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: CustomElevatedButton(
                          onPressed: () async {
                            setState(() {
                              errorMessage = null;
                            });

                            if (!resetScreenKey.currentState!.validate()) {
                              return;
                            }

                            await ref.read(resetPasswordProvider.notifier).resetPassword(email: emailController.text);
                          },
                          value: l10n.reset,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

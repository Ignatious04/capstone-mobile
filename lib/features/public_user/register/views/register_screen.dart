import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/exceptions/auth_exception.dart';
import 'package:capstone/core/shared/widgets/custom_app_bar.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/custom_snackbar_helper.dart';
import 'package:capstone/core/shared/widgets/custom_text_field.dart';
import 'package:capstone/core/shared/providers/user_provider.dart';
import 'package:capstone/core/shared/widgets/google_sign_in_button.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/label_text.dart';
import 'package:capstone/features/public_user/register/providers/register_provider.dart';
import 'package:capstone/features/public_user/register/views/privacy_policy_screen.dart';
import 'package:capstone/features/public_user/register/views/terms_and_conditions_screen.dart';
import 'package:capstone/core/shared/widgets/section_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenPage();
}

class _RegisterScreenPage extends ConsumerState<RegisterScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  final registerScreenKey = GlobalKey<FormState>();
  String errorMessage = "";
  bool hasReadTermsAndConditions = false;
  bool hasReadPrivacyPolicy = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    ref.listen<AsyncValue<void>>(registerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stack) {
          final message = error is AuthException ? error.localized(l10n) : l10n.somethingWentWrong;
          CustomSnackbarHelper.show(context, text: message);
        },
      );

      if (previous?.isLoading == true && next.hasValue) {
        Navigator.pop(context);
      }
    });

    final isRegistering = ref.watch(registerProvider).isLoading;

    return Scaffold(
      appBar: CustomAppBar(value: l10n.registration),
      body: SafeArea(
        child: Form(
          key: registerScreenKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SectionTitle(
                          icon: Icons.app_registration,
                          title: l10n.userCredentials.toUpperCase(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        title: l10n.emailAddress.toUpperCase(),
                        controller: emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.fieldRequired(l10n.emailAddress);
                          }

                          return null;
                        },
                        onChanged: (value) {
                          ref.read(userProvider.notifier).setEmail(value);
                        },
                        hideErrorText: false,
                        isRequired: true,
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        title: l10n.password.toUpperCase(),
                        controller: passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.fieldRequired(l10n.password);
                          }

                          return null;
                        },
                        obscureText: true,
                        hideErrorText: false,
                        isRequired: true,
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        title: l10n.confirmPassword.toUpperCase(),
                        controller: confirmPasswordController,
                        validator: (value) {
                          if (value != passwordController.text) {
                            return l10n.passwordsDoNotMatch;
                          }

                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteractionIfError,
                        obscureText: true,
                        hideErrorText: false,
                        isRequired: true,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Checkbox(
                            value: hasReadTermsAndConditions,
                            onChanged: (value) {
                              setState(() {
                                hasReadTermsAndConditions = value ?? false;
                              });
                            },
                          ),
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return TermsAndConditionsScreen();
                                    },
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                child: LabelText(
                                  value: l10n.agreeToTerms,
                                  color: Colors.deepOrange,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: hasReadPrivacyPolicy,
                            onChanged: (value) {
                              setState(() {
                                hasReadPrivacyPolicy = value ?? false;
                              });
                            },
                          ),
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return PrivacyPolicyScreen();
                                    },
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                child: LabelText(
                                  value: l10n.acknowledgePrivacy,
                                  color: Colors.deepOrange,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: CustomElevatedButton(
                          isLoading: isRegistering,
                          onPressed: isRegistering || !hasReadTermsAndConditions || !hasReadPrivacyPolicy
                              ? null
                              : () async {
                                  if (!registerScreenKey.currentState!.validate()) {
                                    return;
                                  }

                                  await ref
                                      .read(registerProvider.notifier)
                                      .register(
                                        email: emailController.text,
                                        password: passwordController.text,
                                      );
                                },
                          value: l10n.signUp,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.black.withValues(alpha: 0.2))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: BodyText(value: l10n.or.toUpperCase(), color: Colors.black54),
                          ),
                          Expanded(child: Divider(color: Colors.black.withValues(alpha: 0.2))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      GoogleSignInButton(
                        label: l10n.signUpWithGoogle,
                        hasReadTermsAndConditions: hasReadTermsAndConditions,
                        hasReadPrivacyPolicy: hasReadPrivacyPolicy,
                        onSuccess: () => Navigator.pop(context),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

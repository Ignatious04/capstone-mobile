import 'package:capstone/core/exceptions/auth_exception.dart';
import 'package:capstone/core/shared/widgets/custom_app_bar.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/custom_snackbar_helper.dart';
import 'package:capstone/core/shared/widgets/custom_text_field.dart';
import 'package:capstone/core/shared/providers/user_provider.dart';
import 'package:capstone/core/shared/widgets/google_sign_in_button.dart';
import 'package:capstone/core/shared/widgets/text/section_title_text.dart';
import 'package:capstone/core/shared/widgets/text/supporting_info_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/features/public_user/register/providers/register_provider.dart';
import 'package:capstone/features/public_user/register/views/privacy_policy_screen.dart';
import 'package:capstone/features/public_user/register/views/terms_and_conditions_screen.dart';
import 'package:capstone/features/public_user/reporting/widgets/section_title.dart';
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
    ref.listen<AsyncValue<void>>(registerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stack) {
          final message = error is AuthException ? error.message : "Something went wrong. Please try again.";
          CustomSnackbarHelper.show(context, text: message);
        },
      );

      if (previous?.isLoading == true && next.hasValue) {
        Navigator.pop(context);
      }
    });

    final isRegistering = ref.watch(registerProvider).isLoading;

    return Scaffold(
      appBar: CustomAppBar(value: "Registration"),
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
                        child: const SectionTitle(
                          icon: Icons.app_registration,
                          title: "USER CREDENTIALS",
                        ),
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        title: "EMAIL ADDRESS",
                        controller: emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Email is required";
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
                        title: "PASSWORD",
                        controller: passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Password is required";
                          }

                          return null;
                        },
                        obscureText: true,
                        hideErrorText: false,
                        isRequired: true,
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        title: "CONFIRM PASSWORD",
                        controller: confirmPasswordController,
                        validator: (value) {
                          if (value != passwordController.text) {
                            return "Passwords do not match";
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
                                child: const SupportingInfoText(
                                  value: "I have read and agree to the Terms and Conditions",
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
                                child: const SupportingInfoText(
                                  value: "I have read and acknowledge the app's Privacy Policy.",
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
                          value: "Sign Up",
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.black.withValues(alpha: 0.2))),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: SectionTitleText(value: "OR", color: AppColors.lighterBlack),
                          ),
                          Expanded(child: Divider(color: Colors.black.withValues(alpha: 0.2))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      GoogleSignInButton(
                        label: "Sign up with Google",
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

import 'package:capstone/core/exceptions/auth_exception.dart';
import 'package:capstone/core/shared/widgets/custom_app_bar.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/custom_snackbar_helper.dart';
import 'package:capstone/core/shared/widgets/custom_text_field.dart';
import 'package:capstone/core/shared/providers/user_provider.dart';
import 'package:capstone/features/public_user/register/providers/register_provider.dart';
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
    return Scaffold(
      appBar: CustomAppBar(value: "Register"),
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
                      SizedBox(
                        width: double.infinity,
                        child: CustomElevatedButton(
                          onPressed: () async {
                            try {
                              if (!registerScreenKey.currentState!.validate()) {
                                return;
                              }

                              await ref
                                  .read(registerProvider.notifier)
                                  .register(
                                    email: emailController.text,
                                    password: passwordController.text,
                                  );
                            } on AuthException catch (e) {
                              setState(() {
                                errorMessage = e.message;
                              });
                              
                              if (!context.mounted) {
                                return;
                              }
                              CustomSnackbarHelper.show(context, text: errorMessage);
                            }
                          },
                          value: "Sign Up",
                        ),
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

import 'package:capstone/core/exceptions/auth_exception.dart';
import 'package:capstone/core/shared/widgets/custom_app_bar.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/custom_header_widget.dart';
import 'package:capstone/core/shared/widgets/custom_snackbar_helper.dart';
import 'package:capstone/core/shared/widgets/custom_text_field.dart';
import 'package:capstone/core/shared/widgets/text/deprecated/text_title_small.dart';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/providers/user_repository_provider.dart';
import 'package:capstone/core/shared/providers/user_provider.dart';
import 'package:capstone/features/reporting/widgets/section_title.dart';
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

                              final firebaseAuthRepository = ref.read(
                                firebaseAuthRepositoryProvider,
                              );

                              final credential = await firebaseAuthRepository.createAccount(
                                email: emailController.text,
                                password: passwordController.text,
                              );

                              final userID = credential.user!.uid;
                              ref.read(userProvider.notifier).setUserID(userID);
                              ref.read(userProvider.notifier).setEmail(emailController.text);

                              final user = ref
                                  .read(userProvider)
                                  .copyWith(
                                    createdAt: DateTime.now().millisecondsSinceEpoch,
                                    updatedAt: DateTime.now().millisecondsSinceEpoch,
                                  );

                              await ref.read(userRepositoryProvider).createUser(user);

                              if (!context.mounted) {
                                return;
                              }

                              Navigator.pop(context);
                            } on AuthException catch (e) {
                              setState(() {
                                errorMessage = e.message;
                              });
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

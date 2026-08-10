import 'package:capstone/core/exceptions/auth_exception.dart';
import 'package:capstone/core/shared/widgets/custom_app_bar.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/custom_header_widget.dart';
import 'package:capstone/core/shared/widgets/custom_snackbar_helper.dart';
import 'package:capstone/core/shared/widgets/custom_text_field.dart';
import 'package:capstone/core/shared/widgets/text/deprecated/text_title_small.dart';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/providers/user_provider.dart';
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
    return Scaffold(
      appBar: CustomAppBar(value: "Reset Password"),
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
                        title: "EMAIL ADDRESS",
                        controller: emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Email is required";
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
                            try {
                              setState(() {
                                errorMessage = null;
                              });

                              if (!resetScreenKey.currentState!.validate()) {
                                return;
                              }

                              final firebaseAuthRepository = ref.read(
                                firebaseAuthRepositoryProvider,
                              );

                              await firebaseAuthRepository.resetPassword(
                                email: emailController.text.trim(),
                              );

                              if (!context.mounted) {
                                return;
                              }

                              CustomSnackbarHelper.show(context, text: "Successful! Please check your email.");
                            } on AuthException catch (e) {
                              setState(() {
                                errorMessage = e.message;
                              });

                              CustomSnackbarHelper.show(context, text: errorMessage!);
                            }
                          },
                          value: "Reset",
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

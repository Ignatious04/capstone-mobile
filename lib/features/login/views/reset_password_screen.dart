import 'package:capstone/core/exceptions/auth_exception.dart';
import 'package:capstone/core/shared/widgets/custom_snackbar.dart';
import 'package:capstone/core/shared/widgets/custom_text_field.dart';
import 'package:capstone/core/shared/widgets/text/text_title_small.dart';
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
  final resetKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String? errorMessage = "";

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        ref.read(userProvider.notifier).reset();
        Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: resetKey,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextTitleSmall(
                          title: "RESET PASSWORD",
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 10),
                      CustomTextField(
                        title: "EMAIL ADDRESS *",
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
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            setState(() {
                              errorMessage = null;
                            });

                            if (!resetKey.currentState!.validate()) {
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

                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              CustomSnackbar(
                                text: "Successful! Please check your email",
                              ),
                            );
                          } on AuthException catch (e) {
                            setState(() {
                              errorMessage = e.message;
                            });

                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              CustomSnackbar(
                                text: errorMessage!,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text("Reset"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

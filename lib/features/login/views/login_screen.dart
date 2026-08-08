import 'package:capstone/core/exceptions/auth_exception.dart';
import 'package:capstone/core/shared/widgets/auth_wrapper.dart';
import 'package:capstone/core/shared/widgets/custom_snackbar_helper.dart';
import 'package:capstone/core/shared/widgets/custom_text_field.dart';
import 'package:capstone/core/shared/widgets/text/deprecated/text_body_medium.dart';
import 'package:capstone/core/shared/widgets/text/deprecated/text_body_small.dart';
import 'package:capstone/core/shared/widgets/text/deprecated/text_title_medium.dart';
import 'package:capstone/core/shared/widgets/text/deprecated/text_title_small.dart';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/features/register/register_screen.dart';
import 'package:capstone/features/login/views/reset_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final loginKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String? errorMessage;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 200,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        elevation: 5.0,
        shadowColor: Colors.black.withValues(alpha: 1),
        flexibleSpace: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.deepOrange,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TextTitleMedium(
                  title: "MEAS",
                  color: Colors.white,
                ),
                const TextTitleSmall(
                  title: "Mobile Emergency Access System",
                  color: Colors.white,
                  isBold: false,
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: loginKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextTitleSmall(title: "Welcome!"),
                const TextBodySmall(
                  title: "Log in to your account",
                  isBold: false,
                ),
                const SizedBox(
                  height: 30.0,
                ),
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
                  onChanged: (value) {},
                ),
                const SizedBox(
                  height: 10.0,
                ),
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
                  onChanged: (value) {},
                ),
                if (errorMessage != null) ...[
                  TextBodySmall(
                    title: errorMessage!,
                    color: Colors.red,
                    isBold: false,
                  ),
                ],
                const SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return ResetPasswordScreen();
                          },
                        ),
                      );
                    },
                    child: const TextBodySmall(
                      title: "Forgot password?",
                      isBold: false,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      try {
                        setState(() {
                          errorMessage = null;
                        });

                        if (!loginKey.currentState!.validate()) {
                          return;
                        }

                        final firebaseAuthRepository = ref.read(
                          firebaseAuthRepositoryProvider,
                        );

                        await firebaseAuthRepository.signIn(
                          email: emailController.text.trim(),
                          password: passwordController.text,
                        );

                        if (!context.mounted) {
                          return;
                        }

                        CustomSnackbarHelper.show(context, text: "Logged in successfully!");

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return AuthWrapper();
                            },
                          ),
                          (route) => false,
                        );
                      } on AuthException catch (e) {
                        setState(() {
                          errorMessage = e.message;
                        });
                      }
                    },
                    child: const Text("Log In"),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: Colors.black.withValues(alpha: 0.2),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const TextBodyMedium(
                      title: "OR",
                      color: AppColors.lighterBlack,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: Colors.black.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const TextBodySmall(
                      title: "Didn't have an account?",
                      isBold: false,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return RegisterScreen();
                            },
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: TextBodySmall(
                          title: "Create one",
                          color: Colors.deepOrange,
                          isBold: false,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

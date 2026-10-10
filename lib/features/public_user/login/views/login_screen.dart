import 'package:capstone/core/exceptions/auth_exception.dart';
import 'package:capstone/core/shared/widgets/custom_circular_progress_indicator.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/custom_snackbar_helper.dart';
import 'package:capstone/core/shared/widgets/custom_text_field.dart';
import 'package:capstone/core/shared/widgets/google_sign_in_button.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/headline_text.dart';
import 'package:capstone/core/shared/widgets/text/label_text.dart';
import 'package:capstone/core/shared/widgets/text/title_text.dart';
import 'package:capstone/features/public_user/login/providers/login_provider.dart';
import 'package:capstone/features/public_user/register/views/register_screen.dart';
import 'package:capstone/features/public_user/login/views/reset_password_screen.dart';
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
    final loginState = ref.watch(loginProvider);
    final isLoading = loginState is AsyncLoading;

    ref.listen(loginProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          setState(() {
            errorMessage = error is AuthException ? error.message : "Something went wrong";
          });
        },
        data: (_) {
          if (previous is AsyncLoading) {
            CustomSnackbarHelper.show(context, text: "Logged in successfully!");
          }
        },
      );
    });

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
                const HeadlineText(
                  value: "Saup Angeles",
                  color: Colors.white,
                  isBold: true,
                ),
                const TitleText(
                  value: "Mobile Emergency Access System",
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: loginKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TitleText(
                        value: "Welcome!",
                        color: Colors.black,
                      ),
                      const BodyText(
                        value: "Log in to your account",
                        color: Colors.black54,
                      ),
                      const SizedBox(
                        height: 20.0,
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
                        LabelText(
                          value: errorMessage!,
                          color: Colors.red[700]!,
                        ),
                      ],
                      const SizedBox(
                        height: 10,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
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
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5.0),
                            child: const LabelText(
                              value: "Forgot password?",
                              color: Colors.deepOrange,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: isLoading
                            ? Center(
                                child: CustomCircularProgressIndicator(),
                              )
                            : CustomElevatedButton(
                                onPressed: () async {
                                  setState(() => errorMessage = null);

                                  if (!loginKey.currentState!.validate()) return;

                                  await ref
                                      .read(loginProvider.notifier)
                                      .signIn(
                                        email: emailController.text,
                                        password: passwordController.text,
                                      );
                                },
                                value: "Log In",
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
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          const BodyText(
                            value: "OR",
                            color: Colors.black54,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const GoogleSignInButton(),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const LabelText(value: "Didn't have an account?", color: Colors.black54),
                          SizedBox(width: 5),
                          InkWell(
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
                              padding: const EdgeInsets.symmetric(horizontal: 5.0),
                              child: LabelText(
                                value: "Create one",
                                color: Colors.deepOrange,
                              ),
                            ),
                          ),
                        ],
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

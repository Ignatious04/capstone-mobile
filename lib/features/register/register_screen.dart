import 'package:capstone/core/shared/widgets/custom_text_field.dart';
import 'package:capstone/core/shared/widgets/text/text_title_small.dart';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/providers/user_repository_provider.dart';
import 'package:capstone/core/shared/providers/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      appBar: AppBar(),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextTitleSmall(
                      title: "USER CREDENTIALS",
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
                    onChanged: (value) {
                      ref.read(userProvider.notifier).setEmail(value);
                    },
                  ),
                  SizedBox(height: 10),
                  CustomTextField(
                    title: "PASSWORD *",
                    controller: passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Password is required";
                      }

                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  CustomTextField(
                    title: "CONFIRM PASSWORD *",
                    controller: confirmPasswordController,
                    validator: (value) {
                      if (value != passwordController.text) {
                        return "Passwords do not match";
                      }

                      return null;
                    },
                    hideErrorText: false,
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      try {
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
                      } on FirebaseAuthException catch (e) {
                        setState(() {
                          errorMessage = e.message ?? "There is an error.";
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text("Sign Up"),
                  ),
                  SizedBox(height: 10),
                  Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

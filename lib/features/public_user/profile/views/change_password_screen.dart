import 'package:capstone/core/exceptions/auth_exception.dart';
import 'package:capstone/core/shared/providers/change_password_provider.dart';
import 'package:capstone/core/shared/widgets/custom_app_bar.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/custom_snackbar_helper.dart';
import 'package:capstone/core/shared/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final formKey = GlobalKey<FormState>();
  final currentController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();

  @override
  void dispose() {
    currentController.dispose();
    newController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(changePasswordProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          CustomSnackbarHelper.show(
            context,
            text: error is AuthException ? error.message : "Something went wrong. Please try again.",
          );
        },
      );

      if (previous?.isLoading == true && next.hasValue) {
        CustomSnackbarHelper.show(context, text: "Password updated.");
        Navigator.pop(context);
      }
    });

    final isLoading = ref.watch(changePasswordProvider).isLoading;

    return Scaffold(
      appBar: CustomAppBar(value: "Change Password"),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CustomTextField(
                  title: "CURRENT PASSWORD",
                  controller: currentController,
                  obscureText: true,
                  hideErrorText: false,
                  isRequired: true,
                  validator: (value) => (value == null || value.isEmpty) ? "Current password is required" : null,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  title: "NEW PASSWORD",
                  controller: newController,
                  obscureText: true,
                  hideErrorText: false,
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "New password is required";
                    if (value.length < 6) return "Password must be at least 6 characters";
                    if (value == currentController.text) return "New password must be different";
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  title: "CONFIRM NEW PASSWORD",
                  controller: confirmController,
                  obscureText: true,
                  hideErrorText: false,
                  isRequired: true,
                  autovalidateMode: AutovalidateMode.onUserInteractionIfError,
                  validator: (value) => value != newController.text ? "Passwords do not match" : null,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: CustomElevatedButton(
                    value: isLoading ? "Updating..." : "Update Password",
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;
                            await ref
                                .read(changePasswordProvider.notifier)
                                .changePassword(
                                  currentPassword: currentController.text,
                                  newPassword: newController.text,
                                );
                          },
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
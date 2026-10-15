import 'package:capstone/core/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

    ref.listen<AsyncValue<void>>(changePasswordProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          CustomSnackbarHelper.show(
            context,
            text: error is AuthException
                ? error.localized(AppLocalizations.of(context)!)
                : AppLocalizations.of(context)!.somethingWentWrong,
          );
        },
      );

      if (previous?.isLoading == true && next.hasValue) {
        CustomSnackbarHelper.show(context, text: l10n.passwordUpdated);
        Navigator.pop(context);
      }
    });

    final isLoading = ref.watch(changePasswordProvider).isLoading;

    return Scaffold(
      appBar: CustomAppBar(value: l10n.changePassword),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CustomTextField(
                  title: l10n.currentPassword.toUpperCase(),
                  controller: currentController,
                  obscureText: true,
                  hideErrorText: false,
                  isRequired: true,
                  validator: (value) => (value == null || value.isEmpty) ? l10n.fieldRequired(l10n.currentPassword) : null,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  title: l10n.newPassword.toUpperCase(),
                  controller: newController,
                  obscureText: true,
                  hideErrorText: false,
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return l10n.fieldRequired(l10n.newPassword);
                    if (value.length < 6) return l10n.passwordMin6;
                    if (value == currentController.text) return l10n.newPasswordMustDiffer;
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  title: l10n.confirmNewPassword.toUpperCase(),
                  controller: confirmController,
                  obscureText: true,
                  hideErrorText: false,
                  isRequired: true,
                  autovalidateMode: AutovalidateMode.onUserInteractionIfError,
                  validator: (value) => value != newController.text ? l10n.passwordsDoNotMatch : null,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: CustomElevatedButton(
                    value: isLoading ? l10n.updating : l10n.updatePassword,
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
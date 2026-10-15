import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/exceptions/auth_exception.dart';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/widgets/custom_app_bar.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/custom_snackbar_helper.dart';
import 'package:capstone/core/shared/widgets/custom_text_field.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/title_text.dart';
import 'package:capstone/features/public_user/profile/providers/deactivate_account_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeactivateAccountScreen extends ConsumerStatefulWidget {
  const DeactivateAccountScreen({super.key});

  @override
  ConsumerState<DeactivateAccountScreen> createState() => _DeactivateAccountScreenState();
}

class _DeactivateAccountScreenState extends ConsumerState<DeactivateAccountScreen> {
  final formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _onDeactivate(bool usesPassword) async {
    if (usesPassword && !formKey.currentState!.validate()) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: BodyText(value: AppLocalizations.of(context)!.deactivateTitle),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
        actions: [
          CustomElevatedButton(onPressed: () => Navigator.pop(context, false), value: AppLocalizations.of(context)!.cancel),
          CustomElevatedButton(onPressed: () => Navigator.pop(context, true), value: AppLocalizations.of(context)!.deactivate),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final deactivated = await ref
        .read(deactivateAccountProvider.notifier)
        .deactivate(password: usesPassword ? passwordController.text : null);
    if (!mounted) return;

    final state = ref.read(deactivateAccountProvider);
    if (state.hasError) {
      final error = state.error;
      CustomSnackbarHelper.show(
        context,
        text: error is AuthException
            ? error.localized(AppLocalizations.of(context)!)
            : AppLocalizations.of(context)!.somethingWentWrong,
      );
    } else if (deactivated) {
      CustomSnackbarHelper.show(context, text: AppLocalizations.of(context)!.accountDeactivated);
      // AuthWrapper already switched to LoginScreen underneath; clear the
      // routes pushed on top (Safety Profile, this screen) so it shows.
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final usesPassword = ref.read(firebaseAuthRepositoryProvider).hasPasswordProvider;
    final isLoading = ref.watch(deactivateAccountProvider).isLoading;

    return PopScope(
      canPop: !isLoading,
      child: Scaffold(
        appBar: CustomAppBar(value: l10n.deactivateAccount),
        body: SafeArea(
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.pause_circle_outline, size: 50, color: Colors.deepOrange),
                  const SizedBox(height: 10),
                  TitleText(value: l10n.deactivateHeading, alignment: TextAlign.center),
                  const SizedBox(height: 10),
                  BodyText(
                    value:
                        l10n.deactivateBody,
                    color: Colors.black54,
                    alignment: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  if (usesPassword)
                    CustomTextField(
                      title: l10n.confirmYourPassword.toUpperCase(),
                      controller: passwordController,
                      obscureText: true,
                      hideErrorText: false,
                      isRequired: true,
                      validator: (value) => (value == null || value.isEmpty) ? l10n.fieldRequired(l10n.password) : null,
                    )
                  else
                    BodyText(
                      value: l10n.googleConfirmNote,
                      color: Colors.black54,
                      alignment: TextAlign.center,
                    ),
                  const SizedBox(height: 20),
                  CustomElevatedButton(
                    value: isLoading ? l10n.deactivating : l10n.deactivateMyAccount,
                    onPressed: isLoading ? null : () => _onDeactivate(usesPassword),
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

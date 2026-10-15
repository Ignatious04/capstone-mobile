import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/exceptions/auth_exception.dart';
import 'package:capstone/core/shared/widgets/custom_app_bar.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/custom_snackbar_helper.dart';
import 'package:capstone/core/shared/widgets/custom_text_field.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/features/public_user/profile/providers/deactivate_account_provider.dart';
import 'package:capstone/features/public_user/profile/providers/reactivation_phone_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReactivationVerificationScreen extends ConsumerStatefulWidget {
  const ReactivationVerificationScreen({super.key, required this.contactNumber});

  /// Stored, already-verified number, e.g. "+639171234567".
  final String contactNumber;

  @override
  ConsumerState<ReactivationVerificationScreen> createState() => _ReactivationVerificationScreenState();
}

class _ReactivationVerificationScreenState extends ConsumerState<ReactivationVerificationScreen> {
  final otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reactivationPhoneProvider.notifier).sendCode(widget.contactNumber);
    });
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyAndReactivate() async {
    await ref.read(reactivationPhoneProvider.notifier).verifyCode(otpController.text.trim());
    if (!mounted || ref.read(reactivationPhoneProvider).status.hasError) return;

    await ref.read(deactivateAccountProvider.notifier).reactivate();
    if (!mounted || ref.read(deactivateAccountProvider).hasError) return;

    CustomSnackbarHelper.show(context, text: AppLocalizations.of(context)!.accountReactivated);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final phoneState = ref.watch(reactivationPhoneProvider);
    final isSending = phoneState.status is AsyncLoading && !phoneState.codeSent;
    final isVerifying = phoneState.status is AsyncLoading && phoneState.codeSent;
    final isReactivating = ref.watch(deactivateAccountProvider).isLoading;

    ref.listen(reactivationPhoneProvider, (previous, next) {
      next.status.whenOrNull(
        error: (error, _) {
          final message = error is AuthException
              ? error.localized(AppLocalizations.of(context)!)
              : AppLocalizations.of(context)!.invalidOrExpiredCode;
          CustomSnackbarHelper.show(context, text: message);
        },
      );
    });

    ref.listen(deactivateAccountProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          final message = error is AuthException
              ? error.localized(AppLocalizations.of(context)!)
              : AppLocalizations.of(context)!.somethingWentWrong;
          CustomSnackbarHelper.show(context, text: message);
        },
      );
    });

    return Scaffold(
      appBar: CustomAppBar(value: l10n.verifyItsYou),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BodyText(
                value: !phoneState.codeSent
                    ? l10n.sendingCodeTo(widget.contactNumber)
                    : l10n.enterCodeSentTo(widget.contactNumber),
                color: Colors.black54,
                alignment: TextAlign.center,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                title: l10n.enterCode.toUpperCase(),
                controller: otpController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                hideErrorText: true,
                enabled: phoneState.codeSent,
                onChanged: (value) {},
              ),
              const SizedBox(height: 10),
              CustomElevatedButton(
                value: (isVerifying || isReactivating) ? l10n.verifying : l10n.verifyAndReactivate,
                onPressed: (isVerifying || isReactivating || !phoneState.codeSent) ? null : _verifyAndReactivate,
              ),
              TextButton(
                onPressed: isSending ? null : () => ref.read(reactivationPhoneProvider.notifier).sendCode(widget.contactNumber),
                child: Text(l10n.resendCode),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/exceptions/auth_exception.dart';
import 'package:capstone/core/shared/providers/user_provider.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/custom_snackbar_helper.dart';
import 'package:capstone/core/shared/widgets/custom_text_field.dart';
import 'package:capstone/core/shared/widgets/section_title.dart';
import 'package:capstone/features/public_user/setup/providers/phone_verification_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PhoneVerificationScreen extends ConsumerStatefulWidget {
  const PhoneVerificationScreen({super.key});

  @override
  ConsumerState<PhoneVerificationScreen> createState() => _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends ConsumerState<PhoneVerificationScreen> {
  TextEditingController contactNumController = TextEditingController();
  TextEditingController otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    contactNumController.dispose();
    otpController.dispose();
    super.dispose();
  }

  void handleSendCode() {
    if (contactNumController.text.trim().length != 10) {
      CustomSnackbarHelper.show(context, text: AppLocalizations.of(context)!.invalidPhone10);
      return;
    }
    final e164Number = "+63${contactNumController.text.trim()}";
    ref.read(phoneVerificationProvider.notifier).sendCode(e164Number);
  }

  void handleVerifyCode() {
    if (otpController.text.trim().isEmpty) return;
    ref.read(phoneVerificationProvider.notifier).verifyCode(otpController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final phoneState = ref.watch(phoneVerificationProvider);
    final isVerified = ref.watch(userProvider.select((u) => u.isContactNumberVerified));
    final isSending = phoneState.status is AsyncLoading && !phoneState.codeSent;
    final isVerifying = phoneState.status is AsyncLoading && phoneState.codeSent;

    ref.listen(phoneVerificationProvider, (previous, next) {
      if (next.isVerified && previous?.isVerified != true) {
        final e164Number = "+63${contactNumController.text.trim()}";
        ref.read(userProvider.notifier).setContactNumber(e164Number);
        ref.read(userProvider.notifier).setIsContactNumberVerified(true);
        CustomSnackbarHelper.show(context, text: l10n.phoneVerifiedOk);
      }

      next.status.whenOrNull(
        error: (error, _) {
          final message = error is AuthException
              ? error.localized(AppLocalizations.of(context)!)
              : AppLocalizations.of(context)!.somethingWentWrong;
          CustomSnackbarHelper.show(context, text: message);
        },
      );
    });

    return SingleChildScrollView(
      child: Column(
        children: [
          SectionTitle(icon: Icons.contact_phone, title: l10n.registerPhoneNumber.toUpperCase()),
          const SizedBox(height: 10),
          CustomTextField(
            key: ValueKey('phone-field-$isVerified'),
            title: l10n.contactNumber.toUpperCase(),
            prefixText: "+63 ",
            controller: contactNumController,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) return l10n.fieldRequired(l10n.contactNumber);
              if (value.length != 10) return l10n.invalidPhone10;
              if (!isVerified) return l10n.pleaseVerifyPhone;
              return null;
            },
            onChanged: (value) {
              if (isVerified) {
                ref.read(userProvider.notifier).setIsContactNumberVerified(false);
                ref.read(phoneVerificationProvider.notifier).reset();
              }
            },
            enabled: !isVerified,
            isRequired: true,
            hideErrorText: false,
          ),
          const SizedBox(height: 10),
          if (isVerified) ...[
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 20),
                SizedBox(width: 6),
                Text(l10n.phoneVerified, style: TextStyle(color: Colors.green)),
              ],
            ),
          ] else if (!phoneState.codeSent) ...[
            CustomElevatedButton(
              value: isSending ? l10n.sending : l10n.sendVerificationCode,
              onPressed: isSending ? () {} : handleSendCode,
            ),
          ] else ...[
            CustomTextField(
              title: l10n.enterCode.toUpperCase(),
              controller: otpController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              hideErrorText: true,
              onChanged: (value) {},
            ),
            const SizedBox(height: 10),
            CustomElevatedButton(
              value: isVerifying ? l10n.verifying : l10n.verifyCode,
              onPressed: isVerifying ? () {} : handleVerifyCode,
            ),
            TextButton(onPressed: isSending ? null : handleSendCode, child: Text(l10n.resendCode)),
          ],
        ],
      ),
    );
  }
}

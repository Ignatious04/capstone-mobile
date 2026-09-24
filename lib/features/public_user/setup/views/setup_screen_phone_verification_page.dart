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

class SetupScreenPhoneVerificationPage extends ConsumerStatefulWidget {
  const SetupScreenPhoneVerificationPage({super.key});

  @override
  ConsumerState<SetupScreenPhoneVerificationPage> createState() => _SetupScreenContactNumberPageState();
}

class _SetupScreenContactNumberPageState extends ConsumerState<SetupScreenPhoneVerificationPage> {
  TextEditingController contactNumController = TextEditingController();
  TextEditingController otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider);
    contactNumController.text = user.contactNumber.replaceFirst('+63', '');
  }

  @override
  void dispose() {
    contactNumController.dispose();
    otpController.dispose();
    super.dispose();
  }

  void handleSendCode() {
    if (contactNumController.text.trim().length != 10) {
      CustomSnackbarHelper.show(context, text: "Enter a valid 10-digit number.");
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
    final phoneState = ref.watch(phoneVerificationProvider);
    final isVerified = ref.watch(userProvider.select((u) => u.isContactNumberVerified));
    final isSending = phoneState.status is AsyncLoading && !phoneState.codeSent;
    final isVerifying = phoneState.status is AsyncLoading && phoneState.codeSent;

    ref.listen(phoneVerificationProvider, (previous, next) {
      if (next.isVerified && previous?.isVerified != true) {
        final e164Number = "+63${contactNumController.text.trim()}";
        ref.read(userProvider.notifier).setContactNumber(e164Number);
        ref.read(userProvider.notifier).setIsContactNumberVerified(true);
        CustomSnackbarHelper.show(context, text: "Phone number verified!");
      }

      next.status.whenOrNull(
        error: (error, _) {
          final message = error is AuthException ? error.message : "Something went wrong.";
          CustomSnackbarHelper.show(context, text: message);
        },
      );
    });

    return SingleChildScrollView(
      child: Column(
        children: [
          const SectionTitle(icon: Icons.contact_phone, title: "REGISTER PHONE NUMBER"),
          const SizedBox(height: 10),
          CustomTextField(
            title: "CONTACT NUMBER",
            prefixText: "+63 ",
            autovalidateMode: AutovalidateMode.onUserInteractionIfError,
            controller: contactNumController,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) return "Contact number is required";
              if (value.length != 10) return "Enter a valid 10-digit number";
              if (!isVerified) return "Please verify your phone number";
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
            const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 20),
                SizedBox(width: 6),
                Text("Phone number verified", style: TextStyle(color: Colors.green)),
              ],
            ),
          ] else if (!phoneState.codeSent) ...[
            CustomElevatedButton(
              value: isSending ? "Sending..." : "Send verification code",
              onPressed: isSending ? () {} : handleSendCode,
            ),
          ] else ...[
            CustomTextField(
              title: "ENTER CODE",
              controller: otpController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              hideErrorText: true,
              onChanged: (value) {},
            ),
            const SizedBox(height: 10),
            CustomElevatedButton(
              value: isVerifying ? "Verifying..." : "Verify code",
              onPressed: isVerifying ? () {} : handleVerifyCode,
            ),
            TextButton(onPressed: isSending ? null : handleSendCode, child: const Text("Resend code")),
          ],
        ],
      ),
    );
  }
}

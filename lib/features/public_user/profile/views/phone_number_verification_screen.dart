import 'package:capstone/core/exceptions/auth_exception.dart';
import 'package:capstone/core/shared/widgets/custom_app_bar.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/custom_snackbar_helper.dart';
import 'package:capstone/core/shared/widgets/custom_text_field.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/features/public_user/setup/providers/phone_verification_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PhoneNumberVerificationScreen extends ConsumerStatefulWidget {
  const PhoneNumberVerificationScreen({super.key, required this.currentContactNumber});

  /// Stored format, e.g. "+639171234567".
  final String currentContactNumber;

  @override
  ConsumerState<PhoneNumberVerificationScreen> createState() => _PhoneNumberVerificationScreenState();
}

class _PhoneNumberVerificationScreenState extends ConsumerState<PhoneNumberVerificationScreen> {
  final otpController = TextEditingController();

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phoneState = ref.watch(phoneVerificationProvider);
    final isSending = phoneState.status is AsyncLoading && !phoneState.codeSent;
    final isVerifying = phoneState.status is AsyncLoading && phoneState.codeSent;

    ref.listen(phoneVerificationProvider, (previous, next) {
      // Relies on isContactNumberVerified being persisted to Firestore
      // inside PhoneVerificationNotifier itself (see the earlier fix to
      // sendCode's onVerificationCompleted and to verifyCode).
      if (next.isVerified && previous?.isVerified != true) {
        CustomSnackbarHelper.show(context, text: "Phone number verified!");
        Navigator.pop(context, true);
      }

      next.status.whenOrNull(
        error: (error, _) {
          final message = error is AuthException ? error.message : "Something went wrong.";
          CustomSnackbarHelper.show(context, text: message);
        },
      );
    });

    return Scaffold(
      appBar: CustomAppBar(value: "Verify Phone Number"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BodyText(
                value:
                    "We'll send a code to ${widget.currentContactNumber} to verify it's still yours. "
                    "This lets you deactivate and later reactivate your account securely.",
                color: Colors.black54,
                alignment: TextAlign.center,
              ),
              const SizedBox(height: 10),
              if (!phoneState.codeSent) ...[
                CustomElevatedButton(
                  value: isSending ? "Sending..." : "Send verification code",
                  onPressed: isSending
                      ? null
                      : () => ref.read(phoneVerificationProvider.notifier).sendCode(widget.currentContactNumber),
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
                  onPressed: isVerifying
                      ? null
                      : () => ref.read(phoneVerificationProvider.notifier).verifyCode(otpController.text.trim()),
                ),
                TextButton(
                  onPressed: isSending
                      ? null
                      : () => ref.read(phoneVerificationProvider.notifier).sendCode(widget.currentContactNumber),
                  child: const Text("Resend code"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

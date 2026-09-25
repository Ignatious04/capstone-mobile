import 'package:capstone/core/exceptions/auth_exception.dart';
import 'package:capstone/core/shared/providers/google_sign_in_provider.dart';
import 'package:capstone/core/shared/widgets/custom_circular_progress_indicator.dart';
import 'package:capstone/core/shared/widgets/custom_snackbar_helper.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GoogleSignInButton extends ConsumerWidget {
  const GoogleSignInButton({
    super.key,
    this.label = "Continue with Google",
    this.hasReadTermsAndConditions,
    this.hasReadPrivacyPolicy,
    this.isSignIn = true,
    this.onSuccess,
  });

  final String label;
  final bool? hasReadTermsAndConditions;
  final bool? hasReadPrivacyPolicy;
  final bool isSignIn;
  final VoidCallback? onSuccess;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(googleSignInProvider).isLoading;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading || hasReadTermsAndConditions == false || hasReadPrivacyPolicy == false
            ? null
            : () async {
                final signedIn = await ref.read(googleSignInProvider.notifier).signIn();
                if (!context.mounted) return; // LoginScreen gets swapped out by AuthWrapper

                final state = ref.read(googleSignInProvider);
                if (state.hasError) {
                  final error = state.error;
                  CustomSnackbarHelper.show(
                    context,
                    text: error is AuthException ? error.message : "Something went wrong. Please try again.",
                  );
                } else if (signedIn) {
                  onSuccess?.call();
                }
              },
        icon: isLoading
            ? const SizedBox(width: 20, height: 20, child: CustomCircularProgressIndicator())
            : Image.asset(
                'assets/images/google_logo.png',
                width: 25,
                height: 25,
                errorBuilder: (_, _, _) => const Icon(Icons.g_mobiledata, size: 28),
              ),
        label: BodyText(
          value: label,
          isBold: true,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

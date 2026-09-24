import 'package:capstone/core/exceptions/auth_exception.dart';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/custom_snackbar_helper.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/title_text.dart';
import 'package:capstone/features/public_user/profile/providers/deactivate_account_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeactivatedScreen extends ConsumerWidget {
  const DeactivatedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<void>>(deactivateAccountProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          CustomSnackbarHelper.show(
            context,
            text: error is AuthException ? error.message : "Something went wrong. Please try again.",
          );
        },
      );
    });

    final isLoading = ref.watch(deactivateAccountProvider).isLoading;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.pause_circle_outline, size: 50, color: Colors.deepOrange),
              const SizedBox(height: 10),
              const TitleText(value: "Your account is deactivated", alignment: TextAlign.center),
              const SizedBox(height: 10),
              const BodyText(
                value: "Your profile and reports are safe. Reactivate to use the app and send reports again.",
                color: Colors.black54,
                alignment: TextAlign.center,
              ),
              const SizedBox(height: 20),
              CustomElevatedButton(
                value: isLoading ? "Reactivating..." : "Reactivate Account",
                onPressed: isLoading ? null : () => ref.read(deactivateAccountProvider.notifier).reactivate(),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: isLoading ? null : () => ref.read(firebaseAuthRepositoryProvider).signOut(),
                child: const Text("Log out"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

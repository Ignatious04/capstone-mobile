import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/exceptions/auth_exception.dart';
import 'package:capstone/core/shared/models/user_model.dart';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/custom_snackbar_helper.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/title_text.dart';
import 'package:capstone/features/public_user/profile/providers/deactivate_account_provider.dart';
import 'package:capstone/features/public_user/profile/views/reactivation_verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeactivatedScreen extends ConsumerWidget {
  const DeactivatedScreen({super.key, required this.user,});

  final UserModel user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    ref.listen<AsyncValue<void>>(deactivateAccountProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          CustomSnackbarHelper.show(
            context,
            text: error is AuthException ? error.localized(l10n) : l10n.somethingWentWrong,
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
              TitleText(value: l10n.deactivatedTitle, alignment: TextAlign.center),
              const SizedBox(height: 10),
              BodyText(
                value: l10n.deactivatedBody,
                color: Colors.black54,
                alignment: TextAlign.center,
              ),
              const SizedBox(height: 20),
              CustomElevatedButton(
    value: l10n.reactivateAccount,
    onPressed: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReactivationVerificationScreen(contactNumber: user.contactNumber)),
    ),
  ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: isLoading ? null : () => ref.read(firebaseAuthRepositoryProvider).signOut(),
                child: Text(l10n.logout),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

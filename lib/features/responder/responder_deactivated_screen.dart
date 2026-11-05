import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/providers/responder_active_guard_provider.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/title_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResponderDeactivatedScreen extends ConsumerWidget {
  const ResponderDeactivatedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.person_off_outlined, size: 50, color: Colors.deepOrange),
              const SizedBox(height: 10),
              TitleText(value: l10n.responderDeactivatedTitle, alignment: TextAlign.center),
              const SizedBox(height: 10),
              BodyText(
                value: l10n.responderDeactivatedBody,
                color: Colors.black54,
                alignment: TextAlign.center,
              ),
              const SizedBox(height: 20),
              CustomElevatedButton(
                value: l10n.backToLogin,
                onPressed: () async {
                  await ref.read(firebaseAuthRepositoryProvider).signOut();
                  ref.read(responderDeactivatedProvider.notifier).dismiss();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

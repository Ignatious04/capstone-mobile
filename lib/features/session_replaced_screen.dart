import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/providers/session_provider.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/title_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionReplacedScreen extends ConsumerWidget {
  const SessionReplacedScreen({super.key});

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
              const Icon(Icons.devices_other, size: 50, color: Colors.deepOrange),
              const SizedBox(height: 10),
              TitleText(value: l10n.signedOutTitle, alignment: TextAlign.center),
              const SizedBox(height: 10),
              BodyText(
                value: l10n.signedOutBody,
                color: Colors.black54,
                alignment: TextAlign.center,
              ),
              const SizedBox(height: 20),
              CustomElevatedButton(
                value: l10n.backToLogin,
                onPressed: () => ref.read(sessionReplacedProvider.notifier).dismiss(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
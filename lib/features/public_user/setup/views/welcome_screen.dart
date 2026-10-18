import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/headline_text.dart';
import 'package:capstone/core/shared/widgets/text/title_text.dart';
import 'package:capstone/features/public_user/setup/views/setup_screen_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.deepOrange,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 100,
                    color: Colors.black54,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const HeadlineText(
                    value: "Saup Angeles",
                    isBold: true,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TitleText(
                    value: l10n.hello,
                    color: Colors.black54,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  BodyText(
                    value: l10n.welcomeSetup,
                    alignment: TextAlign.center,
                    color: Colors.black54,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: CustomElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SetupScreenPageView(),
                          ),
                        );
                      },
                      value: l10n.proceed,
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: CustomElevatedButton(
                      backgroundColor: Colors.black54,
                      onPressed: () async {
                        await ref.read(firebaseAuthRepositoryProvider).signOut();
                      },
                      value: l10n.signOut,
                    ),
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

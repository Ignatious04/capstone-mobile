import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/headline_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: AppColors.themeColor,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check,
                    size: 75,
                    color: AppColors.darkerGreen,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  HeadlineText(
                    value: l10n.onboardingTitle,
                    alignment: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  BodyText(
                    value:
                        l10n.onboardingBody,
                    alignment: TextAlign.center,
                    color: AppColors.blackTextMuted,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.themeColor,
                      ),
                      onPressed: () {
                        debugPrint("Pressed");
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      child: Text(l10n.proceedToHome),
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

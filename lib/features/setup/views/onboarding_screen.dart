import 'package:capstone/core/shared/widgets/location_gate.dart';
import 'package:capstone/core/shared/widgets/text/deprecated/text_body_small.dart';
import 'package:capstone/core/shared/widgets/text/deprecated/text_title_medium.dart';
import 'package:capstone/core/shared/widgets/text/deprecated/text_title_small.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  const TextTitleMedium(
                    title: "MEAS",
                    isBold: true,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const TextTitleSmall(title: "Account and Safety Profile Saved"),
                  const SizedBox(
                    height: 20,
                  ),
                  const TextBodySmall(
                    title:
                        "Your personal information has been successfully saved and secured. You're now ready to access emergency services through the application.",
                    alignment: TextAlign.center,
                    color: AppColors.darkerGrey,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                      ),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return LocationGate();
                            },
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text("Proceed to Home"),
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

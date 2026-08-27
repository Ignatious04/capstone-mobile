import 'package:capstone/core/shared/widgets/location_gate.dart';
import 'package:capstone/core/shared/widgets/text/screen_title_text.dart';
import 'package:capstone/core/shared/widgets/text/sub_title_text.dart';
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
                  const ScreenTitleText(
                    value: "MEAS",
                    isBold: true,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const SubtitleText(value: "Account and Safety Profile Saved"),
                  const SizedBox(
                    height: 20,
                  ),
                  const SubtitleText(
                    value:
                        "Your personal information has been successfully saved and secured. You're now ready to access emergency services through the application.",
                    alignment: TextAlign.center,
                    maxLines: 4,
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

import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/title_text.dart';
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
                  const TitleText(
                    value: "Saup Angeles",
                    isBold: true,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const BodyText(value: "Account and Safety Profile Saved"),
                  const SizedBox(
                    height: 20,
                  ),
                  const BodyText(
                    value:
                        "Your personal information has been successfully saved and secured. You're now ready to access emergency services through the application.",
                    alignment: TextAlign.center,
                    color: Colors.black54,
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
                        debugPrint("Pressed");
                        Navigator.popUntil(context, (route) => route.isFirst);
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

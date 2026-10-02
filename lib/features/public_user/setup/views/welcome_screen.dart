import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/title_text.dart';
import 'package:capstone/features/public_user/setup/views/setup_screen_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  TitleText(value: "Saup Angeles"),
                  SizedBox(
                    height: 10,
                  ),
                  TitleText(value: "Hello!"),
                  SizedBox(
                    height: 10,
                  ),
                  BodyText(
                    value: "Let's start off by setting up your account.",
                    alignment: TextAlign.center,
                    color: Colors.black54,
                  ),
                  SizedBox(
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
                      value: "Proceed",
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: CustomElevatedButton(
                      backgroundColor: Colors.black54,
                      onPressed: () async {
                        await ref.read(firebaseAuthRepositoryProvider).signOut();
                      },
                      value: "Sign out",
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

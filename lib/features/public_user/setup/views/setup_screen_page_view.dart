import 'package:capstone/core/shared/providers/user_provider.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/custom_header_widget.dart';
import 'package:capstone/features/public_user/setup/views/setup_screen_phone_verification_page.dart.dart';
import 'package:capstone/features/public_user/setup/views/setup_screen_user_card_page.dart';
import 'package:capstone/features/public_user/setup/views/setup_screen_personal_info_page.dart';
import 'package:capstone/features/public_user/setup/views/setup_screen_medical_info_page.dart';
import 'package:capstone/features/public_user/setup/views/setup_screen_summary_page.dart';
import 'package:capstone/features/public_user/setup/views/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SetupScreenPageView extends ConsumerStatefulWidget {
  const SetupScreenPageView({super.key});

  @override
  ConsumerState<SetupScreenPageView> createState() => _SetupScreenPageView();
}

class _SetupScreenPageView extends ConsumerState<SetupScreenPageView> {
  final userContactNumPageKey = GlobalKey<FormState>();
  final userInfoPageKey = GlobalKey<FormState>();
  final userCardPageKey = GlobalKey<FormState>();
  final pageController = PageController(initialPage: 0);
  int currentPage = 0;
  final numberOfPages = 5;

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void navigateFromPage() {
    pageController.animateToPage(
      currentPage -= 1,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  void navigateToPage() {
    pageController.animateToPage(
      currentPage += 1,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    final formKeys = [
      userContactNumPageKey,
      userInfoPageKey,
      userCardPageKey,
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        ref.read(userProvider.notifier).reset();
        Navigator.pop(context);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(statusBarColor: Colors.deepOrange),
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                CustomHeaderWidget(
                  title: "Create Account",
                  body: "Set up your safety profile",
                  progressIndicator: LinearProgressIndicator(
                    value: (currentPage + 1) / numberOfPages,
                    color: Colors.white,
                    backgroundColor: Colors.white30,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 20.0,
                      left: 20,
                      right: 20,
                    ),
                    child: PageView(
                      controller: pageController,
                      physics: NeverScrollableScrollPhysics(),
                      onPageChanged: (value) {
                        setState(() {
                          currentPage = value;
                        });
                      },
                      children: [
                        Form(
                          key: userContactNumPageKey,
                          child: SetupScreenPhoneVerificationPage(),
                        ),
                        Form(
                          key: userInfoPageKey,
                          child: SetupScreenPersonalInfoPage(),
                        ),
                        Form(
                          key: userCardPageKey,
                          child: SetupScreenUserCardPage(),
                        ),
                        Form(
                          child: SetupScreenMedicalInfoPage(),
                        ),
                        SetupScreenSummaryPage(),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      if (currentPage > 0) ...[
                        Expanded(
                          child: CustomElevatedButton(
                            onPressed: () {
                              navigateFromPage();
                            },
                            value: "Previous",
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                      ],
                      Expanded(
                        child: CustomElevatedButton(
                          onPressed: () async {
                            if (currentPage < 3) {
                              if (!formKeys[currentPage].currentState!.validate()) {
                                return;
                              }
                            }

                            if (currentPage == numberOfPages - 1) {
                              await ref.read(userProvider.notifier).updateUserSetup();

                              if (!context.mounted) {
                                return;
                              }

                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return OnboardingScreen();
                                  },
                                ),
                                (route) => false,
                              );
                            } else {
                              navigateToPage();
                            }
                          },

                          value: currentPage == numberOfPages - 1 ? "Create" : "Next",
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

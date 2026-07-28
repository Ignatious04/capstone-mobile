import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/providers/user_repository_provider.dart';
import 'package:capstone/core/shared/providers/user_provider.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/features/setup/views/setup_screen_user_card_page.dart';
import 'package:capstone/features/setup/views/setup_screen_personal_info_page.dart';
import 'package:capstone/features/setup/views/setup_screen_medical_info_page.dart';
import 'package:capstone/features/setup/views/setup_screen_summary_page.dart';
import 'package:capstone/features/setup/views/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SetupScreenPageView extends ConsumerStatefulWidget {
  const SetupScreenPageView({super.key});

  @override
  ConsumerState<SetupScreenPageView> createState() => _SetupScreenPageView();
}

class _SetupScreenPageView extends ConsumerState<SetupScreenPageView> {
  final userInfoPageKey = GlobalKey<FormState>();
  final userCardPageKey = GlobalKey<FormState>();
  final pageController = PageController(initialPage: 0);

  int currentPage = 0;

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
    final user = ref.watch(userProvider);
    debugPrint("SetupScreen userID: '${user.userID}'");
    final formKeys = [
      userInfoPageKey,
      userCardPageKey,
    ];
    final numberOfPages = 4;

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
                Container(
                  height: 75,
                  width: double.infinity,
                  color: Colors.deepOrange,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Create Account",
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(color: Colors.white),
                          textAlign: TextAlign.left,
                        ),
                        Text(
                          "User Information - Safety Profile",
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.white),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        LinearProgressIndicator(
                          value: (currentPage + 1) / numberOfPages,
                          color: Colors.white,
                          backgroundColor: Colors.white30,
                        ),
                      ],
                    ),
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
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.lighterBlack,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              navigateFromPage();
                            },

                            child: Text("Previous"),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                      ],
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            if (currentPage < 2) {
                              if (!formKeys[currentPage].currentState!.validate()) {
                                return;
                              }
                            }

                            if (currentPage == numberOfPages - 1) {
                              ref.read(userProvider.notifier).setIsSetup(true);

                              final userID = ref.read(firebaseAuthProvider).currentUser!.uid;
                              final user = ref.read(userProvider);

                              debugPrint("=== BEFORE UPDATE ===");
                              debugPrint("userID: '${user.userID}'");
                              debugPrint(user.toMap().toString());

                              await ref
                                  .read(userRepositoryProvider)
                                  .updateUser(
                                    userID,
                                    user.toMap(),
                                  );

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

                          child: Text(
                            currentPage == numberOfPages - 1 ? "Create" : "Next",
                          ),
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

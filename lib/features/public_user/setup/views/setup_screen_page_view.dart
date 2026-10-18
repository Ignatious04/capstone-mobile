import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/models/user_model.dart';
import 'package:capstone/core/shared/providers/user_provider.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/custom_header_widget.dart';
import 'package:capstone/core/shared/widgets/custom_snackbar_helper.dart';
import 'package:capstone/core/shared/widgets/loading_overlay_widget.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/title_text.dart';
import 'package:capstone/features/public_user/setup/views/phone_verification_screen.dart';
import 'package:capstone/features/public_user/setup/views/setup_screen_user_card_page.dart';
import 'package:capstone/features/public_user/setup/views/setup_screen_personal_info_page.dart';
import 'package:capstone/features/public_user/setup/views/setup_screen_medical_info_page.dart';
import 'package:capstone/features/public_user/setup/views/setup_screen_summary_page.dart';
import 'package:capstone/features/public_user/setup/views/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SetupScreenPageView extends ConsumerStatefulWidget {
  const SetupScreenPageView({super.key, this.resubmitFrom});

  final UserModel? resubmitFrom;

  @override
  ConsumerState<SetupScreenPageView> createState() => _SetupScreenPageView();
}

class _SetupScreenPageView extends ConsumerState<SetupScreenPageView> {
  final userContactNumPageKey = GlobalKey<FormState>();
  final userInfoPageKey = GlobalKey<FormState>();
  final userCardPageKey = GlobalKey<FormState>();
  late final PageController pageController;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();

    pageController = PageController(initialPage: 0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final previous = widget.resubmitFrom;
      if (previous != null) {
        ref.read(userProvider.notifier).prefillForResubmission(previous);
      }
      checkPhoneStatus();
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void checkPhoneStatus() {
    final alreadyVerified = ref.read(userProvider.notifier).syncVerifiedPhone();

    if (alreadyVerified && mounted) {
      pageController.jumpToPage(1);
    }
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

  Widget showLoadingOverlay() {
    return LoadingOverlayWidget();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Minors skip ID capture and medical info, so the page list is dynamic.
    final isMinor = ref.watch(userProvider.select((u) => u.isMinor));
    final pages = <({GlobalKey<FormState>? key, Widget child})>[
      (key: userContactNumPageKey, child: PhoneVerificationScreen()),
      (key: userInfoPageKey, child: SetupScreenPersonalInfoPage()),
      if (!isMinor) (key: userCardPageKey, child: SetupScreenUserCardPage()),
      if (!isMinor) (key: null, child: SetupScreenMedicalInfoPage()),
      (key: null, child: SetupScreenSummaryPage()),
    ];
    final numberOfPages = pages.length;

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
                  title: widget.resubmitFrom == null ? l10n.createAccount : l10n.updateYourInformation,
                  body: widget.resubmitFrom == null ? l10n.setupSafetyProfile : l10n.fixFlaggedDetails,
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
                        for (final p in pages) p.key == null ? p.child : Form(key: p.key, child: p.child),
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
                            value: l10n.previous,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                      ],
                      Expanded(
                        child: CustomElevatedButton(
                          onPressed: () async {
                            final formKey = pages[currentPage].key;
                            if (formKey != null && !formKey.currentState!.validate()) {
                              return;
                            }

                            if (currentPage == numberOfPages - 1) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => showLoadingOverlay(),
                              );

                              final isResubmission = widget.resubmitFrom != null;

                              try {
                                await ref.read(userProvider.notifier).updateUserSetup(isResubmission: isResubmission);

                                if (!context.mounted) return;

                                Navigator.pop(context); // dismiss the loading overlay
                                if (isResubmission) {
                                  await showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: TitleText(value: l10n.resubmitted),
                                      content: BodyText(
                                        value: l10n.resubmittedBody,
                                      ),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.ok)),
                                      ],
                                    ),
                                  );
                                  if (!context.mounted) return;
                                  Navigator.popUntil(context, (route) => route.isFirst);
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => OnboardingScreen()),
                                  );
                                }
                              } catch (e) {
                                if (!context.mounted) return;

                                Navigator.pop(context); // dismiss the loading overlay
                                CustomSnackbarHelper.show(context, text: l10n.somethingWentWrong);
                              }
                            } else {
                              navigateToPage();
                            }
                          },

                          value: currentPage == numberOfPages - 1
                              ? (widget.resubmitFrom == null ? l10n.create : l10n.resubmit)
                              : l10n.next,
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

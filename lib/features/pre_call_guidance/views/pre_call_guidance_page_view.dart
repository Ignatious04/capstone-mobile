import 'package:capstone/core/shared/widgets/custom_app_bar.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/features/pre_call_guidance/providers/guidance_provider.dart';
import 'package:capstone/features/pre_call_guidance/views/pre_call_guidance_page.dart';
import 'package:capstone/features/pre_call_guidance/views/pre_call_guidance_summary_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PreCallGuidancePageView extends ConsumerStatefulWidget {
  const PreCallGuidancePageView({
    super.key,
  });

  @override
  ConsumerState<PreCallGuidancePageView> createState() => _PreCallGuidancePageViewState();
}

class _PreCallGuidancePageViewState extends ConsumerState<PreCallGuidancePageView> {
  late final PageController pageController;
  int length = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(guidanceProvider.notifier).resetAnswers();
    });
  }

  void navigateToPage() {
    final questionCount = ref.read(guidanceProvider).questions.length;
    final state = ref.read(guidanceProvider);
    if (state.currentPage < questionCount - 1) {
      pageController.animateToPage(
        state.currentPage + 1,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
    } else {
      pageController.animateToPage(
        questionCount,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(guidanceProvider);
    return Scaffold(
      appBar: CustomAppBar(value: "Pre-Call Guidance"),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (state.currentPage + 1) / state.questions.length,
              color: Colors.white,
              backgroundColor: AppColors.darkerGrey,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                ),
                child: PageView.builder(
                  controller: pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.questions.length + 1,
                  itemBuilder: (context, index) {
                    if (index == state.questions.length) {
                      return PreCallGuidanceSummaryScreen(
                        pageController: pageController,
                        onCancel: () {
                          Navigator.pop(context);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            ref.read(guidanceProvider.notifier).resetAnswers();
                          });
                        },
                      );
                    }

                    return PreCallGuidancePage(
                      question: state.questions[index],
                      index: index,
                      onNext: navigateToPage,
                    );
                  },
                  onPageChanged: (page) {
                    ref.read(guidanceProvider.notifier).setCurrentPage(page);
                  },
                ),
              ),
            ),
            if (state.currentPage < state.questions.length)
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: CustomElevatedButton(
                  onPressed: () {},
                  value: "Call nearest related service",
                  color: Colors.white,
                  backgroundColor: Colors.deepOrange,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

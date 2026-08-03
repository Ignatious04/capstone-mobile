import 'package:capstone/core/shared/widgets/custom_header_widget.dart';
import 'package:capstone/core/shared/widgets/text/text_title_small.dart';
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return PreCallGuidanceSummaryScreen();
          },
        ),
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
      appBar: AppBar(
        toolbarHeight: 40,
        title: TextTitleSmall(
          title: "Back",
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: CustomHeaderWidget(
                title: "Pre-Call Guidance",
                body: "Help us route you to the right service",
                progressIndicator: LinearProgressIndicator(
                  value: (state.currentPage + 1) / state.questions.length,
                  color: Colors.white,
                  backgroundColor: Colors.white30,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: PageView.builder(
                  controller: pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.questions.length,
                  itemBuilder: (context, index) {
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
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                ),
                child: const Text("Call nearest related service"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

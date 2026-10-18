import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/providers/report_provider.dart';
import 'package:capstone/core/shared/widgets/custom_app_bar.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/text/label_text.dart';
import 'package:capstone/core/utilities/call_nearest_service.dart';
import 'package:capstone/features/public_user/main/providers/nearest_emergency_services_provider.dart';
import 'package:capstone/features/public_user/pre_call_guidance/providers/guidance_provider.dart';
import 'package:capstone/features/public_user/pre_call_guidance/views/pre_call_guidance_page.dart';
import 'package:capstone/features/public_user/pre_call_guidance/views/pre_call_guidance_summary_screen.dart';
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

  Future<void> _callNearestService() async {
    final type = ref.read(reportProvider).incidentType;
    if (type == null) return;
    await callNearestService(context, ref, type);
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
    final l10n = AppLocalizations.of(context)!;

    final state = ref.watch(guidanceProvider);
    final incidentType = ref.watch(reportProvider).incidentType;
    final nearestServiceName = incidentType == null
        ? null
        : ref.watch(nearestEmergencyServicesProvider).value?[incidentType]?.name;

    final callLabel = (nearestServiceName != null && nearestServiceName.isNotEmpty)
        ? nearestServiceName
        : l10n.callNearestService;

    return Scaffold(
      appBar: CustomAppBar(value: l10n.preCallGuidance),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (state.currentPage + 1) / state.questions.length,
              color: Colors.white,
              backgroundColor: Colors.black26,
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
                        onCall: _callNearestService, // add
                        callLabel: callLabel, // add
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
            if (state.currentPage < state.questions.length) ...[
              LabelText(value: callLabel),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: CustomElevatedButton(
                  onPressed: () {
                    _callNearestService();
                  },
                  value: l10n.call.toUpperCase(),
                  icon: const Icon(Icons.call),
                  color: Colors.white,
                  backgroundColor: Colors.deepOrange,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

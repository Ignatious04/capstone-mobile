import 'package:capstone/core/shared/widgets/custom_header_widget.dart';
import 'package:capstone/core/shared/widgets/text/text_body_medium.dart';
import 'package:capstone/core/shared/widgets/text/text_title_small.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/features/main/main_screen.dart';
import 'package:capstone/features/pre_call_guidance/providers/guidance_provider.dart';
import 'package:capstone/features/pre_call_guidance/widgets/pre_call_guidance_summary_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PreCallGuidanceSummaryScreen extends ConsumerWidget {
  const PreCallGuidanceSummaryScreen({super.key, required this.pageController});

  final PageController pageController;
  static const size = 25.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(guidanceProvider);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 64,
                        ),
                        const SizedBox(height: 10),
                        TextTitleSmall(
                          title: "Guidance Complete",
                          isBold: true,
                        ),
                        const SizedBox(height: 10),
                        TextBodyMedium(
                          title:
                              "Your emergency guidance has been completed."
                              "You may now submit your report to the appropriate agency.",
                          alignment: TextAlign.center,
                          isBold: false,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.questions.length,
                itemBuilder: (_, index) {
                  final question = state.questions[index];

                  return PreCallGuidanceSummaryCardWidget(
                    question: question.question,
                    answer: question.answer.toString(),
                  );
                },
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Submit report",
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  ref.read(guidanceProvider.notifier).resetAnswers();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lighterBlack,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Cancel",
                ),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

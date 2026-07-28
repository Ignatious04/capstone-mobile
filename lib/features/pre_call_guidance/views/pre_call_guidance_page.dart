import 'package:capstone/core/shared/widgets/text/text_body_large.dart';
import 'package:capstone/core/shared/widgets/text/text_title_large.dart';
import 'package:capstone/features/pre_call_guidance/models/question_model.dart';
import 'package:capstone/features/pre_call_guidance/providers/guidance_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PreCallGuidancePage extends ConsumerWidget {
  const PreCallGuidancePage({
    super.key,
    required this.question,
    required this.index,
    required this.onNext,
  });

  final QuestionModel question;
  final int index;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextTitleLarge(title: question.question),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                ref.read(guidanceProvider.notifier).answerQuestion(index, false);

                onNext();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(20.0),
                child: TextBodyLarge(title: "No", color: Colors.white),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(guidanceProvider.notifier).answerQuestion(index, true);
                onNext();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(20.0),
                child: TextBodyLarge(title: "Yes", color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

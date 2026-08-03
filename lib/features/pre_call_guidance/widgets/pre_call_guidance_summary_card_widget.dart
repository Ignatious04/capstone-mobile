import 'package:capstone/core/shared/widgets/text/text_body_medium.dart';
import 'package:flutter/material.dart';

class PreCallGuidanceSummaryCardWidget extends StatelessWidget {
  const PreCallGuidanceSummaryCardWidget({
    super.key,
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextBodyMedium(title: question, isBold: false,),
              const SizedBox(height: 10),
              TextBodyMedium(title: answer),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:capstone/core/shared/widgets/text/paragraph_text.dart';
import 'package:capstone/features/public_user/reporting/widgets/empty_card.dart';
import 'package:flutter/material.dart';

class AdditionalInformationCard extends StatelessWidget {
  const AdditionalInformationCard({super.key, this.additionalInfo});

  final String? additionalInfo;

  @override
  Widget build(BuildContext context) {
    if (additionalInfo?.isEmpty ?? true) {
      return EmptyCard(
        icon: Icons.notes_outlined,
        message: 'No additional information provided.',
      );
    }

    return Card(
      color: Colors.white,
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: ParagraphText(
          value: additionalInfo!,
        ),
      ),
    );
  }
}

import 'package:capstone/features/reporting/widgets/attachments_card_item.dart';
import 'package:capstone/features/reporting/widgets/empty_card.dart';
import 'package:flutter/material.dart';

class AttachmentsCard extends StatelessWidget {
  const AttachmentsCard({super.key, this.attachments});

  final List<String>? attachments;

  @override
  Widget build(BuildContext context) {
    if (attachments?.isEmpty ?? true) {
      return EmptyCard(
        icon: Icons.image_not_supported_outlined,
        message: 'No attachments provided.',
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
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: attachments!.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            return AttachmentsCardItem(
              url: attachments![index],
            );
          },
        ),
      ),
    );
  }
}

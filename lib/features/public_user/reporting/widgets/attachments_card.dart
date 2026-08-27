import 'package:capstone/features/public_user/reporting/models/attachment_model.dart';
import 'package:capstone/features/public_user/reporting/widgets/attachments_card_item.dart';
import 'package:capstone/features/public_user/reporting/widgets/empty_card.dart';
import 'package:flutter/material.dart';

class AttachmentsCard extends StatelessWidget {
  const AttachmentsCard({super.key, required this.attachments});

  final List<AttachmentModel> attachments;

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) {
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
          itemCount: attachments.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            return AttachmentsCardItem(
              attachment: attachments[index],
            );
          },
        ),
      ),
    );
  }
}

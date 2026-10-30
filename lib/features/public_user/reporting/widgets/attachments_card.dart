import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/models/attachment_model.dart';
import 'package:capstone/features/public_user/reporting/widgets/attachments_card_item.dart';
import 'package:capstone/features/public_user/reporting/widgets/empty_card.dart';
import 'package:flutter/material.dart';

class AttachmentsCard extends StatelessWidget {
  const AttachmentsCard({
    super.key,
    required this.attachments,
    this.onDelete,
    this.canDelete,
  });

  final List<AttachmentModel> attachments;
  final ValueChanged<AttachmentModel>? onDelete;

  /// Optional per-image filter, e.g. only the caller's own uploads.
  final bool Function(AttachmentModel)? canDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (attachments.isEmpty) {
      return EmptyCard(
        icon: Icons.image_not_supported_outlined,
        message: l10n.noAttachments,
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
              onDelete: onDelete != null && (canDelete?.call(attachments[index]) ?? true)
                  ? () => onDelete!(attachments[index])
                  : null,
            );
          },
        ),
      ),
    );
  }
}

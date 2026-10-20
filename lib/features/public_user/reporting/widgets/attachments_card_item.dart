import 'package:cached_network_image/cached_network_image.dart';
import 'package:capstone/core/shared/widgets/custom_circular_progress_indicator.dart';
import 'package:capstone/core/shared/widgets/view_attachment_screen.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/core/shared/models/attachment_model.dart';
import 'package:flutter/material.dart';

class AttachmentsCardItem extends StatelessWidget {
  const AttachmentsCardItem({
    super.key,
    required this.attachment,
  });

  final AttachmentModel attachment;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return ViewAttachmentScreen(
                fileName: attachment.fileName,
                url: attachment.url,
              );
            },
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          color: AppColors.lighterBlack,
          child: CachedNetworkImage(
            imageUrl: attachment.url,
            fit: BoxFit.cover,
            placeholder:
                (
                  context,
                  child,
                ) {
                  return const Center(
                    child: CustomCircularProgressIndicator(),
                  );
                },
            errorWidget:
                (
                  context,
                  error,
                  stackTrace,
                ) {
                  return const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 36,
                      color: Colors.white,
                    ),
                  );
                },
          ),
        ),
      ),
    );
  }
}

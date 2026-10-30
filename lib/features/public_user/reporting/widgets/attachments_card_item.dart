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
    this.onDelete,
  });

  final AttachmentModel attachment;
  final VoidCallback? onDelete;

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
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
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
          if (onDelete != null)
            Positioned(
              top: 2,
              right: 2,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onDelete,
                child: const Padding(
                  padding: EdgeInsets.all(6), // bigger tap target than the icon
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                    child: Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

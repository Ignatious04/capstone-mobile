import 'package:capstone/core/shared/widgets/custom_circular_progress_indicator.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class AttachmentsCardItem extends StatelessWidget {
  const AttachmentsCardItem({
    super.key,
    required this.url,
  });

  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        color: AppColors.lighterBlack,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder:
              (
                context,
                child,
                loadingProgress,
              ) {
                if (loadingProgress == null) {
                  return child;
                }

                return const Center(
                  child: CustomCircularProgressIndicator(),
                );
              },
          errorBuilder:
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
    );
  }
}

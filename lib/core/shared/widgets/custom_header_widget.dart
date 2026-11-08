import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/headline_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class CustomHeaderWidget extends StatelessWidget {
  const CustomHeaderWidget({
    super.key,
    required this.title,
    this.body,
    this.progressIndicator,
    this.hasPadding = true,
    this.hasBoxShadow = true,
  });

  final String title;
  final String? body;
  final Widget? progressIndicator;
  final bool hasPadding;
  final bool hasBoxShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.themeColor,
        boxShadow: hasBoxShadow
            ? [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: Offset(0, 3),
                ),
              ]
            : null,
      ),

      child: Padding(
        padding: hasPadding ? const EdgeInsets.all(20) : EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeadlineText(
              value: title,
              color: AppColors.whiteTextFull,
              isBold: true,
            ),
            if (body != null)
              BodyText(
                value: body!,
                color: AppColors.whiteTextFull,
              ),
            if (progressIndicator != null) ...[
              SizedBox(height: 10),
              progressIndicator!,
            ],
          ],
        ),
      ),
    );
  }
}

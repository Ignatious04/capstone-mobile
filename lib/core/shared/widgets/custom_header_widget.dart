import 'package:capstone/core/shared/widgets/text/sub_title_text.dart';
import 'package:capstone/core/shared/widgets/text/screen_title_text.dart';
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
        color: Colors.deepOrange,
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
            ScreenTitleText(
              value: title,
              color: Colors.white,
              isBold: true,
            ),
            if (body != null)
              SubtitleText(
                value: body!,
                color: Colors.white,
                isBold: false,
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

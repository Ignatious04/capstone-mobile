import 'package:capstone/core/shared/widgets/text/sub_title_text.dart';
import 'package:capstone/core/shared/widgets/text/screen_title_text.dart';
import 'package:flutter/material.dart';

class CustomHeaderWidget extends StatelessWidget {
  const CustomHeaderWidget({super.key, required this.title, this.body, this.progressIndicator});

  final String title;
  final String? body;
  final Widget? progressIndicator;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.deepOrange,
      child: Padding(
        padding: const EdgeInsets.all(20),
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

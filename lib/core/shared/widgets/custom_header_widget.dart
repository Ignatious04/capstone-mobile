import 'package:capstone/core/shared/widgets/text/text_body_small.dart';
import 'package:capstone/core/shared/widgets/text/text_title_small.dart';
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
            TextTitleSmall(
              title: title,
              color: Colors.white,
              isBold: true,
            ),
            if (body != null)
              TextBodySmall(
                title: body!,
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

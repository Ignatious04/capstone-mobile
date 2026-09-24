import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:flutter/material.dart';

class InfoColumn extends StatelessWidget {
  const InfoColumn({
    super.key,
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BodyText(
          value: title,
          color: Colors.black54,
        ),
        BodyText(
          value: value,
          isBold: true,
        ),
      ],
    );
  }
}

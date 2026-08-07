import 'package:capstone/core/shared/widgets/text/text_body_medium.dart';
import 'package:capstone/core/shared/widgets/text/text_title_medium.dart';
import 'package:capstone/core/shared/widgets/text/text_title_small.dart';
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
        TextBodyMedium(
          title: title,
          isBold: false,
        ),
        TextTitleMedium(
          title: value,
          isBold: false,
        ),
      ],
    );
  }
}

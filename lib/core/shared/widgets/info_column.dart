import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/label_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
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
        LabelText(
          value: title,
          color: AppColors.blackTextMuted,
        ),
        BodyText(
          value: value,
          color: AppColors.blackTextFull,
          isBold: true,
        ),
      ],
    );
  }
}

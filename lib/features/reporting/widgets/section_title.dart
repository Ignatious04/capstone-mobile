import 'package:capstone/core/shared/widgets/text/deprecated/text_title_small.dart';
import 'package:capstone/core/shared/widgets/text/section_title_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 22,
          color: AppColors.lighterBlack,
        ),
        const SizedBox(width: 8),
        SectionTitleText(
          value: title,
          isBold: true,
        ),
      ],
    );
  }
}

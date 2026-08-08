import 'package:capstone/core/shared/widgets/text/section_title_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.icon,
    required this.title,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  final IconData icon;
  final String title;
  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      children: [
        Icon(
          icon,
          size: 22,
          color: AppColors.darkerGrey,
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

import 'package:capstone/core/shared/widgets/text/section_title_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.icon,
    required this.title,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.size = 25,
    this.isBold = true,
  });

  final IconData icon;
  final String title;
  final double size;
  final MainAxisAlignment mainAxisAlignment;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      children: [
        Icon(
          icon,
          size: size,
          color: AppColors.darkerGrey,
        ),
        const SizedBox(width: 10),
        SectionTitleText(
          value: title,
          isBold: isBold,
        ),
      ],
    );
  }
}

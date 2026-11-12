import 'package:capstone/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class LabelText extends StatelessWidget {
  const LabelText({
    super.key,
    required this.value,
    this.alignment = TextAlign.left,
    this.color = AppColors.blackTextFull,
    this.decorationColor = Colors.transparent,
    this.isBold = false,
    this.hasUnderline = false,
  });

  final String value;
  final TextAlign alignment;
  final Color color;
  final Color decorationColor;
  final bool isBold;
  final bool hasUnderline;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      textAlign: alignment,
      style:
          Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: isBold ? FontWeight.bold : null,
            decoration: hasUnderline ? TextDecoration.underline : null,
            decorationColor: decorationColor,
          ),
    );
  }
}

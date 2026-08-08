import 'package:capstone/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class DataLabelText extends StatelessWidget {
  const DataLabelText({
    super.key,
    required this.value,
    this.alignment = TextAlign.left,
    this.color = AppColors.darkerGrey,
    this.isBold = false,
  });

  final String value;
  final TextAlign alignment;
  final Color color;
  final bool isBold;

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
          ),
    );
  }
}

import 'package:flutter/material.dart';

class SubtitleText extends StatelessWidget {
  const SubtitleText({
    super.key,
    required this.value,
    this.alignment = TextAlign.left,
    this.color = Colors.black,
    this.isBold = false,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
  });

  final String value;
  final TextAlign alignment;
  final Color color;
  final bool isBold;
  final int maxLines;
  final TextOverflow overflow;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      textAlign: alignment,
      maxLines: maxLines,
      overflow: overflow,
      style:
          Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: isBold ? FontWeight.bold : null,
          ),
    );
  }
}

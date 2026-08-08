import 'package:flutter/material.dart';

class TextBodyMedium extends StatelessWidget {
  const TextBodyMedium({
    super.key,
    required this.title,
    this.color = Colors.black,
    this.alignment = TextAlign.start,
    this.isBold = true,
  });

  final String title;
  final Color color;
  final TextAlign alignment;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: alignment,
      style:
          Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: isBold == true ? FontWeight.bold : null,
          ),
    );
  }
}

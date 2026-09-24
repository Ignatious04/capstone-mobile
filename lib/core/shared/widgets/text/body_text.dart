import 'package:flutter/material.dart';

class BodyText extends StatelessWidget {
  const BodyText({
    super.key,
    required this.value,
    this.alignment = TextAlign.left,
    this.color = Colors.black,
    this.isOverflow = false,
    this.isBold = false,
  });

  final String value;
  final TextAlign alignment;
  final Color color;
  final bool isOverflow;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      textAlign: alignment,
      overflow: isOverflow ? TextOverflow.ellipsis : null,
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

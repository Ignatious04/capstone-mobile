import 'package:flutter/material.dart';

class TextBodySmall extends StatelessWidget {
  const TextBodySmall({
    super.key,
    required this.title,
    this.color = Colors.black54,
    this.isBold = true,
  });

  final String title;
  final Color color;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style:
          Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: isBold ? FontWeight.bold : null,
          ),
    );
  }
}

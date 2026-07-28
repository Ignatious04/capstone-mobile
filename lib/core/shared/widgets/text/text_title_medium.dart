import 'package:flutter/material.dart';

class TextTitleMedium extends StatelessWidget {
  const TextTitleMedium({
    super.key,
    required this.title,
    this.color = Colors.black,
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
          ).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: isBold ? FontWeight.bold : null,
          ),
    );
  }
}

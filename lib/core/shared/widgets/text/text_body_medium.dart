import 'package:flutter/material.dart';

class TextBodyMedium extends StatelessWidget {
  const TextBodyMedium({super.key, required this.title, this.color = Colors.black, this.isBold = true});

  final String title;
  final Color color;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.center,
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

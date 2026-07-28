import 'package:flutter/material.dart';

class TextTitleSmall extends StatelessWidget {
  const TextTitleSmall({
    super.key,
    required this.title,
    this.alignment = TextAlign.center,
    this.color = Colors.black,
    this.isBold = false,
  });

  final String title;
  final TextAlign alignment;
  final Color? color;
  final bool? isBold;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: alignment,
      style:
          Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(
            color: color,
            fontWeight: isBold == true ? FontWeight.bold : null,
          ),
    );
  }
}

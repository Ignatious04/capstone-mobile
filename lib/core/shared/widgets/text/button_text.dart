import 'package:flutter/material.dart';

class ButtonText extends StatelessWidget {
  const ButtonText({
    super.key,
    required this.value,
    this.alignment = TextAlign.left,
    this.color = Colors.black,
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
          ).textTheme.labelLarge?.copyWith(
            color: color,
            fontWeight: isBold ? FontWeight.bold : null,
          ),
    );
  }
}

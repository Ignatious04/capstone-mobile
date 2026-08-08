import 'package:capstone/core/shared/widgets/text/button_text.dart';
import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    super.key,
    required this.onPressed,
    required this.value,
    required this.color,
    required this.backgroundColor,
    this.hasPadding = false,
  });

  final VoidCallback onPressed;
  final String value;
  final Color color;
  final Color backgroundColor;
  final bool hasPadding;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        iconColor: color,
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: hasPadding
          ? Padding(
              padding: const EdgeInsets.all(20.0),
              child: ButtonText(
                value: value,
                color: color,
              ),
            )
          : ButtonText(
              value: value,
              color: color,
            ),
    );
  }
}

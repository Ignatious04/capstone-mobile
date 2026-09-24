import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    super.key,
    required this.onPressed,
    required this.value,
    this.icon,
    this.color = Colors.white,
    this.backgroundColor = Colors.deepOrange,
    this.hasPadding = false,
  });

  final VoidCallback? onPressed;
  final String value;
  final Widget? icon;
  final Color color;
  final Color backgroundColor;
  final bool hasPadding;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon,
      style: ElevatedButton.styleFrom(
        iconColor: color,
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      label: hasPadding
          ? Padding(
              padding: const EdgeInsets.all(20.0),
              child: BodyText(
                value: value,
                color: color,
                isBold: true,
              ),
            )
          : BodyText(
              value: value,
              color: color,
              isBold: true,
            ),
    );
  }
}

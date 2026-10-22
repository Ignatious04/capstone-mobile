import 'package:capstone/core/shared/widgets/custom_circular_progress_indicator.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    super.key,
    this.onPressed,
    this.onLongPress,
    required this.value,
    this.icon,
    this.color = Colors.white,
    this.backgroundColor = Colors.deepOrange,
    this.hasPadding = false,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final String value;
  final Widget? icon;
  final Color color;
  final Color backgroundColor;
  final bool hasPadding;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      onLongPress: isLoading ? null : onLongPress,
      icon: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CustomCircularProgressIndicator(color: color),
            )
          : icon,
      style: ElevatedButton.styleFrom(
        iconColor: color,
        backgroundColor: backgroundColor,
        // Keep the brand color while loading instead of the greyed-out disabled look.
        disabledBackgroundColor: isLoading ? backgroundColor : null,
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

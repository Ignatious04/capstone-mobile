import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:flutter/material.dart';

class ServiceButton extends StatelessWidget {
  const ServiceButton({
    super.key,
    required this.onPressed,
    required this.value,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  final VoidCallback onPressed;
  final String value;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 1,
        iconColor: color,
        backgroundColor: backgroundColor,
        padding: EdgeInsets.all(0),
        fixedSize: const Size(95, 100),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(
          color: color,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 30,
          ),
          SizedBox(
            height: 10,
          ),
          BodyText(
            value: value,
            color: color,
            isBold: true,
          ),
        ],
      ),
    );
  }
}

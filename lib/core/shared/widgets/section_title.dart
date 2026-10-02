import 'package:capstone/core/shared/widgets/text/title_text.dart';
import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.icon,
    required this.title,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.size = 25,
    this.isBold = false,
  });

  final IconData icon;
  final String title;
  final double size;
  final MainAxisAlignment mainAxisAlignment;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      children: [
        Icon(
          icon,
          size: size,
          color: Colors.black54,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TitleText(
            value: title,
            isBold: isBold,
          ),
        ),
      ],
    );
  }
}

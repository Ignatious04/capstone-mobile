import 'package:capstone/core/shared/widgets/text/card_title_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class EmptyCard extends StatelessWidget {
  const EmptyCard({
    super.key,
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 28,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 34,
              color: AppColors.lighterBlack,
            ),
            const SizedBox(height: 10),
            CardTitleText(
              value: message,
              alignment: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

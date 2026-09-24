import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/label_text.dart';
import 'package:capstone/core/shared/widgets/text/title_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class VictimCardItem extends StatelessWidget {
  const VictimCardItem({
    super.key,
    required this.name,
    required this.description,
    required this.index,
  });

  final String name;
  final String description;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.darkerGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: LabelText(
                      value: '$index',
                      color: Colors.white,
                      isBold: true,
                      alignment: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TitleText(
                    value: name.isEmpty ? 'Unnamed victim' : name,
                    color: Colors.white,
                    isBold: false,
                  ),
                ),
              ],
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 10),
              BodyText(
                value: description,
                color: Colors.white,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

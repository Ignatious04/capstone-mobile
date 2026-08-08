import 'package:capstone/core/shared/classes/formatter.dart';
import 'package:capstone/core/shared/widgets/text/supporting_info_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class ReportStatusWidget extends StatelessWidget {
  const ReportStatusWidget({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.darkerGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          SupportingInfoText(
            value: Formatter.formatEnumName(status),
            color: Colors.white,
            isBold: true,
          ),
        ],
      ),
    );
  }
}

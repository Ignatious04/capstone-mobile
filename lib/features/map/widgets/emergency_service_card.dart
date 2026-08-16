import 'package:capstone/core/shared/widgets/text/card_title_text.dart';
import 'package:capstone/core/shared/widgets/text/sub_title_text.dart';
import 'package:capstone/core/shared/widgets/text/supporting_info_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class EmergencyServiceCard extends StatelessWidget {
  const EmergencyServiceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.distance,
    required this.status,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String distance;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.lighterBlack,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Later:
          // Move map to this emergency service.
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.lighterBlack,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.deepOrange,
                  size: 50,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CardTitleText(
                      value: title,
                    ),
                    SubtitleText(
                      value: subtitle,
                      overflow: TextOverflow.ellipsis,
                      color: AppColors.darkerGrey,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 25,
                          color: AppColors.darkerGrey,
                        ),
                        SupportingInfoText(
                          value: distance,
                          color: AppColors.darkerGrey,
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.lighterGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SupportingInfoText(
                            value: status,
                            color: AppColors.darkerGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
                size: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

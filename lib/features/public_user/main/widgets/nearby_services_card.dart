import 'package:capstone/core/shared/widgets/text/card_title_text.dart';
import 'package:capstone/core/shared/widgets/text/sub_title_text.dart';
import 'package:capstone/core/shared/widgets/text/supporting_info_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/core/utilities/call_launcher.dart';
import 'package:flutter/material.dart';

class NearbyServicesCard extends StatelessWidget {
  const NearbyServicesCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.name,
    required this.contactNumber,
    required this.address,
    required this.distance,
  });

  final IconData icon;
  final Color iconColor;
  final String name;
  final String contactNumber;
  final String address;
  final double distance;

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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
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
                color: iconColor,
                size: 50,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CardTitleText(
                    value: name,
                    isBold: true,
                  ),
                  SubtitleText(value: contactNumber),
                  SubtitleText(value: address),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 25,
                        color: AppColors.darkerGrey,
                      ),
                      SupportingInfoText(value: "${distance.toStringAsFixed(2)} km"),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            IconButton(
              onPressed: () {
                launchPhoneCall(contactNumber);
              },
              icon: Icon(
                Icons.call,
                size: 30,
                color: Colors.deepOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

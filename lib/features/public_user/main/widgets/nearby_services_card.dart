import 'package:capstone/core/enums/audit_action_enum.dart';
import 'package:capstone/core/shared/providers/audit_log_repository_provider.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/title_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/core/utilities/call_launcher.dart';
import 'package:capstone/core/utilities/distance_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NearbyServicesCard extends ConsumerWidget {
  const NearbyServicesCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.name,
    required this.contactNumber,
    required this.address,
    required this.distance,
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String name;
  final String contactNumber;
  final String address;
  final double distance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: backgroundColor,
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
                      TitleText(value: name),
                      BodyText(
                        value: contactNumber,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BodyText(
                        value: address,
                        color: Colors.black54,
                        isOverflow: false,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 25,
                            color: Colors.black54,
                          ),
                          BodyText(
                            value: DistanceHelper.formatDistance(distance),
                            color: Colors.black54,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: CustomElevatedButton(
                          onPressed: () {
                            ref
                                .read(auditLogRepositoryProvider)
                                .log(
                                  AuditAction.emergencyCallInitiated,
                                  metadata: {'source': 'home_nearby', 'number': contactNumber},
                                );
                            launchPhoneCall(contactNumber);
                          },
                          icon: Icon(
                            Icons.call,
                            size: 25,
                            color: Colors.white,
                          ),
                          value: "Call",
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

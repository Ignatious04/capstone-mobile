import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/core/utilities/emergency_guidance_tips.dart';
import 'package:capstone/core/utilities/formatter.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/title_text.dart';
import 'package:flutter/material.dart';

class EmergencyGuidanceSheet extends StatelessWidget {
  const EmergencyGuidanceSheet({super.key, required this.incidentType});

  final ServiceTypeEnum incidentType;

  /// Shows the sheet, or does nothing if there's no guidance content
  /// for this incident type (e.g. non-emergency police reports).
  static Future<void> show(BuildContext context, ServiceTypeEnum incidentType) {
    if (EmergencyGuidanceTips.forType(incidentType).isEmpty) {
      return Future.value();
    }

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => EmergencyGuidanceSheet(incidentType: incidentType),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tips = EmergencyGuidanceTips.forType(incidentType);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.deepOrange, size: 25),
                const SizedBox(width: 10),
                Expanded(
                  child: TitleText(
                    value: "While You Wait — ${Formatter.formatEnumName(incidentType.name)}",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            const BodyText(
              value: "Responders are on the way. These general steps may help in the meantime.",
              color: Colors.black54,
            ),
            const SizedBox(height: 20),
            ...tips.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Icon(Icons.circle, size: 10, color: Colors.deepOrange),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: BodyText(value: tip)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 5),
            const BodyText(
              value: "This is general guidance only and does not replace instructions from responders.",
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}
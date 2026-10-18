import 'package:capstone/core/l10n/enum_labels.dart';
import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/utilities/call_nearest_service.dart';
import 'package:capstone/core/utilities/emergency_guidance_tips.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/title_text.dart';
import 'package:capstone/features/public_user/main/providers/nearest_emergency_services_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmergencyGuidanceSheet extends ConsumerWidget {
  const EmergencyGuidanceSheet({super.key, required this.incidentType});

  final ServiceTypeEnum incidentType;

  /// Shows the sheet, or does nothing if there's no guidance content
  /// for this incident type (e.g. non-emergency police reports).
  static Future<void> show(BuildContext context, ServiceTypeEnum incidentType) {
    if (EmergencyGuidanceTips.forType(incidentType, AppLocalizations.of(context)!).isEmpty) {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final tips = EmergencyGuidanceTips.forType(incidentType, l10n);
    final nearestName = ref.watch(nearestEmergencyServicesProvider).value?[incidentType]?.name;

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
                    value: l10n.whileYouWaitTitle(incidentType.label(l10n)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            BodyText(
              value: l10n.guidanceSheetIntro,
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
            BodyText(
              value: l10n.guidanceSheetDisclaimer,
              color: Colors.black54,
            ),
            const SizedBox(height: 15),
            if (nearestName != null && nearestName.isNotEmpty) BodyText(value: nearestName, color: Colors.black54),
            CustomElevatedButton(
              onPressed: () => callNearestService(context, ref, incidentType),
              value: l10n.call.toUpperCase(),
              icon: const Icon(Icons.call),
              color: Colors.white,
              backgroundColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}

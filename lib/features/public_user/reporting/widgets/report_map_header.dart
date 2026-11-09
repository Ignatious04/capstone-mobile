import 'package:capstone/core/enums/report_status_enum.dart';
import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/l10n/enum_labels.dart';
import 'package:capstone/core/shared/models/report_model.dart';
import 'package:capstone/core/shared/models/response_model.dart';
import 'package:capstone/core/shared/providers/response_repository_provider.dart';
import 'package:capstone/features/public_user/reporting/providers/responder_location_provider.dart';
import 'package:capstone/features/public_user/reporting/widgets/eta_card.dart';
import 'package:capstone/features/public_user/reporting/widgets/location_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// The incident / responder map pinned to the top of a report view screen,
/// edge-to-edge like the map on the report form screen, with an ETA card for
/// every responder who is sharing their location right below it.
///
/// Place it OUTSIDE the screen's padding. Renders nothing when the report has
/// no location.
class ReportMapHeader extends ConsumerWidget {
  const ReportMapHeader({super.key, required this.report});

  final ReportModel report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final location = report.location;
    if (location == null) return const SizedBox.shrink();
    final incident = LatLng(location.latitude, location.longitude);

    final responses = ref
            .watch(responsesForReportProvider((reportID: report.reportID, userID: report.userID)))
            .value ??
        const <ResponseModel>[];

    // Live pins: only responders who are assigned, unresolved and sharing.
    final live = <({ResponseModel response, LatLng position})>[];
    for (final response in responses) {
      final responderID = response.assignedTo;
      if (responderID == null || response.status == ReportStatusEnum.resolved) continue;
      final position = ref
          .watch(responderLocationProvider((reportID: response.reportID, responderID: responderID)))
          .value;
      if (position != null) live.add((response: response, position: position));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LocationCard(
          location: location,
          attached: true,
          responders: [
            for (final item in live) (reportID: item.response.reportID, responderID: item.response.assignedTo!),
          ],
        ),
        if (live.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final item in live) ...[
                  EtaCard(
                    responder: item.position,
                    incident: incident,
                    isOnScene: item.response.status == ReportStatusEnum.onScene,
                    title: live.length > 1
                        ? '${item.response.serviceType.label(l10n)} - ${l10n.estimatedArrival}'
                        : null,
                  ),
                  if (item != live.last) const SizedBox(height: 10),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
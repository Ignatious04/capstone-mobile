import 'package:capstone/core/enums/audit_action_enum.dart';
import 'package:capstone/core/enums/map_mode_enum.dart';
import 'package:capstone/core/enums/report_status_enum.dart';
import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/providers/audit_log_repository_provider.dart';
import 'package:capstone/core/shared/widgets/custom_app_bar.dart';
import 'package:capstone/core/shared/widgets/text/label_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/core/utilities/case_marker_icons.dart';
import 'package:capstone/core/utilities/directions_launcher.dart';
import 'package:capstone/features/public_user/map/widgets/map_layer_button.dart';
import 'package:capstone/features/public_user/map/widgets/map_tile_widget.dart';
import 'package:capstone/features/responder/active_case/providers/active_case_provider.dart';
import 'package:capstone/features/responder/active_case/providers/responder_location_sharing_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Full-screen, interactive version of the map on the active case screen:
/// same incident pin and arrival zone, but you can pan, zoom and switch layers.
class ActiveCaseMapScreen extends ConsumerWidget {
  const ActiveCaseMapScreen({
    super.key,
    required this.incident,
    required this.reportID,
  });

  final LatLng incident;
  final String reportID;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    // Case resolved / unassigned while this screen is open: go back.
    ref.listen(activeCaseProvider, (_, next) {
      final data = next.asData;
      if (data != null && data.value == null) {
        Navigator.of(context).maybePop();
      }
    });

    final status = ref.watch(activeCaseProvider).value?.response.status;
    final icons = ref.watch(caseMarkerIconsProvider).value;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: CustomAppBar(value: l10n.incidentLocation),
      body: Stack(
        children: [
          Positioned.fill(
            child: MapTileWidget(
              initialLocation: incident,
              mode: MapModeEnum.view,
              gesturesEnabled: true,
              showLayerToggle: false, // layer toggle shows automatically
              extraMarkers: buildCaseMarkers(icons: icons, incident: incident),
              extraCircles: {
                if (status == ReportStatusEnum.dispatched)
                  Circle(
                    circleId: const CircleId('arrivalZone'),
                    center: incident,
                    radius: ResponderLocationSharer.arrivalRadiusMeters,
                    strokeWidth: 2,
                    strokeColor: AppColors.themeColor,
                    fillColor: AppColors.themeColor.withValues(alpha: 0.15),
                  ),
              },
            ),
          ),
          const Positioned(
            right: 20,
            bottom: 80,
            child: MapLayerButton(),
          ),
          if (status == ReportStatusEnum.dispatched)
            Positioned(
              left: 12,
              top: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.bgWhiteLight,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: LabelText(
                  value: l10n.arrivalZoneLabel(ResponderLocationSharer.arrivalRadiusMeters.round()),
                ),
              ),
            ),
          Positioned(
            right: 20,
            bottom: 20 + bottomInset,
            child: SizedBox(
              width: 50,
              height: 50,
              child: FloatingActionButton(
                heroTag: 'directionsFullMapFAB',
                backgroundColor: AppColors.bgWhiteLight,
                foregroundColor: AppColors.themeColor,
                onPressed: () {
                  ref
                      .read(auditLogRepositoryProvider)
                      .log(
                        AuditAction.directionsRequested,
                        targetType: 'report',
                        targetId: reportID,
                        metadata: {'source': 'responder_active_case_map'},
                      );
                  launchDirections(incident.latitude, incident.longitude);
                },
                child: const Icon(Icons.directions, size: 40),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/enums/map_mode_enum.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/label_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/core/utilities/case_marker_icons.dart';
import 'package:capstone/features/public_user/map/widgets/map_tile_widget.dart';
import 'package:capstone/features/public_user/reporting/providers/responder_location_provider.dart';
import 'package:capstone/features/public_user/reporting/views/report_location_map_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationCard extends ConsumerWidget {
  const LocationCard({
    super.key,
    required this.location,
    this.responders = const [],
    this.attached = false,
  });

  final GeoPoint location;

  /// Every responder currently sharing their location. The positions are
  /// watched here (and on the full-screen map) so both stay live.
  final List<ResponderKey> responders;

  /// Edge-to-edge header style (rounded bottom corners), like the map on the
  /// report form screen. Meant to sit at the very top of a screen, outside
  /// any padding.
  final bool attached;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final incident = LatLng(location.latitude, location.longitude);
    final responderLocations = watchResponderPositions(ref, responders);
    // null while the bitmaps render; buildCaseMarkers falls back to default pins.
    final icons = ref.watch(caseMarkerIconsProvider).value;

    return Card(
      shape: attached
          ? const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            )
          : null,
      color: AppColors.bgWhiteLight,
      elevation: 1,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 250,
            child: Stack(
              children: [
                Positioned.fill(
                  child: MapTileWidget(
                    initialLocation: incident,
                    fitToPoints: responderLocations.isEmpty ? const [] : [incident, ...responderLocations],
                    mode: MapModeEnum.view,
                    gesturesEnabled: false,
                    extraMarkers: buildCaseMarkers(
                      icons: icons,
                      incident: incident,
                      responders: responderLocations,
                    ),
                  ),
                ),
                // Transparent layer above the native map view so taps reach Flutter
                // and open the full-screen map.
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReportLocationMapScreen(
                          incident: incident,
                          responders: responders,
                        ),
                      ),
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: IgnorePointer(
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.bgWhiteLight,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                      ),
                      child: const Icon(Icons.fullscreen, size: 22, color: AppColors.themeColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.place_outlined,
                  color: AppColors.blackTextMuted,
                  size: 25,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LabelText(
                        value: l10n.reportedLocation.toUpperCase(),
                        color: AppColors.blackTextMuted,
                      ),
                      BodyText(
                        value:
                            '${location.latitude.toStringAsFixed(6)}, '
                            '${location.longitude.toStringAsFixed(6)}',
                        isBold: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

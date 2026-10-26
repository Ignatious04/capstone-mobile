import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/enums/map_mode_enum.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/utilities/case_marker_icons.dart';
import 'package:capstone/features/public_user/map/widgets/map_tile_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationCard extends ConsumerWidget {
  const LocationCard({
    super.key,
    required this.location,
    this.responderLocations = const [],
  });

  final GeoPoint location;

  /// Live positions of every responder currently sharing their location.
  final List<LatLng> responderLocations;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final incident = LatLng(location.latitude, location.longitude);
    // null while the bitmaps render; buildCaseMarkers falls back to default pins.
    final icons = ref.watch(caseMarkerIconsProvider).value;

    return Card(
      color: Colors.white,
      elevation: 1,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 250,
            child: MapTileWidget(
              initialLocation: incident,
              fitToPoints: responderLocations.isEmpty ? const [] : [incident, ...responderLocations],
              mode: MapModeEnum.view,
              gesturesEnabled: responderLocations.isNotEmpty,
              extraMarkers: buildCaseMarkers(
                icons: icons,
                incident: incident,
                responders: responderLocations,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.place_outlined,
                  color: Colors.black54,
                  size: 25,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BodyText(
                        value: l10n.reportedLocation.toUpperCase(),
                        color: Colors.black54,
                      ),
                      const SizedBox(height: 10),
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

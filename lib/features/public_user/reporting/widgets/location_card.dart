import 'package:capstone/core/enums/map_mode_enum.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/features/public_user/map/widgets/map_tile_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationCard extends StatelessWidget {
  const LocationCard({super.key, required this.location, this.responderLocation});

  final GeoPoint location;
  final LatLng? responderLocation;

  @override
  Widget build(BuildContext context) {
    final incident = LatLng(location.latitude, location.longitude);
    final responder = responderLocation;

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
              fitToPoints: responder == null ? const [] : [incident, responder],
              mode: MapModeEnum.view,
              gesturesEnabled: responder != null,
              extraMarkers: {
                Marker(
                  markerId: const MarkerId('incident'),
                  position: incident,
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                ),
                if (responder != null)
                  Marker(
                    markerId: const MarkerId('responder'),
                    position: responder,
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                  ),
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.place_outlined,
                  size: 25,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const BodyText(
                        value: 'REPORTED LOCATION',
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

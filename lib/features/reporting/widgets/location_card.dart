import 'package:capstone/core/enums/map_mode_enum.dart';
import 'package:capstone/core/shared/widgets/text/data_label_text.dart';
import 'package:capstone/core/shared/widgets/text/data_value_text.dart';
import 'package:capstone/features/map/widgets/map_tile_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationCard extends StatelessWidget {
  const LocationCard({super.key, required this.location});

  final GeoPoint location;

  @override
  Widget build(BuildContext context) {
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
              initialLocation: LatLng(
                location.latitude,
                location.longitude,
              ),
              mode: MapModeEnum.view,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.place_outlined,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const DataLabelText(
                        value: 'REPORTED LOCATION',
                      ),
                      const SizedBox(height: 4),
                      DataValueText(
                        value:
                            '${location.latitude.toStringAsFixed(6)}, '
                            '${location.longitude.toStringAsFixed(6)}',
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

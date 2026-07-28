import 'package:capstone/core/enums/map_mode_enum.dart';
import 'package:capstone/core/shared/widgets/custom_header_widget.dart';
import 'package:capstone/features/map/widgets/map_tile_widget.dart';
import 'package:capstone/core/shared/providers/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  bool showOptions = false;
  GoogleMapController? _mapController;
  LatLng? _currentLocation;

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(locationStreamProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: CustomHeaderWidget(
                title: "Map",
                body: "Get a hold of where you are",
              ),
            ),
            Expanded(
              child: location.when(
                data: (latLng) {
                  _currentLocation = latLng;
                  return MapTileWidget(
                    initialLocation: latLng,
                    mode: MapModeEnum.explore,
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                  );
                },
                loading: () => Center(child: const CircularProgressIndicator()),
                error: (e, _) => Text(e.toString()),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "mapFAB",
        onPressed: () {
          _mapController?.animateCamera(CameraUpdate.newLatLng(_currentLocation!));
        },
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        child: const Icon(
          Icons.location_searching,
        ),
      ),
    );
  }
}

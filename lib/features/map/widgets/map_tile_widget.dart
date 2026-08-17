import 'package:capstone/core/enums/map_mode_enum.dart';
import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/features/map/models/emergency_service_model.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapTileWidget extends StatefulWidget {
  const MapTileWidget({
    super.key,
    this.onMapCreated,
    this.onLocationChanged,
    required this.initialLocation,
    this.services = const [],
    this.mode = MapModeEnum.view,
    this.gesturesEnabled,
  });

  final void Function(GoogleMapController controller)? onMapCreated;
  final void Function(LatLng latlng)? onLocationChanged;
  final LatLng initialLocation;
  final List<EmergencyServiceModel> services;
  final MapModeEnum mode;
  final bool? gesturesEnabled;

  @override
  State<MapTileWidget> createState() => _MapTileWidgetState();
}

class _MapTileWidgetState extends State<MapTileWidget> {
  GoogleMapController? _mapController;
  CameraPosition? _cameraPosition;

  bool get _showCenterPin => widget.mode == MapModeEnum.selectLocation;
  bool get _gesturesEnabled => widget.gesturesEnabled ?? (widget.mode != MapModeEnum.view);

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    if (widget.mode == MapModeEnum.explore) {
      for (final service in widget.services) {
        markers.add(
          Marker(
            markerId: MarkerId(service.name),
            position: LatLng(
              service.location.latitude,
              service.location.longitude,
            ),
            icon: _serviceMarkerIcon(service),
          ),
        );
      }
    }

    return markers;
  }

  BitmapDescriptor _serviceMarkerIcon(EmergencyServiceModel service) {
    switch (service.type) {
      case ServiceTypeEnum.medical:
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueGreen,
        );

      case ServiceTypeEnum.police:
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueBlue,
        );

      case ServiceTypeEnum.fire:
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRed,
        );
    }
  }

  @override
  void initState() {
    super.initState();

    _cameraPosition = CameraPosition(
      target: widget.initialLocation,
      zoom: 15,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: widget.initialLocation,
            zoom: 15,
          ),
          scrollGesturesEnabled: _gesturesEnabled,
          zoomGesturesEnabled: _gesturesEnabled,
          rotateGesturesEnabled: _gesturesEnabled,
          tiltGesturesEnabled: _gesturesEnabled,
          zoomControlsEnabled: false,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          compassEnabled: false,
          mapToolbarEnabled: false,
          onMapCreated: (controller) {
            _mapController = controller;
            widget.onMapCreated?.call(controller);
          },
          markers: _showCenterPin ? {} : _buildMarkers(),
          onCameraIdle: () {
            if (_cameraPosition != null) {
              widget.onLocationChanged?.call(_cameraPosition!.target);
            }
          },
          onCameraMove: (position) {
            _cameraPosition = position;
          },
        ),
        if (_showCenterPin)
          const IgnorePointer(
            child: Center(
              child: Icon(
                Icons.location_pin,
                size: 50,
                color: Colors.red,
              ),
            ),
          ),
      ],
    );
  }
}

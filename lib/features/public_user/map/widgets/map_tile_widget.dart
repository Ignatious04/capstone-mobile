import 'package:capstone/core/constants/map_bounds.dart';
import 'package:capstone/core/enums/map_mode_enum.dart';
import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/core/utilities/icon_to_bitmap_descriptor.dart';
import 'package:capstone/features/public_user/map/models/emergency_service_model.dart';
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
    this.extraMarkers = const {},
  });

  final void Function(GoogleMapController controller)? onMapCreated;
  final void Function(LatLng latlng)? onLocationChanged;
  final LatLng initialLocation;
  final List<EmergencyServiceModel> services;
  final MapModeEnum mode;
  final bool? gesturesEnabled;
  final Set<Marker> extraMarkers;

  @override
  State<MapTileWidget> createState() => _MapTileWidgetState();
}

class _MapTileWidgetState extends State<MapTileWidget> {
  CameraPosition? _cameraPosition;

  bool get _showCenterPin => widget.mode == MapModeEnum.selectLocation;

  bool get _gesturesEnabled => widget.gesturesEnabled ?? (widget.mode != MapModeEnum.view);

  late BitmapDescriptor _medicalMarkerIcon;
  late BitmapDescriptor _policeMarkerIcon;
  late BitmapDescriptor _fireMarkerIcon;

  bool _markerIconsLoaded = false;

  @override
  void initState() {
    super.initState();

    final start = AngelesCityMap.contains(widget.initialLocation) ? widget.initialLocation : AngelesCityMap.center;

    _cameraPosition = CameraPosition(
      target: start,
      zoom: 15,
    );

    _loadMarkerIcons();
  }

  Future<void> _loadMarkerIcons() async {
    final medicalIcon = await IconToBitmapDescriptor.convert(
      icon: Icons.local_hospital,
      color: Colors.green,
    );

    final policeIcon = await IconToBitmapDescriptor.convert(
      icon: Icons.local_police,
      color: Colors.blue,
    );

    final fireIcon = await IconToBitmapDescriptor.convert(
      icon: Icons.local_fire_department,
      color: Colors.red,
    );

    if (!mounted) return;

    setState(() {
      _medicalMarkerIcon = medicalIcon;
      _policeMarkerIcon = policeIcon;
      _fireMarkerIcon = fireIcon;
      _markerIconsLoaded = true;
    });
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    // Don't create service markers until the custom icons
    // have finished loading.
    if (widget.mode == MapModeEnum.explore && _markerIconsLoaded) {
      for (final service in widget.services) {
        markers.add(
          Marker(
            markerId: MarkerId(service.id),
            position: LatLng(
              service.location.latitude,
              service.location.longitude,
            ),
            icon: _serviceMarkerIcon(service),
            anchor: const Offset(0.5, 0.92),
          ),
        );
      }
    }

    markers.addAll(widget.extraMarkers);

    return markers;
  }

  BitmapDescriptor _serviceMarkerIcon(
    EmergencyServiceModel service,
  ) {
    switch (service.type) {
      case ServiceTypeEnum.medical:
        return _medicalMarkerIcon;

      case ServiceTypeEnum.police:
        return _policeMarkerIcon;

      case ServiceTypeEnum.fire:
        return _fireMarkerIcon;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: _cameraPosition!,
          cameraTargetBounds: CameraTargetBounds(
            AngelesCityMap.bounds,
          ),
          minMaxZoomPreference: const MinMaxZoomPreference(
            AngelesCityMap.minZoom,
            AngelesCityMap.maxZoom,
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
            widget.onMapCreated?.call(controller);
          },
          markers: _showCenterPin ? {} : _buildMarkers(),
          onCameraIdle: () {
            if (_cameraPosition != null) {
              widget.onLocationChanged?.call(
                _cameraPosition!.target,
              );
            }
          },
          onCameraMove: (position) {
            _cameraPosition = position;
          },
        ),

        if (_showCenterPin)
           IgnorePointer(
            child: Center(
              child: Transform.translate(
                offset: const Offset(0, -21),
                child: Icon(
                  Icons.location_pin,
                  size: 50,
                  color: Colors.red,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

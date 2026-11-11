import 'package:capstone/core/constants/map_bounds.dart';
import 'package:capstone/core/enums/map_mode_enum.dart';
import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/core/shared/providers/map_layer_provider.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/core/utilities/icon_to_bitmap_descriptor.dart';
import 'package:capstone/features/public_user/map/models/emergency_service_model.dart';
import 'package:capstone/features/public_user/map/widgets/map_layer_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapTileWidget extends ConsumerStatefulWidget {
  const MapTileWidget({
    super.key,
    this.onMapCreated,
    this.onLocationChanged,
    required this.initialLocation,
    this.services = const [],
    this.mode = MapModeEnum.view,
    this.gesturesEnabled,
    this.extraMarkers = const {},
    this.extraCircles = const {},
    this.fitToPoints = const [],
    this.followLocation = false,
    this.showLayerToggle,
  });

  final void Function(GoogleMapController controller)? onMapCreated;
  final void Function(LatLng latlng)? onLocationChanged;
  final LatLng initialLocation;
  final List<EmergencyServiceModel> services;
  final MapModeEnum mode;
  final bool? gesturesEnabled;
  final Set<Marker> extraMarkers;
  final Set<Circle> extraCircles;
  final List<LatLng> fitToPoints;

  /// When true, the camera re-centers whenever [initialLocation] changes.
  /// Off by default so other map views keep their current behavior.
  final bool followLocation;

  /// Whether to show the layer (default / satellite) button on the map.
  /// Defaults to true for interactive maps and false for small, static
  /// previews. The selected layer is applied to every map either way.
  final bool? showLayerToggle;

  @override
  ConsumerState<MapTileWidget> createState() => _MapTileWidgetState();
}

class _MapTileWidgetState extends ConsumerState<MapTileWidget> {
  CameraPosition? _cameraPosition;

  GoogleMapController? _controller;

  @override
  void didUpdateWidget(covariant MapTileWidget old) {
    super.didUpdateWidget(old);
    if (widget.fitToPoints.length >= 2 && !listEquals(widget.fitToPoints, old.fitToPoints)) {
  _fit();
}

    if (widget.followLocation &&
        widget.initialLocation != old.initialLocation &&
        AngelesCityMap.contains(widget.initialLocation)) {
      // newLatLng keeps the current zoom level.
      _controller?.animateCamera(CameraUpdate.newLatLng(widget.initialLocation));
    }
  }

  Future<void> _fit() async {
    final c = _controller;
    if (c == null) return;
    final pts = widget.fitToPoints;
    final south = pts.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    final north = pts.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    final west = pts.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    final east = pts.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);
    await c.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: LatLng(south, west), northeast: LatLng(north, east)),
        60,
      ),
    );
  }

  bool get _showCenterPin => widget.mode == MapModeEnum.selectLocation;

  bool get _gesturesEnabled => widget.gesturesEnabled ?? (widget.mode != MapModeEnum.view);

  bool get _showLayerToggle => widget.showLayerToggle ?? _gesturesEnabled;

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
          mapType: ref.watch(mapLayerProvider).mapType,
          scrollGesturesEnabled: _gesturesEnabled,
          zoomGesturesEnabled: _gesturesEnabled,
          rotateGesturesEnabled: _gesturesEnabled,
          tiltGesturesEnabled: _gesturesEnabled,
          zoomControlsEnabled: false,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          compassEnabled: false,
          mapToolbarEnabled: false,
          onMapCreated: (c) {
            _controller = c;
            widget.onMapCreated?.call(c);
            if (widget.fitToPoints.length >= 2) _fit();
          },
          markers: _showCenterPin ? {} : _buildMarkers(),
          circles: _showCenterPin ? {} : widget.extraCircles,
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

        if (_showLayerToggle)
          const Positioned(
           top: 12,
           right: 12,
            child: MapLayerButton(),
          ),

        if (_showCenterPin)
          IgnorePointer(
            child: Center(
              child: Transform.translate(
                offset: const Offset(0, -21),
                child: Icon(
                  Icons.location_pin,
                  size: 50,
                  color: AppColors.themeColor,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

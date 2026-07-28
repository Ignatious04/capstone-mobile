import 'package:capstone/core/enums/map_mode_enum.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapTileWidget extends StatefulWidget {
  const MapTileWidget({
    super.key,
    this.onMapCreated,
    this.onLocationChanged,
    required this.initialLocation,
    this.mode = MapModeEnum.view,
    this.gesturesEnabled,
  });

  final void Function(GoogleMapController controller)? onMapCreated;
  final void Function(LatLng latlng)? onLocationChanged;
  final LatLng initialLocation;
  final MapModeEnum mode;
  final bool? gesturesEnabled;

  @override
  State<MapTileWidget> createState() => _MapTileWidgetState();
}

class _MapTileWidgetState extends State<MapTileWidget> {
  GoogleMapController? _controller;
  CameraPosition? _cameraPosition;

  bool get _showCenterPin => widget.mode == MapModeEnum.selectLocation;
  bool get _gesturesEnabled => widget.gesturesEnabled ?? (widget.mode != MapModeEnum.view);

  @override
  void initState() {
    super.initState();

    _cameraPosition = CameraPosition(
      target: widget.initialLocation,
      zoom: 15,
    );
  }

  BitmapDescriptor _markerIcon() {
    switch (widget.mode) {
      case MapModeEnum.view:
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRed,
        );

      case MapModeEnum.explore:
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueAzure,
        );

      case MapModeEnum.selectLocation:
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRed,
        );
    }
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
          myLocationButtonEnabled: false,
          compassEnabled: false,
          mapToolbarEnabled: false,
          onMapCreated: (controller) {
            _controller = controller;
            widget.onMapCreated?.call(controller);
          },
          markers: _showCenterPin
              ? {}
              : {
                  Marker(
                    markerId: const MarkerId("location"),
                    position: widget.initialLocation,
                    icon: _markerIcon(),
                  ),
                },
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

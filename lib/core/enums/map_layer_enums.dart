import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Base map layers the user can switch between.
///
/// [satellite] maps to [MapType.hybrid] (satellite imagery with street and
/// place labels) so people can still read road names during an emergency.
enum MapLayerEnum {
  standard(MapType.normal),
  satellite(MapType.hybrid);

  const MapLayerEnum(this.mapType);

  final MapType mapType;
}
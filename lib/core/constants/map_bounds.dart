import 'package:google_maps_flutter/google_maps_flutter.dart';

class AngelesCityMap {
  static const LatLng center = LatLng(15.1470, 120.5888);

  // APPROXIMATE box around the city. Verify and tune these on a real map.
  static final LatLngBounds bounds = LatLngBounds(
    southwest: const LatLng(15.10, 120.52),
    northeast: const LatLng(15.20, 120.64),
  );

  static const double minZoom = 12.5;
  static const double maxZoom = 19;

  static bool contains(LatLng p) =>
      p.latitude >= bounds.southwest.latitude &&
      p.latitude <= bounds.northeast.latitude &&
      p.longitude >= bounds.southwest.longitude &&
      p.longitude <= bounds.northeast.longitude;
}

import 'package:capstone/core/enums/location_status_enum.dart';
import 'package:capstone/core/services/location_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final locationServiceProvider = Provider<LocationService>(
  (ref) => LocationService(),
);

final locationStatusProvider = FutureProvider<LocationStatusEnum>((ref) async {
  final locationService = ref.read(locationServiceProvider);

  return locationService.checkLocationStatus();
});

final currentLocationProvider = FutureProvider<LatLng>((ref) async {
  final locationService = ref.read(locationServiceProvider);

  return locationService.getCurrentLocation();
});

final locationStreamProvider = StreamProvider<LatLng>((ref) {
  final locationService = ref.read(locationServiceProvider);

  return locationService.getLocationStream();
});

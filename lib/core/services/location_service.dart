import 'package:capstone/core/enums/location_status_enum.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  LatLng? currentLatLng;

  Future<LocationStatusEnum> checkLocationStatus() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return LocationStatusEnum.serviceDisabled;
    }

    final permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      return LocationStatusEnum.permissionDenied;
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationStatusEnum.permissionDeniedForever;
    }

    return LocationStatusEnum.ready;
  }

  Future<LocationStatusEnum> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return LocationStatusEnum.permissionDenied;
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationStatusEnum.permissionDeniedForever;
    }

    return LocationStatusEnum.ready;
  }

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  Future<LatLng> getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition();

    currentLatLng = LatLng(
      position.latitude,
      position.longitude,
    );

    return currentLatLng!;
  }

  Stream<LatLng> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).map((position) {
      currentLatLng = LatLng(
        position.latitude,
        position.longitude,
      );

      return currentLatLng!;
    });
  }
}

import 'package:capstone/core/l10n/app_localizations.dart';
import 'dart:async';
import 'package:capstone/core/enums/location_status_enum.dart';
import 'package:flutter/foundation.dart';
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

  Future<LocationFix> getCurrentLocation() async {
    Position position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } on TimeoutException {
      // Fall back to last known position, or a lower-accuracy fix
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        position = lastKnown;
      } else {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 20),
          ),
        );
      }
    }

    currentLatLng = LatLng(position.latitude, position.longitude);
    return LocationFix(latLng: currentLatLng!, accuracy: position.accuracy);
  }

  Stream<LatLng> getLocationStream() async* {
    final last = await Geolocator.getLastKnownPosition();
    if (last != null &&
        DateTime.now().difference(last.timestamp) < const Duration(minutes: 1)) {
      yield LatLng(last.latitude, last.longitude);
    }

    yield* Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).map((p) => currentLatLng = LatLng(p.latitude, p.longitude));
  }

  Stream<LatLng> getResponderLocationStream({required AppLocalizations l10n}) {
    final LocationSettings settings = defaultTargetPlatform == TargetPlatform.android
        ? AndroidSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
            intervalDuration: const Duration(seconds: 5),
            foregroundNotificationConfig: ForegroundNotificationConfig(
              notificationTitle: l10n.locationShareTitle,
              notificationText: l10n.locationShareBody,
              enableWakeLock: true,
              setOngoing: true,
            ),
          )
        : AppleSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
            activityType: ActivityType.automotiveNavigation,
            pauseLocationUpdatesAutomatically: false,
            showBackgroundLocationIndicator: true,
            allowBackgroundLocationUpdates: true,
          );

    return Geolocator.getPositionStream(locationSettings: settings).map((p) {
      currentLatLng = LatLng(p.latitude, p.longitude);
      return currentLatLng!;
    });
  }
}

class LocationFix {
  const LocationFix({required this.latLng, required this.accuracy});
  final LatLng latLng;
  final double accuracy; // meters
}

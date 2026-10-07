import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EtaEstimate {
  const EtaEstimate({required this.distanceMeters, required this.duration});

  final double distanceMeters;
  final Duration duration;

  bool get isArriving => distanceMeters < EtaCalculator.arrivedMeters;

  String get distanceLabel =>
      distanceMeters >= 1000 ? '${(distanceMeters / 1000).toStringAsFixed(1)} km' : '${distanceMeters.round()} m';

  String get durationLabel {
    if (isArriving) return 'Arriving now';
    final minutes = duration.inSeconds / 60;
    if (minutes < 1) return 'Less than 1 min';
    if (minutes < 60) return '~${minutes.round()} min';
    final h = duration.inHours;
    final m = duration.inMinutes % 60;
    return '~${h}h ${m}m';
  }
}

class EtaCalculator {
  /// Straight-line distance understates real road distance.
  static const double roadFactor = 1.4;

  /// Assumed average speed for an emergency vehicle in city traffic.
  static const double avgSpeedKmh = 30;

  /// Closer than this counts as arrived.
  static const double arrivedMeters = 50;

  static EtaEstimate estimate(LatLng responder, LatLng incident) {
    final straight = Geolocator.distanceBetween(
      responder.latitude,
      responder.longitude,
      incident.latitude,
      incident.longitude,
    );
    final roadMeters = straight * roadFactor;
    final seconds = (roadMeters / (avgSpeedKmh * 1000 / 3600)).round();
    return EtaEstimate(
      distanceMeters: roadMeters,
      duration: Duration(seconds: seconds),
    );
  }
}

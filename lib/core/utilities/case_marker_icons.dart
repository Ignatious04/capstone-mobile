import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/core/utilities/icon_to_bitmap_descriptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// The pin's tip sits ~92% down the bitmap (see IconToBitmapDescriptor).
/// Without this anchor the pin floats above the actual coordinate.
const Offset kPinAnchor = Offset(0.5, 0.92);

const _serviceStyles = <ServiceTypeEnum, (IconData, Color)>{
  ServiceTypeEnum.medical: (Icons.local_hospital, Colors.green),
  ServiceTypeEnum.police: (Icons.local_police, Colors.blue),
  ServiceTypeEnum.fire: (Icons.local_fire_department, Colors.red),
};

class CaseMarkerIcons {
  const CaseMarkerIcons({required this.services, required this.responder});
  final Map<ServiceTypeEnum, BitmapDescriptor> services;
  final BitmapDescriptor responder;
}

/// Not autoDispose, so the bitmaps are rendered once per app session.
final caseMarkerIconsProvider = FutureProvider<CaseMarkerIcons>((ref) async {
  final entries = await Future.wait(
    _serviceStyles.entries.map(
      (e) async => MapEntry(
        e.key,
        await IconToBitmapDescriptor.convert(icon: e.value.$1, color: e.value.$2),
      ),
    ),
  );

  final responder = await IconToBitmapDescriptor.convert(
    icon: Icons.directions_car, // your call: any icon/color not used by the services
    color: Colors.deepOrange,
  );

  return CaseMarkerIcons(services: Map.fromEntries(entries), responder: responder);
});

/// Falls back to the old default markers while icons load (or if incidentType is null).
Set<Marker> buildCaseMarkers({
  required CaseMarkerIcons? icons,
  required LatLng incident,
  required ServiceTypeEnum? incidentType,
  LatLng? responder,
}) {
  final incidentIcon = icons?.services[incidentType];

  return {
    Marker(
      markerId: const MarkerId('incident'),
      position: incident,
      icon: incidentIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      anchor: incidentIcon != null ? kPinAnchor : const Offset(0.5, 1.0),
    ),
    if (responder != null)
      Marker(
        markerId: const MarkerId('responder'),
        position: responder,
        icon: icons?.responder ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        anchor: icons != null ? kPinAnchor : const Offset(0.5, 1.0),
      ),
  };
}
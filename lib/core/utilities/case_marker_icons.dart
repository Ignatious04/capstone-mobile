import 'package:capstone/core/utilities/icon_to_bitmap_descriptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// The pin's tip sits ~92% down the bitmap (see IconToBitmapDescriptor).
/// Without this anchor the pin floats above the actual coordinate.
const Offset kPinAnchor = Offset(0.5, 0.92);

class CaseMarkerIcons {
  const CaseMarkerIcons({required this.incident, required this.responder});
  final BitmapDescriptor incident;
  final BitmapDescriptor responder;
}

/// Not autoDispose, so the bitmaps are rendered once per app session.
final caseMarkerIconsProvider = FutureProvider<CaseMarkerIcons>((ref) async {
  final incident = await IconToBitmapDescriptor.convert(
    icon: Icons.emergency, // any icon works here
    color: Colors.red,
  );

  final responder = await IconToBitmapDescriptor.convert(
    icon: Icons.directions_car, // your call: any icon/color not used by the services
    color: Colors.deepOrange,
  );

  return CaseMarkerIcons(incident: incident, responder: responder);
});

/// Falls back to the old default markers while icons load (or if incidentType is null).
Set<Marker> buildCaseMarkers({
  required CaseMarkerIcons? icons,
  required LatLng incident,
  LatLng? responder,
}) {
  return {
    Marker(
      markerId: const MarkerId('incident'),
      position: incident,
      icon: icons?.incident ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      anchor: icons != null ? kPinAnchor : const Offset(0.5, 1.0),
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

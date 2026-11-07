import 'package:capstone/core/shared/models/realtime_responder_location_model.dart';
import 'package:capstone/core/shared/providers/realtime_database_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Live position of one responder on one report. Each responder has their own
/// node (`responderLocations/{reportID}/{responderID}`), so every service on
/// a report can be watched separately.
final responderLocationProvider = StreamProvider.autoDispose
    .family<LatLng?, ({String reportID, String responderID})>((ref, key) {
      final database = ref.read(realtimeDatabaseRepositoryProvider);

      return database.watch(path: 'responderLocations/${key.reportID}/${key.responderID}').map((event) {
        final value = event.snapshot.value;
        if (value is! Map) return null; // node missing = not sharing (or their case resolved)
        final model = RealtimeResponderLocationModel.fromMap(Map<String, dynamic>.from(value));
        return LatLng(model.latitude, model.longitude);
      });
    });

    typedef ResponderKey = ({String reportID, String responderID});

/// Positions of every responder in [keys] who is currently sharing their location.
/// Call from build(): it watches each responder's stream.
List<LatLng> watchResponderPositions(WidgetRef ref, List<ResponderKey> keys) {
  final positions = <LatLng>[];
  for (final key in keys) {
    final position = ref.watch(responderLocationProvider(key)).value;
    if (position != null) positions.add(position);
  }
  return positions;
}

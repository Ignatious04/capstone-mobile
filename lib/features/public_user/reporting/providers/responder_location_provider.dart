import 'package:capstone/core/shared/models/realtime_responder_location_model.dart';
import 'package:capstone/core/shared/providers/realtime_database_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final responderLocationProvider = StreamProvider.autoDispose.family<LatLng?, String>((ref, reportID) {
  final database = ref.read(realtimeDatabaseRepositoryProvider);

  return database.watch(path: 'responderLocations/$reportID').map((event) {
    final value = event.snapshot.value;
    if (value is! Map) return null; // node missing = not sharing (or case resolved)
    final model = RealtimeResponderLocationModel.fromMap(Map<String, dynamic>.from(value));
    return LatLng(model.latitude, model.longitude);
  });
});

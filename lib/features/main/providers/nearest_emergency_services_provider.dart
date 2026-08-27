// lib/features/map/providers/nearest_emergency_service_provider.dart
import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/core/shared/providers/location_provider.dart';
import 'package:capstone/core/utilities/distance_helper.dart';
import 'package:capstone/features/map/models/emergency_service_model.dart';
import 'package:capstone/features/map/providers/emergency_service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final nearestEmergencyServicesProvider =
    Provider<AsyncValue<Map<ServiceTypeEnum, EmergencyServiceModel?>>>((ref) {
  final servicesAsync = ref.watch(emergencyServicesProvider);
  final locationAsync = ref.watch(locationStreamProvider);

  if (locationAsync.hasError) {
    return AsyncValue.error(locationAsync.error!, locationAsync.stackTrace!);
  }
  if (servicesAsync.hasError) {
    return AsyncValue.error(servicesAsync.error!, servicesAsync.stackTrace!);
  }

  final currentLocation = locationAsync.value;
  final services = servicesAsync.value;

  if (currentLocation == null || services == null) {
    return const AsyncValue.loading();
  }

  final Map<ServiceTypeEnum, EmergencyServiceModel?> nearest = {};

  for (final type in ServiceTypeEnum.values) {
    final servicesOfType = services.where((s) => s.type == type).toList()
      ..sort(
        (a, b) => DistanceHelper.distanceInMeters(currentLocation, a.location)
            .compareTo(DistanceHelper.distanceInMeters(currentLocation, b.location)),
      );

    nearest[type] = servicesOfType.isNotEmpty ? servicesOfType.first : null;
  }

  return AsyncValue.data(nearest);
});
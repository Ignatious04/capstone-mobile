import 'package:capstone/features/map/models/emergency_service_model.dart';
import 'package:capstone/features/map/providers/emergency_service_filter_provider.dart';
import 'package:capstone/features/map/providers/emergency_service_provider.dart';
import 'package:capstone/features/map/providers/emergency_service_search_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final filteredEmergencyServicesProvider = Provider<AsyncValue<List<EmergencyServiceModel>>>((ref) {
  final servicesAsync = ref.watch(emergencyServicesProvider);
  final query = ref.watch(emergencyServiceSearchProvider).trim().toLowerCase();
  final typeFilter = ref.watch(emergencyServiceFilterProvider);

  return servicesAsync.whenData((services) {
    return services.where((service) {
      final matchesQuery = query.isEmpty || service.name.toLowerCase().contains(query);
      final matchesType = typeFilter == null || service.type == typeFilter;

      return matchesQuery && matchesType;
    }).toList();
  });
});

import 'package:capstone/features/public_user/map/models/emergency_service_model.dart';
import 'package:capstone/features/public_user/map/providers/emergency_service_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final emergencyServicesProvider =
    StreamProvider<List<EmergencyServiceModel>>((ref) {
      final repository = ref.watch(
        emergencyServicesRepositoryProvider,
      );

      return repository.watchServices();
    });
import 'package:capstone/core/shared/providers/firestore_provider.dart';
import 'package:capstone/features/public_user/map/repositories/emergency_service_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final emergencyServicesRepositoryProvider = Provider<EmergencyServicesRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);

  return EmergencyServicesRepository(firestore);
});

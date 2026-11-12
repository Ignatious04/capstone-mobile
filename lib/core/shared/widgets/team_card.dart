import 'package:capstone/core/shared/models/team_model.dart';
import 'package:capstone/core/shared/providers/team_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final teamsByServiceProvider = StreamProvider.family<List<TeamModel>, String>((ref, serviceID) {
  if (serviceID.isEmpty) {
    return Stream.value(const <TeamModel>[]);
  }

  return ref.watch(teamRepositoryProvider).watchTeamsByService(serviceID);
});
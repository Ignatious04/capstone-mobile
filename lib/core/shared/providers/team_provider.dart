import 'package:capstone/core/shared/models/team_model.dart';
import 'package:capstone/core/shared/providers/team_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final teamsForServiceProvider = StreamProvider.family<List<TeamModel>, String>((ref, serviceID) {
  if (serviceID.isEmpty) return Stream.value(const []);
  return ref.watch(teamRepositoryProvider).watchTeamsForService(serviceID);
});

final teamsForMemberProvider = StreamProvider.family<List<TeamModel>, String>((ref, responderID) {
  if (responderID.isEmpty) return Stream.value(const []);
  return ref.watch(teamRepositoryProvider).watchTeamsForMember(responderID);
});
import 'package:capstone/core/shared/providers/firestore_provider.dart';
import 'package:capstone/core/shared/repositories/team_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final teamRepositoryProvider = Provider<TeamRepository>((ref) {
  return TeamRepository(ref.watch(firestoreProvider));
});
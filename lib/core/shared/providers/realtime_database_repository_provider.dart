import 'package:capstone/core/shared/repositories/realtime_database_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final realtimeDatabaseRepositoryProvider = Provider<RealtimeDatabaseRepository>((
  ref,
) {
  return RealtimeDatabaseRepository();
});

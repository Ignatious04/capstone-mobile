import 'package:capstone/core/shared/providers/firestore_provider.dart';
import 'package:capstone/core/shared/repositories/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(firestoreProvider));
});

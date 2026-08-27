import 'package:capstone/core/shared/providers/firestore_provider.dart';
import 'package:capstone/core/shared/repositories/responder_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final responderRepositoryProvider = Provider<ResponderRepository>((ref) {
  return ResponderRepository(ref.watch(firestoreProvider));
});

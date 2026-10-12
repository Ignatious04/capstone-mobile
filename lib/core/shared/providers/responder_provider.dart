import 'package:capstone/core/shared/models/responder_model.dart';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/providers/responder_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentAuthenticatedResponderProvider = StreamProvider<ResponderModel?>((ref) {
  final currentUser = ref.watch(authStateProvider).value;

  if (currentUser == null) {
    return Stream.value(null);
  }

  return ref.read(responderRepositoryProvider).watchResponder(currentUser.uid);
});

final responderByIdProvider = StreamProvider.family<ResponderModel?, String>(
  (ref, responderID) {
    if (responderID.isEmpty) {
      return Stream.value(null);
    }

    return ref.read(responderRepositoryProvider).watchResponder(responderID);
  },
);

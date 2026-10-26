import 'package:capstone/core/shared/models/response_model.dart';
import 'package:capstone/core/shared/providers/responder_provider.dart';
import 'package:capstone/core/shared/providers/response_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The responder's own resolved responses. Incident details are loaded per
/// item from the report (see HistoryCaseCard).
final responderHistoryProvider = StreamProvider<List<ResponseModel>>((ref) {
  // Watch only the id. Watching the whole responder would rebuild this stream
  // (and flash a spinner) every time the responder doc changes, e.g. when
  // isAvailable flips back to true on resolve.
  final responderID = ref.watch(
    currentAuthenticatedResponderProvider.select((r) => r.value?.id),
  );

  if (responderID == null) return Stream.value(const <ResponseModel>[]);
  return ref.read(responseRepositoryProvider).watchResolvedResponses(responderID);
});

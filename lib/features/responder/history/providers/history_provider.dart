import 'package:capstone/core/shared/models/report_model.dart';
import 'package:capstone/core/shared/providers/report_repository_provider.dart';
import 'package:capstone/core/shared/providers/responder_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final responderHistoryProvider = StreamProvider<List<ReportModel>>((ref) {
  // Watch only the id. Watching the whole responder would rebuild this stream
  // (and flash a spinner) every time the responder doc changes, e.g. when
  // isAvailable flips back to true on resolve.
  final responderID = ref.watch(
    currentAuthenticatedResponderProvider.select((r) => r.value?.id),
  );

  if (responderID == null) return Stream.value(const <ReportModel>[]);
  return ref.read(reportRepositoryProvider).watchResolvedReports(responderID);
});

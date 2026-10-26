import 'package:capstone/core/shared/models/report_model.dart';
import 'package:capstone/core/shared/models/response_model.dart';
import 'package:capstone/core/shared/providers/report_repository_provider.dart';
import 'package:capstone/core/shared/providers/responder_provider.dart';
import 'package:capstone/core/shared/providers/response_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A responder's current case: their own service's response, plus the shared
/// incident it belongs to.
class ActiveCase {
  const ActiveCase({required this.response, required this.report});

  final ResponseModel response;
  final ReportModel report;
}

final activeResponseProvider = StreamProvider<ResponseModel?>((ref) {
  final responderAsync = ref.watch(currentAuthenticatedResponderProvider);

  return responderAsync.when(
    data: (responder) {
      if (responder == null) return Stream.value(null);
      return ref.read(responseRepositoryProvider).watchActiveResponse(responder.id);
    },
    loading: () => const Stream.empty(),
    error: (_, _) => Stream.value(null),
  );
});

final activeCaseProvider = Provider<AsyncValue<ActiveCase?>>((ref) {
  final responseAsync = ref.watch(activeResponseProvider);
  final response = responseAsync.value;
  if (response == null) return responseAsync.whenData((_) => null);

  return ref
      .watch(reportByIdProvider(response.reportID))
      .whenData((report) => report == null ? null : ActiveCase(response: response, report: report));
});

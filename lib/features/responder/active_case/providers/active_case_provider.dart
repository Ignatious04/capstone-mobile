import 'package:capstone/core/shared/providers/responder_provider.dart';
import 'package:capstone/features/public_user/reporting/models/report_model.dart';
import 'package:capstone/features/public_user/reporting/providers/report_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final activeCaseProvider = StreamProvider<ReportModel?>((ref) {
  final responderAsync = ref.watch(currentAuthenticatedResponderProvider);

  return responderAsync.when(
    data: (responder) {
      if (responder == null) return Stream.value(null);
      return ref.read(reportRepositoryProvider).watchAssignedReport(responder.responderId);
    },
    loading: () => const Stream.empty(),
    error: (_, _) => Stream.value(null),
  );
});

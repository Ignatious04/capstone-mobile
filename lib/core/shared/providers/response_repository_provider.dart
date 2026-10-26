import 'package:capstone/core/shared/models/response_model.dart';
import 'package:capstone/core/shared/providers/firestore_provider.dart';
import 'package:capstone/core/shared/repositories/response_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final responseRepositoryProvider = Provider<ResponseRepository>(
  (ref) => ResponseRepository(ref.watch(firestoreProvider)),
);

/// All service responses for one report (the reporter's view).
final responsesForReportProvider = StreamProvider.autoDispose
    .family<List<ResponseModel>, ({String reportID, String userID})>((ref, key) {
      return ref.watch(responseRepositoryProvider).watchForReport(reportID: key.reportID, userID: key.userID);
    });

import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/providers/firestore_provider.dart';
import 'package:capstone/core/shared/models/report_model.dart';
import 'package:capstone/core/shared/repositories/report_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reportRepositoryProvider = Provider<ReportRepository>(
  (ref) {
    return ReportRepository(ref.watch(firestoreProvider));
  },
);

final reportsStreamProvider = StreamProvider.autoDispose<List<ReportModel>>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(reportRepositoryProvider).getReports(uid);
});

final reportByIdProvider = StreamProvider.autoDispose.family<ReportModel?, String>((ref, reportID) {
  return ref.watch(reportRepositoryProvider).watchReport(reportID);
});

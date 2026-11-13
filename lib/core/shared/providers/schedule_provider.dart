import 'package:capstone/core/shared/models/shift_exception_model.dart';
import 'package:capstone/core/shared/models/shift_model.dart';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/providers/firestore_provider.dart';
import 'package:capstone/core/shared/providers/team_provider.dart';
import 'package:capstone/core/shared/repositories/shift_repository.dart';
import 'package:capstone/core/utilities/duty_resolver.dart';
import 'package:capstone/core/utilities/schedule_time.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const int kScheduleWindowDays = 14;

final shiftRepositoryProvider = Provider<ShiftRepository>((ref) {
  return ShiftRepository(ref.watch(firestoreProvider));
});

// Family keys need value equality, so the owner IDs are passed as one sorted, comma-joined string.
String _ownerKey(Iterable<String> ids) => (ids.where((id) => id.isNotEmpty).toSet().toList()..sort()).join(',');

List<String> _ownerIDs(String key) => key.isEmpty ? <String>[] : key.split(',');

final shiftsForOwnersProvider = StreamProvider.family<List<ShiftModel>, String>((ref, key) {
  return ref.watch(shiftRepositoryProvider).watchShiftsForOwners(_ownerIDs(key));
});

final shiftExceptionsForOwnersProvider = StreamProvider.family<List<ShiftExceptionModel>, String>((ref, key) {
  return ref.watch(shiftRepositoryProvider).watchExceptionsForOwners(_ownerIDs(key));
});

/// Philippine wall-clock "now", refreshed every 30 seconds.
final phClockProvider = StreamProvider.autoDispose<DateTime>((ref) async* {
  while (true) {
    yield phNow();
    await Future<void>.delayed(const Duration(seconds: 30));
  }
});

/// Only changes at midnight, so the schedule isn't recomputed every tick.
final phTodayProvider = Provider.autoDispose<DateTime>((ref) {
  final now = ref.watch(phClockProvider).value ?? phNow();
  return DateTime.utc(now.year, now.month, now.day);
});

final myDutyProvider = Provider.autoDispose<AsyncValue<List<DutyEntry>>>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid ?? '';
  final teamsAsync = ref.watch(teamsForMemberProvider(uid));
  final teamIDs = (teamsAsync.value ?? const []).map((t) => t.id).toSet();

  final key = _ownerKey([uid, ...teamIDs]);
  final shiftsAsync = ref.watch(shiftsForOwnersProvider(key));
  final exceptionsAsync = ref.watch(shiftExceptionsForOwnersProvider(key));

  final error = teamsAsync.error ?? shiftsAsync.error ?? exceptionsAsync.error;
  if (error != null) return AsyncError(error, StackTrace.current);

  if (!teamsAsync.hasValue || !shiftsAsync.hasValue || !exceptionsAsync.hasValue) {
    return const AsyncLoading();
  }

  return AsyncData(
    resolveDuty(
      responderID: uid,
      teamIDs: teamIDs,
      shifts: shiftsAsync.requireValue,
      exceptions: exceptionsAsync.requireValue,
      from: ref.watch(phTodayProvider),
      days: kScheduleWindowDays,
    ),
  );
});
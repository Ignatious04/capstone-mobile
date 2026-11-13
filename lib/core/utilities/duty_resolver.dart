import 'package:capstone/core/enums/shift_exception_type.dart';
import 'package:capstone/core/enums/shift_owner_type.dart';
import 'package:capstone/core/shared/models/shift_exception_model.dart';
import 'package:capstone/core/shared/models/shift_model.dart';
import 'package:capstone/core/utilities/schedule_time.dart';

enum DutyStatus { scheduled, extra, overtime, onLeave, swappedAway }

/// One concrete duty window. [start]/[end] are naive wall-clock values (UTC-flagged).
class DutyEntry {
  const DutyEntry({
    required this.start,
    required this.end,
    required this.status,
    this.teamID = '',
    this.swapWithOwnerID = '',
    this.note = '',
  });

  final DateTime start;
  final DateTime end;
  final DutyStatus status;

  /// The team the duty comes from; '' for a personal shift/exception.
  final String teamID;
  final String swapWithOwnerID;
  final String note;

  bool get isWorking =>
      status == DutyStatus.scheduled || status == DutyStatus.extra || status == DutyStatus.overtime;
}

/// Turns recurring shifts + one-off exceptions into dated duty windows for
/// [days] days starting at [from] (a date at 00:00, UTC-flagged).
List<DutyEntry> resolveDuty({
  required String responderID,
  required Set<String> teamIDs,
  required List<ShiftModel> shifts,
  required List<ShiftExceptionModel> exceptions,
  required DateTime from,
  required int days,
}) {
  bool follows(ShiftOwnerType type, String id) =>
      type == ShiftOwnerType.responder ? id == responderID : teamIDs.contains(id);

  final mine = shifts.where((s) => follows(s.ownerType, s.ownerID)).toList();
  final myExceptions = exceptions.where((e) => follows(e.ownerType, e.ownerID)).toList();

  final windowEnd = from.add(Duration(days: days));
  final entries = <DutyEntry>[];

  // Start one day early: a night shift that began yesterday may still be running at [from].
  for (var d = from.subtract(const Duration(days: 1));
      d.isBefore(windowEnd);
      d = d.add(const Duration(days: 1))) {
    final onThisDate = myExceptions.where((e) => e.date == dateKey(d)).toList();

    for (final shift in mine) {
      if (!shift.runsOn(d)) continue;

      final start = d.add(Duration(minutes: shift.startMinutes));
      var end = start.add(Duration(minutes: shift.durationMinutes));
      final teamID = shift.ownerType == ShiftOwnerType.team ? shift.ownerID : '';

      // Exceptions on this date that touch this shift: its own owner's, or the
      // responder's personal ones (those also cover team shifts they follow).
      final touching = onThisDate
          .where((e) => e.ownerType == ShiftOwnerType.responder ||
              (e.ownerType == shift.ownerType && e.ownerID == shift.ownerID))
          .toList();

      final cancel = touching
          .where((e) => e.type == ShiftExceptionType.leave || e.type == ShiftExceptionType.swap)
          .firstOrNull;

      if (cancel != null) {
        entries.add(DutyEntry(
          start: start,
          end: end,
          status: cancel.type == ShiftExceptionType.swap ? DutyStatus.swappedAway : DutyStatus.onLeave,
          teamID: teamID,
          swapWithOwnerID: cancel.swapWithOwnerID,
          note: cancel.note,
        ));
        continue;
      }

      var status = DutyStatus.scheduled;
      var note = '';

      final overtime = touching.where((e) => e.type == ShiftExceptionType.overtime).firstOrNull;
      if (overtime != null) {
        // Earliest moment with the overtime clock time on the shift's end date;
        // ignored unless it really extends the shift ("can only extend").
        final candidate = DateTime.utc(end.year, end.month, end.day).add(Duration(minutes: overtime.endMinutes));
        if (candidate.isAfter(end)) {
          end = candidate;
          status = DutyStatus.overtime;
          note = overtime.note;
        }
      }

      entries.add(DutyEntry(start: start, end: end, status: status, teamID: teamID, note: note));
    }

    for (final extra in onThisDate.where((e) => e.type == ShiftExceptionType.extra)) {
      final start = d.add(Duration(minutes: extra.startMinutes));
      final diff = extra.endMinutes - extra.startMinutes;
      final end = start.add(Duration(minutes: diff <= 0 ? diff + 1440 : diff));

      entries.add(DutyEntry(
        start: start,
        end: end,
        status: DutyStatus.extra,
        teamID: extra.ownerType == ShiftOwnerType.team ? extra.ownerID : '',
        swapWithOwnerID: extra.swapWithOwnerID,
        note: extra.note,
      ));
    }
  }

  return entries.where((e) => e.end.isAfter(from)).toList()..sort((a, b) => a.start.compareTo(b.start));
}
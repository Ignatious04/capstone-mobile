import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/core/enums/shift_owner_type.dart';
import 'package:capstone/core/enums/shift_pattern.dart';
import 'package:capstone/core/utilities/schedule_time.dart';

/// shifts/{shiftID}: a recurring WEEKLY work pattern for a team or a single
/// responder, e.g. "Medical Team A works Monday to Friday, 20:00 to 08:00".
/// One document repeats every week; it is not one document per day.
///
/// READ-ONLY on the client model: written only through ShiftRepository.
///
/// Two ways to repeat ([pattern]):
///  * weekly: [daysOfWeek] uses DateTime.weekday (1 = Monday ... 7 = Sunday)
///    and names the day each shift STARTS.
///  * cycle: a rotating cycle of [cycleLengthDays] days counted from
///    [cycleStartDate] (day 1). The shift starts on the cycle days listed in
///    [cycleWorkDays], so "1 day on, 3 days off" is length 4, work days [1].
///    It never runs before its start date, and [daysOfWeek] is ignored.
///
/// Rules of the pattern:
///  * An [endTime] that is earlier than or equal to the [startTime] is on the
///    NEXT day: 20:00 -> 08:00 is a 12-hour night shift, and 08:00 -> 08:00 is
///    a 24-hour shift.
///  * [effectiveFrom] / [effectiveUntil] ("yyyy-MM-dd", '' = open) limit the
///    pattern by the date a shift starts.
class ShiftModel {
  final String id;
  final ServiceTypeEnum department;

  /// The station that owns the shift (same field as teams and responders).
  final String serviceID;

  final ShiftOwnerType ownerType;

  /// teams/{id} or responders/{id}, depending on [ownerType].
  final String ownerID;

  final List<int> daysOfWeek;

  final ShiftPattern pattern;

  /// Cycle shifts only (0 / empty / '' for weekly shifts): the length of the
  /// cycle in days, which of its days (1-based) are work days, and the date
  /// ("yyyy-MM-dd") of day 1.
  final int cycleLengthDays;
  final List<int> cycleWorkDays;
  final String cycleStartDate;

  /// "HH:mm", 24-hour, wall-clock in [timezone].
  final String startTime;
  final String endTime;

  /// A label for now: the schedule is evaluated at the Philippines' fixed
  /// UTC+8 (see phUtcOffset).
  final String timezone;

  final String effectiveFrom;
  final String effectiveUntil;
  final DateTime createdAt;

  const ShiftModel({
    required this.id,
    required this.department,
    required this.ownerType,
    required this.ownerID,
    required this.daysOfWeek,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
    this.serviceID = '',
    this.pattern = ShiftPattern.weekly,
    this.cycleLengthDays = 0,
    this.cycleWorkDays = const [],
    this.cycleStartDate = '',
    this.timezone = defaultScheduleTimezone,
    this.effectiveFrom = '',
    this.effectiveUntil = '',
  });

  int get startMinutes => parseClockMinutes(startTime) ?? 0;

  int get endMinutes => parseClockMinutes(endTime) ?? 0;

  bool get crossesMidnight => endMinutes <= startMinutes;

  /// Length of one shift in minutes, 1..1440.
  int get durationMinutes {
    final diff = endMinutes - startMinutes;

    return diff <= 0 ? diff + 1440 : diff;
  }

  /// 1-based day of the cycle that [date] falls on, or null for a weekly
  /// shift, a bad cycle, or a date before the cycle starts.
  int? cyclePosition(DateTime date) {
    if (pattern != ShiftPattern.cycle || cycleLengthDays < 1) return null;

    final start = parseDateKey(cycleStartDate);

    if (start == null) return null;

    final day = DateTime.utc(date.year, date.month, date.day);
    final diff = day.difference(start).inDays;

    if (diff < 0) return null;

    return diff % cycleLengthDays + 1;
  }

  /// Whether a shift STARTS on [startDate] (a date at 00:00): it falls on one
  /// of the weekdays (weekly) or work days (cycle), and inside the effective
  /// range.
  bool runsOn(DateTime startDate) {
    final key = dateKey(startDate);

    // "yyyy-MM-dd" strings sort the same as the dates they name.
    if (effectiveFrom.isNotEmpty && key.compareTo(effectiveFrom) < 0) {
      return false;
    }

    if (effectiveUntil.isNotEmpty && key.compareTo(effectiveUntil) > 0) {
      return false;
    }

    if (pattern == ShiftPattern.cycle) {
      final position = cyclePosition(startDate);

      return position != null && cycleWorkDays.contains(position);
    }

    return daysOfWeek.contains(startDate.weekday);
  }

  /// Throws [FormatException] for a malformed document, so the caller can
  /// skip it instead of misfiling it.
  factory ShiftModel.fromMap(Map<String, dynamic> map, String id) {
    final department = tryParseServiceType(map['department'] as String?);
    final ownerType = tryParseShiftOwnerType(map['ownerType'] as String?);
    final ownerID = (map['ownerID'] as String?)?.trim() ?? '';

    if (department == null || ownerType == null || ownerID.isEmpty) {
      throw FormatException('Shift $id has an unknown department or owner.');
    }

    final startTime = (map['startTime'] as String?)?.trim() ?? '';
    final endTime = (map['endTime'] as String?)?.trim() ?? '';

    if (parseClockMinutes(startTime) == null ||
        parseClockMinutes(endTime) == null) {
      throw FormatException('Shift $id has an invalid start or end time.');
    }

    // No pattern = a weekly shift made before cycles existed.
    final rawPattern = (map['pattern'] as String?)?.trim() ?? '';
    final pattern = rawPattern.isEmpty
        ? ShiftPattern.weekly
        : tryParseShiftPattern(rawPattern);

    if (pattern == null) {
      throw FormatException('Shift $id has an unknown pattern.');
    }

    List<int> sortedUnique(Object? raw, int max) =>
        ((raw as List?) ?? const [])
            .whereType<num>()
            .map((n) => n.toInt())
            .where((d) => d >= 1 && d <= max)
            .toSet()
            .toList()
          ..sort();

    var days = <int>[];
    var cycleLength = 0;
    var cycleWork = <int>[];
    var cycleStart = '';

    if (pattern == ShiftPattern.cycle) {
      cycleLength = (map['cycleLengthDays'] as num?)?.toInt() ?? 0;
      cycleStart = (map['cycleStartDate'] as String?)?.trim() ?? '';
      cycleWork = sortedUnique(map['cycleWorkDays'], cycleLength);

      if (cycleLength < kMinCycleDays ||
          cycleLength > kMaxCycleDays ||
          cycleWork.isEmpty ||
          parseDateKey(cycleStart) == null) {
        throw FormatException('Shift $id has an invalid cycle.');
      }
    } else {
      days = sortedUnique(map['daysOfWeek'], 7);

      if (days.isEmpty) {
        throw FormatException('Shift $id has no valid days of the week.');
      }
    }

    return ShiftModel(
      id: id,
      department: department,
      serviceID: (map['serviceID'] as String?)?.trim() ?? '',
      ownerType: ownerType,
      ownerID: ownerID,
      daysOfWeek: days,
      pattern: pattern,
      cycleLengthDays: cycleLength,
      cycleWorkDays: cycleWork,
      cycleStartDate: cycleStart,
      startTime: startTime,
      endTime: endTime,
      timezone: (map['timezone'] as String?)?.trim().isNotEmpty == true
          ? (map['timezone'] as String).trim()
          : defaultScheduleTimezone,
      effectiveFrom: (map['effectiveFrom'] as String?)?.trim() ?? '',
      effectiveUntil: (map['effectiveUntil'] as String?)?.trim() ?? '',
      createdAt: scheduleDateOf(map['createdAt']) ?? DateTime.now(),
    );
  }
}

/// A Firestore Timestamp (anything with toDate()) or a DateTime, as a
/// DateTime; null when absent (e.g. a server timestamp still pending). Kept
/// free of a cloud_firestore import so the schedule models stay plain Dart.
DateTime? scheduleDateOf(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value;

  try {
    final converted = (value as dynamic).toDate();

    return converted is DateTime ? converted : null;
  } catch (_) {
    return null;
  }
}
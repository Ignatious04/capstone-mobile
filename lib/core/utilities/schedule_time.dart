/// Small, dependency-free helpers for the duty schedule's clock times
/// ("HH:mm") and calendar dates ("yyyy-MM-dd").
///
/// Times and dates in shifts / shiftExceptions are WALL-CLOCK values in
/// the shift's timezone, stored as plain strings so they never shift with the
/// viewer's browser timezone.

/// The Philippines has no daylight saving time, so the schedule is evaluated
/// at a fixed UTC+8. The timezone field on a shift is a label ("Asia/Manila")
/// until a second timezone is ever needed.
const Duration phUtcOffset = Duration(hours: 8);

const String defaultScheduleTimezone = 'Asia/Manila';

final RegExp _clock = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');
final RegExp _date = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

/// "20:00" -> 1200 (minutes after midnight), or null when it is not a valid
/// 24-hour "HH:mm".
int? parseClockMinutes(String? value) {
  final match = _clock.firstMatch((value ?? '').trim());

  if (match == null) return null;

  return int.parse(match.group(1)!) * 60 + int.parse(match.group(2)!);
}

/// 1200 -> "20:00".
String formatClock(int minutes) {
  final h = (minutes ~/ 60) % 24;
  final m = minutes % 60;

  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
}

/// A calendar date as "yyyy-MM-dd" (the date parts are used as they are).
String dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

/// "2026-12-25" -> that date at 00:00 as a UTC-flagged DateTime (a "naive"
/// wall-clock value, not an instant), or null when it is not a real date
/// (2026-02-31 is rejected).
DateTime? parseDateKey(String? value) {
  final match = _date.firstMatch((value ?? '').trim());

  if (match == null) return null;

  final year = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final day = int.parse(match.group(3)!);
  final date = DateTime.utc(year, month, day);

  if (date.year != year || date.month != month || date.day != day) return null;

  return date;
}

/// Current Philippine wall-clock time as a "naive" UTC-flagged DateTime,
/// so it compares directly with the schedule's wall-clock values.
DateTime phNow() => DateTime.now().toUtc().add(phUtcOffset);

DateTime phToday() {
  final n = phNow();
  return DateTime.utc(n.year, n.month, n.day);
}

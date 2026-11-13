/// How a shift repeats.
///
///  * weekly  the same weekdays every week (Monday to Friday, say).
///  * cycle   a rotating cycle counted in days from a start date, so the
///            weekdays drift from week to week: "on duty 1 day, then 3 days
///            off" is a 4-day cycle with day 1 as the work day.
enum ShiftPattern {
  weekly,
  cycle,
}

/// Reads a stored pattern, or null when it is unknown. A missing pattern is
/// the caller's to treat as [ShiftPattern.weekly] (shifts created before
/// cycles existed have none).
ShiftPattern? tryParseShiftPattern(String? value) {
  for (final pattern in ShiftPattern.values) {
    if (pattern.name == value) return pattern;
  }
  return null;
}

/// A cycle is 2 to 31 days long.
const int kMinCycleDays = 2;
const int kMaxCycleDays = 31;

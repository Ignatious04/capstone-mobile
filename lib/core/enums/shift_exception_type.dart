/// A one-off change to the weekly pattern, for one date. The date is the day
/// the affected shift STARTS (so a night shift that starts on Monday 20:00 and
/// ends Tuesday 08:00 is changed by a Monday exception).
///
///  * leave     the owner does not work the shift that starts on [date].
///  * swap      the owner hands the shift away. It behaves like [leave]; the
///              owner who covers it gets an [extra] with the same times (the
///              pair is written together by ShiftRepository.createSwap).
///  * extra     the owner works an extra window on [date] (start and end
///              times required).
///  * overtime  the shift that starts on [date] runs until a later end time
///              (end time required; it can only extend the shift).
enum ShiftExceptionType {
  leave,
  swap,
  extra,
  overtime,
}

/// Reads a stored exception type, or null when it is missing or unknown.
ShiftExceptionType? tryParseShiftExceptionType(String? value) {
  for (final type in ShiftExceptionType.values) {
    if (type.name == value) return type;
  }
  return null;
}

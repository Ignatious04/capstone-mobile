/// Who a shift (or a one-off exception) belongs to.
///
///  * team       everyone in teams/{id}.memberIDs follows it (Medical).
///  * responder  one person follows it (for departments, or people, that do
///               not work by team).
enum ShiftOwnerType {
  team,
  responder,
}

/// Reads a stored owner type, or null when it is missing or unknown (so
/// callers can skip the record instead of misfiling it).
ShiftOwnerType? tryParseShiftOwnerType(String? value) {
  for (final type in ShiftOwnerType.values) {
    if (type.name == value) return type;
  }
  return null;
}

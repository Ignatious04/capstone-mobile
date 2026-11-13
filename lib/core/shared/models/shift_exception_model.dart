import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/core/enums/shift_exception_type.dart';
import 'package:capstone/core/enums/shift_owner_type.dart';
import 'package:capstone/core/shared/models/shift_model.dart';
import 'package:capstone/core/utilities/schedule_time.dart';

/// shiftExceptions/{id}: a one-off change to the weekly pattern for one
/// date. See [ShiftExceptionType] for what each type does. [date] is the day
/// the affected shift STARTS.
///
/// READ-ONLY on the client model: written only through ShiftRepository.
class ShiftExceptionModel {
  final String id;
  final ServiceTypeEnum department;
  final String serviceID;
  final ShiftOwnerType ownerType;
  final String ownerID;

  /// "yyyy-MM-dd".
  final String date;
  final ShiftExceptionType type;

  /// "HH:mm". Required for [ShiftExceptionType.extra] (both) and
  /// [ShiftExceptionType.overtime] (end only); '' otherwise.
  final String startTime;
  final String endTime;

  /// For a swap: the other owner (who gave the shift away or covers it).
  final String swapWithOwnerID;
  final String note;
  final DateTime createdAt;

  const ShiftExceptionModel({
    required this.id,
    required this.department,
    required this.ownerType,
    required this.ownerID,
    required this.date,
    required this.type,
    required this.createdAt,
    this.serviceID = '',
    this.startTime = '',
    this.endTime = '',
    this.swapWithOwnerID = '',
    this.note = '',
  });

  int get startMinutes => parseClockMinutes(startTime) ?? 0;

  int get endMinutes => parseClockMinutes(endTime) ?? 0;

  /// Throws [FormatException] for a malformed document, so the caller can
  /// skip it instead of misfiling it.
  factory ShiftExceptionModel.fromMap(Map<String, dynamic> map, String id) {
    final department = tryParseServiceType(map['department'] as String?);
    final ownerType = tryParseShiftOwnerType(map['ownerType'] as String?);
    final type = tryParseShiftExceptionType(map['type'] as String?);
    final ownerID = (map['ownerID'] as String?)?.trim() ?? '';
    final date = (map['date'] as String?)?.trim() ?? '';

    if (department == null ||
        ownerType == null ||
        type == null ||
        ownerID.isEmpty) {
      throw FormatException(
        'Shift exception $id has an unknown department, owner or type.',
      );
    }

    if (parseDateKey(date) == null) {
      throw FormatException('Shift exception $id has an invalid date.');
    }

    final startTime = (map['startTime'] as String?)?.trim() ?? '';
    final endTime = (map['endTime'] as String?)?.trim() ?? '';

    final needsStart = type == ShiftExceptionType.extra;
    final needsEnd = type == ShiftExceptionType.extra ||
        type == ShiftExceptionType.overtime;

    if ((needsStart && parseClockMinutes(startTime) == null) ||
        (needsEnd && parseClockMinutes(endTime) == null)) {
      throw FormatException('Shift exception $id is missing its times.');
    }

    return ShiftExceptionModel(
      id: id,
      department: department,
      serviceID: (map['serviceID'] as String?)?.trim() ?? '',
      ownerType: ownerType,
      ownerID: ownerID,
      date: date,
      type: type,
      startTime: startTime,
      endTime: endTime,
      swapWithOwnerID: (map['swapWithOwnerID'] as String?)?.trim() ?? '',
      note: (map['note'] as String?)?.trim() ?? '',
      createdAt: scheduleDateOf(map['createdAt']) ?? DateTime.now(),
    );
  }
}

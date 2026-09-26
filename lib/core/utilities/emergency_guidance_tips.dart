import 'package:capstone/core/enums/service_type_enum.dart';

abstract final class EmergencyGuidanceTips {
  static const Map<ServiceTypeEnum, List<String>> _tips = {
    ServiceTypeEnum.medical: [
      'Keep the person calm and as still as possible.',
      'Apply steady pressure to any bleeding wound with a clean cloth.',
      'Do not give food or water if they are unconscious or having trouble breathing.',
      'Loosen tight clothing and keep them warm.',
      'If they stop breathing and you know CPR, begin chest compressions.',
    ],
    ServiceTypeEnum.fire: [
      'Get everyone out of the building and stay out.',
      'Do not use elevators; take the stairs if evacuating.',
      'Stay low to the ground to avoid smoke inhalation.',
      'Close doors behind you as you leave to slow the fire\'s spread.',
      'If clothing catches fire: stop, drop, and roll.',
    ],
    ServiceTypeEnum.police: [
      'Move to a safe location away from the threat if you can.',
      'Do not confront a suspect directly.',
      'Note identifying details — appearance, vehicle, direction they went.',
      'Keep bystanders away from the area.',
      'Stay reachable in case a responder needs more information.',
    ],
  };

  /// Returns an empty list for cases with no generalized guidance
  /// (e.g. non-emergency police concerns) — callers should check
  /// `isEmpty` and skip showing the sheet entirely in that case.
  static List<String> forType(ServiceTypeEnum type) => _tips[type] ?? const [];
}
import 'package:capstone/core/enums/report_priority_enum.dart';
import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/features/public_user/pre_call_guidance/models/pre_call_guidance_model.dart';

class PriorityCalculator {
  const PriorityCalculator._();

  /// Quick reports carry no details, so default to the safe side.
  static ReportPriorityEnum forQuickReport(ServiceTypeEnum type) => ReportPriorityEnum.high;

  static ReportPriorityEnum forGuidance(
    ServiceTypeEnum type,
    List<PreCallGuidanceModel> answers,
  ) {
    // Only an explicit answer counts; null (unanswered) never escalates.
    bool yes(String id) => answers.any((a) => a.id == id && a.answer == true);
    bool no(String id) => answers.any((a) => a.id == id && a.answer == false);

    switch (type) {
      case ServiceTypeEnum.medical:
        if (no('medical_conscious') || yes('medical_life_threatening')) {
          return ReportPriorityEnum.critical;
        }
        return ReportPriorityEnum.high;

      case ServiceTypeEnum.fire:
        if (yes('fire_trapped')) return ReportPriorityEnum.critical;
        return ReportPriorityEnum.high;

      case ServiceTypeEnum.police:
        if (yes('police_weapons') && (yes('police_suspect_present') || yes('police_injured'))) {
          return ReportPriorityEnum.critical;
        }
        return ReportPriorityEnum.high;
    }
  }

  static ReportPriorityEnum forManualReport(ServiceTypeEnum? type, {required bool isPoliceEmergency}) {
    if (type == ServiceTypeEnum.police) {
      return isPoliceEmergency ? ReportPriorityEnum.high : ReportPriorityEnum.low;
    }
    return ReportPriorityEnum.high;
  }

  static List<ServiceTypeEnum> secondaryServicesForGuidance(
    ServiceTypeEnum primary,
    List<PreCallGuidanceModel> answers,
  ) {
    bool yes(String id) => answers.any((a) => a.id == id && a.answer == true);
    final result = <ServiceTypeEnum>{};

    switch (primary) {
      case ServiceTypeEnum.police:
        if (yes('police_injured')) result.add(ServiceTypeEnum.medical);
      case ServiceTypeEnum.fire:
        if (yes('fire_trapped')) result.add(ServiceTypeEnum.medical);
        if (yes('fire_spreading')) result.add(ServiceTypeEnum.police); // crowd/traffic control, to confirm
      case ServiceTypeEnum.medical:
        if (yes('medical_intentional')) result.add(ServiceTypeEnum.police); // possible self-harm or assault, to confirm
    }

    result.remove(primary);
    return result.toList();
  }
}

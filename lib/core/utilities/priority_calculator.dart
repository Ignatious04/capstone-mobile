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
}

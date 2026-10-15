import 'package:capstone/features/public_user/pre_call_guidance/models/pre_call_guidance_model.dart';
import 'package:capstone/core/utilities/formatter.dart';
import 'package:capstone/core/enums/police_concern_enum.dart';
import 'package:capstone/core/enums/report_status_enum.dart';
import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/core/l10n/app_localizations.dart';

/// Localized display names for enums. Use these instead of Formatter.formatEnumName.
extension ServiceTypeLabel on ServiceTypeEnum {
  String label(AppLocalizations l10n) {
    switch (this) {
      case ServiceTypeEnum.medical:
        return l10n.serviceMedical;
      case ServiceTypeEnum.police:
        return l10n.servicePolice;
      case ServiceTypeEnum.fire:
        return l10n.serviceFire;
    }
  }
}

extension ReportStatusLabel on ReportStatusEnum {
  String label(AppLocalizations l10n) {
    switch (this) {
      case ReportStatusEnum.pending:
        return l10n.reportStatusPending;
      case ReportStatusEnum.accepted:
        return l10n.reportStatusAccepted;
      case ReportStatusEnum.dispatched:
        return l10n.reportStatusDispatched;
      case ReportStatusEnum.onScene:
        return l10n.reportStatusOnScene;
      case ReportStatusEnum.resolved:
        return l10n.reportStatusResolved;
    }
  }
}

extension PoliceConcernLabel on PoliceConcernTypeEnum {
  String label(AppLocalizations l10n) {
    switch (this) {
      case PoliceConcernTypeEnum.noiseComplaint:
        return l10n.concernNoiseComplaint;
      case PoliceConcernTypeEnum.lostItem:
        return l10n.concernLostItem;
      case PoliceConcernTypeEnum.minorDispute:
        return l10n.concernMinorDispute;
      case PoliceConcernTypeEnum.suspiciousActivity:
        return l10n.concernSuspiciousActivity;
      case PoliceConcernTypeEnum.vandalism:
        return l10n.concernVandalism;
      case PoliceConcernTypeEnum.requestForReport:
        return l10n.concernRequestForReport;
      case PoliceConcernTypeEnum.other:
        return l10n.concernOther;
    }
  }
}

/// For places that only have the enum's name as a String (older widgets).
String serviceTypeLabelFromName(AppLocalizations l10n, String name) =>
    ServiceTypeEnum.values.asNameMap()[name]?.label(l10n) ?? Formatter.formatEnumName(name);

String reportStatusLabelFromName(AppLocalizations l10n, String name) =>
    ReportStatusEnum.values.asNameMap()[name]?.label(l10n) ?? Formatter.formatEnumName(name);

/// The question text stored in Firestore / SMS stays English (dispatch reads it);
/// this only changes what the user sees. Reports saved before ids were stored fall back to the stored text.
extension GuidanceQuestionLabel on PreCallGuidanceModel {
  String localizedQuestion(AppLocalizations l10n) {
    switch (id) {
      case 'medical_conscious':
        return l10n.guidanceQConscious;
      case 'medical_life_threatening':
        return l10n.guidanceQLifeThreatening;
      case 'medical_intentional':
        return l10n.guidanceQIntentional;
      case 'police_suspect_present':
        return l10n.guidanceQSuspectPresent;
      case 'police_weapons':
        return l10n.guidanceQWeapons;
      case 'police_injured':
        return l10n.guidanceQSomeoneInjured;
      case 'fire_trapped':
        return l10n.guidanceQTrapped;
      case 'fire_spreading':
        return l10n.guidanceQFireSpreading;
      default:
        return question;
    }
  }
}

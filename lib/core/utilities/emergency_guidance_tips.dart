import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/core/l10n/app_localizations.dart';

abstract final class EmergencyGuidanceTips {
  /// Returns an empty list for cases with no generalized guidance
  /// (e.g. non-emergency police concerns) — callers should check
  /// `isEmpty` and skip showing the sheet entirely in that case.
  static List<String> forType(ServiceTypeEnum type, AppLocalizations l10n) {
    switch (type) {
      case ServiceTypeEnum.medical:
        return [l10n.tipMedical1, l10n.tipMedical2, l10n.tipMedical3, l10n.tipMedical4, l10n.tipMedical5];
      case ServiceTypeEnum.fire:
        return [l10n.tipFire1, l10n.tipFire2, l10n.tipFire3, l10n.tipFire4, l10n.tipFire5];
      case ServiceTypeEnum.police:
        return [l10n.tipPolice1, l10n.tipPolice2, l10n.tipPolice3, l10n.tipPolice4, l10n.tipPolice5];
    }
  }
}

import 'package:capstone/core/l10n/app_localizations.dart';

enum GuardianRelationshipEnum {
  mother,
  father,
  grandparent,
  legalGuardian,
  otherRelative;

  static GuardianRelationshipEnum? tryParse(String? value) =>
      value == null ? null : GuardianRelationshipEnum.values.asNameMap()[value];

  String label(AppLocalizations l10n) {
    switch (this) {
      case GuardianRelationshipEnum.mother:
        return l10n.relationshipMother;
      case GuardianRelationshipEnum.father:
        return l10n.relationshipFather;
      case GuardianRelationshipEnum.grandparent:
        return l10n.relationshipGrandparent;
      case GuardianRelationshipEnum.legalGuardian:
        return l10n.relationshipLegalGuardian;
      case GuardianRelationshipEnum.otherRelative:
        return l10n.relationshipOtherRelative;
    }
  }
}
import 'package:capstone/core/l10n/app_localizations.dart';

enum RejectionCodeEnum {
  idUnreadable,
  selfieMismatch,
  incompleteInfo,
  duplicateAccount,
  other
  ;

  /// Safe parse: unknown or missing codes become null, never a crash.
  static RejectionCodeEnum? tryParse(String? value) => RejectionCodeEnum.values.asNameMap()[value];
}

extension RejectionCodeMessage on RejectionCodeEnum {
  /// Null means "show only the admin's note, no headline".
  String? message(AppLocalizations l10n) {
    switch (this) {
      case RejectionCodeEnum.idUnreadable:
        return l10n.rejectionIdUnreadable;
      case RejectionCodeEnum.selfieMismatch:
        return l10n.rejectionSelfieMismatch;
      case RejectionCodeEnum.incompleteInfo:
        return l10n.rejectionIncompleteInfo;
      case RejectionCodeEnum.duplicateAccount:
      case RejectionCodeEnum.other:
        return null; // intentionally generic, see below
    }
  }
}

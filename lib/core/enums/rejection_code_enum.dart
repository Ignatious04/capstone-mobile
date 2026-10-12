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
  String? get message {
    switch (this) {
      case RejectionCodeEnum.idUnreadable:
        return "Your ID photo could not be read clearly.";
      case RejectionCodeEnum.selfieMismatch:
        return "Your selfie did not match your ID.";
      case RejectionCodeEnum.incompleteInfo:
        return "Some of your information is missing or incorrect.";
      case RejectionCodeEnum.duplicateAccount:
      case RejectionCodeEnum.other:
        return null; // intentionally generic, see below
    }
  }
}

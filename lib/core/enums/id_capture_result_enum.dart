enum IdCaptureResult { ok, unreadable, duplicate }

extension IdCaptureResultMessage on IdCaptureResult {
  String get message {
    switch (this) {
      case IdCaptureResult.ok:
        return '';
      case IdCaptureResult.unreadable:
        return "Couldn't read the ID number. Retake with better lighting.";
      case IdCaptureResult.duplicate:
        return "This ID is already registered to another account.";
    }
  }
}
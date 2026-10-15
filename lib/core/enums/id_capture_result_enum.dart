import 'package:capstone/core/l10n/app_localizations.dart';

enum IdCaptureResult { ok, unreadable, duplicate }

extension IdCaptureResultMessage on IdCaptureResult {
  String message(AppLocalizations l10n) {
    switch (this) {
      case IdCaptureResult.ok:
        return '';
      case IdCaptureResult.unreadable:
        return l10n.idCaptureUnreadable;
      case IdCaptureResult.duplicate:
        return l10n.idCaptureDuplicate;
    }
  }
}

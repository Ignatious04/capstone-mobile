import 'package:capstone/core/l10n/app_localizations.dart';

enum FaceCheckResult { ok, noFace, multipleFaces, notFacingCamera, eyesClosed }

extension FaceCheckResultMessage on FaceCheckResult {
  String message(AppLocalizations l10n) {
    switch (this) {
      case FaceCheckResult.ok:
        return '';
      case FaceCheckResult.noFace:
        return l10n.faceNoFace;
      case FaceCheckResult.multipleFaces:
        return l10n.faceMultiple;
      case FaceCheckResult.notFacingCamera:
        return l10n.faceNotFacing;
      case FaceCheckResult.eyesClosed:
        return l10n.faceEyesClosed;
    }
  }
}

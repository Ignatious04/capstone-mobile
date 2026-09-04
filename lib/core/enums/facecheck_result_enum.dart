enum FaceCheckResult { ok, noFace, multipleFaces, notFacingCamera, eyesClosed }

extension FaceCheckResultMessage on FaceCheckResult {
  String get message {
    switch (this) {
      case FaceCheckResult.ok:
        return '';
      case FaceCheckResult.noFace:
        return "No face detected. Please retake the photo.";
      case FaceCheckResult.multipleFaces:
        return "Multiple faces detected. Please retake alone.";
      case FaceCheckResult.notFacingCamera:
        return "Please face the camera directly.";
      case FaceCheckResult.eyesClosed:
        return "Your eyes appear closed. Please retake.";
    }
  }
}

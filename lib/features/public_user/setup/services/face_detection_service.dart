import 'package:capstone/core/enums/facecheck_result_enum.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectionService {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true, // needed for eye-open probabilities
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  static const _angleThresholdDegrees = 15.0;
  static const _eyeOpenThreshold = 0.4;

  Future<FaceCheckResult> checkFace(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final faces = await _faceDetector.processImage(inputImage);

    if (faces.isEmpty) return FaceCheckResult.noFace;
    if (faces.length > 1) return FaceCheckResult.multipleFaces;

    final face = faces.first;

    final yaw = face.headEulerAngleY ?? 0;
    final roll = face.headEulerAngleZ ?? 0;
    if (yaw.abs() > _angleThresholdDegrees || roll.abs() > _angleThresholdDegrees) {
      return FaceCheckResult.notFacingCamera;
    }

    final leftEyeOpen = face.leftEyeOpenProbability ?? 1.0;
    final rightEyeOpen = face.rightEyeOpenProbability ?? 1.0;
    if (leftEyeOpen < _eyeOpenThreshold || rightEyeOpen < _eyeOpenThreshold) {
      return FaceCheckResult.eyesClosed;
    }

    return FaceCheckResult.ok;
  }

  void dispose() => _faceDetector.close();
}
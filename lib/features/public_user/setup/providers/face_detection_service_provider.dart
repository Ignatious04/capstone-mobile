import 'package:capstone/features/public_user/setup/services/face_detection_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final faceDetectionServiceProvider = Provider<FaceDetectionService>((ref) {
  final service = FaceDetectionService();
  ref.onDispose(service.dispose);
  return service;
});

import 'package:camera/camera.dart';

class CameraService {
  late CameraController cameraController;

  Future<CameraController> getCamera() async {
    final cameras = await availableCameras();

    cameraController = CameraController(
      cameras.first,
      ResolutionPreset.veryHigh,
      enableAudio: false,
    );

    await cameraController.initialize();
    return cameraController;
  }
}

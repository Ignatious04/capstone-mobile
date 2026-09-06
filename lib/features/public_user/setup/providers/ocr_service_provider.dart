import 'package:capstone/features/public_user/setup/services/ocr_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ocrServiceProvider = Provider<OcrService>((ref) {
  final service = OcrService();
  ref.onDispose(service.dispose);
  return service;
});

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  // PhilSys National ID: 4 groups of 4 digits, e.g. 1234-5678-9012-3456
  static final _philSysPattern = RegExp(r'\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}');

  // LTO Driver's License: e.g. N01-92-123456
  static final _driversLicensePattern = RegExp(r'[A-Z]\d{2}-\d{2}-\d{6}');

  // Philippine Passport: 1-2 letters followed by 7 digits, e.g. P1234567
  static final _passportPattern = RegExp(r'[A-Z]{1,2}\d{7}');

  Future<String?> extractIdNumber(String imagePath, String idType) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final result = await _textRecognizer.processImage(inputImage);
    final text = result.text;

    final pattern = _patternFor(idType);
    final match = pattern.firstMatch(text);

    return match?.group(0)?.replaceAll(RegExp(r'[\s-]'), '');
  }

  RegExp _patternFor(String idType) {
    switch (idType) {
      case "Driver's License":
        return _driversLicensePattern;
      case "Passport":
        return _passportPattern;
      case "National ID (PhilSys)":
      default:
        return _philSysPattern;
    }
  }

  void dispose() => _textRecognizer.close();
}

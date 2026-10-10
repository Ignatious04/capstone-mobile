import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  // PhilSys National ID: 4 groups of 4 digits, e.g. 1234-5678-9012-3456
  static final _philSysPattern = RegExp(r'\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}');

  // LTO Driver's License: e.g. N01-92-123456
  static final _driversLicensePattern = RegExp(r'[A-Z]\d{2}[\s\-–]\d{2}[\s\-–]\d{6}');

  // Philippine Passport: 1-2 letters followed by 7 digits, e.g. P1234567
  static final _passportPattern = RegExp(r'[A-Z]{1,2}\d{7}[A-Z]?');

  Future<String?> extractIdNumber(String imagePath, String idType) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final result = await _textRecognizer.processImage(inputImage);
    final text = result.text;

    return _extract(text, idType)?.replaceAll(RegExp(r'[\s\-–]'), '');
  }

  RegExp? _patternFor(String idType) {
    switch (idType) {
      case "Driver's License":
        return _driversLicensePattern;
      case "Passport":
        return _passportPattern;
      case "National ID (PhilSys)":
        return _philSysPattern;
      default:
        return null;
    }
  }

  void dispose() => _textRecognizer.close();

  // Characters OCR commonly confuses with digits
  static const _toDigit = {'O': '0', 'Q': '0', 'I': '1', 'L': '1', '|': '1', 'Z': '2', 'S': '5', 'B': '8'};
  static const _toLetter = {'0': 'O', '1': 'I', '5': 'S', '8': 'B'};
  static const _d = '[0-9OQILZSB|]'; // a digit or a common look-alike

  static final _philSysLoose = RegExp('$_d{4}[\\s-]?$_d{4}[\\s-]?$_d{4}[\\s-]?$_d{4}');
  static final _licenseLoose = RegExp('([A-Z0-9])($_d{2})[\\s\\-–]($_d{2})[\\s\\-–]($_d{6})');
  static final _passportLoose = RegExp('([A-Z]{1,2})($_d{7})([A-Z]?)');

  String _toDigits(String s) => s.split('').map((c) => _toDigit[c] ?? c).join();
  int _realDigits(String s) => RegExp(r'\d').allMatches(s).length;

  String? _extract(String text, String idType) {
    final upper = text.toUpperCase();

    // 1. Strict match first (existing behaviour)
    final strict = _patternFor(idType)?.firstMatch(upper)?.group(0);
    if (strict != null) return strict;

    // 2. Lenient fallback. The _realDigits checks stop ordinary words
    //    made of look-alike letters from being read as numbers.
    switch (idType) {
      case 'National ID (PhilSys)':
        for (final m in _philSysLoose.allMatches(upper)) {
          final raw = m.group(0)!;
          if (_realDigits(raw) < 10) continue; // of 16
          return _toDigits(raw);
        }
      case "Driver's License":
        for (final m in _licenseLoose.allMatches(upper)) {
          final digits = '${m[2]}${m[3]}${m[4]}';
          if (_realDigits(digits) < 7) continue; // of 10
          final letter = _toLetter[m[1]!] ?? m[1]!;
          if (!RegExp(r'[A-Z]').hasMatch(letter)) continue;
          return '$letter${_toDigits(digits)}';
        }
      case 'Passport':
        for (final m in _passportLoose.allMatches(upper)) {
          if (_realDigits(m[2]!) < 5) continue; // of 7
          return '${m[1]}${_toDigits(m[2]!)}${m[3]}';
        }
    }
    return null;
  }
}

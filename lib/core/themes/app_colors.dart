import 'package:flutter/material.dart';

class AppColors {
  static const Color lighterRed = Color.fromARGB(255, 255, 200, 200);
  static const Color lighterGreen = Color.fromARGB(255, 205, 255, 200);
  static const Color lighterBlue = Color.fromARGB(255, 200, 238, 255);
  static const Color lighterDeepOrange = Color.fromARGB(255, 255, 217, 200);
  static const Color lighterPurple = Color.fromARGB(255, 200, 105, 255);
  static const Color lighterBlack = Color.fromARGB(255, 200, 200, 200);
  // static const Color darkerGrey = Color.fromARGB(255, 125, 125, 125);
  static const Color darkerGreen = Color.fromARGB(255, 10, 125, 0);
  // 0.90 * 255 ≈ 230 (0xE6)
  static const Color bgWhiteDark = Color(0xFFE6E6E6);

  // 0.95 * 255 ≈ 242 (0xF2)
  static const Color bgWhite = Color(0xFFF2F2F2);

  // 1.0 * 255 = 255
  static const Color bgWhiteLight = Color(0xFFFFFFFF); // same as Colors.white

  static const Color blackTextFull = Color(0xFF0D0D0D); // 5% lightness
  static const Color blackTextMuted = Color(0xFF4D4D4D); // 30% lightness

  static const Color whiteTextFull = Color(0xFFF2F2F2); // 95% lightness
  static const Color whiteTextMuted = Color(0xFFB3B3B3); // 70% lightness

  static const cardBorder = Color.fromARGB(255, 214, 210, 207);
  static const danger = Color(0xFFB42318);
  static const lighterThemeColor = Color.fromARGB(255, 255, 191, 186);
  static const themeColor = Color.fromARGB(255, 197, 29, 17);
}

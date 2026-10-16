import 'dart:ui';

import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _localeKey = 'app_locale';
const supportedLanguageCodes = ['en', 'fil'];

/// Set once in main() before runApp, so the first frame is already in the saved language.
Locale initialLocale = const Locale('en');

/// Saved choice first; otherwise follow the phone's language if it is Filipino; otherwise English.
Future<Locale> loadSavedLocale() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey);
    if (code != null && supportedLanguageCodes.contains(code)) return Locale(code);
  } catch (_) {
    // Fall through to the default.
  }

  final device = PlatformDispatcher.instance.locale.languageCode;
  return (device == 'fil' || device == 'tl') ? const Locale('fil') : const Locale('en');
}

Future<void> saveLocale(Locale locale) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  } catch (_) {
    // Not being able to save only means the choice is forgotten on restart.
  }
}

final localeProvider = StateProvider<Locale>((ref) {
  return initialLocale;
});

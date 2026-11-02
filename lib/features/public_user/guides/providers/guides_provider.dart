import 'dart:convert';

import 'package:capstone/features/public_user/guides/models/guides_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _guideLanguages = ['en', 'fil'];

String guidesAssetDir(String languageCode) =>
    'assets/guides/${_guideLanguages.contains(languageCode) ? languageCode : 'en'}';

final guideIndexProvider = FutureProvider.family<List<GuideSummary>, String>((ref, languageCode) async {
  final raw = await rootBundle.loadString('${guidesAssetDir(languageCode)}/index.json');
  final list = jsonDecode(raw) as List<dynamic>;
  return list.map((e) => GuideSummary.fromJson(e as Map<String, dynamic>)).toList();
});
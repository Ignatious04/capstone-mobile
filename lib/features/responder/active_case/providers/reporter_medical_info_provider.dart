import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReporterMedicalInfo {
  const ReporterMedicalInfo({required this.bloodType, required this.height, required this.weight});

  final String bloodType;
  final double height;
  final double weight;

  factory ReporterMedicalInfo.fromMap(Map<String, dynamic> map) => ReporterMedicalInfo(
    bloodType: map['bloodType'] as String? ?? '',
    height: (map['height'] as num?)?.toDouble() ?? 0,
    weight: (map['weight'] as num?)?.toDouble() ?? 0,
  );
}

/// Not autoDispose on purpose: `ref.read(p.future)` on an autoDispose provider can be
/// disposed mid-request. The card invalidates it after each read instead.
final reporterMedicalInfoProvider = FutureProvider.family<ReporterMedicalInfo?, String>((ref, reportID) async {
  try {
    final result = await FirebaseFunctions.instance
        .httpsCallable('getReporterMedicalInfo')
        .call({'reportID': reportID});
    final data = Map<String, dynamic>.from(result.data as Map);
    if (data['available'] != true) return null;
    return ReporterMedicalInfo.fromMap(Map<String, dynamic>.from(data['info'] as Map));
  } on FirebaseFunctionsException catch (e) {
    if (e.code == 'permission-denied') return null;
    rethrow;
  }
});
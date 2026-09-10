import 'dart:convert';
import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/features/public_user/map/models/emergency_service_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactNumberRepository {
  static const _key = 'cachedServiceContactNumbers';

  Future<void> saveNearest(Map<ServiceTypeEnum, EmergencyServiceModel?> nearest) async {
    final prefs = await SharedPreferences.getInstance();

    final data = <String, String>{
      for (final entry in nearest.entries)
        if (entry.value != null) entry.key.name: entry.value!.contactNumber,
    };

    await prefs.setString(_key, jsonEncode(data));
  }

  Future<String?> getNumber(ServiceTypeEnum type) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    if (raw == null) return null;

    final data = Map<String, dynamic>.from(jsonDecode(raw));
    return data[type.name] as String?;
  }
}
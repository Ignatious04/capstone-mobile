import 'dart:convert';
import 'package:capstone/core/shared/models/notification_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationHistoryRepository {
  static const _maxEntries = 50;

  String _key(String userID) => 'notificationHistory_$userID';

  Future<List<NotificationModel>> getAll(String userID) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key(userID)) ?? [];

    return raw.map((entry) => NotificationModel.fromMap(Map<String, dynamic>.from(jsonDecode(entry)))).toList();
  }

  Future<void> add(String userID, NotificationModel notification) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getAll(userID);

    final updated = [notification, ...current].take(_maxEntries).toList();

    await prefs.setStringList(
      _key(userID),
      updated.map((n) => jsonEncode(n.toMap())).toList(),
    );
  }

  Future<void> markAsRead(String userID, String notificationID) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getAll(userID);

    final updated = current.map((n) => n.id == notificationID ? n.copyWith(isRead: true) : n).toList();

    await prefs.setStringList(
      _key(userID),
      updated.map((n) => jsonEncode(n.toMap())).toList(),
    );
  }

  Future<void> markAllAsRead(String userID) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getAll(userID);

    final updated = current.map((n) => n.copyWith(isRead: true)).toList();

    await prefs.setStringList(
      _key(userID),
      updated.map((n) => jsonEncode(n.toMap())).toList(),
    );
  }

  Future<void> delete(String userID, String notificationID) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getAll(userID);

    final updated = current.where((n) => n.id != notificationID).toList();

    await prefs.setStringList(
      _key(userID),
      updated.map((n) => jsonEncode(n.toMap())).toList(),
    );
  }
}

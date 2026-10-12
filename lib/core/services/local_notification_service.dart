import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  LocalNotificationService._();
  static final instance = LocalNotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  /// Set by PushNotificationService; receives the data of a tapped notification.
  void Function(Map<String, dynamic> data)? onTap;

  // Must match the id in AndroidManifest.xml and the FCM payload.
  static const _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'Emergency updates',
    description: 'Report status and case assignment alerts',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  Future<void> init() async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          // FirebaseMessaging.requestPermission() already asks for these.
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) => _dispatch(response.payload),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  Future<void> show({
    required int id,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) {
    return _plugin.show(
      id: id,
      title: title,
      body: body,
      payload: data == null ? null : jsonEncode(data),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: true,
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> launchData() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp != true) return null;
    return _decode(details!.notificationResponse?.payload);
  }

  void _dispatch(String? payload) {
    final data = _decode(payload);
    if (data != null) onTap?.call(data);
  }

  Map<String, dynamic>? _decode(String? payload) {
    if (payload == null) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(payload) as Map);
    } catch (_) {
      return null;
    }
  }
}

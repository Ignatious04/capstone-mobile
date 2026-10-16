import 'package:capstone/core/l10n/app_localizations.dart';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  LocalNotificationService._();
  static final instance = LocalNotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  /// Set by PushNotificationService; receives the data of a tapped notification.
  void Function(Map<String, dynamic> data)? onTap;

  // The id must match AndroidManifest.xml and the FCM payload. Only the name/description are translated.
  static AndroidNotificationChannel _buildChannel(Locale locale) {
    final l10n = lookupAppLocalizations(locale);
    return AndroidNotificationChannel(
      'high_importance_channel',
      l10n.notifChannelName,
      description: l10n.notifChannelDescription,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );
  }

  // English until init() runs (the background isolate never calls init()).
  AndroidNotificationChannel _channel = _buildChannel(const Locale('en'));

  Future<void> init({Locale locale = const Locale('en')}) async {
    _channel = _buildChannel(locale);
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

  /// Re-registering a channel with the same id updates its visible name and description.
  Future<void> updateChannelLocale(Locale locale) async {
    _channel = _buildChannel(locale);
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

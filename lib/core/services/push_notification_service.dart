import 'package:capstone/core/enums/notification_type_enum.dart';
import 'package:capstone/core/shared/models/notification_model.dart';
import 'package:capstone/core/shared/providers/app_notification_provider.dart';
import 'package:capstone/core/shared/providers/notification_history_provider.dart';
import 'package:capstone/core/shared/providers/user_repository_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Must be a top-level function — this is what the OS calls when a
/// data message arrives while the app is backgrounded/terminated.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background FCM message: ${message.messageId}');
}

class PushNotificationService {
  PushNotificationService(this.ref);

  final Ref ref;
  final _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // App opened by tapping a notification (background, not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // App launched cold by tapping a notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  /// Call once after login (user is authenticated, email-verified, setup).
  Future<void> registerToken(String userID) async {
    final token = await _messaging.getToken();
    if (token != null) {
      await ref.read(userRepositoryProvider).updateFcmToken(userID, token);
    }

    // Token can rotate at any time, not just on login.
    _messaging.onTokenRefresh.listen((newToken) {
      ref.read(userRepositoryProvider).updateFcmToken(userID, newToken);
    });
  }

  /// Call on sign-out so a stale token doesn't keep receiving another
  /// account's pushes on a shared device.
  Future<void> clearToken(String userID) async {
    await ref.read(userRepositoryProvider).clearFcmToken(userID);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final title = message.notification?.title ?? message.data['title'] ?? '';
    final body = message.notification?.body ?? message.data['body'] ?? '';
    final reportID = message.data['reportID'] as String?;

    ref.read(appNotificationProvider.notifier).show('$title: $body');

    ref.read(notificationHistoryProvider.notifier).add(
      NotificationModel(
        id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        type: NotificationTypeEnum.reportStatus,
        title: title,
        message: body,
        createdAt: DateTime.now(),
        reportID: reportID,
      ),
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    final reportID = message.data['reportID'] as String?;
    debugPrint('Notification tapped, reportID: $reportID');
    // TODO: navigate to the report detail screen once there's a
    // navigatorKey/route for it — data payload already carries reportID.
  }
}

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  return PushNotificationService(ref);
});
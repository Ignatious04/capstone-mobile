import 'package:capstone/core/enums/notification_type_enum.dart';
import 'package:capstone/core/enums/report_type_enum.dart';
import 'package:capstone/core/shared/models/notification_model.dart';
import 'package:capstone/core/shared/providers/app_notification_provider.dart';
import 'package:capstone/core/shared/providers/navigator_key_provider.dart';
import 'package:capstone/core/shared/providers/notification_history_provider.dart';
import 'package:capstone/core/shared/providers/report_repository_provider.dart';
import 'package:capstone/core/shared/providers/user_repository_provider.dart';
import 'package:capstone/core/shared/repositories/notification_history_repository.dart';
import 'package:capstone/features/public_user/reporting/views/normal_reports_view_screen.dart';
import 'package:capstone/features/public_user/reporting/views/pre_call_guidance_report_view_screen.dart';
import 'package:capstone/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Must be a top-level function — this is what the OS calls when a
/// data message arrives while the app is backgrounded/terminated.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final userID = FirebaseAuth.instance.currentUser?.uid;
  if (userID == null) return;

  final title = message.notification?.title ?? message.data['title'] ?? '';
  final body = message.notification?.body ?? message.data['body'] ?? '';
  final reportID = message.data['reportID'] as String?;

  await NotificationHistoryRepository().add(
    userID,
    NotificationModel(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotificationTypeEnum.reportStatus,
      title: title,
      message: body,
      createdAt: DateTime.now(),
      reportID: reportID,
    ),
  );
  debugPrint('Background FCM message saved to history: ${message.messageId}');
}

class PushNotificationService {
  PushNotificationService(this.ref);

  final Ref ref;
  final _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

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
    try {
      await ref.read(userRepositoryProvider).clearFcmToken(userID);
    } catch (e) {
      debugPrint('clearToken failed: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final title = message.notification?.title ?? message.data['title'] ?? '';
    final body = message.notification?.body ?? message.data['body'] ?? '';
    final reportID = message.data['reportID'] as String?;

    ref.read(appNotificationProvider.notifier).show('$title: $body');

    ref
        .read(notificationHistoryProvider.notifier)
        .add(
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

  Future<void> _handleNotificationTap(RemoteMessage message) async {
    final reportID = message.data['reportID'] as String?;
    debugPrint('Notification tapped, reportID: $reportID');
    if (reportID == null) return;

    final navigatorState = ref.read(navigatorKeyProvider).currentState;
    if (navigatorState == null) return;

    final report = await ref.read(reportRepositoryProvider).getReportByID(reportID);
    if (report == null) return;

    navigatorState.push(
      MaterialPageRoute(
        builder: (context) => report.reportType == ReportTypeEnum.preCallGuidance
            ? PreCallGuidanceReportViewScreen(report: report)
            : NormalReportsViewScreen(report: report),
      ),
    );
  }
}

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  return PushNotificationService(ref);
});

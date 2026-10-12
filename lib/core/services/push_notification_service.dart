import 'dart:async';
import 'package:capstone/core/enums/notification_type_enum.dart';
import 'package:capstone/core/enums/report_type_enum.dart';
import 'package:capstone/core/services/local_notification_service.dart';
import 'package:capstone/core/shared/models/notification_model.dart';
import 'package:capstone/core/shared/providers/app_notification_provider.dart';
import 'package:capstone/core/shared/providers/navigator_key_provider.dart';
import 'package:capstone/core/shared/providers/notification_history_provider.dart';
import 'package:capstone/core/shared/providers/report_repository_provider.dart';
import 'package:capstone/core/shared/providers/responder_repository_provider.dart';
import 'package:capstone/core/shared/providers/user_repository_provider.dart';
import 'package:capstone/core/shared/repositories/notification_history_repository.dart';
import 'package:capstone/features/public_user/reporting/views/normal_reports_view_screen.dart';
import 'package:capstone/features/public_user/reporting/views/pre_call_guidance_report_view_screen.dart';
import 'package:capstone/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Must be a top-level function — this is what the OS calls when a
/// data message arrives while the app is backgrounded/terminated.
NotificationTypeEnum _notificationTypeOf(RemoteMessage message) =>
    message.data['type'] == 'reportAssigned' ? NotificationTypeEnum.reportAssigned : NotificationTypeEnum.reportStatus;

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
      type: _notificationTypeOf(message),
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

  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onOpenedSub;
  StreamSubscription<String>? _tokenRefreshSub;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    _onMessageSub = FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    _onOpenedSub = FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    LocalNotificationService.instance.onTap = _openFromData;
    final launchData = await LocalNotificationService.instance.launchData();
    if (launchData != null) _openFromData(launchData);
  }

  Future<void> dispose() async {
    await _onMessageSub?.cancel();
    await _onOpenedSub?.cancel();
    await _tokenRefreshSub?.cancel();
    _onMessageSub = null;
    _onOpenedSub = null;
    _tokenRefreshSub = null;
    LocalNotificationService.instance.onTap = null;
    _initialized = false;
  }

  /// Call once after login (user is authenticated, email-verified, setup).
  Future<void> registerToken(String userID) async {
    final responderRepo = ref.read(responderRepositoryProvider);
    final isResponder = await responderRepo.exists(userID);

    Future<void> save(String token) => isResponder
        ? responderRepo.updateFcmToken(userID, token)
        : ref.read(userRepositoryProvider).updateFcmToken(userID, token);

    final token = await _messaging.getToken();
    if (token != null) {
      await save(token);
    }

    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = _messaging.onTokenRefresh.listen(save);
  }

  /// Call on sign-out so a stale token doesn't keep receiving another
  /// account's pushes on a shared device.
  Future<void> clearToken(String userID) async {
    try {
      final responderRepo = ref.read(responderRepositoryProvider);
      if (await responderRepo.exists(userID)) {
        await responderRepo.clearFcmToken(userID);
      } else {
        await ref.read(userRepositoryProvider).clearFcmToken(userID);
      }
    } catch (e) {
      debugPrint('clearToken failed: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('FG message ${message.messageId} handled by service #${identityHashCode(this)}');
    final title = message.notification?.title ?? message.data['title'] ?? '';
    final body = message.notification?.body ?? message.data['body'] ?? '';
    final reportID = message.data['reportID'] as String?;

    ref.read(appNotificationProvider.notifier).show('$title: $body');

    // FCM doesn't show anything while the app is open, so raise a local
    // notification to get the device's sound/vibration.
    LocalNotificationService.instance.show(
      id: message.hashCode,
      title: title,
      body: body,
      data: message.data,
    );

    ref
        .read(notificationHistoryProvider.notifier)
        .add(
          NotificationModel(
            id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
            type: _notificationTypeOf(message),
            title: title,
            message: body,
            createdAt: DateTime.now(),
            reportID: reportID,
          ),
        );
  }

  Future<void> _handleNotificationTap(RemoteMessage message) => _openFromData(message.data);
  // Responders land on the Active Case tab, which already streams their assigned report.

  Future<void> _openFromData(Map<String, dynamic> data) async {
    if (data['type'] == 'reportAssigned') return;

    final reportID = data['reportID'] as String?;
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
  final service = PushNotificationService(ref);
  ref.onDispose(service.dispose);
  return service;
});

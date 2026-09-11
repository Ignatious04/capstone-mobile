import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppNotificationProvider {
  const AppNotificationProvider({
    required this.message,
    this.color,
  });

  final String message;
  final Color? color;
}

class AppNotificationNotifier extends Notifier<AppNotificationProvider?> {
  @override
  AppNotificationProvider? build() => null;

  void show(
    String message, {
    Color? color,
  }) {
    state = AppNotificationProvider(
      message: message,
      color: color,
    );
  }

  void hide() {
    state = null;
  }
}

final appNotificationProvider = NotifierProvider<AppNotificationNotifier, AppNotificationProvider?>(
  AppNotificationNotifier.new,
);

import 'package:capstone/core/shared/providers/notification_history_provider.dart';
import 'package:capstone/core/shared/widgets/custom_app_bar.dart';
import 'package:capstone/core/shared/widgets/text/title_text.dart';
import 'package:capstone/features/public_user/notifications/widgets/notification_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationHistoryScreen extends ConsumerWidget {
  const NotificationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationHistoryProvider);
    final hasUnread = notifications.any((n) => !n.isRead);

    return Scaffold(
      appBar: CustomAppBar(value: "Notifications"),
      body: SafeArea(
        child: Column(
          children: [
            if (hasUnread)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => ref.read(notificationHistoryProvider.notifier).markAllAsRead(),
                  child: const Text("Mark all as read"),
                ),
              ),
            Expanded(
              child: notifications.isEmpty
                  ? const Center(
                      child: TitleText(value: "No notifications yet."),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: NotificationCard(
                            notification: notification,
                            onTap: () {
                              if (!notification.isRead) {
                                ref.read(notificationHistoryProvider.notifier).markAsRead(notification.id);
                              }
                              // TODO: if notification.reportID != null, navigate to the
                              // report detail screen once a "get report by ID" repository
                              // method exists.
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

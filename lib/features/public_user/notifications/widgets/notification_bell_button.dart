import 'package:capstone/core/shared/providers/notification_history_provider.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/features/public_user/notifications/views/notification_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationBellButton extends ConsumerWidget {
  const NotificationBellButton({super.key, this.isResponder = false});

  final bool isResponder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => NotificationHistoryScreen(isResponder: isResponder)),
            );
          },
          icon: const Icon(Icons.notifications),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.themeColor,
            foregroundColor: AppColors.whiteTextFull,
          ),
        ),
        if (unreadCount > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
              child: Text(
                '$unreadCount',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.whiteTextFull, fontSize: 10),
              ),
            ),
          ),
      ],
    );
  }
}
import 'package:capstone/core/enums/notification_type_enum.dart';
import 'package:capstone/core/shared/models/notification_model.dart';
import 'package:capstone/core/shared/widgets/text/card_title_text.dart';
import 'package:capstone/core/shared/widgets/text/sub_title_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
  });

  final NotificationModel notification;
  final VoidCallback? onTap;

  IconData get _icon {
    switch (notification.type) {
      case NotificationTypeEnum.connectivity:
        return Icons.wifi_off;
      case NotificationTypeEnum.reportStatus:
        return Icons.assignment_turned_in;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: notification.isRead ? Colors.white : Colors.deepOrange.shade50,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_icon, color: Colors.deepOrange),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CardTitleText(value: notification.title, isBold: true),
                    const SizedBox(height: 4),
                    SubtitleText(value: notification.message, maxLines: 3),
                    const SizedBox(height: 4),
                    SubtitleText(
                      value: DateFormat("MMM dd, yyyy • h:mm a").format(notification.createdAt),
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
              if (!notification.isRead)
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(left: 8, top: 4),
                  decoration: const BoxDecoration(color: Colors.deepOrange, shape: BoxShape.circle),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
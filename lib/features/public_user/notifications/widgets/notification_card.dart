import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/enums/notification_type_enum.dart';
import 'package:capstone/core/shared/models/notification_model.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/title_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onDelete,
  });

  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  IconData get _icon {
    switch (notification.type) {
      case NotificationTypeEnum.connectivity:
        return Icons.wifi_off;
      case NotificationTypeEnum.reportStatus:
        return Icons.assignment_turned_in;
      case NotificationTypeEnum.reportAssigned:
        return Icons.assignment_ind;
      case NotificationTypeEnum.consent:
        return Icons.family_restroom;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                    TitleText(value: notification.title, isBold: true),
                    const SizedBox(height: 4),
                    BodyText(value: notification.message),
                    const SizedBox(height: 4),
                    BodyText(
                      value: DateFormat(
                        "MMM dd, yyyy • h:mm a",
                        Localizations.localeOf(context).toString(),
                      ).format(notification.createdAt),
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
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.grey),
                  tooltip: l10n.deleteNotification,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: onDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/enums/report_type_enum.dart';
import 'package:capstone/core/shared/providers/notification_history_provider.dart';
import 'package:capstone/core/shared/providers/report_repository_provider.dart';
import 'package:capstone/core/shared/widgets/custom_alert_dialog.dart';
import 'package:capstone/core/shared/widgets/custom_app_bar.dart';
import 'package:capstone/core/shared/widgets/custom_snackbar_helper.dart';
import 'package:capstone/core/shared/widgets/text/title_text.dart';
import 'package:capstone/features/public_user/notifications/widgets/notification_card.dart';
import 'package:capstone/features/public_user/reporting/views/normal_reports_view_screen.dart';
import 'package:capstone/features/public_user/reporting/views/pre_call_guidance_report_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationHistoryScreen extends ConsumerWidget {
  const NotificationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final notifications = ref.watch(notificationHistoryProvider);
    final hasUnread = notifications.any((n) => !n.isRead);

    return Scaffold(
      appBar: CustomAppBar(value: l10n.notifications),
      body: SafeArea(
        child: Column(
          children: [
            if (hasUnread)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => ref.read(notificationHistoryProvider.notifier).markAllAsRead(),
                  child: Text(l10n.markAllRead),
                ),
              ),
            Expanded(
              child: notifications.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.notifications_none,
                          size: 75,
                          color: Colors.black54,
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: TitleText(value: l10n.noNotifications),
                        ),
                      ],
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
                            onDelete: () async {
                              final confirmed = await showConfirmationDialog(
                                context,
                                title: l10n.deleteNotificationTitle,
                                content: l10n.deleteNotificationBody,
                              );
                              if (confirmed != true) return;

                              await ref.read(notificationHistoryProvider.notifier).delete(notification.id);
                              if (!context.mounted) return;
                              CustomSnackbarHelper.show(context, text: l10n.notificationDeleted);
                            },
                            onTap: () async {
                              if (!notification.isRead) {
                                ref.read(notificationHistoryProvider.notifier).markAsRead(notification.id);
                              }
                              final reportID = notification.reportID;
                              if (reportID == null) return;

                              final report = await ref.read(reportRepositoryProvider).getReportByID(reportID);
                              if (report == null || !context.mounted) return;

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => report.reportType == ReportTypeEnum.preCallGuidance
                                      ? PreCallGuidanceReportViewScreen(report: report)
                                      : NormalReportsViewScreen(report: report),
                                ),
                              );
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

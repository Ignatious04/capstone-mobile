import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/l10n/enum_labels.dart';
import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/core/shared/models/report_model.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/title_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/core/utilities/formatter.dart';
import 'package:capstone/features/responder/history/views/history_case_detail_screen.dart';
import 'package:flutter/material.dart';

class HistoryCaseCard extends StatelessWidget {
  const HistoryCaseCard({super.key, required this.report});

  final ReportModel report;

  IconData get _icon => switch (report.incidentType) {
    ServiceTypeEnum.medical => Icons.local_hospital,
    ServiceTypeEnum.police => Icons.local_police,
    ServiceTypeEnum.fire => Icons.local_fire_department,
    null => Icons.emergency_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    // resolvedAt can be briefly null right after resolving (pending server timestamp)
    final closedAt = report.resolvedAt ?? report.createdAt;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.lighterBlack),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => HistoryCaseDetailScreen(report: report)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.deepOrange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_icon, size: 30, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TitleText(value: report.referenceNumber),
                    BodyText(
                      value: report.incidentType?.label(l10n) ?? '—',
                    ),
                    BodyText(
                      value: closedAt == null ? '—' : l10n.resolvedAt(Formatter.formatDateTime(closedAt, locale)),
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 30, color: Colors.deepOrange),
            ],
          ),
        ),
      ),
    );
  }
}
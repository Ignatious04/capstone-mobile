import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/l10n/enum_labels.dart';
import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/core/shared/models/response_model.dart';
import 'package:capstone/core/shared/providers/report_repository_provider.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/title_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/core/utilities/formatter.dart';
import 'package:capstone/features/responder/history/views/history_case_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HistoryCaseCard extends ConsumerWidget {
  const HistoryCaseCard({super.key, required this.response});

  final ResponseModel response;

  IconData _icon(ServiceTypeEnum? incidentType) => switch (incidentType) {
    ServiceTypeEnum.medical => Icons.local_hospital,
    ServiceTypeEnum.police => Icons.local_police,
    ServiceTypeEnum.fire => Icons.local_fire_department,
    null => Icons.emergency_outlined,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    // Incident details live on the report; this response only holds this service's part.
    final report = ref.watch(reportByIdProvider(response.reportID)).value;

    // resolvedAt can be briefly null right after resolving (pending server timestamp)
    final closedAt = response.resolvedAt ?? response.createdAt;

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
          MaterialPageRoute(builder: (_) => HistoryCaseDetailScreen(response: response)),
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
                child: Icon(_icon(report?.incidentType), size: 30, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TitleText(value: report?.referenceNumber ?? '—'),
                    BodyText(
                      value: report?.incidentType?.label(l10n) ?? '—',
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
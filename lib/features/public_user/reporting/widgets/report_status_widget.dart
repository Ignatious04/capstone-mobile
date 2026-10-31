import 'package:capstone/core/enums/report_status_enum.dart';
import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/l10n/enum_labels.dart';
import 'package:capstone/core/shared/widgets/text/label_text.dart';
import 'package:capstone/core/utilities/formatter.dart';
import 'package:flutter/material.dart';

class ReportStatusWidget extends StatelessWidget {
  const ReportStatusWidget({super.key, required this.status, this.resolvedAt});

  final String status;

  /// Only shown once the status is resolved. Can be briefly null right after
  /// resolving (server timestamp / derive-status function still catching up).
  final DateTime? resolvedAt;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final resolvedTime = status == ReportStatusEnum.resolved.name ? resolvedAt : null;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LabelText(
                value: reportStatusLabelFromName(l10n, status),
                color: Colors.white,
                isBold: true,
              ),
              if (resolvedTime != null)
                LabelText(
                  value: Formatter.formatDateTime(resolvedTime, locale),
                  color: Colors.white70,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/l10n/enum_labels.dart';
import 'package:capstone/core/shared/models/report_model.dart';
import 'package:capstone/core/shared/widgets/text/label_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

/// Shows every service involved in a report: the primary one first (outlined),
/// then each secondary one. Coloured like the home screen's quick report
/// buttons (fire = red, police = blue, medical = green).
///
/// Reads `incidentType` (primary) and `secondaryServices` straight off the
/// report, so it needs no extra Firestore reads.
class ReportServiceTypesWidget extends StatelessWidget {
  const ReportServiceTypesWidget({super.key, required this.report});

  final ReportModel report;

  @override
  Widget build(BuildContext context) {
    final primary = report.incidentType;
    if (primary == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final secondary = report.secondaryServices.where((s) => s != primary).toSet();

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _ServiceTypeChip(type: primary, caption: l10n.primaryService, isPrimary: true),
        for (final type in secondary) _ServiceTypeChip(type: type, caption: l10n.secondaryService),
      ],
    );
  }
}

class _ServiceTypeChip extends StatelessWidget {
  const _ServiceTypeChip({required this.type, required this.caption, this.isPrimary = false});

  final ServiceTypeEnum type;
  final String caption;
  final bool isPrimary;

  (IconData, Color, Color) get _style => switch (type) {
    ServiceTypeEnum.medical => (Icons.local_hospital, Colors.green, AppColors.lighterGreen),
    ServiceTypeEnum.police => (Icons.local_police, Colors.blue, AppColors.lighterBlue),
    ServiceTypeEnum.fire => (Icons.local_fire_department, Colors.red, AppColors.lighterRed),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (icon, color, background) = _style;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: isPrimary ? Border.all(color: color, width: 1.5) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LabelText(value: caption.toUpperCase(), color: AppColors.blackTextMuted),
              LabelText(value: type.label(l10n), color: color, isBold: true),
            ],
          ),
        ],
      ),
    );
  }
}
import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/models/response_model.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/label_text.dart';
import 'package:capstone/core/utilities/eta_calculator.dart';
import 'package:capstone/core/utilities/formatter.dart';
import 'package:flutter/material.dart';

/// Shows when each status was reached for one service's response, plus the
/// ETA recorded at dispatch and (once the responder arrives) how long the
/// trip actually took. Without a response it only shows when it was reported.
class ReportTimelineCard extends StatelessWidget {
  const ReportTimelineCard({super.key, required this.createdAt, this.response, this.embedded = false});


  final DateTime? createdAt;
  final ResponseModel? response;
  /// When true, renders only the timeline rows (no Card, no padding) so it can
  /// live inside a parent such as an ExpansionTile.
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    final r = response;

    // ETA snapshot saved when the responder went en route.
    String? etaNote;
    if (r?.etaSeconds != null) {
      final recorded = EtaEstimate(
        distanceMeters: r!.etaDistanceMeters ?? 0,
        duration: Duration(seconds: r.etaSeconds!),
      );
      etaNote = l10n.etaRecorded(
        EtaCalculator.formatDuration(l10n, recorded.duration),
        recorded.distanceLabel,
      );
    }

    // Actual travel time = dispatched -> on scene.
    String? travelNote;
    if (r?.dispatchedAt != null && r?.arrivedAt != null) {
      final actual = r!.arrivedAt!.difference(r.dispatchedAt!);
      travelNote = l10n.actualTravelTime(EtaCalculator.formatDuration(l10n, actual));
    }

    final steps = <_TimelineStep>[
      _TimelineStep(l10n.reported, createdAt),
      _TimelineStep(l10n.reportStatusAccepted, r?.acceptedAt),
      _TimelineStep(l10n.reportStatusDispatched, r?.dispatchedAt, note: etaNote),
      _TimelineStep(l10n.reportStatusOnScene, r?.arrivedAt, note: travelNote),
      _TimelineStep(l10n.reportStatusResolved, r?.resolvedAt),
    ];

    final rows = Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          _TimelineRow(
            step: steps[i],
            locale: locale,
            isLast: i == steps.length - 1,
          ),
      ],
    );

    if (embedded) return rows;

    return Card(
      color: Colors.white,
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: rows,
      ),
    );
  }
}

class _TimelineStep {
  const _TimelineStep(this.label, this.time, {this.note});

  final String label;
  final DateTime? time;
  final String? note;

  bool get isReached => time != null;
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.step, required this.locale, required this.isLast});

  final _TimelineStep step;
  final String locale;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = step.isReached ? Colors.deepOrange : Colors.black26;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 20,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: step.isReached ? color : Colors.white,
                    border: Border.all(color: color, width: 2),
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast) Expanded(child: Container(width: 2, color: Colors.black12)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LabelText(value: step.label.toUpperCase()),
                  BodyText(
                    value: step.time == null ? '—' : Formatter.formatDateTime(step.time!, locale),
                    isBold: step.isReached,
                  ),
                  if (step.note != null) BodyText(value: step.note!, color: Colors.black54),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

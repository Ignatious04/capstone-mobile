import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/label_text.dart';
import 'package:capstone/core/utilities/eta_calculator.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EtaCard extends StatelessWidget {
  const EtaCard({
    super.key,
    required this.responder,
    required this.incident,
    required this.isOnScene,
    this.title,
  });

  final LatLng responder;
  final LatLng incident;
  final bool isOnScene;

  /// Overrides the default label, e.g. to say which service this ETA is for.
  final String? title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final eta = EtaCalculator.estimate(responder, incident);

    final headline = isOnScene ? l10n.responderOnScene : eta.durationLabel(l10n);
    final detail = isOnScene ? null : l10n.distanceAway(eta.distanceLabel);

    return Card(
      color: Colors.white,
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.timer_outlined, size: 30, color: Colors.deepOrange),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LabelText(value: (title ?? l10n.estimatedArrival).toUpperCase()),
                  BodyText(value: headline, isBold: true),
                  if (detail != null) BodyText(value: detail),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

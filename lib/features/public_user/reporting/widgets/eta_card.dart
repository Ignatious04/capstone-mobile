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
  });

  final LatLng responder;
  final LatLng incident;
  final bool isOnScene;

  @override
  Widget build(BuildContext context) {
    final eta = EtaCalculator.estimate(responder, incident);

    final headline = isOnScene ? 'Responder is on scene' : eta.durationLabel;
    final detail = isOnScene ? null : '${eta.distanceLabel} away (estimate)';

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
                  const LabelText(value: 'ESTIMATED ARRIVAL'),
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

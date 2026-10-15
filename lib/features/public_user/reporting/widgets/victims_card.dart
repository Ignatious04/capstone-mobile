import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/features/public_user/reporting/models/victim_model.dart';
import 'package:capstone/features/public_user/reporting/widgets/empty_card.dart';
import 'package:capstone/features/public_user/reporting/widgets/victim_card_item.dart';
import 'package:flutter/material.dart';

class VictimsCard extends StatelessWidget {
  const VictimsCard({super.key, this.victims});

  final List<VictimModel>? victims;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (victims?.isEmpty ?? true) {
      return EmptyCard(
        icon: Icons.person_off_outlined,
        message: l10n.noVictimInfo,
      );
    }

    return Card(
      color: Colors.white,
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            for (int i = 0; i < victims!.length; i++) ...[
              VictimCardItem(
                name: victims![i].name,
                description: victims![i].description,
                index: i + 1,
              ),
              if (i != victims!.length - 1) const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

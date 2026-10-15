// lib/features/public_user/reporting/widgets/responder_card.dart
import 'package:capstone/core/l10n/enum_labels.dart';
import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/core/shared/models/responder_model.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/label_text.dart';
import 'package:flutter/material.dart';

class ResponderCard extends StatelessWidget {
  const ResponderCard({super.key, required this.responder});

  final ResponderModel responder;

  IconData get _departmentIcon => switch (responder.department) {
    ServiceTypeEnum.medical => Icons.local_hospital,
    ServiceTypeEnum.police => Icons.local_police,
    ServiceTypeEnum.fire => Icons.local_fire_department,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      color: Colors.white,
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.deepOrange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_departmentIcon, size: 30, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LabelText(value: l10n.responder.toUpperCase()),
                  BodyText(
                    value: responder.fullName.isEmpty ? l10n.unnamedResponder : responder.fullName,
                    isBold: true,
                  ),
                  const SizedBox(height: 6),
                  BodyText(
                    value: responder.department.label(l10n),
                  ),
                  if (responder.contactNumber.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 25, color: Colors.black54),
                        const SizedBox(width: 5),
                        BodyText(value: responder.contactNumber),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
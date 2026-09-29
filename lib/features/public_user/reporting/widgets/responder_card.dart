// lib/features/public_user/reporting/widgets/responder_card.dart
import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/core/shared/models/responder_model.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/label_text.dart';
import 'package:capstone/core/utilities/formatter.dart';
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
                  const LabelText(value: 'RESPONDER'),
                  BodyText(
                    value: responder.fullName.isEmpty ? 'Unnamed responder' : responder.fullName,
                    isBold: true,
                  ),
                  const SizedBox(height: 6),
                  BodyText(
                    value: Formatter.formatEnumName(responder.department.name),
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
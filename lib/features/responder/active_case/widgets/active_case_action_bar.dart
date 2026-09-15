// lib/features/responder/active_case/widgets/active_case_action_bar.dart
import 'package:capstone/core/enums/report_status_enum.dart';
import 'package:flutter/material.dart';

class ActiveCaseActionBar extends StatelessWidget {
  const ActiveCaseActionBar({
    super.key,
    required this.status,
    required this.onAccept,
    required this.onDecline,
    required this.onAdvance,
  });

  final ReportStatusEnum status;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onAdvance;

  @override
  Widget build(BuildContext context) {
    if (status == ReportStatusEnum.pending) {
      // Awaiting the responder's confirmation of an operator-made assignment.
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onDecline,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Decline'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: onAccept,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Accept Case'),
            ),
          ),
        ],
      );
    }

    final (label, icon) = switch (status) {
      ReportStatusEnum.accepted => ('En Route', Icons.directions_car),
      ReportStatusEnum.dispatched => ('Arrived on Scene', Icons.place),
      ReportStatusEnum.onScene => ('Resolve Case', Icons.check_circle),
      _ => ('', Icons.check),
    };

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onAdvance,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
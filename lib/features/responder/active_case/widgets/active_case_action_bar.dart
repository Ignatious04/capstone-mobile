// lib/features/responder/active_case/widgets/active_case_action_bar.dart
import 'package:capstone/core/enums/report_status_enum.dart';
import 'package:flutter/material.dart';

class ActiveCaseActionBar extends StatelessWidget {
  const ActiveCaseActionBar({
    super.key,
    required this.status,
    required this.onAdvance,
  });

  final ReportStatusEnum status;
  final VoidCallback onAdvance;

  @override
  Widget build(BuildContext context) {
    final action = switch (status) {
      ReportStatusEnum.accepted => (label: 'En Route', icon: Icons.directions_car),
      ReportStatusEnum.dispatched => (label: 'Arrived on Scene', icon: Icons.place),
      ReportStatusEnum.onScene => (label: 'Resolve Case', icon: Icons.check_circle),
      _ => null,
    };

    // A responder's active case should never be `pending` or `resolved`
    // by the time it reaches this screen (see watchAssignedReport), but
    // fail safe rather than showing a broken button if it ever is.
    if (action == null) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onAdvance,
        icon: Icon(action.icon),
        label: Text(action.label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

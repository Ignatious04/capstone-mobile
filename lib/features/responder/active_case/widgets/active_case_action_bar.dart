import 'dart:async';

import 'package:capstone/core/enums/report_status_enum.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:flutter/material.dart';

class ActiveCaseActionBar extends StatefulWidget {
  const ActiveCaseActionBar({
    super.key,
    required this.status,
    required this.onAdvance,
    this.holdDuration = const Duration(seconds: 2),
  });

  final ReportStatusEnum status;
  final VoidCallback onAdvance;
  final Duration holdDuration;

  @override
  State<ActiveCaseActionBar> createState() => _ActiveCaseActionBarState();
}

class _ActiveCaseActionBarState extends State<ActiveCaseActionBar> {
  Timer? _holdTimer;
  bool isHeld = false;

  void _startHold() {
    _holdTimer?.cancel();
    _holdTimer = Timer(widget.holdDuration, widget.onAdvance);
    setState(() {
      isHeld = true;
    });
  }

  void _cancelHold() {
    _holdTimer?.cancel();
    _holdTimer = null;
    setState(() {
      isHeld = false;
    });
  }

  @override
  void didUpdateWidget(covariant ActiveCaseActionBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Status changed (case advanced) -> make sure no stale timer is running.
    if (oldWidget.status != widget.status) _cancelHold();
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final action = switch (widget.status) {
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
      child: Listener(
        onPointerDown: (_) => _startHold(),
        onPointerUp: (_) => _cancelHold(),
        onPointerCancel: (_) => _cancelHold(),
        child: CustomElevatedButton(
          onPressed: () {}, // non-null so the button doesn't look disabled
          value: action.label,
          backgroundColor: isHeld ? Colors.black54 : Colors.deepOrange,
          icon: Icon(action.icon),
        ),
      ),
    );
  }
}

import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/enums/report_status_enum.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
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

class _ActiveCaseActionBarState extends State<ActiveCaseActionBar> with SingleTickerProviderStateMixin {
  static const _baseColor = Colors.deepOrange;
  static final _fillColor = Colors.deepOrange.shade900; // swap for Colors.black54 to keep the old held look
  static const _maxDrift = 24.0; // px the finger may wander before the hold is cancelled

  late final AnimationController _controller;
  Offset? _downPosition;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
          vsync: this,
          duration: widget.holdDuration,
          reverseDuration: const Duration(milliseconds: 250), // drains faster than it fills
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) widget.onAdvance();
        });
  }

  void _startHold(PointerDownEvent event) {
    _downPosition = event.position;
    _controller.forward();
  }

  void _cancelHold() {
    _downPosition = null;
    _controller.reverse();
  }

  void _onMove(PointerMoveEvent event) {
    final start = _downPosition;
    if (start != null && (event.position - start).distance > _maxDrift) _cancelHold();
  }

  @override
  void didUpdateWidget(covariant ActiveCaseActionBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = widget.holdDuration;
    // Status changed (case advanced) -> reset the fill for the next action.
    if (oldWidget.status != widget.status) {
      _downPosition = null;
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final action = switch (widget.status) {
      ReportStatusEnum.accepted => (label: l10n.enRoute, icon: Icons.directions_car),
      ReportStatusEnum.dispatched => (label: l10n.arrivedOnScene, icon: Icons.place),
      ReportStatusEnum.onScene => (label: l10n.resolveCase, icon: Icons.check_circle),
      _ => null,
    };

    // A responder's active case should never be `pending` or `resolved`
    // by the time it reaches this screen (see watchActiveResponse), but
    // fail safe rather than showing a broken button if it ever is.
    if (action == null) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: Listener(
        onPointerDown: _startHold,
        onPointerMove: _onMove,
        onPointerUp: (_) => _cancelHold(),
        onPointerCancel: (_) => _cancelHold(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: _baseColor),
              AnimatedBuilder(
                animation: _controller,
                builder: (_, _) => Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: _controller.value,
                    heightFactor: 1,
                    child: ColoredBox(color: _fillColor),
                  ),
                ),
              ),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(action.icon, color: Colors.white),
                    const SizedBox(width: 8),
                    BodyText(value: action.label, color: Colors.white, isBold: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

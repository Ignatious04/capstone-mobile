import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:flutter/material.dart';

/// A [ServiceButton]-style button that only fires after being held down for
/// [holdDuration]. A fill sweeps across the button while the hold is in
/// progress; letting go early (or dragging away) cancels it.
class HoldServiceButton extends StatefulWidget {
  const HoldServiceButton({
    super.key,
    required this.onHoldComplete,
    required this.value,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    this.enabled = true,
    this.holdDuration = const Duration(seconds: 1),
  });

  final VoidCallback onHoldComplete;
  final String value;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final bool enabled;
  final Duration holdDuration;

  @override
  State<HoldServiceButton> createState() => _HoldServiceButtonState();
}

class _HoldServiceButtonState extends State<HoldServiceButton> with SingleTickerProviderStateMixin {
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
          if (status == AnimationStatus.completed) {
            widget.onHoldComplete();
            // Reset right away so the button never gets stuck full while
            // the report is being sent.
            _controller.reverse();
          }
        });
  }

  void _startHold(PointerDownEvent event) {
    if (!mounted || !widget.enabled) return;
    _downPosition = event.position;
    _controller.forward();
  }

  void _cancelHold() {
    if (!mounted) return;
    _downPosition = null;
    _controller.reverse();
  }

  void _onMove(PointerMoveEvent event) {
    if (!mounted) return;
    final start = _downPosition;
    if (start != null && (event.position - start).distance > _maxDrift) _cancelHold();
  }

  @override
  void didUpdateWidget(covariant HoldServiceButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = widget.holdDuration;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fillColor = widget.color.withValues(alpha: 0.25);

    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: widget.value,
      // Screen-reader users can't "hold" a Listener, so expose a long press.
      onLongPress: widget.enabled ? widget.onHoldComplete : null,
      child: ExcludeSemantics(
        child: SizedBox(
          height: 100,
          child: Listener(
            onPointerDown: _startHold,
            onPointerMove: _onMove,
            onPointerUp: (_) => _cancelHold(),
            onPointerCancel: (_) => _cancelHold(),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: widget.color, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (_, _) => Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: _controller.value,
                          heightFactor: 1,
                          child: ColoredBox(color: fillColor),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(widget.icon, size: 30, color: widget.color),
                        const SizedBox(height: 10),
                        BodyText(
                          value: widget.value,
                          color: widget.color,
                          isBold: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
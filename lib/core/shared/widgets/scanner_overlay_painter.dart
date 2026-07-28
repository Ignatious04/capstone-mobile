import 'package:flutter/material.dart';

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final overlay = Paint()..color = Colors.black.withValues(alpha: 0.4);

    final screen = Path()
      ..addRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    final cutout = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(size.width / 2, size.height / 2),
            width: size.width * 0.9,
            height: size.height * 0.8,
          ),
          const Radius.circular(12),
        ),
      );

    final path = Path.combine(
      PathOperation.difference,
      screen,
      cutout,
    );

    canvas.drawPath(path, overlay);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

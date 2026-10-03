import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class IconToBitmapDescriptor {
  /// [size] is the pin's logical width. Height is 1.3x the width.
  /// [pixelRatio] keeps the marker sharp on high-density screens.
  static Future<BitmapDescriptor> convert({
    required IconData icon,
    required Color color,
    double size = 48,
    Color iconColor = Colors.white,
    double pixelRatio = 3.0,
  }) async {
    final width = size;
    final height = size * 1.3;
    final pad = size * 0.10; // room for shadow so it isn't clipped

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(pixelRatio);

    // ------------------------------------------------------------
    // Pin geometry: circle + tangent lines meeting at the tip
    // ------------------------------------------------------------
    final radius = width / 2 - pad;
    final cx = width / 2;
    final cy = pad + radius;
    final tipY = height - pad;

    final d = tipY - cy; // center -> tip distance
    final theta = math.acos(radius / d); // tangent point angle

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    final pinPath = Path()
      ..moveTo(cx, tipY)
      ..lineTo(
        cx + radius * math.sin(theta),
        cy + radius * math.cos(theta),
      )
      // Arc counter-clockwise over the top to the left tangent point
      ..arcTo(rect, math.pi / 2 - theta, 2 * theta - 2 * math.pi, false)
      ..close();

    // ------------------------------------------------------------
    // Shadow, fill, outline
    // ------------------------------------------------------------
    canvas.drawPath(
      pinPath.shift(const Offset(0, 2)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );

    canvas.drawPath(pinPath, Paint()..color = color);

    canvas.drawPath(
      pinPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size * 0.04
        ..strokeJoin = StrokeJoin.round
        ..color = Colors.white,
    );

    // ------------------------------------------------------------
    // Icon, centered on the circle
    // ------------------------------------------------------------
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: radius * 1.5,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: iconColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(cx - textPainter.width / 2, cy - textPainter.height / 2),
    );

    // ------------------------------------------------------------
    // To BitmapDescriptor
    // ------------------------------------------------------------
    final image = await recorder.endRecording().toImage(
      (width * pixelRatio).ceil(),
      (height * pixelRatio).ceil(),
    );

    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('Failed to convert icon to BitmapDescriptor');
    }

    return BitmapDescriptor.bytes(
      byteData.buffer.asUint8List(),
      imagePixelRatio: pixelRatio,
    );
  }
}

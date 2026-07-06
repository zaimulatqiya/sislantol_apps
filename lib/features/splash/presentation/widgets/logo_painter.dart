import 'dart:math';
import 'package:flutter/material.dart';

class LogoPainter extends CustomPainter {
  final double dotScale;
  final double dotOpacity;
  final double roadProgress;
  final double ring1Scale;
  final double ring1Opacity;
  final double ring2Scale;
  final double ring2Opacity;
  final double ring3Scale;
  final double ring3Opacity;
  final Color primaryColor;

  LogoPainter({
    required this.dotScale,
    required this.dotOpacity,
    required this.roadProgress,
    required this.ring1Scale,
    required this.ring1Opacity,
    required this.ring2Scale,
    required this.ring2Opacity,
    required this.ring3Scale,
    required this.ring3Opacity,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2.5); // Slightly above center
    final dotRadius = size.width * 0.08;

    // Paints
    final dotPaint = Paint()
      ..color = primaryColor.withOpacity(dotOpacity.clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.03
      ..strokeCap = StrokeCap.round;

    final roadPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04
      ..strokeCap = StrokeCap.round;

    final dashedPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.02
      ..strokeCap = StrokeCap.round;

    // 1. Draw Road (Perspective)
    if (roadProgress > 0) {
      _drawRoad(canvas, size, center, dotRadius, roadPaint, dashedPaint);
    }

    // 2. Draw Dot
    if (dotScale > 0 && dotOpacity > 0) {
      canvas.drawCircle(center, dotRadius * dotScale, dotPaint);
    }

    // 3. Draw Rings
    _drawRing(canvas, center, dotRadius * 2.0, ring1Scale, ring1Opacity, ringPaint, primaryColor);
    _drawRing(canvas, center, dotRadius * 3.2, ring2Scale, ring2Opacity, ringPaint, primaryColor);
    _drawRing(canvas, center, dotRadius * 4.4, ring3Scale, ring3Opacity, ringPaint, primaryColor);
  }

  void _drawRoad(
      Canvas canvas, Size size, Offset dotCenter, double dotRadius, Paint roadPaint, Paint dashedPaint) {
    // Road starts just below the dot
    final startY = dotCenter.dy + dotRadius + 10;
    final endY = size.height;
    
    // Top width is narrow, bottom width is wide (perspective)
    final topHalfWidth = size.width * 0.15;
    final bottomHalfWidth = size.width * 0.45;

    final currentY = startY + ((endY - startY) * roadProgress);
    
    // Calculate current width based on progress to animate the drawing outwards
    final currentLeftX = dotCenter.dx - topHalfWidth - ((bottomHalfWidth - topHalfWidth) * roadProgress);
    final currentRightX = dotCenter.dx + topHalfWidth + ((bottomHalfWidth - topHalfWidth) * roadProgress);

    // Left line
    canvas.drawLine(
      Offset(dotCenter.dx - topHalfWidth, startY),
      Offset(currentLeftX, currentY),
      roadPaint,
    );

    // Right line
    canvas.drawLine(
      Offset(dotCenter.dx + topHalfWidth, startY),
      Offset(currentRightX, currentY),
      roadPaint,
    );

    // Dashed center line
    final totalDistance = endY - startY;
    final dashLength = size.height * 0.08;
    final dashSpace = size.height * 0.06;
    
    double distanceDrawn = 0;
    while (distanceDrawn < totalDistance * roadProgress) {
      final dashStartY = startY + distanceDrawn;
      final remainingDist = (totalDistance * roadProgress) - distanceDrawn;
      final actualDashLength = min(dashLength, remainingDist);
      
      canvas.drawLine(
        Offset(dotCenter.dx, dashStartY),
        Offset(dotCenter.dx, dashStartY + actualDashLength),
        dashedPaint,
      );
      distanceDrawn += dashLength + dashSpace;
    }
  }

  void _drawRing(Canvas canvas, Offset center, double baseRadius, double scale, double opacity, Paint paint, Color color) {
    if (scale <= 0 || opacity <= 0) return;
    
    paint.color = color.withOpacity(opacity.clamp(0.0, 1.0));
    final radius = baseRadius * scale;
    final rect = Rect.fromCircle(center: center, radius: radius);
    
    // Draw an arc (top half, open downwards)
    // Start angle: PI (180 degrees), Sweep angle: PI (180 degrees)
    // This draws from 9 o'clock to 3 o'clock (the top half)
    canvas.drawArc(rect, pi, pi, false, paint);
  }

  @override
  bool shouldRepaint(covariant LogoPainter oldDelegate) {
    return oldDelegate.dotScale != dotScale ||
        oldDelegate.dotOpacity != dotOpacity ||
        oldDelegate.roadProgress != roadProgress ||
        oldDelegate.ring1Scale != ring1Scale ||
        oldDelegate.ring1Opacity != ring1Opacity ||
        oldDelegate.ring2Scale != ring2Scale ||
        oldDelegate.ring2Opacity != ring2Opacity ||
        oldDelegate.ring3Scale != ring3Scale ||
        oldDelegate.ring3Opacity != ring3Opacity ||
        oldDelegate.primaryColor != primaryColor;
  }
}

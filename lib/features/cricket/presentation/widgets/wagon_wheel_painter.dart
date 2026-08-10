import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:trace_odd/shared/theme/cricket_colors.dart';

import '../../data/models/cricket_models.dart';

/// A [CustomPainter] that renders a cricket wagon wheel —
/// a 360° circular field with shot lines radiating from the
/// batsman at center.  Colors indicate runs scored:
///
/// | Runs | Color  | Shape       |
/// |------|--------|-------------|
/// | 0    | gray   | dot         |
/// | 1    | white  | line        |
/// | 2    | cyan   | line        |
/// | 3    | teal   | line        |
/// | 4    | green  | line        |
/// | 6    | gold   | line        |
///
/// The pitch strip runs vertically through the center.
/// Off-side labels appear on the right; leg-side on the left.
class WagonWheelPainter extends CustomPainter {
  final List<WagonWheelShot> shots;
  final Color pitchColor;
  final Color grassColor;

  WagonWheelPainter({
    required this.shots,
    this.pitchColor = CricketColors.pitchBrown,
    this.grassColor = CricketColors.fieldGrass,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 16;

    // ── Draw field circle ─────────────────────────────────
    final fieldPaint = Paint()
      ..color = grassColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, fieldPaint);

    // Outer ring
    final ringPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, ringPaint);

    // 30-yard inner circle (dashed)
    final innerPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius * 0.55, innerPaint);

    // ── Pitch strip ───────────────────────────────────────
    final pitchRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: radius * 0.08,
        height: radius * 0.55,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(pitchRect, Paint()..color = pitchColor);

    // Crease lines
    final creasePaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(center.dx - radius * 0.04, center.dy - radius * 0.1),
      Offset(center.dx + radius * 0.04, center.dy - radius * 0.1),
      creasePaint,
    );
    canvas.drawLine(
      Offset(center.dx - radius * 0.04, center.dy + radius * 0.1),
      Offset(center.dx + radius * 0.04, center.dy + radius * 0.1),
      creasePaint,
    );

    // ── Radial guide lines ────────────────────────────────
    final guidePaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    for (int deg = 0; deg < 360; deg += 30) {
      final rad = deg * math.pi / 180;
      final end = Offset(
        center.dx + radius * 0.3 * math.cos(rad),
        center.dy + radius * 0.3 * math.sin(rad),
      );
      canvas.drawLine(center, end, guidePaint);
    }

    // ── Draw shots ────────────────────────────────────────
    for (final shot in shots) {
      _drawShot(canvas, center, radius, shot);
    }

    // ── Labels ────────────────────────────────────────────
    _drawLabel(canvas, center, radius, 'OFF', -math.pi / 4, Colors.blueGrey);
    _drawLabel(
      canvas,
      center,
      radius,
      'LEG',
      math.pi + math.pi / 4,
      Colors.blueGrey,
    );

    // ── Center dot ────────────────────────────────────────
    canvas.drawCircle(center, 4, Paint()..color = Colors.white);
  }

  // ----------------------------------------------------------
  // Helpers
  // ----------------------------------------------------------

  void _drawShot(
    Canvas canvas,
    Offset center,
    double radius,
    WagonWheelShot shot,
  ) {
    // Use coordinates if available, otherwise derive from direction
    double dx, dy;
    if (shot.x != null && shot.y != null) {
      dx = shot.x! * radius;
      dy = shot.y! * radius;
    } else if (shot.direction != null) {
      final rad = shot.direction! * math.pi / 180;
      dx = math.cos(rad) * radius * 0.9;
      dy = math.sin(rad) * radius * 0.9;
    } else {
      return;
    }

    final end = Offset(center.dx + dx, center.dy - dy); // invert Y for canvas
    final color = _colorForRuns(shot.runs);

    if (shot.runs == 0) {
      // Dot ball — small filled circle
      canvas.drawCircle(end, 3, Paint()..color = color);
    } else {
      // Scoring shot — line from center to endpoint
      final linePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = shot.isBoundary ? 2.5 : 1.5
        ..strokeCap = StrokeCap.round;

      // Shorten line slightly so dots sit inside the circle edge
      final start = Offset.lerp(center, end, 0.06)!;
      canvas.drawLine(start, end, linePaint);

      // Small dot at endpoint
      canvas.drawCircle(end, 3, Paint()..color = color);
    }
  }

  Color _colorForRuns(int runs) {
    switch (runs) {
      case 6:
        return CricketColors.runSix; // gold
      case 4:
        return CricketColors.runFour; // green
      case 3:
        return CricketColors.runThree; // teal
      case 2:
        return CricketColors.runTwo; // cyan
      case 1:
        return CricketColors.runSingle;
      default:
        return CricketColors.runDot;
    }
  }

  void _drawLabel(
    Canvas canvas,
    Offset center,
    double radius,
    String text,
    double angle,
    Color color,
  ) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final x = center.dx + (radius + 14) * math.cos(angle) - tp.width / 2;
    final y = center.dy + (radius + 14) * math.sin(angle) - tp.height / 2;
    tp.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(covariant WagonWheelPainter oldDelegate) =>
      shots != oldDelegate.shots;
}

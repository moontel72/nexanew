// NEXATRACE — PASSENGER SEAT PAINTER
// =====================================
// CustomPainter that renders the bus floor-plan from
// AbsoluteLayoutComponent data. Draws structural elements
// (walls, aisle, driver cabin) and interactive seats with
// color-coded availability status.
//
// MODULE: 8V — Interactive Seat Selection

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:trace_odd/features/bus_operations/data/models/passenger_seat_model.dart';

/// Custom painter that renders the entire bus floor plan with
/// structural elements, seat icons, and booking status colors.
class PassengerSeatPainter extends CustomPainter {
  final List<PassengerSeatModel> seats;
  final double canvasWidth;
  final double canvasHeight;
  final PassengerSeatModel? selectedSeat;
  final bool animate;

  // ── Color palette ──
  static const _colorAvailable = Color(0xFF22C55E);   // green
  static const _colorAvailableStroke = Color(0xFF16A34A);
  static const _colorSelected = Color(0xFF3B82F6);     // blue
  static const _colorSelectedStroke = Color(0xFF2563EB);
  static const _colorBooked = Color(0xFFEF4444);       // red
  static const _colorBookedStroke = Color(0xFFDC2626);
  static const _colorBusiness = Color(0xFFA855F7);     // purple
  static const _colorBusinessStroke = Color(0xFF9333EA);
  static const _colorSleeper = Color(0xFFF59E0B);      // amber
  static const _colorSleeperStroke = Color(0xFFD97706);
  static const _colorStructural = Color(0xFF9CA3AF);   // gray
  static const _colorDriver = Color(0xFF1F2937);       // dark
  static const _colorFloor = Color(0xFFF1F5F9);        // light gray
  static const _colorWall = Color(0xFF64748B);         // slate
  static const _colorAisle = Color(0xFFE2E8F0);        // lighter gray

  PassengerSeatPainter({
    required this.seats,
    required this.canvasWidth,
    required this.canvasHeight,
    this.selectedSeat,
    this.animate = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / canvasWidth;
    final scaleY = size.height / canvasHeight;
    final scale = math.min(scaleX, scaleY);

    canvas.save();
    canvas.scale(scale, scale);

    // ── 1. Draw floor ──
    _drawFloor(canvas);

    // ── 2. Draw aisles and structural elements ──
    for (final seat in seats) {
      if (seat.category == PassengerSeatCategory.structural) {
        if (seat.seatLabel == 'aisle') {
          _drawAisle(canvas, seat);
        }
      }
    }

    // ── 3. Draw seats (sorted: structural first, then bookable) ──
    final structural = seats.where((s) => s.isStructural).toList();
    final bookable = seats.where((s) => !s.isStructural).toList();

    for (final seat in [...structural, ...bookable]) {
      _drawSeat(canvas, seat);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PassengerSeatPainter oldDelegate) {
    return oldDelegate.seats != seats ||
        oldDelegate.selectedSeat?.componentId != selectedSeat?.componentId ||
        oldDelegate.canvasWidth != canvasWidth ||
        oldDelegate.canvasHeight != canvasHeight;
  }

  // ── Floor ───────────────────────────────────────────

  void _drawFloor(Canvas canvas) {
    final paint = Paint()
      ..color = _colorFloor
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, canvasWidth, canvasHeight),
        const Radius.circular(8),
      ),
      paint,
    );

    // Outer border (bus walls)
    final border = Paint()
      ..color = _colorWall
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(1, 1, canvasWidth - 2, canvasHeight - 2),
        const Radius.circular(8),
      ),
      border,
    );
  }

  // ── Aisle ───────────────────────────────────────────

  void _drawAisle(Canvas canvas, PassengerSeatModel aisle) {
    final paint = Paint()
      ..color = _colorAisle
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(aisle.x, aisle.y, aisle.width, aisle.height),
      paint,
    );
  }

  // ── Single Seat ─────────────────────────────────────

  void _drawSeat(Canvas canvas, PassengerSeatModel seat) {
    canvas.save();

    // Translate to seat center for rotation
    canvas.translate(seat.centerX, seat.centerY);
    if (seat.rotation != 0) {
      canvas.rotate(seat.rotation * math.pi / 180);
    }

    final halfW = seat.width / 2;
    final halfH = seat.height / 2;

    final (fillColor, strokeColor) = _resolveColors(seat);

    // ── Shadow (for elevated seats) ──
    if (!seat.isStructural) {
      final shadow = Paint()
        ..color = Colors.black.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: const Offset(1.5, 2), width: seat.width, height: seat.height),
          const Radius.circular(6),
        ),
        shadow,
      );
    }

    // ── Main seat body ──
    final bodyPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final bodyStroke = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final seatRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: seat.width - 4, height: seat.height - 4),
      const Radius.circular(5),
    );

    canvas.drawRRect(seatRect, bodyPaint);
    canvas.drawRRect(seatRect, bodyStroke);

    // ── Seat backrest indicator (top 30%) ──
    if (!seat.isStructural) {
      final backrestPaint = Paint()
        ..color = strokeColor.withValues(alpha: 0.25)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(0, seat.isReverseFacing ? halfH * 0.35 : -halfH * 0.35),
            width: seat.width - 10,
            height: seat.height * 0.3,
          ),
          const Radius.circular(4),
        ),
        backrestPaint,
      );
    }

    // ── Type-specific icon ──
    if (!seat.isStructural) {
      _drawSeatIcon(canvas, seat, halfW, halfH);
    }

    // ── Seat number badge ──
    if (seat.displayLabel.isNotEmpty) {
      _drawSeatLabel(canvas, seat, halfW, halfH, fillColor);
    }

    // ── Selection glow ──
    if (seat.availability == SeatAvailability.selected) {
      final glowPaint = Paint()
        ..color = _colorSelected.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawRRect(seatRect, glowPaint);
    }

    canvas.restore();
  }

  // ── Icon ────────────────────────────────────────────

  void _drawSeatIcon(
      Canvas canvas, PassengerSeatModel seat, double halfW, double halfH) {
    final iconPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    String icon;
    switch (seat.category) {
      case PassengerSeatCategory.sleeper:
        icon = '🛏';
        break;
      case PassengerSeatCategory.businessClass:
        icon = '★';
        break;
      case PassengerSeatCategory.folding:
        icon = '⇲';
        break;
      case PassengerSeatCategory.driverCabin:
        icon = '⚙';
        break;
      default:
        icon = '💺';
    }

    textPainter.text = TextSpan(
      text: icon,
      style: TextStyle(fontSize: halfW * 0.55, color: Colors.white.withValues(alpha: 0.5)),
    );
    textPainter.layout(maxWidth: seat.width);
    textPainter.paint(
      canvas,
      Offset(
        -textPainter.width / 2,
        seat.isReverseFacing ? halfH * 0.05 : -halfH * 0.65,
      ),
    );
  }

  // ── Label ───────────────────────────────────────────

  void _drawSeatLabel(
      Canvas canvas, PassengerSeatModel seat, double halfW, double halfH, Color fill) {
    final isLight = _isLightColor(fill);
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.text = TextSpan(
      text: seat.displayLabel,
      style: TextStyle(
        fontSize: halfW * 0.42,
        fontWeight: FontWeight.w700,
        color: isLight ? Colors.black87 : Colors.white,
      ),
    );
    textPainter.layout(maxWidth: seat.width);
    textPainter.paint(
      canvas,
      Offset(
        -textPainter.width / 2,
        seat.isReverseFacing ? -halfH * 0.2 : halfH * 0.05,
      ),
    );
  }

  // ── Color helpers ───────────────────────────────────

  (Color, Color) _resolveColors(PassengerSeatModel seat) {
    if (seat.isStructural) {
      return seat.category == PassengerSeatCategory.driverCabin
          ? (_colorDriver, _colorWall)
          : (_colorStructural, _colorWall);
    }

    // Bookable seats — color by availability + category tint
    Color base;
    Color stroke;
    switch (seat.availability) {
      case SeatAvailability.selected:
        base = _colorSelected;
        stroke = _colorSelectedStroke;
        break;
      case SeatAvailability.booked:
      case SeatAvailability.held:
        base = _colorBooked;
        stroke = _colorBookedStroke;
        break;
      case SeatAvailability.available:
      default:
        switch (seat.category) {
          case PassengerSeatCategory.businessClass:
            base = _colorBusiness;
            stroke = _colorBusinessStroke;
            break;
          case PassengerSeatCategory.sleeper:
            base = _colorSleeper;
            stroke = _colorSleeperStroke;
            break;
          default:
            base = _colorAvailable;
            stroke = _colorAvailableStroke;
        }
    }
    return (base, stroke);
  }

  bool _isLightColor(Color color) {
    final luminance =
        (0.299 * color.r + 0.587 * color.g + 0.114 * color.b) * 255;
    return luminance > 150;
  }
}

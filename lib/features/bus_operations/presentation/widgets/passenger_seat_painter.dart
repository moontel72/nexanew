// NEXATRACE — PASSENGER SEAT PAINTER
// =====================================
// CustomPainter that renders the bus floor-plan from
// AbsoluteLayoutComponent data. Draws structural elements
// (walls, aisle, driver cabin) and interactive seats with
// color-coded availability status.
//
// v2: Airline-style compact design — narrow rounded seats,
//     subtle shadows, clean labels, no emoji icons.
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

  // ── Airline-style color palette ──
  static const _colorAvailable = Color(0xFF3B82F6); // blue (like airline)
  static const _colorAvailableStroke = Color(0xFF2563EB);
  static const _colorSelected = Color(0xFF10B981); // emerald
  static const _colorSelectedStroke = Color(0xFF059669);
  static const _colorBooked = Color(0xFF9CA3AF); // gray
  static const _colorBookedStroke = Color(0xFF6B7280);
  static const _colorBusiness = Color(0xFF8B5CF6); // violet
  static const _colorBusinessStroke = Color(0xFF7C3AED);
  static const _colorSleeper = Color(0xFFF59E0B); // amber
  static const _colorSleeperStroke = Color(0xFFD97706);
  static const _colorStructural = Color(0xFFD1D5DB);
  static const _colorDriver = Color(0xFF374151);
  static const _colorFloor = Color(0xFFF9FAFB);
  static const _colorWall = Color(0xFFE5E7EB);
  static const _colorAisle = Color(0xFFF3F4F6);
  static const _colorAisleLabel = Color(0xFF9CA3AF);

  PassengerSeatPainter({
    required this.seats,
    required this.canvasWidth,
    required this.canvasHeight,
    this.selectedSeat,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / canvasWidth;
    final scaleY = size.height / canvasHeight;
    final scale = math.min(scaleX, scaleY);

    // Center the canvas
    final offsetX = (size.width - canvasWidth * scale) / 2;
    final offsetY = (size.height - canvasHeight * scale) / 2;

    canvas.save();
    canvas.translate(offsetX, offsetY);
    canvas.scale(scale, scale);

    // ── 1. Floor background ──
    _drawFloor(canvas);

    // ── 2. Structural elements (aisle, walls) ──
    for (final seat in seats) {
      if (seat.isStructural) {
        _drawStructural(canvas, seat);
      }
    }

    // ── 3. Seat rows (grouped and drawn back-to-front) ──
    final bookable = seats.where((s) => !s.isStructural).toList();
    // Sort by Y (top to bottom) for consistent z-order
    bookable.sort((a, b) => a.y.compareTo(b.y));
    for (final seat in bookable) {
      _drawSeat(canvas, seat);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PassengerSeatPainter oldDelegate) {
    return oldDelegate.seats != seats ||
        oldDelegate.selectedSeat?.componentId != selectedSeat?.componentId;
  }

  // ── Floor ───────────────────────────────────────────

  void _drawFloor(Canvas canvas) {
    // Subtle outer container
    final outer = Paint()
      ..color = _colorFloor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, canvasWidth, canvasHeight),
        const Radius.circular(12),
      ),
      outer,
    );

    // Thin border
    final border = Paint()
      ..color = _colorWall
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(1, 1, canvasWidth - 2, canvasHeight - 2),
        const Radius.circular(12),
      ),
      border,
    );
  }

  // ── Structural ──────────────────────────────────────

  void _drawStructural(Canvas canvas, PassengerSeatModel el) {
    if (el.category == PassengerSeatCategory.driverCabin) {
      // Driver cabin — dark tinted zone with steering wheel hint
      final paint = Paint()
        ..color = _colorDriver.withValues(alpha: 0.15)
        ..style = PaintingStyle.fill;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(el.x, el.y, el.width, el.height),
        const Radius.circular(4),
      );
      canvas.drawRRect(rect, paint);

      // Label
      final tp = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      tp.text = TextSpan(
        text: '🚌',
        style: TextStyle(
          fontSize: 11,
          color: _colorDriver.withValues(alpha: 0.5),
        ),
      );
      tp.layout(maxWidth: el.width);
      tp.paint(
        canvas,
        Offset(el.centerX - tp.width / 2, el.centerY - tp.height / 2),
      );
    } else {
      // Aisle or other structural — light wash
      final paint = Paint()
        ..color = _colorAisle
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(el.x, el.y, el.width, el.height), paint);

      // Aisle label
      if (el.seatLabel == 'aisle') {
        final tp = TextPainter(
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        tp.text = TextSpan(
          text: 'AISLE',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: _colorAisleLabel,
            letterSpacing: 2,
          ),
        );
        tp.layout(maxWidth: el.width);
        tp.paint(
          canvas,
          Offset(el.centerX - tp.width / 2, el.centerY - tp.height / 2),
        );
      }
    }
  }

  // ── Single Seat ─────────────────────────────────────

  void _drawSeat(Canvas canvas, PassengerSeatModel seat) {
    canvas.save();
    canvas.translate(seat.centerX, seat.centerY);
    if (seat.rotation != 0) {
      canvas.rotate(seat.rotation * math.pi / 180);
    }

    final w = seat.width;
    final h = seat.height;
    final halfH = h / 2;

    final (fillColor, strokeColor) = _resolveColors(seat);

    // Render margin — seat body is slightly inset
    const margin = 3.0;
    final bodyW = w - margin * 2;
    final bodyH = h - margin * 2;
    final radius = math.min(bodyW, bodyH) * 0.2;

    // ── Subtle shadow ──
    if (!seat.isStructural) {
      final shadow = Paint()
        ..color = Colors.black.withValues(alpha: 0.06)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: const Offset(0.5, 1),
            width: bodyW,
            height: bodyH,
          ),
          Radius.circular(radius),
        ),
        shadow,
      );
    }

    // ── Seat body ──
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: bodyW, height: bodyH),
      Radius.circular(radius),
    );

    final bodyPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(bodyRect, bodyPaint);

    // Thin border
    final borderPaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(bodyRect, borderPaint);

    // ── Seat backrest stripe (top portion) ──
    if (!seat.isStructural) {
      final stripeH = bodyH * 0.22;
      final stripeRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(0, -halfH + margin + stripeH / 2),
          width: bodyW - 4,
          height: stripeH,
        ),
        Radius.circular(radius * 0.6),
      );
      final stripePaint = Paint()
        ..color = strokeColor.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(stripeRect, stripePaint);
    }

    // ── Selected glow ring ──
    if (seat.availability == SeatAvailability.selected) {
      final glowPaint = Paint()
        ..color = _colorSelected.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawRRect(bodyRect, glowPaint);
    }

    // ── Seat label (bottom portion) ──
    if (seat.displayLabel.isNotEmpty) {
      _drawCompactLabel(canvas, seat, bodyW, bodyH, halfH, margin);
    }

    canvas.restore();
  }

  // ── Compact Label ───────────────────────────────────

  void _drawCompactLabel(
    Canvas canvas,
    PassengerSeatModel seat,
    double bodyW,
    double bodyH,
    double halfH,
    double margin,
  ) {
    final isLight = _isLightColor(_resolveColors(seat).$1);
    final label = seat.displayLabel;

    // Scale font to fit inside the seat body
    double fontSize;
    if (label.length <= 2) {
      fontSize = bodyW * 0.38;
    } else if (label.length <= 3) {
      fontSize = bodyW * 0.32;
    } else {
      fontSize = bodyW * 0.26;
    }
    fontSize = fontSize.clamp(7.0, 13.0);

    final tp = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    tp.text = TextSpan(
      text: label,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: isLight ? Colors.black87 : Colors.white,
        height: 1.0,
      ),
    );
    tp.layout(maxWidth: bodyW);

    // Position label in lower portion of seat
    final labelY = halfH - margin - tp.height - 2;
    tp.paint(canvas, Offset(-tp.width / 2, labelY));
  }

  // ── Colors ──────────────────────────────────────────

  (Color, Color) _resolveColors(PassengerSeatModel seat) {
    if (seat.isStructural) {
      return seat.category == PassengerSeatCategory.driverCabin
          ? (_colorDriver, _colorWall)
          : (_colorStructural, _colorWall);
    }

    switch (seat.availability) {
      case SeatAvailability.selected:
        return (_colorSelected, _colorSelectedStroke);
      case SeatAvailability.booked:
      case SeatAvailability.held:
        return (_colorBooked, _colorBookedStroke);
      case SeatAvailability.available:
      default:
        switch (seat.category) {
          case PassengerSeatCategory.businessClass:
            return (_colorBusiness, _colorBusinessStroke);
          case PassengerSeatCategory.sleeper:
            return (_colorSleeper, _colorSleeperStroke);
          default:
            return (_colorAvailable, _colorAvailableStroke);
        }
    }
  }

  bool _isLightColor(Color color) {
    final luminance =
        (0.299 * color.r + 0.587 * color.g + 0.114 * color.b) * 255;
    return luminance > 150;
  }
}

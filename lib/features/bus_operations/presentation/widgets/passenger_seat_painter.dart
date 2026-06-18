// NEXATRACE — PASSENGER SEAT PAINTER v3
// ========================================
// Premium bus-cabin rendering with 3D-styled seats,
// bus body framework, windshield, entry door, and
// dynamic availability states.
//
// MODULE: 8V — Interactive Seat Selection (Customer App)

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:trace_odd/features/bus_operations/data/models/passenger_seat_model.dart';

class PassengerSeatPainter extends CustomPainter {
  final List<PassengerSeatModel> seats;
  final double canvasWidth;
  final double canvasHeight;
  final PassengerSeatModel? selectedSeat;

  // ── Premium palette ──
  static const _colorAvailable = Color(0xFF2563EB); // rich blue
  static const _colorAvailableDark = Color(0xFF1D4ED8);
  static const _colorAvailableLight = Color(0xFF60A5FA);
  static const _colorSelected = Color(0xFF059669); // emerald
  static const _colorSelectedDark = Color(0xFF047857);
  static const _colorBooked = Color(0xFF9CA3AF); // gray
  static const _colorBookedDark = Color(0xFF6B7280);
  static const _colorBusiness = Color(0xFF7C3AED); // violet
  static const _colorBusinessDark = Color(0xFF6D28D9);
  static const _colorSleeper = Color(0xFFD97706); // amber
  static const _colorSleeperDark = Color(0xFFB45309);
  static const _colorFloor = Color(0xFFF1F5F9);
  static const _colorWall = Color(0xFFCBD5E1);
  static const _colorWindshield = Color(0xFFDBEAFE);
  static const _colorDoor = Color(0xFFFEE2E2);
  static const _colorAisle = Color(0xFFF8FAFC);

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
    final offsetX = (size.width - canvasWidth * scale) / 2;
    final offsetY = (size.height - canvasHeight * scale) / 2;

    canvas.save();
    canvas.translate(offsetX, offsetY);
    canvas.scale(scale, scale);

    // ── 1. Bus body framework ──
    _drawBusBody(canvas);

    // ── 2. Floor texture ──
    _drawFloorTexture(canvas);

    // ── 3. Structural elements ──
    for (final seat in seats) {
      if (seat.isStructural) _drawStructural(canvas, seat);
    }

    // ── 4. Seats sorted back-to-front ──
    final bookable = seats.where((s) => !s.isStructural).toList();
    bookable.sort((a, b) => a.y.compareTo(b.y));
    for (final seat in bookable) {
      _draw3DSeat(canvas, seat);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PassengerSeatPainter old) =>
      old.seats != seats ||
      old.selectedSeat?.componentId != selectedSeat?.componentId;

  // ═══════════════════════════════════════════════════════════
  // BUS BODY FRAMEWORK
  // ═══════════════════════════════════════════════════════════

  void _drawBusBody(Canvas canvas) {
    final bodyPaint = Paint()
      ..color = _colorFloor
      ..style = PaintingStyle.fill;

    // Main body rounded rect
    final bodyRect = RRect.fromLTRBAndCorners(
      0,
      0,
      canvasWidth,
      canvasHeight,
      topLeft: const Radius.circular(14),
      topRight: const Radius.circular(14),
      bottomLeft: const Radius.circular(6),
      bottomRight: const Radius.circular(6),
    );
    canvas.drawRRect(bodyRect, bodyPaint);

    // Outer wall stroke
    final wall = Paint()
      ..color = _colorWall
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRRect(bodyRect, wall);

    // ── Windshield area (top portion, centered) ──
    final windshieldW = canvasWidth * 0.55;
    final windshieldH = 32.0;
    final windshieldX = (canvasWidth - windshieldW) / 2;
    final windshieldY = 4.0;

    final windshield = Paint()
      ..color = _colorWindshield
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        windshieldX,
        windshieldY,
        windshieldX + windshieldW,
        windshieldY + windshieldH,
        topLeft: const Radius.circular(8),
        topRight: const Radius.circular(8),
      ),
      windshield,
    );

    // Windshield label
    final tp = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    tp.text = TextSpan(
      text: '🚌 FRONT',
      style: TextStyle(
        fontSize: 10,
        color: _colorWall.withValues(alpha: 0.7),
        fontWeight: FontWeight.w600,
        letterSpacing: 2,
      ),
    );
    tp.layout(maxWidth: windshieldW);
    tp.paint(
      canvas,
      Offset(windshieldX + (windshieldW - tp.width) / 2, windshieldY + 9),
    );

    // ── Door marker (right side, top area) ──
    final doorW = 22.0;
    final doorH = 36.0;
    final doorX = canvasWidth - doorW - 6;
    final doorY = windshieldY + windshieldH + 8;

    final doorPaint = Paint()
      ..color = _colorDoor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        doorX,
        doorY,
        doorX + doorW,
        doorY + doorH,
        topLeft: const Radius.circular(5),
        topRight: const Radius.circular(5),
      ),
      doorPaint,
    );

    final doorBorder = Paint()
      ..color = const Color(0xFFFCA5A5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        doorX,
        doorY,
        doorX + doorW,
        doorY + doorH,
        topLeft: const Radius.circular(5),
        topRight: const Radius.circular(5),
      ),
      doorBorder,
    );

    // Door label
    tp.text = TextSpan(
      text: 'DOOR',
      style: TextStyle(
        fontSize: 7,
        color: const Color(0xFFDC2626).withValues(alpha: 0.6),
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
    );
    tp.layout(maxWidth: doorW);
    tp.paint(
      canvas,
      Offset(doorX + (doorW - tp.width) / 2, doorY + doorH / 2 - 3),
    );

    // ── Side wall stripes ──
    final stripe = Paint()
      ..color = _colorWall.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, 3, canvasHeight), stripe);
    canvas.drawRect(Rect.fromLTWH(canvasWidth - 3, 0, 3, canvasHeight), stripe);
  }

  // ═══════════════════════════════════════════════════════════
  // FLOOR TEXTURE
  // ═══════════════════════════════════════════════════════════

  void _drawFloorTexture(Canvas canvas) {
    final stripe = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.fill;
    for (double y = 60; y < canvasHeight; y += 28) {
      canvas.drawRect(Rect.fromLTWH(8, y, canvasWidth - 16, 0.5), stripe);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // STRUCTURAL ELEMENTS
  // ═══════════════════════════════════════════════════════════

  void _drawStructural(Canvas canvas, PassengerSeatModel el) {
    if (el.category == PassengerSeatCategory.driverCabin) {
      // Driver zone with steering wheel icon
      final paint = Paint()
        ..color = const Color(0xFF1E293B).withValues(alpha: 0.12)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromLTRBAndCorners(
          el.x,
          el.y,
          el.x + el.width,
          el.y + el.height,
          topLeft: const Radius.circular(6),
          topRight: const Radius.circular(6),
          bottomLeft: const Radius.circular(3),
          bottomRight: const Radius.circular(3),
        ),
        paint,
      );

      final tp = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      tp.text = TextSpan(
        text: '🚌',
        style: TextStyle(
          fontSize: 13,
          color: const Color(0xFF475569).withValues(alpha: 0.5),
        ),
      );
      tp.layout(maxWidth: el.width);
      tp.paint(
        canvas,
        Offset(el.centerX - tp.width / 2, el.centerY - tp.height / 2),
      );
    } else {
      // Aisle or other structural
      final paint = Paint()
        ..color = _colorAisle
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(el.x, el.y, el.width, el.height), paint);

      if (el.seatLabel == 'aisle') {
        final tp = TextPainter(
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        tp.text = TextSpan(
          text: 'AISLE',
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w500,
            color: _colorWall,
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

  // ═══════════════════════════════════════════════════════════
  // 3D-STYLED SEAT
  // ═══════════════════════════════════════════════════════════

  void _draw3DSeat(Canvas canvas, PassengerSeatModel seat) {
    canvas.save();
    canvas.translate(seat.centerX, seat.centerY);
    if (seat.rotation != 0) {
      canvas.rotate(seat.rotation * math.pi / 180);
    }

    // Visual scale: render at 70% of DB dimensions
    const scale = 0.70;
    final w = seat.width * scale;
    final h = seat.height * scale;
    final hw = w / 2;
    final hh = h / 2;

    final (base, dark, light) = _seatColors(seat);

    const pad = 1.5;
    final bw = w - pad * 2; // body width
    final bh = h - pad * 2; // body height
    final radius = math.min(bw, bh) * 0.18;

    // ── Drop shadow ──
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        -hw + pad + 1,
        -hh + pad + 1.5,
        hw - pad + 1,
        hh - pad + 1.5,
        topLeft: Radius.circular(radius),
        topRight: Radius.circular(radius),
        bottomLeft: Radius.circular(radius * 0.5),
        bottomRight: Radius.circular(radius * 0.5),
      ),
      shadow,
    );

    // ── Seat base (cushion) ──
    final seatBody = RRect.fromLTRBAndCorners(
      -hw + pad,
      -hh + pad,
      hw - pad,
      hh - pad,
      topLeft: Radius.circular(radius),
      topRight: Radius.circular(radius),
      bottomLeft: Radius.circular(radius * 0.5),
      bottomRight: Radius.circular(radius * 0.5),
    );

    // Gradient fill for 3D effect
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [light, base, dark],
      stops: const [0.0, 0.45, 1.0],
    );
    final bodyPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCenter(center: Offset.zero, width: bw, height: bh),
      )
      ..style = PaintingStyle.fill;
    canvas.drawRRect(seatBody, bodyPaint);

    // Border
    final borderPaint = Paint()
      ..color = dark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawRRect(seatBody, borderPaint);

    // ── Headrest (top 25%) ──
    final hrH = bh * 0.25;
    final hrW = bw - 4;
    final hrRect = RRect.fromLTRBAndCorners(
      -hrW / 2,
      -hh + pad + 1,
      hrW / 2,
      -hh + pad + 1 + hrH,
      topLeft: Radius.circular(radius * 1.2),
      topRight: Radius.circular(radius * 1.2),
      bottomLeft: Radius.circular(radius * 0.4),
      bottomRight: Radius.circular(radius * 0.4),
    );
    final hrPaint = Paint()
      ..color = dark.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(hrRect, hrPaint);

    // Headrest highlight line
    final hlPaint = Paint()
      ..color = light.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawLine(
      Offset(-hrW / 2 + 3, -hh + pad + 3),
      Offset(hrW / 2 - 3, -hh + pad + 3),
      hlPaint,
    );

    // ── Armrests (small side bars) ──
    final armW = bw * 0.1;
    final armH = bh * 0.35;
    final armY = -hh + pad + hrH + 5;
    final armPaint = Paint()
      ..color = dark.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    // Left armrest
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        -hw + pad - armW + 1,
        armY,
        -hw + pad + 1,
        armY + armH,
        topRight: const Radius.circular(2),
        bottomRight: const Radius.circular(2),
      ),
      armPaint,
    );
    // Right armrest
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        hw - pad - 1,
        armY,
        hw - pad + armW - 1,
        armY + armH,
        topLeft: const Radius.circular(2),
        bottomLeft: const Radius.circular(2),
      ),
      armPaint,
    );

    // ── Seat crease line (bottom) ──
    final creasePaint = Paint()
      ..color = dark.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawLine(
      Offset(-bw * 0.35, hh - pad - bh * 0.18),
      Offset(bw * 0.35, hh - pad - bh * 0.18),
      creasePaint,
    );

    // ── Selection glow ──
    if (seat.availability == SeatAvailability.selected) {
      final glow = Paint()
        ..color = _colorSelected.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawRRect(seatBody, glow);
    }

    // ── Booked indicator ──
    if (seat.availability == SeatAvailability.booked) {
      final crossPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawLine(
        Offset(-bw * 0.25, -bh * 0.25),
        Offset(bw * 0.25, bh * 0.25),
        crossPaint,
      );
      canvas.drawLine(
        Offset(-bw * 0.25, bh * 0.25),
        Offset(bw * 0.25, -bh * 0.25),
        crossPaint,
      );
    }

    // ── Seat label ──
    if (seat.displayLabel.isNotEmpty) {
      final isLight = _isLight(base);
      final label = seat.displayLabel;
      double fs;
      if (label.length <= 2) {
        fs = bw * 0.32;
      } else {
        fs = bw * 0.25;
      }
      fs = fs.clamp(7.0, 12.0);

      final tp = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      tp.text = TextSpan(
        text: label,
        style: TextStyle(
          fontSize: fs,
          fontWeight: FontWeight.w700,
          color: isLight ? Colors.black87 : Colors.white,
          height: 1.0,
        ),
      );
      tp.layout(maxWidth: bw);
      tp.paint(canvas, Offset(-tp.width / 2, hh - pad - tp.height - 3));
    }

    canvas.restore();
  }

  // ═══════════════════════════════════════════════════════════
  // COLOR HELPERS
  // ═══════════════════════════════════════════════════════════

  (Color base, Color dark, Color light) _seatColors(PassengerSeatModel seat) {
    if (seat.isStructural) {
      return (_colorBooked, _colorBookedDark, const Color(0xFFD1D5DB));
    }
    switch (seat.availability) {
      case SeatAvailability.selected:
        return (_colorSelected, _colorSelectedDark, const Color(0xFF34D399));
      case SeatAvailability.booked:
      case SeatAvailability.held:
        return (_colorBooked, _colorBookedDark, const Color(0xFFD1D5DB));
      case SeatAvailability.available:
      default:
        switch (seat.category) {
          case PassengerSeatCategory.businessClass:
            return (
              _colorBusiness,
              _colorBusinessDark,
              const Color(0xFFA78BFA),
            );
          case PassengerSeatCategory.sleeper:
            return (_colorSleeper, _colorSleeperDark, const Color(0xFFFBBF24));
          default:
            return (_colorAvailable, _colorAvailableDark, _colorAvailableLight);
        }
    }
  }

  bool _isLight(Color c) {
    final lum = (0.299 * c.r + 0.587 * c.g + 0.114 * c.b) * 255;
    return lum > 140;
  }
}

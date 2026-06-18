// NEXATRACE — PASSENGER SEAT PAINTER v3.1
// =========================================
// Clean bus-cabin canvas. Only the outer shell is drawn as
// background. Every seat, door, driver cabin, and structural
// component is rendered dynamically from the database.
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

  // ── Palette ──
  static const _colorAvailable   = Color(0xFF2563EB);
  static const _colorAvailableDk = Color(0xFF1D4ED8);
  static const _colorAvailableLt = Color(0xFF60A5FA);
  static const _colorSelected    = Color(0xFF059669);
  static const _colorSelectedDk  = Color(0xFF047857);
  static const _colorBooked      = Color(0xFF9CA3AF);
  static const _colorBookedDk    = Color(0xFF6B7280);
  static const _colorBusiness    = Color(0xFF7C3AED);
  static const _colorBusinessDk  = Color(0xFF6D28D9);
  static const _colorSleeper     = Color(0xFFD97706);
  static const _colorSleeperDk   = Color(0xFFB45309);
  static const _colorFloor       = Color(0xFFF8FAFC);
  static const _colorWall        = Color(0xFFCBD5E1);

  PassengerSeatPainter({
    required this.seats,
    required this.canvasWidth,
    required this.canvasHeight,
    this.selectedSeat,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width / canvasWidth, size.height / canvasHeight);
    final ox = (size.width  - canvasWidth  * s) / 2;
    final oy = (size.height - canvasHeight * s) / 2;

    canvas.save();
    canvas.translate(ox, oy);
    canvas.scale(s, s);

    // ── 1. Outer shell (NO hardcoded doors or icons) ──
    _drawShell(canvas);

    // ── 2. Structural components (from DB) ──
    for (final seat in seats) {
      if (seat.isStructural) _drawStructural(canvas, seat);
    }

    // ── 3. Bookable seats (sorted back→front) ──
    final bookable = seats.where((s) => !s.isStructural).toList()
      ..sort((a, b) => a.y.compareTo(b.y));
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
  // SHELL — outer walls + windshield only, no hardcoded parts
  // ═══════════════════════════════════════════════════════════

  void _drawShell(Canvas canvas) {
    // Floor
    final body = RRect.fromLTRBAndCorners(
      0, 0, canvasWidth, canvasHeight,
      topLeft: const Radius.circular(12),
      topRight: const Radius.circular(12),
      bottomLeft: const Radius.circular(5),
      bottomRight: const Radius.circular(5),
    );
    canvas.drawRRect(body, Paint()..color = _colorFloor);

    // Wall stroke
    canvas.drawRRect(body, Paint()
      ..color = _colorWall
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5);

    // ── Windshield accent (top center) ──
    final ww = canvasWidth * 0.50;
    final wh = 26.0;
    final wx = (canvasWidth - ww) / 2;
    final wy = 5.0;
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(wx, wy, wx + ww, wy + wh,
        topLeft: const Radius.circular(8), topRight: const Radius.circular(8)),
      Paint()..color = const Color(0xFFDBEAFE),
    );
    final tp = TextPainter(textDirection: TextDirection.ltr, textAlign: TextAlign.center)
      ..text = TextSpan(text: 'FRONT', style: TextStyle(fontSize: 9, color: _colorWall.withValues(alpha: 0.6), fontWeight: FontWeight.w600, letterSpacing: 2))
      ..layout(maxWidth: ww);
    tp.paint(canvas, Offset(wx + (ww - tp.width) / 2, wy + 8));

    // Side wall lines
    final wallLine = Paint()..color = _colorWall.withValues(alpha: 0.25);
    canvas.drawRect(Rect.fromLTWH(0, 0, 2.5, canvasHeight), wallLine);
    canvas.drawRect(Rect.fromLTWH(canvasWidth - 2.5, 0, 2.5, canvasHeight), wallLine);

    // Subtle floor lines
    final floorLine = Paint()..color = const Color(0xFFE2E8F0);
    for (double y = 60; y < canvasHeight; y += 28) {
      canvas.drawRect(Rect.fromLTWH(8, y, canvasWidth - 16, 0.5), floorLine);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // STRUCTURAL — rendered dynamically from database
  // ═══════════════════════════════════════════════════════════

  void _drawStructural(Canvas canvas, PassengerSeatModel el) {
    final String icon;
    final Color bg;
    final String label;
    switch (el.category) {
      case PassengerSeatCategory.driverCabin:
        icon = '🚌'; bg = const Color(0xFF374151).withValues(alpha: 0.10); label = 'DRIVER';
        break;
      default:
        if ((el.seatLabel ?? '').toLowerCase() == 'aisle') {
          icon = ''; bg = const Color(0xFFF1F5F9); label = 'AISLE';
        } else {
          icon = ''; bg = const Color(0xFFF1F5F9); label = '';
        }
    }

    // Background zone
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(el.x, el.y, el.x + el.width, el.y + el.height,
        topLeft: const Radius.circular(4), topRight: const Radius.circular(4),
        bottomLeft: const Radius.circular(2), bottomRight: const Radius.circular(2)),
      Paint()..color = bg,
    );

    // Icon + label
    if (icon.isNotEmpty || label.isNotEmpty) {
      final tp = TextPainter(textDirection: TextDirection.ltr, textAlign: TextAlign.center);
      final buffer = StringBuffer();
      if (icon.isNotEmpty) buffer.write('$icon\n');
      if (label.isNotEmpty) buffer.write(label);
      tp.text = TextSpan(text: buffer.toString(), style: TextStyle(
        fontSize: 8, fontWeight: FontWeight.w500,
        color: const Color(0xFF64748B).withValues(alpha: 0.7), height: 1.3));
      tp.layout(maxWidth: el.width);
      tp.paint(canvas, Offset(el.centerX - tp.width / 2, el.centerY - tp.height / 2));
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 3D-STYLED SEAT
  // ═══════════════════════════════════════════════════════════

  void _draw3DSeat(Canvas canvas, PassengerSeatModel seat) {
    canvas.save();
    canvas.translate(seat.centerX, seat.centerY);
    if (seat.rotation != 0) canvas.rotate(seat.rotation * math.pi / 180);

    const vs = 0.70; // visual scale
    final w = seat.width * vs, h = seat.height * vs;
    final hw = w / 2, hh = h / 2;
    final (base, dark, light) = _seatColors(seat);

    const pad = 1.5;
    final bw = w - pad * 2, bh = h - pad * 2;
    final r = math.min(bw, bh) * 0.18;

    // Shadow
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(-hw + pad + 1, -hh + pad + 1.5, hw - pad + 1, hh - pad + 1.5,
        topLeft: Radius.circular(r), topRight: Radius.circular(r),
        bottomLeft: Radius.circular(r * 0.5), bottomRight: Radius.circular(r * 0.5)),
      Paint()..color = Colors.black.withValues(alpha: 0.08)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );

    // Body
    final body = RRect.fromLTRBAndCorners(-hw + pad, -hh + pad, hw - pad, hh - pad,
      topLeft: Radius.circular(r), topRight: Radius.circular(r),
      bottomLeft: Radius.circular(r * 0.5), bottomRight: Radius.circular(r * 0.5));
    final grad = LinearGradient(colors: [light, base, dark], stops: const [0.0, 0.45, 1.0]);
    canvas.drawRRect(body, Paint()..shader = grad.createShader(Rect.fromCenter(center: Offset.zero, width: bw, height: bh)));
    canvas.drawRRect(body, Paint()..color = dark..style = PaintingStyle.stroke..strokeWidth = 0.8);

    // Headrest
    final hrH = bh * 0.25, hrW = bw - 4;
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(-hrW / 2, -hh + pad + 1, hrW / 2, -hh + pad + 1 + hrH,
        topLeft: Radius.circular(r * 1.2), topRight: Radius.circular(r * 1.2),
        bottomLeft: Radius.circular(r * 0.4), bottomRight: Radius.circular(r * 0.4)),
      Paint()..color = dark.withValues(alpha: 0.35),
    );
    canvas.drawLine(Offset(-hrW / 2 + 3, -hh + pad + 3), Offset(hrW / 2 - 3, -hh + pad + 3),
      Paint()..color = light.withValues(alpha: 0.4)..strokeWidth = 0.5);

    // Armrests
    final armW = bw * 0.1, armH = bh * 0.35, armY = -hh + pad + hrH + 5;
    final armPaint = Paint()..color = dark.withValues(alpha: 0.4);
    canvas.drawRRect(RRect.fromLTRBAndCorners(-hw + pad - armW + 1, armY, -hw + pad + 1, armY + armH, topRight: const Radius.circular(2), bottomRight: const Radius.circular(2)), armPaint);
    canvas.drawRRect(RRect.fromLTRBAndCorners(hw - pad - 1, armY, hw - pad + armW - 1, armY + armH, topLeft: const Radius.circular(2), bottomLeft: const Radius.circular(2)), armPaint);

    // Crease
    canvas.drawLine(Offset(-bw * 0.35, hh - pad - bh * 0.18), Offset(bw * 0.35, hh - pad - bh * 0.18),
      Paint()..color = dark.withValues(alpha: 0.25)..strokeWidth = 0.5);

    // Selected glow
    if (seat.availability == SeatAvailability.selected) {
      canvas.drawRRect(body, Paint()
        ..color = _colorSelected.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke..strokeWidth = 2.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    }

    // Booked X
    if (seat.availability == SeatAvailability.booked) {
      final xp = Paint()..color = Colors.white.withValues(alpha: 0.5)..strokeWidth = 1;
      canvas.drawLine(Offset(-bw * 0.25, -bh * 0.25), Offset(bw * 0.25, bh * 0.25), xp);
      canvas.drawLine(Offset(-bw * 0.25,  bh * 0.25), Offset(bw * 0.25, -bh * 0.25), xp);
    }

    // Label
    if (seat.displayLabel.isNotEmpty) {
      final label = seat.displayLabel;
      double fs = (label.length <= 2) ? bw * 0.32 : bw * 0.25;
      fs = fs.clamp(7.0, 12.0);
      final tp = TextPainter(textDirection: TextDirection.ltr, textAlign: TextAlign.center)
        ..text = TextSpan(text: label, style: TextStyle(fontSize: fs, fontWeight: FontWeight.w700, color: _isLight(base) ? Colors.black87 : Colors.white, height: 1.0))
        ..layout(maxWidth: bw);
      tp.paint(canvas, Offset(-tp.width / 2, hh - pad - tp.height - 3));
    }

    canvas.restore();
  }

  // ═══════════════════════════════════════════════════════════
  // COLORS
  // ═══════════════════════════════════════════════════════════

  (Color, Color, Color) _seatColors(PassengerSeatModel s) {
    switch (s.availability) {
      case SeatAvailability.selected:
        return (_colorSelected, _colorSelectedDk, const Color(0xFF34D399));
      case SeatAvailability.booked:
      case SeatAvailability.held:
        return (_colorBooked, _colorBookedDk, const Color(0xFFD1D5DB));
      default:
        switch (s.category) {
          case PassengerSeatCategory.businessClass:
            return (_colorBusiness, _colorBusinessDk, const Color(0xFFA78BFA));
          case PassengerSeatCategory.sleeper:
            return (_colorSleeper, _colorSleeperDk, const Color(0xFFFBBF24));
          default:
            return (_colorAvailable, _colorAvailableDk, _colorAvailableLt);
        }
    }
  }

  bool _isLight(Color c) => (0.299 * c.r + 0.587 * c.g + 0.114 * c.b) * 255 > 140;
}

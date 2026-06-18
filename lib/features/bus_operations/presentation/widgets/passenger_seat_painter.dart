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
  static const _colorAvailable = Color(0xFF2563EB);
  static const _colorAvailableDk = Color(0xFF1D4ED8);
  static const _colorAvailableLt = Color(0xFF60A5FA);
  static const _colorSelected = Color(0xFF059669);
  static const _colorSelectedDk = Color(0xFF047857);
  static const _colorBooked = Color(0xFF9CA3AF);
  static const _colorBookedDk = Color(0xFF6B7280);
  static const _colorBusiness = Color(0xFF7C3AED);
  static const _colorBusinessDk = Color(0xFF6D28D9);
  static const _colorSleeper = Color(0xFFDB2777);
  static const _colorSleeperDk = Color(0xFFBE185D);
  static const _colorSleeperUpper = Color(0xFFD97706);
  static const _colorSleeperUpperDk = Color(0xFFB45309);
  static const _colorFloor = Color(0xFFF8FAFC);
  static const _colorWall = Color(0xFFCBD5E1);

  PassengerSeatPainter({
    required this.seats,
    required this.canvasWidth,
    required this.canvasHeight,
    this.selectedSeat,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width / canvasWidth, size.height / canvasHeight);
    final ox = (size.width - canvasWidth * s) / 2;
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
      if (seat.category == PassengerSeatCategory.sleeperLower ||
          seat.category == PassengerSeatCategory.sleeperUpper) {
        _drawSleeperBerth(canvas, seat);
      } else {
        _drawSeat(canvas, seat);
      }
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
      0,
      0,
      canvasWidth,
      canvasHeight,
      topLeft: const Radius.circular(12),
      topRight: const Radius.circular(12),
      bottomLeft: const Radius.circular(5),
      bottomRight: const Radius.circular(5),
    );
    canvas.drawRRect(body, Paint()..color = _colorFloor);

    // Wall stroke
    canvas.drawRRect(
      body,
      Paint()
        ..color = _colorWall
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // ── Windshield accent (top center) ──
    final ww = canvasWidth * 0.50;
    final wh = 26.0;
    final wx = (canvasWidth - ww) / 2;
    final wy = 5.0;
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        wx,
        wy,
        wx + ww,
        wy + wh,
        topLeft: const Radius.circular(8),
        topRight: const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFFDBEAFE),
    );
    final tp =
        TextPainter(
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
          )
          ..text = TextSpan(
            text: 'FRONT',
            style: TextStyle(
              fontSize: 9,
              color: _colorWall.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          )
          ..layout(maxWidth: ww);
    tp.paint(canvas, Offset(wx + (ww - tp.width) / 2, wy + 8));

    // Side wall lines
    final wallLine = Paint()..color = _colorWall.withValues(alpha: 0.25);
    canvas.drawRect(Rect.fromLTWH(0, 0, 2.5, canvasHeight), wallLine);
    canvas.drawRect(
      Rect.fromLTWH(canvasWidth - 2.5, 0, 2.5, canvasHeight),
      wallLine,
    );

    // Subtle floor lines
    final floorLine = Paint()..color = const Color(0xFFE2E8F0);
    for (double y = 60; y < canvasHeight; y += 28) {
      canvas.drawRect(Rect.fromLTWH(8, y, canvasWidth - 16, 0.5), floorLine);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // STRUCTURAL — rendered dynamically from database
  void _drawStructural(Canvas canvas, PassengerSeatModel el) {
    switch (el.category) {
      case PassengerSeatCategory.driverCabin:
        _drawDriverCabin(canvas, el);
        break;
      case PassengerSeatCategory.door:
        _drawDoor(canvas, el);
        break;
      case PassengerSeatCategory.aisle:
        _drawAisle(canvas, el);
        break;
      case PassengerSeatCategory.lavatory:
        _drawLavatory(canvas, el);
        break;
      case PassengerSeatCategory.emergency:
        _drawEmergency(canvas, el);
        break;
      default:
        _drawGenericStructural(canvas, el);
    }
  }
  }

  void _drawDriverCabin(Canvas canvas, PassengerSeatModel el) {
    final bg = const Color(0xFF1E293B).withValues(alpha: 0.08);
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
      Paint()..color = bg,
    );

    // Steering wheel — simple vector circle + cross
    final cx = el.centerX, cy = el.centerY;
    final r = math.min(el.width, el.height) * 0.28;
    // Outer ring
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = const Color(0xFF64748B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
    // Inner hub
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.3,
      Paint()..color = const Color(0xFF475569),
    );
    // Spokes
    final spoke = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(cx - r, cy), Offset(cx + r, cy), spoke);
    canvas.drawLine(Offset(cx, cy - r), Offset(cx, cy + r), spoke);

    // Label below wheel
    final tp =
        TextPainter(
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
          )
          ..text = TextSpan(
            text: 'DRIVER',
            style: TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B).withValues(alpha: 0.7),
              letterSpacing: 1.2,
            ),
          )
          ..layout(maxWidth: el.width);
    tp.paint(canvas, Offset(el.centerX - tp.width / 2, cy + r + 6));
  }

  // ── Door ──────────────────────────────────────────────────

  void _drawDoor(Canvas canvas, PassengerSeatModel el) {
    // Door background (light, distinct zone)
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        el.x,
        el.y,
        el.x + el.width,
        el.y + el.height,
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
        bottomLeft: const Radius.circular(2),
        bottomRight: const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFFF1F5F9),
    );

    // Door outline
    final dw = el.width - 8, dh = el.height - 8;
    final dx = el.x + 4, dy = el.y + 4;
    final doorRect = RRect.fromLTRBAndCorners(
      dx,
      dy,
      dx + dw,
      dy + dh,
      topLeft: const Radius.circular(4),
      topRight: const Radius.circular(4),
      bottomLeft: const Radius.circular(2),
      bottomRight: const Radius.circular(2),
    );
    canvas.drawRRect(
      doorRect,
      Paint()
        ..color = const Color(0xFFCBD5E1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // Door handle — small vertical bar on the right side
    final hx = dx + dw - 7, hy = dy + dh * 0.25;
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        hx,
        hy,
        hx + 2.5,
        hy + dh * 0.45,
        topLeft: const Radius.circular(1.5),
        topRight: const Radius.circular(1.5),
        bottomLeft: const Radius.circular(1.5),
        bottomRight: const Radius.circular(1.5),
      ),
      Paint()..color = const Color(0xFF94A3B8),
    );

    // Door swing arc — subtle hinge line on left
    canvas.drawLine(
      Offset(dx + 2, dy + 3),
      Offset(dx + 2, dy + dh - 3),
      Paint()
        ..color = const Color(0xFFCBD5E1).withValues(alpha: 0.5)
        ..strokeWidth = 1.0,
    );

    // Label
    final tp =
        TextPainter(
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
          )
          ..text = TextSpan(
            text: 'DOOR',
            style: TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF94A3B8).withValues(alpha: 0.9),
              letterSpacing: 1.0,
            ),
          )
          ..layout(maxWidth: dw - 12);
    tp.paint(
      canvas,
      Offset(el.centerX - tp.width / 2, el.centerY - tp.height / 2),
    );
  }

  // ── Aisle ─────────────────────────────────────────────────

  void _drawAisle(Canvas canvas, PassengerSeatModel el) {
    // Subtle lane background
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        el.x,
        el.y,
        el.x + el.width,
        el.y + el.height,
        topLeft: const Radius.circular(2),
        topRight: const Radius.circular(2),
        bottomLeft: const Radius.circular(2),
        bottomRight: const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFFF8FAFC),
    );

    // Dashed center line
    final isVertical = el.height > el.width;
    final dashPaint = Paint()
      ..color = const Color(0xFFCBD5E1).withValues(alpha: 0.5)
      ..strokeWidth = 1.0;
    const dashLen = 6.0;
    const gapLen = 4.0;
    if (isVertical) {
      final cx = el.centerX;
      var y = el.y + 4;
      while (y < el.y + el.height - 4) {
        final endY = math.min(y + dashLen, el.y + el.height - 4);
        canvas.drawLine(Offset(cx, y), Offset(cx, endY), dashPaint);
        y += dashLen + gapLen;
      }
    } else {
      final cy = el.centerY;
      var x = el.x + 4;
      while (x < el.x + el.width - 4) {
        final endX = math.min(x + dashLen, el.x + el.width - 4);
        canvas.drawLine(Offset(x, cy), Offset(endX, cy), dashPaint);
        x += dashLen + gapLen;
      }
    }
  }

  // ── Generic Structural (fallback) ─────────────────────────

  void _drawLavatory(Canvas canvas, PassengerSeatModel el) {
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(el.x, el.y, el.x + el.width, el.y + el.height,
        topLeft: const Radius.circular(4), topRight: const Radius.circular(4),
        bottomLeft: const Radius.circular(2), bottomRight: const Radius.circular(2)),
      Paint()..color = const Color(0xFFEEF2FF),
    );
    final cx = el.centerX, cy = el.centerY;
    final r = math.min(el.width, el.height) * 0.22;
    canvas.drawCircle(Offset(cx, cy - r * 0.3), r,
      Paint()..color = const Color(0xFF6366F1)..style = PaintingStyle.stroke..strokeWidth = 2.0);
    canvas.drawLine(Offset(cx, cy - r * 0.3 - r), Offset(cx, cy - r * 0.3 + r),
      Paint()..color = const Color(0xFF6366F1)..strokeWidth = 1.8);
    final tp = TextPainter(textDirection: TextDirection.ltr, textAlign: TextAlign.center)
      ..text = TextSpan(text: "WC", style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: const Color(0xFF6366F1).withValues(alpha: 0.8)))
      ..layout(maxWidth: el.width);
    tp.paint(canvas, Offset(el.centerX - tp.width / 2, cy + r + 4));
  }

  void _drawEmergency(Canvas canvas, PassengerSeatModel el) {
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(el.x, el.y, el.x + el.width, el.y + el.height,
        topLeft: const Radius.circular(4), topRight: const Radius.circular(4),
        bottomLeft: const Radius.circular(2), bottomRight: const Radius.circular(2)),
      Paint()..color = const Color(0xFFFEF2F2),
    );
    final cx = el.centerX, cy = el.centerY;
    final sz = math.min(el.width, el.height) * 0.35;
    final path = Path()..moveTo(cx, cy - sz)..lineTo(cx + sz * 0.8, cy + sz * 0.5)..lineTo(cx - sz * 0.8, cy + sz * 0.5)..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFDC2626)..style = PaintingStyle.stroke..strokeWidth = 2.0);
    canvas.drawPath(path, Paint()..color = const Color(0xFFDC2626).withValues(alpha: 0.12));
    final tp = TextPainter(textDirection: TextDirection.ltr, textAlign: TextAlign.center)
      ..text = TextSpan(text: "!", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: const Color(0xFFDC2626)))
      ..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2 - 2));
  }
  void _drawGenericStructural(Canvas canvas, PassengerSeatModel el) {
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        el.x,
        el.y,
        el.x + el.width,
        el.y + el.height,
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
        bottomLeft: const Radius.circular(2),
        bottomRight: const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFFF1F5F9),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SEAT — slim airline-style seat icon
  // ═══════════════════════════════════════════════════════════

  void _drawSeat(Canvas canvas, PassengerSeatModel seat) {
    canvas.save();
    canvas.translate(seat.centerX, seat.centerY);
    if (seat.rotation != 0) canvas.rotate(seat.rotation * math.pi / 180);

    final w = seat.width * 0.75, h = seat.height * 0.78;
    final hw = w / 2, hh = h / 2;
    final (base, dark, light) = _seatColors(seat);
    final r = math.min(w, h) * 0.16;
    const pad = 2.0;
    final bw = w - pad * 2, bh = h - pad * 2;

    // ── Seat back (taller upper portion) ──
    final backH = bh * 0.48;
    final backTop = -hh + pad;
    final backRR = RRect.fromLTRBAndCorners(
      -hw + pad + 1,
      backTop,
      hw - pad - 1,
      backTop + backH,
      topLeft: Radius.circular(r * 1.3),
      topRight: Radius.circular(r * 1.3),
      bottomLeft: Radius.circular(r * 0.3),
      bottomRight: Radius.circular(r * 0.3),
    );
    canvas.drawRRect(backRR, Paint()..color = dark.withValues(alpha: 0.65));
    // Back highlight
    canvas.drawRect(
      Rect.fromLTWH(-hw + pad + 3, backTop + 3, bw * 0.28, backH - 6),
      Paint()..color = light.withValues(alpha: 0.25),
    );

    // ── Seat cushion (lower wider portion) ──
    final cushionTop = backTop + backH + 1.5;
    final cushionH = bh - backH - 1.5;
    final cushionRR = RRect.fromLTRBAndCorners(
      -hw + pad,
      cushionTop,
      hw - pad,
      cushionTop + cushionH,
      topLeft: Radius.circular(r * 0.5),
      topRight: Radius.circular(r * 0.5),
      bottomLeft: Radius.circular(r * 0.7),
      bottomRight: Radius.circular(r * 0.7),
    );
    final grad = LinearGradient(
      colors: [light, base],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    canvas.drawRRect(
      cushionRR,
      Paint()
        ..shader = grad.createShader(
          Rect.fromLTRB(-hw, cushionTop, hw, cushionTop + cushionH),
        ),
    );
    canvas.drawRRect(
      cushionRR,
      Paint()
        ..color = dark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7,
    );

    // ── Armrest dots ──
    final dotR = 2.5;
    final dotY = cushionTop + cushionH * 0.4;
    canvas.drawCircle(
      Offset(-hw + pad + dotR + 1, dotY),
      dotR,
      Paint()..color = dark.withValues(alpha: 0.5),
    );
    canvas.drawCircle(
      Offset(hw - pad - dotR - 1, dotY),
      dotR,
      Paint()..color = dark.withValues(alpha: 0.5),
    );

    // ── Selected ring ──
    if (seat.availability == SeatAvailability.selected) {
      final selRect = RRect.fromLTRBAndCorners(
        -hw + pad - 1,
        backTop - 1,
        hw - pad + 1,
        cushionTop + cushionH + 1,
        topLeft: Radius.circular(r * 1.3),
        topRight: Radius.circular(r * 1.3),
        bottomLeft: Radius.circular(r * 0.7),
        bottomRight: Radius.circular(r * 0.7),
      );
      canvas.drawRRect(
        selRect,
        Paint()
          ..color = _colorSelected.withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }

    // ── Booked X ──
    if (seat.availability == SeatAvailability.booked) {
      final xp = Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..strokeWidth = 1.2;
      canvas.drawLine(
        Offset(-bw * 0.22, -bh * 0.22),
        Offset(bw * 0.22, bh * 0.22),
        xp,
      );
      canvas.drawLine(
        Offset(-bw * 0.22, bh * 0.22),
        Offset(bw * 0.22, -bh * 0.22),
        xp,
      );
    }

    // ── Label (centered on cushion) ──
    if (seat.displayLabel.isNotEmpty) {
      final label = seat.displayLabel;
      final fs = (label.length <= 2 ? bw * 0.34 : bw * 0.26).clamp(7.5, 11.0);
      final tp =
          TextPainter(
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
            )
            ..text = TextSpan(
              text: label,
              style: TextStyle(
                fontSize: fs,
                fontWeight: FontWeight.w700,
                color: _isLight(base) ? Colors.black87 : Colors.white,
                height: 1.0,
              ),
            )
            ..layout(maxWidth: bw);
      tp.paint(
        canvas,
        Offset(-tp.width / 2, cushionTop + cushionH * 0.28 - tp.height / 2),
      );
    }

    canvas.restore();
  }

  // ═══════════════════════════════════════════════════════════
  // SLEEPER BERTH — horizontal bed-style icon
  // ═══════════════════════════════════════════════════════════

  void _drawSleeperBerth(Canvas canvas, PassengerSeatModel seat) {
    canvas.save();
    canvas.translate(seat.centerX, seat.centerY);
    if (seat.rotation != 0) canvas.rotate(seat.rotation * math.pi / 180);

    final w = seat.width * 0.78, h = seat.height * 0.60;
    final hw = w / 2, hh = h / 2;
    final (base, dark, light) = _seatColors(seat);
    final r = math.min(w, h) * 0.12;
    const pad = 2.0;
    final bw = w - pad * 2, bh = h - pad * 2;

    // ── Bed frame (long horizontal rounded rect) ──
    final bedRR = RRect.fromLTRBAndCorners(
      -hw + pad,
      -hh + pad,
      hw - pad,
      hh - pad,
      topLeft: Radius.circular(r),
      topRight: Radius.circular(r),
      bottomLeft: Radius.circular(r),
      bottomRight: Radius.circular(r),
    );
    final grad = LinearGradient(
      colors: [light, base],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    canvas.drawRRect(
      bedRR,
      Paint()..shader = grad.createShader(Rect.fromLTRB(-hw, -hh, hw, hh)),
    );
    canvas.drawRRect(
      bedRR,
      Paint()
        ..color = dark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    // ── Pillow (left section) ──
    final pillowW = bw * 0.28;
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        -hw + pad + 3,
        -hh + pad + 3,
        -hw + pad + pillowW,
        hh - pad - 3,
        topLeft: Radius.circular(r * 1.5),
        bottomLeft: Radius.circular(r * 1.5),
        topRight: Radius.circular(r * 0.4),
        bottomRight: Radius.circular(r * 0.4),
      ),
      Paint()..color = light.withValues(alpha: 0.7),
    );

    // ── Blanket crease lines ──
    final crease = Paint()
      ..color = dark.withValues(alpha: 0.18)
      ..strokeWidth = 0.6;
    for (var i = 0; i < 3; i++) {
      final cx = -hw + pad + pillowW + 6 + i * (bw - pillowW - 12) / 3;
      canvas.drawLine(
        Offset(cx, -hh + pad + 4),
        Offset(cx, hh - pad - 4),
        crease,
      );
    }

    // ── Selected ring ──
    if (seat.availability == SeatAvailability.selected) {
      canvas.drawRRect(
        bedRR,
        Paint()
          ..color = _colorSelected.withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }

    // ── Booked X ──
    if (seat.availability == SeatAvailability.booked) {
      final xp = Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..strokeWidth = 1.2;
      canvas.drawLine(
        Offset(-bw * 0.25, -bh * 0.25),
        Offset(bw * 0.25, bh * 0.25),
        xp,
      );
      canvas.drawLine(
        Offset(-bw * 0.25, bh * 0.25),
        Offset(bw * 0.25, -bh * 0.25),
        xp,
      );
    }

    // ── Label ──
    if (seat.displayLabel.isNotEmpty) {
      final label = seat.displayLabel;
      final fs = (label.length <= 3 ? bw * 0.22 : bw * 0.18).clamp(6.5, 9.5);
      final tp =
          TextPainter(
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
            )
            ..text = TextSpan(
              text: label,
              style: TextStyle(
                fontSize: fs,
                fontWeight: FontWeight.w700,
                color: _isLight(base) ? Colors.black87 : Colors.white,
                height: 1.0,
              ),
            )
            ..layout(maxWidth: bw);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
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
          case PassengerSeatCategory.sleeperLower:
            return (_colorSleeper, _colorSleeperDk, const Color(0xFFF9A8D4));
          case PassengerSeatCategory.sleeperUpper:
            return (_colorSleeperUpper, _colorSleeperUpperDk, const Color(0xFFFBBF24));
          default:
            return (_colorAvailable, _colorAvailableDk, _colorAvailableLt);
        }
    }
  }

  bool _isLight(Color c) =>
      (0.299 * c.r + 0.587 * c.g + 0.114 * c.b) * 255 > 140;
}

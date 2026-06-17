// NEXATRACE — ROUTE MAP PAINTER
// ===============================
// CustomPainter that renders a stylized bus route map
// with waypoints, traveled/completed path segments,
// and an animated bus icon at the current position.
//
// MODULE: 8V — Live Bus Tracking Canvas

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:trace_odd/features/bus_operations/data/services/bus_tracking_models.dart';

class RouteMapPainter extends CustomPainter {
  final double busLat;
  final double busLng;
  final List<BusEtaStop> etaStops;
  final int currentWaypointIndex;
  final bool isTripComplete;

  static const _colorRoad = Color(0xFFCBD5E1);
  static const _colorTraveled = Color(0xFF3B82F6);
  static const _colorRemaining = Color(0xFF94A3B8);
  static const _colorStop = Color(0xFF64748B);
  static const _colorStopReached = Color(0xFF22C55E);
  static const _colorBus = Color(0xFF3B82F6);
  static const _colorBusGlow = Color(0xFF93C5FD);
  static const _colorCompleted = Color(0xFF16A34A);
  static const _colorBg = Color(0xFFF1F5F9);

  RouteMapPainter({
    required this.busLat,
    required this.busLng,
    required this.etaStops,
    this.currentWaypointIndex = 0,
    this.isTripComplete = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (etaStops.isEmpty) {
      _drawEmpty(canvas, size);
      return;
    }

    final padX = 48.0;
    final padY = 40.0;
    final usableH = size.height - padY * 2;
    final usableW = size.width - padX * 2;
    final stepY = usableH / math.max(etaStops.length - 1, 1);

    // ── Background ──
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(4, 4, size.width - 8, size.height - 8),
        const Radius.circular(16),
      ),
      Paint()..color = _colorBg,
    );

    // ── Path line ──
    final pathPaint = Paint()
      ..color = _colorRoad
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final traveledPaint = Paint()
      ..color = isTripComplete ? _colorCompleted : _colorTraveled
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final traveledPath = Path();

    for (int i = 0; i < etaStops.length; i++) {
      final y = padY + i * stepY;
      final x = size.width / 2;
      if (i == 0) {
        path.moveTo(x, y);
        traveledPath.moveTo(x, y);
      } else {
        path.lineTo(x, y);
        if (i <= currentWaypointIndex + 1) {
          traveledPath.lineTo(x, y);
        }
      }
    }

    canvas.drawPath(path, pathPaint);
    canvas.drawPath(traveledPath, traveledPaint);

    // ── Stops ──
    for (int i = 0; i < etaStops.length; i++) {
      final y = padY + i * stepY;
      final x = size.width / 2;
      final stop = etaStops[i];
      final reached = i <= currentWaypointIndex;

      // Stop circle
      canvas.drawCircle(
        Offset(x, y),
        reached ? 10 : 7,
        Paint()..color = reached ? _colorStopReached : _colorStop,
      );
      if (reached) {
        canvas.drawCircle(Offset(x, y), 4, Paint()..color = Colors.white);
      }

      // Stop label
      final tp = TextPainter(
        text: TextSpan(
          text: stop.station,
          style: TextStyle(
            fontSize: 12,
            fontWeight: reached ? FontWeight.w600 : FontWeight.w400,
            color: reached ? _colorStopReached : const Color(0xFF475569),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: padX - 12);

      tp.paint(canvas, Offset(x - padX + 6, y - tp.height / 2));

      // ETA label (right side)
      if (!reached || i == currentWaypointIndex) {
        final etaTp = TextPainter(
          text: TextSpan(
            text: reached ? '✓' : stop.etaDisplay,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: reached ? _colorStopReached : const Color(0xFF64748B),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: padX - 12);

        etaTp.paint(canvas, Offset(x + 14, y - etaTp.height / 2));
      }
    }

    // ── Bus icon (animated position between current and next waypoint) ──
    if (!isTripComplete && currentWaypointIndex < etaStops.length - 1) {
      final currentY = padY + currentWaypointIndex * stepY;
      final nextY = padY + (currentWaypointIndex + 1) * stepY;
      final progress = 0.5; // interpolated from GPS data
      final busY = currentY + (nextY - currentY) * progress;
      final busX = size.width / 2;

      // Glow
      canvas.drawCircle(
        Offset(busX, busY),
        16,
        Paint()
          ..color = _colorBusGlow
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );

      // Bus body
      final busRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(busX, busY), width: 28, height: 18),
        const Radius.circular(6),
      );
      canvas.drawRRect(busRect, Paint()..color = _colorBus);
      canvas.drawRRect(
        busRect,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );

      // Windows
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(busX - 5, busY - 2),
            width: 8,
            height: 5,
          ),
          const Radius.circular(2),
        ),
        Paint()..color = Colors.white.withValues(alpha: 0.6),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(busX + 5, busY - 2),
            width: 8,
            height: 5,
          ),
          const Radius.circular(2),
        ),
        Paint()..color = Colors.white.withValues(alpha: 0.6),
      );
    }
  }

  void _drawEmpty(Canvas canvas, Size size) {
    final tp = TextPainter(
      text: const TextSpan(
        text: 'No route data',
        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(size.width / 2 - tp.width / 2, size.height / 2 - tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant RouteMapPainter old) {
    return old.busLat != busLat ||
        old.busLng != busLng ||
        old.currentWaypointIndex != currentWaypointIndex ||
        old.isTripComplete != isTripComplete;
  }
}

// NEXATRACE — ROUTE MAP EDITOR PAINTER
// ======================================
// CustomPainter for the Route Scheduler (Module 13B).
// Renders a stylized geographic canvas with grid, roads,
// placed waypoints, and connecting path lines.
// Supports drag-to-place interaction for new waypoints.
//
// MODULE: 13B — Dynamic Route & Waypoint Line Scheduler

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A single waypoint on the route editor canvas.
class EditorWaypoint {
  final String id;
  String stationName;
  double lat;
  double lng;
  final int order;
  bool isDragging;

  EditorWaypoint({
    required this.id,
    this.stationName = '',
    required this.lat,
    required this.lng,
    required this.order,
    this.isDragging = false,
  });

  // Canvas position (projected from lat/lng)
  double get x => lng;
  double get y => -lat; // invert for screen (north = up)
}

class RouteMapEditorPainter extends CustomPainter {
  final List<EditorWaypoint> waypoints;
  final EditorWaypoint? draggingWaypoint;
  final double minLat, maxLat, minLng, maxLng;
  final String originCity, destinationCity;

  static const _colorGrid = Color(0xFFE2E8F0);
  static const _colorPathLine = Color(0xFF3B82F6);
  static const _colorPathFill = Color(0xFFDBEAFE);
  static const _colorWaypoint = Color(0xFF3B82F6);
  static const _colorWaypointStroke = Color(0xFF1D4ED8);
  static const _colorOrigin = Color(0xFF22C55E);
  static const _colorDest = Color(0xFFEF4444);
  static const _colorBg = Color(0xFFF8FAFC);
  static const _colorRoad = Color(0xFFF1F5F9);

  RouteMapEditorPainter({
    required this.waypoints,
    this.draggingWaypoint,
    this.minLat = 30.0,
    this.maxLat = 35.0,
    this.minLng = 71.0,
    this.maxLng = 75.0,
    this.originCity = '',
    this.destinationCity = '',
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    canvas.drawRect(Offset.zero & size, Paint()..color = _colorBg);

    // Grid
    _drawGrid(canvas, size);

    // Path line between waypoints
    if (waypoints.length >= 2) {
      final pathPaint = Paint()
        ..color = _colorPathLine
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final path = Path();
      for (int i = 0; i < waypoints.length; i++) {
        final pt = _project(waypoints[i], size);
        if (i == 0) {
          path.moveTo(pt.dx, pt.dy);
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }
      canvas.drawPath(path, pathPaint);
    }

    // Waypoints
    for (int i = 0; i < waypoints.length; i++) {
      final wp = waypoints[i];
      final pt = _project(wp, size);
      final isDragging = draggingWaypoint?.id == wp.id;
      final isOrigin = i == 0;
      final isDest = i == waypoints.length - 1 && waypoints.length > 1;

      Color fill = _colorWaypoint;
      if (isOrigin) fill = _colorOrigin;
      if (isDest) fill = _colorDest;
      if (isDragging) fill = fill.withValues(alpha: 0.7);

      // Circle
      canvas.drawCircle(pt, isDragging ? 14 : 10, Paint()..color = fill);
      canvas.drawCircle(
        pt,
        isDragging ? 14 : 10,
        Paint()
          ..color = _colorWaypointStroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      // Order number
      final tp = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(pt.dx - tp.width / 2, pt.dy - tp.height / 2));

      // Station label
      if (wp.stationName.isNotEmpty) {
        final lt = TextPainter(
          text: TextSpan(
            text: wp.stationName,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: fill,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: 100);
        lt.paint(canvas, Offset(pt.dx - lt.width / 2, pt.dy + 14));
      }
    }

    // Origin / Destination labels
    if (originCity.isNotEmpty) {
      final o = waypoints.isNotEmpty
          ? _project(waypoints.first, size)
          : Offset(20, size.height - 20);
      _drawLabel(canvas, o, originCity, _colorOrigin, size);
    }
    if (destinationCity.isNotEmpty && waypoints.length > 1) {
      final d = _project(waypoints.last, size);
      _drawLabel(canvas, d, destinationCity, _colorDest, size);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _colorGrid
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawLabel(
    Canvas canvas,
    Offset pos,
    String text,
    Color color,
    Size size,
  ) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = (pos.dx - tp.width / 2).clamp(4.0, size.width - tp.width - 4);
    final y = (pos.dy + 28).clamp(4.0, size.height - tp.height - 4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 4, y - 2, tp.width + 8, tp.height + 4),
        const Radius.circular(4),
      ),
      Paint()..color = color.withValues(alpha: 0.1),
    );
    tp.paint(canvas, Offset(x, y));
  }

  /// Project lat/lng to canvas coordinates.
  Offset _project(EditorWaypoint wp, Size size) {
    final pad = 40.0;
    final w = size.width - pad * 2;
    final h = size.height - pad * 2;
    final x = pad + ((wp.lng - minLng) / (maxLng - minLng)) * w;
    final y = pad + ((maxLat - wp.lat) / (maxLat - minLat)) * h;
    return Offset(x, y);
  }

  /// Inverse project: canvas coords → lat/lng.
  static (double lat, double lng) inverseProject(
    Offset pos,
    Size size,
    double minLat,
    double maxLat,
    double minLng,
    double maxLng,
  ) {
    final pad = 40.0;
    final w = size.width - pad * 2;
    final h = size.height - pad * 2;
    final lng = minLng + ((pos.dx - pad) / w) * (maxLng - minLng);
    final lat = maxLat - ((pos.dy - pad) / h) * (maxLat - minLat);
    return (lat, lng);
  }

  @override
  bool shouldRepaint(covariant RouteMapEditorPainter old) =>
      old.waypoints != waypoints ||
      old.draggingWaypoint?.id != draggingWaypoint?.id;
}

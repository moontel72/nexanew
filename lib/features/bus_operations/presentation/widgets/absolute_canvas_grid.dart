// NEXATRACE — ABSOLUTE CANVAS GRID
// ==================================
// Freeform interactive canvas for the Absolute Bus Layout Engine.
// Uses InteractiveViewer for pan/zoom and a Stack of Positioned widgets
// for drag-and-drop components. No grid coordinates — pure pixel positioning.
//
// 100% isolated from the legacy grid-based CanvasGrid.

import 'package:flutter/material.dart';
import 'package:trace_odd/shared/models/transport/layout_component.dart';
import 'package:trace_odd/shared/models/transport/absolute_layout_component.dart';
import 'package:trace_odd/shared/models/transport/absolute_layout_state.dart';

/// Default component type colors (mirrors legacy kComponentColors).
const Map<ComponentType, Color> kAbsoluteComponentColors = {
  ComponentType.seat: Color(0xFF7C3AED),
  ComponentType.sleeperLower: Color(0xFFDB2777),
  ComponentType.sleeperUpper: Color(0xFFF97316),
  ComponentType.foldingSeat: Color(0xFF06B6D4),
  ComponentType.exitDoor: Color(0xFFEF4444),
  ComponentType.driverCabin: Color(0xFF1E293B),
  ComponentType.emergency: Color(0xFFDC2626),
  ComponentType.lavatory: Color(0xFF6366F1),
  ComponentType.restaurantTable: Color(0xFF059669),
  ComponentType.businessClassSeat: Color(0xFFD97706),
  ComponentType.empty: Color(0xFF1A2533),
};

/// Icons for component types on the absolute canvas.
const Map<ComponentType, IconData> kAbsoluteComponentIcons = {
  ComponentType.seat: Icons.event_seat,
  ComponentType.sleeperLower: Icons.airline_seat_flat,
  ComponentType.sleeperUpper: Icons.airline_seat_flat_angled,
  ComponentType.foldingSeat: Icons.chair_alt,
  ComponentType.exitDoor: Icons.door_front_door,
  ComponentType.driverCabin: Icons.settings_accessibility,
  ComponentType.emergency: Icons.warning_amber_rounded,
  ComponentType.lavatory: Icons.wc,
  ComponentType.restaurantTable: Icons.table_restaurant,
  ComponentType.businessClassSeat: Icons.airline_seat_flat_angled,
  ComponentType.empty: Icons.grid_view,
};

/// Canvas background color.
const Color kCanvasBackground = Color(0xFF0D1B2A);

/// Dot-grid spacing for background visual guide.
const double kGridDotSpacing = 28.0;

class AbsoluteCanvasGrid extends StatefulWidget {
  final AbsoluteLayoutState layoutState;
  final void Function(String componentId, double x, double y)? onComponentTap;
  final void Function(double x, double y)? onCanvasTap;
  final TransformationController? transformController;

  const AbsoluteCanvasGrid({
    super.key,
    required this.layoutState,
    this.onComponentTap,
    this.onCanvasTap,
    this.transformController,
  });

  @override
  State<AbsoluteCanvasGrid> createState() => _AbsoluteCanvasGridState();
}

class _AbsoluteCanvasGridState extends State<AbsoluteCanvasGrid> {
  // Manual tap detection — avoids gesture arena competition with
  // InteractiveViewer's internal ScaleGestureRecognizer.
  Offset? _pointerDownPos;
  static const double _tapSlop = 12.0; // max movement to count as tap

  void _onPointerDown(PointerDownEvent event) {
    _pointerDownPos = event.localPosition;
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_pointerDownPos == null) return;
    final down = _pointerDownPos!;
    _pointerDownPos = null;

    final up = event.localPosition;
    // Ignore if the pointer moved more than the tap slop
    if ((up - down).distance > _tapSlop) return;

    // Hit-test: use the midpoint of down/up for accuracy
    final tapX = (down.dx + up.dx) / 2;
    final tapY = (down.dy + up.dy) / 2;
    final hit = widget.layoutState.componentAt(tapX, tapY);
    if (hit != null) {
      widget.onComponentTap?.call(hit.id, tapX, tapY);
    } else {
      widget.onCanvasTap?.call(tapX, tapY);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ls = widget.layoutState;
    return InteractiveViewer(
      transformationController: widget.transformController,
      constrained: false,
      boundaryMargin: const EdgeInsets.all(400),
      minScale: 0.25,
      maxScale: 4.0,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: _onPointerDown,
        onPointerUp: _onPointerUp,
        child: SizedBox(
          width: ls.canvasWidth,
          height: ls.canvasHeight,
          child: CustomPaint(
            painter: _CanvasBackgroundPainter(
              canvasWidth: ls.canvasWidth,
              canvasHeight: ls.canvasHeight,
            ),
            child: Stack(
              children: [
                for (final comp in ls.components)
                  _AbsoluteComponentWidget(
                    component: comp,
                    isSelected: comp.id == ls.selectedComponentId,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints the dot-grid background and architectural ruler on the canvas.
class _CanvasBackgroundPainter extends CustomPainter {
  final double canvasWidth;
  final double canvasHeight;

  _CanvasBackgroundPainter({
    required this.canvasWidth,
    required this.canvasHeight,
  });

  static const double _rulerThickness = 22.0;
  static const double _inchPx = kPixelsPerInch; // 4 px

  @override
  void paint(Canvas canvas, Size size) {
    // Fill background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = kCanvasBackground,
    );

    // Draw dot grid (shifted down/right to leave room for rulers)
    final dotPaint = Paint()
      ..color = const Color(0x30FFFFFF)
      ..strokeWidth = 1.5;

    for (double x = kGridDotSpacing; x < canvasWidth; x += kGridDotSpacing) {
      for (double y = kGridDotSpacing; y < canvasHeight; y += kGridDotSpacing) {
        canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
      }
    }

    // Draw canvas border
    canvas.drawRect(
      Rect.fromLTWH(0, 0, canvasWidth, canvasHeight),
      Paint()
        ..color = const Color(0x40FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // ═══════════════════════════════════════════════
    // ARCHITECTURAL RULER — TOP EDGE (LENGTH)
    // ═══════════════════════════════════════════════
    _drawRuler(canvas, true);

    // ═══════════════════════════════════════════════
    // ARCHITECTURAL RULER — LEFT EDGE (WIDTH)
    // ═══════════════════════════════════════════════
    _drawRuler(canvas, false);

    // Corner label: total canvas size
    final totalStyle = TextStyle(color: const Color(0x80FFFFFF), fontSize: 9);
    final totalLabel = TextPainter(
      text: TextSpan(
        text: '${pxToFtIn(canvasWidth)} × ${pxToFtIn(canvasHeight)}',
        style: totalStyle,
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    totalLabel.paint(canvas, const Offset(4, 4));
  }

  /// Draws an architectural ruler along the top (horizontal) or left (vertical).
  void _drawRuler(Canvas canvas, bool isTop) {
    final length = isTop ? canvasWidth : canvasHeight;
    final totalInches = (length / _inchPx).round();

    // Ruler background strip
    final rulerBg = Paint()..color = const Color(0xFF07101E);
    final rulerRect = isTop
        ? Rect.fromLTWH(0, 0, canvasWidth, _rulerThickness)
        : Rect.fromLTWH(0, 0, _rulerThickness, canvasHeight);
    canvas.drawRect(rulerRect, rulerBg);

    // Tick marks and labels
    final tickPaint = Paint()
      ..color = const Color(0x60FFFFFF)
      ..strokeWidth = 1.0;
    final footTickPaint = Paint()
      ..color = const Color(0xCCFFFFFF)
      ..strokeWidth = 1.5;
    final labelStyle = TextStyle(color: const Color(0x99FFFFFF), fontSize: 8);

    for (int inch = 0; inch <= totalInches; inch++) {
      final pos = inch * _inchPx;
      final isFoot = inch % 12 == 0;
      final tickLen = isFoot ? 12.0 : 6.0; // longer tick at foot marks

      if (isTop) {
        // Top ruler: ticks go down from the top
        canvas.drawLine(
          Offset(pos, _rulerThickness - tickLen),
          Offset(pos, _rulerThickness),
          isFoot ? footTickPaint : tickPaint,
        );
        // Label at foot marks
        if (isFoot && pos + 16 < canvasWidth) {
          final feet = inch ~/ 12;
          // Draw `feet` number only (not feet.inches) for cleaner look
          final tp = TextPainter(
            text: TextSpan(text: '$feet', style: labelStyle),
            textDirection: TextDirection.ltr,
          )..layout();
          tp.paint(canvas, Offset(pos + 2, _rulerThickness - tickLen - 10));
        }
        // Small inch labels every 3 inches between foot marks
        if (!isFoot && inch % 3 == 0 && pos + 16 < canvasWidth) {
          final tp = TextPainter(
            text: TextSpan(
              text: '${inch % 12}',
              style: TextStyle(color: const Color(0x50FFFFFF), fontSize: 7),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          tp.paint(canvas, Offset(pos + 1, _rulerThickness - tickLen - 9));
        }
      } else {
        // Left ruler: ticks go right from the left
        canvas.drawLine(
          Offset(_rulerThickness - tickLen, pos),
          Offset(_rulerThickness, pos),
          isFoot ? footTickPaint : tickPaint,
        );
        // Label at foot marks
        if (isFoot && pos + 10 < canvasHeight) {
          final feet = inch ~/ 12;
          // Rotate text 90° for vertical ruler
          canvas.save();
          canvas.translate(4, pos + 8);
          canvas.rotate(-3.1415926535 / 2);
          final tp = TextPainter(
            text: TextSpan(text: '$feet', style: labelStyle),
            textDirection: TextDirection.ltr,
          )..layout();
          tp.paint(canvas, Offset.zero);
          canvas.restore();
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CanvasBackgroundPainter old) =>
      canvasWidth != old.canvasWidth || canvasHeight != old.canvasHeight;
}

/// Renders a single component on the absolute canvas.
class _AbsoluteComponentWidget extends StatelessWidget {
  final AbsoluteLayoutComponent component;
  final bool isSelected;

  const _AbsoluteComponentWidget({
    required this.component,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        kAbsoluteComponentColors[component.type] ?? const Color(0xFF334155);
    final icon = kAbsoluteComponentIcons[component.type] ?? Icons.help_outline;
    final label =
        component.customLabel ??
        component.berthLabel ??
        component.seatId ??
        (component.seatNumber?.toString() ?? '');

    return Positioned(
      left: component.x,
      top: component.y,
      width: component.width,
      height: component.height,
      child: Transform.rotate(
        angle: component.rotation * 3.1415926535 / 180.0,
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(isSelected ? 0.9 : 0.7),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? Colors.white : color.withOpacity(0.5),
              width: isSelected ? 2.5 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: _iconSize()),
              if (label.isNotEmpty && component.width >= 40)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _fontSize(),
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  double _iconSize() {
    final minDim = component.width < component.height
        ? component.width
        : component.height;
    return (minDim * 0.45).clamp(12.0, 36.0);
  }

  double _fontSize() {
    return (component.width * 0.22).clamp(8.0, 16.0);
  }
}

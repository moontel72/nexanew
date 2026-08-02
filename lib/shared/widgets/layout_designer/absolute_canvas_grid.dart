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
import "package:trace_odd/shared/widgets/layout_designer/absolute_transform_overlay.dart";

/// Default component type colors (mirrors legacy kComponentColors).
const Map<ComponentType, Color> kAbsoluteComponentColors = {
  ComponentType.seat: Color(0xFF7C3AED),
  ComponentType.sleeperLower: Color(0xFFDB2777),
  ComponentType.sleeperUpper: Color(0xFFF97316),
  ComponentType.foldingSeat: Color(0xFF06B6D4),
  ComponentType.exitDoor: Color(0xFFEF4444),
  ComponentType.sideDoor: Color(0xFF8B4513),
  ComponentType.slidingDoor: Color(0xFF4682B4),
  ComponentType.frontDoor: Color(0xFFCD853F),
  ComponentType.rearDoor: Color(0xFF708090),
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
  ComponentType.sideDoor: Icons.meeting_room,
  ComponentType.slidingDoor: Icons.door_sliding,
  ComponentType.frontDoor: Icons.open_in_new,
  ComponentType.rearDoor: Icons.arrow_circle_up,
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
  final void Function(double w, double h, double x, double y)? onOverlayResize;
  final void Function(double x, double y)? onOverlayMove;
  final void Function(double r)? onOverlayRotate;
  final VoidCallback? onOverlayDelete;
  final VoidCallback? onOverlayTap;
  final VoidCallback? onOverlayClose;
  final TransformationController? transformController;

  const AbsoluteCanvasGrid({
    super.key,
    required this.layoutState,
    this.onComponentTap,
    this.onOverlayResize,
    this.onOverlayMove,
    this.onOverlayRotate,
    this.onOverlayDelete,
    this.onOverlayTap,
    this.onOverlayClose,
    this.onCanvasTap,
    this.transformController,
  });

  @override
  State<AbsoluteCanvasGrid> createState() => _AbsoluteCanvasGridState();
}

class _AbsoluteCanvasGridState extends State<AbsoluteCanvasGrid> {
  // Shared tap handler — dispatches to component or canvas callbacks.
  void _handleTap(double x, double y) {
    final hit = widget.layoutState.componentAt(x, y);
    if (hit != null) {
      widget.onComponentTap?.call(hit.id, x, y);
    } else {
      widget.onCanvasTap?.call(x, y);
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
      child: GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onTapUp: (d) => _handleTap(d.localPosition.dx, d.localPosition.dy),
        child: SizedBox(
          width: ls.canvasWidth,
          height: ls.canvasHeight,
          child: CustomPaint(
            painter: _CanvasBackgroundPainter(
              canvasWidth: ls.canvasWidth,
              canvasHeight: ls.canvasHeight,
              components: ls.components,
              hasFrontPartition: ls.hasFrontPartition,
            ),
            child: Stack(
              children: [
                for (final comp in ls.components)
                  _AbsoluteComponentWidget(
                    component: comp,
                    isSelected: comp.id == ls.selectedComponentId,
                    onComponentTap: widget.onComponentTap,
                  ),
                if (ls.selectedComponent != null)
                  AbsoluteTransformOverlay(
                    key: ValueKey("overlay_${ls.selectedComponent!.id}"),
                    component: ls.selectedComponent!,
                    onResize: (w, h, x, y) =>
                        widget.onOverlayResize?.call(w, h, x, y),
                    onResizeEnd: () {},
                    onMove: (x, y) => widget.onOverlayMove?.call(x, y),
                    onMoveEnd: () {},
                    onRotate: (r) => widget.onOverlayRotate?.call(r),
                    onRotateEnd: () {},
                    onDelete: () => widget.onOverlayDelete?.call(),
                    onTap: () => widget.onOverlayTap?.call(),
                    onClose: () => widget.onOverlayClose?.call(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints the dot-grid background, architectural ruler, and bus body
/// outline (windshield, side windows, passenger door) on the canvas.
///
/// Bus body decorations (windshield, windows, door) are only drawn
/// when [hasFrontPartition] is true — they represent the engine-cover
/// partition area.  When the partition toggle is OFF (HiAce / vans),
/// only the dot grid and ruler are rendered.
class _CanvasBackgroundPainter extends CustomPainter {
  final double canvasWidth;
  final double canvasHeight;
  final List<AbsoluteLayoutComponent> components;
  final bool hasFrontPartition;

  _CanvasBackgroundPainter({
    required this.canvasWidth,
    required this.canvasHeight,
    this.components = const [],
    this.hasFrontPartition = false,
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
    totalLabel.paint(canvas, const Offset(2, 2));

    // ═══════════════════════════════════════════════
    // BUS BODY OUTLINE (windshield, windows, door)
    // Only drawn when front partition is enabled —
    // for HiAce/vans without "Tapa", skip the decoration.
    // ═══════════════════════════════════════════════
    if (hasFrontPartition) {
      _drawBusBody(canvas);
    }
  }

  /// Draws an architectural ruler along the top (horizontal) or left (vertical).
  /// Tick spacing is exactly [_inchPx] pixels per inch. Foot marks every 12″.
  void _drawRuler(Canvas canvas, bool isTop) {
    final length = isTop ? canvasWidth : canvasHeight;
    final totalInches = (length / _inchPx).floor();

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
    final footLabelStyle = TextStyle(
      color: const Color(0xCCFFFFFF),
      fontSize: 8,
      fontWeight: FontWeight.w600,
    );
    final inchLabelStyle = TextStyle(
      color: const Color(0x50FFFFFF),
      fontSize: 7,
    );

    for (int inch = 0; inch <= totalInches; inch++) {
      final pos = inch * _inchPx;
      final isFoot = inch % 12 == 0;
      final tickLen = isFoot ? 12.0 : 6.0; // longer tick at foot marks

      if (isTop) {
        // Top ruler: ticks go down from the top edge
        canvas.drawLine(
          Offset(pos, _rulerThickness - tickLen),
          Offset(pos, _rulerThickness),
          isFoot ? footTickPaint : tickPaint,
        );
        // Label at foot marks
        if (isFoot && pos + 18 < canvasWidth) {
          final tp = TextPainter(
            text: TextSpan(text: "${inch ~/ 12}'", style: footLabelStyle),
            textDirection: TextDirection.ltr,
          )..layout();
          tp.paint(canvas, Offset(pos + 2, _rulerThickness - tickLen - 11));
        }
        // Small inch labels at 3″, 6″, 9″ between foot marks
        if (!isFoot && inch % 3 == 0 && pos + 16 < canvasWidth) {
          final tp = TextPainter(
            text: TextSpan(text: '${inch % 12}"', style: inchLabelStyle),
            textDirection: TextDirection.ltr,
          )..layout();
          tp.paint(canvas, Offset(pos + 1, _rulerThickness - tickLen - 9));
        }
      } else {
        // Left ruler: ticks go right from the left edge
        canvas.drawLine(
          Offset(_rulerThickness - tickLen, pos),
          Offset(_rulerThickness, pos),
          isFoot ? footTickPaint : tickPaint,
        );
        // Label at foot marks (rotated 90°)
        if (isFoot && pos + 10 < canvasHeight) {
          canvas.save();
          canvas.translate(5, pos + 9);
          canvas.rotate(-3.1415926535 / 2);
          final tp = TextPainter(
            text: TextSpan(text: "${inch ~/ 12}'", style: footLabelStyle),
            textDirection: TextDirection.ltr,
          )..layout();
          tp.paint(canvas, Offset.zero);
          canvas.restore();
        }
        // Inch labels at 3″, 6″, 9″ on the vertical ruler
        if (!isFoot && inch % 3 == 0 && pos + 12 < canvasHeight) {
          canvas.save();
          canvas.translate(3, pos + 9);
          canvas.rotate(-3.1415926535 / 2);
          final tp = TextPainter(
            text: TextSpan(text: '${inch % 12}"', style: inchLabelStyle),
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
      canvasWidth != old.canvasWidth ||
      canvasHeight != old.canvasHeight ||
      hasFrontPartition != old.hasFrontPartition;

  // ═══════════════════════════════════════════════
  // BUS BODY GRAPHICS
  // ═══════════════════════════════════════════════

  void _drawBusBody(Canvas canvas) {
    // Determine driver position → front of bus
    final driver = components.isEmpty
        ? null
        : components.where((c) => c.type == ComponentType.driverCabin).isEmpty
        ? null
        : components.firstWhere((c) => c.type == ComponentType.driverCabin);
    final bool frontAtTop = driver == null || driver.y < canvasHeight / 2;

    _drawWindshield(canvas, frontAtTop);
    _drawSideWindows(canvas);
    _drawPassengerDoor(canvas, frontAtTop);
  }

  /// Curved front windshield / dashboard outline at the driver's end.
  void _drawWindshield(Canvas canvas, bool atTop) {
    final windshieldPaint = Paint()
      ..color = const Color(0x1844AAFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final fillPaint = Paint()..color = const Color(0x0810A0FF);

    final double y;
    if (atTop) {
      y = _rulerThickness + 2;
    } else {
      y = canvasHeight - _rulerThickness - 2;
    }

    // Curved windshield shape (like a rounded trapezoid)
    final path = Path();
    final double w = canvasWidth;
    final double windH = 48; // windshield depth
    final double shrink = w * 0.12; // curvature inset

    if (atTop) {
      path.moveTo(shrink, y + windH);
      path.lineTo(w - shrink, y + windH);
      path.quadraticBezierTo(w + 6, y + windH * 0.6, w - shrink * 0.5, y + 4);
      path.lineTo(shrink * 0.5, y + 4);
      path.quadraticBezierTo(-6, y + windH * 0.6, shrink, y + windH);
    } else {
      path.moveTo(shrink, y - windH);
      path.lineTo(w - shrink, y - windH);
      path.quadraticBezierTo(w + 6, y - windH * 0.6, w - shrink * 0.5, y - 4);
      path.lineTo(shrink * 0.5, y - 4);
      path.quadraticBezierTo(-6, y - windH * 0.6, shrink, y - windH);
    }
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, windshieldPaint);

    // "WINDSHIELD" label
    final lblStyle = TextStyle(color: const Color(0x30FFFFFF), fontSize: 8);
    final tp = TextPainter(
      text: TextSpan(text: 'WINDSHIELD', style: lblStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset((w - tp.width) / 2, atTop ? y + windH * 0.55 : y - windH * 0.85),
    );
  }

  /// Subtle side-window indicators along left and right canvas edges.
  void _drawSideWindows(Canvas canvas) {
    final windowPaint = Paint()
      ..color = const Color(0x18CCDDFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final fillPaint = Paint()..color = const Color(0x0610A0FF);

    final double winTop = _rulerThickness + 52;
    final double winBottom = canvasHeight - 4;
    final double winInset = 2; // distance from canvas edge
    final double winWide = 14; // window strip width

    // Left-side window strip
    final leftRect = Rect.fromLTWH(
      winInset,
      winTop,
      winWide,
      winBottom - winTop,
    );
    canvas.drawRect(leftRect, fillPaint);
    canvas.drawRect(leftRect, windowPaint);

    // Right-side window strip
    final rightRect = Rect.fromLTWH(
      canvasWidth - winInset - winWide,
      winTop,
      winWide,
      winBottom - winTop,
    );
    canvas.drawRect(rightRect, fillPaint);
    canvas.drawRect(rightRect, windowPaint);

    // Window separation lines (like pane dividers) every ~2 ft
    final sepPaint = Paint()
      ..color = const Color(0x12FFFFFF)
      ..strokeWidth = 0.8;
    const double sepSpacing = 96; // 2 ft = 24" × 4 px/in
    for (double sy = winTop + sepSpacing; sy < winBottom; sy += sepSpacing) {
      // Left
      canvas.drawLine(
        Offset(winInset, sy),
        Offset(winInset + winWide, sy),
        sepPaint,
      );
      // Right
      canvas.drawLine(
        Offset(canvasWidth - winInset - winWide, sy),
        Offset(canvasWidth - winInset, sy),
        sepPaint,
      );
    }
  }

  /// Passenger entry door graphic on the right side, near the front.
  void _drawPassengerDoor(Canvas canvas, bool frontAtTop) {
    final doorPaint = Paint()
      ..color = const Color(0x28FFAA33)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final doorFill = Paint()..color = const Color(0x10FFAA33);

    final double doorW = 44;
    final double doorH = 80;
    final double doorX = canvasWidth - 6 - doorW;
    final double doorY = frontAtTop
        ? _rulerThickness + 56
        : canvasHeight - _rulerThickness - doorH - 4;

    final doorRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(doorX, doorY, doorW, doorH),
      const Radius.circular(6),
    );
    canvas.drawRRect(doorRect, doorFill);
    canvas.drawRRect(doorRect, doorPaint);

    // Door handle
    final handlePaint = Paint()
      ..color = const Color(0x40FFFFFF)
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(doorX + doorW * 0.65, doorY + doorH * 0.55),
      Offset(doorX + doorW * 0.65, doorY + doorH * 0.75),
      handlePaint,
    );

    // "DOOR" label
    final lblStyle = TextStyle(
      color: const Color(0x30FFAA33),
      fontSize: 8,
      fontWeight: FontWeight.w600,
    );
    final tp = TextPainter(
      text: TextSpan(text: 'DOOR', style: lblStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(doorX + (doorW - tp.width) / 2, doorY + doorH + 2));
  }
}

/// Renders a single component on the absolute canvas.
class _AbsoluteComponentWidget extends StatelessWidget {
  final AbsoluteLayoutComponent component;
  final bool isSelected;
  final void Function(String id, double x, double y)? onComponentTap;

  const _AbsoluteComponentWidget({
    required this.component,
    required this.isSelected,
    this.onComponentTap,
  });

  /// Whether this component type should render as a seat (flat clean style).
  bool get _isSeatType =>
      component.type == ComponentType.seat ||
      component.type == ComponentType.businessClassSeat ||
      component.type == ComponentType.foldingSeat;

  /// Whether this component should be rendered with a 180° visual flip.
  bool get _isReversed =>
      component.isReverseFacing &&
      (component.type == ComponentType.seat ||
          component.type == ComponentType.businessClassSeat);

  @override
  Widget build(BuildContext context) {
    final Color color;
    final IconData icon;
    if (component.type == ComponentType.seat && component.isReverseFacing) {
      color = const Color(0xFF3B82F6);
      icon = Icons.event_seat;
    } else if (component.type == ComponentType.businessClassSeat &&
        component.isReverseFacing) {
      color = const Color(0xFF059669);
      icon = Icons.airline_seat_flat_angled;
    } else if (component.type == ComponentType.businessClassSeat) {
      color = const Color(0xFFD97706);
      icon = Icons.airline_seat_flat_angled;
    } else if (component.type == ComponentType.foldingSeat) {
      color = const Color(0xFF06B6D4);
      icon = Icons.chair_alt;
    } else if (component.type == ComponentType.driverCabin) {
      // Position‑based driver seat styling.
      final pos = component.meta['driver_position'] as String?;
      if (pos == 'left') {
        color = const Color(0xFFDC2626); // red — left‑hand drive
        icon = Icons.settings; // steering wheel
      } else if (pos == 'center') {
        color = const Color(0xFFF59E0B); // amber — center drive
        icon = Icons.settings;
      } else if (pos == 'right') {
        color = const Color(0xFF16A34A); // green — right‑hand drive
        icon = Icons.settings;
      } else {
        // Default to right-hand drive (most common configuration).
        // The old fallback Color(0xFF1E293B) was nearly invisible
        // against the dark canvas background Color(0xFF0D1B2A).
        color = const Color(0xFF16A34A); // green — right‑hand drive
        icon = Icons.settings;
      }
    } else {
      color =
          kAbsoluteComponentColors[component.type] ?? const Color(0xFF334155);
      icon = kAbsoluteComponentIcons[component.type] ?? Icons.help_outline;
    }
    final label =
        component.customLabel ??
        component.berthLabel ??
        component.seatId ??
        (component.seatNumber?.toString() ?? '');

    final dark = Color.lerp(color, Colors.black, 0.40)!;
    final light = color;

    // ── Build the content widget ──
    final Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(7),
      child: _isSeatType
          ? _buildFlatSeat(color, icon, label)
          : _buildCardComponent(dark, light, icon, label),
    );

    // ── Apply 180° rotation for reverse-facing seats ──
    final Widget rotatedContent = _isReversed
        ? Transform.rotate(angle: 3.1415926535, child: content)
        : content;

    return Positioned(
      left: component.x,
      top: component.y,
      width: component.width,
      height: component.height,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          onComponentTap?.call(component.id, component.x, component.y);
        },
        child: Transform.rotate(
          angle: component.rotation * 3.1415926535 / 180.0,
          child: Container(
            // Structural aisles between seat blocks
            margin: _isSeatType
                ? const EdgeInsets.symmetric(vertical: 4, horizontal: 6)
                : const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Colors.white : light.withOpacity(0.35),
                width: isSelected ? 2.5 : 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: dark.withOpacity(0.55),
                  blurRadius: 6,
                  offset: const Offset(2, 3),
                ),
                BoxShadow(
                  color: light.withOpacity(0.25),
                  blurRadius: 3,
                  offset: const Offset(-1, -1),
                ),
                if (isSelected)
                  BoxShadow(
                    color: color.withOpacity(0.6),
                    blurRadius: 14,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: rotatedContent,
          ),
        ),
      ),
    );
  }

  /// Paints the dot-grid background
  // ═══════════════════════════════════════════════════════════
  // FLAT SEAT RENDERING (clean airline / bus booking style)
  // ═══════════════════════════════════════════════════════════

  /// Renders a clean, modern flat seat with a headrest indicator line.
  ///
  /// ── Orientation ──
  /// - Forward seats:  headrest indicator at the **bottom** edge (facing up).
  /// - Reverse seats:  indicator at the **top** edge (facing down).
  ///   (The 180° rotation is applied by [build] via [_isReversed].)
  ///
  /// ── Color ──
  /// - Standard forward: purple  (#7C3AED)
  /// - Standard reverse:  blue    (#3B82F6)
  /// - Business Class:    amber   (#D97706), wider with premium styling
  /// - Folding:           cyan    (#06B6D4)
  Widget _buildFlatSeat(Color color, IconData icon, String label) {
    final double w = component.width - 12; // account for horizontal margin
    final bool isBiz = component.type == ComponentType.businessClassSeat;

    // Seat body colour — use the passed-in [color] directly
    final Color seatBody = color;
    final Color borderClr = Color.lerp(color, Colors.black, 0.18)!;

    // Headrest indicator colour (white with slight opacity)
    const Color indicatorClr = Color(0xCCFFFFFF);

    // Label styling
    final double fontSize = _fontSize();
    final bool showLabel = label.isNotEmpty && component.width >= 34;

    return Container(
      decoration: BoxDecoration(
        color: seatBody,
        borderRadius: BorderRadius.circular(isBiz ? 10 : 8),
        border: Border.all(color: borderClr, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ── Headrest indicator line ──
          // Rendered at the BOTTOM edge for forward seats.
          // The 180° Transform.rotate in build() will flip it
          // to the TOP edge for reverse seats.
          Positioned(
            left: w * 0.18,
            right: w * 0.18,
            bottom: isBiz ? 5 : 3,
            height: isBiz ? 4 : 3,
            child: Container(
              decoration: BoxDecoration(
                color: indicatorClr,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Business Class: top-edge accent stripe ──
          if (isBiz)
            Positioned(
              left: w * 0.22,
              right: w * 0.22,
              top: 4,
              height: 2.5,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

          // ── Seat icon (small, centered) ──
          if (!showLabel || isBiz)
            Center(
              child: component.isReverseFacing
                  ? Transform.rotate(
                      angle: 3.1415926535,
                      child: Icon(
                        icon,
                        color: Colors.white.withOpacity(0.55),
                        size: _iconSize() * 0.65,
                      ),
                    )
                  : Icon(
                      icon,
                      color: Colors.white.withOpacity(0.55),
                      size: _iconSize() * 0.65,
                    ),
            ),

          // ── Seat label ──
          // For business-class seats, render the label near the top so
          // it doesn't collide with the centered icon.
          if (showLabel)
            isBiz
                ? Positioned(
                    top: 1,
                    left: 0,
                    right: 0,
                    child: component.isReverseFacing
                        ? Transform.rotate(
                            angle: 3.1415926535,
                            child: Text(
                              label,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: fontSize,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          )
                        : Text(
                            label,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: fontSize,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: component.isReverseFacing
                          ? Transform.rotate(
                              angle: 3.1415926535,
                              child: Text(
                                label,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            )
                          : Text(
                              label,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: fontSize,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                    ),
                  ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CARD-STYLE COMPONENTS (berths, doors, tables, lavatory)
  // ═══════════════════════════════════════════════════════════

  /// Renders a card-style component (sleeper berth, door, table, lavatory, etc.)
  /// with a gradient background and icon + label.
  Widget _buildCardComponent(
    Color dark,
    Color light,
    IconData icon,
    String label,
  ) {
    final bool isTable = component.type == ComponentType.restaurantTable;
    final bool isStructural =
        component.type == ComponentType.exitDoor ||
        component.type == ComponentType.sideDoor ||
        component.type == ComponentType.slidingDoor ||
        component.type == ComponentType.frontDoor ||
        component.type == ComponentType.rearDoor ||
        component.type == ComponentType.driverCabin ||
        component.type == ComponentType.emergency ||
        component.type == ComponentType.lavatory;

    // ── Icon + label (non-table components) ──
    if (!isTable) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isStructural ? Colors.white : light,
            size: _iconSize(),
          ),
          if (label.isNotEmpty && component.width >= 40)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: _fontSize(),
                  fontWeight: FontWeight.w700,
                  shadows: const [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 3,
                      offset: Offset(0, 1.5),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      );
    }

    // ── Table rendering ──
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [light.withOpacity(0.85), dark.withOpacity(0.85)],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1.2,
            ),
          ),
        ),
        for (final dot in [
          Alignment(-0.55, -0.55),
          Alignment(0.55, -0.55),
          Alignment(-0.55, 0.55),
          Alignment(0.55, 0.55),
        ])
          Align(
            alignment: dot,
            child: Container(
              width: component.width * 0.22,
              height: component.height * 0.22,
              decoration: BoxDecoration(
                color: light.withOpacity(0.45),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        Center(
          child: Icon(
            Icons.table_restaurant,
            color: Colors.white.withOpacity(0.35),
            size: _iconSize() * 0.9,
          ),
        ),
      ],
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

// NEXATRACE — ABSOLUTE TRANSFORM OVERLAY
// =========================================
// Resize, move, rotate, and delete overlay for selected components.
//
// Draws 8 resize handles (4 corners + 4 midpoints), a rotation handle
// (top-center extended arm), a delete button (top-right), and supports
// drag-to-move on the component body.
//
// 100% isolated from legacy system.

import 'package:flutter/material.dart';
import 'package:trace_odd/shared/models/transport/absolute_layout_component.dart';
import 'package:trace_odd/shared/models/transport/absolute_layout_state.dart';

/// Handle positions around the bounding box.
enum _HandlePosition {
  topLeft,
  topCenter,
  topRight,
  middleLeft,
  middleRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
  rotation,
}

typedef OnResize =
    void Function(double newWidth, double newHeight, double newX, double newY);
typedef OnResizeEnd = void Function();
typedef OnMove = void Function(double newX, double newY);
typedef OnMoveEnd = void Function();
typedef OnRotate = void Function(double newRotation);
typedef OnRotateEnd = void Function();
typedef OnDelete = void Function();
typedef OnTapOverlay = void Function();

class AbsoluteTransformOverlay extends StatefulWidget {
  final AbsoluteLayoutComponent component;
  final OnResize onResize;
  final OnResizeEnd onResizeEnd;
  final OnMove onMove;
  final OnMoveEnd onMoveEnd;
  final OnRotate onRotate;
  final OnRotateEnd onRotateEnd;
  final OnDelete? onDelete;
  final OnTapOverlay? onTap;

  const AbsoluteTransformOverlay({
    super.key,
    required this.component,
    required this.onResize,
    required this.onResizeEnd,
    required this.onMove,
    required this.onMoveEnd,
    required this.onRotate,
    required this.onRotateEnd,
    this.onDelete,
    this.onTap,
  });

  @override
  State<AbsoluteTransformOverlay> createState() =>
      _AbsoluteTransformOverlayState();
}

class _AbsoluteTransformOverlayState extends State<AbsoluteTransformOverlay> {
  static const double _handleSize = 18.0;
  static const double _rotationArmLength = 48.0;
  static const double _rotationKnobSize = 40.0;
  static const double _deleteBtnSize = 40.0;

  // Live dimension tooltip during resize
  bool _isResizing = false;
  double _resizeW = 0;
  double _resizeH = 0;

  @override
  Widget build(BuildContext context) {
    final c = widget.component;
    // Use live-resize values when dragging, otherwise the current component
    final displayW = _isResizing ? _resizeW : c.width;
    final displayH = _isResizing ? _resizeH : c.height;

    return Positioned(
      left: c.x,
      top: c.y,
      width: c.width,
      height: c.height,
      child: IgnorePointer(
        ignoring: false,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ── Body: drag-to-move + selection border ──
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: widget.onTap,
                onPanStart: (_) {},
                onPanUpdate: (d) {
                  widget.onMove(c.x + d.delta.dx, c.y + d.delta.dy);
                },
                onPanEnd: (_) => widget.onMoveEnd(),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white.withOpacity(0.9),
                      width: 2.5,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            // ── Delete button (top-right corner, always visible) ──
            Positioned(
              right: -_deleteBtnSize / 3,
              top: -_deleteBtnSize / 3,
              child: GestureDetector(
                onTap: widget.onDelete ?? () {},
                child: Container(
                  width: _deleteBtnSize,
                  height: _deleteBtnSize,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),

            // ── Live resize dimension tooltip ──
            if (_isResizing)
              Positioned(
                left: 0,
                right: 0,
                top: -56,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xE50D1B2A),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFF7C3AED).withOpacity(0.7),
                        width: 1.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '${pxToFtIn(displayW)} × ${pxToFtIn(displayH)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              ),

            // ── 4 corner handles ──
            _buildHandle(_HandlePosition.topLeft, c),
            _buildHandle(_HandlePosition.topRight, c),
            _buildHandle(_HandlePosition.bottomLeft, c),
            _buildHandle(_HandlePosition.bottomRight, c),

            // ── 4 midpoint handles ──
            _buildHandle(_HandlePosition.topCenter, c),
            _buildHandle(_HandlePosition.bottomCenter, c),
            _buildHandle(_HandlePosition.middleLeft, c),
            _buildHandle(_HandlePosition.middleRight, c),

            // ── Rotation handle ──
            _buildRotationHandle(c),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // RESIZE HANDLES
  // ═══════════════════════════════════════════════════════════

  Widget _buildHandle(_HandlePosition pos, AbsoluteLayoutComponent c) {
    final offset = _handleOffset(pos, c);
    final cursor = _handleCursor(pos);
    final isCorner =
        pos == _HandlePosition.topLeft ||
        pos == _HandlePosition.topRight ||
        pos == _HandlePosition.bottomLeft ||
        pos == _HandlePosition.bottomRight;

    return Positioned(
      left: offset.dx - _handleSize / 2,
      top: offset.dy - _handleSize / 2,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (_) {
          setState(() {
            _isResizing = true;
            _resizeW = c.width;
            _resizeH = c.height;
          });
        },
        onPanUpdate: (d) => _onResizeDrag(pos, d),
        onPanEnd: (_) {
          setState(() => _isResizing = false);
          widget.onResizeEnd();
        },
        child: MouseRegion(
          cursor: cursor,
          child: Container(
            width: _handleSize,
            height: _handleSize,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: isCorner ? const Color(0xFF7C3AED) : Colors.blue,
                width: 2,
              ),
              shape: isCorner ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: isCorner ? null : BorderRadius.circular(2),
              boxShadow: const [
                BoxShadow(color: Colors.black38, blurRadius: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Offset _handleOffset(_HandlePosition pos, AbsoluteLayoutComponent c) {
    final w = c.width;
    final h = c.height;
    return switch (pos) {
      _HandlePosition.topLeft => Offset.zero,
      _HandlePosition.topCenter => Offset(w / 2, 0),
      _HandlePosition.topRight => Offset(w, 0),
      _HandlePosition.middleLeft => Offset(0, h / 2),
      _HandlePosition.middleRight => Offset(w, h / 2),
      _HandlePosition.bottomLeft => Offset(0, h),
      _HandlePosition.bottomCenter => Offset(w / 2, h),
      _HandlePosition.bottomRight => Offset(w, h),
      _HandlePosition.rotation => Offset(w / 2, -_rotationArmLength),
    };
  }

  MouseCursor _handleCursor(_HandlePosition pos) {
    return switch (pos) {
      _HandlePosition.topLeft ||
      _HandlePosition.bottomRight => SystemMouseCursors.resizeUpLeftDownRight,
      _HandlePosition.topRight ||
      _HandlePosition.bottomLeft => SystemMouseCursors.resizeUpRightDownLeft,
      _HandlePosition.topCenter ||
      _HandlePosition.bottomCenter => SystemMouseCursors.resizeUpDown,
      _HandlePosition.middleLeft ||
      _HandlePosition.middleRight => SystemMouseCursors.resizeLeftRight,
      _HandlePosition.rotation => SystemMouseCursors.grab,
    };
  }

  void _onResizeDrag(_HandlePosition pos, DragUpdateDetails d) {
    final c = widget.component;
    double newX = c.x;
    double newY = c.y;
    double newW = c.width;
    double newH = c.height;
    const minSize = 24.0;

    switch (pos) {
      case _HandlePosition.topLeft:
        newX = c.x + d.delta.dx;
        newY = c.y + d.delta.dy;
        newW = c.width - d.delta.dx;
        newH = c.height - d.delta.dy;
      case _HandlePosition.topCenter:
        newY = c.y + d.delta.dy;
        newH = c.height - d.delta.dy;
      case _HandlePosition.topRight:
        newY = c.y + d.delta.dy;
        newW = c.width + d.delta.dx;
        newH = c.height - d.delta.dy;
      case _HandlePosition.middleLeft:
        newX = c.x + d.delta.dx;
        newW = c.width - d.delta.dx;
      case _HandlePosition.middleRight:
        newW = c.width + d.delta.dx;
      case _HandlePosition.bottomLeft:
        newX = c.x + d.delta.dx;
        newW = c.width - d.delta.dx;
        newH = c.height + d.delta.dy;
      case _HandlePosition.bottomCenter:
        newH = c.height + d.delta.dy;
      case _HandlePosition.bottomRight:
        newW = c.width + d.delta.dx;
        newH = c.height + d.delta.dy;
      case _HandlePosition.rotation:
        return;
    }

    if (newW < minSize) {
      if (pos == _HandlePosition.topLeft ||
          pos == _HandlePosition.middleLeft ||
          pos == _HandlePosition.bottomLeft) {
        newX = c.x + c.width - minSize;
      }
      newW = minSize;
    }
    if (newH < minSize) {
      if (pos == _HandlePosition.topLeft ||
          pos == _HandlePosition.topCenter ||
          pos == _HandlePosition.topRight) {
        newY = c.y + c.height - minSize;
      }
      newH = minSize;
    }

    widget.onResize(newW, newH, newX, newY);
    // Update live tooltip
    setState(() {
      _resizeW = newW;
      _resizeH = newH;
    });
  }

  // ═══════════════════════════════════════════════════════════
  // ROTATION HANDLE
  // ═══════════════════════════════════════════════════════════

  Widget _buildRotationHandle(AbsoluteLayoutComponent c) {
    return Positioned(
      left: c.width / 2 - 4,
      top: -_rotationArmLength,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (_) {},
        onPanUpdate: (d) => _onRotateDrag(d, c),
        onPanEnd: (_) => widget.onRotateEnd(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Arm
            Container(
              width: 5,
              height: _rotationArmLength - _rotationKnobSize / 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFF97316).withOpacity(0.9),
                    Colors.white70,
                  ],
                ),
              ),
            ),
            // Knob
            Container(
              width: _rotationKnobSize,
              height: _rotationKnobSize,
              decoration: BoxDecoration(
                color: const Color(0xFFF97316),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.sync, color: Colors.white, size: 24),
            ),
          ],
        ),
      ),
    );
  }

  void _onRotateDrag(DragUpdateDetails d, AbsoluteLayoutComponent c) {
    // Rotation by horizontal drag — 1px ≈ 1° for more responsive feel
    final deltaAngle = d.delta.dx * 1.0;
    double newRotation = (c.rotation + deltaAngle) % 360;
    if (newRotation < 0) newRotation += 360;
    widget.onRotate(newRotation);
  }
}

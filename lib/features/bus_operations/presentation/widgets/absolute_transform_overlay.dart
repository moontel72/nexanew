// NEXATRACE — ABSOLUTE TRANSFORM OVERLAY
// =========================================
// Resize and rotation overlay for selected components on the absolute canvas.
//
// Draws 8 resize handles (4 corners + 4 midpoints) and a rotation handle
// (top-center extended arm) when a component is selected. Handles fire
// callbacks for live resize and rotation.
//
// 100% isolated from legacy system.

import 'package:flutter/material.dart';
import 'package:trace_odd/shared/models/transport/absolute_layout_component.dart';

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

/// Callback signatures.
typedef OnResize =
    void Function(double newWidth, double newHeight, double newX, double newY);
typedef OnResizeEnd = void Function();
typedef OnRotate = void Function(double newRotation);
typedef OnRotateEnd = void Function();

class AbsoluteTransformOverlay extends StatefulWidget {
  final AbsoluteLayoutComponent component;
  final OnResize onResize;
  final OnResizeEnd onResizeEnd;
  final OnRotate onRotate;
  final OnRotateEnd onRotateEnd;

  const AbsoluteTransformOverlay({
    super.key,
    required this.component,
    required this.onResize,
    required this.onResizeEnd,
    required this.onRotate,
    required this.onRotateEnd,
  });

  @override
  State<AbsoluteTransformOverlay> createState() =>
      _AbsoluteTransformOverlayState();
}

class _AbsoluteTransformOverlayState extends State<AbsoluteTransformOverlay> {
  static const double _handleSize = 10.0;
  static const double _rotationArmLength = 28.0;

  @override
  Widget build(BuildContext context) {
    final c = widget.component;

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
            // Selection border
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withOpacity(0.9),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            // 4 corner handles
            _buildHandle(_HandlePosition.topLeft, c),
            _buildHandle(_HandlePosition.topRight, c),
            _buildHandle(_HandlePosition.bottomLeft, c),
            _buildHandle(_HandlePosition.bottomRight, c),
            // 4 midpoint handles
            _buildHandle(_HandlePosition.topCenter, c),
            _buildHandle(_HandlePosition.bottomCenter, c),
            _buildHandle(_HandlePosition.middleLeft, c),
            _buildHandle(_HandlePosition.middleRight, c),
            // Rotation handle (top-center extended arm)
            _buildRotationHandle(c),
          ],
        ),
      ),
    );
  }

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
        onPanUpdate: (d) => _onResizeDrag(pos, d),
        onPanEnd: (_) => widget.onResizeEnd(),
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
        // Rotation is handled separately
        return;
    }

    // Enforce minimum size
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
  }

  // ─── Rotation Handle ──────────────────────────────────────

  Widget _buildRotationHandle(AbsoluteLayoutComponent c) {
    return Positioned(
      left: c.width / 2 - 3, // line thickness
      top: -_rotationArmLength,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Vertical line
          Container(
            width: 2,
            height: _rotationArmLength - _handleSize,
            color: Colors.white70,
          ),
          // Rotation knob
          GestureDetector(
            onPanUpdate: (d) => _onRotateDrag(d, c),
            onPanEnd: (_) => widget.onRotateEnd(),
            child: Container(
              width: _handleSize,
              height: _handleSize,
              decoration: const BoxDecoration(
                color: Color(0xFFF97316),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.rotate_right,
                color: Colors.white,
                size: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onRotateDrag(DragUpdateDetails d, AbsoluteLayoutComponent c) {
    // Snapping behaviour: use delta to increment rotation
    final deltaAngle = d.delta.dx * 0.5; // 1px horizontal ≈ 0.5° rotation
    double newRotation = (c.rotation + deltaAngle) % 360;
    if (newRotation < 0) newRotation += 360;
    widget.onRotate(newRotation);
  }
}

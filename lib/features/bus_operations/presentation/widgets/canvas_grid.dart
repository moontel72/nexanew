// NEXATRACE — CANVAS GRID WIDGET
// =================================
// Interactive grid canvas for the component-based seat layout designer.
// Renders the grid with placed components as a 2D interactive view.
//
// Uses InteractiveViewer for pan/zoom, CustomPaint for grid lines,
// and Positioned widgets for components within a Stack.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/features/bus_operations/domain/models/layout_component.dart';
import 'package:trace_odd/features/bus_operations/domain/models/layout_canvas_state.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/canvas/layout_canvas_bloc.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/canvas/layout_canvas_state_bloc.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/canvas/layout_canvas_event.dart';

/// Cell size in logical pixels.
const double kCellSize = 56.0;

/// Colors for component types on the canvas.
const Map<ComponentType, Color> kComponentColors = {
  ComponentType.seat: Color(0xFF7C3AED),
  ComponentType.sleeperLower: Color(0xFFDB2777),
  ComponentType.sleeperUpper: Color(0xFFF97316),
  ComponentType.foldingSeat: Color(0xFF06B6D4),
  ComponentType.aisle: Color(0xFF334155),
  ComponentType.exitDoor: Color(0xFFEF4444),
  ComponentType.driverCabin: Color(0xFF1E293B),
  ComponentType.emergency: Color(0xFFDC2626),
  ComponentType.lavatory: Color(0xFF6366F1),
  ComponentType.empty: Color(0xFF1A2533),
};

/// Icons for component types.
const Map<ComponentType, IconData> kComponentIcons = {
  ComponentType.seat: Icons.event_seat,
  ComponentType.sleeperLower: Icons.airline_seat_flat,
  ComponentType.sleeperUpper: Icons.airline_seat_flat_angled,
  ComponentType.foldingSeat: Icons.chair_alt,
  ComponentType.aisle: Icons.more_horiz,
  ComponentType.exitDoor: Icons.door_front_door,
  ComponentType.driverCabin: Icons.settings_accessibility,
  ComponentType.emergency: Icons.warning_amber_rounded,
  ComponentType.lavatory: Icons.wc,
  ComponentType.empty: Icons.grid_view,
};

class CanvasGrid extends StatelessWidget {
  final LayoutCanvasState canvasState;
  final void Function(String componentId)? onComponentTap;
  final void Function(int row, int col)? onEmptyCellTap;

  const CanvasGrid({
    super.key,
    required this.canvasState,
    this.onComponentTap,
    this.onEmptyCellTap,
  });

  @override
  Widget build(BuildContext context) {
    final gridWidth = canvasState.maxCols * kCellSize;
    final gridHeight = canvasState.maxRows * kCellSize;

    return InteractiveViewer(
      constrained: false,
      boundaryMargin: const EdgeInsets.all(100),
      minScale: 0.3,
      maxScale: 2.5,
      child: RepaintBoundary(
        child: SizedBox(
          width: gridWidth + kCellSize, // +1 for row labels
          height: gridHeight + kCellSize, // +1 for col headers
          child: Stack(
            children: [
              // Grid lines
              Positioned.fill(child: _GridPainter(canvasState: canvasState)),
              // Column headers (A, B, C…)
              ..._buildColumnHeaders(),
              // Row labels (1, 2, 3…)
              ..._buildRowLabels(),
              // Placed components
              ...canvasState.components
                  .where((c) => c.type != ComponentType.empty)
                  .map(
                    (comp) => _ComponentTile(
                      component: comp,
                      onTap: onComponentTap != null
                          ? () => onComponentTap!(comp.id)
                          : null,
                    ),
                  ),
              // Empty cell tap targets (for placing new components via tap)
              ..._buildEmptyCellTargets(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildColumnHeaders() {
    final letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    return List.generate(canvasState.maxCols, (c) {
      return Positioned(
        left: kCellSize + c * kCellSize,
        top: 0,
        width: kCellSize,
        height: kCellSize,
        child: Center(
          child: Text(
            letters[c.clamp(0, 25)],
            style: const TextStyle(
              color: Color(0xFFAABBCC),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    });
  }

  List<Widget> _buildRowLabels() {
    return List.generate(canvasState.maxRows, (r) {
      return Positioned(
        left: 0,
        top: kCellSize + r * kCellSize,
        width: kCellSize,
        height: kCellSize,
        child: Center(
          child: Text(
            '${r + 1}',
            style: const TextStyle(
              color: Color(0xFFAABBCC),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    });
  }

  /// Build tap targets for empty cells so users can tap-to-place.
  List<Widget> _buildEmptyCellTargets() {
    final targets = <Widget>[];
    for (int r = 0; r < canvasState.maxRows; r++) {
      for (int c = 0; c < canvasState.maxCols; c++) {
        final occupied = canvasState.isOccupied(r + 1, c + 1);
        if (!occupied && onEmptyCellTap != null) {
          final row = r + 1;
          final col = c + 1;
          targets.add(
            Positioned(
              left: kCellSize + c * kCellSize,
              top: kCellSize + r * kCellSize,
              width: kCellSize,
              height: kCellSize,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onEmptyCellTap!(row, col),
              ),
            ),
          );
        }
      }
    }
    return targets;
  }
}

/// Paints the grid lines on the canvas.
class _GridPainter extends StatelessWidget {
  final LayoutCanvasState canvasState;
  const _GridPainter({required this.canvasState});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridLinesPainter(
        rows: canvasState.maxRows,
        cols: canvasState.maxCols,
        cellSize: kCellSize,
      ),
      size: Size(
        canvasState.maxCols * kCellSize + kCellSize,
        canvasState.maxRows * kCellSize + kCellSize,
      ),
    );
  }
}

class _GridLinesPainter extends CustomPainter {
  final int rows;
  final int cols;
  final double cellSize;

  _GridLinesPainter({
    required this.rows,
    required this.cols,
    required this.cellSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x15FFFFFF)
      ..strokeWidth = 1;

    // Vertical lines
    for (int c = 0; c <= cols; c++) {
      final x = cellSize + c * cellSize;
      canvas.drawLine(Offset(x, cellSize), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (int r = 0; r <= rows; r++) {
      final y = cellSize + r * cellSize;
      canvas.drawLine(Offset(cellSize, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridLinesPainter oldDelegate) =>
      rows != oldDelegate.rows || cols != oldDelegate.cols;
}

/// Renders a single placed component on the canvas.
class _ComponentTile extends StatefulWidget {
  final LayoutComponent component;
  final VoidCallback? onTap;

  const _ComponentTile({required this.component, this.onTap});

  @override
  State<_ComponentTile> createState() => _ComponentTileState();
}

class _ComponentTileState extends State<_ComponentTile> {
  bool _isHovered = false;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final comp = widget.component;
    final left = kCellSize + (comp.originCol - 1) * kCellSize;
    final top = kCellSize + (comp.originRow - 1) * kCellSize;
    final width = comp.spanCols * kCellSize;
    final height = comp.spanRows * kCellSize;
    final color =
        kComponentColors[comp.type] ?? kComponentColors[ComponentType.empty]!;
    final icon = kComponentIcons[comp.type] ?? Icons.help_outline;

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          onLongPressStart: comp.isEditable
              ? (_) {
                  setState(() => _isDragging = true);
                }
              : null,
          onLongPressEnd: comp.isEditable
              ? (_) {
                  setState(() => _isDragging = false);
                }
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: _isHovered
                  ? color.withValues(alpha: 0.35)
                  : color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(comp.isMultiCell ? 8 : 6),
              border: Border.all(
                color: _isHovered
                    ? color.withValues(alpha: 0.8)
                    : color.withValues(alpha: 0.3),
                width: _isHovered ? 2 : 1,
              ),
              boxShadow: _isDragging
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color.withValues(alpha: 0.9), size: 18),
                if (comp.seatId != null && comp.seatId!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      comp.seatId!,
                      style: TextStyle(
                        color: color.withValues(alpha: 0.9),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                if (comp.isMultiCell)
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(
                      '${comp.spanRows}×${comp.spanCols}',
                      style: TextStyle(
                        color: color.withValues(alpha: 0.5),
                        fontSize: 8,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

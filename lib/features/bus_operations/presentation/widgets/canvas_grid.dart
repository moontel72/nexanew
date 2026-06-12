// NEXATRACE — CANVAS GRID WIDGET
// =================================
// Interactive grid canvas for the component-based seat layout designer.
// Renders the grid with placed components as a 2D interactive view.
//
// Uses InteractiveViewer for pan/zoom, CustomPaint for grid lines,
// and Positioned widgets for components within a Stack.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/shared/models/transport/layout_component.dart';
import 'package:trace_odd/shared/models/transport/layout_canvas_state.dart';
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
  ComponentType.restaurantTable: Color(0xFF059669),
  ComponentType.businessClassSeat: Color(0xFFD97706),
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
  ComponentType.restaurantTable: Icons.table_restaurant,
  ComponentType.businessClassSeat: Icons.airline_seat_flat_angled,
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

  /// Get column widths for a given row (flex overrides or uniform).
  /// Auto-detects business class rows missing explicit flex overrides.
  List<double> _rowColumns(int row) {
    final overrides = canvasState.flexOverrides;
    if (overrides != null && overrides.containsKey(row)) {
      return overrides[row]!;
    }
    // Auto-detect: if this row has a businessClassSeat, compute flex widths
    final hasBizSeat = canvasState.components.any(
      (c) =>
          c.type == ComponentType.businessClassSeat &&
          c.originRow <= row &&
          c.originRow + c.spanRows - 1 >= row,
    );
    if (hasBizSeat) {
      final meta = canvasState.metadata;
      final leftCols =
          (meta['left_cols'] as int?) ??
          ((canvasState.maxCols - 1) ~/ 2).clamp(1, 3);
      final rightCols =
          (meta['right_cols'] as int?) ??
          ((canvasState.maxCols - 1) ~/ 2).clamp(1, 3);
      return <double>[
        kCellSize * leftCols,
        kCellSize,
        for (int i = 0; i < rightCols; i++) kCellSize,
      ];
    }
    return List.generate(canvasState.maxCols, (_) => kCellSize);
  }

  /// Pixel left-edge of a grid cell at (row, col), 1-based.
  double _cellLeft(int row, int col) {
    final cols = _rowColumns(row);
    double x = kCellSize; // offset for row labels
    for (int c = 1; c < col && c <= cols.length; c++) {
      x += cols[c - 1];
    }
    return x;
  }

  /// Pixel width of a component at (row, col) with given spans.
  double _componentWidth(int row, int col, int spanCols) {
    final cols = _rowColumns(row);
    double w = 0;
    for (int c = col; c < col + spanCols && c <= cols.length; c++) {
      w += cols[c - 1];
    }
    return w;
  }

  /// Total canvas pixel width (uses the widest row).
  double get _totalWidth {
    double maxW = canvasState.maxCols * kCellSize;
    final overrides = canvasState.flexOverrides;
    if (overrides != null) {
      for (final cols in overrides.values) {
        double w = cols.fold(0.0, (a, b) => a + b);
        if (w > maxW) maxW = w;
      }
    }
    return maxW;
  }

  @override
  Widget build(BuildContext context) {
    final gridWidth = _totalWidth;
    final gridHeight = canvasState.maxRows * kCellSize;

    return InteractiveViewer(
      constrained: false,
      boundaryMargin: const EdgeInsets.all(100),
      minScale: 0.3,
      maxScale: 2.5,
      child: RepaintBoundary(
        child: SizedBox(
          width: gridWidth + kCellSize,
          height: gridHeight + kCellSize,
          child: Stack(
            children: [
              Positioned.fill(
                child: _GridPainter(
                  canvasState: canvasState,
                  getRowColumns: _rowColumns,
                ),
              ),
              ..._buildColumnHeaders(),
              ..._buildRowLabels(),
              ...canvasState.components
                  .where((c) => c.type != ComponentType.empty)
                  .map(
                    (comp) => _ComponentTile(
                      component: comp,
                      left: _cellLeft(comp.originRow, comp.originCol),
                      top: kCellSize + (comp.originRow - 1) * kCellSize,
                      width: _componentWidth(
                        comp.originRow,
                        comp.originCol,
                        comp.spanCols,
                      ),
                      height: comp.spanRows * kCellSize,
                      onTap: onComponentTap != null
                          ? () => onComponentTap!(comp.id)
                          : null,
                    ),
                  ),
              ..._buildEmptyCellTargets(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildColumnHeaders() {
    // Use maxCols for header count; flex rows may have fewer columns
    // but we still show canonical column letters.
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

  List<Widget> _buildEmptyCellTargets() {
    final targets = <Widget>[];
    for (int r = 0; r < canvasState.maxRows; r++) {
      final row = r + 1;
      final cols = _rowColumns(row);
      for (int c = 0; c < cols.length; c++) {
        final col = c + 1;
        final occupied = canvasState.isOccupied(row, col);
        if (!occupied && onEmptyCellTap != null) {
          targets.add(
            Positioned(
              left: _cellLeft(row, col),
              top: kCellSize + r * kCellSize,
              width: cols[c],
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
  final List<double> Function(int row) getRowColumns;
  const _GridPainter({required this.canvasState, required this.getRowColumns});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridLinesPainter(
        rows: canvasState.maxRows,
        getRowColumns: getRowColumns,
        hasFlexOverrides:
            canvasState.flexOverrides != null &&
            canvasState.flexOverrides!.isNotEmpty,
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
  final List<double> Function(int row) getRowColumns;
  final bool hasFlexOverrides;

  _GridLinesPainter({
    required this.rows,
    required this.getRowColumns,
    required this.hasFlexOverrides,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x15FFFFFF)
      ..strokeWidth = 1;

    final flexPaint = Paint()
      ..color = const Color(0xFFD97706).withValues(alpha: 0.25)
      ..strokeWidth = 2;

    // Horizontal lines (always uniform)
    for (int r = 0; r <= rows; r++) {
      final y = kCellSize + r * kCellSize;
      canvas.drawLine(Offset(kCellSize, y), Offset(size.width, y), paint);
    }

    if (!hasFlexOverrides) {
      // Simple uniform vertical lines
      // Note: we don't know exact col count here, draw based on maxCols
      for (int c = 0; c <= 12; c++) {
        final x = kCellSize + c * kCellSize;
        if (x > size.width) break;
        canvas.drawLine(Offset(x, kCellSize), Offset(x, size.height), paint);
      }
      return;
    }

    // Per-row varying vertical lines
    for (int r = 1; r <= rows; r++) {
      final cols = getRowColumns(r);
      final isFlexRow =
          cols.length < 12 && cols.any((w) => (w - kCellSize).abs() > 1);

      double x = kCellSize;
      final yTop = kCellSize + (r - 1) * kCellSize;
      final yBot = yTop + kCellSize;

      for (int c = 0; c <= cols.length; c++) {
        // Left edge of this column (or right edge of last)
        if (c > 0) x += cols[c - 1];

        // Draw vertical segment for this row only
        final linePaint = isFlexRow ? flexPaint : paint;
        canvas.drawLine(Offset(x, yTop), Offset(x, yBot), linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridLinesPainter oldDelegate) =>
      rows != oldDelegate.rows ||
      hasFlexOverrides != oldDelegate.hasFlexOverrides;
}

/// Renders a single placed component on the canvas.
class _ComponentTile extends StatefulWidget {
  final LayoutComponent component;
  final double left;
  final double top;
  final double width;
  final double height;
  final VoidCallback? onTap;

  const _ComponentTile({
    required this.component,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    this.onTap,
  });

  @override
  State<_ComponentTile> createState() => _ComponentTileState();
}

class _ComponentTileState extends State<_ComponentTile> {
  bool _isHovered = false;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final comp = widget.component;
    final left = widget.left;
    final top = widget.top;
    final width = widget.width;
    final height = widget.height;
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
            child: comp.hasCustomRender
                ? _buildCustomRender(comp, color)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: color.withValues(alpha: 0.9), size: 18),
                      if (comp.displayLabel != null &&
                          comp.displayLabel!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            comp.displayLabel!,
                            style: TextStyle(
                              color: color.withValues(alpha: 0.9),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      if (comp.isMultiCell && !comp.hasCustomRender)
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

  /// Custom sub-layout renderer for composite components (e.g. restaurant table).
  Widget _buildCustomRender(LayoutComponent comp, Color color) {
    if (comp.type == ComponentType.restaurantTable) {
      return _buildRestaurantTableRender(comp, color);
    }
    if (comp.type == ComponentType.businessClassSeat) {
      return _buildBusinessClassSeatRender(comp, color);
    }
    return const SizedBox.shrink();
  }

  /// Restaurant Table Module — 2×2 grid with 4 seats facing a central table.
  Widget _buildRestaurantTableRender(LayoutComponent comp, Color color) {
    final iconColor = color.withValues(alpha: 0.9);
    final bgColor = color.withValues(alpha: 0.12);
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background
        Container(
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        // Central dining table
        Center(
          child: Container(
            width: 44,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF8B4513).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: const Color(0xFFD2691E).withValues(alpha: 0.8),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.table_restaurant,
              color: Colors.white70,
              size: 16,
            ),
          ),
        ),
        // Top-left seat (forward-facing)
        Positioned(
          top: 8,
          left: 8,
          child: _miniSeatIcon(Icons.event_seat, iconColor),
        ),
        // Top-right seat (forward-facing)
        Positioned(
          top: 8,
          right: 8,
          child: _miniSeatIcon(Icons.event_seat, iconColor),
        ),
        // Bottom-left seat (rear-facing)
        Positioned(
          bottom: 8,
          left: 8,
          child: Transform.rotate(
            angle: 3.14159,
            child: _miniSeatIcon(Icons.event_seat, iconColor),
          ),
        ),
        // Bottom-right seat (rear-facing)
        Positioned(
          bottom: 8,
          right: 8,
          child: Transform.rotate(
            angle: 3.14159,
            child: _miniSeatIcon(Icons.event_seat, iconColor),
          ),
        ),
        // Label at bottom center
        Positioned(
          bottom: 1,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              comp.displayLabel ?? 'DINE',
              style: TextStyle(
                color: iconColor,
                fontSize: 8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _miniSeatIcon(IconData icon, Color color) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, size: 12, color: color),
    );
  }

  /// Business Class Seat — premium wide seat with gold accent border.
  Widget _buildBusinessClassSeatRender(LayoutComponent comp, Color color) {
    final goldColor = const Color(0xFFD97706);
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: goldColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: goldColor.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: goldColor.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.airline_seat_flat_angled,
            color: Color(0xFFFBBF24),
            size: 24,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: goldColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'BUSINESS',
              style: TextStyle(
                color: goldColor,
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
          if (comp.displayLabel != null && comp.displayLabel!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                comp.displayLabel!,
                style: TextStyle(
                  color: goldColor.withValues(alpha: 0.9),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

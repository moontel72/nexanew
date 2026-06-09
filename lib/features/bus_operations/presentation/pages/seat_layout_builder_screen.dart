// NEXATRACE — SEAT LAYOUT BUILDER (Blank Slate)
// =================================================
// No presets. Owner enters plate, brand, model, rows, cols.
// Gets a completely blank grid. Taps cells to manually assign
// Seat / Aisle / Folding / Sleeper / Driver / Door / Lavatory.
//
// Pakistani transport support: 3+2, 2+1, any row/col config.

import 'package:flutter/material.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/shared/theme/colors.dart';

// ─── Cell Types ────────────────────────────────────
enum BuilderCellType {
  empty,
  seat,
  aisle,
  foldingSeat,
  sleeperLower,
  sleeperUpper,
  driverCabin,
  exitDoor,
  emergency,
  lavatory,
}

const _cellLabels = {
  BuilderCellType.seat: 'Seat',
  BuilderCellType.aisle: 'Aisle (Walkway)',
  BuilderCellType.foldingSeat: 'Folding Seat (2-in-1)',
  BuilderCellType.sleeperLower: 'Sleeper Berth (Lower)',
  BuilderCellType.sleeperUpper: 'Sleeper Berth (Upper)',
  BuilderCellType.driverCabin: 'Driver Cabin',
  BuilderCellType.exitDoor: 'Exit / Front Door',
  BuilderCellType.emergency: 'Emergency Exit',
  BuilderCellType.lavatory: 'Lavatory / Bathroom',
};

const _cellIcons = {
  BuilderCellType.seat: Icons.event_seat,
  BuilderCellType.aisle: Icons.remove,
  BuilderCellType.foldingSeat: Icons.chair_alt,
  BuilderCellType.sleeperLower: Icons.airline_seat_flat,
  BuilderCellType.sleeperUpper: Icons.airline_seat_flat_angled,
  BuilderCellType.driverCabin: Icons.settings_accessibility,
  BuilderCellType.exitDoor: Icons.door_front_door,
  BuilderCellType.emergency: Icons.warning_amber_rounded,
  BuilderCellType.lavatory: Icons.wc,
};

const _cellColors = {
  BuilderCellType.seat: Color(0xFF7C3AED),
  BuilderCellType.aisle: Color(0xFF64748B),
  BuilderCellType.foldingSeat: Color(0xFF06B6D4),
  BuilderCellType.sleeperLower: Color(0xFFDB2777),
  BuilderCellType.sleeperUpper: Color(0xFFF97316),
  BuilderCellType.driverCabin: Color(0xFF1E293B),
  BuilderCellType.exitDoor: Color(0xFFEF4444),
  BuilderCellType.emergency: Color(0xFFDC2626),
  BuilderCellType.lavatory: Color(0xFF6366F1),
  BuilderCellType.empty: Color(0xFF334155),
};

class _GridCell {
  BuilderCellType type;
  String? label;
  _GridCell({this.type = BuilderCellType.empty, this.label});
}

// ─── Main Screen ────────────────────────────────────
class SeatLayoutBuilderScreen extends StatefulWidget {
  final String companyId;
  final String? companyName;

  const SeatLayoutBuilderScreen({
    super.key,
    required this.companyId,
    this.companyName,
  });

  @override
  State<SeatLayoutBuilderScreen> createState() =>
      _SeatLayoutBuilderScreenState();
}

class _SeatLayoutBuilderScreenState extends State<SeatLayoutBuilderScreen> {
  int _step = 0; // 0=details, 1=grid, 2=saving
  final _plateCtl = TextEditingController();
  final _brandCtl = TextEditingController();
  final _modelCtl = TextEditingController();
  int _rows = 12, _cols = 4;
  List<List<_GridCell>> _grid = [];
  List<List<_GridCell>> _upperGrid = []; // upper deck
  bool _isUpperDeck = false;
  bool _hasUpperDeck = false;
  bool _selectMode = false;
  final _selectedCells = <int>{}; // keys: r*100+c
  bool _saving = false;
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _plateCtl.dispose();
    _brandCtl.dispose();
    _modelCtl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text(
          _step == 0
              ? 'New Seat Layout'
              : _step == 1
              ? 'Assign Seats'
              : 'Saving...',
        ),
        backgroundColor: const Color(0xFF162438),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_step == 0) {
              Navigator.pop(context);
            } else {
              setState(() => _step--);
            }
          },
        ),
        actions: [
          if (_step == 1)
            TextButton.icon(
              onPressed: _saving ? null : _saveLayout,
              icon: const Icon(Icons.save, color: Color(0xFF4ADE80)),
              label: const Text(
                'Save',
                style: TextStyle(color: Color(0xFF4ADE80)),
              ),
            ),
        ],
      ),
      body: _step == 0 ? _buildDetailsStep() : _buildGridStep(),
    );
  }

  // ── Step 0: Bus Details ────────────────────────────
  Widget _buildDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bus Information',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Enter the details of your vehicle',
            style: TextStyle(color: Color(0xFF8899AA), fontSize: 13),
          ),
          const SizedBox(height: 24),

          _inputField(
            _plateCtl,
            'Bus Registration / Number Plate *',
            'e.g. LES-26-1122',
            Icons.directions_bus,
          ),
          const SizedBox(height: 14),
          _inputField(
            _brandCtl,
            'Manufacturer / Brand',
            'e.g. Daewoo, Yutong, Higer',
            Icons.factory,
          ),
          const SizedBox(height: 14),
          _inputField(
            _modelCtl,
            'Bus Model / Category',
            'e.g. Executive 2+1, Business 3+2, Luxury Sleeper',
            Icons.category,
          ),
          const SizedBox(height: 24),

          const Text(
            'Canvas Dimensions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Define your grid size (e.g. 12 rows × 5 cols for 3+2)',
            style: TextStyle(color: Color(0xFF8899AA), fontSize: 13),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _numberField(
                  'Rows',
                  _rows,
                  3,
                  20,
                  (v) => setState(() => _rows = v),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _numberField(
                  'Columns',
                  _cols,
                  2,
                  8,
                  (v) => setState(() => _cols = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF112233),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF2A3A4A)),
            ),
            child: Text(
              'Grid: $_rows rows × $_cols columns = ${_rows * _cols} total cells',
              style: const TextStyle(color: Color(0xFF8899AA), fontSize: 13),
            ),
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                if (_plateCtl.text.trim().isEmpty) {
                  _snack('Please enter the bus plate number', AppColors.error);
                  return;
                }
                if (_brandCtl.text.trim().isEmpty) _brandCtl.text = 'Other';
                if (_modelCtl.text.trim().isEmpty) _modelCtl.text = 'Standard';
                _generateBlankGrid();
                setState(() => _step = 1);
              },
              icon: const Icon(Icons.grid_view),
              label: const Text(
                'Generate Blank Canvas',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 1: Grid Assignment ────────────────────────
  Widget _buildGridStep() {
    final activeGrid = _isUpperDeck && _hasUpperDeck ? _upperGrid : _grid;
    return Column(
      children: [
        // Back button row + Deck switcher + Select toggle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: () => setState(() => _step = 0),
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Back'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFAABBCC),
                ),
              ),
              const Spacer(),
              // Deck toggle
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _deckTab('Lower Deck', false),
                  const SizedBox(width: 4),
                  _deckTab('Upper Deck', true),
                ],
              ),
              const SizedBox(width: 8),
              // Select mode toggle
              _toolBtn(
                icon: _selectMode ? Icons.deselect : Icons.select_all,
                label: _selectMode ? 'Done' : 'Select',
                active: _selectMode,
                onTap: () => setState(() {
                  _selectMode = !_selectMode;
                  _selectedCells.clear();
                }),
              ),
              const Spacer(),
              if (_selectMode && _selectedCells.isNotEmpty)
                _toolBtn(
                  icon: Icons.layers,
                  label: 'Overlay Berth',
                  active: true,
                  color: const Color(0xFFF97316),
                  onTap: _applyUpperBerthOverlay,
                ),
              if (!_selectMode)
                Text(
                  '${_plateCtl.text}',
                  style: const TextStyle(
                    color: Color(0xFF667788),
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ),
        // Legend bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: const Color(0xFF112233),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text(
                  'Tap cells to assign ↓   ',
                  style: TextStyle(color: Color(0xFF8899AA), fontSize: 11),
                ),
                ...BuilderCellType.values
                    .where((t) => t != BuilderCellType.empty)
                    .map(
                      (t) => Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: (_cellColors[t] ?? Colors.grey)
                                    .withAlpha(180),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              _cellLabels[t]?.split('(').first.trim() ?? '',
                              style: const TextStyle(
                                color: Color(0xFFAABBCC),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
        // Stats bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          color: const Color(0xFF0A1625),
          child: Row(
            children: [
              _statBadge(
                'Seats',
                _countTypeIn(activeGrid, BuilderCellType.seat),
                const Color(0xFF7C3AED),
              ),
              const SizedBox(width: 10),
              _statBadge(
                'Folding',
                _countTypeIn(activeGrid, BuilderCellType.foldingSeat),
                const Color(0xFF06B6D4),
              ),
              const SizedBox(width: 10),
              _statBadge(
                'Berths',
                _countTypeIn(_grid, BuilderCellType.sleeperLower) +
                    _countTypeIn(_grid, BuilderCellType.sleeperUpper) +
                    (_hasUpperDeck
                        ? _countTypeIn(
                                _upperGrid,
                                BuilderCellType.sleeperLower,
                              ) +
                              _countTypeIn(
                                _upperGrid,
                                BuilderCellType.sleeperUpper,
                              )
                        : 0),
                const Color(0xFFDB2777),
              ),
              const SizedBox(width: 10),
              _statBadge(
                'Aisle',
                _countTypeIn(activeGrid, BuilderCellType.aisle),
                const Color(0xFF64748B),
              ),
              const Spacer(),
              Text(
                '${_rows}×$_cols ${_isUpperDeck ? 'UPPER' : 'LOWER'}',
                style: const TextStyle(color: Color(0xFF667788), fontSize: 11),
              ),
            ],
          ),
        ),
        // Grid — unified component renderer
        Expanded(
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _buildUnifiedGrid(activeGrid),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCell(_GridCell cell) {
    final type = cell.type;
    final color = _cellColors[type] ?? _cellColors[BuilderCellType.empty]!;
    final icon = _cellIcons[type] ?? Icons.add;
    final isEmpty = type == BuilderCellType.empty;

    return Container(
      decoration: BoxDecoration(
        color: isEmpty ? const Color(0xFF1A2533) : color.withAlpha(40),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isEmpty ? const Color(0xFF2A3A4A) : color.withAlpha(120),
          width: isEmpty ? 1 : 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isEmpty)
            Icon(
              Icons.add_circle_outline,
              size: 16,
              color: const Color(0xFF445566),
            )
          else
            Icon(icon, size: 16, color: color),
          if (cell.label != null && cell.label!.isNotEmpty)
            Text(
              cell.label!,
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }

  // ── Unified grid renderer (Stack + Positioned) ─────
  Widget _buildUnifiedGrid(List<List<_GridCell>> grid) {
    final rows = grid.length;
    final cols = grid.isNotEmpty ? grid[0].length : 0;
    if (rows == 0 || cols == 0) return const SizedBox.shrink();

    const cellW = 56.0, cellH = 46.0, gap = 3.0;

    // Phase 1: Discover multi-cell regions
    final visited = <int>{};
    final regions = <_Region>[];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (visited.contains(r * 100 + c)) continue;
        final type = grid[r][c].type;
        if (!_isMultiCellType(type)) continue;
        // Scan contiguous block
        int spanR = 1, spanC = 1;
        while (r + spanR < rows && grid[r + spanR][c].type == type) spanR++;
        while (c + spanC < cols && grid[r][c + spanC].type == type) spanC++;
        // Mark all cells in this block as visited
        for (int rr = r; rr < r + spanR; rr++) {
          for (int cc = c; cc < c + spanC; cc++) {
            visited.add(rr * 100 + cc);
          }
        }
        regions.add(_Region(r, c, spanR, spanC, type));
      }
    }

    final totalW = cols * (cellW + gap) + 48;
    final totalH = rows * (cellH + gap) + 20 + 60;

    // Determine overlapping cells (both decks occupied at same position)
    final hasOverlap = _hasUpperDeck && !_isUpperDeck;
    final overlapCells = <int>{};
    if (hasOverlap) {
      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          if (grid[r][c].type != BuilderCellType.empty &&
              _upperGrid[r][c].type != BuilderCellType.empty) {
            overlapCells.add(r * 100 + c);
          }
        }
      }
    }

    // Split-view overlapped cells: detect upper grid regions and render unified strips
    final splitWidgets = <Widget>[];
    if (hasOverlap) {
      final upperVisited = <int>{};
      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          if (upperVisited.contains(r * 100 + c)) continue;
          if (_upperGrid[r][c].type == BuilderCellType.empty) continue;
          // Found start of an upper region — find its extent
          final uType = _upperGrid[r][c].type;
          int spanR = 1, spanC = 1;
          while (r + spanR < rows && _upperGrid[r + spanR][c].type == uType)
            spanR++;
          while (c + spanC < cols && _upperGrid[r][c + spanC].type == uType)
            spanC++;
          // Mark visited
          for (int rr = r; rr < r + spanR; rr++)
            for (int cc = c; cc < c + spanC; cc++)
              upperVisited.add(rr * 100 + cc);

          // Mark lower cells as covered so they're skipped in single-cell rendering
          for (int rr = r; rr < r + spanR; rr++)
            for (int cc = c; cc < c + spanC; cc++)
              overlapCells.add(rr * 100 + cc);

          // Determine widths based on whether lower grid has berth content
          final lowerType = grid[r][c].type;
          final isBerthOverlap =
              lowerType == BuilderCellType.sleeperLower ||
              lowerType == BuilderCellType.sleeperUpper;
          final lowerW = isBerthOverlap ? 0.50 : 0.75;
          final upperW = isBerthOverlap ? 0.50 : 0.25;
          final lowerColor = _cellColors[lowerType] ?? Colors.grey;
          final upperColor = _cellColors[uType] ?? Colors.orange;
          final upperLabel = _upperGrid[r][c].label ?? '';

          // Build unified split-view block per region
          splitWidgets.add(
            Positioned(
              left: 48 + c * (cellW + gap),
              top: 20 + r * (cellH + gap),
              width: spanC * cellW + (spanC - 1) * gap,
              height: spanR * cellH + (spanR - 1) * gap,
              child: GestureDetector(
                onTap: () => _openCellPicker(r, c),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: upperColor.withAlpha(180),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Lower component (aisle side — 75% or 50%)
                      Expanded(
                        flex: (lowerW * 100).round(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: lowerColor.withAlpha(35),
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(6),
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _cellIcons[lowerType] ?? Icons.help,
                                  size: spanR > 1 ? 22 : 16,
                                  color: lowerColor,
                                ),
                                if (grid[r][c].label?.isNotEmpty == true)
                                  Text(
                                    grid[r][c].label!,
                                    style: TextStyle(
                                      color: lowerColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                Text(
                                  '${lowerType.name}',
                                  style: TextStyle(
                                    color: lowerColor.withAlpha(150),
                                    fontSize: 8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Upper berth (window/wall side — 25% or 50%)
                      Expanded(
                        flex: (upperW * 100).round(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: upperColor.withAlpha(50),
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(6),
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _cellIcons[uType] ?? Icons.airline_seat_flat,
                                  size: spanR > 1 ? 28 : 18,
                                  color: upperColor,
                                ),
                                if (upperLabel.isNotEmpty)
                                  Text(
                                    upperLabel,
                                    style: TextStyle(
                                      color: upperColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                Text(
                                  '${spanR}×${spanC} upper berth',
                                  style: TextStyle(
                                    color: upperColor.withAlpha(160),
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
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
    }

    return SizedBox(
      width: totalW,
      height: totalH,
      child: Stack(
        children: [
          // Column headers (A, B, C, ...)
          for (int c = 0; c < cols; c++)
            Positioned(
              left: 48 + c * (cellW + gap),
              top: 0,
              width: cellW,
              height: 16,
              child: Center(
                child: Text(
                  String.fromCharCode(65 + c),
                  style: const TextStyle(
                    color: Color(0xFFAABBCC),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

          // Row labels (1, 2, 3, ...)
          for (int r = 0; r < rows; r++)
            Positioned(
              left: 0,
              top: 20 + r * (cellH + gap),
              width: 44,
              height: cellH,
              child: Center(
                child: Text(
                  '${r + 1}',
                  style: const TextStyle(
                    color: Color(0xFF8899AA),
                    fontSize: 11,
                  ),
                ),
              ),
            ),

          // Single cells (not part of any multi-cell region, not overlapped)
          for (int r = 0; r < rows; r++)
            for (int c = 0; c < cols; c++)
              if (!visited.contains(r * 100 + c) &&
                  !overlapCells.contains(r * 100 + c))
                Positioned(
                  left: 48 + c * (cellW + gap),
                  top: 20 + r * (cellH + gap),
                  width: cellW,
                  height: cellH,
                  child: GestureDetector(
                    onTap: () {
                      if (_selectMode) {
                        setState(() {
                          final key = r * 100 + c;
                          if (_selectedCells.contains(key)) {
                            _selectedCells.remove(key);
                          } else {
                            _selectedCells.add(key);
                          }
                        });
                      } else {
                        _openCellPicker(r, c);
                      }
                    },
                    child: _buildSelectableCell(grid[r][c], r, c),
                  ),
                ),

          // Split-view overlapped cells
          ...splitWidgets,

          // Unified multi-cell components
          for (final region in regions)
            Positioned(
              left: 48 + region.c * (cellW + gap),
              top: 20 + region.r * (cellH + gap),
              width: region.sc * cellW + (region.sc - 1) * gap,
              height: region.sr * cellH + (region.sr - 1) * gap,
              child: GestureDetector(
                onTap: () => _openCellPicker(region.r, region.c),
                child: _buildUnifiedRegion(region, grid),
              ),
            ),
        ],
      ),
    );
  }

  bool _isMultiCellType(BuilderCellType type) =>
      type == BuilderCellType.sleeperLower ||
      type == BuilderCellType.sleeperUpper ||
      type == BuilderCellType.lavatory;

  Widget _buildUnifiedRegion(_Region region, List<List<_GridCell>> grid) {
    final cell = grid[region.r][region.c];
    final type = cell.type;
    final color = _cellColors[type] ?? Colors.grey;
    final icon = _cellIcons[type] ?? Icons.help;
    final label = cell.label ?? '';
    final isBerth =
        type == BuilderCellType.sleeperLower ||
        type == BuilderCellType.sleeperUpper;

    return Container(
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(160), width: 2),
        boxShadow: [
          BoxShadow(color: color.withAlpha(40), blurRadius: 8, spreadRadius: 1),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: isBerth ? 36 : 28, color: color),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: isBerth ? 16 : 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            '${region.sr}×${region.sc} berth',
            style: TextStyle(color: color.withAlpha(150), fontSize: 10),
          ),
        ],
      ),
    );
  }

  // ── Selectable cell with highlight ──────────────────
  Widget _buildSelectableCell(_GridCell cell, int r, int c) {
    final isSelected = _selectMode && _selectedCells.contains(r * 100 + c);
    final base = _buildCell(cell);
    if (!_selectMode) return base;
    return Stack(
      children: [
        base,
        if (isSelected)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF97316).withAlpha(35),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFF97316), width: 2),
              ),
              child: const Center(
                child: Icon(
                  Icons.check_circle,
                  color: Color(0xFFF97316),
                  size: 18,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── Mini toolbar button ─────────────────────────────
  Widget _toolBtn({
    required IconData icon,
    required String label,
    required bool active,
    Color? color,
    VoidCallback? onTap,
  }) {
    final c = color ?? const Color(0xFF7C3AED);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: active ? c.withAlpha(30) : const Color(0xFF1A2533),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: active ? c.withAlpha(120) : const Color(0xFF2A3A4A),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: active ? c : const Color(0xFF667788)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: active ? c : const Color(0xFF667788),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Apply upper berth overlay on selected cells ──────
  void _applyUpperBerthOverlay() {
    if (_selectedCells.isEmpty) return;
    final count = _selectedCells.length;
    setState(() {
      _hasUpperDeck = true;
      if (_upperGrid.isEmpty) {
        _upperGrid = List.generate(
          _rows,
          (_) => List.generate(_cols, (_) => _GridCell()),
        );
      }
      for (final key in _selectedCells) {
        final r = key ~/ 100;
        final c = key % 100;
        _upperGrid[r][c].type = BuilderCellType.sleeperUpper;
        _upperGrid[r][c].label = null;
      }
      _renumberGrid(_upperGrid);
      _selectMode = false;
      _selectedCells.clear();
    });
    _snack(
      'Upper berth overlaid on $count cells. Switch to Upper Deck to view.',
      AppColors.success,
    );
  }

  // ── Deck tab toggle ──────────────────────────────
  Widget _deckTab(String label, bool isUpper) {
    final isActive = isUpper ? _isUpperDeck : !_isUpperDeck;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isUpper) {
            _hasUpperDeck = true;
            if (_upperGrid.isEmpty) {
              _upperGrid = List.generate(
                _rows,
                (_) => List.generate(_cols, (_) => _GridCell()),
              );
            }
            _isUpperDeck = !_isUpperDeck;
          } else {
            _isUpperDeck = false;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF7C3AED).withAlpha(40)
              : const Color(0xFF1A2533),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? const Color(0xFF7C3AED).withAlpha(120)
                : const Color(0xFF2A3A4A),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFF7C3AED) : const Color(0xFF8899AA),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ── Cell Assignment Dialog (centered, fully scrollable) ──
  void _openCellPicker(int row, int col) {
    final grid = _isUpperDeck && _hasUpperDeck ? _upperGrid : _grid;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2A3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.touch_app, color: Color(0xFF7C3AED), size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Assign Row $row, Col ${String.fromCharCode(65 + col)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (grid[row][col].type != BuilderCellType.empty)
              TextButton(
                onPressed: () {
                  setState(() {
                    grid[row][col] = _GridCell();
                    _renumberSeats();
                  });
                  Navigator.pop(ctx);
                },
                child: const Text(
                  'Clear',
                  style: TextStyle(color: Color(0xFFEF4444)),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white70, size: 20),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
        titlePadding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
        content: SizedBox(
          width: 380,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 500),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final type in BuilderCellType.values)
                    if (type != BuilderCellType.empty)
                      _optionTile(ctx, type, row, col),
                ],
              ),
            ),
          ),
        ),
        contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      ),
    );
  }

  Widget _optionTile(BuildContext ctx, BuilderCellType type, int row, int col) {
    final grid = _isUpperDeck && _hasUpperDeck ? _upperGrid : _grid;
    final color = _cellColors[type] ?? Colors.grey;
    final icon = _cellIcons[type] ?? Icons.help;
    final label = _cellLabels[type] ?? type.name;
    final isSelected = grid[row][col].type == type;

    return Card(
      color: isSelected ? color.withAlpha(25) : const Color(0xFF112233),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? color.withAlpha(100) : const Color(0xFF2A3A4A),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          if (type == BuilderCellType.sleeperLower ||
              type == BuilderCellType.sleeperUpper) {
            // Auto-expand berth: 3 rows × 2 cols
            if (!_markBerthArea(row, col, type)) return;
          } else {
            setState(() {
              grid[row][col].type = type;
              grid[row][col].label = null;
            });
          }
          _renumberSeats();
          Navigator.pop(ctx);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? color : Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (type == BuilderCellType.foldingSeat)
                      const Text(
                        '2-in-1 Coaster seat — foldable for aisle access',
                        style: TextStyle(
                          color: Color(0xFF667788),
                          fontSize: 11,
                        ),
                      ),
                    if (type == BuilderCellType.sleeperLower ||
                        type == BuilderCellType.sleeperUpper)
                      const Text(
                        'Auto-expands 3 rows × 2 cols (6 cells)\n'
                        'Labeled L1, L2… (Lower) or U1, U2… (Upper)',
                        style: TextStyle(
                          color: Color(0xFF667788),
                          fontSize: 11,
                        ),
                      ),
                    if (type == BuilderCellType.aisle)
                      const Text(
                        'Walkway/path — not a bookable seat',
                        style: TextStyle(
                          color: Color(0xFF667788),
                          fontSize: 11,
                        ),
                      ),
                    if (type == BuilderCellType.driverCabin ||
                        type == BuilderCellType.exitDoor ||
                        type == BuilderCellType.emergency ||
                        type == BuilderCellType.lavatory)
                      const Text(
                        'Structural — not bookable',
                        style: TextStyle(
                          color: Color(0xFF667788),
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              if (isSelected) Icon(Icons.check_circle, color: color, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  // ── Generate blank grid ────────────────────────────
  void _generateBlankGrid() {
    _grid = List.generate(
      _rows,
      (_) => List.generate(_cols, (_) => _GridCell()),
    );
    _upperGrid = List.generate(
      _rows,
      (_) => List.generate(_cols, (_) => _GridCell()),
    );
  }

  // ── Mark berth area (3 rows × 2 cols) ──────────────
  /// Returns true if the berth was successfully placed.
  bool _markBerthArea(int startRow, int startCol, BuilderCellType berthType) {
    final grid = _isUpperDeck && _hasUpperDeck ? _upperGrid : _grid;
    // Bounds check: need 3 rows × 2 columns
    if (startRow + 2 >= _rows || startCol + 1 >= _cols) {
      _snack(
        'Not enough space for berth (needs 3 rows × 2 cols)',
        AppColors.error,
      );
      return false;
    }
    // Overlap check: all 6 cells must be empty
    for (int r = startRow; r < startRow + 3; r++) {
      for (int c = startCol; c < startCol + 2; c++) {
        if (grid[r][c].type != BuilderCellType.empty) {
          _snack('Berth area overlaps existing cells', AppColors.error);
          return false;
        }
      }
    }
    setState(() {
      for (int r = startRow; r < startRow + 3; r++) {
        for (int c = startCol; c < startCol + 2; c++) {
          grid[r][c].type = berthType;
          grid[r][c].label = null;
        }
      }
    });
    return true;
  }

  // ── Label a contiguous berth block (BFS) ────────────
  void _labelBerthBlock(
    int startRow,
    int startCol,
    String label,
    Map<int, Set<int>> visited,
    List<List<_GridCell>> grid,
  ) {
    final targetType = grid[startRow][startCol].type;
    final queue = <List<int>>[
      [startRow, startCol],
    ];
    visited.putIfAbsent(startRow, () => {});
    visited[startRow]!.add(startCol);

    while (queue.isNotEmpty) {
      final cur = queue.removeAt(0);
      final r = cur[0], c = cur[1];
      grid[r][c].label = label;

      // 4-directional neighbours
      const deltas = [
        [-1, 0],
        [1, 0],
        [0, -1],
        [0, 1],
      ];
      for (final delta in deltas) {
        final nr = r + delta[0];
        final nc = c + delta[1];
        if (nr < 0 || nr >= _rows || nc < 0 || nc >= _cols) continue;
        if ((visited[nr]?.contains(nc) ?? false)) continue;
        if (grid[nr][nc].type != targetType) continue;
        visited.putIfAbsent(nr, () => {});
        visited[nr]!.add(nc);
        queue.add([nr, nc]);
      }
    }
  }

  // ── Renumber seats & label berths (airline style) ───
  void _renumberSeats() {
    _renumberGrid(_grid);
    if (_hasUpperDeck) {
      _renumberGrid(_upperGrid);
    }
  }

  void _renumberGrid(List<List<_GridCell>> grid) {
    final visited = <int, Set<int>>{};
    int lowerCount = 0;
    int upperCount = 0;

    // ── First pass: find & label contiguous berth blocks ──
    for (int r = 0; r < grid.length; r++) {
      for (int c = 0; c < grid[r].length; c++) {
        if ((visited[r]?.contains(c) ?? false)) continue;
        final type = grid[r][c].type;
        if (type == BuilderCellType.sleeperLower) {
          lowerCount++;
          _labelBerthBlock(r, c, 'L$lowerCount', visited, grid);
        } else if (type == BuilderCellType.sleeperUpper) {
          upperCount++;
          _labelBerthBlock(r, c, 'U$upperCount', visited, grid);
        }
      }
    }

    // ── Second pass: airline-style seat numbering (row‑letter) ──
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    for (int r = 0; r < grid.length; r++) {
      int letterIdx = 0;
      for (int c = 0; c < grid[r].length; c++) {
        final cell = grid[r][c];
        // Skip non‑ticketable / non‑seat cells + already‑labeled berths
        if (cell.type == BuilderCellType.empty ||
            cell.type == BuilderCellType.aisle ||
            cell.type == BuilderCellType.driverCabin ||
            cell.type == BuilderCellType.exitDoor ||
            cell.type == BuilderCellType.emergency ||
            cell.type == BuilderCellType.lavatory ||
            cell.type == BuilderCellType.sleeperLower ||
            cell.type == BuilderCellType.sleeperUpper) {
          cell.label = null;
          continue;
        }
        // Ticketable seat-type cells (seat, foldingSeat)
        cell.label =
            '${r + 1}${letters[letterIdx < letters.length ? letterIdx : 0]}';
        letterIdx++;
      }
    }
  }

  // ── Count cells of a type in a specific grid ────────
  int _countTypeIn(List<List<_GridCell>> grid, BuilderCellType type) {
    int count = 0;
    for (final row in grid) {
      for (final cell in row) {
        if (cell.type == type) count++;
      }
    }
    return count;
  }

  // ── Save Layout ────────────────────────────────────
  Future<void> _saveLayout() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      final cells = <List<Map<String, dynamic>>>[];
      for (int r = 0; r < _grid.length; r++) {
        final row = <Map<String, dynamic>>[];
        for (int c = 0; c < _grid[r].length; c++) {
          final cell = _grid[r][c];
          row.add({
            'type': _backendTypeName(cell.type),
            'label': cell.label ?? '',
            'seat_id': cell.label,
          });
        }
        cells.add(row);
      }

      // Build upper deck data if present
      List<List<Map<String, dynamic>>>? upperCells;
      if (_hasUpperDeck) {
        upperCells = [];
        for (int r = 0; r < _upperGrid.length; r++) {
          final row = <Map<String, dynamic>>[];
          for (int c = 0; c < _upperGrid[r].length; c++) {
            final cell = _upperGrid[r][c];
            row.add({
              'type': _backendTypeName(cell.type),
              'label': cell.label ?? '',
              'seat_id': cell.label,
            });
          }
          upperCells.add(row);
        }
      }

      final res = await ApiService().post(
        '/bus-owner/layouts',
        data: {
          'bus_plate': _plateCtl.text.trim(),
          'bus_brand': _brandCtl.text.trim().isEmpty
              ? 'Other'
              : _brandCtl.text.trim(),
          'bus_category': _modelCtl.text.trim().isEmpty
              ? 'Standard'
              : _modelCtl.text.trim(),
          'total_rows': _rows,
          'total_cols': _cols,
          'aisle_after_col': 0,
          'grid': cells,
          if (_hasUpperDeck) 'upper_grid': upperCells,
          'has_upper_deck': _hasUpperDeck,
        },
      );

      if (res is Map && res['success'] == true) {
        if (mounted) {
          _snack('Layout saved!', AppColors.success);
          Navigator.pop(context, true);
        }
      } else {
        _snack(
          (res is Map ? res['message'] : null) ?? 'Failed to save',
          AppColors.error,
        );
      }
    } catch (e) {
      _snack('Error: $e', AppColors.error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── Helpers ────────────────────────────────────────
  /// Map builder enum names to backend-expected strings.
  String _backendTypeName(BuilderCellType type) => switch (type) {
    BuilderCellType.empty => 'empty',
    BuilderCellType.seat => 'seat',
    BuilderCellType.aisle => 'aisle',
    BuilderCellType.foldingSeat => 'folding',
    BuilderCellType.sleeperLower => 'sleeperLower',
    BuilderCellType.sleeperUpper => 'sleeperUpper',
    BuilderCellType.driverCabin => 'driver',
    BuilderCellType.exitDoor => 'exitDoor',
    BuilderCellType.emergency => 'emergency',
    BuilderCellType.lavatory => 'lavatory',
  };

  Widget _inputField(
    TextEditingController ctl,
    String label,
    String hint,
    IconData icon,
  ) {
    return TextField(
      controller: ctl,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Color(0xFF8899AA)),
        hintStyle: const TextStyle(color: Color(0xFF556677)),
        prefixIcon: Icon(icon, color: const Color(0xFF556677)),
        filled: true,
        fillColor: const Color(0xFF0D1B2A),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF2A3A4A)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF7C3AED)),
        ),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF2A3A4A)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _numberField(
    String label,
    int value,
    int min,
    int max,
    ValueChanged<int> onChange,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFAABBCC),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0D1B2A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF2A3A4A)),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove, color: Color(0xFF7C3AED)),
                onPressed: value > min ? () => onChange(value - 1) : null,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '$value',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Color(0xFF7C3AED)),
                onPressed: value < max ? () => onChange(value + 1) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statBadge(String label, int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: $count',
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _snack(String msg, Color bg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ── Multi-cell region descriptor ───────────────────
class _Region {
  final int r, c, sr, sc;
  final BuilderCellType t;
  const _Region(this.r, this.c, this.sr, this.sc, this.t);
}

// NEXATRACE — SEAT LAYOUT BUILDER (Blank Slate)
// =================================================
// No presets. Owner enters plate, brand, model, rows, cols.
// Gets a completely blank grid. Taps cells to manually assign
// Seat / Aisle / Folding / Sleeper / Driver / Door / Lavatory.
//
// Pakistani transport support: 3+2, 2+1, any row/col config.

import 'dart:convert';
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
    return Column(
      children: [
        // Back button row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: () => setState(() => _step = 0),
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Back to Details'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFAABBCC),
                ),
              ),
              const Spacer(),
              Text(
                '${_plateCtl.text} — ${_brandCtl.text} ${_modelCtl.text}',
                style: const TextStyle(color: Color(0xFF667788), fontSize: 11),
                overflow: TextOverflow.ellipsis,
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
                  'Tap cells to assign →   ',
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
                _countType(BuilderCellType.seat),
                const Color(0xFF7C3AED),
              ),
              const SizedBox(width: 12),
              _statBadge(
                'Folding',
                _countType(BuilderCellType.foldingSeat),
                const Color(0xFF06B6D4),
              ),
              const SizedBox(width: 12),
              _statBadge(
                'Berths',
                _countType(BuilderCellType.sleeperLower) +
                    _countType(BuilderCellType.sleeperUpper),
                const Color(0xFFDB2777),
              ),
              const SizedBox(width: 12),
              _statBadge(
                'Aisle cols',
                _countType(BuilderCellType.aisle),
                const Color(0xFF64748B),
              ),
              const Spacer(),
              Text(
                '${_rows}×$_cols',
                style: const TextStyle(color: Color(0xFF667788), fontSize: 11),
              ),
            ],
          ),
        ),
        // Grid
        Expanded(
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    // Column headers
                    Row(
                      children: [
                        const SizedBox(width: 48),
                        for (int c = 0; c < _cols; c++)
                          SizedBox(
                            width: 58,
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + c),
                                style: const TextStyle(
                                  color: Color(0xFFAABBCC),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Grid rows
                    for (int r = 0; r < _rows; r++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 48,
                              child: Center(
                                child: Text(
                                  '${r + 1}',
                                  style: const TextStyle(
                                    color: Color(0xFF8899AA),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            for (int c = 0; c < _cols; c++)
                              GestureDetector(
                                onTap: () => _openCellPicker(r, c),
                                child: _buildCell(_grid[r][c]),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
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
      width: 54,
      height: 44,
      margin: const EdgeInsets.all(2),
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

  // ── Cell Assignment Dialog (centered, fully scrollable) ──
  void _openCellPicker(int row, int col) {
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
            if (_grid[row][col].type != BuilderCellType.empty)
              TextButton(
                onPressed: () {
                  setState(() {
                    _grid[row][col] = _GridCell();
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
    final color = _cellColors[type] ?? Colors.grey;
    final icon = _cellIcons[type] ?? Icons.help;
    final label = _cellLabels[type] ?? type.name;
    final isSelected = _grid[row][col].type == type;

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
          setState(() {
            _grid[row][col].type = type;
            _grid[row][col].label = null;
          });
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
                        'Long-distance berth — place across multiple rows',
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
  }

  // ── Renumber seats (aisle-exclusion rule) ───────────
  void _renumberSeats() {
    final letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    int seatNum = 0;

    for (int r = 0; r < _grid.length; r++) {
      int posInRow = 0;
      for (int c = 0; c < _grid[r].length; c++) {
        final cell = _grid[r][c];
        // Structural types: no number
        if (cell.type == BuilderCellType.empty ||
            cell.type == BuilderCellType.aisle ||
            cell.type == BuilderCellType.driverCabin ||
            cell.type == BuilderCellType.exitDoor ||
            cell.type == BuilderCellType.emergency ||
            cell.type == BuilderCellType.lavatory) {
          cell.label = null;
          continue;
        }
        seatNum++;
        posInRow++;
        cell.label = '${letters[r < 26 ? r : 0]}$seatNum';
      }
    }
  }

  // ── Count cells of a type ──────────────────────────
  int _countType(BuilderCellType type) {
    int count = 0;
    for (final row in _grid) {
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

// NEXATRACE — SEAT LAYOUT DESIGNER (Module 14E)
// ================================================
// Wave 4: Dynamic Fleet Seat & Sleeper Berth Layout Designer Engine
//
// • Interactive 2D coordinate grid with cell inspector overlay
// • Preset selector: coach_54, standard_45, coaster_34, hiace_13, sleeper_custom
// • Dual-deck switcher for hybrid sleeper coaches (Lower / Upper)
// • Live metrics sidebar: Total Seats, Sleeper Berths, Bookable Units
// • Revision-based immutable snapshot publishing via optimistic concurrency
// • 3D Pencil/Arrow sidebar theme, dark canvas

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/missile_3d_button.dart';
import 'package:trace_odd/shared/theme/colors.dart';

// ─── Enums & Types ────────────────────────────────────

enum CellType {
  empty,
  seat,
  sleeperLower,
  sleeperUpper,
  aisle,
  exitDoor,
  driverCabin,
  emergency,
}

enum DeckLevel { lower, upper }

// ─── Preset definitions ──────────────────────────────

class LayoutPreset {
  final String key;
  final String label;
  final int rows;
  final int cols;
  final int leftCols;
  final int rightCols;
  final int driverSeats;
  final bool hasUpperDeck;
  final String deckType;
  final Color accentColor;

  const LayoutPreset({
    required this.key,
    required this.label,
    required this.rows,
    required this.cols,
    required this.leftCols,
    required this.rightCols,
    required this.driverSeats,
    required this.hasUpperDeck,
    required this.deckType,
    required this.accentColor,
  });

  static const List<LayoutPreset> builtIn = [
    LayoutPreset(
      key: 'coach_54',
      label: '54-Seat Coach (Large)',
      rows: 14,
      cols: 4,
      leftCols: 2,
      rightCols: 2,
      driverSeats: 1,
      hasUpperDeck: false,
      deckType: 'single',
      accentColor: Color(0xFF7C3AED),
    ),
    LayoutPreset(
      key: 'standard_45',
      label: '45-Seat Standard Coach',
      rows: 11,
      cols: 4,
      leftCols: 2,
      rightCols: 2,
      driverSeats: 1,
      hasUpperDeck: false,
      deckType: 'single',
      accentColor: Color(0xFF2563EB),
    ),
    LayoutPreset(
      key: 'coaster_34',
      label: '34-Seat Coaster',
      rows: 9,
      cols: 4,
      leftCols: 2,
      rightCols: 2,
      driverSeats: 1,
      hasUpperDeck: false,
      deckType: 'single',
      accentColor: Color(0xFF16A34A),
    ),
    LayoutPreset(
      key: 'hiace_13',
      label: '13-Seat HiAce',
      rows: 4,
      cols: 3,
      leftCols: 2,
      rightCols: 1,
      driverSeats: 1,
      hasUpperDeck: false,
      deckType: 'single',
      accentColor: Color(0xFFD97706),
    ),
    LayoutPreset(
      key: 'sleeper_custom',
      label: 'Custom Sleeper Coach',
      rows: 10,
      cols: 4,
      leftCols: 2,
      rightCols: 2,
      driverSeats: 1,
      hasUpperDeck: true,
      deckType: 'dual',
      accentColor: Color(0xFFDB2777),
    ),
  ];
}

// ─── Grid Cell Model ─────────────────────────────────

class GridCell {
  final int row;
  final int col;
  CellType type;
  String? seatId;
  bool bookable;
  String? genderRestriction;

  GridCell({
    required this.row,
    required this.col,
    this.type = CellType.empty,
    this.seatId,
    this.bookable = true,
    this.genderRestriction,
  });

  Map<String, dynamic> toJson() => {
    'row': row,
    'col': col,
    'type': type.name,
    'seat_id': seatId,
    'bookable': bookable,
    'gender_restriction': genderRestriction,
  };

  factory GridCell.fromJson(Map<String, dynamic> json) => GridCell(
    row: json['row'] as int,
    col: json['col'] as int,
    type: CellType.values.firstWhere(
      (e) => e.name == (json['type'] as String? ?? 'empty'),
      orElse: () => CellType.empty,
    ),
    seatId: json['seat_id'] as String?,
    bookable: (json['bookable'] as bool?) ?? true,
    genderRestriction: json['gender_restriction'] as String?,
  );
}

// ─── Main Screen ─────────────────────────────────────

class SeatLayoutDesignerScreen extends StatefulWidget {
  final String? layoutId;
  final String? companyId;
  final String? companyName;

  const SeatLayoutDesignerScreen({
    super.key,
    this.layoutId,
    this.companyId,
    this.companyName,
  });

  @override
  State<SeatLayoutDesignerScreen> createState() =>
      _SeatLayoutDesignerScreenState();
}

class _SeatLayoutDesignerScreenState extends State<SeatLayoutDesignerScreen> {
  // ── State ──────────────────────────────────────────
  bool _sidebarOpen = true;
  bool _isLoading = true;
  String? _error;

  // Preset
  LayoutPreset? _selectedPreset;
  DeckLevel _activeDeck = DeckLevel.lower;

  // Grid data — separate matrices per deck
  List<List<GridCell>> _lowerGrid = [];
  List<List<GridCell>> _upperGrid = [];

  // Layout metadata
  String? _layoutId;
  String? _displayName;
  int _versionNumber = 1;
  bool _hasEditLock = false;
  bool _isDirty = false;

  // Cell inspector
  int? _inspectorRow;
  int? _inspectorCol;

  // Auto seat numbering
  int _seatCounter = 0;

  // Name field controller (persistent to avoid rebuild-reset)
  final _nameController = TextEditingController();
  bool _nameSaved = true;

  // ── Init ───────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    if (widget.layoutId != null) {
      _loadExistingLayout();
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  List<List<GridCell>> get _activeGrid =>
      _activeDeck == DeckLevel.lower ? _lowerGrid : _upperGrid;

  set _activeGrid(List<List<GridCell>> g) {
    if (_activeDeck == DeckLevel.lower) {
      _lowerGrid = g;
    } else {
      _upperGrid = g;
    }
  }

  // ── Load existing layout ──────────────────────────
  Future<void> _loadExistingLayout() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final res = await ApiService().get(
        '/bus-fleet/layouts/${widget.layoutId}',
      );
      final data = res['data'] as Map<String, dynamic>;
      _layoutId = data['id'] as String;
      _displayName = data['display_name'] as String?;
      _nameController.text = _displayName ?? '';
      _versionNumber = (data['version_number'] as int?) ?? 1;

      final vc = data['vehicle_class'] as String?;
      if (vc != null) {
        _selectedPreset = LayoutPreset.builtIn.firstWhere(
          (p) => p.key == vc,
          orElse: () => LayoutPreset.builtIn.first,
        );
      }

      final snap = data['current_snapshot'] as Map<String, dynamic>?;
      if (snap != null) {
        _lowerGrid = _parseGridFromSnapshot(snap);
      }
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
    }
  }

  List<List<GridCell>> _parseGridFromSnapshot(Map<String, dynamic> snap) {
    final rows = (snap['rows'] as int?) ?? 0;
    final cols = (snap['cols'] as int?) ?? 0;
    final gridList = snap['grid'] as List<dynamic>? ?? [];

    final matrix = List.generate(
      rows,
      (r) => List.generate(cols, (c) => GridCell(row: r + 1, col: c + 1)),
    );

    for (final item in gridList) {
      if (item is Map<String, dynamic>) {
        final cell = GridCell.fromJson(item);
        if (cell.row > 0 &&
            cell.row <= rows &&
            cell.col > 0 &&
            cell.col <= cols) {
          matrix[cell.row - 1][cell.col - 1] = cell;
        }
      }
    }
    return matrix;
  }

  // ── Initialize grid from preset ────────────────────
  void _initGridFromPreset(LayoutPreset preset) {
    final rows = preset.rows;
    final cols = preset.cols;
    _seatCounter = 0;

    final matrix = List.generate(
      rows,
      (r) => List.generate(cols, (c) => GridCell(row: r + 1, col: c + 1)),
    );

    // Mark aisle column (middle column(s) when 4 cols)
    if (cols == 4) {
      final aisleCol = preset.leftCols; // col index for aisle start (0-based)
      for (int r = 0; r < rows; r++) {
        matrix[r][aisleCol] = GridCell(
          row: r + 1,
          col: aisleCol + 1,
          type: CellType.aisle,
          bookable: false,
        );
        if (cols == 4 && aisleCol + 1 < cols) {
          matrix[r][aisleCol + 1] = GridCell(
            row: r + 1,
            col: aisleCol + 2,
            type: CellType.aisle,
            bookable: false,
          );
        }
      }
    } else if (cols == 3) {
      // 3-col layout: middle is aisle
      for (int r = 0; r < rows; r++) {
        matrix[r][1] = GridCell(
          row: r + 1,
          col: 2,
          type: CellType.aisle,
          bookable: false,
        );
      }
    }

    // Auto-place seats on non-aisle columns
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (matrix[r][c].type == CellType.empty) {
          _seatCounter++;
          final seatLabel = _seatLabel(_seatCounter);
          matrix[r][c] = GridCell(
            row: r + 1,
            col: c + 1,
            type: CellType.seat,
            seatId: seatLabel,
            bookable: true,
          );
        }
      }
    }

    // Place driver cabin at row 0, left side
    if (preset.driverSeats > 0 && rows > 0 && cols > 0) {
      matrix[0][0] = GridCell(
        row: 1,
        col: 1,
        type: CellType.driverCabin,
        seatId: 'DRV',
        bookable: false,
      );
      if (preset.driverSeats > 1 && cols > 1) {
        matrix[0][1] = GridCell(
          row: 1,
          col: 2,
          type: CellType.driverCabin,
          seatId: 'CO-DRV',
          bookable: false,
        );
      }
    }

    setState(() {
      _selectedPreset = preset;
      if (_activeDeck == DeckLevel.lower) {
        _lowerGrid = matrix;
      } else {
        _upperGrid = matrix;
      }
      _isDirty = true;
      _seatCounter = _countAllSeats();
    });
  }

  String _seatLabel(int n) {
    final letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final row = ((n - 1) ~/ (_selectedPreset?.cols ?? 4)) + 1;
    final col = (n - 1) % (_selectedPreset?.cols ?? 4);
    return '${letters[col.clamp(0, 25)]}$row';
  }

  int _countAllSeats() {
    int count = 0;
    for (final row in _lowerGrid) {
      for (final cell in row) {
        if (cell.type == CellType.seat) count++;
      }
    }
    for (final row in _upperGrid) {
      for (final cell in row) {
        if (cell.type == CellType.seat) count++;
      }
    }
    return count;
  }

  int _countSleeperBerths() {
    int count = 0;
    for (final row in _lowerGrid) {
      for (final cell in row) {
        if (cell.type == CellType.sleeperLower ||
            cell.type == CellType.sleeperUpper)
          count++;
      }
    }
    for (final row in _upperGrid) {
      for (final cell in row) {
        if (cell.type == CellType.sleeperLower ||
            cell.type == CellType.sleeperUpper)
          count++;
      }
    }
    return count;
  }

  int _countBookableUnits() {
    int count = 0;
    for (final row in _lowerGrid) {
      for (final cell in row) {
        if (cell.bookable &&
            (cell.type == CellType.seat ||
                cell.type == CellType.sleeperLower ||
                cell.type == CellType.sleeperUpper))
          count++;
      }
    }
    for (final row in _upperGrid) {
      for (final cell in row) {
        if (cell.bookable &&
            (cell.type == CellType.seat ||
                cell.type == CellType.sleeperLower ||
                cell.type == CellType.sleeperUpper))
          count++;
      }
    }
    return count;
  }

  // ── Cell tap → inspector ───────────────────────────
  void _onCellTap(int row, int col) {
    if (_activeGrid.isEmpty) return;
    final cell = _activeGrid[row][col];
    _showCellInspector(row, col, cell);
  }

  void _showCellInspector(int row, int col, GridCell cell) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CellInspectorSheet(
        currentType: cell.type,
        currentBookable: cell.bookable,
        currentGenderRestriction: cell.genderRestriction,
        onApply: (CellType newType, bool bookable, String? gender) {
          setState(() {
            cell.type = newType;
            cell.bookable = bookable;
            cell.genderRestriction = gender;

            if (newType == CellType.seat ||
                newType == CellType.sleeperLower ||
                newType == CellType.sleeperUpper) {
              if (cell.seatId == null || cell.seatId!.isEmpty) {
                _seatCounter++;
                cell.seatId = _seatLabel(_seatCounter);
              }
            } else {
              cell.seatId = null;
            }

            if (newType == CellType.aisle ||
                newType == CellType.exitDoor ||
                newType == CellType.emergency) {
              cell.bookable = false;
            }

            _isDirty = true;
          });
          Navigator.pop(ctx);
        },
        onClear: () {
          setState(() {
            cell.type = CellType.empty;
            cell.seatId = null;
            cell.bookable = true;
            cell.genderRestriction = null;
            _isDirty = true;
          });
          Navigator.pop(ctx);
        },
      ),
    );
  }

  // ── Save layout name ──────────────────────────────
  Future<void> _saveLayoutName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _layoutId == null) return;
    try {
      await ApiService().put(
        '/bus-fleet/layouts/$_layoutId',
        data: {'display_name': name},
      );
      setState(() {
        _displayName = name;
        _nameSaved = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Name saved'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // ── Publish ────────────────────────────────────────
  Future<void> _publishLayout() async {
    final grid = _activeGrid.isEmpty ? _lowerGrid : _activeGrid;
    final snapshots = <String, dynamic>{
      'rows': grid.length,
      'cols': grid.isNotEmpty ? grid[0].length : 0,
      'grid': grid.expand((row) => row.map((c) => c.toJson())).toList(),
      'metadata': {
        'total_seats': _countAllSeats(),
        'bookable_seats': _countBookableUnits(),
        'sleeper_berths': _countSleeperBerths(),
        'deck_level': _activeDeck.name,
        'preset': _selectedPreset?.key,
        'layout_version': _versionNumber + 1,
      },
    };

    try {
      if (_layoutId != null) {
        await ApiService().post(
          '/bus-fleet/layouts/$_layoutId/publish',
          data: {
            'grid_snapshot': snapshots,
            'expected_version': _versionNumber,
            'change_description': 'Layout revision ${_versionNumber + 1}',
          },
        );
        setState(() => _versionNumber++);
      } else {
        // Create new layout first, then publish
        final createRes = await ApiService().post(
          '/bus-fleet/layouts',
          data: {
            'vehicle_class': _selectedPreset?.key ?? 'standard_45',
            'display_name': _displayName ?? 'Untitled Layout',
            'deck_level': _activeDeck == DeckLevel.lower ? 0 : 1,
            'company_id': widget.companyId,
          },
        );
        _layoutId = createRes['data']['id'] as String;

        await ApiService().post(
          '/bus-fleet/layouts/$_layoutId/publish',
          data: {
            'grid_snapshot': snapshots,
            'expected_version': 1,
            'change_description': 'Initial layout',
          },
        );
        setState(() => _versionNumber = 2);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Layout published successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        setState(() => _isDirty = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Publish failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // ── Acquire edit lock ─────────────────────────────
  Future<void> _acquireEditLock() async {
    if (_layoutId == null) return;
    try {
      await ApiService().post('/bus-fleet/layouts/$_layoutId/acquire-lock');
      setState(() => _hasEditLock = true);
    } catch (_) {}
  }

  // ── Build ──────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D1B2A),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_error != null && _selectedPreset == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D1B2A),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const Gap(12),
              Text(_error!, style: const TextStyle(color: Colors.white70)),
              const Gap(12),
              ElevatedButton(
                onPressed: _loadExistingLayout,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: Row(
        children: [
          if (_sidebarOpen || isWide) _buildSidebar(isWide),
          Expanded(child: _buildMainContent(isWide)),
        ],
      ),
    );
  }

  // ── Sidebar ────────────────────────────────────────
  Widget _buildSidebar(bool isWide) => Container(
    width: 270,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1A2A3A), Color(0xFF0D1B2A)],
      ),
      boxShadow: [
        BoxShadow(
          color: Color(0x30000000),
          blurRadius: 16,
          offset: Offset(4, 0),
        ),
      ],
    ),
    child: SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color:
                        _selectedPreset?.accentColor ?? const Color(0xFF7C3AED),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.event_seat,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: Text(
                    _displayName ?? widget.companyName ?? 'Seat Layout',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!isWide)
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white70,
                      size: 18,
                    ),
                    onPressed: () => setState(() => _sidebarOpen = false),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 30,
                      minHeight: 30,
                    ),
                  ),
              ],
            ),
          ),
          const Divider(color: Color(0x20FFFFFF), height: 1),
          const Gap(8),

          // Preset selector
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              trackVisibility: true,
              thickness: 8,
              radius: const Radius.circular(4),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  _sectionLabel('PRESETS'),
                  ...LayoutPreset.builtIn.map(
                    (p) => Missile3DButton(
                      label: p.label,
                      icon: p.key == 'sleeper_custom'
                          ? Icons.airline_seat_flat_angled
                          : Icons.event_seat,
                      color: p.accentColor,
                      height: 62,
                      onTap: () => _initGridFromPreset(p),
                      subtitle: '${p.rows} rows × ${p.cols} cols',
                    ),
                  ),
                  const Gap(12),
                  _sectionLabel('DECK'),
                  if (_selectedPreset?.hasUpperDeck == true) ...[
                    Missile3DButton(
                      label: 'Lower Deck',
                      icon: Icons.layers,
                      color: _activeDeck == DeckLevel.lower
                          ? const Color(0xFF7C3AED)
                          : const Color(0xFF4A5568),
                      height: 56,
                      onTap: () =>
                          setState(() => _activeDeck = DeckLevel.lower),
                    ),
                    Missile3DButton(
                      label: 'Upper Deck (Berths)',
                      icon: Icons.layers_outlined,
                      color: _activeDeck == DeckLevel.upper
                          ? const Color(0xFFDB2777)
                          : const Color(0xFF4A5568),
                      height: 56,
                      onTap: () =>
                          setState(() => _activeDeck = DeckLevel.upper),
                    ),
                  ],
                  const Gap(12),
                  _sectionLabel('LIVE METRICS'),
                  _metricCard(
                    'Total Seats',
                    '${_countAllSeats()}',
                    Icons.event_seat,
                    const Color(0xFF7C3AED),
                  ),
                  _metricCard(
                    'Sleeper Berths',
                    '${_countSleeperBerths()}',
                    Icons.airline_seat_flat,
                    const Color(0xFFDB2777),
                  ),
                  _metricCard(
                    'Bookable Units',
                    '${_countBookableUnits()}',
                    Icons.check_circle_outline,
                    const Color(0xFF16A34A),
                  ),
                  _metricCard(
                    'Version',
                    'v$_versionNumber',
                    Icons.history,
                    const Color(0xFFD97706),
                  ),
                  const Gap(12),
                  _sectionLabel('ACTIONS'),
                  Missile3DButton(
                    label: _isDirty ? 'Publish Layout ✦' : 'Published ✓',
                    icon: Icons.cloud_upload_rounded,
                    color: const Color(0xFF16A34A),
                    height: 56,
                    onTap: _isDirty ? _publishLayout : () {},
                  ),
                  Missile3DButton(
                    label: 'Reset Grid',
                    icon: Icons.refresh_rounded,
                    color: const Color(0xFFDC2626),
                    height: 48,
                    onTap: () {
                      if (_selectedPreset != null)
                        _initGridFromPreset(_selectedPreset!);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _sectionLabel(String t) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 2),
    child: Text(
      t,
      style: const TextStyle(
        color: Color(0xFF8899AA),
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    ),
  );

  Widget _metricCard(String label, String value, IconData icon, Color color) =>
      Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const Gap(8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Color(0xFFAABBCC), fontSize: 12),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );

  // ── Main Content ───────────────────────────────────
  Widget _buildMainContent(bool isWide) => SafeArea(
    child: Column(
      children: [
        _buildTopBar(isWide),
        if (_selectedPreset?.hasUpperDeck == true) _buildDeckSwitcher(),
        Expanded(child: _buildGridCanvas()),
      ],
    ),
  );

  Widget _buildTopBar(bool isWide) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFF162438),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        // ← Back to Dashboard button
        Tooltip(
          message: 'Back to Dashboard',
          child: TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFFAABBCC),
              size: 20,
            ),
            label: const Text(
              'Back',
              style: TextStyle(
                color: Color(0xFFAABBCC),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Color(0xFF334455)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        if (!_sidebarOpen)
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white70),
            onPressed: () => setState(() => _sidebarOpen = true),
          ),
        Expanded(
          child: Text(
            _selectedPreset != null
                ? '${_selectedPreset!.label} — ${_activeDeck == DeckLevel.lower ? "Lower Deck" : "Upper Deck"}'
                : 'Select a preset to begin',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Name editor with persistent controller + Save button
        if (_selectedPreset != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 140,
                child: TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Layout name...',
                    hintStyle: const TextStyle(
                      color: Color(0xFF556677),
                      fontSize: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF334455)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF334455)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    isDense: true,
                    filled: true,
                    fillColor: const Color(0xFF0D1B2A),
                  ),
                  onChanged: (v) {
                    _displayName = v;
                    _nameSaved = false;
                  },
                ),
              ),
              if (!_nameSaved)
                Tooltip(
                  message: 'Save name',
                  child: IconButton(
                    icon: const Icon(
                      Icons.check,
                      color: Color(0xFF4ADE80),
                      size: 20,
                    ),
                    onPressed: _saveLayoutName,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(
                        0xFF16A34A,
                      ).withValues(alpha: 0.15),
                    ),
                  ),
                ),
            ],
          ),
        const Gap(8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _isDirty
                ? const Color(0xFFD97706).withValues(alpha: 0.15)
                : const Color(0xFF16A34A).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: _isDirty
                  ? const Color(0xFFD97706).withValues(alpha: 0.3)
                  : const Color(0xFF16A34A).withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            _isDirty ? 'UNSAVED' : 'SAVED',
            style: TextStyle(
              color: _isDirty
                  ? const Color(0xFFFBBF24)
                  : const Color(0xFF4ADE80),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildDeckSwitcher() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    color: const Color(0xFF112233),
    child: Row(
      children: [
        _deckTab('Lower Deck / Floor Level', DeckLevel.lower, Icons.layers),
        const Gap(8),
        _deckTab('Upper Deck / Berths', DeckLevel.upper, Icons.layers_outlined),
      ],
    ),
  );

  Widget _deckTab(String label, DeckLevel deck, IconData icon) => Expanded(
    child: GestureDetector(
      onTap: () => setState(() => _activeDeck = deck),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: _activeDeck == deck
              ? const Color(0xFF7C3AED).withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _activeDeck == deck
                ? const Color(0xFF7C3AED).withValues(alpha: 0.5)
                : const Color(0xFF334455).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: _activeDeck == deck
                  ? const Color(0xFFA78BFA)
                  : const Color(0xFF556677),
            ),
            const Gap(6),
            Text(
              label,
              style: TextStyle(
                color: _activeDeck == deck
                    ? const Color(0xFFE2E8F0)
                    : const Color(0xFF556677),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  // ── Grid Canvas ────────────────────────────────────
  Widget _buildGridCanvas() {
    if (_selectedPreset == null) {
      return _buildEmptyState();
    }

    final grid = _activeGrid;
    if (grid.isEmpty) return _buildEmptyState();

    final rows = grid.length;
    final cols = grid[0].length;

    return Scrollbar(
      thumbVisibility: true,
      trackVisibility: true,
      thickness: 8,
      radius: const Radius.circular(4),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Column headers (A, B, C, D...)
            Row(
              children: [
                // Row number spacer
                const SizedBox(width: 40),
                for (int c = 0; c < cols; c++)
                  SizedBox(
                    width: 60,
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
            const Gap(4),
            // Grid rows
            ...List.generate(rows, (r) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    // Row number
                    SizedBox(
                      width: 40,
                      child: Center(
                        child: Text(
                          '${r + 1}',
                          style: const TextStyle(
                            color: Color(0xFF8899AA),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    // Cells
                    for (int c = 0; c < cols; c++)
                      GestureDetector(
                        onTap: () => _onCellTap(r, c),
                        child: _buildGridCell(grid[r][c]),
                      ),
                  ],
                ),
              );
            }),
            const Gap(20),
            // Legend
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCell(GridCell cell) {
    final icon = _cellIcon(cell.type);
    final color = _cellColor(cell.type);
    final label = cell.seatId ?? '';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 56,
      height: 52,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: cell.type == CellType.empty
            ? const Color(0xFF1A2A3A)
            : color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: cell.type == CellType.empty
              ? const Color(0xFF2A3A4A)
              : color.withValues(alpha: 0.4),
          width: cell.type != CellType.empty ? 1.5 : 1,
        ),
        boxShadow: cell.type != CellType.empty
            ? [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 4)]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18,
            color: cell.type == CellType.empty
                ? const Color(0xFF445566)
                : color,
          ),
          if (label.isNotEmpty)
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
              maxLines: 1,
            ),
        ],
      ),
    );
  }

  IconData _cellIcon(CellType type) => switch (type) {
    CellType.seat => Icons.event_seat,
    CellType.sleeperLower => Icons.airline_seat_flat,
    CellType.sleeperUpper => Icons.airline_seat_flat_angled,
    CellType.aisle => Icons.remove,
    CellType.exitDoor => Icons.door_front_door,
    CellType.driverCabin => Icons.airline_seat_recline_extra,
    CellType.emergency => Icons.warning_amber_rounded,
    CellType.empty => Icons.add_circle_outline,
  };

  Color _cellColor(CellType type) => switch (type) {
    CellType.seat => const Color(0xFF7C3AED),
    CellType.sleeperLower => const Color(0xFF2563EB),
    CellType.sleeperUpper => const Color(0xFFDB2777),
    CellType.aisle => const Color(0xFF8899AA),
    CellType.exitDoor => const Color(0xFF16A34A),
    CellType.driverCabin => const Color(0xFFD97706),
    CellType.emergency => const Color(0xFFDC2626),
    CellType.empty => const Color(0xFF445566),
  };

  Widget _buildEmptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.event_seat,
          size: 64,
          color: Colors.white.withValues(alpha: 0.1),
        ),
        const Gap(16),
        const Text(
          'Select a vehicle preset from the sidebar',
          style: TextStyle(color: Color(0xFF667788), fontSize: 16),
        ),
        const Gap(8),
        const Text(
          'Click grid cells to assign seats, berths, aisles, and exits',
          style: TextStyle(color: Color(0xFF445566), fontSize: 13),
        ),
      ],
    ),
  );

  Widget _buildLegend() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF162438),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFF2A3A4A)),
    ),
    child: Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _legendItem('Seat', CellType.seat),
        _legendItem('Sleeper Lower', CellType.sleeperLower),
        _legendItem('Sleeper Upper', CellType.sleeperUpper),
        _legendItem('Aisle', CellType.aisle),
        _legendItem('Exit Door', CellType.exitDoor),
        _legendItem('Driver Cabin', CellType.driverCabin),
        _legendItem('Emergency', CellType.emergency),
        _legendItem('Empty (Click)', CellType.empty),
      ],
    ),
  );

  Widget _legendItem(String label, CellType type) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: _cellColor(type).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: _cellColor(type).withValues(alpha: 0.5)),
        ),
        child: Icon(_cellIcon(type), size: 8, color: _cellColor(type)),
      ),
      const Gap(4),
      Text(
        label,
        style: const TextStyle(color: Color(0xFF8899AA), fontSize: 11),
      ),
    ],
  );
}

// ─── Cell Inspector Bottom Sheet ─────────────────────

class _CellInspectorSheet extends StatefulWidget {
  final CellType currentType;
  final bool currentBookable;
  final String? currentGenderRestriction;
  final void Function(CellType newType, bool bookable, String? gender) onApply;
  final VoidCallback onClear;

  const _CellInspectorSheet({
    required this.currentType,
    required this.currentBookable,
    required this.currentGenderRestriction,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<_CellInspectorSheet> createState() => _CellInspectorSheetState();
}

class _CellInspectorSheetState extends State<_CellInspectorSheet> {
  late CellType _selectedType;
  late bool _bookable;
  String? _genderRestriction;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.currentType;
    _bookable = widget.currentBookable;
    _genderRestriction = widget.currentGenderRestriction;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A2A3A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF445566),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Gap(16),
          const Text(
            'Cell Inspector',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(16),
          // Type selector
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _typeChip(CellType.seat, 'Standard Seat'),
              _typeChip(CellType.sleeperLower, 'Sleeper Lower'),
              _typeChip(CellType.sleeperUpper, 'Sleeper Upper'),
              _typeChip(CellType.aisle, 'Aisle'),
              _typeChip(CellType.exitDoor, 'Exit Door'),
              _typeChip(CellType.driverCabin, 'Driver Cabin'),
              _typeChip(CellType.emergency, 'Emergency'),
            ],
          ),
          const Gap(16),
          // Bookable toggle
          if (_selectedType == CellType.seat ||
              _selectedType == CellType.sleeperLower ||
              _selectedType == CellType.sleeperUpper)
            SwitchListTile(
              title: const Text(
                'Bookable',
                style: TextStyle(color: Colors.white70),
              ),
              value: _bookable,
              onChanged: (v) => setState(() => _bookable = v),
              activeColor: const Color(0xFF16A34A),
              contentPadding: EdgeInsets.zero,
            ),
          // Gender restriction
          if (_selectedType == CellType.seat ||
              _selectedType == CellType.sleeperLower ||
              _selectedType == CellType.sleeperUpper)
            DropdownButtonFormField<String?>(
              value: _genderRestriction,
              dropdownColor: const Color(0xFF162438),
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              decoration: const InputDecoration(
                labelText: 'Gender Restriction',
                labelStyle: TextStyle(color: Color(0xFF667788)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF334455)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF7C3AED)),
                ),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('None')),
                DropdownMenuItem(value: 'female', child: Text('Female Only')),
                DropdownMenuItem(value: 'male', child: Text('Male Only')),
                DropdownMenuItem(value: 'family', child: Text('Family')),
              ],
              onChanged: (v) => setState(() => _genderRestriction = v),
            ),
          const Gap(20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onClear,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                    side: const BorderSide(color: Color(0xFFDC2626)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Clear Cell'),
                ),
              ),
              const Gap(12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => widget.onApply(
                    _selectedType,
                    _bookable,
                    _genderRestriction,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
          const Gap(8),
        ],
      ),
    );
  }

  Widget _typeChip(CellType type, String label) => GestureDetector(
    onTap: () => setState(() => _selectedType = type),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _selectedType == type
            ? _cellInspectorColor(type).withValues(alpha: 0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _selectedType == type
              ? _cellInspectorColor(type)
              : const Color(0xFF334455),
          width: _selectedType == type ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _cellInspectorIcon(type),
            size: 16,
            color: _selectedType == type
                ? _cellInspectorColor(type)
                : const Color(0xFF667788),
          ),
          const Gap(6),
          Text(
            label,
            style: TextStyle(
              color: _selectedType == type
                  ? _cellInspectorColor(type)
                  : const Color(0xFF8899AA),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );

  IconData _cellInspectorIcon(CellType type) => switch (type) {
    CellType.seat => Icons.event_seat,
    CellType.sleeperLower => Icons.airline_seat_flat,
    CellType.sleeperUpper => Icons.airline_seat_flat_angled,
    CellType.aisle => Icons.remove,
    CellType.exitDoor => Icons.door_front_door,
    CellType.driverCabin => Icons.airline_seat_recline_extra,
    CellType.emergency => Icons.warning_amber_rounded,
    CellType.empty => Icons.add_circle_outline,
  };

  Color _cellInspectorColor(CellType type) => switch (type) {
    CellType.seat => const Color(0xFF7C3AED),
    CellType.sleeperLower => const Color(0xFF2563EB),
    CellType.sleeperUpper => const Color(0xFFDB2777),
    CellType.aisle => const Color(0xFF8899AA),
    CellType.exitDoor => const Color(0xFF16A34A),
    CellType.driverCabin => const Color(0xFFD97706),
    CellType.emergency => const Color(0xFFDC2626),
    CellType.empty => const Color(0xFF445566),
  };
}

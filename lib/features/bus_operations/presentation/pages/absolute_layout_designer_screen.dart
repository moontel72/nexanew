// NEXATRACE — ABSOLUTE LAYOUT DESIGNER SCREEN
// ==============================================
// Main screen for the Absolute (Freeform) Bus Layout Engine.
//
// This is the "House Floor Plan" canvas — components are placed via
// free drag-and-drop with pixel-precise X, Y, Width, Height, and Rotation.
// No grid rows/columns. No aisle concept. Pure freeform positioning.
//
// Features:
// • InteractiveViewer for pan/zoom (pinch-to-zoom on mobile)
// • Component palette (left sidebar) — tap to add, no drag source needed
// • Tap-to-place: tap palette item, then tap canvas to drop at that position
// • Tap component: selects it, opens inspector bottom sheet
// • Transform overlay: 8 resize handles + rotation handle on selected component
// • Drag-to-move: long-press + drag to reposition components
// • Presets sidebar: quick-start with predefined vehicle classes
// • Save/Publish to backend: /api/bus-owner/absolute-layouts/*
//
// 100% isolated from the legacy SeatLayoutDesignerScreen.
// Only accessible from the Bus Owner app.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/shared/models/transport/absolute_layout_component.dart';
import 'package:trace_odd/shared/models/transport/absolute_layout_state.dart';
import 'package:trace_odd/shared/models/transport/layout_component.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/absolute_canvas_grid.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/absolute_component_palette.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/absolute_transform_overlay.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/absolute_inspector_panel.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Tool mode for canvas interactions.
enum _CanvasTool { select, placeComponent }

class AbsoluteLayoutDesignerScreen extends StatefulWidget {
  final String companyId;
  final String companyName;
  final String? layoutId;

  const AbsoluteLayoutDesignerScreen({
    super.key,
    required this.companyId,
    required this.companyName,
    this.layoutId,
  });

  @override
  State<AbsoluteLayoutDesignerScreen> createState() =>
      _AbsoluteLayoutDesignerScreenState();
}

class _AbsoluteLayoutDesignerScreenState
    extends State<AbsoluteLayoutDesignerScreen> {
  final ApiService _api = ApiService();
  final TransformationController _transformCtrl = TransformationController();

  late AbsoluteLayoutState _state;
  _CanvasTool _tool = _CanvasTool.select;

  // Place mode state
  ComponentType? _placingType;
  double _placingDefaultW = 56;
  double _placingDefaultH = 56;
  bool _placingIsReverse = false;

  // Sidebar
  bool _sidebarOpen = true;

  @override
  void initState() {
    super.initState();
    _state = const AbsoluteLayoutState();
    if (widget.layoutId != null) {
      _loadLayout(widget.layoutId!);
    }
  }

  @override
  void dispose() {
    _transformCtrl.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════
  // DATA
  // ═══════════════════════════════════════════════════════════

  Future<void> _loadLayout(String id) async {
    _setState(_state.copyWith(isSaving: true));
    try {
      final res = await _api.get('/bus-owner/absolute-layouts/$id');
      final data = res?['data'];
      if (data != null) {
        _setState(
          AbsoluteLayoutState.fromSnapshot(
            data['current_snapshot'] is String
                ? jsonDecode(data['current_snapshot'])
                : (data['current_snapshot'] ?? data),
            layoutId: data['id']?.toString(),
          ).copyWith(
            layoutId: data['id']?.toString(),
            displayName: data['display_name'] as String? ?? 'Loaded Layout',
          ),
        );
      }
    } catch (e) {
      _setState(
        _state.copyWith(
          errorMessage: 'Failed to load layout: $e',
          clearError: false,
        ),
      );
    }
    _setState(_state.copyWith(isSaving: false));
  }

  Future<void> _saveLayout() async {
    final snapshot = _state.toSnapshot();
    final body = {
      'display_name': _state.displayName,
      'current_snapshot': snapshot,
    };

    _setState(_state.copyWith(isSaving: true, clearError: true));
    try {
      Map<String, dynamic>? res;
      if (_state.layoutId != null) {
        res = await _api.put(
          '/bus-owner/absolute-layouts/${_state.layoutId}',
          body: body,
        );
      } else {
        res = await _api.post('/bus-owner/absolute-layouts', body: body);
      }
      final id = res?['data']?['id']?.toString();
      _setState(
        _state.copyWith(
          layoutId: id ?? _state.layoutId,
          isDirty: false,
          isSaving: false,
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Layout saved successfully'),
            backgroundColor: Color(0xFF16A34A),
          ),
        );
      }
    } catch (e) {
      _setState(
        _state.copyWith(isSaving: false, errorMessage: 'Save failed: $e'),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════
  // STATE MUTATIONS
  // ═══════════════════════════════════════════════════════════

  void _setState(AbsoluteLayoutState newState) {
    if (mounted) setState(() => _state = newState);
  }

  String _addComponent(
    ComponentType type,
    double x,
    double y,
    double w,
    double h, {
    bool isReverseFacing = false,
  }) {
    final id = _uuid.v4();
    final comp = AbsoluteLayoutComponent(
      id: id,
      type: type,
      x: x,
      y: y,
      width: w,
      height: h,
      isReverseFacing: isReverseFacing,
      seatId: _nextSeatId(type),
      seatNumber:
          type == ComponentType.seat ||
              type == ComponentType.businessClassSeat ||
              type == ComponentType.foldingSeat
          ? _state.components.where((c) => c.type == type).length + 1
          : null,
      bookable: switch (type) {
        ComponentType.seat ||
        ComponentType.businessClassSeat ||
        ComponentType.foldingSeat ||
        ComponentType.sleeperLower ||
        ComponentType.sleeperUpper => true,
        _ => false,
      },
      bookingMode: switch (type) {
        ComponentType.businessClassSeat => BookingMode.premium,
        ComponentType.sleeperLower ||
        ComponentType.sleeperUpper => BookingMode.berth,
        ComponentType.foldingSeat => BookingMode.conditional,
        _ => BookingMode.standard,
      },
    );
    var comps = [..._state.components, comp];
    comps = _reassignSeatNumbers(comps);
    comps = _reassignBerthLabels(comps);
    _setState(
      _state.copyWith(
        components: comps,
        selectedComponentId: id,
        isDirty: true,
      ),
    );
    return id;
  }

  String? _nextSeatId(ComponentType type) {
    // Per-type independent counters — tables/doors/lavatories never
    // consume a seat number digit, so sequences stay contiguous.
    final comps = _state.components;
    if (type == ComponentType.businessClassSeat) {
      final count = comps
          .where((c) => c.type == ComponentType.businessClassSeat)
          .length;
      return 'B${count + 1}';
    }
    if (type == ComponentType.foldingSeat) {
      final count = comps
          .where((c) => c.type == ComponentType.foldingSeat)
          .length;
      return 'F${count + 1}';
    }
    // Standard seats numbered by _reassignSeatNumbers
    return null;
  }

  /// Auto-assign S1/S2/… labels to all standard seats (forward + reverse).
  /// Numbering always flows from the driver's position toward the opposite
  /// end: the row nearest the driver gets S1/S2/..., and numbers increase
  /// sequentially all the way to the back.
  List<AbsoluteLayoutComponent> _reassignSeatNumbers(
    List<AbsoluteLayoutComponent> comps,
  ) {
    final seats = comps.where((c) => c.type == ComponentType.seat).toList();
    if (seats.isEmpty) return comps;

    // Driver position determines the numbering direction.
    // If the driver is nearer the top (small Y), number top→bottom.
    // If the driver is nearer the bottom (large Y), number bottom→top.
    final driver =
        comps.where((c) => c.type == ComponentType.driverCabin).isEmpty
        ? null
        : comps.firstWhere((c) => c.type == ComponentType.driverCabin);
    final bool numberTopToBottom =
        driver == null || driver.y <= 56; // front half of canvas

    // Sort: Y first (relative to driver), forward-before-reverse, then X
    seats.sort((a, b) {
      final yDiff = numberTopToBottom ? a.y.compareTo(b.y) : b.y.compareTo(a.y);
      if (yDiff != 0) return yDiff;
      if (a.isReverseFacing != b.isReverseFacing) {
        return a.isReverseFacing ? 1 : -1;
      }
      return a.x.compareTo(b.x);
    });

    int s = 1;
    for (final seat in seats) {
      if (seat.customLabel == null) {
        seat.seatId = 'S$s';
        seat.seatNumber = s;
        s++;
      }
    }

    return comps;
  }

  /// Auto-assign L1/L2/… and U1/U2/… labels to sleeper berths.
  /// Berths are sorted by Y (top‑to‑bottom), then X (left‑to‑right).
  /// Berths that have a [customLabel] are skipped (owner override).
  List<AbsoluteLayoutComponent> _reassignBerthLabels(
    List<AbsoluteLayoutComponent> comps,
  ) {
    // Lower berths
    final lower =
        comps.where((c) => c.type == ComponentType.sleeperLower).toList()
          ..sort((a, b) {
            final yDiff = a.y.compareTo(b.y);
            if (yDiff != 0) return yDiff;
            return a.x.compareTo(b.x);
          });
    int l = 1;
    for (final b in lower) {
      b.berthLabel = b.customLabel == null ? 'L$l' : null;
      if (b.customLabel == null) l++;
    }

    // Upper berths
    final upper =
        comps.where((c) => c.type == ComponentType.sleeperUpper).toList()
          ..sort((a, b) {
            final yDiff = a.y.compareTo(b.y);
            if (yDiff != 0) return yDiff;
            return a.x.compareTo(b.x);
          });
    int u = 1;
    for (final b in upper) {
      b.berthLabel = b.customLabel == null ? 'U$u' : null;
      if (b.customLabel == null) u++;
    }

    return comps;
  }

  void _updateComponent(AbsoluteLayoutComponent updated) {
    var comps = _state.components.map((c) {
      return c.id == updated.id ? updated : c;
    }).toList();
    comps = _reassignSeatNumbers(comps);
    comps = _reassignBerthLabels(comps);
    _setState(_state.copyWith(components: comps, isDirty: true));
  }

  /// Convenience: update selected component with specific overrides.
  void _updateCompWith(
    AbsoluteLayoutComponent comp, {
    double? x,
    double? y,
    double? width,
    double? height,
    double? rotation,
  }) {
    _updateComponent(
      AbsoluteLayoutComponent(
        id: comp.id,
        type: comp.type,
        x: x ?? comp.x,
        y: y ?? comp.y,
        width: width ?? comp.width,
        height: height ?? comp.height,
        rotation: rotation ?? comp.rotation,
        seatId: comp.seatId,
        seatNumber: comp.seatNumber,
        berthLabel: comp.berthLabel,
        isReverseFacing: comp.isReverseFacing,
        bookable: comp.bookable,
        bookingMode: comp.bookingMode,
        customLabel: comp.customLabel,
        meta: comp.meta,
      ),
    );
  }

  void _deleteComponent(String id) {
    final wasSelected = _state.selectedComponentId == id;
    var comps = _state.components.where((c) => c.id != id).toList();
    comps = _reassignSeatNumbers(comps);
    comps = _reassignBerthLabels(comps);
    _setState(
      _state.copyWith(
        components: comps,
        selectedComponentId: wasSelected ? null : _state.selectedComponentId,
        isDirty: true,
      ),
    );
  }

  void _selectComponent(String id) {
    _setState(_state.copyWith(selectedComponentId: id));
    _tool = _CanvasTool.select;
    _placingType = null;
    _openInspector(id);
  }

  void _deselectAll() {
    _setState(_state.copyWith(clearSelection: true));
    // Note: does NOT reset _tool or _placingType — callers manage those.
  }

  // ═══════════════════════════════════════════════════════════
  // PRESETS
  // ═══════════════════════════════════════════════════════════

  void _applyPreset(AbsoluteLayoutPreset preset) {
    // Special-case: VIP + Sleeper custom layout (5'1" × 18'8")
    if (preset.key == 'vip_sleeper_40') {
      _applyVipSleeperPreset(preset);
      return;
    }

    final components = <AbsoluteLayoutComponent>[];
    const double seatW = 56, seatH = 56;
    const double aisleW = 56;

    // Driver cabin at the TOP (front) of every layout
    components.add(
      AbsoluteLayoutComponent(
        id: _uuid.v4(),
        type: ComponentType.driverCabin,
        x: 0,
        y: 0,
        width: 56,
        height: 56,
        bookable: false,
        seatId: 'DRIVER',
      ),
    );

    // Seat rows start right after the driver
    double y = seatH; // y = 56
    final int rowCount = ((preset.canvasHeight - 56) / seatH).floor().clamp(
      0,
      16,
    );

    // Generate seat rows
    for (int row = 0; row < rowCount; row++) {
      double x = 0;
      // Left seats
      for (int i = 0; i < preset.leftSeats; i++) {
        components.add(
          AbsoluteLayoutComponent(
            id: _uuid.v4(),
            type: ComponentType.seat,
            x: x,
            y: y,
            width: seatW,
            height: seatH,
            seatId: 'S${components.length + 1}',
            seatNumber: components.length + 1,
            bookable: true,
          ),
        );
        x += seatW;
      }
      // Aisle (visual gap only, no component needed in absolute mode)
      x += aisleW;
      // Right seats
      for (int i = 0; i < preset.rightSeats; i++) {
        components.add(
          AbsoluteLayoutComponent(
            id: _uuid.v4(),
            type: ComponentType.seat,
            x: x,
            y: y,
            width: seatW,
            height: seatH,
            seatId: 'S${components.length + 1}',
            seatNumber: components.length + 1,
            bookable: true,
          ),
        );
        x += seatW;
      }
      y += seatH;
    }

    var reassigned = _reassignSeatNumbers(components);
    reassigned = _reassignBerthLabels(reassigned);

    _setState(
      AbsoluteLayoutState(
        canvasWidth: preset.canvasWidth,
        canvasHeight: preset.canvasHeight,
        displayName: preset.label,
        components: reassigned,
        metadata: {'preset_key': preset.key},
        isDirty: true,
      ),
    );
  }

  /// Generates the VIP + Sleeper layout (5'1" × 18'8" bus).
  ///
  /// Layout (front → back):
  ///   1. Row 1:  Driver (left) + VIP Business Class (right)
  ///   2. Rows 2-3:  8 standard seats (2L+2R × 2)
  ///   3. Rows 4-6:  12 standard seats + 2 upper sleeper berths
  ///   4. Rear (rows 7-16): mixed tables, forward & reverse seats
  void _applyVipSleeperPreset(AbsoluteLayoutPreset preset) {
    final comps = <AbsoluteLayoutComponent>[];
    const double seatW = 56, seatH = 56;
    // 244 px wide = 5'1": left(4,60) | aisle(116-128) | right(128,184)
    const double lx0 = 4, lx1 = 60; // left-side seat X positions
    const double rx0 = 128, rx1 = 184; // right-side seat X positions

    // ── helpers ──
    String nextId() => _uuid.v4();

    int seatNum = 0;
    void addStdSeat(double x, double y, {bool rev = false}) {
      seatNum++;
      final c = AbsoluteLayoutComponent(
        id: nextId(),
        type: ComponentType.seat,
        x: x,
        y: y,
        width: seatW,
        height: seatH,
        isReverseFacing: rev,
        seatId: 'S$seatNum',
        seatNumber: seatNum,
        bookable: true,
      );
      comps.add(c);
    }

    void addRow(double y, {bool revL = false, bool revR = false}) {
      addStdSeat(lx0, y, rev: revL);
      addStdSeat(lx1, y, rev: revL);
      addStdSeat(rx0, y, rev: revR);
      addStdSeat(rx1, y, rev: revR);
    }

    // ═══════════════════════════════════════════════
    // 1. FRONT ROW: Driver + VIP (y = 0)
    // ═══════════════════════════════════════════════
    double y = 0;

    // Driver cabin
    comps.add(
      AbsoluteLayoutComponent(
        id: nextId(),
        type: ComponentType.driverCabin,
        x: lx0,
        y: y,
        width: seatW,
        height: seatH,
        bookable: false,
        seatId: 'DRIVER',
      ),
    );

    // VIP — business class, sits on right side
    comps.add(
      AbsoluteLayoutComponent(
        id: nextId(),
        type: ComponentType.businessClassSeat,
        x: rx1,
        y: y,
        width: seatW,
        height: seatH,
        isReverseFacing: false,
        bookable: true,
        bookingMode: BookingMode.premium,
        customLabel: 'VIP',
        seatId: 'VIP',
        seatNumber: 0,
      ),
    );

    // ═══════════════════════════════════════════════
    // 2. ROWS 2-3: 8 standard seats (y = 56, 112)
    // ═══════════════════════════════════════════════
    y += seatH; // 56
    addRow(y); // row 2 → 4 seats
    y += seatH; // 112
    addRow(y); // row 3 → 4 seats

    // ═══════════════════════════════════════════════
    // 3. ROWS 4-6: 12 standard seats + 2 upper berths
    // ═══════════════════════════════════════════════
    y += seatH; // 168 — row 4
    addRow(y);
    y += seatH; // 224 — row 5
    addRow(y);
    y += seatH; // 280 — row 6
    addRow(y);

    // Upper sleeper berths (above the 6 right + 6 left seats)
    // Each berth spans 3 rows (168 px tall), 1 seat wide (56 px)
    const double berthY = 168;
    const double berthH = 168; // 3 rows

    comps.add(
      AbsoluteLayoutComponent(
        id: nextId(),
        type: ComponentType.sleeperUpper,
        x: lx0,
        y: berthY,
        width: seatW,
        height: berthH,
        berthLabel: 'LU1',
        bookable: true,
        bookingMode: BookingMode.berth,
      ),
    );

    comps.add(
      AbsoluteLayoutComponent(
        id: nextId(),
        type: ComponentType.sleeperUpper,
        x: rx0,
        y: berthY,
        width: seatW,
        height: berthH,
        berthLabel: 'RU1',
        bookable: true,
        bookingMode: BookingMode.berth,
      ),
    );

    // ═══════════════════════════════════════════════
    // 4. REAR SECTION (y = 336 → 896): mixed layout
    // ═══════════════════════════════════════════════
    y += seatH; // 336 — row 7: 2L forward + 2R reverse
    addRow(y, revR: true);

    y += seatH; // 392 — row 8: 2L reverse + 2R forward
    addRow(y, revL: true);

    // Row 9-10: Table (left) + 2 right seats each row
    y += seatH; // 448
    // Table spans 2 seat-widths + aisle (covers left side)
    comps.add(
      AbsoluteLayoutComponent(
        id: nextId(),
        type: ComponentType.restaurantTable,
        x: lx0,
        y: y,
        width: 112,
        height: 112,
        bookable: false,
      ),
    );
    addStdSeat(rx0, y); // row 9 right
    addStdSeat(rx1, y);

    y += seatH; // 504 — row 10 right seats (table covers left side)
    addStdSeat(rx0, y);
    addStdSeat(rx1, y);

    y += seatH; // 560 — row 11: 2L reverse + 2R forward
    addRow(y, revL: true);

    y += seatH; // 616 — row 12: 2L forward + 2R reverse
    addRow(y, revR: true);

    // Row 13-14: Table (right) + 2 left seats each row
    y += seatH; // 672
    comps.add(
      AbsoluteLayoutComponent(
        id: nextId(),
        type: ComponentType.restaurantTable,
        x: rx0,
        y: y,
        width: 112,
        height: 112,
        bookable: false,
      ),
    );
    addStdSeat(lx0, y, rev: true); // row 13 left reverse
    addStdSeat(lx1, y, rev: true);

    y += seatH; // 728 — row 14 left seats (table covers right side)
    addStdSeat(lx0, y);
    addStdSeat(lx1, y);

    y += seatH; // 784 — row 15: 2L + 2R reverse
    addRow(y, revR: true);

    y += seatH; // 840 — row 16: 2L reverse + 2R
    addRow(y, revL: true);

    // ── Finalize state ──
    final reassigned = _reassignSeatNumbers(comps);
    _setState(
      AbsoluteLayoutState(
        canvasWidth: preset.canvasWidth,
        canvasHeight: preset.canvasHeight,
        displayName: preset.label,
        components: reassigned,
        metadata: {'preset_key': preset.key},
        isDirty: true,
      ),
    );
  }

  void _clearCanvas() {
    _setState(const AbsoluteLayoutState(isDirty: true));
  }

  // ═══════════════════════════════════════════════════════════
  // INSPECTOR
  // ═══════════════════════════════════════════════════════════

  void _openInspector(String compId) {
    // The inspector is rendered as a Positioned widget in _buildCanvas.
    // Just trigger a rebuild — no bottom sheet needed.
    if (mounted && _state.selectedComponentId == compId) {
      setState(() {}); // re-render to show the inspector panel
    }
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            Expanded(
              child: Row(
                children: [
                  // Left: palette
                  AbsoluteComponentPalette(
                    onItemSelected: (type, defW, defH, isReverse) {
                      _setState(_state.copyWith(clearSelection: true));
                      _tool = _CanvasTool.placeComponent;
                      _placingType = type;
                      _placingDefaultW = defW;
                      _placingDefaultH = defH;
                      _placingIsReverse = isReverse;
                    },
                  ),
                  // Center: canvas
                  Expanded(child: _buildCanvas()),
                  // Right: presets sidebar
                  if (_sidebarOpen) _presetsSidebar(),
                ],
              ),
            ),
            // Bottom status bar
            _statusBar(),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return Container(
      height: 48,
      decoration: const BoxDecoration(
        color: Color(0xFF0A1628),
        border: Border(bottom: BorderSide(color: Color(0x20FFFFFF))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white70, size: 20),
            onPressed: () {
              if (_state.isDirty) {
                _showUnsavedDialog();
              } else {
                Navigator.pop(context);
              }
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          const Gap(8),
          // Title
          Expanded(
            child: Text(
              _state.displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (_state.isDirty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF97316).withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'UNSAVED',
                style: TextStyle(
                  color: Color(0xFFF97316),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          const Gap(8),
          // Tool toggle
          _toolButton(
            icon: Icons.near_me,
            label: 'Select',
            active: _tool == _CanvasTool.select,
            onTap: () {
              _tool = _CanvasTool.select;
              _placingType = null;
              _setState(_state.copyWith(clearSelection: true));
            },
          ),
          const Gap(4),
          _toolButton(
            icon: Icons.add_location_alt,
            label: 'Place',
            active: _tool == _CanvasTool.placeComponent,
            onTap: () {
              if (_placingType != null) {
                setState(() => _tool = _CanvasTool.placeComponent);
              } else {
                // No part type selected yet — tell the user
                setState(() => _tool = _CanvasTool.placeComponent);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Pick a part from the left palette first, then tap the canvas',
                      ),
                      backgroundColor: Color(0xFFD97706),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              }
            },
          ),
          const Gap(4),
          // Presets toggle
          IconButton(
            icon: Icon(
              _sidebarOpen ? Icons.menu_open : Icons.menu,
              color: _sidebarOpen ? const Color(0xFF7C3AED) : Colors.white54,
              size: 20,
            ),
            onPressed: () => setState(() => _sidebarOpen = !_sidebarOpen),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            tooltip: 'Presets',
          ),
          const Gap(4),
          // Save button
          ElevatedButton.icon(
            onPressed: _state.isSaving ? null : _saveLayout,
            icon: _state.isSaving
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save, size: 16),
            label: Text(_state.isSaving ? 'SAVING...' : 'SAVE'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              textStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolButton({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF7C3AED).withOpacity(0.2) : null,
          borderRadius: BorderRadius.circular(6),
          border: active
              ? Border.all(color: const Color(0xFF7C3AED).withOpacity(0.5))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: active ? const Color(0xFF7C3AED) : Colors.white54,
            ),
            const Gap(4),
            Text(
              label,
              style: TextStyle(
                color: active ? const Color(0xFF7C3AED) : Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvas() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main canvas
        AbsoluteCanvasGrid(
          layoutState: _state,
          transformController: _transformCtrl,
          onComponentTap: (id, x, y) {
            if (_tool == _CanvasTool.select) {
              _selectComponent(id);
            } else if (_tool == _CanvasTool.placeComponent &&
                _placingType != null) {
              // Place mode: drop the new component at the tap position
              final newId = _addComponent(
                _placingType!,
                x,
                y,
                _placingDefaultW,
                _placingDefaultH,
                isReverseFacing: _placingIsReverse,
              );
              _tool = _CanvasTool.select;
              _placingType = null;
              _openInspector(newId);
            }
          },
          onCanvasTap: (x, y) {
            if (_tool == _CanvasTool.placeComponent && _placingType != null) {
              final newId = _addComponent(
                _placingType!,
                x,
                y,
                _placingDefaultW,
                _placingDefaultH,
                isReverseFacing: _placingIsReverse,
              );
              _tool = _CanvasTool.select;
              _placingType = null;
              _openInspector(newId);
            } else if (_tool == _CanvasTool.select) {
              _deselectAll();
            }
          },
        ),

        // Transform overlay for selected component
        if (_state.selectedComponent != null)
          AbsoluteTransformOverlay(
            component: _state.selectedComponent!,
            onResize: (w, h, x, y) {
              _updateCompWith(
                _state.selectedComponent!,
                x: x,
                y: y,
                width: w,
                height: h,
              );
            },
            onResizeEnd: () {},
            onMove: (x, y) {
              _updateCompWith(_state.selectedComponent!, x: x, y: y);
            },
            onMoveEnd: () {},
            onRotate: (r) {
              _updateCompWith(_state.selectedComponent!, rotation: r);
            },
            onRotateEnd: () {},
            onDelete: () => _deleteComponent(_state.selectedComponent!.id),
            onTap: () {
              _openInspector(_state.selectedComponent!.id);
            },
          ),

        // ── Top-Right Inspector Panel (floating) ──
        if (_state.selectedComponent != null)
          Positioned(
            top: 8,
            right: 8,
            child: AbsoluteInspectorPanel(
              component: _state.selectedComponent!,
              onApply: (updated) => _updateComponent(updated),
              onDelete: () => _deleteComponent(_state.selectedComponent!.id),
              onClose: () => _deselectAll(),
            ),
          ),

        // Place mode indicator
        if (_tool == _CanvasTool.placeComponent && _placingType != null)
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Tap canvas to place ${_placingType!.name}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

        // Error banner
        if (_state.errorMessage != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: MaterialBanner(
              backgroundColor: const Color(0xFFDC2626),
              content: Text(
                _state.errorMessage!,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              actions: [
                TextButton(
                  onPressed: () => _setState(_state.copyWith(clearError: true)),
                  child: const Text(
                    'DISMISS',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _presetsSidebar() {
    return Container(
      width: 200,
      decoration: const BoxDecoration(
        color: Color(0xFF0A1628),
        border: Border(left: BorderSide(color: Color(0x20FFFFFF))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0x20FFFFFF))),
            ),
            child: const Text(
              'PRESETS',
              style: TextStyle(
                color: Color(0x80FFFFFF),
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                for (final preset in AbsoluteLayoutPreset.builtIn)
                  _presetCard(preset),
                const Gap(8),
                const Divider(color: Color(0x20FFFFFF)),
                const Gap(8),
                // Clear canvas
                InkWell(
                  onTap: () => _clearCanvas(),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0x30FFFFFF)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: Colors.white54,
                          size: 16,
                        ),
                        Gap(6),
                        Text(
                          'Clear Canvas',
                          style: TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(4),
                // Canvas size
                const Text(
                  'CANVAS SIZE (ft/in)',
                  style: TextStyle(
                    color: Color(0x60FFFFFF),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                const Gap(2),
                Text(
                  'W: ${pxToFtIn(_state.canvasWidth)} · H: ${pxToFtIn(_state.canvasHeight)}',
                  style: const TextStyle(color: Color(0x40FFFFFF), fontSize: 9),
                ),
                const Gap(6),
                Row(
                  children: [
                    Expanded(
                      child: _sizeField(
                        'Width (px)',
                        _state.canvasWidth,
                        (v) => _setState(
                          _state.copyWith(
                            canvasWidth: v.clamp(100, 2000),
                            isDirty: true,
                          ),
                        ),
                      ),
                    ),
                    const Gap(8),
                    Expanded(
                      child: _sizeField(
                        'Height (px)',
                        _state.canvasHeight,
                        (v) => _setState(
                          _state.copyWith(
                            canvasHeight: v.clamp(100, 3000),
                            isDirty: true,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _presetCard(AbsoluteLayoutPreset preset) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: () => _applyPreset(preset),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0x20FFFFFF)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                preset.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(4),
              Text(
                '${pxToFtIn(preset.canvasWidth)} × ${pxToFtIn(preset.canvasHeight)} · ${preset.leftSeats + preset.rightSeats}-abreast',
                style: const TextStyle(color: Color(0x60FFFFFF), fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sizeField(
    String label,
    double value,
    ValueChanged<double> onChanged,
  ) {
    // Use a stateful wrapper so the TextEditingController survives rebuilds
    return _SizeField(
      label: label,
      initialValue: value.toInt().toString(),
      onChanged: (s) {
        final v = double.tryParse(s);
        if (v != null) onChanged(v);
      },
    );
  }

  Widget _statusBar() {
    final sel = _state.selectedComponent;
    return Container(
      height: 28,
      decoration: const BoxDecoration(
        color: Color(0xFF0A1628),
        border: Border(top: BorderSide(color: Color(0x20FFFFFF))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // Component count
          Icon(Icons.grid_view, color: Colors.white38, size: 12),
          const Gap(4),
          Text(
            '${_state.components.length} parts',
            style: const TextStyle(color: Color(0x60FFFFFF), fontSize: 11),
          ),
          const Gap(12),
          Icon(Icons.event_seat, color: const Color(0xFF7C3AED), size: 12),
          const Gap(4),
          Text(
            '${_state.totalSeats} seats',
            style: const TextStyle(color: Color(0x60FFFFFF), fontSize: 11),
          ),
          const Spacer(),
          // Selected component info
          if (sel != null) ...[
            Icon(sel.defaultIcon, color: sel.defaultColor, size: 12),
            const Gap(4),
            Text(
              '${sel.typeLabel} · ${pxToFtIn(sel.width)} × ${pxToFtIn(sel.height)}',
              style: const TextStyle(color: Color(0x80FFFFFF), fontSize: 11),
            ),
          ],
          const Gap(8),
          // Canvas dimensions
          Text(
            'Canvas: ${pxToFtIn(_state.canvasWidth)} × ${pxToFtIn(_state.canvasHeight)}',
            style: const TextStyle(color: Color(0x40FFFFFF), fontSize: 10),
          ),
        ],
      ),
    );
  }

  void _showUnsavedDialog() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF122442),
        title: const Text(
          'Unsaved Changes',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'You have unsaved changes. Save before leaving?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              Navigator.pop(context);
            },
            child: const Text(
              'Discard',
              style: TextStyle(color: Color(0xFFDC2626)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(c);
              await _saveLayout();
              if (mounted && _state.errorMessage == null) {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
            ),
            child: const Text('Save & Exit'),
          ),
        ],
      ),
    );
  }
}

// ─── Size-Field Stateful Wrapper (fixes canvas resize UX) ───

class _SizeField extends StatefulWidget {
  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;

  const _SizeField({
    required this.label,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<_SizeField> createState() => _SizeFieldState();
}

class _SizeFieldState extends State<_SizeField> {
  late final TextEditingController _ctrl;
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
    _focus = FocusNode();
    _focus.addListener(() {
      // Apply on focus loss
      if (!_focus.hasFocus) {
        widget.onChanged(_ctrl.text);
      }
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: const TextStyle(color: Color(0x40FFFFFF), fontSize: 9),
        ),
        const Gap(2),
        TextField(
          controller: _ctrl,
          focusNode: _focus,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white, fontSize: 12),
          onSubmitted: (s) => widget.onChanged(s),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF122442),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 6,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0x20FFFFFF)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFF7C3AED)),
            ),
          ),
        ),
      ],
    );
  }
}

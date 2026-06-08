// NEXATRACE — SEAT LAYOUT DESIGNER (Module 14E) v2
// ======================================================
// Component-based canvas architecture using BLoC state management.
//
// Features:
// • Drag-and-drop component palette (7 building blocks)
// • Interactive coordinate grid with pan/zoom (InteractiveViewer)
// • Component inspector panel (right drawer / bottom sheet)
// • Preset selector with dual-deck support
// • Live metrics sidebar
// • Aisle-exclusion seat numbering
// • Collision detection
// • Optimistic concurrency publishing via revision vault
//
// Section 14E: Seat Layout Designer — Component Architecture.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/shared/models/transport/layout_component.dart';
import 'package:trace_odd/shared/models/transport/layout_canvas_state.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/canvas/layout_canvas_bloc.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/canvas/layout_canvas_event.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/canvas/layout_canvas_state_bloc.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/canvas_grid.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/component_palette.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/cell_inspector_panel.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/missile_3d_button.dart';
import 'package:trace_odd/shared/theme/colors.dart';

// ─── Preset definitions (kept for sidebar selector) ─────

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

// ─── Main Screen Widget ────────────────────────────────

class SeatLayoutDesignerScreen extends StatefulWidget {
  final String? layoutId;
  final String companyId;
  final String? companyName;

  const SeatLayoutDesignerScreen({
    super.key,
    this.layoutId,
    required this.companyId,
    this.companyName,
  });

  @override
  State<SeatLayoutDesignerScreen> createState() =>
      _SeatLayoutDesignerScreenState();
}

class _SeatLayoutDesignerScreenState extends State<SeatLayoutDesignerScreen> {
  late final LayoutCanvasBloc _bloc;
  bool _sidebarOpen = true;
  bool _inspectorOpen = false;
  String? _inspectorComponentId;
  final _nameController = TextEditingController();
  bool _nameSaved = true;

  @override
  void initState() {
    super.initState();
    _bloc = LayoutCanvasBloc(companyId: widget.companyId);
    if (widget.layoutId != null) {
      _bloc.add(LayoutLoaded(widget.layoutId!));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bloc.close();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<LayoutCanvasBloc, LayoutCanvasBlocState>(
        listener: (context, state) {
          if (state.status == CanvasStatus.error && state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: AppColors.error,
              ),
            );
          }
          if (state.status == CanvasStatus.published) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Layout published successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == CanvasStatus.loading) {
            return const Scaffold(
              backgroundColor: Color(0xFF0D1B2A),
              body: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }

          return Scaffold(
            backgroundColor: const Color(0xFF0D1B2A),
            body: Row(
              children: [
                // Left: Sidebar (presets + metrics + actions)
                if (_sidebarOpen || isWide)
                  _buildSidebar(context, state, isWide),

                // Center: Main content
                Expanded(child: _buildMainContent(context, state, isWide)),

                // Right: Inspector panel
                if (_inspectorOpen && _inspectorComponentId != null)
                  _buildInspectorPanel(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Sidebar ─────────────────────────────────────────
  Widget _buildSidebar(
    BuildContext context,
    LayoutCanvasBlocState state,
    bool isWide,
  ) {
    final preset = _findSelectedPreset(state);
    return Container(
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
                      color: preset?.accentColor ?? const Color(0xFF7C3AED),
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
                      state.displayName ?? widget.companyName ?? 'Seat Layout',
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

            // Preset selector + deck + metrics + actions
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
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
                        onTap: () => _bloc.add(PresetSelected(p.key)),
                        subtitle: '${p.rows} rows × ${p.cols} cols',
                      ),
                    ),
                    const Gap(12),
                    _sectionLabel('DECK'),
                    if (preset?.hasUpperDeck == true) ...[
                      Missile3DButton(
                        label: 'Lower Deck',
                        icon: Icons.layers,
                        color: state.activeDeck == 'lower'
                            ? const Color(0xFF7C3AED)
                            : const Color(0xFF4A5568),
                        height: 56,
                        onTap: () => _bloc.add(const DeckSwitched('lower')),
                      ),
                      Missile3DButton(
                        label: 'Upper Deck (Berths)',
                        icon: Icons.layers_outlined,
                        color: state.activeDeck == 'upper'
                            ? const Color(0xFFDB2777)
                            : const Color(0xFF4A5568),
                        height: 56,
                        onTap: () => _bloc.add(const DeckSwitched('upper')),
                      ),
                    ],
                    const Gap(12),
                    _sectionLabel('LIVE METRICS'),
                    _metricCard(
                      'Total Seats',
                      '${state.totalSeats}',
                      Icons.event_seat,
                      const Color(0xFF7C3AED),
                    ),
                    _metricCard(
                      'Sleeper Berths',
                      '${state.sleeperBerths}',
                      Icons.airline_seat_flat,
                      const Color(0xFFDB2777),
                    ),
                    _metricCard(
                      'Bookable Units',
                      '${state.bookableUnits}',
                      Icons.check_circle_outline,
                      const Color(0xFF16A34A),
                    ),
                    _metricCard(
                      'Version',
                      'v${state.versionNumber}',
                      Icons.history,
                      const Color(0xFFD97706),
                    ),
                    const Gap(12),
                    _sectionLabel('ACTIONS'),
                    Missile3DButton(
                      label: state.isDirty ? 'Publish Layout ✦' : 'Published ✓',
                      icon: Icons.cloud_upload_rounded,
                      color: const Color(0xFF16A34A),
                      height: 56,
                      onTap: state.isDirty
                          ? () => _bloc.add(
                              PublishRequested(
                                expectedVersion: state.versionNumber,
                              ),
                            )
                          : () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Main Content ────────────────────────────────────
  Widget _buildMainContent(
    BuildContext context,
    LayoutCanvasBlocState state,
    bool isWide,
  ) {
    return SafeArea(
      child: Column(
        children: [
          _buildTopBar(context, state, isWide),
          if (_findSelectedPreset(state)?.hasUpperDeck == true)
            _buildDeckSwitcher(state),

          // Canvas area — no outer DragTarget so pan/scroll works
          Expanded(
            child: state.isCanvasReady
                ? CanvasGrid(
                    canvasState: state.activeCanvas!,
                    onComponentTap: (id) {
                      setState(() {
                        _inspectorComponentId = id;
                        _inspectorOpen = true;
                      });
                    },
                    onEmptyCellTap: (row, col) {
                      _showAddComponentDialog(context, row, col);
                    },
                  )
                : _buildEmptyState(),
          ),
        ],
      ),
    );
  }

  // ── Top Bar ─────────────────────────────────────────
  Widget _buildTopBar(
    BuildContext context,
    LayoutCanvasBlocState state,
    bool isWide,
  ) {
    final preset = _findSelectedPreset(state);
    return Container(
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
          // Back button
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
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
              preset != null
                  ? '${preset.label} — ${state.activeDeck == "lower" ? "Lower Deck" : "Upper Deck"}'
                  : 'Select a preset to begin',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Name editor
          if (preset != null)
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
          // Save status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: state.isDirty
                  ? const Color(0xFFD97706).withValues(alpha: 0.15)
                  : const Color(0xFF16A34A).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: state.isDirty
                    ? const Color(0xFFD97706).withValues(alpha: 0.3)
                    : const Color(0xFF16A34A).withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              state.isDirty ? 'UNSAVED' : 'SAVED',
              style: TextStyle(
                color: state.isDirty
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
  }

  // ── Deck Switcher ───────────────────────────────────
  Widget _buildDeckSwitcher(LayoutCanvasBlocState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: const Color(0xFF112233),
      child: Row(
        children: [
          _deckTab(
            'Lower Deck',
            'lower',
            Icons.layers,
            state.activeDeck == 'lower',
          ),
          const Gap(8),
          _deckTab(
            'Upper Deck',
            'upper',
            Icons.layers_outlined,
            state.activeDeck == 'upper',
          ),
        ],
      ),
    );
  }

  Widget _deckTab(String label, String deck, IconData icon, bool active) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _bloc.add(DeckSwitched(deck)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFF7C3AED).withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: active
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
                color: active
                    ? const Color(0xFFA78BFA)
                    : const Color(0xFF556677),
              ),
              const Gap(6),
              Text(
                label,
                style: TextStyle(
                  color: active
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
  }

  // ── Inspector Panel ─────────────────────────────────
  Widget _buildInspectorPanel(
    BuildContext context,
    LayoutCanvasBlocState state,
  ) {
    final comp = state.activeCanvas?.componentById(_inspectorComponentId ?? '');
    if (comp == null) return const SizedBox.shrink();

    return CellInspectorPanel(
      component: comp,
      onApply: (updated) {
        _bloc.add(ComponentUpdated(componentId: comp.id, updated: updated));
        setState(() {
          _inspectorOpen = false;
          _inspectorComponentId = null;
        });
      },
      onDelete: () {
        _bloc.add(ComponentDeleted(comp.id));
        setState(() {
          _inspectorOpen = false;
          _inspectorComponentId = null;
        });
      },
      onClose: () {
        setState(() {
          _inspectorOpen = false;
          _inspectorComponentId = null;
        });
      },
    );
  }

  // ── Dialogs ─────────────────────────────────────────
  void _showDropTargetDialog(BuildContext context, ComponentType type) {
    // Show a simple row/col picker dialog
    final rowCtrl = TextEditingController(text: '1');
    final colCtrl = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2A3A),
        title: Text(
          'Place ${type.name}',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: rowCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Row',
                labelStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const Gap(8),
            TextField(
              controller: colCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Column',
                labelStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final row = int.tryParse(rowCtrl.text) ?? 1;
              final col = int.tryParse(colCtrl.text) ?? 1;
              _bloc.add(
                ComponentDropped(type: type, originRow: row, originCol: col),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Place'),
          ),
        ],
      ),
    );
  }

  void _showAddComponentDialog(BuildContext context, int row, int col) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A2A3A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add at Row $row, Col $col',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Gap(12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _addBtn(context, 'Seat', ComponentType.seat, row, col),
                _addBtn(
                  context,
                  'Sleeper Lower',
                  ComponentType.sleeperLower,
                  row,
                  col,
                ),
                _addBtn(
                  context,
                  'Sleeper Upper',
                  ComponentType.sleeperUpper,
                  row,
                  col,
                ),
                _addBtn(
                  context,
                  'Folding Seat',
                  ComponentType.foldingSeat,
                  row,
                  col,
                ),
                _addBtn(context, 'Lavatory', ComponentType.lavatory, row, col),
                _addBtn(context, 'Exit Door', ComponentType.exitDoor, row, col),
                _addBtn(
                  context,
                  'Emergency',
                  ComponentType.emergency,
                  row,
                  col,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _addBtn(
    BuildContext context,
    String label,
    ComponentType type,
    int row,
    int col,
  ) {
    final color = kComponentColors[type] ?? const Color(0xFF7C3AED);
    return ElevatedButton.icon(
      onPressed: () {
        _bloc.add(ComponentDropped(type: type, originRow: row, originCol: col));
        Navigator.pop(context);
      },
      icon: Icon(kComponentIcons[type] ?? Icons.add, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.2),
        foregroundColor: color,
      ),
    );
  }

  void _showPaletteDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
    // Alternatively show as a dialog
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A2A3A),
        title: const Text(
          'Component Palette',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: 300,
          height: 400,
          child: ComponentPalette(
            onComponentSelected: (type) {
              Navigator.pop(context);
              _showDropTargetDialog(context, type);
            },
          ),
        ),
      ),
    );
  }

  // ── Save name ───────────────────────────────────────
  Future<void> _saveLayoutName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    try {
      await ApiService().put(
        '/bus-fleet/layouts/${_bloc.state.layoutId}',
        data: {'display_name': name},
      );
      setState(() => _nameSaved = true);
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

  // ── Empty State ─────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.grid_view,
              color: Color(0xFF7C3AED),
              size: 40,
            ),
          ),
          const Gap(16),
          const Text(
            'Select a Preset to Begin',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(8),
          const Text(
            'Choose a vehicle class from the sidebar\nor drag components from the palette',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF8899AA), fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────
  LayoutPreset? _findSelectedPreset(LayoutCanvasBlocState state) {
    final key = state.selectedPresetKey;
    if (key == null) return null;
    try {
      return LayoutPreset.builtIn.firstWhere((p) => p.key == key);
    } catch (_) {
      return null;
    }
  }

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
}

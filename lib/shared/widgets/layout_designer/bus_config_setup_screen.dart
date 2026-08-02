// NEXATRACE — BUS CONFIGURATION SETUP SCREEN
// ==============================================
// Pre-canvas setup for Absolute Layout. Captures bus profile info
// (number plate, maker, specifications) and dynamic seat configuration
// (left seats, right seats, row count) before entering the canvas editor.
//
// 100% isolated from the legacy grid system.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/shared/widgets/layout_designer/absolute_layout_designer_screen.dart';
import 'package:trace_odd/shared/bloc/layout_designer/layout_validation_bloc.dart';
import 'package:trace_odd/shared/bloc/layout_designer/layout_validation_event.dart';
import 'package:trace_odd/shared/bloc/layout_designer/layout_validation_state.dart';
import 'package:trace_odd/shared/models/transport/layout_validation_result.dart';
import 'package:trace_odd/shared/widgets/layout_designer/dimension_input_group.dart';
import 'package:trace_odd/shared/widgets/layout_designer/component_registry_panel.dart';
import 'package:trace_odd/shared/widgets/layout_designer/inter_seat_distance_input.dart';
import 'package:trace_odd/shared/models/transport/feet_inches.dart';
import 'package:trace_odd/shared/models/transport/component_registry.dart';
import 'package:trace_odd/shared/models/transport/layout_validator.dart';
import 'package:trace_odd/shared/models/transport/bus_dimensions.dart';

class BusConfigSetupScreen extends StatefulWidget {
  final String companyId;
  final String companyName;
  final String? layoutId;
  final String apiPrefix;
  final BusDimensions? initialDimensions;
  final ComponentRegistry? initialRegistry;
  final String? initialPlate;
  final String? initialMaker;
  final String? initialSpecs;
  final int initialLeftSeats;
  final int initialRightSeats;
  final int initialRowCount;
  final bool initialHasFrontPartition;
  final int initialFrontPartitionFt;
  final int initialFrontPartitionIn;
  final bool isPreset;

  const BusConfigSetupScreen({
    super.key,
    required this.companyId,
    required this.companyName,
    this.layoutId,
    this.apiPrefix = '/bus-owner',
    this.initialDimensions,
    this.initialRegistry,
    this.initialPlate,
    this.initialMaker,
    this.initialSpecs,
    this.initialLeftSeats = 0,
    this.initialRightSeats = 0,
    this.initialRowCount = 0,
    this.initialHasFrontPartition = false,
    this.initialFrontPartitionFt = 0,
    this.initialFrontPartitionIn = 0,
    this.isPreset = false,
  });

  @override
  State<BusConfigSetupScreen> createState() => _BusConfigSetupScreenState();
}

class _BusConfigSetupScreenState extends State<BusConfigSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  // ── Bus Profile ──
  late TextEditingController _numberPlateCtrl;
  late TextEditingController _presetNameCtrl;
  late TextEditingController _specsCtrl;
  late TextEditingController _otherMakerCtrl;
  String? _selectedMaker;

  // ── Dynamic Grid ──
  int _leftSeats = 0;
  int _rightSeats = 0;
  int _rowCount = 0;

  // ── Layout Strategy ──
  bool _usePreset = false;
  List<Map<String, dynamic>> _presets = [];
  Map<String, dynamic>? _selectedPreset;
  bool _presetsLoading = false;

  // ── Front Reserved Partition ──
  bool _hasFrontPartition = false;
  int _frontPartitionFt = 0;
  int _frontPartitionIn = 0;

  static const List<String> _busMakers = [
    'Hino',
    'Mercedes-Benz',
    'Volvo',
    'Scania',
    'MAN',
    'Iveco',
    'Yutong',
    'Others',
  ];

  @override
  void initState() {
    super.initState();
    _numberPlateCtrl = TextEditingController();
    _presetNameCtrl = TextEditingController();
    _specsCtrl = TextEditingController();
    _otherMakerCtrl = TextEditingController();

    // Apply pre-loaded data immediately (edit flow).
    if (widget.initialDimensions != null || widget.initialRegistry != null) {
      try {
        final vBloc = context.read<LayoutValidationBloc>();
        if (widget.initialDimensions != null) {
          vBloc.add(DimensionsChanged(widget.initialDimensions!));
        }
        if (widget.initialRegistry != null) {
          vBloc.add(RegistryChanged(widget.initialRegistry!));
        }
      } catch (_) {}
    }

    // Use pre-loaded values directly (no API call needed).
    if (widget.initialPlate != null && widget.initialPlate!.isNotEmpty) {
      if (widget.isPreset) {
        _presetNameCtrl.text = widget.initialPlate!;
      } else {
        _numberPlateCtrl.text = widget.initialPlate!;
        _selectedMaker = widget.initialMaker;
      }
      _specsCtrl.text = widget.initialSpecs ?? '';
      _leftSeats = widget.initialLeftSeats;
      _rightSeats = widget.initialRightSeats;
      _rowCount = widget.initialRowCount;
      _hasFrontPartition = widget.initialHasFrontPartition;
      _frontPartitionFt = widget.initialFrontPartitionFt;
      _frontPartitionIn = widget.initialFrontPartitionIn;
      _dispatchSeatMatrix();
    } else if (widget.layoutId != null) {
      // Fallback: load from API (only if caller didn't provide data).
      _loadExistingLayout();
    }
    _fetchPresets();
  }

  Future<void> _fetchPresets() async {
    setState(() => _presetsLoading = true);
    try {
      final api = ApiService();
      final r = await api.get('${widget.apiPrefix}/absolute-layouts/presets');
      final d = r?['data'];
      setState(() {
        _presets = d is List ? d.cast<Map<String, dynamic>>() : [];
        _presetsLoading = false;
      });
      // If editing an existing layout, try to auto-select the matching preset.
      if (widget.layoutId != null && _presets.isNotEmpty) {
        _matchPresetForEdit();
      }
    } catch (_) {
      setState(() => _presetsLoading = false);
    }
  }

  /// If the current layout matches a preset, auto-select it.
  void _matchPresetForEdit() {
    // Only match if not already in preset mode.
    if (_usePreset && _selectedPreset != null) return;
    // If the layout was configured as custom grid, don't override.
    // Heuristic: if the user previously had a custom seat matrix with
    // non-zero rows, assume custom grid mode.
    if (_rowCount > 0 && !_usePreset) return;
    // Try to match by display name or component count.
    for (final p in _presets) {
      final snap = p['current_snapshot'];
      if (snap is! Map) continue;
      final comps = snap['components'];
      if (comps is! List) continue;
      // Simple heuristic: match by component count.
      if (comps.length > 0 &&
          comps.length == (_rowCount * (_leftSeats + _rightSeats))) {
        // Rough match — auto-select this preset for display only.
        // Data comes from pre-loaded Bloc/_loadExistingLayout, not
        // from the presets list (which may be a summary).
        _selectedPreset = p;
        _usePreset = true;
        break;
      }
    }
  }

  /// Build a human-readable subtitle from preset snapshot components.
  String _presetSubtitle(Map<String, dynamic> p) {
    final snap = p['current_snapshot'];
    if (snap is! Map) {
      final seats = p['total_seats'] ?? p['seat_count'] ?? '?';
      return '$seats seats · ${p['deck_level'] ?? 'single'} deck';
    }
    final comps = snap['components'];
    if (comps is! List || comps.isEmpty) {
      final seats = p['total_seats'] ?? p['seat_count'] ?? '?';
      return '$seats seats · ${p['deck_level'] ?? 'single'} deck';
    }
    final counts = <String, int>{};
    for (final c in comps) {
      if (c is! Map) continue;
      final t = c['type']?.toString() ?? '';
      if (t == 'sleeperLower')
        counts['Low.Berth'] = (counts['Low.Berth'] ?? 0) + 1;
      else if (t == 'sleeperUpper')
        counts['Upp.Berth'] = (counts['Upp.Berth'] ?? 0) + 1;
      else if (t == 'seat')
        counts['Seats'] = (counts['Seats'] ?? 0) + 1;
      else if (t == 'businessClassSeat')
        counts['Business'] = (counts['Business'] ?? 0) + 1;
      else if (t == 'foldingSeat')
        counts['Folding'] = (counts['Folding'] ?? 0) + 1;
    }
    if (counts.isEmpty) {
      final seats = p['total_seats'] ?? p['seat_count'] ?? '?';
      return '$seats seats · ${p['deck_level'] ?? 'single'} deck';
    }
    return counts.entries.map((e) => '${e.value} ${e.key}').join(' + ');
  }

  /// Hydrate form fields from a selected preset's data.
  /// Fetches the full preset from the API if the list summary
  /// doesn't include the complete snapshot.
  Future<void> _hydratePresetData(Map<String, dynamic> preset) async {
    var snap = preset['current_snapshot'];
    // If the presets list didn't include a full snapshot, fetch it.
    if (snap is! Map || snap['registry'] == null) {
      final id = preset['id']?.toString();
      if (id != null) {
        try {
          final api = ApiService();
          final r = await api.get('${widget.apiPrefix}/absolute-layouts/$id');
          final d = r?['data'];
          if (d is Map && d['current_snapshot'] is Map) {
            snap = d['current_snapshot'];
          }
        } catch (_) {}
      }
    }
    if (snap is! Map) return;
    try {
      final vBloc = context.read<LayoutValidationBloc>();
      // Canvas dimensions
      final snapCanvas = snap['canvas'];
      if (snapCanvas is Map) {
        final w = (snapCanvas['canvas_width'] as num?)?.toDouble();
        final h = (snapCanvas['canvas_height'] as num?)?.toDouble();
        if (w != null && h != null && w > 0 && h > 0) {
          final hPx = _readHeightPx(snap);
          vBloc.add(
            DimensionsChanged(
              BusDimensions(
                length: FeetInches.fromPixels(h),
                width: FeetInches.fromPixels(w),
                height: FeetInches.fromPixels(hPx),
              ),
            ),
          );
        }
      }
      // Registry
      dynamic regJson = snap['registry'];
      if (regJson is String) {
        try {
          regJson = jsonDecode(regJson);
        } catch (_) {
          regJson = null;
        }
      }
      if (regJson is Map) {
        try {
          final reg = ComponentRegistry.fromJson(
            Map<String, dynamic>.from(regJson),
          );
          vBloc.add(RegistryChanged(reg));
        } catch (_) {}
      }
    } catch (_) {}
  }

  /// Read bus height in pixels from snapshot metadata.
  /// Returns 5'6" (66 px) as fallback for legacy layouts.
  double _readHeightPx(Map snap) {
    final meta = snap['metadata'];
    final v =
        snap['bus_height_px'] ?? (meta is Map ? meta['bus_height_px'] : null);
    if (v is num) return v.toDouble();
    return 66.0; // 5'6" default
  }

  Future<void> _loadExistingLayout() async {
    try {
      final api = ApiService();
      final r = await api.get(
        '${widget.apiPrefix}/absolute-layouts/${widget.layoutId}',
      );
      final d = r?['data'];
      if (d is Map) {
        final displayName =
            d['display_name']?.toString() ?? d['name']?.toString() ?? '';
        // Parse plate + maker from display_name (e.g. "GUJ-78-98745 | Volvo")
        if (displayName.contains(' | ')) {
          final parts = displayName.split(' | ');
          _numberPlateCtrl.text = parts[0];
          _selectedMaker = _busMakers.contains(parts[1]) ? parts[1] : null;
        } else {
          _numberPlateCtrl.text = displayName;
        }
        _specsCtrl.text =
            d['specifications']?.toString() ?? d['notes']?.toString() ?? '';

        final snap = d['current_snapshot'];
        if (snap is Map) {
          // Canvas dimensions from snapshot.canvas (not top-level)
          final snapCanvas = snap['canvas'];
          double canvasW = 280.0, canvasH = 896.0;
          if (snapCanvas is Map) {
            canvasW =
                (snapCanvas['canvas_width'] as num?)?.toDouble() ?? canvasW;
            canvasH =
                (snapCanvas['canvas_height'] as num?)?.toDouble() ?? canvasH;
          }
          // Registry from snapshot (may be a JSON string or native Map)
          dynamic regJson = snap['registry'];
          if (regJson is String) {
            try {
              regJson = jsonDecode(regJson);
            } catch (_) {
              regJson = null;
            }
          }
          ComponentRegistry? reg;
          if (regJson is Map) {
            try {
              reg = ComponentRegistry.fromJson(
                Map<String, dynamic>.from(regJson),
              );
            } catch (_) {}
          }
          // Dispatch to Bloc (skip dims if already provided by caller)
          try {
            final vBloc = context.read<LayoutValidationBloc>();
            if (widget.initialDimensions == null) {
              vBloc.add(
                DimensionsChanged(
                  BusDimensions(
                    length: FeetInches.fromPixels(canvasH),
                    width: FeetInches.fromPixels(canvasW),
                    height: FeetInches.fromPixels(_readHeightPx(snap)),
                  ),
                ),
              );
            }
            if (reg != null) vBloc.add(RegistryChanged(reg));
          } catch (_) {}

          // ── Derive seat matrix from component positions ──
          // ALWAYS run this — not gated behind initialDimensions == null.
          final comps = snap['components'];
          if (comps is List && comps.isNotEmpty) {
            // Front-reserved boundary — exclude VIP/driver-area seats.
            final frontPxRaw =
                snap['metadata']?['front_partition_px'] ??
                snap['front_partition_px'];
            // Preserve 0 when partition is OFF (no forced boundary).
            // Only clamp when partition is actually enabled.
            final double frontBoundary = frontPxRaw is num
                ? (frontPxRaw).toDouble() > 0
                      ? (frontPxRaw).toDouble()
                      : 0.0
                : 0.0; // Legacy layouts with no metadata — no forced gap.
            const structural = {
              'driverCabin',
              'exitDoor',
              'sideDoor',
              'slidingDoor',
              'frontDoor',
              'rearDoor',
              'aisle',
              'emergency',
              'lavatory',
              'restaurantTable',
              'empty',
            };
            final ySet = <int>{};
            final firstRowXs = <double>[];
            double? firstY;
            double minSeatY = double.infinity;
            for (final c in comps) {
              if (c is! Map) continue;
              final t = c['type']?.toString() ?? '';
              if (structural.contains(t)) continue;
              final y = (c['y'] as num?)?.toDouble();
              final x = (c['x'] as num?)?.toDouble();
              if (y == null || x == null) continue;
              // Skip seats inside the front reserved area (VIP, etc.).
              if (y < frontBoundary) continue;
              ySet.add(y.round());
              if (y < minSeatY) minSeatY = y;
              if (firstY == null) firstY = y;
              if ((y - firstY!).abs() < 5) {
                firstRowXs.add(x);
              }
            }
            // Detect left vs right by finding the aisle gap in X positions.
            // Only merge berth pairs (lower+upper at same floor column);
            // standard seats must never be merged so every column is counted.
            bool hasBerths = false;
            for (final c in comps) {
              if (c is! Map) continue;
              final t = c['type']?.toString() ?? '';
              final y = (c['y'] as num?)?.toDouble();
              if (y != null && firstY != null && (y - firstY!).abs() < 5) {
                if (t == 'sleeperLower' || t == 'sleeperUpper') {
                  hasBerths = true;
                  break;
                }
              }
            }
            int leftC = 0, rightC = 0;
            if (firstRowXs.isNotEmpty) {
              firstRowXs.sort();
              final mergeGap = hasBerths ? 80.0 : 20.0;
              final merged = <double>[firstRowXs.first];
              for (int i = 1; i < firstRowXs.length; i++) {
                if (firstRowXs[i] - merged.last > mergeGap) {
                  merged.add(firstRowXs[i]);
                }
              }
              double maxGap = 0;
              int gapIdx = 0;
              for (int i = 1; i < merged.length; i++) {
                final gap = merged[i] - merged[i - 1];
                if (gap > maxGap) {
                  maxGap = gap;
                  gapIdx = i;
                }
              }
              // Compute average column spacing for aisle validation.
              final avgGap = merged.length > 1
                  ? (merged.last - merged.first) / (merged.length - 1)
                  : 0.0;
              // Only treat as aisle if the gap is clearly wider than
              // inter‑column spacing (≥ 1.5× average). Prevents
              // all‑right or all‑left layouts from being split in two.
              if (maxGap > 30 && merged.length > 1 && maxGap >= avgGap * 1.5) {
                leftC = gapIdx;
                rightC = merged.length - gapIdx;
              } else {
                // No clear aisle gap detected between columns.
                // Infer side from position relative to canvas:
                // - If ALL columns are in the right 80% → all right seats
                // - If ALL columns are in the left 80% → all left seats
                // - Otherwise fall back to midX split
                final midX = canvasW / 2;
                final allRight = merged.every((x) => x > canvasW * 0.20);
                final allLeft = merged.every((x) => x < canvasW * 0.80);
                if (allRight && !allLeft) {
                  leftC = 0;
                  rightC = merged.length;
                } else if (allLeft && !allRight) {
                  leftC = merged.length;
                  rightC = 0;
                } else {
                  for (final x in merged) {
                    if (x < midX)
                      leftC++;
                    else
                      rightC++;
                  }
                }
              }
            }
            // ── Restore front reserved space from snapshot metadata ──
            final frontPxMeta =
                snap['metadata']?['front_partition_px'] ??
                snap['front_partition_px'];
            bool hasFront = false;
            int ftVal = 0, inVal = 0;
            if (frontPxMeta is num && (frontPxMeta).toDouble() > 0) {
              final reservedInches = ((frontPxMeta).toDouble() / 4.0).round();
              if (reservedInches > 0) {
                hasFront = true;
                ftVal = reservedInches ~/ 12;
                inVal = reservedInches % 12;
              }
            }
            // ── Seat matrix from metadata (authoritative, saved by designer) ──
            final savedLeft =
                snap['metadata']?['left_seats'] ?? snap['left_seats'];
            final savedRight =
                snap['metadata']?['right_seats'] ?? snap['right_seats'];
            final savedRows =
                snap['metadata']?['row_count'] ?? snap['row_count'];
            setState(() {
              // Use saved metadata when available (reliable round-trip).
              // Fall back to position-derived values for legacy layouts.
              if (savedLeft is int && savedRight is int && savedRows is int) {
                _rowCount = savedRows.clamp(1, 50);
                _leftSeats = savedLeft.clamp(0, 8);
                _rightSeats = savedRight.clamp(0, 8);
              } else {
                _rowCount = hasFront
                    ? ySet.length.clamp(1, 50)
                    : (ySet.length + 1).clamp(1, 50);
                _leftSeats = leftC.clamp(0, 8);
                _rightSeats = rightC.clamp(0, 8);
              }
              _hasFrontPartition = hasFront;
              _frontPartitionFt = ftVal;
              _frontPartitionIn = inVal;
            });
            _dispatchSeatMatrix();
          }
        }
      }
    } catch (_) {
      // Silently ignore — form starts empty.
    }
  }

  @override
  void dispose() {
    _numberPlateCtrl.dispose();
    _presetNameCtrl.dispose();
    _specsCtrl.dispose();
    _otherMakerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1628),
        title: const Text(
          'Bus Configuration Setup',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ═══════════════════════════════════════════
                // SECTION 1: BUS PROFILE
                // ═══════════════════════════════════════════
                if (widget.isPreset) ...[
                  _sectionHeader(Icons.bookmark, 'PRESET TEMPLATE'),
                  const SizedBox(height: 12),
                  _fieldLabel('Preset / Template Name'),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: _presetNameCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: _inputDecoration(
                      hint: 'e.g. Standard 5x4 Sleeper Layout',
                      prefixIcon: Icons.label,
                    ),
                  ),
                  const SizedBox(height: 14),
                ] else ...[
                  _sectionHeader(Icons.directions_bus, 'BUS PROFILE'),
                  const SizedBox(height: 12),
                  _fieldLabel('Bus Number Plate'),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: _numberPlateCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: _inputDecoration(
                      hint: 'e.g. DHAKA-METRO-JA-11-9999',
                      prefixIcon: Icons.confirmation_number,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _fieldLabel('Bus Maker / Company'),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    value: _selectedMaker,
                    dropdownColor: const Color(0xFF122442),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: _inputDecoration(
                      hint: 'Select manufacturer',
                      prefixIcon: Icons.factory,
                    ),
                    items: _busMakers
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedMaker = v),
                  ),
                  if (_selectedMaker == 'Others') ...[
                    const SizedBox(height: 12),
                    _fieldLabel('Specify Manufacturer Name'),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _otherMakerCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: _inputDecoration(
                        hint: 'e.g. Custom Coach Co.',
                        prefixIcon: Icons.edit,
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 14),

                // Additional Specs
                _fieldLabel('Additional Information / Specifications'),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _specsCtrl,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: _inputDecoration(
                    hint:
                        'e.g. Total Capacity: 54 seats\nRoute Permit: Dhaka-Chittagong\nCoach Type: AC Sleeper',
                    prefixIcon: Icons.description,
                  ),
                ),
                const SizedBox(height: 24),

                // ═══════════════════════════════════════════
                // LAYOUT STRATEGY
                // ═══════════════════════════════════════════
                _sectionHeader(Icons.tune, 'LAYOUT STRATEGY'),
                const SizedBox(height: 12),

                // Toggle: Preset vs Custom
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: true,
                      label: Text(
                        'Saved Presets',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      icon: Icon(Icons.bookmark, size: 16),
                    ),
                    ButtonSegment(
                      value: false,
                      label: Text(
                        'Custom Grid',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      icon: Icon(Icons.grid_view, size: 16),
                    ),
                  ],
                  selected: {_usePreset},
                  style: ButtonStyle(
                    backgroundColor: const WidgetStatePropertyAll(
                      Color(0xFF122442),
                    ),
                    foregroundColor: const WidgetStatePropertyAll(
                      Colors.white70,
                    ),
                    side: const WidgetStatePropertyAll(
                      BorderSide(color: Color(0x30FFFFFF)),
                    ),
                    overlayColor: const WidgetStatePropertyAll(
                      Color(0x20FFFFFF),
                    ),
                  ),
                  onSelectionChanged: (v) =>
                      setState(() => _usePreset = v.first),
                ),
                const SizedBox(height: 16),

                if (_usePreset) ...[
                  // Preset selector
                  if (_presetsLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_presets.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF122442),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0x20FFFFFF)),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Color(0x60FFFFFF),
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'No saved presets available. Create one from the Sub-Admin panel.',
                              style: TextStyle(
                                color: Color(0x60FFFFFF),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('Select a Saved Layout Preset'),
                        const SizedBox(height: 4),
                        ..._presets.map(
                          (p) => Card(
                            color: _selectedPreset?['id'] == p['id']
                                ? const Color(0xFF1A3A5C)
                                : const Color(0xFF122442),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: _selectedPreset?['id'] == p['id']
                                    ? const Color(0xFF7C3AED)
                                    : const Color(0x20FFFFFF),
                              ),
                            ),
                            child: ListTile(
                              title: Text(
                                p['display_name']?.toString() ?? 'Untitled',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                              subtitle: Text(
                                _presetSubtitle(p),
                                style: const TextStyle(
                                  color: Color(0xFF8899AA),
                                  fontSize: 11,
                                ),
                              ),
                              leading: const Icon(
                                Icons.directions_bus,
                                color: Color(0xFF7C3AED),
                              ),
                              onTap: () async {
                                setState(() => _selectedPreset = p);
                                await _hydratePresetData(p);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
                if (!_usePreset) ...[
                  // ═══════════════════════════════════════════
                  _sectionHeader(Icons.straighten, 'PHYSICAL DIMENSIONS'),
                  const SizedBox(height: 4),
                  const Text(
                    'Define the interior boundaries of the bus.',
                    style: TextStyle(color: Color(0x60FFFFFF), fontSize: 11),
                  ),
                  const SizedBox(height: 12),
                  _buildDimensionsInputs(),
                  const SizedBox(height: 16),
                  // ═══════════════════════════════════════════
                  // FRONT RESERVED SPACE (Driver / VIP Partition)
                  // ═══════════════════════════════════════════
                  _sectionHeader(
                    Icons.space_dashboard_rounded,
                    'FRONT RESERVED SPACE',
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Reserve front space for driver cabin, VIP seats, or other uses.',
                    style: TextStyle(color: Color(0x60FFFFFF), fontSize: 11),
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    title: const Text(
                      'Enable Front Reserved Space',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    subtitle: Text(
                      _hasFrontPartition
                          ? '${_frontPartitionFt}\' ${_frontPartitionIn}" reserved at front'
                          : 'No front reservation — all space available for seats',
                      style: const TextStyle(
                        color: Color(0xFF667788),
                        fontSize: 11,
                      ),
                    ),
                    value: _hasFrontPartition,
                    activeColor: const Color(0xFF7C3AED),
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) {
                      setState(() => _hasFrontPartition = v);
                      _dispatchSeatMatrix();
                    },
                  ),
                  if (_hasFrontPartition) ...[
                    const SizedBox(height: 8),
                    // Feet + Inches inputs for front reserved length
                    Row(
                      children: [
                        Expanded(
                          child: _dimensionField(
                            label: 'Feet',
                            value: _frontPartitionFt,
                            min: 0,
                            max: 50,
                            onChanged: (v) {
                              setState(() => _frontPartitionFt = v);
                              _dispatchSeatMatrix();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _dimensionField(
                            label: 'Inches',
                            value: _frontPartitionIn,
                            min: 0,
                            max: 11,
                            onChanged: (v) {
                              setState(() => _frontPartitionIn = v);
                              _dispatchSeatMatrix();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Remaining space display
                    BlocBuilder<LayoutValidationBloc, LayoutValidationState>(
                      builder: (context, state) {
                        final totalIn = state.dimensions.length.totalInches;
                        final frontIn =
                            (_frontPartitionFt * 12.0) + _frontPartitionIn;
                        // Deduct initial gap as well (gap before first row).
                        final gapIn = state.registry.initialGap.totalInches;
                        final remainingIn = (totalIn - frontIn - gapIn).clamp(
                          0,
                          totalIn,
                        );
                        final remFt = remainingIn ~/ 12;
                        final remIn = (remainingIn % 12).round();
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF122442),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0x20FFFFFF)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.straighten,
                                color: Color(0xFF16A34A),
                                size: 14,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Remaining for seats: ${remFt}\' ${remIn}"'
                                '  (${state.dimensions.length.displayString} total'
                                ' − ${(_frontPartitionFt > 0 || _frontPartitionIn > 0) ? '${_frontPartitionFt}\' ${_frontPartitionIn}" partition' : ''}'
                                '${gapIn > 0 ? ' − ${state.registry.initialGap.displayString} gap' : ''})',
                                style: const TextStyle(
                                  color: Color(0xFF16A34A),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ],
                // Component Registry — always visible, even for presets
                const SizedBox(height: 16),
                _sectionHeader(Icons.category, 'COMPONENT REGISTRY'),
                const SizedBox(height: 12),
                _buildRegistryPanel(),
                const SizedBox(height: 16),
                // Aisle & Gap — always visible, including Initial Gap
                _sectionHeader(Icons.space_bar, 'AISLE & GAP'),
                const SizedBox(height: 12),
                _buildAisleGapInputs(),
                const SizedBox(height: 24),
                if (!_usePreset) ...[
                  // Custom grid configuration — ALL limits computed from physics
                  _sectionHeader(Icons.grid_view, 'DYNAMIC GRID CONFIGURATION'),
                  const SizedBox(height: 4),
                  const Text(
                    'All limits are computed from bus dimensions + seat specs.',
                    style: TextStyle(color: Color(0x60FFFFFF), fontSize: 11),
                  ),
                  const SizedBox(height: 14),

                  BlocBuilder<LayoutValidationBloc, LayoutValidationState>(
                    builder: (context, state) {
                      final dims = state.dimensions;
                      final reg = state.registry;
                      final partL = reg.maxPartLength;
                      final gap = reg.interSeatGap;

                      // No hard limits — user can click freely.
                      // RED/GREEN validation below tells them what fits.
                      const colMax = 8;
                      const rowMax = 50;

                      // ── Build required length for validation display ──
                      // ── Build total required length from actual row count ──
                      final requiredLen =
                          LayoutValidator.calculateRequiredLength(
                            rows: _rowCount,
                            partLength: partL,
                            interSeatGap: gap,
                          );
                      final frontReservedFtIn = _hasFrontPartition
                          ? FeetInches.normalize(
                              _frontPartitionFt,
                              _frontPartitionIn,
                            )
                          : FeetInches.zero;
                      // Deduct both partition and initial gap from total.
                      final availableLen =
                          dims.length - frontReservedFtIn - reg.initialGap;
                      final lengthOk =
                          requiredLen <= availableLen || requiredLen.isZero;

                      return Column(
                        children: [
                          // Seat counts per side
                          Row(
                            children: [
                              Expanded(
                                child: _stepperField(
                                  label: 'Left Seats',
                                  value: _leftSeats,
                                  min: 0,
                                  max: colMax,
                                  onChanged: (v) {
                                    setState(() => _leftSeats = v);
                                    _dispatchSeatMatrix();
                                  },
                                  icon: Icons.event_seat,
                                  color: const Color(0xFF7C3AED),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 18,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0x20FFFFFF),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Column(
                                  children: [
                                    Icon(
                                      Icons.swap_horiz,
                                      color: Color(0x30FFFFFF),
                                      size: 20,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'AISLE',
                                      style: TextStyle(
                                        color: Color(0x30FFFFFF),
                                        fontSize: 8,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _stepperField(
                                  label: 'Right Seats',
                                  value: _rightSeats,
                                  min: 0,
                                  max: colMax,
                                  onChanged: (v) {
                                    setState(() => _rightSeats = v);
                                    _dispatchSeatMatrix();
                                  },
                                  icon: Icons.event_seat,
                                  color: const Color(0xFF3B82F6),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _stepperField(
                            label: 'Total Rows',
                            value: _rowCount,
                            min: 1,
                            max: rowMax,
                            onChanged: (v) {
                              setState(() => _rowCount = v);
                              _dispatchSeatMatrix();
                            },
                            icon: Icons.table_rows,
                            color: const Color(0xFF16A34A),
                            wide: true,
                          ),
                          const SizedBox(height: 8),
                          // ── Real-time dimension comparison ──
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF122442),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: lengthOk
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFFDC2626),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      lengthOk
                                          ? Icons.check_circle
                                          : Icons.warning_amber_rounded,
                                      color: lengthOk
                                          ? const Color(0xFF16A34A)
                                          : const Color(0xFFDC2626),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        lengthOk
                                            ? 'Fits within ${availableLen.displayString} remaining space'
                                            : 'NEEDS ${requiredLen.displayString} — exceeds available ${availableLen.displayString}',
                                        style: TextStyle(
                                          color: lengthOk
                                              ? const Color(0xFF16A34A)
                                              : const Color(0xFFDC2626),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${_leftSeats}L + ${_rightSeats}R × $_rowCount rows'
                                  '  |  part: ${partL.displayString}  |  gap: ${gap.displayString}'
                                  '  |  init gap: ${reg.initialGap.displayString}'
                                  '  |  required: ${requiredLen.displayString}',
                                  style: const TextStyle(
                                    color: Color(0xFF667788),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],

                // ═══════════════════════════════════════════
                // VALIDATION GATE + ACTION BUTTONS
                // ═══════════════════════════════════════════
                BlocBuilder<LayoutValidationBloc, LayoutValidationState>(
                  builder: (context, state) {
                    final result = state.lastResult;
                    final canProceed =
                        result is ValidationSuccess || result == null;
                    return Column(
                      children: [
                        // --- Bus interior vs Layout requirements ---
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF122442),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0x20FFFFFF)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.directions_bus,
                                    color: Color(0xFF7C3AED),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Bus interior:',
                                    style: TextStyle(
                                      color: Color(0x80FFFFFF),
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${state.dimensions.length.displayString} x ${state.dimensions.width.displayString}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    canProceed
                                        ? Icons.check_circle
                                        : Icons.warning_amber_rounded,
                                    color: canProceed
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFFDC2626),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    canProceed
                                        ? 'Layout fits:   '
                                        : 'Layout needs:  ',
                                    style: TextStyle(
                                      color: canProceed
                                          ? const Color(0xFF16A34A)
                                          : const Color(0xFFDC2626),
                                      fontSize: 11,
                                    ),
                                  ),
                                  Text(
                                    state.predictedLength.isZero
                                        ? '---'
                                        : '${state.predictedLength.displayString} x ${state.predictedWidth.displayString}',
                                    style: TextStyle(
                                      color: canProceed
                                          ? const Color(0xFF16A34A)
                                          : const Color(0xFFDC2626),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Validation failure banner
                        if (result is ValidationFailure)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDC2626).withAlpha(30),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFDC2626).withAlpha(120),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Color(0xFFDC2626),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    result.userMessage,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close, size: 18),
                                label: const Text('Cancel'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white54,
                                  side: const BorderSide(
                                    color: Color(0x30FFFFFF),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton.icon(
                                onPressed:
                                    (canProceed || widget.layoutId != null)
                                    ? _startDesigning
                                    : null,
                                icon: const Icon(
                                  Icons.design_services,
                                  size: 18,
                                ),
                                label: Text(
                                  canProceed
                                      ? (widget.layoutId != null
                                            ? 'Save & Open Designer'
                                            : 'Start Designing')
                                      : 'LAYOUT EXCEEDS CAPACITY',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: canProceed
                                      ? const Color(0xFF7C3AED)
                                      : Colors.grey[800],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Physics helpers ──────────────────────────────────

  void _dispatchSeatMatrix() {
    try {
      context.read<LayoutValidationBloc>().add(
        SeatMatrixChanged(
          rows: _rowCount,
          leftSeats: _leftSeats,
          rightSeats: _rightSeats,
        ),
      );
    } catch (_) {}
  }

  Widget _buildDimensionsInputs() {
    return BlocBuilder<LayoutValidationBloc, LayoutValidationState>(
      builder: (context, state) {
        final dims = state.dimensions;
        return Column(
          children: [
            DimensionInputGroup(
              key: ValueKey('length_${dims.length.feet}_${dims.length.inches}'),
              label: 'Bus Inside Length (front to back)',
              initialValue: dims.length,
              minFeet: 0,
              maxFeet: 80,
              onChanged: (v) {
                try {
                  context.read<LayoutValidationBloc>().add(
                    DimensionsChanged(dims.copyWith(length: v)),
                  );
                } catch (_) {}
              },
            ),
            const SizedBox(height: 12),
            DimensionInputGroup(
              key: ValueKey('width_${dims.width.feet}_${dims.width.inches}'),
              label: 'Bus Inside Width (left to right)',
              initialValue: dims.width,
              minFeet: 0,
              maxFeet: 15,
              onChanged: (v) {
                try {
                  context.read<LayoutValidationBloc>().add(
                    DimensionsChanged(dims.copyWith(width: v)),
                  );
                } catch (_) {}
              },
            ),
            const SizedBox(height: 12),
            DimensionInputGroup(
              key: ValueKey('height_${dims.height.feet}_${dims.height.inches}'),
              label: 'Bus Inside Height',
              initialValue: dims.height,
              onChanged: (v) {
                try {
                  context.read<LayoutValidationBloc>().add(
                    DimensionsChanged(dims.copyWith(height: v)),
                  );
                } catch (_) {}
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildRegistryPanel() {
    return BlocBuilder<LayoutValidationBloc, LayoutValidationState>(
      builder: (context, state) {
        return ComponentRegistryPanel(
          registry: state.registry,
          onChanged: (r) {
            try {
              context.read<LayoutValidationBloc>().add(RegistryChanged(r));
            } catch (_) {}
          },
        );
      },
    );
  }

  Widget _buildAisleGapInputs() {
    return BlocBuilder<LayoutValidationBloc, LayoutValidationState>(
      builder: (context, state) {
        return InterSeatDistanceInput(
          registry: state.registry,
          onChanged: (r) {
            try {
              context.read<LayoutValidationBloc>().add(RegistryChanged(r));
            } catch (_) {}
          },
        );
      },
    );
  }

  void _startDesigning() {
    final String numberPlate;
    final String maker;
    if (widget.isPreset) {
      numberPlate = _presetNameCtrl.text.trim();
      maker = '';
    } else {
      numberPlate = _numberPlateCtrl.text.trim();
      maker = _selectedMaker == 'Others'
          ? _otherMakerCtrl.text.trim()
          : (_selectedMaker ?? '');
    }

    // Pull physics data from the validation BloC if available.
    LayoutValidationBloc? validationBloc;
    FeetInches busLength = const FeetInches(feet: 0, inches: 0);
    FeetInches busWidth = const FeetInches(feet: 0, inches: 0);
    ComponentRegistry? registry;
    try {
      validationBloc = BlocProvider.of<LayoutValidationBloc>(context);
      final vs = validationBloc.state;
      busLength = vs.dimensions.length;
      busWidth = vs.dimensions.width;
      registry = vs.registry;
      debugPrint(
        'START_DESIGN: dims=${busLength.displayString} x ${busWidth.displayString} '
        'rows=${vs.rows} L/R=${vs.leftSeats}/${vs.rightSeats} '
        'registryParts=${vs.registry.parts.keys.map((k) => k.name).toList()}',
      );
    } catch (e) {
      debugPrint('START_DESIGN: BlocProvider.of FAILED: $e — using defaults');
      validationBloc = null;
      registry = null;
    }

    // Embed authoritative dimensions into config so the designer
    // never relies on a potentially-null Bloc lookup for boundary math.
    final double frontPx = _hasFrontPartition
        ? ((_frontPartitionFt * 12 + _frontPartitionIn) * 4.0)
        : 0.0;
    // Initial gap from registry (0 if not set — backward compatible).
    final double initialGapPx = registry?.initialGap.toPixels ?? 0;
    final config = BusConfig(
      numberPlate: numberPlate,
      maker: maker,
      specifications: _specsCtrl.text.trim(),
      leftSeats: _leftSeats,
      rightSeats: _rightSeats,
      rowCount: _rowCount,
      busLengthPx: busLength.toPixels,
      busWidthPx: busWidth.toPixels,
      frontPartitionPx: frontPx,
      initialGapPx: initialGapPx,
    );

    // When a preset is selected, pass its ID so the designer fetches
    // the preset's saved layout components instead of auto-generating
    // a fresh grid from the seat counts.
    final presetId = (_usePreset && _selectedPreset != null)
        ? _selectedPreset!['id']?.toString()
        : null;
    final effectiveLayoutId = presetId ?? widget.layoutId;

    // When adding a new vehicle from a preset template, clone the layout
    // so Save creates a new record owned by the current user (not the
    // sub-admin who created the original template).
    final isNewVehicle = widget.layoutId == null;
    final shouldClone = isNewVehicle && presetId != null;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => AbsoluteLayoutDesignerScreen(
          companyId: widget.companyId,
          companyName: widget.companyName,
          layoutId: effectiveLayoutId,
          config: config,
          apiPrefix: widget.apiPrefix,
          cloneFromTemplate: shouldClone,
          isPreset: widget.isPreset,
          busDimensions: validationBloc?.state.dimensions,
          registry: registry ?? validationBloc?.state.registry,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // HELPER WIDGETS
  // ═══════════════════════════════════════════════

  Widget _sectionHeader(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF7C3AED).withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF7C3AED), size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xCCFFFFFF),
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0x80FFFFFF),
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF8899AA), fontSize: 13),
      filled: true,
      fillColor: const Color(0xFF122442),
      prefixIcon: Icon(prefixIcon, color: const Color(0x60FFFFFF), size: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0x15FFFFFF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  Widget _stepperField({
    required String label,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
    required IconData icon,
    required Color color,
    bool wide = false,
  }) {
    return Container(
      width: wide ? double.infinity : null,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF122442),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x15FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0x80FFFFFF),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 28),
                color: value > min ? color : const Color(0xFF334455),
                onPressed: value > min ? () => onChanged(value - 1) : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
              const SizedBox(width: 12),
              Text(
                '$value',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 28),
                color: value < max ? color : const Color(0xFF334455),
                onPressed: value < max ? () => onChanged(value + 1) : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dimensionField({
    required String label,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF122442),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x20FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0x80FFFFFF),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove, size: 18),
                color: value > min
                    ? const Color(0xFF7C3AED)
                    : const Color(0xFF334455),
                onPressed: value > min ? () => onChanged(value - 1) : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              const SizedBox(width: 8),
              Text(
                '$value',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add, size: 18),
                color: value < max
                    ? const Color(0xFF7C3AED)
                    : const Color(0xFF334455),
                onPressed: value < max ? () => onChanged(value + 1) : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Holds the bus configuration data collected before entering the canvas.
class BusConfig {
  final String numberPlate;
  final String maker;
  final String specifications;
  final int leftSeats;
  final int rightSeats;
  final int rowCount;
  final double busLengthPx; // authoritative interior length in pixels
  final double busWidthPx; // authoritative interior width in pixels
  final double frontPartitionPx; // reserved front space (driver/VIP) in pixels
  final double initialGapPx; // gap before first row when front partition is OFF

  const BusConfig({
    this.numberPlate = '',
    this.maker = '',
    this.specifications = '',
    this.leftSeats = 0,
    this.rightSeats = 0,
    this.rowCount = 0,
    this.busLengthPx = 0.0,
    this.busWidthPx = 0.0,
    this.frontPartitionPx = 0.0,
    this.initialGapPx = 0.0,
  });

  Map<String, dynamic> toJson() => {
    'number_plate': numberPlate,
    'maker': maker,
    'specifications': specifications,
    'left_seats': leftSeats,
    'right_seats': rightSeats,
    'row_count': rowCount,
  };
}

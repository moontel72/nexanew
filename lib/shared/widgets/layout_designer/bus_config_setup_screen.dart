// NEXATRACE — BUS CONFIGURATION SETUP SCREEN
// ==============================================
// Pre-canvas setup for Absolute Layout. Captures bus profile info
// (number plate, maker, specifications) and dynamic seat configuration
// (left seats, right seats, row count) before entering the canvas editor.
//
// 100% isolated from the legacy grid system.

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

  const BusConfigSetupScreen({
    super.key,
    required this.companyId,
    required this.companyName,
    this.layoutId,
    this.apiPrefix = '/bus-owner',
  });

  @override
  State<BusConfigSetupScreen> createState() => _BusConfigSetupScreenState();
}

class _BusConfigSetupScreenState extends State<BusConfigSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  // ── Bus Profile ──
  late TextEditingController _numberPlateCtrl;
  late TextEditingController _specsCtrl;
  late TextEditingController _otherMakerCtrl;
  String? _selectedMaker;

  // ── Dynamic Grid ──
  int _leftSeats = 2;
  int _rightSeats = 2;
  int _rowCount = 14;

  // ── Layout Strategy ──
  bool _usePreset = false;
  List<Map<String, dynamic>> _presets = [];
  Map<String, dynamic>? _selectedPreset;
  bool _presetsLoading = false;

  // ── Front Reserved Partition ──
  bool _hasFrontPartition = false;
  int _frontPartitionFt = 2;
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
    _specsCtrl = TextEditingController();
    _otherMakerCtrl = TextEditingController();
    if (widget.layoutId != null) {
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
    } catch (_) {
      setState(() => _presetsLoading = false);
    }
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

        // ── Restore saved dimensions into validation Bloc ──
        final canvasW = (d['canvas_width'] as num?)?.toDouble() ?? 280.0;
        final canvasH = (d['canvas_height'] as num?)?.toDouble() ?? 896.0;
        try {
          final vBloc = context.read<LayoutValidationBloc>();
          vBloc.add(DimensionsChanged(BusDimensions(
            length: FeetInches.fromPixels(canvasH),
            width: FeetInches.fromPixels(canvasW),
            height: const FeetInches(feet: 5, inches: 6),
          )));
        } catch (_) {}

        // ── Restore registry (aisle, gap, seat specs) ──
        final snap = d['current_snapshot'];
        Map<String, dynamic>? registryJson;
        if (snap is Map) {
          registryJson = snap['registry'] is Map
              ? Map<String, dynamic>.from(snap['registry'])
              : null;
        }
        if (registryJson != null) {
          try {
            final reg = ComponentRegistry.fromJson(registryJson);
            context.read<LayoutValidationBloc>().add(RegistryChanged(reg));
          } catch (_) {}
        }

        // ── Restore seat config from snapshot canvas ──
        final canvas = snap is Map ? snap['canvas'] : null;
        if (canvas is Map) {
          setState(() {
            _rowCount = (canvas['row_count'] as int?) ?? 14;
            _leftSeats = (canvas['left_seats'] as int?) ?? 2;
            _rightSeats = (canvas['right_seats'] as int?) ?? 2;
          });
        }
      }
    } catch (_) {
      // Silently ignore — form starts empty.
    }
  }

  @override
  void dispose() {
    _numberPlateCtrl.dispose();
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
                _sectionHeader(Icons.directions_bus, 'BUS PROFILE'),
                const SizedBox(height: 12),

                // Number Plate
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

                // Bus Maker Dropdown
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
                // PHYSICAL DIMENSIONS
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
                          max: 10,
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
                      final remainingIn = (totalIn - frontIn).clamp(0, totalIn);
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
                              'Remaining for seats: ${remFt}\' ${remIn}"',
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
                const SizedBox(height: 16),
                // Component Registry
                _sectionHeader(Icons.category, 'COMPONENT REGISTRY'),
                const SizedBox(height: 12),
                _buildRegistryPanel(),
                const SizedBox(height: 16),
                // Aisle & Gap
                _sectionHeader(Icons.space_bar, 'AISLE & GAP'),
                const SizedBox(height: 12),
                _buildAisleGapInputs(),
                const SizedBox(height: 24),

                // ═══════════════════════════════════════════
                // SECTION 2: LAYOUT STRATEGY
                // ═══════════════════════════════════════════
                _sectionHeader(Icons.tune, 'LAYOUT STRATEGY'),
                const SizedBox(height: 12),

                // Toggle: Preset vs Custom
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: true,
                      label: Text('Saved Presets'),
                      icon: Icon(Icons.bookmark, size: 16),
                    ),
                    ButtonSegment(
                      value: false,
                      label: Text('Custom Grid'),
                      icon: Icon(Icons.grid_view, size: 16),
                    ),
                  ],
                  selected: {_usePreset},
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
                                '${p['total_seats'] ?? p['seat_count'] ?? '?'} seats · ${p['deck_level'] ?? 'single'} deck',
                                style: const TextStyle(
                                  color: Color(0xFF8899AA),
                                  fontSize: 11,
                                ),
                              ),
                              leading: const Icon(
                                Icons.directions_bus,
                                color: Color(0xFF7C3AED),
                              ),
                              onTap: () => setState(() => _selectedPreset = p),
                            ),
                          ),
                        ),
                      ],
                    ),
                ] else ...[
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
                      final availableLen = dims.length - frontReservedFtIn;
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
                const SizedBox(height: 28),

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
                                onPressed: canProceed ? _startDesigning : null,
                                icon: const Icon(
                                  Icons.design_services,
                                  size: 18,
                                ),
                                label: Text(
                                  canProceed
                                      ? 'Start Designing'
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
              label: 'Bus Inside Length (front to back)',
              initialValue: dims.length,
              minFeet: 8,
              maxFeet: 50,
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
              label: 'Bus Inside Width (left to right)',
              initialValue: dims.width,
              minFeet: 4,
              maxFeet: 10,
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
              label: 'Bus Inside Height',
              initialValue: dims.height,
              minFeet: 4,
              maxFeet: 8,
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
    // When "Others" is selected, use the custom typed name.
    final effectiveMaker = _selectedMaker == 'Others'
        ? _otherMakerCtrl.text.trim()
        : (_selectedMaker ?? '');

    // Pull physics data from the validation BloC if available.
    LayoutValidationBloc? validationBloc;
    FeetInches busLength = const FeetInches(feet: 20, inches: 0);
    FeetInches busWidth = const FeetInches(feet: 6, inches: 6);
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
    final config = BusConfig(
      numberPlate: _numberPlateCtrl.text.trim(),
      maker: effectiveMaker,
      specifications: _specsCtrl.text.trim(),
      leftSeats: _leftSeats,
      rightSeats: _rightSeats,
      rowCount: _rowCount,
      busLengthPx: busLength.toPixels,
      busWidthPx: busWidth.toPixels,
      frontPartitionPx: frontPx,
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
      hintStyle: const TextStyle(color: Color(0xFF445566), fontSize: 13),
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

  const BusConfig({
    this.numberPlate = '',
    this.maker = '',
    this.specifications = '',
    this.leftSeats = 2,
    this.rightSeats = 2,
    this.rowCount = 14,
    this.busLengthPx = 896.0,
    this.busWidthPx = 280.0,
    this.frontPartitionPx = 0.0,
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

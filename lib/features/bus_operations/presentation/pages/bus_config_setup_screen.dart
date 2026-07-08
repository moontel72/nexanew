// NEXATRACE — BUS CONFIGURATION SETUP SCREEN
// ==============================================
// Pre-canvas setup for Absolute Layout. Captures bus profile info
// (number plate, maker, specifications) and dynamic seat configuration
// (left seats, right seats, row count) before entering the canvas editor.
//
// 100% isolated from the legacy grid system.

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/features/bus_operations/presentation/pages/absolute_layout_designer_screen.dart';

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
  String? _selectedMaker;

  // ── Dynamic Grid ──
  int _leftSeats = 2;
  int _rightSeats = 2;
  int _rowCount = 14;

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
  }

  @override
  void dispose() {
    _numberPlateCtrl.dispose();
    _specsCtrl.dispose();
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
                // SECTION 2: DYNAMIC GRID CONFIGURATION
                // ═══════════════════════════════════════════
                _sectionHeader(Icons.grid_view, 'DYNAMIC GRID CONFIGURATION'),
                const SizedBox(height: 4),
                Text(
                  'Define how many seats per side and how many rows.',
                  style: TextStyle(
                    color: const Color(0x60FFFFFF),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 14),

                // Seat counts per side
                Row(
                  children: [
                    Expanded(
                      child: _stepperField(
                        label: 'Left Seats',
                        value: _leftSeats,
                        min: 1,
                        max: 4,
                        onChanged: (v) => setState(() => _leftSeats = v),
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
                        border: Border.all(color: const Color(0x20FFFFFF)),
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
                        min: 1,
                        max: 4,
                        onChanged: (v) => setState(() => _rightSeats = v),
                        icon: Icons.event_seat,
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Row count
                _stepperField(
                  label: 'Total Rows',
                  value: _rowCount,
                  min: 4,
                  max: 24,
                  onChanged: (v) => setState(() => _rowCount = v),
                  icon: Icons.table_rows,
                  color: const Color(0xFF16A34A),
                  wide: true,
                ),
                const SizedBox(height: 8),

                // Preview summary
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF122442),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0x20FFFFFF)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0x60FFFFFF),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${_leftSeats}L + ${_rightSeats}R abreast × $_rowCount rows'
                          ' = ${(_leftSeats + _rightSeats) * _rowCount} total seats',
                          style: const TextStyle(
                            color: Color(0xCCFFFFFF),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ═══════════════════════════════════════════
                // ACTION BUTTONS
                // ═══════════════════════════════════════════
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Cancel'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white54,
                          side: const BorderSide(color: Color(0x30FFFFFF)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
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
                        onPressed: _startDesigning,
                        icon: const Icon(Icons.design_services, size: 18),
                        label: const Text(
                          'Start Designing',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C3AED),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _startDesigning() {
    final config = BusConfig(
      numberPlate: _numberPlateCtrl.text.trim(),
      maker: _selectedMaker ?? '',
      specifications: _specsCtrl.text.trim(),
      leftSeats: _leftSeats,
      rightSeats: _rightSeats,
      rowCount: _rowCount,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => AbsoluteLayoutDesignerScreen(
          companyId: widget.companyId,
          companyName: widget.companyName,
          layoutId: widget.layoutId,
          config: config,
          apiPrefix: widget.apiPrefix,
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
}

/// Holds the bus configuration data collected before entering the canvas.
class BusConfig {
  final String numberPlate;
  final String maker;
  final String specifications;
  final int leftSeats;
  final int rightSeats;
  final int rowCount;

  const BusConfig({
    this.numberPlate = '',
    this.maker = '',
    this.specifications = '',
    this.leftSeats = 2,
    this.rightSeats = 2,
    this.rowCount = 14,
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

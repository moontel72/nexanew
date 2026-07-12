// Sub-Admin Preset Template Setup Screen
import 'package:flutter/material.dart';
import 'package:trace_odd/features/bus_operations/presentation/pages/absolute_layout_designer_screen.dart';
import 'package:trace_odd/features/bus_operations/presentation/pages/bus_config_setup_screen.dart';

class SubAdminPresetSetupScreen extends StatefulWidget {
  final String apiPrefix;
  const SubAdminPresetSetupScreen({super.key, this.apiPrefix = '/super-admin'});

  @override
  State<SubAdminPresetSetupScreen> createState() =>
      _SubAdminPresetSetupScreenState();
}

class _SubAdminPresetSetupScreenState extends State<SubAdminPresetSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  int _leftSeats = 2;
  int _rightSeats = 2;
  int _rowCount = 14;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _generateCanvas() {
    final name = _nameCtrl.text.trim().isEmpty
        ? 'Untitled Preset'
        : _nameCtrl.text.trim();
    final config = BusConfig(
      numberPlate: name,
      maker: '',
      specifications: '',
      leftSeats: _leftSeats,
      rightSeats: _rightSeats,
      rowCount: _rowCount,
    );
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => AbsoluteLayoutDesignerScreen(
          companyId: '',
          companyName: name,
          config: config,
          apiPrefix: widget.apiPrefix,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1628),
        title: const Text(
          'Create Preset Template',
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
                _sectionHeader(Icons.bookmark, 'TEMPLATE IDENTITY'),
                const SizedBox(height: 12),
                _fieldLabel('Preset / Template Name'),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _nameCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'e.g. 54-Seat Standard Coach',
                    hintStyle: TextStyle(
                      color: Color(0xFF445566),
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: Color(0xFF122442),
                    prefixIcon: Icon(
                      Icons.label,
                      color: Color(0x60FFFFFF),
                      size: 18,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                _sectionHeader(Icons.grid_view, 'BASELINE MATRIX'),
                const SizedBox(height: 4),
                const Text(
                  'Define the seat layout dimensions for this template.',
                  style: TextStyle(color: Color(0x60FFFFFF), fontSize: 11),
                ),
                const SizedBox(height: 14),
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
                          '${_leftSeats}L + ${_rightSeats}R x $_rowCount rows = ${(_leftSeats + _rightSeats) * _rowCount} seats',
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
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _generateCanvas,
                    icon: const Icon(Icons.dashboard_customize, size: 20),
                    label: const Text(
                      'Generate Template Canvas',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
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
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String text) => Row(
    children: [
      Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFF7C3AED).withAlpha(38),
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

  Widget _fieldLabel(String text) => Text(
    text,
    style: const TextStyle(
      color: Color(0x80FFFFFF),
      fontSize: 11,
      fontWeight: FontWeight.w600,
    ),
  );

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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0x20FFFFFF)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
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

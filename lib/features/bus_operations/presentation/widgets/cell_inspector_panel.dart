// NEXATRACE — CELL INSPECTOR PANEL
// ===================================
// Right-side panel or bottom sheet for editing a tapped component's properties.
//
// Editable fields: type, seat_id, bookable toggle, gender restriction,
// booking mode, span dimensions (for multi-cell objects).

import 'package:flutter/material.dart';
import 'package:trace_odd/shared/models/transport/layout_component.dart';

class CellInspectorPanel extends StatefulWidget {
  final LayoutComponent component;
  final void Function(LayoutComponent updated)? onApply;
  final VoidCallback? onDelete;
  final VoidCallback? onClose;

  const CellInspectorPanel({
    super.key,
    required this.component,
    this.onApply,
    this.onDelete,
    this.onClose,
  });

  @override
  State<CellInspectorPanel> createState() => _CellInspectorPanelState();
}

class _CellInspectorPanelState extends State<CellInspectorPanel> {
  late ComponentType _selectedType;
  late bool _bookable;
  late BookingMode _bookingMode;
  late String? _genderRestriction;
  late int _spanRows;
  late int _spanCols;
  late TextEditingController _seatIdController;

  @override
  void initState() {
    super.initState();
    final c = widget.component;
    _selectedType = c.type;
    _bookable = c.bookable;
    _bookingMode = c.bookingMode;
    _genderRestriction = c.genderRestriction;
    _spanRows = c.spanRows;
    _spanCols = c.spanCols;
    _seatIdController = TextEditingController(text: c.seatId ?? '');
  }

  @override
  void dispose() {
    _seatIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final comp = widget.component;
    final color = _colorForType(_selectedType);

    return Container(
      width: 300,
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
            offset: Offset(-4, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.tune, size: 20, color: color),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Inspector',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white70,
                    size: 18,
                  ),
                  onPressed: widget.onClose,
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
          const SizedBox(height: 8),

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _sectionLabel('ID'),
                Text(
                  comp.id,
                  style: const TextStyle(
                    color: Color(0xFFAABBCC),
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 12),

                _sectionLabel('TYPE'),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: ComponentType.values
                      .where(
                        (t) => t != ComponentType.aisle,
                      ) // aisle is auto-generated
                      .map((type) => _typeChip(type))
                      .toList(),
                ),
                const SizedBox(height: 12),

                _sectionLabel('SEAT LABEL'),
                TextField(
                  controller: _seatIdController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'e.g. A1',
                    hintStyle: const TextStyle(color: Color(0xFF556677)),
                    filled: true,
                    fillColor: const Color(0xFF112233),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Bookable toggle
                _sectionLabel('BOOKABLE'),
                SwitchListTile(
                  value: _bookable,
                  onChanged: (v) => setState(() {
                    _bookable = v;
                    if (!v) _bookingMode = BookingMode.none;
                  }),
                  activeColor: const Color(0xFF16A34A),
                  title: const Text(
                    'Bookable',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),

                if (_bookable) ...[
                  _sectionLabel('BOOKING MODE'),
                  ...BookingMode.values
                      .where((m) => m != BookingMode.none || !_bookable)
                      .map(
                        (mode) => RadioListTile<BookingMode>(
                          value: mode,
                          groupValue: _bookingMode,
                          onChanged: (v) =>
                              setState(() => _bookingMode = v ?? _bookingMode),
                          activeColor: color,
                          title: Text(
                            mode.name[0].toUpperCase() + mode.name.substring(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                ],

                _sectionLabel('GENDER RESTRICTION'),
                DropdownButtonFormField<String?>(
                  value: _genderRestriction,
                  dropdownColor: const Color(0xFF1A2A3A),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF112233),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('None')),
                    DropdownMenuItem(
                      value: 'male_only',
                      child: Text('Male Only'),
                    ),
                    DropdownMenuItem(
                      value: 'female_only',
                      child: Text('Female Only'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _genderRestriction = v),
                ),
                const SizedBox(height: 12),

                // Span dimensions (only for multi-cell types)
                if (comp.isMultiCell ||
                    _selectedType == ComponentType.sleeperLower ||
                    _selectedType == ComponentType.sleeperUpper ||
                    _selectedType == ComponentType.lavatory) ...[
                  _sectionLabel('SPAN DIMENSIONS'),
                  Row(
                    children: [
                      Expanded(
                        child: _numField(
                          label: 'Rows',
                          value: _spanRows,
                          min: 1,
                          max: 10,
                          onChanged: (v) => setState(() => _spanRows = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _numField(
                          label: 'Cols',
                          value: _spanCols,
                          min: 1,
                          max: 5,
                          onChanged: (v) => setState(() => _spanCols = v),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                if (widget.onDelete != null && comp.isEditable)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.onDelete,
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFEF4444),
                        side: const BorderSide(color: Color(0xFFEF4444)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                if (widget.onDelete != null) const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final updated = widget.component.copyWith(
                        type: _selectedType,
                        bookable: _bookable,
                        bookingMode: _bookingMode,
                        genderRestriction: _genderRestriction,
                        spanRows: _spanRows,
                        spanCols: _spanCols,
                        seatId: _seatIdController.text.isNotEmpty
                            ? _seatIdController.text
                            : null,
                      );
                      widget.onApply?.call(updated);
                    },
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Apply'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(top: 4, bottom: 4),
    child: Text(
      text,
      style: const TextStyle(
        color: Color(0xFF8899AA),
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    ),
  );

  Widget _typeChip(ComponentType type) {
    final selected = type == _selectedType;
    final color = _colorForType(type);
    return GestureDetector(
      onTap: () => setState(() {
        _selectedType = type;
        // Auto-set booking mode for structural types
        if (type == ComponentType.aisle ||
            type == ComponentType.exitDoor ||
            type == ComponentType.driverCabin ||
            type == ComponentType.emergency ||
            type == ComponentType.lavatory) {
          _bookable = false;
          _bookingMode = BookingMode.none;
        } else if (type == ComponentType.sleeperLower ||
            type == ComponentType.sleeperUpper) {
          _bookable = true;
          _bookingMode = BookingMode.berth;
        } else if (type == ComponentType.foldingSeat) {
          _bookable = true;
          _bookingMode = BookingMode.conditional;
        } else {
          _bookable = true;
          _bookingMode = BookingMode.standard;
        }
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: selected ? color : const Color(0xFF334455)),
        ),
        child: Text(
          type.name,
          style: TextStyle(
            color: selected ? color : const Color(0xFF8899AA),
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _numField({
    required String label,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(color: Color(0xFF8899AA), fontSize: 10),
      ),
      const SizedBox(height: 4),
      Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 16),
            color: const Color(0xFF8899AA),
            onPressed: value > min ? () => onChanged(value - 1) : null,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
          Container(
            width: 36,
            alignment: Alignment.center,
            child: Text(
              '$value',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 16),
            color: const Color(0xFF8899AA),
            onPressed: value < max ? () => onChanged(value + 1) : null,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    ],
  );

  static Color _colorForType(ComponentType type) => switch (type) {
    ComponentType.seat => const Color(0xFF7C3AED),
    ComponentType.sleeperLower => const Color(0xFFDB2777),
    ComponentType.sleeperUpper => const Color(0xFFF97316),
    ComponentType.foldingSeat => const Color(0xFF06B6D4),
    ComponentType.aisle => const Color(0xFF334155),
    ComponentType.exitDoor => const Color(0xFFEF4444),
    ComponentType.driverCabin => const Color(0xFF1E293B),
    ComponentType.emergency => const Color(0xFFDC2626),
    ComponentType.lavatory => const Color(0xFF6366F1),
    ComponentType.empty => const Color(0xFF556677),
  };
}

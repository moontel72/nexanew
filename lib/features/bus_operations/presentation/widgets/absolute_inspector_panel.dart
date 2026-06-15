// NEXATRACE — ABSOLUTE INSPECTOR PANEL
// ======================================
// Floating inspector panel at top-right of canvas.
// Cloned from the functional CellInspectorPanel (Grid layout) and
// adapted for AbsoluteLayoutComponent with position/size, seat label,
// custom label, bookable toggle, booking mode, gender restriction,
// facing direction, and green Apply + red Delete buttons.
//
// 100% isolated from the legacy CellInspectorPanel.

import 'package:flutter/material.dart';
import 'package:trace_odd/shared/models/transport/absolute_layout_component.dart';
import 'package:trace_odd/shared/models/transport/absolute_layout_state.dart';
import 'package:trace_odd/shared/models/transport/layout_component.dart';

class AbsoluteInspectorPanel extends StatefulWidget {
  final AbsoluteLayoutComponent component;
  final void Function(AbsoluteLayoutComponent updated) onApply;
  final VoidCallback onDelete;
  final VoidCallback onClose;

  const AbsoluteInspectorPanel({
    super.key,
    required this.component,
    required this.onApply,
    required this.onDelete,
    required this.onClose,
  });

  @override
  State<AbsoluteInspectorPanel> createState() => _AbsoluteInspectorPanelState();
}

class _AbsoluteInspectorPanelState extends State<AbsoluteInspectorPanel> {
  // ── Position & Size ──
  late TextEditingController _xCtrl;
  late TextEditingController _yCtrl;
  late TextEditingController _wCtrl;
  late TextEditingController _hCtrl;
  late TextEditingController _rotCtrl;

  // ── Seat identity ──
  late TextEditingController _seatIdController;
  late TextEditingController _customLabelController;

  // ── Seat properties ──
  late ComponentType _selectedType;
  late bool _bookable;
  late BookingMode _bookingMode;
  late String? _genderRestriction;
  bool _isReversing = false;

  @override
  void initState() {
    super.initState();
    final c = widget.component;
    _xCtrl = TextEditingController(text: c.x.toStringAsFixed(0));
    _yCtrl = TextEditingController(text: c.y.toStringAsFixed(0));
    _wCtrl = TextEditingController(text: c.width.toStringAsFixed(0));
    _hCtrl = TextEditingController(text: c.height.toStringAsFixed(0));
    _rotCtrl = TextEditingController(text: c.rotation.toStringAsFixed(0));
    _seatIdController = TextEditingController(text: c.seatId ?? '');
    _customLabelController = TextEditingController(text: c.customLabel ?? '');
    _selectedType = c.type;
    _bookable = c.bookable;
    _bookingMode = c.bookingMode;
    _genderRestriction = c.genderRestriction;
    _isReversing = c.isReverseFacing;
  }

  @override
  void dispose() {
    _xCtrl.dispose();
    _yCtrl.dispose();
    _wCtrl.dispose();
    _hCtrl.dispose();
    _rotCtrl.dispose();
    _seatIdController.dispose();
    _customLabelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.component;
    final color = _colorForType(_selectedType);
    final maxPanelH = MediaQuery.of(context).size.height * 0.85;

    return Container(
      width: 280,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A2A3A), Color(0xFF0D1B2A)],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x30FFFFFF), width: 0.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxPanelH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ═══ HEADER ═══
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 4, 0),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(c.defaultIcon, size: 18, color: color),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      c.typeLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white54,
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
            const SizedBox(height: 4),

            // ═══ SCROLLABLE CONTENT ═══
            Flexible(
              child: Scrollbar(
                thumbVisibility: true,
                thickness: 5,
                radius: const Radius.circular(3),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shrinkWrap: true,
                  children: [
                    // ── ID ──
                    _sectionLabel('ID'),
                    Text(
                      c.id,
                      style: const TextStyle(
                        color: Color(0xFFAABBCC),
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ── TYPE ──
                    _sectionLabel('TYPE'),
                    Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: ComponentType.values
                          .where(
                            (t) =>
                                t != ComponentType.aisle &&
                                t != ComponentType.empty,
                          )
                          .map((type) => _typeChip(type))
                          .toList(),
                    ),
                    const SizedBox(height: 10),

                    // ── POSITION & SIZE ──
                    _sectionLabel('POSITION & SIZE'),
                    Row(
                      children: [
                        Expanded(child: _numTextField('X', _xCtrl)),
                        const SizedBox(width: 6),
                        Expanded(child: _numTextField('Y', _yCtrl)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(child: _numTextField('W', _wCtrl)),
                        const SizedBox(width: 6),
                        Expanded(child: _numTextField('H', _hCtrl)),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Text(
                        '≈ ${pxToFtIn(c.width)} × ${pxToFtIn(c.height)}',
                        style: const TextStyle(
                          color: Color(0x50FFFFFF),
                          fontSize: 8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // ── ROTATION ──
                    _sectionLabel('ROTATION'),
                    Row(
                      children: [
                        SizedBox(
                          width: 56,
                          child: _numTextField('Deg', _rotCtrl),
                        ),
                        const SizedBox(width: 6),
                        _rotChip('0', 0),
                        _rotChip('45', 45),
                        _rotChip('90', 90),
                        _rotChip('180', 180),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // ── FACING DIRECTION (seat types only) ──
                    if (c.type == ComponentType.seat ||
                        c.type == ComponentType.businessClassSeat) ...[
                      _sectionLabel('FACING DIRECTION'),
                      Row(
                        children: [
                          const Icon(
                            Icons.arrow_upward,
                            color: Color(0xFF7C3AED),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Forward',
                            style: TextStyle(
                              color: Color(0xCCFFFFFF),
                              fontSize: 10,
                            ),
                          ),
                          const Spacer(),
                          Switch(
                            value: _isReversing,
                            activeColor: const Color(0xFF3B82F6),
                            onChanged: (v) => setState(() => _isReversing = v),
                          ),
                          const Spacer(),
                          const Text(
                            'Reverse',
                            style: TextStyle(
                              color: Color(0xCCFFFFFF),
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_downward,
                            color: Color(0xFF3B82F6),
                            size: 16,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],

                    // ── SEAT LABEL ──
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
                    const SizedBox(height: 10),

                    // ── OVERRIDE STICKER NUMBER / CUSTOM LABEL ──
                    _sectionLabel('OVERRIDE STICKER NUMBER / CUSTOM LABEL'),
                    TextField(
                      controller: _customLabelController,
                      style: const TextStyle(
                        color: Color(0xFFFBBF24),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Owner-set label (e.g. 9-B, VIP)',
                        hintStyle: const TextStyle(color: Color(0xFF556677)),
                        filled: true,
                        fillColor: const Color(0xFF112233),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFD97706),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _customLabelController.text.isNotEmpty
                                ? const Color(0xFFD97706)
                                : const Color(0xFF334455),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        prefixIcon: const Icon(
                          Icons.label_important,
                          color: Color(0xFFD97706),
                          size: 16,
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Freezes automatic numbering for this seat. Mirrors to the booking panel.',
                      style: TextStyle(
                        color: const Color(0xFFD97706).withValues(alpha: 0.6),
                        fontSize: 9,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ── BOOKABLE ──
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
                              onChanged: (v) => setState(
                                () => _bookingMode = v ?? _bookingMode,
                              ),
                              activeColor: color,
                              title: Text(
                                mode.name[0].toUpperCase() +
                                    mode.name.substring(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            ),
                          ),
                      const SizedBox(height: 4),
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
                  ],
                ),
              ),
            ),

            // ═══ ACTION BUTTONS ═══
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  if (c.isEditable)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          widget.onDelete();
                          widget.onClose();
                        },
                        icon: const Icon(Icons.delete, size: 16),
                        label: const Text('Delete'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEF4444),
                          side: const BorderSide(color: Color(0xFFEF4444)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  if (c.isEditable) const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _apply,
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
      ),
    );
  }

  void _apply() {
    final c = widget.component;
    final updated = AbsoluteLayoutComponent(
      id: c.id,
      type: _selectedType,
      x: double.tryParse(_xCtrl.text) ?? c.x,
      y: double.tryParse(_yCtrl.text) ?? c.y,
      width: (double.tryParse(_wCtrl.text) ?? c.width).clamp(24, 1000),
      height: (double.tryParse(_hCtrl.text) ?? c.height).clamp(24, 1000),
      rotation: (double.tryParse(_rotCtrl.text) ?? c.rotation) % 360,
      seatId: _seatIdController.text.trim().isEmpty
          ? null
          : _seatIdController.text.trim(),
      seatNumber: c.seatNumber,
      berthLabel: c.berthLabel,
      isReverseFacing: _isReversing,
      bookable: _bookable,
      bookingMode: _bookingMode,
      genderRestriction: _genderRestriction,
      customLabel: _customLabelController.text.trim().isEmpty
          ? null
          : _customLabelController.text.trim(),
      meta: c.meta,
    );
    widget.onApply(updated);
  }

  // ═══════════════════════════════════════════════
  // HELPER WIDGETS
  // ═══════════════════════════════════════════════

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(top: 2, bottom: 4),
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

  Widget _numTextField(String label, TextEditingController ctrl) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        label,
        style: const TextStyle(color: Color(0x60FFFFFF), fontSize: 9),
      ),
      const SizedBox(height: 2),
      TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white, fontSize: 12),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFF112233),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 6,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    ],
  );

  Widget _rotChip(String label, double value) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: InkWell(
        onTap: () => _rotCtrl.text = value.toStringAsFixed(0),
        borderRadius: BorderRadius.circular(3),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0x30FFFFFF)),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            label,
            style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 9),
          ),
        ),
      ),
    );
  }

  Widget _typeChip(ComponentType type) {
    final selected = type == _selectedType;
    final color = _colorForType(type);
    return GestureDetector(
      onTap: () => setState(() {
        _selectedType = type;
        // Auto-set booking mode for structural types
        if (type == ComponentType.exitDoor ||
            type == ComponentType.driverCabin ||
            type == ComponentType.emergency ||
            type == ComponentType.lavatory ||
            type == ComponentType.restaurantTable) {
          _bookable = false;
          _bookingMode = BookingMode.none;
        } else if (type == ComponentType.sleeperLower ||
            type == ComponentType.sleeperUpper) {
          _bookable = true;
          _bookingMode = BookingMode.berth;
        } else if (type == ComponentType.foldingSeat) {
          _bookable = true;
          _bookingMode = BookingMode.conditional;
        } else if (type == ComponentType.businessClassSeat) {
          _bookable = true;
          _bookingMode = BookingMode.premium;
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

  static Color _colorForType(ComponentType type) => switch (type) {
    ComponentType.seat => const Color(0xFF7C3AED),
    ComponentType.sleeperLower => const Color(0xFFDB2777),
    ComponentType.sleeperUpper => const Color(0xFFF97316),
    ComponentType.foldingSeat => const Color(0xFF06B6D4),
    ComponentType.exitDoor => const Color(0xFFEF4444),
    ComponentType.driverCabin => const Color(0xFF1E293B),
    ComponentType.emergency => const Color(0xFFDC2626),
    ComponentType.lavatory => const Color(0xFF6366F1),
    ComponentType.restaurantTable => const Color(0xFF059669),
    ComponentType.businessClassSeat => const Color(0xFFD97706),
    ComponentType.empty || ComponentType.aisle => const Color(0xFF556677),
  };
}

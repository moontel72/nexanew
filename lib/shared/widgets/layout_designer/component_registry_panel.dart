// NEXATRACE — COMPONENT REGISTRY PANEL
// ======================================
// Centralised hub where users declare which parts are allowed
// on the designer palette.  Shows active configurations as
// deletable chips and a dropdown for adding new part types.

import 'package:flutter/material.dart';
import 'package:trace_odd/shared/models/transport/component_registry.dart';
import 'package:trace_odd/shared/models/transport/feet_inches.dart';

class ComponentRegistryPanel extends StatefulWidget {
  final ComponentRegistry registry;
  final ValueChanged<ComponentRegistry> onChanged;

  const ComponentRegistryPanel({
    super.key,
    required this.registry,
    required this.onChanged,
  });

  @override
  State<ComponentRegistryPanel> createState() => _ComponentRegistryPanelState();
}

class _ComponentRegistryPanelState extends State<ComponentRegistryPanel> {
  SeatPartType? _addingType;
  bool _tableApplied = false;
  DriverPosition _driverPosition = DriverPosition.right;
  late final TextEditingController _lenFtCtrl;
  late final TextEditingController _lenInCtrl;
  late final TextEditingController _widFtCtrl;
  late final TextEditingController _widInCtrl;
  late final TextEditingController _leftTableFtCtrl;
  late final TextEditingController _leftTableInCtrl;
  late final TextEditingController _rightTableFtCtrl;
  late final TextEditingController _rightTableInCtrl;
  late final TextEditingController _leftTableLenFtCtrl;
  late final TextEditingController _leftTableLenInCtrl;
  late final TextEditingController _rightTableLenFtCtrl;
  late final TextEditingController _rightTableLenInCtrl;

  @override
  void initState() {
    super.initState();
    _lenFtCtrl = TextEditingController();
    _lenInCtrl = TextEditingController();
    _widFtCtrl = TextEditingController();
    _widInCtrl = TextEditingController();
    _leftTableFtCtrl = TextEditingController();
    _leftTableInCtrl = TextEditingController();
    _rightTableFtCtrl = TextEditingController();
    _rightTableInCtrl = TextEditingController();
    _leftTableLenFtCtrl = TextEditingController();
    _leftTableLenInCtrl = TextEditingController();
    _rightTableLenFtCtrl = TextEditingController();
    _rightTableLenInCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _lenFtCtrl.dispose();
    _lenInCtrl.dispose();
    _widFtCtrl.dispose();
    _widInCtrl.dispose();
    _leftTableFtCtrl.dispose();
    _leftTableInCtrl.dispose();
    _rightTableFtCtrl.dispose();
    _rightTableInCtrl.dispose();
    _leftTableLenFtCtrl.dispose();
    _leftTableLenInCtrl.dispose();
    _rightTableLenFtCtrl.dispose();
    _rightTableLenInCtrl.dispose();
    super.dispose();
  }

  /// Parts not yet in the registry.
  List<SeatPartType> get _available => SeatPartType.values
      .where((t) => !widget.registry.parts.containsKey(t))
      .toList();

  bool get _isEditing =>
      _addingType != null && widget.registry.parts.containsKey(_addingType);

  void _addPart(SeatPartType type) {
    if (type == SeatPartType.table) {
      final def = PartSpec.defaultFor(type);
      final newParts = Map<SeatPartType, PartSpec>.from(widget.registry.parts)..[type] = def;
      widget.onChanged(widget.registry.copyWith(parts: newParts));
      _leftTableFtCtrl.text = '0'; _leftTableInCtrl.text = '0';
      _leftTableLenFtCtrl.text = '0'; _leftTableLenInCtrl.text = '0';
      _rightTableFtCtrl.text = '0'; _rightTableInCtrl.text = '0';
      _rightTableLenFtCtrl.text = '0'; _rightTableLenInCtrl.text = '0';
      return;
    }
    final def = PartSpec.defaultFor(type);
    _lenFtCtrl.text = def.length.feet.toString();
    _lenInCtrl.text = def.length.inches.toString();
    _widFtCtrl.text = def.width.feet.toString();
    _widInCtrl.text = def.width.inches.toString();
    _driverPosition = def.driverPosition;
    setState(() => _addingType = type);
  }

  void _editPart(SeatPartType type) {
    final existing = widget.registry.parts[type];
    if (existing == null) return;
    _lenFtCtrl.text = existing.length.feet.toString();
    _lenInCtrl.text = existing.length.inches.toString();
    _widFtCtrl.text = existing.width.feet.toString();
    _widInCtrl.text = existing.width.inches.toString();
    _driverPosition = existing.driverPosition;
    setState(() => _addingType = type);
  }

  void _confirmAdd() {
    if (_addingType == null) return;
    final int ft = int.tryParse(_lenFtCtrl.text) ?? 0;
    final int inc = int.tryParse(_lenInCtrl.text) ?? 0;

    // Auto-normalize and push corrected values back to UI text fields
    // so the displayed numbers always match the stored state.
    final length = FeetInches.normalize(ft, inc);
    _lenFtCtrl.text = length.feet.toString();
    _lenInCtrl.text = length.inches.toString();

    final int wFt = int.tryParse(_widFtCtrl.text) ?? 0;
    final int wInc = int.tryParse(_widInCtrl.text) ?? 0;
    final width = FeetInches.normalize(wFt, wInc);
    _widFtCtrl.text = width.feet.toString();
    _widInCtrl.text = width.inches.toString();

    final spec = PartSpec(
      type: _addingType!,
      length: length,
      width: width,
      driverPosition: _driverPosition,
    );
    final newParts = Map<SeatPartType, PartSpec>.from(widget.registry.parts)
      ..[_addingType!] = spec;
    widget.onChanged(widget.registry.copyWith(parts: newParts));
    setState(() => _addingType = null);
  }

  void _removePart(SeatPartType type) {
    final newParts = Map<SeatPartType, PartSpec>.from(widget.registry.parts)
      ..remove(type);
    widget.onChanged(widget.registry.copyWith(parts: newParts));
  }

  // Label above a dimension input group — gold text with purple accent bar.
  Widget _dimLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Row(
      children: [
        Container(
          width: 3,
          height: 12,
          decoration: BoxDecoration(
            color: const Color(0xFF7C3AED),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFFFFD700),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );

  // Feet + inches row for one dimension.
  Widget _dimRow(
    TextEditingController ftCtrl,
    TextEditingController inCtrl,
    String ftHint,
    String inHint,
  ) => Row(
    children: [
      Expanded(child: _smallField(ftHint, ftCtrl)),
      const SizedBox(width: 6),
      Expanded(child: _smallField(inHint, inCtrl)),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF122442),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x20FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'COMPONENT REGISTRY',
            style: TextStyle(
              color: Color(0xCCFFFFFF),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          // ── Active chips with dimensions (tap to edit) ──
          if (widget.registry.parts.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: widget.registry.parts.entries.map((e) {
                final spec = e.value;
                final dimLabel =
                    '${spec.length.displayString} × ${spec.width.displayString}';
                return GestureDetector(
                  onTap: () => _editPart(e.key),
                  child: Chip(
                    avatar: const Icon(
                      Icons.straighten,
                      size: 13,
                      color: Color(0xFF7C3AED),
                    ),
                    label: Text(
                      '${e.key.name}  $dimLabel',
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                    deleteIcon: const Icon(
                      Icons.close,
                      size: 14,
                      color: Colors.white54,
                    ),
                    onDeleted: () => _removePart(e.key),
                    backgroundColor: const Color(0xFF1A2A3A),
                    side: BorderSide.none,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
          ],
          // ── Add dropdown ──
          // -- Table dimension overrides (per side) --
          if (widget.registry.parts.containsKey(SeatPartType.table) && _addingType != SeatPartType.table) ...[
            const SizedBox(height: 4),
            const Text(
              'TABLE DIMENSIONS (per side)',
              style: TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            _dimLabel('Left Table W (span across seats, 0=auto)'),
            _dimRow(_leftTableFtCtrl, _leftTableInCtrl, 'ft', 'in'),
            const SizedBox(height: 4),
            _dimLabel('Left Table L (depth between rows, 0=auto)'),
            _dimRow(_leftTableLenFtCtrl, _leftTableLenInCtrl, 'ft', 'in'),
            const SizedBox(height: 8),
            _dimLabel('Right Table W (span across seats, 0=auto)'),
            _dimRow(_rightTableFtCtrl, _rightTableInCtrl, 'ft', 'in'),
            const SizedBox(height: 4),
            _dimLabel('Right Table L (depth between rows, 0=auto)'),
            _dimRow(_rightTableLenFtCtrl, _rightTableLenInCtrl, 'ft', 'in'),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              height: 38,
              child: ElevatedButton(
                onPressed: () {
                  final lwFt = int.tryParse(_leftTableFtCtrl.text) ?? 0;
                  final lwIn = int.tryParse(_leftTableInCtrl.text) ?? 0;
                  final llFt = int.tryParse(_leftTableLenFtCtrl.text) ?? 0;
                  final llIn = int.tryParse(_leftTableLenInCtrl.text) ?? 0;
                  final rwFt = int.tryParse(_rightTableFtCtrl.text) ?? 0;
                  final rwIn = int.tryParse(_rightTableInCtrl.text) ?? 0;
                  final rlFt = int.tryParse(_rightTableLenFtCtrl.text) ?? 0;
                  final rlIn = int.tryParse(_rightTableLenInCtrl.text) ?? 0;
                  final lw = FeetInches.normalize(lwFt, lwIn);
                  final ll = FeetInches.normalize(llFt, llIn);
                  final rw = FeetInches.normalize(rwFt, rwIn);
                  final rl = FeetInches.normalize(rlFt, rlIn);
                  widget.onChanged(widget.registry.copyWith(
                      leftTableWidth: lw.isZero ? null : lw,
                      leftTableLength: ll.isZero ? null : ll,
                      rightTableWidth: rw.isZero ? null : rw,
                      rightTableLength: rl.isZero ? null : rl));
                  setState(() => _tableApplied = true);
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) setState(() => _tableApplied = false);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: Text(_tableApplied ? 'SAVED!' : 'ADD / SAVE',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (_available.isNotEmpty)
            DropdownButtonFormField<SeatPartType>(
              value: null,
              hint: const Text(
                'Add part type…',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              dropdownColor: const Color(0xFF122442),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                filled: true,
                fillColor: Color(0xFF1A2A3A),
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
              items: _available
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                  .toList(),
              onChanged: (v) {
                if (v != null) _addPart(v);
              },
            ),
          // ── Add-form with explicit labels ──
          if (_addingType != null) ...[
            const SizedBox(height: 10),
            Text(
              'Configuring: ${_addingType!.name}',
              style: const TextStyle(color: Color(0xFF7C3AED), fontSize: 11),
            ),
            const SizedBox(height: 8),
            // Width row with label
            _dimLabel('Width (Left \u2192 Right)'),
            _dimRow(_widFtCtrl, _widInCtrl, 'ft', 'in'),
            const SizedBox(height: 10),
            // Length row with label
            _dimLabel('Length (Front → Back)'),
            _dimRow(_lenFtCtrl, _lenInCtrl, 'ft', 'in'),
            // Driver position selector (only for driverSeat)
            if (_addingType == SeatPartType.driverSeat) ...[
              const SizedBox(height: 10),
              _dimLabel('Driving Position'),
              const SizedBox(height: 4),
              DropdownButtonFormField<DriverPosition>(
                value: _driverPosition,
                dropdownColor: const Color(0xFF122442),
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  filled: true,
                  fillColor: Color(0xFF1A2A3A),
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                ),
                items: DriverPosition.values.map((p) {
                  final label = switch (p) {
                    DriverPosition.left => 'Left side (window / door)',
                    DriverPosition.center => 'Center',
                    DriverPosition.right => 'Right side (window / door)',
                  };
                  return DropdownMenuItem(value: p, child: Text(label));
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _driverPosition = v);
                },
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: ElevatedButton(
                      onPressed: _confirmAdd,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: Text(_isEditing ? 'UPDATE' : 'ADD',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _smallField(String hint, TextEditingController ctrl) => TextField(
    controller: ctrl,
    keyboardType: TextInputType.number,
    style: const TextStyle(color: Colors.white, fontSize: 12),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF445566), fontSize: 11),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      filled: true,
      fillColor: const Color(0xFF1A2A3A),
      border: const OutlineInputBorder(borderSide: BorderSide.none),
    ),
  );
}

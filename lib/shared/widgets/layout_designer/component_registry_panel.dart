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
  late final TextEditingController _lenFtCtrl;
  late final TextEditingController _lenInCtrl;
  late final TextEditingController _widFtCtrl;
  late final TextEditingController _widInCtrl;

  @override
  void initState() {
    super.initState();
    _lenFtCtrl = TextEditingController();
    _lenInCtrl = TextEditingController();
    _widFtCtrl = TextEditingController();
    _widInCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _lenFtCtrl.dispose();
    _lenInCtrl.dispose();
    _widFtCtrl.dispose();
    _widInCtrl.dispose();
    super.dispose();
  }

  /// Parts not yet in the registry.
  List<SeatPartType> get _available => SeatPartType.values
      .where((t) => !widget.registry.parts.containsKey(t))
      .toList();

  void _addPart(SeatPartType type) {
    final spec = PartSpec.defaultFor(type);
    _lenFtCtrl.text = spec.length.feet.toString();
    _lenInCtrl.text = spec.length.inches.toString();
    _widFtCtrl.text = spec.width.feet.toString();
    _widInCtrl.text = spec.width.inches.toString();
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

    final spec = PartSpec(type: _addingType!, length: length, width: width);
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

  // Small label above a dimension group.
  Widget _dimLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(
      text,
      style: const TextStyle(
        color: Color(0x99FFFFFF),
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  // Feet + inches row for one dimension.
  Widget _dimRow(
    TextEditingController ftCtrl,
    TextEditingController inCtrl,
    String ftHint,
    String inHint,
  ) =>
      Row(
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
          // ── Active chips ──
          if (widget.registry.parts.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: widget.registry.parts.entries.map((e) {
                return Chip(
                  label: Text(
                    e.key.name,
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
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
          ],
          // ── Add dropdown ──
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
            _dimLabel('Length (Front \u2192 Back)'),
            _dimRow(_lenFtCtrl, _lenInCtrl, 'ft', 'in'),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton(
                  onPressed: () => setState(() => _addingType = null),
                  child: const Text('Cancel'),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _confirmAdd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                  ),
                  child: const Text('Add'),
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

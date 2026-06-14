// NEXATRACE — ABSOLUTE INSPECTOR PANEL
// ======================================
// Floating inspector panel at top-right of canvas.
// Entire panel is scrollable with a visible scrollbar so the Apply
// button is always reachable even on small laptop screens.
//
// 100% isolated from the legacy CellInspectorPanel.

import 'package:flutter/material.dart';
import 'package:trace_odd/shared/models/transport/absolute_layout_component.dart';
import 'package:trace_odd/shared/models/transport/absolute_layout_state.dart';

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
  late TextEditingController _xCtrl;
  late TextEditingController _yCtrl;
  late TextEditingController _wCtrl;
  late TextEditingController _hCtrl;
  late TextEditingController _rotCtrl;
  late TextEditingController _labelCtrl;

  @override
  void initState() {
    super.initState();
    final c = widget.component;
    _xCtrl = TextEditingController(text: c.x.toStringAsFixed(0));
    _yCtrl = TextEditingController(text: c.y.toStringAsFixed(0));
    _wCtrl = TextEditingController(text: c.width.toStringAsFixed(0));
    _hCtrl = TextEditingController(text: c.height.toStringAsFixed(0));
    _rotCtrl = TextEditingController(text: c.rotation.toStringAsFixed(0));
    _labelCtrl = TextEditingController(text: c.customLabel ?? '');
  }

  @override
  void dispose() {
    _xCtrl.dispose();
    _yCtrl.dispose();
    _wCtrl.dispose();
    _hCtrl.dispose();
    _rotCtrl.dispose();
    _labelCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.component;
    final ftLabel =
        '≈ ${pxToFtIn(c.width)} × ${pxToFtIn(c.height)}'
        '  (1 in = ${kPixelsPerInch.toInt()} px)';

    // Cap panel height so it never overflows the screen.
    // 85% leaves room for the top bar, status bar, and taskbar.
    final maxPanelH = MediaQuery.of(context).size.height * 0.85;

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: const Color(0xEE0A1628),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x30FFFFFF), width: 0.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxPanelH),
        child: Scrollbar(
          thumbVisibility: true,
          thickness: 6,
          radius: const Radius.circular(3),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ═══ HEADER ═══
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 4, 0),
                  child: Row(
                    children: [
                      Icon(c.defaultIcon, color: c.defaultColor, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        c.typeLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white38,
                          size: 16,
                        ),
                        onPressed: widget.onClose,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),

                // ═══ POSITION & SIZE 2x2 grid ═══
                _chip('POSITION & SIZE'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _field('X (px)', _xCtrl)),
                      const SizedBox(width: 8),
                      Expanded(child: _field('Y (px)', _yCtrl)),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _field('Width (px)', _wCtrl)),
                      const SizedBox(width: 8),
                      Expanded(child: _field('Height (px)', _hCtrl)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 1),
                  child: Text(
                    ftLabel,
                    style: const TextStyle(
                      color: Color(0x50FFFFFF),
                      fontSize: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // ═══ ROTATION ═══
                _chip('ROTATION'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      SizedBox(width: 56, child: _field('Deg', _rotCtrl)),
                      const SizedBox(width: 6),
                      _rotChip('0', 0),
                      _rotChip('45', 45),
                      _rotChip('90', 90),
                      _rotChip('180', 180),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // ═══ CUSTOM LABEL (all seat types) ═══
                if (c.isEditable) ...[
                  _chip('CUSTOM LABEL'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: TextField(
                      controller: _labelCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      decoration: InputDecoration(
                        hintText: 'e.g. VIP-1, A1',
                        hintStyle: const TextStyle(color: Color(0x40FFFFFF)),
                        filled: true,
                        fillColor: const Color(0xFF122442),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                            color: Color(0x20FFFFFF),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                            color: Color(0x20FFFFFF),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: c.defaultColor),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],

                // ═══ APPLY + DELETE BUTTONS ═══
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0x20FFFFFF), width: 0.5),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 36,
                          child: ElevatedButton.icon(
                            onPressed: _apply,
                            icon: const Icon(Icons.check, size: 14),
                            label: const Text(
                              'Apply',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7C3AED),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (c.isEditable) ...[
                        const SizedBox(width: 6),
                        SizedBox(
                          height: 36,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              widget.onDelete();
                              widget.onClose();
                            },
                            icon: const Icon(Icons.delete_outline, size: 14),
                            label: const Text(
                              'Delete',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDC2626),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 2),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0x50FFFFFF),
          fontSize: 8,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0x40FFFFFF), fontSize: 9),
        ),
        const SizedBox(height: 1),
        TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white, fontSize: 12),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF122442),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 4,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0x20FFFFFF)),
            ),
            enabledBorder: OutlineInputBorder(
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

  void _apply() {
    final c = widget.component;
    final updated = AbsoluteLayoutComponent(
      id: c.id,
      type: c.type,
      x: double.tryParse(_xCtrl.text) ?? c.x,
      y: double.tryParse(_yCtrl.text) ?? c.y,
      width: (double.tryParse(_wCtrl.text) ?? c.width).clamp(24, 1000),
      height: (double.tryParse(_hCtrl.text) ?? c.height).clamp(24, 1000),
      rotation: (double.tryParse(_rotCtrl.text) ?? c.rotation) % 360,
      seatId: c.seatId,
      seatNumber: c.seatNumber,
      berthLabel: c.berthLabel,
      bookable: c.bookable,
      bookingMode: c.bookingMode,
      genderRestriction: c.genderRestriction,
      customLabel: _labelCtrl.text.trim().isEmpty
          ? null
          : _labelCtrl.text.trim(),
      meta: c.meta,
    );
    widget.onApply(updated);
  }
}

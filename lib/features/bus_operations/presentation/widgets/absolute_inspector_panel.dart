// NEXATRACE — ABSOLUTE INSPECTOR PANEL
// ======================================
// Compact property inspector for the Absolute Bus Layout Engine.
// Uses a sticky footer so the Apply button is ALWAYS visible.
// No scrollbars needed — the DraggableScrollableSheet handles resizing.
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
  final ScrollController? scrollController;

  const AbsoluteInspectorPanel({
    super.key,
    required this.component,
    required this.onApply,
    required this.onDelete,
    required this.onClose,
    this.scrollController,
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
    final ftInLabel =
        '≈ ${pxToFtIn(c.width)} × ${pxToFtIn(c.height)}'
        '  (1 in = ${kPixelsPerInch.toInt()} px)';

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A1628),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(
          top: BorderSide(color: Color(0x30FFFFFF)),
          left: BorderSide(color: Color(0x20FFFFFF)),
          right: BorderSide(color: Color(0x20FFFFFF)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ═══ SCROLLABLE CONTENT ═══
          Flexible(
            child: ListView(
              controller: widget.scrollController,
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: [
                // ── Header bar ──
                _header(c),
                const SizedBox(height: 6),

                // ── Position + Size side-by-side ──
                _sectionChip('POSITION & SIZE'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left column: X / Y
                      Expanded(
                        child: Column(
                          children: [
                            _tinyField('X (px)', _xCtrl),
                            const SizedBox(height: 6),
                            _tinyField('Y (px)', _yCtrl),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Right column: W / H
                      Expanded(
                        child: Column(
                          children: [
                            _tinyField('Width (px)', _wCtrl),
                            const SizedBox(height: 6),
                            _tinyField('Height (px)', _hCtrl),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 2),
                  child: Text(
                    ftInLabel,
                    style: const TextStyle(
                      color: Color(0x50FFFFFF),
                      fontSize: 9,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // ── Rotation ──
                _sectionChip('ROTATION'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      SizedBox(width: 70, child: _tinyField('Deg', _rotCtrl)),
                      const SizedBox(width: 6),
                      _rotateChip('0°', 0),
                      _rotateChip('45°', 45),
                      _rotateChip('90°', 90),
                      _rotateChip('180°', 180),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // ── Custom Label (editable only) ──
                if (c.isEditable) ...[
                  _sectionChip('CUSTOM LABEL'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: _labelCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'e.g. VIP-1, A1, Driver Seat',
                        hintStyle: const TextStyle(color: Color(0x40FFFFFF)),
                        filled: true,
                        fillColor: const Color(0xFF122442),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(
                            color: Color(0x20FFFFFF),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(
                            color: Color(0x20FFFFFF),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: c.defaultColor),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],

                // Bottom spacer so content doesn't crash into footer
                const SizedBox(height: 8),
              ],
            ),
          ),

          // ═══ STICKY FOOTER — ALWAYS VISIBLE ═══
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0A1628),
              border: Border(
                top: BorderSide(color: Color(0x20FFFFFF), width: 0.5),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton.icon(
                        onPressed: _apply,
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text(
                          'Apply',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C3AED),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (c.isEditable) ...[
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          widget.onDelete();
                          widget.onClose();
                        },
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: const Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ───

  Widget _header(AbsoluteLayoutComponent c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 0),
      child: Row(
        children: [
          Icon(c.defaultIcon, color: c.defaultColor, size: 18),
          const SizedBox(width: 6),
          Text(
            c.typeLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white38, size: 18),
            onPressed: widget.onClose,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
        ],
      ),
    );
  }

  Widget _sectionChip(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 2, 12, 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0x60FFFFFF),
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _tinyField(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0x50FFFFFF), fontSize: 10),
        ),
        const SizedBox(height: 2),
        TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF122442),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: Color(0x20FFFFFF)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: Color(0x20FFFFFF)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: Color(0xFF7C3AED)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _rotateChip(String label, double value) {
    return Padding(
      padding: const EdgeInsets.only(left: 3),
      child: InkWell(
        onTap: () => _rotCtrl.text = value.toStringAsFixed(0),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0x30FFFFFF)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 10),
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

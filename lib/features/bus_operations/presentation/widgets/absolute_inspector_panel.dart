// NEXATRACE — ABSOLUTE INSPECTOR PANEL
// ======================================
// Property inspector bottom sheet for the Absolute Bus Layout Engine.
// Appears when a component is selected on the canvas. Shows editable
// fields for position, size, rotation, custom label, and type metadata.
//
// 100% isolated from the legacy CellInspectorPanel.

import 'package:flutter/material.dart';
import 'package:trace_odd/shared/models/transport/absolute_layout_component.dart';

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
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(c.defaultIcon, color: c.defaultColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    c.typeLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white54,
                    size: 20,
                  ),
                  onPressed: widget.onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Position
            _sectionTitle('POSITION'),
            const SizedBox(height: 8),
            Row(
              children: [
                _field('X (px)', _xCtrl, 80),
                const SizedBox(width: 12),
                _field('Y (px)', _yCtrl, 80),
              ],
            ),
            const SizedBox(height: 16),

            // Size
            _sectionTitle('SIZE'),
            const SizedBox(height: 8),
            Row(
              children: [
                _field('Width', _wCtrl, 80),
                const SizedBox(width: 12),
                _field('Height', _hCtrl, 80),
              ],
            ),
            const SizedBox(height: 16),

            // Rotation
            _sectionTitle('ROTATION'),
            const SizedBox(height: 8),
            Row(
              children: [
                _field('Degrees', _rotCtrl, 80),
                const SizedBox(width: 12),
                // Quick-rotate buttons
                _rotateBtn('0°', 0),
                _rotateBtn('45°', 45),
                _rotateBtn('90°', 90),
                _rotateBtn('180°', 180),
              ],
            ),
            const SizedBox(height: 16),

            // Custom Label
            if (c.isEditable) ...[
              _sectionTitle('CUSTOM LABEL'),
              const SizedBox(height: 8),
              TextField(
                controller: _labelCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'e.g. VIP-1, A1, Driver Seat',
                  hintStyle: const TextStyle(color: Color(0x40FFFFFF)),
                  filled: true,
                  fillColor: const Color(0xFF122442),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0x20FFFFFF)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0x20FFFFFF)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: c.defaultColor),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Set a custom sticker label. Auto-numbering will skip this seat.',
                style: TextStyle(
                  color: const Color(0x60FFFFFF),
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Metadata
            _sectionTitle('INFO'),
            const SizedBox(height: 8),
            _infoRow('Type', c.typeLabel),
            _infoRow('ID', c.id.substring(0, 8)),
            if (c.seatNumber != null) _infoRow('Seat #', '${c.seatNumber}'),
            _infoRow('Bookable', c.bookable ? 'Yes' : 'No'),
            if (!c.isStructural) _infoRow('Booking Mode', c.bookingMode.name),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _apply,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Apply'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                if (c.isEditable) ...[
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      widget.onDelete();
                      widget.onClose();
                    },
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0x80FFFFFF),
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0x60FFFFFF), fontSize: 11),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: width,
          child: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF122442),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0x20FFFFFF)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0x20FFFFFF)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFF7C3AED)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _rotateBtn(String label, double value) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: InkWell(
        onTap: () => _rotCtrl.text = value.toStringAsFixed(0),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0x30FFFFFF)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 11),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              key,
              style: const TextStyle(color: Color(0x60FFFFFF), fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 12),
            ),
          ),
        ],
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

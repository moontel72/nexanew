// NEXATRACE — DIMENSION INPUT GROUP
// ==================================
// A row of Feet + Inches numerical inputs with stepper triggers
// and inline validation.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trace_odd/shared/models/transport/feet_inches.dart';

class DimensionInputGroup extends StatefulWidget {
  final String label;
  final FeetInches initialValue;
  final ValueChanged<FeetInches> onChanged;
  final int minFeet;
  final int maxFeet;

  const DimensionInputGroup({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.minFeet = 0,
    this.maxFeet = 50,
  });

  @override
  State<DimensionInputGroup> createState() => _DimensionInputGroupState();
}

class _DimensionInputGroupState extends State<DimensionInputGroup> {
  late final TextEditingController _feetCtrl;
  late final TextEditingController _inchesCtrl;
  String? _error;

  @override
  void initState() {
    super.initState();
    _feetCtrl = TextEditingController(
      text: widget.initialValue.feet.toString(),
    );
    _inchesCtrl = TextEditingController(
      text: widget.initialValue.inches.toString(),
    );
  }

  @override
  void didUpdateWidget(DimensionInputGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue.feet != oldWidget.initialValue.feet) {
      _feetCtrl.text = widget.initialValue.feet.toString();
    }
    if (widget.initialValue.inches != oldWidget.initialValue.inches) {
      _inchesCtrl.text = widget.initialValue.inches.toString();
    }
  }

  @override
  void dispose() {
    _feetCtrl.dispose();
    _inchesCtrl.dispose();
    super.dispose();
  }

  void _emit() {
    final f = int.tryParse(_feetCtrl.text) ?? 0;
    final i = int.tryParse(_inchesCtrl.text) ?? 0;

    if (i >= 12) {
      setState(
        () => _error = 'Inches must be between 0 and 11 (12 inches = 1 foot)',
      );
      return;
    }
    if (i < 0) {
      setState(() => _error = 'Inches cannot be negative');
      return;
    }

    setState(() => _error = null);
    final clamped = f.clamp(widget.minFeet, widget.maxFeet);
    widget.onChanged(FeetInches.normalize(clamped, i));
  }

  void _stepFeet(int delta) {
    final current = int.tryParse(_feetCtrl.text) ?? 0;
    final next = (current + delta).clamp(widget.minFeet, widget.maxFeet);
    _feetCtrl.text = next.toString();
    _emit();
  }

  void _stepInches(int delta) {
    final current = int.tryParse(_inchesCtrl.text) ?? 0;
    final next = current + delta;
    if (next >= 12) {
      _feetCtrl.text = ((int.tryParse(_feetCtrl.text) ?? 0) + 1).toString();
      _inchesCtrl.text = '0';
    } else if (next < 0) {
      final f = (int.tryParse(_feetCtrl.text) ?? 0) - 1;
      if (f >= widget.minFeet) {
        _feetCtrl.text = f.toString();
        _inchesCtrl.text = '11';
      }
    } else {
      _inchesCtrl.text = next.toString();
    }
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: Color(0xCCFFFFFF),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            // ── Feet ──
            _stepper(icon: Icons.remove, onTap: () => _stepFeet(-1)),
            const SizedBox(width: 4),
            SizedBox(
              width: 48,
              child: TextField(
                controller: _feetCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 6),
                  filled: true,
                  fillColor: Color(0xFF122442),
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                ),
                onChanged: (_) => _emit(),
              ),
            ),
            const SizedBox(width: 2),
            _stepper(icon: Icons.add, onTap: () => _stepFeet(1)),
            const SizedBox(width: 6),
            const Text(
              'ft',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(width: 12),
            // ── Inches ──
            _stepper(icon: Icons.remove, onTap: () => _stepInches(-1)),
            const SizedBox(width: 4),
            SizedBox(
              width: 48,
              child: TextField(
                controller: _inchesCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 6),
                  filled: true,
                  fillColor: Color(0xFF122442),
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                ),
                onChanged: (_) => _emit(),
              ),
            ),
            const SizedBox(width: 2),
            _stepper(icon: Icons.add, onTap: () => _stepInches(1)),
            const SizedBox(width: 6),
            const Text(
              'in',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _error!,
              style: const TextStyle(color: Color(0xFFDC2626), fontSize: 11),
            ),
          ),
      ],
    );
  }

  Widget _stepper({required IconData icon, required VoidCallback onTap}) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF1A2A3A),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0x30FFFFFF)),
          ),
          child: Icon(icon, size: 14, color: Colors.white54),
        ),
      );
}

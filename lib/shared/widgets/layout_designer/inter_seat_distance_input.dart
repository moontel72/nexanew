// NEXATRACE — INTER‑SEAT DISTANCE INPUT
// ======================================
// Compact control for aisle width and inter‑seat gap using
// the shared DimensionInputGroup.

import 'package:flutter/material.dart';
import 'package:trace_odd/shared/models/transport/component_registry.dart';
import 'package:trace_odd/shared/models/transport/dimensional_constants.dart';
import 'package:trace_odd/shared/widgets/layout_designer/dimension_input_group.dart';

class InterSeatDistanceInput extends StatelessWidget {
  final ComponentRegistry registry;
  final ValueChanged<ComponentRegistry> onChanged;

  const InterSeatDistanceInput({
    super.key,
    required this.registry,
    required this.onChanged,
  });

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
            'SPACING',
            style: TextStyle(
              color: Color(0xCCFFFFFF),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          DimensionInputGroup(
            label: 'Aisle Width',
            initialValue: registry.aisleWidth,
            minFeet: 1,
            maxFeet: 4,
            onChanged: (v) => onChanged(registry.copyWith(aisleWidth: v)),
          ),
          const SizedBox(height: 14),
          DimensionInputGroup(
            label: 'Inter‑Seat Gap (knee room)',
            initialValue: registry.interSeatGap,
            minFeet: 0,
            maxFeet: 3,
            onChanged: (v) => onChanged(registry.copyWith(interSeatGap: v)),
          ),
          const SizedBox(height: 8),
          if (registry.aisleWidth < kMinAisleWidth)
            const Text(
              '⚠ Aisle below 1′0″ minimum for emergency egress',
              style: TextStyle(color: Color(0xFFF59E0B), fontSize: 11),
            ),
        ],
      ),
    );
  }
}

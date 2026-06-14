// NEXATRACE — ABSOLUTE COMPONENT PALETTE
// =========================================
// Draggable palette of building blocks for the Absolute Bus Layout Engine.
// Unlike the legacy grid palette, this has NO aisle item (unnecessary in
// freeform positioning). Components are dragged directly onto the canvas.
//
// 100% isolated from the legacy ComponentPalette.

import 'package:flutter/material.dart';
import 'package:trace_odd/shared/models/transport/layout_component.dart';

/// Palette item definition.
class _PaletteItem {
  final ComponentType type;
  final String label;
  final IconData icon;
  final Color color;
  final double defaultWidth;
  final double defaultHeight;
  final bool isReverseFacing;

  const _PaletteItem({
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
    this.defaultWidth = 56.0,
    this.defaultHeight = 56.0,
    this.isReverseFacing = false,
  });
}

/// The items available in the palette (NO aisle).
const _paletteItems = [
  _PaletteItem(
    type: ComponentType.seat,
    label: 'Seat',
    icon: Icons.event_seat,
    color: Color(0xFF7C3AED),
  ),
  _PaletteItem(
    type: ComponentType.seat,
    label: 'Seat Rev.',
    icon: Icons.event_seat,
    color: Color(0xFF3B82F6),
    isReverseFacing: true,
  ),
  _PaletteItem(
    type: ComponentType.businessClassSeat,
    label: 'Business',
    icon: Icons.airline_seat_flat_angled,
    color: Color(0xFFD97706),
    defaultWidth: 84,
    defaultHeight: 84,
  ),
  _PaletteItem(
    type: ComponentType.sleeperLower,
    label: 'Sleeper L.',
    icon: Icons.airline_seat_flat,
    color: Color(0xFFDB2777),
    defaultWidth: 56,
    defaultHeight: 168,
  ),
  _PaletteItem(
    type: ComponentType.sleeperUpper,
    label: 'Sleeper U.',
    icon: Icons.airline_seat_flat_angled,
    color: Color(0xFFF97316),
    defaultWidth: 56,
    defaultHeight: 168,
  ),
  _PaletteItem(
    type: ComponentType.foldingSeat,
    label: 'Folding',
    icon: Icons.chair_alt,
    color: Color(0xFF06B6D4),
  ),
  _PaletteItem(
    type: ComponentType.restaurantTable,
    label: 'Table',
    icon: Icons.table_restaurant,
    color: Color(0xFF059669),
    defaultWidth: 112,
    defaultHeight: 112,
  ),
  _PaletteItem(
    type: ComponentType.driverCabin,
    label: 'Driver',
    icon: Icons.settings_accessibility,
    color: Color(0xFF1E293B),
    defaultWidth: 56,
    defaultHeight: 112,
  ),
  _PaletteItem(
    type: ComponentType.exitDoor,
    label: 'Exit',
    icon: Icons.door_front_door,
    color: Color(0xFFEF4444),
  ),
  _PaletteItem(
    type: ComponentType.emergency,
    label: 'Emergency',
    icon: Icons.warning_amber_rounded,
    color: Color(0xFFDC2626),
  ),
  _PaletteItem(
    type: ComponentType.lavatory,
    label: 'Lavatory',
    icon: Icons.wc,
    color: Color(0xFF6366F1),
    defaultWidth: 112,
    defaultHeight: 112,
  ),
];

class AbsoluteComponentPalette extends StatelessWidget {
  final void Function(
    ComponentType type,
    double defaultWidth,
    double defaultHeight,
    bool isReverseFacing,
  )
  onItemSelected;

  const AbsoluteComponentPalette({super.key, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      decoration: BoxDecoration(
        color: const Color(0xFF0A1628),
        border: Border(right: BorderSide(color: const Color(0x20FFFFFF))),
      ),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: const Color(0x20FFFFFF)),
              ),
            ),
            child: Text(
              'PARTS',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0x80FFFFFF),
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
          // Palette items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: _paletteItems.length,
              itemBuilder: (context, index) {
                final item = _paletteItems[index];
                return _PaletteTile(
                  item: item,
                  onTap: () => onItemSelected(
                    item.type,
                    item.defaultWidth,
                    item.defaultHeight,
                    item.isReverseFacing,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PaletteTile extends StatelessWidget {
  final _PaletteItem item;
  final VoidCallback onTap;

  const _PaletteTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: item.color.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.icon, color: item.color, size: 22),
                const SizedBox(height: 2),
                Text(
                  item.label,
                  style: TextStyle(
                    color: const Color(0xCCFFFFFF),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

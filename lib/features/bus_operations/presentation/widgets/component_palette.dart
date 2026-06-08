// NEXATRACE — COMPONENT PALETTE WIDGET
// =======================================
// Left-side drawer containing the 7 draggable component types.
// Users drag components from here onto the canvas grid.
//
// Section 14E: Component Palette.

import 'package:flutter/material.dart';
import 'package:trace_odd/features/bus_operations/domain/models/layout_component.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/canvas_grid.dart';

/// Metadata for palette items.
class _PaletteItem {
  final ComponentType type;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _PaletteItem({
    required this.type,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

const _paletteItems = [
  _PaletteItem(
    type: ComponentType.seat,
    label: 'Passenger Seat',
    subtitle: '1×1 · Standard',
    icon: Icons.event_seat,
    color: Color(0xFF7C3AED),
  ),
  _PaletteItem(
    type: ComponentType.sleeperLower,
    label: 'Sleeper Berth (Lower)',
    subtitle: '1×3 · Long-haul',
    icon: Icons.airline_seat_flat,
    color: Color(0xFFDB2777),
  ),
  _PaletteItem(
    type: ComponentType.sleeperUpper,
    label: 'Sleeper Berth (Upper)',
    subtitle: '1×3 · Long-haul',
    icon: Icons.airline_seat_flat_angled,
    color: Color(0xFFF97316),
  ),
  _PaletteItem(
    type: ComponentType.foldingSeat,
    label: 'Folding Aisle Seat',
    subtitle: '1×1 · 2-in-1 Coaster',
    icon: Icons.chair_alt,
    color: Color(0xFF06B6D4),
  ),
  _PaletteItem(
    type: ComponentType.lavatory,
    label: 'Lavatory / Washroom',
    subtitle: '2×2 · Non-bookable',
    icon: Icons.wc,
    color: Color(0xFF6366F1),
  ),
  _PaletteItem(
    type: ComponentType.exitDoor,
    label: 'Exit / Front Door',
    subtitle: '1×1 · Structural',
    icon: Icons.door_front_door,
    color: Color(0xFFEF4444),
  ),
  _PaletteItem(
    type: ComponentType.emergency,
    label: 'Emergency Exit',
    subtitle: '1×1 · Structural',
    icon: Icons.warning_amber_rounded,
    color: Color(0xFFDC2626),
  ),
];

class ComponentPalette extends StatelessWidget {
  final void Function(ComponentType type)? onComponentSelected;

  const ComponentPalette({super.key, this.onComponentSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
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
            offset: Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(14),
            child: Text(
              'COMPONENTS',
              style: TextStyle(
                color: Color(0xFF8899AA),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const Divider(color: Color(0x20FFFFFF), height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              itemCount: _paletteItems.length,
              itemBuilder: (context, index) {
                final item = _paletteItems[index];
                return _PaletteCard(
                  item: item,
                  onTap: onComponentSelected != null
                      ? () => onComponentSelected!(item.type)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PaletteCard extends StatefulWidget {
  final _PaletteItem item;
  final VoidCallback? onTap;

  const _PaletteCard({required this.item, this.onTap});

  @override
  State<_PaletteCard> createState() => _PaletteCardState();
}

class _PaletteCardState extends State<_PaletteCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: LongPressDraggable<ComponentType>(
        data: item.type,
        delay: const Duration(milliseconds: 200),
        feedback: Material(
          color: Colors.transparent,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: item.color, width: 2),
            ),
            child: Icon(item.icon, color: Colors.white, size: 32),
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.3, child: _buildCard(item)),
        child: GestureDetector(onTap: widget.onTap, child: _buildCard(item)),
      ),
    );
  }

  Widget _buildCard(_PaletteItem item) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _isHovered
            ? item.color.withValues(alpha: 0.15)
            : item.color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _isHovered
              ? item.color.withValues(alpha: 0.5)
              : item.color.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item.icon, size: 18, color: item.color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: const TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    color: item.color.withValues(alpha: 0.6),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

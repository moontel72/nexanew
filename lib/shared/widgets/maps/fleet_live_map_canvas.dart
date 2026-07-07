// Fleet Live Map Canvas — reactive map widget for telemetry tracking
//
// Wraps a map view inside a BlocBuilder<TelemetryTrackingBloc>.
// GPS marker updates are scoped to this widget's subtree — parent
// pages and sidebars are NOT rebuilt on every coordinate tick.
//
// Supports:
//   • Google Maps integration (uncomment google_maps_flutter when added)
//   • Placeholder canvas with grid + live marker dots
//   • Multi-tenant filtering via TelemetryScope
//   • Vehicle info cards on marker tap
//   • Connection status overlay
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/shared/bloc/telemetry_tracking/telemetry_models.dart';
import 'package:trace_odd/shared/bloc/telemetry_tracking/telemetry_tracking_bloc.dart';
import 'package:trace_odd/shared/bloc/telemetry_tracking/telemetry_tracking_state.dart';
import 'package:trace_odd/shared/theme/colors.dart';

class FleetLiveMapCanvas extends StatelessWidget {
  /// Map height in logical pixels. Use double.infinity to fill parent.
  final double height;

  /// Called when the user taps a vehicle marker.
  final void Function(VehicleTelemetry vehicle)? onVehicleTap;

  /// Whether to show the connection status badge overlay.
  final bool showConnectionBadge;

  /// Whether to show vehicle info popup on tap.
  final bool showVehiclePopup;

  const FleetLiveMapCanvas({
    super.key,
    this.height = 320,
    this.onVehicleTap,
    this.showConnectionBadge = true,
    this.showVehiclePopup = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TelemetryTrackingBloc, TelemetryTrackingState>(
      // buildWhen: only rebuild on packet updates or connection changes,
      // NOT on scope changes (which are handled separately).
      buildWhen: (prev, next) =>
          prev.visibleVehicles != next.visibleVehicles ||
          prev.connectionState != next.connectionState ||
          prev.lastUpdate != next.lastUpdate,
      builder: (ctx, state) {
        final vehicles = state.visibleVehicles;
        final isConnected =
            state.connectionState == TelemetryConnectionState.connected;

        return SizedBox(
          height: height,
          child: Stack(
            children: [
              // ── Map Background ──────────────────────────
              _MapPlaceholder(
                vehicles: vehicles,
                onVehicleTap: (v) {
                  if (onVehicleTap != null) {
                    onVehicleTap!(v);
                  } else if (showVehiclePopup) {
                    _showVehiclePopup(ctx, v);
                  }
                },
              ),

              // ── Connection Badge ────────────────────────
              if (showConnectionBadge)
                Positioned(
                  top: 12,
                  right: 12,
                  child: _ConnectionBadge(
                    isConnected: isConnected,
                    count: vehicles.length,
                  ),
                ),

              // ── Vehicle Count Badge ─────────────────────
              if (vehicles.isNotEmpty)
                Positioned(
                  top: 12,
                  left: 12,
                  child: _VehicleCountBadge(
                    count: vehicles.length,
                    activeCount: vehicles.where((v) => v.isActive).length,
                  ),
                ),

              // ── Loading / Error overlay ──────────────────
              if (state.connectionState == TelemetryConnectionState.connecting)
                const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF00B4D8)),
                      Gap(8),
                      Text(
                        'Connecting to tracking server…',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              if (state.error != null)
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      state.error!,
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showVehiclePopup(BuildContext context, VehicleTelemetry v) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B2838),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  v.vehicleType == 'truck'
                      ? Icons.local_shipping
                      : Icons.directions_bus,
                  color: const Color(0xFF00B4D8),
                ),
                const Gap(8),
                Text(
                  v.vehicleId,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                _statusChip(v.status),
              ],
            ),
            const Gap(16),
            _infoRow('Latitude', v.lat.toStringAsFixed(6)),
            _infoRow('Longitude', v.lng.toStringAsFixed(6)),
            _infoRow('Speed', '${v.speed.toStringAsFixed(1)} km/h'),
            _infoRow('Heading', '${v.heading.toStringAsFixed(0)}°'),
            if (v.routeId != null) _infoRow('Route', v.routeId!),
            if (v.tripId != null) _infoRow('Trip', v.tripId!),
            const Gap(8),
            Text(
              'Last update: ${_formatTime(v.timestamp)}',
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    final color = status == 'active'
        ? AppColors.success
        : status == 'idle'
        ? AppColors.warning
        : AppColors.gray400;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );

  String _formatTime(DateTime t) {
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${t.hour}:${t.minute.toString().padLeft(2, '0')}';
  }
}

// ─────────────────────────────────────────────────────────────
// Map Placeholder (swap with Google Maps when package is added)
// ─────────────────────────────────────────────────────────────

class _MapPlaceholder extends StatelessWidget {
  final List<VehicleTelemetry> vehicles;
  final void Function(VehicleTelemetry)? onVehicleTap;

  const _MapPlaceholder({required this.vehicles, this.onVehicleTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A1628),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x20FFFFFF)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Grid pattern
            CustomPaint(size: Size.infinite, painter: _GridPainter()),

            // Vehicle markers
            ...vehicles.map(
              (v) => _VehicleMarker(
                telemetry: v,
                onTap: () => onVehicleTap?.call(v),
              ),
            ),

            // Center hint if empty
            if (vehicles.isEmpty)
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.map, size: 48, color: Color(0x30FFFFFF)),
                    Gap(8),
                    Text(
                      'No active vehicles',
                      style: TextStyle(color: Color(0x50FFFFFF), fontSize: 14),
                    ),
                    Gap(4),
                    Text(
                      'Live tracking will appear here',
                      style: TextStyle(color: Color(0x30FFFFFF), fontSize: 11),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Paints a subtle grid on the map background.
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x10FFFFFF)
      ..strokeWidth = 0.5;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Animated vehicle marker dot on the map canvas.
class _VehicleMarker extends StatelessWidget {
  final VehicleTelemetry telemetry;
  final VoidCallback? onTap;

  const _VehicleMarker({required this.telemetry, this.onTap});

  @override
  Widget build(BuildContext context) {
    // Position is relative to the map container — in a real Google Maps
    // implementation, this would be a proper LatLng-based Marker.
    // For the placeholder, we use a pseudo-position based on vehicle ID hash.
    final hash = telemetry.vehicleId.hashCode.abs();
    final x = 20.0 + (hash % 300).toDouble();
    final y = 20.0 + ((hash ~/ 10) % 250).toDouble();

    final color = telemetry.vehicleType == 'truck'
        ? const Color(0xFFF59E0B)
        : telemetry.isActive
        ? const Color(0xFF00B4D8)
        : const Color(0xFF6B7280);

    return Positioned(
      left: x,
      top: y,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const Gap(2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xCC0A1628),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                telemetry.vehicleId.length > 6
                    ? '${telemetry.vehicleId.substring(0, 6)}…'
                    : telemetry.vehicleId,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Overlay Badges
// ─────────────────────────────────────────────────────────────

class _ConnectionBadge extends StatelessWidget {
  final bool isConnected;
  final int count;
  const _ConnectionBadge({required this.isConnected, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xCC0A1628),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isConnected
              ? AppColors.success.withValues(alpha: 0.5)
              : AppColors.error.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isConnected ? AppColors.success : AppColors.error,
            ),
          ),
          const Gap(6),
          Text(
            isConnected ? 'LIVE' : 'OFFLINE',
            style: TextStyle(
              color: isConnected ? AppColors.success : AppColors.error,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleCountBadge extends StatelessWidget {
  final int count;
  final int activeCount;
  const _VehicleCountBadge({required this.count, required this.activeCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xCC0A1628),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x30FFFFFF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.directions_bus, color: Color(0xFF00B4D8), size: 14),
          const Gap(4),
          Text(
            '$activeCount/$count active',
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

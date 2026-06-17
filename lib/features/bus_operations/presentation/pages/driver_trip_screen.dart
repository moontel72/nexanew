// NEXATRACE — DRIVER ACTIVE TRIP SCREEN
// =======================================
// Live operational dashboard for bus drivers. Shows the
// assigned trip, route stops, and provides Start/Complete
// trip controls. Launches the GPS beacon on trip start.
//
// MODULE: 15A — Active Line Manifest Terminal
// MODULE: 15B — High-Frequency Spatial Telemetry Beacon

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/features/bus_operations/data/services/driver_gps_beacon.dart';

class DriverTripScreen extends StatefulWidget {
  const DriverTripScreen({super.key});
  @override
  State<DriverTripScreen> createState() => _DriverTripScreenState();
}

class _DriverTripScreenState extends State<DriverTripScreen> {
  final _api = ApiService();
  DriverGpsBeacon? _beacon;
  Map<String, dynamic>? _trip;
  List<Map<String, dynamic>> _stops = [];
  bool _loading = true, _tripActive = false;

  @override
  void initState() {
    super.initState();
    _fetchAssignedTrip();
  }

  Future<void> _fetchAssignedTrip() async {
    try {
      final r = await _api.get('/bus-fleet/trips/active');
      final trips = r['data'] as List? ?? [];
      if (trips.isNotEmpty) {
        _trip = Map<String, dynamic>.from(trips.first);
        _stops = List<Map<String, dynamic>>.from(
          _trip!['stops'] ?? _trip!['waypoints'] ?? [],
        );
        _tripActive = (_trip!['status'] ?? '') == 'active';
        if (_tripActive) _startBeacon();
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _startTrip() async {
    if (_trip == null) return;
    await _api.post('/bus-fleet/driver/start-trip/${_trip!['id']}');
    _startBeacon();
    setState(() => _tripActive = true);
  }

  Future<void> _completeTrip() async {
    if (_trip == null) return;
    await _api.post('/bus-fleet/driver/complete-trip/${_trip!['id']}');
    _beacon?.stop();
    setState(() => _tripActive = false);
  }

  void _startBeacon() {
    if (_trip == null) return;
    _beacon?.stop();
    _beacon = DriverGpsBeacon(
      tripId: _trip!['id']?.toString() ?? '',
      intervalSec: 4,
    );
    _beacon!.start(
      lat: _trip!['current_lat'] ?? 31.5,
      lng: _trip!['current_lng'] ?? 73.0,
    );
  }

  @override
  void dispose() {
    _beacon?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Active Trip',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _trip == null
          ? _buildNoTrip()
          : RefreshIndicator(
              onRefresh: _fetchAssignedTrip,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _tripCard(theme),
                  const Gap(16),
                  _stopsList(theme),
                  const Gap(24),
                  _actionButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildNoTrip() => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.bus_alert, size: 64, color: Color(0xFFCBD5E1)),
        Gap(16),
        Text(
          'No active trip assigned',
          style: TextStyle(fontSize: 16, color: Color(0xFF94A3B8)),
        ),
        Gap(8),
        Text(
          'Contact dispatch for route assignment',
          style: TextStyle(fontSize: 13, color: Color(0xFFCBD5E1)),
        ),
      ],
    ),
  );

  Widget _tripCard(ThemeData theme) {
    final t = _trip!;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.directions_bus,
                    color: Color(0xFF3B82F6),
                    size: 24,
                  ),
                ),
                const Gap(14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t['route_name'] ?? t['display_name'] ?? 'Transit Route',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        'Bus: ${t['bus_reg'] ?? t['bus_id'] ?? 'N/A'} · ${_stops.length} stops',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _tripActive
                        ? const Color(0xFFF0FDF4)
                        : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _tripActive ? 'LIVE' : 'Ready',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _tripActive
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFD97706),
                    ),
                  ),
                ),
              ],
            ),
            const Gap(16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _infoChip(Icons.route, t['route_code'] ?? '—'),
                _infoChip(Icons.speed, '${t['current_speed'] ?? 0} km/h'),
                _infoChip(Icons.pin_drop, '${_stops.length} stops'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14, color: const Color(0xFF64748B)),
      const Gap(4),
      Text(
        label,
        style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
      ),
    ],
  );

  Widget _stopsList(ThemeData theme) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Route Stops',
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      const Gap(8),
      ..._stops.asMap().entries.map((e) {
        final s = e.value;
        final isFirst = e.key == 0, isLast = e.key == _stops.length - 1;
        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Icon(
                isFirst
                    ? Icons.trip_origin
                    : isLast
                    ? Icons.flag
                    : Icons.circle,
                size: 16,
                color: isFirst
                    ? const Color(0xFF22C55E)
                    : isLast
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF94A3B8),
              ),
              const Gap(10),
              Text(
                s['station_name'] ?? 'Stop ${e.key + 1}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (s['distance_from_origin_km'] != null)
                Text(
                  '${(s['distance_from_origin_km'] as num).toStringAsFixed(1)} km',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
            ],
          ),
        );
      }),
    ],
  );

  Widget _actionButton() {
    if (!_tripActive)
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: _startTrip,
          icon: const Icon(Icons.play_arrow),
          label: const Text('Start Trip'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            backgroundColor: const Color(0xFF16A34A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      );
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _completeTrip,
            icon: const Icon(Icons.stop),
            label: const Text('Complete Trip'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              foregroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const Gap(12),
        Expanded(
          child: FilledButton.icon(
            onPressed: _fetchAssignedTrip,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// NEXATRACE — LIVE BUS TRACKING SCREEN
// =======================================
// Real-time bus tracking dashboard with JWT-secured
// ETA share link generation.
//
// MODULE: 8V — Live Bus Tracking Canvas + ETA Exporter

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace_odd/features/bus_operations/data/services/bus_tracking_models.dart';
import 'package:trace_odd/features/bus_operations/data/services/jwt_encoder.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/bus_tracking/bus_tracking_bloc.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/route_map_painter.dart';

class LiveBusTrackingScreen extends StatefulWidget {
  final String tripId;
  final String? busId;
  const LiveBusTrackingScreen({super.key, required this.tripId, this.busId});
  @override
  State<LiveBusTrackingScreen> createState() => _LiveBusTrackingScreenState();
}

class _LiveBusTrackingScreenState extends State<LiveBusTrackingScreen>
    with SingleTickerProviderStateMixin {
  late final BusTrackingBloc _bloc;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _bloc = BusTrackingBloc();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _connect();
  }

  Future<void> _connect() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    _bloc.add(
      ConnectTracking(
        widget.tripId,
        busId: widget.busId,
        baseUrl: 'http://135.181.46.27/api/v1',
        authToken: token,
      ),
    );
  }

  @override
  void dispose() {
    _bloc.close();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: _bloc,
    child: Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _appBar(),
      body: BlocBuilder<BusTrackingBloc, BusTrackingState>(
        builder: (_, s) =>
            (!s.isConnected &&
                s.connectionState == TrackingConnectionState.connecting)
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(strokeWidth: 2.5),
                    Gap(20),
                    Text(
                      'Connecting to live tracking...',
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  _statsBar(s),
                  Expanded(flex: 3, child: _routeMap(s)),
                  Expanded(flex: 2, child: _etaPanel(s)),
                ],
              ),
      ),
    ),
  );

  PreferredSizeWidget _appBar() => AppBar(
    title: BlocBuilder<BusTrackingBloc, BusTrackingState>(
      builder: (_, s) {
        final label = s.isTripComplete
            ? 'Completed'
            : s.isConnected
            ? 'Live'
            : s.connectionState.name;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Live Tracking',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Row(
              children: [
                _dot(s),
                const Gap(6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.share, size: 20),
        tooltip: 'Share ETA link',
        onPressed: _shareEtaLink,
      ),
      const SizedBox(width: 4),
    ],
  );

  Widget _dot(BusTrackingState s) {
    final c = s.isTripComplete
        ? const Color(0xFF16A34A)
        : switch (s.connectionState) {
            TrackingConnectionState.connected => const Color(0xFF22C55E),
            TrackingConnectionState.connecting ||
            TrackingConnectionState.reconnecting => const Color(0xFFF59E0B),
            TrackingConnectionState.error => const Color(0xFFEF4444),
            _ => const Color(0xFF94A3B8),
          };
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: c,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: c.withValues(alpha: 0.4), blurRadius: 4)],
      ),
    );
  }

  Widget _statsBar(BusTrackingState s) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    color: Colors.white,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _stat(Icons.speed, '${s.currentSpeed.toInt()} km/h', 'Speed'),
        _stat(
          Icons.place,
          '${s.currentLat.toStringAsFixed(4)}, ${s.currentLng.toStringAsFixed(4)}',
          'Position',
        ),
        _stat(
          Icons.timer,
          s.lastUpdate != null
              ? '${DateTime.now().difference(s.lastUpdate!).inSeconds}s ago'
              : '--',
          'Last update',
        ),
      ],
    ),
  );

  Widget _stat(IconData i, String v, String l) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(i, size: 18, color: const Color(0xFF64748B)),
      const Gap(4),
      Text(
        v,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      Text(l, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
    ],
  );

  Widget _routeMap(BusTrackingState s) => Padding(
    padding: const EdgeInsets.all(12),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          painter: RouteMapPainter(
            busLat: s.currentLat,
            busLng: s.currentLng,
            etaStops: s.etaStops,
            currentWaypointIndex: s.etaStops.isNotEmpty
                ? s.etaStops.indexWhere((st) => st.etaSeconds > 0)
                : 0,
            isTripComplete: s.isTripComplete,
          ),
          size: Size.infinite,
        ),
      ),
    ),
  );

  Widget _etaPanel(BusTrackingState s) {
    final stops = s.etaStops;
    if (stops.isEmpty)
      return const Center(
        child: Text(
          'No stop data yet',
          style: TextStyle(color: Color(0xFF94A3B8)),
        ),
      );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule, size: 16, color: Color(0xFF64748B)),
              const Gap(6),
              Text(
                s.isTripComplete ? 'Route Complete' : 'Upcoming Stops',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
              const Spacer(),
              if (s.nextStop != null)
                Text(
                  'Next: ${s.nextStop!.etaDisplay}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3B82F6),
                  ),
                ),
            ],
          ),
          const Gap(8),
          Expanded(
            child: ListView.separated(
              itemCount: stops.length,
              separatorBuilder: (_, __) => const Gap(0),
              itemBuilder: (_, i) {
                final stop = stops[i];
                final isPast = stop.etaSeconds <= 0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isPast
                        ? const Color(0xFFF0FDF4)
                        : i == 0
                        ? const Color(0xFFEFF6FF)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isPast
                          ? const Color(0xFFBBF7D0)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isPast ? Icons.check_circle : Icons.circle_outlined,
                        size: 18,
                        color: isPast
                            ? const Color(0xFF16A34A)
                            : const Color(0xFF94A3B8),
                      ),
                      const Gap(10),
                      Expanded(
                        child: Text(
                          stop.station,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isPast
                                ? const Color(0xFF166534)
                                : const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      Text(
                        isPast ? 'Arrived' : stop.etaDisplay,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isPast
                              ? const Color(0xFF16A34A)
                              : const Color(0xFF64748B),
                        ),
                      ),
                      const Gap(8),
                      Text(
                        stop.distanceDisplay,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _shareEtaLink() {
    final s = _bloc.state;
    final jwt = JwtEncoder().generateEtaShareToken(
      tripId: s.tripId,
      busId: s.busId,
    );
    final url = JwtEncoder().buildShareUrl(jwt);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🔗 Secure tracking link generated!\n$url'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 6),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }
}

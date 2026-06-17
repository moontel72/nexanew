// NEXATRACE — LIVE BUS TRACKING SCREEN
// =======================================
// Real-time bus tracking dashboard for the Customer App.
// Shows the route map with animated bus icon, live speed,
// ETA for each upcoming stop, and connection status.
//
// ROUTE:  /bus-fleet/live-tracking?trip=:tripId&bus=:busId
//
// MODULE: 8V — Live Bus Tracking Canvas

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace_odd/features/bus_operations/data/services/bus_tracking_models.dart';
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
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: _buildAppBar(),
        body: BlocBuilder<BusTrackingBloc, BusTrackingState>(
          builder: (context, state) {
            if (!state.isConnected &&
                state.connectionState == TrackingConnectionState.connecting) {
              return _buildConnecting();
            }
            return _buildTrackingView(state);
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: BlocBuilder<BusTrackingBloc, BusTrackingState>(
        builder: (_, state) {
          final statusLabel = state.isTripComplete
              ? 'Completed'
              : state.isConnected
              ? 'Live'
              : state.connectionState.name;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Live Tracking',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              Row(
                children: [
                  _connectionDot(state),
                  const Gap(6),
                  Text(
                    statusLabel,
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
          onPressed: () => _shareEtaLink(),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _connectionDot(BusTrackingState state) {
    Color c;
    if (state.isTripComplete) {
      c = const Color(0xFF16A34A);
    } else {
      c = switch (state.connectionState) {
        TrackingConnectionState.connected => const Color(0xFF22C55E),
        TrackingConnectionState.connecting ||
        TrackingConnectionState.reconnecting => const Color(0xFFF59E0B),
        TrackingConnectionState.error => const Color(0xFFEF4444),
        _ => const Color(0xFF94A3B8),
      };
    }
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

  Widget _buildConnecting() {
    return const Center(
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
    );
  }

  Widget _buildTrackingView(BusTrackingState state) {
    return Column(
      children: [
        _buildStatsBar(state),
        Expanded(flex: 3, child: _buildRouteMap(state)),
        Expanded(flex: 2, child: _buildEtaPanel(state)),
      ],
    );
  }

  Widget _buildStatsBar(BusTrackingState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _stat(Icons.speed, '${state.currentSpeed.toInt()} km/h', 'Speed'),
          _stat(
            Icons.place,
            '${state.currentLat.toStringAsFixed(4)}, ${state.currentLng.toStringAsFixed(4)}',
            'Position',
          ),
          _stat(
            Icons.timer,
            state.lastUpdate != null
                ? '${DateTime.now().difference(state.lastUpdate!).inSeconds}s ago'
                : '--',
            'Last update',
          ),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF64748B)),
        const Gap(4),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
        ),
      ],
    );
  }

  Widget _buildRouteMap(BusTrackingState state) {
    return Padding(
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
              busLat: state.currentLat,
              busLng: state.currentLng,
              etaStops: state.etaStops,
              currentWaypointIndex: state.etaStops.isNotEmpty
                  ? state.etaStops.indexWhere((s) => s.etaSeconds > 0)
                  : 0,
              isTripComplete: state.isTripComplete,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }

  Widget _buildEtaPanel(BusTrackingState state) {
    final stops = state.etaStops;
    if (stops.isEmpty) {
      return const Center(
        child: Text(
          'No stop data yet',
          style: TextStyle(color: Color(0xFF94A3B8)),
        ),
      );
    }
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
                state.isTripComplete ? 'Route Complete' : 'Upcoming Stops',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
              const Spacer(),
              if (state.nextStop != null)
                Text(
                  'Next: ${state.nextStop!.etaDisplay}',
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
    final state = _bloc.state;
    final etaText = state.etaStops
        .map((s) => '${s.station}: ${s.etaDisplay} (${s.distanceDisplay})')
        .join('\n');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🚌 Live — ${state.currentSpeed.toInt()} km/h\n'
          'Next: ${state.nextStop?.station ?? "N/A"} — ${state.nextStop?.etaDisplay ?? "N/A"}\n$etaText',
        ),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }
}

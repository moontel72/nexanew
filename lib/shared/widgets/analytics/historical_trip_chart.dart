// Historical Trip Chart — BLoC-driven analytics widget
//
// Displays speed profiles, alert counts, and trip metrics
// using a lightweight custom-painted chart. No external chart
// package dependency — uses Flutter's Canvas API directly.
//
// Data comes from FleetAnalyticsBloc → FleetAnalyticsState.tripAnalytics.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/shared/bloc/fleet_analytics/fleet_analytics_bloc.dart';
import 'package:trace_odd/shared/bloc/fleet_analytics/fleet_analytics_state.dart';
import 'package:trace_odd/shared/models/geofence_models.dart';
import 'package:trace_odd/shared/theme/colors.dart';

class HistoricalTripChart extends StatelessWidget {
  /// Which trip to display. If null, shows fleet aggregate.
  final String? tripId;

  /// Chart height.
  final double height;

  const HistoricalTripChart({super.key, this.tripId, this.height = 280});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FleetAnalyticsBloc, FleetAnalyticsState>(
      buildWhen: (prev, next) =>
          prev.tripAnalytics != next.tripAnalytics ||
          prev.fleetOnTimePct != next.fleetOnTimePct ||
          prev.totalDeviations != next.totalDeviations ||
          prev.totalSpeedViolations != next.totalSpeedViolations,
      builder: (ctx, state) {
        final analytics = tripId != null ? state.tripAnalytics[tripId] : null;

        return Container(
          height: height,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1B2838),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0x20FFFFFF)),
          ),
          child: analytics != null
              ? _SingleTripView(analytics: analytics)
              : _FleetAggregateView(state: state),
        );
      },
    );
  }
}

/// Single trip detailed analytics view.
class _SingleTripView extends StatelessWidget {
  final TripAnalytics analytics;
  const _SingleTripView({required this.analytics});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.route, color: Color(0xFF00B4D8), size: 18),
            const Gap(8),
            Text(
              'Trip ${analytics.tripId}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const Gap(12),
        // Metrics row
        Row(
          children: [
            _metricChip(
              'Distance',
              '${analytics.totalDistanceKm.toStringAsFixed(1)} km',
              const Color(0xFF00B4D8),
            ),
            const Gap(8),
            _metricChip(
              'Avg Speed',
              '${analytics.avgSpeedKmh.toStringAsFixed(0)} km/h',
              const Color(0xFF059669),
            ),
            const Gap(8),
            _metricChip(
              'Max Speed',
              '${analytics.maxSpeedKmh.toStringAsFixed(0)} km/h',
              const Color(0xFFF59E0B),
            ),
          ],
        ),
        const Gap(8),
        Row(
          children: [
            _metricChip(
              'Duration',
              analytics.durationDisplay,
              const Color(0xFF7C3AED),
            ),
            const Gap(8),
            _metricChip(
              'Alerts',
              '${analytics.alertCount}',
              analytics.alertCount > 0 ? AppColors.error : AppColors.success,
            ),
            const Gap(8),
            _metricChip(
              'On-Time',
              '${analytics.onTimePercentage.toStringAsFixed(0)}%',
              analytics.onTimePercentage >= 90
                  ? AppColors.success
                  : AppColors.warning,
            ),
          ],
        ),
        const Gap(16),
        // Speed profile mini-chart
        Expanded(
          child: _SpeedProfileChart(
            profile: analytics.speedProfile,
            maxSpeed: analytics.maxSpeedKmh,
          ),
        ),
      ],
    );
  }
}

/// Fleet aggregate metrics view.
class _FleetAggregateView extends StatelessWidget {
  final FleetAnalyticsState state;
  const _FleetAggregateView({required this.state});

  @override
  Widget build(BuildContext context) {
    final trips = state.tripAnalytics.values.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fleet Analytics Overview',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Gap(12),
        Row(
          children: [
            _metricChip(
              'Active Trips',
              '${state.totalActiveTrips}',
              const Color(0xFF00B4D8),
            ),
            const Gap(8),
            _metricChip(
              'Deviations',
              '${state.totalDeviations}',
              state.totalDeviations > 0 ? AppColors.warning : AppColors.success,
            ),
            const Gap(8),
            _metricChip(
              'Speed Alerts',
              '${state.totalSpeedViolations}',
              state.totalSpeedViolations > 0
                  ? AppColors.error
                  : AppColors.success,
            ),
            const Gap(8),
            _metricChip(
              'On-Time',
              '${state.fleetOnTimePct.toStringAsFixed(0)}%',
              state.fleetOnTimePct >= 90
                  ? AppColors.success
                  : AppColors.warning,
            ),
          ],
        ),
        const Gap(16),
        // Recent alerts mini-list
        if (state.recentAlerts.isNotEmpty) ...[
          const Text(
            'Recent Alerts',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const Gap(6),
          Expanded(
            child: ListView(
              children: state.recentAlerts
                  .take(5)
                  .map((a) => _alertRow(a))
                  .toList(),
            ),
          ),
        ] else
          const Expanded(
            child: Center(
              child: Text(
                'No recent alerts',
                style: TextStyle(color: Colors.white38),
              ),
            ),
          ),
        // Trip summaries
        if (trips.isNotEmpty) ...[
          const Gap(12),
          const Text(
            'Trip Summaries',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const Gap(4),
          Expanded(
            child: ListView(
              children: trips.take(5).map((t) => _tripSummaryRow(t)).toList(),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Shared sub-widgets ──

Widget _metricChip(String label, String value, Color color) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(2),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ],
      ),
    ),
  );
}

Widget _alertRow(GeofenceAlert alert) {
  final color = alert.isCritical ? AppColors.error : AppColors.warning;
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      children: [
        Icon(
          alert.type == 'speed_violation' ? Icons.speed : Icons.warning_amber,
          color: color,
          size: 14,
        ),
        const Gap(6),
        Expanded(
          child: Text(
            '${alert.vehicleId} — ${alert.type.replaceAll('_', ' ')}',
            style: TextStyle(color: color, fontSize: 11),
          ),
        ),
        Text(
          _timeAgo(alert.timestamp),
          style: const TextStyle(color: Colors.white38, fontSize: 10),
        ),
      ],
    ),
  );
}

Widget _tripSummaryRow(TripAnalytics t) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      children: [
        const Icon(Icons.directions_bus, color: Color(0xFF00B4D8), size: 14),
        const Gap(6),
        Expanded(
          child: Text(
            t.tripId,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ),
        Text(
          '${t.totalDistanceKm.toStringAsFixed(0)}km · ${t.alertCount} alerts',
          style: const TextStyle(color: Colors.white38, fontSize: 10),
        ),
      ],
    ),
  );
}

String _timeAgo(DateTime t) {
  final diff = DateTime.now().difference(t);
  if (diff.inMinutes < 1) return 'now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  return '${diff.inHours}h';
}

// ── Speed Profile Mini-Chart (CustomPainter) ──

class _SpeedProfileChart extends StatelessWidget {
  final List<double> profile;
  final double maxSpeed;
  const _SpeedProfileChart({required this.profile, required this.maxSpeed});

  @override
  Widget build(BuildContext context) {
    if (profile.isEmpty) {
      return const Center(
        child: Text('No speed data', style: TextStyle(color: Colors.white38)),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CustomPaint(
        size: Size.infinite,
        painter: _SpeedProfilePainter(profile: profile, maxSpeed: maxSpeed),
      ),
    );
  }
}

class _SpeedProfilePainter extends CustomPainter {
  final List<double> profile;
  final double maxSpeed;
  _SpeedProfilePainter({required this.profile, required this.maxSpeed});

  @override
  void paint(Canvas canvas, Size size) {
    if (profile.isEmpty) return;

    final bgPaint = Paint()..color = const Color(0x10FFFFFF);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Grid lines
    final gridPaint = Paint()
      ..color = const Color(0x10FFFFFF)
      ..strokeWidth = 0.5;
    for (int i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Speed line
    final linePaint = Paint()
      ..color = const Color(0xFF00B4D8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF00B4D8).withValues(alpha: 0.3),
          const Color(0xFF00B4D8).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();
    final stepX = size.width / (profile.length - 1);
    final effectiveMax = maxSpeed > 0 ? maxSpeed : 120.0;

    for (int i = 0; i < profile.length; i++) {
      final x = i * stepX;
      final y = size.height - (profile[i] / effectiveMax * size.height * 0.9);
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // Labels
    final labelStyle = const TextStyle(color: Color(0x60FFFFFF), fontSize: 9);
    final tp = TextPainter(
      text: TextSpan(
        text: '${effectiveMax.toStringAsFixed(0)} km/h',
        style: labelStyle,
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, const Offset(4, 2));
  }

  @override
  bool shouldRepaint(covariant _SpeedProfilePainter old) =>
      old.profile != profile || old.maxSpeed != maxSpeed;
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/features/cricket/data/models/cricket_models.dart';
import 'package:trace_odd/features/cricket/data/repositories/cricket_repository.dart';
import 'package:trace_odd/features/cricket/presentation/blocs/match_analytics/match_analytics_bloc.dart';

class MatchAnalyticsPage extends StatefulWidget {
  final String matchId;
  final String matchTitle;
  const MatchAnalyticsPage({
    super.key,
    required this.matchId,
    required this.matchTitle,
  });

  @override
  State<MatchAnalyticsPage> createState() => _MatchAnalyticsPageState();
}

class _MatchAnalyticsPageState extends State<MatchAnalyticsPage> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<MatchAnalyticsBloc>();
    bloc.add(LoadWagonWheel(widget.matchId));
    bloc.add(LoadRunDistribution(widget.matchId));
    bloc.add(LoadConcededRuns(widget.matchId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: Text('${widget.matchTitle} — Analytics'),
        backgroundColor: const Color(0xFF1A1E31),
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<MatchAnalyticsBloc, MatchAnalyticsState>(
        builder: (ctx, state) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (state is WagonWheelLoaded)
                _WagonWheelSection(shots: state.shots),
              if (state is RunDistributionLoaded)
                _DistributionSection(dist: state.distribution),
              if (state is ConcededRunsLoaded)
                _ConcededSection(breakdown: state.breakdown),
            ],
          ),
        ),
      ),
    );
  }
}

class _WagonWheelSection extends StatelessWidget {
  final List<WagonWheelShot> shots;
  const _WagonWheelSection({required this.shots});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Wagon Wheel',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 300,
          child: CustomPaint(
            size: const Size(300, 300),
            painter: _WagonWheelPainter(shots: shots),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendItem(color: Colors.grey, label: '0'),
            _LegendItem(color: Colors.white, label: '1'),
            _LegendItem(color: Colors.cyan, label: '2'),
            _LegendItem(color: Colors.green, label: '4'),
            _LegendItem(color: Colors.amber, label: '6'),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 11)),
      ],
    ),
  );
}

class _WagonWheelPainter extends CustomPainter {
  final List<WagonWheelShot> shots;
  _WagonWheelPainter({required this.shots});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Draw field circle
    final fieldPaint = Paint()
      ..color = const Color(0xFF2D5A27)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, fieldPaint);

    // Draw boundary
    final boundaryPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, boundaryPaint);

    // Draw pitch strip
    final pitchPaint = Paint()..color = const Color(0xFFC4A35A);
    canvas.drawRect(
      Rect.fromCenter(center: center, width: 8, height: radius * 1.2),
      pitchPaint,
    );

    // Draw shots
    for (final shot in shots) {
      if (shot.direction == null) continue;
      final angle = (shot.direction! - 90) * (pi / 180);
      final shotRadius = radius * 0.85;
      final endX = center.dx + shotRadius * cos(angle);
      final endY = center.dy + shotRadius * sin(angle);

      Color shotColor;
      switch (shot.runs) {
        case 0:
          shotColor = Colors.grey;
          break;
        case 1:
          shotColor = Colors.white;
          break;
        case 2:
          shotColor = Colors.cyanAccent;
          break;
        case 3:
          shotColor = Colors.teal;
          break;
        case 4:
          shotColor = Colors.greenAccent;
          break;
        case 6:
          shotColor = Colors.amber;
          break;
        default:
          shotColor = Colors.white54;
      }

      final paint = Paint()
        ..color = shotColor.withOpacity(0.7)
        ..strokeWidth = shot.isBoundary ? 3.0 : 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(center, Offset(endX, endY), paint);
    }

    // Off-side / Leg-side labels
    final textStyle = TextStyle(
      color: Colors.white.withOpacity(0.5),
      fontSize: 10,
    );
    final offPainter = TextPainter(
      text: TextSpan(text: 'OFF', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    offPainter.paint(canvas, Offset(center.dx + radius - 30, center.dy - 8));
    final legPainter = TextPainter(
      text: TextSpan(text: 'LEG', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    legPainter.paint(canvas, Offset(center.dx - radius + 10, center.dy - 8));
  }

  @override
  bool shouldRepaint(covariant _WagonWheelPainter old) => old.shots != shots;
}

class _DistributionSection extends StatelessWidget {
  final RunDistribution dist;
  const _DistributionSection({required this.dist});

  @override
  Widget build(BuildContext context) {
    final total = dist.totalRuns;
    return Column(
      children: [
        const SizedBox(height: 24),
        const Text(
          'Run Distribution',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _DistBar(
          label: 'Dot Balls',
          count: dist.dotBalls,
          total: dist.totalBalls,
          color: Colors.grey,
        ),
        _DistBar(
          label: '1s',
          count: dist.singles,
          total: total,
          color: Colors.white,
        ),
        _DistBar(
          label: '2s',
          count: dist.twos,
          total: total,
          color: Colors.cyanAccent,
        ),
        _DistBar(
          label: '3s',
          count: dist.threes,
          total: total,
          color: Colors.teal,
        ),
        _DistBar(
          label: '4s',
          count: dist.fours,
          total: total,
          color: Colors.greenAccent,
        ),
        _DistBar(
          label: '6s',
          count: dist.sixes,
          total: total,
          color: Colors.amber,
        ),
        _DistBar(
          label: 'Extras',
          count:
              dist.extrasWides +
              dist.extrasNoBalls +
              dist.extrasByes +
              dist.extrasLegByes,
          total: total,
          color: Colors.orange,
        ),
      ],
    );
  }
}

class _DistBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;
  const _DistBar({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? count / total : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(label, style: TextStyle(color: color, fontSize: 12)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 12,
                backgroundColor: Colors.white10,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('$count', style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}

class _ConcededSection extends StatelessWidget {
  final ConcededRunsBreakdown breakdown;
  const _ConcededSection({required this.breakdown});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const SizedBox(height: 24),
      const Text(
        'Conceded Runs',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        'Total: ${breakdown.totalConceded} runs',
        style: const TextStyle(color: Colors.grey),
      ),
      const SizedBox(height: 8),
      _PctRow(label: '1s', pct: breakdown.singlesPct, color: Colors.white),
      _PctRow(label: '2s', pct: breakdown.twosPct, color: Colors.cyanAccent),
      _PctRow(label: '3s', pct: breakdown.threesPct, color: Colors.teal),
      _PctRow(label: '4s', pct: breakdown.foursPct, color: Colors.greenAccent),
      _PctRow(label: '6s', pct: breakdown.sixesPct, color: Colors.amber),
      _PctRow(label: 'Extras', pct: breakdown.extrasPct, color: Colors.orange),
    ],
  );
}

class _PctRow extends StatelessWidget {
  final String label;
  final double pct;
  final Color color;
  const _PctRow({required this.label, required this.pct, required this.color});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        SizedBox(
          width: 50,
          child: Text(label, style: TextStyle(color: color)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct / 100,
              minHeight: 10,
              backgroundColor: Colors.white10,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${pct.toStringAsFixed(1)}%',
          style: TextStyle(color: color, fontSize: 12),
        ),
      ],
    ),
  );
}

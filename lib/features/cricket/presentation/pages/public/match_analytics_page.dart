import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/theme/cricket_colors.dart';
import 'package:trace_odd/features/cricket/data/models/cricket_models.dart';
import 'package:trace_odd/features/cricket/presentation/blocs/match_analytics/match_analytics_bloc.dart';
import 'package:trace_odd/features/cricket/presentation/widgets/wagon_wheel_painter.dart';

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
  WagonWheelLoaded? _wagonState;
  RunDistributionLoaded? _distState;
  ConcededRunsLoaded? _concededState;

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
      backgroundColor: CricketColors.background,
      appBar: AppBar(
        title: Text('${widget.matchTitle} — Analytics'),
        backgroundColor: CricketColors.surface,
        foregroundColor: CricketColors.textPrimary,
      ),
      body: BlocBuilder<MatchAnalyticsBloc, MatchAnalyticsState>(
        builder: (ctx, state) {
          // Accumulate loaded states
          if (state is WagonWheelLoaded) _wagonState = state;
          if (state is RunDistributionLoaded) _distState = state;
          if (state is ConcededRunsLoaded) _concededState = state;

          final hasData =
              _wagonState != null ||
              _distState != null ||
              _concededState != null;

          if (!hasData && state is MatchAnalyticsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (_wagonState != null)
                  _WagonWheelSection(shots: _wagonState!.shots),
                if (_distState != null)
                  _DistributionSection(dist: _distState!.distribution),
                if (_concededState != null)
                  _ConcededSection(breakdown: _concededState!.breakdown),
                if (state is MatchAnalyticsError)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          );
        },
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
        Text(
          'Wagon Wheel',
          style: TextStyle(
            color: CricketColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 320,
          child: CustomPaint(
            size: const Size(double.infinity, 320),
            painter: WagonWheelPainter(shots: shots),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendItem(color: CricketColors.runDot, label: '0'),
            _LegendItem(color: CricketColors.runSingle, label: '1'),
            _LegendItem(color: CricketColors.runTwo, label: '2'),
            _LegendItem(color: CricketColors.runFour, label: '4'),
            _LegendItem(color: CricketColors.runSix, label: '6'),
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

class _DistributionSection extends StatelessWidget {
  final RunDistribution dist;
  const _DistributionSection({required this.dist});

  @override
  Widget build(BuildContext context) {
    final total = dist.totalRuns;
    return Column(
      children: [
        const SizedBox(height: 24),
        Text(
          'Run Distribution',
          style: TextStyle(
            color: CricketColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _DistBar(
          label: 'Dot Balls',
          count: dist.dotBalls,
          total: dist.totalBalls,
          color: CricketColors.runDot,
        ),
        _DistBar(
          label: '1s',
          count: dist.singles,
          total: total,
          color: CricketColors.runSingle,
        ),
        _DistBar(
          label: '2s',
          count: dist.twos,
          total: total,
          color: CricketColors.runTwo,
        ),
        _DistBar(
          label: '3s',
          count: dist.threes,
          total: total,
          color: CricketColors.runThree,
        ),
        _DistBar(
          label: '4s',
          count: dist.fours,
          total: total,
          color: CricketColors.runFour,
        ),
        _DistBar(
          label: '6s',
          count: dist.sixes,
          total: total,
          color: CricketColors.runSix,
        ),
        _DistBar(
          label: 'Extras',
          count:
              dist.extrasWides +
              dist.extrasNoBalls +
              dist.extrasByes +
              dist.extrasLegByes,
          total: total,
          color: AppColors.warning,
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
      Text(
        'Conceded Runs',
        style: TextStyle(
          color: CricketColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        'Total: ${breakdown.totalConceded} runs',
        style: TextStyle(color: CricketColors.textSecondary),
      ),
      const SizedBox(height: 8),
      _PctRow(
        label: '1s',
        pct: breakdown.singlesPct,
        color: CricketColors.runSingle,
      ),
      _PctRow(label: '2s', pct: breakdown.twosPct, color: CricketColors.runTwo),
      _PctRow(
        label: '3s',
        pct: breakdown.threesPct,
        color: CricketColors.runThree,
      ),
      _PctRow(
        label: '4s',
        pct: breakdown.foursPct,
        color: CricketColors.runFour,
      ),
      _PctRow(
        label: '6s',
        pct: breakdown.sixesPct,
        color: CricketColors.runSix,
      ),
      _PctRow(
        label: 'Extras',
        pct: breakdown.extrasPct,
        color: AppColors.warning,
      ),
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

import 'package:flutter/material.dart';
import 'package:trace_odd/shared/theme/cricket_colors.dart';

import '../../data/models/cricket_models.dart';

/// Phase 5 — worm chart: over-by-over run progression comparison between
/// the two innings. Pure CustomPainter — no state, no setState.
class WormChart extends StatelessWidget {
  final List<ProgressionPoint> innings1;
  final List<ProgressionPoint> innings2;
  final String innings1Label;
  final String innings2Label;

  const WormChart({
    super.key,
    required this.innings1,
    required this.innings2,
    required this.innings1Label,
    required this.innings2Label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 200,
          child: CustomPaint(
            painter: WormChartPainter(innings1: innings1, innings2: innings2),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendDot(color: CricketColors.teamA, label: innings1Label),
            const SizedBox(width: 16),
            _LegendDot(color: CricketColors.teamB, label: innings2Label),
          ],
        ),
      ],
    );
  }
}

class WormChartPainter extends CustomPainter {
  final List<ProgressionPoint> innings1;
  final List<ProgressionPoint> innings2;

  WormChartPainter({required this.innings1, required this.innings2});

  @override
  void paint(Canvas canvas, Size size) {
    const padding = EdgeInsets.fromLTRB(34, 12, 12, 24);
    final plotRect = Rect.fromLTRB(
      padding.left,
      padding.top,
      size.width - padding.right,
      size.height - padding.bottom,
    );

    final maxOvers = _maxOvers;
    final maxRuns = _maxRuns;

    if (maxOvers <= 0 || maxRuns <= 0) {
      return;
    }

    // Grid + axes
    final gridPaint = Paint()
      ..color = CricketColors.textTertiary.withOpacity(0.4)
      ..strokeWidth = 0.5;
    for (var o = 0; o <= maxOvers; o += 5) {
      final x = plotRect.left + plotRect.width * o / maxOvers;
      canvas.drawLine(
        Offset(x, plotRect.top),
        Offset(x, plotRect.bottom),
        gridPaint,
      );
    }
    final runStep = _niceStep(maxRuns);
    for (var r = 0; r <= maxRuns + runStep; r += runStep) {
      final y = plotRect.bottom - plotRect.height * r / maxRuns;
      canvas.drawLine(
        Offset(plotRect.left, y),
        Offset(plotRect.right, y),
        gridPaint,
      );
      _paintLabel(canvas, '$r', Offset(plotRect.left - 4, y), alignRight: true);
    }

    // Axes labels
    _paintLabel(canvas, 'OVERS', Offset(plotRect.center.dx, size.height - 2));
    _paintLabel(canvas, 'RUNS', Offset(4, plotRect.center.dy));

    _drawLine(
      canvas,
      plotRect,
      maxOvers,
      maxRuns,
      innings1,
      CricketColors.teamA,
    );
    _drawLine(
      canvas,
      plotRect,
      maxOvers,
      maxRuns,
      innings2,
      CricketColors.teamB,
    );
  }

  int get _maxOvers {
    var maxOvers = 0;
    for (final p in [...innings1, ...innings2]) {
      if (p.over > maxOvers) maxOvers = p.over;
    }
    return maxOvers;
  }

  int get _maxRuns {
    var maxRuns = 0;
    for (final p in [...innings1, ...innings2]) {
      if (p.runs > maxRuns) maxRuns = p.runs;
    }
    return maxRuns == 0 ? 10 : maxRuns;
  }

  static int _niceStep(int maxRuns) {
    final step = (maxRuns / 4).ceil();
    if (step <= 5) return 5;
    if (step <= 10) return 10;
    if (step <= 25) return 25;
    return 50;
  }

  void _drawLine(
    Canvas canvas,
    Rect rect,
    int maxOvers,
    int maxRuns,
    List<ProgressionPoint> points,
    Color color,
  ) {
    if (points.isEmpty) return;

    Offset offsetFor(ProgressionPoint p) => Offset(
      rect.left + rect.width * p.over / maxOvers,
      rect.bottom - rect.height * p.runs / maxRuns,
    );

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()..moveTo(rect.left, rect.bottom);
    for (final p in points) {
      path.lineTo(offsetFor(p).dx, offsetFor(p).dy);
    }
    canvas.drawPath(path, paint);

    // Endpoint dot
    final last = points.last;
    canvas.drawCircle(offsetFor(last), 3.5, Paint()..color = color);
  }

  void _paintLabel(
    Canvas canvas,
    String text,
    Offset at, {
    bool alignRight = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(color: CricketColors.textSecondary, fontSize: 8),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = alignRight ? at.dx - tp.width : at.dx;
    tp.paint(canvas, Offset(dx, at.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant WormChartPainter oldDelegate) =>
      innings1 != oldDelegate.innings1 || innings2 != oldDelegate.innings2;
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: CricketColors.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/shared/theme/cricket_colors.dart';

import '../blocs/live_score/live_score_bloc.dart';
import '../blocs/scoring_control/scoring_control_bloc.dart';

/// Phase 3 — interactive wagon-wheel shot-direction picker shown after
/// the scorer taps FOUR or SIX.
///
/// The scorer no longer picks a labelled chip: they tap (or drag) the
/// small ground map and the direction is fetched automatically from the
/// map geometry — hovering anywhere on the map resolves the zone name
/// under the cursor without any manual typing. Tap submits the boundary
/// with `shot_direction` so the public wagon wheel, the Studio mini-map,
/// the auto-popup text and the bowler heat map all render real data.
///
/// Direction convention (matches the Laravel ShotZoneMapper):
///   0° = straight down the ground (up on screen), 0–180 leg side,
///   180–360 off side.
class ShotDirectionSheet extends StatefulWidget {
  const ShotDirectionSheet({super.key});

  @override
  State<ShotDirectionSheet> createState() => _ShotDirectionSheetState();
}

class _ShotDirectionSheetState extends State<ShotDirectionSheet> {
  static const _zones = <({String label, int center})>[
    (label: 'Straight', center: 0),
    (label: 'Mid-Wicket', center: 45),
    (label: 'Square Leg', center: 90),
    (label: 'Fine Leg', center: 135),
    (label: 'Long On', center: 180),
    (label: 'Third Man', center: 225),
    (label: 'Point', center: 270),
    (label: 'Cover', center: 315),
  ];

  /// Angle under the pointer while hovering (null = no hover).
  double? _hoverAngle;

  /// The currently picked shot (set on tap/drag, submitted on release).
  double? _pickedAngle;

  String zoneFor(double angle) {
    final normalized = ((angle % 360) + 360) % 360;
    for (final z in _zones) {
      var delta = (normalized - z.center).abs();
      if (delta > 180) delta = 360 - delta;
      if (delta <= 22.5) return z.label;
    }
    return 'Straight';
  }

  double _angleAt(Offset local, Offset center) {
    final dx = local.dx - center.dx;
    final dy = center.dy - local.dy; // map y grows downward
    final angle = math.atan2(dx, dy) * 180 / math.pi;
    return (angle + 360) % 360;
  }

  void _submit(ScoringControlLoaded control, int runs, double? degrees) {
    final ball = <String, dynamic>{
      'runs': runs,
      if (degrees != null) 'shot_direction': degrees.round(),
      if (!control.playerTrackingDisabled) ...{
        if (control.strikerId != null) 'batsman_id': control.strikerId!,
        if (control.nonStrikerId != null)
          'non_striker_id': control.nonStrikerId!,
        if (control.bowlerId != null) 'bowler_id': control.bowlerId!,
      },
    };

    context.read<LiveScoreBloc>().add(SubmitBall(ball));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final control = context.read<ScoringControlBloc>().state;
    if (control is! ScoringControlLoaded ||
        control.pendingBoundaryRuns == null) {
      return const SizedBox.shrink();
    }

    final runs = control.pendingBoundaryRuns!;
    final accent = runs == 4 ? CricketColors.runFour : CricketColors.runSix;
    final pickedZone = _pickedAngle == null ? null : zoneFor(_pickedAngle!);

    return Container(
      decoration: const BoxDecoration(
        color: CricketColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            runs == 4
                ? 'FOUR! — tap the map for direction'
                : 'SIX! — tap the map for direction',
            style: const TextStyle(
              color: CricketColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tap or drag on the ground map — the zone is fetched automatically.',
            style: TextStyle(color: CricketColors.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 16),

          // Interactive mini ground map.
          LayoutBuilder(
            builder: (context, constraints) {
              final side = constraints.maxWidth;
              final center = Offset(side / 2, side / 2 * 0.92);
              return MouseRegion(
                onHover: (event) => setState(
                  () => _hoverAngle = _angleAt(event.localPosition, center),
                ),
                onExit: (_) => setState(() => _hoverAngle = null),
                child: GestureDetector(
                  onTapDown: (details) => setState(
                    () =>
                        _pickedAngle = _angleAt(details.localPosition, center),
                  ),
                  onPanUpdate: (details) => setState(
                    () =>
                        _pickedAngle = _angleAt(details.localPosition, center),
                  ),
                  onTapUp: (_) {
                    if (_pickedAngle != null) {
                      _submit(control, runs, _pickedAngle);
                    }
                  },
                  child: SizedBox(
                    height: side * 0.78,
                    child: CustomPaint(
                      painter: _WagonMapPainter(
                        zones: _zones,
                        hoverAngle: _hoverAngle,
                        pickedAngle: _pickedAngle,
                        accent: accent,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  pickedZone != null
                      ? 'Selected: $pickedZone (${_pickedAngle!.round()}°) — release to confirm'
                      : _hoverAngle != null
                      ? 'Under cursor: ${zoneFor(_hoverAngle!)} (${_hoverAngle!.round()}°)'
                      : 'Hover to read zones · tap to pick',
                  style: TextStyle(
                    color: pickedZone != null
                        ? accent
                        : CricketColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
              if (_pickedAngle != null)
                TextButton(
                  onPressed: () => _submit(control, runs, _pickedAngle),
                  child: Text(
                    'CONFIRM ${runs == 4 ? 'FOUR' : 'SIX'}',
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CricketColors.textSecondary,
                    side: const BorderSide(color: CricketColors.textTertiary),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.skip_next, size: 16),
                  label: const Text('SKIP'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CricketColors.textSecondary,
                  ),
                  onPressed: () => _submit(control, runs, null),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Paints the oval ground, zone wedges, the pitch and the live cursor /
/// picked marker.
class _WagonMapPainter extends CustomPainter {
  final List<({String label, int center})> zones;
  final double? hoverAngle;
  final double? pickedAngle;
  final Color accent;

  const _WagonMapPainter({
    required this.zones,
    required this.hoverAngle,
    required this.pickedAngle,
    required this.accent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 * 0.92);
    final rx = size.width * 0.42;
    final ry = size.height * 0.44;
    final radius = math.min(rx, ry);

    Offset pointFor(double angle, [double scale = 1.0]) {
      final rad = angle * math.pi / 180;
      return Offset(
        center.dx + rx * scale * math.sin(rad),
        center.dy - ry * scale * math.cos(rad),
      );
    }

    // Zone wedges.
    for (final zone in zones) {
      final active = _activeZone(zone.label);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = active
            ? accent.withOpacity(0.35)
            : Colors.white.withOpacity(0.04);
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCenter(center: center, width: rx * 2, height: ry * 2),
          // Canvas 0 rad = east; cricket 0° = up ⇒ subtract 90°.
          _radians(zone.center - 22.5 - 90),
          _radians(45),
          false,
        )
        ..close();
      canvas.drawPath(path, paint);
    }

    // Boundary oval.
    canvas.drawOval(
      Rect.fromCenter(center: center, width: rx * 2, height: ry * 2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withOpacity(0.5),
    );

    // Pitch (batter at the bottom end).
    final pitch = Paint()..color = Colors.white.withOpacity(0.18);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + ry - 30),
        width: 10,
        height: 60,
      ),
      pitch,
    );
    canvas.drawCircle(center, 3, Paint()..color = Colors.white);

    // Zone labels.
    for (final zone in zones) {
      final p = pointFor(zone.center.toDouble(), 0.62);
      final painter = TextPainter(
        text: TextSpan(
          text: zone.label,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, p - Offset(painter.width / 2, painter.height / 2));
    }

    // Marker for the picked shot.
    if (pickedAngle != null) {
      final p = pointFor(pickedAngle!, 0.82);
      canvas.drawLine(
        center,
        p,
        Paint()
          ..color = accent
          ..strokeWidth = 3,
      );
      canvas.drawCircle(
        p,
        radius * 0.09,
        Paint()..color = accent.withOpacity(0.25),
      );
      canvas.drawCircle(p, radius * 0.035, Paint()..color = accent);
    }

    // Hover cursor.
    if (hoverAngle != null) {
      final p = pointFor(hoverAngle!);
      canvas.drawCircle(
        p,
        5,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = Colors.white,
      );
    }
  }

  bool _activeZone(String label) {
    if (pickedAngle != null) return _zoneFor(pickedAngle!) == label;
    if (hoverAngle != null) return _zoneFor(hoverAngle!) == label;
    return false;
  }

  String _zoneFor(double angle) {
    final normalized = ((angle % 360) + 360) % 360;
    for (final z in zones) {
      var delta = (normalized - z.center).abs();
      if (delta > 180) delta = 360 - delta;
      if (delta <= 22.5) return z.label;
    }
    return 'Straight';
  }

  /// Maps the cricket convention to canvas arc angles (0° = up).
  double _radians(double degrees) => degrees * math.pi / 180;

  @override
  bool shouldRepaint(covariant _WagonMapPainter oldDelegate) =>
      oldDelegate.hoverAngle != hoverAngle ||
      oldDelegate.pickedAngle != pickedAngle ||
      oldDelegate.accent != accent;
}

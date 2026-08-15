import 'package:flutter/material.dart';
import 'package:trace_odd/shared/theme/cricket_colors.dart';

import '../../data/models/cricket_models.dart';

/// Phase 4 — boundary/wicket celebration overlay.
///
/// Watches `lastBallResult` on the incoming snapshot; when a boundary
/// (4 / 6) or wicket is recorded, a short scale+fade banner plays over
/// the video area. Animation is controller-driven via AnimatedBuilder —
/// no setState anywhere.
class BoundaryCelebration extends StatefulWidget {
  final LiveScoreSnapshot? score;

  const BoundaryCelebration({super.key, required this.score});

  @override
  State<BoundaryCelebration> createState() => _BoundaryCelebrationState();
}

class _BoundaryCelebrationState extends State<BoundaryCelebration>
    with SingleTickerProviderStateMixin {
  static const _wicketTypes = [
    'BOWLED',
    'CAUGHT',
    'LBW',
    'RUN_OUT',
    'STUMPED',
    'HIT_WICKET',
  ];

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  String _text = '';
  Color _color = CricketColors.complete;

  @override
  void didUpdateWidget(BoundaryCelebration oldWidget) {
    super.didUpdateWidget(oldWidget);

    final result = widget.score?.lastBallResult;
    final previous = oldWidget.score?.lastBallResult;
    if (result == null || result.isEmpty || result == previous) {
      return;
    }

    if (result == '4') {
      _text = 'FOUR!';
      _color = CricketColors.runFour;
    } else if (result == '6') {
      _text = 'SIX!';
      _color = CricketColors.runSix;
    } else if (_wicketTypes.contains(result)) {
      _text = 'WICKET!';
      _color = CricketColors.wicket;
    } else {
      return;
    }

    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        if (t == 0.0 || _text.isEmpty) {
          return const SizedBox.shrink();
        }

        // Pop in fast, hold, then fade out.
        final opacity = t < 0.15
            ? (t / 0.15)
            : t > 0.75
            ? (1 - (t - 0.75) / 0.25)
            : 1.0;
        final scale = 0.8 + 0.4 * (t < 0.2 ? t / 0.2 : 1.0);

        return IgnorePointer(
          child: Center(
            child: Opacity(
              opacity: opacity.clamp(0.0, 1.0),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _color.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: _color.withOpacity(0.5),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    _text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

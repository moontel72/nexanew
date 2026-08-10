import 'package:flutter/material.dart';
import 'package:trace_odd/shared/theme/cricket_colors.dart';

import '../../data/models/cricket_models.dart';

/// A [CustomPainter] that renders a 2D top-down cricket field
/// (elliptical) with player positions plotted as circles.
///
/// Each player position includes a rating badge — a colored
/// circle with the rating number inside.  The field is green
/// with a central pitch strip.
///
/// Intended for use in Best XI / team lineup screens.
class FieldOverlayPainter extends CustomPainter {
  final List<BestXiPlayer> players;
  final Color grassColor;
  final Color pitchColor;
  final Color boundaryColor;

  FieldOverlayPainter({
    required this.players,
    this.grassColor = CricketColors.fieldGrass,
    this.pitchColor = CricketColors.pitchBrown,
    this.boundaryColor = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rx = size.width / 2 - 12; // horizontal radius
    final ry = size.height / 2 - 12; // vertical radius

    // ── Field ellipse ─────────────────────────────────────
    final fieldPaint = Paint()
      ..color = grassColor
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: center, width: rx * 2, height: ry * 2),
      fieldPaint,
    );

    // ── Boundary ring ─────────────────────────────────────
    final boundaryPaint = Paint()
      ..color = boundaryColor.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawOval(
      Rect.fromCenter(center: center, width: rx * 2, height: ry * 2),
      boundaryPaint,
    );

    // ── Inner 30-yard circle ──────────────────────────────
    final innerPaint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawOval(
      Rect.fromCenter(center: center, width: rx * 1.1, height: ry * 1.1),
      innerPaint,
    );

    // ── Pitch strip ───────────────────────────────────────
    final pitchW = rx * 0.04;
    final pitchH = ry * 0.55;
    final pitchRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: pitchW, height: pitchH),
      const Radius.circular(2),
    );
    canvas.drawRRect(pitchRect, Paint()..color = pitchColor);

    // ── Crease lines ──────────────────────────────────────
    final creasePaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(center.dx - pitchW, center.dy - ry * 0.08),
      Offset(center.dx + pitchW, center.dy - ry * 0.08),
      creasePaint,
    );
    canvas.drawLine(
      Offset(center.dx - pitchW, center.dy + ry * 0.08),
      Offset(center.dx + pitchW, center.dy + ry * 0.08),
      creasePaint,
    );

    // ── Player positions ──────────────────────────────────
    for (final player in players) {
      _drawPlayer(canvas, center, rx, ry, player);
    }
  }

  // ----------------------------------------------------------
  // Helpers
  // ----------------------------------------------------------

  void _drawPlayer(
    Canvas canvas,
    Offset center,
    double rx,
    double ry,
    BestXiPlayer player,
  ) {
    // Map normalized [0–1] coords to field ellipse
    final px = center.dx + (player.x - 0.5) * rx * 2;
    final py = center.dy + (player.y - 0.5) * ry * 2;
    final pos = Offset(px, py);

    final rating = player.rating ?? 0;

    // Player dot
    final dotColor = _roleColor(player.playerRole);
    canvas.drawCircle(pos, 8, Paint()..color = dotColor);

    // White border
    canvas.drawCircle(
      pos,
      9,
      Paint()
        ..color = Colors.white.withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Rating badge
    if (rating > 0) {
      final badgeColor = _ratingColor(rating);
      final badgeRadius = 11.0;
      final badgeOffset = Offset(pos.dx + 12, pos.dy - 12);

      canvas.drawCircle(badgeOffset, badgeRadius, Paint()..color = badgeColor);
      canvas.drawCircle(
        badgeOffset,
        badgeRadius,
        Paint()
          ..color = Colors.white.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );

      // Rating number
      final tp = TextPainter(
        text: TextSpan(
          text: rating.toStringAsFixed(
            rating == rating.roundToDouble() ? 0 : 1,
          ),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(badgeOffset.dx - tp.width / 2, badgeOffset.dy - tp.height / 2),
      );
    }

    // Player name below the dot
    final nameTp = TextPainter(
      text: TextSpan(
        text: player.playerName,
        style: TextStyle(
          color: Colors.white.withOpacity(0.85),
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: 60);

    final nameX = pos.dx - nameTp.width / 2;
    final nameY = pos.dy + 14;
    // Draw subtle background for readability
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          nameX - 3,
          nameY - 1,
          nameTp.width + 6,
          nameTp.height + 2,
        ),
        const Radius.circular(3),
      ),
      Paint()..color = Colors.black54,
    );
    nameTp.paint(canvas, Offset(nameX, nameY));
  }

  Color _roleColor(String? role) {
    switch (role?.toLowerCase()) {
      case 'batsman':
        return CricketColors.roleBatsman;
      case 'bowler':
        return CricketColors.roleBowler;
      case 'all-rounder':
        return CricketColors.roleAllRounder;
      case 'wicket-keeper':
        return CricketColors.roleWicketKeeper;
      default:
        return CricketColors.textTertiary;
    }
  }

  Color _ratingColor(double rating) {
    if (rating >= 90) return CricketColors.ratingGold;
    if (rating >= 80) return CricketColors.ratingGreen;
    if (rating >= 70) return CricketColors.ratingBlue;
    return CricketColors.ratingGrey;
  }

  @override
  bool shouldRepaint(covariant FieldOverlayPainter oldDelegate) =>
      players != oldDelegate.players;
}

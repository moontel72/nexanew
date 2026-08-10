import 'package:flutter/material.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/features/cricket/data/models/cricket_models.dart';

class BestXiPage extends StatelessWidget {
  final BestXiModel bestXi;
  const BestXiPage({super.key, required this.bestXi});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: Text(bestXi.teamLabel),
        backgroundColor: const Color(0xFF1A1E31),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _TeamFilterBar(),
          Expanded(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 2.0,
              child: CustomPaint(
                size: const Size(double.infinity, 500),
                painter: _FieldOverlayPainter(players: bestXi.selections),
              ),
            ),
          ),
          _PlayerLegend(players: bestXi.selections),
        ],
      ),
    );
  }
}

class _TeamFilterBar extends StatefulWidget {
  @override
  State<_TeamFilterBar> createState() => _TeamFilterBarState();
}

class _TeamFilterBarState extends State<_TeamFilterBar> {
  int _selected = 0;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: ['All Players', 'Team A', 'Team B']
          .asMap()
          .entries
          .map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(
                  e.value,
                  style: TextStyle(
                    color: _selected == e.key ? Colors.white : Colors.grey,
                  ),
                ),
                selected: _selected == e.key,
                selectedColor: AppColors.secondary,
                backgroundColor: const Color(0xFF1A1E31),
                onSelected: (_) => setState(() => _selected = e.key),
              ),
            ),
          )
          .toList(),
    ),
  );
}

class _PlayerLegend extends StatelessWidget {
  final List<BestXiPlayer> players;
  const _PlayerLegend({required this.players});

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(maxHeight: 150),
    child: ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: players.length,
      itemBuilder: (_, i) => ListTile(
        dense: true,
        leading: CircleAvatar(
          radius: 14,
          backgroundColor: AppColors.secondary,
          child: Text(
            '${i + 1}',
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ),
        title: Text(
          players[i].playerName,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
        subtitle: Text(
          players[i].positionName,
          style: const TextStyle(color: Colors.grey, fontSize: 11),
        ),
        trailing: players[i].rating != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  players[i].rating!.toStringAsFixed(1),
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
      ),
    ),
  );
}

class _FieldOverlayPainter extends CustomPainter {
  final List<BestXiPlayer> players;
  _FieldOverlayPainter({required this.players});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw grass
    final grass = Paint()..color = const Color(0xFF2D5A27);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), grass);

    // Draw elliptical field boundary
    final boundary = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final fieldRect = Rect.fromLTWH(20, 40, size.width - 40, size.height - 80);
    canvas.drawOval(fieldRect, boundary);

    // Draw pitch strip (30-yard circle)
    final pitchPaint = Paint()..color = const Color(0xFFC4A35A);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: 60,
        height: 4,
      ),
      pitchPaint,
    );

    // Inner circle
    final innerCircle = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.3,
      innerCircle,
    );

    // Draw players
    for (final player in players) {
      final px = player.x * size.width;
      final py = 40 + player.y * (size.height - 80);

      // Player dot
      final dot = Paint()
        ..color = player.teamShort == 'T1' ? Colors.blue : Colors.red;
      canvas.drawCircle(Offset(px, py), 12, dot);

      // White outline
      final outline = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(Offset(px, py), 12, outline);

      // Rating badge
      if (player.rating != null) {
        final badgeBg = Paint()..color = AppColors.accent;
        canvas.drawCircle(Offset(px + 16, py - 14), 11, badgeBg);

        final tp = TextPainter(
          text: TextSpan(
            text: player.rating!.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(
          canvas,
          Offset(px + 16 - tp.width / 2, py - 14 - tp.height / 2),
        );
      }

      // Position name
      final tp = TextPainter(
        text: TextSpan(
          text: player.positionName,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 8),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(px - tp.width / 2, py + 16));
    }
  }

  @override
  bool shouldRepaint(covariant _FieldOverlayPainter old) =>
      old.players != players;
}

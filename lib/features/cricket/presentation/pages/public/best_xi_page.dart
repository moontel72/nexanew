import 'package:flutter/material.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/theme/cricket_colors.dart';
import 'package:trace_odd/features/cricket/data/models/cricket_models.dart';
import 'package:trace_odd/features/cricket/presentation/widgets/field_overlay_painter.dart';

class BestXiPage extends StatelessWidget {
  final BestXiModel bestXi;
  const BestXiPage({super.key, required this.bestXi});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CricketColors.background,
      appBar: AppBar(
        title: Text(bestXi.teamLabel),
        backgroundColor: CricketColors.surface,
        foregroundColor: CricketColors.textPrimary,
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
                painter: FieldOverlayPainter(players: bestXi.selections),
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
                    color: _selected == e.key
                        ? CricketColors.textPrimary
                        : CricketColors.textSecondary,
                  ),
                ),
                selected: _selected == e.key,
                selectedColor: AppColors.secondary,
                backgroundColor: CricketColors.surface,
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
            style: TextStyle(color: CricketColors.textPrimary, fontSize: 11),
          ),
        ),
        title: Text(
          players[i].playerName,
          style: TextStyle(color: CricketColors.textPrimary, fontSize: 13),
        ),
        subtitle: Text(
          players[i].positionName,
          style: TextStyle(color: CricketColors.textSecondary, fontSize: 11),
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

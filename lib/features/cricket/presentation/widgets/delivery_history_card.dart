import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/shared/theme/cricket_colors.dart';

import '../blocs/correction/correction_bloc.dart';
import '../blocs/scoring_control/scoring_control_bloc.dart';
import '../../data/models/cricket_models.dart';
import 'ball_badge.dart';
import 'player_picker_sheet.dart';

/// Tappable delivery history (Phase 2 correction interface). Every row
/// carries the delivery's unique ball_id — tapping it opens the correction
/// sheet; the backend recomputes everything forward from the edited point.
class DeliveryHistoryCard extends StatelessWidget {
  const DeliveryHistoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CorrectionBloc, CorrectionState>(
      listener: (context, state) {
        final notice = state is CorrectionLoaded ? state.notice : null;
        if (notice == null || notice.isEmpty) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(notice),
              backgroundColor: notice.contains('Failed')
                  ? CricketColors.wicket
                  : CricketColors.complete,
            ),
          );
        context.read<CorrectionBloc>().add(ClearCorrectionNotice());
      },
      child: BlocBuilder<CorrectionBloc, CorrectionState>(
        builder: (context, state) {
          final deliveries = state is CorrectionLoaded
              ? state.deliveries
              : const <DeliveryModel>[];

          return Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CricketColors.inputFill,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'BALL HISTORY — TAP TO CORRECT',
                      style: TextStyle(
                        color: CricketColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Spacer(),
                    if (state is CorrectionLoading)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: CricketColors.complete,
                        ),
                      )
                    else
                      IconButton(
                        icon: const Icon(
                          Icons.refresh,
                          color: CricketColors.textSecondary,
                          size: 18,
                        ),
                        tooltip: 'Refresh history',
                        onPressed: () => context.read<CorrectionBloc>().add(
                          RefreshDeliveries(),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (deliveries.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'No deliveries recorded yet.',
                      style: TextStyle(
                        color: CricketColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  )
                else
                  ...deliveries
                      .take(30)
                      .map(
                        (d) => _DeliveryRow(
                          delivery: d,
                          onTap: () => _openCorrectionSheet(context, d),
                        ),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openCorrectionSheet(BuildContext context, DeliveryModel delivery) {
    final correctionBloc = context.read<CorrectionBloc>();
    final controlBloc = context.read<ScoringControlBloc>();

    correctionBloc.add(OpenEditBall(delivery.ballId));
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: correctionBloc),
          BlocProvider.value(value: controlBloc),
        ],
        child: const CorrectionSheet(),
      ),
    ).whenComplete(() {
      if (!correctionBloc.isClosed) correctionBloc.add(CloseEditBall());
    });
  }
}

class _DeliveryRow extends StatelessWidget {
  final DeliveryModel delivery;
  final VoidCallback onTap;

  const _DeliveryRow({required this.delivery, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Player names come from the scoring-control state (shared player list).
    final control = context.read<ScoringControlBloc>().state;
    String? batterName;
    String? bowlerName;
    if (control is ScoringControlLoaded) {
      batterName = control.playerById(delivery.batterId)?.name;
      bowlerName = control.playerById(delivery.bowlerId)?.name;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(width: 30, child: BallBadge(ball: delivery.recentBall)),
            const SizedBox(width: 10),
            SizedBox(
              width: 34,
              child: Text(
                delivery.label,
                style: const TextStyle(
                  color: CricketColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                [
                  batterName ?? 'Batter',
                  'to',
                  bowlerName ?? 'Bowler',
                ].join(' '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: CricketColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
            const Icon(
              Icons.edit_outlined,
              size: 16,
              color: CricketColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Correction sheet (BLoC-driven edit form)
// ─────────────────────────────────────────────────────────────

class CorrectionSheet extends StatelessWidget {
  const CorrectionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CorrectionBloc, CorrectionState>(
      builder: (context, state) {
        if (state is! CorrectionLoaded ||
            state.editingBallId == null ||
            state.editingDelivery == null) {
          return const SizedBox.shrink();
        }

        final s = state;
        final delivery = s.editingDelivery!;
        final control = context.read<ScoringControlBloc>().state;
        final battingPlayers = control is ScoringControlLoaded
            ? control.battingPlayers
            : const <PlayerModel>[];
        final bowlingPlayers = control is ScoringControlLoaded
            ? control.bowlingPlayers
            : const <PlayerModel>[];

        return Container(
          decoration: const BoxDecoration(
            color: CricketColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Correct ball ${delivery.label}',
                  style: const TextStyle(
                    color: CricketColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _EditRow(
                  label: 'RUNS',
                  child: DropdownButtonFormField<int>(
                    value: s.editRuns,
                    dropdownColor: const Color(0xFF0F2936),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Color(0xFF0F2936),
                    ),
                    items: List.generate(
                      8,
                      (r) => DropdownMenuItem<int>(
                        value: r,
                        child: Text('$r run(s)'),
                      ),
                    ),
                    onChanged: (v) =>
                        context.read<CorrectionBloc>().add(SetEditRuns(v ?? 0)),
                  ),
                ),
                const SizedBox(height: 12),
                _Label('EXTRAS'),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('None', style: TextStyle(fontSize: 12)),
                      selected: s.editExtrasType == null,
                      backgroundColor: CricketColors.inputFill,
                      selectedColor: CricketColors.textSecondary,
                      labelStyle: const TextStyle(color: Colors.white),
                      onSelected: (_) => context.read<CorrectionBloc>().add(
                        const SetEditExtrasType(null),
                      ),
                    ),
                    ...['wide', 'no_ball', 'bye', 'leg_bye'].map((t) {
                      return ChoiceChip(
                        label: Text(
                          t.replaceAll('_', ' ').toUpperCase(),
                          style: const TextStyle(fontSize: 12),
                        ),
                        selected: s.editExtrasType == t,
                        backgroundColor: CricketColors.inputFill,
                        selectedColor: const Color(0xFFF59E0B),
                        labelStyle: const TextStyle(color: Colors.white),
                        onSelected: (_) => context.read<CorrectionBloc>().add(
                          SetEditExtrasType(t),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: s.editIsWicket,
                  activeColor: CricketColors.wicket,
                  title: const Text(
                    'WICKET',
                    style: TextStyle(
                      color: CricketColors.textPrimary,
                      fontSize: 12,
                      letterSpacing: 1.1,
                    ),
                  ),
                  contentPadding: EdgeInsets.zero,
                  onChanged: (v) =>
                      context.read<CorrectionBloc>().add(SetEditIsWicket(v)),
                ),
                if (s.editIsWicket) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        [
                          'bowled',
                          'caught',
                          'lbw',
                          'run_out',
                          'stumped',
                          'hit_wicket',
                        ].map((t) {
                          return ChoiceChip(
                            label: Text(
                              t.replaceAll('_', ' ').toUpperCase(),
                              style: const TextStyle(fontSize: 12),
                            ),
                            selected: s.editWicketType == t,
                            backgroundColor: CricketColors.inputFill,
                            selectedColor: CricketColors.wicket,
                            labelStyle: const TextStyle(color: Colors.white),
                            onSelected: (_) => context
                                .read<CorrectionBloc>()
                                .add(SetEditWicketType(t)),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 12),
                  _EditRow(
                    label: 'DISMISSED BATTER',
                    child: _PlayerPickerButton(
                      name: _nameOf(battingPlayers, s.editDismissedId),
                      onTap: () => _pickPlayer(
                        context,
                        title: 'Dismissed Batter',
                        players: battingPlayers,
                        selectedId: s.editDismissedId,
                        onPicked: (id) => context.read<CorrectionBloc>().add(
                          SetEditDismissed(id),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _EditRow(
                    label: 'NEXT BATTER',
                    child: _PlayerPickerButton(
                      name: _nameOf(battingPlayers, s.editNextBatterId),
                      onTap: () => _pickPlayer(
                        context,
                        title: 'Next Batter',
                        players: battingPlayers,
                        selectedId: s.editNextBatterId,
                        onPicked: (id) => context.read<CorrectionBloc>().add(
                          SetEditNextBatter(id),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                _EditRow(
                  label: 'BATTER',
                  child: _PlayerPickerButton(
                    name: _nameOf(battingPlayers, s.editBatterId),
                    onTap: () => _pickPlayer(
                      context,
                      title: 'Batter (striker)',
                      players: battingPlayers,
                      selectedId: s.editBatterId,
                      onPicked: (id) =>
                          context.read<CorrectionBloc>().add(SetEditBatter(id)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _EditRow(
                  label: 'BOWLER',
                  child: _PlayerPickerButton(
                    name: _nameOf(bowlingPlayers, s.editBowlerId),
                    onTap: () => _pickPlayer(
                      context,
                      title: 'Bowler',
                      players: bowlingPlayers,
                      selectedId: s.editBowlerId,
                      onPicked: (id) =>
                          context.read<CorrectionBloc>().add(SetEditBowler(id)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: CricketColors.wicket,
                          side: const BorderSide(color: CricketColors.wicket),
                        ),
                        onPressed: s.saving
                            ? null
                            : () => _confirmDelete(context),
                        child: const Text('DELETE'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: CricketColors.textSecondary,
                          side: const BorderSide(
                            color: CricketColors.textTertiary,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('CANCEL'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: s.saving
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check, size: 16),
                        label: const Text('SAVE'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CricketColors.complete,
                        ),
                        onPressed: s.saving ? null : () => _save(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _save(BuildContext context) {
    context.read<CorrectionBloc>().add(SaveEditBall());
    Navigator.pop(context);
  }

  void _confirmDelete(BuildContext context) {
    final state = context.read<CorrectionBloc>().state;
    final ballId = state is CorrectionLoaded ? state.editingBallId : null;
    if (ballId == null) return;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CricketColors.surface,
        title: const Text(
          'Delete this ball?',
          style: TextStyle(color: CricketColors.textPrimary),
        ),
        content: const Text(
          'The delivery will be removed and the score recomputed from the remaining balls. This cannot be undone from the history list.',
          style: TextStyle(color: CricketColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: CricketColors.wicket),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<CorrectionBloc>().add(DeleteBall(ballId));
              Navigator.pop(context); // close the correction sheet too
            },
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickPlayer(
    BuildContext context, {
    required String title,
    required List<PlayerModel> players,
    String? selectedId,
    required void Function(String?) onPicked,
  }) async {
    final id = await showPlayerPickerSheet(
      context,
      title: title,
      players: players,
      selectedId: selectedId,
    );
    if (id != null) onPicked(id);
  }

  static String? _nameOf(List<PlayerModel> players, String? id) {
    if (id == null) return null;
    for (final p in players) {
      if (p.id == id) return p.name;
    }
    return null;
  }
}

class _EditRow extends StatelessWidget {
  final String label;
  final Widget child;

  const _EditRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_Label(label), const SizedBox(height: 6), child],
    );
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: CricketColors.textSecondary,
        fontSize: 10,
        letterSpacing: 1.1,
      ),
    );
  }
}

class _PlayerPickerButton extends StatelessWidget {
  final String? name;
  final VoidCallback onTap;

  const _PlayerPickerButton({required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: CricketColors.textPrimary,
        side: const BorderSide(color: CricketColors.textTertiary),
        alignment: Alignment.centerLeft,
      ),
      onPressed: onTap,
      child: Row(
        children: [
          Expanded(
            child: Text(
              name ?? '— tap to select —',
              style: TextStyle(
                color: name != null
                    ? CricketColors.textPrimary
                    : CricketColors.textTertiary,
                fontSize: 13,
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: CricketColors.textSecondary,
            size: 18,
          ),
        ],
      ),
    );
  }
}

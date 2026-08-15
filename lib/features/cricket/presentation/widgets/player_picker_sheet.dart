import 'package:flutter/material.dart';
import 'package:trace_odd/shared/theme/cricket_colors.dart';

import '../../data/models/cricket_models.dart';

/// Generic player picker bottom sheet — fully stateless (returns the chosen
/// player id via `Navigator.pop`; the caller dispatches the BLoC event).
Future<String?> showPlayerPickerSheet(
  BuildContext context, {
  required String title,
  required List<PlayerModel> players,
  String? selectedId,
  bool showRoles = true,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _PlayerPickerSheet(
      title: title,
      players: players,
      selectedId: selectedId,
      showRoles: showRoles,
    ),
  );
}

class _PlayerPickerSheet extends StatelessWidget {
  final String title;
  final List<PlayerModel> players;
  final String? selectedId;
  final bool showRoles;

  const _PlayerPickerSheet({
    required this.title,
    required this.players,
    this.selectedId,
    required this.showRoles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: CricketColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: CricketColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: CricketColors.textSecondary,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(color: CricketColors.textTertiary, height: 1),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                if (players.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No players available. Register players first.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: CricketColors.textSecondary),
                    ),
                  )
                else
                  ...players.map((p) {
                    final selected = p.id == selectedId;
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: selected
                            ? CricketColors.complete
                            : CricketColors.inputFill,
                        child: Icon(
                          Icons.person,
                          size: 16,
                          color: selected
                              ? Colors.white
                              : CricketColors.textSecondary,
                        ),
                      ),
                      title: Text(
                        p.name,
                        style: const TextStyle(
                          color: CricketColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: showRoles
                          ? Text(
                              '${p.roleDisplay} · ${p.jerseyNumber ?? '—'}',
                              style: const TextStyle(
                                color: CricketColors.textSecondary,
                                fontSize: 11,
                              ),
                            )
                          : null,
                      trailing: selected
                          ? const Icon(
                              Icons.check_circle,
                              color: CricketColors.complete,
                              size: 20,
                            )
                          : null,
                      onTap: () => Navigator.pop(context, p.id),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

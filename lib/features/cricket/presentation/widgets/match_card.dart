import 'package:flutter/material.dart';

import '../../data/models/cricket_models.dart';
import 'cricket_lookups.dart';

/// Section header format: `2026-08-20`.
String formatMatchDate(DateTime dt) =>
    '${dt.year.toString().padLeft(4, '0')}-'
    '${dt.month.toString().padLeft(2, '0')}-'
    '${dt.day.toString().padLeft(2, '0')}';

/// Kickoff format: `14:30`.
String formatMatchTime(DateTime dt) =>
    '${dt.hour.toString().padLeft(2, '0')}:'
    '${dt.minute.toString().padLeft(2, '0')}';

/// A single fixture row used by the Fixture Scheduler list.
class MatchCard extends StatelessWidget {
  final MatchModel match;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onTap;

  const MatchCard({
    super.key,
    required this.match,
    this.onEdit,
    this.onDelete,
    this.onToggleStatus,
    this.onTap,
  });

  String get _teamALabel =>
      '${match.teamAShort ?? match.teamAName ?? 'TBD'} ${match.teamAName != null && match.teamAShort != null ? '· ${match.teamAName}' : ''}'
          .trim();

  String get _teamBLabel =>
      '${match.teamBShort ?? match.teamBName ?? 'TBD'} ${match.teamBName != null && match.teamBShort != null ? '· ${match.teamBName}' : ''}'
          .trim();

  String? get _venueLabel {
    if (match.groundName != null && match.groundName!.isNotEmpty) {
      final loc = match.groundLocation;
      return loc != null && loc.isNotEmpty
          ? '${match.groundName} · $loc'
          : match.groundName;
    }
    return match.venue;
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = match.status == 'scheduled' || match.status == 'cancelled';
    final scheduled = match.scheduledAt?.toLocal();

    return Card(
      color: const Color(0xFF0F2936),
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '$_teamALabel  vs  $_teamBLabel',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  StageChip(stage: match.stage ?? 'group_stage'),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  MatchStatusChip(status: match.status),
                  if (scheduled != null)
                    _MetaLine(
                      icon: Icons.access_time,
                      text:
                          '${formatMatchDate(scheduled)} · ${formatMatchTime(scheduled)}',
                    ),
                  if (_venueLabel != null && _venueLabel!.isNotEmpty)
                    _MetaLine(icon: Icons.location_on, text: _venueLabel!),
                  if (match.matchType != null)
                    _MetaLine(
                      icon: Icons.sports_cricket,
                      text:
                          '${cricketMatchTypeLabel(match.matchType!)} · ${match.oversPerSide} ov',
                    ),
                ],
              ),
              if (canEdit &&
                  (onEdit != null ||
                      onDelete != null ||
                      onToggleStatus != null))
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (onEdit != null)
                        TextButton.icon(
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Edit'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF3B82F6),
                          ),
                          onPressed: onEdit,
                        ),
                      if (onToggleStatus != null)
                        TextButton.icon(
                          icon: Icon(
                            match.status == 'cancelled'
                                ? Icons.event_available
                                : Icons.event_busy,
                            size: 16,
                          ),
                          label: Text(
                            match.status == 'cancelled' ? 'Re-open' : 'Cancel',
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFF59E0B),
                          ),
                          onPressed: onToggleStatus,
                        ),
                      if (onDelete != null)
                        TextButton.icon(
                          icon: const Icon(Icons.delete_outline, size: 16),
                          label: const Text('Delete'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFEF4444),
                          ),
                          onPressed: onDelete,
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: const Color(0xFFBDD8DB)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: Color(0xFFBDD8DB), fontSize: 12),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

/// Shared labels, colors, and badges for cricket match scheduling.
///
/// Single source of truth for stage, match-type, and status display so
/// list, forms, and generator sheets never duplicate this mapping.

const List<String> cricketStages = [
  'group_stage',
  'quarter_final',
  'semi_final',
  'final',
  'friendly_test',
];

const List<String> cricketMatchTypes = ['t20', 'odi', 'test', 't10', 'other'];

String cricketStageLabel(String stage) => switch (stage) {
  'group_stage' => 'Group Stage',
  'quarter_final' => 'Quarter-Final',
  'semi_final' => 'Semi-Final',
  'final' => 'Final',
  'friendly_test' => 'Friendly',
  _ => stage,
};

String cricketMatchTypeLabel(String type) => switch (type) {
  't20' => 'T20',
  'odi' => 'ODI',
  'test' => 'Test',
  't10' => 'T10',
  'other' => 'Custom',
  _ => type,
};

String cricketStatusLabel(String status) => switch (status) {
  'scheduled' => 'Scheduled',
  'toss_pending' => 'Toss Pending',
  'toss_done' => 'Toss Done',
  'in_progress' => 'Live',
  'innings_break' => 'Innings Break',
  'completed' => 'Completed',
  'abandoned' => 'Abandoned',
  'cancelled' => 'Cancelled',
  _ => status,
};

Color cricketStageColor(String stage) => switch (stage) {
  'quarter_final' => const Color(0xFF8B5CF6),
  'semi_final' => const Color(0xFFF59E0B),
  'final' => const Color(0xFFEF4444),
  'friendly_test' => const Color(0xFF64748B),
  _ => const Color(0xFF10B981),
};

Color cricketStatusColor(String status) => switch (status) {
  'in_progress' => const Color(0xFFEF4444),
  'completed' => const Color(0xFF10B981),
  'cancelled' => const Color(0xFF6B7280),
  'abandoned' => const Color(0xFFF59E0B),
  _ => const Color(0xFF3B82F6),
};

/// Shared dark form-field decoration for fixture scheduling forms.
InputDecoration cricketFieldDecoration(String label) => InputDecoration(
  labelText: label,
  labelStyle: const TextStyle(color: Color(0xFFBDD8DB)),
  filled: true,
  fillColor: const Color(0xFF0C1D2C),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: Color(0x20FFFFFF)),
  ),
);

class StageChip extends StatelessWidget {
  final String stage;
  const StageChip({super.key, required this.stage});

  @override
  Widget build(BuildContext context) {
    final color = cricketStageColor(stage);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        cricketStageLabel(stage),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class MatchStatusChip extends StatelessWidget {
  final String status;
  const MatchStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = cricketStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        cricketStatusLabel(status),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

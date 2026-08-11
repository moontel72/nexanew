import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/replay/replay_bloc.dart';
import '../../../data/models/replay_models.dart';
import 'package:trace_odd/shared/theme/cricket_colors.dart';
import 'package:trace_odd/shared/theme/colors.dart';

/// VAR Replay Console — instant event marking, annotation,
/// buffer trimming, slow-motion playback controls, and
/// public broadcast toggle.
class ManagerReplayPage extends StatefulWidget {
  final String matchId;
  final String matchTitle;
  const ManagerReplayPage({
    super.key,
    required this.matchId,
    required this.matchTitle,
  });

  @override
  State<ManagerReplayPage> createState() => _ManagerReplayPageState();
}

class _ManagerReplayPageState extends State<ManagerReplayPage> {
  bool _isLooping = false;
  double _playbackSpeed = 1.0;
  double _bufferBefore = 5000; // ms
  double _bufferAfter = 5000;

  @override
  void initState() {
    super.initState();
    context.read<ReplayBloc>().add(LoadReplayEvents(widget.matchId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CricketColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.matchTitle} — VAR Console',
          style: TextStyle(color: CricketColors.textPrimary),
        ),
        backgroundColor: CricketColors.surface,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            tooltip: 'Back to Dashboard',
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => context.read<ReplayBloc>().add(
              LoadReplayEvents(widget.matchId),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Video preview area
          _VideoPreviewSection(
            matchId: widget.matchId,
            speed: _playbackSpeed,
            isLooping: _isLooping,
          ),
          // Mark event button
          _MarkEventBar(matchId: widget.matchId),
          const Divider(color: Colors.white12),
          // Event list
          Expanded(child: _EventsList()),
        ],
      ),
      // Speed / loop overlay at bottom
      bottomNavigationBar: _ControlBar(
        speed: _playbackSpeed,
        isLooping: _isLooping,
        bufferBefore: _bufferBefore,
        bufferAfter: _bufferAfter,
        onSpeedChanged: (s) => setState(() => _playbackSpeed = s),
        onLoopToggled: () => setState(() => _isLooping = !_isLooping),
        onBufferChanged: (before, after) => setState(() {
          _bufferBefore = before;
          _bufferAfter = after;
        }),
      ),
    );
  }
}

// ─── Video Preview Section ────────────────────────────────────

class _VideoPreviewSection extends StatelessWidget {
  final String matchId;
  final double speed;
  final bool isLooping;
  const _VideoPreviewSection({
    required this.matchId,
    required this.speed,
    required this.isLooping,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReplayBloc, ReplayState>(
      builder: (ctx, state) {
        final hasClip =
            state is ReplayClipReady || state is ReplayClipPublished;
        return Container(
          height: 200,
          color: Colors.black,
          child: hasClip
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.play_circle_fill,
                        size: 48,
                        color: CricketColors.textPrimary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Replay Preview',
                        style: TextStyle(
                          color: CricketColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${speed}x ${isLooping ? "🔁 Looping" : ""}',
                        style: TextStyle(
                          color: CricketColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.videocam,
                        size: 48,
                        color: CricketColors.textSecondary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap Mark Event to capture timestamp',
                        style: TextStyle(
                          color: CricketColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

// ─── Mark Event Bar ────────────────────────────────────────────

class _MarkEventBar extends StatelessWidget {
  final String matchId;
  const _MarkEventBar({required this.matchId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _EventButton(
            icon: Icons.safety_check,
            label: 'Wicket',
            color: CricketColors.wicket,
            onTap: () => _showAnnotationModal(context, matchId, 'wicket'),
          ),
          _EventButton(
            icon: Icons.star,
            label: 'Boundary',
            color: CricketColors.runSix,
            onTap: () => _showAnnotationModal(context, matchId, 'boundary'),
          ),
          _EventButton(
            icon: Icons.gavel,
            label: 'Appeal',
            color: AppColors.warning,
            onTap: () => _showAnnotationModal(context, matchId, 'appeal'),
          ),
          _EventButton(
            icon: Icons.tv,
            label: 'Review',
            color: CricketColors.teamA,
            onTap: () => _showAnnotationModal(context, matchId, 'review'),
          ),
          _EventButton(
            icon: Icons.bookmark,
            label: 'Custom',
            color: CricketColors.textSecondary,
            onTap: () => _showAnnotationModal(context, matchId, 'custom'),
          ),
        ],
      ),
    );
  }

  void _showAnnotationModal(
    BuildContext context,
    String matchId,
    String eventType,
  ) {
    final controller = TextEditingController();
    final ts = DateTime.now().millisecondsSinceEpoch;

    showModalBottomSheet(
      context: context,
      backgroundColor: CricketColors.surface,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Mark ${eventType.replaceAll('_', ' ').toUpperCase()}',
              style: TextStyle(
                color: CricketColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              style: TextStyle(color: CricketColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Optional annotation...',
                hintStyle: TextStyle(color: CricketColors.placeholder),
                filled: true,
                fillColor: CricketColors.inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                ),
                onPressed: () {
                  context.read<ReplayBloc>().add(
                    MarkEvent(
                      matchId: matchId,
                      eventType: eventType,
                      frameTimestamp: ts,
                      annotation: controller.text.trim().isEmpty
                          ? null
                          : controller.text.trim(),
                    ),
                  );
                  Navigator.pop(ctx);
                },
                child: Text(
                  'MARK EVENT',
                  style: TextStyle(color: CricketColors.textPrimary),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _EventButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _EventButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: color, fontSize: 10)),
        ],
      ),
    ),
  );
}

// ─── Events List ───────────────────────────────────────────────

class _EventsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReplayBloc, ReplayState>(
      builder: (ctx, state) => switch (state) {
        ReplayLoading() => const Center(child: CircularProgressIndicator()),
        ReplayEventsLoaded(:final events) =>
          events.isEmpty
              ? Center(
                  child: Text(
                    'No events marked yet.\nTap a button above to mark.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: CricketColors.textSecondary),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: events.length,
                  itemBuilder: (_, i) => _EventTile(event: events[i]),
                ),
        ReplayClipReady(:final clip) => _ClipReadyCard(),
        ReplayError(:final message) => Center(
          child: Text(message, style: const TextStyle(color: Colors.red)),
        ),
        _ => Center(
          child: Text(
            'Loading replay console...',
            style: TextStyle(color: CricketColors.textSecondary),
          ),
        ),
      },
    );
  }
}

class _EventTile extends StatelessWidget {
  final ReplayEventModel event;
  const _EventTile({required this.event});

  IconData get _icon => switch (event.eventType) {
    'wicket' => Icons.safety_check,
    'boundary' => Icons.star,
    'appeal' => Icons.gavel,
    'review' => Icons.tv,
    _ => Icons.bookmark,
  };

  Color get _color => switch (event.eventType) {
    'wicket' => CricketColors.wicket,
    'boundary' => CricketColors.runSix,
    'appeal' => AppColors.warning,
    'review' => CricketColors.teamA,
    _ => CricketColors.textSecondary,
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      color: CricketColors.surface,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _color.withOpacity(0.2),
          child: Icon(_icon, color: _color, size: 18),
        ),
        title: Text(
          '${event.displayType} — ${event.formattedTimestamp}',
          style: TextStyle(
            color: CricketColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        subtitle: event.annotation != null
            ? Text(
                event.annotation!,
                style: TextStyle(
                  color: CricketColors.textSecondary,
                  fontSize: 11,
                ),
              )
            : null,
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: CricketColors.textSecondary,
            size: 18,
          ),
          color: CricketColors.surface,
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'clip',
              child: Text(
                'Create Clip',
                style: TextStyle(color: CricketColors.textPrimary),
              ),
            ),
            PopupMenuItem(
              value: 'annotate',
              child: Text(
                'Annotate',
                style: TextStyle(color: CricketColors.textPrimary),
              ),
            ),
          ],
          onSelected: (action) {
            if (action == 'clip') {
              _showClipDialog(context, event);
            } else if (action == 'annotate') {
              _showAnnotateDialog(context, event);
            }
          },
        ),
      ),
    );
  }

  void _showClipDialog(BuildContext context, ReplayEventModel event) {
    showDialog(
      context: context,
      builder: (ctx) => _ClipDialog(event: event),
    );
  }

  void _showAnnotateDialog(BuildContext context, ReplayEventModel event) {
    final ctrl = TextEditingController(text: event.annotation ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CricketColors.surface,
        title: Text(
          'Annotate Event',
          style: TextStyle(color: CricketColors.textPrimary),
        ),
        content: TextField(
          controller: ctrl,
          style: TextStyle(color: CricketColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter annotation...',
            hintStyle: TextStyle(color: CricketColors.placeholder),
            filled: true,
            fillColor: CricketColors.inputFill,
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ReplayBloc>().add(
                AnnotateEvent(event.id, ctrl.text),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _ClipReadyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 48, color: AppColors.secondary),
          const SizedBox(height: 12),
          Text(
            'Clip ready!',
            style: TextStyle(color: CricketColors.textPrimary, fontSize: 18),
          ),
          Text(
            'Preview above or publish to public.',
            style: TextStyle(color: CricketColors.textSecondary),
          ),
        ],
      ),
    ),
  );
}

class _ClipDialog extends StatefulWidget {
  final ReplayEventModel event;
  const _ClipDialog({required this.event});

  @override
  State<_ClipDialog> createState() => _ClipDialogState();
}

class _ClipDialogState extends State<_ClipDialog> {
  double _before = 5000;
  double _after = 5000;
  double _speed = 1.0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: CricketColors.surface,
      title: Text(
        'Create Replay Clip',
        style: TextStyle(color: CricketColors.textPrimary),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Event: ${widget.event.displayType} at ${widget.event.formattedTimestamp}',
            style: TextStyle(color: CricketColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Text(
            'Buffer Before: ${(_before / 1000).round()}s',
            style: TextStyle(color: CricketColors.textPrimary),
          ),
          Slider(
            value: _before,
            min: 2000,
            max: 30000,
            divisions: 14,
            activeColor: AppColors.secondary,
            onChanged: (v) => setState(() => _before = v),
          ),
          Text(
            'Buffer After: ${(_after / 1000).round()}s',
            style: TextStyle(color: CricketColors.textPrimary),
          ),
          Slider(
            value: _after,
            min: 2000,
            max: 30000,
            divisions: 14,
            activeColor: AppColors.secondary,
            onChanged: (v) => setState(() => _after = v),
          ),
          Text(
            'Speed: ${_speed}x',
            style: TextStyle(color: CricketColors.textPrimary),
          ),
          Slider(
            value: _speed,
            min: 0.25,
            max: 2.0,
            divisions: 7,
            activeColor: AppColors.accent,
            onChanged: (v) => setState(() => _speed = v),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
          onPressed: () {
            final matchId = widget.event.matchId;
            context.read<ReplayBloc>().add(
              CreateClip(
                matchId: matchId,
                eventId: widget.event.id,
                bufferBeforeMs: _before.round(),
                bufferAfterMs: _after.round(),
                playbackSpeed: _speed,
              ),
            );
            Navigator.pop(context);
          },
          child: Text(
            'Create Clip',
            style: TextStyle(color: CricketColors.textPrimary),
          ),
        ),
      ],
    );
  }
}

// ─── Bottom Control Bar ────────────────────────────────────────

class _ControlBar extends StatelessWidget {
  final double speed;
  final bool isLooping;
  final double bufferBefore;
  final double bufferAfter;
  final ValueChanged<double> onSpeedChanged;
  final VoidCallback onLoopToggled;
  final Function(double before, double after) onBufferChanged;

  const _ControlBar({
    required this.speed,
    required this.isLooping,
    required this.bufferBefore,
    required this.bufferAfter,
    required this.onSpeedChanged,
    required this.onLoopToggled,
    required this.onBufferChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: CricketColors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Slow motion speeds
          ...[0.25, 0.5, 0.75, 1.0].map(
            (s) => _SpeedChip(
              speed: s,
              isActive: speed == s,
              onTap: () => onSpeedChanged(s),
            ),
          ),
          const SizedBox(width: 8),
          // Loop toggle
          _LoopToggle(isActive: isLooping, onTap: onLoopToggled),
        ],
      ),
    );
  }
}

class _SpeedChip extends StatelessWidget {
  final double speed;
  final bool isActive;
  final VoidCallback onTap;
  const _SpeedChip({
    required this.speed,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? AppColors.secondary : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isActive ? AppColors.secondary : CricketColors.border,
        ),
      ),
      child: Text(
        '${speed}x',
        style: TextStyle(
          color: isActive
              ? CricketColors.textPrimary
              : CricketColors.textSecondary,
          fontSize: 12,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    ),
  );
}

class _LoopToggle extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;
  const _LoopToggle({required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? AppColors.accent : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isActive ? AppColors.accent : CricketColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.repeat,
            size: 14,
            color: isActive
                ? CricketColors.textPrimary
                : CricketColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            'Loop',
            style: TextStyle(
              color: isActive
                  ? CricketColors.textPrimary
                  : CricketColors.textSecondary,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    ),
  );
}

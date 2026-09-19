import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/shared/theme/cricket_colors.dart';

import '../../../data/repositories/cricket_repository.dart';

/// Live video status for a match.
///
/// Video comes from the Todd Broadcaster, which publishes its cameras into
/// the Todd Studio room over WHIP. The engine then forwards the on-air camera
/// to SRS, and SRS serves the HLS playlist the public page plays:
///
///   broadcaster → engine → SRS → cricket.traceodd.com
///
/// So there is nothing to create or configure here — the cameras already
/// exist, owned by the broadcaster. This screen answers the one question an
/// operator actually has when the public page is dark: *is the engine
/// currently writing an HLS playlist for this match, and if not, why?*
class LiveVideoPage extends StatefulWidget {
  final String matchId;

  const LiveVideoPage({super.key, required this.matchId});

  @override
  State<LiveVideoPage> createState() => _LiveVideoPageState();
}

class _LiveVideoPageState extends State<LiveVideoPage> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _health;
  String? _notice;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final health = await context.read<CricketRepository>().getVideoHealth(
        widget.matchId,
      );
      if (!mounted) return;
      setState(() {
        _health = health;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _reconnect() async {
    setState(() => _loading = true);
    try {
      final result = await context.read<CricketRepository>().resyncVideo(
        widget.matchId,
      );
      if (!mounted) return;
      setState(() {
        _notice = result['message']?.toString();
        _loading = false;
      });
      await _load();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final healthy = _health?['healthy'] == true;
    final state = _health?['forwarder_state']?.toString() ?? 'unknown';
    final hlsUrl = _health?['hls_url']?.toString();
    final forwarderError = _health?['forwarder_error']?.toString();

    return Scaffold(
      backgroundColor: CricketColors.background,
      appBar: AppBar(
        title: const Text('Live Video'),
        backgroundColor: CricketColors.inputFill,
        foregroundColor: CricketColors.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: CricketColors.complete),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_notice != null) ...[
                  _Banner(text: _notice!, color: CricketColors.textAccent),
                  const SizedBox(height: 16),
                ],
                if (_error != null) ...[
                  _Banner(text: _error!, color: CricketColors.wicket),
                  const SizedBox(height: 16),
                ],

                // The one thing the operator needs to know at a glance.
                _StatusCard(healthy: healthy, state: state),

                // The engine's own failure text. Without it the screen says
                // "BROKEN" and nothing else — the dead end that made a dead
                // forwarder look like a playback problem.
                if (!healthy && forwarderError != null) ...[
                  const SizedBox(height: 12),
                  _Banner(text: forwarderError, color: CricketColors.wicket),
                ],

                const SizedBox(height: 16),

                // Why it might not be working, in the order the pipeline is
                // built. Each line is a step the operator can act on.
                _StepCard(
                  title: '1. Broadcaster',
                  body: healthy || state == 'running'
                      ? 'A camera is live in Todd Studio and the engine is '
                            'receiving it.'
                      : 'Start the broadcast in Todd Studio (Go Live). '
                            'Video is published from there — nothing needs to '
                            'be created here.',
                  done: healthy || state == 'running',
                ),
                _StepCard(
                  title: '2. Engine → SRS bridge',
                  body: healthy
                      ? 'The forwarder is running and writing HLS segments.'
                      : 'Not running ($state). Tap "Reconnect live video" '
                            'below once the broadcaster is live.',
                  done: healthy,
                ),
                _StepCard(
                  title: '3. Public page',
                  body: healthy
                      ? 'The playlist is being served. The public page should '
                            'play within a few seconds.'
                      : 'Waiting for the bridge. The page shows its offline '
                            'state until then.',
                  done: healthy,
                ),

                const SizedBox(height: 20),

                if (hlsUrl != null) ...[
                  _UrlRow(label: 'HLS playlist', value: hlsUrl),
                  const SizedBox(height: 8),
                ],
                if (_health?['rtmp_url'] != null)
                  _UrlRow(
                    label: 'Engine target',
                    value: _health!['rtmp_url'].toString(),
                  ),

                const SizedBox(height: 24),

                FilledButton.icon(
                  onPressed: _loading ? null : _reconnect,
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Reconnect live video'),
                  style: FilledButton.styleFrom(
                    backgroundColor: CricketColors.complete,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Safe to tap any time — a bridge that is already running is '
                  'left untouched.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: CricketColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final bool healthy;
  final String state;

  const _StatusCard({required this.healthy, required this.state});

  @override
  Widget build(BuildContext context) {
    final color = healthy
        ? CricketColors.complete
        : (state == 'failed' ? CricketColors.wicket : CricketColors.upcoming);
    final label = healthy
        ? 'LIVE — visible to viewers'
        : (state == 'failed'
              ? 'BROKEN — the bridge failed'
              : 'OFF AIR — no video reaching viewers');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            healthy ? Icons.videocam : Icons.videocam_off,
            color: color,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'bridge: $state',
                  style: const TextStyle(
                    color: CricketColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String title;
  final String body;
  final bool done;

  const _StepCard({
    required this.title,
    required this.body,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CricketColors.surface,
        border: Border.all(color: CricketColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: done ? CricketColors.complete : CricketColors.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: CricketColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: const TextStyle(
                    color: CricketColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UrlRow extends StatelessWidget {
  final String label;
  final String value;

  const _UrlRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: const TextStyle(
              color: CricketColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: CricketColors.textPrimary,
              fontSize: 11,
              fontFamily: 'monospace',
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy, size: 15),
          color: CricketColors.textAccent,
          tooltip: 'Copy',
          onPressed: () => Clipboard.setData(ClipboardData(text: value)),
        ),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  final String text;
  final Color color;

  const _Banner({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 12)),
    );
  }
}

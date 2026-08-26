import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:trace_odd/shared/widgets/error_state/error_state_widget.dart';

import '../broadcaster_constants.dart';
import '../data/services/device_telemetry.dart';
import '../data/services/whip_client.dart';
import 'broadcaster_cubit.dart';

/// Todd Broadcaster — mobile ground camera control plane.
///
/// Idle: director-supplied connection form. Live: camera preview with
/// lens/torch/resolution/FPS/mute controls plus live device health.
class BroadcasterPage extends StatelessWidget {
  const BroadcasterPage({super.key, this.initialConfig});

  /// Connection config pre-filled from a deep link (e.g. the PWA opened
  /// with `?url=<whip ingest url>`). Null when the app starts fresh.
  final BroadcasterConfig? initialConfig;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BroadcasterCubit(initialConfig: initialConfig),
      child: const _BroadcasterView(),
    );
  }
}

class _BroadcasterView extends StatelessWidget {
  const _BroadcasterView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BroadcasterCubit, BroadcasterState>(
      builder: (context, state) {
        return Scaffold(
          body: switch (state.phase) {
            BroadcasterPhase.idle || BroadcasterPhase.stopped => _ConfigForm(
              error: state.error,
              initial: state.config,
            ),
            _ => _LiveView(state: state),
          },
        );
      },
    );
  }
}

// ─── Connection form ─────────────────────────────────────

class _ConfigForm extends StatefulWidget {
  const _ConfigForm({this.error, this.initial});

  final String? error;
  final BroadcasterConfig? initial;

  @override
  State<_ConfigForm> createState() => _ConfigFormState();
}

class _ConfigFormState extends State<_ConfigForm> {
  late final TextEditingController _whipUrl;
  late final TextEditingController _baseUrl;
  late final TextEditingController _roomId;
  late final TextEditingController _cameraId;
  late final TextEditingController _token;
  late final TextEditingController _stunUrl;
  late final TextEditingController _turnUrl;

  Timer? _urlDebounce;
  String? _urlError;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _whipUrl = TextEditingController();
    _baseUrl = TextEditingController(text: initial?.baseUrl ?? '');
    _roomId = TextEditingController(text: initial?.roomId ?? '');
    _cameraId = TextEditingController(text: initial?.cameraId ?? '');
    _token = TextEditingController(text: initial?.token ?? '');
    _stunUrl = TextEditingController(text: initial?.stunUrl ?? '');
    _turnUrl = TextEditingController(text: initial?.turnUrl ?? '');
  }

  /// Auto-fills the connection fields as soon as a pasted WHIP URL is
  /// recognizable — no Enter key or button press required. Debounced so
  /// manual typing doesn't clobber fields mid-edit.
  void _onWhipUrlChanged(String input) {
    _urlDebounce?.cancel();
    _urlDebounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) _applyWhipUrl(input);
    });
  }

  /// Fills the connection fields from a single pasted WHIP ingest URL
  /// (`https://host/api/v1/whip/ingest/{room}/{camera}?token=…`). A
  /// non-empty value that fails to parse shows an inline error instead of
  /// silently doing nothing.
  void _applyWhipUrl(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      setState(() => _urlError = null);
      return;
    }
    final parts = WhipClient.parseWhipUrl(trimmed);
    if (parts == null) {
      setState(() {
        _urlError =
            'Not a WHIP ingest URL — expected '
            'https://…/api/v1/whip/ingest/{room}/{camera}?token=…';
      });
      return;
    }
    setState(() {
      _urlError = null;
      _baseUrl.text = parts.baseUrl;
      _roomId.text = parts.roomId;
      _cameraId.text = parts.cameraId;
      if (parts.token.isNotEmpty) {
        _token.text = parts.token;
      }
    });
  }

  @override
  void didUpdateWidget(covariant _ConfigForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-sync after a failed start resets the config while this State
    // stays mounted; only touch fields whose incoming value differs.
    final initial = widget.initial;
    if (initial == null) return;
    if (initial.baseUrl != _baseUrl.text) _baseUrl.text = initial.baseUrl;
    if (initial.roomId != _roomId.text) _roomId.text = initial.roomId;
    if (initial.cameraId != _cameraId.text) _cameraId.text = initial.cameraId;
    if (initial.token != _token.text) _token.text = initial.token;
    if (initial.stunUrl != _stunUrl.text) _stunUrl.text = initial.stunUrl;
    if (initial.turnUrl != _turnUrl.text) _turnUrl.text = initial.turnUrl;
  }

  @override
  void dispose() {
    _urlDebounce?.cancel();
    _whipUrl.dispose();
    _baseUrl.dispose();
    _roomId.dispose();
    _cameraId.dispose();
    _token.dispose();
    _stunUrl.dispose();
    _turnUrl.dispose();
    super.dispose();
  }

  void _start(BuildContext context) {
    context.read<BroadcasterCubit>().add(
      BroadcastStart(
        BroadcasterConfig(
          baseUrl: _baseUrl.text,
          roomId: _roomId.text,
          cameraId: _cameraId.text,
          token: _token.text,
          stunUrl: _stunUrl.text,
          turnUrl: _turnUrl.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.videocam, size: 56),
                const SizedBox(height: 12),
                Text(
                  'Todd Broadcaster',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  'Ground camera uplink for the T-Odd media engine',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 20),
                if (widget.error != null) ...[
                  ListErrorState(message: widget.error!),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: _whipUrl,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'Paste WHIP URL (auto-fills below)',
                    hintText:
                        'https://studio.traceodd.com/api/v1/whip/ingest/…',
                    prefixIcon: Icon(Icons.content_paste),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _onWhipUrlChanged,
                  onSubmitted: _applyWhipUrl,
                ),
                if (_urlError != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _urlError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _applyWhipUrl(_whipUrl.text),
                    icon: const Icon(Icons.auto_fix_high, size: 16),
                    label: const Text('Fill connection fields'),
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: _baseUrl,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'Engine base URL',
                    hintText: BroadcasterConstants.engineUrlHint,
                    prefixIcon: Icon(Icons.link),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _roomId,
                  decoration: const InputDecoration(
                    labelText: 'Room ID',
                    prefixIcon: Icon(Icons.meeting_room),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _cameraId,
                  decoration: const InputDecoration(
                    labelText: 'Camera ID',
                    prefixIcon: Icon(Icons.videocam_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _token,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Room token',
                    prefixIcon: Icon(Icons.key),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _stunUrl,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'STUN server (optional)',
                    prefixIcon: Icon(Icons.public),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _turnUrl,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'TURN server (optional)',
                    prefixIcon: Icon(Icons.router),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => _start(context),
                  icon: const Icon(Icons.cast),
                  label: const Text('Start Broadcast'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LiveView extends StatelessWidget {
  const _LiveView({required this.state});

  final BroadcasterState state;

  @override
  Widget build(BuildContext context) {
    final renderer = state.renderer;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (renderer != null)
          RTCVideoView(
            renderer,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
            mirror: state.facingMode == 'user',
          )
        else
          const Center(child: CircularProgressIndicator()),
        _StatusOverlay(state: state),
      ],
    );
  }
}

class _StatusOverlay extends StatelessWidget {
  const _StatusOverlay({required this.state});

  final BroadcasterState state;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _PhaseChip(state: state),
                const SizedBox(height: 8),
                _HealthStrip(health: state.health),
                if (state.notice != null) ...[
                  const SizedBox(height: 8),
                  _NoticeBanner(message: state.notice!),
                ],
                if (state.phase == BroadcasterPhase.reconnecting) ...[
                  const SizedBox(height: 8),
                  _ReconnectBanner(state: state),
                ],
              ],
            ),
          ),
          const Spacer(),
          if (state.phase == BroadcasterPhase.live)
            _ControlBar(state: state)
          else if (state.phase == BroadcasterPhase.reconnecting ||
              state.phase == BroadcasterPhase.connecting)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: FilledButton.tonalIcon(
                onPressed: () =>
                    context.read<BroadcasterCubit>().add(const BroadcastStop()),
                icon: const Icon(Icons.stop),
                label: const Text('Stop'),
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _PhaseChip extends StatelessWidget {
  const _PhaseChip({required this.state});

  final BroadcasterState state;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (state.phase) {
      BroadcasterPhase.connecting => ('Connecting…', const Color(0xFFF59E0B)),
      BroadcasterPhase.live => ('LIVE', const Color(0xFFEF4444)),
      BroadcasterPhase.reconnecting => (
        'Reconnecting…',
        const Color(0xFFF59E0B),
      ),
      _ => ('—', const Color(0xFF64748B)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.phase == BroadcasterPhase.live) ...[
            const Icon(Icons.circle, size: 10, color: Colors.white),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthStrip extends StatelessWidget {
  const _HealthStrip({this.health});

  final DeviceHealth? health;

  @override
  Widget build(BuildContext context) {
    final health = this.health;
    if (health == null) return const SizedBox.shrink();

    final quality = health.quality;
    final qualityColor = switch (quality) {
      'good' => const Color(0xFF22C55E),
      'fair' => const Color(0xFFF59E0B),
      _ => const Color(0xFFEF4444),
    };
    final battery = health.batteryPct;
    final fps = health.fps;
    final uplink = health.uplinkKbps;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        if (battery != null)
          _HealthChip(
            icon: Icons.battery_full,
            label: '$battery%',
            color: const Color(0xFF64748B),
          ),
        if (fps != null)
          _HealthChip(
            icon: Icons.speed,
            label: '${fps.toStringAsFixed(0)} fps',
            color: const Color(0xFF64748B),
          ),
        if (uplink != null)
          _HealthChip(
            icon: Icons.upload,
            label: '${uplink.toStringAsFixed(0)} kbps',
            color: const Color(0xFF64748B),
          ),
        if (health.droppedFrames != null)
          _HealthChip(
            icon: Icons.call_missed_outgoing,
            label: '${health.droppedFrames} lost',
            color: const Color(0xFF64748B),
          ),
        _HealthChip(
          icon: Icons.network_check,
          label: quality.toUpperCase(),
          color: qualityColor,
        ),
      ],
    );
  }
}

class _HealthChip extends StatelessWidget {
  const _HealthChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _NoticeBanner extends StatelessWidget {
  const _NoticeBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Colors.white, fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _ReconnectBanner extends StatelessWidget {
  const _ReconnectBanner({required this.state});

  final BroadcasterState state;

  @override
  Widget build(BuildContext context) {
    final delay = state.reconnectDelay;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Retry ${state.reconnectAttempt}'
        '${delay != null ? ' in ${delay.inSeconds}s' : ''}…',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ─── Control bar ───────────────────────────────────────────

class _ControlBar extends StatelessWidget {
  const _ControlBar({required this.state});

  final BroadcasterState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BroadcasterCubit>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: _ControlButton(
                    icon: state.audioMuted ? Icons.mic_off : Icons.mic,
                    label: state.audioMuted ? 'Unmute' : 'Mute',
                    active: state.audioMuted,
                    onPressed: () =>
                        cubit.add(const ToggleAudioMuteRequested()),
                  ),
                ),
                Expanded(
                  child: _ControlButton(
                    icon: state.facingMode == 'environment'
                        ? Icons.camera_rear
                        : Icons.camera_front,
                    label: state.facingMode == 'environment' ? 'Rear' : 'Front',
                    onPressed: () => cubit.add(const SwitchCameraRequested()),
                  ),
                ),
                Expanded(
                  child: _ControlButton(
                    icon: state.torchOn
                        ? Icons.flashlight_on
                        : Icons.flashlight_off,
                    label: 'Torch',
                    active: state.torchOn,
                    onPressed: () => cubit.add(const ToggleTorchRequested()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<CameraProfile>(
                    segments: kCameraProfiles
                        .map(
                          (profile) => ButtonSegment<CameraProfile>(
                            value: profile,
                            label: Text(profile.label),
                          ),
                        )
                        .toList(),
                    selected: <CameraProfile>{state.profile},
                    onSelectionChanged: (selection) =>
                        cubit.add(ProfileChanged(selection.first)),
                    showSelectedIcon: false,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SegmentedButton<int>(
                    segments: <ButtonSegment<int>>[
                      for (final fps in BroadcasterConstants.fpsOptions)
                        ButtonSegment<int>(
                          value: fps,
                          label: Text('${fps}fps'),
                        ),
                    ],
                    selected: <int>{state.targetFps},
                    onSelectionChanged: (selection) =>
                        cubit.add(FpsChanged(selection.first)),
                    showSelectedIcon: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                ),
                onPressed: () => cubit.add(const BroadcastStop()),
                icon: const Icon(Icons.stop),
                label: const Text('Stop Broadcast'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filled(
          onPressed: onPressed,
          icon: Icon(icon),
          style: IconButton.styleFrom(
            backgroundColor: active ? scheme.primary : scheme.surfaceContainer,
            foregroundColor: active ? scheme.onPrimary : scheme.onSurface,
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

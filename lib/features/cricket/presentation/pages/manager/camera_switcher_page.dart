import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/shared/theme/cricket_colors.dart';
import 'package:trace_odd/shared/theme/colors.dart';

import '../../blocs/camera_switcher/camera_switcher_bloc.dart';
import '../../../data/models/cricket_models.dart';
import '../../widgets/video_player_widget.dart';

/// Multi-camera switcher UI — up to 5 RTMP streams with failover.
///
/// For the 3-mobile-camera test: create one stream row per phone, copy the
/// generated RTMP stream key into the phone's streaming app (Larix /
/// Streamlabs / prism), then activate the camera here and verify the HLS
/// preview plays.
class CameraSwitcherPage extends StatefulWidget {
  final String matchId;

  const CameraSwitcherPage({super.key, required this.matchId});

  @override
  State<CameraSwitcherPage> createState() => _CameraSwitcherPageState();
}

class _CameraSwitcherPageState extends State<CameraSwitcherPage> {
  @override
  void initState() {
    super.initState();
    if (widget.matchId.isNotEmpty) {
      context.read<CameraSwitcherBloc>().add(LoadCameras(widget.matchId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CameraSwitcherBloc, CameraSwitcherState>(
      listener: (context, state) {
        final notice = state is CameraSwitcherLoaded ? state.notice : null;
        if (notice != null && notice.isNotEmpty) {
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
        }
      },
      child: Scaffold(
        backgroundColor: CricketColors.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Camera Switcher'),
          backgroundColor: CricketColors.surface,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.home, color: Color(0xFF10B981)),
              tooltip: 'Back to Dashboard',
              onPressed: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => context.read<CameraSwitcherBloc>().add(
                LoadCameras(widget.matchId),
              ),
            ),
          ],
        ),
        body: BlocBuilder<CameraSwitcherBloc, CameraSwitcherState>(
          builder: (context, state) => switch (state) {
            CameraSwitcherLoading() => const Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            ),
            CameraSwitcherLoaded(:final cameras) => _buildCameraList(cameras),
            CameraSwitcherError(:final message) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  message,
                  style: const TextStyle(color: CricketColors.wicket),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            _ => const Center(
              child: Text(
                'Enter a match ID to load cameras.',
                style: TextStyle(color: CricketColors.textSecondary),
              ),
            ),
          },
        ),
      ),
    );
  }

  Widget _buildCameraList(List<StreamModel> cameras) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Add camera (3-mobile test: create one row per phone) ──
        ElevatedButton.icon(
          icon: const Icon(Icons.add_a_photo),
          label: Text(
            cameras.length >= 5
                ? 'Camera limit reached (5)'
                : 'Add Camera Stream',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
          ),
          onPressed: cameras.length >= 5
              ? null
              : () => _showAddCameraDialog(context),
        ),
        const SizedBox(height: 12),
        if (cameras.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                'No cameras yet.\nAdd up to 3 mobile camera streams and share each\nRTMP key with the phone streaming app.',
                textAlign: TextAlign.center,
                style: TextStyle(color: CricketColors.textSecondary),
              ),
            ),
          ),
        ...cameras.map(
          (cam) => _CameraTile(
            camera: cam,
            matchId: widget.matchId,
            isActive: cam.isLive,
          ),
        ),
      ],
    );
  }

  Future<void> _showAddCameraDialog(BuildContext context) async {
    final labelController = TextEditingController();
    int cameraNumber = 1;
    bool isPrimary = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: CricketColors.surface,
          title: const Text(
            'Add Camera Stream',
            style: TextStyle(color: CricketColors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Camera Label (e.g. "Cam 1 — Pitch End")',
                  labelStyle: TextStyle(color: Color(0xFFBDD8DB)),
                  filled: true,
                  fillColor: Color(0xFF0F2936),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: cameraNumber,
                dropdownColor: const Color(0xFF0F2936),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Camera Number',
                  labelStyle: TextStyle(color: Color(0xFFBDD8DB)),
                  filled: true,
                  fillColor: Color(0xFF0F2936),
                ),
                items: [1, 2, 3, 4, 5]
                    .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
                    .toList(),
                onChanged: (v) => setDialogState(() => cameraNumber = v ?? 1),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                value: isPrimary,
                activeColor: AppColors.secondary,
                title: const Text(
                  'Primary camera',
                  style: TextStyle(color: CricketColors.textPrimary),
                ),
                onChanged: (v) => setDialogState(() => isPrimary = v ?? false),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancel',
                style: TextStyle(color: CricketColors.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
              ),
              onPressed: () {
                final label = labelController.text.trim();
                if (label.isEmpty) return;
                context.read<CameraSwitcherBloc>().add(
                  CreateCamera(
                    matchId: widget.matchId,
                    cameraLabel: label,
                    cameraNumber: cameraNumber,
                    isPrimary: isPrimary,
                  ),
                );
                Navigator.pop(ctx);
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraTile extends StatefulWidget {
  final StreamModel camera;
  final String matchId;
  final bool isActive;

  const _CameraTile({
    required this.camera,
    required this.matchId,
    required this.isActive,
  });

  @override
  State<_CameraTile> createState() => _CameraTileState();
}

class _CameraTileState extends State<_CameraTile> {
  bool _showPreview = false;
  bool _showRtmpDetails = false;

  @override
  Widget build(BuildContext context) {
    final cam = widget.camera;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CricketColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: widget.isActive
            ? Border.all(color: AppColors.secondary, width: 2)
            : Border.all(color: CricketColors.textSecondary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Status indicator
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isActive
                      ? AppColors.secondary
                      : CricketColors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              // Camera info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Camera ${cam.cameraNumber}: ${cam.cameraLabel}',
                      style: const TextStyle(
                        color: CricketColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _StatusBadge(
                          label: cam.streamStatus.toUpperCase(),
                          color: widget.isActive
                              ? AppColors.secondary
                              : CricketColors.textSecondary,
                        ),
                        if (cam.isPrimary)
                          const _StatusBadge(
                            label: 'PRIMARY',
                            color: CricketColors.teamA,
                          ),
                        if (cam.failoverPriority > 0)
                          _StatusBadge(
                            label: 'FAILOVER #${cam.failoverPriority}',
                            color: CricketColors.roleAllRounder,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Toggle button — keyed by stream id (never list index)
              Switch.adaptive(
                value: widget.isActive,
                activeColor: AppColors.secondary,
                onChanged: (_) {
                  context.read<CameraSwitcherBloc>().add(
                    ToggleCamera(widget.matchId, cam.id),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // RTMP details toggle (mobile camera setup info)
              TextButton.icon(
                icon: const Icon(Icons.videocam_outlined, size: 16),
                label: Text(
                  _showRtmpDetails ? 'Hide RTMP key' : 'Show RTMP key',
                ),
                style: TextButton.styleFrom(
                  foregroundColor: CricketColors.textAccent,
                ),
                onPressed: () =>
                    setState(() => _showRtmpDetails = !_showRtmpDetails),
              ),
              const Spacer(),
              // HLS verification preview
              TextButton.icon(
                icon: Icon(
                  _showPreview
                      ? Icons.visibility_off_outlined
                      : Icons.play_circle_outline,
                  size: 16,
                ),
                label: Text(_showPreview ? 'Hide preview' : 'Verify stream'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.secondary,
                ),
                onPressed: cam.isLive && cam.hlsPlaylistUrl != null
                    ? () => setState(() => _showPreview = !_showPreview)
                    : null,
              ),
              // Delete
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: CricketColors.wicket,
                ),
                tooltip: 'Delete camera stream',
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
          if (_showRtmpDetails) _RtmpDetails(camera: cam),
          if (_showPreview && cam.isLive && cam.hlsPlaylistUrl != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child: CricketVideoPlayer(hlsUrl: cam.hlsPlaylistUrl!),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CricketColors.surface,
        title: const Text(
          'Delete camera stream?',
          style: TextStyle(color: CricketColors.textPrimary),
        ),
        content: Text(
          'This removes the stream entry for Camera ${widget.camera.cameraNumber}. '
          'The RTMP key will stop being listed.',
          style: const TextStyle(color: CricketColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: CricketColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: CricketColors.wicket,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<CameraSwitcherBloc>().add(
        DeleteCamera(widget.matchId, widget.camera.id),
      );
    }
  }
}

/// RTMP ingest details for the mobile camera operator.
/// All values come from the backend stream registry (env/config-driven).
class _RtmpDetails extends StatelessWidget {
  final StreamModel camera;

  const _RtmpDetails({required this.camera});

  @override
  Widget build(BuildContext context) {
    final key = camera.rtmpStreamKey;
    final ingest = camera.rtmpIngestUrl;
    final hls = camera.hlsPlaylistUrl;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2936),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mobile camera setup (Larix / Streamlabs / prism):',
            style: TextStyle(color: CricketColors.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 8),
          if (key != null && key.isNotEmpty) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Stream key: $key',
                    style: const TextStyle(
                      color: CricketColors.textPrimary,
                      fontSize: 12,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.copy,
                    size: 16,
                    color: CricketColors.textAccent,
                  ),
                  tooltip: 'Copy stream key',
                  onPressed: () => Clipboard.setData(ClipboardData(text: key)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              ingest != null && ingest.isNotEmpty
                  ? 'RTMP server: $ingest'
                  : 'RTMP server: not configured',
              style: const TextStyle(
                color: CricketColors.textSecondary,
                fontSize: 11,
              ),
            ),
            if (hls != null && hls.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'HLS: $hls',
                style: const TextStyle(
                  color: CricketColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ] else
            const Text(
              'Stream key not generated yet — save the camera first.',
              style: TextStyle(color: CricketColors.wicket, fontSize: 12),
            ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(right: 6),
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.2),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
    ),
  );
}

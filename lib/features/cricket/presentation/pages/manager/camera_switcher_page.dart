import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/camera_switcher/camera_switcher_bloc.dart';
import '../../../data/models/cricket_models.dart';

/// Multi-camera switcher UI — up to 5 RTMP streams with failover.
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
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text('Camera Switcher'),
        backgroundColor: const Color(0xFF1A1E31),
        foregroundColor: Colors.white,
        actions: [
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
            child: CircularProgressIndicator(color: Colors.green),
          ),
          CameraSwitcherLoaded(:final cameras, :final hasFailover) =>
            _buildCameraGrid(cameras),
          CameraSwitcherError(:final message) => Center(
            child: Text(message, style: const TextStyle(color: Colors.red)),
          ),
          _ => const Center(
            child: Text(
              'Enter a match ID to load cameras.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        },
      ),
    );
  }

  Widget _buildCameraGrid(List<StreamModel> cameras) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cameras.length,
      itemBuilder: (context, index) {
        final cam = cameras[index];
        return _CameraTile(
          camera: cam,
          matchId: widget.matchId,
          isActive: cam.isLive,
        );
      },
    );
  }
}

class _CameraTile extends StatelessWidget {
  final StreamModel camera;
  final String matchId;
  final bool isActive;

  const _CameraTile({
    required this.camera,
    required this.matchId,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1E31),
        borderRadius: BorderRadius.circular(12),
        border: isActive
            ? Border.all(color: Colors.green, width: 2)
            : Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Status indicator
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.green : Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
          // Camera info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Camera ${camera.cameraNumber}: ${camera.cameraLabel}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _StatusBadge(
                      label: camera.streamStatus.toUpperCase(),
                      color: isActive ? Colors.green : Colors.grey,
                    ),
                    if (camera.isPrimary)
                      const _StatusBadge(label: 'PRIMARY', color: Colors.blue),
                    if (camera.failoverPriority > 0)
                      _StatusBadge(
                        label: 'FAILOVER #${camera.failoverPriority}',
                        color: Colors.orange,
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Toggle button
          Switch.adaptive(
            value: isActive,
            activeColor: Colors.green,
            onChanged: (_) {
              context.read<CameraSwitcherBloc>().add(
                ToggleCamera(matchId, camera.cameraNumber - 1),
              );
            },
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

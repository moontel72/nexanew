import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/features/cricket/data/models/cricket_models.dart';
import 'package:trace_odd/features/cricket/data/repositories/cricket_repository.dart';
import 'package:trace_odd/features/cricket/presentation/widgets/cricket_image_resolver.dart';

class MediaManagementPage extends StatefulWidget {
  const MediaManagementPage({super.key});
  @override
  State<MediaManagementPage> createState() => _MediaManagementPageState();
}

class _MediaManagementPageState extends State<MediaManagementPage> {
  List<TeamModel> _teams = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repo = _safeRepo();
      if (repo == null) return;
      final teams = await repo.getAllTeams();
      if (mounted) {
        setState(() {
          _teams = teams;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Safely access CricketRepository, falling back gracefully.
  CricketRepository? _safeRepo() {
    try {
      return RepositoryProvider.of<CricketRepository>(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Service unavailable — please go back and try again.',
            ),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1D2C),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Media Management',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0F2936),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Color(0xFF10B981)),
            tooltip: 'Back to Dashboard',
            onPressed: () {
              try {
                Navigator.of(context).popUntil(
                  (route) =>
                      route.settings.name == 'cricket_manager_dashboard' ||
                      route.isFirst,
                );
              } catch (_) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _teams.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    size: 64,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No teams found',
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async => _load(),
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: _teams.length,
                itemBuilder: (_, i) {
                  final team = _teams[i];
                  return _TeamMediaCard(team: team, onChanged: _load);
                },
              ),
            ),
    );
  }
}

class _TeamMediaCard extends StatelessWidget {
  final TeamModel team;
  final VoidCallback onChanged;
  const _TeamMediaCard({required this.team, required this.onChanged});

  Future<void> _pickAndUploadLogo(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final bytes = result.files.first.bytes;
    final fileName = result.files.first.name;
    if (bytes == null) return;
    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF0F2936),
        title: const Text('New Logo', style: TextStyle(color: Colors.white)),
        content: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            bytes,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
            ),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await CricketRepository().uploadTeamLogo(team.id, bytes, fileName);
      onChanged();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logo updated'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final code = team.shortCode.isNotEmpty
        ? team.shortCode
        : (team.teamCode ?? '');
    final logo = resolveImageUrl(team.logoUrl);

    return Card(
      color: const Color(0xFF0F2936),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Team logo (or neutral placeholder)
            CircleAvatar(
              radius: 36,
              backgroundColor: const Color(0xFF1E2238),
              backgroundImage: logo != null ? NetworkImage(logo) : null,
              child: logo == null
                  ? const Icon(
                      Icons.shield_outlined,
                      color: Color(0xFFA0AAB8),
                      size: 32,
                    )
                  : null,
            ),
            const SizedBox(height: 10),
            // Team name
            Text(
              team.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (code.isNotEmpty) ...[
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: const Color(0xFF10B981).withOpacity(0.5),
                  ),
                ),
                child: Text(
                  code,
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
            const Spacer(),
            // Upload Logo button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.upload, size: 16),
                label: const Text(
                  'Upload Logo',
                  style: TextStyle(fontSize: 12),
                ),
                onPressed: () => _pickAndUploadLogo(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF10B981),
                  side: const BorderSide(color: Color(0xFF10B981)),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                ),
              ),
            ),
            const SizedBox(height: 6),
            // Upload Photo button (disabled)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add_a_photo, size: 16),
                label: const Text(
                  'Upload Photo',
                  style: TextStyle(fontSize: 12),
                ),
                onPressed: null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6B7280),
                  side: const BorderSide(color: Color(0xFF374151)),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

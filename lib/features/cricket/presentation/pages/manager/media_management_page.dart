import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/features/cricket/data/models/cricket_models.dart';
import 'package:trace_odd/features/cricket/data/repositories/cricket_repository.dart';

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
          icon: const Icon(Icons.arrow_back),
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
            icon: const Icon(Icons.home, color: Colors.white),
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
                  return _TeamMediaCard(team: team);
                },
              ),
            ),
    );
  }
}

class _TeamMediaCard extends StatelessWidget {
  final TeamModel team;
  const _TeamMediaCard({required this.team});

  @override
  Widget build(BuildContext context) {
    final initial = team.name.isNotEmpty ? team.name[0].toUpperCase() : '?';
    final code = team.shortCode.isNotEmpty
        ? team.shortCode
        : (team.teamCode ?? '');

    return Card(
      color: const Color(0xFF0F2936),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Placeholder avatar
            CircleAvatar(
              radius: 36,
              backgroundColor: const Color(0xFF2563EB),
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
            // Upload Logo button (disabled)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.upload, size: 16),
                label: const Text(
                  'Upload Logo',
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

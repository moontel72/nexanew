import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/features/cricket/data/models/cricket_models.dart';
import 'package:trace_odd/features/cricket/data/repositories/cricket_repository.dart';
import 'package:trace_odd/features/cricket/presentation/blocs/team/team_bloc.dart';
import 'team_register_page.dart';
import 'player_register_page.dart';

class TeamsListPage extends StatefulWidget {
  const TeamsListPage({super.key});
  @override
  State<TeamsListPage> createState() => _TeamsListPageState();
}

class _TeamsListPageState extends State<TeamsListPage> {
  List<TeamModel> _teams = [];
  bool _loading = true;
  String _search = '';

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
      if (mounted)
        setState(() {
          _teams = teams;
          _loading = false;
        });
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

  List<TeamModel> get _filtered => _search.isEmpty
      ? _teams
      : _teams
            .where((t) => t.name.toLowerCase().contains(_search.toLowerCase()))
            .toList();

  void _showDetailModal(TeamModel team) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F2936),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row with close icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    team.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Info chips
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (team.teamCode != null && team.teamCode!.isNotEmpty)
                  _infoChip('Code: ${team.teamCode}'),
                if (team.homeCity != null && team.homeCity!.isNotEmpty)
                  _infoChip('City: ${team.homeCity}'),
                if (team.shortCode.isNotEmpty)
                  _infoChip('Short: ${team.shortCode}'),
              ],
            ),
            const SizedBox(height: 20),
            // Details section
            const Text(
              'Details',
              style: TextStyle(
                color: Color(0xFFBDD8DB),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (team.details != null && team.details!.isNotEmpty)
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.35,
                ),
                child: SingleChildScrollView(
                  child: Text(
                    team.details!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              )
            else
              const Text(
                'No details available',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontStyle: FontStyle.italic,
                  fontSize: 14,
                ),
              ),
            const SizedBox(height: 24),
            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF10B981),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
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
        title: const Text('Teams', style: TextStyle(color: Colors.white)),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search teams...',
                hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280)),
                filled: true,
                fillColor: const Color(0xFF0F2936),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0x20FFFFFF)),
                ),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.groups,
                          size: 64,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No teams found',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async => _load(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) {
                        final t = _filtered[i];
                        return Card(
                          color: const Color(0xFF0F2936),
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF2563EB),
                              child: Text(
                                t.name.isNotEmpty
                                    ? t.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    t.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (t.teamCode != null &&
                                    t.teamCode!.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF10B981,
                                      ).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: const Color(
                                          0xFF10B981,
                                        ).withOpacity(0.5),
                                      ),
                                    ),
                                    child: Text(
                                      t.teamCode!,
                                      style: const TextStyle(
                                        color: Color(0xFF10B981),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            subtitle: Text(
                              '${t.playerCount ?? 0} players${t.homeCity != null ? ' · ${t.homeCity}' : ''}',
                              style: const TextStyle(
                                color: Color(0xFFBDD8DB),
                                fontSize: 12,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(
                                  onPressed: () => _showDetailModal(t),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Detail',
                                    style: TextStyle(
                                      color: Color(0xFF10B981),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Color(0xFF6B7280),
                                ),
                              ],
                            ),
                            onTap: () {
                              final repo = _safeRepo();
                              if (repo == null) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RepositoryProvider.value(
                                    value: repo,
                                    child: PlayerRegisterPage(
                                      teamId: t.id,
                                      teamName: t.name,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2563EB),
        onPressed: () async {
          final repo = _safeRepo();
          if (repo == null) return;
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RepositoryProvider.value(
                value: repo,
                child: BlocProvider(
                  create: (_) => TeamBloc(repo: repo),
                  child: const TeamRegisterPage(),
                ),
              ),
            ),
          );
          if (result == true) _load();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

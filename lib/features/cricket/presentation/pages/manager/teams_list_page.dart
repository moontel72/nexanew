import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/features/cricket/data/models/cricket_models.dart';
import 'package:trace_odd/features/cricket/data/repositories/cricket_repository.dart';
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
      final repo = RepositoryProvider.of<CricketRepository>(context);
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

  List<TeamModel> get _filtered => _search.isEmpty
      ? _teams
      : _teams
            .where((t) => t.name.toLowerCase().contains(_search.toLowerCase()))
            .toList();

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
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
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
                                t.name[0].toUpperCase(),
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
                                if (t.teamCode != null) ...[
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
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: Color(0xFF6B7280),
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PlayerRegisterPage(
                                  teamId: t.id,
                                  teamName: t.name,
                                ),
                              ),
                            ),
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
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TeamRegisterPage()),
          );
          if (result == true) _load();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

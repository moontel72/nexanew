import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/features/cricket/data/models/cricket_models.dart';
import 'package:trace_odd/features/cricket/data/repositories/cricket_repository.dart';
import 'player_register_page.dart';

class PlayersListPage extends StatefulWidget {
  const PlayersListPage({super.key});
  @override
  State<PlayersListPage> createState() => _PlayersListPageState();
}

class _PlayersListPageState extends State<PlayersListPage> {
  List<PlayerModel> _players = [];
  List<PlayerModel> _trashedPlayers = [];
  List<TeamModel> _teams = [];
  bool _loading = true;
  bool _showingTrash = false;
  String _search = '';
  String? _selectedTeamId;

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
      final results = await Future.wait([
        repo.getAllPlayers(),
        repo.getAllTeams(),
      ]);
      if (mounted)
        setState(() {
          _players = results[0] as List<PlayerModel>;
          _teams = results[1] as List<TeamModel>;
          _loading = false;
        });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadTrash() async {
    setState(() => _loading = true);
    try {
      final repo = _safeRepo();
      if (repo == null) return;
      final players = await repo.getTrashedPlayers();
      if (mounted)
        setState(() {
          _trashedPlayers = players;
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

  List<PlayerModel> get _filtered {
    var list = _showingTrash ? _trashedPlayers : _players;
    if (_search.isNotEmpty) {
      list = list
          .where((p) => p.name.toLowerCase().contains(_search.toLowerCase()))
          .toList();
    }
    if (!_showingTrash && _selectedTeamId != null) {
      list = list.where((p) => p.teamId == _selectedTeamId).toList();
    }
    return list;
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'batsman':
        return const Color(0xFF10B981); // green
      case 'bowler':
        return const Color(0xFFEF4444); // red
      case 'all_rounder':
        return const Color(0xFFA855F7); // purple
      case 'wicket_keeper':
        return const Color(0xFF3B82F6); // blue
      default:
        return const Color(0xFF9CA3AF); // grey
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
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
        title: const Text('Players', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0F2936),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              _showingTrash ? Icons.restore : Icons.delete_outline,
              color: Colors.white,
            ),
            tooltip: _showingTrash ? 'Back to Players' : 'View Trash',
            onPressed: () {
              setState(() {
                _showingTrash = !_showingTrash;
                _search = '';
              });
              if (_showingTrash) {
                _loadTrash();
              } else {
                _load();
              }
            },
          ),
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
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search players...',
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
          // Team filter dropdown
          if (!_showingTrash)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F2936),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0x20FFFFFF)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: _selectedTeamId,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF0F2936),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Color(0xFF6B7280),
                    ),
                    hint: const Text(
                      'All Teams',
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('All Teams'),
                      ),
                      ..._teams.map(
                        (t) => DropdownMenuItem<String?>(
                          value: t.id,
                          child: Text(t.name),
                        ),
                      ),
                    ],
                    onChanged: (v) => setState(() => _selectedTeamId = v),
                  ),
                ),
              ),
            ),
          // Results count
          if (!_loading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_filtered.length} player${_filtered.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          // Player list
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_search,
                          size: 64,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _showingTrash
                              ? 'No trashed players'
                              : 'No players found',
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) {
                        final p = _filtered[i];
                        return Card(
                          color: const Color(0xFF0F2936),
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: _showingTrash
                                ? null
                                : () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${p.name} — ${p.roleDisplay}',
                                        ),
                                      ),
                                    );
                                  },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Player avatar
                                  CircleAvatar(
                                    backgroundColor: const Color(0xFF2563EB),
                                    radius: 22,
                                    child: Text(
                                      p.name.isNotEmpty
                                          ? p.name[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Player info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Name + captain badge
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                p.name,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (p.isCaptain)
                                              const Padding(
                                                padding: EdgeInsets.only(
                                                  left: 6,
                                                ),
                                                child: Icon(
                                                  Icons.star,
                                                  color: Color(0xFFFBBF24),
                                                  size: 16,
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        if (_showingTrash)
                                          Text(
                                            p.deletedAt != null
                                                ? 'Deleted ${_formatDate(p.deletedAt!)}'
                                                : '(deleted)',
                                            style: const TextStyle(
                                              color: Color(0xFFEF4444),
                                              fontSize: 12,
                                            ),
                                          )
                                        else
                                          // Role chip + team info
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 4,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 3,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: _roleColor(
                                                    p.role,
                                                  ).withOpacity(0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: _roleColor(
                                                      p.role,
                                                    ).withOpacity(0.5),
                                                  ),
                                                ),
                                                child: Text(
                                                  p.roleDisplay,
                                                  style: TextStyle(
                                                    color: _roleColor(p.role),
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              if (p.teamName != null) ...[
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.shield,
                                                      size: 13,
                                                      color: Color(0xFF6B7280),
                                                    ),
                                                    const SizedBox(width: 3),
                                                    Flexible(
                                                      child: Text(
                                                        p.teamName!,
                                                        style: const TextStyle(
                                                          color: Color(
                                                            0xFFBDD8DB,
                                                          ),
                                                          fontSize: 12,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    if (p.teamShortCode !=
                                                            null &&
                                                        p
                                                            .teamShortCode!
                                                            .isNotEmpty) ...[
                                                      const SizedBox(width: 4),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 4,
                                                              vertical: 1,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: const Color(
                                                            0xFF10B981,
                                                          ).withOpacity(0.15),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                4,
                                                              ),
                                                        ),
                                                        child: Text(
                                                          p.teamShortCode!,
                                                          style:
                                                              const TextStyle(
                                                                color: Color(
                                                                  0xFF10B981,
                                                                ),
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ],
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (!_showingTrash) ...[
                                    // Jersey number
                                    if (p.jerseyNumber != null &&
                                        p.jerseyNumber!.isNotEmpty)
                                      Container(
                                        width: 40,
                                        height: 40,
                                        margin: const EdgeInsets.only(left: 8),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: const Color(
                                              0xFF6B7280,
                                            ).withOpacity(0.4),
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          p.jerseyNumber!,
                                          style: const TextStyle(
                                            color: Color(0xFFBDD8DB),
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    // Action menu
                                    PopupMenuButton<String>(
                                      icon: const Icon(
                                        Icons.more_vert,
                                        color: Colors.white,
                                      ),
                                      color: const Color(0xFF0F2936),
                                      onSelected: (action) async {
                                        final repo = _safeRepo();
                                        if (repo == null) return;
                                        switch (action) {
                                          case 'edit':
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Edit coming soon',
                                                ),
                                              ),
                                            );
                                          case 'delete':
                                            final confirmed =
                                                await showDialog<bool>(
                                                  context: context,
                                                  builder: (ctx) => AlertDialog(
                                                    backgroundColor:
                                                        const Color(0xFF0F2936),
                                                    title: const Text(
                                                      'Delete Player',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    content: Text(
                                                      'Delete "${p.name}"? This cannot be undone.',
                                                      style: const TextStyle(
                                                        color: Color(
                                                          0xFFBDD8DB,
                                                        ),
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              ctx,
                                                              false,
                                                            ),
                                                        child: const Text(
                                                          'Cancel',
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              ctx,
                                                              true,
                                                            ),
                                                        child: const Text(
                                                          'Delete',
                                                          style: TextStyle(
                                                            color: Color(
                                                              0xFFEF4444,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                            if (confirmed == true) {
                                              try {
                                                await repo.deletePlayer(p.id);
                                                _load();
                                              } catch (e) {
                                                if (mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text('${e}'),
                                                      backgroundColor:
                                                          const Color(
                                                            0xFFEF4444,
                                                          ),
                                                    ),
                                                  );
                                                }
                                              }
                                            }
                                          case 'mark_active':
                                            try {
                                              await repo.updatePlayerStatus(
                                                p.id,
                                                'active',
                                              );
                                              _load();
                                            } catch (e) {
                                              if (mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text('${e}'),
                                                    backgroundColor:
                                                        const Color(0xFFEF4444),
                                                  ),
                                                );
                                              }
                                            }
                                          case 'mark_inactive':
                                            try {
                                              await repo.updatePlayerStatus(
                                                p.id,
                                                'inactive',
                                              );
                                              _load();
                                            } catch (e) {
                                              if (mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text('${e}'),
                                                    backgroundColor:
                                                        const Color(0xFFEF4444),
                                                  ),
                                                );
                                              }
                                            }
                                          case 'suspend':
                                            try {
                                              await repo.updatePlayerStatus(
                                                p.id,
                                                'suspended',
                                              );
                                              _load();
                                            } catch (e) {
                                              if (mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text('${e}'),
                                                    backgroundColor:
                                                        const Color(0xFFEF4444),
                                                  ),
                                                );
                                              }
                                            }
                                        }
                                      },
                                      itemBuilder: (ctx) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: ListTile(
                                            leading: Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                            ),
                                            title: Text(
                                              'Edit',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            contentPadding: EdgeInsets.zero,
                                            visualDensity:
                                                VisualDensity.compact,
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: ListTile(
                                            leading: Icon(
                                              Icons.delete,
                                              color: Color(0xFFEF4444),
                                            ),
                                            title: Text(
                                              'Delete',
                                              style: TextStyle(
                                                color: Color(0xFFEF4444),
                                              ),
                                            ),
                                            contentPadding: EdgeInsets.zero,
                                            visualDensity:
                                                VisualDensity.compact,
                                          ),
                                        ),
                                        if (p.status == 'active')
                                          const PopupMenuItem(
                                            value: 'mark_inactive',
                                            child: ListTile(
                                              leading: Icon(
                                                Icons.block,
                                                color: Colors.white70,
                                              ),
                                              title: Text(
                                                'Mark Inactive',
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                ),
                                              ),
                                              contentPadding: EdgeInsets.zero,
                                              visualDensity:
                                                  VisualDensity.compact,
                                            ),
                                          )
                                        else
                                          const PopupMenuItem(
                                            value: 'mark_active',
                                            child: ListTile(
                                              leading: Icon(
                                                Icons.check_circle,
                                                color: Color(0xFF10B981),
                                              ),
                                              title: Text(
                                                'Mark Active',
                                                style: TextStyle(
                                                  color: Color(0xFF10B981),
                                                ),
                                              ),
                                              contentPadding: EdgeInsets.zero,
                                              visualDensity:
                                                  VisualDensity.compact,
                                            ),
                                          ),
                                        const PopupMenuItem(
                                          value: 'suspend',
                                          child: ListTile(
                                            leading: Icon(
                                              Icons.pause_circle,
                                              color: Color(0xFFF97316),
                                            ),
                                            title: Text(
                                              'Suspend',
                                              style: TextStyle(
                                                color: Color(0xFFF97316),
                                              ),
                                            ),
                                            contentPadding: EdgeInsets.zero,
                                            visualDensity:
                                                VisualDensity.compact,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (_showingTrash)
                                    TextButton.icon(
                                      icon: const Icon(Icons.restore, size: 18),
                                      label: const Text('Restore'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: const Color(
                                          0xFF10B981,
                                        ),
                                      ),
                                      onPressed: () async {
                                        final repo = _safeRepo();
                                        if (repo == null) return;
                                        try {
                                          await repo.restorePlayer(p.id);
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  '${p.name} restored',
                                                ),
                                                backgroundColor: const Color(
                                                  0xFF10B981,
                                                ),
                                              ),
                                            );
                                            _loadTrash();
                                            _load();
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text('${e}'),
                                                backgroundColor: const Color(
                                                  0xFFEF4444,
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                ],
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
      floatingActionButton: _showingTrash
          ? null
          : FloatingActionButton(
              backgroundColor: const Color(0xFF2563EB),
              onPressed: () async {
                final repo = _safeRepo();
                if (repo == null) return;
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RepositoryProvider.value(
                      value: repo,
                      child: PlayerRegisterPage(),
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

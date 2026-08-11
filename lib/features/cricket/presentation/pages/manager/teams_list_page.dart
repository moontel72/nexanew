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
  List<TeamModel> _trashedTeams = [];
  bool _loading = true;
  bool _showingTrash = false;
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

  Future<void> _loadTrash() async {
    setState(() => _loading = true);
    try {
      final repo = _safeRepo();
      if (repo == null) return;
      final teams = await repo.getTrashedTeams();
      if (mounted)
        setState(() {
          _trashedTeams = teams;
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

  List<TeamModel> get _filtered {
    final source = _showingTrash ? _trashedTeams : _teams;
    return _search.isEmpty
        ? source
        : source
              .where(
                (t) => t.name.toLowerCase().contains(_search.toLowerCase()),
              )
              .toList();
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  Color _teamColor(TeamModel t) {
    if (t.primaryColor == null || t.primaryColor!.isEmpty) {
      return const Color(0xFF2563EB);
    }
    try {
      final hex = t.primaryColor!.replaceFirst('#', '0xFF');
      return Color(int.parse(hex));
    } catch (_) {
      return const Color(0xFF2563EB);
    }
  }

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

  Future<void> _showEditTeamDialog(TeamModel team) async {
    final nameCtrl = TextEditingController(text: team.name);
    final cityCtrl = TextEditingController(text: team.homeCity ?? '');
    final detailsCtrl = TextEditingController(text: team.details ?? '');
    Color selectedColor = const Color(0xFF2563EB);
    if (team.primaryColor != null) {
      try {
        selectedColor = Color(
          int.parse(team.primaryColor!.replaceFirst('#', '0xFF')),
        );
      } catch (_) {}
    }
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF0F2936),
          title: const Text('Edit Team', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: _darkInputDecoration('Team Name'),
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: cityCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: _darkInputDecoration('Home City'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: detailsCtrl,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: _darkInputDecoration('Team Details'),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Primary Color',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children:
                        const [
                              Color(0xFF2563EB),
                              Color(0xFF10B981),
                              Color(0xFFF59E0B),
                              Color(0xFFEF4444),
                              Color(0xFF8B5CF6),
                              Color(0xFFEC4899),
                              Color(0xFF06B6D4),
                              Color(0xFF84CC16),
                            ]
                            .map(
                              (c) => GestureDetector(
                                onTap: () =>
                                    setDialogState(() => selectedColor = c),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: c,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: selectedColor == c
                                          ? Colors.white
                                          : Colors.transparent,
                                      width: 3,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
              ),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                try {
                  final repo = _safeRepo();
                  if (repo == null) return;
                  await repo.updateTeam(
                    teamId: team.id,
                    name: nameCtrl.text.trim(),
                    homeCity: cityCtrl.text.trim().isEmpty
                        ? null
                        : cityCtrl.text.trim(),
                    details: detailsCtrl.text.trim().isEmpty
                        ? null
                        : detailsCtrl.text.trim(),
                    primaryColor:
                        '#${selectedColor.value.toRadixString(16).substring(2)}',
                  );
                  if (ctx.mounted) Navigator.pop(ctx, true);
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: const Color(0xFFEF4444),
                      ),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result == true && mounted) {
      _load();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Team updated'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    }
  }

  InputDecoration _darkInputDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Color(0xFFBDD8DB)),
    filled: true,
    fillColor: const Color(0xFF0C1D2C),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0x20FFFFFF)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1D2C),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Teams', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0F2936),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              _showingTrash ? Icons.restore : Icons.delete_outline,
              color: Colors.white,
            ),
            tooltip: _showingTrash ? 'Back to Teams' : 'View Trash',
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
                          _showingTrash ? 'No trashed teams' : 'No teams found',
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
                              backgroundColor: _teamColor(t),
                              backgroundImage:
                                  t.logoUrl != null && t.logoUrl!.isNotEmpty
                                  ? NetworkImage(t.logoUrl!)
                                  : null,
                              child: t.logoUrl == null || t.logoUrl!.isEmpty
                                  ? Text(
                                      t.name.isNotEmpty
                                          ? t.name[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                            title: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: t.status == 'active'
                                        ? const Color(0xFF10B981)
                                        : t.status == 'inactive'
                                        ? const Color(0xFF6B7280)
                                        : const Color(0xFFEF4444),
                                  ),
                                ),
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
                            subtitle: _showingTrash
                                ? Text(
                                    t.deletedAt != null
                                        ? 'Deleted ${_formatDate(t.deletedAt!)}'
                                        : '(deleted)',
                                    style: const TextStyle(
                                      color: Color(0xFFEF4444),
                                      fontSize: 12,
                                    ),
                                  )
                                : Text(
                                    '${t.playerCount ?? 0} players${t.homeCity != null ? ' · ${t.homeCity}' : ''}',
                                    style: const TextStyle(
                                      color: Color(0xFFBDD8DB),
                                      fontSize: 12,
                                    ),
                                  ),
                            trailing: _showingTrash
                                ? TextButton.icon(
                                    icon: const Icon(Icons.restore, size: 18),
                                    label: const Text('Restore'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFF10B981),
                                    ),
                                    onPressed: () async {
                                      final repo = _safeRepo();
                                      if (repo == null) return;
                                      try {
                                        await repo.restoreTeam(t.id);
                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '${t.name} restored',
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
                                  )
                                : PopupMenuButton<String>(
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
                                          _showEditTeamDialog(t);
                                        case 'delete':
                                          final confirmed = await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              backgroundColor: const Color(
                                                0xFF0F2936,
                                              ),
                                              title: const Text(
                                                'Delete Team',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              content: Text(
                                                'Delete "${t.name}"? This cannot be undone.',
                                                style: const TextStyle(
                                                  color: Color(0xFFBDD8DB),
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(ctx, false),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(ctx, true),
                                                  child: const Text(
                                                    'Delete',
                                                    style: TextStyle(
                                                      color: Color(0xFFEF4444),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirmed == true) {
                                            try {
                                              await repo.deleteTeam(t.id);
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
                                        case 'mark_active':
                                          try {
                                            await repo.updateTeamStatus(
                                              t.id,
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
                                                  backgroundColor: const Color(
                                                    0xFFEF4444,
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        case 'mark_inactive':
                                          try {
                                            await repo.updateTeamStatus(
                                              t.id,
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
                                                  backgroundColor: const Color(
                                                    0xFFEF4444,
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        case 'suspend':
                                          try {
                                            await repo.updateTeamStatus(
                                              t.id,
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
                                                  backgroundColor: const Color(
                                                    0xFFEF4444,
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        case 'detail':
                                          _showDetailModal(t);
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
                                          visualDensity: VisualDensity.compact,
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
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'mark_active',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              size: 16,
                                              color: t.status == 'active'
                                                  ? const Color(0xFF10B981)
                                                  : Colors.transparent,
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              'Active',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'mark_inactive',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              size: 16,
                                              color: t.status == 'inactive'
                                                  ? const Color(0xFF10B981)
                                                  : Colors.transparent,
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              'Inactive',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
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
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'detail',
                                        child: ListTile(
                                          leading: Icon(
                                            Icons.info_outline,
                                            color: Colors.white,
                                          ),
                                          title: Text(
                                            'Detail',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          contentPadding: EdgeInsets.zero,
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                    ],
                                  ),
                            onTap: _showingTrash
                                ? null
                                : () {
                                    final repo = _safeRepo();
                                    if (repo == null) return;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            RepositoryProvider.value(
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

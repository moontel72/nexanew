import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/core/config/api_config.dart';
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

  String _fullUrl(String path) {
    if (path.startsWith('http')) return path;
    return '${ApiConfig.baseUrl}$path';
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

  /// Returns players grouped by team, with each group sorted by position
  /// priority (ASC), then active-first, then name A–Z.
  Map<String?, List<PlayerModel>> get _sortedGrouped {
    final raw = <String?, List<PlayerModel>>{};
    for (final p in _filtered) {
      raw.putIfAbsent(p.teamId, () => []).add(p);
    }
    for (final list in raw.values) {
      list.sort((a, b) {
        final posC = _positionSort(
          a.position,
        ).compareTo(_positionSort(b.position));
        if (posC != 0) return posC;
        final activeA = a.status == 'active' ? 0 : 1;
        final activeB = b.status == 'active' ? 0 : 1;
        final statusC = activeA.compareTo(activeB);
        if (statusC != 0) return statusC;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    }
    // Sort group keys: named teams alphabetically, then "No Team" (null) last
    final sorted = <String?, List<PlayerModel>>{};
    final namedKeys = raw.keys.where((k) => k != null).toList()
      ..sort((a, b) {
        final teamA = _teams.cast<TeamModel?>().firstWhere(
          (t) => t!.id == a,
          orElse: () => null,
        );
        final teamB = _teams.cast<TeamModel?>().firstWhere(
          (t) => t!.id == b,
          orElse: () => null,
        );
        return (teamA?.name ?? '').toLowerCase().compareTo(
          (teamB?.name ?? '').toLowerCase(),
        );
      });
    for (final k in namedKeys) {
      sorted[k] = raw[k]!;
    }
    if (raw.containsKey(null)) {
      sorted[null] = raw[null]!;
    }
    return sorted;
  }

  int get _groupedItemCount {
    int c = 0;
    for (final entry in _sortedGrouped.entries) {
      c += 1 + entry.value.length; // header + players
    }
    return c;
  }

  Widget _buildGroupedItem(int index) {
    int cursor = 0;
    for (final entry in _sortedGrouped.entries) {
      if (index == cursor) return _buildTeamHeader(entry.key);
      cursor++;
      final groupLen = entry.value.length;
      if (index < cursor + groupLen) {
        return _buildPlayerCard(entry.value[index - cursor]);
      }
      cursor += groupLen;
    }
    return const SizedBox.shrink();
  }

  int _positionSort(String position) {
    switch (position) {
      case 'manager':
        return 0;
      case 'coach':
        return 1;
      case 'captain':
        return 2;
      case 'vice_captain':
        return 3;
      case 'player':
        return 4;
      case 'extra':
        return 5;
      default:
        return 6;
    }
  }

  Color _positionColor(String position) {
    switch (position) {
      case 'manager':
        return const Color(0xFF8B5CF6); // purple
      case 'coach':
        return const Color(0xFFF59E0B); // amber
      case 'captain':
        return const Color(0xFFF59E0B); // gold
      case 'vice_captain':
        return const Color(0xFF06B6D4); // teal
      case 'player':
        return const Color(0xFF2563EB); // blue
      case 'extra':
        return const Color(0xFF6B7280); // grey
      default:
        return const Color(0xFF2563EB);
    }
  }

  String _positionLabel(String position) {
    switch (position) {
      case 'manager':
        return 'Manager';
      case 'coach':
        return 'Coach';
      case 'captain':
        return 'Captain';
      case 'vice_captain':
        return 'Vice Captain';
      case 'player':
        return 'Player';
      case 'extra':
        return 'Extra';
      default:
        return position;
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  Widget _buildTeamHeader(String? teamId) {
    if (teamId == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFF1E2238),
              radius: 16,
              child: Icon(
                Icons.shield_outlined,
                color: Color(0xFFA0AAB8),
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'No Team',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }
    final team = _teams.cast<TeamModel?>().firstWhere(
      (t) => t!.id == teamId,
      orElse: () => null,
    );
    final name = team?.name ?? 'Unknown Team';
    final short = team?.shortCode ?? '';
    final logoUrl = team?.logoUrl;
    Color avatarColor = const Color(0xFF2563EB);
    if (team?.primaryColor != null && team!.primaryColor!.isNotEmpty) {
      try {
        avatarColor = Color(
          int.parse(team.primaryColor!.replaceFirst('#', '0xFF')),
        );
      } catch (_) {}
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: avatarColor,
            radius: 16,
            backgroundImage: logoUrl != null && logoUrl.isNotEmpty
                ? NetworkImage(_fullUrl(logoUrl))
                : null,
            child: logoUrl == null || logoUrl.isEmpty
                ? const Icon(
                    Icons.shield_outlined,
                    color: Colors.white,
                    size: 16,
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          if (short.isNotEmpty) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                short,
                style: const TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayerCard(PlayerModel p) {
    final posColor = _positionColor(p.position);
    final isActive = p.status == 'active';
    final isSuspended = p.status == 'suspended';

    Color statusDotColor;
    if (isActive) {
      statusDotColor = const Color(0xFF10B981);
    } else if (isSuspended) {
      statusDotColor = const Color(0xFFEF4444);
    } else {
      statusDotColor = const Color(0xFF6B7280);
    }

    return Card(
      color: const Color(0xFF0F2936),
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _showPlayerDetail(p),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Status dot
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusDotColor,
                ),
              ),
              // Player avatar
              GestureDetector(
                onTap: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.image,
                    withData: true,
                  );
                  if (result == null || result.files.isEmpty || !mounted) {
                    return;
                  }
                  final bytes = result.files.first.bytes;
                  final fileName = result.files.first.name;
                  if (bytes == null) return;

                  // Preview dialog with Save/Cancel
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: const Color(0xFF0F2936),
                      title: const Text(
                        'New Photo',
                        style: TextStyle(color: Colors.white),
                      ),
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
                          onPressed: () => Navigator.pop(ctx, false),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFEF4444),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: const Text('✕ CANCEL'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                          ),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('SAVE'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed != true || !mounted) return;
                  final repo = _safeRepo();
                  if (repo == null) return;
                  try {
                    await repo.uploadPlayerPhoto(p.id, bytes, fileName);
                    if (mounted) {
                      _load();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Photo updated'),
                          backgroundColor: Color(0xFF10B981),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed: $e'),
                          backgroundColor: Color(0xFFEF4444),
                        ),
                      );
                    }
                  }
                },
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: posColor.withOpacity(0.2),
                  backgroundImage: p.photoUrl != null && p.photoUrl!.isNotEmpty
                      ? NetworkImage(_fullUrl(p.photoUrl!))
                      : null,
                  child: p.photoUrl == null || p.photoUrl!.isEmpty
                      ? Text(
                          p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                          style: TextStyle(
                            color: posColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              // Player info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        decoration: (!isActive && !isSuspended)
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Position badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: posColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: posColor.withOpacity(0.5)),
                      ),
                      child: Text(
                        _positionLabel(p.position),
                        style: TextStyle(
                          color: posColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Jersey number
              if (p.jerseyNumber != null && p.jerseyNumber!.isNotEmpty)
                Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF6B7280).withOpacity(0.4),
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
                icon: const Icon(Icons.more_vert, color: Colors.white),
                color: const Color(0xFF0F2936),
                onSelected: (action) async {
                  final repo = _safeRepo();
                  if (repo == null) return;
                  switch (action) {
                    case 'edit':
                      _showEditPlayerDialog(p);
                      break;
                    case 'delete':
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: const Color(0xFF0F2936),
                          title: const Text(
                            'Delete Player',
                            style: TextStyle(color: Colors.white),
                          ),
                          content: Text(
                            'Delete "${p.name}"? This cannot be undone.',
                            style: const TextStyle(color: Color(0xFFBDD8DB)),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Color(0xFFEF4444)),
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$e'),
                                backgroundColor: const Color(0xFFEF4444),
                              ),
                            );
                          }
                        }
                      }
                    case 'mark_active':
                      try {
                        await repo.updatePlayerStatus(p.id, 'active');
                        _load();
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$e'),
                              backgroundColor: const Color(0xFFEF4444),
                            ),
                          );
                        }
                      }
                    case 'mark_inactive':
                      try {
                        await repo.updatePlayerStatus(p.id, 'inactive');
                        _load();
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$e'),
                              backgroundColor: const Color(0xFFEF4444),
                            ),
                          );
                        }
                      }
                    case 'suspend':
                      try {
                        await repo.updatePlayerStatus(p.id, 'suspended');
                        _load();
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$e'),
                              backgroundColor: const Color(0xFFEF4444),
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
                      leading: Icon(Icons.edit, color: Colors.white),
                      title: Text(
                        'Edit',
                        style: TextStyle(color: Colors.white),
                      ),
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Color(0xFFEF4444)),
                      title: Text(
                        'Delete',
                        style: TextStyle(color: Color(0xFFEF4444)),
                      ),
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  if (p.status == 'active')
                    const PopupMenuItem(
                      value: 'mark_inactive',
                      child: ListTile(
                        leading: Icon(Icons.block, color: Colors.white70),
                        title: Text(
                          'Mark Inactive',
                          style: TextStyle(color: Colors.white70),
                        ),
                        contentPadding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
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
                          style: TextStyle(color: Color(0xFF10B981)),
                        ),
                        contentPadding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
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
                        style: TextStyle(color: Color(0xFFF97316)),
                      ),
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPlayerDetail(PlayerModel p) {
    final age = _calcAge(p.dateOfBirth);
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Align(
        alignment: Alignment.topCenter,
        child: Material(
          color: const Color(0xFF0F2936),
          type: MaterialType.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520, maxHeight: 650),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header: photo + code + name
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: _positionColor(p.position),
                          backgroundImage:
                              p.photoUrl != null && p.photoUrl!.isNotEmpty
                              ? NetworkImage(_fullUrl(p.photoUrl!))
                              : null,
                          child: p.photoUrl == null || p.photoUrl!.isEmpty
                              ? const Icon(
                                  Icons.sports_cricket,
                                  color: Colors.white,
                                  size: 30,
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (p.playerCode != null &&
                                  p.playerCode!.isNotEmpty)
                                Text(
                                  'CODE: ${p.playerCode}',
                                  style: const TextStyle(
                                    color: Color(0xFF10B981),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Color(0xFF6B7280),
                          ),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Partition 1: Position + Role (blue)
                    _detailRow(
                      'POSITION',
                      _positionLabel(p.position),
                      const Color(0xFF2563EB),
                      const Color(0xFFFFD54F),
                    ),
                    const SizedBox(height: 8),
                    _detailRow(
                      'ROLE TYPE',
                      _roleLabel(p.role),
                      const Color(0xFF1D4ED8),
                      const Color(0xFFFFD54F),
                    ),
                    const SizedBox(height: 8),
                    // Partition 2: Playing styles (purple)
                    _detailRow(
                      'BATTING STYLE',
                      p.battingStyle?.replaceAll('_', ' ').toUpperCase() ?? '—',
                      const Color(0xFF8B5CF6),
                      const Color(0xFFFFB74D),
                    ),
                    const SizedBox(height: 8),
                    _detailRow(
                      'BOWLING STYLE',
                      p.bowlingStyle?.replaceAll('_', ' ').toUpperCase() ?? '—',
                      const Color(0xFF7C3AED),
                      const Color(0xFFFFB74D),
                    ),
                    const SizedBox(height: 8),
                    // Partition 3: Identity (teal)
                    _detailRow(
                      'JERSEY NUMBER',
                      p.jerseyNumber ?? '—',
                      const Color(0xFF06B6D4),
                      const Color(0xFFFFF59D),
                    ),
                    const SizedBox(height: 8),
                    _detailRow(
                      'AGE',
                      age != null ? '$age' : '—',
                      const Color(0xFF0EA5E9),
                      const Color(0xFFFFF59D),
                    ),
                    const SizedBox(height: 8),
                    // Partition 4: Contact (green)
                    _detailRow(
                      'EMAIL',
                      p.email ?? '—',
                      const Color(0xFF10B981),
                      const Color(0xFFFFCC80),
                    ),
                    const SizedBox(height: 8),
                    _detailRow(
                      'PHONE',
                      p.phone ?? '—',
                      const Color(0xFF059669),
                      const Color(0xFFFFCC80),
                    ),
                    const SizedBox(height: 8),
                    _detailRow(
                      'ID CARD',
                      p.idCardNumber ?? '—',
                      const Color(0xFF047857),
                      const Color(0xFFFFCC80),
                    ),
                    const SizedBox(height: 8),
                    // Partition 5: Status (color by status)
                    _detailRow(
                      'STATUS',
                      p.status.toUpperCase(),
                      p.status == 'active'
                          ? const Color(0xFF10B981)
                          : p.status == 'inactive'
                          ? const Color(0xFF6B7280)
                          : const Color(0xFFEF4444),
                      Colors.white,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('CLOSE'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _roleLabel(String? role) {
    switch (role) {
      case 'batsman':
        return 'Batsman';
      case 'bowler':
        return 'Bowler';
      case 'all_rounder':
        return 'All Rounder';
      case 'wicket_keeper':
        return 'Wicket Keeper';
      default:
        return '—';
    }
  }

  int? _calcAge(String? dob) {
    if (dob == null || dob.isEmpty) return null;
    try {
      final parts = dob.split('-');
      final birth = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      final now = DateTime.now();
      var age = now.year - birth.year;
      if (now.month < birth.month ||
          (now.month == birth.month && now.day < birth.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return null;
    }
  }

  Widget _detailRow(String label, String value, Color color, Color labelColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
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

  Future<void> _showEditPlayerDialog(PlayerModel player) async {
    final nameCtrl = TextEditingController(text: player.name);
    final jerseyCtrl = TextEditingController(text: player.jerseyNumber ?? '');
    final emailCtrl = TextEditingController(text: player.email ?? '');
    final phoneCtrl = TextEditingController(text: player.phone ?? '');
    final idCardCtrl = TextEditingController(text: player.idCardNumber ?? '');
    String selectedPosition = player.position;
    String selectedStatus = player.status;
    String? selectedTeamId = player.teamId;
    String? selectedRole = player.role;
    String? selectedBattingStyle = player.battingStyle;
    String? selectedBowlingStyle = player.bowlingStyle;
    DateTime? selectedDob;
    if (player.dateOfBirth != null) {
      selectedDob = DateTime.tryParse(player.dateOfBirth!);
    }
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF0F2936),
          title: const Text(
            'Edit Player',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name field
                  TextFormField(
                    controller: nameCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: _darkInputDecoration('Name'),
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  // Position dropdown
                  DropdownButtonFormField<String>(
                    value: selectedPosition,
                    dropdownColor: const Color(0xFF0F2936),
                    style: const TextStyle(color: Colors.white),
                    decoration: _darkInputDecoration('Position'),
                    items:
                        [
                              'player',
                              'captain',
                              'vice_captain',
                              'coach',
                              'manager',
                              'extra',
                            ]
                            .map(
                              (p) => DropdownMenuItem(
                                value: p,
                                child: Text(_positionLabel(p)),
                              ),
                            )
                            .toList(),
                    onChanged: (v) =>
                        setDialogState(() => selectedPosition = v!),
                  ),
                  const SizedBox(height: 12),
                  // Role Type dropdown
                  DropdownButtonFormField<String?>(
                    value: selectedRole,
                    dropdownColor: const Color(0xFF0F2936),
                    style: const TextStyle(color: Colors.white),
                    decoration: _darkInputDecoration('Role Type'),
                    items: const [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text('None'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'batsman',
                        child: Text('Batsman'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'bowler',
                        child: Text('Bowler'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'all_rounder',
                        child: Text('All Rounder'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'wicket_keeper',
                        child: Text('Wicket Keeper'),
                      ),
                    ],
                    onChanged: (v) => setDialogState(() => selectedRole = v),
                  ),
                  const SizedBox(height: 12),
                  // Batting style dropdown
                  DropdownButtonFormField<String?>(
                    value: selectedBattingStyle,
                    dropdownColor: const Color(0xFF0F2936),
                    style: const TextStyle(color: Colors.white),
                    decoration: _darkInputDecoration('Batting Style'),
                    items: const [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text('None'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'right_hand',
                        child: Text('Right Hand'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'left_hand',
                        child: Text('Left Hand'),
                      ),
                    ],
                    onChanged: (v) =>
                        setDialogState(() => selectedBattingStyle = v),
                  ),
                  const SizedBox(height: 12),
                  // Bowling style dropdown
                  DropdownButtonFormField<String?>(
                    value: selectedBowlingStyle,
                    dropdownColor: const Color(0xFF0F2936),
                    style: const TextStyle(color: Colors.white),
                    decoration: _darkInputDecoration('Bowling Style'),
                    items: const [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text('None'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'right_arm_fast',
                        child: Text('Right Arm Fast'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'left_arm_fast',
                        child: Text('Left Arm Fast'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'right_arm_off_spin',
                        child: Text('Off Spin'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'right_arm_leg_spin',
                        child: Text('Leg Spin'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'left_arm_orthodox',
                        child: Text('Orthodox'),
                      ),
                    ],
                    onChanged: (v) =>
                        setDialogState(() => selectedBowlingStyle = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    dropdownColor: const Color(0xFF0F2936),
                    style: const TextStyle(color: Colors.white),
                    decoration: _darkInputDecoration('Status'),
                    items: ['active', 'inactive', 'suspended']
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(s[0].toUpperCase() + s.substring(1)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setDialogState(() => selectedStatus = v!),
                  ),
                  const SizedBox(height: 12),
                  // Team transfer dropdown
                  DropdownButtonFormField<String>(
                    value: selectedTeamId,
                    dropdownColor: const Color(0xFF0F2936),
                    style: const TextStyle(color: Colors.white),
                    decoration: _darkInputDecoration('Team (Transfer)'),
                    hint: const Text(
                      'Select team',
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                    items: _teams
                        .map(
                          (t) => DropdownMenuItem(
                            value: t.id,
                            child: Text(
                              '${t.name} ${t.teamCode != null ? "(${t.teamCode})" : ""}',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setDialogState(() => selectedTeamId = v),
                  ),
                  const SizedBox(height: 12),
                  // Jersey number
                  TextFormField(
                    controller: jerseyCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: _darkInputDecoration('Jersey Number'),
                  ),
                  const SizedBox(height: 12),
                  // Email
                  TextFormField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: _darkInputDecoration('Email'),
                  ),
                  const SizedBox(height: 12),
                  // Phone
                  TextFormField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white),
                    decoration: _darkInputDecoration('Phone'),
                  ),
                  const SizedBox(height: 12),
                  // ID Card Number
                  TextFormField(
                    controller: idCardCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: _darkInputDecoration('ID Card Number'),
                  ),
                  const SizedBox(height: 12),
                  // Date of Birth
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: selectedDob ?? DateTime(2000),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                        builder: (pickerCtx, child) => Theme(
                          data: ThemeData.dark().copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: Color(0xFF10B981),
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        setDialogState(() => selectedDob = picked);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C1D2C),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0x20FFFFFF)),
                      ),
                      child: Text(
                        selectedDob != null
                            ? '${selectedDob!.year}-${selectedDob!.month.toString().padLeft(2, '0')}-${selectedDob!.day.toString().padLeft(2, '0')}'
                            : 'Date of Birth',
                        style: TextStyle(
                          color: selectedDob != null
                              ? Colors.white
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('✕ CANCEL'),
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
                  await repo.updatePlayer(
                    playerId: player.id,
                    name: nameCtrl.text.trim(),
                    position: selectedPosition,
                    status: selectedStatus,
                    teamId: selectedTeamId,
                    jerseyNumber: jerseyCtrl.text.trim().isEmpty
                        ? null
                        : jerseyCtrl.text.trim(),
                    role: selectedRole,
                    battingStyle: selectedBattingStyle,
                    bowlingStyle: selectedBowlingStyle,
                    email: emailCtrl.text.trim().isEmpty
                        ? null
                        : emailCtrl.text.trim(),
                    phone: phoneCtrl.text.trim().isEmpty
                        ? null
                        : phoneCtrl.text.trim(),
                    idCardNumber: idCardCtrl.text.trim().isEmpty
                        ? null
                        : idCardCtrl.text.trim(),
                    dateOfBirth: selectedDob != null
                        ? '${selectedDob!.year}-${selectedDob!.month.toString().padLeft(2, '0')}-${selectedDob!.day.toString().padLeft(2, '0')}'
                        : null,
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
          content: Text('Player updated'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
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
                : _showingTrash
                ? RefreshIndicator(
                    onRefresh: () async => _loadTrash(),
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
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: _positionColor(p.position),
                                  radius: 22,
                                  backgroundImage:
                                      p.photoUrl != null &&
                                          p.photoUrl!.isNotEmpty
                                      ? NetworkImage(_fullUrl(p.photoUrl!))
                                      : null,
                                  child:
                                      p.photoUrl == null || p.photoUrl!.isEmpty
                                      ? const Icon(
                                          Icons.sports_cricket,
                                          color: Colors.white,
                                          size: 20,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        p.deletedAt != null
                                            ? 'Deleted ${_formatDate(p.deletedAt!)}'
                                            : '(deleted)',
                                        style: const TextStyle(
                                          color: Color(0xFFEF4444),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
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
                                                content: Text('$e'),
                                                backgroundColor: const Color(
                                                  0xFFEF4444,
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                    TextButton.icon(
                                      icon: const Icon(
                                        Icons.delete_forever,
                                        size: 18,
                                      ),
                                      label: const Text('Delete Forever'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: const Color(
                                          0xFFEF4444,
                                        ),
                                      ),
                                      onPressed: () async {
                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            backgroundColor: const Color(
                                              0xFF0F2936,
                                            ),
                                            title: const Text(
                                              'Permanently Delete Player?',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            content: Text(
                                              '"${p.name}" will be permanently deleted and cannot be restored.',
                                              style: const TextStyle(
                                                color: Color(0xFFBDD8DB),
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, false),
                                                child: const Text('CANCEL'),
                                              ),
                                              TextButton(
                                                style: TextButton.styleFrom(
                                                  foregroundColor: const Color(
                                                    0xFFEF4444,
                                                  ),
                                                ),
                                                onPressed: () =>
                                                    Navigator.pop(ctx, true),
                                                child: const Text(
                                                  'DELETE FOREVER',
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirmed != true || !mounted) {
                                          return;
                                        }
                                        final repo = _safeRepo();
                                        if (repo == null) return;
                                        try {
                                          await repo.permanentlyDeletePlayer(
                                            p.id,
                                          );
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  '${p.name} permanently deleted',
                                                ),
                                                backgroundColor: const Color(
                                                  0xFFEF4444,
                                                ),
                                              ),
                                            );
                                            _loadTrash();
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text('$e'),
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
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async => _load(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: _groupedItemCount,
                      itemBuilder: (_, i) => _buildGroupedItem(i),
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

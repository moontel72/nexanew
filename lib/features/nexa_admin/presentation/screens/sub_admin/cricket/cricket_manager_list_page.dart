import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/core/services/api_client.dart';
import 'package:trace_odd/shared/widgets/status_badge.dart';

/// Sub-Admin page: List all Cricket Operations Managers.
class CricketManagerListPage extends StatefulWidget {
  const CricketManagerListPage({super.key});

  @override
  State<CricketManagerListPage> createState() => _CricketManagerListPageState();
}

class _CricketManagerListPageState extends State<CricketManagerListPage> {
  final ApiClient _api = ApiClient();
  List<Map<String, dynamic>> _managers = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchManagers();
  }

  Future<void> _fetchManagers() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _api.get('/api/v1/cricket/admin/managers');
      if (res is Map && res['data'] is List) {
        _managers = List<Map<String, dynamic>>.from(res['data']);
      }
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1D2C),
      appBar: AppBar(
        title: const Text(
          'Cricket Operations Managers',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFF0F2936),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/sub-admin/dashboard'),
          tooltip: 'Back to Dashboard',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchManagers,
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        onPressed: () => context.go('/sub-admin/cricket/managers/add'),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Manager'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const Gap(12),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const Gap(12),
                  ElevatedButton(
                    onPressed: _fetchManagers,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _managers.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.people_outline,
                    color: Colors.white38,
                    size: 64,
                  ),
                  const Gap(16),
                  const Text(
                    'No cricket managers provisioned yet.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const Gap(8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () =>
                        context.go('/sub-admin/cricket/managers/add'),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add First Manager'),
                  ),
                  const Gap(24),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                      ),
                    ),
                    child: const Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Color(0xFF10B981),
                              size: 16,
                            ),
                            Gap(6),
                            Text(
                              'Manager Login',
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Gap(4),
                        SelectableText(
                          '/cricket-manager/login',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _managers.length + 1, // +1 for login info card
              itemBuilder: (ctx, i) {
                if (i == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF10B981).withOpacity(0.3),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Color(0xFF10B981),
                            size: 16,
                          ),
                          Gap(8),
                          Text(
                            'Manager Login:',
                            style: TextStyle(
                              color: Color(0xFF10B981),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          Gap(4),
                          SelectableText(
                            '/cricket-manager/login',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                final m = _managers[i - 1];
                return _ManagerCard(
                  manager: m,
                  onToggle: () => _toggleStatus(m),
                  onEdit: () =>
                      context.go('/sub-admin/cricket/managers/edit', extra: m),
                  onDelete: () => _confirmDelete(m),
                );
              },
            ),
    );
  }

  Future<void> _toggleStatus(Map<String, dynamic> manager) async {
    final id = manager['id'] as String;
    final isActive = manager['status'] == 'active';
    try {
      if (isActive) {
        await _api.post('/api/v1/cricket/admin/managers/$id/suspend');
      } else {
        await _api.post('/api/v1/cricket/admin/managers/$id/activate');
      }
      _fetchManagers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _confirmDelete(Map<String, dynamic> manager) async {
    final name = manager['name']?.toString() ?? 'this manager';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B3A4B),
        title: const Text(
          'Delete this Cricket Manager?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: Text(
          '$name will be permanently removed and lose panel access.',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final id = manager['id'];
    try {
      await _api.delete('/api/v1/cricket/admin/managers/$id');
      _fetchManagers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Manager deleted.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

class _ManagerCard extends StatelessWidget {
  final Map<String, dynamic> manager;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ManagerCard({
    required this.manager,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = manager['status'] == 'active';
    final permissions = manager['permissions'] is Map
        ? manager['permissions'] as Map
        : const <String, dynamic>{};
    final canAccessStudio = permissions['can_access_studio'] == true;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: const Color(0xFF1B3A4B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isActive ? const Color(0xFF10B981) : Colors.grey,
          child: Text(
            (manager['name'] as String? ?? 'M')[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          manager['name'] ?? 'Unknown',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              manager['email'] ?? '',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            if (canAccessStudio) ...[
              const Gap(4),
              const StatusBadge(
                label: 'Studio Access',
                color: Color(0xFF8B5CF6),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white70, size: 20),
              onPressed: onEdit,
              tooltip: 'Edit',
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 20,
              ),
              onPressed: onDelete,
              tooltip: 'Delete',
              visualDensity: VisualDensity.compact,
            ),
            Text(
              isActive ? 'ACTIVE' : 'SUSPENDED',
              style: TextStyle(
                color: isActive ? const Color(0xFF10B981) : Colors.red,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Gap(8),
            Tooltip(
              message: 'Suspend / Activate',
              child: Switch(
                value: isActive,
                activeColor: const Color(0xFF10B981),
                onChanged: (_) => onToggle(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

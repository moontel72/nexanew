import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/core/services/api_client.dart';
import 'package:trace_odd/shared/theme/colors.dart';

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
      backgroundColor: AppColors.adminContentBackground,
      appBar: AppBar(
        title: const Text('Cricket Operations Managers'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchManagers,
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
          ? const Center(
              child: Text(
                'No cricket managers provisioned yet.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _managers.length,
              itemBuilder: (ctx, i) {
                final m = _managers[i];
                return _ManagerCard(
                  manager: m,
                  onToggle: () => _toggleStatus(m),
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
}

class _ManagerCard extends StatelessWidget {
  final Map<String, dynamic> manager;
  final VoidCallback onToggle;

  const _ManagerCard({required this.manager, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isActive = manager['status'] == 'active';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
        subtitle: Text(
          manager['email'] ?? '',
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        trailing: Switch(
          value: isActive,
          activeColor: const Color(0xFF10B981),
          onChanged: (_) => onToggle(),
        ),
      ),
    );
  }
}

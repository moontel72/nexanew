// NEXATRACE — ROUTE LIST SCREEN
// ================================
// Management dashboard listing all transit routes.
// Shows route code, display name, waypoint count,
// status, and publish/delete actions.
//
// MODULE: 13B — Dynamic Route & Waypoint Line Scheduler

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/core/services/api_service.dart';

class RouteListScreen extends StatefulWidget {
  const RouteListScreen({super.key});
  @override
  State<RouteListScreen> createState() => _RouteListScreenState();
}

class _RouteListScreenState extends State<RouteListScreen> {
  final _api = ApiService();
  List<Map<String, dynamic>> _routes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final r = await _api.get('/bus-fleet/routes');
      setState(() {
        _routes = List<Map<String, dynamic>>.from(r['data'] ?? []);
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _delete(String id) async {
    await _api.delete('/bus-fleet/routes/$id');
    _fetch();
  }

  Future<void> _publish(String id) async {
    await _api.post('/bus-fleet/routes/$id/publish');
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Routes',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const RouteEditorScreen(carrierCompanyId: ''),
            ),
          );
          if (result == true) _fetch();
        },
        icon: const Icon(Icons.add),
        label: const Text('New Route'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _routes.isEmpty
          ? _buildEmpty()
          : RefreshIndicator(
              onRefresh: _fetch,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _routes.length,
                itemBuilder: (_, i) {
                  final r = _routes[i];
                  final wps = r['waypoints'] as List? ?? [];
                  final isPublished = r['status'] == 'published';
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color:
                                  (isPublished
                                          ? const Color(0xFF16A34A)
                                          : const Color(0xFFF59E0B))
                                      .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isPublished
                                  ? Icons.check_circle
                                  : Icons.edit_road,
                              color: isPublished
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFF59E0B),
                              size: 20,
                            ),
                          ),
                          const Gap(12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r['display_name'] ?? '',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Gap(2),
                                Text(
                                  '${r['route_code']} · ${wps.length} stops · ${(r['total_distance_km'] ?? 0).toStringAsFixed(0)} km',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isPublished)
                            IconButton(
                              icon: const Icon(
                                Icons.publish,
                                size: 18,
                                color: Color(0xFF16A34A),
                              ),
                              tooltip: 'Publish',
                              onPressed: () => _publish(r['id']),
                            ),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RouteEditorScreen(
                                    routeId: r['id'],
                                    carrierCompanyId: '',
                                  ),
                                ),
                              );
                              if (result == true) _fetch();
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Color(0xFFEF4444),
                            ),
                            onPressed: () => _delete(r['id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildEmpty() => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.alt_route, size: 64, color: Color(0xFFCBD5E1)),
        Gap(16),
        Text(
          'No routes yet',
          style: TextStyle(fontSize: 16, color: Color(0xFF94A3B8)),
        ),
        Gap(8),
        Text(
          'Tap + to create your first transit route',
          style: TextStyle(fontSize: 13, color: Color(0xFFCBD5E1)),
        ),
      ],
    ),
  );
}

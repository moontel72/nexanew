// NEXATRACE — ROUTE SCHEDULER SCREEN
// ====================================
// Create multi-stopover bus routes with departure/arrival
// times, waypoint management, and publish workflow.
//
// MODULE: 13B — Dynamic Route & Waypoint Line Scheduler

import 'package:flutter/material.dart';
import 'package:trace_odd/core/services/api_service.dart';

class RouteSchedulerScreen extends StatefulWidget {
  final String panelPrefix; // '/bus-fleet' or '/bus-owner'
  const RouteSchedulerScreen({super.key, this.panelPrefix = '/bus-fleet'});

  @override
  State<RouteSchedulerScreen> createState() => _RouteSchedulerScreenState();
}

class _RouteSchedulerScreenState extends State<RouteSchedulerScreen> {
  final _api = ApiService();
  List<Map<String, dynamic>> _routes = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _api.get('${widget.panelPrefix}/routes');
      final data = res?['data'];
      if (data is List) {
        _routes = data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _deleteRoute(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Route?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _api.delete('${widget.panelPrefix}/routes/$id');
      _loadRoutes();
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _publishRoute(String id) async {
    try {
      await _api.post('${widget.panelPrefix}/routes/$id/publish');
      _loadRoutes();
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Route published!')));
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Publish failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Route Scheduler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Route',
            onPressed: () => _showRouteEditor(),
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadRoutes),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _loadRoutes,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _routes.isEmpty
          ? const Center(child: Text('No routes yet. Tap + to create one.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _routes.length,
              itemBuilder: (_, i) => _routeCard(_routes[i]),
            ),
    );
  }

  Widget _routeCard(Map<String, dynamic> r) {
    final status = r['status'] ?? 'draft';
    final color = status == 'published'
        ? const Color(0xFF16A34A)
        : const Color(0xFFF59E0B);
    final waypoints = (r['waypoints'] as List<dynamic>?) ?? [];
    final wpStr = waypoints.map((w) => w['station_name'] ?? '').join(' → ');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    r['display_name'] ?? 'Untitled',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              r['route_code'] ?? '',
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            if (wpStr.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(wpStr, style: const TextStyle(fontSize: 13)),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${r['origin_city'] ?? ''} → ${r['destination_city'] ?? ''}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF475569),
                  ),
                ),
                const Spacer(),
                if (r['total_distance_km'] != null)
                  Text(
                    '${r['total_distance_km']} km',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _actionBtn(
                  Icons.edit,
                  'Edit',
                  () => _showRouteEditor(route: r),
                ),
                const SizedBox(width: 8),
                _actionBtn(
                  Icons.attach_money,
                  'Pricing',
                  () => _showPricingEditor(r),
                ),
                const SizedBox(width: 8),
                if (status == 'draft')
                  _actionBtn(
                    Icons.publish,
                    'Publish',
                    () => _publishRoute(r['id']),
                    color: const Color(0xFF16A34A),
                  ),
                const Spacer(),
                _actionBtn(
                  Icons.delete,
                  'Delete',
                  () => _deleteRoute(r['id']),
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color color = const Color(0xFF475569),
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }

  void _showRouteEditor({Map<String, dynamic>? route}) {
    final nameCtrl = TextEditingController(text: route?['display_name'] ?? '');
    final codeCtrl = TextEditingController(text: route?['route_code'] ?? '');
    final originCtrl = TextEditingController(text: route?['origin_city'] ?? '');
    final destCtrl = TextEditingController(
      text: route?['destination_city'] ?? '',
    );
    final olatCtrl = TextEditingController(
      text: route?['origin_lat']?.toString() ?? '',
    );
    final olngCtrl = TextEditingController(
      text: route?['origin_lng']?.toString() ?? '',
    );
    final dlatCtrl = TextEditingController(
      text: route?['destination_lat']?.toString() ?? '',
    );
    final dlngCtrl = TextEditingController(
      text: route?['destination_lng']?.toString() ?? '',
    );
    // Waypoints editor
    List<_WaypointEntry> waypoints = [];
    if (route != null) {
      final wps = (route['waypoints'] as List<dynamic>?) ?? [];
      for (final w in wps) {
        waypoints.add(
          _WaypointEntry(
            stationCtrl: TextEditingController(text: w['station_name'] ?? ''),
            latCtrl: TextEditingController(text: w['lat']?.toString() ?? ''),
            lngCtrl: TextEditingController(text: w['lng']?.toString() ?? ''),
          ),
        );
      }
    }

    final isEdit = route != null;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          title: Text(isEdit ? 'Edit Route' : 'New Route'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Display Name',
                    hintText: 'Lahore → Islamabad Express',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Route Code',
                    hintText: 'LHR-ISB-001',
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Origin',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                TextField(
                  controller: originCtrl,
                  decoration: const InputDecoration(labelText: 'Origin City'),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: olatCtrl,
                        decoration: const InputDecoration(labelText: 'Lat'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: olngCtrl,
                        decoration: const InputDecoration(labelText: 'Lng'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Destination',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                TextField(
                  controller: destCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Destination City',
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: dlatCtrl,
                        decoration: const InputDecoration(labelText: 'Lat'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: dlngCtrl,
                        decoration: const InputDecoration(labelText: 'Lng'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      'Stopovers',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Stop'),
                      onPressed: () {
                        setDlg(() {
                          waypoints.add(
                            _WaypointEntry(
                              stationCtrl: TextEditingController(),
                              latCtrl: TextEditingController(),
                              lngCtrl: TextEditingController(),
                            ),
                          );
                        });
                      },
                    ),
                  ],
                ),
                ...waypoints.asMap().entries.map(
                  (e) => _waypointRow(e.key, e.value, () {
                    setDlg(() {
                      waypoints.removeAt(e.key);
                      e.value.dispose();
                    });
                  }),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final body = <String, dynamic>{
                  'display_name': nameCtrl.text,
                  'route_code': codeCtrl.text,
                  'origin_city': originCtrl.text,
                  'destination_city': destCtrl.text,
                  'origin_lat': double.tryParse(olatCtrl.text) ?? 0,
                  'origin_lng': double.tryParse(olngCtrl.text) ?? 0,
                  'destination_lat': double.tryParse(dlatCtrl.text) ?? 0,
                  'destination_lng': double.tryParse(dlngCtrl.text) ?? 0,
                };
                try {
                  if (isEdit) {
                    await _api.put(
                      '${widget.panelPrefix}/routes/${route!['id']}',
                      body: body,
                    );
                  } else {
                    final r = await _api.post(
                      '${widget.panelPrefix}/routes',
                      body: body,
                    );
                    final newId = r?['data']?['id']?.toString();
                    // Save waypoints if any
                    if (newId != null && waypoints.isNotEmpty) {
                      final wpBody = {
                        'waypoints': waypoints
                            .map(
                              (w) => {
                                'station_name': w.stationCtrl.text,
                                'lat': double.tryParse(w.latCtrl.text) ?? 0,
                                'lng': double.tryParse(w.lngCtrl.text) ?? 0,
                              },
                            )
                            .toList(),
                      };
                      await _api.post(
                        '${widget.panelPrefix}/routes/$newId/waypoints',
                        body: wpBody,
                      );
                    }
                  }
                  Navigator.pop(context);
                  _loadRoutes();
                } catch (e) {
                  if (mounted)
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: Text(isEdit ? 'Update' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _waypointRow(int idx, _WaypointEntry w, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: w.stationCtrl,
              decoration: InputDecoration(
                labelText: 'Stop ${idx + 1}',
                hintText: 'Station name',
              ),
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 60,
            child: TextField(
              controller: w.latCtrl,
              decoration: const InputDecoration(labelText: 'Lat'),
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 60,
            child: TextField(
              controller: w.lngCtrl,
              decoration: const InputDecoration(labelText: 'Lng'),
              keyboardType: TextInputType.number,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle, color: Colors.red, size: 20),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }

  void _showPricingEditor(Map<String, dynamic> route) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoutePricingScreen(
          routeId: route['id'],
          routeName: route['display_name'] ?? '',
          waypoints: (route['waypoints'] as List<dynamic>?) ?? [],
          panelPrefix: widget.panelPrefix,
        ),
      ),
    );
  }
}

// ── Waypoint Entry ──
class _WaypointEntry {
  final TextEditingController stationCtrl, latCtrl, lngCtrl;
  _WaypointEntry({
    required this.stationCtrl,
    required this.latCtrl,
    required this.lngCtrl,
  });
  void dispose() {
    stationCtrl.dispose();
    latCtrl.dispose();
    lngCtrl.dispose();
  }
}

// ── Pricing Screen ──
class RoutePricingScreen extends StatefulWidget {
  final String routeId, routeName, panelPrefix;
  final List<dynamic> waypoints;
  const RoutePricingScreen({
    super.key,
    required this.routeId,
    required this.routeName,
    required this.waypoints,
    this.panelPrefix = '/bus-fleet',
  });

  @override
  State<RoutePricingScreen> createState() => _RoutePricingScreenState();
}

class _RoutePricingScreenState extends State<RoutePricingScreen> {
  final _api = ApiService();
  List<Map<String, dynamic>> _prices = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await _api.get(
        '${widget.panelPrefix}/routes/${widget.routeId}/pricing',
      );
      final data = res?['data'];
      if (data != null && data['prices'] != null) {
        _prices = (data['prices'] as List).cast<Map<String, dynamic>>();
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    final body = {'prices': _prices};
    try {
      await _api.put(
        '${widget.panelPrefix}/routes/${widget.routeId}/pricing',
        body: body,
      );
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Prices saved!')));
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pricing: ${widget.routeName}'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _save)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: _buildPriceRows(),
            ),
    );
  }

  List<Widget> _buildPriceRows() {
    final wps = widget.waypoints;
    final widgets = <Widget>[];
    for (int i = 0; i < wps.length; i++) {
      for (int j = i + 1; j < wps.length; j++) {
        final from = wps[i]['station_name'] ?? 'Stop $i';
        final to = wps[j]['station_name'] ?? 'Stop $j';
        final existing = _prices
            .where((p) => p['from_stop_order'] == i && p['to_stop_order'] == j)
            .firstOrNull;
        final ctrl = TextEditingController(
          text: existing?['price']?.toString() ?? '',
        );

        widgets.add(
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '$from → $to',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  const Text('Rs. '),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: ctrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: '0'),
                      onChanged: (v) {
                        final price = double.tryParse(v) ?? 0;
                        final idx = _prices.indexWhere(
                          (p) =>
                              p['from_stop_order'] == i &&
                              p['to_stop_order'] == j,
                        );
                        final entry = {
                          'from_stop_order': i,
                          'to_stop_order': j,
                          'from_station': from,
                          'to_station': to,
                          'price': price,
                          'seat_category': 'standard',
                        };
                        if (idx >= 0) {
                          _prices[idx] = entry;
                        } else {
                          _prices.add(entry);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
    if (widgets.isEmpty)
      widgets.add(
        const Center(
          child: Text('No waypoints. Add stops to the route first.'),
        ),
      );
    return widgets;
  }
}

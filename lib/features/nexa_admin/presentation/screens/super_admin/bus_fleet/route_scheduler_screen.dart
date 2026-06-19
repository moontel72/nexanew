// NEXATRACE — ROUTE SCHEDULER SCREEN v3
// ====================================
// Multi-stopover routes with departure time, arrival times,
// city-to-city pricing. No Lat/Lng fields.
//
// MODULE: 13B — Dynamic Route & Waypoint Line Scheduler

import 'package:flutter/material.dart';
import 'package:trace_odd/core/services/api_service.dart';

class RouteSchedulerScreen extends StatefulWidget {
  final String panelPrefix;
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
      if (data is List) _routes = data.cast<Map<String, dynamic>>();
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
                  Icons.visibility,
                  'View',
                  () => _showRouteDetail(r),
                  color: const Color(0xFF0D9488),
                ),
                const SizedBox(width: 8),
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

  // ═══ ROUTE DETAIL VIEW ═══
  void _showRouteDetail(Map<String, dynamic> r) {
    final waypoints = (r['waypoints'] as List<dynamic>?) ?? [];
    final depTime = _metaStr(r, 'departure_time');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(r['display_name'] ?? 'Route Detail'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Route Code', r['route_code'] ?? '—'),
              _detailRow(
                'Status',
                (r['status'] ?? 'draft').toString().toUpperCase(),
              ),
              _detailRow('From', r['origin_city'] ?? '—'),
              _detailRow('To', r['destination_city'] ?? '—'),
              if (depTime.isNotEmpty) _detailRow('Bus Departure', depTime),
              if (r['total_distance_km'] != null)
                _detailRow('Distance', '${r['total_distance_km']} km'),
              if (waypoints.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Stopovers:',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 6),
                ...waypoints.asMap().entries.map((e) {
                  final w = e.value;
                  final arr = _metaStr(w, 'arrival_time');
                  final stay = _metaStr(w, 'stay_minutes');
                  final dep = _metaStr(w, 'departure_time');
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${e.key + 1}. ${w['station_name'] ?? 'Stop ${e.key + 1}'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        if (arr.isNotEmpty || stay.isNotEmpty || dep.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Wrap(
                              spacing: 12,
                              children: [
                                if (arr.isNotEmpty)
                                  Text(
                                    'Arr: $arr',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                if (stay.isNotEmpty)
                                  Text(
                                    'Stay: ${stay}m',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFD97706),
                                    ),
                                  ),
                                if (dep.isNotEmpty)
                                  Text(
                                    'Dep: $dep',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF059669),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    ),
  );

  // ═══ ROUTE EDITOR DIALOG ═══
  void _showRouteEditor({Map<String, dynamic>? route}) {
    final nameCtrl = TextEditingController(text: route?['display_name'] ?? '');
    final codeCtrl = TextEditingController(text: route?['route_code'] ?? '');
    final originCtrl = TextEditingController(text: route?['origin_city'] ?? '');
    final destCtrl = TextEditingController(
      text: route?['destination_city'] ?? '',
    );
    final depCtrl = TextEditingController(
      text: _metaStr(route, 'departure_time'),
    );
    List<TextEditingController> stopCtrls = [];
    List<TextEditingController> stopArrCtrls = [];
    List<TextEditingController> stopStayCtrls = [];
    List<TextEditingController> stopDepCtrls = [];
    if (route != null) {
      final wps = (route['waypoints'] as List<dynamic>?) ?? [];
      for (final w in wps) {
        stopCtrls.add(TextEditingController(text: w['station_name'] ?? ''));
        stopArrCtrls.add(
          TextEditingController(text: _metaStr(w, 'arrival_time')),
        );
        stopStayCtrls.add(
          TextEditingController(text: _metaStr(w, 'stay_minutes')),
        );
        stopDepCtrls.add(
          TextEditingController(text: _metaStr(w, 'departure_time')),
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
                    labelText: 'Route Name',
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
                const SizedBox(height: 14),
                TextField(
                  controller: depCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Bus Departure Time',
                    hintText: 'e.g. 15:00',
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Origin',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                TextField(
                  controller: originCtrl,
                  decoration: const InputDecoration(
                    labelText: 'City / Terminal Name',
                    hintText: 'e.g. Lahore Old Bus Stand',
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Destination',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                TextField(
                  controller: destCtrl,
                  decoration: const InputDecoration(
                    labelText: 'City / Terminal Name',
                    hintText: 'e.g. Islamabad Faizabad',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      'Stopovers',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Stop'),
                      onPressed: () => setDlg(() {
                        stopCtrls.add(TextEditingController());
                        stopArrCtrls.add(TextEditingController());
                        stopStayCtrls.add(TextEditingController());
                        stopDepCtrls.add(TextEditingController());
                      }),
                    ),
                  ],
                ),
                ...stopCtrls.asMap().entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: e.value,
                          decoration: InputDecoration(
                            labelText: 'Stop ${e.key + 1}',
                            hintText: 'e.g. Gujrat Itehad ADA',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: stopArrCtrls[e.key],
                                decoration: const InputDecoration(
                                  labelText: 'Arrival',
                                  hintText: '17:00',
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: stopStayCtrls[e.key],
                                decoration: const InputDecoration(
                                  labelText: 'Stay',
                                  hintText: '30m',
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: stopDepCtrls[e.key],
                                decoration: const InputDecoration(
                                  labelText: 'Depart',
                                  hintText: '17:30',
                                  isDense: true,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                                size: 20,
                              ),
                              onPressed: () => setDlg(() {
                                e.value.dispose();
                                stopArrCtrls[e.key].dispose();
                                stopStayCtrls[e.key].dispose();
                                stopDepCtrls[e.key].dispose();
                                stopCtrls.removeAt(e.key);
                                stopArrCtrls.removeAt(e.key);
                                stopStayCtrls.removeAt(e.key);
                                stopDepCtrls.removeAt(e.key);
                              }),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
                  'origin_lat': 0,
                  'origin_lng': 0,
                  'destination_lat': 0,
                  'destination_lng': 0,
                  'meta': {'departure_time': depCtrl.text},
                };
                try {
                  if (isEdit) {
                    await _api.put(
                      '${widget.panelPrefix}/routes/${route!['id']}',
                      body: body,
                    );
                    if (stopCtrls.isNotEmpty) {
                      final wps = <Map<String, dynamic>>[];
                      for (int k = 0; k < stopCtrls.length; k++) {
                        wps.add({
                          'station_name': stopCtrls[k].text,
                          'lat': 0,
                          'lng': 0,
                          'meta': {
                            'arrival_time': stopArrCtrls[k].text,
                            'stay_minutes': stopStayCtrls[k].text,
                            'departure_time': stopDepCtrls[k].text,
                          },
                        });
                      }
                      await _api.post(
                        '${widget.panelPrefix}/routes/${route!['id']}/waypoints',
                        body: {'waypoints': wps},
                      );
                    }
                  } else {
                    final r = await _api.post(
                      '${widget.panelPrefix}/routes',
                      body: body,
                    );
                    final newId = r?['data']?['id']?.toString();
                    if (newId != null && stopCtrls.isNotEmpty) {
                      final wps = <Map<String, dynamic>>[];
                      for (int k = 0; k < stopCtrls.length; k++) {
                        wps.add({
                          'station_name': stopCtrls[k].text,
                          'lat': 0,
                          'lng': 0,
                          'meta': {
                            'arrival_time': stopArrCtrls[k].text,
                            'stay_minutes': stopStayCtrls[k].text,
                            'departure_time': stopDepCtrls[k].text,
                          },
                        });
                      }
                      await _api.post(
                        '${widget.panelPrefix}/routes/$newId/waypoints',
                        body: {'waypoints': wps},
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

  String _metaStr(dynamic obj, String key) {
    if (obj == null) return '';
    final meta = obj['meta'];
    if (meta is Map) return (meta[key] ?? '').toString();
    return '';
  }

  void _showPricingEditor(Map<String, dynamic> route) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoutePricingScreen(
          routeId: route['id'],
          routeName: route['display_name'] ?? '',
          originCity: route['origin_city'] ?? 'Origin',
          destCity: route['destination_city'] ?? 'Destination',
          waypoints: (route['waypoints'] as List<dynamic>?) ?? [],
          panelPrefix: widget.panelPrefix,
        ),
      ),
    );
  }
}

// ═══ PRICING SCREEN ═══
class RoutePricingScreen extends StatefulWidget {
  final String routeId, routeName, panelPrefix, originCity, destCity;
  final List<dynamic> waypoints;
  const RoutePricingScreen({
    super.key,
    required this.routeId,
    required this.routeName,
    required this.originCity,
    required this.destCity,
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
      if (data != null && data['prices'] != null)
        _prices = (data['prices'] as List).cast<Map<String, dynamic>>();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    try {
      await _api.put(
        '${widget.panelPrefix}/routes/${widget.routeId}/pricing',
        body: {'prices': _prices},
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

  void _onPriceChanged(
    int i,
    int j,
    String from,
    String to,
    String field,
    String v,
  ) {
    final val = double.tryParse(v) ?? 0;
    final idx = _prices.indexWhere(
      (p) => p['from_stop_order'] == i && p['to_stop_order'] == j,
    );
    Map<String, dynamic> entry;
    if (idx >= 0) {
      entry = Map<String, dynamic>.from(_prices[idx]);
    } else {
      entry = {
        'from_stop_order': i,
        'to_stop_order': j,
        'from_station': from,
        'to_station': to,
        'price': 0,
        'distance_km': 0,
        'seat_category': 'standard',
      };
    }
    if (field == 'price') entry['price'] = val;
    if (field == 'distance_km') entry['distance_km'] = val;
    if (idx >= 0) {
      _prices[idx] = entry;
    } else {
      _prices.add(entry);
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
    // Build full station list: Origin + waypoints + Destination
    final stations = <Map<String, dynamic>>[
      {'name': widget.originCity, 'is_origin': true},
      ...widget.waypoints.map(
        (w) => {'name': w['station_name'] ?? 'Stop', 'is_origin': false},
      ),
      {'name': widget.destCity, 'is_dest': true},
    ];
    final widgets = <Widget>[];
    for (int i = 0; i < stations.length; i++) {
      for (int j = i + 1; j < stations.length; j++) {
        final from = stations[i]['name'] ?? 'Stop $i';
        final to = stations[j]['name'] ?? 'Stop $j';
        final existing = _prices
            .where((p) => p['from_stop_order'] == i && p['to_stop_order'] == j)
            .firstOrNull;
        final priceCtrl = TextEditingController(
          text: existing?['price']?.toString() ?? '',
        );
        final kmCtrl = TextEditingController(
          text: existing?['distance_km']?.toString() ?? '',
        );
        widgets.add(
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$from → $to',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Rs. '),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: priceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Price',
                            isDense: true,
                          ),
                          onChanged: (v) =>
                              _onPriceChanged(i, j, from, to, 'price', v),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text('KM '),
                      SizedBox(
                        width: 90,
                        child: TextField(
                          controller: kmCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Distance',
                            isDense: true,
                          ),
                          onChanged: (v) =>
                              _onPriceChanged(i, j, from, to, 'distance_km', v),
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

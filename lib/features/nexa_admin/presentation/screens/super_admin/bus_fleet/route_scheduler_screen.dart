// NEXATRACE — ROUTE SCHEDULER SCREEN v3
// ====================================
// Multi-stopover routes with departure time, arrival times,
// city-to-city pricing. No Lat/Lng fields.
//
// MODULE: 13B — Dynamic Route & Waypoint Line Scheduler

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'all_tickets_screen.dart';

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

  Future<void> _unpublishRoute(String id) async {
    try {
      await _api.post('${widget.panelPrefix}/routes/$id/unpublish');
      _loadRoutes();
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Route unpublished!')));
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
                if ((r['total_km'] ?? r['total_distance_km']) != null)
                  Text(
                    '${r['total_km'] ?? r['total_distance_km']} km',
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
                  'add tickets prices',
                  () => _showPricingEditor(r),
                ),
                const SizedBox(width: 8),
                _actionBtn(
                  Icons.list_alt,
                  'View all tickets',
                  () => _showAllPrices(r),
                  color: const Color(0xFF0D9488),
                ),
                const SizedBox(width: 8),
                if (status == 'draft')
                  _actionBtn(
                    Icons.publish,
                    'Publish',
                    () => _publishRoute(r['id']),
                    color: const Color(0xFF16A34A),
                  ),
                if (status == 'published')
                  _actionBtn(
                    Icons.undo,
                    'Unpublish',
                    () => _unpublishRoute(r['id']),
                    color: const Color(0xFFD97706),
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
    final destArrTime = _metaStr(r, 'destination_arrival_time');
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
              if (destArrTime.isNotEmpty)
                _detailRow('Dest Arrival', destArrTime),
              if (r['total_km'] != null || r['total_distance_km'] != null)
                _detailRow(
                  'Distance',
                  '${r['total_km'] ?? r['total_distance_km']} km',
                ),
              ..._buildDetailBadges(
                label: 'Assigned Vouchers',
                items:
                    (r['assigned_vouchers'] as List?)
                        ?.cast<Map<String, dynamic>>() ??
                    [],
                chipColor: const Color(0xFF3B82F6),
                icon: Icons.card_giftcard,
                nameKey: 'title',
                subKey: 'code',
              ),
              ..._buildDetailBadges(
                label: 'Assigned Bonuses',
                items:
                    (r['assigned_bonuses'] as List?)
                        ?.cast<Map<String, dynamic>>() ??
                    [],
                chipColor: const Color(0xFFF59E0B),
                icon: Icons.star,
                nameKey: 'bonus_name',
                subKey: 'staff_type',
              ),
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

  // ═══ ROUTE EDITOR DIALOG (CHIP-BASED MULTI-SELECT) ═══
  Future<void> _showRouteEditor({Map<String, dynamic>? route}) async {
    // ── Pre-fetch: show loading, fetch dropdown data ──
    // Show a brief loading overlay so the dialog never renders
    // before dropdown data is fully resolved (eliminates 3-click race).
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    List<Map<String, dynamic>> _vouchers = [];
    List<Map<String, dynamic>> _bonuses = [];
    try {
      final vRes = await _api.get('${widget.panelPrefix}/vouchers');
      final vData = vRes?['data'];
      if (vData is List) _vouchers = vData.cast<Map<String, dynamic>>();
    } catch (_) {}
    try {
      final bRes = await _api.get('${widget.panelPrefix}/bonuses');
      final bData = bRes?['data'];
      if (bData is List) _bonuses = bData.cast<Map<String, dynamic>>();
    } catch (_) {}

    // Dismiss loading overlay
    if (mounted) Navigator.of(context, rootNavigator: true).pop();

    // ── Form controllers ──
    final nameCtrl = TextEditingController(text: route?['display_name'] ?? '');
    final codeCtrl = TextEditingController(text: route?['route_code'] ?? '');
    final originCtrl = TextEditingController(text: route?['origin_city'] ?? '');
    final destCtrl = TextEditingController(
      text: route?['destination_city'] ?? '',
    );
    final depCtrl = TextEditingController(
      text: _metaStr(route, 'departure_time'),
    );
    final destArrCtrl = TextEditingController(
      text: _metaStr(route, 'destination_arrival_time'),
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

    // ── Multi-select state: hydrate IDs from route's array fields ──
    // The backend returns voucher_ids / bonus_ids as arrays (many-to-many).
    Set<String> voucherIds = {};
    Set<String> bonusIds = {};
    if (route != null) {
      final vList = route['voucher_ids'] as List?;
      if (vList != null && vList.isNotEmpty) {
        voucherIds = vList.map((e) => e.toString()).toSet();
      }
      final bList = route['bonus_ids'] as List?;
      if (bList != null && bList.isNotEmpty) {
        bonusIds = bList.map((e) => e.toString()).toSet();
      }
    }

    // ── Show the edit dialog with pre-loaded data ──
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
                const SizedBox(height: 14),
                TextField(
                  controller: destArrCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Destination Arrival Time',
                    hintText: 'e.g. 21:00',
                  ),
                ),
                const SizedBox(height: 14),
                // ═══ VOUCHER MULTI-SELECT CHIPS ═══
                _buildDialogChipSection(
                  label: 'Assigned Vouchers',
                  selectedIds: voucherIds,
                  allItems: _vouchers,
                  idKey: 'id',
                  nameKey: 'title',
                  fallbackNameKey: 'code',
                  chipColor: const Color(0xFF3B82F6),
                  icon: Icons.card_giftcard,
                  onChanged: (updated) => setDlg(() => voucherIds = updated),
                ),
                const SizedBox(height: 14),
                // ═══ BONUS MULTI-SELECT CHIPS ═══
                _buildDialogChipSection(
                  label: 'Assigned Bonuses',
                  selectedIds: bonusIds,
                  allItems: _bonuses,
                  idKey: 'id',
                  nameKey: 'bonus_name',
                  fallbackNameKey: null,
                  chipColor: const Color(0xFFF59E0B),
                  icon: Icons.star,
                  subKey: 'staff_type',
                  onChanged: (updated) => setDlg(() => bonusIds = updated),
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
                  'meta': {
                    'departure_time': depCtrl.text,
                    'destination_arrival_time': destArrCtrl.text,
                  },
                  'voucher_ids': voucherIds.toList(),
                  'bonus_ids': bonusIds.toList(),
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
                  if (mounted)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Route updated successfully!'),
                      ),
                    );
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

  // ═══ FIX 3: Detail-view badge chips ═══
  /// Renders coloured Chip badges for assigned vouchers/bonuses
  /// in the View Route detail dialog. Returns empty list when
  /// no items exist (zero wasted vertical space).
  List<Widget> _buildDetailBadges({
    required String label,
    required List<Map<String, dynamic>> items,
    required Color chipColor,
    required IconData icon,
    required String nameKey,
    String? subKey,
  }) {
    if (items.isEmpty) return [];
    return [
      const SizedBox(height: 12),
      Text(
        '$label:',
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: Color(0xFF1E293B),
        ),
      ),
      const SizedBox(height: 6),
      Wrap(
        spacing: 8,
        runSpacing: 6,
        children: items.map((item) {
          final name = (item[nameKey] ?? '').toString();
          final sub = subKey != null ? (item[subKey] ?? '').toString() : '';
          return Chip(
            avatar: Icon(icon, size: 14, color: chipColor),
            label: sub.isNotEmpty
                ? Text('$name · $sub', style: const TextStyle(fontSize: 12))
                : Text(name, style: const TextStyle(fontSize: 12)),
            backgroundColor: chipColor.withValues(alpha: 0.08),
            side: BorderSide(color: chipColor.withValues(alpha: 0.3)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          );
        }).toList(),
      ),
    ];
  }

  // ═══ FIX 1 & 2: Chip-based multi-select for edit dialog ═══
  Widget _buildDialogChipSection({
    required String label,
    required Set<String> selectedIds,
    required List<Map<String, dynamic>> allItems,
    required String idKey,
    required String nameKey,
    String? fallbackNameKey,
    required Color chipColor,
    required IconData icon,
    String? subKey,
    required void Function(Set<String>) onChanged,
  }) {
    // Build selected items list (preserves insertion order)
    final selectedItems = <Map<String, dynamic>>[];
    for (final id in selectedIds) {
      final match = allItems.cast<Map<String, dynamic>?>().firstWhere(
        (item) => item?[idKey]?.toString() == id,
        orElse: () => null,
      );
      if (match != null) selectedItems.add(match);
    }

    // Available items (not yet selected)
    final available = allItems
        .where((item) => !selectedIds.contains(item[idKey]?.toString()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const Spacer(),
            if (available.isNotEmpty)
              PopupMenuButton<String>(
                offset: const Offset(0, 36),
                constraints: const BoxConstraints(maxWidth: 260),
                onSelected: (id) {
                  final updated = Set<String>.from(selectedIds)..add(id);
                  onChanged(updated);
                },
                itemBuilder: (_) => available.map((item) {
                  final name = (item[nameKey] ?? item[fallbackNameKey] ?? '')
                      .toString();
                  final sub = subKey != null
                      ? (item[subKey] ?? '').toString()
                      : '';
                  final display = sub.isNotEmpty ? '$name · $sub' : name;
                  return PopupMenuItem<String>(
                    value: item[idKey]?.toString(),
                    child: Text(
                      display,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  );
                }).toList(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFF16A34A).withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 14, color: Color(0xFF16A34A)),
                      SizedBox(width: 4),
                      Text(
                        'Add',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        if (selectedItems.isEmpty)
          const Text(
            'None assigned',
            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          )
        else
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: selectedItems.map((item) {
              final name = (item[nameKey] ?? item[fallbackNameKey] ?? '')
                  .toString();
              final sub = subKey != null ? (item[subKey] ?? '').toString() : '';
              return Chip(
                avatar: Icon(icon, size: 14, color: chipColor),
                label: sub.isNotEmpty
                    ? Text('$name · $sub', style: const TextStyle(fontSize: 12))
                    : Text(name, style: const TextStyle(fontSize: 12)),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  final updated = Set<String>.from(selectedIds)
                    ..remove(item[idKey]?.toString() ?? '');
                  onChanged(updated);
                },
                backgroundColor: chipColor.withValues(alpha: 0.08),
                side: BorderSide(color: chipColor.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
              );
            }).toList(),
          ),
      ],
    );
  }

  void _showAllPrices(Map<String, dynamic> route) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AllTicketsScreen(
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
  final _renderedPairs = <String>{};

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
    final val = v.isEmpty ? null : (double.tryParse(v) ?? 0);
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
    if (field == 'price') entry['price'] = val ?? 0;
    if (field == 'distance_km') entry['distance_km'] = val ?? 0;
    if (field == 'price_sleeper_upper') entry['price_sleeper_upper'] = val;
    if (field == 'price_sleeper_lower') entry['price_sleeper_lower'] = val;
    if (field == 'price_business') entry['price_business'] = val;
    if (field == 'price_folding') entry['price_folding'] = val;
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
    // Deduplicate by trimmed name so Stop-5=Dest doesn't create phantom pairs
    final rawStations = <Map<String, dynamic>>[
      {'name': widget.originCity, 'is_origin': true},
      ...widget.waypoints.map(
        (w) => {'name': w['station_name'] ?? 'Stop', 'is_origin': false},
      ),
      {'name': widget.destCity, 'is_dest': true},
    ];
    final stations = <Map<String, dynamic>>[];
    final stationSet = <String>{};
    for (final s in rawStations) {
      final name = (s['name']?.toString() ?? '')
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'\s*/\s*'), '/')
          .replaceAll(RegExp(r'\s*-\s*'), '-')
          .replaceAll(RegExp(r'\s+'), ' ');
      if (name.isNotEmpty && stationSet.add(name)) {
        stations.add({
          'name': name,
          'is_origin': s['is_origin'],
          'is_dest': s['is_dest'],
        });
      }
    }
    final widgets = <Widget>[];
    _renderedPairs.clear();

    // Build 2D grid of FocusNodes for keyboard arrow navigation
    final gridNodes = <String, FocusNode>{};
    int rowIdx = 0;
    // First pass: count rows and create focus nodes
    for (int i = 0; i < stations.length; i++) {
      for (int j = i + 1; j < stations.length; j++) {
        final f = stations[i]['name'] ?? '';
        final t = stations[j]['name'] ?? '';
        if (f == t) continue;
        final nk = '$f→$t';
        if (_renderedPairs.contains(nk)) continue;
        _renderedPairs.add(nk);
        for (int col = 0; col < 6; col++) {
          gridNodes['$rowIdx-$col'] = FocusNode(
            onKeyEvent: (node, event) {
              if (event is! KeyDownEvent) return KeyEventResult.ignored;
              final key = event.logicalKey;
              int nr = rowIdx, nc = col;
              if (key == LogicalKeyboardKey.arrowRight)
                nc = (col + 1) % 6;
              else if (key == LogicalKeyboardKey.arrowLeft)
                nc = (col - 1 + 6) % 6;
              else if (key == LogicalKeyboardKey.arrowDown)
                nr = rowIdx + 1;
              else if (key == LogicalKeyboardKey.arrowUp)
                nr = rowIdx - 1;
              else
                return KeyEventResult.ignored;
              final tgt = gridNodes['$nr-$nc'];
              if (tgt != null && tgt != node) {
                tgt.requestFocus();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
          );
        }
        rowIdx++;
      }
    }

    // Second pass: build widgets with focus nodes
    _renderedPairs.clear();
    rowIdx = 0;
    for (int i = 0; i < stations.length; i++) {
      for (int j = i + 1; j < stations.length; j++) {
        final from = stations[i]['name'] ?? 'Stop $i';
        final to = stations[j]['name'] ?? 'Stop $j';
        if (from == to) continue;
        final pairKey = '$from→$to';
        if (_renderedPairs.contains(pairKey)) continue;
        _renderedPairs.add(pairKey);
        final existing = _prices
            .where((p) => p['from_stop_order'] == i && p['to_stop_order'] == j)
            .firstOrNull;
        final priceCtrl = TextEditingController(
          text: existing?['price']?.toString() ?? '',
        );
        final kmCtrl = TextEditingController(
          text: existing?['distance_km']?.toString() ?? '',
        );
        final suCtrl = TextEditingController(
          text: existing?['price_sleeper_upper']?.toString() ?? '',
        );
        final slCtrl = TextEditingController(
          text: existing?['price_sleeper_lower']?.toString() ?? '',
        );
        final bizCtrl = TextEditingController(
          text: existing?['price_business']?.toString() ?? '',
        );
        final foldCtrl = TextEditingController(
          text: existing?['price_folding']?.toString() ?? '',
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
                  // Standard price + KM on one row
                  Row(
                    children: [
                      const Text('Rs. '),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: priceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Standard',
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
                  const SizedBox(height: 6),
                  // Seat category prices in a 2x2 compact grid
                  Row(
                    children: [
                      Expanded(
                        child: _seatPriceField(
                          'Sleeper Upper',
                          suCtrl,
                          (v) => _onPriceChanged(
                            i,
                            j,
                            from,
                            to,
                            'price_sleeper_upper',
                            v,
                          ),
                          focusNode: gridNodes['$rowIdx-2'],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _seatPriceField(
                          'Sleeper Lower',
                          slCtrl,
                          (v) => _onPriceChanged(
                            i,
                            j,
                            from,
                            to,
                            'price_sleeper_lower',
                            v,
                          ),
                          focusNode: gridNodes['$rowIdx-3'],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: _seatPriceField(
                          'Business',
                          bizCtrl,
                          (v) => _onPriceChanged(
                            i,
                            j,
                            from,
                            to,
                            'price_business',
                            v,
                          ),
                          focusNode: gridNodes['$rowIdx-4'],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _seatPriceField(
                          'Folding',
                          foldCtrl,
                          (v) => _onPriceChanged(
                            i,
                            j,
                            from,
                            to,
                            'price_folding',
                            v,
                          ),
                          focusNode: gridNodes['$rowIdx-5'],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
        rowIdx++;
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

  Widget _seatPriceField(
    String label,
    TextEditingController controller,
    ValueChanged<String> onChanged, {
    FocusNode? focusNode,
  }) {
    final tf = TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
        signed: true,
        decimal: true,
      ),
      decoration: InputDecoration(
        hintText: 'Rs.',
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      ),
      onChanged: onChanged,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 2),
        SizedBox(
          height: 38,
          child: focusNode != null
              ? Focus(focusNode: focusNode, child: tf)
              : tf,
        ),
      ],
    );
  }
}

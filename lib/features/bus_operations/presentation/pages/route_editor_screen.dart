// NEXATRACE — ROUTE EDITOR SCREEN
// =================================
// Interactive map canvas for defining bus transit routes.
// Admin places waypoints by tapping the grid, then saves
// the full waypoint list to the backend.
//
// MODULE: 13B — Dynamic Route & Waypoint Line Scheduler

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/route_map_editor_painter.dart';

class RouteEditorScreen extends StatefulWidget {
  final String? routeId;
  final String carrierCompanyId;
  const RouteEditorScreen({
    super.key,
    this.routeId,
    required this.carrierCompanyId,
  });
  @override
  State<RouteEditorScreen> createState() => _RouteEditorScreenState();
}

class _RouteEditorScreenState extends State<RouteEditorScreen> {
  final _api = ApiService();
  final _nameCtrl = TextEditingController(),
      _codeCtrl = TextEditingController();
  final _originCtrl = TextEditingController(),
      _destCtrl = TextEditingController();
  List<EditorWaypoint> _waypoints = [];
  EditorWaypoint? _dragging;
  bool _saving = false, _loading = true;
  String? _routeId;

  // Voucher & Bonus multi-select (many-to-many)
  Set<String> _voucherIds = {};
  Set<String> _bonusIds = {};
  List<Map<String, dynamic>> _vouchers = [];
  List<Map<String, dynamic>> _bonuses = [];
  bool _dropdownsReady = false;

  static const _defaultLat = 31.5, _defaultLng = 73.0;
  final _minLat = 24.0, _maxLat = 37.0, _minLng = 61.0, _maxLng = 78.0;

  @override
  void initState() {
    super.initState();
    _routeId = widget.routeId;
    _initData();
  }

  Future<void> _initData() async {
    // Fetch route data and dropdown lists in parallel, then hydrate state
    // atomically so the UI never renders with partial data.
    final futures = <Future>[
      _api.get('/bus-fleet/vouchers'),
      _api.get('/bus-fleet/bonuses'),
      if (_routeId != null) _api.get('/bus-fleet/routes/$_routeId'),
    ];
    try {
      final results = await Future.wait(futures);
      final vouchers = List<Map<String, dynamic>>.from(
        results[0]['data'] ?? [],
      );
      final allBonuses = List<Map<String, dynamic>>.from(
        results[1]['data'] ?? [],
      );

      if (_routeId != null && results.length > 2) {
        final data = results[2]['data'];
        _nameCtrl.text = data['display_name'] ?? '';
        _codeCtrl.text = data['route_code'] ?? '';
        _originCtrl.text = data['origin_city'] ?? '';
        _destCtrl.text = data['destination_city'] ?? '';
        // Support both legacy single IDs and new many-to-many arrays
        final vList = data['voucher_ids'] as List?;
        if (vList != null) {
          _voucherIds = vList.map((e) => e.toString()).toSet();
        } else if (data['voucher_id'] != null) {
          _voucherIds = {data['voucher_id'].toString()};
        }
        final bList = data['bonus_ids'] as List?;
        if (bList != null) {
          _bonusIds = bList.map((e) => e.toString()).toSet();
        } else {
          if (data['driver_bonus_id'] != null)
            _bonusIds.add(data['driver_bonus_id'].toString());
          if (data['conductor_bonus_id'] != null)
            _bonusIds.add(data['conductor_bonus_id'].toString());
        }
        final wps = data['waypoints'] as List? ?? [];
        _waypoints = wps.asMap().entries.map((e) {
          final w = Map<String, dynamic>.from(e.value);
          return EditorWaypoint(
            id: w['id']?.toString() ?? '${e.key}',
            stationName: w['station_name'] ?? '',
            lat: (w['lat'] ?? _defaultLat).toDouble(),
            lng: (w['lng'] ?? _defaultLng).toDouble(),
            order: e.key,
          );
        }).toList();
      } else {
        _addDefaultWaypoints();
      }
      setState(() {
        _vouchers = vouchers;
        _bonuses = allBonuses;
        _dropdownsReady = true;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _dropdownsReady = true;
        _loading = false;
      });
      if (_routeId == null) _addDefaultWaypoints();
    }
  }

  void _addDefaultWaypoints() {
    _waypoints = [
      EditorWaypoint(
        id: 'o',
        stationName: 'Origin',
        lat: 31.52,
        lng: 74.35,
        order: 0,
      ),
      EditorWaypoint(
        id: 'd',
        stationName: 'Destination',
        lat: 33.68,
        lng: 73.05,
        order: 1,
      ),
    ];
  }

  Future<void> _save() async {
    if (_codeCtrl.text.isEmpty || _nameCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter route code and name'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final isUpdate = _routeId != null;
      final body = <String, dynamic>{
        'route_code': _codeCtrl.text,
        'display_name': _nameCtrl.text,
        'origin_city': _originCtrl.text,
        'destination_city': _destCtrl.text,
        'origin_lat': _waypoints.first.lat,
        'origin_lng': _waypoints.first.lng,
        'destination_lat': _waypoints.last.lat,
        'destination_lng': _waypoints.last.lng,
        // Many-to-many: send arrays of selected IDs
        if (isUpdate || _voucherIds.isNotEmpty)
          'voucher_ids': _voucherIds.toList(),
        if (isUpdate || _bonusIds.isNotEmpty) 'bonus_ids': _bonusIds.toList(),
      };
      if (!isUpdate) {
        final r = await _api.post('/bus-fleet/routes', body: body);
        _routeId = r['data']['id']?.toString();
      } else {
        await _api.put('/bus-fleet/routes/$_routeId', body: body);
      }
      if (_routeId != null) {
        await _api.post(
          '/bus-fleet/routes/$_routeId/waypoints',
          body: {
            'waypoints': _waypoints
                .map(
                  (w) => {
                    'station_name': w.stationName,
                    'lat': w.lat,
                    'lng': w.lng,
                  },
                )
                .toList(),
          },
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Route saved!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
    setState(() => _saving = false);
  }

  Future<void> _publish() async {
    if (_routeId == null) return;
    try {
      await _api.post('/bus-fleet/routes/$_routeId/publish');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Route published!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF8FAFC),
    appBar: AppBar(
      title: Text(_routeId == null ? 'New Route' : 'Edit Route'),
      actions: [
        if (_routeId != null)
          TextButton(
            onPressed: _publish,
            child: const Text(
              'Publish',
              style: TextStyle(
                color: Color(0xFF16A34A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        const SizedBox(width: 4),
      ],
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              _buildForm(),
              Expanded(child: _buildCanvas()),
              _buildBottomBar(),
            ],
          ),
  );

  Widget _buildForm() => Container(
    padding: const EdgeInsets.all(12),
    color: Colors.white,
    width: double.infinity,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _codeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Code',
                  hintText: 'LHR-ISB-001',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const Gap(8),
            Expanded(
              flex: 2,
              child: TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Lahore → Islamabad Express',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const Gap(8),
            Expanded(
              child: TextField(
                controller: _originCtrl,
                decoration: const InputDecoration(
                  labelText: 'Origin',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const Gap(8),
            Expanded(
              child: TextField(
                controller: _destCtrl,
                decoration: const InputDecoration(
                  labelText: 'Dest.',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const Gap(10),
        _buildChipSection(
          label: 'Vouchers',
          selectedIds: _voucherIds,
          allItems: _vouchers,
          idKey: 'id',
          nameKey: 'title',
          fallbackNameKey: 'code',
          chipColor: const Color(0xFF3B82F6),
          onAdd: (id) => setState(() => _voucherIds.add(id)),
          onRemove: (id) => setState(() => _voucherIds.remove(id)),
        ),
        const Gap(10),
        _buildChipSection(
          label: 'Staff Bonuses',
          selectedIds: _bonusIds,
          allItems: _bonuses,
          idKey: 'id',
          nameKey: 'bonus_name',
          fallbackNameKey: null,
          chipColor: const Color(0xFFF59E0B),
          badgeLabel: (b) =>
              '${b['staff_type'] ?? ''} · ${b['bonus_category'] ?? ''}',
          onAdd: (id) => setState(() => _bonusIds.add(id)),
          onRemove: (id) => setState(() => _bonusIds.remove(id)),
        ),
      ],
    ),
  );

  /// Reusable multi-select chip row with + button.
  Widget _buildChipSection({
    required String label,
    required Set<String> selectedIds,
    required List<Map<String, dynamic>> allItems,
    required String idKey,
    required String nameKey,
    String? fallbackNameKey,
    required Color chipColor,
    String? Function(Map<String, dynamic>)? badgeLabel,
    required void Function(String id) onAdd,
    required void Function(String id) onRemove,
  }) {
    if (!_dropdownsReady) {
      return const SizedBox(
        height: 36,
        child: Center(
          child: SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    // Build lookup for selected items
    final selectedItems = <Map<String, dynamic>>[];
    for (final id in selectedIds) {
      final match = allItems.cast<Map<String, dynamic>?>().firstWhere(
        (item) => item?[idKey]?.toString() == id,
        orElse: () => null,
      );
      if (match != null) selectedItems.add(match);
    }
    // Unselected items for the add dropdown
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
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
            const Spacer(),
            if (available.isNotEmpty)
              _buildAddButton(
                available,
                idKey,
                nameKey,
                fallbackNameKey,
                onAdd,
              ),
          ],
        ),
        const Gap(4),
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
              final sub = badgeLabel?.call(item);
              return Chip(
                avatar: Icon(Icons.local_offer, size: 14, color: chipColor),
                label: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 12)),
                    if (sub != null && sub.isNotEmpty)
                      Text(
                        sub,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF64748B),
                        ),
                      ),
                  ],
                ),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => onRemove(item[idKey]?.toString() ?? ''),
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

  Widget _buildAddButton(
    List<Map<String, dynamic>> available,
    String idKey,
    String nameKey,
    String? fallbackNameKey,
    void Function(String) onAdd,
  ) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 36),
      constraints: const BoxConstraints(maxWidth: 280),
      onSelected: onAdd,
      itemBuilder: (_) => available.map((item) {
        final name = (item[nameKey] ?? item[fallbackNameKey] ?? '').toString();
        return PopupMenuItem<String>(
          value: item[idKey]?.toString(),
          child: Text(name, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
            Gap(4),
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
    );
  }

  Widget _buildCanvas() => LayoutBuilder(
    builder: (ctx, constraints) => GestureDetector(
      onTapUp: (d) {
        final rb = ctx.findRenderObject() as RenderBox;
        final lp = rb.globalToLocal(d.globalPosition);
        final (lat, lng) = RouteMapEditorPainter.inverseProject(
          lp,
          rb.size,
          _minLat,
          _maxLat,
          _minLng,
          _maxLng,
        );
        setState(
          () => _waypoints.add(
            EditorWaypoint(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              stationName: 'Stop ${_waypoints.length + 1}',
              lat: lat,
              lng: lng,
              order: _waypoints.length,
            ),
          ),
        );
      },
      child: CustomPaint(
        painter: RouteMapEditorPainter(
          waypoints: _waypoints,
          draggingWaypoint: _dragging,
          minLat: _minLat,
          maxLat: _maxLat,
          minLng: _minLng,
          maxLng: _maxLng,
          originCity: _originCtrl.text,
          destinationCity: _destCtrl.text,
        ),
        size: Size.infinite,
      ),
    ),
  );

  Widget _buildBottomBar() => Container(
    padding: const EdgeInsets.all(16),
    color: Colors.white,
    child: Row(
      children: [
        Text(
          '${_waypoints.length} stops',
          style: const TextStyle(color: Color(0xFF64748B)),
        ),
        const Spacer(),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        const Gap(8),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Saving...' : 'Save Route'),
        ),
      ],
    ),
  );
}

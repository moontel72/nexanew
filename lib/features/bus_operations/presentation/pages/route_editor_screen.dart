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

  static const _defaultLat = 31.5, _defaultLng = 73.0;
  final _minLat = 24.0, _maxLat = 37.0, _minLng = 61.0, _maxLng = 78.0;

  @override
  void initState() {
    super.initState();
    _routeId = widget.routeId;
    if (_routeId != null) {
      _loadRoute();
    } else {
      _loading = false;
      _addDefaultWaypoints();
    }
  }

  Future<void> _loadRoute() async {
    try {
      final r = await _api.get('/bus-fleet/routes/$_routeId');
      final data = r['data'];
      _nameCtrl.text = data['display_name'] ?? '';
      _codeCtrl.text = data['route_code'] ?? '';
      _originCtrl.text = data['origin_city'] ?? '';
      _destCtrl.text = data['destination_city'] ?? '';
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
    } catch (_) {}
    setState(() => _loading = false);
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
      final body = {
        'route_code': _codeCtrl.text,
        'display_name': _nameCtrl.text,
        'origin_city': _originCtrl.text,
        'destination_city': _destCtrl.text,
        'origin_lat': _waypoints.first.lat,
        'origin_lng': _waypoints.first.lng,
        'destination_lat': _waypoints.last.lat,
        'destination_lng': _waypoints.last.lng,
      };
      if (_routeId == null) {
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
    child: Row(
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
  );

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

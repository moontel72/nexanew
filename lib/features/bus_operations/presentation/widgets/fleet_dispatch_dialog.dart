// NEXATRACE — ADVANCED DISPATCH ENGINE v2
// =======================================
// Supports: multi-staff, handover, return trip, edit, multi-leg.
//
// MODULE: 14C — Active Fleet Scheduling

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/core/services/api_service.dart';

const _shifts = ['morning', 'evening', 'night', 'special'];
const _shiftColors = <String, Color>{
  'morning': Color(0xFFF59E0B),
  'evening': Color(0xFF8B5CF6),
  'night': Color(0xFF1E293B),
  'special': Color(0xFFEF4444),
};

// ═══════════════════════════════════════════════════════════
// CREATE ASSIGNMENT FORM (Feature 2, 3)
// ═══════════════════════════════════════════════════════════
class FleetDispatchForm extends StatefulWidget {
  final String apiPrefix;
  final String? busCompanyId;
  final VoidCallback? onSaved;

  const FleetDispatchForm({
    super.key,
    required this.apiPrefix,
    this.busCompanyId,
    this.onSaved,
  });

  @override
  State<FleetDispatchForm> createState() => _FleetDispatchFormState();
}

class _FleetDispatchFormState extends State<FleetDispatchForm> {
  final _api = ApiService();

  List<Map<String, dynamic>> _vehicles = [],
      _routes = [],
      _drivers = [],
      _conductors = [],
      _waypoints = [];

  bool _loading = true, _saving = false;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _departureTime = const TimeOfDay(hour: 8, minute: 0);

  String? _vehicleId,
      _routeId,
      _driverId,
      _reliefDriverId,
      _conductorId,
      _handoverStopId;
  Set<String> _conductorIds = {};
  String _shift = 'morning';
  bool _showReturnTrip = false;

  // Return trip staff
  String? _retDriverId, _retReliefDriverId, _retConductorId;
  Set<String> _retConductorIds = {};
  TimeOfDay _retDepartureTime = const TimeOfDay(hour: 16, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  Future<void> _loadResources({String? routeId}) async {
    setState(() => _loading = true);
    try {
      final params = <String, dynamic>{
        if (widget.busCompanyId != null) 'bus_company_id': widget.busCompanyId,
        if (routeId != null) 'route_id': routeId,
      };
      final res = await _api.get(
        '${widget.apiPrefix}/dispatch/resources',
        queryParams: params,
      );
      final d = res?['data'] as Map<String, dynamic>? ?? {};
      if (!mounted) return;
      setState(() {
        _vehicles = _cast(d['vehicles']);
        _routes = _cast(d['routes']);
        _drivers = _cast(d['drivers']);
        _conductors = _cast(d['conductors']);
        _waypoints = _cast(d['waypoints']);
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> _cast(dynamic list) =>
      (list as List?)?.cast<Map<String, dynamic>>() ?? [];

  Future<void> _save() async {
    if (_vehicleId == null || _routeId == null || _driverId == null) {
      _snack('Vehicle, Route, and Driver are required.', Colors.red);
      return;
    }
    setState(() => _saving = true);
    try {
      final body = <String, dynamic>{
        if (widget.busCompanyId != null) 'bus_company_id': widget.busCompanyId,
        'vehicle_id': _vehicleId,
        'route_id': _routeId,
        'driver_id': _driverId,
        if (_reliefDriverId != null) 'relief_driver_id': _reliefDriverId,
        if (_conductorId != null) 'conductor_id': _conductorId,
        if (_conductorIds.isNotEmpty) 'conductor_ids': _conductorIds.toList(),
        if (_handoverStopId != null) 'handover_stop_id': _handoverStopId,
        'assignment_date': _fmtDate(_selectedDate),
        'departure_time':
            '${_departureTime.hour.toString().padLeft(2, '0')}:${_departureTime.minute.toString().padLeft(2, '0')}',
        'shift_type': _shift,
        'create_return_trip': _showReturnTrip,
        if (_showReturnTrip) ...{
          'return_driver_id': _retDriverId ?? _driverId,
          if (_retReliefDriverId != null)
            'return_relief_driver_id': _retReliefDriverId,
          if (_retConductorId != null) 'return_conductor_id': _retConductorId,
          if (_retConductorIds.isNotEmpty)
            'return_conductor_ids': _retConductorIds.toList(),
          'return_departure_time':
              '${_retDepartureTime.hour.toString().padLeft(2, '0')}:${_retDepartureTime.minute.toString().padLeft(2, '0')}',
        },
      };
      final res = await _api.post(
        '${widget.apiPrefix}/dispatch/assignments',
        body: body,
      );
      if (res?['success'] == true) {
        _snack('Assignment created!', const Color(0xFF16A34A));
        _resetForm();
        widget.onSaved?.call();
      } else {
        final conflicts = res?['conflicts'] as List? ?? [];
        _snack(
          conflicts.isNotEmpty
              ? conflicts.join('\n')
              : (res?['message'] ?? 'Error'),
          Colors.red,
        );
      }
    } catch (e) {
      _snack(
        'Error: ${e.toString().replaceAll('Exception: ', '')}',
        Colors.red,
      );
    }
    setState(() => _saving = false);
  }

  void _resetForm() {
    setState(() {
      _vehicleId = null;
      _routeId = null;
      _driverId = null;
      _reliefDriverId = null;
      _conductorId = null;
      _conductorIds = {};
      _handoverStopId = null;
      _showReturnTrip = false;
      _retDriverId = null;
      _retReliefDriverId = null;
      _retConductorId = null;
      _retConductorIds = {};
    });
  }

  void _snack(String msg, Color c) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontSize: 12)),
        backgroundColor: c,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickTime(bool isReturn) async {
    final t = await showTimePicker(
      context: context,
      initialTime: isReturn ? _retDepartureTime : _departureTime,
    );
    if (t != null) {
      setState(() {
        if (isReturn)
          _retDepartureTime = t;
        else
          _departureTime = t;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650, maxHeight: 850),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _header('Create Assignment', Icons.add_task),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _dateShiftRow(),
                          const Gap(12),
                          _section('Route & Vehicle'),
                          const Gap(8),
                          _dd(
                            'Vehicle',
                            Icons.directions_bus,
                            _vehicleId,
                            _vehicles,
                            (v) => setState(() => _vehicleId = v),
                          ),
                          const Gap(8),
                          _dd(
                            'Route',
                            Icons.alt_route,
                            _routeId,
                            _routes,
                            (v) {
                              setState(() => _routeId = v);
                              if (v != null) _loadResources(routeId: v);
                            },
                            itemBuilder: (r) => r['description'] != null
                                ? '${r['name']} (${r['description']})'
                                : r['name']?.toString() ?? '',
                          ),
                          const Gap(12),
                          _section('Staff — Outbound'),
                          const Gap(8),
                          _dd(
                            'Primary Driver *',
                            Icons.person,
                            _driverId,
                            _drivers,
                            (v) => setState(() => _driverId = v),
                          ),
                          const Gap(8),
                          _dd(
                            'Relief Driver (handover)',
                            Icons.airline_seat_recline_normal,
                            _reliefDriverId,
                            _drivers,
                            (v) => setState(() => _reliefDriverId = v),
                          ),
                          const Gap(8),
                          if (_reliefDriverId != null && _waypoints.isNotEmpty)
                            _dd(
                              'Handover Stop',
                              Icons.transfer_within_a_station,
                              _handoverStopId,
                              _waypoints,
                              (v) => setState(() => _handoverStopId = v),
                              itemBuilder: (w) =>
                                  'Stop ${w['stop_order'] ?? '?'}: ${w['name'] ?? ''}',
                            ),
                          const Gap(8),
                          _dd(
                            'Conductor',
                            Icons.person_outline,
                            _conductorId,
                            _conductors,
                            (v) => setState(() => _conductorId = v),
                          ),
                          if (_conductors.isNotEmpty)
                            _chipSection(
                              'Additional Conductors',
                              _conductorIds,
                              _conductors,
                              'id',
                              'name',
                              const Color(0xFF8B5CF6),
                              Icons.group,
                              onChanged: (s) =>
                                  setState(() => _conductorIds = s),
                            ),
                          const Gap(12),
                          // Return trip toggle (Feature 3)
                          SwitchListTile(
                            title: const Text(
                              'Separate Return Trip Staff',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: const Text(
                              'Staff group B takes vehicle back inbound',
                              style: TextStyle(fontSize: 11),
                            ),
                            value: _showReturnTrip,
                            onChanged: (v) =>
                                setState(() => _showReturnTrip = v),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          if (_showReturnTrip) ...[
                            const Gap(4),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _pickTime(true),
                                    icon: const Icon(
                                      Icons.access_time,
                                      size: 16,
                                    ),
                                    label: Text(
                                      'Return: ${_retDepartureTime.format(context)}',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Gap(8),
                            _dd(
                              'Return Driver',
                              Icons.person,
                              _retDriverId,
                              _drivers,
                              (v) => setState(() => _retDriverId = v),
                            ),
                            const Gap(8),
                            _dd(
                              'Return Relief Driver',
                              Icons.airline_seat_recline_normal,
                              _retReliefDriverId,
                              _drivers,
                              (v) => setState(() => _retReliefDriverId = v),
                            ),
                            const Gap(8),
                            _dd(
                              'Return Conductor',
                              Icons.person_outline,
                              _retConductorId,
                              _conductors,
                              (v) => setState(() => _retConductorId = v),
                            ),
                            if (_conductors.isNotEmpty)
                              _chipSection(
                                'Return Additional Conductors',
                                _retConductorIds,
                                _conductors,
                                'id',
                                'name',
                                const Color(0xFF8B5CF6),
                                Icons.group,
                                onChanged: (s) =>
                                    setState(() => _retConductorIds = s),
                              ),
                          ],
                          const Gap(14),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: FilledButton.icon(
                              onPressed: _saving ? null : _save,
                              icon: _saving
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.save, size: 18),
                              label: Text(
                                _saving ? 'Saving...' : 'Assign Duty',
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(String title, IconData icon) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    decoration: const BoxDecoration(
      color: Color(0xFF1E293B),
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    child: Row(
      children: [
        Icon(icon, color: Colors.white, size: 22),
        const Gap(10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white70, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );

  Widget _section(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: Color(0xFF1E293B),
    ),
  );

  Widget _dateShiftRow() => Row(
    children: [
      Expanded(
        flex: 2,
        child: OutlinedButton.icon(
          onPressed: () async {
            final p = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2024),
              lastDate: DateTime(2030),
            );
            if (p != null) setState(() => _selectedDate = p);
          },
          icon: const Icon(Icons.calendar_today, size: 16),
          label: Text(
            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ),
      const Gap(8),
      Expanded(
        flex: 2,
        child: OutlinedButton.icon(
          onPressed: () => _pickTime(false),
          icon: const Icon(Icons.access_time, size: 16),
          label: Text(
            _departureTime.format(context),
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ),
      const Gap(8),
      Expanded(
        flex: 3,
        child: SegmentedButton<String>(
          segments: _shifts
              .map(
                (s) => ButtonSegment<String>(
                  value: s,
                  label: Text(
                    s[0].toUpperCase() + s.substring(1),
                    style: TextStyle(
                      fontSize: 11,
                      color: _shift == s ? Colors.white : _shiftColors[s],
                    ),
                  ),
                ),
              )
              .toList(),
          selected: {_shift},
          onSelectionChanged: (sel) => setState(() => _shift = sel.first),
          style: ButtonStyle(visualDensity: VisualDensity.compact),
        ),
      ),
    ],
  );

  Widget _dd(
    String label,
    IconData icon,
    String? value,
    List<Map<String, dynamic>> items,
    void Function(String?)? onChanged, {
    String Function(Map<String, dynamic>)? itemBuilder,
  }) => DropdownButtonFormField<String>(
    value: value,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 18),
      border: const OutlineInputBorder(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      isDense: true,
    ),
    isExpanded: true,
    items: [
      DropdownMenuItem<String>(
        value: null,
        child: Text(
          'Select...',
          style: const TextStyle(color: Color(0xFF94A3B8)),
        ),
      ),
      ...items.map(
        (i) => DropdownMenuItem<String>(
          value: i['id']?.toString(),
          child: Text(
            itemBuilder?.call(i) ?? i['name']?.toString() ?? '',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ),
    ],
    onChanged: onChanged,
    style: const TextStyle(fontSize: 13),
  );

  Widget _chipSection(
    String label,
    Set<String> selected,
    List<Map<String, dynamic>> all,
    String idKey,
    String nameKey,
    Color color,
    IconData icon, {
    required void Function(Set<String>) onChanged,
  }) {
    final sel = all
        .where((i) => selected.contains(i[idKey]?.toString()))
        .toList();
    final avail = all
        .where((i) => !selected.contains(i[idKey]?.toString()))
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(4),
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
            if (avail.isNotEmpty)
              PopupMenuButton<String>(
                offset: const Offset(0, 36),
                constraints: const BoxConstraints(maxWidth: 240),
                onSelected: (id) {
                  final u = Set<String>.from(selected)..add(id);
                  onChanged(u);
                },
                itemBuilder: (_) => avail
                    .map(
                      (i) => PopupMenuItem<String>(
                        value: i[idKey]?.toString(),
                        child: Text(
                          i[nameKey]?.toString() ?? '',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
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
                          fontSize: 11,
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
        if (sel.isEmpty)
          const Text(
            'None',
            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          )
        else
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: sel
                .map(
                  (i) => Chip(
                    avatar: Icon(icon, size: 13, color: color),
                    label: Text(
                      i[nameKey]?.toString() ?? '',
                      style: const TextStyle(fontSize: 11),
                    ),
                    deleteIcon: const Icon(Icons.close, size: 14),
                    onDeleted: () {
                      final u = Set<String>.from(selected)
                        ..remove(i[idKey]?.toString());
                      onChanged(u);
                    },
                    backgroundColor: color.withValues(alpha: 0.08),
                    side: BorderSide(color: color.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
// EDIT ASSIGNMENT DIALOG (Feature 1)
// ═══════════════════════════════════════════════════════════
class FleetDispatchEditDialog extends StatefulWidget {
  final String apiPrefix;
  final String? busCompanyId;
  final Map<String, dynamic> assignment;
  final VoidCallback? onSaved;

  const FleetDispatchEditDialog({
    super.key,
    required this.apiPrefix,
    this.busCompanyId,
    required this.assignment,
    this.onSaved,
  });

  @override
  State<FleetDispatchEditDialog> createState() =>
      _FleetDispatchEditDialogState();
}

class _FleetDispatchEditDialogState extends State<FleetDispatchEditDialog> {
  final _api = ApiService();
  List<Map<String, dynamic>> _vehicles = [],
      _routes = [],
      _drivers = [],
      _conductors = [],
      _waypoints = [];
  bool _loading = true, _saving = false;

  late String? _vehicleId,
      _routeId,
      _driverId,
      _reliefDriverId,
      _conductorId,
      _handoverStopId;
  late Set<String> _conductorIds;
  late String _shift, _legType;
  late TimeOfDay _departureTime;

  @override
  void initState() {
    super.initState();
    final a = widget.assignment;
    _vehicleId = a['vehicle_id']?.toString();
    _routeId = a['route_id']?.toString();
    _driverId = a['driver_id']?.toString();
    _reliefDriverId = a['relief_driver_id']?.toString();
    _conductorId = a['conductor_id']?.toString();
    _handoverStopId = a['handover_stop_id']?.toString();
    _conductorIds =
        ((a['conductor_ids'] as List?)?.map((e) => e.toString()) ?? const [])
            .toSet();
    _shift = a['shift_type']?.toString() ?? 'morning';
    _legType = a['leg_type']?.toString() ?? 'outbound';
    if (a['departure_time'] != null) {
      final parts = a['departure_time'].toString().split(':');
      _departureTime = TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 8,
        minute: int.tryParse(parts[1]) ?? 0,
      );
    } else {
      _departureTime = const TimeOfDay(hour: 8, minute: 0);
    }
    _loadResources();
  }

  Future<void> _loadResources() async {
    setState(() => _loading = true);
    try {
      final params = <String, dynamic>{
        if (widget.busCompanyId != null) 'bus_company_id': widget.busCompanyId,
        if (_routeId != null) 'route_id': _routeId,
      };
      final res = await _api.get(
        '${widget.apiPrefix}/dispatch/resources',
        queryParams: params,
      );
      final d = res?['data'] as Map<String, dynamic>? ?? {};
      if (!mounted) return;
      setState(() {
        _vehicles = _cast(d['vehicles']);
        _routes = _cast(d['routes']);
        _drivers = _cast(d['drivers']);
        _conductors = _cast(d['conductors']);
        _waypoints = _cast(d['waypoints']);
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> _cast(dynamic l) =>
      (l as List?)?.cast<Map<String, dynamic>>() ?? [];

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final body = <String, dynamic>{
        'vehicle_id': _vehicleId,
        'route_id': _routeId,
        'driver_id': _driverId,
        'relief_driver_id': _reliefDriverId,
        'conductor_id': _conductorId,
        'conductor_ids': _conductorIds.toList(),
        'handover_stop_id': _handoverStopId,
        'departure_time':
            '${_departureTime.hour.toString().padLeft(2, '0')}:${_departureTime.minute.toString().padLeft(2, '0')}',
        'shift_type': _shift,
        'leg_type': _legType,
      };
      await _api.put(
        '${widget.apiPrefix}/dispatch/assignments/${widget.assignment['id']}',
        body: body,
      );
      if (mounted) {
        _snack('Updated!', const Color(0xFF16A34A));
        Navigator.pop(context);
        widget.onSaved?.call();
      }
    } catch (e) {
      _snack('Error: $e', Colors.red);
    }
    setState(() => _saving = false);
  }

  void _snack(String msg, Color c) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontSize: 12)),
        backgroundColor: c,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _departureTime,
    );
    if (t != null) setState(() => _departureTime = t);
  }

  @override
  Widget build(BuildContext context) => Dialog(
    insetPadding: const EdgeInsets.all(16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _header(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sec('Route & Vehicle'),
                        const Gap(8),
                        _dd(
                          'Vehicle',
                          Icons.directions_bus,
                          _vehicleId,
                          _vehicles,
                          (v) => setState(() => _vehicleId = v),
                        ),
                        const Gap(8),
                        _dd(
                          'Route',
                          Icons.alt_route,
                          _routeId,
                          _routes,
                          (v) {
                            setState(() => _routeId = v);
                            if (v != null) {
                              setState(() => _loading = true);
                              _loadResources();
                            }
                          },
                          itemBuilder: (r) => r['description'] != null
                              ? '${r['name']} (${r['description']})'
                              : r['name']?.toString() ?? '',
                        ),
                        const Gap(12),
                        _sec('Staff'),
                        const Gap(8),
                        _dd(
                          'Driver',
                          Icons.person,
                          _driverId,
                          _drivers,
                          (v) => setState(() => _driverId = v),
                        ),
                        const Gap(8),
                        _dd(
                          'Relief Driver',
                          Icons.airline_seat_recline_normal,
                          _reliefDriverId,
                          _drivers,
                          (v) => setState(() => _reliefDriverId = v),
                        ),
                        const Gap(8),
                        if (_waypoints.isNotEmpty)
                          _dd(
                            'Handover Stop',
                            Icons.transfer_within_a_station,
                            _handoverStopId,
                            _waypoints,
                            (v) => setState(() => _handoverStopId = v),
                            itemBuilder: (w) =>
                                'Stop ${w['stop_order'] ?? '?'}: ${w['name'] ?? ''}',
                          ),
                        const Gap(8),
                        _dd(
                          'Conductor',
                          Icons.person_outline,
                          _conductorId,
                          _conductors,
                          (v) => setState(() => _conductorId = v),
                        ),
                        if (_conductors.isNotEmpty)
                          _chipSection(
                            'Additional Conductors',
                            _conductorIds,
                            _conductors,
                            'id',
                            'name',
                            const Color(0xFF8B5CF6),
                            Icons.group,
                          ),
                        const Gap(12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _pickTime,
                                icon: const Icon(Icons.access_time, size: 16),
                                label: Text(
                                  _departureTime.format(context),
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ),
                            const Gap(8),
                            Expanded(
                              child: SegmentedButton<String>(
                                segments: _shifts
                                    .map(
                                      (s) => ButtonSegment<String>(
                                        value: s,
                                        label: Text(
                                          s[0].toUpperCase() + s.substring(1),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: _shift == s
                                                ? Colors.white
                                                : _shiftColors[s],
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                selected: {_shift},
                                onSelectionChanged: (s) =>
                                    setState(() => _shift = s.first),
                                style: ButtonStyle(
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_legType == 'inbound') ...[
                          const Gap(8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF8B5CF6,
                              ).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.arrow_back,
                                  size: 14,
                                  color: Color(0xFF8B5CF6),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Return (Inbound) Leg',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF8B5CF6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const Gap(14),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: FilledButton.icon(
                            onPressed: _saving ? null : _save,
                            icon: _saving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.save, size: 18),
                            label: Text(
                              _saving ? 'Saving...' : 'Update Assignment',
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _header() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    decoration: const BoxDecoration(
      color: Color(0xFF1E293B),
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    child: Row(
      children: [
        const Icon(Icons.edit, color: Colors.white, size: 22),
        const Gap(10),
        const Expanded(
          child: Text(
            'Edit Assignment',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white70, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
  Widget _sec(String t) => Text(
    t,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: Color(0xFF1E293B),
    ),
  );
  Widget _dd(
    String label,
    IconData icon,
    String? value,
    List<Map<String, dynamic>> items,
    void Function(String?)? onChanged, {
    String Function(Map<String, dynamic>)? itemBuilder,
  }) => DropdownButtonFormField<String>(
    value: value,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 18),
      border: const OutlineInputBorder(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      isDense: true,
    ),
    isExpanded: true,
    items: [
      DropdownMenuItem<String>(
        value: null,
        child: Text(
          'Select...',
          style: const TextStyle(color: Color(0xFF94A3B8)),
        ),
      ),
      ...items.map(
        (i) => DropdownMenuItem<String>(
          value: i['id']?.toString(),
          child: Text(
            itemBuilder?.call(i) ?? i['name']?.toString() ?? '',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ),
    ],
    onChanged: onChanged,
    style: const TextStyle(fontSize: 13),
  );
  Widget _chipSection(
    String label,
    Set<String> selected,
    List<Map<String, dynamic>> all,
    String idKey,
    String nameKey,
    Color color,
    IconData icon,
  ) {
    final sel = all
        .where((i) => selected.contains(i[idKey]?.toString()))
        .toList();
    final avail = all
        .where((i) => !selected.contains(i[idKey]?.toString()))
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(4),
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
            if (avail.isNotEmpty)
              PopupMenuButton<String>(
                offset: const Offset(0, 36),
                constraints: const BoxConstraints(maxWidth: 240),
                onSelected: (id) => setState(
                  () =>
                      _conductorIds = Set<String>.from(_conductorIds)..add(id),
                ),
                itemBuilder: (_) => avail
                    .map(
                      (i) => PopupMenuItem<String>(
                        value: i[idKey]?.toString(),
                        child: Text(
                          i[nameKey]?.toString() ?? '',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
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
                          fontSize: 11,
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
        if (sel.isEmpty)
          const Text(
            'None',
            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          )
        else
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: sel
                .map(
                  (i) => Chip(
                    avatar: Icon(icon, size: 13, color: color),
                    label: Text(
                      i[nameKey]?.toString() ?? '',
                      style: const TextStyle(fontSize: 11),
                    ),
                    deleteIcon: const Icon(Icons.close, size: 14),
                    onDeleted: () => setState(
                      () =>
                          _conductorIds = Set<String>.from(_conductorIds)
                            ..remove(i[idKey]?.toString()),
                    ),
                    backgroundColor: color.withValues(alpha: 0.08),
                    side: BorderSide(color: color.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
// ACTIVE ASSIGNMENTS LIST (with edit button — Feature 1)
// ═══════════════════════════════════════════════════════════
class FleetDispatchList extends StatefulWidget {
  final String apiPrefix;
  final String? busCompanyId;

  const FleetDispatchList({
    super.key,
    required this.apiPrefix,
    this.busCompanyId,
  });

  @override
  State<FleetDispatchList> createState() => _FleetDispatchListState();
}

class _FleetDispatchListState extends State<FleetDispatchList> {
  final _api = ApiService();
  List<Map<String, dynamic>> _assignments = [];
  bool _loading = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await _api.get(
        '${widget.apiPrefix}/dispatch/assignments',
        queryParams: {'date': _fmtDate(_selectedDate), 'status': 'active'},
      );
      if (!mounted) return;
      setState(() {
        _assignments =
            (res?['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        _loading = false;
      });
    } catch (_) {
      if (mounted)
        setState(() {
          _loading = false;
          _assignments = [];
        });
    }
  }

  Future<void> _cancel(String id) async {
    try {
      await _api.delete('${widget.apiPrefix}/dispatch/assignments/$id');
      _load();
    } catch (_) {}
  }

  void _edit(Map<String, dynamic> a) {
    showDialog(
      context: context,
      builder: (_) => FleetDispatchEditDialog(
        apiPrefix: widget.apiPrefix,
        busCompanyId: widget.busCompanyId,
        assignment: a,
        onSaved: _load,
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) => Dialog(
    insetPadding: const EdgeInsets.all(16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 750, maxHeight: 750),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.list_alt, color: Colors.white, size: 22),
                const Gap(10),
                const Expanded(
                  child: Text(
                    'Active Assignments',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white70,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Color(0xFF64748B),
                ),
                const Gap(8),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.chevron_left, size: 20),
                  onPressed: () {
                    setState(
                      () => _selectedDate = _selectedDate.subtract(
                        const Duration(days: 1),
                      ),
                    );
                    _load();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 20),
                  onPressed: () {
                    setState(
                      () => _selectedDate = _selectedDate.add(
                        const Duration(days: 1),
                      ),
                    );
                    _load();
                  },
                ),
              ],
            ),
          ),
          Flexible(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _assignments.isEmpty
                ? const Center(
                    child: Text(
                      'No active assignments for this date.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _assignments.length,
                    itemBuilder: (_, i) => _card(_assignments[i]),
                  ),
          ),
        ],
      ),
    ),
  );

  Widget _card(Map<String, dynamic> a) {
    final sc = _shiftColors[a['shift_type']] ?? const Color(0xFF64748B);
    final isInbound = a['leg_type'] == 'inbound';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: sc.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    (a['shift_type'] ?? '').toString().toUpperCase() +
                        (isInbound ? ' ◀ INBOUND' : ''),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: sc,
                    ),
                  ),
                ),
                if (isInbound)
                  Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'RETURN',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                  ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: Color(0xFF3B82F6),
                  ),
                  tooltip: 'Edit',
                  onPressed: () => _edit(a),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(
                    Icons.cancel_outlined,
                    size: 16,
                    color: Color(0xFFEF4444),
                  ),
                  tooltip: 'Cancel',
                  onPressed: () => _cancel(a['id']),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const Gap(6),
            Text(
              a['route_name'] ?? '—',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            if (a['departure_time'] != null)
              Text(
                a['departure_time'].toString(),
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
            const Gap(4),
            Row(
              children: [
                const Icon(
                  Icons.directions_bus,
                  size: 14,
                  color: Color(0xFF64748B),
                ),
                const Gap(4),
                Expanded(
                  child: Text(
                    a['vehicle_name'] ?? '—',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
            const Gap(2),
            Row(
              children: [
                const Icon(Icons.person, size: 14, color: Color(0xFF64748B)),
                const Gap(4),
                Text(
                  'Driver: ${a['driver_name'] ?? '—'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            if (a['relief_driver_name'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  children: [
                    const Icon(
                      Icons.airline_seat_recline_normal,
                      size: 14,
                      color: Color(0xFFD97706),
                    ),
                    const Gap(4),
                    Text(
                      'Relief: ${a['relief_driver_name']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFD97706),
                      ),
                    ),
                  ],
                ),
              ),
            if (a['conductor_name'] != null ||
                (a['conductor_ids'] is List &&
                    (a['conductor_ids'] as List).isNotEmpty))
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                    const Gap(4),
                    Text(
                      'Cond: ${[if (a['conductor_name'] != null) a['conductor_name'], if (a['conductor_ids'] is List) ...(a['conductor_ids'] as List).map((e) => e.toString())].where((e) => e.isNotEmpty).take(3).join(', ')}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

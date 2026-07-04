// NEXATRACE — ADVANCED DISPATCH ENGINE v2.2
// =========================================
// Supports: multi-driver, relief conductor, handover for both driver + conductor.
// v2.2: Date range scheduling (From/To) + trip-linked catering issuance.

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
// SHARED BUILDERS (used by both Create and Edit dialogs)
// ═══════════════════════════════════════════════════════════

Widget _header(String title, IconData icon, {required VoidCallback onClose}) =>
    Container(
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
            onPressed: onClose,
          ),
        ],
      ),
    );

Widget _section(String t) => Text(
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
          itemBuilder?.call(i) ??
              '${i['name']?.toString() ?? ''}${i['external'] == true ? ' — (Owner: ${i['owner']})' : ''}',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            color: i['external'] == true ? const Color(0xFFD97706) : null,
          ),
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

String _fmtDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
String _fmtTime(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
List<Map<String, dynamic>> _cast(dynamic l) =>
    (l as List?)?.cast<Map<String, dynamic>>() ?? [];

// ═══════════════════════════════════════════════════════════
// CREATE ASSIGNMENT FORM
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
  List<Map<String, dynamic>> _v = [], _r = [], _d = [], _c = [], _wp = [];
  bool _loading = true, _saving = false;
  DateTime _dateFrom = DateTime.now();
  DateTime? _dateTo;

  String? _veh, _route, _drv, _relDrv, _con, _relCon, _handover;
  Set<String> _drvIds = {}, _conIds = {};
  String _shift = 'morning';
  bool _ret = false;
  String? _retDrv, _retRelDrv, _retCon, _retRelCon;
  Set<String> _retDrvIds = {}, _retConIds = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({String? routeId}) async {
    setState(() => _loading = true);
    try {
      final p = <String, dynamic>{
        if (widget.busCompanyId != null) 'bus_company_id': widget.busCompanyId,
        if (routeId != null) 'route_id': routeId,
      };
      final r = await _api.get(
        '${widget.apiPrefix}/dispatch/resources',
        queryParams: p,
      );
      final d = r?['data'] as Map<String, dynamic>? ?? {};
      if (!mounted) return;
      setState(() {
        _v = _cast(d['vehicles']);
        _r = _cast(d['routes']);
        _d = _cast(d['drivers']);
        _c = _cast(d['conductors']);
        _wp = _cast(d['waypoints']);
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (_veh == null || _route == null || _drv == null) {
      _snack('Vehicle, Route, Driver required.', Colors.red);
      return;
    }
    setState(() => _saving = true);
    try {
      final b = <String, dynamic>{
        if (widget.busCompanyId != null) 'bus_company_id': widget.busCompanyId,
        'vehicle_id': _veh,
        'route_id': _route,
        'driver_id': _drv,
        if (_drvIds.isNotEmpty) 'driver_ids': _drvIds.toList(),
        if (_relDrv != null) 'relief_driver_id': _relDrv,
        if (_con != null) 'conductor_id': _con,
        if (_conIds.isNotEmpty) 'conductor_ids': _conIds.toList(),
        if (_relCon != null) 'relief_conductor_id': _relCon,
        if (_handover != null) 'handover_stop_id': _handover,
        'assignment_date': _fmtDate(_dateFrom),
        if (_dateTo != null) 'assignment_date_to': _fmtDate(_dateTo!),
        'shift_type': _shift,
        'create_return_trip': _ret,
        if (_ret) ...{
          'return_driver_id': _retDrv ?? _drv,
          if (_retDrvIds.isNotEmpty) 'return_driver_ids': _retDrvIds.toList(),
          if (_retRelDrv != null) 'return_relief_driver_id': _retRelDrv,
          if (_retCon != null) 'return_conductor_id': _retCon,
          if (_retConIds.isNotEmpty)
            'return_conductor_ids': _retConIds.toList(),
          if (_retRelCon != null) 'return_relief_conductor_id': _retRelCon,
        },
      };
      final res = await _api.post(
        '${widget.apiPrefix}/dispatch/assignments',
        body: b,
      );
      if (res?['success'] == true) {
        _snack('Created!', const Color(0xFF16A34A));
        _reset();
        widget.onSaved?.call();
      } else {
        final cf = res?['conflicts'] as List? ?? [];
        _snack(
          cf.isNotEmpty ? cf.join('\n') : (res?['message'] ?? 'Error'),
          Colors.red,
        );
      }
    } catch (e) {
      _snack('Error: $e'.replaceAll('Exception: ', ''), Colors.red);
    }
    setState(() => _saving = false);
  }

  void _reset() => setState(() {
    _veh = null;
    _route = null;
    _drv = null;
    _drvIds = {};
    _relDrv = null;
    _con = null;
    _conIds = {};
    _relCon = null;
    _handover = null;
    _ret = false;
    _retDrv = null;
    _retDrvIds = {};
    _retRelDrv = null;
    _retCon = null;
    _retConIds = {};
    _retRelCon = null;
  });
  void _snack(String m, Color c) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(m, style: const TextStyle(fontSize: 12)),
        backgroundColor: c,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  bool get _hasHandover => _relDrv != null || _relCon != null;

  @override
  Widget build(BuildContext c) => Dialog(
    insetPadding: const EdgeInsets.all(16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 650, maxHeight: 900),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _header(
            'Create Assignment',
            Icons.add_task,
            onClose: () => Navigator.pop(context),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Start Date + End Date with labels
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Start Date',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Gap(4),
                                      OutlinedButton.icon(
                                        onPressed: () async {
                                          final p = await showDatePicker(
                                            context: c,
                                            initialDate: _dateFrom,
                                            firstDate: DateTime.now(),
                                            lastDate: DateTime(2030),
                                          );
                                          if (p != null)
                                            setState(() => _dateFrom = p);
                                        },
                                        icon: const Icon(
                                          Icons.calendar_today,
                                          size: 14,
                                          color: Colors.black,
                                        ),
                                        label: Text(
                                          _fmtDate(_dateFrom),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          side: const BorderSide(
                                            color: Color(0xFF475569),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 10,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Gap(8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'End Date',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Gap(4),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: () async {
                                                final p = await showDatePicker(
                                                  context: c,
                                                  initialDate:
                                                      _dateTo ?? _dateFrom,
                                                  firstDate: _dateFrom,
                                                  lastDate: DateTime(2030),
                                                );
                                                if (p != null)
                                                  setState(() => _dateTo = p);
                                              },
                                              icon: Icon(
                                                _dateTo != null
                                                    ? Icons.event
                                                    : Icons.event_outlined,
                                                size: 14,
                                                color: Colors.black,
                                              ),
                                              label: Text(
                                                _dateTo != null
                                                    ? _fmtDate(_dateTo!)
                                                    : 'Optional',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: _dateTo != null
                                                      ? Colors.black
                                                      : Colors.black54,
                                                  fontWeight: _dateTo != null
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                                ),
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                side: const BorderSide(
                                                  color: Color(0xFF475569),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 10,
                                                    ),
                                              ),
                                            ),
                                          ),
                                          if (_dateTo != null)
                                            IconButton(
                                              icon: const Icon(
                                                Icons.clear,
                                                size: 16,
                                                color: Colors.white54,
                                              ),
                                              onPressed: () => setState(
                                                () => _dateTo = null,
                                              ),
                                              tooltip: 'Clear end date',
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(
                                                minWidth: 24,
                                                minHeight: 24,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Gap(8),
                        // Shift selector
                        SegmentedButton<String>(
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
                          style: const ButtonStyle(
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        const Gap(12),
                        _section('Route & Vehicle'),
                        const Gap(8),
                        _dd(
                          'Vehicle',
                          Icons.directions_bus,
                          _veh,
                          _v,
                          (v) => setState(() => _veh = v),
                        ),
                        const Gap(8),
                        _dd(
                          'Route',
                          Icons.alt_route,
                          _route,
                          _r,
                          (v) {
                            setState(() => _route = v);
                            if (v != null) _load(routeId: v);
                          },
                          itemBuilder: (r) => r['description'] != null
                              ? '${r['name']} (${r['description']})'
                              : r['name']?.toString() ?? '',
                        ),
                        const Gap(12),
                        _section('Staff — Drivers'),
                        const Gap(8),
                        _dd(
                          'Primary Driver *',
                          Icons.person,
                          _drv,
                          _d,
                          (v) => setState(() => _drv = v),
                        ),
                        if (_d.isNotEmpty)
                          _chipSection(
                            'Additional Drivers',
                            _drvIds,
                            _d,
                            'id',
                            'name',
                            const Color(0xFF3B82F6),
                            Icons.group,
                            onChanged: (s) => setState(() => _drvIds = s),
                          ),
                        const Gap(8),
                        _dd(
                          'Relief Driver (handover)',
                          Icons.airline_seat_recline_normal,
                          _relDrv,
                          _d,
                          (v) => setState(() => _relDrv = v),
                        ),
                        const Gap(12),
                        _section('Staff — Conductor / Cabin Crew'),
                        const Gap(8),
                        _dd(
                          'Primary Conductor / Cabin Crew',
                          Icons.person_outline,
                          _con,
                          _c,
                          (v) => setState(() => _con = v),
                        ),
                        if (_c.isNotEmpty)
                          _chipSection(
                            'Additional Conductor / Cabin Crew',
                            _conIds,
                            _c,
                            'id',
                            'name',
                            const Color(0xFF8B5CF6),
                            Icons.group,
                            onChanged: (s) => setState(() => _conIds = s),
                          ),
                        const Gap(8),
                        _dd(
                          'Relief Conductor / Cabin Crew (handover)',
                          Icons.airline_seat_recline_extra,
                          _relCon,
                          _c,
                          (v) => setState(() => _relCon = v),
                        ),
                        const Gap(8),
                        if (_hasHandover && _wp.isNotEmpty)
                          _dd(
                            'Handover Stop (staff swap)',
                            Icons.transfer_within_a_station,
                            _handover,
                            _wp,
                            (v) => setState(() => _handover = v),
                            itemBuilder: (w) {
                              final a = w['arrival'];
                              final d = w['departure'];
                              final timing = [
                                if (a != null) 'Arr: $a',
                                if (d != null) 'Dep: $d',
                              ].join(' · ');
                              return 'Stop ${w['stop_order'] ?? '?'}: ${w['name'] ?? ''}${timing.isNotEmpty ? ' ($timing)' : ''}';
                            },
                          ),
                        const Gap(12),
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
                          value: _ret,
                          onChanged: (v) => setState(() => _ret = v),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        if (_ret) ...[
                          const Gap(8),
                          _section('Return — Drivers'),
                          const Gap(8),
                          _dd(
                            'Return Driver',
                            Icons.person,
                            _retDrv,
                            _d,
                            (v) => setState(() => _retDrv = v),
                          ),
                          if (_d.isNotEmpty)
                            _chipSection(
                              'Return Add. Drivers',
                              _retDrvIds,
                              _d,
                              'id',
                              'name',
                              const Color(0xFF3B82F6),
                              Icons.group,
                              onChanged: (s) => setState(() => _retDrvIds = s),
                            ),
                          const Gap(8),
                          _dd(
                            'Return Relief Driver',
                            Icons.airline_seat_recline_normal,
                            _retRelDrv,
                            _d,
                            (v) => setState(() => _retRelDrv = v),
                          ),
                          const Gap(8),
                          _section('Return — Conductor / Cabin Crew'),
                          const Gap(8),
                          _dd(
                            'Return Conductor / Cabin Crew',
                            Icons.person_outline,
                            _retCon,
                            _c,
                            (v) => setState(() => _retCon = v),
                          ),
                          if (_c.isNotEmpty)
                            _chipSection(
                              'Return Add. Conductor / Cabin Crew',
                              _retConIds,
                              _c,
                              'id',
                              'name',
                              const Color(0xFF8B5CF6),
                              Icons.group,
                              onChanged: (s) => setState(() => _retConIds = s),
                            ),
                          const Gap(8),
                          _dd(
                            'Return Relief Conductor / Cabin Crew',
                            Icons.airline_seat_recline_extra,
                            _retRelCon,
                            _c,
                            (v) => setState(() => _retRelCon = v),
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
                            label: Text(_saving ? 'Saving...' : 'Assign Duty'),
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

// ═══════════════════════════════════════════════════════════
// EDIT ASSIGNMENT DIALOG
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
  List<Map<String, dynamic>> _v = [], _r = [], _d = [], _c = [], _wp = [];
  bool _loading = true, _saving = false;
  late String? _veh, _route, _drv, _relDrv, _con, _relCon, _handover;
  late Set<String> _drvIds, _conIds;
  late String _shift, _leg;
  late TimeOfDay _time;

  @override
  void initState() {
    super.initState();
    final a = widget.assignment;
    _veh = a['vehicle_id']?.toString();
    _route = a['route_id']?.toString();
    _drv = a['driver_id']?.toString();
    _relDrv = a['relief_driver_id']?.toString();
    _con = a['conductor_id']?.toString();
    _relCon = a['relief_conductor_id']?.toString();
    _handover = a['handover_stop_id']?.toString();
    _drvIds = ((a['driver_ids'] as List?)?.map((e) => e.toString()) ?? const [])
        .toSet();
    _conIds =
        ((a['conductor_ids'] as List?)?.map((e) => e.toString()) ?? const [])
            .toSet();
    _shift = a['shift_type']?.toString() ?? 'morning';
    _leg = a['leg_type']?.toString() ?? 'outbound';
    if (a['departure_time'] != null) {
      final p = a['departure_time'].toString().split(':');
      _time = TimeOfDay(
        hour: int.tryParse(p[0]) ?? 8,
        minute: int.tryParse(p[1]) ?? 0,
      );
    } else {
      _time = const TimeOfDay(hour: 8, minute: 0);
    }
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final p = <String, dynamic>{
        if (widget.busCompanyId != null) 'bus_company_id': widget.busCompanyId,
        if (_route != null) 'route_id': _route,
      };
      final r = await _api.get(
        '${widget.apiPrefix}/dispatch/resources',
        queryParams: p,
      );
      final d = r?['data'] as Map<String, dynamic>? ?? {};
      if (!mounted) return;
      setState(() {
        _v = _cast(d['vehicles']);
        _r = _cast(d['routes']);
        _d = _cast(d['drivers']);
        _c = _cast(d['conductors']);
        _wp = _cast(d['waypoints']);
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final b = <String, dynamic>{
        'vehicle_id': _veh,
        'route_id': _route,
        'driver_id': _drv,
        'driver_ids': _drvIds.toList(),
        'relief_driver_id': _relDrv,
        'conductor_id': _con,
        'conductor_ids': _conIds.toList(),
        'relief_conductor_id': _relCon,
        'handover_stop_id': _handover,
        'departure_time': _fmtTime(_time),
        'shift_type': _shift,
        'leg_type': _leg,
      };
      await _api.put(
        '${widget.apiPrefix}/dispatch/assignments/${widget.assignment['id']}',
        body: b,
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

  void _snack(String m, Color c) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(m, style: const TextStyle(fontSize: 12)),
        backgroundColor: c,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _pickT() async {
    final t = await showTimePicker(context: context, initialTime: _time);
    if (t != null) setState(() => _time = t);
  }

  bool get _hasHandover => _relDrv != null || _relCon != null;

  @override
  Widget build(BuildContext c) => Dialog(
    insetPadding: const EdgeInsets.all(16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _header(
            'Edit Assignment',
            Icons.edit,
            onClose: () => Navigator.pop(context),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _section('Route & Vehicle'),
                        const Gap(8),
                        _dd(
                          'Vehicle',
                          Icons.directions_bus,
                          _veh,
                          _v,
                          (v) => setState(() => _veh = v),
                        ),
                        const Gap(8),
                        _dd(
                          'Route',
                          Icons.alt_route,
                          _route,
                          _r,
                          (v) {
                            setState(() => _route = v);
                            if (v != null) {
                              setState(() => _loading = true);
                              _load();
                            }
                          },
                          itemBuilder: (r) => r['description'] != null
                              ? '${r['name']} (${r['description']})'
                              : r['name']?.toString() ?? '',
                        ),
                        const Gap(12),
                        _section('Staff — Drivers'),
                        const Gap(8),
                        _dd(
                          'Driver',
                          Icons.person,
                          _drv,
                          _d,
                          (v) => setState(() => _drv = v),
                        ),
                        if (_d.isNotEmpty)
                          _chipSection(
                            'Additional Drivers',
                            _drvIds,
                            _d,
                            'id',
                            'name',
                            const Color(0xFF3B82F6),
                            Icons.group,
                            onChanged: (s) => setState(() => _drvIds = s),
                          ),
                        const Gap(8),
                        _dd(
                          'Relief Driver',
                          Icons.airline_seat_recline_normal,
                          _relDrv,
                          _d,
                          (v) => setState(() => _relDrv = v),
                        ),
                        const Gap(12),
                        _section('Staff — Conductor / Cabin Crew'),
                        const Gap(8),
                        _dd(
                          'Conductor / Cabin Crew',
                          Icons.person_outline,
                          _con,
                          _c,
                          (v) => setState(() => _con = v),
                        ),
                        if (_c.isNotEmpty)
                          _chipSection(
                            'Additional Conductor / Cabin Crew',
                            _conIds,
                            _c,
                            'id',
                            'name',
                            const Color(0xFF8B5CF6),
                            Icons.group,
                            onChanged: (s) => setState(() => _conIds = s),
                          ),
                        const Gap(8),
                        _dd(
                          'Relief Conductor / Cabin Crew',
                          Icons.airline_seat_recline_extra,
                          _relCon,
                          _c,
                          (v) => setState(() => _relCon = v),
                        ),
                        const Gap(8),
                        if (_hasHandover && _wp.isNotEmpty)
                          _dd(
                            'Handover Stop',
                            Icons.transfer_within_a_station,
                            _handover,
                            _wp,
                            (v) => setState(() => _handover = v),
                            itemBuilder: (w) {
                              final a = w['arrival'];
                              final d = w['departure'];
                              final timing = [
                                if (a != null) 'Arr: $a',
                                if (d != null) 'Dep: $d',
                              ].join(' · ');
                              return 'Stop ${w['stop_order'] ?? '?'}: ${w['name'] ?? ''}${timing.isNotEmpty ? ' ($timing)' : ''}';
                            },
                          ),
                        const Gap(12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _pickT,
                                icon: const Icon(Icons.access_time, size: 16),
                                label: Text(
                                  _time.format(c),
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
                        if (_leg == 'inbound') ...[
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
}

// ═══════════════════════════════════════════════════════════
// ACTIVE ASSIGNMENTS LIST
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
  List<Map<String, dynamic>> _a = [];
  bool _loading = true;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final r = await _api.get(
        '${widget.apiPrefix}/dispatch/assignments',
        queryParams: {'date': _fmtDate(_date), 'status': 'active'},
      );
      if (!mounted) return;
      setState(() {
        _a = (r?['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        _loading = false;
      });
    } catch (_) {
      if (mounted)
        setState(() {
          _loading = false;
          _a = [];
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

  @override
  Widget build(BuildContext c) => Dialog(
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
                  '${_date.day}/${_date.month}/${_date.year}',
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
                      () => _date = _date.subtract(const Duration(days: 1)),
                    );
                    _load();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 20),
                  onPressed: () {
                    setState(() => _date = _date.add(const Duration(days: 1)));
                    _load();
                  },
                ),
              ],
            ),
          ),
          Flexible(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _a.isEmpty
                ? const Center(
                    child: Text(
                      'No active assignments for this date.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _a.length,
                    itemBuilder: (_, i) => _card(_a[i]),
                  ),
          ),
        ],
      ),
    ),
  );

  Widget _card(Map<String, dynamic> a) {
    final sc = _shiftColors[a['shift_type']] ?? const Color(0xFF64748B);
    final inbound = a['leg_type'] == 'inbound';
    final drvIds = (a['driver_ids'] as List?)?.map((e) => e.toString()) ?? [];
    final conIds =
        (a['conductor_ids'] as List?)?.map((e) => e.toString()) ?? [];
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
                        (inbound ? ' ◀ INBOUND' : ''),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: sc,
                    ),
                  ),
                ),
                if (inbound)
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
                Expanded(
                  child: Text(
                    [
                      a['driver_name'] ?? '',
                      ...drvIds,
                    ].where((e) => e.isNotEmpty).join(', '),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (a['relief_driver_name'] != null ||
                a['relief_conductor_name'] != null)
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
                    Expanded(
                      child: Text(
                        [
                          if (a['relief_driver_name'] != null)
                            'D: ${a['relief_driver_name']}',
                          if (a['relief_conductor_name'] != null)
                            'Crew: ${a['relief_conductor_name']}',
                        ].join(' · '),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFD97706),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            if (a['conductor_name'] != null || conIds.isNotEmpty)
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
                    Expanded(
                      child: Text(
                        [
                          if (a['conductor_name'] != null) a['conductor_name'],
                          ...conIds,
                        ].where((e) => e.isNotEmpty).join(', '),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                        overflow: TextOverflow.ellipsis,
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

// NEXATRACE — LIVE DISPATCH & DUTY ASSIGNMENT ENGINE
// ======================================================
// Two independent views for assigning and viewing fleet
// dispatch entries. Used by both bus-fleet and bus-owner
// dashboards via a sub-menu button pattern.
//
// MODULE: 14C — Active Fleet Scheduling

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/core/services/api_service.dart';

// ═══════════════════════════════════════════════════════════
// SHARED CONSTANTS
// ═══════════════════════════════════════════════════════════
const _shifts = ['morning', 'evening', 'night', 'special'];
const _shiftColors = <String, Color>{
  'morning': Color(0xFFF59E0B),
  'evening': Color(0xFF8B5CF6),
  'night': Color(0xFF1E293B),
  'special': Color(0xFFEF4444),
};

// ═══════════════════════════════════════════════════════════
// FLEET DISPATCH FORM (Create Assignment)
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

  List<Map<String, dynamic>> _vehicles = [];
  List<Map<String, dynamic>> _routes = [];
  List<Map<String, dynamic>> _drivers = [];
  List<Map<String, dynamic>> _conductors = [];

  bool _loading = true;
  bool _saving = false;

  DateTime _selectedDate = DateTime.now();
  String? _selectedVehicleId;
  String? _selectedRouteId;
  String? _selectedDriverId;
  String? _selectedConductorId;
  String _selectedShift = 'morning';

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  Future<void> _loadResources() async {
    setState(() => _loading = true);
    try {
      final params = <String, dynamic>{};
      if (widget.busCompanyId != null) {
        params['bus_company_id'] = widget.busCompanyId;
      }
      final res = await _api.get(
        '${widget.apiPrefix}/dispatch/resources',
        queryParams: params,
      );
      final data = res?['data'] as Map<String, dynamic>? ?? {};
      if (!mounted) return;
      setState(() {
        _vehicles =
            (data['vehicles'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        _routes = (data['routes'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        _drivers =
            (data['drivers'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        _conductors =
            (data['conductors'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (_selectedVehicleId == null ||
        _selectedRouteId == null ||
        _selectedDriverId == null) {
      _snack('Please select Vehicle, Route, and Driver.', Colors.red);
      return;
    }
    setState(() => _saving = true);
    try {
      final dateStr = _fmtDate(_selectedDate);
      final body = <String, dynamic>{
        if (widget.busCompanyId != null) 'bus_company_id': widget.busCompanyId,
        'vehicle_id': _selectedVehicleId,
        'route_id': _selectedRouteId,
        'driver_id': _selectedDriverId,
        if (_selectedConductorId != null) 'conductor_id': _selectedConductorId,
        'assignment_date': dateStr,
        'shift_type': _selectedShift,
      };
      final res = await _api.post(
        '${widget.apiPrefix}/dispatch/assignments',
        body: body,
      );
      if (res?['success'] == true) {
        _snack('Assignment created!', const Color(0xFF16A34A));
        setState(() {
          _selectedVehicleId = null;
          _selectedRouteId = null;
          _selectedDriverId = null;
          _selectedConductorId = null;
        });
        widget.onSaved?.call();
      } else {
        final conflicts = res?['conflicts'] as List? ?? [];
        final msg = conflicts.isNotEmpty
            ? conflicts.join('\n')
            : (res?['message'] ?? 'Unknown error');
        _snack(msg, Colors.red);
      }
    } catch (e) {
      _snack(
        'Error: ${e.toString().replaceAll('Exception: ', '')}',
        Colors.red,
      );
    }
    setState(() => _saving = false);
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontSize: 12)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _dateShiftRow(),
                          const Gap(14),
                          _sectionLabel('Assignment Details'),
                          const Gap(8),
                          _dropdown(
                            label: 'Vehicle',
                            icon: Icons.directions_bus,
                            value: _selectedVehicleId,
                            items: _vehicles,
                            hint: 'Select vehicle...',
                            onChanged: (v) =>
                                setState(() => _selectedVehicleId = v),
                          ),
                          const Gap(10),
                          _dropdown(
                            label: 'Route',
                            icon: Icons.alt_route,
                            value: _selectedRouteId,
                            items: _routes,
                            hint: 'Select route...',
                            itemBuilder: (r) => r['description'] != null
                                ? '${r['name']} (${r['description']})'
                                : r['name']?.toString() ?? '',
                            onChanged: (v) =>
                                setState(() => _selectedRouteId = v),
                          ),
                          const Gap(10),
                          _dropdown(
                            label: 'Driver',
                            icon: Icons.person,
                            value: _selectedDriverId,
                            items: _drivers,
                            hint: 'Select driver...',
                            onChanged: (v) =>
                                setState(() => _selectedDriverId = v),
                          ),
                          const Gap(10),
                          _dropdown(
                            label: 'Conductor (optional)',
                            icon: Icons.person_outline,
                            value: _selectedConductorId,
                            items: _conductors,
                            hint: 'Select conductor...',
                            onChanged: (v) =>
                                setState(() => _selectedConductorId = v),
                          ),
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

  Widget _header() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    decoration: const BoxDecoration(
      color: Color(0xFF1E293B),
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    child: Row(
      children: [
        const Icon(Icons.add_task, color: Colors.white, size: 22),
        const Gap(10),
        const Expanded(
          child: Text(
            'Create Assignment',
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

  Widget _dateShiftRow() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: OutlinedButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2024),
                lastDate: DateTime(2030),
              );
              if (picked != null) setState(() => _selectedDate = picked);
            },
            icon: const Icon(Icons.calendar_today, size: 16),
            label: Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ),
        const Gap(10),
        Expanded(
          flex: 3,
          child: SegmentedButton<String>(
            segments: _shifts.map((s) {
              final color = _shiftColors[s] ?? Colors.grey;
              return ButtonSegment<String>(
                value: s,
                label: Text(
                  s[0].toUpperCase() + s.substring(1),
                  style: TextStyle(
                    fontSize: 12,
                    color: _selectedShift == s ? Colors.white : color,
                  ),
                ),
              );
            }).toList(),
            selected: {_selectedShift},
            onSelectionChanged: (sel) =>
                setState(() => _selectedShift = sel.first),
            style: ButtonStyle(visualDensity: VisualDensity.compact),
          ),
        ),
      ],
    );
  }

  Widget _dropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<Map<String, dynamic>> items,
    required String hint,
    String Function(Map<String, dynamic>)? itemBuilder,
    required void Function(String?)? onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        isDense: true,
      ),
      isExpanded: true,
      items: [
        DropdownMenuItem<String>(
          value: null,
          child: Text(hint, style: const TextStyle(color: Color(0xFF94A3B8))),
        ),
        ...items.map((item) {
          final id = item['id']?.toString() ?? '';
          final display =
              itemBuilder?.call(item) ?? item['name']?.toString() ?? id;
          return DropdownMenuItem<String>(
            value: id,
            child: Text(
              display,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
          );
        }),
      ],
      onChanged: onChanged,
      style: const TextStyle(fontSize: 13),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: Color(0xFF1E293B),
    ),
  );
}

// ═══════════════════════════════════════════════════════════
// FLEET DISPATCH LIST (Active Assignments)
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
      final dateStr = _fmtDate(_selectedDate);
      final res = await _api.get(
        '${widget.apiPrefix}/dispatch/assignments',
        queryParams: {'date': dateStr, 'status': 'active'},
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Assignment cancelled.'),
            backgroundColor: Color(0xFFF59E0B),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
      _load();
    } catch (_) {}
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 750),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──
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

            // ── Date filter ──
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

            // ── List body ──
            Flexible(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _assignments.isEmpty
                  ? const Center(
                      child: Text(
                        'No active assignments for this date.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF94A3B8),
                        ),
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
  }

  Widget _card(Map<String, dynamic> a) {
    final shiftColor = _shiftColors[a['shift_type']] ?? const Color(0xFF64748B);
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
                    color: shiftColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    (a['shift_type'] ?? '').toString().toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: shiftColor,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.cancel_outlined,
                    size: 18,
                    color: Color(0xFFEF4444),
                  ),
                  tooltip: 'Cancel assignment',
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
                if (a['conductor_name'] != null) ...[
                  const Gap(12),
                  const Icon(
                    Icons.person_outline,
                    size: 14,
                    color: Color(0xFF64748B),
                  ),
                  const Gap(4),
                  Text(
                    'Cond: ${a['conductor_name']}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

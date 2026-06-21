// NEXATRACE — ROUTE DETAIL SCREEN
// =================================
// Read-only detail view for a transit route.
// Displays full metadata: header, info row, assigned
// voucher/bonus badges, and a complete waypoint list.
//
// MODULE: 13B — Dynamic Route & Waypoint Line Scheduler

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/core/services/api_service.dart';

class RouteDetailScreen extends StatefulWidget {
  final String routeId;
  const RouteDetailScreen({super.key, required this.routeId});
  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  final _api = ApiService();
  Map<String, dynamic>? _route;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final r = await _api.get('/bus-fleet/routes/${widget.routeId}');
      setState(() {
        _route = r is Map<String, dynamic> ? r : (r['data'] ?? r);
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _disp(dynamic v) => (v ?? '').toString();

  String _dispNum(num? v, [int digits = 0]) => (v ?? 0).toStringAsFixed(digits);

  Color _statusColor(String? status) =>
      status == 'published' ? const Color(0xFF16A34A) : const Color(0xFFF59E0B);

  Color _statusBg(String? status) =>
      (status == 'published'
              ? const Color(0xFF16A34A)
              : const Color(0xFFF59E0B))
          .withValues(alpha: 0.1);

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: _appBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_route == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: _appBar(),
        body: const Center(
          child: Text(
            'Route not found',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
        ),
      );
    }

    final r = _route!;
    final wps = (r['waypoints'] as List?) ?? [];
    final vouchers = (r['assigned_vouchers'] as List?) ?? [];
    final bonuses = (r['assigned_bonuses'] as List?) ?? [];
    final isPublished = r['status'] == 'published';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _appBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---- Header card ----
          _sectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _disp(r['route_code']),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const Gap(8),
                    _statusChip(r['status']),
                  ],
                ),
                const Gap(6),
                Text(
                  _disp(r['display_name']),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const Gap(8),
                Row(
                  children: [
                    const Icon(
                      Icons.trip_origin,
                      size: 16,
                      color: Color(0xFF16A34A),
                    ),
                    const Gap(4),
                    Expanded(
                      child: Text(
                        _disp(r['origin_name']),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Color(0xFFEF4444),
                    ),
                    const Gap(4),
                    Expanded(
                      child: Text(
                        _disp(r['destination_name']),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Gap(12),

          // ---- Info row ----
          _sectionCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _infoTile(
                  Icons.straighten,
                  '${_dispNum(r['total_distance_km'])} km',
                  'Distance',
                ),
                Container(width: 1, height: 36, color: const Color(0xFFE2E8F0)),
                _infoTile(Icons.flag_outlined, '${wps.length}', 'Stops'),
                Container(width: 1, height: 36, color: const Color(0xFFE2E8F0)),
                _infoTile(
                  isPublished ? Icons.check_circle : Icons.edit_road,
                  isPublished ? 'Published' : 'Draft',
                  'Status',
                  iconColor: _statusColor(r['status']),
                ),
              ],
            ),
          ),

          // ---- Badge sections ----
          if (vouchers.isNotEmpty) ...[
            const Gap(16),
            _buildBadgeSection(
              label: 'Assigned Vouchers',
              items: vouchers.cast<Map<String, dynamic>>(),
              chipColor: const Color(0xFF3B82F6),
              icon: Icons.card_giftcard,
              primaryText: (v) => _disp(v['title']),
              subText: (v) {
                final type = _disp(v['type']);
                return type.isEmpty ? null : type;
              },
            ),
          ],
          if (bonuses.isNotEmpty) ...[
            const Gap(16),
            _buildBadgeSection(
              label: 'Assigned Bonuses',
              items: bonuses.cast<Map<String, dynamic>>(),
              chipColor: const Color(0xFFF59E0B),
              icon: Icons.star,
              primaryText: (b) => _disp(b['bonus_name']),
              subText: (b) {
                final staff = _disp(b['staff_type']);
                final cat = _disp(b['bonus_category']);
                if (staff.isEmpty && cat.isEmpty) return null;
                if (staff.isEmpty) return cat;
                if (cat.isEmpty) return staff;
                return '$staff · $cat';
              },
            ),
          ],

          const Gap(16),

          // ---- Waypoints section ----
          _sectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.alt_route,
                      size: 18,
                      color: Color(0xFF64748B),
                    ),
                    const Gap(6),
                    Text(
                      'Waypoints (${wps.length})',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                const Gap(10),
                if (wps.isEmpty)
                  const Text(
                    'No waypoints defined',
                    style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  )
                else
                  ...List.generate(wps.length, (i) {
                    final wp = wps[i] as Map<String, dynamic>;
                    final isFirst = i == 0;
                    final isLast = i == wps.length - 1;
                    return _waypointRow(
                      wp,
                      i,
                      isFirst: isFirst,
                      isLast: isLast,
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // App bar
  // ---------------------------------------------------------------------------

  PreferredSizeWidget _appBar() => AppBar(
    title: const Text(
      'Route Details',
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    ),
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
  );

  // ---------------------------------------------------------------------------
  // Shared widgets
  // ---------------------------------------------------------------------------

  Widget _sectionCard({required Widget child}) => Card(
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    elevation: 1,
    color: Colors.white,
    child: Padding(padding: const EdgeInsets.all(16), child: child),
  );

  Widget _infoTile(
    IconData icon,
    String value,
    String label, {
    Color? iconColor,
  }) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor ?? const Color(0xFF64748B)),
          const Gap(5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
      const Gap(2),
      Text(
        label,
        style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
      ),
    ],
  );

  Widget _statusChip(String? status) {
    final isPub = status == 'published';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _statusBg(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isPub ? 'Published' : 'Draft',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _statusColor(status),
        ),
      ),
    );
  }

  // ---- Badge chip section ----

  Widget _buildBadgeSection({
    required String label,
    required List<Map<String, dynamic>> items,
    required Color chipColor,
    required IconData icon,
    required String Function(Map<String, dynamic>) primaryText,
    String? Function(Map<String, dynamic>)? subText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            final name = primaryText(item);
            final sub = subText?.call(item);
            return Chip(
              avatar: Icon(icon, size: 14, color: chipColor),
              label: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
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
              backgroundColor: chipColor.withValues(alpha: 0.08),
              side: BorderSide(color: chipColor.withValues(alpha: 0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ---- Waypoint row ----

  Widget _waypointRow(
    Map<String, dynamic> wp,
    int index, {
    required bool isFirst,
    required bool isLast,
  }) {
    final order = _disp(wp['stop_order'] ?? (index + 1));
    final name = _disp(wp['station_name']);
    final lat = (wp['latitude'] ?? wp['lat'])?.toString() ?? '';
    final lng = (wp['longitude'] ?? wp['lng'])?.toString() ?? '';
    final dist = wp['distance_from_origin'] is num
        ? '${(wp['distance_from_origin'] as num).toStringAsFixed(1)} km'
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stop-order marker
            SizedBox(
              width: 32,
              child: Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isFirst
                          ? const Color(0xFF16A34A)
                          : isLast
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF3B82F6),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: isFirst
                        ? const Icon(
                            Icons.trip_origin,
                            size: 14,
                            color: Colors.white,
                          )
                        : isLast
                        ? const Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.white,
                          )
                        : Text(
                            order,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: const Color(0xFFCBD5E1),
                      ),
                    ),
                ],
              ),
            ),
            const Gap(10),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    if (lat.isNotEmpty || lng.isNotEmpty) ...[
                      const Gap(2),
                      Text(
                        [lat, lng].where((e) => e.isNotEmpty).join(', '),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                    if (dist != null) ...[
                      const Gap(2),
                      Text(
                        dist,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

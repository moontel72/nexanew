// NEXATRACE — TICKET MANAGEMENT SCREEN
// =======================================
// Admin ticket control & reporting center.
// Shows issued tickets, active holds, sold seats,
// and revenue per active trip/route.
//
// MODULE: 13D — Ticket Revenue Ledger Hub

import 'package:flutter/material.dart';
import 'package:trace_odd/core/services/api_service.dart';

class TicketManagementScreen extends StatefulWidget {
  final String panelPrefix; // '/bus-fleet' or '/bus-owner'
  const TicketManagementScreen({super.key, this.panelPrefix = '/bus-fleet'});

  @override
  State<TicketManagementScreen> createState() => _TicketManagementScreenState();
}

class _TicketManagementScreenState extends State<TicketManagementScreen> {
  final _api = ApiService();
  List<Map<String, dynamic>> _routes = [];
  Map<String, dynamic>? _routeStats;
  String? _selectedRouteId;
  bool _loadingRoutes = true, _loadingStats = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    setState(() {
      _loadingRoutes = true;
      _error = null;
    });
    try {
      final res = await _api.get('${widget.panelPrefix}/routes');
      final data = res?['data'];
      if (data is List) _routes = data.cast<Map<String, dynamic>>();
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loadingRoutes = false);
  }

  Future<void> _loadStats(String routeId) async {
    setState(() {
      _loadingStats = true;
      _selectedRouteId = routeId;
    });
    try {
      final res = await _api.get(
        '${widget.panelPrefix}/routes/$routeId/ticket-stats',
      );
      _routeStats = res?['data'] as Map<String, dynamic>?;
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    if (mounted) setState(() => _loadingStats = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Ticket Management'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadRoutes),
        ],
      ),
      body: _loadingRoutes
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Route selector
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.white,
                  child: DropdownButtonFormField<String>(
                    value: _selectedRouteId,
                    decoration: const InputDecoration(
                      labelText: 'Select Route',
                      border: OutlineInputBorder(),
                    ),
                    items: _routes
                        .map(
                          (r) => DropdownMenuItem(
                            value: r['id']?.toString(),
                            child: Text(
                              r['display_name'] ??
                                  r['route_code'] ??
                                  'Untitled',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) _loadStats(v);
                    },
                  ),
                ),
                Expanded(
                  child: _selectedRouteId == null
                      ? const Center(
                          child: Text(
                            'Select a route to view ticket statistics',
                          ),
                        )
                      : _loadingStats
                      ? const Center(child: CircularProgressIndicator())
                      : _routeStats == null
                      ? const Center(child: Text('No data'))
                      : _buildStatsView(),
                ),
              ],
            ),
    );
  }

  Widget _buildStatsView() {
    final s = _routeStats!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _statCard(
          'Total Issued Tickets',
          '${s['total_issued'] ?? 0}',
          Icons.confirmation_num,
          const Color(0xFF2563EB),
        ),
        _statCard(
          'Active Holds',
          '${s['active_holds'] ?? 0}',
          Icons.timer,
          const Color(0xFFF59E0B),
        ),
        _statCard(
          'Total Booked Seats',
          '${s['total_booked'] ?? 0}',
          Icons.event_seat,
          const Color(0xFF16A34A),
        ),
        _statCard(
          'Passengers Boarded',
          '${s['total_boarded'] ?? 0}',
          Icons.directions_bus,
          const Color(0xFF7C3AED),
        ),
        _statCard(
          'Total Revenue',
          'Rs. ${(s['total_revenue'] as num?)?.toStringAsFixed(0) ?? '0'}',
          Icons.monetization_on,
          const Color(0xFF059669),
        ),
        const SizedBox(height: 16),
        const Text(
          'Recent Trips',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ..._buildTripList(),
      ],
    );
  }

  List<Widget> _buildTripList() {
    final trips = (_routeStats!['recent_trips'] as List<dynamic>?) ?? [];
    if (trips.isEmpty) return [const Text('No trips yet.')];
    return trips.map((t) {
      final status = t['status'] ?? 'unknown';
      final color = status == 'active'
          ? const Color(0xFF16A34A)
          : status == 'completed'
          ? const Color(0xFF64748B)
          : const Color(0xFFF59E0B);
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Icon(Icons.route, color: color),
          title: Text(
            '${t['origin'] ?? ''} → ${t['destination'] ?? ''}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            'Status: $status${t['scheduled_departure_at'] != null ? ' · ${t['scheduled_departure_at']}' : ''}',
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status.toString().toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

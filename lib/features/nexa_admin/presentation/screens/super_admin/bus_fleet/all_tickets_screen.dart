// NEXATRACE — ALL TICKETS SCREEN
// ===============================
// Displays all station-to-station ticket fare structures for a route.
// Each segment can be downloaded as a printable PDF ticket.
//
// MODULE: 13B — Route Scheduler Pricing & Ticketing

import 'package:flutter/material.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/core/constants/api_endpoints.dart';
import 'dart:html' as html;

class AllTicketsScreen extends StatefulWidget {
  final String routeId, routeName, panelPrefix, originCity, destCity;
  final List<dynamic> waypoints;
  const AllTicketsScreen({
    super.key,
    required this.routeId,
    required this.routeName,
    required this.originCity,
    required this.destCity,
    required this.waypoints,
    this.panelPrefix = '/bus-fleet',
  });
  @override
  State<AllTicketsScreen> createState() => _AllTicketsScreenState();
}

class _AllTicketsScreenState extends State<AllTicketsScreen> {
  final _api = ApiService();
  List<Map<String, dynamic>> _prices = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await _api.get(
        '${widget.panelPrefix}/routes/${widget.routeId}/pricing',
      );
      final data = res?['data'];
      final raw = (data?['prices'] as List?) ?? [];
      // Filter out self-referencing and duplicates
      final seen = <String>{};
      _prices = raw.cast<Map<String, dynamic>>().where((p) {
        final from = p['from_station']?.toString() ?? '';
        final to = p['to_station']?.toString() ?? '';
        if (from == to) return false;
        final key = '$from→$to';
        if (seen.contains(key)) return false;
        seen.add(key);
        return true;
      }).toList();
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _downloadPdf(Map<String, dynamic> segment) async {
    try {
      final segId = segment['id']?.toString() ?? '';
      final url = ApiEndpoints.getFullUrl(
        '${widget.panelPrefix}/routes/${widget.routeId}/pricing/$segId/pdf',
      );
      // Open PDF in new tab for download
      html.window.open(url, '_blank');
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF error: $e')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('All Tickets: ${widget.routeName}'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Error: $_error', style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                      FilledButton(onPressed: _load, child: const Text('Retry')),
                    ],
                  ),
                )
              : _prices.isEmpty
                  ? const Center(
                      child: Text(
                        'No ticket prices set yet.\n\nGo to Pricing editor to add prices for each segment.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _prices.length,
                      itemBuilder: (ctx, i) => _ticketCard(_prices[i]),
                    ),
    );
  }

  Widget _ticketCard(Map<String, dynamic> p) {
    final from = p['from_station']?.toString() ?? '?';
    final to = p['to_station']?.toString() ?? '?';
    final price = (p['price'] as num?)?.toStringAsFixed(0) ?? '0';
    final km = p['distance_km'];
    final segId = p['id']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Route icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.directions_bus, color: Color(0xFF0D9488)),
            ),
            const SizedBox(width: 14),
            // Segment info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$from → $to',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Rs. $price',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF059669),
                          fontSize: 16,
                        ),
                      ),
                      if (km != null && km > 0) ...[
                        const SizedBox(width: 12),
                        Text(
                          '$km km',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'ID: ${segId.substring(0, 8)}...',
                    style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
            // PDF download button
            IconButton(
              icon: const Icon(Icons.picture_as_pdf, color: Color(0xFFDC2626)),
              tooltip: 'Download PDF Ticket',
              onPressed: () => _downloadPdf(p),
            ),
          ],
        ),
      ),
    );
  }
}

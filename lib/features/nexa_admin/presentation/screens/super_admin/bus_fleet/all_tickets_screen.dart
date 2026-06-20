// NEXATRACE — ALL TICKETS SCREEN
// ===============================
// Displays all station-to-station ticket fare structures for a route.
// Generates every possible segment pair from the route's waypoints
// and overlays saved pricing data. Each priced segment can be
// downloaded as a printable HTML ticket.
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
  List<_TicketSegment> _segments = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Fetch saved pricing data
      Map<String, Map<String, dynamic>> priceMap = {};
      try {
        final res = await _api.get(
          '${widget.panelPrefix}/routes/${widget.routeId}/pricing',
        );
        final data = res?['data'];
        final prices = (data?['prices'] as List?) ?? [];
        for (final p in prices) {
          if (p is Map) {
            // Key by stop order — immune to station name drift
            final fromOrd = p['from_stop_order'];
            final toOrd = p['to_stop_order'];
            if (fromOrd != null && toOrd != null) {
              final key = '${fromOrd}→${toOrd}';
              // Keep the first entry if duplicate stop-order pairs exist
              priceMap[key] ??= Map<String, dynamic>.from(p);
            }
          }
        }
      } catch (_) {
        // Pricing fetch failed — continue with empty prices
      }

      // Build full station list: Origin + waypoints + Destination
      final stations = <String>[];
      stations.add(widget.originCity.isNotEmpty ? widget.originCity : 'Origin');
      for (final w in widget.waypoints) {
        final name =
            (w is Map ? w['station_name']?.toString() : w?.toString()) ?? '';
        if (name.isNotEmpty && name != stations.last) {
          stations.add(name);
        }
      }
      final dest = widget.destCity.isNotEmpty ? widget.destCity : 'Destination';
      if (dest != stations.last) {
        stations.add(dest);
      }

      // Generate all segment pairs, matching pricing by stop order
      final segments = <_TicketSegment>[];
      final seenNames = <String>{};
      for (int i = 0; i < stations.length; i++) {
        for (int j = i + 1; j < stations.length; j++) {
          final from = stations[i];
          final to = stations[j];
          // Skip self-referencing (station cannot route to itself)
          if (from == to) continue;
          // Skip duplicate station-name pairs
          final nameKey = '$from→$to';
          if (seenNames.contains(nameKey)) continue;
          seenNames.add(nameKey);

          // Match by stop-order index — exact, not fuzzy string match
          final orderKey = '$i→$j';
          final saved = priceMap[orderKey];
          segments.add(
            _TicketSegment(
              from: from,
              to: to,
              price: saved?['price'],
              distanceKm: saved?['distance_km'],
              segmentId: saved?['id']?.toString(),
              isConsecutive: j == i + 1,
              fromOrder: i,
              toOrder: j,
            ),
          );
        }
      }

      _segments = segments;
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  void _openPdf(_TicketSegment seg) {
    if (seg.segmentId == null) return;
    final url = ApiEndpoints.getFullUrl(
      '${widget.panelPrefix}/routes/${widget.routeId}/pricing/${seg.segmentId}/pdf',
    );
    html.window.open(url, '_blank');
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
          ? _buildError()
          : _segments.isEmpty
          ? _buildEmpty()
          : _buildSegmentList(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              'Failed to load ticket data',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              onPressed: _load,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.confirmation_num_outlined,
              size: 56,
              color: Color(0xFF94A3B8),
            ),
            const SizedBox(height: 16),
            const Text(
              'No route segments found',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'This route has no waypoints or stations defined.\nAdd stops via the Route Editor first.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              onPressed: _load,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentList() {
    return Column(
      children: [
        // Summary header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              const Icon(Icons.route, color: Color(0xFF0D9488)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.originCity} → ${widget.destCity}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '${_segments.length} segment${_segments.length == 1 ? '' : 's'} · '
                      '${_segments.where((s) => s.price != null).length} priced',
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
        // Segment list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _segments.length,
            itemBuilder: (ctx, i) => _segmentCard(_segments[i]),
          ),
        ),
      ],
    );
  }

  Widget _segmentCard(_TicketSegment seg) {
    final hasPrice = seg.price != null && (seg.price as num) > 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: hasPrice
                    ? const Color(0xFF059669).withValues(alpha: 0.1)
                    : const Color(0xFF94A3B8).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                hasPrice ? Icons.confirmation_num : Icons.edit_calendar,
                color: hasPrice
                    ? const Color(0xFF059669)
                    : const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${seg.from} → ${seg.to}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (hasPrice)
                    Row(
                      children: [
                        Text(
                          'Rs. ${(seg.price as num).toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF059669),
                            fontSize: 16,
                          ),
                        ),
                        if (seg.distanceKm != null && seg.distanceKm > 0) ...[
                          const SizedBox(width: 12),
                          Text(
                            '${seg.distanceKm} km',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ],
                    )
                  else
                    Text(
                      seg.isConsecutive ? 'Not priced yet' : 'Not priced',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
            // Action button
            if (hasPrice)
              IconButton(
                icon: const Icon(
                  Icons.picture_as_pdf,
                  color: Color(0xFFDC2626),
                ),
                tooltip: 'Download Ticket PDF',
                onPressed: () => _openPdf(seg),
              )
            else
              const SizedBox(
                width: 48,
                height: 48,
                child: Icon(
                  Icons.lock_outline,
                  size: 18,
                  color: Color(0xFFCBD5E1),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Internal model for a ticket segment row.
class _TicketSegment {
  final String from;
  final String to;
  final dynamic price;
  final dynamic distanceKm;
  final String? segmentId;
  final bool isConsecutive;
  final int fromOrder;
  final int toOrder;

  const _TicketSegment({
    required this.from,
    required this.to,
    this.price,
    this.distanceKm,
    this.segmentId,
    this.isConsecutive = false,
    this.fromOrder = 0,
    this.toOrder = 0,
  });
}

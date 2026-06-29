/// Activity Log Screen — Issuance Audit Trail.
///
/// Shows which storekeeper issued how much stock to which bus plate at what time.
/// Admin/Owner view for monitoring storekeeper performance.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/core/services/api_service.dart';

class StorekeeperActivityLogScreen extends StatefulWidget {
  const StorekeeperActivityLogScreen({super.key});

  @override
  State<StorekeeperActivityLogScreen> createState() =>
      _StorekeeperActivityLogScreenState();
}

class _StorekeeperActivityLogScreenState
    extends State<StorekeeperActivityLogScreen> {
  final _api = ApiService();
  static const _prefix = '/api/v1/bus-fleet/storekeeper/audit-trail';

  List<Map<String, dynamic>> _entries = [];
  Map<String, dynamic>? _meta;
  bool _loading = true;
  String? _error;
  int _page = 1;

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
      final r = await _api.get('$_prefix?page=$_page&limit=30');
      final list = (r['data'] as List<dynamic>?) ?? [];
      if (mounted) {
        setState(() {
          _entries = list.cast<Map<String, dynamic>>();
          _meta = r['meta'] as Map<String, dynamic>?;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _statusColor(String status) {
    switch (status) {
      case 'pending':
        return '🟠';
      case 'issued':
        return '🔵';
      case 'reconciled':
        return '🟢';
      default:
        return '⚪';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2838),
        title: const Text('Issuance Audit Trail',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.refresh, color: Colors.white70),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text('Error: $_error',
                      style:
                          const TextStyle(color: Colors.redAccent)))
              : _entries.isEmpty
                  ? const Center(
                      child: Text('No activity logs yet.',
                          style: TextStyle(color: Colors.white54)))
                  : isWide
                      ? _buildTable()
                      : _buildCardList(),
    );
  }

  Widget _buildTable() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Row(
            children: [
              Expanded(flex: 2, child: Text('Storekeeper', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Text('Bus / Conductor', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold))),
              Expanded(flex: 1, child: Text('Qty', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold))),
              Expanded(flex: 1, child: Text('Status', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold))),
              Expanded(flex: 1, child: Text('Date', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold))),
            ],
          ),
        ),
        const Gap(4),
        ..._entries.map(_buildRow),
      ],
    );
  }

  Widget _buildRow(Map<String, dynamic> e) {
    final status = e['status'] ?? 'pending';
    final date = e['issued_at'] ?? e['created_at'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2838),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              e['storekeeper_name'] ?? '—',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              e['bus_reg_number'] ??
                  e['conductor_name'] ??
                  '—',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${e['total_quantity'] ?? 0}',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${_statusColor(status)} ${status[0].toUpperCase()}${status.substring(1)}',
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              _fmtDate(date.toString()),
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardList() {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _entries.length,
      separatorBuilder: (_, __) => const Gap(6),
      itemBuilder: (_, i) {
        final e = _entries[i];
        return Card(
          color: const Color(0xFF1B2838),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(e['storekeeper_name'] ?? '—',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ),
                    Text('${e['total_quantity'] ?? 0} items',
                        style: const TextStyle(
                            color: Color(0xFF00B4D8), fontSize: 12)),
                  ],
                ),
                const Gap(4),
                Text(
                    'Bus: ${e['bus_reg_number'] ?? e['conductor_name'] ?? '—'}',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12)),
                const Gap(2),
                Text(_fmtDate((e['issued_at'] ?? e['created_at']).toString()),
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
        );
      },
    );
  }

  String _fmtDate(String s) {
    if (s.isEmpty) return '—';
    try {
      final dt = DateTime.parse(s);
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return s.substring(0, s.length > 10 ? 10 : s.length);
    }
  }
}

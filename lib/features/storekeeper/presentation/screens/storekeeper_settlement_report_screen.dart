/// Settlement Report Screen — Financial ledger per trip.
///
/// Shows total cash collected vs inventory variance (shortages/losses).
/// Admin/Owner view for monitoring storekeeper financial performance.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/core/services/api_service.dart';

class StorekeeperSettlementReportScreen extends StatefulWidget {
  const StorekeeperSettlementReportScreen({super.key});

  @override
  State<StorekeeperSettlementReportScreen> createState() =>
      _StorekeeperSettlementReportScreenState();
}

class _StorekeeperSettlementReportScreenState
    extends State<StorekeeperSettlementReportScreen> {
  final _api = ApiService();
  static const _prefix = '/api/v1/bus-fleet/storekeeper/settlement-report';

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

  String _fmtPaisa(dynamic v) {
    final p = v is int ? v : int.tryParse(v?.toString() ?? '0') ?? 0;
    return '\$${(p / 100).toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final totalCash = _fmtPaisa(_meta?['total_cash_collected'] ?? 0);
    final totalVariance = _fmtPaisa(_meta?['total_variance'] ?? 0);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2838),
        title: const Text('Trip Settlement Report',
            style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: Column(
        children: [
          // Summary ribbon
          if (_meta != null)
            Container(
              color: const Color(0xFF1B2838),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  _KpiBox('Total Cash Collected', totalCash,
                      const Color(0xFF16A34A)),
                  const Gap(16),
                  _KpiBox('Total Variance', totalVariance,
                      const Color(0xFFF59E0B)),
                ],
              ),
            ),
          // List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Text('Error: $_error',
                            style: const TextStyle(
                                color: Colors.redAccent)))
                    : _entries.isEmpty
                        ? const Center(
                            child: Text('No settlement records yet.',
                                style: TextStyle(
                                    color: Colors.white54)))
                        : isWide
                            ? _buildTable()
                            : _buildCardList(),
          ),
          if (_meta != null) _buildPagination(),
        ],
      ),
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
              Expanded(flex: 2, child: Text('Storekeeper / Bus', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold))),
              Expanded(flex: 1, child: Text('Issued', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold))),
              Expanded(flex: 1, child: Text('Sold', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold))),
              Expanded(flex: 1, child: Text('Returned', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold))),
              Expanded(flex: 1, child: Text('Variance', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold))),
              Expanded(flex: 1, child: Text('Status', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold))),
            ],
          ),
        ),
        const Gap(4),
        ..._entries.map(_buildRow),
      ],
    );
  }

  Widget _buildRow(Map<String, dynamic> e) {
    final variance = _fmtPaisa(e['variance_paisa']);
    final varianceP = (e['variance_paisa'] ?? 0) is int
        ? e['variance_paisa'] as int
        : int.tryParse(e['variance_paisa'].toString()) ?? 0;
    final vColor =
        varianceP == 0 ? Colors.green : varianceP > 0 ? Colors.orange : Colors.redAccent;
    final status = e['reconciliation_status'] ?? 'draft';

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e['storekeeper_name'] ?? '—',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 12)),
                Text(e['bus_reg_number'] ?? '—',
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 10)),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(_fmtPaisa(e['total_issued_value_paisa']),
                style: const TextStyle(
                    color: Colors.white70, fontSize: 12)),
          ),
          Expanded(
            flex: 1,
            child: Text(_fmtPaisa(e['total_sold_value_paisa']),
                style: const TextStyle(
                    color: Color(0xFF00B4D8), fontSize: 12)),
          ),
          Expanded(
            flex: 1,
            child: Text(_fmtPaisa(e['total_returned_value_paisa']),
                style: const TextStyle(
                    color: Colors.white70, fontSize: 12)),
          ),
          Expanded(
            flex: 1,
            child: Text(variance,
                style: TextStyle(
                    color: vColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12)),
          ),
          Expanded(
            flex: 1,
            child: Text(
                status[0].toUpperCase() + status.substring(1),
                style: const TextStyle(
                    color: Colors.white54, fontSize: 11)),
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
        final varianceP = (e['variance_paisa'] ?? 0) is int
            ? e['variance_paisa'] as int
            : int.tryParse(e['variance_paisa'].toString()) ?? 0;
        final vColor = varianceP == 0
            ? Colors.green
            : varianceP > 0 ? Colors.orange : Colors.redAccent;

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
                      child: Text(
                          e['storekeeper_name'] ?? '—',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ),
                    Text(_fmtPaisa(e['variance_paisa']),
                        style: TextStyle(
                            color: vColor,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                const Gap(4),
                Text('Bus: ${e['bus_reg_number'] ?? '—'}',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12)),
                const Gap(6),
                Row(
                  children: [
                    _valCol('Issued',
                        e['total_issued_value_paisa'], Colors.white70),
                    const Gap(12),
                    _valCol('Sold', e['total_sold_value_paisa'],
                        const Color(0xFF00B4D8)),
                    const Gap(12),
                    _valCol('Returned',
                        e['total_returned_value_paisa'], Colors.white70),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _valCol(String label, dynamic paisa, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(color: Colors.white38, fontSize: 10)),
        Text(_fmtPaisa(paisa),
            style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildPagination() {
    final current = (_meta?['current_page'] ?? 1) as int;
    final last = (_meta?['last_page'] ?? 1) as int;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left,
                color: Colors.white54),
            onPressed: current > 1
                ? () {
                    _page = current - 1;
                    _load();
                  }
                : null,
          ),
          Text('$current / $last',
              style: const TextStyle(
                  color: Colors.white54, fontSize: 12)),
          IconButton(
            icon: const Icon(Icons.chevron_right,
                color: Colors.white54),
            onPressed: current < last
                ? () {
                    _page = current + 1;
                    _load();
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

class _KpiBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _KpiBox(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            Text(label,
                style: const TextStyle(
                    color: Colors.white54, fontSize: 10),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

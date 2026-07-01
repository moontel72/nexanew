/// Reconciliation Screen — End-of-trip count: returned vs sold vs issued.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/features/storekeeper/data/repositories/storekeeper_repository.dart';
import 'package:trace_odd/features/storekeeper/domain/models/catering_issuance.dart';
import 'package:trace_odd/features/storekeeper/domain/models/catering_reconciliation.dart';

class ReconciliationScreen extends StatefulWidget {
  final String panel;
  const ReconciliationScreen({super.key, this.panel = 'bus-fleet'});

  @override
  State<ReconciliationScreen> createState() => _ReconciliationScreenState();
}

class _ReconciliationScreenState extends State<ReconciliationScreen> {
  final _repo = StorekeeperRepository();
  List<CateringReconciliation> _reconciliations = [];
  Map<String, dynamic>? _meta;
  bool _loading = true;
  String? _error;
  int _page = 1;
  String? _statusFilter;

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
      final result = await _repo.getReconciliations(
        status: _statusFilter,
        page: _page,
      );
      if (mounted) {
        setState(() {
          _reconciliations =
              result['reconciliations'] as List<CateringReconciliation>;
          _meta = result['meta'] as Map<String, dynamic>?;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _doReconciliation(CateringIssuance issuance) async {
    if (issuance.items.isEmpty) {
      _showMessage('No items in this issuance.');
      return;
    }

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => _ReconciliationFormPage(issuance: issuance),
      ),
    );
    if (result != null) {
      try {
        await _repo.reconcile(issuance.id, result);
        _load();
      } catch (e) {
        _showMessage(e.toString());
      }
    }
  }

  Future<void> _confirm(CateringReconciliation rec) async {
    try {
      await _repo.confirmReconciliation(rec.id);
      _load();
    } catch (e) {
      _showMessage(e.toString());
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: msg.contains('Error') ? Colors.red : null,
      ),
    );
  }

  Future<void> _loadActiveIssuancesForReconcile() async {
    // Fetch active issuances and let user pick one to reconcile
    try {
      final result = await _repo.getIssuances(status: 'issued', limit: 50);
      final issuances = result['issuances'] as List<CateringIssuance>;
      if (issuances.isEmpty) {
        _showMessage('No active issuances to reconcile.');
        return;
      }

      if (mounted) {
        final selected = await showDialog<CateringIssuance>(
          context: context,
          builder: (ctx) => SimpleDialog(
            backgroundColor: const Color(0xFF1B2838),
            title: const Text(
              'Select Issuance to Reconcile',
              style: TextStyle(color: Colors.white),
            ),
            children: issuances.map((i) {
              return SimpleDialogOption(
                onPressed: () => Navigator.pop(ctx, i),
                child: Text(
                  '${i.busRegNumber ?? i.conductorName ?? 'Issuance'} — ${i.items.length} items',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
          ),
        );
        if (selected != null) {
          await _doReconciliation(selected);
        }
      }
    } catch (e) {
      _showMessage(e.toString());
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'draft':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'disputed':
        return Colors.redAccent;
      default:
        return Colors.white54;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Column(
      children: [
        // Filter + Actions bar
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FiltChip('All', null, _statusFilter, (v) {
                        _statusFilter = v;
                        _page = 1;
                        _load();
                      }),
                      const Gap(6),
                      _FiltChip('Draft', 'draft', _statusFilter, (v) {
                        _statusFilter = v;
                        _page = 1;
                        _load();
                      }),
                      const Gap(6),
                      _FiltChip('Confirmed', 'confirmed', _statusFilter, (v) {
                        _statusFilter = v;
                        _page = 1;
                        _load();
                      }),
                    ],
                  ),
                ),
              ),
              const Gap(8),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Color(0xFF00B4D8)),
                tooltip: 'New Reconciliation',
                onPressed: _loadActiveIssuancesForReconcile,
              ),
            ],
          ),
        ),
        // List
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                  child: Text(
                    'Error: $_error',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                )
              : _reconciliations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.receipt_long,
                        size: 48,
                        color: Colors.white24,
                      ),
                      const Gap(8),
                      const Text(
                        'No reconciliations yet.',
                        style: TextStyle(color: Colors.white54),
                      ),
                      const Gap(12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Reconcile Issuance'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B4D8),
                        ),
                        onPressed: _loadActiveIssuancesForReconcile,
                      ),
                    ],
                  ),
                )
              : isWide
              ? _buildTable()
              : _buildCardList(),
        ),
        if (_meta != null) _buildPagination(),
      ],
    );
  }

  Widget _buildTable() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  'Status',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Issued',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Returned',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Sold',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Variance',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                width: 40,
                child: Text('', style: TextStyle(color: Colors.white54)),
              ),
            ],
          ),
        ),
        const Gap(4),
        ..._reconciliations.map(_buildTableRow),
      ],
    );
  }

  Widget _buildTableRow(CateringReconciliation r) {
    final varianceColor = r.variancePaisa == 0
        ? Colors.green
        : r.variancePaisa > 0
        ? Colors.orange
        : Colors.redAccent;
    final varianceSign = r.variancePaisa >= 0 ? '+' : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2838),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _statusColor(r.status).withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                r.status[0].toUpperCase() + r.status.substring(1),
                style: TextStyle(
                  color: _statusColor(r.status),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '\$${(r.totalIssuedValuePaisa / 100).toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '\$${(r.totalReturnedValuePaisa / 100).toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '\$${(r.totalSoldValuePaisa / 100).toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '$varianceSign\$${(r.variancePaisa / 100).toStringAsFixed(0)}',
              style: TextStyle(
                color: varianceColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (r.isDraft)
            IconButton(
              icon: const Icon(
                Icons.check_circle_outline,
                size: 16,
                color: Colors.green,
              ),
              tooltip: 'Confirm',
              onPressed: () => _confirm(r),
              constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }

  Widget _buildCardList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: _reconciliations.length,
      separatorBuilder: (_, __) => const Gap(6),
      itemBuilder: (_, idx) => _buildCard(_reconciliations[idx]),
    );
  }

  Widget _buildCard(CateringReconciliation r) {
    final varianceColor = r.variancePaisa == 0
        ? Colors.green
        : r.variancePaisa > 0
        ? Colors.orange
        : Colors.redAccent;

    return Card(
      color: const Color(0xFF1B2838),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                    color: _statusColor(r.status).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    r.status[0].toUpperCase() + r.status.substring(1),
                    style: TextStyle(
                      color: _statusColor(r.status),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                if (r.isDraft)
                  TextButton.icon(
                    icon: const Icon(Icons.check_circle_outline, size: 14),
                    label: const Text(
                      'Confirm',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onPressed: () => _confirm(r),
                  ),
              ],
            ),
            const Gap(8),
            Row(
              children: [
                _buildValueCol(
                  'Issued',
                  r.totalIssuedValuePaisa,
                  Colors.white70,
                ),
                const Gap(16),
                _buildValueCol(
                  'Returned',
                  r.totalReturnedValuePaisa,
                  Colors.white70,
                ),
                const Gap(16),
                _buildValueCol(
                  'Sold',
                  r.totalSoldValuePaisa,
                  const Color(0xFF00B4D8),
                ),
              ],
            ),
            const Gap(4),
            Text(
              'Variance: \$${(r.variancePaisa / 100).toStringAsFixed(2)}',
              style: TextStyle(
                color: varianceColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueCol(String label, int paisa, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 10),
        ),
        Text(
          '\$${(paisa / 100).toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
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
            icon: const Icon(Icons.chevron_left, color: Colors.white54),
            onPressed: current > 1
                ? () {
                    _page = current - 1;
                    _load();
                  }
                : null,
          ),
          Text(
            '$current / $last',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white54),
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

class _FiltChip extends StatelessWidget {
  final String label;
  final String? value;
  final String? selected;
  final void Function(String?) onSelect;

  const _FiltChip(this.label, this.value, this.selected, this.onSelect);

  @override
  Widget build(BuildContext context) {
    final active = selected == value;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : Colors.white70,
          fontSize: 12,
        ),
      ),
      selected: active,
      selectedColor: const Color(0xFF00B4D8).withOpacity(0.3),
      backgroundColor: const Color(0xFF1B2838),
      side: BorderSide(
        color: active ? const Color(0xFF00B4D8) : Colors.white12,
      ),
      onSelected: (_) => onSelect(value),
    );
  }
}

// ─── Reconciliation Form Page ────────────────────────────────

class _ReconciliationFormPage extends StatefulWidget {
  final CateringIssuance issuance;

  const _ReconciliationFormPage({required this.issuance});

  @override
  State<_ReconciliationFormPage> createState() =>
      _ReconciliationFormPageState();
}

class _ReconciliationFormPageState extends State<_ReconciliationFormPage> {
  final _notesCtrl = TextEditingController();
  final Map<String, _Counts> _counts = {};
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    for (final item in widget.issuance.items) {
      _counts[item.id] = _Counts(
        issued: item.quantityIssued,
        returned: 0,
        sold: 0,
      );
    }
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final payload = {
      'items': _counts.entries
          .map(
            (e) => {
              'item_id': e.key,
              'quantity_returned': e.value.returned,
              'quantity_sold': e.value.sold,
            },
          )
          .toList(),
      'notes': _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    };
    Navigator.pop(context, payload);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2838),
        title: const Text(
          'Reconcile Issuance',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Issuance info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1B2838),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bus: ${widget.issuance.busRegNumber ?? 'N/A'}  •  Conductor: ${widget.issuance.conductorName ?? 'N/A'}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const Gap(4),
                Text(
                  '${widget.issuance.items.length} items issued',
                  style: const TextStyle(color: Colors.white38),
                ),
              ],
            ),
          ),
          const Gap(16),
          // Items
          ...widget.issuance.items.map((item) {
            final counts = _counts[item.id]!;
            final outstanding = counts.issued - counts.returned - counts.sold;

            return Card(
              color: const Color(0xFF1B2838),
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.itemName ?? 'Item',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          'Issued: ${counts.issued}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const Gap(8),
                    Row(
                      children: [
                        _buildCountField('Returned', counts.returned, (v) {
                          counts.returned = v;
                          setState(() {});
                        }),
                        const Gap(12),
                        _buildCountField('Sold', counts.sold, (v) {
                          counts.sold = v;
                          setState(() {});
                        }),
                        const Gap(12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Outstanding',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              '$outstanding',
                              style: TextStyle(
                                color: outstanding > 0
                                    ? Colors.orange
                                    : Colors.green,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          const Gap(8),
          TextFormField(
            controller: _notesCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Reconciliation notes...',
              hintStyle: TextStyle(color: Colors.white38),
              filled: true,
              fillColor: Color(0xFF1B2838),
              border: OutlineInputBorder(borderSide: BorderSide.none),
            ),
            maxLines: 2,
          ),
          const Gap(20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B4D8),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Submit Reconciliation',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountField(
    String label,
    int value,
    void Function(int) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 10),
        ),
        SizedBox(
          width: 70,
          child: TextFormField(
            initialValue: value.toString(),
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              filled: true,
              fillColor: Color(0xFF0D1B2A),
              border: OutlineInputBorder(borderSide: BorderSide.none),
            ),
            onChanged: (v) {
              onChanged(int.tryParse(v) ?? 0);
            },
          ),
        ),
      ],
    );
  }
}

class _Counts {
  final int issued;
  int returned;
  int sold;
  _Counts({required this.issued, this.returned = 0, this.sold = 0});
}

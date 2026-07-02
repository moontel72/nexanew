/// Issuance Screen — Issue catering items to buses/trips.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/features/storekeeper/data/repositories/storekeeper_repository.dart';
import 'package:trace_odd/features/storekeeper/domain/models/catering_issuance.dart';
import 'package:trace_odd/features/storekeeper/domain/models/catering_item.dart';

class IssuanceScreen extends StatefulWidget {
  final String panel;
  const IssuanceScreen({super.key, this.panel = 'bus-fleet'});

  @override
  State<IssuanceScreen> createState() => _IssuanceScreenState();
}

class _IssuanceScreenState extends State<IssuanceScreen> {
  final _repo = StorekeeperRepository();
  List<CateringIssuance> _issuances = [];
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
      final result = await _repo.getIssuances(
        status: _statusFilter,
        page: _page,
      );
      if (mounted) {
        setState(() {
          _issuances = result['issuances'] as List<CateringIssuance>;
          _meta = result['meta'] as Map<String, dynamic>?;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createIssuance() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => _CreateIssuancePage(panel: widget.panel),
      ),
    );
    if (result == true) _load();
  }

  Future<void> _issueItems(CateringIssuance issuance) async {
    try {
      await _repo.issueItems(issuance.id);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'issued':
        return const Color(0xFF00B4D8);
      case 'reconciled':
        return Colors.green;
      default:
        return Colors.white54;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Column(
      children: [
        // Filter + Add bar
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip('All', null, _statusFilter, (v) {
                        _statusFilter = v;
                        _page = 1;
                        _load();
                      }),
                      const Gap(6),
                      _FilterChip('Pending', 'pending', _statusFilter, (v) {
                        _statusFilter = v;
                        _page = 1;
                        _load();
                      }),
                      const Gap(6),
                      _FilterChip('Issued', 'issued', _statusFilter, (v) {
                        _statusFilter = v;
                        _page = 1;
                        _load();
                      }),
                      const Gap(6),
                      _FilterChip('Reconciled', 'reconciled', _statusFilter, (
                        v,
                      ) {
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
                tooltip: 'New Issuance',
                onPressed: _createIssuance,
              ),
            ],
          ),
        ),
        // Issuances list
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
              : _issuances.isEmpty
              ? const Center(
                  child: Text(
                    'No issuances yet.',
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              : isWide
              ? _buildTable()
              : _buildCardList(),
        ),
        // Pagination
        if (_meta != null) _buildPagination(),
      ],
    );
  }

  Widget _buildTable() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Bus / Trip',
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
                  'Items',
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
                  'Date',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                width: 40,
                child: Text(
                  '',
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
        const Gap(4),
        ..._issuances.map(_buildTableRow),
      ],
    );
  }

  Widget _buildTableRow(CateringIssuance i) {
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
            flex: 2,
            child: Text(
              i.busRegNumber ?? i.conductorName ?? i.tripId ?? '—',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${i.items.length} items',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _statusColor(i.status).withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                i.status[0].toUpperCase() + i.status.substring(1),
                style: TextStyle(
                  color: _statusColor(i.status),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              _formatDate(i.createdAt),
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ),
          if (i.isPending)
            IconButton(
              icon: const Icon(
                Icons.local_shipping,
                size: 16,
                color: Color(0xFF00B4D8),
              ),
              tooltip: 'Issue items',
              onPressed: () => _issueItems(i),
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
      itemCount: _issuances.length,
      separatorBuilder: (_, __) => const Gap(6),
      itemBuilder: (_, idx) => _buildCard(_issuances[idx]),
    );
  }

  Widget _buildCard(CateringIssuance i) {
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
                    color: _statusColor(i.status).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    i.status[0].toUpperCase() + i.status.substring(1),
                    style: TextStyle(
                      color: _statusColor(i.status),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                if (i.isPending)
                  TextButton.icon(
                    icon: const Icon(Icons.local_shipping, size: 14),
                    label: const Text('Issue', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF00B4D8),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onPressed: () => _issueItems(i),
                  ),
              ],
            ),
            const Gap(8),
            Text(
              'Bus: ${i.busRegNumber ?? 'N/A'}  •  Conductor: ${i.conductorName ?? 'N/A'}',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
            const Gap(4),
            Text(
              '${i.items.length} items  •  ${_formatDate(i.createdAt)}',
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
            if (i.notes != null && i.notes!.isNotEmpty) ...[
              const Gap(4),
              Text(
                i.notes!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white30, fontSize: 11),
              ),
            ],
          ],
        ),
      ),
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

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String? value;
  final String? selected;
  final void Function(String?) onSelect;

  const _FilterChip(this.label, this.value, this.selected, this.onSelect);

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

// ─── Create Issuance Page ────────────────────────────────────

class _CreateIssuancePage extends StatefulWidget {
  final String panel;
  const _CreateIssuancePage({required this.panel});

  @override
  State<_CreateIssuancePage> createState() => _CreateIssuancePageState();
}

class _CreateIssuancePageState extends State<_CreateIssuancePage> {
  late final StorekeeperRepository _repo;
  final _formKey = GlobalKey<FormState>();
  final _busCtrl = TextEditingController();
  final _conductorCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  List<CateringItem> _availableItems = [];
  final List<_SelectedItem> _selectedItems = [];
  bool _loadingItems = true;
  bool _submitting = false;

  List<Map<String, dynamic>> _activeAssignments = [];
  bool _loadingAssignments = false;
  String? _selectedAssignmentId;

  @override
  void initState() {
    super.initState();
    _repo = StorekeeperRepository(panel: widget.panel);
    _loadItems();
    _loadActiveAssignments();
  }

  @override
  void dispose() {
    _busCtrl.dispose();
    _conductorCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    try {
      final result = await _repo.getItems(status: 'active', limit: 100);
      if (mounted) {
        setState(() {
          _availableItems = result['items'] as List<CateringItem>;
          _loadingItems = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingItems = false);
    }
  }

  Future<void> _loadActiveAssignments() async {
    setState(() => _loadingAssignments = true);
    try {
      final result = await _repo.getActiveAssignments();
      if (mounted) {
        setState(() {
          _activeAssignments = result;
          _loadingAssignments = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingAssignments = false);
    }
  }

  void _onAssignmentSelected(String? assignmentId) {
    if (assignmentId == null) return;
    final assignment = _activeAssignments.firstWhere(
      (a) => a['id']?.toString() == assignmentId,
      orElse: () => {},
    );
    if (assignment.isNotEmpty) {
      setState(() {
        _selectedAssignmentId = assignmentId;
        _busCtrl.text = assignment['bus_reg_number']?.toString() ?? '';
        _conductorCtrl.text = assignment['conductor_name']?.toString() ?? '';
      });
    }
  }

  void _addItem(CateringItem item) {
    if (_selectedItems.any((s) => s.item.id == item.id)) return;
    setState(() {
      _selectedItems.add(_SelectedItem(item: item, quantity: 1));
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one item.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await _repo.createIssuance({
        'bus_reg_number': _busCtrl.text.trim(),
        'conductor_name': _conductorCtrl.text.trim(),
        'notes': _notesCtrl.text.trim(),
        if (_selectedAssignmentId != null)
          'assignment_id': _selectedAssignmentId,
        'items': _selectedItems
            .map((s) => {'item_id': s.item.id, 'quantity_issued': s.quantity})
            .toList(),
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2838),
        title: const Text(
          'New Issuance',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Trip-linked dropdown
            if (_loadingAssignments)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              DropdownButtonFormField<String>(
                value: _selectedAssignmentId,
                decoration: _inputDec('Select Active Assignment / Trip'),
                isExpanded: true,
                dropdownColor: const Color(0xFF1B2838),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                validator: (v) => v == null ? 'Please select an assignment' : null,
                items: [
                  ..._activeAssignments.map((a) {
                    final plate = a['bus_reg_number']?.toString() ?? '';
                    final route = a['route_name']?.toString() ?? '';
                    return DropdownMenuItem<String>(
                      value: a['id']?.toString(),
                      child: Text(
                        '$route | $plate',
                        style: const TextStyle(fontSize: 13, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }),
                ],
                onChanged: _onAssignmentSelected,
              ),
            // Auto-populated badges when assignment selected
            if (_selectedAssignmentId != null) ...[
              const Gap(12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00B4D8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF00B4D8).withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.directions_bus, size: 16, color: Color(0xFF00B4D8)),
                        const Gap(6),
                        Text(_busCtrl.text,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const Gap(4),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 14, color: Colors.white54),
                        const Gap(6),
                        Text(_conductorCtrl.text,
                            style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const Gap(12),
            TextFormField(
              controller: _notesCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDec('Notes (optional)'),
              maxLines: 2,
            ),
            const Gap(16),
            const Text(
              'Select Items',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const Gap(8),
            if (_loadingItems)
              const Center(child: CircularProgressIndicator())
            else ...[
              // Available items
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _availableItems.map((item) {
                  final alreadyAdded = _selectedItems.any(
                    (s) => s.item.id == item.id,
                  );
                  return ActionChip(
                    label: Text(
                      '${item.name} (${item.stockOnHand})',
                      style: TextStyle(
                        color: alreadyAdded ? Colors.white38 : Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: const Color(0xFF1B2838),
                    side: const BorderSide(color: Colors.white12),
                    onPressed: alreadyAdded ? null : () => _addItem(item),
                  );
                }).toList(),
              ),
              const Gap(12),
              // Selected items
              ..._selectedItems.map(
                (s) => Card(
                  color: const Color(0xFF1B2838),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            s.item.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(
                          width: 60,
                          child: TextFormField(
                            initialValue: s.quantity.toString(),
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),
                            ),
                            onChanged: (v) {
                              s.quantity = int.tryParse(v) ?? s.quantity;
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.redAccent,
                          ),
                          onPressed: () {
                            setState(() => _selectedItems.remove(s));
                          },
                          constraints: const BoxConstraints(
                            minWidth: 30,
                            minHeight: 30,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
                      'Create Issuance',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDec(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.white38),
    filled: true,
    fillColor: const Color(0xFF1B2838),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
  );
}

class _SelectedItem {
  final CateringItem item;
  int quantity;
  _SelectedItem({required this.item, this.quantity = 1});
}

// NEXATRACE — STAFF BONUS MANAGEMENT SCREEN
// ============================================
// Bus Fleet / Bus Owner admin panel for creating and
// managing staff bonuses (drivers, conductors, office staff).
//
// Each bonus auto-inherits the logged-in user's
// bus_company_id for safe multi-tenant isolation.

import 'package:flutter/material.dart';
import 'package:trace_odd/core/services/api_service.dart';

class BonusManagementScreen extends StatefulWidget {
  final String panelPrefix;
  const BonusManagementScreen({super.key, this.panelPrefix = '/bus-fleet'});

  @override
  State<BonusManagementScreen> createState() => _BonusManagementScreenState();
}

class _BonusManagementScreenState extends State<BonusManagementScreen> {
  final _api = ApiService();
  List<Map<String, dynamic>> _bonuses = [];
  bool _loading = true;
  String? _error;

  static const _staffTypes = ['driver', 'conductor', 'office_staff'];
  static const _categories = [
    'mountain_terrain',
    'festive',
    'overtime',
    'target',
    'special_trip',
  ];

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
      final res = await _api.get('${widget.panelPrefix}/bonuses');
      final data = res?['data'];
      if (data is List) _bonuses = data.cast<Map<String, dynamic>>();
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _delete(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Bonus'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _api.delete('${widget.panelPrefix}/bonuses/$id');
      _load();
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showDialog({Map<String, dynamic>? bonus}) {
    final isEdit = bonus != null;
    final nameCtrl = TextEditingController(text: bonus?['bonus_name'] ?? '');
    String staffType = bonus?['staff_type'] ?? 'driver';
    String category = bonus?['bonus_category'] ?? 'mountain_terrain';
    String amountType = bonus?['amount_type'] ?? 'fixed';
    final valueCtrl = TextEditingController(
      text: bonus?['amount_value']?.toString() ?? '',
    );
    bool isActive = bonus?['is_active'] != false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          title: Text(isEdit ? 'Edit Bonus' : 'Create Bonus'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Bonus Name',
                    hintText: 'Karanpur Mountain Allowance',
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: staffType,
                  decoration: const InputDecoration(labelText: 'Staff Type'),
                  items: _staffTypes
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.replaceAll('_', ' ').toUpperCase()),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setDlg(() => staffType = v ?? 'driver'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(
                    labelText: 'Bonus Category',
                  ),
                  items: _categories
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.replaceAll('_', ' ').toUpperCase()),
                        ),
                      )
                      .toList(),
                  onChanged: (v) =>
                      setDlg(() => category = v ?? 'mountain_terrain'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: amountType,
                  decoration: const InputDecoration(labelText: 'Amount Type'),
                  items: const [
                    DropdownMenuItem(
                      value: 'fixed',
                      child: Text('Fixed Amount (Rs.)'),
                    ),
                    DropdownMenuItem(
                      value: 'percentage',
                      child: Text('Percentage (%)'),
                    ),
                  ],
                  onChanged: (v) => setDlg(() => amountType = v ?? 'fixed'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: valueCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: amountType == 'percentage'
                        ? 'Value (%)'
                        : 'Amount (Rs.)',
                    hintText: '500',
                  ),
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  title: const Text('Active'),
                  value: isActive,
                  onChanged: (v) => setDlg(() => isActive = v),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final body = {
                  'bonus_name': nameCtrl.text,
                  'staff_type': staffType,
                  'bonus_category': category,
                  'amount_type': amountType,
                  'amount_value': double.tryParse(valueCtrl.text) ?? 0,
                  'is_active': isActive,
                };
                try {
                  if (isEdit) {
                    await _api.put(
                      '${widget.panelPrefix}/bonuses/${bonus!['id']}',
                      body: body,
                    );
                  } else {
                    await _api.post(
                      '${widget.panelPrefix}/bonuses',
                      body: body,
                    );
                  }
                  Navigator.pop(context);
                  _load();
                } catch (e) {
                  if (mounted)
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: Text(isEdit ? 'Update' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Manage Staff Bonuses'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDialog(),
        icon: const Icon(Icons.add),
        label: const Text('New Bonus'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: _load, child: const Text('Retry')),
                ],
              ),
            )
          : _bonuses.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.emoji_events, size: 56, color: Color(0xFF94A3B8)),
                  SizedBox(height: 16),
                  Text(
                    'No bonuses yet',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Create your first staff bonus!',
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _bonuses.length,
              itemBuilder: (_, i) => _bonusCard(_bonuses[i]),
            ),
    );
  }

  Widget _bonusCard(Map<String, dynamic> b) {
    final staffType = b['staff_type'] ?? 'driver';
    final category = b['bonus_category'] ?? 'mountain_terrain';
    final amountType = b['amount_type'] ?? 'fixed';
    final isActive = b['is_active'] != false;

    Color catColor;
    IconData catIcon;
    switch (category) {
      case 'festive':
        catColor = const Color(0xFFF59E0B);
        catIcon = Icons.celebration;
        break;
      case 'mountain_terrain':
        catColor = const Color(0xFF7C3AED);
        catIcon = Icons.terrain;
        break;
      case 'overtime':
        catColor = const Color(0xFF2563EB);
        catIcon = Icons.timer;
        break;
      case 'target':
        catColor = const Color(0xFF059669);
        catIcon = Icons.track_changes;
        break;
      default:
        catColor = const Color(0xFFDB2777);
        catIcon = Icons.airport_shuttle;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                    color: catColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    staffType.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: catColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    b['bonus_name'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF16A34A).withValues(alpha: 0.1)
                        : const Color(0xFF64748B).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isActive
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(catIcon, size: 16, color: catColor),
                const SizedBox(width: 4),
                Text(
                  category.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: catColor,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  amountType == 'percentage'
                      ? '${b['amount_value']}%'
                      : 'Rs. ${b['amount_value']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  onPressed: () => _showDialog(bonus: b),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  onPressed: () => _delete(b['id']),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

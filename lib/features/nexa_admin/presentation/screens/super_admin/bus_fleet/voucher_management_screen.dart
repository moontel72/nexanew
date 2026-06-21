// NEXATRACE — VOUCHER MANAGEMENT SCREEN
// ======================================
// Bus Fleet / Bus Owner admin panel for creating and
// managing vouchers, promo codes, and loyalty multipliers.
//
// Each voucher auto-inherits the logged-in user's
// bus_company_id for safe multi-tenant isolation.

import 'package:flutter/material.dart';
import 'package:trace_odd/core/services/api_service.dart';

class VoucherManagementScreen extends StatefulWidget {
  final String panelPrefix;
  const VoucherManagementScreen({super.key, this.panelPrefix = '/bus-fleet'});

  @override
  State<VoucherManagementScreen> createState() =>
      _VoucherManagementScreenState();
}

class _VoucherManagementScreenState extends State<VoucherManagementScreen> {
  final _api = ApiService();
  List<Map<String, dynamic>> _vouchers = [];
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
      final res = await _api.get('${widget.panelPrefix}/vouchers');
      final data = res?['data'];
      if (data is List) _vouchers = data.cast<Map<String, dynamic>>();
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _delete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Voucher'),
        content: const Text('Are you sure? This cannot be undone.'),
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
    if (confirm != true) return;
    try {
      await _api.delete('${widget.panelPrefix}/vouchers/$id');
      _load();
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showCreateDialog({Map<String, dynamic>? voucher}) {
    final isEdit = voucher != null;
    final codeCtrl = TextEditingController(text: voucher?['code'] ?? '');
    final titleCtrl = TextEditingController(text: voucher?['title'] ?? '');
    String type = voucher?['type'] ?? 'percentage';
    final valueCtrl =
        TextEditingController(text: voucher?['value']?.toString() ?? '');
    final minOrderCtrl =
        TextEditingController(text: voucher?['min_order']?.toString() ?? '');
    final maxDiscCtrl =
        TextEditingController(text: voucher?['max_discount']?.toString() ?? '');
    final usageCtrl =
        TextEditingController(text: voucher?['usage_limit']?.toString() ?? '');
    final startsCtrl =
        TextEditingController(text: voucher?['starts_at']?.toString() ?? '');
    final expiresCtrl =
        TextEditingController(text: voucher?['expires_at']?.toString() ?? '');
    bool isActive = voucher?['is_active'] != false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          title: Text(isEdit ? 'Edit Voucher' : 'Create Voucher'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Voucher Code',
                    hintText: 'RADHNAL50',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Eid Special 15% Off',
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(
                        value: 'percentage', child: Text('Percentage')),
                    DropdownMenuItem(
                        value: 'fixed', child: Text('Fixed Amount')),
                    DropdownMenuItem(
                        value: 'multiplier', child: Text('Point Multiplier')),
                  ],
                  onChanged: (v) => setDlg(() => type = v ?? 'percentage'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: valueCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: type == 'percentage'
                        ? 'Value (%)'
                        : type == 'multiplier'
                            ? 'Multiplier (e.g. 2)'
                            : 'Amount (Rs.)',
                    hintText: '15',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: minOrderCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Min Order (Rs.)',
                    hintText: '500',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: maxDiscCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Max Discount (Rs.)',
                    hintText: '200',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: usageCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Usage Limit',
                    hintText: '100',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: startsCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Starts At',
                    hintText: '2026-01-01',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: expiresCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Expires At',
                    hintText: '2026-12-31',
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
                final body = <String, dynamic>{
                  'code': codeCtrl.text,
                  'title': titleCtrl.text,
                  'type': type,
                  'value': double.tryParse(valueCtrl.text) ?? 0,
                  'min_order': double.tryParse(minOrderCtrl.text) ?? 0,
                  'max_discount': double.tryParse(maxDiscCtrl.text),
                  'usage_limit': int.tryParse(usageCtrl.text),
                  'starts_at': startsCtrl.text.isEmpty ? null : startsCtrl.text,
                  'expires_at':
                      expiresCtrl.text.isEmpty ? null : expiresCtrl.text,
                  'is_active': isActive,
                };
                try {
                  if (isEdit) {
                    await _api.put(
                      '${widget.panelPrefix}/vouchers/${voucher!['id']}',
                      body: body,
                    );
                  } else {
                    await _api.post(
                      '${widget.panelPrefix}/vouchers',
                      body: body,
                    );
                  }
                  Navigator.pop(context);
                  _load();
                } catch (e) {
                  if (mounted)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
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
        title: const Text('Manage Vouchers / Promos'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(),
        icon: const Icon(Icons.add),
        label: const Text('New Voucher'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text(_error!,
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                      FilledButton(
                          onPressed: _load, child: const Text('Retry')),
                    ],
                  ),
                )
              : _vouchers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.card_giftcard,
                              size: 56, color: Color(0xFF94A3B8)),
                          const SizedBox(height: 16),
                          const Text('No vouchers yet',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          const Text(
                            'Create your first promo code!',
                            style: TextStyle(color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _vouchers.length,
                      itemBuilder: (_, i) => _voucherCard(_vouchers[i]),
                    ),
    );
  }

  Widget _voucherCard(Map<String, dynamic> v) {
    final type = v['type'] ?? 'percentage';
    final isActive = v['is_active'] != false;
    final typeIcon = type == 'percentage'
        ? Icons.percent
        : type == 'multiplier'
            ? Icons.star
            : Icons.money;
    final typeColor = type == 'percentage'
        ? const Color(0xFF7C3AED)
        : type == 'multiplier'
            ? const Color(0xFFF59E0B)
            : const Color(0xFF059669);

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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    v['code'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    v['title'] ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                      color:
                          isActive ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(typeIcon, size: 16, color: typeColor),
                const SizedBox(width: 4),
                Text(
                  type == 'percentage'
                      ? '${v['value']}% off'
                      : type == 'multiplier'
                          ? '${v['value']}x points'
                          : 'Rs. ${v['value']} off',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: typeColor),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  onPressed: () => _showCreateDialog(voucher: v),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  onPressed: () => _delete(v['id']),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

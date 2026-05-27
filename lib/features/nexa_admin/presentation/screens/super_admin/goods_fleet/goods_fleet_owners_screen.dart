// Goods Fleet Owners — List + Add + Edit + Status + Delete Truck Owners

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nexatrace_system/core/services/api_service.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';

class GoodsFleetOwnersScreen extends StatefulWidget {
  const GoodsFleetOwnersScreen({super.key});

  @override
  State<GoodsFleetOwnersScreen> createState() => _GoodsFleetOwnersScreenState();
}

class _GoodsFleetOwnersScreenState extends State<GoodsFleetOwnersScreen> {
  List<Map<String, dynamic>> _owners = [];
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
      final res = await ApiService().get('/goods-fleet/owners');
      final data = res['data'] as Map<String, dynamic>;
      setState(() {
        _owners = List<Map<String, dynamic>>.from(data['data'] ?? []);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // ═══ ADD / EDIT DIALOG ═══
  Future<void> _showFormDialog({Map<String, dynamic>? existing}) async {
    final isEdit = existing != null;
    final nameCtrl = TextEditingController(text: existing?['name'] ?? '');
    final emailCtrl = TextEditingController(text: existing?['email'] ?? '');
    final phoneCtrl = TextEditingController(text: existing?['phone'] ?? '');
    final passCtrl = TextEditingController();
    final cnicCtrl = TextEditingController(text: existing?['cnic'] ?? '');
    final addrCtrl = TextEditingController(text: existing?['address'] ?? '');
    bool obscure = true;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (stCtx, setSt) => AlertDialog(
          title: Text(isEdit ? 'Edit Truck Owner' : 'Add Truck Owner'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(nameCtrl, 'Full Name *'),
                SizedBox(height: 10.h),
                _field(emailCtrl, 'Email *', email: true),
                SizedBox(height: 10.h),
                _field(phoneCtrl, 'Phone *', phone: true),
                SizedBox(height: 10.h),
                if (!isEdit)
                  TextField(
                    controller: passCtrl,
                    obscureText: obscure,
                    decoration: InputDecoration(
                      labelText: 'Password *',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscure ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => setSt(() => obscure = !obscure),
                      ),
                    ),
                  ),
                if (!isEdit) SizedBox(height: 10.h),
                _field(cnicCtrl, 'CNIC'),
                SizedBox(height: 10.h),
                _field(addrCtrl, 'Address', maxLines: 2),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(isEdit ? 'Update' : 'Save'),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;

    try {
      final payload = <String, dynamic>{
        'name': nameCtrl.text.trim(),
        'email': emailCtrl.text.trim(),
        'phone': phoneCtrl.text.trim(),
        if (passCtrl.text.isNotEmpty) 'password': passCtrl.text,
        if (cnicCtrl.text.isNotEmpty) 'cnic': cnicCtrl.text.trim(),
        if (addrCtrl.text.isNotEmpty) 'address': addrCtrl.text.trim(),
      };

      if (isEdit) {
        await ApiService().put(
          '/goods-fleet/owners/${existing['id']}',
          data: payload,
        );
      } else {
        await ApiService().post('/goods-fleet/owners', data: payload);
      }
      _load();
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEdit ? 'Owner updated' : 'Owner added'),
            backgroundColor: AppColors.success,
          ),
        );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
    }
  }

  // ═══ STATUS CHANGE ═══
  Future<void> _setStatus(String id, String status) async {
    try {
      await ApiService().put(
        '/goods-fleet/owners/$id',
        data: {'status': status},
      );
      _load();
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status set to $status'),
            backgroundColor: AppColors.success,
          ),
        );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
    }
  }

  // ═══ DELETE ═══
  Future<void> _confirmDelete(String id, String name) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Truck Owner?'),
        content: Text(
          'Permanently delete "$name" and all associated data? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ApiService().delete('/goods-fleet/owners/$id');
      _load();
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Owner deleted'),
            backgroundColor: AppColors.success,
          ),
        );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
    }
  }

  // ═══ FIELD HELPER ═══
  Widget _field(
    TextEditingController ctrl,
    String label, {
    bool obscure = false,
    bool email = false,
    bool phone = false,
    bool number = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      maxLines: maxLines,
      keyboardType: email
          ? TextInputType.emailAddress
          : phone || number
          ? TextInputType.phone
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  // ═══ STATUS COLOR ═══
  Color _statusColor(String s) {
    switch (s) {
      case 'active':
        return AppColors.success;
      case 'inactive':
        return AppColors.warning;
      case 'suspended':
        return AppColors.error;
      default:
        return AppColors.gray500;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Truck Owners'),
      backgroundColor: AppColors.success,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _showFormDialog(),
        ),
      ],
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_error!),
                SizedBox(height: 12),
                ElevatedButton(onPressed: _load, child: const Text('Retry')),
              ],
            ),
          )
        : _owners.isEmpty
        ? const Center(child: Text('No owners registered'))
        : ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: _owners.length,
            separatorBuilder: (_, __) => SizedBox(height: 8.h),
            itemBuilder: (_, i) => _ownerCard(_owners[i]),
          ),
  );

  Widget _ownerCard(Map<String, dynamic> o) {
    final id = o['id']?.toString() ?? '';
    final name = o['name']?.toString() ?? '—';
    final status = o['status']?.toString() ?? 'active';
    final color = _statusColor(status);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.1),
                  child: Icon(Icons.person, color: color),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        o['email'] ?? '',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.gray500,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(children: [_chip(Icons.phone, o['phone'] ?? '—')]),
                    ],
                  ),
                ),
                _badge(status, color),
              ],
            ),
            SizedBox(height: 10.h),
            // ── Lifecycle toolbar ──
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: [
                _actionChip(
                  'Edit',
                  Icons.edit,
                  AppColors.primary,
                  () => _showFormDialog(existing: o),
                ),
                if (status != 'active')
                  _actionChip(
                    'Active',
                    Icons.check_circle,
                    AppColors.success,
                    () => _setStatus(id, 'active'),
                  ),
                if (status != 'inactive')
                  _actionChip(
                    'Inactive',
                    Icons.pause_circle,
                    AppColors.warning,
                    () => _setStatus(id, 'inactive'),
                  ),
                if (status != 'suspended')
                  _actionChip(
                    'Suspend',
                    Icons.block,
                    AppColors.error,
                    () => _setStatus(id, 'suspended'),
                  ),
                _actionChip(
                  'Delete',
                  Icons.delete,
                  AppColors.error,
                  () => _confirmDelete(id, name),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionChip(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.w, color: color),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData ic, String t) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(ic, size: 14, color: AppColors.gray400),
      SizedBox(width: 4),
      Text(
        t,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColors.gray500),
      ),
    ],
  );

  Widget _badge(String s, Color c) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
    decoration: BoxDecoration(
      color: c.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: c.withValues(alpha: 0.3)),
    ),
    child: Text(
      s.toUpperCase(),
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c),
    ),
  );
}

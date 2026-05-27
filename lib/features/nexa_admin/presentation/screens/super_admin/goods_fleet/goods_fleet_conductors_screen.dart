// Goods Fleet Conductors — List + Add + Edit + Status + Delete Truck Conductors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nexatrace_system/core/services/api_service.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';

class GoodsFleetConductorsScreen extends StatefulWidget {
  const GoodsFleetConductorsScreen({super.key});

  @override
  State<GoodsFleetConductorsScreen> createState() =>
      _GoodsFleetConductorsScreenState();
}

class _GoodsFleetConductorsScreenState
    extends State<GoodsFleetConductorsScreen> {
  List<Map<String, dynamic>> _items = [];
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
      final res = await ApiService().get('/goods-fleet/conductors');
      final data = res['data'] as Map<String, dynamic>;
      setState(() {
        _items = List<Map<String, dynamic>>.from(data['data'] ?? []);
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
  Future<void> _showForm({Map<String, dynamic>? existing}) async {
    final isEdit = existing != null;
    final name = TextEditingController(text: existing?['name'] ?? '');
    final phone = TextEditingController(text: existing?['phone'] ?? '');
    final pass = TextEditingController();
    final email = TextEditingController(text: existing?['email'] ?? '');
    final cnic = TextEditingController(text: existing?['cnic'] ?? '');
    final addr = TextEditingController(text: existing?['address'] ?? '');
    final salary = TextEditingController(
      text: existing?['salary']?.toString() ?? '',
    );
    bool obscure = true;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) {
          return AlertDialog(
            title: Text(isEdit ? 'Edit Truck Conductor' : 'Add Truck Conductor'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _f(name, 'Full Name *'),
                  SizedBox(height: 10.h),
                  _f(phone, 'Phone *', phone: true),
                  SizedBox(height: 10.h),
                  if (!isEdit)
                    TextField(
                      controller: pass,
                      obscureText: obscure,
                      decoration: InputDecoration(
                        labelText: 'Password *',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setSt(() => obscure = !obscure),
                        ),
                      ),
                    ),
                  if (!isEdit) SizedBox(height: 10.h),
                  _f(email, 'Email', email: true),
                  SizedBox(height: 10.h),
                  _f(cnic, 'CNIC'),
                  SizedBox(height: 10.h),
                  _f(addr, 'Address', maxLines: 2),
                  SizedBox(height: 10.h),
                  _f(salary, 'Salary *', number: true),
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
          );
        },
      ),
    );
    if (ok != true) return;

    try {
      final payload = <String, dynamic>{
        'name': name.text.trim(),
        'phone': phone.text.trim(),
        if (pass.text.isNotEmpty) 'password': pass.text,
        if (email.text.isNotEmpty) 'email': email.text.trim(),
        if (cnic.text.isNotEmpty) 'cnic': cnic.text.trim(),
        if (addr.text.isNotEmpty) 'address': addr.text.trim(),
        'salary': double.tryParse(salary.text) ?? 0,
      };
      if (isEdit) {
        await ApiService().put(
          '/goods-fleet/conductors/${existing!['id']}',
          data: payload,
        );
      } else {
        await ApiService().post('/goods-fleet/conductors', data: payload);
      }
      _load();
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEdit ? 'Conductor updated' : 'Conductor added'),
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
        '/goods-fleet/conductors/$id',
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
        title: const Text('Delete Truck Conductor?'),
        content: Text('Permanently delete "$name"? This cannot be undone.'),
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
      await ApiService().delete('/goods-fleet/conductors/$id');
      _load();
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conductor deleted'),
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

  Widget _f(
    TextEditingController c,
    String l, {
    bool obscure = false,
    bool email = false,
    bool phone = false,
    bool number = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: c,
      obscureText: obscure,
      maxLines: maxLines,
      keyboardType: email
          ? TextInputType.emailAddress
          : phone || number
          ? TextInputType.phone
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: l,
        border: const OutlineInputBorder(),
      ),
    );
  }

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
      title: const Text('Truck Conductors'),
      backgroundColor: AppColors.warning,
      foregroundColor: Colors.white,
      actions: [
        IconButton(icon: const Icon(Icons.add), onPressed: () => _showForm()),
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
        : _items.isEmpty
        ? const Center(child: Text('No conductors registered'))
        : ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: _items.length,
            separatorBuilder: (_, __) => SizedBox(height: 8.h),
            itemBuilder: (_, i) => _card(_items[i]),
          ),
  );

  Widget _card(Map<String, dynamic> c) {
    final id = c['id']?.toString() ?? '';
    final name = c['name']?.toString() ?? '—';
    final status = c['status']?.toString() ?? 'active';
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
                  child: Icon(Icons.group, color: color),
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
                      _ch(Icons.phone, c['phone'] ?? '—'),
                      if (c['salary'] != null) ...[
                        SizedBox(height: 2.h),
                        Text(
                          'Salary: Rs. ${c['salary']}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.gray500),
                        ),
                      ],
                    ],
                  ),
                ),
                _bd(status, color),
              ],
            ),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: [
                _actionChip(
                  'Edit',
                  Icons.edit,
                  AppColors.primary,
                  () => _showForm(existing: c),
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

  Widget _ch(IconData i, String t) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(i, size: 14, color: AppColors.gray400),
      SizedBox(width: 4),
      Text(
        t,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColors.gray500),
      ),
    ],
  );

  Widget _bd(String s, Color c) => Container(
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

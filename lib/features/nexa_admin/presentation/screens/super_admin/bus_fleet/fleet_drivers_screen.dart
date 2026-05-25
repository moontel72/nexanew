// Fleet Drivers — List + Add Bus Drivers

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nexatrace_system/core/services/api_service.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';

class FleetDriversScreen extends StatefulWidget {
  const FleetDriversScreen({super.key});

  @override
  State<FleetDriversScreen> createState() => _FleetDriversScreenState();
}

class _FleetDriversScreenState extends State<FleetDriversScreen> {
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
      final res = await ApiService().get('/bus-fleet/drivers/manage');
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

  Future<void> _showAdd() async {
    final name = TextEditingController(), phone = TextEditingController();
    final license = TextEditingController(), pass = TextEditingController();
    final cnic = TextEditingController(), addr = TextEditingController();
    final plate = TextEditingController(), salary = TextEditingController();
    final email = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Bus Driver'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _f(name, 'Full Name *'),
              SizedBox(height: 10.h),
              _f(phone, 'Phone *', phone: true),
              SizedBox(height: 10.h),
              _f(license, 'License Number *'),
              SizedBox(height: 10.h),
              _f(pass, 'Password *', obscure: true),
              SizedBox(height: 10.h),
              _f(email, 'Email', email: true),
              SizedBox(height: 10.h),
              _f(cnic, 'CNIC'),
              SizedBox(height: 10.h),
              _f(addr, 'Address', maxLines: 2),
              SizedBox(height: 10.h),
              _f(plate, 'Vehicle Plate'),
              SizedBox(height: 10.h),
              _f(salary, 'Salary', number: true),
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
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await ApiService().post(
        '/bus-fleet/drivers/manage',
        data: {
          'name': name.text.trim(),
          'phone': phone.text.trim(),
          'license_number': license.text.trim(),
          'password': pass.text,
          if (email.text.isNotEmpty) 'email': email.text.trim(),
          if (cnic.text.isNotEmpty) 'cnic': cnic.text.trim(),
          if (addr.text.isNotEmpty) 'address': addr.text.trim(),
          if (plate.text.isNotEmpty) 'vehicle_plate_number': plate.text.trim(),
          if (salary.text.isNotEmpty) 'salary': double.tryParse(salary.text),
        },
      );
      _load();
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Driver added'),
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
  }) => TextField(
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

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Bus Drivers'),
      backgroundColor: AppColors.success,
      foregroundColor: Colors.white,
      actions: [IconButton(icon: const Icon(Icons.add), onPressed: _showAdd)],
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
        ? const Center(child: Text('No drivers registered'))
        : ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: _items.length,
            separatorBuilder: (_, __) => SizedBox(height: 8.h),
            itemBuilder: (_, i) => _card(_items[i]),
          ),
  );

  Widget _card(Map<String, dynamic> d) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
    child: Padding(
      padding: EdgeInsets.all(14.w),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.success.withValues(alpha: 0.1),
            child: Icon(Icons.badge, color: AppColors.success),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d['name'] ?? '—',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    _ch(Icons.phone, d['phone'] ?? '—'),
                    SizedBox(width: 12.w),
                    _ch(Icons.credit_card, d['license_number'] ?? '—'),
                  ],
                ),
              ],
            ),
          ),
          _bd(d['status'] ?? 'active'),
        ],
      ),
    ),
  );
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
  Widget _bd(String s) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
    decoration: BoxDecoration(
      color: AppColors.success.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Text(
      s.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.success,
      ),
    ),
  );
}

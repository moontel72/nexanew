// Fleet Owners — List + Add Bus Owners

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nexatrace_system/core/services/api_service.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';

class FleetOwnersScreen extends StatefulWidget {
  const FleetOwnersScreen({super.key});

  @override
  State<FleetOwnersScreen> createState() => _FleetOwnersScreenState();
}

class _FleetOwnersScreenState extends State<FleetOwnersScreen> {
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
      final res = await ApiService().get('/bus-fleet/owners');
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

  Future<void> _showAddDialog() async {
    final nameCtrl = TextEditingController(),
        emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController(),
        passCtrl = TextEditingController();
    final cnicCtrl = TextEditingController(),
        addrCtrl = TextEditingController();
    final licenseCtrl = TextEditingController(),
        plateCtrl = TextEditingController();
    final salaryCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Bus Owner'),
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
              _field(passCtrl, 'Password *', obscure: true),
              SizedBox(height: 10.h),
              _field(cnicCtrl, 'CNIC'),
              SizedBox(height: 10.h),
              _field(addrCtrl, 'Address', maxLines: 2),
              SizedBox(height: 10.h),
              _field(licenseCtrl, 'License Number'),
              SizedBox(height: 10.h),
              _field(plateCtrl, 'Vehicle Plate'),
              SizedBox(height: 10.h),
              _field(salaryCtrl, 'Salary', number: true),
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
        '/bus-fleet/owners',
        data: {
          'name': nameCtrl.text.trim(),
          'email': emailCtrl.text.trim(),
          'phone': phoneCtrl.text.trim(),
          'password': passCtrl.text,
          if (cnicCtrl.text.isNotEmpty) 'cnic': cnicCtrl.text.trim(),
          if (addrCtrl.text.isNotEmpty) 'address': addrCtrl.text.trim(),
          if (licenseCtrl.text.isNotEmpty)
            'license_number': licenseCtrl.text.trim(),
          if (plateCtrl.text.isNotEmpty)
            'vehicle_plate_number': plateCtrl.text.trim(),
          if (salaryCtrl.text.isNotEmpty)
            'salary': double.tryParse(salaryCtrl.text),
        },
      );
      _load();
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Owner added'),
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

  Widget _field(
    TextEditingController ctrl,
    String label, {
    bool obscure = false,
    bool email = false,
    bool phone = false,
    bool number = false,
    int maxLines = 1,
  }) => TextField(
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

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Bus Owners'),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      actions: [
        IconButton(icon: const Icon(Icons.add), onPressed: _showAddDialog),
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

  Widget _ownerCard(Map<String, dynamic> o) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
    child: Padding(
      padding: EdgeInsets.all(14.w),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Icon(Icons.person, color: AppColors.primary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  o['name'] ?? '—',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  o['email'] ?? '',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.gray500),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    _chip(Icons.phone, o['phone'] ?? '—'),
                    SizedBox(width: 12.w),
                    if ((o['vehicle_plate_number'] ?? '').toString().isNotEmpty)
                      _chip(Icons.directions_bus, o['vehicle_plate_number']),
                  ],
                ),
              ],
            ),
          ),
          _badge(o['status'] ?? 'active'),
        ],
      ),
    ),
  );

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
  Widget _badge(String s) => Container(
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

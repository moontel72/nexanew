// Bus Fleet Dashboard — Company Admin Panel (Module 13)
// Management hub: Owners, Drivers, Conductors, Fleet Overview

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/features/nexa_admin/data/models/company/bus_company_model.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/auth/admin_auth_bloc.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/auth/admin_auth_event.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/auth/admin_auth_state.dart';
import 'package:trace_odd/features/nexa_admin/presentation/screens/super_admin/bus_fleet/fleet_owners_screen.dart';
import 'package:trace_odd/features/nexa_admin/presentation/screens/super_admin/bus_fleet/fleet_drivers_screen.dart';
import 'package:trace_odd/features/nexa_admin/presentation/screens/super_admin/bus_fleet/fleet_conductors_screen.dart';
import 'package:trace_odd/shared/models/company/company_model.dart';
import 'package:trace_odd/shared/theme/colors.dart';

class BusFleetDashboardScreen extends StatefulWidget {
  final String? companyId;
  const BusFleetDashboardScreen({super.key, this.companyId});

  @override
  State<BusFleetDashboardScreen> createState() =>
      _BusFleetDashboardScreenState();
}

class _BusFleetDashboardScreenState extends State<BusFleetDashboardScreen> {
  Company? _company;
  Map<String, dynamic>? _profile;
  String? _error;
  bool _isLoading = true;

  int _ownerCount = 0;
  int _driverCount = 0;
  int _conductorCount = 0;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final api = ApiService();
      final res = await api.get('/bus-fleet/profile');
      if (!mounted) return;
      final data = res['data'] as Map<String, dynamic>?;
      if (data == null) throw Exception('No data');
      _profile = data;

      final cJson = data['company'] as Map<String, dynamic>?;
      Company? comp;
      if (cJson != null) comp = Company.fromJson(cJson);

      // Fetch counts
      int owners = 0, drivers = 0, conductors = 0;
      try {
        final oRes = await api.get(
          '/bus-fleet/owners',
          queryParams: {'per_page': '1'},
        );
        owners = (oRes['data'] as Map?)?['total'] as int? ?? 0;
      } catch (_) {}
      try {
        final dRes = await api.get(
          '/bus-fleet/drivers/manage',
          queryParams: {'per_page': '1'},
        );
        drivers = (dRes['data'] as Map?)?['total'] as int? ?? 0;
      } catch (_) {}
      try {
        final cRes = await api.get(
          '/bus-fleet/conductors',
          queryParams: {'per_page': '1'},
        );
        conductors = (cRes['data'] as Map?)?['total'] as int? ?? 0;
      } catch (_) {}

      if (mounted) {
        setState(() {
          _company = comp;
          _ownerCount = owners;
          _driverCount = drivers;
          _conductorCount = conductors;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
    }
  }

  void _logout() {
    context.read<AdminAuthBloc>().add(AdminLogoutRequested());
    context.go('/bus-fleet/login');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return _scaffold(const Center(child: CircularProgressIndicator()));
    if (_error != null) return _scaffold(_errorView());

    return _scaffold(
      SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_company != null) _companyHeader(),
            SizedBox(height: 20.h),
            _sectionTitle('Fleet Management'),
            SizedBox(height: 12.h),
            _managementGrid(),
            SizedBox(height: 24.h),
            _sectionTitle('Quick Stats'),
            SizedBox(height: 12.h),
            _statsRow(),
            SizedBox(height: 24.h),
            _quickLinks(),
          ],
        ),
      ),
    );
  }

  Widget _scaffold(Widget body) => Scaffold(
    appBar: AppBar(
      title: Text(_company?.name ?? 'Bus Fleet Dashboard'),
      backgroundColor: AppColors.info,
      foregroundColor: Colors.white,
      actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAll),
        IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
      ],
    ),
    body: body,
  );

  // ── Company header ─────────────────────────────────────
  Widget _companyHeader() {
    final c = _company!;
    return Card(
      color: AppColors.info.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                color: AppColors.info,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(
                Icons.directions_bus,
                size: 26.w,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${c.city}, ${c.country}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.gray500),
                  ),
                ],
              ),
            ),
            _badge(
              c.status.name,
              c.status == CompanyStatus.active
                  ? AppColors.success
                  : AppColors.warning,
            ),
          ],
        ),
      ),
    );
  }

  // ── Management grid ────────────────────────────────────
  Widget _managementGrid() => GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: 2,
    crossAxisSpacing: 12.w,
    mainAxisSpacing: 12.h,
    childAspectRatio: 1.4,
    children: [
      _mgmtCard(
        'Bus Owners',
        '$_ownerCount',
        Icons.person,
        AppColors.primary,
        () {
          context.push('/bus-fleet/dashboard/owners');
        },
      ),
      _mgmtCard(
        'Bus Drivers',
        '$_driverCount',
        Icons.badge,
        AppColors.success,
        () {
          context.push('/bus-fleet/dashboard/drivers');
        },
      ),
      _mgmtCard(
        'Conductors',
        '$_conductorCount',
        Icons.group,
        AppColors.warning,
        () {
          context.push('/bus-fleet/dashboard/conductors');
        },
      ),
      _mgmtCard('Fleet Routes', '—', Icons.alt_route, AppColors.info, () {}),
    ],
  );

  Widget _mgmtCard(
    String title,
    String count,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 28.w, color: color),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14.w,
                  color: AppColors.gray400,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.gray600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Stats row ──────────────────────────────────────────
  Widget _statsRow() => Row(
    children: [
      Expanded(
        child: _statBox(
          'Fleet Size',
          '${_profile?['fleet_size'] ?? 0}',
          Icons.directions_bus,
          AppColors.info,
        ),
      ),
      SizedBox(width: 12.w),
      Expanded(
        child: _statBox(
          'Routes',
          '${_profile?['active_routes'] ?? 0}',
          Icons.alt_route,
          AppColors.success,
        ),
      ),
      SizedBox(width: 12.w),
      Expanded(
        child: _statBox(
          'Staff',
          '${_ownerCount + _driverCount + _conductorCount}',
          Icons.people,
          AppColors.warning,
        ),
      ),
    ],
  );

  Widget _statBox(String label, String value, IconData icon, Color color) =>
      Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withValues(alpha: 0.12)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22.w, color: color),
            SizedBox(height: 6.h),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.gray500),
            ),
          ],
        ),
      );

  // ── Quick links ────────────────────────────────────────
  Widget _quickLinks() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionTitle('Quick Actions'),
      SizedBox(height: 8.h),
      Wrap(
        spacing: 10.w,
        runSpacing: 10.h,
        children: [
          _qLink(
            'Add Owner',
            Icons.person_add,
            AppColors.primary,
            () => context.push('/bus-fleet/dashboard/owners/add'),
          ),
          _qLink(
            'Add Driver',
            Icons.badge_outlined,
            AppColors.success,
            () => context.push('/bus-fleet/dashboard/drivers/add'),
          ),
          _qLink(
            'Add Conductor',
            Icons.group_add,
            AppColors.warning,
            () => context.push('/bus-fleet/dashboard/conductors/add'),
          ),
        ],
      ),
    ],
  );

  Widget _qLink(String label, IconData icon, Color color, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18.w, color: color),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp,
                ),
              ),
            ],
          ),
        ),
      );

  // ── Helpers ────────────────────────────────────────────
  Widget _sectionTitle(String t) => Text(
    t,
    style: Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
  );
  Widget _badge(String t, Color c) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
    decoration: BoxDecoration(
      color: c.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20.r),
      border: Border.all(color: c.withValues(alpha: 0.3)),
    ),
    child: Text(
      t.toUpperCase(),
      style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: c),
    ),
  );
  Widget _errorView() => Center(
    child: Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.error),
          SizedBox(height: 16.h),
          Text(_error!, textAlign: TextAlign.center),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: _loadAll, child: const Text('Retry')),
              SizedBox(width: 12.w),
              OutlinedButton(onPressed: _logout, child: const Text('Logout')),
            ],
          ),
        ],
      ),
    ),
  );
}

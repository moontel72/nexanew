// Bus Fleet Dashboard — Company Admin Panel (Module 13)
// Management hub: Owners, Drivers, Conductors, Fleet Overview
// 3D Pencil Sidebar Layout (unified with Sub-Admin theme)

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'package:trace_odd/features/bus_operations/presentation/widgets/missile_3d_button.dart';

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
  String _currentPage = 'dashboard';
  bool _sidebarOpen = true;

  int _ownerCount = 0;
  int _driverCount = 0;
  int _conductorCount = 0;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null || token.isEmpty) {
      if (mounted) context.go('/bus-fleet/login');
      return;
    }
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
      if (cJson != null) _company = Company.fromJson(cJson);
      int owners = 0, drivers = 0, conductors = 0;
      try {
        final o = await api.get(
          '/bus-fleet/owners',
          queryParams: {'per_page': '1'},
        );
        owners = (o['data'] as Map?)?['total'] as int? ?? 0;
      } catch (_) {}
      try {
        final d = await api.get(
          '/bus-fleet/drivers/manage',
          queryParams: {'per_page': '1'},
        );
        drivers = (d['data'] as Map?)?['total'] as int? ?? 0;
      } catch (_) {}
      try {
        final c = await api.get(
          '/bus-fleet/conductors',
          queryParams: {'per_page': '1'},
        );
        conductors = (c['data'] as Map?)?['total'] as int? ?? 0;
      } catch (_) {}
      if (mounted)
        setState(() {
          _ownerCount = owners;
          _driverCount = drivers;
          _conductorCount = conductors;
          _isLoading = false;
        });
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
    final isWide = MediaQuery.of(context).size.width > 900;
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null)
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(_error!),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _loadAll, child: const Text('Retry')),
            ],
          ),
        ),
      );
    return Scaffold(
      backgroundColor: const Color(0xFFE6F7F4),
      body: Row(
        children: [
          if (_sidebarOpen || isWide) _sidebar(isWide),
          Expanded(child: _mainContent()),
        ],
      ),
    );
  }

  Widget _sidebar(bool isWide) => Container(
    width: 240,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1A3A5C), Color(0xFF0F2B3F)],
      ),
      boxShadow: [
        BoxShadow(
          color: Color(0x30144055),
          blurRadius: 16,
          offset: Offset(4, 0),
        ),
      ],
    ),
    child: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C49F),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.directions_bus,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _company?.name ?? 'Bus Fleet',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!isWide)
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white70,
                      size: 18,
                    ),
                    onPressed: () => setState(() => _sidebarOpen = false),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 30,
                      minHeight: 30,
                    ),
                  ),
              ],
            ),
          ),
          const Divider(
            color: Color(0x20FFFFFF),
            height: 1,
            indent: 12,
            endIndent: 12,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                _sl('MAIN'),
                Missile3DButton(
                  label: 'Dashboard',
                  icon: Icons.dashboard_rounded,
                  color: const Color(0xFF7C3AED),
                  onTap: () => setState(() => _currentPage = 'dashboard'),
                ),
                const SizedBox(height: 8),
                _sl('FLEET'),
                Missile3DButton(
                  label: 'Owners',
                  icon: Icons.badge_rounded,
                  color: const Color(0xFFDB2777),
                  onTap: () => setState(() => _currentPage = 'owners'),
                ),
                Missile3DButton(
                  label: 'Drivers',
                  icon: Icons.person_rounded,
                  color: const Color(0xFF2563EB),
                  onTap: () => setState(() => _currentPage = 'drivers'),
                ),
                Missile3DButton(
                  label: 'Conductors',
                  icon: Icons.group_rounded,
                  color: const Color(0xFF16A34A),
                  onTap: () => setState(() => _currentPage = 'conductors'),
                ),
                const SizedBox(height: 8),
                _sl('SYSTEM'),
                Missile3DButton(
                  label: 'Refresh',
                  icon: Icons.refresh_rounded,
                  color: const Color(0xFF0891B2),
                  onTap: _loadAll,
                ),
                Missile3DButton(
                  label: 'Logout',
                  icon: Icons.logout_rounded,
                  color: const Color(0xFFDC2626),
                  onTap: _logout,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _sl(String t) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 4),
    child: Text(
      t,
      style: const TextStyle(
        color: Color(0xFFBDD8DB),
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    ),
  );

  Widget _mainContent() => SafeArea(
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4),
            ],
          ),
          child: Row(
            children: [
              if (!_sidebarOpen)
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => setState(() => _sidebarOpen = true),
                ),
              Expanded(
                child: Text(
                  _currentPage == 'owners'
                      ? 'Fleet Owners'
                      : _currentPage == 'drivers'
                      ? 'Fleet Drivers'
                      : _currentPage == 'conductors'
                      ? 'Fleet Conductors'
                      : 'Dashboard',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAll),
            ],
          ),
        ),
        Expanded(
          child: _currentPage == 'owners'
              ? _page('Owners', Icons.badge_rounded)
              : _currentPage == 'drivers'
              ? _page('Drivers', Icons.person_rounded)
              : _currentPage == 'conductors'
              ? _page('Conductors', Icons.group_rounded)
              : _home(),
        ),
      ],
    ),
  );

  Widget _page(String t, IconData i) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(i, size: 48, color: Colors.grey[400]),
        const SizedBox(height: 12),
        Text(t, style: TextStyle(fontSize: 18, color: Colors.grey[600])),
        const SizedBox(height: 8),
        Text(
          'Coming soon',
          style: TextStyle(fontSize: 13, color: Colors.grey[400]),
        ),
      ],
    ),
  );

  Widget _home() => SingleChildScrollView(
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
      ],
    ),
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
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
    padding: EdgeInsets.only(bottom: 4.h),
    child: Text(
      t,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
    ),
  );

  Widget _managementGrid() {
    return Row(
      children: [
        Expanded(
          child: _mgmtCard(
            'Owners',
            '$_ownerCount',
            Icons.badge_rounded,
            const Color(0xFFDB2777),
            () {},
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _mgmtCard(
            'Drivers',
            '$_driverCount',
            Icons.person_rounded,
            const Color(0xFF2563EB),
            () {},
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _mgmtCard(
            'Conductors',
            '$_conductorCount',
            Icons.group_rounded,
            const Color(0xFF16A34A),
            () {},
          ),
        ),
      ],
    );
  }

  Widget _mgmtCard(
    String label,
    String count,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26.w),
              SizedBox(height: 8.h),
              Text(
                count,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 11.sp, color: AppColors.gray500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statsRow() {
    return Row(
      children: [
        Expanded(
          child: _stat('Fleet Size', '${_profile?['active_buses'] ?? 0}'),
        ),
        SizedBox(width: 10.w),
        Expanded(child: _stat('Daily Revenue', 'PKR 0')),
      ],
    );
  }

  Widget _stat(String label, String value) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
    child: Padding(
      padding: EdgeInsets.all(14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: AppColors.gray500),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    ),
  );
}

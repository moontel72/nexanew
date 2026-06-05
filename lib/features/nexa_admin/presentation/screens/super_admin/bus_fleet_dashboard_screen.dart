// Bus Fleet Dashboard — Company Admin Panel (Module 13)
// Management hub: Owners, Drivers, Conductors, Fleet Overview

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/missile_3d_button.dart';
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
  String _currentPage = 'dashboard';
  bool _sidebarOpen = true;

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
    final isWide = MediaQuery.of(context).size.width > 900;
    if (_isLoading) return _loadingView();
    if (_error != null) return _errorView();

    return Scaffold(
      backgroundColor: const Color(0xFFE6F7F4),
      body: Row(children: [
        if (_sidebarOpen || isWide) _buildSidebar(isWide),
        Expanded(child: _buildMainContent()),
      ]),
    );
  }

  Widget _loadingView() => const Scaffold(body: Center(child: CircularProgressIndicator()));
  Widget _errorView() => Scaffold(body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.error_outline, size: 48, color: Colors.red), const SizedBox(height: 12), Text(_error ?? 'Error'), const SizedBox(height: 12), ElevatedButton(onPressed: _loadAll, child: const Text('Retry'))])));

  // ═══════════════════════════════════════════════════════
  // SIDEBAR — 3D Pencil Style
  // ═══════════════════════════════════════════════════════
  Widget _buildSidebar(bool isWide) {
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1A3A5C), Color(0xFF0F2B3F)]),
        boxShadow: [BoxShadow(color: Color(0x30144055), blurRadius: 16, offset: Offset(4, 0))],
      ),
      child: SafeArea(
        child: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFF00C49F), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.directions_bus, color: Colors.white, size: 20)),
              const SizedBox(width: 10),
              Expanded(child: Text(_company?.name ?? 'Bus Fleet', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis)),
              if (!isWide) IconButton(icon: const Icon(Icons.close, color: Colors.white70, size: 18), onPressed: () => setState(() => _sidebarOpen = false), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 30, minHeight: 30)),
            ]),
          ),
          const Divider(color: Color(0x20FFFFFF), height: 1, indent: 12, endIndent: 12),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(padding: const EdgeInsets.symmetric(horizontal: 10), children: [
              _sideLabel('MAIN'),
              Missile3DButton(label: 'Dashboard', icon: Icons.dashboard_rounded, color: const Color(0xFF7C3AED), onTap: () => setState(() => _currentPage = 'dashboard')),
              const SizedBox(height: 10),
              _sideLabel('FLEET'),
              Missile3DButton(label: 'Owners', icon: Icons.badge_rounded, color: const Color(0xFFDB2777), onTap: () => setState(() => _currentPage = 'owners')),
              Missile3DButton(label: 'Drivers', icon: Icons.person_rounded, color: const Color(0xFF2563EB), onTap: () => setState(() => _currentPage = 'drivers')),
              Missile3DButton(label: 'Conductors', icon: Icons.group_rounded, color: const Color(0xFF16A34A), onTap: () => setState(() => _currentPage = 'conductors')),
              const SizedBox(height: 10),
              _sideLabel('SYSTEM'),
              Missile3DButton(label: 'Refresh', icon: Icons.refresh_rounded, color: const Color(0xFF0891B2), onTap: _loadAll),
              Missile3DButton(label: 'Logout', icon: Icons.logout_rounded, color: const Color(0xFFDC2626), onTap: _logout),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _sideLabel(String t) => Padding(padding: const EdgeInsets.only(left: 4, bottom: 4), child: Text(t, style: const TextStyle(color: Color(0xFFBDD8DB), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2))));

  Widget _buildMainContent() {
    return SafeArea(
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)]),
          child: Row(children: [
            if (!_sidebarOpen) IconButton(icon: const Icon(Icons.menu), onPressed: () => setState(() => _sidebarOpen = true)),
            Expanded(child: Text(_currentPage == 'owners' ? 'Fleet Owners' : _currentPage == 'drivers' ? 'Fleet Drivers' : _currentPage == 'conductors' ? 'Fleet Conductors' : 'Dashboard', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700))),
            IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAll),
          ]),
        ),
        Expanded(
          child: _currentPage == 'owners' ? _placeholderPage('Owners', Icons.badge_rounded) :
                 _currentPage == 'drivers' ? _placeholderPage('Drivers', Icons.person_rounded) :
                 _currentPage == 'conductors' ? _placeholderPage('Conductors', Icons.group_rounded) :
                 _buildDashboardHome(),
        ),
      ]),
    );
  }

  Widget _placeholderPage(String title, IconData icon) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 48, color: Colors.grey[400]),
      const SizedBox(height: 12),
      Text(title, style: TextStyle(fontSize: 18, color: Colors.grey[600])),
      const SizedBox(height: 8),
      Text('Coming soon', style: TextStyle(fontSize: 13, color: Colors.grey[400])),
    ]));
  }

  Widget _buildDashboardHome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (_company != null) _companyHeader(),
        const SizedBox(height: 20),
        _sectionTitle('Fleet Management'),
        const SizedBox(height: 12),
        _managementGrid(),
        const SizedBox(height: 24),
        _sectionTitle('Quick Stats'),
        const SizedBox(height: 12),
        _statsRow(),
      ]),
    );
  }

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

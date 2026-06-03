// Sub-Admin Dashboard — Vertical Ecosystem Control
//
// Pencil-shaped sidebar navigation (identical to Bus Owner Dashboard pattern)
// with color-coded buttons per functional module.
// The sidebar shows different modules based on the sub-admin's vertical.
//
// Designed per MODULE 2 — SUB-ADMIN PANELS (QUAD SUB-ADMIN HIERARCHY)
// from the NEXATRACE_SUPREME_MASTER_SPEC.md

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/missile_3d_button.dart';
import 'package:trace_odd/shared/theme/colors.dart';

// ─── Sub-Admin Module Color Spectrum ──────────────────────
class SubAdminButtonColors {
  static const Color tenants = Color(0xFF7C3AED);     // Purple
  static const Color features = Color(0xFFDB2777);     // Pink
  static const Color finance = Color(0xFF2563EB);      // Blue
  static const Color fleet = Color(0xFF16A34A);         // Green
  static const Color reports = Color(0xFFD97706);       // Gold/Bronze
  static const Color settings = Color(0xFF0891B2);      // Cyan/Teal
}

class SubAdminDashboardScreen extends StatefulWidget {
  const SubAdminDashboardScreen({super.key});

  @override
  State<SubAdminDashboardScreen> createState() => _SubAdminDashboardScreenState();
}

class _SubAdminDashboardScreenState extends State<SubAdminDashboardScreen> {
  String _subAdminName = 'Sub-Admin';
  String _vertical = '';
  String _token = '';
  bool _isSidebarOpen = true;

  // ── Dashboard metrics
  int _tenantCount = 0;
  int _activeFeatures = 0;
  double _monthlyRevenue = 0.0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('sub_admin_token') ?? '';

    if (!mounted) return;
    if (_token.isEmpty) {
      context.go('/sub-admin/login');
      return;
    }

    setState(() {
      _subAdminName = prefs.getString('sub_admin_name') ?? 'Sub-Admin';
      _vertical = prefs.getString('sub_admin_vertical') ?? '';
    });

    await _loadDashboardData();
  }

  String get _verticalLabel {
    switch (_vertical) {
      case 'bus_transit': return 'Bus Transit';
      case 'goods_logistics': return 'Goods & Logistics';
      case 'commercial_marketplace': return 'Commercial Marketplace';
      case 'financial_auditor': return 'Financial Auditor';
      default: return 'Sub-Admin';
    }
  }

  Future<void> _loadDashboardData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      // Simulate data load (replace with real API calls)
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      setState(() {
        _tenantCount = 12;
        _activeFeatures = 28;
        _monthlyRevenue = 245600.0;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sub_admin_token');
    await prefs.remove('sub_admin_name');
    await prefs.remove('sub_admin_vertical');
    await prefs.remove('sub_admin_email');
    if (mounted) context.go('/sub-admin/login');
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          if (_isSidebarOpen || isWide) _buildSidebar(isWide),
          Expanded(child: _buildMainContent(isWide)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // SIDEBAR — Pencil-shaped navigation (Bus Owner pattern)
  // ═══════════════════════════════════════════════════════
  Widget _buildSidebar(bool isWide) {
    return Container(
      width: 260,
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
            _buildSidebarHeader(isWide),
            const Gap(8),
            _buildSubAdminBadge(),
            const Gap(12),
            const Divider(color: Color(0x20FFFFFF), height: 1, indent: 20, endIndent: 20),
            const Gap(12),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    _sectionLabel('COMMAND CENTER'),
                    const Gap(6),
                    Missile3DButton(
                      label: 'Tenant Companies',
                      icon: Icons.business_rounded,
                      color: SubAdminButtonColors.tenants,
                      onTap: () {},
                    ),
                    Missile3DButton(
                      label: 'Onboard New Tenant',
                      icon: Icons.add_business_rounded,
                      color: SubAdminButtonColors.tenants,
                      onTap: () {},
                    ),
                    const Gap(8),
                    _sectionLabel('PERMISSIONS'),
                    const Gap(6),
                    Missile3DButton(
                      label: 'Feature Allowance Grid',
                      icon: Icons.toggle_on_rounded,
                      color: SubAdminButtonColors.features,
                      onTap: () {},
                    ),
                    Missile3DButton(
                      label: 'Access Control Matrix',
                      icon: Icons.shield_rounded,
                      color: SubAdminButtonColors.features,
                      onTap: () {},
                    ),
                    const Gap(8),
                    _sectionLabel('OPERATIONS'),
                    const Gap(6),
                    Missile3DButton(
                      label: 'Fleet Management',
                      icon: Icons.directions_bus_rounded,
                      color: SubAdminButtonColors.fleet,
                      onTap: () {},
                    ),
                    Missile3DButton(
                      label: 'Route & Waypoint Scheduler',
                      icon: Icons.alt_route_rounded,
                      color: SubAdminButtonColors.fleet,
                      onTap: () {},
                    ),
                    const Gap(8),
                    _sectionLabel('FINANCE'),
                    const Gap(6),
                    Missile3DButton(
                      label: 'Tariff & Commission Guard',
                      icon: Icons.account_balance_wallet_rounded,
                      color: SubAdminButtonColors.finance,
                      onTap: () {},
                    ),
                    Missile3DButton(
                      label: 'Revenue Dashboard',
                      icon: Icons.trending_up_rounded,
                      color: SubAdminButtonColors.finance,
                      onTap: () {},
                    ),
                    const Gap(8),
                    _sectionLabel('INSIGHTS'),
                    const Gap(6),
                    Missile3DButton(
                      label: 'Analytics & Reports',
                      icon: Icons.analytics_rounded,
                      color: SubAdminButtonColors.reports,
                      onTap: () {},
                    ),
                    Missile3DButton(
                      label: 'Audit Trail',
                      icon: Icons.history_rounded,
                      color: SubAdminButtonColors.reports,
                      onTap: () {},
                    ),
                    const Gap(8),
                    _sectionLabel('SYSTEM'),
                    const Gap(6),
                    Missile3DButton(
                      label: 'Settings & Profile',
                      icon: Icons.settings_rounded,
                      color: SubAdminButtonColors.settings,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
            _buildSidebarBottom(),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarHeader(bool isWide) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 10, 8),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 20),
          ),
          const Gap(10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Trace Odd',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$_verticalLabel Terminal',
                  style: const TextStyle(color: Color(0xFFBDD8DB), fontSize: 11),
                ),
              ],
            ),
          ),
          if (!isWide)
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
              onPressed: () => setState(() => _isSidebarOpen = false),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
        ],
      ),
    );
  }

  Widget _buildSubAdminBadge() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.secondary,
            child: Text(
              _subAdminName.characters.first.toUpperCase(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
          const Gap(8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _subAdminName,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _verticalLabel,
                  style: const TextStyle(color: Color(0xFFBDD8DB), fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 2),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFFBDD8DB),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarBottom() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          const Divider(color: Color(0x20FFFFFF), height: 1),
          const Gap(8),
          InkWell(
            onTap: _loadDashboardData,
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Icon(Icons.refresh_rounded, size: 18, color: Colors.white60),
                  Gap(8),
                  Text('Refresh Data', style: TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: _logout,
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Icon(Icons.logout_rounded, size: 18, color: Colors.white60),
                  Gap(8),
                  Text('Logout', style: TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // MAIN CONTENT AREA
  // ═══════════════════════════════════════════════════════
  Widget _buildMainContent(bool isWide) {
    return SafeArea(
      child: Column(
        children: [
          _buildTopBar(isWide),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorView()
                    : RefreshIndicator(
                        onRefresh: _loadDashboardData,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildGreeting(),
                              const Gap(20),
                              _buildKpiCards(isWide),
                              const Gap(24),
                              _buildQuickActions(),
                              const Gap(24),
                              _buildRecentActivity(),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(bool isWide) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          if (!_isSidebarOpen || !isWide)
            IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => setState(() => _isSidebarOpen = true),
            ),
          Expanded(
            child: Text(
              '$_verticalLabel Dashboard',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            color: AppColors.gray500,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back, $_subAdminName',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const Gap(4),
        Text(
          '$_verticalLabel — Ecosystem Control Terminal',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildKpiCards(bool isWide) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 700 ? 3 : (constraints.maxWidth > 400 ? 2 : 1);
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.6,
          children: [
            _kpiCard('Tenant Companies', '$_tenantCount', Icons.business_rounded, SubAdminButtonColors.tenants),
            _kpiCard('Active Features', '$_activeFeatures', Icons.toggle_on_rounded, SubAdminButtonColors.features),
            _kpiCard('Monthly Revenue', 'PKR ${_monthlyRevenue.toStringAsFixed(0)}', Icons.trending_up_rounded, SubAdminButtonColors.finance),
          ],
        );
      },
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const Gap(12),
        Row(
          children: [
            Expanded(
              child: _actionCard('Onboard Tenant', Icons.add_business_rounded, SubAdminButtonColors.tenants, () {}),
            ),
            const Gap(12),
            Expanded(
              child: _actionCard('Feature Grid', Icons.grid_view_rounded, SubAdminButtonColors.features, () {}),
            ),
            const Gap(12),
            Expanded(
              child: _actionCard('View Reports', Icons.description_rounded, SubAdminButtonColors.reports, () {}),
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionCard(String label, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const Gap(8),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const Gap(12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: const Padding(
            padding: EdgeInsets.all(40),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.inbox_rounded, size: 40, color: AppColors.gray300),
                  Gap(8),
                  Text('Activity feed will appear here', style: TextStyle(color: AppColors.textTertiary)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const Gap(12),
          Text(_error!, style: const TextStyle(color: AppColors.textSecondary)),
          const Gap(12),
          ElevatedButton(onPressed: _loadDashboardData, child: const Text('Retry')),
        ],
      ),
    );
  }
}

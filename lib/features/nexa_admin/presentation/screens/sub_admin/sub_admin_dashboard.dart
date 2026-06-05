// Sub-Admin Dashboard — Vertical Ecosystem Control
//
// Pencil-shaped sidebar navigation (identical to Bus Owner Dashboard pattern)
// with color-coded buttons per functional module.
// The sidebar shows different modules based on the sub-admin's vertical.
//
// Designed per MODULE 2 — SUB-ADMIN PANELS (QUAD SUB-ADMIN HIERARCHY)
// from the NEXATRACE_SUPREME_MASTER_SPEC.md

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace_odd/core/config/api_config.dart';
import 'package:trace_odd/core/services/api_client.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/missile_3d_button.dart';
import 'package:trace_odd/shared/theme/colors.dart';

// ─── Sub-Admin Module Color Spectrum ──────────────────────
class SubAdminButtonColors {
  static const Color tenants = Color(0xFF7C3AED); // Purple
  static const Color features = Color(0xFFDB2777); // Pink
  static const Color finance = Color(0xFF2563EB); // Blue
  static const Color fleet = Color(0xFF16A34A); // Green
  static const Color reports = Color(0xFFD97706); // Gold/Bronze
  static const Color settings = Color(0xFF0891B2); // Cyan/Teal
}

class SubAdminDashboardScreen extends StatefulWidget {
  const SubAdminDashboardScreen({super.key});

  @override
  State<SubAdminDashboardScreen> createState() =>
      _SubAdminDashboardScreenState();
}

class _SubAdminDashboardScreenState extends State<SubAdminDashboardScreen> {
  String _subAdminName = 'Sub-Admin';
  String _vertical = '';
  String _token = '';
  bool _isSidebarOpen = true;
  String _currentPage =
      'dashboard'; // 'dashboard' | 'add_bus_company' | 'view_bus_companies'
  bool _busCompanyExpanded = false;

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
      case 'bus_transit':
        return 'Bus Transit';
      case 'goods_logistics':
        return 'Goods & Logistics';
      case 'commercial_marketplace':
        return 'Commercial Marketplace';
      case 'financial_auditor':
        return 'Financial Auditor';
      default:
        return 'Sub-Admin';
    }
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
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
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
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
            const Divider(
              color: Color(0x20FFFFFF),
              height: 1,
              indent: 20,
              endIndent: 20,
            ),
            const Gap(12),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    _sectionLabel('BUS COMPANY'),
                    const Gap(6),
                    // Parent — pencil-shaped expand/collapse
                    Missile3DButton(
                      label: 'Bus Company',
                      icon: Icons.directions_bus_rounded,
                      color: SubAdminButtonColors.tenants,
                      onTap: () => setState(
                        () => _busCompanyExpanded = !_busCompanyExpanded,
                      ),
                    ),
                    // Sub-items — pencil-shaped, slightly smaller, unique colors
                    if (_busCompanyExpanded) ...[
                      Missile3DButton(
                        label: 'Add Bus Company',
                        icon: Icons.add_business_rounded,
                        color: const Color(0xFFD97706),
                        height: 66,
                        onTap: () =>
                            setState(() => _currentPage = 'add_bus_company'),
                      ),
                      Missile3DButton(
                        label: 'View All Bus Companies',
                        icon: Icons.list_alt_rounded,
                        color: const Color(0xFF0891B2),
                        height: 66,
                        onTap: () =>
                            setState(() => _currentPage = 'view_bus_companies'),
                      ),
                    ],
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SvgPicture.asset(
                'assets/logo/logo-company-name.svg',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const Gap(10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Trace Odd',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$_verticalLabel Terminal',
                  style: const TextStyle(
                    color: Color(0xFFBDD8DB),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (!isWide)
            IconButton(
              icon: const Icon(
                Icons.close_rounded,
                color: Colors.white70,
                size: 20,
              ),
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
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _verticalLabel,
                  style: const TextStyle(
                    color: Color(0xFFBDD8DB),
                    fontSize: 10,
                  ),
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
                  Text(
                    'Refresh Data',
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
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
                  Text(
                    'Logout',
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
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
                : _currentPage == 'add_bus_company'
                ? _buildAddBusCompanyPage()
                : _currentPage == 'view_bus_companies'
                ? _buildBusCompanyListPage()
                : _buildDashboardHome(),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // DASHBOARD HOME (original KPI + quick actions)
  // ═══════════════════════════════════════════════════════
  Widget _buildDashboardHome() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreeting(),
            const Gap(20),
            _buildKpiCards(true),
            const Gap(24),
            _buildQuickActions(),
            const Gap(24),
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isWide) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
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
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
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
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
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
        final crossAxisCount = constraints.maxWidth > 700
            ? 3
            : (constraints.maxWidth > 400 ? 2 : 1);
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.6,
          children: [
            _kpiCard(
              'Tenant Companies',
              '$_tenantCount',
              Icons.business_rounded,
              SubAdminButtonColors.tenants,
            ),
            _kpiCard(
              'Active Features',
              '$_activeFeatures',
              Icons.toggle_on_rounded,
              SubAdminButtonColors.features,
            ),
            _kpiCard(
              'Monthly Revenue',
              'PKR ${_monthlyRevenue.toStringAsFixed(0)}',
              Icons.trending_up_rounded,
              SubAdminButtonColors.finance,
            ),
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
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const Gap(12),
        Row(
          children: [
            Expanded(
              child: _actionCard(
                'Onboard Tenant',
                Icons.add_business_rounded,
                SubAdminButtonColors.tenants,
                () {},
              ),
            ),
            const Gap(12),
            Expanded(
              child: _actionCard(
                'Feature Grid',
                Icons.grid_view_rounded,
                SubAdminButtonColors.features,
                () {},
              ),
            ),
            const Gap(12),
            Expanded(
              child: _actionCard(
                'View Reports',
                Icons.description_rounded,
                SubAdminButtonColors.reports,
                () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionCard(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
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
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
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
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const Gap(12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Padding(
            padding: EdgeInsets.all(40),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.inbox_rounded, size: 40, color: AppColors.gray300),
                  Gap(8),
                  Text(
                    'Activity feed will appear here',
                    style: TextStyle(color: AppColors.textTertiary),
                  ),
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
          ElevatedButton(
            onPressed: _loadDashboardData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // ADD BUS COMPANY PAGE
  // ═══════════════════════════════════════════════════════
  final _busFormKey = GlobalKey<FormState>();
  final _companyNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _regCodeCtrl = TextEditingController();
  final _fleetSizeCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();
  bool _busFormLoading = false;
  bool _obscurePassword = true;

  Widget _buildAddBusCompanyPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _busFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: SubAdminButtonColors.tenants.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.add_business_rounded,
                    color: Color(0xFF7C3AED),
                    size: 22,
                  ),
                ),
                const Gap(12),
                const Expanded(
                  child: Text(
                    'Register New Bus Company',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const Gap(20),
            _busField('Company Name', _companyNameCtrl, Icons.business),
            const Gap(14),
            _busField(
              'Corporate Email',
              _emailCtrl,
              Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const Gap(14),
            // Password field with visibility toggle
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscurePassword,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty)
                  return 'Password is required';
                if (v.length < 8) return 'Minimum 8 characters';
                return null;
              },
            ),
            const Gap(14),
            _busField(
              'Phone / Support Contact',
              _phoneCtrl,
              Icons.phone,
              keyboardType: TextInputType.phone,
              required: false,
            ),
            const Gap(24),
            const Text(
              'System Assignment',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const Gap(10),
            _busField(
              'Registration Code',
              _regCodeCtrl,
              Icons.qr_code,
              required: false,
            ),
            const Gap(14),
            _busField(
              'Fleet Size (vehicles)',
              _fleetSizeCtrl,
              Icons.directions_bus,
              keyboardType: TextInputType.number,
              required: false,
            ),
            const Gap(14),
            _busField(
              'Transit License Ref',
              _licenseCtrl,
              Icons.assignment,
              required: false,
            ),
            const Gap(24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: SubAdminButtonColors.tenants,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _busFormLoading ? null : _submitBusCompany,
                child: _busFormLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Create Bus Company',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _busField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    TextInputType? keyboardType,
    bool obscure = false,
    bool required = true,
    int? minLen,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) {
        if (!required) return null;
        if (v == null || v.trim().isEmpty) return '$label is required';
        if (minLen != null && v.length < minLen)
          return 'Minimum $minLen characters';
        return null;
      },
    );
  }

  Future<void> _submitBusCompany() async {
    if (!_busFormKey.currentState!.validate()) return;
    setState(() => _busFormLoading = true);
    try {
      final api = ApiClient();
      await api.post(
        '${ApiConfig.apiBaseUrl}/admin/bus-companies/create',
        body: {
          'company_name': _companyNameCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'password': _passwordCtrl.text,
          'phone': _phoneCtrl.text.trim(),
          'registration_code': _regCodeCtrl.text.trim(),
          'fleet_size': int.tryParse(_fleetSizeCtrl.text.trim()) ?? 0,
          'transit_license': _licenseCtrl.text.trim(),
        },
      );
      _clearBusForm();
      setState(() {
        _busFormLoading = false;
        _currentPage = 'view_bus_companies';
      });
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bus company created!'),
            backgroundColor: Colors.green,
          ),
        );
    } catch (e) {
      setState(() => _busFormLoading = false);
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
    }
  }

  void _clearBusForm() {
    _companyNameCtrl.clear();
    _emailCtrl.clear();
    _passwordCtrl.clear();
    _phoneCtrl.clear();
    _regCodeCtrl.clear();
    _fleetSizeCtrl.clear();
    _licenseCtrl.clear();
    _obscurePassword = true;
  }

  // ═══════════════════════════════════════════════════════
  // VIEW ALL BUS COMPANIES PAGE
  // ═══════════════════════════════════════════════════════
  List<Map<String, dynamic>> _busCompanies = [];
  bool _busListLoading = false;

  Widget _buildBusCompanyListPage() {
    if (_busCompanies.isEmpty && !_busListLoading) _fetchBusCompanies();
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Flexible(
                child: Text(
                  'Bus Companies',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Gap(12),
              ElevatedButton.icon(
                onPressed: () =>
                    setState(() => _currentPage = 'add_bus_company'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add New'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SubAdminButtonColors.tenants,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _busListLoading
              ? const Center(child: CircularProgressIndicator())
              : _busCompanies.isEmpty
              ? const Center(
                  child: Text(
                    'No bus companies yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchBusCompanies,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _busCompanies.length,
                    itemBuilder: (ctx, i) => _busCompanyCard(_busCompanies[i]),
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _fetchBusCompanies() async {
    setState(() => _busListLoading = true);
    try {
      final api = ApiClient();
      final res = await api.get('${ApiConfig.apiBaseUrl}/admin/bus-companies');
      final data = res['data'];
      setState(() {
        _busCompanies = (data is List) ? data.cast<Map<String, dynamic>>() : [];
        _busListLoading = false;
      });
    } catch (e) {
      setState(() => _busListLoading = false);
    }
  }

  Widget _busCompanyCard(Map<String, dynamic> c) {
    final isActive = c['status'] == 'active';
    final isDeleted = c['status'] == 'deleted';
    // Safe metadata parsing — API may return JSON string or Map
    Map<String, dynamic> meta = {};
    final rawMeta = c['metadata'];
    if (rawMeta is Map) {
      meta = rawMeta.cast<String, dynamic>();
    } else if (rawMeta is String && rawMeta.isNotEmpty) {
      try {
        meta = jsonDecode(rawMeta) as Map<String, dynamic>;
      } catch (_) {}
    }
    final fleetSize = meta['fleet_size']?.toString() ?? '0';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: SubAdminButtonColors.tenants.withValues(alpha: 0.12),
          child: const Icon(Icons.directions_bus, color: Color(0xFF7C3AED)),
        ),
        title: Text(
          c['account_name'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${c['email'] ?? ''}  •  Fleet: $fleetSize  •  ${_formatDate(c['created_at'])}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isDeleted
                    ? Colors.red.withValues(alpha: 0.1)
                    : isActive
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isDeleted ? 'DELETED' : (isActive ? 'ACTIVE' : 'SUSPENDED'),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isDeleted
                      ? Colors.red
                      : isActive
                      ? Colors.green
                      : Colors.orange,
                ),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (action) => _handleBusCompanyAction(action, c),
              itemBuilder: (ctx) {
                if (isDeleted) {
                  return [
                    const PopupMenuItem(
                      value: 'restore',
                      child: ListTile(
                        leading: Icon(Icons.restore, color: Colors.green),
                        title: Text('Restore'),
                        dense: true,
                      ),
                    ),
                  ];
                }
                return [
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Edit'),
                      dense: true,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggle_status',
                    child: ListTile(
                      leading: Icon(
                        isActive ? Icons.block : Icons.check_circle,
                        color: isActive ? Colors.orange : Colors.green,
                      ),
                      title: Text(isActive ? 'Suspend' : 'Activate'),
                      dense: true,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'reset_password',
                    child: ListTile(
                      leading: Icon(Icons.lock_reset),
                      title: Text('Reset Password'),
                      dense: true,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                      dense: true,
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic d) {
    if (d == null) return '';
    try {
      return DateTime.parse(d.toString()).toString().substring(0, 10);
    } catch (_) {
      return d.toString();
    }
  }

  // ── Bus Company Actions ────────────────────────────────

  void _handleBusCompanyAction(String action, Map<String, dynamic> c) {
    switch (action) {
      case 'edit':
        _showEditBusCompanyDialog(c);
        break;
      case 'toggle_status':
        _toggleBusCompanyStatus(c);
        break;
      case 'reset_password':
        _showResetBusCompanyPasswordDialog(c);
        break;
      case 'delete':
        _confirmDeleteBusCompany(c);
        break;
      case 'restore':
        _restoreBusCompany(c);
        break;
    }
  }

  Future<void> _toggleBusCompanyStatus(Map<String, dynamic> c) async {
    try {
      await ApiClient().patch(
        '${ApiConfig.apiBaseUrl}/admin/bus-companies/${c['id']}/status',
      );
      _fetchBusCompanies();
    } catch (_) {}
  }

  void _showEditBusCompanyDialog(Map<String, dynamic> c) {
    final meta = _parseMeta(c['metadata']);
    final nameCtrl = TextEditingController(text: c['account_name']);
    final emailCtrl = TextEditingController(text: c['email']);
    final regCtrl = TextEditingController(
      text: meta['registration_code']?.toString() ?? '',
    );
    final fleetCtrl = TextEditingController(
      text: meta['fleet_size']?.toString() ?? '',
    );
    final licCtrl = TextEditingController(
      text: meta['transit_license']?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Bus Company'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Company Name'),
              ),
              const Gap(10),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const Gap(10),
              TextField(
                controller: regCtrl,
                decoration: const InputDecoration(
                  labelText: 'Registration Code',
                ),
              ),
              const Gap(10),
              TextField(
                controller: fleetCtrl,
                decoration: const InputDecoration(labelText: 'Fleet Size'),
                keyboardType: TextInputType.number,
              ),
              const Gap(10),
              TextField(
                controller: licCtrl,
                decoration: const InputDecoration(labelText: 'Transit License'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ApiClient().put(
                  '${ApiConfig.apiBaseUrl}/admin/bus-companies/${c['id']}',
                  body: {
                    'company_name': nameCtrl.text.trim(),
                    'email': emailCtrl.text.trim(),
                    'registration_code': regCtrl.text.trim(),
                    'fleet_size': int.tryParse(fleetCtrl.text.trim()) ?? 0,
                    'transit_license': licCtrl.text.trim(),
                  },
                );
                Navigator.pop(ctx);
                _fetchBusCompanies();
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Failed: $e')));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showResetBusCompanyPasswordDialog(Map<String, dynamic> c) {
    final passCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Password'),
        content: TextField(
          controller: passCtrl,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'New Password (min 8 chars)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (passCtrl.text.length < 8) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Minimum 8 characters')),
                );
                return;
              }
              try {
                await ApiClient().put(
                  '${ApiConfig.apiBaseUrl}/admin/bus-companies/${c['id']}',
                  body: {'password': passCtrl.text},
                );
                Navigator.pop(ctx);
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Failed: $e')));
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteBusCompany(Map<String, dynamic> c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Bus Company?'),
        content: Text(
          'This will soft-delete ${c['account_name']}. Restorable for 30 days.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ApiClient().delete(
                  '${ApiConfig.apiBaseUrl}/admin/bus-companies/${c['id']}',
                );
                _fetchBusCompanies();
              } catch (e) {
                if (mounted)
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Failed: $e')));
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _restoreBusCompany(Map<String, dynamic> c) async {
    try {
      await ApiClient().patch(
        '${ApiConfig.apiBaseUrl}/admin/bus-companies/${c['id']}/restore',
      );
      _fetchBusCompanies();
    } catch (_) {}
  }

  Map<String, dynamic> _parseMeta(dynamic rawMeta) {
    if (rawMeta is Map) return rawMeta.cast<String, dynamic>();
    if (rawMeta is String && rawMeta.isNotEmpty) {
      try {
        return jsonDecode(rawMeta) as Map<String, dynamic>;
      } catch (_) {}
    }
    return {};
  }
}

// Bus Owner Interactive 3D Dashboard (Module 14)
//
// • Sidebar: fixed 260px, no screenutil scaling inside (prevents text collapse)
// • Brand: dynamic parent company from login response
// • Auth: token verified BEFORE any API call, redirects to login if missing

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/missile_3d_button.dart';
import 'package:trace_odd/shared/theme/colors.dart';

// ─── Mizaeel Color Spectrum ──────────────────────────────
class OwnerButtonColors {
  static const Color timeline = Color(0xFF7C3AED);
  static const Color drivers = Color(0xFFDB2777);
  static const Color conductors = Color(0xFFDC2626);
  static const Color seats = Color(0xFF2563EB);
  static const Color earnings = Color(0xFF16A34A);
  static const Color alerts = Color(0xFFD97706);
}

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  // ── Identity (loaded from SharedPreferences before anything else)
  String _token = '';
  String _ownerName = 'Owner';
  String _parentCompanyName = '';
  String _customDisplayName = '';

  // ── Dashboard data
  bool _isSidebarOpen = true;
  int _activeBuses = 0;
  double _dailyRevenue = 0.0;
  List<Map<String, dynamic>> _seatManifest = [];
  bool _isLoading = true;
  String? _error;

  // ── Editing
  final _displayNameController = TextEditingController();
  bool _isEditingName = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  // ────────────────────────────────────────────────────────
  // BOOTSTRAP: load identity & token, then fetch fleet data
  // ────────────────────────────────────────────────────────
  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token') ?? '';

    if (!mounted) return;
    if (_token.isEmpty) {
      // No token → redirect to login immediately
      context.go('/bus-owner/login');
      return;
    }

    setState(() {
      _ownerName = prefs.getString('bus_owner_name') ?? 'Owner';
      _parentCompanyName = prefs.getString('bus_owner_company') ?? '';
      _customDisplayName = prefs.getString('bus_owner_display_name') ?? '';
    });

    await _loadDashboardData();
  }

  /// Brand name: custom > parent company > fallback
  String get _brandName {
    if (_customDisplayName.isNotEmpty) return _customDisplayName;
    if (_parentCompanyName.isNotEmpty) return _parentCompanyName;
    return 'NexaTrace';
  }

  // ────────────────────────────────────────────────────────
  // DATA FETCH — only called after token is confirmed
  // ────────────────────────────────────────────────────────
  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = ApiService();

      final profileRes = await api.get('/super-admin/tenants/fleet-data');
      final fleet = profileRes['data'] as Map<String, dynamic>? ?? {};

      List<Map<String, dynamic>> manifest = [];
      try {
        manifest = (fleet['shift_allocations'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>();
      } catch (_) {}

      if (!mounted) return;
      setState(() {
        _activeBuses = (fleet['buses'] as List<dynamic>?)?.length ?? 0;
        _dailyRevenue = 0.0;
        _seatManifest = manifest;
        _isLoading = false;
      });
    } on Exception catch (e) {
      if (!mounted) return;
      final msg = e.toString().toLowerCase();
      // If token expired or invalid, bounce to login
      if (msg.contains('unauth') ||
          msg.contains('401') ||
          msg.contains('token')) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        if (mounted) context.go('/bus-owner/login');
        return;
      }
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    if (mounted) context.go('/bus-owner/login');
  }

  // ═══════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════
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
  // SIDEBAR — 260px fixed, NO .w/.sp scaling inside
  // ═══════════════════════════════════════════════════════
  Widget _buildSidebar(bool isWide) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF256B77), Color(0xFF14434D)],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x30144A55),
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
            _buildOwnerBadge(),
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
                    _sectionLabel('NAVIGATION'),
                    const Gap(6),
                    Missile3DButton(
                      label: 'Project / Fleet Timeline',
                      subtitle: 'Activity & routes',
                      icon: Icons.timeline_rounded,
                      color: OwnerButtonColors.timeline,
                      onTap: () {},
                    ),
                    Missile3DButton(
                      label: 'My Drivers Ledger',
                      subtitle: 'Type D personnel',
                      icon: Icons.badge_rounded,
                      color: OwnerButtonColors.drivers,
                      onTap: () {},
                    ),
                    Missile3DButton(
                      label: 'My Conductors Ledger',
                      subtitle: 'Type E personnel',
                      icon: Icons.group_rounded,
                      color: OwnerButtonColors.conductors,
                      onTap: () {},
                    ),
                    Missile3DButton(
                      label: 'Active Bus Seats Tracker',
                      subtitle: 'Live seat manifest',
                      icon: Icons.event_seat_rounded,
                      color: OwnerButtonColors.seats,
                      onTap: () {},
                    ),
                    Missile3DButton(
                      label: 'Daily Earnings Matrix',
                      subtitle: 'Revenue dashboard',
                      icon: Icons.account_balance_wallet_rounded,
                      color: OwnerButtonColors.earnings,
                      onTap: () {},
                    ),
                    Missile3DButton(
                      label: 'Alerts & Maintenance',
                      subtitle: 'Issues & repairs',
                      icon: Icons.warning_amber_rounded,
                      color: OwnerButtonColors.alerts,
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
            child: const Icon(
              Icons.directions_bus_filled,
              color: Colors.white,
              size: 20,
            ),
          ),
          const Gap(10),
          // FLEXIBLE prevents text from collapsing vertically
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _brandName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  'Owner Terminal',
                  style: TextStyle(color: Color(0xFFBDD8DB), fontSize: 11),
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

  Widget _buildOwnerBadge() {
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
              _ownerName.characters.first.toUpperCase(),
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
                  _ownerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_parentCompanyName.isNotEmpty)
                  Text(
                    'under $_parentCompanyName',
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
  // MAIN CONTENT
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
                          _buildAnalyticsCards(isWide),
                          const Gap(24),
                          _buildSeatManifestSection(),
                          const Gap(24),
                          _buildStaffManagementCards(),
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
          const Expanded(
            child: Text(
              'Owner Dashboard',
              style: TextStyle(
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
        Row(
          children: [
            Expanded(
              child: Text(
                'Welcome back, $_ownerName',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                _isEditingName ? Icons.check_rounded : Icons.edit_rounded,
                size: 20,
                color: AppColors.gray400,
              ),
              onPressed: _isEditingName
                  ? _saveDisplayName
                  : _startEditDisplayName,
              tooltip: _isEditingName
                  ? 'Save brand name'
                  : 'Edit fleet display name',
            ),
          ],
        ),
        if (_isEditingName) ...[
          const Gap(8),
          TextFormField(
            controller: _displayNameController,
            decoration: InputDecoration(
              hintText: _parentCompanyName.isNotEmpty
                  ? _parentCompanyName
                  : 'Enter fleet brand name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              isDense: true,
              filled: true,
              fillColor: Colors.white,
            ),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            onFieldSubmitted: (_) => _saveDisplayName(),
          ),
        ] else ...[
          const Gap(4),
          Text(
            _parentCompanyName.isNotEmpty
                ? 'Fleet under $_parentCompanyName'
                : 'Here\'s your fleet overview for today',
            style: const TextStyle(fontSize: 13, color: AppColors.gray500),
          ),
          if (_customDisplayName.isNotEmpty)
            Text(
              'Branding: $_customDisplayName',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ],
    );
  }

  void _startEditDisplayName() {
    setState(() {
      _isEditingName = true;
      _displayNameController.text = _customDisplayName;
    });
  }

  Future<void> _saveDisplayName() async {
    final name = _displayNameController.text.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bus_owner_display_name', name);
    setState(() {
      _customDisplayName = name;
      _isEditingName = false;
    });
  }

  // ─── Analytics ─────────────────────────────────────────
  Widget _buildAnalyticsCards(bool isWide) {
    return Flex(
      direction: isWide ? Axis.horizontal : Axis.vertical,
      children: [
        Expanded(
          child: _analyticsCard(
            'Active Buses',
            '$_activeBuses',
            'Total owned',
            Icons.directions_bus,
            AppColors.primary,
          ),
        ),
        const Gap(12),
        Expanded(
          child: _analyticsCard(
            'Daily Revenue',
            'Rs. ${_dailyRevenue.toStringAsFixed(0)}',
            'Earnings',
            Icons.trending_up_rounded,
            OwnerButtonColors.earnings,
          ),
        ),
      ],
    );
  }

  Widget _analyticsCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color accent,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accent, size: 20),
              ),
              const Icon(Icons.more_horiz, color: AppColors.gray300, size: 18),
            ],
          ),
          const Gap(12),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const Gap(2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: AppColors.gray400),
          ),
        ],
      ),
    );
  }

  // ─── Seat Manifest ─────────────────────────────────────
  Widget _buildSeatManifestSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Live Seat Manifest',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  _legendDot(OwnerButtonColors.seats, 'Booked'),
                  const Gap(10),
                  _legendDot(Colors.grey.shade300, 'Vacant'),
                ],
              ),
            ],
          ),
          const Gap(14),
          if (_seatManifest.isEmpty)
            _buildEmptyManifest()
          else
            ..._seatManifest.map(_buildTripSeatCard),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const Gap(4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.gray500),
        ),
      ],
    );
  }

  Widget _buildEmptyManifest() {
    return SizedBox(
      height: 100,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_seat, size: 40, color: AppColors.gray300),
            const Gap(8),
            const Text(
              'No active trips',
              style: TextStyle(color: AppColors.gray400, fontSize: 13),
            ),
            Text(
              'Manifests appear when trips are in progress',
              style: TextStyle(color: AppColors.gray300, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripSeatCard(Map<String, dynamic> trip) {
    final route = trip['route_name']?.toString() ?? 'Unknown Route';
    final plate =
        trip['plate_number']?.toString() ??
        trip['bus_plate']?.toString() ??
        '--';
    final total = (trip['total_seats'] as num?)?.toInt() ?? 0;
    final booked = (trip['booked_seats'] as num?)?.toInt() ?? 0;
    final vacant = (trip['vacant_seats'] as num?)?.toInt() ?? (total - booked);
    final safeTotal = total > 0 ? total : 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  route,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  plate,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const Gap(8),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  Flexible(
                    flex: booked.clamp(0, safeTotal),
                    child: Container(color: OwnerButtonColors.seats),
                  ),
                  Flexible(
                    flex: vacant.clamp(0, safeTotal),
                    child: Container(color: Colors.grey.shade200),
                  ),
                ],
              ),
            ),
          ),
          const Gap(6),
          Text(
            '$booked / $total seats',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Staff ─────────────────────────────────────────────
  Widget _buildStaffManagementCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Staff Management',
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
              child: _staffCard(
                'My Drivers',
                'Type D',
                Icons.badge_rounded,
                OwnerButtonColors.drivers,
              ),
            ),
            const Gap(12),
            Expanded(
              child: _staffCard(
                'My Conductors',
                'Type E',
                Icons.group_rounded,
                OwnerButtonColors.conductors,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _staffCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const Gap(10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: AppColors.gray500),
          ),
          const Gap(6),
          Align(
            alignment: Alignment.centerRight,
            child: Icon(Icons.arrow_forward_rounded, size: 16, color: color),
          ),
        ],
      ),
    );
  }

  // ─── Error ─────────────────────────────────────────────
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const Gap(16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.gray600, fontSize: 13),
            ),
            const Gap(20),
            ElevatedButton.icon(
              onPressed: _loadDashboardData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
            const Gap(8),
            TextButton(onPressed: _logout, child: const Text('Back to Login')),
          ],
        ),
      ),
    );
  }
}

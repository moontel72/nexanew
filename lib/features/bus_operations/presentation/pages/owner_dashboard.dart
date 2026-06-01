// Bus Owner Interactive 3D Dashboard (Module 14)
//
// Fixed layout with constrained sidebar (260dp), dynamic parent company
// branding, editable custom display name, and proper token-passing.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/core/services/api_client.dart';
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
  bool _isSidebarOpen = true;
  int _activeBuses = 0;
  double _dailyRevenue = 0.0;
  List<Map<String, dynamic>> _seatManifest = [];
  String _ownerName = 'Owner';
  String _parentCompanyName = '';
  String _customDisplayName = '';
  bool _isLoading = true;
  String? _error;
  String _selectedNav = 'dashboard';

  // Editing state
  final _displayNameController = TextEditingController();
  bool _isEditingName = false;

  @override
  void initState() {
    super.initState();
    _loadCachedIdentity();
    _loadDashboardData();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  /// Read cached identity from login, then fetch fleet data.
  Future<void> _loadCachedIdentity() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _ownerName = prefs.getString('bus_owner_name') ?? 'Owner';
      _parentCompanyName = prefs.getString('bus_owner_company') ?? '';
      _customDisplayName = prefs.getString('bus_owner_display_name') ?? '';
    });
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Ensure token is available before making authenticated calls
      final apiClient = ApiClient();
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      if (token.isNotEmpty) {
        await apiClient.setAuthToken(token);
      }

      final api = ApiService();

      // Fetch fleet data (requires auth)
      final profileRes = await api.get('/super-admin/tenants/fleet-data');
      final fleet = profileRes['data'] as Map<String, dynamic>? ?? {};

      List<Map<String, dynamic>> manifest = [];
      try {
        final shifts = fleet['shift_allocations'] as List<dynamic>? ?? [];
        manifest = shifts.cast<Map<String, dynamic>>();
      } catch (_) {}

      if (!mounted) return;

      setState(() {
        _activeBuses = (fleet['buses'] as List<dynamic>?)?.length ?? 0;
        _dailyRevenue = 0.0;
        _seatManifest = manifest;
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

  void _logout() {
    // Clear token and navigate to login
    ApiClient().clearAuthToken();
    context.go('/bus-owner/login');
  }

  /// Brand name shown in header: custom > parent company > fallback
  String get _brandName {
    if (_customDisplayName.isNotEmpty) return _customDisplayName;
    if (_parentCompanyName.isNotEmpty) return _parentCompanyName;
    return 'NexaTrace';
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
  // SIDEBAR — fixed width 260, deep teal
  // ═══════════════════════════════════════════════════════
  Widget _buildSidebar(bool isWide) {
    return Container(
      width: 260, // FIXED: prevents sidebar from crushing content
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
            Gap(8.h),
            _buildOwnerBadge(),
            Gap(12.h),
            Divider(
              color: Colors.white.withValues(alpha: 0.12),
              height: 1,
              indent: 20,
              endIndent: 20,
            ),
            Gap(12.h),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Column(
                  children: [
                    _sectionLabel('NAVIGATION'),
                    Gap(6.h),
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
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 12.w, 8.h),
      child: Row(
        children: [
          Container(
            width: 34.w,
            height: 34.h,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: const Icon(
              Icons.directions_bus_filled,
              color: Colors.white,
              size: 20,
            ),
          ),
          Gap(10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _brandName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Owner Terminal',
                  style: TextStyle(
                    color: AppColors.adminSidebarTextMuted,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),
          if (!isWide)
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white70),
              onPressed: () => setState(() => _isSidebarOpen = false),
              iconSize: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildOwnerBadge() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14.w),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16.r,
            backgroundColor: AppColors.secondary,
            child: Text(
              _ownerName.characters.first.toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
              ),
            ),
          ),
          Gap(8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _ownerName,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_parentCompanyName.isNotEmpty)
                  Text(
                    'under $_parentCompanyName',
                    style: TextStyle(
                      color: AppColors.adminSidebarTextMuted,
                      fontSize: 10.sp,
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
        padding: EdgeInsets.only(left: 4.w, bottom: 2.h),
        child: Text(
          text,
          style: TextStyle(
            color: AppColors.adminSidebarTextMuted,
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarBottom() {
    return Padding(
      padding: EdgeInsets.all(10.w),
      child: Column(
        children: [
          Divider(color: Colors.white.withValues(alpha: 0.12), height: 1),
          Gap(8.h),
          InkWell(
            onTap: _loadDashboardData,
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              child: Row(
                children: [
                  Icon(Icons.refresh_rounded, size: 18, color: Colors.white60),
                  Gap(8.w),
                  Text(
                    'Refresh Data',
                    style: TextStyle(color: Colors.white60, fontSize: 12.sp),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: _logout,
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              child: Row(
                children: [
                  Icon(Icons.logout_rounded, size: 18, color: Colors.white60),
                  Gap(8.w),
                  Text(
                    'Logout',
                    style: TextStyle(color: Colors.white60, fontSize: 12.sp),
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
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildGreeting(),
                          Gap(20.h),
                          _buildAnalyticsCards(),
                          Gap(24.h),
                          _buildSeatManifestSection(),
                          Gap(24.h),
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
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
          Text(
            'Owner Dashboard',
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
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
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            // Edit brand name button
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
          Gap(8.h),
          TextFormField(
            controller: _displayNameController,
            decoration: InputDecoration(
              hintText: _parentCompanyName.isNotEmpty
                  ? _parentCompanyName
                  : 'Enter your fleet brand name',
              hintStyle: TextStyle(color: AppColors.gray400, fontSize: 13.sp),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 8.h,
              ),
              isDense: true,
              filled: true,
              fillColor: Colors.white,
            ),
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            onFieldSubmitted: (_) => _saveDisplayName(),
          ),
        ] else ...[
          Gap(4.h),
          Text(
            _parentCompanyName.isNotEmpty
                ? 'Fleet under $_parentCompanyName'
                : 'Here\'s your fleet overview for today',
            style: TextStyle(fontSize: 13.sp, color: AppColors.gray500),
          ),
          if (_customDisplayName.isNotEmpty)
            Text(
              'Branding: $_customDisplayName',
              style: TextStyle(
                fontSize: 12.sp,
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
    // TODO: POST /api/v1/bus-fleet/owner/update-display-name
  }

  // ─── Analytics Cards ───────────────────────────────────
  Widget _buildAnalyticsCards() {
    return Row(
      children: [
        Expanded(
          child: _analyticsCard(
            'Active Buses',
            '$_activeBuses',
            'Total owned assets',
            Icons.directions_bus,
            AppColors.primary,
          ),
        ),
        Gap(12.w),
        Expanded(
          child: _analyticsCard(
            'Daily Revenue',
            'Rs. ${_dailyRevenue.toStringAsFixed(0)}',
            'Today\'s earnings',
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
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
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
                width: 36.w,
                height: 36.h,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: accent, size: 20),
              ),
              Icon(Icons.more_horiz, color: AppColors.gray300, size: 18),
            ],
          ),
          Gap(12.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 26.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          Gap(2.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11.sp, color: AppColors.gray400),
          ),
        ],
      ),
    );
  }

  // ─── Seat Manifest ─────────────────────────────────────
  Widget _buildSeatManifestSection() {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Live Seat Manifest',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              _buildSeatLegend(),
            ],
          ),
          Gap(14.h),
          if (_seatManifest.isEmpty)
            _buildEmptyManifest()
          else
            ..._seatManifest.map(_buildTripSeatCard),
        ],
      ),
    );
  }

  Widget _buildSeatLegend() {
    return Row(
      children: [
        _legendDot(OwnerButtonColors.seats, 'Booked'),
        Gap(10.w),
        _legendDot(Colors.grey.shade300, 'Vacant'),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.w,
          height: 8.h,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        Gap(4.w),
        Text(
          label,
          style: TextStyle(fontSize: 10.sp, color: AppColors.gray500),
        ),
      ],
    );
  }

  Widget _buildEmptyManifest() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.event_seat, size: 40, color: AppColors.gray300),
            Gap(8.h),
            Text(
              'No active trips with seat data',
              style: TextStyle(color: AppColors.gray400, fontSize: 13.sp),
            ),
            Text(
              'Seat manifests appear when trips are in progress',
              style: TextStyle(color: AppColors.gray300, fontSize: 11.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripSeatCard(Map<String, dynamic> trip) {
    final routeName = trip['route_name']?.toString() ?? 'Unknown Route';
    final busPlate =
        trip['plate_number']?.toString() ??
        trip['bus_plate']?.toString() ??
        '--';
    final totalSeats = (trip['total_seats'] as num?)?.toInt() ?? 0;
    final bookedSeats = (trip['booked_seats'] as num?)?.toInt() ?? 0;
    final vacantSeats =
        (trip['vacant_seats'] as num?)?.toInt() ?? (totalSeats - bookedSeats);
    final safeTotal = totalSeats > 0 ? totalSeats : 1;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  routeName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  busPlate,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          Gap(8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(5.r),
            child: SizedBox(
              height: 10.h,
              child: Row(
                children: [
                  Flexible(
                    flex: bookedSeats.clamp(0, safeTotal),
                    child: Container(color: OwnerButtonColors.seats),
                  ),
                  Flexible(
                    flex: vacantSeats.clamp(0, safeTotal),
                    child: Container(color: Colors.grey.shade200),
                  ),
                ],
              ),
            ),
          ),
          Gap(6.h),
          Text(
            '$bookedSeats/$totalSeats seats',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Staff Cards ───────────────────────────────────────
  Widget _buildStaffManagementCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Staff Management',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        Gap(12.h),
        Row(
          children: [
            Expanded(
              child: _staffCard(
                'My Drivers',
                'Type D -- View & register',
                Icons.badge_rounded,
                OwnerButtonColors.drivers,
                () {},
              ),
            ),
            Gap(12.w),
            Expanded(
              child: _staffCard(
                'My Conductors',
                'Type E -- View & register',
                Icons.group_rounded,
                OwnerButtonColors.conductors,
                () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _staffCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34.w,
              height: 34.h,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            Gap(10.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11.sp, color: AppColors.gray500),
            ),
            Gap(6.h),
            Align(
              alignment: Alignment.centerRight,
              child: Icon(Icons.arrow_forward_rounded, size: 16, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error),
            Gap(16.h),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.gray600, fontSize: 13.sp),
            ),
            Gap(20.h),
            ElevatedButton.icon(
              onPressed: _loadDashboardData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

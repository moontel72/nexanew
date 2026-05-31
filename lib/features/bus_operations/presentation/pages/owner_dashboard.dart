// Bus Owner Interactive 3D Dashboard (Module 14)
//
// Scrollable dashboard with:
//   • Deep teal sidebar navigation deck (toggle-able on mobile)
//   • Mizaeel 3D arrow buttons with distinct multi-color spectrum
//   • Analytics summary cards (active buses, daily revenue)
//   • Real-time seat manifest matrix showing booked vs vacant seats
//   • Staff management links (drivers & conductors)
//
// Color spectrum (per spec):
//   Timeline:    Rich Violet   (0xFF7C3AED)
//   Drivers:     Neon Magenta  (0xFFDB2777)
//   Conductors:  Crimson Red   (0xFFDC2626)
//   Seats:       Electric Blue (0xFF2563EB)
//   Earnings:    Field Green   (0xFF16A34A)
//   Alerts:      Amber Orange  (0xFFD97706)

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/missile_3d_button.dart';
import 'package:trace_odd/shared/theme/colors.dart';

// ─── Mizaeel Color Spectrum ──────────────────────────────
class OwnerButtonColors {
  static const Color timeline = Color(0xFF7C3AED); // Rich Violet/Purple
  static const Color drivers = Color(0xFFDB2777); // Neon Magenta/Deep Pink
  static const Color conductors = Color(0xFFDC2626); // Crimson Red
  static const Color seats = Color(0xFF2563EB); // Electric Blue
  static const Color earnings = Color(0xFF16A34A); // Field Green
  static const Color alerts = Color(0xFFD97706); // Amber Orange
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
  String? _ownerName;
  String? _companyName;
  bool _isLoading = true;
  String? _error;

  // Selected navigation item (reserved for future sub-page routing)
  // ignore: unused_field
  String _selectedNav = 'dashboard';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = ApiService();

      // Fetch owner profile + dashboard summary
      final profileRes = await api.get('/bus-fleet/owner/profile');
      final profile = profileRes['data'] as Map<String, dynamic>? ?? {};

      // Fetch seat manifest
      List<Map<String, dynamic>> manifest = [];
      try {
        final manifestRes = await api.get('/bus-fleet/owner/seat-manifest');
        final raw = manifestRes['data'];
        if (raw is List) {
          manifest = raw.cast<Map<String, dynamic>>();
        } else if (raw is Map && raw['trips'] is List) {
          manifest = (raw['trips'] as List).cast<Map<String, dynamic>>();
        }
      } catch (_) {
        // Seat manifest may be empty if no active trips
      }

      if (!mounted) return;

      setState(() {
        _ownerName = profile['name']?.toString() ?? 'Bus Owner';
        _companyName =
            profile['company_name']?.toString() ??
            profile['tenant']?.toString();
        _activeBuses =
            (profile['active_buses'] as num?)?.toInt() ??
            (profile['fleet_size'] as num?)?.toInt() ??
            0;
        _dailyRevenue =
            (profile['daily_revenue'] as num?)?.toDouble() ??
            (profile['earnings_today'] as num?)?.toDouble() ??
            0.0;
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
    context.go('/bus-owner/login');
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // ── Sidebar Navigation Deck ──────────────────
          if (_isSidebarOpen || isWide) _buildSidebar(isWide),

          // ── Main Content Area ────────────────────────
          Expanded(child: _buildMainContent(isWide)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // SIDEBAR — Deep teal navigation deck with Mizaeel buttons
  // ═══════════════════════════════════════════════════════
  Widget _buildSidebar(bool isWide) {
    return Container(
      width: isWide ? 290.w : 270.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.adminSidebarBackground, AppColors.primaryDark],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.adminSidebarBackground.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ── Sidebar Header ──────────────────────────
            _buildSidebarHeader(isWide),

            Gap(8.h),

            // ── Owner Identity Badge ────────────────────
            _buildOwnerBadge(),

            Gap(12.h),
            Divider(
              color: Colors.white.withValues(alpha: 0.12),
              height: 1,
              indent: 20,
              endIndent: 20,
            ),
            Gap(12.h),

            // ── Mizaeel Navigation Buttons ──────────────
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                child: Column(
                  children: [
                    _sectionLabel('NAVIGATION'),
                    Gap(6.h),
                    Missile3DButton(
                      label: 'Project / Fleet Timeline',
                      subtitle: 'Activity & routes',
                      icon: Icons.timeline_rounded,
                      color: OwnerButtonColors.timeline,
                      onTap: () => _setNav('timeline'),
                    ),
                    Missile3DButton(
                      label: 'My Drivers Ledger',
                      subtitle: 'Type D personnel',
                      icon: Icons.badge_rounded,
                      color: OwnerButtonColors.drivers,
                      onTap: () => _setNav('drivers'),
                    ),
                    Missile3DButton(
                      label: 'My Conductors Ledger',
                      subtitle: 'Type E personnel',
                      icon: Icons.group_rounded,
                      color: OwnerButtonColors.conductors,
                      onTap: () => _setNav('conductors'),
                    ),
                    Missile3DButton(
                      label: 'Active Bus Seats Tracker',
                      subtitle: 'Live seat manifest',
                      icon: Icons.event_seat_rounded,
                      color: OwnerButtonColors.seats,
                      onTap: () => _setNav('seats'),
                    ),
                    Missile3DButton(
                      label: 'Daily Earnings Matrix',
                      subtitle: 'Revenue dashboard',
                      icon: Icons.account_balance_wallet_rounded,
                      color: OwnerButtonColors.earnings,
                      onTap: () => _setNav('earnings'),
                    ),
                    Missile3DButton(
                      label: 'Alerts & Maintenance',
                      subtitle: 'Issues & repairs',
                      icon: Icons.warning_amber_rounded,
                      color: OwnerButtonColors.alerts,
                      onTap: () => _setNav('alerts'),
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom Actions ──────────────────────────
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                children: [
                  Divider(
                    color: Colors.white.withValues(alpha: 0.12),
                    height: 1,
                  ),
                  Gap(10.h),
                  _sidebarBottomAction(
                    Icons.refresh_rounded,
                    'Refresh Data',
                    _loadDashboardData,
                  ),
                  _sidebarBottomAction(Icons.logout_rounded, 'Logout', _logout),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarHeader(bool isWide) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 16.w, 10.h),
      child: Row(
        children: [
          Container(
            width: 38.w,
            height: 38.h,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: const Icon(
              Icons.directions_bus_filled,
              color: Colors.white,
              size: 22,
            ),
          ),
          Gap(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NexaTrace',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Owner Terminal',
                  style: TextStyle(
                    color: AppColors.adminSidebarTextMuted,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
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
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundColor: AppColors.secondary,
            child: Text(
              (_ownerName ?? 'O').characters.first.toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15.sp,
              ),
            ),
          ),
          Gap(10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _ownerName ?? 'Owner',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
                if (_companyName != null)
                  Text(
                    _companyName!,
                    style: TextStyle(
                      color: AppColors.adminSidebarTextMuted,
                      fontSize: 11.sp,
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
    return Padding(
      padding: EdgeInsets.only(left: 6.w, bottom: 2.h),
      child: Align(
        alignment: Alignment.centerLeft,
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

  Widget _sidebarBottomAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.white60),
            Gap(10.w),
            Text(
              label,
              style: TextStyle(
                color: Colors.white60,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setNav(String nav) {
    setState(() => _selectedNav = nav);
    // Future: switch main content area based on _selectedNav
  }

  // ═══════════════════════════════════════════════════════
  // MAIN CONTENT AREA
  // ═══════════════════════════════════════════════════════
  Widget _buildMainContent(bool isWide) {
    return SafeArea(
      child: Column(
        children: [
          // ── Top Bar ───────────────────────────────────
          _buildTopBar(isWide),

          // ── Scrollable Content ────────────────────────
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
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
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
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
            color: AppColors.gray500,
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
          'Welcome back, ${_ownerName ?? 'Owner'}',
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        Gap(4.h),
        Text(
          'Here\'s your fleet overview for today',
          style: TextStyle(fontSize: 14.sp, color: AppColors.gray500),
        ),
      ],
    );
  }

  // ─── Analytics Summary Cards ───────────────────────────
  Widget _buildAnalyticsCards() {
    return Row(
      children: [
        Expanded(
          child: _analyticsCard(
            'Active Operating Buses',
            '$_activeBuses',
            'Total owned assets',
            Icons.directions_bus,
            AppColors.primary,
          ),
        ),
        Gap(14.w),
        Expanded(
          child: _analyticsCard(
            'Daily Revenue Share',
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
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: accent, size: 22),
              ),
              Icon(Icons.more_horiz, color: AppColors.gray300, size: 20),
            ],
          ),
          Gap(14.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          Gap(4.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          Gap(2.h),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11.sp, color: AppColors.gray400),
          ),
        ],
      ),
    );
  }

  // ─── Seat Manifest Section ─────────────────────────────
  Widget _buildSeatManifestSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              _buildSeatLegend(),
            ],
          ),
          Gap(16.h),
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
        Gap(12.w),
        _legendDot(Colors.grey.shade300, 'Vacant'),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10.w,
          height: 10.h,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        Gap(4.w),
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: AppColors.gray500),
        ),
      ],
    );
  }

  Widget _buildEmptyManifest() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 30.h),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.event_seat, size: 44, color: AppColors.gray300),
            Gap(8.h),
            Text(
              'No active trips with seat data',
              style: TextStyle(color: AppColors.gray400, fontSize: 14.sp),
            ),
            Gap(4.h),
            Text(
              'Seat manifests appear when trips are in progress',
              style: TextStyle(color: AppColors.gray300, fontSize: 12.sp),
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
        '—';
    final totalSeats = (trip['total_seats'] as num?)?.toInt() ?? 0;
    final bookedSeats = (trip['booked_seats'] as num?)?.toInt() ?? 0;
    final vacantSeats =
        (trip['vacant_seats'] as num?)?.toInt() ?? (totalSeats - bookedSeats);
    final seats = trip['seats'] as List<dynamic>?;

    final safeTotal = totalSeats > 0 ? totalSeats : 1;

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trip header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  routeName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  busPlate,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          Gap(10.h),

          // Occupancy bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: SizedBox(
              height: 12.h,
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
          Gap(8.h),

          // Stats row
          Row(
            children: [
              _statChip(
                '${bookedSeats.toString().padLeft(2, '0')} Booked',
                OwnerButtonColors.seats,
              ),
              Gap(10.w),
              _statChip(
                '${vacantSeats.toString().padLeft(2, '0')} Vacant',
                AppColors.gray400,
              ),
              const Spacer(),
              Text(
                '$bookedSeats/$totalSeats',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          // Seat grid (if detailed seat array provided)
          if (seats != null && seats.isNotEmpty) ...[
            Gap(10.h),
            _buildSeatGrid(seats, totalSeats),
          ],
        ],
      ),
    );
  }

  Widget _statChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSeatGrid(List<dynamic> seats, int totalSeats) {
    // Show up to 24 seats inline; scroll beyond that
    final displaySeats = seats.take(24).toList();
    return Wrap(
      spacing: 5.w,
      runSpacing: 5.h,
      children: displaySeats.map((s) {
        final seat = s is Map<String, dynamic> ? s : <String, dynamic>{};
        final isBooked =
            seat['status']?.toString() == 'booked' || seat['booked'] == true;
        final seatNo =
            seat['number']?.toString() ?? seat['seat_no']?.toString() ?? '?';
        return Container(
          width: 30.w,
          height: 28.h,
          decoration: BoxDecoration(
            color: isBooked
                ? OwnerButtonColors.seats.withValues(alpha: 0.15)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(5.r),
            border: Border.all(
              color: isBooked
                  ? OwnerButtonColors.seats.withValues(alpha: 0.4)
                  : Colors.grey.shade300,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            seatNo,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: isBooked ? OwnerButtonColors.seats : AppColors.gray400,
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Staff Management Cards ────────────────────────────
  Widget _buildStaffManagementCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Staff Management',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        Gap(14.h),
        Row(
          children: [
            Expanded(
              child: _staffCard(
                'My Drivers',
                'Type D — View & register',
                Icons.badge_rounded,
                OwnerButtonColors.drivers,
                () => _setNav('drivers'),
              ),
            ),
            Gap(14.w),
            Expanded(
              child: _staffCard(
                'My Conductors',
                'Type E — View & register',
                Icons.group_rounded,
                OwnerButtonColors.conductors,
                () => _setNav('conductors'),
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
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38.w,
              height: 38.h,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            Gap(12.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Gap(4.h),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12.sp, color: AppColors.gray500),
            ),
            Gap(8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.arrow_forward_rounded, size: 18, color: color),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Error View ────────────────────────────────────────
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
              style: TextStyle(color: AppColors.gray600),
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

// Bus Owner Dashboard (Module 14) — Wave 2 Identity Spine
//
// Dark gradient sidebar (Sub-Admin style: #1A3A5C → #0F2B3F)
// 3D pencil navigation buttons
// Live data: fleet layouts, drivers, conductors, seat manifest
// ScrollbarTheme wrappers on all scrollable areas

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/missile_3d_button.dart';
import 'package:trace_odd/shared/theme/colors.dart';

// ─── Button Color Spectrum ────────────────────────────
class OwnerButtonColors {
  static const Color dashboard = Color(0xFF7C3AED);
  static const Color buses = Color(0xFF2563EB);
  static const Color drivers = Color(0xFFDB2777);
  static const Color conductors = Color(0xFFDC2626);
  static const Color seats = Color(0xFF16A34A);
  static const Color earnings = Color(0xFFD97706);
  static const Color alerts = Color(0xFF0891B2);
}

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  // ── State
  String _ownerName = 'Owner';
  String _companyName = '';
  bool _isSidebarOpen = true;
  String _currentPage = 'dashboard';
  bool _isLoading = true;
  String? _error;

  // ── Counts
  int _busCount = 0;
  int _driverCount = 0;
  int _conductorCount = 0;
  int _layoutCount = 0;

  // ── Layout list data
  List<Map<String, dynamic>> _layouts = [];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    if (!mounted) return;
    if (token.isEmpty) {
      context.go('/bus-owner/login');
      return;
    }

    setState(() {
      _ownerName = prefs.getString('bus_owner_name') ?? 'Owner';
      _companyName = prefs.getString('bus_owner_company') ?? '';
    });

    await _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final api = ApiService();

      // Owner profile
      final profileRes = await api.get('/bus-fleet/owner/profile');
      final profile = (profileRes['data'] as Map<String, dynamic>?) ?? {};
      final ownerIdentityId = profile['id'] as String? ?? '';

      // Dashboard stats
      final results = await Future.wait([
        _safeCount(api, '/bus-fleet/layouts'),
        _safeCount(api, '/bus-fleet/drivers/manage'),
        _safeCount(api, '/bus-fleet/conductors'),
      ], eagerError: false);

      // Load layouts list
      List<Map<String, dynamic>> layouts = [];
      try {
        final lr = await api.get('/bus-fleet/layouts');
        final d = lr['data'];
        if (d is List) {
          layouts = List<Map<String, dynamic>>.from(d);
        } else if (d is Map) {
          layouts = List<Map<String, dynamic>>.from(d['data'] ?? []);
        }
      } catch (_) {}

      if (mounted)
        setState(() {
          _busCount = (profile['active_buses'] as int?) ?? layouts.length;
          _layoutCount = results[0];
          _driverCount = results[1];
          _conductorCount = results[2];
          _layouts = layouts;
          _ownerName = (profile['account_name'] as String?) ?? _ownerName;
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

  Future<int> _safeCount(ApiService api, String endpoint) async {
    try {
      final res = await api.get(endpoint, queryParams: {'per_page': '1'});
      if (res == null || res is! Map) return 0;
      final data = res['data'];
      if (data is Map) return (data['total'] as int?) ?? 0;
      if (data is List) return data.length;
      return 0;
    } catch (_) {
      return 0;
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    if (mounted) context.go('/bus-owner/login');
  }

  // ── Build ──────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D1B2A),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: Row(
        children: [
          if (_isSidebarOpen || isWide) _buildSidebar(isWide),
          Expanded(child: _buildMainContent(isWide)),
        ],
      ),
    );
  }

  // ── Sidebar (Sub-Admin dark theme) ─────────────────
  Widget _buildSidebar(bool isWide) => Container(
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
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 10, 8),
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
                const Gap(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _ownerName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_companyName.isNotEmpty)
                        Text(
                          _companyName,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                if (!isWide)
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white70,
                      size: 18,
                    ),
                    onPressed: () => setState(() => _isSidebarOpen = false),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 30,
                      minHeight: 30,
                    ),
                  ),
              ],
            ),
          ),
          const Gap(8),
          // Owner badge
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF00C49F).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF00C49F).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.verified_user,
                  size: 14,
                  color: const Color(0xFF00C49F).withValues(alpha: 0.8),
                ),
                const Gap(6),
                Text(
                  'Fleet Owner',
                  style: TextStyle(
                    color: const Color(0xFF00C49F).withValues(alpha: 0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '$_busCount buses',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const Gap(12),
          const Divider(
            color: Color(0x20FFFFFF),
            height: 1,
            indent: 20,
            endIndent: 20,
          ),
          const Gap(12),

          // Navigation
          Expanded(
            child: ScrollbarTheme(
              data: ScrollbarThemeData(
                thumbVisibility: WidgetStateProperty.all(true),
                trackVisibility: WidgetStateProperty.all(true),
                thickness: WidgetStateProperty.all(8),
                radius: const Radius.circular(4),
                thumbColor: WidgetStateProperty.all(const Color(0xFF00C49F)),
                trackColor: WidgetStateProperty.all(const Color(0x20FFFFFF)),
              ),
              child: Scrollbar(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      _sectionLabel('FLEET'),
                      Missile3DButton(
                        label: 'Dashboard',
                        icon: Icons.dashboard_rounded,
                        color: OwnerButtonColors.dashboard,
                        onTap: () => setState(() => _currentPage = 'dashboard'),
                      ),
                      Missile3DButton(
                        label: 'My Buses ($_busCount)',
                        icon: Icons.directions_bus,
                        color: OwnerButtonColors.buses,
                        onTap: () => setState(() => _currentPage = 'buses'),
                      ),
                      Missile3DButton(
                        label: 'Seat Layouts ($_layoutCount)',
                        icon: Icons.event_seat,
                        color: OwnerButtonColors.seats,
                        onTap: () => setState(() => _currentPage = 'layouts'),
                      ),
                      const Gap(8),
                      _sectionLabel('STAFF'),
                      Missile3DButton(
                        label: 'My Drivers ($_driverCount)',
                        icon: Icons.badge_rounded,
                        color: OwnerButtonColors.drivers,
                        onTap: () => setState(() => _currentPage = 'drivers'),
                      ),
                      Missile3DButton(
                        label: 'My Conductors ($_conductorCount)',
                        icon: Icons.group_rounded,
                        color: OwnerButtonColors.conductors,
                        onTap: () =>
                            setState(() => _currentPage = 'conductors'),
                      ),
                      const Gap(8),
                      _sectionLabel('FINANCE'),
                      Missile3DButton(
                        label: 'Earnings',
                        icon: Icons.account_balance_wallet_rounded,
                        color: OwnerButtonColors.earnings,
                        onTap: () {},
                      ),
                      const Gap(8),
                      _sectionLabel('SYSTEM'),
                      Missile3DButton(
                        label: 'Refresh',
                        icon: Icons.refresh_rounded,
                        color: OwnerButtonColors.alerts,
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
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _sectionLabel(String t) => Padding(
    padding: const EdgeInsets.only(left: 4, top: 4, bottom: 2),
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

  // ── Main Content ──────────────────────────────────
  Widget _buildMainContent(bool isWide) => SafeArea(
    child: Column(
      children: [
        // Top bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF162438),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Row(
            children: [
              if (!_isSidebarOpen)
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white70),
                  onPressed: () => setState(() => _isSidebarOpen = true),
                ),
              Expanded(
                child: Text(
                  _currentPage == 'buses'
                      ? 'My Buses'
                      : _currentPage == 'layouts'
                      ? 'Seat Layouts'
                      : _currentPage == 'drivers'
                      ? 'My Drivers'
                      : _currentPage == 'conductors'
                      ? 'My Conductors'
                      : 'Dashboard',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white60),
                onPressed: _loadAll,
              ),
            ],
          ),
        ),
        // Content area
        Expanded(
          child: _currentPage == 'layouts'
              ? _buildLayoutPage()
              : _currentPage == 'buses'
              ? _buildBusesPage()
              : _currentPage == 'drivers'
              ? _buildDriversPage()
              : _currentPage == 'conductors'
              ? _buildConductorsPage()
              : _buildHomePage(),
        ),
      ],
    ),
  );

  // ── Dashboard Home ────────────────────────────────
  Widget _buildHomePage() => ScrollbarTheme(
    data: ScrollbarThemeData(
      thumbVisibility: WidgetStateProperty.all(true),
      trackVisibility: WidgetStateProperty.all(true),
      thickness: WidgetStateProperty.all(10),
      radius: const Radius.circular(5),
      thumbColor: WidgetStateProperty.all(const Color(0xFF00C49F)),
      trackColor: WidgetStateProperty.all(const Color(0xFF1A2A3A)),
    ),
    child: Scrollbar(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Text(
              'Welcome back, $_ownerName',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Gap(4),
            Text(
              '$_busCount buses • $_driverCount drivers • $_conductorCount conductors',
              style: const TextStyle(color: Color(0xFF8899AA), fontSize: 13),
            ),
            const Gap(24),

            // KPI cards
            Row(
              children: [
                _kpiCard(
                  'Active Buses',
                  '$_busCount',
                  Icons.directions_bus,
                  const Color(0xFF2563EB),
                ),
                const Gap(12),
                _kpiCard(
                  'Seat Layouts',
                  '$_layoutCount',
                  Icons.event_seat,
                  const Color(0xFF16A34A),
                ),
                const Gap(12),
                _kpiCard(
                  'Staff Total',
                  '${_driverCount + _conductorCount}',
                  Icons.people,
                  const Color(0xFF7C3AED),
                ),
              ],
            ),
            const Gap(24),

            // Layout preview
            if (_layouts.isNotEmpty) ...[
              const Text(
                'Recent Layouts',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(12),
              ..._layouts.take(3).map((l) => _layoutCard(l)),
            ],
          ],
        ),
      ),
    ),
  );

  // ── Layout Page ────────────────────────────────────
  Widget _buildLayoutPage() {
    if (_layouts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_seat,
              size: 48,
              color: Colors.white.withValues(alpha: 0.15),
            ),
            const Gap(12),
            Text(
              'No seat layouts yet',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }
    return ScrollbarTheme(
      data: ScrollbarThemeData(
        thumbVisibility: WidgetStateProperty.all(true),
        trackVisibility: WidgetStateProperty.all(true),
        thickness: WidgetStateProperty.all(10),
        radius: const Radius.circular(5),
        thumbColor: WidgetStateProperty.all(const Color(0xFF00C49F)),
        trackColor: WidgetStateProperty.all(const Color(0xFF1A2A3A)),
      ),
      child: Scrollbar(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _layouts.length,
          separatorBuilder: (_, __) => const Gap(8),
          itemBuilder: (_, i) => _layoutCard(_layouts[i]),
        ),
      ),
    );
  }

  Widget _layoutCard(Map<String, dynamic> layout) {
    final vc = layout['vehicle_class'] as String? ?? 'unknown';
    final name = layout['display_name'] as String? ?? 'Untitled';
    final status = layout['layout_status'] as String? ?? 'draft';
    final version = layout['version_number'] as int? ?? 1;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2A3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A3A4A)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.event_seat,
              color: Color(0xFF16A34A),
              size: 20,
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(2),
                Text(
                  '$vc • v$version • $status',
                  style: const TextStyle(
                    color: Color(0xFF667788),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: status == 'published'
                  ? const Color(0xFF16A34A).withValues(alpha: 0.15)
                  : const Color(0xFFD97706).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                color: status == 'published'
                    ? const Color(0xFF4ADE80)
                    : const Color(0xFFFBBF24),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Buses Page ─────────────────────────────────────
  Widget _buildBusesPage() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.directions_bus,
          size: 48,
          color: Colors.white.withValues(alpha: 0.15),
        ),
        const Gap(12),
        Text(
          '$_busCount buses registered',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 15,
          ),
        ),
        const Gap(8),
        Text(
          'Connected to $_companyName',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.25),
            fontSize: 13,
          ),
        ),
      ],
    ),
  );

  // ── Drivers Page ───────────────────────────────────
  Widget _buildDriversPage() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.badge_rounded,
          size: 48,
          color: Colors.white.withValues(alpha: 0.15),
        ),
        const Gap(12),
        Text(
          '$_driverCount drivers assigned',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 15,
          ),
        ),
      ],
    ),
  );

  // ── Conductors Page ────────────────────────────────
  Widget _buildConductorsPage() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.group_rounded,
          size: 48,
          color: Colors.white.withValues(alpha: 0.15),
        ),
        const Gap(12),
        Text(
          '$_conductorCount conductors assigned',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 15,
          ),
        ),
      ],
    ),
  );

  // ── KPI Card ──────────────────────────────────────
  Widget _kpiCard(String label, String value, IconData icon, Color color) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2A3A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF2A3A4A)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 24),
              const Gap(10),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Gap(4),
              Text(
                label,
                style: const TextStyle(color: Color(0xFF667788), fontSize: 12),
              ),
            ],
          ),
        ),
      );
}

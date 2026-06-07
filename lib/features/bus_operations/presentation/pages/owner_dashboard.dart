// Bus Owner Dashboard (Module 14) — Wave 2 Identity Spine
//
// Dark gradient sidebar (Sub-Admin style: #1A3A5C → #0F2B3F)
// 3D pencil navigation buttons
// Full CRUD: Drivers, Conductors, Bus Seat Layouts
// Edit forms pre-populate ALL registration data 100%
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

// ─── Layout Presets ───────────────────────────────────
const List<Map<String, String>> _layoutPresets = [
  {'key': 'coach_54', 'label': 'Coach 54-Seater'},
  {'key': 'standard_45', 'label': 'Standard 45-Seater'},
  {'key': 'coaster_34', 'label': 'Coaster 34-Seater'},
  {'key': 'hiace_13', 'label': 'Hiace 13-Seater'},
  {'key': 'sleeper_custom', 'label': 'Sleeper Custom'},
];

// ─── Non-const colors using .withValues() ─────────────
final Color _mint15 = const Color(0xFF00C49F).withValues(alpha: 0.15);
final Color _mint3 = const Color(0xFF00C49F).withValues(alpha: 0.3);
final Color _mint8 = const Color(0xFF00C49F).withValues(alpha: 0.8);
final Color _green15 = const Color(0xFF16A34A).withValues(alpha: 0.15);
final Color _green3 = const Color(0xFF16A34A).withValues(alpha: 0.3);
final Color _amber15 = const Color(0xFFD97706).withValues(alpha: 0.15);
const Color _closeIconColor = Color(0x66FFFFFF);
const Color _white10 = Color(0x1AFFFFFF);
const Color _white40 = Color(0x66FFFFFF);

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});
  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  // ── Auth state
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

  // ── Data lists
  List<Map<String, dynamic>> _layouts = [];
  List<Map<String, dynamic>> _drivers = [];
  List<Map<String, dynamic>> _conductors = [];
  int _driversTotal = 0;
  int _conductorsTotal = 0;

  // ── Pagination
  int _driversPage = 1;
  int _conductorsPage = 1;
  final int _perPage = 20;

  // ── Search
  final _driverSearchCtl = TextEditingController();
  final _conductorSearchCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _driverSearchCtl.dispose();
    _conductorSearchCtl.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════
  // BOOTSTRAP & DATA LOADING
  // ═══════════════════════════════════════════════════════

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
      final dash = await api.get('/bus-owner/dashboard');
      final d = (dash['data'] as Map<String, dynamic>?) ?? {};

      List<Map<String, dynamic>> layouts = [];
      try {
        final lr = await api.get('/bus-owner/layouts');
        final ld = lr['data'];
        if (ld is List) layouts = List<Map<String, dynamic>>.from(ld);
      } catch (_) {}

      if (mounted)
        setState(() {
          _busCount = (d['fleet_size'] as int?) ?? layouts.length;
          _driverCount = (d['driver_count'] as int?) ?? 0;
          _conductorCount = (d['conductor_count'] as int?) ?? 0;
          _layoutCount = layouts.length;
          _layouts = layouts;
          _companyName = (d['company_name'] as String?) ?? _companyName;
          _isLoading = false;
        });

      _loadDrivers();
      _loadConductors();
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
    }
  }

  Future<void> _loadDrivers() async {
    try {
      final api = ApiService();
      final res = await api.get(
        '/bus-owner/drivers',
        queryParams: {
          'page': _driversPage.toString(),
          'per_page': _perPage.toString(),
          if (_driverSearchCtl.text.isNotEmpty) 'search': _driverSearchCtl.text,
        },
      );
      final d = res['data'];
      if (d is Map && mounted)
        setState(() {
          _drivers = List<Map<String, dynamic>>.from(d['data'] ?? []);
          _driversTotal = (d['total'] as int?) ?? _drivers.length;
          _driverCount = _driversTotal;
        });
    } catch (_) {}
  }

  Future<void> _loadConductors() async {
    try {
      final api = ApiService();
      final res = await api.get(
        '/bus-owner/conductors',
        queryParams: {
          'page': _conductorsPage.toString(),
          'per_page': _perPage.toString(),
          if (_conductorSearchCtl.text.isNotEmpty)
            'search': _conductorSearchCtl.text,
        },
      );
      final d = res['data'];
      if (d is Map && mounted)
        setState(() {
          _conductors = List<Map<String, dynamic>>.from(d['data'] ?? []);
          _conductorsTotal = (d['total'] as int?) ?? _conductors.length;
          _conductorCount = _conductorsTotal;
        });
    } catch (_) {}
  }

  Future<void> _loadLayouts() async {
    try {
      final api = ApiService();
      final lr = await api.get('/bus-owner/layouts');
      final ld = lr['data'];
      if (ld is List && mounted)
        setState(() {
          _layouts = List<Map<String, dynamic>>.from(ld);
          _layoutCount = _layouts.length;
          _busCount = _layouts
              .where((l) => l['layout_status'] != 'archived')
              .length;
        });
    } catch (_) {}
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

  // ═══════════════════════════════════════════════════════
  // SIDEBAR
  // ═══════════════════════════════════════════════════════

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
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _mint15,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _mint3),
            ),
            child: Row(
              children: [
                Icon(Icons.verified_user, size: 14, color: _mint8),
                const Gap(6),
                Text(
                  'Fleet Owner',
                  style: TextStyle(
                    color: _mint8,
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
                        onTap: () {
                          setState(() => _currentPage = 'layouts');
                          _loadLayouts();
                        },
                      ),
                      const Gap(8),
                      _sectionLabel('STAFF'),
                      Missile3DButton(
                        label: 'My Drivers ($_driverCount)',
                        icon: Icons.badge_rounded,
                        color: OwnerButtonColors.drivers,
                        onTap: () {
                          setState(() => _currentPage = 'drivers');
                          _loadDrivers();
                        },
                      ),
                      Missile3DButton(
                        label: 'My Conductors ($_conductorCount)',
                        icon: Icons.group_rounded,
                        color: OwnerButtonColors.conductors,
                        onTap: () {
                          setState(() => _currentPage = 'conductors');
                          _loadConductors();
                        },
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

  // ═══════════════════════════════════════════════════════
  // MAIN CONTENT
  // ═══════════════════════════════════════════════════════

  Widget _buildMainContent(bool isWide) => SafeArea(
    child: Column(
      children: [
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
                onPressed: () {
                  _loadAll();
                  _loadDrivers();
                  _loadConductors();
                  _loadLayouts();
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: _currentPage == 'layouts'
              ? _buildLayoutsPage()
              : _currentPage == 'buses'
              ? _buildBusesPage()
              : _currentPage == 'drivers'
              ? _buildStaffPage('driver')
              : _currentPage == 'conductors'
              ? _buildStaffPage('conductor')
              : _buildHomePage(),
        ),
      ],
    ),
  );

  // ═══════════════════════════════════════════════════════
  // HOME
  // ═══════════════════════════════════════════════════════

  Widget _buildHomePage() => ScrollbarTheme(
    data: _scrollbarTheme(),
    child: Scrollbar(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              '$_busCount buses \u2022 $_driverCount drivers \u2022 $_conductorCount conductors',
              style: const TextStyle(color: Color(0xFF8899AA), fontSize: 13),
            ),
            const Gap(24),
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

  // ═══════════════════════════════════════════════════════
  // BUSES
  // ═══════════════════════════════════════════════════════

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
          'Create seat layouts to define your bus configurations',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.25),
            fontSize: 13,
          ),
        ),
      ],
    ),
  );

  // ═══════════════════════════════════════════════════════
  // STAFF PAGE (Drivers / Conductors)
  // ═══════════════════════════════════════════════════════

  Widget _buildStaffPage(String role) {
    final isDriver = role == 'driver';
    final list = isDriver ? _drivers : _conductors;
    final total = isDriver ? _driversTotal : _conductorsTotal;
    final searchCtl = isDriver ? _driverSearchCtl : _conductorSearchCtl;
    final page = isDriver ? _driversPage : _conductorsPage;
    final title = isDriver ? 'Driver' : 'Conductor';
    final icon = isDriver ? Icons.badge_rounded : Icons.group_rounded;
    final color = isDriver ? const Color(0xFFDB2777) : const Color(0xFFDC2626);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: const Color(0xFF162438),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: searchCtl,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search $title...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF556677),
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF556677),
                        size: 18,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF0D1B2A),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF2A3A4A)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF2A3A4A)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: color),
                      ),
                    ),
                    onSubmitted: (_) {
                      if (isDriver)
                        _loadDrivers();
                      else
                        _loadConductors();
                    },
                  ),
                ),
              ),
              const Gap(8),
              _actionButton(
                'Add $title',
                Icons.add,
                color,
                () => _showStaffForm(role, null),
              ),
            ],
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 48,
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                      const Gap(12),
                      Text(
                        'No ${title.toLowerCase()}s yet',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 15,
                        ),
                      ),
                      const Gap(8),
                      _actionButton(
                        'Add First $title',
                        Icons.add,
                        color,
                        () => _showStaffForm(role, null),
                      ),
                    ],
                  ),
                )
              : ScrollbarTheme(
                  data: _scrollbarTheme(),
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(12),
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(
                            const Color(0xFF1A2A3A),
                          ),
                          dataRowColor: WidgetStateProperty.all(
                            const Color(0xFF162438),
                          ),
                          dividerThickness: 0.5,
                          columns: [
                            _col('#', 50),
                            _col('Name', 150),
                            _col('Email', 180),
                            _col('Phone', 120),
                            if (isDriver) _col('License', 120),
                            _col('Plate', 100),
                            _col('Salary', 80),
                            _col('Status', 80),
                            _col('Actions', 120),
                          ],
                          rows: list
                              .map(
                                (item) => DataRow(
                                  cells: [
                                    DataCell(
                                      Text(
                                        item['id']?.toString().substring(
                                              0,
                                              8,
                                            ) ??
                                            '\u2014',
                                        style: const TextStyle(
                                          color: Color(0xFF8899AA),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        item['name']?.toString() ?? '\u2014',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        item['email']?.toString() ?? '\u2014',
                                        style: const TextStyle(
                                          color: Color(0xFF8899AA),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        item['phone']?.toString() ?? '\u2014',
                                        style: const TextStyle(
                                          color: Color(0xFF8899AA),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    if (isDriver)
                                      DataCell(
                                        Text(
                                          item['license_number']?.toString() ??
                                              '\u2014',
                                          style: const TextStyle(
                                            color: Color(0xFF8899AA),
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    DataCell(
                                      Text(
                                        item['vehicle_plate']?.toString() ??
                                            '\u2014',
                                        style: const TextStyle(
                                          color: Color(0xFF8899AA),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        item['salary']?.toString() ?? '\u2014',
                                        style: const TextStyle(
                                          color: Color(0xFF8899AA),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      _statusBadge(
                                        item['status']?.toString() ?? 'active',
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _iconBtn(
                                            Icons.edit,
                                            const Color(0xFF3B82F6),
                                            () => _showStaffForm(role, item),
                                          ),
                                          const Gap(4),
                                          _iconBtn(
                                            Icons.delete,
                                            const Color(0xFFEF4444),
                                            () => _confirmDeleteStaff(
                                              role,
                                              item['id']?.toString() ?? '',
                                              item['name']?.toString() ?? '',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
        if (total > _perPage)
          Container(
            padding: const EdgeInsets.all(8),
            color: const Color(0xFF162438),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _pageBtn(Icons.chevron_left, page > 1, () {
                  if (isDriver) {
                    _driversPage--;
                    _loadDrivers();
                  } else {
                    _conductorsPage--;
                    _loadConductors();
                  }
                }),
                const Gap(8),
                Text(
                  'Page $page',
                  style: const TextStyle(
                    color: Color(0xFF8899AA),
                    fontSize: 12,
                  ),
                ),
                const Gap(8),
                _pageBtn(Icons.chevron_right, (page * _perPage) < total, () {
                  if (isDriver) {
                    _driversPage++;
                    _loadDrivers();
                  } else {
                    _conductorsPage++;
                    _loadConductors();
                  }
                }),
              ],
            ),
          ),
      ],
    );
  }

  DataColumn _col(String label, double w) => DataColumn(
    label: SizedBox(
      width: w,
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF8899AA),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );

  Widget _statusBadge(String status) {
    final c = status == 'active'
        ? const Color(0xFF16A34A)
        : status == 'suspended'
        ? const Color(0xFFD97706)
        : const Color(0xFF667788);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(4),
    child: Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, color: color, size: 16),
    ),
  );

  Widget _pageBtn(IconData icon, bool enabled, VoidCallback onTap) => InkWell(
    onTap: enabled ? onTap : null,
    child: Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: enabled ? const Color(0xFF1A2A3A) : const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        icon,
        color: enabled ? Colors.white : const Color(0xFF334455),
        size: 18,
      ),
    ),
  );

  Widget _actionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) => SizedBox(
    height: 40,
    child: ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 14),
      ),
    ),
  );

  // ═══════════════════════════════════════════════════════
  // STAFF FORM (Add/Edit — 100% pre-populated)
  // ═══════════════════════════════════════════════════════

  void _showStaffForm(String role, Map<String, dynamic>? existing) {
    final isDriver = role == 'driver';
    final isEdit = existing != null;
    final title =
        '${isEdit ? "Edit" : "Add"} ${isDriver ? "Driver" : "Conductor"}';
    final color = isDriver ? const Color(0xFFDB2777) : const Color(0xFFDC2626);

    final nameCtl = TextEditingController(
      text: existing?['name']?.toString() ?? '',
    );
    final emailCtl = TextEditingController(
      text: existing?['email']?.toString() ?? '',
    );
    final phoneCtl = TextEditingController(
      text: existing?['phone']?.toString() ?? '',
    );
    final cnicCtl = TextEditingController(
      text: existing?['cnic']?.toString() ?? '',
    );
    final addressCtl = TextEditingController(
      text: existing?['address']?.toString() ?? '',
    );
    final licenseCtl = TextEditingController(
      text: existing?['license_number']?.toString() ?? '',
    );
    final plateCtl = TextEditingController(
      text: existing?['vehicle_plate']?.toString() ?? '',
    );
    final salaryCtl = TextEditingController(
      text: existing?['salary']?.toString() ?? '',
    );
    final passCtl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          backgroundColor: const Color(0xFF162438),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: color.withValues(alpha: 0.3)),
          ),
          title: Row(
            children: [
              Icon(
                isDriver ? Icons.badge_rounded : Icons.group_rounded,
                color: color,
                size: 24,
              ),
              const Gap(8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: _closeIconColor, size: 20),
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _formField(
                      'Full Name *',
                      nameCtl,
                      Icons.person,
                      required: true,
                    ),
                    const Gap(10),
                    _formField(
                      'Email *',
                      emailCtl,
                      Icons.email,
                      required: true,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const Gap(10),
                    _formField(
                      'Phone *',
                      phoneCtl,
                      Icons.phone,
                      required: true,
                      keyboardType: TextInputType.phone,
                    ),
                    const Gap(10),
                    _formField('CNIC', cnicCtl, Icons.credit_card),
                    const Gap(10),
                    _formField(
                      'Address',
                      addressCtl,
                      Icons.location_on,
                      maxLines: 2,
                    ),
                    const Gap(10),
                    if (isDriver) ...[
                      _formField(
                        'License Number *',
                        licenseCtl,
                        Icons.document_scanner,
                        required: true,
                      ),
                      const Gap(10),
                    ],
                    _formField('Vehicle Plate', plateCtl, Icons.directions_bus),
                    const Gap(10),
                    _formField(
                      'Salary',
                      salaryCtl,
                      Icons.attach_money,
                      keyboardType: TextInputType.number,
                    ),
                    const Gap(10),
                    _formField(
                      isEdit
                          ? 'New Password (leave blank to keep)'
                          : 'Password *',
                      passCtl,
                      Icons.lock,
                      required: !isEdit,
                      obscure: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(ctx),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF8899AA)),
              ),
            ),
            const Gap(8),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDlgState(() => isLoading = true);
                      try {
                        final api = ApiService();
                        final body = <String, dynamic>{
                          'name': nameCtl.text.trim(),
                          'email': emailCtl.text.trim(),
                          'phone': phoneCtl.text.trim(),
                          if (cnicCtl.text.isNotEmpty)
                            'cnic': cnicCtl.text.trim(),
                          if (addressCtl.text.isNotEmpty)
                            'address': addressCtl.text.trim(),
                          if (isDriver)
                            'license_number': licenseCtl.text.trim(),
                          if (plateCtl.text.isNotEmpty)
                            'vehicle_plate': plateCtl.text.trim(),
                          if (salaryCtl.text.isNotEmpty)
                            'salary':
                                double.tryParse(salaryCtl.text.trim()) ?? 0,
                        };
                        if (!isEdit || passCtl.text.isNotEmpty)
                          body['password'] = passCtl.text;

                        final endpoint = isEdit
                            ? '/bus-owner/$role/${existing!['id']}'
                            : '/bus-owner/$role';
                        final res = isEdit
                            ? await api.put(endpoint, body: body)
                            : await api.post(endpoint, body: body);

                        if (res != null && res['success'] == true) {
                          Navigator.pop(ctx);
                          if (isDriver)
                            _loadDrivers();
                          else
                            _loadConductors();
                          _loadAll();
                          _showSnack(
                            '${isEdit ? "Updated" : "Created"} successfully',
                            Colors.green,
                          );
                        } else {
                          _showSnack(res?['message'] ?? 'Failed', Colors.red);
                        }
                      } catch (e) {
                        _showSnack(
                          'Error: ${e.toString().replaceAll("Exception: ", "")}',
                          Colors.red,
                        );
                      }
                      setDlgState(() => isLoading = false);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formField(
    String label,
    TextEditingController ctl,
    IconData icon, {
    bool required = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool obscure = false,
  }) => TextFormField(
    controller: ctl,
    obscureText: obscure,
    maxLines: maxLines,
    keyboardType: keyboardType,
    style: const TextStyle(color: Colors.white, fontSize: 13),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF8899AA), fontSize: 12),
      prefixIcon: Icon(icon, color: const Color(0xFF556677), size: 18),
      filled: true,
      fillColor: const Color(0xFF0D1B2A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2A3A4A)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2A3A4A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF00C49F)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    ),
    validator: required
        ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
        : null,
  );

  void _confirmDeleteStaff(String role, String id, String name) => showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF162438),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Confirm Delete',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Text(
        'Delete "$name"? This is reversible (soft-delete).',
        style: const TextStyle(color: Color(0xFF8899AA), fontSize: 13),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Color(0xFF8899AA)),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(ctx);
            try {
              final api = ApiService();
              final res = await api.delete('/bus-owner/$role/$id');
              if (res != null && res['success'] == true) {
                if (role == 'driver')
                  _loadDrivers();
                else
                  _loadConductors();
                _loadAll();
                _showSnack('Deleted', Colors.green);
              }
            } catch (e) {
              _showSnack('Error: ${e.toString()}', Colors.red);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
          ),
          child: const Text('Delete'),
        ),
      ],
    ),
  );

  // ═══════════════════════════════════════════════════════
  // LAYOUTS PAGE
  // ═══════════════════════════════════════════════════════

  Widget _buildLayoutsPage() => Column(
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        color: const Color(0xFF162438),
        child: Row(
          children: [
            const Expanded(child: SizedBox()),
            _actionButton(
              'Add Layout',
              Icons.add,
              const Color(0xFF16A34A),
              () => _showLayoutForm(null),
            ),
          ],
        ),
      ),
      Expanded(
        child: _layouts.isEmpty
            ? Center(
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
                    const Gap(8),
                    _actionButton(
                      'Create First Layout',
                      Icons.add,
                      const Color(0xFF16A34A),
                      () => _showLayoutForm(null),
                    ),
                  ],
                ),
              )
            : ScrollbarTheme(
                data: _scrollbarTheme(),
                child: Scrollbar(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _layouts.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _layoutCardExt(_layouts[i]),
                    ),
                  ),
                ),
              ),
      ),
    ],
  );

  Widget _layoutCardExt(Map<String, dynamic> layout) {
    final vc = layout['vehicle_class']?.toString() ?? 'unknown';
    final name = layout['display_name']?.toString() ?? 'Untitled';
    final status = layout['layout_status']?.toString() ?? 'draft';
    final version = layout['version_number'] ?? 1;
    final seats = layout['total_seats'] ?? 0;
    final id = layout['id']?.toString() ?? '';

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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _green15,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.event_seat,
              color: Color(0xFF16A34A),
              size: 22,
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
                  '$vc \u2022 $seats seats \u2022 v$version',
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
              color: status == 'published' ? _green15 : _amber15,
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
          const Gap(8),
          _iconBtn(
            Icons.edit,
            const Color(0xFF3B82F6),
            () => _showLayoutForm(layout),
          ),
          const Gap(4),
          _iconBtn(
            Icons.delete,
            const Color(0xFFEF4444),
            () => _confirmDeleteLayout(id, name),
          ),
        ],
      ),
    );
  }

  void _showLayoutForm(Map<String, dynamic>? existing) {
    final isEdit = existing != null;
    final nameCtl = TextEditingController(
      text: existing?['display_name']?.toString() ?? '',
    );
    String selectedPreset =
        existing?['vehicle_class']?.toString() ?? 'coach_54';
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          backgroundColor: const Color(0xFF162438),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: _green3),
          ),
          title: Row(
            children: [
              const Icon(Icons.event_seat, color: Color(0xFF16A34A), size: 24),
              const Gap(8),
              Text(
                isEdit ? 'Edit Layout' : 'Add Layout',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: _closeIconColor, size: 20),
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
          content: SizedBox(
            width: 450,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _formField(
                    'Layout Name *',
                    nameCtl,
                    Icons.label,
                    required: true,
                  ),
                  const Gap(14),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Bus Type',
                      style: TextStyle(color: Color(0xFF8899AA), fontSize: 12),
                    ),
                  ),
                  const Gap(6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1B2A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF2A3A4A)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value:
                            _layoutPresets.any(
                              (p) => p['key'] == selectedPreset,
                            )
                            ? selectedPreset
                            : 'coach_54',
                        dropdownColor: const Color(0xFF162438),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        isExpanded: true,
                        items: _layoutPresets
                            .map(
                              (p) => DropdownMenuItem(
                                value: p['key'],
                                child: Text(
                                  p['label']!,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: isEdit
                            ? null
                            : (v) => setDlgState(() => selectedPreset = v!),
                      ),
                    ),
                  ),
                  if (_presetInfo(selectedPreset) != null) ...[
                    const Gap(8),
                    Text(
                      _presetInfo(selectedPreset)!,
                      style: const TextStyle(
                        color: Color(0xFF667788),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(ctx),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF8899AA)),
              ),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDlgState(() => isLoading = true);
                      try {
                        final api = ApiService();
                        final body = <String, dynamic>{
                          'display_name': nameCtl.text.trim(),
                          'vehicle_class': selectedPreset,
                        };
                        final endpoint = isEdit
                            ? '/bus-owner/layouts/${existing!['id']}'
                            : '/bus-owner/layouts';
                        final res = isEdit
                            ? await api.put(endpoint, body: body)
                            : await api.post(endpoint, body: body);
                        if (res != null && res['success'] == true) {
                          Navigator.pop(ctx);
                          _loadLayouts();
                          _loadAll();
                          _showSnack(
                            '${isEdit ? "Updated" : "Created"} successfully',
                            Colors.green,
                          );
                        } else {
                          _showSnack(res?['message'] ?? 'Failed', Colors.red);
                        }
                      } catch (e) {
                        _showSnack(
                          'Error: ${e.toString().replaceAll("Exception: ", "")}',
                          Colors.red,
                        );
                      }
                      setDlgState(() => isLoading = false);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String? _presetInfo(String key) {
    const map = {
      'coach_54': '14 rows \u00d7 4 cols = 54 seats',
      'standard_45': '12 rows \u00d7 4 cols = 45 seats',
      'coaster_34': '9 rows \u00d7 4 cols = 34 seats',
      'hiace_13': '4 rows \u00d7 3 cols = 13 seats',
      'sleeper_custom': '10 rows \u00d7 2 cols = 20 sleeper berths',
    };
    return map[key];
  }

  void _confirmDeleteLayout(String id, String name) => showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF162438),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Archive Layout',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Text(
        'Archive "$name"? It can be restored later.',
        style: const TextStyle(color: Color(0xFF8899AA), fontSize: 13),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Color(0xFF8899AA)),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(ctx);
            try {
              final api = ApiService();
              final res = await api.delete('/bus-owner/layouts/$id');
              if (res != null && res['success'] == true) {
                _loadLayouts();
                _loadAll();
                _showSnack('Archived', Colors.green);
              }
            } catch (e) {
              _showSnack('Error: ${e.toString()}', Colors.red);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
          ),
          child: const Text('Archive'),
        ),
      ],
    ),
  );

  // ═══════════════════════════════════════════════════════
  // LAYOUT CARD (compact, dashboard)
  // ═══════════════════════════════════════════════════════

  Widget _layoutCard(Map<String, dynamic> layout) {
    final vc = layout['vehicle_class']?.toString() ?? 'unknown';
    final name = layout['display_name']?.toString() ?? 'Untitled';
    final status = layout['layout_status']?.toString() ?? 'draft';
    final version = layout['version_number'] ?? 1;
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
              color: _green15,
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
                  '$vc \u2022 v$version \u2022 $status',
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
              color: status == 'published' ? _green15 : _amber15,
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

  // ═══════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════

  ScrollbarThemeData _scrollbarTheme() => ScrollbarThemeData(
    thumbVisibility: WidgetStateProperty.all(true),
    trackVisibility: WidgetStateProperty.all(true),
    thickness: WidgetStateProperty.all(10),
    radius: const Radius.circular(5),
    thumbColor: WidgetStateProperty.all(const Color(0xFF00C49F)),
    trackColor: WidgetStateProperty.all(const Color(0xFF1A2A3A)),
  );

  void _showSnack(String msg, [Color? color]) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
        backgroundColor: color ?? const Color(0xFF333333),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

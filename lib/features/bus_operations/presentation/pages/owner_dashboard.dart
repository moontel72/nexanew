// Bus Owner Dashboard — cloned from Bus Fleet Dashboard (Module 13/14)
// Card-based drivers & conductors (matching FleetDriversScreen / FleetConductorsScreen)
// Visual grid canvas for seat layout designer
// Dark sidebar with 3D pencil buttons

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/missile_3d_button.dart';
import 'package:trace_odd/shared/theme/colors.dart';

class OwnerButtonColors {
  static const Color dashboard = Color(0xFF7C3AED);
  static const Color buses = Color(0xFF2563EB);
  static const Color drivers = Color(0xFFDB2777);
  static const Color conductors = Color(0xFFDC2626);
  static const Color seats = Color(0xFF16A34A);
  static const Color alerts = Color(0xFF0891B2);
}

// Layout presets
const _presets = [
  {
    'key': 'coach_54',
    'label': '54-Seat Coach',
    'rows': 14,
    'leftCols': 2,
    'rightCols': 2,
  },
  {
    'key': 'standard_45',
    'label': '45-Seat Standard',
    'rows': 12,
    'leftCols': 2,
    'rightCols': 2,
  },
  {
    'key': 'coaster_34',
    'label': '34-Seat Coaster',
    'rows': 9,
    'leftCols': 2,
    'rightCols': 2,
  },
  {
    'key': 'hiace_13',
    'label': '13-Seat HiAce',
    'rows': 4,
    'leftCols': 2,
    'rightCols': 2,
  },
  {
    'key': 'sleeper_custom',
    'label': 'Sleeper Custom',
    'rows': 10,
    'leftCols': 1,
    'rightCols': 1,
  },
];

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});
  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  String _ownerName = 'Owner';
  String _currentPage = 'dashboard';
  bool _sidebarOpen = true;
  bool _isLoading = true;

  int _driverCount = 0, _conductorCount = 0, _layoutCount = 0;

  // Drivers
  List<Map<String, dynamic>> _drivers = [];
  bool _driversLoading = true;
  // Conductors
  List<Map<String, dynamic>> _conductors = [];
  bool _conductorsLoading = true;
  // Layouts
  List<Map<String, dynamic>> _layouts = [];
  bool _layoutsLoading = true;

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
    _ownerName = prefs.getString('bus_owner_name') ?? 'Owner';
    setState(() => _isLoading = false);
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    if (mounted) context.go('/bus-owner/login');
  }

  // ═══ BUILD ═══
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: Row(
        children: [
          if (_sidebarOpen || isWide) _sidebar(isWide),
          Expanded(child: _content(isWide)),
        ],
      ),
    );
  }

  // ═══ SIDEBAR ═══
  Widget _sidebar(bool isWide) => Container(
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
                  child: Text(
                    _ownerName,
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
          const Gap(12),
          const Divider(color: Color(0x20FFFFFF), indent: 20, endIndent: 20),
          const Gap(12),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  _sec('FLEET'),
                  Missile3DButton(
                    label: 'Dashboard',
                    icon: Icons.dashboard_rounded,
                    color: OwnerButtonColors.dashboard,
                    onTap: () => setState(() => _currentPage = 'dashboard'),
                  ),
                  Missile3DButton(
                    label: 'Seat Layouts',
                    icon: Icons.event_seat,
                    color: OwnerButtonColors.seats,
                    onTap: () => setState(() {
                      _currentPage = 'layouts';
                      if (_layouts.isEmpty) _loadLayouts();
                    }),
                  ),
                  const Gap(8),
                  _sec('STAFF'),
                  Missile3DButton(
                    label: 'Drivers',
                    icon: Icons.badge_rounded,
                    color: OwnerButtonColors.drivers,
                    onTap: () => setState(() {
                      _currentPage = 'drivers';
                      if (_drivers.isEmpty) _loadDrivers();
                    }),
                  ),
                  Missile3DButton(
                    label: 'Conductors',
                    icon: Icons.group_rounded,
                    color: OwnerButtonColors.conductors,
                    onTap: () => setState(() {
                      _currentPage = 'conductors';
                      if (_conductors.isEmpty) _loadConductors();
                    }),
                  ),
                  const Gap(8),
                  _sec('SYSTEM'),
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
        ],
      ),
    ),
  );

  Widget _sec(String t) => Padding(
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

  // ═══ MAIN CONTENT ═══
  Widget _content(bool isWide) => SafeArea(
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
              if (!_sidebarOpen)
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white70),
                  onPressed: () => setState(() => _sidebarOpen = true),
                ),
              Expanded(
                child: Text(
                  _pageTitle,
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
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: _currentPage == 'drivers'
              ? _driversPage()
              : _currentPage == 'conductors'
              ? _conductorsPage()
              : _currentPage == 'layouts'
              ? _layoutsPage()
              : _homePage(),
        ),
      ],
    ),
  );

  String get _pageTitle => _currentPage == 'drivers'
      ? 'Bus Drivers'
      : _currentPage == 'conductors'
      ? 'Bus Conductors'
      : _currentPage == 'layouts'
      ? 'Seat Layouts'
      : 'Dashboard';

  Future<void> _loadAll() {
    _loadDrivers();
    _loadConductors();
    _loadLayouts();
    return Future.value();
  }

  // ═══ HOME ═══
  Widget _homePage() {
    _loadCounts();
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        Text(
          'Welcome, $_ownerName',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Gap(4),
        Text(
          '$_driverCount drivers \u2022 $_conductorCount conductors \u2022 $_layoutCount layouts',
          style: const TextStyle(color: Color(0xFF8899AA), fontSize: 13),
        ),
        const Gap(24),
        Row(
          children: [
            _kpi(
              'Drivers',
              '$_driverCount',
              Icons.badge,
              OwnerButtonColors.drivers,
            ),
            SizedBox(width: 12.w),
            _kpi(
              'Conductors',
              '$_conductorCount',
              Icons.group,
              OwnerButtonColors.conductors,
            ),
            SizedBox(width: 12.w),
            _kpi(
              'Layouts',
              '$_layoutCount',
              Icons.event_seat,
              OwnerButtonColors.seats,
            ),
          ],
        ),
        const Gap(24),
        ElevatedButton.icon(
          onPressed: () => setState(() {
            _currentPage = 'layouts';
            _loadLayouts();
          }),
          icon: const Icon(Icons.add),
          label: const Text('Create Seat Layout'),
          style: ElevatedButton.styleFrom(
            backgroundColor: OwnerButtonColors.seats,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          ),
        ),
      ],
    );
  }

  Widget _kpi(String label, String value, IconData icon, Color color) =>
      Expanded(
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2A3A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF2A3A4A)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 24),
              Gap(10.h),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Gap(4.h),
              Text(
                label,
                style: const TextStyle(color: Color(0xFF667788), fontSize: 12),
              ),
            ],
          ),
        ),
      );

  void _loadCounts() {
    _loadDrivers();
    _loadConductors();
    _loadLayouts();
  }

  // ═══════════════════════════════════════════════════════
  // DRIVERS (cloned from FleetDriversScreen)
  // ═══════════════════════════════════════════════════════

  Future<void> _loadDrivers() async {
    setState(() => _driversLoading = true);
    try {
      final res = await ApiService().get('/bus-owner/drivers');
      final d = res['data'] as Map<String, dynamic>?;
      if (mounted)
        setState(() {
          _drivers = List<Map<String, dynamic>>.from(d?['data'] ?? []);
          _driverCount = d?['total'] ?? _drivers.length;
          _driversLoading = false;
        });
    } catch (_) {
      if (mounted) setState(() => _driversLoading = false);
    }
  }

  Future<void> _showAddDriver() async {
    final name = TextEditingController(), phone = TextEditingController();
    final license = TextEditingController(), pass = TextEditingController();
    final cnic = TextEditingController(), addr = TextEditingController();
    final plate = TextEditingController(), salary = TextEditingController();
    final email = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Bus Driver'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _tf(name, 'Full Name *'),
              SizedBox(height: 10.h),
              _tf(phone, 'Phone *', phone: true),
              SizedBox(height: 10.h),
              _tf(license, 'License Number *'),
              SizedBox(height: 10.h),
              _tf(pass, 'Password *', obscure: true),
              SizedBox(height: 10.h),
              _tf(email, 'Email', email: true),
              SizedBox(height: 10.h),
              _tf(cnic, 'CNIC'),
              SizedBox(height: 10.h),
              _tf(addr, 'Address', maxLines: 2),
              SizedBox(height: 10.h),
              _tf(plate, 'Vehicle Plate'),
              SizedBox(height: 10.h),
              _tf(salary, 'Salary', number: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ApiService().post(
        '/bus-owner/drivers',
        data: {
          'name': name.text.trim(),
          'phone': phone.text.trim(),
          'license_number': license.text.trim(),
          'password': pass.text,
          if (email.text.isNotEmpty) 'email': email.text.trim(),
          if (cnic.text.isNotEmpty) 'cnic': cnic.text.trim(),
          if (addr.text.isNotEmpty) 'address': addr.text.trim(),
          if (plate.text.isNotEmpty) 'vehicle_plate': plate.text.trim(),
          if (salary.text.isNotEmpty)
            'salary': double.tryParse(salary.text) ?? 0,
        },
      );
      _loadDrivers();
      _snack('Driver added', AppColors.success);
    } catch (e) {
      _snack('Error: $e', AppColors.error);
    }
  }

  Widget _driversPage() => Scaffold(
    backgroundColor: const Color(0xFF0D1B2A),
    appBar: AppBar(
      title: const Text('Bus Drivers'),
      backgroundColor: OwnerButtonColors.drivers,
      foregroundColor: Colors.white,
      actions: [
        IconButton(icon: const Icon(Icons.add), onPressed: _showAddDriver),
      ],
    ),
    body: _driversLoading
        ? const Center(child: CircularProgressIndicator())
        : _drivers.isEmpty
        ? const Center(
            child: Text(
              'No drivers registered',
              style: TextStyle(color: Color(0xFF8899AA)),
            ),
          )
        : ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: _drivers.length,
            separatorBuilder: (_, __) => SizedBox(height: 8.h),
            itemBuilder: (_, i) => _driverCard(_drivers[i]),
          ),
  );

  Widget _driverCard(Map<String, dynamic> d) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
    color: const Color(0xFF1A2A3A),
    child: Padding(
      padding: EdgeInsets.all(14.w),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: OwnerButtonColors.drivers.withValues(alpha: 0.15),
            child: Icon(Icons.badge, color: OwnerButtonColors.drivers),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d['name'] ?? '\u2014',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                _chip(Icons.phone, d['phone'] ?? '\u2014'),
                SizedBox(width: 12.w),
                _chip(Icons.credit_card, d['license_number'] ?? '\u2014'),
                if (d['salary'] != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    'Salary: Rs. ${d['salary']}',
                    style: TextStyle(color: AppColors.gray500, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          _badge(d['status'] ?? 'active', OwnerButtonColors.drivers),
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    ),
  );

  // ═══════════════════════════════════════════════════════
  // CONDUCTORS (cloned from FleetConductorsScreen)
  // ═══════════════════════════════════════════════════════

  Future<void> _loadConductors() async {
    setState(() => _conductorsLoading = true);
    try {
      final res = await ApiService().get('/bus-owner/conductors');
      final d = res['data'] as Map<String, dynamic>?;
      if (mounted)
        setState(() {
          _conductors = List<Map<String, dynamic>>.from(d?['data'] ?? []);
          _conductorCount = d?['total'] ?? _conductors.length;
          _conductorsLoading = false;
        });
    } catch (_) {
      if (mounted) setState(() => _conductorsLoading = false);
    }
  }

  Future<void> _showAddConductor() async {
    final name = TextEditingController(), phone = TextEditingController();
    final cnic = TextEditingController(), addr = TextEditingController();
    final salary = TextEditingController(), pass = TextEditingController();
    final email = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Bus Conductor'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _tf(name, 'Full Name *'),
              SizedBox(height: 10.h),
              _tf(phone, 'Phone *', phone: true),
              SizedBox(height: 10.h),
              _tf(pass, 'Password *', obscure: true),
              SizedBox(height: 10.h),
              _tf(email, 'Email', email: true),
              SizedBox(height: 10.h),
              _tf(cnic, 'CNIC'),
              SizedBox(height: 10.h),
              _tf(addr, 'Address', maxLines: 2),
              SizedBox(height: 10.h),
              _tf(salary, 'Salary *', number: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ApiService().post(
        '/bus-owner/conductors',
        data: {
          'name': name.text.trim(),
          'phone': phone.text.trim(),
          'password': pass.text,
          if (email.text.isNotEmpty) 'email': email.text.trim(),
          if (cnic.text.isNotEmpty) 'cnic': cnic.text.trim(),
          if (addr.text.isNotEmpty) 'address': addr.text.trim(),
          'salary': double.tryParse(salary.text) ?? 0,
        },
      );
      _loadConductors();
      _snack('Conductor added', AppColors.success);
    } catch (e) {
      _snack('Error: $e', AppColors.error);
    }
  }

  Widget _conductorsPage() => Scaffold(
    backgroundColor: const Color(0xFF0D1B2A),
    appBar: AppBar(
      title: const Text('Bus Conductors'),
      backgroundColor: OwnerButtonColors.conductors,
      foregroundColor: Colors.white,
      actions: [
        IconButton(icon: const Icon(Icons.add), onPressed: _showAddConductor),
      ],
    ),
    body: _conductorsLoading
        ? const Center(child: CircularProgressIndicator())
        : _conductors.isEmpty
        ? const Center(
            child: Text(
              'No conductors registered',
              style: TextStyle(color: Color(0xFF8899AA)),
            ),
          )
        : ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: _conductors.length,
            separatorBuilder: (_, __) => SizedBox(height: 8.h),
            itemBuilder: (_, i) => _conductorCard(_conductors[i]),
          ),
  );

  Widget _conductorCard(Map<String, dynamic> c) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
    color: const Color(0xFF1A2A3A),
    child: Padding(
      padding: EdgeInsets.all(14.w),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: OwnerButtonColors.conductors.withValues(
              alpha: 0.15,
            ),
            child: Icon(Icons.group, color: OwnerButtonColors.conductors),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c['name'] ?? '\u2014',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                _chip(Icons.phone, c['phone'] ?? '\u2014'),
                if (c['salary'] != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    'Salary: Rs. ${c['salary']}',
                    style: TextStyle(color: AppColors.gray500, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          _badge(c['status'] ?? 'active', OwnerButtonColors.conductors),
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    ),
  );

  // ═══════════════════════════════════════════════════════
  // SEAT LAYOUTS (grid canvas designer)
  // ═══════════════════════════════════════════════════════

  Future<void> _loadLayouts() async {
    setState(() => _layoutsLoading = true);
    try {
      final res = await ApiService().get('/bus-owner/layouts');
      final d = res['data'];
      if (mounted)
        setState(() {
          if (d is List) _layouts = List<Map<String, dynamic>>.from(d);
          _layoutCount = _layouts.length;
          _layoutsLoading = false;
        });
    } catch (_) {
      if (mounted) setState(() => _layoutsLoading = false);
    }
  }

  String? _designerPreset;
  int _designerRows = 12, _designerLeftCols = 2, _designerRightCols = 2;
  List<List<String>> _designerGrid = []; // 'seat', 'aisle', 'empty'

  void _initDesigner(String presetKey) {
    final p = _presets.firstWhere(
      (x) => x['key'] == presetKey,
      orElse: () => _presets[0],
    );
    _designerPreset = presetKey;
    _designerRows = p['rows'] as int;
    _designerLeftCols = p['leftCols'] as int;
    _designerRightCols = p['rightCols'] as int;
    final totalCols =
        _designerLeftCols + 1 + _designerRightCols; // +1 for aisle
    _designerGrid = List.generate(_designerRows, (r) {
      final row = <String>[];
      for (int c = 0; c < totalCols; c++) {
        if (c == _designerLeftCols) {
          row.add('aisle');
        } else {
          row.add('seat');
        }
      }
      return row;
    });
  }

  String _cellLabel(int row, int col) {
    final letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final l = row < letters.length ? letters[row] : '${row + 1}';
    return '$l${col + 1}';
  }

  int _totalSeats() {
    int count = 0;
    for (final row in _designerGrid) {
      for (final cell in row) {
        if (cell == 'seat') count++;
      }
    }
    return count;
  }

  Widget _layoutsPage() => Scaffold(
    backgroundColor: const Color(0xFF0D1B2A),
    appBar: AppBar(
      title: const Text('Seat Layouts'),
      backgroundColor: OwnerButtonColors.seats,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _showLayoutDesigner(),
        ),
      ],
    ),
    body: _layoutsLoading
        ? const Center(child: CircularProgressIndicator())
        : _layouts.isEmpty
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
                const Text(
                  'No seat layouts yet',
                  style: TextStyle(color: Color(0xFF8899AA)),
                ),
                const Gap(12),
                ElevatedButton.icon(
                  onPressed: () => _showLayoutDesigner(),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Layout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OwnerButtonColors.seats,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: _layouts.length,
            itemBuilder: (_, i) => _layoutCard(_layouts[i]),
          ),
  );

  Widget _layoutCard(Map<String, dynamic> l) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
    color: const Color(0xFF1A2A3A),
    child: Padding(
      padding: EdgeInsets.all(14.w),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: OwnerButtonColors.seats.withValues(alpha: 0.15),
            child: Icon(Icons.event_seat, color: OwnerButtonColors.seats),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l['display_name'] ?? 'Untitled',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${l['vehicle_class']} \u2022 ${l['total_seats'] ?? 0} seats \u2022 v${l['version_number'] ?? 1}',
                  style: TextStyle(color: AppColors.gray500, fontSize: 11),
                ),
              ],
            ),
          ),
          _badge(l['layout_status'] ?? 'draft', OwnerButtonColors.seats),
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    ),
  );

  void _showLayoutDesigner() {
    if (_designerGrid.isEmpty) _initDesigner('standard_45');
    final nameCtl = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) {
          final seats = _totalSeats();
          final totalCols = _designerLeftCols + 1 + _designerRightCols;

          return AlertDialog(
            backgroundColor: const Color(0xFF162438),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(
                  Icons.event_seat,
                  color: Color(0xFF16A34A),
                  size: 24,
                ),
                const Gap(8),
                const Text(
                  'Seat Layout Designer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white70,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            content: SizedBox(
              width: 700,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Preset selector
                    Row(
                      children: [
                        const Text(
                          'Preset:',
                          style: TextStyle(
                            color: Color(0xFF8899AA),
                            fontSize: 12,
                          ),
                        ),
                        const Gap(8),
                        DropdownButton<String>(
                          value: _designerPreset,
                          dropdownColor: const Color(0xFF162438),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                          items: _presets
                              .map(
                                (p) => DropdownMenuItem(
                                  value: p['key'] as String,
                                  child: Text(p['label'] as String),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setDlg(() => _initDesigner(v!)),
                        ),
                        const Spacer(),
                        Text(
                          '$seats seats',
                          style: const TextStyle(
                            color: Color(0xFF00C49F),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Gap(4),
                    Text(
                      'Tap cells to toggle: Seat → Aisle → Empty',
                      style: const TextStyle(
                        color: Color(0xFF556677),
                        fontSize: 11,
                      ),
                    ),
                    const Gap(12),
                    // Legend
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _legend('Seat', OwnerButtonColors.seats),
                        const Gap(16),
                        _legend('Aisle', AppColors.gray500),
                        const Gap(16),
                        _legend('Empty', const Color(0xFF334455)),
                      ],
                    ),
                    const Gap(12),
                    // Grid canvas
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1B2A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF2A3A4A)),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          children: [
                            // Column headers
                            Row(
                              children: [
                                const SizedBox(width: 40),
                                for (int c = 0; c < totalCols; c++)
                                  SizedBox(
                                    width: c == _designerLeftCols ? 48 : 44,
                                    child: Center(
                                      child: Text(
                                        c == _designerLeftCols
                                            ? '\u2195'
                                            : '${c + 1}',
                                        style: const TextStyle(
                                          color: Color(0xFF667788),
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const Gap(4),
                            // Rows
                            for (int r = 0; r < _designerRows; r++)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 40,
                                      child: Center(
                                        child: Text(
                                          '${r + 1}',
                                          style: const TextStyle(
                                            color: Color(0xFF667788),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    for (int c = 0; c < totalCols; c++)
                                      GestureDetector(
                                        onTap: () => setDlg(() {
                                          final cur = _designerGrid[r][c];
                                          if (cur == 'seat') {
                                            _designerGrid[r][c] = 'aisle';
                                          } else if (cur == 'aisle') {
                                            _designerGrid[r][c] = 'empty';
                                          } else {
                                            _designerGrid[r][c] = 'seat';
                                          }
                                        }),
                                        child: Container(
                                          width: c == _designerLeftCols
                                              ? 48
                                              : 44,
                                          height: 36,
                                          margin: const EdgeInsets.all(1.5),
                                          decoration: BoxDecoration(
                                            color: _designerGrid[r][c] == 'seat'
                                                ? OwnerButtonColors.seats
                                                      .withValues(alpha: 0.6)
                                                : _designerGrid[r][c] == 'aisle'
                                                ? AppColors.gray500.withValues(
                                                    alpha: 0.3,
                                                  )
                                                : const Color(
                                                    0xFF334455,
                                                  ).withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            border: Border.all(
                                              color:
                                                  _designerGrid[r][c] == 'seat'
                                                  ? OwnerButtonColors.seats
                                                  : _designerGrid[r][c] ==
                                                        'aisle'
                                                  ? AppColors.gray500
                                                        .withValues(alpha: 0.5)
                                                  : const Color(
                                                      0xFF334455,
                                                    ).withValues(alpha: 0.3),
                                            ),
                                          ),
                                          child: Center(
                                            child: _designerGrid[r][c] == 'seat'
                                                ? Text(
                                                    _cellLabel(r, c),
                                                    style: TextStyle(
                                                      color: Colors.white
                                                          .withValues(
                                                            alpha: 0.8,
                                                          ),
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  )
                                                : _designerGrid[r][c] == 'aisle'
                                                ? const Icon(
                                                    Icons.remove,
                                                    size: 10,
                                                    color: Color(0xFF667788),
                                                  )
                                                : null,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const Gap(12),
                    // Layout name
                    TextField(
                      controller: nameCtl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Layout Name *',
                        labelStyle: const TextStyle(color: Color(0xFF8899AA)),
                        filled: true,
                        fillColor: const Color(0xFF0D1B2A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF2A3A4A),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
                  final name = nameCtl.text.trim();
                  if (name.isEmpty) {
                    _snack('Please enter a layout name', AppColors.error);
                    return;
                  }
                  try {
                    await ApiService().post(
                      '/bus-owner/layouts',
                      data: {
                        'display_name': name,
                        'vehicle_class': _designerPreset ?? 'standard_45',
                      },
                    );
                    Navigator.pop(ctx);
                    _loadLayouts();
                    _snack('Layout created', AppColors.success);
                  } catch (e) {
                    _snack('Error: $e', AppColors.error);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: OwnerButtonColors.seats,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save Layout'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _legend(String label, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      const Gap(4),
      Text(
        label,
        style: const TextStyle(color: Color(0xFF8899AA), fontSize: 10),
      ),
    ],
  );

  // ═══ SHARED WIDGETS ═══

  Widget _tf(
    TextEditingController c,
    String l, {
    bool obscure = false,
    bool email = false,
    bool phone = false,
    bool number = false,
    int maxLines = 1,
  }) => TextField(
    controller: c,
    obscureText: obscure,
    maxLines: maxLines,
    keyboardType: email
        ? TextInputType.emailAddress
        : phone || number
        ? TextInputType.phone
        : TextInputType.text,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      labelText: l,
      labelStyle: const TextStyle(color: Color(0xFF8899AA)),
      border: const OutlineInputBorder(),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF2A3A4A)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF00C49F)),
      ),
    ),
  );

  Widget _chip(IconData i, String t) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(i, size: 13, color: AppColors.gray400),
      SizedBox(width: 3.w),
      Text(t, style: TextStyle(color: AppColors.gray500, fontSize: 11)),
    ],
  );

  Widget _badge(String s, Color color) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Text(
      s.toUpperCase(),
      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
    ),
  );

  void _snack(String msg, Color bg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

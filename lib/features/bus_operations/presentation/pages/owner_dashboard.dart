// Bus Owner Dashboard — Full Dynamic Seat Layout Generator
// 4-step wizard: Bus Details → Grid Setup → Preview/Edit → Save

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
  static const Color drivers = Color(0xFFDB2777);
  static const Color conductors = Color(0xFFDC2626);
  static const Color seats = Color(0xFF16A34A);
}

const _brands = [
  'Daewoo',
  'Yutong',
  'Higer',
  'Benz',
  'Isuzu',
  'Tata',
  'Ashok Leyland',
  'Volvo',
  'Scania',
  'Other',
];
const _categories = [
  'Luxury Coach',
  'Standard Coach',
  'Coaster',
  'HiAce',
  'Sleeper',
  'Mini Bus',
];

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});
  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  String _ownerName = 'Owner', _currentPage = 'dashboard';
  bool _sidebarOpen = true, _isLoading = true;
  int _driverCount = 0, _conductorCount = 0, _layoutCount = 0;
  List<Map<String, dynamic>> _drivers = [], _conductors = [], _layouts = [];
  bool _driversLoading = true,
      _conductorsLoading = true,
      _layoutsLoading = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final p = await SharedPreferences.getInstance();
    final t = p.getString('auth_token') ?? '';
    if (!mounted) return;
    if (t.isEmpty) {
      context.go('/bus-owner/login');
      return;
    }
    _ownerName = p.getString('bus_owner_name') ?? 'Owner';
    setState(() => _isLoading = false);
  }

  void _logout() async {
    await (await SharedPreferences.getInstance()).remove('auth_token');
    if (mounted) context.go('/bus-owner/login');
  }

  @override
  Widget build(BuildContext c) {
    final w = MediaQuery.of(c).size.width > 900;
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: Row(
        children: [
          if (_sidebarOpen || w) _sidebar(w),
          Expanded(child: _content(w)),
        ],
      ),
    );
  }

  Widget _sidebar(bool w) => Container(
    width: 260,
    decoration: BoxDecoration(
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
            padding: EdgeInsets.fromLTRB(14, 14, 10, 8),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Color(0xFF00C49F),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.directions_bus,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                Gap(10),
                Expanded(
                  child: Text(
                    _ownerName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!w)
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white70, size: 18),
                    onPressed: () => setState(() => _sidebarOpen = false),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 30, minHeight: 30),
                  ),
              ],
            ),
          ),
          Gap(12),
          const Divider(color: Color(0x20FFFFFF), indent: 20, endIndent: 20),
          Gap(12),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 12),
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
                    onTap: () {
                      setState(() => _currentPage = 'layouts');
                      if (_layouts.isEmpty) _loadLayouts();
                    },
                  ),
                  Gap(8),
                  _sec('STAFF'),
                  Missile3DButton(
                    label: 'Drivers',
                    icon: Icons.badge_rounded,
                    color: OwnerButtonColors.drivers,
                    onTap: () {
                      setState(() => _currentPage = 'drivers');
                      if (_drivers.isEmpty) _loadDrivers();
                    },
                  ),
                  Missile3DButton(
                    label: 'Conductors',
                    icon: Icons.group_rounded,
                    color: OwnerButtonColors.conductors,
                    onTap: () {
                      setState(() => _currentPage = 'conductors');
                      if (_conductors.isEmpty) _loadConductors();
                    },
                  ),
                  Gap(8),
                  _sec('SYSTEM'),
                  Missile3DButton(
                    label: 'Logout',
                    icon: Icons.logout_rounded,
                    color: Color(0xFFDC2626),
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
    padding: EdgeInsets.only(left: 4, top: 4, bottom: 2),
    child: Text(
      t,
      style: TextStyle(
        color: Color(0xFFBDD8DB),
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    ),
  );

  Widget _content(bool w) => SafeArea(
    child: Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Color(0xFF162438),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Row(
            children: [
              if (!_sidebarOpen)
                IconButton(
                  icon: Icon(Icons.menu, color: Colors.white70),
                  onPressed: () => setState(() => _sidebarOpen = true),
                ),
              Expanded(
                child: Text(
                  _pageTitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.white60),
                onPressed: _loadAll,
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
  void _loadAll() {
    _loadDrivers();
    _loadConductors();
    _loadLayouts();
  }

  Widget _homePage() {
    _loadCounts();
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        Text(
          'Welcome, $_ownerName',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        Gap(4),
        Text(
          '$_driverCount drivers \u2022 $_conductorCount conductors \u2022 $_layoutCount layouts',
          style: TextStyle(color: Color(0xFF8899AA), fontSize: 13),
        ),
        Gap(24),
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
        Gap(24),
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _currentPage = 'layouts';
              _loadLayouts();
            });
          },
          icon: Icon(Icons.add),
          label: Text('Create Seat Layout'),
          style: ElevatedButton.styleFrom(
            backgroundColor: OwnerButtonColors.seats,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          ),
        ),
      ],
    );
  }

  Widget _kpi(String l, String v, IconData i, Color c) => Expanded(
    child: Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Color(0xFF1A2A3A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Color(0xFF2A3A4A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(i, color: c, size: 24),
          Gap(10.h),
          Text(
            v,
            style: TextStyle(
              color: c,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          Gap(4.h),
          Text(l, style: TextStyle(color: Color(0xFF667788), fontSize: 12)),
        ],
      ),
    ),
  );
  void _loadCounts() {
    _loadDrivers();
    _loadConductors();
    _loadLayouts();
  }

  // ═══ DRIVERS ═══
  Future<void> _loadDrivers() async {
    setState(() => _driversLoading = true);
    try {
      final r = await ApiService().get('/bus-owner/drivers');
      final d = r['data'] as Map<String, dynamic>?;
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
    final n = TextEditingController(),
        p = TextEditingController(),
        l = TextEditingController(),
        pw = TextEditingController(),
        cn = TextEditingController(),
        ad = TextEditingController(),
        pl = TextEditingController(),
        s = TextEditingController(),
        e = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Add Bus Driver'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _tf(n, 'Full Name *'),
              SizedBox(height: 10.h),
              _tf(p, 'Phone *', isPhone: true),
              SizedBox(height: 10.h),
              _tf(l, 'License Number *'),
              SizedBox(height: 10.h),
              _tf(pw, 'Password *', isPassword: true),
              SizedBox(height: 10.h),
              _tf(e, 'Email', isEmail: true),
              SizedBox(height: 10.h),
              _tf(cn, 'CNIC'),
              SizedBox(height: 10.h),
              _tf(ad, 'Address', maxLines: 2),
              SizedBox(height: 10.h),
              _tf(pl, 'Vehicle Plate'),
              SizedBox(height: 10.h),
              _tf(s, 'Salary', isNumber: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text('Save'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ApiService().post(
        '/bus-owner/drivers',
        data: {
          'name': n.text.trim(),
          'phone': p.text.trim(),
          'license_number': l.text.trim(),
          'password': pw.text,
          if (e.text.isNotEmpty) 'email': e.text.trim(),
          if (cn.text.isNotEmpty) 'cnic': cn.text.trim(),
          if (ad.text.isNotEmpty) 'address': ad.text.trim(),
          if (pl.text.isNotEmpty) 'vehicle_plate': pl.text.trim(),
          if (s.text.isNotEmpty) 'salary': double.tryParse(s.text) ?? 0,
        },
      );
      _loadDrivers();
      _snack('Driver added', AppColors.success);
    } catch (e) {
      _snack('Error: $e', AppColors.error);
    }
  }

  Widget _driversPage() => Scaffold(
    backgroundColor: Color(0xFF0D1B2A),
    appBar: AppBar(
      title: Text('Bus Drivers'),
      backgroundColor: OwnerButtonColors.drivers,
      foregroundColor: Colors.white,
      actions: [IconButton(icon: Icon(Icons.add), onPressed: _showAddDriver)],
    ),
    body: _driversLoading
        ? Center(child: CircularProgressIndicator())
        : _drivers.isEmpty
        ? Center(
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
    color: Color(0xFF1A2A3A),
    child: Padding(
      padding: EdgeInsets.all(14.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: OwnerButtonColors.drivers.withValues(alpha: .15),
            child: Icon(Icons.badge, color: OwnerButtonColors.drivers),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d['name'] ?? '\u2014',
                  style: TextStyle(
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
      ),
    ),
  );

  // ═══ CONDUCTORS ═══
  Future<void> _loadConductors() async {
    setState(() => _conductorsLoading = true);
    try {
      final r = await ApiService().get('/bus-owner/conductors');
      final d = r['data'] as Map<String, dynamic>?;
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
    final n = TextEditingController(),
        p = TextEditingController(),
        cn = TextEditingController(),
        ad = TextEditingController(),
        s = TextEditingController(),
        pw = TextEditingController(),
        e = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Add Bus Conductor'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _tf(n, 'Full Name *'),
              SizedBox(height: 10.h),
              _tf(p, 'Phone *', isPhone: true),
              SizedBox(height: 10.h),
              _tf(pw, 'Password *', isPassword: true),
              SizedBox(height: 10.h),
              _tf(e, 'Email', isEmail: true),
              SizedBox(height: 10.h),
              _tf(cn, 'CNIC'),
              SizedBox(height: 10.h),
              _tf(ad, 'Address', maxLines: 2),
              SizedBox(height: 10.h),
              _tf(s, 'Salary *', isNumber: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text('Save'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ApiService().post(
        '/bus-owner/conductors',
        data: {
          'name': n.text.trim(),
          'phone': p.text.trim(),
          'password': pw.text,
          if (e.text.isNotEmpty) 'email': e.text.trim(),
          if (cn.text.isNotEmpty) 'cnic': cn.text.trim(),
          if (ad.text.isNotEmpty) 'address': ad.text.trim(),
          'salary': double.tryParse(s.text) ?? 0,
        },
      );
      _loadConductors();
      _snack('Conductor added', AppColors.success);
    } catch (e) {
      _snack('Error: $e', AppColors.error);
    }
  }

  Widget _conductorsPage() => Scaffold(
    backgroundColor: Color(0xFF0D1B2A),
    appBar: AppBar(
      title: Text('Bus Conductors'),
      backgroundColor: OwnerButtonColors.conductors,
      foregroundColor: Colors.white,
      actions: [
        IconButton(icon: Icon(Icons.add), onPressed: _showAddConductor),
      ],
    ),
    body: _conductorsLoading
        ? Center(child: CircularProgressIndicator())
        : _conductors.isEmpty
        ? Center(
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
    color: Color(0xFF1A2A3A),
    child: Padding(
      padding: EdgeInsets.all(14.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: OwnerButtonColors.conductors.withValues(
              alpha: .15,
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
                  style: TextStyle(
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
      ),
    ),
  );

  // ═══ LAYOUTS ═══
  Future<void> _loadLayouts() async {
    setState(() => _layoutsLoading = true);
    try {
      final r = await ApiService().get('/bus-owner/layouts');
      if (!mounted) return;
      final d = r?['data'];
      if (d is List) {
        _layouts = d.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } else if (d is Map && d['data'] is List) {
        _layouts = (d['data'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      } else {
        _layouts = [];
      }
      _layoutCount = _layouts.length;
      _layoutsLoading = false;
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        setState(() {
          _layoutsLoading = false;
          _layouts = [];
          _layoutCount = 0;
        });
      }
    }
  }

  Future<void> _deleteLayout(String id, String name) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: Color(0xFF162438),
        title: Text('Delete Layout?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Permanently delete "$name"?',
          style: TextStyle(color: Color(0xFF8899AA)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ApiService().delete('/bus-owner/layouts/$id?permanent=true');
      _loadLayouts();
      _snack('Layout deleted', AppColors.success);
    } catch (e) {
      _snack('Error: $e', AppColors.error);
    }
  }

  Widget _layoutsPage() => Scaffold(
    backgroundColor: Color(0xFF0D1B2A),
    appBar: AppBar(
      title: Text('Seat Layouts'),
      backgroundColor: OwnerButtonColors.seats,
      foregroundColor: Colors.white,
      actions: [
        IconButton(icon: Icon(Icons.add), onPressed: _openLayoutWizard),
      ],
    ),
    body: _layoutsLoading
        ? Center(child: CircularProgressIndicator())
        : _layouts.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_seat,
                  size: 48,
                  color: Colors.white.withValues(alpha: .15),
                ),
                Gap(12),
                Text(
                  'No seat layouts yet',
                  style: TextStyle(color: Color(0xFF8899AA)),
                ),
                Gap(12),
                ElevatedButton.icon(
                  onPressed: _openLayoutWizard,
                  icon: Icon(Icons.add),
                  label: Text('Create Your First Layout'),
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

  Widget _layoutCard(Map<String, dynamic> l) {
    try {
      final sn = l['current_snapshot'] is Map
          ? l['current_snapshot'] as Map<String, dynamic>
          : null;
      final plate =
          (l['bus_plate'] ?? sn?['bus_plate'] ?? l['vehicle_class'] ?? '')
              .toString();
      final seats = l['total_seats'] ?? 0;
      final rows = l['total_rows'] ?? sn?['total_rows'] ?? 0;
      final cols = l['total_cols'] ?? sn?['total_cols'] ?? 0;
      final name = (l['display_name'] ?? 'Untitled').toString();
      final status = (l['layout_status'] ?? 'draft').toString();
      final id = (l['id'] ?? '').toString();
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        color: Color(0xFF1A2A3A),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: OwnerButtonColors.seats.withValues(alpha: .15),
                child: Icon(Icons.event_seat, color: OwnerButtonColors.seats),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '$plate \u2022 $seats seats \u2022 ${rows}\u00d7$cols',
                      style: TextStyle(color: AppColors.gray500, fontSize: 11),
                    ),
                  ],
                ),
              ),
              _badge(status, OwnerButtonColors.seats),
              SizedBox(width: 4.w),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.redAccent, size: 20),
                onPressed: () => _deleteLayout(id, name),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ),
      );
    } catch (_) {
      return const SizedBox.shrink();
    }
  }

  // ═══════════════════════ LAYOUT WIZARD ═══════════════════════
  void _openLayoutWizard() {
    int step = 0;
    final plateCtl = TextEditingController(),
        brandCtl = TextEditingController(),
        catCtl = TextEditingController();
    int rows = 12, cols = 4, aisle = 2;
    List<List<String>> grid = [];
    bool built = false, saving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) {
          final w = MediaQuery.of(ctx).size.width > 700;
          return AlertDialog(
            backgroundColor: Color(0xFF162438),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            insetPadding: EdgeInsets.symmetric(
              horizontal: w ? 40 : 16,
              vertical: 24,
            ),
            title: Row(
              children: [
                Icon(Icons.event_seat, color: Color(0xFF16A34A), size: 24),
                Gap(8),
                Expanded(
                  child: Text(
                    step == 0
                        ? 'Step 1: Bus Details'
                        : step == 1
                        ? 'Step 2: Grid Setup'
                        : step == 2
                        ? 'Step 3: Preview & Edit'
                        : 'Saving...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white70, size: 20),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            content: SizedBox(
              width: w ? 720 : 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: List.generate(
                      3,
                      (i) => Expanded(
                        child: Container(
                          height: 4,
                          margin: EdgeInsets.symmetric(
                            horizontal: i == 1 ? 3 : 0,
                          ),
                          decoration: BoxDecoration(
                            color: i <= step
                                ? OwnerButtonColors.seats
                                : Color(0xFF2A3A4A),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Gap(20),
                  if (step == 0)
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _wiz(
                              'Bus Plate Number *',
                              'e.g. LES-26-1122',
                              Icons.directions_bus,
                              plateCtl,
                            ),
                            Gap(12),
                            _wiz(
                              'Bus Brand',
                              'e.g. Daewoo, Yutong',
                              Icons.factory,
                              brandCtl,
                            ),
                            Gap(12),
                            _wiz(
                              'Bus Category',
                              'e.g. Luxury Coach, Coaster',
                              Icons.category,
                              catCtl,
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (step == 1)
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _num(
                                    'Rows',
                                    rows,
                                    3,
                                    20,
                                    (v) => setDlg(() => rows = v),
                                  ),
                                ),
                                Gap(12),
                                Expanded(
                                  child: _num(
                                    'Columns',
                                    cols,
                                    2,
                                    7,
                                    (v) => setDlg(() => cols = v),
                                  ),
                                ),
                              ],
                            ),
                            Gap(12),
                            _num(
                              'Aisle After Col',
                              aisle,
                              0,
                              cols - 1,
                              (v) => setDlg(() => aisle = v),
                            ),
                            Gap(16),
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Color(0xFF0D1B2A),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Color(0xFF2A3A4A)),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '$rows rows x $cols cols',
                                    style: TextStyle(
                                      color: Color(0xFF8899AA),
                                      fontSize: 12,
                                    ),
                                  ),
                                  Gap(8),
                                  _mini(rows, cols, aisle),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (step == 2 && built)
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Tap: Seat → Aisle → Empty → Folding',
                              style: TextStyle(
                                color: Color(0xFF556677),
                                fontSize: 11,
                              ),
                            ),
                            Gap(6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _leg('Seat', OwnerButtonColors.seats),
                                Gap(12),
                                _leg('Aisle', AppColors.gray500),
                                Gap(12),
                                _leg('Empty', Color(0xFF334455)),
                                Gap(12),
                                _leg('Folding', Color(0xFFD97706)),
                              ],
                            ),
                            Gap(8),
                            Text(
                              () {
                                int s = 0, f = 0;
                                for (var r in grid)
                                  for (var c in r) {
                                    if (c == 'seat') s++;
                                    if (c == 'folding') f++;
                                  }
                                return '$s seats + $f folding';
                              }(),
                              style: TextStyle(
                                color: Color(0xFF00C49F),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Gap(10),
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Color(0xFF0D1B2A),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Color(0xFF2A3A4A)),
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(width: 44),
                                        for (int i = 0; i < cols; i++)
                                          SizedBox(
                                            width: i == aisle ? 52 : 44,
                                            child: Center(
                                              child: Text(
                                                i == aisle
                                                    ? '\u2195 Aisle'
                                                    : 'Col ${i + 1}',
                                                style: TextStyle(
                                                  color: i == aisle
                                                      ? AppColors.gray500
                                                      : Color(0xFF667788),
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    Gap(4),
                                    for (int r = 0; r < rows; r++)
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 3),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 44,
                                              child: Center(
                                                child: Text(
                                                  'R${r + 1}',
                                                  style: TextStyle(
                                                    color: Color(0xFF667788),
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            for (int c = 0; c < cols; c++)
                                              GestureDetector(
                                                onTap: () => setDlg(() {
                                                  final t = grid[r][c];
                                                  grid[r][c] = t == 'seat'
                                                      ? 'aisle'
                                                      : t == 'aisle'
                                                      ? 'empty'
                                                      : t == 'empty'
                                                      ? 'folding'
                                                      : 'seat';
                                                }),
                                                child: _gc(
                                                  grid[r][c],
                                                  grid[r][c] == 'seat' ||
                                                          grid[r][c] ==
                                                              'folding'
                                                      ? _lbl(
                                                          r,
                                                          c,
                                                          cols: cols,
                                                          aisle: aisle,
                                                        )
                                                      : '',
                                                  c == aisle,
                                                  w: c == aisle ? 52 : 44,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              if (step > 0)
                TextButton(
                  onPressed: () => setDlg(() => step--),
                  child: Text(
                    '\u2190 Back',
                    style: TextStyle(color: Color(0xFF8899AA)),
                  ),
                ),
              Spacer(),
              if (step == 0)
                ElevatedButton(
                  onPressed: () {
                    if (plateCtl.text.trim().isEmpty) {
                      _snack('Please enter bus plate number', AppColors.error);
                      return;
                    }
                    if (brandCtl.text.trim().isEmpty) brandCtl.text = 'Other';
                    if (catCtl.text.trim().isEmpty)
                      catCtl.text = 'Standard Coach';
                    setDlg(() => step = 1);
                  },
                  style: _nxt,
                  child: Text('Next \u2192'),
                ),
              if (step == 1)
                ElevatedButton(
                  onPressed: () => setDlg(() {
                    grid = List.generate(
                      rows,
                      (r) => List.generate(
                        cols,
                        (c) => c == aisle ? 'aisle' : 'seat',
                      ),
                    );
                    built = true;
                    step = 2;
                  }),
                  style: _nxt,
                  child: Text('Generate Grid \u2192'),
                ),
              if (step == 2)
                ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          setDlg(() => saving = true);
                          try {
                            final cells = grid
                                .asMap()
                                .entries
                                .map(
                                  (re) => re.value.asMap().entries.map((ce) {
                                    final t = ce.value;
                                    return {
                                      'type': t,
                                      'label': t == 'seat' || t == 'folding'
                                          ? _lbl(
                                              re.key,
                                              ce.key,
                                              cols: cols,
                                              aisle: aisle,
                                            )
                                          : '',
                                      'seat_id': t == 'seat' || t == 'folding'
                                          ? _lbl(
                                              re.key,
                                              ce.key,
                                              cols: cols,
                                              aisle: aisle,
                                            )
                                          : null,
                                    };
                                  }).toList(),
                                )
                                .toList();
                            final res = await ApiService().post(
                              '/bus-owner/layouts',
                              data: {
                                'bus_plate': plateCtl.text.trim(),
                                'bus_brand': brandCtl.text.trim().isEmpty
                                    ? 'Other'
                                    : brandCtl.text.trim(),
                                'bus_category': catCtl.text.trim().isEmpty
                                    ? 'Standard Coach'
                                    : catCtl.text.trim(),
                                'total_rows': rows,
                                'total_cols': cols,
                                'aisle_after_col': aisle,
                                'grid': cells,
                              },
                            );
                            if (res != null && res['success'] == true) {
                              Navigator.pop(ctx);
                              _loadLayouts();
                              _snack('Layout created!', AppColors.success);
                            } else {
                              _snack(
                                res?['message'] ?? 'Failed',
                                AppColors.error,
                              );
                            }
                          } catch (e) {
                            _snack('Error: $e', AppColors.error);
                          }
                          setDlg(() => saving = false);
                        },
                  style: _nxt,
                  child: saving
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text('Save Layout'),
                ),
            ],
          );
        },
      ),
    );
  }

  // ═══ WIZARD HELPERS ═══
  Widget _wiz(String lbl, String hint, IconData ic, TextEditingController ctl, {List<String>? dd}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctl,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: lbl,
          hintText: hint,
          labelStyle: const TextStyle(color: Color(0xFF8899AA)),
          hintStyle: const TextStyle(color: Color(0xFF556677)),
          prefixIcon: Icon(ic, color: const Color(0xFF556677)),
          filled: true,
          fillColor: const Color(0xFF0D1B2A),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF2A3A4A))),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00C49F))),
          border: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF2A3A4A))),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }

  Widget _num(
    String lbl,
    int v,
    int min,
    int max,
    void Function(int) cb, {
    String? hint,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        lbl,
        style: TextStyle(
          color: Color(0xFF8899AA),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      if (hint != null)
        Text(hint, style: TextStyle(color: Color(0xFF556677), fontSize: 10)),
      Gap(4),
      Row(
        children: [
          IconButton(
            icon: Icon(Icons.remove, color: Color(0xFF00C49F)),
            onPressed: v > min ? () => cb(v - 1) : null,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          Container(
            width: 48,
            height: 36,
            decoration: BoxDecoration(
              color: Color(0xFF0D1B2A),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Color(0xFF2A3A4A)),
            ),
            child: Center(
              child: Text(
                '$v',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.add, color: Color(0xFF00C49F)),
            onPressed: v < max ? () => cb(v + 1) : null,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    ],
  );

  Widget _mini(int r, int c, int a) => Container(
    padding: EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: Color(0xFF082030),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      children: List.generate(
        r,
        (rr) => Padding(
          padding: EdgeInsets.only(bottom: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              c,
              (cc) => Container(
                width: 22,
                height: 18,
                margin: EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: cc == a
                      ? AppColors.gray500.withValues(alpha: .3)
                      : OwnerButtonColors.seats.withValues(alpha: .4),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _gc(String t, String lb, bool isA, {double w = 44}) => Container(
    width: w,
    height: 36,
    margin: EdgeInsets.all(1.5),
    decoration: BoxDecoration(
      color: t == 'seat'
          ? OwnerButtonColors.seats.withValues(alpha: .55)
          : t == 'folding'
          ? Color(0xFFD97706).withValues(alpha: .5)
          : t == 'aisle'
          ? AppColors.gray500.withValues(alpha: .25)
          : Color(0xFF334455).withValues(alpha: .15),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(
        color: t == 'seat'
            ? OwnerButtonColors.seats
            : t == 'folding'
            ? Color(0xFFD97706)
            : t == 'aisle'
            ? AppColors.gray500.withValues(alpha: .4)
            : Color(0xFF334455).withValues(alpha: .2),
      ),
    ),
    child: Center(
      child: t == 'seat' || t == 'folding'
          ? Text(
              lb,
              style: TextStyle(
                color: Colors.white.withValues(alpha: .85),
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            )
          : t == 'aisle'
          ? Text(
              '\u2195',
              style: TextStyle(color: Color(0xFF667788), fontSize: 10),
            )
          : null,
    ),
  );

  String _lbl(int r, int c, {int cols = 4, int aisle = 2}) {
    final ll = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final rl = r < ll.length ? ll[r] : 'R${r + 1}';
    return '$rl${c < aisle ? c + 1 : c}';
  }

  Widget _leg(String l, Color c) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: c.withValues(alpha: .5),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      Gap(4),
      Text(l, style: TextStyle(color: Color(0xFF8899AA), fontSize: 10)),
    ],
  );

  ButtonStyle get _nxt => ElevatedButton.styleFrom(
    backgroundColor: OwnerButtonColors.seats,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  // ═══ SHARED ═══
  Widget _tf(
    TextEditingController ctrl,
    String label, {
    bool isPassword = false,
    bool isEmail = false,
    bool isPhone = false,
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: isPassword,
      maxLines: maxLines,
      keyboardType: isEmail
          ? TextInputType.emailAddress
          : (isPhone || isNumber)
          ? TextInputType.phone
          : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF8899AA)),
        border: const OutlineInputBorder(),
        enabledBorder: const OutlineInputBorder(
          borderSide: const BorderSide(color: const Color(0xFF2A3A4A)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: const BorderSide(color: const Color(0xFF00C49F)),
        ),
      ),
    );
  }

  Widget _chip(IconData i, String t) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(i, size: 13, color: AppColors.gray400),
      SizedBox(width: 3.w),
      Text(t, style: TextStyle(color: AppColors.gray500, fontSize: 11)),
    ],
  );
  Widget _badge(String s, Color c) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
    decoration: BoxDecoration(
      color: c.withValues(alpha: .15),
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Text(
      s.toUpperCase(),
      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: c),
    ),
  );
  void _snack(String m, Color b) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(m),
        backgroundColor: b,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }
}

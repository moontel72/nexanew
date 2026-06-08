// Bus Owner Dashboard — cloned from Bus Fleet Dashboard (Module 13/14)
// Dynamic Seat Layout Generator (4-step wizard: Bus Details → Grid Setup → Preview → Save)
// Card-based drivers & conductors (matching FleetDriversScreen / FleetConductorsScreen)
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
  static const Color drivers = Color(0xFFDB2777);
  static const Color conductors = Color(0xFFDC2626);
  static const Color seats = Color(0xFF16A34A);
  static const Color alerts = Color(0xFF0891B2);
}

const _brands = ['Daewoo', 'Yutong', 'Higer', 'Benz', 'Isuzu', 'Tata', 'Ashok Leyland', 'Volvo', 'Scania', 'Other'];
const _categories = ['Luxury Coach', 'Standard Coach', 'Coaster', 'HiAce', 'Sleeper', 'Mini Bus'];

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

  List<Map<String, dynamic>> _drivers = [];
  bool _driversLoading = true;
  List<Map<String, dynamic>> _conductors = [];
  bool _conductorsLoading = true;
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
    if (token.isEmpty) { context.go('/bus-owner/login'); return; }
    _ownerName = prefs.getString('bus_owner_name') ?? 'Owner';
    setState(() => _isLoading = false);
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    if (mounted) context.go('/bus-owner/login');
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: Row(children: [
        if (_sidebarOpen || isWide) _sidebar(isWide),
        Expanded(child: _content(isWide)),
      ]),
    );
  }

  Widget _sidebar(bool isWide) => Container(
    width: 260,
    decoration: const BoxDecoration(
      gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1A3A5C), Color(0xFF0F2B3F)]),
      boxShadow: [BoxShadow(color: Color(0x30144055), blurRadius: 16, offset: Offset(4, 0))],
    ),
    child: SafeArea(child: Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 10, 8),
        child: Row(children: [
          Container(width: 34, height: 34, decoration: BoxDecoration(color: const Color(0xFF00C49F), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.directions_bus, color: Colors.white, size: 20)),
          const Gap(10),
          Expanded(child: Text(_ownerName, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis)),
          if (!isWide) IconButton(icon: const Icon(Icons.close, color: Colors.white70, size: 18), onPressed: () => setState(() => _sidebarOpen = false), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 30, minHeight: 30)),
        ]),
      ),
      const Gap(12), const Divider(color: Color(0x20FFFFFF), indent: 20, endIndent: 20), const Gap(12),
      Expanded(
        child: SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 12), child: Column(children: [
          _sec('FLEET'),
          Missile3DButton(label: 'Dashboard', icon: Icons.dashboard_rounded, color: OwnerButtonColors.dashboard, onTap: () => setState(() => _currentPage = 'dashboard')),
          Missile3DButton(label: 'Seat Layouts', icon: Icons.event_seat, color: OwnerButtonColors.seats, onTap: () => setState(() { _currentPage = 'layouts'; if (_layouts.isEmpty) _loadLayouts(); })),
          const Gap(8),
          _sec('STAFF'),
          Missile3DButton(label: 'Drivers', icon: Icons.badge_rounded, color: OwnerButtonColors.drivers, onTap: () => setState(() { _currentPage = 'drivers'; if (_drivers.isEmpty) _loadDrivers(); })),
          Missile3DButton(label: 'Conductors', icon: Icons.group_rounded, color: OwnerButtonColors.conductors, onTap: () => setState(() { _currentPage = 'conductors'; if (_conductors.isEmpty) _loadConductors(); })),
          const Gap(8),
          _sec('SYSTEM'),
          Missile3DButton(label: 'Logout', icon: Icons.logout_rounded, color: const Color(0xFFDC2626), onTap: _logout),
        ])),
      ),
    ])),
  );

  Widget _sec(String t) => Padding(padding: const EdgeInsets.only(left: 4, top: 4, bottom: 2), child: Text(t, style: const TextStyle(color: Color(0xFFBDD8DB), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2)));

  Widget _content(bool isWide) => SafeArea(child: Column(children: [
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: const Color(0xFF162438), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4)]),
      child: Row(children: [
        if (!_sidebarOpen) IconButton(icon: const Icon(Icons.menu, color: Colors.white70), onPressed: () => setState(() => _sidebarOpen = true)),
        Expanded(child: Text(_pageTitle, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700))),
        IconButton(icon: const Icon(Icons.refresh, color: Colors.white60), onPressed: _loadAll),
      ]),
    ),
    Expanded(child: _currentPage == 'drivers' ? _driversPage() : _currentPage == 'conductors' ? _conductorsPage() : _currentPage == 'layouts' ? _layoutsPage() : _homePage()),
  ]));

  String get _pageTitle => _currentPage == 'drivers' ? 'Bus Drivers' : _currentPage == 'conductors' ? 'Bus Conductors' : _currentPage == 'layouts' ? 'Seat Layouts' : 'Dashboard';

  void _loadAll() { _loadDrivers(); _loadConductors(); _loadLayouts(); }

  // ═══ HOME ═══
  Widget _homePage() {
    _loadCounts();
    return ListView(padding: EdgeInsets.all(16.w), children: [
      Text('Welcome, $_ownerName', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)), const Gap(4),
      Text('$_driverCount drivers \u2022 $_conductorCount conductors \u2022 $_layoutCount layouts', style: const TextStyle(color: Color(0xFF8899AA), fontSize: 13)), const Gap(24),
      Row(children: [
        _kpi('Drivers', '$_driverCount', Icons.badge, OwnerButtonColors.drivers), SizedBox(width: 12.w),
        _kpi('Conductors', '$_conductorCount', Icons.group, OwnerButtonColors.conductors), SizedBox(width: 12.w),
        _kpi('Layouts', '$_layoutCount', Icons.event_seat, OwnerButtonColors.seats),
      ]), const Gap(24),
      ElevatedButton.icon(
        onPressed: () => setState(() { _currentPage = 'layouts'; _loadLayouts(); }),
        icon: const Icon(Icons.add), label: const Text('Create Seat Layout'),
        style: ElevatedButton.styleFrom(backgroundColor: OwnerButtonColors.seats, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h)),
      ),
    ]);
  }

  Widget _kpi(String l, String v, IconData i, Color c) => Expanded(
    child: Container(padding: EdgeInsets.all(16.w), decoration: BoxDecoration(color: const Color(0xFF1A2A3A), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF2A3A4A))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(i, color: c, size: 24), Gap(10.h), Text(v, style: TextStyle(color: c, fontSize: 24, fontWeight: FontWeight.w800)), Gap(4.h), Text(l, style: const TextStyle(color: Color(0xFF667788), fontSize: 12))])),
  );

  void _loadCounts() { _loadDrivers(); _loadConductors(); _loadLayouts(); }

  // ═══════════════ DRIVERS ═══════════════
  Future<void> _loadDrivers() async {
    setState(() => _driversLoading = true);
    try {
      final res = await ApiService().get('/bus-owner/drivers');
      final d = res['data'] as Map<String, dynamic>?;
      if (mounted) setState(() { _drivers = List<Map<String, dynamic>>.from(d?['data'] ?? []); _driverCount = d?['total'] ?? _drivers.length; _driversLoading = false; });
    } catch (_) { if (mounted) setState(() => _driversLoading = false); }
  }

  Future<void> _showAddDriver() async {
    final name = TextEditingController(), phone = TextEditingController(), license = TextEditingController(), pass = TextEditingController();
    final cnic = TextEditingController(), addr = TextEditingController(), plate = TextEditingController(), salary = TextEditingController(), email = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Add Bus Driver'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        _tf(name, 'Full Name *'), SizedBox(height: 10.h), _tf(phone, 'Phone *', phone: true), SizedBox(height: 10.h),
        _tf(license, 'License Number *'), SizedBox(height: 10.h), _tf(pass, 'Password *', obscure: true),
        SizedBox(height: 10.h), _tf(email, 'Email', email: true), SizedBox(height: 10.h), _tf(cnic, 'CNIC'),
        SizedBox(height: 10.h), _tf(addr, 'Address', maxLines: 2), SizedBox(height: 10.h), _tf(plate, 'Vehicle Plate'),
        SizedBox(height: 10.h), _tf(salary, 'Salary', number: true),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save'))],
    ));
    if (ok != true) return;
    try {
      await ApiService().post('/bus-owner/drivers', data: {'name': name.text.trim(), 'phone': phone.text.trim(), 'license_number': license.text.trim(), 'password': pass.text, if (email.text.isNotEmpty) 'email': email.text.trim(), if (cnic.text.isNotEmpty) 'cnic': cnic.text.trim(), if (addr.text.isNotEmpty) 'address': addr.text.trim(), if (plate.text.isNotEmpty) 'vehicle_plate': plate.text.trim(), if (salary.text.isNotEmpty) 'salary': double.tryParse(salary.text) ?? 0});
      _loadDrivers(); _snack('Driver added', AppColors.success);
    } catch (e) { _snack('Error: $e', AppColors.error); }
  }

  Widget _driversPage() => Scaffold(
    backgroundColor: const Color(0xFF0D1B2A),
    appBar: AppBar(title: const Text('Bus Drivers'), backgroundColor: OwnerButtonColors.drivers, foregroundColor: Colors.white, actions: [IconButton(icon: const Icon(Icons.add), onPressed: _showAddDriver)]),
    body: _driversLoading ? const Center(child: CircularProgressIndicator()) : _drivers.isEmpty ? const Center(child: Text('No drivers registered', style: TextStyle(color: Color(0xFF8899AA)))) : ListView.separated(padding: EdgeInsets.all(16.w), itemCount: _drivers.length, separatorBuilder: (_, __) => SizedBox(height: 8.h), itemBuilder: (_, i) => _driverCard(_drivers[i])),
  );

  Widget _driverCard(Map<String, dynamic> d) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)), color: const Color(0xFF1A2A3A),
    child: Padding(padding: EdgeInsets.all(14.w), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CircleAvatar(backgroundColor: OwnerButtonColors.drivers.withValues(alpha: 0.15), child: Icon(Icons.badge, color: OwnerButtonColors.drivers)), SizedBox(width: 12.w),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(d['name'] ?? '\u2014', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        _chip(Icons.phone, d['phone'] ?? '\u2014'), SizedBox(width: 12.w), _chip(Icons.credit_card, d['license_number'] ?? '\u2014'),
        if (d['salary'] != null) ...[SizedBox(height: 2.h), Text('Salary: Rs. ${d['salary']}', style: TextStyle(color: AppColors.gray500, fontSize: 11))],
      ])),
      _badge(d['status'] ?? 'active', OwnerButtonColors.drivers),
    ])),
  );

  // ═══════════════ CONDUCTORS ═══════════════
  Future<void> _loadConductors() async {
    setState(() => _conductorsLoading = true);
    try {
      final res = await ApiService().get('/bus-owner/conductors');
      final d = res['data'] as Map<String, dynamic>?;
      if (mounted) setState(() { _conductors = List<Map<String, dynamic>>.from(d?['data'] ?? []); _conductorCount = d?['total'] ?? _conductors.length; _conductorsLoading = false; });
    } catch (_) { if (mounted) setState(() => _conductorsLoading = false); }
  }

  Future<void> _showAddConductor() async {
    final name = TextEditingController(), phone = TextEditingController(), cnic = TextEditingController(), addr = TextEditingController(), salary = TextEditingController(), pass = TextEditingController(), email = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Add Bus Conductor'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        _tf(name, 'Full Name *'), SizedBox(height: 10.h), _tf(phone, 'Phone *', phone: true), SizedBox(height: 10.h),
        _tf(pass, 'Password *', obscure: true), SizedBox(height: 10.h), _tf(email, 'Email', email: true),
        SizedBox(height: 10.h), _tf(cnic, 'CNIC'), SizedBox(height: 10.h), _tf(addr, 'Address', maxLines: 2), SizedBox(height: 10.h), _tf(salary, 'Salary *', number: true),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save'))],
    ));
    if (ok != true) return;
    try {
      await ApiService().post('/bus-owner/conductors', data: {'name': name.text.trim(), 'phone': phone.text.trim(), 'password': pass.text, if (email.text.isNotEmpty) 'email': email.text.trim(), if (cnic.text.isNotEmpty) 'cnic': cnic.text.trim(), if (addr.text.isNotEmpty) 'address': addr.text.trim(), 'salary': double.tryParse(salary.text) ?? 0});
      _loadConductors(); _snack('Conductor added', AppColors.success);
    } catch (e) { _snack('Error: $e', AppColors.error); }
  }

  Widget _conductorsPage() => Scaffold(
    backgroundColor: const Color(0xFF0D1B2A),
    appBar: AppBar(title: const Text('Bus Conductors'), backgroundColor: OwnerButtonColors.conductors, foregroundColor: Colors.white, actions: [IconButton(icon: const Icon(Icons.add), onPressed: _showAddConductor)]),
    body: _conductorsLoading ? const Center(child: CircularProgressIndicator()) : _conductors.isEmpty ? const Center(child: Text('No conductors registered', style: TextStyle(color: Color(0xFF8899AA)))) : ListView.separated(padding: EdgeInsets.all(16.w), itemCount: _conductors.length, separatorBuilder: (_, __) => SizedBox(height: 8.h), itemBuilder: (_, i) => _conductorCard(_conductors[i])),
  );

  Widget _conductorCard(Map<String, dynamic> c) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)), color: const Color(0xFF1A2A3A),
    child: Padding(padding: EdgeInsets.all(14.w), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CircleAvatar(backgroundColor: OwnerButtonColors.conductors.withValues(alpha: 0.15), child: Icon(Icons.group, color: OwnerButtonColors.conductors)), SizedBox(width: 12.w),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(c['name'] ?? '\u2014', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        _chip(Icons.phone, c['phone'] ?? '\u2014'),
        if (c['salary'] != null) ...[SizedBox(height: 2.h), Text('Salary: Rs. ${c['salary']}', style: TextStyle(color: AppColors.gray500, fontSize: 11))],
      ])),
      _badge(c['status'] ?? 'active', OwnerButtonColors.conductors),
    ])),
  );

  // ═══════════════════════════════════════════════════════════════
  // DYNAMIC SEAT LAYOUT GENERATOR (4-Step Wizard)
  // ═══════════════════════════════════════════════════════════════

  Future<void> _loadLayouts() async {
    setState(() => _layoutsLoading = true);
    try {
      final res = await ApiService().get('/bus-owner/layouts');
      final d = res['data'];
      if (mounted) setState(() { if (d is List) _layouts = List<Map<String, dynamic>>.from(d); _layoutCount = _layouts.length; _layoutsLoading = false; });
    } catch (_) { if (mounted) setState(() => _layoutsLoading = false); }
  }

  Future<void> _deleteLayout(String id, String name) async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF162438),
      title: const Text('Delete Layout?', style: TextStyle(color: Colors.white)),
      content: Text('Permanently delete "$name"?', style: const TextStyle(color: Color(0xFF8899AA))),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Delete'))],
    ));
    if (ok != true) return;
    try {
      await ApiService().delete('/bus-owner/layouts/$id?permanent=true');
      _loadLayouts(); _snack('Layout deleted', AppColors.success);
    } catch (e) { _snack('Error: $e', AppColors.error); }
  }

  Widget _layoutsPage() => Scaffold(
    backgroundColor: const Color(0xFF0D1B2A),
    appBar: AppBar(title: const Text('Seat Layouts'), backgroundColor: OwnerButtonColors.seats, foregroundColor: Colors.white, actions: [IconButton(icon: const Icon(Icons.add), onPressed: () => _openLayoutWizard())]),
    body: _layoutsLoading
        ? const Center(child: CircularProgressIndicator())
        : _layouts.isEmpty
        ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.event_seat, size: 48, color: Colors.white.withValues(alpha: 0.15)), const Gap(12),
            const Text('No seat layouts yet', style: TextStyle(color: Color(0xFF8899AA))), const Gap(12),
            ElevatedButton.icon(onPressed: _openLayoutWizard, icon: const Icon(Icons.add), label: const Text('Create Your First Layout'), style: ElevatedButton.styleFrom(backgroundColor: OwnerButtonColors.seats, foregroundColor: Colors.white)),
          ]))
        : ListView.builder(padding: EdgeInsets.all(16.w), itemCount: _layouts.length, itemBuilder: (_, i) => _layoutCard(_layouts[i])),
  );

  Widget _layoutCard(Map<String, dynamic> l) {
    final snap = l['current_snapshot'] is Map ? l['current_snapshot'] as Map<String, dynamic> : null;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)), color: const Color(0xFF1A2A3A),
      child: Padding(padding: EdgeInsets.all(14.w), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(backgroundColor: OwnerButtonColors.seats.withValues(alpha: 0.15), child: Icon(Icons.event_seat, color: OwnerButtonColors.seats)), SizedBox(width: 12.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l['display_name'] ?? 'Untitled', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          SizedBox(height: 2.h),
          Text('${l['bus_plate'] ?? snap?['bus_plate'] ?? l['vehicle_class']} \u2022 ${l['total_seats'] ?? 0} seats \u2022 ${l['total_rows'] ?? 0}\u00d7${l['total_cols'] ?? 0}', style: TextStyle(color: AppColors.gray500, fontSize: 11)),
        ])),
        _badge(l['layout_status'] ?? 'draft', OwnerButtonColors.seats), SizedBox(width: 4.w),
        IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20), onPressed: () => _deleteLayout(l['id']?.toString() ?? '', l['display_name']?.toString() ?? ''), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 32, minHeight: 32)),
      ])),
    );
  }

  // ═══ LAYOUT WIZARD ═══
  void _openLayoutWizard() {
    // Step state
    int _step = 0;
    // Step 1: Bus details
    final plateCtl = TextEditingController();
    final brandCtl = TextEditingController();
    final catCtl = TextEditingController();
    // Step 2: Grid setup
    int _rows = 12, _cols = 4, _aisleAfter = 2;
    // Step 3: Grid
    List<List<String>> _grid = []; // 'seat'|'aisle'|'empty'|'folding'|'driver'
    bool _gridBuilt = false;
    bool _saving = false;
    final _scrollCtl = ScrollController();

    showDialog(
      context: context, barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDlg) {
        final isWide = MediaQuery.of(ctx).size.width > 700;
        return AlertDialog(
          backgroundColor: const Color(0xFF162438),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(children: [
            const Icon(Icons.event_seat, color: Color(0xFF16A34A), size: 24), const Gap(8),
            Text(_step == 0 ? 'Step 1: Bus Details' : _step == 1 ? 'Step 2: Grid Setup' : _step == 2 ? 'Step 3: Preview & Edit' : 'Saving...', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            const Spacer(),
            IconButton(icon: const Icon(Icons.close, color: Colors.white70, size: 20), onPressed: () => Navigator.pop(ctx)),
          ]),
          content: SizedBox(
            width: isWide ? 720 : 500,
            child: SingleChildScrollView(controller: _scrollCtl, child: Column(mainAxisSize: MainAxisSize.min, children: [
              // ── Progress indicator ──
              Row(children: List.generate(3, (i) => Expanded(child: Container(
                height: 4,
                margin: EdgeInsets.symmetric(horizontal: i == 1 ? 3 : 0),
                decoration: BoxDecoration(color: i <= _step ? OwnerButtonColors.seats : const Color(0xFF2A3A4A), borderRadius: BorderRadius.circular(2)),
              )))),
              const Gap(20),

              // ═══ STEP 0: BUS DETAILS ═══
              if (_step == 0) ...[
                _wizardField('Bus Registration / Plate Number *', 'e.g. LES-26-1122', Icons.directions_bus, plateCtl),
                const Gap(12),
                _wizardField('Bus Brand / Manufacturer', 'e.g. Daewoo, Yutong, Higer', Icons.factory, brandCtl,
                  dropdownItems: _brands, onDropdownSelected: (v) => brandCtl.text = v),
                const Gap(12),
                _wizardField('Bus Category / Type', 'e.g. Luxury Coach, Coaster', Icons.category, catCtl,
                  dropdownItems: _categories, onDropdownSelected: (v) => catCtl.text = v),
              ],

              // ═══ STEP 1: GRID SETUP ═══
              if (_step == 1) ...[
                Row(children: [
                  Expanded(child: _numField('Horizontal Rows', _rows, 3, 20, (v) => setDlg(() => _rows = v))),
                  const Gap(12),
                  Expanded(child: _numField('Total Columns', _cols, 2, 7, (v) => setDlg(() => _cols = v))),
                ]),
                const Gap(12),
                _numField('Aisle (Walking Path) After Column', _aisleAfter, 0, _cols - 1, (v) => setDlg(() => _aisleAfter = v),
                  hint: '0 = first column is aisle. $_cols cols: 0..${_cols - 1}'),
                const Gap(16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFF0D1B2A), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF2A3A4A))),
                  child: Column(children: [
                    Text('Preview: $_rows rows \u00d7 $_cols cols (aisle after column $_aisleAfter)', style: const TextStyle(color: Color(0xFF8899AA), fontSize: 12)),
                    const Gap(8),
                    _miniPreview(_rows, _cols, _aisleAfter),
                  ]),
                ),
              ],

              // ═══ STEP 2: GRID PREVIEW & EDIT ═══
              if (_step == 2 && _gridBuilt) ...[
                Text('Tap cells to toggle: Seat \u2192 Aisle \u2192 Empty \u2192 Folding', style: const TextStyle(color: Color(0xFF556677), fontSize: 11)),
                const Gap(6),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _leg('Seat', OwnerButtonColors.seats), const Gap(12),
                  _leg('Aisle', AppColors.gray500), const Gap(12),
                  _leg('Empty', const Color(0xFF334455)), const Gap(12),
                  _leg('Folding', const Color(0xFFD97706)),
                ]),
                const Gap(8),
                Text(() { int s=0,f=0; for(var r in _grid) for(var c in r) { if(c=='seat')s++; if(c=='folding')f++; } return '$s seats + $f folding'; }(), style: const TextStyle(color: Color(0xFF00C49F), fontSize: 13, fontWeight: FontWeight.w600)),
                const Gap(10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFF0D1B2A), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2A3A4A))),
                  child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Column(children: [
                    // Column headers
                    Row(children: [
                      const SizedBox(width: 44),
                      for (int c = 0; c < _cols; c++)
                        SizedBox(width: c == _aisleAfter ? 52 : 44, child: Center(child: Text(c == _aisleAfter ? '\u2195 Aisle' : 'Col ${c + 1}', style: TextStyle(color: c == _aisleAfter ? AppColors.gray500 : const Color(0xFF667788), fontSize: 10, fontWeight: c == _aisleAfter ? FontWeight.w600 : FontWeight.normal)))),
                    ]),
                    const Gap(4),
                    for (int r = 0; r < _rows; r++)
                      Padding(padding: const EdgeInsets.only(bottom: 3), child: Row(children: [
                        SizedBox(width: 44, child: Center(child: Text('Row ${r + 1}', style: const TextStyle(color: Color(0xFF667788), fontSize: 10)))),
                        for (int c = 0; c < _cols; c++)
                          GestureDetector(
                            onTap: () => setDlg(() {
                              final cur = _grid[r][c];
                              _grid[r][c] = cur == 'seat' ? 'aisle' : cur == 'aisle' ? 'empty' : cur == 'empty' ? 'folding' : 'seat';
                            }),
                            child: _gridCell(_grid[r][c], _grid[r][c] == 'seat' || _grid[r][c] == 'folding' ? _seatLabel(r, c, cols: _cols, aisleAfter: _aisleAfter) : '', c == _aisleAfter, width: c == _aisleAfter ? 52 : 44),
                          ),
                      ])),
                  ])),
                ),
              ],
            ])),
          ),
          actions: [
            // Back button
            if (_step > 0)
              TextButton(onPressed: () => setDlg(() { _step--; _scrollCtl.jumpTo(0); }), child: const Text('\u2190 Back', style: TextStyle(color: Color(0xFF8899AA)))),
            const Spacer(),
            // Step 0 → Next
            if (_step == 0)
              ElevatedButton(onPressed: () {
                if (plateCtl.text.trim().isEmpty) { _snack('Please enter bus plate number', AppColors.error); return; }
                if (brandCtl.text.trim().isEmpty) brandCtl.text = 'Other';
                if (catCtl.text.trim().isEmpty) catCtl.text = 'Standard Coach';
                setDlg(() { _step = 1; _scrollCtl.jumpTo(0); });
              }, style: _nextBtnStyle, child: const Text('Next \u2192')),
            // Step 1 → Generate Grid
            if (_step == 1)
              ElevatedButton(onPressed: () => setDlg(() {
                _grid = List.generate(_rows, (r) {
                  final row = <String>[];
                  for (int c = 0; c < _cols; c++) {
                    row.add(c == _aisleAfter ? 'aisle' : 'seat');
                  }
                  return row;
                });
                _gridBuilt = true;
                _step = 2;
                _scrollCtl.jumpTo(0);
              }), style: _nextBtnStyle, child: const Text('Generate Grid \u2192')),
            // Step 2 → Save
            if (_step == 2)
              ElevatedButton(
                onPressed: _saving ? null : () async {
                  setDlg(() => _saving = true);
                  try {
                    final cells = _grid.asMap().entries.map((re) {
                      final r = re.key; final row = re.value;
                      return row.asMap().entries.map((ce) {
                        final c = ce.key; final type = ce.value;
                        return {
                          'type': type,
                          'label': type == 'seat' || type == 'folding' ? _seatLabel(r, c, cols: _cols, aisleAfter: _aisleAfter) : '',
                          'seat_id': type == 'seat' || type == 'folding' ? _seatLabel(r, c, cols: _cols, aisleAfter: _aisleAfter) : null,
                        };
                      }).toList();
                    }).toList();

                    final res = await ApiService().post('/bus-owner/layouts', data: {
                      'bus_plate': plateCtl.text.trim(),
                      'bus_brand': brandCtl.text.trim().isEmpty ? 'Other' : brandCtl.text.trim(),
                      'bus_category': catCtl.text.trim().isEmpty ? 'Standard Coach' : catCtl.text.trim(),
                      'total_rows': _rows,
                      'total_cols': _cols,
                      'aisle_after_col': _aisleAfter,
                      'grid': cells,
                    });
                    if (res != null && res['success'] == true) {
                      Navigator.pop(ctx);
                      _loadLayouts();
                      _snack('Layout created!', AppColors.success);
                    } else { _snack(res?['message'] ?? 'Failed', AppColors.error); }
                  } catch (e) { _snack('Error: $e', AppColors.error); }
                  setDlg(() => _saving = false);
                },
                style: _nextBtnStyle,
                child: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Save Layout'),
              ),
          ],
        );
      }),
    );
  }

  Widget _miniPreview(int rows, int cols, int aisle) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(color: const Color(0xFF082030), borderRadius: BorderRadius.circular(8)),
    child: Column(children: List.generate(rows, (r) => Padding(padding: const EdgeInsets.only(bottom: 2), child: Row(mainAxisSize: MainAxisSize.min, children: List.generate(cols, (c) => Container(
      width: 22, height: 18, margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: c == aisle ? AppColors.gray500.withValues(alpha: 0.3) : OwnerButtonColors.seats.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(3),
      ),
    )))))),
  );

  Widget _gridCell(String type, String label, bool isAisle, {double width = 44}) => Container(
    width: width, height: 36, margin: const EdgeInsets.all(1.5),
    decoration: BoxDecoration(
      color: type == 'seat' ? OwnerButtonColors.seats.withValues(alpha: 0.55)
          : type == 'folding' ? const Color(0xFFD97706).withValues(alpha: 0.5)
          : type == 'aisle' ? AppColors.gray500.withValues(alpha: 0.25)
          : const Color(0xFF334455).withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: type == 'seat' ? OwnerButtonColors.seats : type == 'folding' ? const Color(0xFFD97706) : type == 'aisle' ? AppColors.gray500.withValues(alpha: 0.4) : const Color(0xFF334455).withValues(alpha: 0.2)),
    ),
    child: Center(child: type == 'seat' || type == 'folding'
        ? Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 9, fontWeight: FontWeight.w600))
        : type == 'aisle' ? const Text('\u2195', style: TextStyle(color: Color(0xFF667788), fontSize: 10)) : null),
  );

  String _seatLabel(int row, int col, {int cols = 4, int aisleAfter = 2}) {
    final letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final rowLetter = row < letters.length ? letters[row] : 'R${row + 1}';
    // Adjust column number to skip aisle
    int seatNum;
    if (col < aisleAfter) {
      seatNum = col + 1;
    } else {
      seatNum = col; // skip the aisle column
    }
    return '$rowLetter$seatNum';
  }

  Widget _leg(String l, Color c) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 12, height: 12, decoration: BoxDecoration(color: c.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(3))), const Gap(4),
    Text(l, style: const TextStyle(color: Color(0xFF8899AA), fontSize: 10)),
  ]);

  Widget _wizardField(String label, String hint, IconData icon, TextEditingController ctl, {List<String>? dropdownItems, void Function(String)? onDropdownSelected}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(color: Color(0xFF8899AA), fontSize: 12, fontWeight: FontWeight.w600)),
    const Gap(4),
    Row(children: [
      Expanded(child: TextField(
        controller: ctl, style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Color(0xFF556677)), prefixIcon: Icon(icon, color: const Color(0xFF556677)), filled: true, fillColor: const Color(0xFF0D1B2A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2A3A4A))), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
      )),
      if (dropdownItems != null && onDropdownSelected != null) ...[const Gap(8), PopupMenuButton<String>(
        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00C49F)),
        color: const Color(0xFF1A2A3A),
        onSelected: onDropdownSelected,
        itemBuilder: (_) => dropdownItems.map((item) => PopupMenuItem(value: item, child: Text(item, style: const TextStyle(color: Colors.white)))).toList(),
      )],
    ]),
  ]);

  Widget _numField(String label, int value, int min, int max, void Function(int) onChanged, {String? hint}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(color: Color(0xFF8899AA), fontSize: 12, fontWeight: FontWeight.w600)),
    if (hint != null) Text(hint, style: const TextStyle(color: Color(0xFF556677), fontSize: 10)),
    const Gap(4),
    Row(children: [
      IconButton(icon: const Icon(Icons.remove, color: Color(0xFF00C49F)), onPressed: value > min ? () => onChanged(value - 1) : null, padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 36, minHeight: 36)),
      Container(width: 48, height: 36, decoration: BoxDecoration(color: const Color(0xFF0D1B2A), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFF2A3A4A))), child: Center(child: Text('$value', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)))),
      IconButton(icon: const Icon(Icons.add, color: Color(0xFF00C49F)), onPressed: value < max ? () => onChanged(value + 1) : null, padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 36, minHeight: 36)),
    ]),
  ]);

  ButtonStyle get _nextBtnStyle => ElevatedButton.styleFrom(backgroundColor: OwnerButtonColors.seats, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)));

  // ═══ SHARED ═══
  Widget _tf(TextEditingController c, String l, {bool obscure = false, bool email = false, bool phone = false, bool number = false, int maxLines = 1}) => TextField(
    controller: c, obscureText: obscure, maxLines: maxLines,
    keyboardType: email ? TextInputType.emailAddress : phone || number ? TextInputType.phone : TextInputType.text,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(labelText: l, labelStyle: const TextStyle(color: Color(0xFF8899AA)), border: const OutlineInputBorder(), enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF2A3A4A))), focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00C49F)))),
  );

  Widget _chip(IconData i, String t) => Row(mainAxisSize: MainAxisSize.min, children: [Icon(i, size: 13, color: AppColors.gray400), SizedBox(width: 3.w), Text(t, style: TextStyle(color: AppColors.gray500, fontSize: 11))]);

  Widget _badge(String s, Color c) => Container(padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h), decoration: BoxDecoration(color: c.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12.r)), child: Text(s.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: c)));

  void _snack(String msg, Color bg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: bg, behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 3)));
  }
}

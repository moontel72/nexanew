// Bus Owner Dashboard — Full Dynamic Seat Layout Generator
// 4-step wizard: Bus Details → Grid Setup → Preview/Edit → Save

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/missile_3d_button.dart';
import 'package:trace_odd/features/bus_operations/presentation/pages/seat_layout_builder_screen.dart';
import 'package:trace_odd/shared/theme/colors.dart';

class OwnerButtonColors {
  static const Color dashboard = Color(0xFF7C3AED);
  static const Color drivers = Color(0xFFDB2777);
  static const Color conductors = Color(0xFFDC2626);
  static const Color seats = Color(0xFF16A34A);
}

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});
  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  String _ownerName = 'Owner', _currentPage = 'dashboard', _companyId = '';
  bool _sidebarOpen = true, _isLoading = true;
  int _driverCount = 0, _conductorCount = 0, _layoutCount = 0;
  List<Map<String, dynamic>> _drivers = [], _conductors = [], _layouts = [];
  bool _driversLoading = true,
      _conductorsLoading = true,
      _layoutsLoading = true;

  // Carrier Link state
  Map<String, dynamic>? _linkStatus;
  bool _linkLoading = false;
  List<Map<String, dynamic>> _busCompanies = [];
  bool _companiesLoading = false;
  String _companySearch = '';
  final _linkMsgCtrl = TextEditingController();

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
    // Fetch company ID from profile
    try {
      final r = await ApiService().get('/bus-owner/profile');
      _companyId = r?['data']?['id']?.toString() ?? '';
    } catch (_) {
      _companyId = '';
    }
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
                  _sec('CARRIER'),
                  Missile3DButton(
                    label: 'Carrier Link',
                    icon: Icons.link_rounded,
                    color: const Color(0xFFF59E0B),
                    onTap: () {
                      setState(() => _currentPage = 'carrier');
                      _loadLinkStatus();
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
              : _currentPage == 'carrier'
              ? _carrierLinkPage()
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
      : _currentPage == 'carrier'
      ? 'Carrier Link'
      : 'Dashboard';
  void _loadAll() {
    _loadDrivers();
    _loadConductors();
    _loadLayouts();
  }

  // ═══════════════════════════════════════════════════════
  // CARRIER LINK
  // ═══════════════════════════════════════════════════════

  Future<void> _loadLinkStatus() async {
    setState(() => _linkLoading = true);
    try {
      final r = await ApiService().get('/bus-owner/link-status');
      if (!mounted) return;
      setState(() {
        _linkStatus = (r?['data'] as Map<String, dynamic>?) ?? {};
        _linkLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _linkLoading = false);
    }
  }

  Future<void> _loadBusCompanies({String search = ''}) async {
    setState(() => _companiesLoading = true);
    try {
      final r = await ApiService().get(
        '/bus-owner/available-companies',
        queryParams: {if (search.isNotEmpty) 'search': search},
      );
      if (!mounted) return;
      final list = (r?['data'] as List?) ?? [];
      setState(() {
        _busCompanies = list
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        _companiesLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _busCompanies = [];
          _companiesLoading = false;
        });
      }
    }
  }

  Future<void> _sendLinkRequest(String carrierId, String carrierName) async {
    try {
      final r = await ApiService().post(
        '/bus-owner/link-request',
        data: {
          'carrier_company_id': carrierId,
          'message': _linkMsgCtrl.text.trim().isNotEmpty
              ? _linkMsgCtrl.text.trim()
              : null,
        },
      );
      if (!mounted) return;
      if (r?['success'] == true) {
        final token = r?['data']?['sender_identity_token'] ?? '?';
        final sender = r?['data']?['sender_name'] ?? '?';
        _snack(
          'Link request sent to $carrierName. Sender: $sender ($token)',
          AppColors.success,
        );
        _linkMsgCtrl.clear();
        _loadLinkStatus();
      } else {
        _snack(r?['message'] ?? 'Failed to send request', AppColors.error);
      }
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      if (msg.contains('409')) {
        _snack('You already have a pending or active link', AppColors.warning);
      } else {
        _snack('Error: $msg', AppColors.error);
      }
    }
  }

  Future<void> _leaveCarrier(String assignmentId, String carrierName) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF162438),
        title: const Text(
          'Leave Carrier?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to leave \'$carrierName\'?\n\n'
          'Your staff and layouts will no longer be visible to them. '
          'You can link with another company afterwards.',
          style: const TextStyle(color: Color(0xFF8899AA)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ApiService().post('/bus-owner/link-request/$assignmentId/leave');
      if (!mounted) return;
      _snack('You have left $carrierName.', AppColors.success);
      _loadLinkStatus();
    } catch (e) {
      if (!mounted) return;
      _snack('Error: $e', AppColors.error);
    }
  }

  Future<void> _cancelLinkRequest(String assignmentId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF162438),
        title: const Text(
          'Cancel Link Request?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to cancel this pending link request?',
          style: TextStyle(color: Color(0xFF8899AA)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('No, Keep It'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ApiService().post('/bus-owner/link-request/$assignmentId/cancel');
      if (!mounted) return;
      _snack('Link request cancelled', AppColors.success);
      _loadLinkStatus();
    } catch (e) {
      if (!mounted) return;
      _snack('Error: $e', AppColors.error);
    }
  }

  // ═══════════════════════════════════════════════════════
  // CARRIER LINK PAGE
  // ═══════════════════════════════════════════════════════

  Widget _carrierLinkPage() {
    if (_linkLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final linked = _linkStatus?['linked'] == true;
    final status = _linkStatus?['status'] as String? ?? 'independent';
    final carrierName = _linkStatus?['carrier_name'] as String? ?? '';
    final assignmentId = _linkStatus?['assignment_id'] as String? ?? '';

    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        // --- Status Banner ---
        if (linked && status == 'active')
          _linkStatusBanner(
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF16A34A),
            title: 'Linked with $carrierName',
            subtitle:
                'Your fleet staff and seat layouts are visible to this carrier.',
            bgColor: const Color(0xFF052E16),
            action: TextButton.icon(
              onPressed: () => _leaveCarrier(assignmentId, carrierName),
              icon: const Icon(Icons.logout_rounded, size: 16),
              label: const Text('Leave Carrier'),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            ),
          ),
        if (linked && status == 'pending_acceptance')
          _linkStatusBanner(
            icon: Icons.hourglass_empty_rounded,
            color: const Color(0xFFF59E0B),
            title: 'Waiting for $carrierName approval...',
            subtitle: 'Your link request is pending review by the bus company.',
            bgColor: const Color(0xFF451A03),
            action: TextButton.icon(
              onPressed: () => _cancelLinkRequest(assignmentId),
              icon: const Icon(Icons.close, size: 16),
              label: const Text('Cancel Request'),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            ),
          ),
        if (linked && status == 'on_hold')
          _linkStatusBanner(
            icon: Icons.pause_circle_rounded,
            color: const Color(0xFFF59E0B),
            title: 'Your link request is ON HOLD',
            subtitle:
                'The company has placed your request on hold. Please contact the company management for updates.',
            bgColor: const Color(0xFF451A03),
            action: TextButton.icon(
              onPressed: () => _cancelLinkRequest(assignmentId),
              icon: const Icon(Icons.close, size: 16),
              label: const Text('Cancel Request'),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            ),
          ),
        if (!linked)
          _linkStatusBanner(
            icon: Icons.link_off_rounded,
            color: const Color(0xFF8899AA),
            title: 'Not Linked to Any Carrier',
            subtitle:
                'Link with a Bus Company to have your fleet managed under their panel.',
            bgColor: const Color(0xFF162438),
          ),

        Gap(24),

        // --- Link to a Company (only when not linked) ---
        if (!linked) ...[
          Text(
            'Select a Bus Company',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          Gap(8),
          Text(
            'Search for an active Bus Company to send a link request.',
            style: TextStyle(color: const Color(0xFF8899AA), fontSize: 12),
          ),
          Gap(12),

          // Search input
          TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search bus company...',
              hintStyle: const TextStyle(color: Color(0xFF556677)),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF556677)),
              filled: true,
              fillColor: const Color(0xFF1A2A3A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF2A3A4A)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF2A3A4A)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF00C49F)),
              ),
            ),
            onChanged: (v) {
              _companySearch = v;
              _loadBusCompanies(search: v);
            },
          ),
          Gap(8),

          // Optional message
          TextField(
            controller: _linkMsgCtrl,
            maxLines: 2,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Optional message to the company...',
              hintStyle: const TextStyle(color: Color(0xFF556677)),
              filled: true,
              fillColor: const Color(0xFF1A2A3A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF2A3A4A)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF2A3A4A)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF00C49F)),
              ),
            ),
          ),
          Gap(12),

          // Company list or loading
          if (_companiesLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_busCompanies.isEmpty)
            Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  _companySearch.isEmpty
                      ? 'Tap search to find companies'
                      : 'No bus companies found',
                  style: const TextStyle(color: Color(0xFF667788)),
                ),
              ),
            )
          else
            ...(_busCompanies.map((company) {
              final cId = (company['id'] ?? '').toString();
              final cName = (company['account_name'] ?? '—').toString();
              final cEmail = (company['email'] ?? '').toString();
              final cStatus = (company['status'] ?? 'active').toString();

              return Card(
                color: const Color(0xFF1A2A3A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: EdgeInsets.only(bottom: 8.h),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(
                          0xFFF59E0B,
                        ).withValues(alpha: 0.15),
                        child: const Icon(
                          Icons.directions_bus,
                          color: Color(0xFFF59E0B),
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              cName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              cEmail.isNotEmpty ? cEmail : 'No email',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF667788),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      ElevatedButton.icon(
                        onPressed: () => _sendLinkRequest(cId, cName),
                        icon: const Icon(Icons.send_rounded, size: 14),
                        label: const Text(
                          'Link',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B),
                          foregroundColor: Colors.white,
                          minimumSize: Size.zero,
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            })),
        ],

        // --- Show linked info ---
        if (linked) ...[
          Gap(16),
          Card(
            color: const Color(0xFF1A2A3A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Link Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Gap(10),
                  _linkDetailRow(
                    Icons.business_rounded,
                    'Carrier',
                    carrierName,
                  ),
                  _linkDetailRow(
                    Icons.info_outline,
                    'Status',
                    status.replaceAll('_', ' ').toUpperCase(),
                  ),
                  if (_linkStatus?['linked_at'] != null)
                    _linkDetailRow(
                      Icons.calendar_today_rounded,
                      'Since',
                      _linkStatus!['linked_at'].toString(),
                    ),
                  Gap(8),
                  if (status == 'active')
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF052E16),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Color(0xFF16A34A),
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Your drivers, conductors, and layouts are visible to this carrier via the Fleet Panel.',
                              style: TextStyle(
                                color: Color(0xFF86EFAC),
                                fontSize: 11,
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
        ],
      ],
    );
  }

  Widget _linkStatusBanner({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required Color bgColor,
    Widget? action,
  }) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Gap(4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF8899AA),
                    fontSize: 12,
                  ),
                ),
                if (action != null) ...[Gap(8), action],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _linkDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF8899AA)),
          SizedBox(width: 8.w),
          Text(
            '$label: ',
            style: const TextStyle(color: Color(0xFF667788), fontSize: 12),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
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
          '$_driverCount drivers • $_conductorCount conductors • $_layoutCount layouts',
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
        // Two separate buttons — same as Bus Company admin panel
        Missile3DButton(
          label: 'Add New Layout',
          icon: Icons.add,
          color: const Color(0xFF0891B2),
          height: 56,
          onTap: _openLayoutDesigner,
        ),
        Gap(8),
        Missile3DButton(
          label: 'View All Layouts ($_layoutCount)',
          icon: Icons.event_seat,
          color: OwnerButtonColors.seats,
          height: 56,
          onTap: () {
            setState(() {
              _currentPage = 'layouts';
              _loadLayouts();
            });
          },
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
          _drivers = (d?['data'] as List? ?? [])
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
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
          _conductors = (d?['data'] as List? ?? [])
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
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
        // Old API format: {success: true, data: [...]}
        _layouts = d
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      } else if (d is Map) {
        // New paginated format: {success: true, data: {data: [...], ...}}
        final list = d['data'];
        if (list is List) {
          _layouts = list
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        } else {
          _layouts = [];
        }
      } else {
        _layouts = [];
      }
      _layoutCount = _layouts.length;
    } catch (e) {
      _layouts = [];
      _layoutCount = 0;
    } finally {
      _layoutsLoading = false;
      if (mounted) setState(() {});
    }
  }

  Future<void> _publishLayout(String id, String name) async {
    try {
      await ApiService().post('/bus-owner/layouts/$id/publish');
      _loadLayouts();
      _snack('$name published', AppColors.success);
    } catch (e) {
      _snack('Error: $e', AppColors.error);
    }
  }

  Future<void> _archiveLayout(String id, String name) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF162438),
        title: const Text(
          'Archive Layout?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Archive "$name"? It can be restored later.',
          style: const TextStyle(color: Color(0xFF8899AA)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ApiService().delete('/bus-owner/layouts/$id');
      _loadLayouts();
      _snack('$name archived', AppColors.success);
    } catch (e) {
      _snack('Error: $e', AppColors.error);
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

  Widget _layoutsPage() {
    if (_layoutsLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_layouts.isEmpty) {
      return Center(
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
              onPressed: _openLayoutDesigner,
              icon: Icon(Icons.add),
              label: Text('Create Your First Layout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: OwnerButtonColors.seats,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }
    return Stack(
      children: [
        ListView.builder(
          padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 80.h),
          itemCount: _layouts.length,
          itemBuilder: (_, i) => _layoutCard(_layouts[i]),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: _openLayoutDesigner,
            icon: Icon(Icons.add),
            label: Text('New Layout'),
            backgroundColor: OwnerButtonColors.seats,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _layoutCard(Map<String, dynamic> l) {
    try {
      final sn = l['current_snapshot'] is Map
          ? l['current_snapshot'] as Map<String, dynamic>
          : null;
      final plate =
          (l['bus_plate'] ?? sn?['bus_plate'] ?? l['vehicle_class'] ?? '')
              .toString();
      final seats =
          (sn?['total_seats'] ??
          sn?['metadata']?['total_bookable_seats'] ??
          l['total_seats'] ??
          0);
      final rows = (sn?['total_rows'] ?? l['total_rows'] ?? 0);
      final cols = (sn?['total_cols'] ?? l['total_cols'] ?? 0);
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
              _badge(
                status,
                status == 'published'
                    ? const Color(0xFF16A34A)
                    : status == 'draft'
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFF8899AA),
              ),
              SizedBox(width: 4.w),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Color(0xFF8899AA), size: 20),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text(
                      'Design Layout',
                      style: TextStyle(color: Color(0xFF0891B2)),
                    ),
                  ),
                  if (status == 'draft')
                    PopupMenuItem(
                      value: 'publish',
                      child: Text(
                        'Publish',
                        style: TextStyle(color: Color(0xFF16A34A)),
                      ),
                    ),
                  PopupMenuItem(
                    value: 'archive',
                    child: Text(
                      'Archive',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
                onSelected: (v) {
                  if (v == 'edit') _openLayoutDesigner(layoutId: id);
                  if (v == 'publish') _publishLayout(id, name);
                  if (v == 'archive') _archiveLayout(id, name);
                },
              ),
            ],
          ),
        ),
      );
    } catch (_) {
      return const SizedBox.shrink();
    }
  }

  // ═══ OPEN BUILDER (blank slate, no presets) ═══
  void _openLayoutDesigner({String? layoutId}) async {
    if (_companyId.isEmpty) {
      _snack('Company ID not available. Please reload.', AppColors.error);
      return;
    }
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SeatLayoutBuilderScreen(
          companyId: _companyId,
          companyName: _ownerName,
          layoutId: layoutId,
        ),
      ),
    );
    if (mounted && result == true) _loadLayouts();
  }

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

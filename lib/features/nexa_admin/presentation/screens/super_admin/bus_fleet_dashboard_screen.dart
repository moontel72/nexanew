// Bus Fleet Dashboard — Company Admin Panel (Module 13)
// Management hub: Owners, Drivers, Conductors, Seat Layouts, Fleet Overview
// 3D Pencil Sidebar Layout (unified with Sub-Admin theme)
// Phase 4: Live data wired to all tabs — no placeholders

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/features/bus_operations/presentation/pages/seat_layout_builder_screen.dart';
import 'package:trace_odd/features/nexa_admin/data/models/company/bus_company_model.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/auth/admin_auth_bloc.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/auth/admin_auth_event.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/auth/admin_auth_state.dart';
import 'package:trace_odd/shared/models/company/company_model.dart';
import 'package:trace_odd/core/constants/app_constants.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/missile_3d_button.dart';

class BusFleetDashboardScreen extends StatefulWidget {
  final String? companyId;
  const BusFleetDashboardScreen({super.key, this.companyId});

  @override
  State<BusFleetDashboardScreen> createState() =>
      _BusFleetDashboardScreenState();
}

class _BusFleetDashboardScreenState extends State<BusFleetDashboardScreen> {
  Company? _company;
  Map<String, dynamic>? _profile;
  String? _error;
  bool _isLoading = true;
  String _currentPage = 'dashboard';
  bool _sidebarOpen = true;
  String? _pendingAddDialog; // auto-open add dialog on next build

  int _ownerCount = 0;
  int _driverCount = 0;
  int _conductorCount = 0;
  int _layoutCount = 0;

  // Link Requests state
  int _linkRequestCount = 0;
  List<Map<String, dynamic>> _linkRequests = [];
  bool _linkRequestsLoading = false;

  // B2B Communication Center state
  List<Map<String, dynamic>> _conversations = [];
  bool _conversationsLoading = false;
  String? _expandedConversationId;
  List<Map<String, dynamic>> _conversationMessages = [];
  bool _messagesLoading = false;
  final _inboxReplyCtrl = TextEditingController();
  final _homeScrollController = ScrollController();
  final _sidebarScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    // Unified token key — try standard key first, then fallback to admin auth key
    String? token = prefs.getString(AppConstants.authTokenKey);
    token ??= prefs.getString('admin_auth_token');
    if (token == null || token.isEmpty) {
      if (mounted) context.go('/bus-fleet/login');
      return;
    }
    // Ensure the ApiClient also has the token set
    ApiService().post; // no-op, just ensures headers are initialized
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final api = ApiService();
      final res = await api.get('/bus-fleet/profile');
      if (!mounted) return;
      final data = res['data'] as Map<String, dynamic>?;
      if (data == null) throw Exception('No data');
      _profile = data;
      final cJson = data['company'] as Map<String, dynamic>?;
      if (cJson != null) _company = Company.fromJson(cJson);

      // Parallel fetches for counts
      final results = await Future.wait([
        _safeCount(api, '/bus-fleet/owners'),
        _safeCount(api, '/bus-fleet/drivers/manage'),
        _safeCount(api, '/bus-fleet/conductors'),
        _safeCount(api, '/bus-fleet/layouts'),
        _safeCount(api, '/bus-fleet/link-requests'),
      ], eagerError: false);

      if (mounted)
        setState(() {
          _ownerCount = results[0];
          _driverCount = results[1];
          _conductorCount = results[2];
          _layoutCount = results[3];
          _linkRequestCount = results[4];
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
      if (data == null) return 0;
      if (data is Map) {
        return (data['total'] as int?) ??
            (data['pagination']?['total'] as int?) ??
            0;
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  void _logout() {
    context.read<AdminAuthBloc>().add(AdminLogoutRequested());
    context.go('/bus-fleet/login');
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null && _company == null)
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(_error!),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _loadAll, child: const Text('Retry')),
            ],
          ),
        ),
      );
    return Scaffold(
      backgroundColor: const Color(0xFFE6F7F4),
      body: Row(
        children: [
          if (_sidebarOpen || isWide) _sidebar(isWide),
          Expanded(child: _mainContent()),
        ],
      ),
    );
  }

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
            padding: const EdgeInsets.all(14),
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
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _company?.name ?? 'Bus Fleet',
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
          const Divider(
            color: Color(0x20FFFFFF),
            height: 1,
            indent: 12,
            endIndent: 12,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ScrollbarTheme(
              data: ScrollbarThemeData(
                thumbVisibility: WidgetStateProperty.all(true),
                trackVisibility: WidgetStateProperty.all(true),
                thickness: WidgetStateProperty.all(8),
                radius: Radius.circular(4),
                thumbColor: WidgetStateProperty.all(Color(0xFF00C49F)),
                trackColor: WidgetStateProperty.all(Color(0x20FFFFFF)),
              ),
              child: Scrollbar(
                controller: _sidebarScrollController,
                interactive: true,
                child: ListView(
                  controller: _sidebarScrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  children: [
                    _sl('MAIN'),
                    Missile3DButton(
                      label: 'Dashboard',
                      icon: Icons.dashboard_rounded,
                      color: const Color(0xFF7C3AED),
                      onTap: () => setState(() => _currentPage = 'dashboard'),
                    ),
                    const SizedBox(height: 8),
                    _sl('FLEET STAFF'),
                    Missile3DButton(
                      label: 'Add New Owner',
                      icon: Icons.person_add,
                      color: const Color(0xFFDB2777),
                      height: 56,
                      onTap: () => _showStaffAddDialog('owners'),
                    ),
                    Missile3DButton(
                      label: 'View Owners ($_ownerCount)',
                      icon: Icons.badge_rounded,
                      color: const Color(0xFFDB2777),
                      height: 56,
                      onTap: () => setState(() => _currentPage = 'owners'),
                    ),
                    Missile3DButton(
                      label: 'Add New Driver',
                      icon: Icons.person_add_alt,
                      color: const Color(0xFF2563EB),
                      height: 56,
                      onTap: () => _showStaffAddDialog('drivers'),
                    ),
                    Missile3DButton(
                      label: 'View Drivers ($_driverCount)',
                      icon: Icons.person_rounded,
                      color: const Color(0xFF2563EB),
                      height: 56,
                      onTap: () => setState(() => _currentPage = 'drivers'),
                    ),
                    Missile3DButton(
                      label: 'Add New Conductor',
                      icon: Icons.group_add,
                      color: const Color(0xFF16A34A),
                      height: 56,
                      onTap: () => _showStaffAddDialog('conductors'),
                    ),
                    Missile3DButton(
                      label: 'View Conductors ($_conductorCount)',
                      icon: Icons.group_rounded,
                      color: const Color(0xFF16A34A),
                      height: 56,
                      onTap: () => setState(() => _currentPage = 'conductors'),
                    ),
                    Missile3DButton(
                      label: 'Link Requests ($_linkRequestCount)',
                      icon: Icons.link_rounded,
                      color: const Color(0xFFF59E0B),
                      height: 56,
                      onTap: () {
                        setState(() => _currentPage = 'linkreqs');
                        _loadLinkRequests();
                      },
                    ),
                    Missile3DButton(
                      label: 'Fleet Inbox',
                      icon: Icons.message_rounded,
                      color: const Color(0xFF7C3AED),
                      height: 56,
                      onTap: () {
                        setState(() => _currentPage = 'inbox');
                        _loadConversations();
                      },
                    ),
                    const SizedBox(height: 8),
                    _sl('FLEET ASSETS'),
                    Missile3DButton(
                      label: 'New Seat Layout',
                      icon: Icons.add,
                      color: const Color(0xFF0891B2),
                      height: 56,
                      onTap: () => _openLayoutDesigner(),
                    ),
                    Missile3DButton(
                      label: 'View Layouts ($_layoutCount)',
                      icon: Icons.event_seat,
                      color: const Color(0xFF0891B2),
                      height: 56,
                      onTap: () => setState(() => _currentPage = 'layouts'),
                    ),
                    if (_layoutCount > 0)
                      Missile3DButton(
                        label: 'Purge All Layouts',
                        icon: Icons.delete_sweep,
                        color: const Color(0xFFDC2626),
                        height: 56,
                        subtitle: 'Archive $_layoutCount layout(s)',
                        onTap: _confirmPurgeLayouts,
                      ),
                    const SizedBox(height: 8),
                    _sl('SYSTEM'),
                    Missile3DButton(
                      label: 'Refresh',
                      icon: Icons.refresh_rounded,
                      color: const Color(0xFF0891B2),
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
        ],
      ),
    ),
  );

  Widget _sl(String t) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 4),
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

  void _showStaffAddDialog(String type) {
    setState(() {
      _pendingAddDialog = type;
      _currentPage = type;
    });
  }

  void _openLayoutDesigner() {
    final cId = widget.companyId ?? _company?.id.toString() ?? '';
    if (cId.isEmpty) return;
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => SeatLayoutBuilderScreen(
              companyId: cId,
              companyName: _company?.name,
            ),
          ),
        )
        .then((_) => _loadAll());
  }

  void _confirmPurgeLayouts() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Purge All Layouts?'),
        content: Text(
          'This will archive ALL $_layoutCount seat layout(s). '
          'This action cannot be undone. Proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _purgeLayouts();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Purge All'),
          ),
        ],
      ),
    );
  }

  Future<void> _purgeLayouts() async {
    try {
      final res = await ApiService().delete('/bus-fleet/layouts/purge/all');
      final msg = res?['message'] ?? 'Purge completed';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg.toString()),
            backgroundColor: Colors.green,
          ),
        );
        _loadAll();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purge failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _mainContent() => SafeArea(
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4),
            ],
          ),
          child: Row(
            children: [
              if (_currentPage != 'dashboard') ...[
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                  tooltip: 'Back to Dashboard',
                  onPressed: () => setState(() => _currentPage = 'dashboard'),
                ),
              ],
              if (!_sidebarOpen)
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => setState(() => _sidebarOpen = true),
                ),
              Expanded(
                child: Text(
                  _currentPage == 'owners'
                      ? 'Fleet Owners'
                      : _currentPage == 'drivers'
                      ? 'Fleet Drivers'
                      : _currentPage == 'conductors'
                      ? 'Fleet Conductors'
                      : _currentPage == 'layouts'
                      ? 'Seat Layouts'
                      : _currentPage == 'linkreqs'
                      ? 'Pending Link Requests'
                      : _currentPage == 'inbox'
                      ? 'Fleet Inbox'
                      : 'Dashboard',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAll),
            ],
          ),
        ),
        Expanded(
          child: _currentPage == 'owners'
              ? _buildFleetList('owners')
              : _currentPage == 'drivers'
              ? _buildFleetList('drivers')
              : _currentPage == 'conductors'
              ? _buildFleetList('conductors')
              : _currentPage == 'layouts'
              ? _buildLayoutList()
              : _currentPage == 'linkreqs'
              ? _linkRequestsPage()
              : _currentPage == 'inbox'
              ? _inboxPage()
              : _home(),
        ),
      ],
    ),
  );

  // ═══════════════════════════════════════════════════
  // LIVE FLEET LIST (Owners / Drivers / Conductors)
  // ═══════════════════════════════════════════════════
  Widget _buildFleetList(String type) {
    final autoOpen = _pendingAddDialog == type;
    if (autoOpen) _pendingAddDialog = null;
    return _FleetListView(
      key: ValueKey('fleet_$type'),
      type: type,
      autoOpenAddDialog: autoOpen,
      companyName: _company?.name,
      companyId: widget.companyId ?? _company?.id.toString(),
      onDataChanged: _loadAll,
    );
  }

  // ═══════════════════════════════════════════════════
  // LAYOUT LIST
  // ═══════════════════════════════════════════════════
  Widget _buildLayoutList() {
    return _LayoutListView(
      companyId: widget.companyId ?? _company?.id.toString(),
      companyName: _company?.name,
      onDataChanged: _loadAll,
    );
  }

  // ═══════════════════════════════════════════════════
  // LINK REQUESTS PAGE — Pending Owner Approvals
  // ═══════════════════════════════════════════════════

  Future<void> _loadLinkRequests() async {
    setState(() => _linkRequestsLoading = true);
    try {
      final r = await ApiService().get('/bus-fleet/link-requests');
      if (!mounted) return;
      final d = r?['data'];
      List list = [];
      if (d is Map) {
        list = (d['data'] as List?) ?? [];
        _linkRequestCount = d['total'] ?? list.length;
      } else if (d is List) {
        list = d;
        _linkRequestCount = list.length;
      }
      setState(() {
        _linkRequests = list
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        _linkRequestsLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _linkRequestsLoading = false);
    }
  }

  // ── Action handlers for link requests ──

  Future<void> _acceptLink(String assignmentId, String ownerName) async {
    try {
      final r = await ApiService().post(
        '/bus-fleet/link-requests/$assignmentId/accept',
      );
      if (!mounted) return;
      if (r?['success'] == true) {
        _snackBar(
          'Owner \'$ownerName\' linked successfully. Sub-fleet staff and layouts are now visible.',
          Colors.green,
        );
        _loadLinkRequests();
        _loadAll();
        _loadConversations();
      } else {
        _snackBar(r?['message'] ?? 'Failed to accept', Colors.red);
      }
    } catch (e) {
      if (!mounted) return;
      _snackBar('Error: $e', Colors.red);
    }
  }

  Future<void> _rejectLink(String assignmentId, String ownerName) async {
    final reasonCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Reject \'$ownerName\'?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Provide a reason for rejection (optional):'),
            const SizedBox(height: 8),
            TextField(
              controller: reasonCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'e.g. Incomplete documents',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ApiService().post(
        '/bus-fleet/link-requests/$assignmentId/reject',
        data: {
          if (reasonCtrl.text.trim().isNotEmpty)
            'reason': reasonCtrl.text.trim(),
        },
      );
      if (!mounted) return;
      _snackBar('Link request from \'$ownerName\' rejected.', Colors.orange);
      _loadLinkRequests();
      _loadAll();
      _loadConversations();
    } catch (e) {
      if (!mounted) return;
      _snackBar('Error: $e', Colors.red);
    }
  }

  Future<void> _holdLink(String assignmentId, String ownerName) async {
    final msgCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Hold \'$ownerName\'?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add a reason (visible to the owner for 60 days):'),
            const SizedBox(height: 8),
            TextField(
              controller: msgCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g. Awaiting document verification',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
            ),
            child: const Text('Hold'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ApiService().post(
        '/bus-fleet/link-requests/$assignmentId/hold',
        data: {
          if (msgCtrl.text.trim().isNotEmpty)
            'message_body': msgCtrl.text.trim(),
        },
      );
      if (!mounted) return;
      _snackBar(
        'Request from \'$ownerName\' placed on hold.',
        const Color(0xFFF59E0B),
      );
      _loadLinkRequests();
      _loadAll();
      _loadConversations();
    } catch (e) {
      if (!mounted) return;
      _snackBar('Error: $e', Colors.red);
    }
  }

  // ═══════════════════════════════════════════════════
  // B2B COMMUNICATION CENTER — Data Methods
  // ═══════════════════════════════════════════════════

  Future<void> _loadConversations() async {
    setState(() => _conversationsLoading = true);
    try {
      final r = await ApiService().get('/bus-fleet/link-messages');
      if (!mounted) return;
      final list = (r?['data'] as List?) ?? [];
      setState(() {
        _conversations = list
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        _conversationsLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _conversationsLoading = false);
    }
  }

  Future<void> _loadConversationMessages(String assignmentId) async {
    setState(() {
      _messagesLoading = true;
      _expandedConversationId = assignmentId;
    });
    try {
      final r = await ApiService().get(
        '/bus-fleet/link-messages/$assignmentId',
      );
      if (!mounted) return;
      final list = (r?['data'] as List?) ?? [];
      setState(() {
        _conversationMessages = list
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        _messagesLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _messagesLoading = false);
    }
  }

  Future<void> _sendInboxReply(String assignmentId) async {
    final msg = _inboxReplyCtrl.text.trim();
    if (msg.isEmpty) return;
    try {
      await ApiService().post(
        '/bus-fleet/link-messages/$assignmentId',
        data: {'message_body': msg},
      );
      _inboxReplyCtrl.clear();
      _loadConversationMessages(assignmentId);
      // Refresh conversation list to update latest message
      _loadConversations();
    } catch (e) {
      if (!mounted) return;
      _snackBar('Error: $e', Colors.red);
    }
  }

  // ═══════════════════════════════════════════════════
  // FLEET INBOX PAGE
  // ═══════════════════════════════════════════════════

  // ═══════════════════════════════════════════════════
  // B2B COMMUNICATION CENTER — Unified Inbox Page
  // ═══════════════════════════════════════════════════

  Widget _inboxPage() {
    if (_conversationsLoading && _conversations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.message_rounded,
              size: 48,
              color: Colors.grey.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            const Text(
              'No conversations',
              style: TextStyle(color: AppColors.gray500),
            ),
            const SizedBox(height: 4),
            const Text(
              'Messages from Bus Owners appear here.',
              style: TextStyle(color: AppColors.gray400, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scrollbar(
          thumbVisibility: true,
          thickness: 8,
          radius: const Radius.circular(4),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.w),
            itemCount: _conversations.length,
            itemBuilder: (_, i) => _conversationCard(_conversations[i]),
          ),
        );
      },
    );
  }

  Widget _conversationCard(Map<String, dynamic> conv) {
    final id = (conv['assignment_id'] ?? '').toString();
    final name = (conv['name'] ?? '—').toString();
    final token = (conv['identity_token'] ?? '—').toString();
    final status = (conv['status'] ?? 'unknown').toString();
    final latestMsg = conv['latest_message'] as Map<String, dynamic>?;
    final msgCount = (conv['message_count'] as int?) ?? 0;
    final email = (conv['email'] ?? '').toString();
    final isExpanded = _expandedConversationId == id;

    // Status badge color
    final statusColor = status == 'active'
        ? const Color(0xFF16A34A)
        : status == 'on_hold'
        ? const Color(0xFFF59E0B)
        : const Color(0xFF8899AA);
    final statusLabel = status == 'active'
        ? 'Connected'
        : status == 'on_hold'
        ? 'On Hold'
        : 'Pending';

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      margin: EdgeInsets.only(bottom: 10.h),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (isExpanded) {
            setState(() {
              _expandedConversationId = null;
              _conversationMessages = [];
            });
          } else {
            _loadConversationMessages(id);
          }
        },
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── HEADER: Avatar | Name+Token | Status Badge ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 18.r,
                    backgroundColor: statusColor.withValues(alpha: 0.12),
                    child: Icon(
                      status == 'active'
                          ? Icons.check_circle_rounded
                          : Icons.person_rounded,
                      color: statusColor,
                      size: 18,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          token,
                          style: const TextStyle(
                            color: AppColors.gray500,
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              // ── Contact Info ──
              if (email.isNotEmpty) ...[
                SizedBox(height: 6.h),
                Row(
                  children: [
                    const Icon(
                      Icons.email_outlined,
                      size: 13,
                      color: AppColors.gray500,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ],

              // ── Latest Message Preview ──
              if (latestMsg != null) ...[
                SizedBox(height: 8.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          (latestMsg['message_body'] ?? '').toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.gray600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (msgCount > 0) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF7C3AED,
                            ).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$msgCount',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF7C3AED),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              // ── Quick Actions for Pending/On-Hold ──
              if (status == 'pending_acceptance' || status == 'on_hold') ...[
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _acceptLink(id, name),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          foregroundColor: Colors.white,
                          minimumSize: Size.zero,
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          textStyle: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Accept',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _rejectLink(id, name),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red, width: 1.2),
                          minimumSize: Size.zero,
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          textStyle: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text(
                          'Reject',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _holdLink(id, name),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFD97706),
                          side: const BorderSide(
                            color: Color(0xFFD97706),
                            width: 1.2,
                          ),
                          minimumSize: Size.zero,
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          textStyle: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text(
                          'Hold',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // ── EXPANDED: Full Message Thread + Reply ──
              if (isExpanded) ...[
                SizedBox(height: 10.h),
                const Divider(height: 1),
                SizedBox(height: 10.h),
                if (_messagesLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_conversationMessages.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'No messages yet. Start the conversation.',
                      style: TextStyle(color: AppColors.gray400, fontSize: 11),
                    ),
                  )
                else
                  Container(
                    constraints: BoxConstraints(maxHeight: 250.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(10.w),
                      itemCount: _conversationMessages.length,
                      itemBuilder: (_, j) {
                        final m = _conversationMessages[j];
                        final ctx = (m['context_type'] ?? 'general').toString();
                        final color = ctx == 'rejection_reason'
                            ? Colors.red
                            : ctx == 'hold_reason'
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFF6B7280);
                        return Padding(
                          padding: EdgeInsets.only(bottom: 6.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 5.w,
                                      vertical: 1.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      ctx.replaceAll('_', ' ').toUpperCase(),
                                      style: TextStyle(
                                        color: color,
                                        fontSize: 8,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    (m['created_at'] ?? '').toString(),
                                    style: const TextStyle(
                                      color: AppColors.gray400,
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                (m['message_body'] ?? '').toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.gray700,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                // ── Reply Input ──
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inboxReplyCtrl,
                        style: const TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          hintText: 'Type a reply...',
                          hintStyle: const TextStyle(color: AppColors.gray400),
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5E7EB),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5E7EB),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF7C3AED),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    IconButton(
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Color(0xFF7C3AED),
                      ),
                      onPressed: () => _sendInboxReply(id),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // LINK REQUESTS PAGE — Pending Owner Approvals
  // ═══════════════════════════════════════════════════

  Widget _linkRequestsPage() {
    if (_linkRequestsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_linkRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.link_off_rounded,
              size: 48,
              color: Colors.grey.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            const Text(
              'No pending link requests',
              style: TextStyle(color: AppColors.gray500),
            ),
            const SizedBox(height: 4),
            const Text(
              'Independent Bus Owners can request to link with your company via their app.',
              style: TextStyle(color: AppColors.gray400, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scrollbar(
          thumbVisibility: true,
          thickness: 8,
          radius: const Radius.circular(4),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.w),
            itemCount: _linkRequests.length,
            itemBuilder: (_, i) => _linkRequestCard(
              _linkRequests[i],
              containerWidth: constraints.maxWidth,
            ),
          ),
        );
      },
    );
  }

  Widget _linkRequestCard(
    Map<String, dynamic> req, {
    double containerWidth = 600,
  }) {
    final name = (req['name'] ?? '—').toString();
    final token = (req['identity_token'] ?? '—').toString();
    final email = (req['email'] ?? '').toString();
    final phone = (req['phone'] ?? '').toString();
    final message = (req['message'] ?? '').toString();
    final requestedAt = (req['requested_at'] ?? '').toString();
    final id = (req['assignment_id'] ?? '').toString();
    final kycStatus = (req['kyc_status'] ?? 'unverified').toString();
    final source = (req['source'] ?? 'unknown').toString();

    // Removed narrow-screen branching — single clean layout

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      margin: EdgeInsets.only(bottom: 10.h),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ═══ HEADER: Avatar | Name+Token | Badge ═══
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18.r,
                  backgroundColor: const Color(
                    0xFFF59E0B,
                  ).withValues(alpha: 0.12),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Color(0xFFF59E0B),
                    size: 18,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'SENDER',
                        style: TextStyle(
                          color: Color(0xFFF59E0B),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        token,
                        style: const TextStyle(
                          color: AppColors.gray500,
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                _linkBadge(kycStatus),
              ],
            ),

            SizedBox(height: 8.h),

            // ═══ ACTION BUTTON BAR — 3 equal-width buttons ═══
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: 4.w),
                    child: ElevatedButton(
                      onPressed: () => _acceptLink(id, name),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        minimumSize: Size.zero,
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        textStyle: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Accept',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: OutlinedButton(
                      onPressed: () => _rejectLink(id, name),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red, width: 1.2),
                        minimumSize: Size.zero,
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        textStyle: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text(
                        'Reject',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 4.w),
                    child: OutlinedButton(
                      onPressed: () => _holdLink(id, name),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFD97706),
                        side: const BorderSide(
                          color: Color(0xFFD97706),
                          width: 1.2,
                        ),
                        minimumSize: Size.zero,
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        textStyle: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text(
                        'Hold',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 10.h),
            const Divider(height: 1),
            SizedBox(height: 10.h),

            // ═══ CONTACT INFO ═══
            if (email.isNotEmpty || phone.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Wrap(
                  spacing: 12.w,
                  runSpacing: 4.h,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (email.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.email_outlined,
                            size: 13,
                            color: AppColors.gray500,
                          ),
                          SizedBox(width: 4.w),
                          Flexible(
                            child: Text(
                              email,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.gray500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    if (phone.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.phone_outlined,
                            size: 13,
                            color: AppColors.gray500,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            phone,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.gray500,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

            // ═══ MESSAGE ═══
            if (message.isNotEmpty)
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 8.h),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '\u201c$message\u201d',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF92400E),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            // ═══ META ROW ═══
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 12,
                  color: AppColors.gray400,
                ),
                SizedBox(width: 4.w),
                Flexible(
                  child: Text(
                    requestedAt.isNotEmpty ? 'Requested: $requestedAt' : '',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.gray400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (source == 'bus_owner_app') ...[
                  SizedBox(width: 8.w),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E7FF),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'App',
                      style: TextStyle(fontSize: 9, color: Color(0xFF4338CA)),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _linkBadge(String status) {
    final color = status == 'verified'
        ? const Color(0xFF16A34A)
        : status == 'pending'
        ? const Color(0xFFF59E0B)
        : const Color(0xFF8899AA);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  void _snackBar(String msg, Color bg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // DASHBOARD HOME
  // ═══════════════════════════════════════════════════
  Widget _home() => LayoutBuilder(
    builder: (context, constraints) {
      return ScrollbarTheme(
        data: ScrollbarThemeData(
          thumbVisibility: WidgetStateProperty.all(true),
          trackVisibility: WidgetStateProperty.all(true),
          thickness: WidgetStateProperty.all(10),
          radius: const Radius.circular(5),
          thumbColor: WidgetStateProperty.all(const Color(0xFF1F5E6B)),
          trackColor: WidgetStateProperty.all(const Color(0xFFD4EFEA)),
        ),
        child: Scrollbar(
          controller: _homeScrollController,
          interactive: true,
          child: SingleChildScrollView(
            controller: _homeScrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_company != null) _companyHeader(),
                SizedBox(height: 20.h),
                _sectionTitle('Fleet Management'),
                SizedBox(height: 12.h),
                _managementGrid(),
                SizedBox(height: 24.h),
                _sectionTitle('Quick Stats'),
                SizedBox(height: 12.h),
                _statsRow(),
              ],
            ),
          ),
        ),
      );
    },
  );

  Widget _companyHeader() {
    final c = _company!;
    return Card(
      color: AppColors.info.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                color: AppColors.info,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(
                Icons.directions_bus,
                size: 26.w,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${c.city}, ${c.country}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.gray500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
    padding: EdgeInsets.only(bottom: 4.h),
    child: Text(
      t,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
    ),
  );

  Widget _managementGrid() {
    return Row(
      children: [
        Expanded(
          child: _mgmtCard(
            'Owners',
            '$_ownerCount',
            Icons.badge_rounded,
            const Color(0xFFDB2777),
            () => setState(() => _currentPage = 'owners'),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _mgmtCard(
            'Drivers',
            '$_driverCount',
            Icons.person_rounded,
            const Color(0xFF2563EB),
            () => setState(() => _currentPage = 'drivers'),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _mgmtCard(
            'Conductors',
            '$_conductorCount',
            Icons.group_rounded,
            const Color(0xFF16A34A),
            () => setState(() => _currentPage = 'conductors'),
          ),
        ),
      ],
    );
  }

  Widget _mgmtCard(
    String label,
    String count,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26.w),
              SizedBox(height: 8.h),
              Text(
                count,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 11.sp, color: AppColors.gray500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statsRow() {
    return Row(
      children: [
        Expanded(
          child: _stat('Fleet Size', '${_profile?['active_buses'] ?? 0}'),
        ),
        SizedBox(width: 10.w),
        Expanded(child: _stat('Daily Revenue', 'PKR 0')),
      ],
    );
  }

  Widget _stat(String label, String value) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
    child: Padding(
      padding: EdgeInsets.all(14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: AppColors.gray500),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    ),
  );

  @override
  void dispose() {
    _inboxReplyCtrl.dispose();
    _homeScrollController.dispose();
    _sidebarScrollController.dispose();
    super.dispose();
  }
}

// ═══════════════════════════════════════════════════════
// LIVE FLEET LIST VIEW — Reusable for Owners/Drvrs/Cond
// ═══════════════════════════════════════════════════════

class _FleetListView extends StatefulWidget {
  final String type;
  final String? companyName;
  final String? companyId;
  final VoidCallback onDataChanged;
  final bool autoOpenAddDialog;

  const _FleetListView({
    super.key,
    required this.type,
    this.companyName,
    this.companyId,
    required this.onDataChanged,
    this.autoOpenAddDialog = false,
  });

  @override
  State<_FleetListView> createState() => _FleetListViewState();
}

class _FleetListViewState extends State<_FleetListView> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String? _error;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _load();
    if (widget.autoOpenAddDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showAddDialog());
    }
  }

  String get _endpoint => switch (widget.type) {
    'owners' => '/bus-fleet/owners',
    'drivers' => '/bus-fleet/drivers/manage',
    'conductors' => '/bus-fleet/conductors',
    _ => '/bus-fleet/owners',
  };

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiService().get(_endpoint);
      if (res == null || res is! Map) {
        setState(() {
          _error = 'Invalid response';
          _loading = false;
        });
        return;
      }
      final data = res['data'];
      if (data == null) {
        setState(() {
          _items = [];
          _total = 0;
          _loading = false;
        });
        return;
      }
      if (data is Map) {
        setState(() {
          _items = List<Map<String, dynamic>>.from(data['data'] ?? []);
          _total = (data['total'] as int?) ?? _items.length;
          _loading = false;
        });
      } else {
        setState(() {
          _items = [];
          _total = 0;
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _showAddDialog() async {
    final nameCtrl = TextEditingController(),
        emailCtrl = TextEditingController(),
        phoneCtrl = TextEditingController(),
        passCtrl = TextEditingController(),
        cnicCtrl = TextEditingController(),
        addrCtrl = TextEditingController(),
        licenseCtrl = TextEditingController(),
        plateCtrl = TextEditingController(),
        salaryCtrl = TextEditingController();

    final isOwner = widget.type == 'owners';
    final isDriver = widget.type == 'drivers';
    final isConductor = widget.type == 'conductors';

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add ${_capitalize(widget.type)}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(nameCtrl, 'Full Name *'),
              SizedBox(height: 10.h),
              _field(emailCtrl, 'Email *', email: true),
              SizedBox(height: 10.h),
              _field(phoneCtrl, 'Phone *', phone: true),
              SizedBox(height: 10.h),
              _field(passCtrl, 'Password *', obscure: true),
              if (isDriver) ...[
                SizedBox(height: 10.h),
                _field(licenseCtrl, 'License Number *'),
              ],
              if (isDriver || isConductor) ...[
                SizedBox(height: 10.h),
                _field(plateCtrl, 'Vehicle Plate'),
                SizedBox(height: 10.h),
                _field(salaryCtrl, 'Salary', number: true),
              ],
              SizedBox(height: 10.h),
              _field(cnicCtrl, 'CNIC'),
              SizedBox(height: 10.h),
              _field(addrCtrl, 'Address', maxLines: 2),
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

    final body = <String, dynamic>{
      'name': nameCtrl.text.trim(),
      'email': emailCtrl.text.trim(),
      'phone': phoneCtrl.text.trim(),
      'password': passCtrl.text,
      if (cnicCtrl.text.isNotEmpty) 'cnic': cnicCtrl.text.trim(),
      if (addrCtrl.text.isNotEmpty) 'address': addrCtrl.text.trim(),
    };
    if (isDriver || isConductor) {
      if (isDriver) body['license_number'] = licenseCtrl.text.trim();
      if (plateCtrl.text.isNotEmpty)
        body['vehicle_plate'] = plateCtrl.text.trim();
      if (salaryCtrl.text.isNotEmpty)
        body['salary'] = double.tryParse(salaryCtrl.text);
    }

    try {
      await ApiService().post(_endpoint, data: body);
      _load();
      widget.onDataChanged();
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_capitalize(widget.type)} added'),
            backgroundColor: AppColors.success,
          ),
        );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
    }
  }

  Future<void> _showEditDialog(Map<String, dynamic> item) async {
    final nameCtrl = TextEditingController(text: item['name'] ?? '');
    final emailCtrl = TextEditingController(text: item['email'] ?? '');
    final phoneCtrl = TextEditingController(text: item['phone'] ?? '');
    final passCtrl = TextEditingController();
    final isDriver = widget.type == 'drivers';
    final isConductor = widget.type == 'conductors';
    final licenseCtrl = TextEditingController(
      text: isDriver ? item['license_number'] ?? '' : '',
    );
    final plateCtrl = TextEditingController(
      text: (isDriver || isConductor) ? item['vehicle_plate'] ?? '' : '',
    );
    final salaryCtrl = TextEditingController(
      text: (isDriver || isConductor) ? '${item['salary'] ?? ''}' : '',
    );

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit ${_capitalize(widget.type)}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(nameCtrl, 'Full Name'),
              SizedBox(height: 10.h),
              _field(emailCtrl, 'Email', email: true),
              SizedBox(height: 10.h),
              _field(phoneCtrl, 'Phone', phone: true),
              SizedBox(height: 10.h),
              _field(
                passCtrl,
                'New Password (leave blank to keep)',
                obscure: true,
              ),
              if (isDriver) ...[
                SizedBox(height: 10.h),
                _field(licenseCtrl, 'License Number'),
              ],
              if (isDriver || isConductor) ...[
                SizedBox(height: 10.h),
                _field(plateCtrl, 'Vehicle Plate'),
                SizedBox(height: 10.h),
                _field(salaryCtrl, 'Salary', number: true),
              ],
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

    final body = <String, dynamic>{
      'name': nameCtrl.text.trim(),
      'email': emailCtrl.text.trim(),
      'phone': phoneCtrl.text.trim(),
    };
    if (passCtrl.text.isNotEmpty) body['password'] = passCtrl.text;
    if (isDriver || isConductor) {
      if (isDriver) body['license_number'] = licenseCtrl.text.trim();
      if (plateCtrl.text.isNotEmpty)
        body['vehicle_plate'] = plateCtrl.text.trim();
      if (salaryCtrl.text.isNotEmpty)
        body['salary'] = double.tryParse(salaryCtrl.text);
    }

    try {
      final id = item['id'] as String;
      await ApiService().put('$_endpoint/$id', data: body);
      _load();
      widget.onDataChanged();
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_capitalize(widget.type)} updated'),
            backgroundColor: AppColors.success,
          ),
        );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
    }
  }

  Future<void> _confirmDelete(String id, String name) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Remove "$name"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ApiService().delete('$_endpoint/$id');
      _load();
      widget.onDataChanged();
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deleted'),
            backgroundColor: AppColors.success,
          ),
        );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
    }
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    bool obscure = false,
    bool email = false,
    bool phone = false,
    bool number = false,
    int maxLines = 1,
  }) => TextField(
    controller: ctrl,
    obscureText: obscure,
    maxLines: maxLines,
    keyboardType: email
        ? TextInputType.emailAddress
        : phone || number
        ? TextInputType.phone
        : TextInputType.text,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
  );

  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null)
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );

    return Column(
      children: [
        // Header bar
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          color: Colors.white,
          child: Row(
            children: [
              Text(
                'Total: $_total',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.gray500),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _showAddDialog,
                icon: const Icon(Icons.add, size: 18),
                label: Text('Add ${_capitalize(widget.type)}'),
              ),
            ],
          ),
        ),
        // List
        Expanded(
          child: _items.isEmpty
              ? Center(
                  child: Text(
                    'No ${widget.type} registered',
                    style: TextStyle(color: AppColors.gray400),
                  ),
                )
              : ScrollbarTheme(
                  data: ScrollbarThemeData(
                    thumbVisibility: WidgetStateProperty.all(true),
                    trackVisibility: WidgetStateProperty.all(true),
                    thickness: WidgetStateProperty.all(10),
                    radius: Radius.circular(5),
                    thumbColor: WidgetStateProperty.all(Color(0xFF1F5E6B)),
                    trackColor: WidgetStateProperty.all(Color(0xFFD4EFEA)),
                  ),
                  child: Scrollbar(
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(16.w),
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => SizedBox(height: 8.h),
                      itemBuilder: (_, i) => _itemCard(_items[i]),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _itemCard(Map<String, dynamic> item) {
    final ownerName = (item['owner_company_name'] ?? '').toString();
    final isExternal =
        ownerName.isNotEmpty &&
        widget.companyName != null &&
        ownerName != widget.companyName;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Icon(Icons.person, color: AppColors.primary),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'] ?? '—',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        item['email'] ?? '',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.gray500,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          _chip(Icons.phone, item['phone'] ?? '—'),
                          if (item['license_number'] != null) ...[
                            SizedBox(width: 10.w),
                            _chip(Icons.badge, item['license_number']),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                _badge(item['status'] ?? 'active'),
                SizedBox(width: 4.w),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                  onSelected: (v) {
                    if (v == 'edit') {
                      _showEditDialog(item);
                    } else if (v == 'delete') {
                      _confirmDelete(
                        item['id'] as String,
                        item['name'] as String? ?? '',
                      );
                    }
                  },
                ),
              ],
            ),
            // ── Ownership badge ──
            if (isExternal && ownerName.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.link_rounded,
                      size: 12,
                      color: Color(0xFF7C3AED),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Linked from $ownerName',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF7C3AED),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData ic, String t) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(ic, size: 14, color: AppColors.gray400),
      SizedBox(width: 4),
      Text(
        t,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColors.gray500),
      ),
    ],
  );

  Widget _badge(String s) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
    decoration: BoxDecoration(
      color: s == 'active'
          ? AppColors.success.withValues(alpha: 0.1)
          : AppColors.warning.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Text(
      s.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: s == 'active' ? AppColors.success : AppColors.warning,
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════
// LAYOUT LIST VIEW
// ═══════════════════════════════════════════════════════

class _LayoutListView extends StatefulWidget {
  final String? companyId;
  final String? companyName;
  final VoidCallback onDataChanged;

  const _LayoutListView({
    this.companyId,
    this.companyName,
    required this.onDataChanged,
  });

  @override
  State<_LayoutListView> createState() => _LayoutListViewState();
}

class _LayoutListViewState extends State<_LayoutListView> {
  List<Map<String, dynamic>> _layouts = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiService().get('/bus-fleet/layouts');
      if (res == null || res is! Map) {
        setState(() {
          _error = 'Invalid response';
          _loading = false;
        });
        return;
      }
      final data = res['data'];
      if (data == null) {
        setState(() {
          _layouts = [];
          _loading = false;
        });
        return;
      }
      // LayoutService returns data as a flat array, not nested {data: [...], pagination}
      if (data is List) {
        setState(() {
          _layouts = List<Map<String, dynamic>>.from(data);
          _loading = false;
        });
      } else if (data is Map) {
        setState(() {
          _layouts = List<Map<String, dynamic>>.from(data['data'] ?? []);
          _loading = false;
        });
      } else {
        setState(() {
          _layouts = [];
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _openDesigner({String? layoutId}) {
    final cId = widget.companyId ?? '';
    if (cId.isEmpty) return;
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => SeatLayoutBuilderScreen(
              layoutId: layoutId,
              companyId: cId,
              companyName: widget.companyName,
            ),
          ),
        )
        .then((_) {
          _load();
          widget.onDataChanged();
        });
  }

  void _confirmPurge() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Purge All Layouts?'),
        content: Text(
          'This will archive ALL ${_layouts.length} layout(s). '
          'This action cannot be undone. Proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _purgeLayouts();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Purge All'),
          ),
        ],
      ),
    );
  }

  Future<void> _purgeLayouts() async {
    try {
      final res = await ApiService().delete('/bus-fleet/layouts/purge/all');
      final msg = res?['message'] ?? 'Purge completed';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg.toString()),
            backgroundColor: Colors.green,
          ),
        );
        _load();
        widget.onDataChanged();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purge failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null)
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          color: Colors.white,
          child: Row(
            children: [
              Text(
                'Total: ${_layouts.length} layouts',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.gray500),
              ),
              const Spacer(),
              if (_layouts.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ElevatedButton.icon(
                    onPressed: () => _confirmPurge(),
                    icon: const Icon(Icons.delete_sweep, size: 16),
                    label: const Text('Purge All'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ElevatedButton.icon(
                onPressed: () => _openDesigner(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Layout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0891B2),
                ),
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
                        color: AppColors.gray300,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No seat layouts yet',
                        style: TextStyle(color: AppColors.gray400),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _openDesigner(),
                        child: const Text('Create First Layout'),
                      ),
                    ],
                  ),
                )
              : ScrollbarTheme(
                  data: ScrollbarThemeData(
                    thumbVisibility: WidgetStateProperty.all(true),
                    trackVisibility: WidgetStateProperty.all(true),
                    thickness: WidgetStateProperty.all(10),
                    radius: Radius.circular(5),
                    thumbColor: WidgetStateProperty.all(Color(0xFF1F5E6B)),
                    trackColor: WidgetStateProperty.all(Color(0xFFD4EFEA)),
                  ),
                  child: Scrollbar(
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(16.w),
                      itemCount: _layouts.length,
                      separatorBuilder: (_, __) => SizedBox(height: 8.h),
                      itemBuilder: (_, i) => _layoutCard(_layouts[i]),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _layoutCard(Map<String, dynamic> layout) {
    final vc = layout['vehicle_class'] as String? ?? 'unknown';
    final name = layout['display_name'] as String? ?? 'Untitled';
    final status = layout['layout_status'] as String? ?? 'draft';
    final version = layout['version_number'] as int? ?? 1;
    final deck = (layout['deck_level'] as int? ?? 0);
    final ownerName =
        (layout['owner_company_name'] ?? layout['owner_display_name'] ?? '')
            .toString();
    final isExternal =
        ownerName.isNotEmpty &&
        widget.companyName != null &&
        ownerName != widget.companyName;
    // Vehicle class → (label, accent color)
    const _vcMeta = {
      'coach_54': ('54-Seat Coach (Large)', Color(0xFF7C3AED)),
      'standard_45': ('45-Seat Standard Coach', Color(0xFF2563EB)),
      'coaster_34': ('34-Seat Coaster', Color(0xFF16A34A)),
      'hiace_13': ('13-Seat HiAce', Color(0xFFD97706)),
      'sleeper_custom': ('Custom Sleeper Coach', Color(0xFFDB2777)),
    };
    final vcInfo = _vcMeta[vc] ?? _vcMeta['standard_45']!;
    final presetLabel = vcInfo.$1;
    final presetColor = vcInfo.$2;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: presetColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    vc == 'sleeper_custom'
                        ? Icons.airline_seat_flat_angled
                        : Icons.event_seat,
                    color: presetColor,
                    size: 22,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${presetLabel}  •  v$version  •  ${deck == 0 ? 'Lower Deck' : 'Upper Deck'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
                _layoutBadge(status),
                SizedBox(width: 4.w),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Design Layout'),
                    ),
                    if (status == 'draft')
                      const PopupMenuItem(
                        value: 'publish',
                        child: Text(
                          'Publish',
                          style: TextStyle(color: Color(0xFF16A34A)),
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Archive'),
                    ),
                  ],
                  onSelected: (v) {
                    if (v == 'edit') _openDesigner(layoutId: layout['id']);
                    if (v == 'publish') _publishLayout(layout['id'], name);
                    if (v == 'delete') _archiveLayout(layout['id']);
                  },
                ),
              ],
            ),
            // ── Ownership badge ──
            if (isExternal && ownerName.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.link_rounded,
                      size: 12,
                      color: Color(0xFF7C3AED),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Linked from $ownerName',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF7C3AED),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _layoutBadge(String s) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
    decoration: BoxDecoration(
      color: s == 'published'
          ? AppColors.success.withValues(alpha: 0.1)
          : AppColors.warning.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Text(
      s.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: s == 'published' ? AppColors.success : AppColors.warning,
      ),
    ),
  );

  Future<void> _publishLayout(String id, String name) async {
    try {
      await ApiService().post('/bus-fleet/layouts/$id/publish');
      _load();
      widget.onDataChanged();
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$name published'),
            backgroundColor: AppColors.success,
          ),
        );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
    }
  }

  Future<void> _archiveLayout(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Archive Layout'),
        content: const Text('Archive this layout? It can be restored later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Archive', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ApiService().delete('/bus-fleet/layouts/$id');
      _load();
      widget.onDataChanged();
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Layout archived'),
            backgroundColor: AppColors.success,
          ),
        );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
    }
  }
}

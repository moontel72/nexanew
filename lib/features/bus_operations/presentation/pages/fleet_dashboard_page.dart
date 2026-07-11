// Fleet Dashboard Page — thin BLoC-driven root for bus-fleet panel
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/fleet_dashboard/fleet_dashboard_bloc.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/fleet_dashboard/fleet_dashboard_event.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/fleet_dashboard/fleet_dashboard_state.dart';
import 'package:trace_odd/features/bus_operations/presentation/pages/bus_config_setup_screen.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/missile_3d_button.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/add_staff_dialog.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/dashboard_kpi_section.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/chat_inbox_section.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/fleet_carrier_link_section.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/layout_list_section.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/staff_list_section.dart';
import 'package:trace_odd/features/nexa_admin/presentation/screens/super_admin/bus_fleet/route_scheduler_screen.dart';
import 'package:trace_odd/features/nexa_admin/presentation/screens/super_admin/bus_fleet/ticket_management_screen.dart';
import 'package:trace_odd/features/nexa_admin/presentation/screens/super_admin/bus_fleet/voucher_management_screen.dart';
import 'package:trace_odd/features/nexa_admin/presentation/screens/super_admin/bus_fleet/bonus_management_screen.dart';
import 'package:trace_odd/features/storekeeper/presentation/screens/storekeeper_dashboard_screen.dart';
import 'package:trace_odd/features/storekeeper/presentation/screens/storekeeper_management_screen.dart';
import 'package:trace_odd/features/storekeeper/presentation/screens/storekeeper_activity_log_screen.dart';
import 'package:trace_odd/features/storekeeper/presentation/screens/storekeeper_settlement_report_screen.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/dispatch/fleet_dispatch_bloc.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/fleet_dispatch_dialog.dart';
import 'package:trace_odd/core/services/api_service.dart';

abstract class FleetColors {
  static const bg = Color(0xFF0D1B2A);
  static const card = Color(0xFF1A2A3A);
  static const drivers = Color(0xFF00B4D8);
  static const conductors = Color(0xFF7C3AED);
  static const seats = Color(0xFF2563EB);
}

class FleetDashboardPage extends StatelessWidget {
  final String storagePrefix;
  final String panelPrefix;
  final String loginRoute;

  const FleetDashboardPage({
    super.key,
    required this.storagePrefix,
    required this.panelPrefix,
    required this.loginRoute,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FleetDashboardBloc()
        ..add(
          BootstrapDashboard(
            storagePrefix: storagePrefix,
            panelPrefix: panelPrefix,
            loginRoute: loginRoute,
          ),
        ),
      child: const _FleetDashboardView(),
    );
  }
}

class _FleetDashboardView extends StatelessWidget {
  const _FleetDashboardView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FleetDashboardBloc, FleetDashboardState>(
      builder: (ctx, state) {
        if (state.status == FleetDashboardStatus.loading) {
          return const Scaffold(
            backgroundColor: FleetColors.bg,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final bloc = ctx.read<FleetDashboardBloc>();
        final wide = MediaQuery.of(ctx).size.width > 900;

        // ── Load data on page change ──
        _loadDataForPage(bloc, state.currentPage);

        if (state.staffActionError != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(state.staffActionError!),
                backgroundColor: Colors.redAccent,
              ),
            );
            bloc.add(const ClearStaffError());
          });
        }

        return Scaffold(
          backgroundColor: FleetColors.bg,
          body: Row(
            children: [
              if (wide) _SidebarWidget(bloc: bloc, state: state),
              Expanded(child: _pageContent(ctx, bloc, state)),
            ],
          ),
        );
      },
    );
  }

  Widget _pageContent(
    BuildContext ctx,
    FleetDashboardBloc bloc,
    FleetDashboardState state,
  ) {
    switch (state.currentPage) {
      case 'drivers':
        return StaffListSection(
          title: 'Bus Drivers',
          accentColor: FleetColors.drivers,
          icon: Icons.badge,
          items: state.drivers,
          isLoading: state.driversLoading,
          emptyMessage: 'No drivers registered',
          onAdd: () => _openAddStaff(ctx, bloc, 'driver'),
          onRemove: (id, name) => _confirmRemove(ctx, bloc, id, name, 'driver'),
        );
      case 'conductors':
        return StaffListSection(
          title: 'Conductors / Cabin Crew',
          accentColor: FleetColors.conductors,
          icon: Icons.group,
          items: state.conductors,
          isLoading: state.conductorsLoading,
          emptyMessage: 'No conductors registered',
          onAdd: () => _openAddStaff(ctx, bloc, 'conductor'),
          onRemove: (id, name) =>
              _confirmRemove(ctx, bloc, id, name, 'conductor'),
        );
      case 'layouts':
        return LayoutListSection(
          layouts: state.layouts,
          isLoading: state.layoutsLoading,
          isMutating: state.isLayoutMutating,
          onPublish: (id, name) => _showPublishConfirm(ctx, bloc, id, name),
          onArchive: (id, name) => _showArchiveConfirm(ctx, bloc, id, name),
          onDelete: (id, name) => _showDeleteConfirm(ctx, bloc, id, name),
          onEdit: (id, name) => _openExistingLayoutDesigner(ctx, state, id),
          onAdd: () => _openLayoutDesigner(ctx, state),
          onPurgeAll: () => _showPurgeConfirm(ctx, bloc, state.layouts.length),
        );
      case 'carrier':
        return FleetCarrierLinkSection(
          incomingRequests: state.incomingRequests,
          linkedCarriers: state.linkedCarriers,
          isLoading: state.linkLoading,
          onAccept: (id) => bloc.add(
            AcceptCarrierRequest(panelPrefix: '/bus-fleet', assignmentId: id),
          ),
          onReject: (id) => bloc.add(
            RejectCarrierRequest(panelPrefix: '/bus-fleet', assignmentId: id),
          ),
          onUnlink: (id, name) => _showUnlinkConfirm(ctx, bloc, id, name),
        );
      case 'inbox':
        return ChatInboxSection(
          conversations: state.inboxConversations,
          activeMessages: state.activeChatMessages,
          isLoading: state.inboxLoading,
          isSending: state.chatSending,
          expandedId: state.expandedConversationId,
          error: state.chatError,
          onExpand: (id) => bloc.add(
            LoadConversation(panelPrefix: '/bus-fleet', assignmentId: id),
          ),
          onSend: (id, msg) => bloc.add(
            SendChatMessage(
              panelPrefix: '/bus-fleet',
              assignmentId: id,
              message: msg,
            ),
          ),
        );
      case 'routes':
        return RouteSchedulerScreen(panelPrefix: '/bus-fleet');
      case 'tickets':
        return TicketManagementScreen(panelPrefix: '/bus-fleet');
      case 'vouchers':
        return VoucherManagementScreen(panelPrefix: '/bus-fleet');
      case 'bonuses':
        return BonusManagementScreen(panelPrefix: '/bus-fleet');
      case 'storekeepers':
        return const StorekeeperManagementScreen();
      case 'catering':
        return const StorekeeperDashboardScreen(
          isStorekeeperOnly: false,
          panel: 'bus-fleet',
        );
      case 'activity_log':
        return const StorekeeperActivityLogScreen();
      case 'settlement':
        return const StorekeeperSettlementReportScreen();
      case 'dispatch_create':
        // Immediately show the FleetDispatchDialog modal.
        // The dialog wraps its own FleetDispatchBloc provider.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FleetDispatchDialog.show(
            ctx,
            apiPrefix: '/bus-fleet',
            onSaved: () {
              // Navigate to active assignments after saving
              bloc.add(const NavigateToPage('dispatch_list'));
            },
          );
        });
        return _homeTab(ctx, bloc, state);
      case 'dispatch_list':
        return BlocProvider(
          create: (_) =>
              FleetDispatchBloc()..add(InitDispatch(apiPrefix: '/bus-fleet')),
          child: const _DispatchListPage(),
        );
      default:
        return _homeTab(ctx, bloc, state);
    }
  }

  Widget _homeTab(
    BuildContext ctx,
    FleetDashboardBloc bloc,
    FleetDashboardState state,
  ) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(16.w),
      children: [
        Text(
          'Welcome, ${state.ownerName}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        Gap(4),
        Text(
          '${state.driverCount} drivers · ${state.conductorCount} conductors · ${state.layoutCount} vehicles',
          style: const TextStyle(color: Color(0xFF8899AA), fontSize: 13),
        ),
        Gap(24),
        DashboardKpiSection(
          driverCount: state.driverCount,
          conductorCount: state.conductorCount,
          layoutCount: state.layoutCount,
          onDriversTap: () => bloc.add(const NavigateToPage('drivers')),
          onConductorsTap: () => bloc.add(const NavigateToPage('conductors')),
          onLayoutsTap: () => bloc.add(const NavigateToPage('layouts')),
        ),
        Gap(24),
        _missileBtn(
          '+ Add New Vehicle',
          Icons.add,
          const Color(0xFF0891B2),
          () => _openLayoutDesigner(ctx, state),
        ),
        Gap(12),
        _missileBtn(
          'View All Vehicles (${state.layoutCount})',
          Icons.directions_bus,
          FleetColors.seats,
          () => bloc.add(const NavigateToPage('layouts')),
        ),
      ],
    );
  }

  Widget _missileBtn(
    String label,
    IconData icon,
    Color color,
    VoidCallback tap,
  ) {
    return GestureDetector(
      onTap: tap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.3),
              color.withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(width: 10.w),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openAddStaff(
    BuildContext ctx,
    FleetDashboardBloc bloc,
    String role,
  ) async {
    final data = await AddStaffDialog.show(
      ctx,
      title: role == 'driver' ? 'Add Bus Driver' : 'Add Conductor',
    );
    if (data != null) {
      bloc.add(
        RegisterStaff(panelPrefix: '/bus-fleet', role: role, data: data),
      );
    }
  }

  Future<void> _confirmRemove(
    BuildContext ctx,
    FleetDashboardBloc bloc,
    String id,
    String name,
    String role,
  ) async {
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF1B2838),
        title: const Text(
          'Remove Staff',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Remove "$name"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
    if (ok == true) {
      bloc.add(RemoveStaff(panelPrefix: '/bus-fleet', staffId: id, role: role));
    }
  }

  // ── Layout actions ─────────────────────────────────

  void _openLayoutDesigner(BuildContext ctx, FleetDashboardState state) {
    // First show BusConfigSetupScreen to capture vehicle details,
    // then proceed to the canvas designer.
    Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (_) => BusConfigSetupScreen(
          companyId: state.companyId,
          companyName: state.ownerName,
          apiPrefix: '/bus-fleet',
        ),
      ),
    );
  }

  void _openExistingLayoutDesigner(
    BuildContext ctx,
    FleetDashboardState state,
    String layoutId,
  ) {
    // Open the Bus Configuration form FIRST, pre-populated with existing
    // vehicle data, then proceed to the layout designer canvas.
    Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (_) => BusConfigSetupScreen(
          companyId: state.companyId,
          companyName: state.ownerName,
          apiPrefix: '/bus-fleet',
          layoutId: layoutId,
        ),
      ),
    );
  }

  Future<void> _showPublishConfirm(
    BuildContext ctx,
    FleetDashboardBloc bloc,
    String id,
    String name,
  ) async {
    final ok = await _confirm(
      ctx,
      'Publish Layout',
      'Publish "$name" to make it live?',
    );
    if (ok == true)
      bloc.add(
        PublishLayout(panelPrefix: '/bus-fleet', layoutId: id, name: name),
      );
  }

  Future<void> _showArchiveConfirm(
    BuildContext ctx,
    FleetDashboardBloc bloc,
    String id,
    String name,
  ) async {
    final ok = await _confirm(
      ctx,
      'Archive Layout',
      'Archive "$name"? It can be restored later.',
    );
    if (ok == true)
      bloc.add(
        ArchiveLayout(panelPrefix: '/bus-fleet', layoutId: id, name: name),
      );
  }

  Future<void> _showDeleteConfirm(
    BuildContext ctx,
    FleetDashboardBloc bloc,
    String id,
    String name,
  ) async {
    final ok = await _confirm(
      ctx,
      'Delete Layout',
      'Permanently delete "$name"? This cannot be undone.',
    );
    if (ok == true)
      bloc.add(
        DeleteLayout(panelPrefix: '/bus-fleet', layoutId: id, name: name),
      );
  }

  Future<void> _showPurgeConfirm(
    BuildContext ctx,
    FleetDashboardBloc bloc,
    int count,
  ) async {
    final ok = await _confirm(
      ctx,
      'Purge All Layouts',
      'Archive ALL $count vehicles? This cannot be undone.',
    );
    if (ok == true) bloc.add(const PurgeAllLayouts(panelPrefix: '/bus-fleet'));
  }

  Future<bool?> _confirm(BuildContext ctx, String title, String msg) {
    return showDialog<bool>(
      context: ctx,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF162438),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(msg, style: const TextStyle(color: Color(0xFF8899AA))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  // ── Page navigation side-effects ────────────────────

  void _loadDataForPage(FleetDashboardBloc bloc, String page) {
    switch (page) {
      case 'carrier':
        if (!bloc.state.linkLoading &&
            bloc.state.incomingRequests.isEmpty &&
            bloc.state.linkedCarriers.isEmpty) {
          bloc.add(const LoadCarrierLink(panelPrefix: '/bus-fleet'));
        }
        break;
      case 'inbox':
        if (!bloc.state.inboxLoading && bloc.state.inboxConversations.isEmpty) {
          bloc.add(const LoadInboxMessages(panelPrefix: '/bus-fleet'));
        }
        break;
    }
  }

  Future<void> _showUnlinkConfirm(
    BuildContext ctx,
    FleetDashboardBloc bloc,
    String id,
    String name,
  ) async {
    final ok = await _confirm(
      ctx,
      'Terminate Link',
      'Unlink "$name" from your fleet? Their staff will no longer be visible.',
    );
    if (ok == true)
      bloc.add(UnlinkCarrier(panelPrefix: '/bus-fleet', assignmentId: id));
  }
}

// ── Sidebar Widget ────────────────────────────────────────

class _SidebarWidget extends StatelessWidget {
  final FleetDashboardBloc bloc;
  final FleetDashboardState state;
  const _SidebarWidget({required this.bloc, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Color(0xFF1A3A5C),
        border: Border(right: BorderSide(color: Color(0x20FFFFFF))),
      ),
      child: Column(
        children: [
          const Gap(16),
          // Profile header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00B4D8), Color(0xFF0077B6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00B4D8).withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.directions_bus,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.ownerName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        'BUS FLEET',
                        style: TextStyle(
                          color: Color(0xFFBDD8DB),
                          fontSize: 9,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(12),
          const Divider(height: 1, color: Color(0x20FFFFFF)),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 4),
              children: [
                _sec('DASHBOARD'),
                _pencil(
                  'Dashboard',
                  Icons.dashboard,
                  'dashboard',
                  const Color(0xFF7C3AED),
                ),
                _sec('FLEET MANAGEMENT'),
                _pencil(
                  'Drivers',
                  Icons.badge,
                  'drivers',
                  const Color(0xFF00B4D8),
                ),
                _pencil(
                  'Conductors',
                  Icons.group,
                  'conductors',
                  const Color(0xFF7C3AED),
                ),
                _pencil(
                  'Vehicles',
                  Icons.directions_bus,
                  'layouts',
                  const Color(0xFF2563EB),
                ),
                _sec('OPERATIONS'),
                _pencil(
                  'Route Scheduler',
                  Icons.alt_route_rounded,
                  'routes',
                  const Color(0xFF16A34A),
                ),
                _pencil(
                  'Ticket Management',
                  Icons.confirmation_num_rounded,
                  'tickets',
                  const Color(0xFFDB2777),
                ),
                _pencil(
                  'Vouchers',
                  Icons.card_giftcard,
                  'vouchers',
                  const Color(0xFFD97706),
                ),
                _pencil(
                  'Staff Bonuses',
                  Icons.emoji_events,
                  'bonuses',
                  const Color(0xFF0891B2),
                ),
                _sec('LIVE DISPATCH & DUTY'),
                _pencil(
                  'Create Assignment',
                  Icons.assignment_add,
                  'dispatch_create',
                  const Color(0xFF059669),
                ),
                _pencil(
                  'Active Assignments',
                  Icons.list_alt,
                  'dispatch_list',
                  const Color(0xFF0EA5E9),
                ),
                _sec('CARRIER'),
                _pencil(
                  'Carrier Link',
                  Icons.link_rounded,
                  'carrier',
                  const Color(0xFF4F46E5),
                ),
                _pencil(
                  'Inbox',
                  Icons.message_rounded,
                  'inbox',
                  const Color(0xFF059669),
                ),
                _sec('STOREKEEPER'),
                _pencil(
                  'Storekeepers',
                  Icons.inventory_2_rounded,
                  'storekeepers',
                  const Color(0xFFDC2626),
                ),
                _pencil(
                  'Catering',
                  Icons.restaurant_menu,
                  'catering',
                  const Color(0xFFF97316),
                ),
                _pencil(
                  'Activity Logs',
                  Icons.receipt_long_rounded,
                  'activity_log',
                  const Color(0xFF6366F1),
                ),
                _pencil(
                  'Settlement Reports',
                  Icons.account_balance_wallet,
                  'settlement',
                  const Color(0xFF14B8A6),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0x20FFFFFF)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Missile3DButton(
              label: 'Logout',
              icon: Icons.logout,
              color: const Color(0xFFDC2626),
              height: 48,
              onTap: () => bloc.add(
                LogoutRequested(
                  storagePrefix: state.ownerName.isNotEmpty
                      ? state.ownerName
                      : 'busFleet',
                ),
              ),
            ),
          ),
          const Gap(8),
        ],
      ),
    );
  }

  Widget _pencil(String label, IconData icon, String page, Color color) {
    return Missile3DButton(
      label: label,
      icon: icon,
      color: color,
      height: state.currentPage == page ? 64 : 56,
      onTap: () => bloc.add(NavigateToPage(page)),
    );
  }

  Widget _sec(String label) => Padding(
    padding: const EdgeInsets.fromLTRB(14, 12, 16, 4),
    child: Text(
      label,
      style: const TextStyle(
        color: Color(0xFFBDD8DB),
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
      ),
    ),
  );
}

// ── Dispatch List Page ────────────────────────────────────

class _DispatchListPage extends StatefulWidget {
  const _DispatchListPage();
  @override
  State<_DispatchListPage> createState() => _DispatchListPageState();
}

class _DispatchListPageState extends State<_DispatchListPage> {
  List<Map<String, dynamic>> _assignments = [];
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
      final api = ApiService();
      final r = await api.get('/bus-fleet/dispatch/assignments');
      final d = r?['data'];
      setState(() {
        _assignments = d is List ? d.cast<Map<String, dynamic>>() : [];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FleetColors.bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1628),
        title: const Text(
          'Active Assignments',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () {
            // Navigate back to the dispatch_create page to trigger the dialog
            // when the user returns to Create Assignment.
            context.read<FleetDashboardBloc>().add(
              const NavigateToPage('dispatch_create'),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF00B4D8)),
            tooltip: 'Create Assignment',
            onPressed: () {
              FleetDispatchDialog.show(
                context,
                apiPrefix: '/bus-fleet',
                onSaved: () => _load(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white54),
            tooltip: 'Refresh',
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.redAccent,
                  ),
                  const Gap(12),
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(12),
                  ElevatedButton(onPressed: _load, child: const Text('Retry')),
                ],
              ),
            )
          : _assignments.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.assignment,
                    size: 64,
                    color: Colors.white.withOpacity(0.15),
                  ),
                  const Gap(16),
                  const Text(
                    'No Active Assignments',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                  const Gap(8),
                  ElevatedButton.icon(
                    onPressed: () {
                      FleetDispatchDialog.show(
                        context,
                        apiPrefix: '/bus-fleet',
                        onSaved: () => _load(),
                      );
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Create First Assignment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B4D8),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _assignments.length,
              itemBuilder: (_, i) {
                final a = _assignments[i];
                final vehicle = a['vehicle_plate']?.toString() ?? '—';
                final route = a['route_name']?.toString() ?? '—';
                final driver = a['driver_name']?.toString() ?? '—';
                final conductor = a['conductor_name']?.toString();
                final shift = a['shift']?.toString() ?? '—';
                final status = a['status']?.toString() ?? 'active';

                return Card(
                  color: const Color(0xFF1A3A5C),
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.directions_bus,
                              color: Color(0xFF00B4D8),
                              size: 20,
                            ),
                            const Gap(8),
                            Expanded(
                              child: Text(
                                vehicle,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: status == 'active'
                                    ? const Color(0xFF16A34A).withOpacity(0.2)
                                    : const Color(0xFFF97316).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  color: status == 'active'
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFFF97316),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Gap(6),
                        _infoRow(Icons.route, 'Route', route),
                        _infoRow(Icons.person, 'Driver', driver),
                        if (conductor != null && conductor.isNotEmpty)
                          _infoRow(Icons.group, 'Conductor', conductor),
                        _infoRow(Icons.schedule, 'Shift', shift),
                        const Gap(6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _actionBtn(
                              Icons.edit,
                              'Edit',
                              const Color(0xFF2563EB),
                              () => _editAssignment(a),
                            ),
                            const Gap(8),
                            _actionBtn(
                              Icons.delete_outline,
                              'Delete',
                              Colors.redAccent,
                              () => _deleteAssignment(a),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF8899AA)),
          const Gap(6),
          Text(
            '$label: ',
            style: const TextStyle(color: Color(0xFF8899AA), fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 13),
      label: Text(label, style: const TextStyle(fontSize: 11)),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _editAssignment(Map<String, dynamic> a) {
    FleetDispatchDialog.show(
      context,
      apiPrefix: '/bus-fleet',
      assignmentId: a['id']?.toString(),
      initialData: {
        'vehicle_id': a['vehicle_id'],
        'route_id': a['route_id'],
        'driver_id': a['driver_id'],
        'conductor_id': a['conductor_id'],
        'relief_driver_id': a['relief_driver_id'],
        'relief_conductor_id': a['relief_conductor_id'],
        'shift': a['shift'],
        'return_type': a['return_type'],
        'date_from': a['date_from'],
        'date_to': a['date_to'],
      },
      onSaved: () => _load(),
    );
  }

  Future<void> _deleteAssignment(Map<String, dynamic> a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF162438),
        title: const Text(
          'Delete Assignment',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Delete assignment for ${a['driver_name'] ?? '—'}?',
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        final api = ApiService();
        await api.delete('/bus-fleet/dispatch/assignments/${a['id']}');
        _load();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Delete failed: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }
}

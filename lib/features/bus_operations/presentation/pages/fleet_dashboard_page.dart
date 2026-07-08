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
        return _dispatchPlaceholder('Create Assignment', Icons.assignment_add);
      case 'dispatch_list':
        return _dispatchPlaceholder('Active Assignments', Icons.list_alt);
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

// Dispatch placeholder — defined at top level for use in _pageContent
Widget _dispatchPlaceholder(String title, IconData icon) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 64, color: Colors.white24),
        const Gap(16),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Gap(8),
        const Text(
          'Dispatch module initializing...',
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),
      ],
    ),
  );
}

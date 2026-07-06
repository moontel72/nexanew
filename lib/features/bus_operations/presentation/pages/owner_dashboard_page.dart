// Owner Dashboard Page — thin BLoC-driven root for bus-owner panel
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/owner_dashboard/owner_dashboard_bloc.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/owner_dashboard/owner_dashboard_event.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/owner_dashboard/owner_dashboard_state.dart';
import 'package:trace_odd/features/bus_operations/presentation/pages/absolute_layout_designer_screen.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/add_staff_dialog.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/chat_inbox_section.dart'
    as chat;
import 'package:trace_odd/features/bus_operations/presentation/widgets/dashboard_kpi_section.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/layout_list_section.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/staff_list_section.dart';

class OwnerDashboardPage extends StatelessWidget {
  final String panelPrefix;
  const OwnerDashboardPage({super.key, this.panelPrefix = '/bus-owner'});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OwnerDashboardBloc()
        ..add(
          const BootstrapOwner(
            storagePrefix: 'busFleet',
            panelPrefix: '/bus-owner',
            loginRoute: '/bus-owner/login',
          ),
        ),
      child: const _OwnerView(),
    );
  }
}

class _OwnerView extends StatelessWidget {
  const _OwnerView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OwnerDashboardBloc, OwnerDashboardState>(
      builder: (ctx, state) {
        if (state.status == OwnerDashboardStatus.loading) {
          return const Scaffold(
            backgroundColor: Color(0xFF0D1B2A),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final bloc = ctx.read<OwnerDashboardBloc>();
        final wide = MediaQuery.of(ctx).size.width > 900;
        // Auto-load data on tab change
        if (state.currentPage == 'carrier' &&
            !state.linkLoading &&
            state.linkStatus == null) {
          bloc.add(const LoadOwnerLinkStatus());
        }
        if (state.currentPage == 'inbox' &&
            !state.inboxLoading &&
            state.inboxConversations.isEmpty) {
          bloc.add(const LoadOwnerInbox());
        }
        return Scaffold(
          backgroundColor: const Color(0xFF0D1B2A),
          body: Row(
            children: [
              if (wide) _Sidebar(bloc: bloc, state: state),
              Expanded(child: _content(ctx, bloc, state)),
            ],
          ),
        );
      },
    );
  }

  Widget _content(
    BuildContext ctx,
    OwnerDashboardBloc bloc,
    OwnerDashboardState state,
  ) {
    switch (state.currentPage) {
      case 'drivers':
        return StaffListSection(
          title: 'Bus Drivers',
          accentColor: const Color(0xFFDB2777),
          icon: Icons.badge,
          items: state.drivers,
          isLoading: state.driversLoading,
          onAdd: () => _addStaff(ctx, bloc, 'driver'),
          onRemove: (id, name) => _confirmRemove(ctx, bloc, id, name, 'driver'),
        );
      case 'conductors':
        return StaffListSection(
          title: 'Conductors / Cabin Crew',
          accentColor: const Color(0xFF7C3AED),
          icon: Icons.group,
          items: state.conductors,
          isLoading: state.conductorsLoading,
          onAdd: () => _addStaff(ctx, bloc, 'conductor'),
          onRemove: (id, name) =>
              _confirmRemove(ctx, bloc, id, name, 'conductor'),
        );
      case 'layouts':
        return LayoutListSection(
          layouts: state.layouts,
          isLoading: state.layoutsLoading,
          isMutating: state.isMutating,
          onAdd: () => _openDesigner(ctx, state),
          onPublish: (id, n) =>
              bloc.add(PublishOwnerLayout(layoutId: id, name: n)),
          onArchive: (id, n) => _confirm(
            ctx,
            bloc,
            'Archive',
            'Archive "$n"?',
            () => bloc.add(ArchiveOwnerLayout(layoutId: id, name: n)),
          ),
          onDelete: (id, n) => _confirm(
            ctx,
            bloc,
            'Delete',
            'Delete "$n"?',
            () => bloc.add(DeleteOwnerLayout(layoutId: id, name: n)),
          ),
        );
      case 'carrier':
        return _carrierLinkTab(ctx, bloc, state);
      case 'inbox':
        return chat.ChatInboxSection(
          conversations: state.inboxConversations,
          activeMessages: state.activeChatMessages,
          isLoading: state.inboxLoading,
          isSending: state.chatSending,
          expandedId: state.expandedConversationId,
          error: state.chatError,
          onExpand: (id) => bloc.add(LoadOwnerConversation(id)),
          onSend: (id, msg) =>
              bloc.add(SendOwnerMessage(assignmentId: id, message: msg)),
        );
      default:
        return _homeTab(ctx, bloc, state);
    }
  }

  Widget _homeTab(
    BuildContext ctx,
    OwnerDashboardBloc bloc,
    OwnerDashboardState state,
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
          onDriversTap: () => bloc.add(const NavigateOwnerPage('drivers')),
          onConductorsTap: () =>
              bloc.add(const NavigateOwnerPage('conductors')),
          onLayoutsTap: () => bloc.add(const NavigateOwnerPage('layouts')),
        ),
        Gap(24),
        _btn(
          '+ Add New Vehicle',
          Icons.add,
          const Color(0xFF0891B2),
          () => _openDesigner(ctx, state),
        ),
        Gap(12),
        _btn(
          'View All Vehicles (${state.layoutCount})',
          Icons.directions_bus,
          const Color(0xFF2563EB),
          () => bloc.add(const NavigateOwnerPage('layouts')),
        ),
      ],
    );
  }

  // ── Carrier Link (owner-side) ──
  Widget _carrierLinkTab(
    BuildContext ctx,
    OwnerDashboardBloc bloc,
    OwnerDashboardState state,
  ) {
    if (state.linkLoading)
      return const Center(child: CircularProgressIndicator());
    final linked = state.isLinked;
    final status = state.linkStatus?['status']?.toString() ?? 'independent';
    final carrierName = state.linkStatus?['carrier_name']?.toString() ?? '';
    final assignmentId = state.linkStatus?['assignment_id']?.toString() ?? '';

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(16.w),
      children: [
        // Status banner
        if (linked && status == 'active')
          _banner(
            Icons.check_circle,
            const Color(0xFF16A34A),
            'Linked with $carrierName',
            'Your fleet is visible to this carrier.',
            const Color(0xFF052E16),
            TextButton.icon(
              onPressed: () => _confirm(
                ctx,
                bloc,
                'Leave Carrier',
                'Leave $carrierName?',
                () => bloc.add(LeaveCarrier(assignmentId)),
              ),
              icon: const Icon(Icons.logout, size: 16),
              label: const Text('Leave'),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            ),
          ),
        if (linked && status == 'pending_acceptance')
          _banner(
            Icons.hourglass_empty,
            const Color(0xFFF59E0B),
            'Waiting for approval...',
            'Your request is pending.',
            const Color(0xFF451A03),
            TextButton.icon(
              onPressed: () => bloc.add(CancelLinkRequest(assignmentId)),
              icon: const Icon(Icons.close, size: 16),
              label: const Text('Cancel'),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            ),
          ),
        if (!linked)
          _banner(
            Icons.link_off,
            const Color(0xFF8899AA),
            'Not Linked',
            'Link with a Bus Company to join their fleet.',
            const Color(0xFF162438),
            null,
          ),
        Gap(24),
        if (!linked) ...[
          const Text(
            'Select a Bus Company',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          Gap(8),
          const Text(
            'Search for an active Bus Company.',
            style: TextStyle(color: Color(0xFF8899AA), fontSize: 12),
          ),
          Gap(12),
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
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (v) {
              if (v.length >= 2) bloc.add(SearchCompanies(v));
            },
          ),
          Gap(12),
          if (state.companiesLoading)
            const Center(child: CircularProgressIndicator())
          else
            ...state.availableCompanies.map(
              (c) => Card(
                color: const Color(0xFF1A2A3A),
                margin: EdgeInsets.only(bottom: 8.h),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFF59E0B),
                    child: Icon(
                      Icons.directions_bus,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  title: Text(
                    c['account_name']?.toString() ?? '—',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    c['email']?.toString() ?? '',
                    style: const TextStyle(
                      color: Color(0xFF667788),
                      fontSize: 11,
                    ),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => bloc.add(
                      SendLinkRequest(companyId: c['id']?.toString() ?? ''),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                    ),
                    child: const Text('Link'),
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _banner(
    IconData icon,
    Color color,
    String title,
    String sub,
    Color bg,
    Widget? action,
  ) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: color, fontWeight: FontWeight.w600),
                ),
                Text(
                  sub,
                  style: TextStyle(
                    color: color.withValues(alpha: .7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (action != null) action,
        ],
      ),
    );
  }

  // ── Helpers ──
  Future<void> _addStaff(
    BuildContext ctx,
    OwnerDashboardBloc bloc,
    String role,
  ) async {
    final data = await AddStaffDialog.show(
      ctx,
      title: role == 'driver' ? 'Add Bus Driver' : 'Add Conductor',
    );
    if (data != null) bloc.add(RegisterOwnerStaff(role: role, data: data));
  }

  Future<void> _confirmRemove(
    BuildContext ctx,
    OwnerDashboardBloc bloc,
    String id,
    String name,
    String role,
  ) async {
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF1B2838),
        title: const Text('Remove', style: TextStyle(color: Colors.white)),
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
    if (ok == true) bloc.add(RemoveOwnerStaff(staffId: id, role: role));
  }

  Future<void> _confirm(
    BuildContext ctx,
    OwnerDashboardBloc bloc,
    String title,
    String msg,
    VoidCallback onOk,
  ) async {
    final ok = await showDialog<bool>(
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
    if (ok == true) onOk();
  }

  void _openDesigner(BuildContext ctx, OwnerDashboardState state) {
    Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (_) => AbsoluteLayoutDesignerScreen(
          companyId: state.companyId,
          companyName: state.ownerName,
          apiPrefix: '/bus-owner',
        ),
      ),
    );
  }

  Widget _btn(String l, IconData i, Color c, VoidCallback t) => GestureDetector(
    onTap: t,
    child: Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [c.withValues(alpha: .3), c.withValues(alpha: .08)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.withValues(alpha: .4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(i, color: c, size: 20),
          SizedBox(width: 10.w),
          Text(
            l,
            style: TextStyle(
              color: c,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    ),
  );
}

// ── Sidebar ──
class _Sidebar extends StatelessWidget {
  final OwnerDashboardBloc bloc;
  final OwnerDashboardState state;
  const _Sidebar({required this.bloc, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: const Color(0xFF162438),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                const Icon(
                  Icons.directions_bus,
                  color: Color(0xFFDB2777),
                  size: 28,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    state.ownerName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF2A3A4A)),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              children: [
                _nav('Dashboard', Icons.dashboard, 'dashboard'),
                _sec('FLEET'),
                _nav('Drivers', Icons.badge, 'drivers'),
                _nav('Conductors', Icons.group, 'conductors'),
                _nav('Vehicles', Icons.directions_bus, 'layouts'),
                _sec('CARRIER'),
                _nav('Carrier Link', Icons.link_rounded, 'carrier'),
                _nav('Inbox', Icons.message_rounded, 'inbox'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _nav(String l, IconData i, String p) => ListTile(
    dense: true,
    leading: Icon(
      i,
      size: 20,
      color: state.currentPage == p ? Colors.white : const Color(0xFF667788),
    ),
    title: Text(
      l,
      style: TextStyle(
        color: state.currentPage == p ? Colors.white : const Color(0xFF8899AA),
        fontSize: 13,
      ),
    ),
    selected: state.currentPage == p,
    selectedTileColor: const Color(0xFFDB2777).withValues(alpha: .1),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    onTap: () => bloc.add(NavigateOwnerPage(p)),
  );
  Widget _sec(String l) => Padding(
    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 4.h),
    child: Text(
      l,
      style: const TextStyle(
        color: Color(0xFF556677),
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    ),
  );
}

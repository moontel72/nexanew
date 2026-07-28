// Owner Dashboard Page — thin BLoC-driven root for bus-owner panel
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/owner_dashboard/owner_dashboard_bloc.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/owner_dashboard/owner_dashboard_event.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/owner_dashboard/owner_dashboard_state.dart';
import 'package:trace_odd/shared/widgets/layout_designer/bus_config_setup_screen.dart';
import 'package:trace_odd/shared/widgets/layout_designer/absolute_layout_designer_screen.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/missile_3d_button.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/add_staff_dialog.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/chat_inbox_section.dart'
    as chat;
import 'package:trace_odd/features/bus_operations/presentation/widgets/dashboard_kpi_section.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/layout_list_section.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/staff_list_section.dart';
import 'package:trace_odd/shared/bloc/layout_designer/layout_validation_bloc.dart';
import 'package:trace_odd/shared/bloc/layout_designer/layout_validation_event.dart';
import 'package:trace_odd/shared/models/transport/bus_dimensions.dart';
import 'package:trace_odd/shared/models/transport/component_registry.dart';
import 'package:trace_odd/shared/models/transport/feet_inches.dart';
import 'package:trace_odd/core/services/api_service.dart';

class OwnerDashboardPage extends StatelessWidget {
  final String panelPrefix;
  final String loginRoute;
  const OwnerDashboardPage({
    super.key,
    this.panelPrefix = '/bus-owner',
    this.loginRoute = '/bus-owner/login',
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LayoutValidationBloc(),
      child: BlocProvider(
        create: (_) => OwnerDashboardBloc()
          ..add(
            const BootstrapOwner(
              storagePrefix: 'busFleet',
              panelPrefix: '/bus-owner',
              loginRoute: '/bus-owner/login',
            ),
          ),
        child: _OwnerView(loginRoute: loginRoute),
      ),
    );
  }
}

class _OwnerView extends StatelessWidget {
  final String loginRoute;
  const _OwnerView({required this.loginRoute});

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
              if (wide)
                _Sidebar(bloc: bloc, state: state, loginRoute: loginRoute),
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
          onEdit: (id, n) => _openEditForm(ctx, state, id),
          onOpenDesigner: (id, n) => _openDesigner(ctx, state, layoutId: id),
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

  void _openDesigner(
    BuildContext ctx,
    OwnerDashboardState state, {
    String? layoutId,
  }) {
    if (layoutId != null) {
      // Edit existing layout — open the canvas designer directly.
      Navigator.push(
        ctx,
        MaterialPageRoute(
          builder: (_) => AbsoluteLayoutDesignerScreen(
            companyId: state.companyId,
            companyName: state.ownerName,
            apiPrefix: '/bus-owner',
            layoutId: layoutId,
          ),
        ),
      ).then((_) {
        ctx.read<OwnerDashboardBloc>().add(const LoadOwnerLayouts());
      });
    } else {
      Navigator.push(
        ctx,
        MaterialPageRoute(
          builder: (_) => BlocProvider<LayoutValidationBloc>(
            create: (_) => LayoutValidationBloc(),
            child: BusConfigSetupScreen(
              companyId: state.companyId,
              companyName: state.ownerName,
              apiPrefix: '/bus-owner',
            ),
          ),
        ),
      ).then((_) {
        ctx.read<OwnerDashboardBloc>().add(const LoadOwnerLayouts());
      });
    }
  }

  void _openEditForm(
    BuildContext ctx,
    OwnerDashboardState state,
    String layoutId,
  ) async {
    BusDimensions? dims;
    ComponentRegistry? reg;
    String? plate;
    String? maker;
    String? specs;
    int leftS = 0, rightS = 0, rows = 0;
    bool hasFront = false;
    int frontFt = 0, frontIn = 0;
    try {
      final api = ApiService();
      final r = await api.get('/bus-owner/absolute-layouts/$layoutId');
      final d = r?['data'];
      if (d is Map) {
        // Plate + Maker
        final displayName =
            d['display_name']?.toString() ?? d['name']?.toString() ?? '';
        if (displayName.contains(' | ')) {
          final parts = displayName.split(' | ');
          plate = parts[0];
          maker = parts.length > 1 ? parts[1] : null;
        } else {
          plate = displayName;
        }
        specs = d['specifications']?.toString() ?? d['notes']?.toString() ?? '';
        final snap = d['current_snapshot'];
        Map<String, dynamic>? snapMap;
        if (snap is Map) snapMap = Map<String, dynamic>.from(snap);
        final snapCanvas = snapMap?['canvas'];
        if (snapCanvas is Map) {
          final w = (snapCanvas['canvas_width'] as num?)?.toDouble();
          final h = (snapCanvas['canvas_height'] as num?)?.toDouble();
          if (w != null && h != null && w > 0 && h > 0) {
            final meta = snapMap?['metadata'];
            final hPx =
                snapMap?['bus_height_px'] ??
                (meta is Map ? meta['bus_height_px'] : null);
            FeetInches busH = hPx is num
                ? FeetInches.fromPixels(hPx.toDouble())
                : FeetInches.zero;
            dims = BusDimensions(
              length: FeetInches.fromPixels(h),
              width: FeetInches.fromPixels(w),
              height: busH,
            );
          }
        }
        // Registry
        dynamic regJson = snapMap?['registry'];
        if (regJson is String) {
          try {
            regJson = jsonDecode(regJson);
          } catch (_) {
            regJson = null;
          }
        }
        if (regJson is Map) {
          try {
            reg = ComponentRegistry.fromJson(
              Map<String, dynamic>.from(regJson),
            );
          } catch (_) {}
        }
        // Seat matrix from components
        final comps = snapMap?['components'];
        if (comps is List && comps.isNotEmpty) {
          const structural = {
            'driverCabin',
            'exitDoor',
            'sideDoor',
            'slidingDoor',
            'frontDoor',
            'rearDoor',
            'aisle',
            'emergency',
            'lavatory',
            'restaurantTable',
            'empty',
          };
          final ySet = <int>{};
          final firstRowXs = <double>[];
          double? firstY;
          double minSeatY = double.infinity;
          for (final c in comps) {
            if (c is! Map) continue;
            if (structural.contains(c['type']?.toString() ?? '')) continue;
            final y = (c['y'] as num?)?.toDouble();
            final x = (c['x'] as num?)?.toDouble();
            if (y == null || x == null) continue;
            ySet.add(y.round());
            if (y < minSeatY) minSeatY = y;
            if (firstY == null) firstY = y;
            if ((y - firstY!).abs() < 5) firstRowXs.add(x);
          }
          int lC = 0, rC = 0;
          if (firstRowXs.isNotEmpty) {
            firstRowXs.sort();
            double maxGap = 0;
            int gapIdx = 0;
            for (int i = 1; i < firstRowXs.length; i++) {
              final gap = firstRowXs[i] - firstRowXs[i - 1];
              if (gap > maxGap) {
                maxGap = gap;
                gapIdx = i;
              }
            }
            if (maxGap > 30) {
              lC = gapIdx;
              rC = firstRowXs.length - gapIdx;
            } else {
              final cw = (snapCanvas is Map
                  ? ((snapCanvas['canvas_width'] as num?)?.toDouble() ?? 280)
                  : 280);
              for (final x in firstRowXs) {
                if (x < cw / 2)
                  lC++;
                else
                  rC++;
              }
            }
          }
          leftS = lC.clamp(0, 8);
          rightS = rC.clamp(0, 8);
          rows = ySet.length.clamp(1, 50);
          // Front partition
          final fpx =
              snapMap?['metadata']?['front_partition_px'] ??
              snapMap?['front_partition_px'];
          if (fpx is num && fpx.toDouble() > 0) {
            final ri = (fpx.toDouble() / 4.0).round();
            if (ri > 0) {
              hasFront = true;
              frontFt = ri ~/ 12;
              frontIn = ri % 12;
            }
          } else if ((minSeatY - 100).abs() > 20 &&
              minSeatY < double.infinity) {
            final ri = (minSeatY / 4.0).round();
            if (ri > 0) {
              hasFront = true;
              frontFt = ri ~/ 12;
              frontIn = ri % 12;
            }
          }
        }
      }
    } catch (_) {}
    if (!ctx.mounted) return;
    Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (_) => BlocProvider<LayoutValidationBloc>(
          create: (_) {
            final b = LayoutValidationBloc();
            if (dims != null) b.add(DimensionsChanged(dims));
            if (reg != null) b.add(RegistryChanged(reg));
            b.add(
              SeatMatrixChanged(
                rows: rows,
                leftSeats: leftS,
                rightSeats: rightS,
              ),
            );
            return b;
          },
          child: BusConfigSetupScreen(
            companyId: state.companyId,
            companyName: state.ownerName,
            apiPrefix: '/bus-owner',
            layoutId: layoutId,
            initialDimensions: dims,
            initialRegistry: reg,
            initialPlate: plate,
            initialMaker: maker,
            initialSpecs: specs,
            initialLeftSeats: leftS,
            initialRightSeats: rightS,
            initialRowCount: rows,
            initialHasFrontPartition: hasFront,
            initialFrontPartitionFt: frontFt,
            initialFrontPartitionIn: frontIn,
          ),
        ),
      ),
    ).then((_) {
      ctx.read<OwnerDashboardBloc>().add(const LoadOwnerLayouts());
    });
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
  final String loginRoute;
  const _Sidebar({
    required this.bloc,
    required this.state,
    required this.loginRoute,
  });

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
                      colors: [Color(0xFFDB2777), Color(0xFF9D174D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFDB2777).withOpacity(0.4),
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
                        'BUS OWNER',
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
                _sec('FLEET'),
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
                const Divider(height: 1, color: Color(0x20FFFFFF)),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Missile3DButton(
                    label: 'Logout',
                    icon: Icons.logout,
                    color: const Color(0xFFDC2626),
                    height: 48,
                    onTap: () {
                      bloc.add(const OwnerLogout('busFleet'));
                      GoRouter.of(context).go(loginRoute);
                    },
                  ),
                ),
              ],
            ),
          ),
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
      onTap: () => bloc.add(NavigateOwnerPage(page)),
    );
  }

  Widget _sec(String label) => Padding(
    padding: EdgeInsets.fromLTRB(14, 12, 16, 4),
    child: Text(
      label,
      style: TextStyle(
        color: Color(0xFFBDD8DB),
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
      ),
    ),
  );
}

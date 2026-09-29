// Sub-Admin Dashboard Screen — BLoC-driven
//
// Post-login workspace for a vertical sub-admin.
// Shows KPIs, bus company management, and profile info.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/sub_admin/sub_admin_bloc.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/sub_admin/sub_admin_event.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/sub_admin/sub_admin_state.dart';
import 'package:trace_odd/features/nexa_admin/presentation/screens/sub_admin/sub_admin_verticals.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/widgets/buttons/missile_3d_button.dart';
import 'package:trace_odd/shared/widgets/feedback/sticky_error_banner.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/shared/widgets/layout_designer/absolute_layout_designer_screen.dart';
import 'package:trace_odd/shared/bloc/layout_designer/layout_validation_bloc.dart';
import 'package:trace_odd/shared/bloc/layout_designer/layout_validation_event.dart';
import 'package:trace_odd/shared/models/transport/bus_dimensions.dart';
import 'package:trace_odd/shared/models/transport/component_registry.dart';
import 'package:trace_odd/shared/models/transport/feet_inches.dart';
import 'package:trace_odd/shared/widgets/layout_designer/bus_config_setup_screen.dart';

class SubAdminDashboardScreen extends StatelessWidget {
  const SubAdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LayoutValidationBloc(),
      child: BlocProvider(
        create: (_) => SubAdminBloc()..add(const BootstrapDashboard()),
        child: const _DashboardView(),
      ),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  String _vertical = '';
  bool _verticalLoaded = false;

  /// Scroll target for the "View Companies" / "View Accounts" quick actions.
  /// Those buttons used to be silent no-ops (`() {}`), so clicking them did
  /// nothing at all — the list lives inline further down this same ListView.
  final GlobalKey _listSectionKey = GlobalKey();

  /// First child of whichever vertical dashboard is showing — used by the
  /// sidebar's "Dashboard" item to scroll back to the top.
  final GlobalKey _dashboardTopKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadVertical();
  }

  Future<void> _loadVertical() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _vertical = prefs.getString('sub_admin_vertical') ?? '';
      _verticalLoaded = true;
    });
  }

  /// Bring the inline list section into view (wired to the quick actions).
  void _revealListSection() {
    final target = _listSectionKey.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      alignment: 0.05,
    );
  }

  /// Scroll the dashboard content back to the top — wired to the sidebar's
  /// "Dashboard" item, which used to be a silent no-op (`() {}`).
  void _scrollToTop() {
    final target = _dashboardTopKey.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      alignment: 0,
    );
  }

  Widget _listEmptyBox(String message) => Container(
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(
      color: const Color(0xFF1B3A4B),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Center(
      child: Text(message, style: const TextStyle(color: Colors.white54)),
    ),
  );

  /// A dismissed *list* failure message (see `StickyErrorBanner`). The list-load
  /// failure must stay on screen until the operator closes it — before this, an
  /// API error looked exactly like "no records yet", which is how a 403/500
  /// masqueraded as an empty list.
  ///
  /// Only the *message* is remembered (the factory screens' pattern): the same
  /// failure stays closed, but a different one always appears again.
  String? _dismissedListError;

  /// Shown when a list request itself failed. Dismissing hides the banner (the
  /// caller's `else if (…isEmpty)` branch is not taken), so a dismissed error
  /// never turns back into a silent "empty".
  Widget _listErrorBanner({required String source, required String message}) {
    if (message == _dismissedListError) return const SizedBox.shrink();
    return StickyErrorBanner(
      message: message,
      source: source,
      onDismiss: () => setState(() => _dismissedListError = message),
    );
  }

  /// A failed form submit inside a bottom sheet — stays, copies and closes.
  Widget _formErrorBanner({
    required String source,
    required String message,
    required SubAdminBloc bloc,
  }) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: StickyErrorBanner(
      message: message,
      source: source,
      onDismiss: () => bloc.add(const ClearSubAdminError()),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubAdminBloc, SubAdminState>(
      builder: (ctx, state) {
        if (state.dashStatus == SubAdminViewStatus.loading ||
            !_verticalLoaded) {
          return const Scaffold(
            backgroundColor: Color(0xFF0C1D2C),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF1F5E6B)),
            ),
          );
        }
        final bloc = ctx.read<SubAdminBloc>();
        final wide = MediaQuery.of(ctx).size.width > 900;
        return Scaffold(
          backgroundColor: const Color(0xFF0C1D2C),
          body: Row(
            children: [
              if (wide)
                _Sidebar(
                  bloc: bloc,
                  state: state,
                  vertical: _vertical,
                  onDashboardTap: _scrollToTop,
                ),
              Expanded(child: _content(ctx, bloc, state, wide)),
            ],
          ),
        );
      },
    );
  }

  Widget _content(
    BuildContext ctx,
    SubAdminBloc bloc,
    SubAdminState state,
    bool wide,
  ) {
    return Column(
      children: [
        _topBar(state, wide, _vertical),
        Expanded(
          child: state.busListLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF1F5E6B)),
                )
              : Builder(
                  builder: (_) {
                    // Determine which sub-page to show (managed inside bloc via events or local index)
                    // For simplicity, we'll keep the dashboard + bus company list as the main view
                    // since the BLoC already loads bus companies on bootstrap.
                    return _mainView(ctx, bloc, state);
                  },
                ),
        ),
      ],
    );
  }

  // ── Top Bar ──
  Widget _topBar(SubAdminState state, bool wide, String vertical) {
    final verticalColor = SubAdminVerticals.color(vertical);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF0F2936),
        border: Border(bottom: BorderSide(color: Color(0x20FFFFFF))),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF1F5E6B),
            child: Text(
              state.subAdminName.isNotEmpty
                  ? state.subAdminName[0].toUpperCase()
                  : 'S',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Gap(12),
          Text(
            state.subAdminName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          // Which vertical this session actually belongs to. Without it the
          // header was identical for every sub-admin, so "wrong dashboard"
          // reports were impossible to tell apart from a stale build.
          if (vertical.isNotEmpty) ...[
            const Gap(10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: verticalColor.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: verticalColor.withValues(alpha: 0.5)),
              ),
              child: Text(
                SubAdminVerticals.label(vertical),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const Spacer(),
          Text(
            '${state.tenantCount} tenants · ${state.activeFeatures.length} features',
            style: const TextStyle(color: Color(0xFFBDD8DB), fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ── Dynamic Main View — delegates to vertical-specific dashboard ──
  Widget _mainView(BuildContext ctx, SubAdminBloc bloc, SubAdminState state) {
    // No resolved vertical → do NOT guess. The switch's `default` is the bus
    // dashboard, which is exactly how a mis-provisioned account appeared to
    // "open as Bus-Transit". Say what is wrong instead of showing the wrong UI.
    if (_vertical.isEmpty) {
      return _missingVerticalView(bloc);
    }
    // Dynamically select dashboard content based on stored vertical code.
    // New verticals only need a new builder method — no switch statement changes.
    switch (_vertical) {
      case 'cricket_ops':
        return _cricketDashboard(ctx, bloc, state);
      case 'factory':
        return _factoryDashboard(ctx, bloc, state);
      case 'commercial_marketplace':
        return _resellerDashboard(ctx, bloc, state);
      case 'bus_transit':
      case 'goods_logistics':
      case 'financial_auditor':
      default:
        return _busDashboard(ctx, bloc, state);
    }
  }

  /// Shown when the account has no vertical on record: the login response's
  /// `sub_admin_vertical` came back empty (no active `sub_admin_assignments` row
  /// for this identity), so there is no dashboard to pick.
  Widget _missingVerticalView(SubAdminBloc bloc) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.report_problem_outlined,
              color: Color(0xFFF59E0B),
              size: 48,
            ),
            const Gap(16),
            const Text(
              'No vertical assigned',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Gap(8),
            const Text(
              'This sub-admin account has no active vertical assignment, so no '
              'dashboard can be shown. Ask the Super Admin to set it in '
              'Sub Admins → Change Vertical, then sign in again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFFBDD8DB), fontSize: 13),
            ),
            const Gap(20),
            TextButton.icon(
              onPressed: () => bloc.add(const BootstrapDashboard()),
              icon: const Icon(Icons.refresh, color: Color(0xFFBDD8DB)),
              label: const Text(
                'Retry',
                style: TextStyle(color: Color(0xFFBDD8DB)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Cricket Sub-Admin Dashboard ──────────────────────
  /// Only provisions and manages Cricket Operations Managers.
  /// Operational tasks live in the separate Cricket Manager Panel.
  Widget _cricketDashboard(
    BuildContext ctx,
    SubAdminBloc bloc,
    SubAdminState state,
  ) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Header
        Container(
          key: _dashboardTopKey,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.sports_cricket,
                    color: Colors.white,
                    size: 32,
                  ),
                  const Gap(12),
                  const Expanded(
                    child: Text(
                      'Cricket Operations',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'SUB-ADMIN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(8),
              const Text(
                'Provision and manage Cricket Operations Managers who handle tournament setup, live scoring, and streaming.',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
        const Gap(24),

        // Primary Actions — only two
        const Text(
          'Cricket Manager Actions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Gap(12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => ctx.go('/sub-admin/cricket/managers/add'),
            icon: const Icon(Icons.person_add),
            label: const Text(
              'Add Operations Manager',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const Gap(12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF10B981),
              side: const BorderSide(color: Color(0xFF10B981)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => ctx.go('/sub-admin/cricket/managers'),
            icon: const Icon(Icons.people),
            label: const Text(
              'View All Operations Managers',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  // ── Bus Management Dashboard (existing verticals) ────
  Widget _busDashboard(
    BuildContext ctx,
    SubAdminBloc bloc,
    SubAdminState state,
  ) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // KPI Cards
        Row(
          key: _dashboardTopKey,
          children: [
            _kpiCard(
              'Tenants',
              '${state.tenantCount}',
              Icons.business,
              const Color(0xFF7C3AED),
            ),
            const Gap(12),
            _kpiCard(
              'Features',
              '${state.activeFeatures.length}',
              Icons.grid_view,
              const Color(0xFF2563EB),
            ),
            const Gap(12),
            _kpiCard(
              'Revenue',
              '\$${state.monthlyRevenue.toStringAsFixed(0)}',
              Icons.trending_up,
              const Color(0xFF059669),
            ),
          ],
        ),
        const Gap(24),

        // Quick Actions
        const Text(
          'Quick Actions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Gap(12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _actionBtn(
              Icons.add_business,
              'Add Bus Company',
              () => _showAddBusCompanySheet(ctx, bloc),
            ),
            _actionBtn(Icons.list_alt, 'View Companies', () {
              bloc.add(const FetchBusCompanies());
              _revealListSection();
            }),
            _actionBtn(
              Icons.airline_seat_recline_normal,
              'View Layout Presets',
              () => _openPresetsList(ctx),
            ),
            // A 'Reports' action used to sit here with an empty `() {}` onTap, so
            // it did nothing when clicked. Reports/billing belong to the
            // financial_auditor vertical (C0 §2b.3), not the bus sub-admin's, so
            // it is removed rather than left dead. Re-add a WIRED one only if it
            // is actually given a destination.
          ],
        ),
        const Gap(24),

        // Bus Companies Section
        Row(
          key: _listSectionKey,
          children: [
            const Expanded(
              child: Text(
                'Registered Bus Companies',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () => bloc.add(const FetchBusCompanies()),
              icon: const Icon(
                Icons.refresh,
                size: 16,
                color: Color(0xFFBDD8DB),
              ),
              label: const Text(
                'Refresh',
                style: TextStyle(color: Color(0xFFBDD8DB)),
              ),
            ),
          ],
        ),
        const Gap(8),
        if (state.busListError != null)
          _listErrorBanner(
            source:
                'Sub-Admin · Bus Companies · GET /api/v1/admin/bus-companies',
            message: 'Could not load bus companies: ${state.busListError}',
          )
        else if (state.busCompanies.isEmpty)
          _listEmptyBox('No bus companies registered yet.')
        else
          ...state.busCompanies.map((c) => _busCompanyCard(ctx, bloc, c)),
      ],
    );
  }

  // ── KPI Card ──
  Widget _kpiCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1B3A4B),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const Gap(4),
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // ── Action Button ──
  Widget _actionBtn(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1B3A4B),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF1F5E6B), size: 18),
            const Gap(8),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bus Company Card ──
  Widget _busCompanyCard(
    BuildContext ctx,
    SubAdminBloc bloc,
    Map<String, dynamic> c,
  ) {
    final name =
        c['account_name']?.toString() ?? c['name']?.toString() ?? 'Unknown';
    final email = c['email']?.toString() ?? '';
    final status = c['status']?.toString() ?? 'pending';
    final id = c['id']?.toString() ?? '';
    final statusColor = _statusColor(status);
    final statusLabel = _statusLabel(status);

    return Card(
      color: const Color(0xFF1B3A4B),
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: statusColor,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
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
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        email,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white54),
                  color: const Color(0xFF1B3A4B),
                  onSelected: (action) {
                    switch (action) {
                      case 'verified':
                        bloc.add(
                          UpdateBusCompanyStatus(
                            companyId: id,
                            newStatus: 'verified',
                          ),
                        );
                        break;
                      case 'active':
                        bloc.add(
                          UpdateBusCompanyStatus(
                            companyId: id,
                            newStatus: 'active',
                          ),
                        );
                        break;
                      case 'inactive':
                        bloc.add(
                          UpdateBusCompanyStatus(
                            companyId: id,
                            newStatus: 'inactive',
                          ),
                        );
                        break;
                      case 'suspended':
                        bloc.add(
                          UpdateBusCompanyStatus(
                            companyId: id,
                            newStatus: 'suspended',
                          ),
                        );
                        break;
                      case 'edit':
                        _showEditBusCompanySheet(ctx, bloc, c);
                        break;
                      case 'delete':
                        showDialog(
                          context: ctx,
                          builder: (dctx) => AlertDialog(
                            title: const Text('Delete Company?'),
                            content: Text('This will archive $name.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dctx),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.error,
                                ),
                                onPressed: () {
                                  Navigator.pop(dctx);
                                  bloc.add(DeleteBusCompany(id));
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        break;
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'verified',
                      child: ListTile(
                        leading: Icon(Icons.verified, color: Color(0xFF2563EB)),
                        title: Text('Verified'),
                        dense: true,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'active',
                      child: ListTile(
                        leading: Icon(
                          Icons.check_circle,
                          color: Color(0xFF059669),
                        ),
                        title: Text('Active'),
                        dense: true,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'inactive',
                      child: ListTile(
                        leading: Icon(
                          Icons.pause_circle,
                          color: Color(0xFFD97706),
                        ),
                        title: Text('Inactive'),
                        dense: true,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'suspended',
                      child: ListTile(
                        leading: Icon(Icons.block, color: AppColors.warning),
                        title: Text('Suspend'),
                        dense: true,
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit, color: Color(0xFF1F5E6B)),
                        title: Text('Update'),
                        dense: true,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: AppColors.error),
                        title: Text('Delete'),
                        dense: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return const Color(0xFF059669);
      case 'verified':
        return const Color(0xFF2563EB);
      case 'pending':
        return const Color(0xFFD97706);
      case 'inactive':
        return Colors.grey;
      case 'suspended':
        return AppColors.warning;
      case 'deleted':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'active':
        return 'Active';
      case 'verified':
        return 'Verified';
      case 'pending':
        return 'Pending';
      case 'inactive':
        return 'Inactive';
      case 'suspended':
        return 'Suspended';
      case 'deleted':
        return 'Deleted';
      default:
        return status;
    }
  }

  // ── Add Bus Company Bottom Sheet ──
  void _showAddBusCompanySheet(BuildContext context, SubAdminBloc bloc) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final regCtrl = TextEditingController();
    final fleetCtrl = TextEditingController();
    final licenseCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1B3A4B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: BlocConsumer<SubAdminBloc, SubAdminState>(
          listener: (lctx, state) {
            if (state.busFormSuccess != null) {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.busFormSuccess!),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          },
          builder: (lctx, state) => Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(lctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Add Bus Company',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(16),
                _sheetField('Company Name', nameCtrl),
                const Gap(10),
                _sheetField('Email', emailCtrl, TextInputType.emailAddress),
                const Gap(10),
                _sheetField('Phone', phoneCtrl, TextInputType.phone),
                const Gap(10),
                _sheetField('Registration Code', regCtrl),
                const Gap(10),
                _sheetField('Fleet Size', fleetCtrl, TextInputType.number),
                const Gap(10),
                _sheetField('License Number', licenseCtrl),
                const Gap(10),
                _sheetField(
                  'Password',
                  passwordCtrl,
                  TextInputType.visiblePassword,
                ),
                if (state.busFormError != null)
                  _formErrorBanner(
                    source:
                        'Sub-Admin · Bus Companies · POST /api/v1/admin/bus-companies',
                    message: state.busFormError!,
                    bloc: bloc,
                  ),
                const Gap(16),
                ElevatedButton(
                  onPressed: state.busFormLoading
                      ? null
                      : () {
                          bloc.add(
                            CreateBusCompany(
                              name: nameCtrl.text.trim(),
                              email: emailCtrl.text.trim(),
                              password: passwordCtrl.text,
                              phone: phoneCtrl.text.trim(),
                              regCode: regCtrl.text.trim(),
                              fleetSize: fleetCtrl.text.trim(),
                              license: licenseCtrl.text.trim(),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F5E6B),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: state.busFormLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Create Company',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Edit Bus Company Bottom Sheet ──
  void _showEditBusCompanySheet(
    BuildContext context,
    SubAdminBloc bloc,
    Map<String, dynamic> company,
  ) {
    final id = company['id']?.toString() ?? '';
    final nameCtrl = TextEditingController(
      text:
          company['account_name']?.toString() ??
          company['name']?.toString() ??
          '',
    );
    final emailCtrl = TextEditingController(
      text: company['email']?.toString() ?? '',
    );
    final phoneCtrl = TextEditingController(
      text:
          company['phone_number']?.toString() ??
          company['phone']?.toString() ??
          '',
    );
    final passwordCtrl = TextEditingController();
    final metadata = company['metadata'] is Map
        ? Map<String, dynamic>.from(company['metadata'] as Map)
        : <String, dynamic>{};
    final regCtrl = TextEditingController(
      text: metadata['registration_code']?.toString() ?? '',
    );
    final fleetCtrl = TextEditingController(
      text: metadata['fleet_size']?.toString() ?? '',
    );
    final licenseCtrl = TextEditingController(
      text: metadata['transit_license']?.toString() ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1B3A4B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: BlocConsumer<SubAdminBloc, SubAdminState>(
          listener: (lctx, state) {
            if (state.actionSuccess != null) {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.actionSuccess!),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          },
          builder: (lctx, state) => Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(lctx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Edit Bus Company',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(16),
                  _sheetField('Company Name', nameCtrl),
                  const Gap(10),
                  _sheetField('Email', emailCtrl, TextInputType.emailAddress),
                  const Gap(10),
                  _sheetField('Phone', phoneCtrl, TextInputType.phone),
                  const Gap(10),
                  _sheetField('Registration Code', regCtrl),
                  const Gap(10),
                  _sheetField('Fleet Size', fleetCtrl, TextInputType.number),
                  const Gap(10),
                  _sheetField('License Number', licenseCtrl),
                  const Gap(10),
                  _sheetField(
                    'New Password (leave blank to keep existing)',
                    passwordCtrl,
                    TextInputType.visiblePassword,
                  ),
                  if (state.actionError != null)
                    _formErrorBanner(
                      source:
                          'Sub-Admin · Bus Companies · PUT /api/v1/admin/bus-companies/{id}',
                      message: state.actionError!,
                      bloc: bloc,
                    ),
                  const Gap(16),
                  ElevatedButton(
                    onPressed: state.actionLoading
                        ? null
                        : () {
                            final data = <String, dynamic>{
                              'name': nameCtrl.text.trim(),
                              'email': emailCtrl.text.trim(),
                              'phone': phoneCtrl.text.trim(),
                              'registration_code': regCtrl.text.trim(),
                              'fleet_size': fleetCtrl.text.trim(),
                              'license': licenseCtrl.text.trim(),
                            };
                            final pwd = passwordCtrl.text;
                            if (pwd.isNotEmpty) {
                              data['password'] = pwd;
                            }
                            bloc.add(EditBusCompany(companyId: id, data: data));
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F5E6B),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: state.actionLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Factory Management Dashboard (factory vertical) ────
  Widget _factoryDashboard(
    BuildContext ctx,
    SubAdminBloc bloc,
    SubAdminState state,
  ) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // KPI Cards
        Row(
          key: _dashboardTopKey,
          children: [
            _kpiCard(
              'Tenants',
              '${state.tenantCount}',
              Icons.business,
              const Color(0xFF7C3AED),
            ),
            const Gap(12),
            _kpiCard(
              'Features',
              '${state.activeFeatures.length}',
              Icons.grid_view,
              const Color(0xFF2563EB),
            ),
            const Gap(12),
            _kpiCard(
              'Revenue',
              '\$${state.monthlyRevenue.toStringAsFixed(0)}',
              Icons.trending_up,
              const Color(0xFF059669),
            ),
          ],
        ),
        const Gap(24),

        // Quick Actions
        const Text(
          'Quick Actions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Gap(12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _actionBtn(
              Icons.factory,
              'Add Factory Company',
              () => _showAddFactoryCompanySheet(ctx, bloc),
            ),
            _actionBtn(Icons.list_alt, 'View Companies', () {
              bloc.add(const FetchFactoryCompanies());
              _revealListSection();
            }),
            // A 'Reports' action used to sit here with an empty `() {}` onTap, so
            // it did nothing when clicked. Reports/billing belong to the
            // financial_auditor vertical (C0 §2b.3), not the factory sub-admin's,
            // so it is removed rather than left dead.
          ],
        ),
        const Gap(24),

        // Factory Companies Section
        Row(
          key: _listSectionKey,
          children: [
            const Expanded(
              child: Text(
                'Registered Factory Companies',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () => bloc.add(const FetchFactoryCompanies()),
              icon: const Icon(
                Icons.refresh,
                size: 16,
                color: Color(0xFFBDD8DB),
              ),
              label: const Text(
                'Refresh',
                style: TextStyle(color: Color(0xFFBDD8DB)),
              ),
            ),
          ],
        ),
        const Gap(8),
        if (state.factoryListError != null)
          _listErrorBanner(
            source:
                'Sub-Admin · Factory Companies · GET /api/v1/admin/factory-companies',
            message:
                'Could not load factory companies: ${state.factoryListError}',
          )
        else if (state.factoryCompanies.isEmpty)
          _listEmptyBox('No factory companies registered yet.')
        else
          ...state.factoryCompanies.map(
            (c) => _factoryCompanyCard(ctx, bloc, c),
          ),
      ],
    );
  }

  // ── Factory Company Card ──
  Widget _factoryCompanyCard(
    BuildContext ctx,
    SubAdminBloc bloc,
    Map<String, dynamic> c,
  ) {
    final name =
        c['name']?.toString() ?? c['account_name']?.toString() ?? 'Unknown';
    final regNumber = c['business_registration_number']?.toString() ?? '';
    final contactName = c['contact_person_name']?.toString() ?? '';
    final contactEmail = c['contact_person_email']?.toString() ?? '';
    final contactPhone = c['contact_person_phone']?.toString() ?? '';
    final status = c['status']?.toString() ?? 'pending';
    final id = c['id']?.toString() ?? '';
    final statusColor = _statusColor(status);
    final statusLabel = _statusLabel(status);

    return Card(
      color: const Color(0xFF1B3A4B),
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: statusColor,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
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
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (regNumber.isNotEmpty)
                        Text(
                          'Reg: $regNumber',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      Text(
                        contactName.isNotEmpty
                            ? '$contactName · $contactEmail'
                            : contactEmail,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                      if (contactPhone.isNotEmpty)
                        Text(
                          contactPhone,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white54),
                  color: const Color(0xFF1B3A4B),
                  onSelected: (action) {
                    switch (action) {
                      case 'verified':
                        bloc.add(
                          UpdateFactoryCompanyStatus(
                            companyId: id,
                            newStatus: 'verified',
                          ),
                        );
                        break;
                      case 'active':
                        bloc.add(
                          UpdateFactoryCompanyStatus(
                            companyId: id,
                            newStatus: 'active',
                          ),
                        );
                        break;
                      case 'inactive':
                        bloc.add(
                          UpdateFactoryCompanyStatus(
                            companyId: id,
                            newStatus: 'inactive',
                          ),
                        );
                        break;
                      case 'suspended':
                        bloc.add(
                          UpdateFactoryCompanyStatus(
                            companyId: id,
                            newStatus: 'suspended',
                          ),
                        );
                        break;
                      case 'edit':
                        _showEditFactoryCompanySheet(ctx, bloc, c);
                        break;
                      case 'restore':
                        bloc.add(RestoreFactoryCompany(id));
                        break;
                      case 'delete':
                        showDialog(
                          context: ctx,
                          builder: (dctx) => AlertDialog(
                            title: const Text('Delete Company?'),
                            content: Text('This will archive $name.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dctx),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.error,
                                ),
                                onPressed: () {
                                  Navigator.pop(dctx);
                                  bloc.add(DeleteFactoryCompany(id));
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        break;
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'verified',
                      child: ListTile(
                        leading: Icon(Icons.verified, color: Color(0xFF2563EB)),
                        title: Text('Verified'),
                        dense: true,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'active',
                      child: ListTile(
                        leading: Icon(
                          Icons.check_circle,
                          color: Color(0xFF059669),
                        ),
                        title: Text('Active'),
                        dense: true,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'inactive',
                      child: ListTile(
                        leading: Icon(
                          Icons.pause_circle,
                          color: Color(0xFFD97706),
                        ),
                        title: Text('Inactive'),
                        dense: true,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'suspended',
                      child: ListTile(
                        leading: Icon(Icons.block, color: AppColors.warning),
                        title: Text('Suspend'),
                        dense: true,
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit, color: Color(0xFF1F5E6B)),
                        title: Text('Update'),
                        dense: true,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'restore',
                      child: ListTile(
                        leading: Icon(Icons.restore, color: Color(0xFF059669)),
                        title: Text('Restore'),
                        dense: true,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: AppColors.error),
                        title: Text('Delete'),
                        dense: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Add Factory Company Bottom Sheet ──
  void _showAddFactoryCompanySheet(BuildContext context, SubAdminBloc bloc) {
    final nameCtrl = TextEditingController();
    final regCtrl = TextEditingController();
    final industryCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    final contactEmailCtrl = TextEditingController();
    final contactPhoneCtrl = TextEditingController();
    final countryCtrl = TextEditingController(text: 'Pakistan');
    final cityCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1B3A4B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: BlocConsumer<SubAdminBloc, SubAdminState>(
          listener: (lctx, state) {
            if (state.factoryFormSuccess != null) {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.factoryFormSuccess!),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          },
          builder: (lctx, state) => Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(lctx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Add Factory Company',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(16),
                  _sheetField('Company Name', nameCtrl),
                  const Gap(10),
                  _sheetField('Business Registration No.', regCtrl),
                  const Gap(10),
                  _sheetField(
                    'Industry Type (optional)',
                    industryCtrl,
                    TextInputType.text,
                    'FMCG, Pharma, Logistics',
                  ),
                  const Gap(10),
                  _sheetField('Contact Person Name', contactCtrl),
                  const Gap(10),
                  _sheetField(
                    'Contact Person Email',
                    contactEmailCtrl,
                    TextInputType.emailAddress,
                  ),
                  const Gap(10),
                  _sheetField(
                    'Contact Person Phone',
                    contactPhoneCtrl,
                    TextInputType.phone,
                  ),
                  const Gap(10),
                  _sheetField('Country', countryCtrl),
                  const Gap(10),
                  _sheetField('City', cityCtrl),
                  const Gap(10),
                  _sheetField(
                    'Password',
                    passwordCtrl,
                    TextInputType.visiblePassword,
                  ),
                  if (state.factoryFormError != null)
                    _formErrorBanner(
                      source:
                          'Sub-Admin · Factory Companies · POST /api/v1/admin/factory-companies',
                      message: state.factoryFormError!,
                      bloc: bloc,
                    ),
                  const Gap(16),
                  ElevatedButton(
                    onPressed: state.factoryFormLoading
                        ? null
                        : () {
                            bloc.add(
                              CreateFactoryCompany(
                                name: nameCtrl.text.trim(),
                                regNumber: regCtrl.text.trim(),
                                industryType: industryCtrl.text.trim(),
                                contactName: contactCtrl.text.trim(),
                                contactEmail: contactEmailCtrl.text.trim(),
                                contactPhone: contactPhoneCtrl.text.trim(),
                                country: countryCtrl.text.trim(),
                                city: cityCtrl.text.trim(),
                                password: passwordCtrl.text,
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F5E6B),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: state.factoryFormLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Create Company',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Edit Factory Company Bottom Sheet ──
  void _showEditFactoryCompanySheet(
    BuildContext context,
    SubAdminBloc bloc,
    Map<String, dynamic> company,
  ) {
    final id = company['id']?.toString() ?? '';
    final nameCtrl = TextEditingController(
      text:
          company['name']?.toString() ??
          company['account_name']?.toString() ??
          '',
    );
    final regCtrl = TextEditingController(
      text: company['business_registration_number']?.toString() ?? '',
    );
    final industryCtrl = TextEditingController(
      text: company['industry_type']?.toString() ?? '',
    );
    final contactCtrl = TextEditingController(
      text: company['contact_person_name']?.toString() ?? '',
    );
    final contactEmailCtrl = TextEditingController(
      text: company['contact_person_email']?.toString() ?? '',
    );
    final contactPhoneCtrl = TextEditingController(
      text: company['contact_person_phone']?.toString() ?? '',
    );
    final countryCtrl = TextEditingController(
      text: company['country']?.toString() ?? '',
    );
    final cityCtrl = TextEditingController(
      text: company['city']?.toString() ?? '',
    );
    final passwordCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1B3A4B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: BlocConsumer<SubAdminBloc, SubAdminState>(
          listener: (lctx, state) {
            if (state.actionSuccess != null) {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.actionSuccess!),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          },
          builder: (lctx, state) => Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(lctx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Edit Factory Company',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(16),
                  _sheetField('Company Name', nameCtrl),
                  const Gap(10),
                  _sheetField('Business Registration No.', regCtrl),
                  const Gap(10),
                  _sheetField('Industry Type', industryCtrl),
                  const Gap(10),
                  _sheetField('Contact Person Name', contactCtrl),
                  const Gap(10),
                  _sheetField(
                    'Contact Person Email',
                    contactEmailCtrl,
                    TextInputType.emailAddress,
                  ),
                  const Gap(10),
                  _sheetField(
                    'Contact Person Phone',
                    contactPhoneCtrl,
                    TextInputType.phone,
                  ),
                  const Gap(10),
                  _sheetField('Country', countryCtrl),
                  const Gap(10),
                  _sheetField('City', cityCtrl),
                  const Gap(10),
                  _sheetField(
                    'New Password (leave blank to keep existing)',
                    passwordCtrl,
                    TextInputType.visiblePassword,
                  ),
                  if (state.actionError != null)
                    _formErrorBanner(
                      source:
                          'Sub-Admin · Factory Companies · PUT /api/v1/admin/factory-companies/{id}',
                      message: state.actionError!,
                      bloc: bloc,
                    ),
                  const Gap(16),
                  ElevatedButton(
                    onPressed: state.actionLoading
                        ? null
                        : () {
                            final data = <String, dynamic>{
                              'name': nameCtrl.text.trim(),
                              'business_registration_number': regCtrl.text
                                  .trim(),
                              'industry_type': industryCtrl.text.trim(),
                              'contact_person_name': contactCtrl.text.trim(),
                              'contact_person_email': contactEmailCtrl.text
                                  .trim(),
                              'contact_person_phone': contactPhoneCtrl.text
                                  .trim(),
                              'country': countryCtrl.text.trim(),
                              'city': cityCtrl.text.trim(),
                            };
                            final pwd = passwordCtrl.text;
                            if (pwd.isNotEmpty) {
                              data['password'] = pwd;
                            }
                            bloc.add(
                              EditFactoryCompany(companyId: id, data: data),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F5E6B),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: state.actionLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Reseller Sub-Admin Dashboard (commercial_marketplace, C2b) ──
  /// Only provisions and manages reseller accounts (MASTER-TASK-LIST.md §2b).
  Widget _resellerDashboard(
    BuildContext ctx,
    SubAdminBloc bloc,
    SubAdminState state,
  ) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // KPI Cards
        Row(
          key: _dashboardTopKey,
          children: [
            _kpiCard(
              'Resellers',
              '${state.resellerAccounts.length}',
              Icons.storefront,
              const Color(0xFF7C3AED),
            ),
            const Gap(12),
            _kpiCard(
              'Features',
              '${state.activeFeatures.length}',
              Icons.grid_view,
              const Color(0xFF2563EB),
            ),
            const Gap(12),
            _kpiCard(
              'Revenue',
              '\$${state.monthlyRevenue.toStringAsFixed(0)}',
              Icons.trending_up,
              const Color(0xFF059669),
            ),
          ],
        ),
        const Gap(24),

        // Quick Actions
        const Text(
          'Quick Actions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Gap(12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _actionBtn(
              Icons.add_business,
              'Add Reseller Account',
              () => _showAddResellerAccountSheet(ctx, bloc),
            ),
            _actionBtn(Icons.list_alt, 'View Accounts', () {
              bloc.add(const FetchResellerAccounts());
              _revealListSection();
            }),
            // A 'Reports' action used to sit here with an empty `() {}` onTap, so
            // it did nothing when clicked. Reports/billing belong to the
            // financial_auditor vertical (C0 §2b.3), not the marketplace
            // sub-admin's, so it is removed rather than left dead.
          ],
        ),
        const Gap(24),

        // Reseller Accounts Section
        Row(
          key: _listSectionKey,
          children: [
            const Expanded(
              child: Text(
                'Registered Reseller Accounts',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () => bloc.add(const FetchResellerAccounts()),
              icon: const Icon(
                Icons.refresh,
                size: 16,
                color: Color(0xFFBDD8DB),
              ),
              label: const Text(
                'Refresh',
                style: TextStyle(color: Color(0xFFBDD8DB)),
              ),
            ),
          ],
        ),
        const Gap(8),
        if (state.resellerListError != null)
          _listErrorBanner(
            source:
                'Sub-Admin · Reseller Accounts · GET /api/v1/admin/reseller-accounts',
            message:
                'Could not load reseller accounts: ${state.resellerListError}',
          )
        else if (state.resellerAccounts.isEmpty)
          _listEmptyBox('No reseller accounts registered yet.')
        else
          ...state.resellerAccounts.map(
            (c) => _resellerAccountCard(ctx, bloc, c),
          ),
      ],
    );
  }

  // ── Reseller Account Card ──
  Widget _resellerAccountCard(
    BuildContext ctx,
    SubAdminBloc bloc,
    Map<String, dynamic> c,
  ) {
    final businessName = c['business_name']?.toString() ?? 'Unknown';
    final personName = c['name']?.toString() ?? '';
    final city = c['city']?.toString() ?? '';
    final registrationNo = c['registration_no']?.toString() ?? '';
    final status = c['status']?.toString() ?? 'active';
    final id = c['id']?.toString() ?? '';
    final statusColor = _statusColor(status);
    final statusLabel = _statusLabel(status);

    return Card(
      color: const Color(0xFF1B3A4B),
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: statusColor,
                  child: Text(
                    businessName.isNotEmpty
                        ? businessName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        businessName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (personName.isNotEmpty)
                        Text(
                          personName,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      if (city.isNotEmpty)
                        Text(
                          city,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      if (registrationNo.isNotEmpty)
                        Text(
                          'Reg: $registrationNo',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white54),
                  color: const Color(0xFF1B3A4B),
                  onSelected: (action) {
                    switch (action) {
                      case 'active':
                        bloc.add(
                          UpdateResellerAccountStatus(
                            accountId: id,
                            newStatus: 'active',
                          ),
                        );
                        break;
                      case 'inactive':
                        bloc.add(
                          UpdateResellerAccountStatus(
                            accountId: id,
                            newStatus: 'inactive',
                          ),
                        );
                        break;
                      case 'suspended':
                        bloc.add(
                          UpdateResellerAccountStatus(
                            accountId: id,
                            newStatus: 'suspended',
                          ),
                        );
                        break;
                      case 'edit':
                        _showEditResellerAccountSheet(ctx, bloc, c);
                        break;
                      case 'restore':
                        bloc.add(RestoreResellerAccount(id));
                        break;
                      case 'delete':
                        showDialog(
                          context: ctx,
                          builder: (dctx) => AlertDialog(
                            title: const Text('Delete Account?'),
                            content: Text('This will archive $businessName.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dctx),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.error,
                                ),
                                onPressed: () {
                                  Navigator.pop(dctx);
                                  bloc.add(DeleteResellerAccount(id));
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        break;
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'active',
                      child: ListTile(
                        leading: Icon(
                          Icons.check_circle,
                          color: Color(0xFF059669),
                        ),
                        title: Text('Active'),
                        dense: true,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'inactive',
                      child: ListTile(
                        leading: Icon(
                          Icons.pause_circle,
                          color: Color(0xFFD97706),
                        ),
                        title: Text('Inactive'),
                        dense: true,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'suspended',
                      child: ListTile(
                        leading: Icon(Icons.block, color: AppColors.warning),
                        title: Text('Suspend'),
                        dense: true,
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit, color: Color(0xFF1F5E6B)),
                        title: Text('Update'),
                        dense: true,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'restore',
                      child: ListTile(
                        leading: Icon(Icons.restore, color: Color(0xFF059669)),
                        title: Text('Restore'),
                        dense: true,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: AppColors.error),
                        title: Text('Delete'),
                        dense: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Add Reseller Account Bottom Sheet ──
  void _showAddResellerAccountSheet(BuildContext context, SubAdminBloc bloc) {
    final nameCtrl = TextEditingController();
    final businessCtrl = TextEditingController();
    final regCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final addressCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1B3A4B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: BlocConsumer<SubAdminBloc, SubAdminState>(
          listener: (lctx, state) {
            if (state.resellerFormSuccess != null) {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.resellerFormSuccess!),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          },
          builder: (lctx, state) => Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(lctx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Add Reseller Account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(16),
                  _sheetField('Full Name', nameCtrl),
                  const Gap(10),
                  _sheetField('Business Name', businessCtrl),
                  const Gap(10),
                  _sheetField('Registration No.', regCtrl),
                  const Gap(10),
                  _sheetField('Email', emailCtrl, TextInputType.emailAddress),
                  const Gap(10),
                  _sheetField('Phone', phoneCtrl, TextInputType.phone),
                  const Gap(10),
                  _sheetField(
                    'Password',
                    passwordCtrl,
                    TextInputType.visiblePassword,
                  ),
                  const Gap(10),
                  _sheetField('City', cityCtrl),
                  const Gap(10),
                  _sheetField('Address (optional)', addressCtrl),
                  if (state.resellerFormError != null)
                    _formErrorBanner(
                      source:
                          'Sub-Admin · Reseller Accounts · POST /api/v1/admin/reseller-accounts',
                      message: state.resellerFormError!,
                      bloc: bloc,
                    ),
                  const Gap(16),
                  ElevatedButton(
                    onPressed: state.resellerFormLoading
                        ? null
                        : () {
                            bloc.add(
                              CreateResellerAccount(
                                name: nameCtrl.text.trim(),
                                businessName: businessCtrl.text.trim(),
                                registrationNo: regCtrl.text.trim(),
                                email: emailCtrl.text.trim(),
                                phone: phoneCtrl.text.trim(),
                                password: passwordCtrl.text,
                                city: cityCtrl.text.trim(),
                                address: addressCtrl.text.trim(),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F5E6B),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: state.resellerFormLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Create Account',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Edit Reseller Account Bottom Sheet ──
  void _showEditResellerAccountSheet(
    BuildContext context,
    SubAdminBloc bloc,
    Map<String, dynamic> account,
  ) {
    final id = account['id']?.toString() ?? '';
    final nameCtrl = TextEditingController(
      text: account['name']?.toString() ?? '',
    );
    final businessCtrl = TextEditingController(
      text: account['business_name']?.toString() ?? '',
    );
    final regCtrl = TextEditingController(
      text: account['registration_no']?.toString() ?? '',
    );
    final emailCtrl = TextEditingController(
      text: account['email']?.toString() ?? '',
    );
    final phoneCtrl = TextEditingController(
      text: account['phone']?.toString() ?? '',
    );
    final passwordCtrl = TextEditingController();
    final cityCtrl = TextEditingController(
      text: account['city']?.toString() ?? '',
    );
    final addressCtrl = TextEditingController(
      text: account['address']?.toString() ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1B3A4B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: BlocConsumer<SubAdminBloc, SubAdminState>(
          listener: (lctx, state) {
            if (state.actionSuccess != null) {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.actionSuccess!),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          },
          builder: (lctx, state) => Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(lctx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Edit Reseller Account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(16),
                  _sheetField('Full Name', nameCtrl),
                  const Gap(10),
                  _sheetField('Business Name', businessCtrl),
                  const Gap(10),
                  _sheetField('Registration No.', regCtrl),
                  const Gap(10),
                  _sheetField('Email', emailCtrl, TextInputType.emailAddress),
                  const Gap(10),
                  _sheetField('Phone', phoneCtrl, TextInputType.phone),
                  const Gap(10),
                  _sheetField(
                    'New Password (leave blank to keep existing)',
                    passwordCtrl,
                    TextInputType.visiblePassword,
                  ),
                  const Gap(10),
                  _sheetField('City', cityCtrl),
                  const Gap(10),
                  _sheetField('Address', addressCtrl),
                  if (state.actionError != null)
                    _formErrorBanner(
                      source:
                          'Sub-Admin · Reseller Accounts · PUT /api/v1/admin/reseller-accounts/{id}',
                      message: state.actionError!,
                      bloc: bloc,
                    ),
                  const Gap(16),
                  ElevatedButton(
                    onPressed: state.actionLoading
                        ? null
                        : () {
                            final data = <String, dynamic>{
                              'name': nameCtrl.text.trim(),
                              'business_name': businessCtrl.text.trim(),
                              'registration_no': regCtrl.text.trim(),
                              'email': emailCtrl.text.trim(),
                              'phone': phoneCtrl.text.trim(),
                              'city': cityCtrl.text.trim(),
                              'address': addressCtrl.text.trim(),
                            };
                            final pwd = passwordCtrl.text;
                            if (pwd.isNotEmpty) {
                              data['password'] = pwd;
                            }
                            bloc.add(
                              EditResellerAccount(accountId: id, data: data),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F5E6B),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: state.actionLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sheetField(
    String label,
    TextEditingController ctrl, [
    TextInputType type = TextInputType.text,
    String? hint,
  ]) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        labelStyle: const TextStyle(color: Colors.white54),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0x30FFFFFF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1F5E6B)),
        ),
        filled: true,
        fillColor: const Color(0x10FFFFFF),
      ),
    );
  }

  void _openPresetsList(BuildContext ctx) {
    Navigator.push(
      ctx,
      MaterialPageRoute(builder: (_) => const _SubAdminPresetsListPage()),
    );
  }
}

// ── Presets List Page ──
class _SubAdminPresetsListPage extends StatefulWidget {
  const _SubAdminPresetsListPage();
  @override
  State<_SubAdminPresetsListPage> createState() =>
      _SubAdminPresetsListPageState();
}

class _SubAdminPresetsListPageState extends State<_SubAdminPresetsListPage> {
  List<Map<String, dynamic>> _presets = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final api = ApiService();
      final r = await api.get('/admin/absolute-layouts');
      final d = r?['data'];
      // Response wraps: { data: { data: [...], pagination: {...} } }
      final list = d is Map ? d['data'] : d;
      setState(() {
        _presets = list is List ? list.cast<Map<String, dynamic>>() : [];
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _delete(String id) async {
    try {
      final api = ApiService();
      await api.delete('/admin/absolute-layouts/$id');
      _load();
    } catch (_) {}
  }

  void _openPreset(Map<String, dynamic> p) {
    final id = p['id']?.toString();
    if (id == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AbsoluteLayoutDesignerScreen(
          companyId: '',
          companyName: p['display_name']?.toString() ?? 'Preset',
          apiPrefix: '/admin',
          layoutId: id,
        ),
      ),
    );
  }

  Future<void> _editPreset(Map<String, dynamic> p) async {
    final id = p['id']?.toString();
    if (id == null) return;

    // Pre-fetch the full preset data so the edit form is fully populated.
    BusDimensions? dims;
    ComponentRegistry? reg;
    String? name;
    int leftS = 0, rightS = 0, rows = 0;
    bool hasFront = false;
    int frontFt = 0, frontIn = 0;
    try {
      final api = ApiService();
      final r = await api.get('/admin/absolute-layouts/$id');
      final d = r?['data'];
      if (d is Map) {
        name = d['display_name']?.toString() ?? d['name']?.toString() ?? '';
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
        // Derive seat matrix from components
        final comps = snapMap?['components'];
        if (comps is List && comps.isNotEmpty) {
          final frontPxRaw =
              snapMap?['metadata']?['front_partition_px'] ??
              snapMap?['front_partition_px'];
          final double frontBoundary = frontPxRaw is num
              ? (frontPxRaw).toDouble() > 0
                    ? (frontPxRaw).toDouble()
                    : 0.0
              : 0.0;
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
            if (y < frontBoundary) continue;
            ySet.add(y.round());
            if (y < minSeatY) minSeatY = y;
            if (firstY == null) firstY = y;
            if ((y - firstY).abs() < 5) firstRowXs.add(x);
          }
          int lC = 0, rC = 0;
          if (firstRowXs.isNotEmpty) {
            firstRowXs.sort();
            bool hasBerths = false;
            for (final c in comps) {
              if (c is! Map) continue;
              final t = c['type']?.toString() ?? '';
              final y = (c['y'] as num?)?.toDouble();
              if (y != null && firstY != null && (y - firstY).abs() < 5) {
                if (t == 'sleeperLower' || t == 'sleeperUpper') {
                  hasBerths = true;
                  break;
                }
              }
            }
            final mergeGap = hasBerths ? 80.0 : 20.0;
            final merged = <double>[firstRowXs.first];
            for (int i = 1; i < firstRowXs.length; i++) {
              if (firstRowXs[i] - merged.last > mergeGap)
                merged.add(firstRowXs[i]);
            }
            double maxGap = 0;
            int gapIdx = 0;
            for (int i = 1; i < merged.length; i++) {
              final gap = merged[i] - merged[i - 1];
              if (gap > maxGap) {
                maxGap = gap;
                gapIdx = i;
              }
            }
            final avgGap = merged.length > 1
                ? (merged.last - merged.first) / (merged.length - 1)
                : 0.0;
            if (maxGap > 30 && merged.length > 1 && maxGap >= avgGap * 1.5) {
              lC = gapIdx;
              rC = merged.length - gapIdx;
            } else {
              final cw = (snapCanvas is Map
                  ? ((snapCanvas['canvas_width'] as num?)?.toDouble() ?? 280)
                  : 280);
              final allRight = merged.every((x) => x > cw * 0.20);
              final allLeft = merged.every((x) => x < cw * 0.80);
              if (allRight && !allLeft) {
                lC = 0;
                rC = merged.length;
              } else if (allLeft && !allRight) {
                lC = merged.length;
                rC = 0;
              } else {
                for (final x in merged) {
                  if (x < cw / 2)
                    lC++;
                  else
                    rC++;
                }
              }
            }
          }
          // ── Seat matrix from metadata (authoritative saved values) ──
          final savedLeft =
              snapMap?['metadata']?['left_seats'] ?? snapMap?['left_seats'];
          final savedRight =
              snapMap?['metadata']?['right_seats'] ?? snapMap?['right_seats'];
          final savedRows =
              snapMap?['metadata']?['row_count'] ?? snapMap?['row_count'];
          if (savedLeft is int && savedRight is int && savedRows is int) {
            leftS = savedLeft.clamp(0, 8);
            rightS = savedRight.clamp(0, 8);
            rows = savedRows.clamp(1, 50);
          } else {
            leftS = lC.clamp(0, 8);
            rightS = rC.clamp(0, 8);
            rows = hasFront
                ? ySet.length.clamp(1, 50)
                : (ySet.length + 1).clamp(1, 50);
          }
          // Front partition detection
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
          }
        }
      }
    } catch (_) {}

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider<LayoutValidationBloc>(
          create: (_) {
            final b = LayoutValidationBloc();
            if (dims != null) b.add(DimensionsChanged(dims));
            b.add(RegistryChanged(reg ?? const ComponentRegistry()));
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
            companyId: '',
            companyName: 'Template',
            apiPrefix: '/admin',
            isPreset: true,
            layoutId: id,
            initialDimensions: dims,
            initialRegistry: reg,
            initialPlate: name,
            initialLeftSeats: leftS,
            initialRightSeats: rightS,
            initialRowCount: rows,
            initialHasFrontPartition: hasFront,
            initialFrontPartitionFt: frontFt,
            initialFrontPartitionIn: frontIn,
          ),
        ),
      ),
    ).then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1628),
        title: const Text(
          'Layout Presets',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white54),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _presets.isEmpty
          ? const Center(
              child: Text(
                'No presets yet',
                style: TextStyle(color: Colors.white54),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _presets.length,
              itemBuilder: (_, i) {
                final p = _presets[i];
                return Card(
                  color: const Color(0xFF1A2A3A),
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.airline_seat_recline_normal,
                      color: Color(0xFF7C3AED),
                    ),
                    title: Text(
                      p['display_name']?.toString() ?? '—',
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      '${p['total_components'] ?? '?'} components',
                      style: const TextStyle(
                        color: Color(0xFF8899AA),
                        fontSize: 11,
                      ),
                    ),
                    onTap: () => _openPreset(p),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Color(0xFF00B4D8),
                            size: 20,
                          ),
                          onPressed: () => _editPreset(p),
                          tooltip: 'Edit',
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                          onPressed: () => _delete(p['id']?.toString() ?? ''),
                          tooltip: 'Delete',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ── Sidebar ──
class _Sidebar extends StatelessWidget {
  final SubAdminBloc bloc;
  final SubAdminState state;
  final String vertical;
  final VoidCallback onDashboardTap;
  const _Sidebar({
    required this.bloc,
    required this.state,
    required this.vertical,
    required this.onDashboardTap,
  });

  /// Build sidebar items dynamically based on the sub-admin's vertical.
  /// Each vertical only gets the shortcuts its own dashboard can actually use.
  List<Widget> _buildNavItems(BuildContext context) {
    if (vertical == 'cricket_ops') {
      // Cricket vertical: Sub-Admin only manages Cricket Operations
      // Manager accounts — single navigation item.
      return [
        Missile3DButton(
          label: 'Cricket Managers',
          icon: Icons.people,
          color: const Color(0xFF059669),
          height: 64,
          onTap: () => context.go('/sub-admin/cricket/managers'),
        ),
      ];
    }
    // Factory and Marketplace manage their accounts inline on their own
    // dashboard (C2 / C2b) — the seat-template / layout-preset shortcuts below
    // are bus-only and make no sense in those panels, so they are excluded.
    if (vertical == 'factory' || vertical == 'commercial_marketplace') {
      return [
        // Scrolls the dashboard content back to the top. This used to be a
        // silent no-op (`() {}`), so clicking it did nothing at all.
        Missile3DButton(
          label: 'Dashboard',
          icon: Icons.dashboard,
          color: SubAdminVerticals.color(vertical),
          height: 64,
          onTap: onDashboardTap,
        ),
        // Marketplace oversight — READ-ONLY (MASTER-TASK-LIST.md §4 done-ledger item #11).
        // The commercial_marketplace Sub-Admin owns no factory and no product: it
        // controls the marketplace *platform* (disputes, content, reseller /
        // shop-keeper accounts), so it observes listings and orders here and
        // never creates either.
        if (vertical == 'commercial_marketplace')
          Missile3DButton(
            label: 'Marketplace Oversight',
            icon: Icons.storefront_outlined,
            color: const Color(0xFF0D9488),
            height: 64,
            onTap: () => context.go('/sub-admin/marketplace'),
          ),
        Missile3DButton(
          label: 'Refresh Data',
          icon: Icons.refresh,
          color: const Color(0xFF2563EB),
          height: 56,
          onTap: () => bloc.add(const BootstrapDashboard()),
        ),
      ];
    }
    // Default: the original bus / goods / marketplace workspace, which is the
    // only dashboard with seat-template and layout-preset tooling.
    return [
      // Scrolls the dashboard content back to the top. This used to be a silent
      // no-op (`() {}`), so clicking it did nothing at all.
      Missile3DButton(
        label: 'Dashboard',
        icon: Icons.dashboard,
        color: const Color(0xFF7C3AED),
        height: 64,
        onTap: onDashboardTap,
      ),
      // NOTE: a 'Bus Companies' button used to sit here with an empty onTap. Removed 2026-09-26
      // (A3): the bus-company management is inline in this same dashboard, so the entry was a dead
      // duplicate. Re-add a WIRED shortcut only if it is actually given a destination.
      Missile3DButton(
        label: 'Seat Templates & Presets',
        icon: Icons.airline_seat_recline_normal,
        color: const Color(0xFF00B4D8),
        height: 64,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider<LayoutValidationBloc>(
                create: (_) => LayoutValidationBloc(),
                child: const BusConfigSetupScreen(
                  companyId: '',
                  companyName: 'Template',
                  apiPrefix: '/admin',
                  isPreset: true,
                ),
              ),
            ),
          );
        },
      ),
      Missile3DButton(
        label: 'View All Preset Layouts',
        icon: Icons.list_alt,
        color: const Color(0xFF059669),
        height: 56,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const _SubAdminPresetsListPage()),
          );
        },
      ),
      Missile3DButton(
        label: 'Refresh Data',
        icon: Icons.refresh,
        color: const Color(0xFF2563EB),
        height: 56,
        onTap: () => bloc.add(const BootstrapDashboard()),
      ),
    ];
  }

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
          const Gap(20),
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
                      colors: [Color(0xFF1F5E6B), Color(0xFF0D3440)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1F5E6B).withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      state.subAdminName.isNotEmpty
                          ? state.subAdminName[0].toUpperCase()
                          : 'S',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.subAdminName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F5E6B).withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          SubAdminVerticals.label(vertical).toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFBDD8DB),
                            fontSize: 9,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(16),
          const Divider(height: 1, color: Color(0x20FFFFFF)),
          const Gap(8),
          // Section label
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Text(
              'NAVIGATION',
              style: TextStyle(
                color: Color(0xFFBDD8DB),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ),
          // Pencil-shape navigation buttons
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 4),
              children: _buildNavItems(context),
            ),
          ),
          const Divider(height: 1, color: Color(0x20FFFFFF)),
          // Logout
          Padding(
            padding: const EdgeInsets.all(12),
            child: Missile3DButton(
              label: 'Logout',
              icon: Icons.logout,
              color: const Color(0xFFDC2626),
              height: 48,
              onTap: () async {
                bloc.add(const SubAdminLogout());
                if (context.mounted) context.go('/sub-admin/login');
              },
            ),
          ),
          const Gap(8),
        ],
      ),
    );
  }
}

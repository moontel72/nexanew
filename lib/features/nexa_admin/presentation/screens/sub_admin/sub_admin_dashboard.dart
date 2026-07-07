// Sub-Admin Dashboard Screen — BLoC-driven
//
// Post-login workspace for a vertical sub-admin.
// Shows KPIs, bus company management, and profile info.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/sub_admin/sub_admin_bloc.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/sub_admin/sub_admin_event.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/sub_admin/sub_admin_state.dart';
import 'package:trace_odd/shared/theme/colors.dart';

class SubAdminDashboardScreen extends StatelessWidget {
  const SubAdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SubAdminBloc()..add(const BootstrapDashboard()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubAdminBloc, SubAdminState>(
      builder: (ctx, state) {
        if (state.dashStatus == SubAdminViewStatus.loading) {
          return const Scaffold(
            backgroundColor: Color(0xFF0C1D2C),
            body: Center(child: CircularProgressIndicator(color: Color(0xFF1F5E6B))),
          );
        }
        final bloc = ctx.read<SubAdminBloc>();
        final wide = MediaQuery.of(ctx).size.width > 900;
        return Scaffold(
          backgroundColor: const Color(0xFF0C1D2C),
          body: Row(children: [
            if (wide) _Sidebar(bloc: bloc, state: state),
            Expanded(child: _content(ctx, bloc, state, wide)),
          ]),
        );
      },
    );
  }

  Widget _content(BuildContext ctx, SubAdminBloc bloc, SubAdminState state, bool wide) {
    return Column(children: [
      _topBar(state, wide),
      Expanded(
        child: state.busListLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF1F5E6B)))
            : Builder(builder: (_) {
                // Determine which sub-page to show (managed inside bloc via events or local index)
                // For simplicity, we'll keep the dashboard + bus company list as the main view
                // since the BLoC already loads bus companies on bootstrap.
                return _mainView(ctx, bloc, state);
              }),
      ),
    ]);
  }

  // ── Top Bar ──
  Widget _topBar(SubAdminState state, bool wide) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF0F2936),
        border: Border(bottom: BorderSide(color: Color(0x20FFFFFF))),
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFF1F5E6B),
          child: Text(
            state.subAdminName.isNotEmpty ? state.subAdminName[0].toUpperCase() : 'S',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
        const Gap(12),
        Text(state.subAdminName,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        const Spacer(),
        Text('${state.tenantCount} tenants · ${state.activeFeatures.length} features',
            style: const TextStyle(color: Color(0xFFBDD8DB), fontSize: 12)),
      ]),
    );
  }

  // ── Main Dashboard View ──
  Widget _mainView(BuildContext ctx, SubAdminBloc bloc, SubAdminState state) {
    return ListView(padding: const EdgeInsets.all(20), children: [
      // KPI Cards
      Row(children: [
        _kpiCard('Tenants', '${state.tenantCount}', Icons.business, const Color(0xFF7C3AED)),
        const Gap(12),
        _kpiCard('Features', '${state.activeFeatures.length}', Icons.grid_view, const Color(0xFF2563EB)),
        const Gap(12),
        _kpiCard('Revenue', '\$${state.monthlyRevenue.toStringAsFixed(0)}', Icons.trending_up, const Color(0xFF059669)),
      ]),
      const Gap(24),

      // Quick Actions
      const Text('Quick Actions', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
      const Gap(12),
      Wrap(spacing: 12, runSpacing: 12, children: [
        _actionBtn(Icons.add_business, 'Add Bus Company', () => _showAddBusCompanySheet(ctx, bloc)),
        _actionBtn(Icons.list_alt, 'View Companies', () {}),
        _actionBtn(Icons.people, 'Manage Staff', () {}),
        _actionBtn(Icons.receipt_long, 'Reports', () {}),
      ]),
      const Gap(24),

      // Bus Companies Section
      Row(children: [
        const Expanded(child: Text('Registered Bus Companies',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
        TextButton.icon(
          onPressed: () => bloc.add(const FetchBusCompanies()),
          icon: const Icon(Icons.refresh, size: 16, color: Color(0xFFBDD8DB)),
          label: const Text('Refresh', style: TextStyle(color: Color(0xFFBDD8DB))),
        ),
      ]),
      const Gap(8),
      if (state.busCompanies.isEmpty)
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF1B3A4B),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text('No bus companies registered yet.', style: TextStyle(color: Colors.white54)),
          ),
        )
      else
        ...state.busCompanies.map((c) => _busCompanyCard(ctx, bloc, c)),
    ]);
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: color, size: 18),
            const Spacer(),
            Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w700)),
          ]),
          const Gap(4),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ]),
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
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: const Color(0xFF1F5E6B), size: 18),
          const Gap(8),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ]),
      ),
    );
  }

  // ── Bus Company Card ──
  Widget _busCompanyCard(BuildContext ctx, SubAdminBloc bloc, Map<String, dynamic> c) {
    final name = c['name']?.toString() ?? 'Unknown';
    final email = c['email']?.toString() ?? '';
    final status = c['status']?.toString() ?? 'active';
    final isActive = status == 'active';
    final id = c['id']?.toString() ?? '';

    return Card(
      color: const Color(0xFF1B3A4B),
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isActive ? const Color(0xFF059669) : AppColors.warning,
          child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ),
        title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        subtitle: Text('$email · ${isActive ? "Active" : "Suspended"}',
            style: TextStyle(color: isActive ? AppColors.success : AppColors.warning, fontSize: 11)),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white54),
          color: const Color(0xFF1B3A4B),
          onSelected: (action) {
            switch (action) {
              case 'toggle': bloc.add(ToggleBusCompanyStatus(id)); break;
              case 'delete':
                showDialog(context: ctx, builder: (dctx) => AlertDialog(
                  title: const Text('Delete Company?'),
                  content: Text('This will archive $name.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(dctx), child: const Text('Cancel')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                      onPressed: () { Navigator.pop(dctx); bloc.add(DeleteBusCompany(id)); },
                      child: const Text('Delete')),
                  ],
                ));
                break;
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'toggle',
              child: ListTile(
                leading: Icon(isActive ? Icons.block : Icons.check_circle,
                    color: isActive ? AppColors.warning : AppColors.success),
                title: Text(isActive ? 'Suspend' : 'Activate'), dense: true,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: AppColors.error),
                title: Text('Delete'), dense: true,
              ),
            ),
          ],
        ),
      ),
    );
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
                SnackBar(content: Text(state.busFormSuccess!), backgroundColor: AppColors.success));
            }
          },
          builder: (lctx, state) => Padding(
            padding: EdgeInsets.only(
              left: 20, right: 20, top: 20,
              bottom: MediaQuery.of(lctx).viewInsets.bottom + 20,
            ),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Text('Add Bus Company', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              const Gap(16),
              _sheetField('Company Name', nameCtrl),
              const Gap(10), _sheetField('Email', emailCtrl, TextInputType.emailAddress),
              const Gap(10), _sheetField('Phone', phoneCtrl, TextInputType.phone),
              const Gap(10), _sheetField('Registration Code', regCtrl),
              const Gap(10), _sheetField('Fleet Size', fleetCtrl, TextInputType.number),
              const Gap(10), _sheetField('License Number', licenseCtrl),
              const Gap(10), _sheetField('Password', passwordCtrl, TextInputType.visiblePassword),
              if (state.busFormError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(state.busFormError!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
                ),
              const Gap(16),
              ElevatedButton(
                onPressed: state.busFormLoading ? null : () {
                  bloc.add(CreateBusCompany(
                    name: nameCtrl.text.trim(), email: emailCtrl.text.trim(),
                    password: passwordCtrl.text, phone: phoneCtrl.text.trim(),
                    regCode: regCtrl.text.trim(), fleetSize: fleetCtrl.text.trim(),
                    license: licenseCtrl.text.trim(),
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F5E6B),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: state.busFormLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Create Company', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _sheetField(String label, TextEditingController ctrl, [TextInputType type = TextInputType.text]) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
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
}

// ── Sidebar ──
class _Sidebar extends StatelessWidget {
  final SubAdminBloc bloc;
  final SubAdminState state;
  const _Sidebar({required this.bloc, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: const BoxDecoration(
        color: Color(0xFF091524),
        border: Border(right: BorderSide(color: Color(0x20FFFFFF))),
      ),
      child: Column(children: [
        const Gap(24),
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF1F5E6B),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(state.subAdminName.isNotEmpty ? state.subAdminName[0].toUpperCase() : 'S',
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
          alignment: Alignment.center,
        ),
        const Gap(8),
        Text(state.subAdminName,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        const Gap(4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF1F5E6B).withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text('SUB-ADMIN', style: TextStyle(color: Color(0xFFBDD8DB), fontSize: 10, letterSpacing: 0.5)),
        ),
        const Gap(24),
        _navItem(Icons.dashboard, 'Dashboard', true),
        _navItem(Icons.refresh, 'Refresh Data', false, onTap: () => bloc.add(const BootstrapDashboard())),
        const Spacer(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.redAccent, size: 18),
          title: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
          onTap: () async {
            bloc.add(const SubAdminLogout());
            if (context.mounted) context.go('/sub-admin/login');
          },
          dense: true,
        ),
        const Gap(12),
      ]),
    );
  }

  Widget _navItem(IconData icon, String label, bool active, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: active ? const Color(0xFF1F5E6B) : Colors.white54, size: 18),
      title: Text(label, style: TextStyle(color: active ? Colors.white : Colors.white54, fontSize: 12)),
      onTap: onTap,
      dense: true,
    );
  }
}

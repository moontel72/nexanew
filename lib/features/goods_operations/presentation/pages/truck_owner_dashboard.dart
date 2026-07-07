// Truck Owner Dashboard — BLoC-driven root for truck-owner panel
// Mirrors the bus-owner OwnerDashboardBloc pattern for truck operations.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/add_staff_dialog.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/dashboard_kpi_section.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/staff_list_section.dart';
import 'package:trace_odd/features/goods_operations/presentation/bloc/truck_owner/truck_owner_bloc.dart';
import 'package:trace_odd/features/goods_operations/presentation/bloc/truck_owner/truck_owner_event.dart';
import 'package:trace_odd/features/goods_operations/presentation/bloc/truck_owner/truck_owner_state.dart';
import 'package:trace_odd/shared/theme/colors.dart';

class TruckOwnerDashboardPage extends StatelessWidget {
  final String panelPrefix;
  const TruckOwnerDashboardPage({super.key, this.panelPrefix = '/truck-owner'});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TruckOwnerDashboardBloc()
        ..add(const BootstrapTruckOwner(
          storagePrefix: 'truckFleet',
          panelPrefix: '/truck-owner',
          loginRoute: '/truck-owner/login',
        )),
      child: const _TruckOwnerView(),
    );
  }
}

class _TruckOwnerView extends StatelessWidget {
  const _TruckOwnerView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TruckOwnerDashboardBloc, TruckOwnerState>(
      builder: (ctx, state) {
        if (state.status == TruckOwnerStatus.loading) {
          return const Scaffold(
            backgroundColor: Color(0xFF0D1B2A),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final bloc = ctx.read<TruckOwnerDashboardBloc>();
        final wide = MediaQuery.of(ctx).size.width > 900;
        // Auto-load link status
        if (state.currentPage == 'carrier' && !state.linkLoading && state.linkStatus == null) {
          Future.microtask(() => bloc.add(const LoadTruckLinkStatus()));
        }
        return Scaffold(
          backgroundColor: const Color(0xFF0D1B2A),
          body: Row(children: [
            if (wide) _Sidebar(bloc: bloc, state: state),
            Expanded(child: _content(ctx, bloc, state)),
          ]),
        );
      },
    );
  }

  Widget _content(BuildContext ctx, TruckOwnerDashboardBloc bloc, TruckOwnerState state) {
    switch (state.currentPage) {
      case 'drivers':
        return _driversTab(bloc, state);
      case 'conductors':
        return _conductorsTab(bloc, state);
      case 'vehicles':
        return _vehiclesTab(bloc, state);
      case 'carrier':
        return _carrierLinkTab(bloc, state);
      case 'freight':
        return _freightTab(bloc, state);
      default:
        return _dashboardTab(bloc, state);
    }
  }

  // ── Dashboard Home ──
  Widget _dashboardTab(TruckOwnerDashboardBloc bloc, TruckOwnerState state) {
    return ListView(padding: const EdgeInsets.all(20), children: [
      _topBar(state),
      const Gap(16),
      DashboardKpiSection(
        metrics: {
          'Drivers': state.driverCount.toString(),
          'Conductors': state.conductorCount.toString(),
          'Vehicles': state.vehicleCount.toString(),
          'Freight Loads': state.freightLoadCount.toString(),
        },
      ),
      const Gap(20),
      Row(children: [
        _quickAction(Icons.person_add, 'Add Driver', () => _showAddDriverDialog(context, bloc)),
        const Gap(12),
        _quickAction(Icons.group_add, 'Add Conductor', () => _showAddConductorDialog(context, bloc)),
        const Gap(12),
        _quickAction(Icons.local_shipping, 'Add Vehicle', () => _showAddVehicleDialog(context, bloc)),
        const Gap(12),
        _quickAction(Icons.inventory, 'Freight Loads', () => bloc.add(const NavigateTruckOwnerPage('freight'))),
      ]),
    ]);
  }

  Widget _topBar(TruckOwnerState state) {
    return Row(children: [
      CircleAvatar(
        radius: 22,
        backgroundColor: const Color(0xFFF59E0B),
        child: Text(state.ownerName.isNotEmpty ? state.ownerName[0].toUpperCase() : 'T',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      const Gap(12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(state.ownerName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        Text(state.isLinked ? 'Linked to Carrier' : 'Independent',
            style: TextStyle(color: state.isLinked ? AppColors.success : AppColors.gray400, fontSize: 12)),
      ]),
    ]);
  }

  Widget _quickAction(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1B3A4B),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(children: [
            Icon(icon, color: const Color(0xFFF59E0B), size: 28),
            const Gap(6),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ]),
        ),
      ),
    );
  }

  // ── Drivers Tab ──
  Widget _driversTab(TruckOwnerDashboardBloc bloc, TruckOwnerState state) {
    return StaffListSection(
      title: 'Truck Drivers',
      items: state.drivers,
      isLoading: state.driversLoading,
      role: 'driver',
      onAdd: () => _showAddDriverDialog(context, bloc),
      onDelete: (staffId) => bloc.add(RemoveTruckStaff(staffId: staffId, role: 'driver')),
    );
  }

  // ── Conductors Tab ──
  Widget _conductorsTab(TruckOwnerDashboardBloc bloc, TruckOwnerState state) {
    return StaffListSection(
      title: 'Truck Conductors',
      items: state.conductors,
      isLoading: state.conductorsLoading,
      role: 'conductor',
      onAdd: () => _showAddConductorDialog(context, bloc),
      onDelete: (staffId) => bloc.add(RemoveTruckStaff(staffId: staffId, role: 'conductor')),
    );
  }

  // ── Vehicles Tab ──
  Widget _vehiclesTab(TruckOwnerDashboardBloc bloc, TruckOwnerState state) {
    return ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Vehicles', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
      const Gap(12),
      if (state.vehiclesLoading)
        const Center(child: CircularProgressIndicator())
      else if (state.vehicles.isEmpty)
        const Center(child: Text('No vehicles registered', style: TextStyle(color: Colors.white54)))
      else
        ...state.vehicles.map((v) => Card(
          color: const Color(0xFF1B3A4B),
          child: ListTile(
            leading: const Icon(Icons.local_shipping, color: Color(0xFFF59E0B)),
            title: Text(v['plate_number']?.toString() ?? 'Unknown',
                style: const TextStyle(color: Colors.white)),
            subtitle: Text(v['model']?.toString() ?? '', style: const TextStyle(color: Colors.white54)),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => bloc.add(RemoveTruckVehicle(v['id']?.toString() ?? '')),
            ),
          ),
        )),
    ]);
  }

  // ── Freight Tab ──
  Widget _freightTab(TruckOwnerDashboardBloc bloc, TruckOwnerState state) {
    return ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Freight Loads', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
      const Gap(12),
      if (state.freightLoading)
        const Center(child: CircularProgressIndicator())
      else if (state.freightLoads.isEmpty)
        const Center(child: Text('No active freight loads', style: TextStyle(color: Colors.white54)))
      else
        ...state.freightLoads.map((f) => Card(
          color: const Color(0xFF1B3A4B),
          child: ListTile(
            leading: const Icon(Icons.inventory, color: Color(0xFFF59E0B)),
            title: Text(f['description']?.toString() ?? 'Load', style: const TextStyle(color: Colors.white)),
            subtitle: Text('Status: ${f['status'] ?? 'pending'}', style: const TextStyle(color: Colors.white54)),
          ),
        )),
    ]);
  }

  // ── Carrier Link Tab ──
  Widget _carrierLinkTab(TruckOwnerDashboardBloc bloc, TruckOwnerState state) {
    final searchCtrl = TextEditingController();
    return ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Carrier Link', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
      const Gap(12),
      if (state.isLinked)
        Card(
          color: const Color(0xFF1B3A4B),
          child: ListTile(
            leading: const Icon(Icons.link, color: AppColors.success),
            title: Text('Linked with ${state.linkStatus?['carrier_name'] ?? 'Carrier'}',
                style: const TextStyle(color: Colors.white)),
            subtitle: const Text('Status: ACTIVE', style: TextStyle(color: AppColors.success)),
            trailing: TextButton(
              onPressed: () => bloc.add(LeaveTruckCarrier(state.linkStatus?['assignment_id']?.toString() ?? '')),
              child: const Text('Leave', style: TextStyle(color: Colors.redAccent)),
            ),
          ),
        )
      else ...[
        TextField(
          controller: searchCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search companies...',
            hintStyle: const TextStyle(color: Colors.white38),
            prefixIcon: const Icon(Icons.search, color: Colors.white38),
            filled: true, fillColor: const Color(0xFF1B3A4B),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
          onSubmitted: (q) => bloc.add(SearchTruckCompanies(q)),
        ),
        const Gap(12),
        if (state.companiesLoading)
          const Center(child: CircularProgressIndicator())
        else
          ...state.availableCompanies.map((c) => Card(
            color: const Color(0xFF1B3A4B),
            child: ListTile(
              leading: const Icon(Icons.business, color: Color(0xFFF59E0B)),
              title: Text(c['name']?.toString() ?? '', style: const TextStyle(color: Colors.white)),
              trailing: ElevatedButton(
                onPressed: () => bloc.add(SendTruckLinkRequest(companyId: c['id']?.toString() ?? '')),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
                child: const Text('Link'),
              ),
            ),
          )),
        if (!state.companiesLoading && state.availableCompanies.isEmpty && searchCtrl.text.isNotEmpty)
          const Center(child: Text('No companies found', style: TextStyle(color: Colors.white54))),
      ],
    ]);
  }

  // ── Dialogs ──
  void _showAddDriverDialog(BuildContext context, TruckOwnerDashboardBloc bloc) {
    showDialog(
      context: context,
      builder: (ctx) => AddStaffDialog(
        role: 'driver',
        accentColor: const Color(0xFFF59E0B),
        onSubmit: (data) => bloc.add(RegisterTruckStaff(role: 'driver', data: data)),
      ),
    );
  }

  void _showAddConductorDialog(BuildContext context, TruckOwnerDashboardBloc bloc) {
    showDialog(
      context: context,
      builder: (ctx) => AddStaffDialog(
        role: 'conductor',
        accentColor: const Color(0xFFF59E0B),
        onSubmit: (data) => bloc.add(RegisterTruckStaff(role: 'conductor', data: data)),
      ),
    );
  }

  void _showAddVehicleDialog(BuildContext context, TruckOwnerDashboardBloc bloc) {
    final plateCtrl = TextEditingController();
    final modelCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Vehicle'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: plateCtrl, decoration: const InputDecoration(labelText: 'Plate Number')),
          const Gap(8),
          TextField(controller: modelCtrl, decoration: const InputDecoration(labelText: 'Model')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () {
            Navigator.pop(ctx);
            bloc.add(AddTruckVehicle({'plate_number': plateCtrl.text.trim(), 'model': modelCtrl.text.trim()}));
          }, child: const Text('Add')),
        ],
      ),
    );
  }
}

// ── Sidebar ──
class _Sidebar extends StatelessWidget {
  final TruckOwnerDashboardBloc bloc;
  final TruckOwnerState state;
  const _Sidebar({required this.bloc, required this.state});

  static const _tabs = [
    {'key': 'dashboard', 'label': 'Dashboard', 'icon': Icons.dashboard},
    {'key': 'drivers', 'label': 'Drivers', 'icon': Icons.person},
    {'key': 'conductors', 'label': 'Conductors', 'icon': Icons.group},
    {'key': 'vehicles', 'label': 'Vehicles', 'icon': Icons.local_shipping},
    {'key': 'freight', 'label': 'Freight Loads', 'icon': Icons.inventory},
    {'key': 'carrier', 'label': 'Carrier Link', 'icon': Icons.link},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: const BoxDecoration(
        color: Color(0xFF0A1628),
        border: Border(right: BorderSide(color: Color(0x20FFFFFF))),
      ),
      child: Column(children: [
        const Gap(20),
        Text(state.ownerName,
            style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 16, fontWeight: FontWeight.w700)),
        const Gap(24),
        ..._tabs.map((t) => ListTile(
          leading: Icon(t['icon'] as IconData,
              color: state.currentPage == t['key'] ? const Color(0xFFF59E0B) : Colors.white54, size: 20),
          title: Text(t['label'] as String,
              style: TextStyle(color: state.currentPage == t['key'] ? Colors.white : Colors.white54, fontSize: 13)),
          onTap: () => bloc.add(NavigateTruckOwnerPage(t['key'] as String)),
          dense: true,
        )),
        const Spacer(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
          title: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
          onTap: () async {
            bloc.add(const TruckOwnerLogout('truckFleet'));
            if (context.mounted) context.go('/truck-owner/login');
          },
          dense: true,
        ),
        const Gap(16),
      ]),
    );
  }
}

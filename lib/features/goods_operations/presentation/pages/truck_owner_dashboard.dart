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
        if (state.currentPage == 'carrier' && !state.linkLoading && state.linkStatus == null) {
          Future.microtask(() => bloc.add(const LoadTruckLinkStatus()));
        }
        return Scaffold(
          backgroundColor: const Color(0xFF0D1B2A),
          body: Row(children: [
            if (wide) _buildSidebar(ctx, bloc, state),
            Expanded(child: _content(ctx, bloc, state)),
          ]),
        );
      },
    );
  }

  // ── Sidebar ──
  static Widget _buildSidebar(BuildContext ctx, TruckOwnerDashboardBloc bloc, TruckOwnerState state) {
    const tabs = [
      ('dashboard', 'Dashboard', Icons.dashboard),
      ('drivers', 'Drivers', Icons.person),
      ('conductors', 'Conductors', Icons.group),
      ('vehicles', 'Vehicles', Icons.local_shipping),
      ('freight', 'Freight Loads', Icons.inventory),
      ('carrier', 'Carrier Link', Icons.link),
    ];
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
        for (final t in tabs)
          ListTile(
            leading: Icon(t.$3,
                color: state.currentPage == t.$1 ? const Color(0xFFF59E0B) : Colors.white54, size: 20),
            title: Text(t.$2,
                style: TextStyle(color: state.currentPage == t.$1 ? Colors.white : Colors.white54, fontSize: 13)),
            onTap: () => bloc.add(NavigateTruckOwnerPage(t.$1)),
            dense: true,
          ),
        const Spacer(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
          title: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
          onTap: () async {
            bloc.add(const TruckOwnerLogout('truckFleet'));
            if (ctx.mounted) ctx.go('/truck-owner/login');
          },
          dense: true,
        ),
        const Gap(16),
      ]),
    );
  }

  // ── Content Router ──
  static Widget _content(BuildContext ctx, TruckOwnerDashboardBloc bloc, TruckOwnerState state) {
    switch (state.currentPage) {
      case 'drivers': return _driversTab(ctx, bloc, state);
      case 'conductors': return _conductorsTab(ctx, bloc, state);
      case 'vehicles': return _vehiclesTab(bloc, state);
      case 'carrier': return _carrierLinkTab(ctx, bloc, state);
      case 'freight': return _freightTab(bloc, state);
      default: return _dashboardTab(ctx, bloc, state);
    }
  }

  // ── Dashboard Home ──
  static Widget _dashboardTab(BuildContext ctx, TruckOwnerDashboardBloc bloc, TruckOwnerState state) {
    return ListView(padding: const EdgeInsets.all(20), children: [
      _topBar(state),
      const Gap(16),
      DashboardKpiSection(
        driverCount: state.driverCount,
        conductorCount: state.conductorCount,
        layoutCount: state.vehicleCount,
        onDriversTap: () => bloc.add(const NavigateTruckOwnerPage('drivers')),
        onConductorsTap: () => bloc.add(const NavigateTruckOwnerPage('conductors')),
        onLayoutsTap: () => bloc.add(const NavigateTruckOwnerPage('vehicles')),
      ),
      const Gap(20),
      Row(children: [
        _quickAction(Icons.person_add, 'Add Driver', () => _showAddStaff(ctx, bloc, 'driver')),
        const Gap(12),
        _quickAction(Icons.group_add, 'Add Conductor', () => _showAddStaff(ctx, bloc, 'conductor')),
        const Gap(12),
        _quickAction(Icons.local_shipping, 'Add Vehicle', () => _showAddVehicle(ctx, bloc)),
        const Gap(12),
        _quickAction(Icons.inventory, 'Freight', () => bloc.add(const NavigateTruckOwnerPage('freight'))),
      ]),
    ]);
  }

  static Widget _topBar(TruckOwnerState state) {
    return Row(children: [
      CircleAvatar(
        radius: 22, backgroundColor: const Color(0xFFF59E0B),
        child: Text(state.ownerName.isNotEmpty ? state.ownerName[0].toUpperCase() : 'T',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      const Gap(12),
      Text(state.ownerName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
    ]);
  }

  static Widget _quickAction(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap, borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(color: const Color(0xFF1B3A4B), borderRadius: BorderRadius.circular(10)),
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
  static Widget _driversTab(BuildContext ctx, TruckOwnerDashboardBloc bloc, TruckOwnerState state) {
    return StaffListSection(
      title: 'Truck Drivers',
      accentColor: const Color(0xFFF59E0B),
      icon: Icons.person,
      items: state.drivers,
      isLoading: state.driversLoading,
      onAdd: () => _showAddStaff(ctx, bloc, 'driver'),
      onRemove: (id, name) => bloc.add(RemoveTruckStaff(staffId: id, role: 'driver')),
    );
  }

  // ── Conductors Tab ──
  static Widget _conductorsTab(BuildContext ctx, TruckOwnerDashboardBloc bloc, TruckOwnerState state) {
    return StaffListSection(
      title: 'Truck Conductors',
      accentColor: const Color(0xFFF59E0B),
      icon: Icons.group,
      items: state.conductors,
      isLoading: state.conductorsLoading,
      onAdd: () => _showAddStaff(ctx, bloc, 'conductor'),
      onRemove: (id, name) => bloc.add(RemoveTruckStaff(staffId: id, role: 'conductor')),
    );
  }

  // ── Vehicles Tab ──
  static Widget _vehiclesTab(TruckOwnerDashboardBloc bloc, TruckOwnerState state) {
    return ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Vehicles', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
      const Gap(12),
      if (state.vehiclesLoading)
        const Center(child: CircularProgressIndicator())
      else if (state.vehicles.isEmpty)
        const Center(child: Text('No vehicles', style: TextStyle(color: Colors.white54)))
      else
        ...state.vehicles.map((v) => Card(
          color: const Color(0xFF1B3A4B),
          child: ListTile(
            leading: const Icon(Icons.local_shipping, color: Color(0xFFF59E0B)),
            title: Text(v['plate_number']?.toString() ?? 'Unknown', style: const TextStyle(color: Colors.white)),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => bloc.add(RemoveTruckVehicle(v['id']?.toString() ?? '')),
            ),
          ),
        )),
    ]);
  }

  // ── Freight Tab ──
  static Widget _freightTab(TruckOwnerDashboardBloc bloc, TruckOwnerState state) {
    return ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Freight Loads', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
      const Gap(12),
      if (state.freightLoading)
        const Center(child: CircularProgressIndicator())
      else if (state.freightLoads.isEmpty)
        const Center(child: Text('No active loads', style: TextStyle(color: Colors.white54)))
      else
        ...state.freightLoads.map((f) => Card(
          color: const Color(0xFF1B3A4B),
          child: ListTile(
            leading: const Icon(Icons.inventory, color: Color(0xFFF59E0B)),
            title: Text(f['description']?.toString() ?? 'Load', style: const TextStyle(color: Colors.white)),
          ),
        )),
    ]);
  }

  // ── Carrier Link Tab ──
  static Widget _carrierLinkTab(BuildContext ctx, TruckOwnerDashboardBloc bloc, TruckOwnerState state) {
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
            hintText: 'Search companies...', hintStyle: const TextStyle(color: Colors.white38),
            prefixIcon: const Icon(Icons.search, color: Colors.white38),
            filled: true, fillColor: const Color(0xFF1B3A4B),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
          onSubmitted: (q) => bloc.add(SearchTruckCompanies(q)),
        ),
        const Gap(12),
        if (state.companiesLoading) const Center(child: CircularProgressIndicator()),
        for (final c in state.availableCompanies)
          Card(
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
          ),
      ],
    ]);
  }

  // ── Dialogs ──
  static Future<void> _showAddStaff(BuildContext ctx, TruckOwnerDashboardBloc bloc, String role) async {
    final data = await AddStaffDialog.show(ctx, title: role == 'driver' ? 'Add Truck Driver' : 'Add Truck Conductor');
    if (data != null) {
      bloc.add(RegisterTruckStaff(role: role, data: data));
    }
  }

  static void _showAddVehicle(BuildContext ctx, TruckOwnerDashboardBloc bloc) {
    final plateCtrl = TextEditingController();
    final modelCtrl = TextEditingController();
    showDialog(
      context: ctx,
      builder: (dctx) => AlertDialog(
        title: const Text('Add Vehicle'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: plateCtrl, decoration: const InputDecoration(labelText: 'Plate Number')),
          const Gap(8),
          TextField(controller: modelCtrl, decoration: const InputDecoration(labelText: 'Model')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () {
            Navigator.pop(dctx);
            bloc.add(AddTruckVehicle({'plate_number': plateCtrl.text.trim(), 'model': modelCtrl.text.trim()}));
          }, child: const Text('Add')),
        ],
      ),
    );
  }
}

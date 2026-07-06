// Fleet Dashboard Page — thin BLoC-driven root for bus-fleet panel
// ===================================================================
// Replaces the 2500-line OwnerDashboardScreen for /bus-fleet/.
// Delegates all state to FleetDashboardBloc; UI is assembled from
// shared widgets in presentation/widgets/.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/fleet_dashboard/fleet_dashboard_bloc.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/fleet_dashboard/fleet_dashboard_event.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/fleet_dashboard/fleet_dashboard_state.dart';
import 'package:trace_odd/features/bus_operations/presentation/pages/absolute_layout_designer_screen.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/dashboard_kpi_section.dart';

/// Botón 3D estilo "misil" (mismo que existía en el dashboard legacy).
class _MissileButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final double height;
  final VoidCallback onTap;
  const _MissileButton({
    required this.label,
    required this.icon,
    required this.color,
    this.height = 56,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
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
    return BlocListener<FleetDashboardBloc, FleetDashboardState>(
      listener: (ctx, state) {
        if (state.status == FleetDashboardStatus.initial &&
            state.errorMessage == 'Not authenticated') {
          // Navigate handled by GoRouter via the page's loginRoute.
        }
      },
      child: BlocBuilder<FleetDashboardBloc, FleetDashboardState>(
        builder: (ctx, state) {
          if (state.status == FleetDashboardStatus.loading) {
            return const Scaffold(
              backgroundColor: Color(0xFF0D1B2A),
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            backgroundColor: const Color(0xFF0D1B2A),
            appBar: _appBar(ctx, state),
            body: _body(ctx, state),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext ctx, FleetDashboardState state) {
    return AppBar(
      backgroundColor: const Color(0xFF1B2838),
      title: Text(
        state.ownerName,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white60),
          onPressed: () => ctx.read<FleetDashboardBloc>().add(
            FetchDashboardMetrics(panelPrefix: ''),
          ),
        ),
      ],
    );
  }

  Widget _body(BuildContext ctx, FleetDashboardState state) {
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
          onDriversTap: () => ctx.read<FleetDashboardBloc>().add(
            const NavigateToPage('drivers'),
          ),
          onConductorsTap: () => ctx.read<FleetDashboardBloc>().add(
            const NavigateToPage('conductors'),
          ),
          onLayoutsTap: () => ctx.read<FleetDashboardBloc>().add(
            const NavigateToPage('layouts'),
          ),
        ),
        Gap(24),
        _MissileButton(
          label: '+ Add New Vehicle',
          icon: Icons.add,
          color: const Color(0xFF0891B2),
          height: 56,
          onTap: () => Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => AbsoluteLayoutDesignerScreen(
                companyId: state.companyId,
                companyName: state.ownerName,
                apiPrefix: '/bus-fleet',
              ),
            ),
          ),
        ),
        Gap(12),
        _MissileButton(
          label: 'View All Vehicles (${state.layoutCount})',
          icon: Icons.directions_bus,
          color: const Color(0xFF2563EB),
          height: 56,
          onTap: () => ctx.read<FleetDashboardBloc>().add(
            const NavigateToPage('layouts'),
          ),
        ),
      ],
    );
  }
}

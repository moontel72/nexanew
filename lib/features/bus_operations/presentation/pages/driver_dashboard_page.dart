// Driver Dashboard Page — thin BLoC-driven root
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/widgets/fleet/fleet_shared_widgets.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/driver_dashboard/driver_dashboard_bloc.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/driver_dashboard/driver_dashboard_event.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/driver_dashboard/driver_dashboard_state.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/driver_dashboard/driver_profile.dart';

class DriverDashboardPage extends StatelessWidget {
  final String storagePrefix;
  const DriverDashboardPage({super.key, this.storagePrefix = 'busFleet'});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        DriverDashboardBloc()
          ..add(LoadDriverProfile(storagePrefix: storagePrefix)),
    child: const _DriverView(),
  );
}

class _DriverView extends StatelessWidget {
  const _DriverView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverDashboardBloc, DriverDashboardState>(
      builder: (ctx, state) {
        final bloc = ctx.read<DriverDashboardBloc>();
        final profile = state.profile;

        if (state.status == DriverDashboardStatus.initial ||
            (state.status == DriverDashboardStatus.loading &&
                profile == null)) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text(
              'Driver Terminal',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
            ),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => bloc.add(const RefreshDriverProfile()),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  bloc.add(DriverLogout(storagePrefix: 'busFleet'));
                  if (ctx.mounted) ctx.go('/bus-driver/login');
                },
              ),
            ],
          ),
          body: state.status == DriverDashboardStatus.error
              ? FleetErrorView(
                  error: state.error ?? 'Error',
                  onRetry: () => bloc.add(const RefreshDriverProfile()),
                )
              : profile == null
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () async => bloc.add(const RefreshDriverProfile()),
                  child: _DashboardBody(
                    profile: profile,
                    isRefreshing: state.isRefreshing,
                  ),
                ),
        );
      },
    );
  }
}

class _DashboardBody extends StatelessWidget {
  final DriverProfile profile;
  final bool isRefreshing;
  const _DashboardBody({required this.profile, this.isRefreshing = false});

  Color get _statusColor {
    switch (profile.scheduleStatus.toLowerCase()) {
      case 'active':
      case 'on route':
      case 'driving':
        return AppColors.success;
      case 'delayed':
      case 'stopped':
        return AppColors.warning;
      default:
        return AppColors.gray400;
    }
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isRefreshing) const LinearProgressIndicator(),
        Text(
          'Welcome, ${profile.name}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        Gap(4),
        Text(
          'Plate: ${profile.vehiclePlate}',
          style: const TextStyle(fontSize: 14, color: AppColors.gray500),
        ),
        Gap(24),
        FleetSectionCard(
          title: 'Active Route',
          icon: Icons.alt_route_rounded,
          color: AppColors.primary,
          children: [
            FleetDetailRow('Route', profile.activeRoute),
            FleetDetailRow(
              'Status',
              profile.scheduleStatus.toUpperCase(),
              _statusColor,
            ),
            FleetDetailRow('Next Stop', profile.nextStop),
          ],
        ),
        Gap(16),
        FleetSectionCard(
          title: 'Seat Manifest',
          icon: Icons.event_seat_rounded,
          color: const Color(0xFF2563EB),
          children: [
            FleetDetailRow('Total Seats', '${profile.totalSeats}'),
            FleetDetailRow(
              'Booked',
              '${profile.bookedSeats}',
              const Color(0xFF2563EB),
            ),
            FleetDetailRow(
              'Vacant',
              '${profile.vacantSeats}',
              AppColors.gray400,
            ),
            Gap(8),
            FleetOccupancyBar(
              total: profile.totalSeats,
              booked: profile.bookedSeats,
            ),
          ],
        ),
        Gap(16),
        FleetSectionCard(
          title: 'GPS Tracking',
          icon: Icons.gps_fixed_rounded,
          color: AppColors.secondary,
          children: [
            FleetDetailRow('Live Beacon', 'Active', AppColors.success),
            FleetDetailRow('Last Sync', 'Just now'),
            FleetDetailRow('Accuracy', '3.2 meters'),
          ],
        ),
        Gap(16),
        FleetSectionCard(
          title: 'Dispatch Alerts',
          icon: Icons.campaign_rounded,
          color: AppColors.warning,
          children: [
            FleetDetailRow('Traffic', 'Clear ahead'),
            FleetDetailRow('ETA', 'On schedule'),
          ],
        ),
      ],
    ),
  );
}

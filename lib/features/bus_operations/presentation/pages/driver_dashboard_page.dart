// Driver Dashboard Page — thin BLoC-driven root
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/driver_dashboard/driver_dashboard_bloc.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/driver_dashboard/driver_dashboard_event.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/driver_dashboard/driver_dashboard_state.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/driver_dashboard/driver_profile.dart';

class DriverDashboardPage extends StatelessWidget {
  final String storagePrefix;
  const DriverDashboardPage({super.key, this.storagePrefix = 'busFleet'});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          DriverDashboardBloc()
            ..add(LoadDriverProfile(storagePrefix: storagePrefix)),
      child: const _DriverView(),
    );
  }
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
              ? _ErrorView(
                  error: state.error ?? 'Unknown error',
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
          _SectionCard(
            title: 'Active Route',
            icon: Icons.alt_route_rounded,
            color: AppColors.primary,
            children: [
              _Row('Route', profile.activeRoute),
              _Row(
                'Status',
                profile.scheduleStatus.toUpperCase(),
                _statusColor,
              ),
              _Row('Next Stop', profile.nextStop),
            ],
          ),
          Gap(16),
          _SectionCard(
            title: 'Seat Manifest',
            icon: Icons.event_seat_rounded,
            color: const Color(0xFF2563EB),
            children: [
              _Row('Total Seats', '${profile.totalSeats}'),
              _Row('Booked', '${profile.bookedSeats}', const Color(0xFF2563EB)),
              _Row('Vacant', '${profile.vacantSeats}', AppColors.gray400),
              Gap(8),
              _OccupancyBar(
                total: profile.totalSeats,
                booked: profile.bookedSeats,
              ),
            ],
          ),
          Gap(16),
          _SectionCard(
            title: 'GPS Tracking',
            icon: Icons.gps_fixed_rounded,
            color: AppColors.secondary,
            children: [
              _Row('Live Beacon', 'Active', AppColors.success),
              _Row('Last Sync', 'Just now'),
              _Row('Accuracy', '3.2 meters'),
            ],
          ),
          Gap(16),
          _SectionCard(
            title: 'Dispatch Alerts',
            icon: Icons.campaign_rounded,
            color: AppColors.warning,
            children: [
              _Row('Traffic', 'Clear ahead'),
              _Row('ETA', 'On schedule'),
            ],
          ),
        ],
      ),
    );
  }

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
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> children;
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.children,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 8),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            Gap(12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        Gap(16),
        ...children,
      ],
    ),
  );
}

class _Row extends StatelessWidget {
  final String label, value;
  final Color? color;
  const _Row(this.label, this.value, [this.color]);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.gray500),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    ),
  );
}

class _OccupancyBar extends StatelessWidget {
  final int total, booked;
  const _OccupancyBar({required this.total, required this.booked});
  @override
  Widget build(BuildContext context) {
    final safe = total > 0 ? total : 1;
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: SizedBox(
        height: 12,
        child: Row(
          children: [
            Flexible(
              flex: booked.clamp(0, safe),
              child: Container(color: const Color(0xFF2563EB)),
            ),
            Flexible(
              flex: (total - booked).clamp(0, safe),
              child: Container(color: Colors.grey.shade200),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          Gap(16),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.gray600),
          ),
          Gap(20),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    ),
  );
}

// Conductor Dashboard Page — thin BLoC-driven root
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/conductor_dashboard/conductor_dashboard_bloc.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/conductor_dashboard/conductor_dashboard_event.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/conductor_dashboard/conductor_dashboard_state.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/conductor_dashboard/conductor_models.dart';

class ConductorDashboardPage extends StatelessWidget {
  final String storagePrefix;
  const ConductorDashboardPage({super.key, this.storagePrefix = 'busFleet'});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ConductorDashboardBloc()
            ..add(LoadConductorProfile(storagePrefix: storagePrefix)),
      child: const _ConductorView(),
    );
  }
}

class _ConductorView extends StatelessWidget {
  const _ConductorView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConductorDashboardBloc, ConductorDashboardState>(
      builder: (ctx, state) {
        final bloc = ctx.read<ConductorDashboardBloc>();
        final profile = state.profile;
        final manifest = state.manifest;

        if (state.status == ConductorDashboardStatus.initial ||
            (state.status == ConductorDashboardStatus.loading &&
                profile == null)) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text(
              'Conductor / Cabin Crew Terminal',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
            ),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => bloc.add(const RefreshConductorData()),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  bloc.add(ConductorLogout(storagePrefix: 'busFleet'));
                  if (ctx.mounted) ctx.go('/bus-conductor/login');
                },
              ),
            ],
          ),
          body:
              state.status == ConductorDashboardStatus.error && profile == null
              ? _ErrorView(
                  error: state.error ?? 'Error',
                  onRetry: () => bloc.add(const RefreshConductorData()),
                )
              : profile == null
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () async => bloc.add(const RefreshConductorData()),
                  child: _DashboardBody(
                    profile: profile,
                    manifest: manifest,
                    isRefreshing: state.isRefreshing,
                  ),
                ),
        );
      },
    );
  }
}

class _DashboardBody extends StatelessWidget {
  final ConductorProfile profile;
  final TicketManifest? manifest;
  final bool isRefreshing;
  const _DashboardBody({
    required this.profile,
    this.manifest,
    this.isRefreshing = false,
  });

  @override
  Widget build(BuildContext context) {
    final booked = manifest?.bookedSeats ?? 0;
    final total = manifest?.totalSeats ?? profile.totalSeats;
    final vacant = total - booked;

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
            'Route: ${profile.routeName}',
            style: const TextStyle(fontSize: 14, color: AppColors.gray500),
          ),
          if (profile.linkedCarrierName != null) ...[
            Gap(2),
            Text(
              'Carrier: ${profile.linkedCarrierName}',
              style: const TextStyle(fontSize: 12, color: AppColors.gray500),
            ),
          ],
          if (profile.starRating != null) ...[
            Gap(2),
            Row(
              children: [
                const Icon(Icons.star, size: 14, color: Color(0xFFF59E0B)),
                Gap(4),
                Text(
                  '${profile.starRating!.toStringAsFixed(1)} · ${profile.completedTrips ?? 0} trips',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
          ],
          Gap(24),
          // Stats row
          Row(
            children: [
              Expanded(
                child: _StatCard('Booked', '$booked', const Color(0xFF2563EB)),
              ),
              Gap(12),
              Expanded(
                child: _StatCard('Vacant', '$vacant', AppColors.gray400),
              ),
              Gap(12),
              Expanded(child: _StatCard('Total', '$total', AppColors.primary)),
            ],
          ),
          if ((manifest?.totalRevenue ?? 0) > 0) ...[
            Gap(12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A).withValues(alpha: .1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.attach_money, color: Color(0xFF16A34A)),
                  Gap(8),
                  Text(
                    'Revenue: Rs. ${manifest!.totalRevenue.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Color(0xFF16A34A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Synced: ${_fmt(manifest!.lastSync)}',
                    style: const TextStyle(
                      color: Color(0xFF667788),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
          Gap(24),
          // Legend
          Row(
            children: [
              _Dot(const Color(0xFF2563EB), 'Booked'),
              Gap(16),
              _Dot(Colors.grey.shade300, 'Vacant'),
            ],
          ),
          Gap(16),
          if (manifest != null && manifest!.seats.isNotEmpty)
            _SeatGrid(seats: manifest!.seats)
          else
            _SeatGrid(
              seats: List.generate(
                total,
                (i) => {
                  'number': '${i + 1}',
                  'status': i < booked ? 'booked' : 'vacant',
                },
              ),
            ),
          Gap(12),
          Text(
            'Last sync: ${manifest != null ? _fmt(manifest!.lastSync) : 'Never'}',
            style: const TextStyle(color: Color(0xFF556677), fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatCard(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 6),
      ],
    ),
    child: Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Gap(2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.gray500),
        ),
      ],
    ),
  );
}

class _Dot extends StatelessWidget {
  final Color color;
  final String label;
  const _Dot(this.color, this.label);
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      Gap(6),
      Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppColors.gray600),
      ),
    ],
  );
}

class _SeatGrid extends StatelessWidget {
  final List<Map<String, dynamic>> seats;
  const _SeatGrid({required this.seats});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 6),
      ],
    ),
    child: Column(
      children: [
        Container(
          width: double.infinity,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Center(
            child: Text(
              '🚌 DRIVER',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        Gap(12),
        ...List.generate((seats.length / 4).ceil(), (row) {
          final start = row * 4;
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                ...List.generate(
                  2,
                  (i) => start + i < seats.length
                      ? _Seat(seats[start + i])
                      : const SizedBox(width: 55),
                ),
                const SizedBox(width: 20),
                ...List.generate(
                  2,
                  (i) => start + 2 + i < seats.length
                      ? _Seat(seats[start + 2 + i])
                      : const SizedBox(width: 55),
                ),
              ],
            ),
          );
        }),
        Gap(12),
        Container(
          width: double.infinity,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Center(
            child: Text(
              'REAR',
              style: TextStyle(fontSize: 9, color: AppColors.gray500),
            ),
          ),
        ),
      ],
    ),
  );
}

class _Seat extends StatelessWidget {
  final Map<String, dynamic> seat;
  const _Seat(this.seat);
  @override
  Widget build(BuildContext context) {
    final isBooked =
        seat['status']?.toString() == 'booked' || seat['booked'] == true;
    final num =
        seat['number']?.toString() ?? seat['seat_no']?.toString() ?? '?';
    final color = isBooked ? const Color(0xFF2563EB) : Colors.grey.shade300;
    return Expanded(
      child: Container(
        height: 44,
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: isBooked ? color.withValues(alpha: .12) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Center(
          child: Text(
            num,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
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

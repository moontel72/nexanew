// Driver Trip Screen — BLoC-driven (Wave 6)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/widgets/loading/loading_state_widget.dart';
import 'package:trace_odd/shared/widgets/error_state/error_state_widget.dart';
import 'package:trace_odd/shared/widgets/fleet/fleet_shared_widgets.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/trip/trip_vault_bloc.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/trip/trip_vault_event.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/trip/trip_vault_state.dart';

class DriverTripScreen extends StatelessWidget {
  const DriverTripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TripVaultBloc()..add(const LoadTrip()),
      child: BlocBuilder<TripVaultBloc, TripState>(
        builder: (ctx, state) {
          final t = state.trip;
          return Scaffold(
            backgroundColor: AppColors.fleetBackground,
            appBar: AppBar(
              backgroundColor: AppColors.fleetCard,
              title: const Text(
                'Active Trip',
                style: TextStyle(color: AppColors.textInverse),
              ),
            ),
            body: state.loading
                ? const LoadingState()
                : t == null
                ? ErrorState.empty(
                    customTitle: 'No Active Trip',
                    customMessage: 'No active trip found.',
                  )
                : Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FleetSectionCard(
                          title: t['route_name']?.toString() ?? 'Route',
                          icon: Icons.route,
                          color: AppColors.fleetInfo,
                          children: [
                            FleetDetailRow(
                              'Route',
                              '${t['origin'] ?? ''} → ${t['destination'] ?? ''}',
                            ),
                            FleetDetailRow(
                              'Vehicle',
                              t['vehicle_plate'] ?? t['bus_reg_number'] ?? '—',
                            ),
                            FleetDetailRow(
                              'Status',
                              state.tripActive ? 'EN ROUTE' : 'PENDING',
                              state.tripActive
                                  ? AppColors.fleetSuccess
                                  : AppColors.fleetWarning,
                            ),
                          ],
                        ),
                        const Gap(20),
                        if (!state.tripActive)
                          ElevatedButton.icon(
                            onPressed: () => ctx.read<TripVaultBloc>().add(
                              const StartTrip(),
                            ),
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Start Trip'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.fleetSuccess,
                              padding: const EdgeInsets.all(16),
                            ),
                          )
                        else
                          ElevatedButton.icon(
                            onPressed: () => ctx.read<TripVaultBloc>().add(
                              const CompleteTrip(),
                            ),
                            icon: const Icon(Icons.stop),
                            label: const Text('Complete Trip'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.fleetInfo,
                              padding: const EdgeInsets.all(16),
                            ),
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

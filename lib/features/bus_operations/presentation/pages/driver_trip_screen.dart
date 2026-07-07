// Driver Trip Screen — BLoC-driven (Wave 6)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/trip/trip_vault_bloc.dart';

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
            backgroundColor: const Color(0xFF0D1B2A),
            appBar: AppBar(
              backgroundColor: const Color(0xFF1B2838),
              title: const Text(
                'Active Trip',
                style: TextStyle(color: Colors.white),
              ),
            ),
            body: state.loading
                ? const Center(child: CircularProgressIndicator())
                : t == null
                ? const Center(
                    child: Text(
                      'No active trip',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B2838),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                t['route_name']?.toString() ?? 'Route',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Gap(8),
                              Text(
                                '${t['origin'] ?? ''} → ${t['destination'] ?? ''}',
                                style: const TextStyle(color: Colors.white54),
                              ),
                              const Gap(12),
                              Text(
                                'Vehicle: ${t['vehicle_plate'] ?? t['bus_reg_number'] ?? '—'}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              Text(
                                'Status: ${state.tripActive ? 'EN ROUTE' : 'PENDING'}',
                                style: TextStyle(
                                  color: state.tripActive
                                      ? const Color(0xFF059669)
                                      : Colors.orange,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
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
                              backgroundColor: const Color(0xFF059669),
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
                              backgroundColor: const Color(0xFF2563EB),
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

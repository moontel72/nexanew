// Ticket Vault Screen — BLoC-driven (Wave 6)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/widgets/loading/loading_state_widget.dart';
import 'package:trace_odd/shared/widgets/error_state/error_state_widget.dart';
import 'package:trace_odd/shared/widgets/fleet/fleet_shared_widgets.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/trip/trip_vault_bloc.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/trip/trip_vault_event.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/trip/trip_vault_state.dart';

class TicketVaultScreen extends StatelessWidget {
  const TicketVaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TripVaultBloc()..add(const LoadVault()),
      child: BlocBuilder<TripVaultBloc, TripState>(
        builder: (ctx, state) => Scaffold(
          backgroundColor: AppColors.fleetBackground,
          appBar: AppBar(
            backgroundColor: AppColors.fleetCard,
            title: const Text(
              'Ticket Vault (Offline)',
              style: TextStyle(color: AppColors.textInverse),
            ),
          ),
          body: state.vaultLoading
              ? const LoadingState()
              : state.tickets.isEmpty
              ? ErrorState.empty(
                  customTitle: 'No Tickets',
                  customMessage: 'No offline tickets found.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.tickets.length,
                  itemBuilder: (_, i) {
                    final t = state.tickets[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: FleetSectionCard(
                        title: t.busDisplayName,
                        icon: Icons.confirmation_number,
                        color: AppColors.fleetWarning,
                        children: [
                          FleetDetailRow('Bus Name', t.busDisplayName),
                          FleetDetailRow('Seat', t.seatLabel),
                          FleetDetailRow('Status', t.status),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

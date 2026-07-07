// Ticket Vault Screen — BLoC-driven (Wave 6)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/trip/trip_vault_bloc.dart';

class TicketVaultScreen extends StatelessWidget {
  const TicketVaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TripVaultBloc()..add(const LoadVault()),
      child: BlocBuilder<TripVaultBloc, TripState>(
        builder: (ctx, state) => Scaffold(
          backgroundColor: const Color(0xFF0D1B2A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1B2838),
            title: const Text(
              'Ticket Vault (Offline)',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: state.vaultLoading
              ? const Center(child: CircularProgressIndicator())
              : state.tickets.isEmpty
              ? const Center(
                  child: Text(
                    'No offline tickets',
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.tickets.length,
                  itemBuilder: (_, i) {
                    final t = state.tickets[i];
                    return Card(
                      color: const Color(0xFF1B2838),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(
                          Icons.confirmation_number,
                          color: Color(0xFFF59E0B),
                        ),
                        title: Text(
                          t.busDisplayName,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          'Seat: ${t.seatLabel} · ${t.status}',
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

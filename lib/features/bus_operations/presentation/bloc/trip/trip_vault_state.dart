// Trip & Vault State — immutable state for driver trip + ticket vault
import 'package:equatable/equatable.dart';
import 'package:trace_odd/features/bus_operations/data/services/ticket_vault_service.dart';

class TripState extends Equatable {
  final Map<String, dynamic>? trip;
  final bool tripActive, loading, vaultLoading;
  final List<CachedBusTicket> tickets;
  final String? error;

  const TripState({
    this.trip,
    this.tripActive = false,
    this.loading = true,
    this.vaultLoading = true,
    this.tickets = const [],
    this.error,
  });

  TripState copyWith({
    Map<String, dynamic>? trip,
    bool? tripActive,
    bool? loading,
    bool? vaultLoading,
    List<CachedBusTicket>? tickets,
    String? error,
  }) => TripState(
    trip: trip ?? this.trip,
    tripActive: tripActive ?? this.tripActive,
    loading: loading ?? this.loading,
    vaultLoading: vaultLoading ?? this.vaultLoading,
    tickets: tickets ?? this.tickets,
    error: error,
  );

  @override
  List<Object?> get props => [
    trip,
    tripActive,
    loading,
    vaultLoading,
    tickets,
    error,
  ];
}

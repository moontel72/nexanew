// Trip & Vault Bloc — driver trip lifecycle + ticket vault
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/features/bus_operations/data/services/ticket_vault_service.dart';

// ── Events ──
abstract class TripEvent extends Equatable {
  const TripEvent();
  @override List<Object?> get props => [];
}
class LoadTrip extends TripEvent { const LoadTrip(); }
class StartTrip extends TripEvent { const StartTrip(); }
class CompleteTrip extends TripEvent { const CompleteTrip(); }
class LoadVault extends TripEvent { const LoadVault(); }

// ── State ──
class TripState extends Equatable {
  final Map<String, dynamic>? trip;
  final bool tripActive, loading, vaultLoading;
  final List<Map<String, dynamic>> tickets;
  final String? error;
  const TripState({this.trip, this.tripActive = false, this.loading = true, this.vaultLoading = true, this.tickets = const [], this.error});
  TripState copyWith({Map<String, dynamic>? trip, bool? tripActive, bool? loading, bool? vaultLoading, List<Map<String, dynamic>>? tickets, String? error}) =>
      TripState(trip: trip ?? this.trip, tripActive: tripActive ?? this.tripActive, loading: loading ?? this.loading, vaultLoading: vaultLoading ?? this.vaultLoading, tickets: tickets ?? this.tickets, error: error);
  @override List<Object?> get props => [trip, tripActive, loading, vaultLoading, tickets, error];
}

// ── Bloc ──
class TripVaultBloc extends Bloc<TripEvent, TripState> {
  final _api = ApiService();
  final _vault = TicketVaultService();
  TripVaultBloc() : super(const TripState()) {
    on<LoadTrip>(_onLoadTrip);
    on<StartTrip>(_onStart);
    on<CompleteTrip>(_onComplete);
    on<LoadVault>(_onVault);
  }
  Future<void> _onLoadTrip(LoadTrip e, Emitter<TripState> emit) async {
    emit(state.copyWith(loading: true));
    try {
      final r = await _api.get('/bus-fleet/driver/trips/active');
      final d = r?['data'];
      final trip = d is Map ? Map<String, dynamic>.from(d) : (d is List && d.isNotEmpty ? Map<String, dynamic>.from(d.first) : null);
      emit(state.copyWith(trip: trip, loading: false));
    } catch (_) { emit(state.copyWith(loading: false)); }
  }
  Future<void> _onStart(StartTrip e, Emitter<TripState> emit) async {
    if (state.trip == null) return;
    await _api.post('/bus-fleet/driver/start-trip/${state.trip!['id']}');
    emit(state.copyWith(tripActive: true));
  }
  Future<void> _onComplete(CompleteTrip e, Emitter<TripState> emit) async {
    if (state.trip == null) return;
    await _api.post('/bus-fleet/driver/complete-trip/${state.trip!['id']}');
    emit(state.copyWith(tripActive: false));
  }
  Future<void> _onVault(LoadVault e, Emitter<TripState> emit) async {
    emit(state.copyWith(vaultLoading: true));
    await _vault.init();
    emit(state.copyWith(tickets: _vault.getAllTickets(), vaultLoading: false));
  }
}

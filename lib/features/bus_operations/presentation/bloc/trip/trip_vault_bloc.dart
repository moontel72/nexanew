// Trip & Vault Bloc — driver trip lifecycle + ticket vault
import 'package:bloc/bloc.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/features/bus_operations/data/services/ticket_vault_service.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/trip/trip_vault_event.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/trip/trip_vault_state.dart';

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
      final trip = d is Map
          ? Map<String, dynamic>.from(d)
          : (d is List && d.isNotEmpty
                ? Map<String, dynamic>.from(d.first)
                : null);
      emit(state.copyWith(trip: trip, loading: false));
    } catch (_) {
      emit(state.copyWith(loading: false));
    }
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

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:trace_odd/features/nexa_admin/data/repositories/transport_admin_repository.dart';
import 'package:trace_odd/shared/models/transport/admin_transport_stats.dart';

part 'transport_admin_event.dart';
part 'transport_admin_state.dart';

class TransportAdminBloc extends Bloc<TransportAdminEvent, TransportAdminState> {
  final TransportAdminRepository repository;

  TransportAdminBloc({required this.repository})
      : super(const TransportAdminState()) {
    on<LoadWalletAdminStats>(_onLoadWallet);
    on<LoadMarketplaceAdminStats>(_onLoadMarketplace);
    on<LoadDriversAdminStats>(_onLoadDrivers);
    on<LoadFraudAdminStats>(_onLoadFraud);
  }

  Future<void> _onLoadWallet(
    LoadWalletAdminStats event,
    Emitter<TransportAdminState> emit,
  ) async {
    emit(state.copyWith(walletStatus: TransportAdminStatus.loading));
    try {
      final stats = await repository.getWalletStats();
      emit(state.copyWith(
        walletStatus: TransportAdminStatus.loaded,
        walletStats: stats,
        walletError: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        walletStatus: TransportAdminStatus.error,
        walletError: e.toString(),
      ));
    }
  }

  Future<void> _onLoadMarketplace(
    LoadMarketplaceAdminStats event,
    Emitter<TransportAdminState> emit,
  ) async {
    emit(state.copyWith(marketplaceStatus: TransportAdminStatus.loading));
    try {
      final stats = await repository.getMarketplaceStats();
      emit(state.copyWith(
        marketplaceStatus: TransportAdminStatus.loaded,
        marketplaceStats: stats,
        marketplaceError: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        marketplaceStatus: TransportAdminStatus.error,
        marketplaceError: e.toString(),
      ));
    }
  }

  Future<void> _onLoadDrivers(
    LoadDriversAdminStats event,
    Emitter<TransportAdminState> emit,
  ) async {
    emit(state.copyWith(driversStatus: TransportAdminStatus.loading));
    try {
      final stats = await repository.getDriversStats();
      emit(state.copyWith(
        driversStatus: TransportAdminStatus.loaded,
        driversStats: stats,
        driversError: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        driversStatus: TransportAdminStatus.error,
        driversError: e.toString(),
      ));
    }
  }

  Future<void> _onLoadFraud(
    LoadFraudAdminStats event,
    Emitter<TransportAdminState> emit,
  ) async {
    emit(state.copyWith(fraudStatus: TransportAdminStatus.loading));
    try {
      final stats = await repository.getFraudStats();
      emit(state.copyWith(
        fraudStatus: TransportAdminStatus.loaded,
        fraudStats: stats,
        fraudError: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        fraudStatus: TransportAdminStatus.error,
        fraudError: e.toString(),
      ));
    }
  }
}


// Storekeeper Dashboard Bloc
import 'package:bloc/bloc.dart';
import 'package:trace_odd/features/storekeeper/data/repositories/storekeeper_repository.dart';
import 'storekeeper_event.dart';
import 'storekeeper_state.dart';

class StorekeeperDashboardBloc
    extends Bloc<StorekeeperEvent, StorekeeperDashboardState> {
  StorekeeperDashboardBloc() : super(const StorekeeperDashboardState()) {
    on<LoadStorekeeperDashboard>(_onLoad);
    on<RefreshStorekeeperData>(_onRefresh);
  }

  Future<void> _onLoad(
    LoadStorekeeperDashboard e,
    Emitter<StorekeeperDashboardState> emit,
  ) async {
    emit(state.copyWith(status: StorekeeperStatus.loading));
    try {
      final repo = StorekeeperRepository(panel: e.panel);
      final data = await repo.getDashboard();
      emit(
        state.copyWith(
          status: StorekeeperStatus.loaded,
          totalItems: data.totalItems,
          lowStockItems: data.lowStockItems,
          pendingIssuances: data.pendingIssuances,
          activeIssuances: data.activeIssuances,
          draftReconciliations: data.draftReconciliations,
          outstandingValue: data.outstandingValueMain,
        ),
      );
    } catch (ex) {
      emit(
        state.copyWith(status: StorekeeperStatus.error, error: ex.toString()),
      );
    }
  }

  Future<void> _onRefresh(
    RefreshStorekeeperData e,
    Emitter<StorekeeperDashboardState> emit,
  ) async {
    await _onLoad(LoadStorekeeperDashboard(panel: e.panel), emit);
  }
}

// Storekeeper Dashboard Bloc — manages all storekeeper operations
import 'package:bloc/bloc.dart';
import 'package:trace_odd/features/storekeeper/data/repositories/storekeeper_repository.dart';
import 'storekeeper_event.dart';
import 'storekeeper_state.dart';

class StorekeeperDashboardBloc
    extends Bloc<StorekeeperEvent, StorekeeperDashboardState> {
  StorekeeperDashboardBloc() : super(const StorekeeperDashboardState()) {
    on<LoadStorekeeperDashboard>(_onLoadDash);
    on<RefreshStorekeeperData>(_onRefresh);
    on<LoadCategories>(_onLoadCategories);
    on<LoadItems>(_onLoadItems);
    on<CreateCategory>(_onCreateCategory);
    on<CreateItem>(_onCreateItem);
    on<DeleteCategory>(_onDeleteCategory);
    on<DeleteItem>(_onDeleteItem);
    on<CreateIssuance>(_onCreateIssuance);
    on<IssueItems>(_onIssueItems);
    on<ReconcileIssuance>(_onReconcile);
    on<CreateBundle>(_onCreateBundle);
    on<ClearStorekeeperError>(_onClear);
    on<LoadIssuances>(_onLoadIssuances);
    on<LoadReconciliations>(_onLoadReconciliations);
    on<LoadBundles>(_onLoadBundles);
  }

  StorekeeperRepository _repo(String panel) =>
      StorekeeperRepository(panel: panel);

  Future<void> _onLoadDash(
    LoadStorekeeperDashboard e,
    Emitter<StorekeeperDashboardState> emit,
  ) async {
    emit(state.copyWith(status: StorekeeperStatus.loading));
    try {
      final data = await _repo(e.panel).getDashboard();
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
  ) async => _onLoadDash(LoadStorekeeperDashboard(panel: e.panel), emit);

  // ── Catering ──
  Future<void> _onLoadCategories(
    LoadCategories e,
    Emitter<StorekeeperDashboardState> emit,
  ) async {
    try {
      final cats = await _repo(e.panel).getCategories();
      emit(state.copyWith(categories: cats));
    } catch (_) {}
  }

  Future<void> _onLoadItems(
    LoadItems e,
    Emitter<StorekeeperDashboardState> emit,
  ) async {
    try {
      final res = await _repo(
        e.panel,
      ).getItems(categoryId: e.categoryId, page: e.page, search: e.search);
      emit(
        state.copyWith(
          items: res['items'] as List<dynamic>,
          selectedCategoryId: e.categoryId,
          itemPage: e.page,
          itemSearch: e.search,
        ),
      );
    } catch (_) {}
  }

  Future<void> _onCreateCategory(
    CreateCategory e,
    Emitter<StorekeeperDashboardState> emit,
  ) async {
    emit(state.copyWith(isMutating: true));
    try {
      await _repo(e.panel).createCategory(e.data);
      add(LoadCategories(panel: e.panel));
    } catch (_) {}
    emit(state.copyWith(isMutating: false));
  }

  Future<void> _onCreateItem(
    CreateItem e,
    Emitter<StorekeeperDashboardState> emit,
  ) async {
    emit(state.copyWith(isMutating: true));
    try {
      await _repo(e.panel).createItem(e.data);
      add(LoadItems(panel: e.panel));
    } catch (_) {}
    emit(state.copyWith(isMutating: false));
  }

  Future<void> _onDeleteCategory(
    DeleteCategory e,
    Emitter<StorekeeperDashboardState> emit,
  ) async {
    try {
      await _repo(e.panel).deleteCategory(e.id);
      add(LoadCategories(panel: e.panel));
    } catch (_) {}
  }

  Future<void> _onDeleteItem(
    DeleteItem e,
    Emitter<StorekeeperDashboardState> emit,
  ) async {
    try {
      await _repo(e.panel).deleteItem(e.id);
      add(LoadItems(panel: e.panel));
    } catch (_) {}
  }

  // ── Issuance ──
  Future<void> _onCreateIssuance(
    CreateIssuance e,
    Emitter<StorekeeperDashboardState> emit,
  ) async {
    emit(state.copyWith(isMutating: true));
    try {
      await _repo(e.panel).createIssuance(e.data);
    } catch (_) {}
    emit(state.copyWith(isMutating: false));
  }

  Future<void> _onIssueItems(
    IssueItems e,
    Emitter<StorekeeperDashboardState> emit,
  ) async {
    emit(state.copyWith(isMutating: true));
    try {
      await _repo(e.panel).issueItems(e.issuanceId);
    } catch (_) {}
    emit(state.copyWith(isMutating: false));
  }

  // ── Reconciliation ──
  Future<void> _onReconcile(
    ReconcileIssuance e,
    Emitter<StorekeeperDashboardState> emit,
  ) async {
    emit(state.copyWith(isMutating: true));
    try {
      await _repo(e.panel).reconcile(e.issuanceId, e.data);
    } catch (_) {}
    emit(state.copyWith(isMutating: false));
  }

  // ── Bundle ──
  Future<void> _onCreateBundle(
    CreateBundle e,
    Emitter<StorekeeperDashboardState> emit,
  ) async {
    emit(state.copyWith(isMutating: true));
    try {
      /* bundle creation via repo */
    } catch (_) {}
    emit(state.copyWith(isMutating: false));
  }

  // ── List events for sub-screens ──
  Future<void> _onLoadIssuances(
    LoadIssuances e,
    Emitter<StorekeeperDashboardState> emit,
  ) async {
    emit(state.copyWith(issuancesLoading: true));
    try {
      final res = await _repo(
        e.panel,
      ).getIssuances(page: e.page, status: e.statusFilter);
      emit(
        state.copyWith(
          issuances: (res['issuances'] as List?) ?? [],
          issuancesLoading: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(issuancesLoading: false));
    }
  }

  Future<void> _onLoadReconciliations(
    LoadReconciliations e,
    Emitter<StorekeeperDashboardState> emit,
  ) async {
    emit(state.copyWith(reconciliationsLoading: true));
    try {
      final res = await _repo(
        e.panel,
      ).getReconciliations(page: e.page, status: e.statusFilter);
      emit(
        state.copyWith(
          reconciliations: (res['reconciliations'] as List?) ?? [],
          reconciliationsLoading: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(reconciliationsLoading: false));
    }
  }

  Future<void> _onLoadBundles(
    LoadBundles e,
    Emitter<StorekeeperDashboardState> emit,
  ) async {
    emit(state.copyWith(bundlesLoading: true));
    try {
      final res = await _repo(e.panel).getBundles();
      emit(state.copyWith(bundles: res, bundlesLoading: false));
    } catch (_) {
      emit(state.copyWith(bundlesLoading: false));
    }
  }

  void _onClear(
    ClearStorekeeperError e,
    Emitter<StorekeeperDashboardState> emit,
  ) => emit(state.copyWith(error: null));
}

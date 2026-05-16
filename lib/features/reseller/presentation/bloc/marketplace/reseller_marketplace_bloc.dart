import 'package:bloc/bloc.dart';
import 'package:nexatrace_system/features/reseller/data/repositories/reseller_marketplace_repository.dart';
import 'package:nexatrace_system/shared/models/reseller/reseller_marketplace_product_model.dart';

enum ResellerMarketplaceStatus { initial, loading, loaded, error }

sealed class ResellerMarketplaceEvent {}

final class ResellerMarketplaceBootRequested extends ResellerMarketplaceEvent {
  final String tenantId;
  ResellerMarketplaceBootRequested({required this.tenantId});
}

final class ResellerMarketplaceFactorySelected extends ResellerMarketplaceEvent {
  final String factoryId;
  ResellerMarketplaceFactorySelected(this.factoryId);
}

final class ResellerMarketplaceSearchChanged extends ResellerMarketplaceEvent {
  final String query;
  ResellerMarketplaceSearchChanged(this.query);
}

final class ResellerMarketplaceRefreshRequested extends ResellerMarketplaceEvent {}

final class ResellerMarketplaceState {
  final ResellerMarketplaceStatus status;
  final String tenantId;
  final String selectedFactoryId;
  final String searchQuery;
  final List<Map<String, dynamic>> factories;
  final List<ResellerMarketplaceProductModel> products;
  final String? errorMessage;

  const ResellerMarketplaceState({
    required this.status,
    required this.tenantId,
    required this.selectedFactoryId,
    required this.searchQuery,
    required this.factories,
    required this.products,
    this.errorMessage,
  });

  factory ResellerMarketplaceState.initial() => const ResellerMarketplaceState(
        status: ResellerMarketplaceStatus.initial,
        tenantId: '',
        selectedFactoryId: '',
        searchQuery: '',
        factories: [],
        products: [],
      );

  ResellerMarketplaceState copyWith({
    ResellerMarketplaceStatus? status,
    String? tenantId,
    String? selectedFactoryId,
    String? searchQuery,
    List<Map<String, dynamic>>? factories,
    List<ResellerMarketplaceProductModel>? products,
    String? errorMessage,
  }) {
    return ResellerMarketplaceState(
      status: status ?? this.status,
      tenantId: tenantId ?? this.tenantId,
      selectedFactoryId: selectedFactoryId ?? this.selectedFactoryId,
      searchQuery: searchQuery ?? this.searchQuery,
      factories: factories ?? this.factories,
      products: products ?? this.products,
      errorMessage: errorMessage,
    );
  }
}

class ResellerMarketplaceBloc
    extends Bloc<ResellerMarketplaceEvent, ResellerMarketplaceState> {
  final ResellerMarketplaceRepository _repo;

  ResellerMarketplaceBloc({required ResellerMarketplaceRepository repo})
      : _repo = repo,
        super(ResellerMarketplaceState.initial()) {
    on<ResellerMarketplaceBootRequested>(_onBoot);
    on<ResellerMarketplaceFactorySelected>(_onSelectFactory);
    on<ResellerMarketplaceSearchChanged>(_onSearchChanged);
    on<ResellerMarketplaceRefreshRequested>(_onRefresh);
  }

  Future<void> _onBoot(
    ResellerMarketplaceBootRequested event,
    Emitter<ResellerMarketplaceState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ResellerMarketplaceStatus.loading,
        tenantId: event.tenantId,
        errorMessage: null,
      ),
    );
    try {
      final factories = await _repo.getFactories(tenantId: event.tenantId);
      final selectedFactoryId = factories.isNotEmpty
          ? (factories.first['id']?.toString() ?? '')
          : '';

      var products = <ResellerMarketplaceProductModel>[];
      if (selectedFactoryId.isNotEmpty) {
        products = await _repo.getProducts(
          tenantId: event.tenantId,
          factoryId: selectedFactoryId,
          search: state.searchQuery,
        );
      }

      emit(
        state.copyWith(
          status: ResellerMarketplaceStatus.loaded,
          factories: factories,
          selectedFactoryId: selectedFactoryId,
          products: products,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ResellerMarketplaceStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onSelectFactory(
    ResellerMarketplaceFactorySelected event,
    Emitter<ResellerMarketplaceState> emit,
  ) async {
    if (state.tenantId.isEmpty) return;
    emit(
      state.copyWith(
        status: ResellerMarketplaceStatus.loading,
        selectedFactoryId: event.factoryId,
        errorMessage: null,
      ),
    );
    try {
      final products = await _repo.getProducts(
        tenantId: state.tenantId,
        factoryId: event.factoryId,
        search: state.searchQuery,
      );
      emit(
        state.copyWith(
          status: ResellerMarketplaceStatus.loaded,
          products: products,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ResellerMarketplaceStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onSearchChanged(
    ResellerMarketplaceSearchChanged event,
    Emitter<ResellerMarketplaceState> emit,
  ) async {
    emit(state.copyWith(searchQuery: event.query));
    if (state.tenantId.isEmpty || state.selectedFactoryId.isEmpty) return;
    add(ResellerMarketplaceRefreshRequested());
  }

  Future<void> _onRefresh(
    ResellerMarketplaceRefreshRequested event,
    Emitter<ResellerMarketplaceState> emit,
  ) async {
    if (state.tenantId.isEmpty || state.selectedFactoryId.isEmpty) return;
    emit(state.copyWith(status: ResellerMarketplaceStatus.loading));
    try {
      final products = await _repo.getProducts(
        tenantId: state.tenantId,
        factoryId: state.selectedFactoryId,
        search: state.searchQuery,
      );
      emit(
        state.copyWith(
          status: ResellerMarketplaceStatus.loaded,
          products: products,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ResellerMarketplaceStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}


import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nexatrace_system/core/constants/api_endpoints.dart';
import 'package:nexatrace_system/core/services/api_service.dart';

// ─── Events ─────────────────────────────────────────────────────

abstract class BundleInsightsEvent extends Equatable {
  const BundleInsightsEvent();
  @override
  List<Object?> get props => [];
}

class LoadBundleInsights extends BundleInsightsEvent {
  final String bundleId;
  const LoadBundleInsights(this.bundleId);
  @override
  List<Object?> get props => [bundleId];
}

class LinkUnitsToPacketRequested extends BundleInsightsEvent {
  final String packetId;
  final String productId;
  final String batchId;
  final int quantity;
  const LinkUnitsToPacketRequested({
    required this.packetId,
    required this.productId,
    required this.batchId,
    required this.quantity,
  });
  @override
  List<Object?> get props => [packetId, productId, batchId, quantity];
}

class LoadAvailableProducts extends BundleInsightsEvent {
  const LoadAvailableProducts();
}

class FetchAvailableBatchesRequested extends BundleInsightsEvent {
  final String productId;
  const FetchAvailableBatchesRequested(this.productId);
  @override
  List<Object?> get props => [productId];
}

class ClearLinkResult extends BundleInsightsEvent {
  const ClearLinkResult();
}

// ─── State ───────────────────────────────────────────────────────

enum BundleInsightsStatus { initial, loading, loaded, linking, linked, error }

class BundleInsightsState extends Equatable {
  final BundleInsightsStatus status;
  final Map<String, dynamic>? insightsData;
  final List<Map<String, dynamic>> availableProducts;
  final List<Map<String, dynamic>> availableBatches;
  final Map<String, dynamic>? linkResult;
  final String? errorMessage;

  const BundleInsightsState({
    this.status = BundleInsightsStatus.initial,
    this.insightsData,
    this.availableProducts = const [],
    this.availableBatches = const [],
    this.linkResult,
    this.errorMessage,
  });

  BundleInsightsState copyWith({
    BundleInsightsStatus? status,
    Map<String, dynamic>? insightsData,
    List<Map<String, dynamic>>? availableProducts,
    List<Map<String, dynamic>>? availableBatches,
    Map<String, dynamic>? linkResult,
    String? errorMessage,
  }) {
    return BundleInsightsState(
      status: status ?? this.status,
      insightsData: insightsData ?? this.insightsData,
      availableProducts: availableProducts ?? this.availableProducts,
      availableBatches: availableBatches ?? this.availableBatches,
      linkResult: linkResult ?? this.linkResult,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    insightsData,
    availableProducts,
    availableBatches,
    linkResult,
    errorMessage,
  ];
}

// ─── BLoC ────────────────────────────────────────────────────────

class BundleInsightsBloc
    extends Bloc<BundleInsightsEvent, BundleInsightsState> {
  final ApiService _api = ApiService();

  BundleInsightsBloc() : super(const BundleInsightsState()) {
    on<LoadBundleInsights>(_onLoad);
    on<LinkUnitsToPacketRequested>(_onLinkUnits);
    on<LoadAvailableProducts>(_onLoadAvailableProducts);
    on<FetchAvailableBatchesRequested>(_onFetchBatches);
    on<ClearLinkResult>(_onClearResult);
  }

  Future<void> _onLoad(
    LoadBundleInsights event,
    Emitter<BundleInsightsState> emit,
  ) async {
    emit(state.copyWith(status: BundleInsightsStatus.loading));
    try {
      final res = await _api.get(ApiEndpoints.bundleInsights(event.bundleId));
      emit(
        state.copyWith(
          status: BundleInsightsStatus.loaded,
          insightsData: res['data'] as Map<String, dynamic>?,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: BundleInsightsStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLinkUnits(
    LinkUnitsToPacketRequested event,
    Emitter<BundleInsightsState> emit,
  ) async {
    emit(state.copyWith(status: BundleInsightsStatus.linking));
    try {
      final result = await _api.post(
        ApiEndpoints.aggregationLinkUnits,
        body: {
          'packet_id': event.packetId,
          'product_id': event.productId,
          'batch_id': event.batchId,
          'quantity': event.quantity,
        },
      );
      // Store the raw result — listener will extract what it needs
      final Map<String, dynamic> safeResult = result is Map<String, dynamic>
          ? result
          : <String, dynamic>{};
      emit(
        state.copyWith(
          status: BundleInsightsStatus.linked,
          linkResult: safeResult,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: BundleInsightsStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadAvailableProducts(
    LoadAvailableProducts event,
    Emitter<BundleInsightsState> emit,
  ) async {
    try {
      final res = await _api.get(ApiEndpoints.aggregationAvailableProducts);
      final data = res['data'] as Map<String, dynamic>?;
      final products =
          (data?['products'] as List<dynamic>?)
              ?.map((p) => p as Map<String, dynamic>)
              .toList() ??
          [];
      emit(state.copyWith(availableProducts: products));
    } catch (_) {
      emit(state.copyWith(availableProducts: []));
    }
  }

  Future<void> _onFetchBatches(
    FetchAvailableBatchesRequested event,
    Emitter<BundleInsightsState> emit,
  ) async {
    try {
      final res = await _api.get(
        ApiEndpoints.aggregationAvailableBatches,
        queryParameters: {'product_id': event.productId},
      );
      final data = res['data'] as Map<String, dynamic>?;
      final batches =
          (data?['batches'] as List<dynamic>?)
              ?.map((b) => b as Map<String, dynamic>)
              .toList() ??
          [];
      emit(state.copyWith(availableBatches: batches));
    } catch (_) {
      emit(state.copyWith(availableBatches: []));
    }
  }

  Future<void> _onClearResult(
    ClearLinkResult event,
    Emitter<BundleInsightsState> emit,
  ) async {
    emit(state.copyWith(linkResult: null));
  }
}

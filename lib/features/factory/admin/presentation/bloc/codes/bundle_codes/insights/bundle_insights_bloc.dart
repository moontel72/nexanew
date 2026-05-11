import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nexatrace_system/features/factory/admin/domain/repositories/codes_repository.dart';

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
  final List<Map<String, dynamic>> availableBatches;
  final Map<String, dynamic>? linkResult;
  final String? errorMessage;

  const BundleInsightsState({
    this.status = BundleInsightsStatus.initial,
    this.insightsData,
    this.availableBatches = const [],
    this.linkResult,
    this.errorMessage,
  });

  BundleInsightsState copyWith({
    BundleInsightsStatus? status,
    Map<String, dynamic>? insightsData,
    List<Map<String, dynamic>>? availableBatches,
    Map<String, dynamic>? linkResult,
    String? errorMessage,
  }) {
    return BundleInsightsState(
      status: status ?? this.status,
      insightsData: insightsData ?? this.insightsData,
      availableBatches: availableBatches ?? this.availableBatches,
      linkResult: linkResult ?? this.linkResult,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    insightsData,
    availableBatches,
    linkResult,
    errorMessage,
  ];
}

// ─── BLoC ────────────────────────────────────────────────────────

class BundleInsightsBloc
    extends Bloc<BundleInsightsEvent, BundleInsightsState> {
  final CodesRepository _repository;

  BundleInsightsBloc({required CodesRepository repository})
    : _repository = repository,
      super(const BundleInsightsState()) {
    on<LoadBundleInsights>(_onLoad);
    on<LinkUnitsToPacketRequested>(_onLinkUnits);
    on<FetchAvailableBatchesRequested>(_onFetchBatches);
    on<ClearLinkResult>(_onClearResult);
  }

  Future<void> _onLoad(
    LoadBundleInsights event,
    Emitter<BundleInsightsState> emit,
  ) async {
    emit(state.copyWith(status: BundleInsightsStatus.loading));
    try {
      final data = await _repository.fetchBundleInsights(event.bundleId);
      emit(
        state.copyWith(
          status: BundleInsightsStatus.loaded,
          insightsData: data['data'] as Map<String, dynamic>?,
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
      final result = await _repository.linkUnitsToPacket(
        packetId: event.packetId,
        productId: event.productId,
        batchId: event.batchId,
        quantity: event.quantity,
      );
      emit(
        state.copyWith(status: BundleInsightsStatus.linked, linkResult: result),
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

  Future<void> _onFetchBatches(
    FetchAvailableBatchesRequested event,
    Emitter<BundleInsightsState> emit,
  ) async {
    try {
      final res = await _repository.fetchAvailableBatches(
        productId: event.productId,
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

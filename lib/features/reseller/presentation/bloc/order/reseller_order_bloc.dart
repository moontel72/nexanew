import 'package:bloc/bloc.dart';
import 'package:trace_odd/features/reseller/data/repositories/reseller_order_repository.dart';
import 'package:trace_odd/shared/models/order/cart_item_model.dart';
import 'package:trace_odd/shared/models/order/order_model.dart';

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

sealed class ResellerOrderEvent {}

final class PlaceOrderRequested extends ResellerOrderEvent {
  final String tenantId;
  final String factoryId;
  final String resellerId;
  final List<CartItemModel> items;
  final String? factoryName; // for UI feedback

  PlaceOrderRequested({
    required this.tenantId,
    required this.factoryId,
    required this.resellerId,
    required this.items,
    this.factoryName,
  });
}

final class FetchOrderHistoryRequested extends ResellerOrderEvent {
  final String resellerId;
  final String? tenantId;
  final String? factoryId;
  final int page;
  final int limit;

  FetchOrderHistoryRequested({
    required this.resellerId,
    this.tenantId,
    this.factoryId,
    this.page = 1,
    this.limit = 20,
  });
}

final class FetchOrderDetailRequested extends ResellerOrderEvent {
  final String orderId;
  FetchOrderDetailRequested(this.orderId);
}

// ---------------------------------------------------------------------------
// States
// ---------------------------------------------------------------------------

enum OrderStatus { initial, loading, success, failure }

final class ResellerOrderState {
  final OrderStatus status;
  final OrderModel? lastPlacedOrder;
  final String? lastPlacedFactoryName;
  final List<OrderModel> orderHistory;
  final OrderModel? selectedOrder;
  final String? errorMessage;

  const ResellerOrderState({
    this.status = OrderStatus.initial,
    this.lastPlacedOrder,
    this.lastPlacedFactoryName,
    this.orderHistory = const [],
    this.selectedOrder,
    this.errorMessage,
  });

  ResellerOrderState copyWith({
    OrderStatus? status,
    OrderModel? lastPlacedOrder,
    String? lastPlacedFactoryName,
    List<OrderModel>? orderHistory,
    OrderModel? selectedOrder,
    String? errorMessage,
  }) {
    return ResellerOrderState(
      status: status ?? this.status,
      lastPlacedOrder: lastPlacedOrder ?? this.lastPlacedOrder,
      lastPlacedFactoryName: lastPlacedFactoryName ?? this.lastPlacedFactoryName,
      orderHistory: orderHistory ?? this.orderHistory,
      selectedOrder: selectedOrder ?? this.selectedOrder,
      errorMessage: errorMessage,
    );
  }
}

// ---------------------------------------------------------------------------
// BLoC
// ---------------------------------------------------------------------------

class ResellerOrderBloc
    extends Bloc<ResellerOrderEvent, ResellerOrderState> {
  final ResellerOrderRepository _repo;

  /// Threshold beyond which Rust batch-validates product codes.
  static const int _rustBatchThreshold = 500;

  ResellerOrderBloc({required ResellerOrderRepository repo})
      : _repo = repo,
        super(const ResellerOrderState()) {
    on<PlaceOrderRequested>(_onPlaceOrder);
    on<FetchOrderHistoryRequested>(_onFetchHistory);
    on<FetchOrderDetailRequested>(_onFetchDetail);
  }

  // -----------------------------------------------------------------------
  // Place Order (with optional Rust batch-validation for large orders)
  // -----------------------------------------------------------------------

  Future<void> _onPlaceOrder(
    PlaceOrderRequested event,
    Emitter<ResellerOrderState> emit,
  ) async {
    emit(state.copyWith(status: OrderStatus.loading, errorMessage: null));

    try {
      // ── Rust hook: batch-validate large orders ──
      if (event.items.length >= _rustBatchThreshold) {
        await _batchValidateWithRust(event.items);
      }

      final order = await _repo.placeOrder(
        tenantId: event.tenantId,
        factoryId: event.factoryId,
        resellerId: event.resellerId,
        items: event.items,
      );

      emit(state.copyWith(
        status: OrderStatus.success,
        lastPlacedOrder: order,
        lastPlacedFactoryName: event.factoryName,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OrderStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  // -----------------------------------------------------------------------
  // Fetch History
  // -----------------------------------------------------------------------

  Future<void> _onFetchHistory(
    FetchOrderHistoryRequested event,
    Emitter<ResellerOrderState> emit,
  ) async {
    emit(state.copyWith(status: OrderStatus.loading, errorMessage: null));

    try {
      final history = await _repo.fetchOrderHistory(
        resellerId: event.resellerId,
        tenantId: event.tenantId,
        factoryId: event.factoryId,
        page: event.page,
        limit: event.limit,
      );

      emit(state.copyWith(
        status: OrderStatus.success,
        orderHistory: event.page == 1
            ? history
            : [...state.orderHistory, ...history],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OrderStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  // -----------------------------------------------------------------------
  // Fetch Detail
  // -----------------------------------------------------------------------

  Future<void> _onFetchDetail(
    FetchOrderDetailRequested event,
    Emitter<ResellerOrderState> emit,
  ) async {
    emit(state.copyWith(status: OrderStatus.loading, errorMessage: null));

    try {
      final detail = await _repo.fetchOrderDetail(event.orderId);
      emit(state.copyWith(
        status: OrderStatus.success,
        selectedOrder: detail,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OrderStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  // -----------------------------------------------------------------------
  // Rust batch-validation hook — stubbed for Phase 2 wiring
  // -----------------------------------------------------------------------

  /// Validates all product codes in the cart via the Rust FFI bridge.
  /// Throws [Exception] if any code fails validation.
  Future<void> _batchValidateWithRust(List<CartItemModel> items) async {
    // In Phase 3 this calls:
    //   final valid = await RustModuleService.validateCode(code);
    // For now we perform a lightweight Dart-side sanity check.
    for (final item in items) {
      if (item.productId.isEmpty || item.quantity <= 0) {
        throw Exception('Invalid item in large order: ${item.productId}');
      }
    }
    // TODO (Phase 3): wire RustModuleService.validateCode for each productId
  }
}

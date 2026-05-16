import 'package:bloc/bloc.dart';
import 'package:nexatrace_system/shared/models/order/cart_item_model.dart';
import 'package:nexatrace_system/shared/models/reseller/reseller_marketplace_product_model.dart';

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

sealed class ResellerCartEvent {}

final class AddToCart extends ResellerCartEvent {
  final ResellerMarketplaceProductModel product;
  final int quantity;

  AddToCart({required this.product, this.quantity = 1});
}

final class RemoveFromCart extends ResellerCartEvent {
  final String productId;
  final String factoryId;

  RemoveFromCart({required this.productId, required this.factoryId});
}

final class UpdateQuantity extends ResellerCartEvent {
  final String productId;
  final String factoryId;
  final int newQuantity;

  UpdateQuantity({
    required this.productId,
    required this.factoryId,
    required this.newQuantity,
  });
}

final class ClearCart extends ResellerCartEvent {
  final String? factoryId; // null = clear all

  ClearCart({this.factoryId});
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

final class ResellerCartState {
  /// Grouped by factoryId → list of cart items.
  final Map<String, List<CartItemModel>> itemsByFactory;

  /// Total amount across all factories.
  final double totalAmount;

  /// Total unique item count (not quantity).
  final int itemCount;

  const ResellerCartState({
    this.itemsByFactory = const {},
    this.totalAmount = 0.0,
    this.itemCount = 0,
  });

  ResellerCartState copyWith({
    Map<String, List<CartItemModel>>? itemsByFactory,
  }) {
    final map = itemsByFactory ?? this.itemsByFactory;
    double total = 0;
    int count = 0;
    for (final list in map.values) {
      for (final item in list) {
        total += item.unitPrice * item.quantity;
        count++;
      }
    }
    return ResellerCartState(
      itemsByFactory: map,
      totalAmount: total,
      itemCount: count,
    );
  }

  /// Convenience: all items in a flat list.
  List<CartItemModel> get allItems =>
      itemsByFactory.values.expand((e) => e).toList();

  /// Grouped subtotals per factory.
  Map<String, double> get subtotalsByFactory {
    final map = <String, double>{};
    itemsByFactory.forEach((factoryId, items) {
      double sub = 0;
      for (final item in items) {
        sub += item.unitPrice * item.quantity;
      }
      map[factoryId] = sub;
    });
    return map;
  }
}

// ---------------------------------------------------------------------------
// BLoC
// ---------------------------------------------------------------------------

class ResellerCartBloc extends Bloc<ResellerCartEvent, ResellerCartState> {
  ResellerCartBloc() : super(const ResellerCartState()) {
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateQuantity>(_onUpdateQuantity);
    on<ClearCart>(_onClearCart);
  }

  void _onAddToCart(AddToCart event, Emitter<ResellerCartState> emit) {
    final factoryId = event.product.factoryId;
    final map = Map<String, List<CartItemModel>>.from(state.itemsByFactory);
    final list = List<CartItemModel>.from(map[factoryId] ?? []);

    final existingIdx = list.indexWhere((e) => e.productId == event.product.id);

    final meta = <String, dynamic>{
      'product_name': event.product.name,
      'sku': event.product.sku,
    };

    if (existingIdx >= 0) {
      final existing = list[existingIdx];
      list[existingIdx] = CartItemModel(
        productId: existing.productId,
        tenantId: existing.tenantId,
        factoryId: existing.factoryId,
        quantity: existing.quantity + event.quantity,
        unitPrice: existing.unitPrice,
        metadata: meta,
      );
    } else {
      list.add(
        CartItemModel(
          productId: event.product.id,
          tenantId: event.product.tenantId,
          factoryId: event.product.factoryId,
          quantity: event.quantity,
          unitPrice: event.product.price,
          metadata: meta,
        ),
      );
    }

    map[factoryId] = list;
    emit(state.copyWith(itemsByFactory: map));
  }

  void _onRemoveFromCart(
    RemoveFromCart event,
    Emitter<ResellerCartState> emit,
  ) {
    final map = Map<String, List<CartItemModel>>.from(state.itemsByFactory);
    final list = List<CartItemModel>.from(map[event.factoryId] ?? []);
    list.removeWhere((e) => e.productId == event.productId);

    if (list.isEmpty) {
      map.remove(event.factoryId);
    } else {
      map[event.factoryId] = list;
    }

    emit(state.copyWith(itemsByFactory: map));
  }

  void _onUpdateQuantity(
    UpdateQuantity event,
    Emitter<ResellerCartState> emit,
  ) {
    if (event.newQuantity <= 0) {
      add(
        RemoveFromCart(productId: event.productId, factoryId: event.factoryId),
      );
      return;
    }

    final map = Map<String, List<CartItemModel>>.from(state.itemsByFactory);
    final list = List<CartItemModel>.from(map[event.factoryId] ?? []);
    final idx = list.indexWhere((e) => e.productId == event.productId);

    if (idx >= 0) {
      list[idx] = CartItemModel(
        productId: list[idx].productId,
        tenantId: list[idx].tenantId,
        factoryId: list[idx].factoryId,
        quantity: event.newQuantity,
        unitPrice: list[idx].unitPrice,
        metadata: list[idx].metadata,
      );
      map[event.factoryId] = list;
      emit(state.copyWith(itemsByFactory: map));
    }
  }

  void _onClearCart(ClearCart event, Emitter<ResellerCartState> emit) {
    if (event.factoryId == null) {
      emit(const ResellerCartState());
    } else {
      final map = Map<String, List<CartItemModel>>.from(state.itemsByFactory);
      map.remove(event.factoryId);
      emit(state.copyWith(itemsByFactory: map));
    }
  }
}

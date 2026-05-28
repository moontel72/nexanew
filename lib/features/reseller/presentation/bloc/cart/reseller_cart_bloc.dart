import 'package:bloc/bloc.dart';
import 'package:trace_odd/shared/models/order/cart_item_model.dart';
import 'package:trace_odd/shared/models/product/product_model.dart';
import 'package:trace_odd/shared/models/reseller/reseller_marketplace_product_model.dart';

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

  /// Total amount across all factories (sum of unitPrice × qty).
  final double totalAmount;

  /// Total unique item count (not quantity).
  final int itemCount;

  /// Sum of listPrice × qty per factory.
  final Map<String, double> subtotalByFactory;

  /// Sum of discountAmount per factory.
  final Map<String, double> discountByFactory;

  /// Sum of taxAmount per factory.
  final Map<String, double> taxByFactory;

  const ResellerCartState({
    this.itemsByFactory = const {},
    this.totalAmount = 0.0,
    this.itemCount = 0,
    this.subtotalByFactory = const {},
    this.discountByFactory = const {},
    this.taxByFactory = const {},
  });

  ResellerCartState copyWith({
    Map<String, List<CartItemModel>>? itemsByFactory,
  }) {
    final map = itemsByFactory ?? this.itemsByFactory;
    double total = 0;
    int count = 0;
    final subtotals = <String, double>{};
    final discounts = <String, double>{};
    final taxes = <String, double>{};

    for (final entry in map.entries) {
      double factorySubtotal = 0;
      double factoryDiscount = 0;
      double factoryTax = 0;
      for (final item in entry.value) {
        total += item.unitPrice * item.quantity;
        factorySubtotal += item.listPrice * item.quantity;
        factoryDiscount += item.discountAmount;
        factoryTax += item.taxAmount;
        count++;
      }
      subtotals[entry.key] = factorySubtotal;
      discounts[entry.key] = factoryDiscount;
      taxes[entry.key] = factoryTax;
    }

    return ResellerCartState(
      itemsByFactory: map,
      totalAmount: total,
      itemCount: count,
      subtotalByFactory: subtotals,
      discountByFactory: discounts,
      taxByFactory: taxes,
    );
  }

  /// Convenience: all items in a flat list.
  List<CartItemModel> get allItems =>
      itemsByFactory.values.expand((e) => e).toList();

  /// Grouped subtotals per factory (unitPrice × qty).
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
  static const double _defaultTaxRate = 0.15;

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

    // --- Pricing computation ---
    final listPrice = event.product.price; // base MSRP
    final int totalQty =
        (existingIdx >= 0 ? list[existingIdx].quantity : 0) + event.quantity;

    // Determine discount percent from volume tiers or promo
    double discountPercent = 0.0;
    String? discountType;

    // Check volume discounts
    final volumeDiscounts = event.product.volumeDiscounts;
    if (volumeDiscounts != null && volumeDiscounts.isNotEmpty) {
      // Sort tiers by minQuantity descending, pick highest applicable tier
      final sorted = List<VolumeDiscountTier>.from(volumeDiscounts)
        ..sort((a, b) => b.minQuantity.compareTo(a.minQuantity));
      for (final tier in sorted) {
        if (totalQty >= tier.minQuantity) {
          discountPercent = tier.discountPercent;
          discountType = 'volume';
          break;
        }
      }
    }

    // Check promo discount (takes precedence if higher)
    if (event.product.promoDiscount != null &&
        event.product.promoDiscount! > discountPercent) {
      discountPercent = event.product.promoDiscount!;
      discountType = 'promo';
    }

    final discountAmount = listPrice * discountPercent * totalQty;
    final unitPrice = listPrice * (1 - discountPercent);
    final taxRate = _defaultTaxRate;
    final taxAmount = unitPrice * totalQty * taxRate;
    final lineTotal = (unitPrice * totalQty) + taxAmount;

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
        quantity: totalQty,
        unitPrice: unitPrice,
        listPrice: listPrice,
        discountPercent: discountPercent > 0 ? discountPercent : null,
        discountAmount: discountAmount,
        taxRate: taxRate,
        taxAmount: taxAmount,
        lineTotal: lineTotal,
        discountType: discountType,
        metadata: meta,
      );
    } else {
      list.add(
        CartItemModel(
          productId: event.product.id,
          tenantId: event.product.tenantId,
          factoryId: event.product.factoryId,
          quantity: totalQty,
          unitPrice: unitPrice,
          listPrice: listPrice,
          discountPercent: discountPercent > 0 ? discountPercent : null,
          discountAmount: discountAmount,
          taxRate: taxRate,
          taxAmount: taxAmount,
          lineTotal: lineTotal,
          discountType: discountType,
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
      final existing = list[idx];
      final qty = event.newQuantity;
      final listPrice = existing.listPrice;
      final discountPercent = existing.discountPercent ?? 0.0;
      final unitPrice = listPrice * (1 - discountPercent);
      final discountAmount = listPrice * discountPercent * qty;
      final taxRate = existing.taxRate;
      final taxAmount = unitPrice * qty * taxRate;
      final lineTotal = (unitPrice * qty) + taxAmount;

      list[idx] = CartItemModel(
        productId: existing.productId,
        tenantId: existing.tenantId,
        factoryId: existing.factoryId,
        quantity: qty,
        unitPrice: unitPrice,
        listPrice: listPrice,
        discountPercent: existing.discountPercent,
        discountAmount: discountAmount,
        taxRate: taxRate,
        taxAmount: taxAmount,
        lineTotal: lineTotal,
        discountType: existing.discountType,
        bonusQuantity: existing.bonusQuantity,
        metadata: existing.metadata,
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

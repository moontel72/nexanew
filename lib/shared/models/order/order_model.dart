import 'package:freezed_annotation/freezed_annotation.dart';
import 'cart_item_model.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

@Freezed(fromJson: true, toJson: true)
abstract class OrderModel with _$OrderModel {
  const factory OrderModel({
    required String id,
    required String resellerId,
    required String tenantId,
    required String factoryId,
    @Default('pending') String orderStatus,
    @Default(<CartItemModel>[]) List<CartItemModel> items,
    @Default(0.0) double totalAmount,
    @Default('PKR') String currency,
    @Default(0.0) double subtotal,
    @Default(0.0) double discountTotal,
    @Default(0.0) double taxTotal,
    @Default(0.0) double grandTotal,
    String? pricingProfileId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) = _OrderModel;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final order = _$OrderModelFromJson(json);

    // Apply cross-field defaults
    final subtotal = order.subtotal == 0.0 && order.totalAmount != 0.0
        ? order.totalAmount
        : order.subtotal;
    final grandTotal = order.grandTotal == 0.0
        ? order.totalAmount
        : order.grandTotal;

    if (subtotal != order.subtotal || grandTotal != order.grandTotal) {
      return order.copyWith(subtotal: subtotal, grandTotal: grandTotal);
    }
    return order;
  }
}

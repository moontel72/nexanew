import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart_item_model.freezed.dart';
part 'cart_item_model.g.dart';

@Freezed(fromJson: true, toJson: true)
abstract class CartItemModel with _$CartItemModel {
  const factory CartItemModel({
    required String productId,
    required String tenantId,
    required String factoryId,
    @Default(1) int quantity,
    @Default(0.0) double unitPrice,
    @Default(0.0) double listPrice,
    double? discountPercent,
    @Default(0.0) double discountAmount,
    @Default(0.0) double taxRate,
    @Default(0.0) double taxAmount,
    @Default(0.0) double lineTotal,
    String? discountType,
    double? bonusQuantity,
    Map<String, dynamic>? metadata,
  }) = _CartItemModel;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final item = _$CartItemModelFromJson(json);

    // Apply cross-field defaults
    final listPrice = item.listPrice == 0.0 && item.unitPrice != 0.0
        ? item.unitPrice
        : item.listPrice;
    final lineTotal = item.lineTotal == 0.0
        ? item.unitPrice * item.quantity
        : item.lineTotal;

    if (listPrice != item.listPrice || lineTotal != item.lineTotal) {
      return item.copyWith(listPrice: listPrice, lineTotal: lineTotal);
    }
    return item;
  }
}

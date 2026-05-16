import 'package:freezed_annotation/freezed_annotation.dart';
import 'cart_item_model.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

@freezed
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
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) = _OrderModel;

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);
}


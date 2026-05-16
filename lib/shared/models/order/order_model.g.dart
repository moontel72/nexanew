// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => _OrderModel(
  id: json['id'] as String,
  resellerId: json['resellerId'] as String,
  tenantId: json['tenantId'] as String,
  factoryId: json['factoryId'] as String,
  orderStatus: json['orderStatus'] as String? ?? 'pending',
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CartItemModel>[],
  totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
  currency: json['currency'] as String? ?? 'PKR',
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$OrderModelToJson(_OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'resellerId': instance.resellerId,
      'tenantId': instance.tenantId,
      'factoryId': instance.factoryId,
      'orderStatus': instance.orderStatus,
      'items': instance.items,
      'totalAmount': instance.totalAmount,
      'currency': instance.currency,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'metadata': instance.metadata,
    };

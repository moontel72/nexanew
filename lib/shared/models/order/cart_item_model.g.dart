// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CartItemModel _$CartItemModelFromJson(Map<String, dynamic> json) =>
    _CartItemModel(
      productId: json['productId'] as String,
      tenantId: json['tenantId'] as String,
      factoryId: json['factoryId'] as String,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$CartItemModelToJson(_CartItemModel instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'tenantId': instance.tenantId,
      'factoryId': instance.factoryId,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'metadata': instance.metadata,
    };

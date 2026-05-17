// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CartItemModel _$CartItemModelFromJson(Map<String, dynamic> json) =>
    _CartItemModel(
      productId: json['product_id'] as String,
      tenantId: json['tenant_id'] as String,
      factoryId: json['factory_id'] as String,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      listPrice: (json['list_price'] as num?)?.toDouble() ?? 0.0,
      discountPercent: (json['discount_percent'] as num?)?.toDouble(),
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      taxRate: (json['tax_rate'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['tax_amount'] as num?)?.toDouble() ?? 0.0,
      lineTotal: (json['line_total'] as num?)?.toDouble() ?? 0.0,
      discountType: json['discount_type'] as String?,
      bonusQuantity: (json['bonus_quantity'] as num?)?.toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$CartItemModelToJson(_CartItemModel instance) =>
    <String, dynamic>{
      'product_id': instance.productId,
      'tenant_id': instance.tenantId,
      'factory_id': instance.factoryId,
      'quantity': instance.quantity,
      'unit_price': instance.unitPrice,
      'list_price': instance.listPrice,
      'discount_percent': instance.discountPercent,
      'discount_amount': instance.discountAmount,
      'tax_rate': instance.taxRate,
      'tax_amount': instance.taxAmount,
      'line_total': instance.lineTotal,
      'discount_type': instance.discountType,
      'bonus_quantity': instance.bonusQuantity,
      'metadata': instance.metadata,
    };

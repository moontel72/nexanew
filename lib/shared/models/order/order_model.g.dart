// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => _OrderModel(
  id: json['id'] as String,
  resellerId: json['reseller_id'] as String,
  tenantId: json['tenant_id'] as String,
  factoryId: json['factory_id'] as String,
  orderStatus: json['order_status'] as String? ?? 'pending',
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CartItemModel>[],
  totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
  currency: json['currency'] as String? ?? 'PKR',
  subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
  discountTotal: (json['discount_total'] as num?)?.toDouble() ?? 0.0,
  taxTotal: (json['tax_total'] as num?)?.toDouble() ?? 0.0,
  grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0.0,
  pricingProfileId: json['pricing_profile_id'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$OrderModelToJson(_OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reseller_id': instance.resellerId,
      'tenant_id': instance.tenantId,
      'factory_id': instance.factoryId,
      'order_status': instance.orderStatus,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'total_amount': instance.totalAmount,
      'currency': instance.currency,
      'subtotal': instance.subtotal,
      'discount_total': instance.discountTotal,
      'tax_total': instance.taxTotal,
      'grand_total': instance.grandTotal,
      'pricing_profile_id': instance.pricingProfileId,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'metadata': instance.metadata,
    };

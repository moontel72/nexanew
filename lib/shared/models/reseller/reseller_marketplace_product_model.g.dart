// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reseller_marketplace_product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ResellerMarketplaceProductModel _$ResellerMarketplaceProductModelFromJson(
  Map<String, dynamic> json,
) => _ResellerMarketplaceProductModel(
  id: json['id'] as String,
  tenantId: json['tenant_id'] as String,
  factoryId: json['factory_id'] as String,
  name: json['name'] as String,
  sku: json['sku'] as String? ?? '',
  category: json['category'] as String? ?? '',
  productType: json['product_type'] as String? ?? '',
  status: json['status'] as String? ?? 'active',
  price: (json['price'] as num?)?.toDouble() ?? 0.0,
  currency: json['currency'] as String? ?? 'PKR',
  volumeDiscounts: (json['volume_discounts'] as List<dynamic>?)
      ?.map((e) => VolumeDiscountTier.fromJson(e as Map<String, dynamic>))
      .toList(),
  promoDiscount: (json['promo_discount'] as num?)?.toDouble(),
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ResellerMarketplaceProductModelToJson(
  _ResellerMarketplaceProductModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'tenant_id': instance.tenantId,
  'factory_id': instance.factoryId,
  'name': instance.name,
  'sku': instance.sku,
  'category': instance.category,
  'product_type': instance.productType,
  'status': instance.status,
  'price': instance.price,
  'currency': instance.currency,
  'volume_discounts': instance.volumeDiscounts?.map((e) => e.toJson()).toList(),
  'promo_discount': instance.promoDiscount,
  'metadata': instance.metadata,
};

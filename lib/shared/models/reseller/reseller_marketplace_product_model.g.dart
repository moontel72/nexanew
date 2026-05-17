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
  price: json['price'] == null ? 0.0 : _safeParseDoubleNN(json['price']),
  currency: json['currency'] as String? ?? 'PKR',
  volumeDiscounts: (json['volume_discounts'] as List<dynamic>?)
      ?.map((e) => VolumeDiscountTier.fromJson(e as Map<String, dynamic>))
      .toList(),
  promoDiscount: _safeParseDouble(json['promo_discount']),
  metadata: json['metadata'] as Map<String, dynamic>?,
  factoryName: json['factory_name'] as String?,
  factoryCity: json['factory_city'] as String?,
  factoryLogo: json['factory_logo'] as String?,
  factoryStatus: json['factory_status'] as String?,
  cartonPrice: _safeParseDouble(json['carton_price']),
  wholesalePrice: _safeParseDouble(json['wholesale_price']),
  moq: (json['moq'] as num?)?.toInt(),
  bonusQuantity: (json['bonus_quantity'] as num?)?.toInt(),
  bonusThreshold: (json['bonus_threshold'] as num?)?.toInt(),
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
  'factory_name': instance.factoryName,
  'factory_city': instance.factoryCity,
  'factory_logo': instance.factoryLogo,
  'factory_status': instance.factoryStatus,
  'carton_price': instance.cartonPrice,
  'wholesale_price': instance.wholesalePrice,
  'moq': instance.moq,
  'bonus_quantity': instance.bonusQuantity,
  'bonus_threshold': instance.bonusThreshold,
};

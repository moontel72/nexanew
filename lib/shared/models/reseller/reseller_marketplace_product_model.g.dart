// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reseller_marketplace_product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ResellerMarketplaceProductModel _$ResellerMarketplaceProductModelFromJson(
  Map<String, dynamic> json,
) => _ResellerMarketplaceProductModel(
  id: json['id'] as String,
  tenantId: json['tenantId'] as String,
  factoryId: json['factoryId'] as String,
  name: json['name'] as String,
  sku: json['sku'] as String? ?? '',
  category: json['category'] as String? ?? '',
  productType: json['productType'] as String? ?? '',
  status: json['status'] as String? ?? 'active',
  price: (json['price'] as num?)?.toDouble() ?? 0.0,
  currency: json['currency'] as String? ?? 'PKR',
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ResellerMarketplaceProductModelToJson(
  _ResellerMarketplaceProductModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'tenantId': instance.tenantId,
  'factoryId': instance.factoryId,
  'name': instance.name,
  'sku': instance.sku,
  'category': instance.category,
  'productType': instance.productType,
  'status': instance.status,
  'price': instance.price,
  'currency': instance.currency,
  'metadata': instance.metadata,
};

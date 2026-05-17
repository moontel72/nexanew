// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reseller_shop_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ResellerShopModel _$ResellerShopModelFromJson(Map<String, dynamic> json) =>
    _ResellerShopModel(
      id: json['id'] as String,
      resellerId: json['reseller_id'] as String,
      name: json['name'] as String,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ResellerShopModelToJson(_ResellerShopModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reseller_id': instance.resellerId,
      'name': instance.name,
      'is_active': instance.isActive,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'metadata': instance.metadata,
    };

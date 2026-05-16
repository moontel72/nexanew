// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reseller_shop_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ResellerShopModel _$ResellerShopModelFromJson(Map<String, dynamic> json) =>
    _ResellerShopModel(
      id: json['id'] as String,
      resellerId: json['resellerId'] as String,
      name: json['name'] as String,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ResellerShopModelToJson(_ResellerShopModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'resellerId': instance.resellerId,
      'name': instance.name,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'metadata': instance.metadata,
    };

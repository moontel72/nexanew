// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reseller_employee_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ResellerEmployeeModel _$ResellerEmployeeModelFromJson(
  Map<String, dynamic> json,
) => _ResellerEmployeeModel(
  id: json['id'] as String,
  resellerId: json['reseller_id'] as String,
  shopId: json['shop_id'] as String,
  name: json['name'] as String,
  role: $enumDecode(_$ResellerEmployeeRoleEnumMap, json['role']),
  isActive: json['is_active'] as bool? ?? true,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ResellerEmployeeModelToJson(
  _ResellerEmployeeModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'reseller_id': instance.resellerId,
  'shop_id': instance.shopId,
  'name': instance.name,
  'role': _$ResellerEmployeeRoleEnumMap[instance.role]!,
  'is_active': instance.isActive,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'metadata': instance.metadata,
};

const _$ResellerEmployeeRoleEnumMap = {
  ResellerEmployeeRole.shopManager: 'shopManager',
  ResellerEmployeeRole.cashier: 'cashier',
  ResellerEmployeeRole.stockKeeper: 'stockKeeper',
};

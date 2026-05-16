// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reseller_employee_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ResellerEmployeeModel _$ResellerEmployeeModelFromJson(
  Map<String, dynamic> json,
) => _ResellerEmployeeModel(
  id: json['id'] as String,
  resellerId: json['resellerId'] as String,
  shopId: json['shopId'] as String,
  name: json['name'] as String,
  role: $enumDecode(_$ResellerEmployeeRoleEnumMap, json['role']),
  isActive: json['isActive'] as bool? ?? true,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ResellerEmployeeModelToJson(
  _ResellerEmployeeModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'resellerId': instance.resellerId,
  'shopId': instance.shopId,
  'name': instance.name,
  'role': _$ResellerEmployeeRoleEnumMap[instance.role]!,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'metadata': instance.metadata,
};

const _$ResellerEmployeeRoleEnumMap = {
  ResellerEmployeeRole.shopManager: 'shopManager',
  ResellerEmployeeRole.cashier: 'cashier',
  ResellerEmployeeRole.stockKeeper: 'stockKeeper',
};

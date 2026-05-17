// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_code_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BaseCodeModel _$BaseCodeModelFromJson(Map<String, dynamic> json) =>
    _BaseCodeModel(
      id: json['id'] as String,
      code: json['code'] as String,
      type: $enumDecode(_$CodeTypeEnumMap, json['type']),
      status:
          $enumDecodeNullable(_$CodeStatusEnumMap, json['status']) ??
          CodeStatus.generated,
      factoryId: json['factory_id'] as String,
      subscriptionPlanId: json['subscription_plan_id'] as String,
      storeKeeperCode: json['store_keeper_code'] as String,
      internationalCode: json['international_code'] as String?,
      batchId: json['batch_id'] as String,
      generatedAt: DateTime.parse(json['generated_at'] as String),
      linkedAt: json['linked_at'] == null
          ? null
          : DateTime.parse(json['linked_at'] as String),
      publishedAt: json['published_at'] == null
          ? null
          : DateTime.parse(json['published_at'] as String),
      deactivatedAt: json['deactivated_at'] == null
          ? null
          : DateTime.parse(json['deactivated_at'] as String),
      productId: json['product_id'] as String?,
      productBatchNumber: json['product_batch_number'] as String?,
      manufacturingDate: json['manufacturing_date'] == null
          ? null
          : DateTime.parse(json['manufacturing_date'] as String),
      expiryDate: json['expiry_date'] == null
          ? null
          : DateTime.parse(json['expiry_date'] as String),
      warrantyMonths: (json['warranty_months'] as num?)?.toInt(),
      qrCodeData: json['qr_code_data'] as String?,
      barcodeData: json['barcode_data'] as String?,
      metadata: json['metadata'] as String?,
      version: (json['version'] as num?)?.toInt() ?? 1,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isDeleted: json['is_deleted'] as bool? ?? false,
    );

Map<String, dynamic> _$BaseCodeModelToJson(_BaseCodeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'type': _$CodeTypeEnumMap[instance.type]!,
      'status': _$CodeStatusEnumMap[instance.status]!,
      'factory_id': instance.factoryId,
      'subscription_plan_id': instance.subscriptionPlanId,
      'store_keeper_code': instance.storeKeeperCode,
      'international_code': instance.internationalCode,
      'batch_id': instance.batchId,
      'generated_at': instance.generatedAt.toIso8601String(),
      'linked_at': instance.linkedAt?.toIso8601String(),
      'published_at': instance.publishedAt?.toIso8601String(),
      'deactivated_at': instance.deactivatedAt?.toIso8601String(),
      'product_id': instance.productId,
      'product_batch_number': instance.productBatchNumber,
      'manufacturing_date': instance.manufacturingDate?.toIso8601String(),
      'expiry_date': instance.expiryDate?.toIso8601String(),
      'warranty_months': instance.warrantyMonths,
      'qr_code_data': instance.qrCodeData,
      'barcode_data': instance.barcodeData,
      'metadata': instance.metadata,
      'version': instance.version,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'is_deleted': instance.isDeleted,
    };

const _$CodeTypeEnumMap = {
  CodeType.bundle: 'bundle',
  CodeType.carton: 'carton',
  CodeType.packet: 'packet',
  CodeType.unit: 'unit',
};

const _$CodeStatusEnumMap = {
  CodeStatus.generated: 'generated',
  CodeStatus.linked: 'linked',
  CodeStatus.published: 'published',
  CodeStatus.deactivated: 'deactivated',
  CodeStatus.expired: 'expired',
};

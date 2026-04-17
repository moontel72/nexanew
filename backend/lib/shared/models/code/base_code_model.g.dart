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
      factoryId: json['factoryId'] as String,
      subscriptionPlanId: json['subscriptionPlanId'] as String,
      storeKeeperCode: json['storeKeeperCode'] as String,
      internationalCode: json['internationalCode'] as String?,
      batchId: json['batchId'] as String,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      linkedAt: json['linkedAt'] == null
          ? null
          : DateTime.parse(json['linkedAt'] as String),
      publishedAt: json['publishedAt'] == null
          ? null
          : DateTime.parse(json['publishedAt'] as String),
      deactivatedAt: json['deactivatedAt'] == null
          ? null
          : DateTime.parse(json['deactivatedAt'] as String),
      productId: json['productId'] as String?,
      productBatchNumber: json['productBatchNumber'] as String?,
      manufacturingDate: json['manufacturingDate'] == null
          ? null
          : DateTime.parse(json['manufacturingDate'] as String),
      expiryDate: json['expiryDate'] == null
          ? null
          : DateTime.parse(json['expiryDate'] as String),
      warrantyMonths: (json['warrantyMonths'] as num?)?.toInt(),
      qrCodeData: json['qrCodeData'] as String?,
      barcodeData: json['barcodeData'] as String?,
      metadata: json['metadata'] as String?,
      version: (json['version'] as num?)?.toInt() ?? 1,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );

Map<String, dynamic> _$BaseCodeModelToJson(_BaseCodeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'type': _$CodeTypeEnumMap[instance.type]!,
      'status': _$CodeStatusEnumMap[instance.status]!,
      'factoryId': instance.factoryId,
      'subscriptionPlanId': instance.subscriptionPlanId,
      'storeKeeperCode': instance.storeKeeperCode,
      'internationalCode': instance.internationalCode,
      'batchId': instance.batchId,
      'generatedAt': instance.generatedAt.toIso8601String(),
      'linkedAt': instance.linkedAt?.toIso8601String(),
      'publishedAt': instance.publishedAt?.toIso8601String(),
      'deactivatedAt': instance.deactivatedAt?.toIso8601String(),
      'productId': instance.productId,
      'productBatchNumber': instance.productBatchNumber,
      'manufacturingDate': instance.manufacturingDate?.toIso8601String(),
      'expiryDate': instance.expiryDate?.toIso8601String(),
      'warrantyMonths': instance.warrantyMonths,
      'qrCodeData': instance.qrCodeData,
      'barcodeData': instance.barcodeData,
      'metadata': instance.metadata,
      'version': instance.version,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isDeleted': instance.isDeleted,
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

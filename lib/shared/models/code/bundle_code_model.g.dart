// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bundle_code_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BundleCodeModel _$BundleCodeModelFromJson(
  Map<String, dynamic> json,
) => _BundleCodeModel(
  id: json['id'] as String,
  code: json['code'] as String,
  type: $enumDecodeNullable(_$CodeTypeEnumMap, json['type']) ?? CodeType.bundle,
  status:
      $enumDecodeNullable(_$CodeStatusEnumMap, json['status']) ??
      CodeStatus.generated,
  factoryId: json['factoryId'] as String? ?? '',
  subscriptionPlanId: json['subscriptionPlanId'] as String? ?? '',
  storeKeeperCode: json['storeKeeperCode'] as String? ?? '',
  internationalCode: json['internationalCode'] as String? ?? '',
  batchId: json['batchId'] as String? ?? '',
  generatedAt: _dateTimeFromJson(json['generatedAt']),
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
  createdAt: _dateTimeFromJson(json['createdAt']),
  updatedAt: _dateTimeFromJson(json['updatedAt']),
  isDeleted: json['isDeleted'] as bool? ?? false,
  cartonCount: (json['cartonCount'] as num?)?.toInt() ?? 0,
  cartonCodes:
      (json['cartonCodes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  weight: (json['weight'] as num?)?.toDouble(),
  dimensions: json['dimensions'] as String?,
  storageLocation: json['storageLocation'] as String?,
  shippingMethod: json['shippingMethod'] as String?,
  expectedDeliveryDate: json['expectedDeliveryDate'] == null
      ? null
      : DateTime.parse(json['expectedDeliveryDate'] as String),
  actualDeliveryDate: json['actualDeliveryDate'] == null
      ? null
      : DateTime.parse(json['actualDeliveryDate'] as String),
  sequenceNumber: (json['sequenceNumber'] as num?)?.toInt() ?? 0,
  totalUnits: (json['totalUnits'] as num?)?.toInt() ?? 0,
  category: json['category'] as String?,
  handlingInstructions: json['handlingInstructions'] as String?,
  customsDeclarationNumber: json['customsDeclarationNumber'] as String?,
  insuranceValue: (json['insuranceValue'] as num?)?.toDouble(),
  priority: (json['priority'] as num?)?.toInt() ?? 2,
);

Map<String, dynamic> _$BundleCodeModelToJson(_BundleCodeModel instance) =>
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
      'generatedAt': _dateTimeToJson(instance.generatedAt),
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
      'createdAt': _dateTimeToJson(instance.createdAt),
      'updatedAt': _dateTimeToJson(instance.updatedAt),
      'isDeleted': instance.isDeleted,
      'cartonCount': instance.cartonCount,
      'cartonCodes': instance.cartonCodes,
      'weight': instance.weight,
      'dimensions': instance.dimensions,
      'storageLocation': instance.storageLocation,
      'shippingMethod': instance.shippingMethod,
      'expectedDeliveryDate': instance.expectedDeliveryDate?.toIso8601String(),
      'actualDeliveryDate': instance.actualDeliveryDate?.toIso8601String(),
      'sequenceNumber': instance.sequenceNumber,
      'totalUnits': instance.totalUnits,
      'category': instance.category,
      'handlingInstructions': instance.handlingInstructions,
      'customsDeclarationNumber': instance.customsDeclarationNumber,
      'insuranceValue': instance.insuranceValue,
      'priority': instance.priority,
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

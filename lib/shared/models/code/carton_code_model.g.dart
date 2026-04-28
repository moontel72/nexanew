// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'carton_code_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CartonCodeModel _$CartonCodeModelFromJson(
  Map<String, dynamic> json,
) => _CartonCodeModel(
  id: json['id'] as String,
  code: json['code'] as String,
  type: $enumDecodeNullable(_$CodeTypeEnumMap, json['type']) ?? CodeType.carton,
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
  bundleCode: json['bundleCode'] as String? ?? '',
  packetCount: (json['packetCount'] as num?)?.toInt() ?? 0,
  packetCodes:
      (json['packetCodes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  weight: (json['weight'] as num?)?.toDouble(),
  dimensions: json['dimensions'] as String?,
  sequenceNumber: (json['sequenceNumber'] as num?)?.toInt() ?? 0,
  totalUnits: (json['totalUnits'] as num?)?.toInt() ?? 0,
  cartonType: json['cartonType'] as String?,
  grade: json['grade'] as String?,
  maxWeightCapacity: (json['maxWeightCapacity'] as num?)?.toDouble(),
  isSealed: json['isSealed'] as bool? ?? false,
  sealedAt: json['sealedAt'] == null
      ? null
      : DateTime.parse(json['sealedAt'] as String),
  sealedBy: json['sealedBy'] as String?,
  temperatureRequirements: json['temperatureRequirements'] as String?,
  handlingInstructions: json['handlingInstructions'] as String?,
  cartonBarcode: json['cartonBarcode'] as String?,
  cartonQrCode: json['cartonQrCode'] as String?,
  codeFormat: json['codeFormat'] as String? ?? 'qr',
  condition: json['condition'] as String? ?? 'New',
  lastInspectionDate: json['lastInspectionDate'] == null
      ? null
      : DateTime.parse(json['lastInspectionDate'] as String),
  inspectionNotes: json['inspectionNotes'] as String?,
);

Map<String, dynamic> _$CartonCodeModelToJson(_CartonCodeModel instance) =>
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
      'bundleCode': instance.bundleCode,
      'packetCount': instance.packetCount,
      'packetCodes': instance.packetCodes,
      'weight': instance.weight,
      'dimensions': instance.dimensions,
      'sequenceNumber': instance.sequenceNumber,
      'totalUnits': instance.totalUnits,
      'cartonType': instance.cartonType,
      'grade': instance.grade,
      'maxWeightCapacity': instance.maxWeightCapacity,
      'isSealed': instance.isSealed,
      'sealedAt': instance.sealedAt?.toIso8601String(),
      'sealedBy': instance.sealedBy,
      'temperatureRequirements': instance.temperatureRequirements,
      'handlingInstructions': instance.handlingInstructions,
      'cartonBarcode': instance.cartonBarcode,
      'cartonQrCode': instance.cartonQrCode,
      'codeFormat': instance.codeFormat,
      'condition': instance.condition,
      'lastInspectionDate': instance.lastInspectionDate?.toIso8601String(),
      'inspectionNotes': instance.inspectionNotes,
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

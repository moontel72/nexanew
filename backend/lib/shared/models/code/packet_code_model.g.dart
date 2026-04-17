// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'packet_code_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PacketCodeModel _$PacketCodeModelFromJson(
  Map<String, dynamic> json,
) => _PacketCodeModel(
  id: json['id'] as String,
  code: json['code'] as String,
  type: $enumDecodeNullable(_$CodeTypeEnumMap, json['type']) ?? CodeType.packet,
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
  cartonCode: json['cartonCode'] as String? ?? '',
  unitCount: (json['unitCount'] as num?)?.toInt() ?? 0,
  unitCodes:
      (json['unitCodes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  weight: (json['weight'] as num?)?.toDouble(),
  dimensions: json['dimensions'] as String?,
  sequenceNumber: (json['sequenceNumber'] as num?)?.toInt() ?? 0,
  packetType: json['packetType'] as String?,
  material: json['material'] as String?,
  isSealed: json['isSealed'] as bool? ?? false,
  sealedAt: json['sealedAt'] == null
      ? null
      : DateTime.parse(json['sealedAt'] as String),
  sealedBy: json['sealedBy'] as String?,
  sealingMethod: json['sealingMethod'] as String?,
  packetBarcode: json['packetBarcode'] as String?,
  packetQrCode: json['packetQrCode'] as String?,
  condition: json['condition'] as String? ?? 'Intact',
  hasTamperEvidence: json['hasTamperEvidence'] as bool? ?? false,
  hasChildSafety: json['hasChildSafety'] as bool? ?? false,
  hasInstructions: json['hasInstructions'] as bool? ?? false,
  packetBatchNumber: json['packetBatchNumber'] as String?,
  serialNumber: json['serialNumber'] as String?,
  color: json['color'] as String?,
  printingDetails: json['printingDetails'] as String?,
  qcPassed: json['qcPassed'] as bool? ?? false,
  qcPassedDate: json['qcPassedDate'] == null
      ? null
      : DateTime.parse(json['qcPassedDate'] as String),
  qcPassedBy: json['qcPassedBy'] as String?,
  qcNotes: json['qcNotes'] as String?,
);

Map<String, dynamic> _$PacketCodeModelToJson(_PacketCodeModel instance) =>
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
      'cartonCode': instance.cartonCode,
      'unitCount': instance.unitCount,
      'unitCodes': instance.unitCodes,
      'weight': instance.weight,
      'dimensions': instance.dimensions,
      'sequenceNumber': instance.sequenceNumber,
      'packetType': instance.packetType,
      'material': instance.material,
      'isSealed': instance.isSealed,
      'sealedAt': instance.sealedAt?.toIso8601String(),
      'sealedBy': instance.sealedBy,
      'sealingMethod': instance.sealingMethod,
      'packetBarcode': instance.packetBarcode,
      'packetQrCode': instance.packetQrCode,
      'condition': instance.condition,
      'hasTamperEvidence': instance.hasTamperEvidence,
      'hasChildSafety': instance.hasChildSafety,
      'hasInstructions': instance.hasInstructions,
      'packetBatchNumber': instance.packetBatchNumber,
      'serialNumber': instance.serialNumber,
      'color': instance.color,
      'printingDetails': instance.printingDetails,
      'qcPassed': instance.qcPassed,
      'qcPassedDate': instance.qcPassedDate?.toIso8601String(),
      'qcPassedBy': instance.qcPassedBy,
      'qcNotes': instance.qcNotes,
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

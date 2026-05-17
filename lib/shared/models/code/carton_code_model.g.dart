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
  factoryId: json['factory_id'] as String? ?? '',
  subscriptionPlanId: json['subscription_plan_id'] as String? ?? '',
  storeKeeperCode: json['store_keeper_code'] as String? ?? '',
  internationalCode: json['international_code'] as String? ?? '',
  batchId: json['batch_id'] as String? ?? '',
  generatedAt: _dateTimeFromJson(json['generated_at']),
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
  createdAt: _dateTimeFromJson(json['created_at']),
  updatedAt: _dateTimeFromJson(json['updated_at']),
  isDeleted: json['is_deleted'] as bool? ?? false,
  bundleCode: json['bundle_code'] as String? ?? '',
  packetCount: (json['packet_count'] as num?)?.toInt() ?? 0,
  packetCodes:
      (json['packet_codes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  weight: (json['weight'] as num?)?.toDouble(),
  dimensions: json['dimensions'] as String?,
  sequenceNumber: (json['sequence_number'] as num?)?.toInt() ?? 0,
  totalUnits: (json['total_units'] as num?)?.toInt() ?? 0,
  cartonType: json['carton_type'] as String?,
  grade: json['grade'] as String?,
  maxWeightCapacity: (json['max_weight_capacity'] as num?)?.toDouble(),
  isSealed: json['is_sealed'] as bool? ?? false,
  sealedAt: json['sealed_at'] == null
      ? null
      : DateTime.parse(json['sealed_at'] as String),
  sealedBy: json['sealed_by'] as String?,
  temperatureRequirements: json['temperature_requirements'] as String?,
  handlingInstructions: json['handling_instructions'] as String?,
  cartonBarcode: json['carton_barcode'] as String?,
  cartonQrCode: json['carton_qr_code'] as String?,
  codeFormat: json['code_format'] as String? ?? 'qr',
  condition: json['condition'] as String? ?? 'New',
  lastInspectionDate: json['last_inspection_date'] == null
      ? null
      : DateTime.parse(json['last_inspection_date'] as String),
  inspectionNotes: json['inspection_notes'] as String?,
  linkedOrderReference: json['linked_order_reference'] as String? ?? '',
);

Map<String, dynamic> _$CartonCodeModelToJson(_CartonCodeModel instance) =>
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
      'generated_at': _dateTimeToJson(instance.generatedAt),
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
      'created_at': _dateTimeToJson(instance.createdAt),
      'updated_at': _dateTimeToJson(instance.updatedAt),
      'is_deleted': instance.isDeleted,
      'bundle_code': instance.bundleCode,
      'packet_count': instance.packetCount,
      'packet_codes': instance.packetCodes,
      'weight': instance.weight,
      'dimensions': instance.dimensions,
      'sequence_number': instance.sequenceNumber,
      'total_units': instance.totalUnits,
      'carton_type': instance.cartonType,
      'grade': instance.grade,
      'max_weight_capacity': instance.maxWeightCapacity,
      'is_sealed': instance.isSealed,
      'sealed_at': instance.sealedAt?.toIso8601String(),
      'sealed_by': instance.sealedBy,
      'temperature_requirements': instance.temperatureRequirements,
      'handling_instructions': instance.handlingInstructions,
      'carton_barcode': instance.cartonBarcode,
      'carton_qr_code': instance.cartonQrCode,
      'code_format': instance.codeFormat,
      'condition': instance.condition,
      'last_inspection_date': instance.lastInspectionDate?.toIso8601String(),
      'inspection_notes': instance.inspectionNotes,
      'linked_order_reference': instance.linkedOrderReference,
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

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
  cartonCode: json['carton_code'] as String? ?? '',
  unitCount: (json['unit_count'] as num?)?.toInt() ?? 0,
  unitCodes:
      (json['unit_codes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  weight: (json['weight'] as num?)?.toDouble(),
  dimensions: json['dimensions'] as String?,
  sequenceNumber: (json['sequence_number'] as num?)?.toInt() ?? 0,
  packetType: json['packet_type'] as String?,
  material: json['material'] as String?,
  isSealed: json['is_sealed'] as bool? ?? false,
  sealedAt: json['sealed_at'] == null
      ? null
      : DateTime.parse(json['sealed_at'] as String),
  sealedBy: json['sealed_by'] as String?,
  sealingMethod: json['sealing_method'] as String?,
  packetBarcode: json['packet_barcode'] as String?,
  packetQrCode: json['packet_qr_code'] as String?,
  condition: json['condition'] as String? ?? 'Intact',
  hasTamperEvidence: json['has_tamper_evidence'] as bool? ?? false,
  hasChildSafety: json['has_child_safety'] as bool? ?? false,
  hasInstructions: json['has_instructions'] as bool? ?? false,
  packetBatchNumber: json['packet_batch_number'] as String?,
  serialNumber: json['serial_number'] as String?,
  color: json['color'] as String?,
  printingDetails: json['printing_details'] as String?,
  qcPassed: json['qc_passed'] as bool? ?? false,
  qcPassedDate: json['qc_passed_date'] == null
      ? null
      : DateTime.parse(json['qc_passed_date'] as String),
  qcPassedBy: json['qc_passed_by'] as String?,
  qcNotes: json['qc_notes'] as String?,
  codeFormat: json['code_format'] as String? ?? 'qr',
  linkedOrderReference: json['linked_order_reference'] as String? ?? '',
);

Map<String, dynamic> _$PacketCodeModelToJson(_PacketCodeModel instance) =>
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
      'carton_code': instance.cartonCode,
      'unit_count': instance.unitCount,
      'unit_codes': instance.unitCodes,
      'weight': instance.weight,
      'dimensions': instance.dimensions,
      'sequence_number': instance.sequenceNumber,
      'packet_type': instance.packetType,
      'material': instance.material,
      'is_sealed': instance.isSealed,
      'sealed_at': instance.sealedAt?.toIso8601String(),
      'sealed_by': instance.sealedBy,
      'sealing_method': instance.sealingMethod,
      'packet_barcode': instance.packetBarcode,
      'packet_qr_code': instance.packetQrCode,
      'condition': instance.condition,
      'has_tamper_evidence': instance.hasTamperEvidence,
      'has_child_safety': instance.hasChildSafety,
      'has_instructions': instance.hasInstructions,
      'packet_batch_number': instance.packetBatchNumber,
      'serial_number': instance.serialNumber,
      'color': instance.color,
      'printing_details': instance.printingDetails,
      'qc_passed': instance.qcPassed,
      'qc_passed_date': instance.qcPassedDate?.toIso8601String(),
      'qc_passed_by': instance.qcPassedBy,
      'qc_notes': instance.qcNotes,
      'code_format': instance.codeFormat,
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

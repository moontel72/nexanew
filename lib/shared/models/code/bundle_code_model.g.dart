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
  cartonCount: (json['carton_count'] as num?)?.toInt() ?? 0,
  cartonCodes:
      (json['carton_codes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  weight: (json['weight'] as num?)?.toDouble(),
  dimensions: json['dimensions'] as String?,
  storageLocation: json['storage_location'] as String?,
  shippingMethod: json['shipping_method'] as String?,
  expectedDeliveryDate: json['expected_delivery_date'] == null
      ? null
      : DateTime.parse(json['expected_delivery_date'] as String),
  actualDeliveryDate: json['actual_delivery_date'] == null
      ? null
      : DateTime.parse(json['actual_delivery_date'] as String),
  sequenceNumber: (json['sequence_number'] as num?)?.toInt() ?? 0,
  totalUnits: (json['total_units'] as num?)?.toInt() ?? 0,
  category: json['category'] as String?,
  handlingInstructions: json['handling_instructions'] as String?,
  customsDeclarationNumber: json['customs_declaration_number'] as String?,
  insuranceValue: (json['insurance_value'] as num?)?.toDouble(),
  priority: (json['priority'] as num?)?.toInt() ?? 2,
);

Map<String, dynamic> _$BundleCodeModelToJson(
  _BundleCodeModel instance,
) => <String, dynamic>{
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
  'carton_count': instance.cartonCount,
  'carton_codes': instance.cartonCodes,
  'weight': instance.weight,
  'dimensions': instance.dimensions,
  'storage_location': instance.storageLocation,
  'shipping_method': instance.shippingMethod,
  'expected_delivery_date': instance.expectedDeliveryDate?.toIso8601String(),
  'actual_delivery_date': instance.actualDeliveryDate?.toIso8601String(),
  'sequence_number': instance.sequenceNumber,
  'total_units': instance.totalUnits,
  'category': instance.category,
  'handling_instructions': instance.handlingInstructions,
  'customs_declaration_number': instance.customsDeclarationNumber,
  'insurance_value': instance.insuranceValue,
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

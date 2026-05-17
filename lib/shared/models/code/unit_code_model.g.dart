// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit_code_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UnitCodeModel _$UnitCodeModelFromJson(Map<String, dynamic> json) =>
    _UnitCodeModel(
      id: json['id'] as String,
      code: json['code'] as String,
      type:
          $enumDecodeNullable(_$CodeTypeEnumMap, json['type']) ?? CodeType.unit,
      status:
          $enumDecodeNullable(_$CodeStatusEnumMap, json['status']) ??
          CodeStatus.generated,
      factoryId: json['factory_id'] as String? ?? '',
      subscriptionPlanId: json['subscription_plan_id'] as String? ?? '',
      storeKeeperCode: json['store_keeper_code'] as String? ?? '',
      internationalCode: json['international_code'] as String?,
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
      packetCode: json['packet_code'] as String? ?? '',
      sequenceNumber: (json['sequence_number'] as num?)?.toInt() ?? 0,
      authenticationCode: json['authentication_code'] as String? ?? '',
      isMasterCode: json['is_master_code'] as bool? ?? false,
      masterCodeId: json['master_code_id'] as String?,
      verificationCount: (json['verification_count'] as num?)?.toInt() ?? 0,
      firstVerifiedAt: json['first_verified_at'] == null
          ? null
          : DateTime.parse(json['first_verified_at'] as String),
      lastVerifiedAt: json['last_verified_at'] == null
          ? null
          : DateTime.parse(json['last_verified_at'] as String),
      verificationLocation: json['verification_location'] as String?,
      verifiedBy: json['verified_by'] as String?,
      isReportedFake: json['is_reported_fake'] as bool? ?? false,
      fakeReportedAt: json['fake_reported_at'] == null
          ? null
          : DateTime.parse(json['fake_reported_at'] as String),
      fakeReportedBy: json['fake_reported_by'] as String?,
      fakeReportReason: json['fake_report_reason'] as String?,
      isBlocked: json['is_blocked'] as bool? ?? false,
      blockedAt: json['blocked_at'] == null
          ? null
          : DateTime.parse(json['blocked_at'] as String),
      blockedBy: json['blocked_by'] as String?,
      blockReason: json['block_reason'] as String?,
      serialNumber: json['serial_number'] as String? ?? '',
      model: json['model'] as String?,
      color: json['color'] as String?,
      size: json['size'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      dimensions: json['dimensions'] as String?,
      condition: json['condition'] as String? ?? 'New',
      grade: json['grade'] as String?,
      hasWarrantyCard: json['has_warranty_card'] as bool? ?? false,
      hasUserManual: json['has_user_manual'] as bool? ?? false,
      hasAccessories: json['has_accessories'] as bool? ?? false,
      accessoriesList: json['accessories_list'] as String?,
      specialFeatures: json['special_features'] as String?,
      safetyCertifications: json['safety_certifications'] as String?,
      complianceStandards: json['compliance_standards'] as String?,
      lastMaintenanceDate: json['last_maintenance_date'] == null
          ? null
          : DateTime.parse(json['last_maintenance_date'] as String),
      maintenanceNotes: json['maintenance_notes'] as String?,
      isActivated: json['is_activated'] as bool? ?? false,
      activatedAt: json['activated_at'] == null
          ? null
          : DateTime.parse(json['activated_at'] as String),
      activatedBy: json['activated_by'] as String?,
      activationLocation: json['activation_location'] as String?,
      codeFormat: json['code_format'] as String? ?? 'qr',
      linkedOrderReference: json['linked_order_reference'] as String? ?? '',
      linkedBundleCode: json['linked_bundle_code'] as String? ?? '',
    );

Map<String, dynamic> _$UnitCodeModelToJson(_UnitCodeModel instance) =>
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
      'packet_code': instance.packetCode,
      'sequence_number': instance.sequenceNumber,
      'authentication_code': instance.authenticationCode,
      'is_master_code': instance.isMasterCode,
      'master_code_id': instance.masterCodeId,
      'verification_count': instance.verificationCount,
      'first_verified_at': instance.firstVerifiedAt?.toIso8601String(),
      'last_verified_at': instance.lastVerifiedAt?.toIso8601String(),
      'verification_location': instance.verificationLocation,
      'verified_by': instance.verifiedBy,
      'is_reported_fake': instance.isReportedFake,
      'fake_reported_at': instance.fakeReportedAt?.toIso8601String(),
      'fake_reported_by': instance.fakeReportedBy,
      'fake_report_reason': instance.fakeReportReason,
      'is_blocked': instance.isBlocked,
      'blocked_at': instance.blockedAt?.toIso8601String(),
      'blocked_by': instance.blockedBy,
      'block_reason': instance.blockReason,
      'serial_number': instance.serialNumber,
      'model': instance.model,
      'color': instance.color,
      'size': instance.size,
      'weight': instance.weight,
      'dimensions': instance.dimensions,
      'condition': instance.condition,
      'grade': instance.grade,
      'has_warranty_card': instance.hasWarrantyCard,
      'has_user_manual': instance.hasUserManual,
      'has_accessories': instance.hasAccessories,
      'accessories_list': instance.accessoriesList,
      'special_features': instance.specialFeatures,
      'safety_certifications': instance.safetyCertifications,
      'compliance_standards': instance.complianceStandards,
      'last_maintenance_date': instance.lastMaintenanceDate?.toIso8601String(),
      'maintenance_notes': instance.maintenanceNotes,
      'is_activated': instance.isActivated,
      'activated_at': instance.activatedAt?.toIso8601String(),
      'activated_by': instance.activatedBy,
      'activation_location': instance.activationLocation,
      'code_format': instance.codeFormat,
      'linked_order_reference': instance.linkedOrderReference,
      'linked_bundle_code': instance.linkedBundleCode,
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

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
      factoryId: json['factoryId'] as String? ?? '',
      subscriptionPlanId: json['subscriptionPlanId'] as String? ?? '',
      storeKeeperCode: json['storeKeeperCode'] as String? ?? '',
      internationalCode: json['internationalCode'] as String?,
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
      packetCode: json['packetCode'] as String? ?? '',
      sequenceNumber: (json['sequenceNumber'] as num?)?.toInt() ?? 0,
      authenticationCode: json['authenticationCode'] as String? ?? '',
      isMasterCode: json['isMasterCode'] as bool? ?? false,
      masterCodeId: json['masterCodeId'] as String?,
      verificationCount: (json['verificationCount'] as num?)?.toInt() ?? 0,
      firstVerifiedAt: json['firstVerifiedAt'] == null
          ? null
          : DateTime.parse(json['firstVerifiedAt'] as String),
      lastVerifiedAt: json['lastVerifiedAt'] == null
          ? null
          : DateTime.parse(json['lastVerifiedAt'] as String),
      verificationLocation: json['verificationLocation'] as String?,
      verifiedBy: json['verifiedBy'] as String?,
      isReportedFake: json['isReportedFake'] as bool? ?? false,
      fakeReportedAt: json['fakeReportedAt'] == null
          ? null
          : DateTime.parse(json['fakeReportedAt'] as String),
      fakeReportedBy: json['fakeReportedBy'] as String?,
      fakeReportReason: json['fakeReportReason'] as String?,
      isBlocked: json['isBlocked'] as bool? ?? false,
      blockedAt: json['blockedAt'] == null
          ? null
          : DateTime.parse(json['blockedAt'] as String),
      blockedBy: json['blockedBy'] as String?,
      blockReason: json['blockReason'] as String?,
      serialNumber: json['serialNumber'] as String? ?? '',
      model: json['model'] as String?,
      color: json['color'] as String?,
      size: json['size'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      dimensions: json['dimensions'] as String?,
      condition: json['condition'] as String? ?? 'New',
      grade: json['grade'] as String?,
      hasWarrantyCard: json['hasWarrantyCard'] as bool? ?? false,
      hasUserManual: json['hasUserManual'] as bool? ?? false,
      hasAccessories: json['hasAccessories'] as bool? ?? false,
      accessoriesList: json['accessoriesList'] as String?,
      specialFeatures: json['specialFeatures'] as String?,
      safetyCertifications: json['safetyCertifications'] as String?,
      complianceStandards: json['complianceStandards'] as String?,
      lastMaintenanceDate: json['lastMaintenanceDate'] == null
          ? null
          : DateTime.parse(json['lastMaintenanceDate'] as String),
      maintenanceNotes: json['maintenanceNotes'] as String?,
      isActivated: json['isActivated'] as bool? ?? false,
      activatedAt: json['activatedAt'] == null
          ? null
          : DateTime.parse(json['activatedAt'] as String),
      activatedBy: json['activatedBy'] as String?,
      activationLocation: json['activationLocation'] as String?,
      codeFormat: json['codeFormat'] as String? ?? 'qr',
      linkedOrderReference: json['linkedOrderReference'] as String? ?? '',
      linkedBundleCode: json['linkedBundleCode'] as String? ?? '',
    );

Map<String, dynamic> _$UnitCodeModelToJson(_UnitCodeModel instance) =>
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
      'packetCode': instance.packetCode,
      'sequenceNumber': instance.sequenceNumber,
      'authenticationCode': instance.authenticationCode,
      'isMasterCode': instance.isMasterCode,
      'masterCodeId': instance.masterCodeId,
      'verificationCount': instance.verificationCount,
      'firstVerifiedAt': instance.firstVerifiedAt?.toIso8601String(),
      'lastVerifiedAt': instance.lastVerifiedAt?.toIso8601String(),
      'verificationLocation': instance.verificationLocation,
      'verifiedBy': instance.verifiedBy,
      'isReportedFake': instance.isReportedFake,
      'fakeReportedAt': instance.fakeReportedAt?.toIso8601String(),
      'fakeReportedBy': instance.fakeReportedBy,
      'fakeReportReason': instance.fakeReportReason,
      'isBlocked': instance.isBlocked,
      'blockedAt': instance.blockedAt?.toIso8601String(),
      'blockedBy': instance.blockedBy,
      'blockReason': instance.blockReason,
      'serialNumber': instance.serialNumber,
      'model': instance.model,
      'color': instance.color,
      'size': instance.size,
      'weight': instance.weight,
      'dimensions': instance.dimensions,
      'condition': instance.condition,
      'grade': instance.grade,
      'hasWarrantyCard': instance.hasWarrantyCard,
      'hasUserManual': instance.hasUserManual,
      'hasAccessories': instance.hasAccessories,
      'accessoriesList': instance.accessoriesList,
      'specialFeatures': instance.specialFeatures,
      'safetyCertifications': instance.safetyCertifications,
      'complianceStandards': instance.complianceStandards,
      'lastMaintenanceDate': instance.lastMaintenanceDate?.toIso8601String(),
      'maintenanceNotes': instance.maintenanceNotes,
      'isActivated': instance.isActivated,
      'activatedAt': instance.activatedAt?.toIso8601String(),
      'activatedBy': instance.activatedBy,
      'activationLocation': instance.activationLocation,
      'codeFormat': instance.codeFormat,
      'linkedOrderReference': instance.linkedOrderReference,
      'linkedBundleCode': instance.linkedBundleCode,
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

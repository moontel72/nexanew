// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'code_generation_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BaseCodeGenerationRequest _$BaseCodeGenerationRequestFromJson(
  Map<String, dynamic> json,
) => _BaseCodeGenerationRequest(
  factoryId: json['factoryId'] as String,
  subscriptionPlanId: json['subscriptionPlanId'] as String,
  count: (json['count'] as num).toInt(),
  prefix: json['prefix'] as String,
  startSequence: (json['startSequence'] as num?)?.toInt() ?? 1,
  includeInternationalCodes: json['includeInternationalCodes'] as bool? ?? true,
  generateQrCodes: json['generateQrCodes'] as bool? ?? true,
  generateBarcodes: json['generateBarcodes'] as bool? ?? true,
  batchName: json['batchName'] as String?,
  batchNotes: json['batchNotes'] as String?,
  metadata: json['metadata'] as String?,
);

Map<String, dynamic> _$BaseCodeGenerationRequestToJson(
  _BaseCodeGenerationRequest instance,
) => <String, dynamic>{
  'factoryId': instance.factoryId,
  'subscriptionPlanId': instance.subscriptionPlanId,
  'count': instance.count,
  'prefix': instance.prefix,
  'startSequence': instance.startSequence,
  'includeInternationalCodes': instance.includeInternationalCodes,
  'generateQrCodes': instance.generateQrCodes,
  'generateBarcodes': instance.generateBarcodes,
  'batchName': instance.batchName,
  'batchNotes': instance.batchNotes,
  'metadata': instance.metadata,
};

_BundleCodeGenerationRequest _$BundleCodeGenerationRequestFromJson(
  Map<String, dynamic> json,
) => _BundleCodeGenerationRequest(
  factoryId: json['factoryId'] as String,
  subscriptionPlanId: json['subscriptionPlanId'] as String,
  count: (json['count'] as num).toInt(),
  prefix: json['prefix'] as String,
  startSequence: (json['startSequence'] as num?)?.toInt() ?? 1,
  includeInternationalCodes: json['includeInternationalCodes'] as bool? ?? true,
  generateQrCodes: json['generateQrCodes'] as bool? ?? true,
  generateBarcodes: json['generateBarcodes'] as bool? ?? true,
  batchName: json['batchName'] as String?,
  batchNotes: json['batchNotes'] as String?,
  metadata: json['metadata'] as String?,
  cartonsPerBundle: (json['cartonsPerBundle'] as num).toInt(),
  bundleWeight: (json['bundleWeight'] as num?)?.toDouble(),
  bundleDimensions: json['bundleDimensions'] as String?,
  storageLocation: json['storageLocation'] as String?,
  shippingMethod: json['shippingMethod'] as String?,
  expectedDeliveryDate: json['expectedDeliveryDate'] == null
      ? null
      : DateTime.parse(json['expectedDeliveryDate'] as String),
  category: json['category'] as String?,
  handlingInstructions: json['handlingInstructions'] as String?,
  customsDeclarationNumber: json['customsDeclarationNumber'] as String?,
  insuranceValue: (json['insuranceValue'] as num?)?.toDouble(),
  priority: (json['priority'] as num?)?.toInt() ?? 2,
);

Map<String, dynamic> _$BundleCodeGenerationRequestToJson(
  _BundleCodeGenerationRequest instance,
) => <String, dynamic>{
  'factoryId': instance.factoryId,
  'subscriptionPlanId': instance.subscriptionPlanId,
  'count': instance.count,
  'prefix': instance.prefix,
  'startSequence': instance.startSequence,
  'includeInternationalCodes': instance.includeInternationalCodes,
  'generateQrCodes': instance.generateQrCodes,
  'generateBarcodes': instance.generateBarcodes,
  'batchName': instance.batchName,
  'batchNotes': instance.batchNotes,
  'metadata': instance.metadata,
  'cartonsPerBundle': instance.cartonsPerBundle,
  'bundleWeight': instance.bundleWeight,
  'bundleDimensions': instance.bundleDimensions,
  'storageLocation': instance.storageLocation,
  'shippingMethod': instance.shippingMethod,
  'expectedDeliveryDate': instance.expectedDeliveryDate?.toIso8601String(),
  'category': instance.category,
  'handlingInstructions': instance.handlingInstructions,
  'customsDeclarationNumber': instance.customsDeclarationNumber,
  'insuranceValue': instance.insuranceValue,
  'priority': instance.priority,
};

_CartonCodeGenerationRequest _$CartonCodeGenerationRequestFromJson(
  Map<String, dynamic> json,
) => _CartonCodeGenerationRequest(
  factoryId: json['factoryId'] as String,
  subscriptionPlanId: json['subscriptionPlanId'] as String,
  count: (json['count'] as num).toInt(),
  prefix: json['prefix'] as String,
  startSequence: (json['startSequence'] as num?)?.toInt() ?? 1,
  includeInternationalCodes: json['includeInternationalCodes'] as bool? ?? true,
  generateQrCodes: json['generateQrCodes'] as bool? ?? true,
  generateBarcodes: json['generateBarcodes'] as bool? ?? true,
  batchName: json['batchName'] as String?,
  batchNotes: json['batchNotes'] as String?,
  metadata: json['metadata'] as String?,
  bundleCode: json['bundleCode'] as String,
  packetsPerCarton: (json['packetsPerCarton'] as num).toInt(),
  cartonWeight: (json['cartonWeight'] as num?)?.toDouble(),
  cartonDimensions: json['cartonDimensions'] as String?,
  cartonType: json['cartonType'] as String?,
  grade: json['grade'] as String?,
  maxWeightCapacity: (json['maxWeightCapacity'] as num?)?.toDouble(),
  temperatureRequirements: json['temperatureRequirements'] as String?,
  handlingInstructions: json['handlingInstructions'] as String?,
  generateCartonBarcode: json['generateCartonBarcode'] as bool? ?? true,
  generateCartonQrCode: json['generateCartonQrCode'] as bool? ?? true,
);

Map<String, dynamic> _$CartonCodeGenerationRequestToJson(
  _CartonCodeGenerationRequest instance,
) => <String, dynamic>{
  'factoryId': instance.factoryId,
  'subscriptionPlanId': instance.subscriptionPlanId,
  'count': instance.count,
  'prefix': instance.prefix,
  'startSequence': instance.startSequence,
  'includeInternationalCodes': instance.includeInternationalCodes,
  'generateQrCodes': instance.generateQrCodes,
  'generateBarcodes': instance.generateBarcodes,
  'batchName': instance.batchName,
  'batchNotes': instance.batchNotes,
  'metadata': instance.metadata,
  'bundleCode': instance.bundleCode,
  'packetsPerCarton': instance.packetsPerCarton,
  'cartonWeight': instance.cartonWeight,
  'cartonDimensions': instance.cartonDimensions,
  'cartonType': instance.cartonType,
  'grade': instance.grade,
  'maxWeightCapacity': instance.maxWeightCapacity,
  'temperatureRequirements': instance.temperatureRequirements,
  'handlingInstructions': instance.handlingInstructions,
  'generateCartonBarcode': instance.generateCartonBarcode,
  'generateCartonQrCode': instance.generateCartonQrCode,
};

_PacketCodeGenerationRequest _$PacketCodeGenerationRequestFromJson(
  Map<String, dynamic> json,
) => _PacketCodeGenerationRequest(
  factoryId: json['factoryId'] as String,
  subscriptionPlanId: json['subscriptionPlanId'] as String,
  count: (json['count'] as num).toInt(),
  prefix: json['prefix'] as String,
  startSequence: (json['startSequence'] as num?)?.toInt() ?? 1,
  includeInternationalCodes: json['includeInternationalCodes'] as bool? ?? true,
  generateQrCodes: json['generateQrCodes'] as bool? ?? true,
  generateBarcodes: json['generateBarcodes'] as bool? ?? true,
  batchName: json['batchName'] as String?,
  batchNotes: json['batchNotes'] as String?,
  metadata: json['metadata'] as String?,
  cartonCode: json['cartonCode'] as String,
  unitsPerPacket: (json['unitsPerPacket'] as num).toInt(),
  packetWeight: (json['packetWeight'] as num?)?.toDouble(),
  packetDimensions: json['packetDimensions'] as String?,
  packetType: json['packetType'] as String?,
  material: json['material'] as String?,
  sealingMethod: json['sealingMethod'] as String?,
  includeTamperEvidence: json['includeTamperEvidence'] as bool? ?? false,
  includeChildSafety: json['includeChildSafety'] as bool? ?? false,
  includeInstructions: json['includeInstructions'] as bool? ?? true,
  color: json['color'] as String?,
  printingDetails: json['printingDetails'] as String?,
  generatePacketBarcode: json['generatePacketBarcode'] as bool? ?? true,
  generatePacketQrCode: json['generatePacketQrCode'] as bool? ?? true,
);

Map<String, dynamic> _$PacketCodeGenerationRequestToJson(
  _PacketCodeGenerationRequest instance,
) => <String, dynamic>{
  'factoryId': instance.factoryId,
  'subscriptionPlanId': instance.subscriptionPlanId,
  'count': instance.count,
  'prefix': instance.prefix,
  'startSequence': instance.startSequence,
  'includeInternationalCodes': instance.includeInternationalCodes,
  'generateQrCodes': instance.generateQrCodes,
  'generateBarcodes': instance.generateBarcodes,
  'batchName': instance.batchName,
  'batchNotes': instance.batchNotes,
  'metadata': instance.metadata,
  'cartonCode': instance.cartonCode,
  'unitsPerPacket': instance.unitsPerPacket,
  'packetWeight': instance.packetWeight,
  'packetDimensions': instance.packetDimensions,
  'packetType': instance.packetType,
  'material': instance.material,
  'sealingMethod': instance.sealingMethod,
  'includeTamperEvidence': instance.includeTamperEvidence,
  'includeChildSafety': instance.includeChildSafety,
  'includeInstructions': instance.includeInstructions,
  'color': instance.color,
  'printingDetails': instance.printingDetails,
  'generatePacketBarcode': instance.generatePacketBarcode,
  'generatePacketQrCode': instance.generatePacketQrCode,
};

_UnitCodeGenerationRequest _$UnitCodeGenerationRequestFromJson(
  Map<String, dynamic> json,
) => _UnitCodeGenerationRequest(
  factoryId: json['factoryId'] as String,
  subscriptionPlanId: json['subscriptionPlanId'] as String,
  count: (json['count'] as num).toInt(),
  prefix: json['prefix'] as String,
  startSequence: (json['startSequence'] as num?)?.toInt() ?? 1,
  includeInternationalCodes:
      json['includeInternationalCodes'] as bool? ?? false,
  generateQrCodes: json['generateQrCodes'] as bool? ?? true,
  generateBarcodes: json['generateBarcodes'] as bool? ?? true,
  batchName: json['batchName'] as String?,
  batchNotes: json['batchNotes'] as String?,
  metadata: json['metadata'] as String?,
  packetCode: json['packetCode'] as String,
  authenticationAlgorithm:
      json['authenticationAlgorithm'] as String? ?? 'secure_random',
  authenticationCodeLength:
      (json['authenticationCodeLength'] as num?)?.toInt() ?? 16,
  includeMasterCodes: json['includeMasterCodes'] as bool? ?? true,
  unitsPerMasterCode: (json['unitsPerMasterCode'] as num?)?.toInt() ?? 100,
  model: json['model'] as String?,
  color: json['color'] as String?,
  size: json['size'] as String?,
  unitWeight: (json['unitWeight'] as num?)?.toDouble(),
  unitDimensions: json['unitDimensions'] as String?,
  condition: json['condition'] as String? ?? 'New',
  grade: json['grade'] as String?,
  includeWarrantyCard: json['includeWarrantyCard'] as bool? ?? true,
  includeUserManual: json['includeUserManual'] as bool? ?? true,
  includeAccessories: json['includeAccessories'] as bool? ?? false,
  accessoriesList: json['accessoriesList'] as String?,
  specialFeatures: json['specialFeatures'] as String?,
  safetyCertifications: json['safetyCertifications'] as String?,
  complianceStandards: json['complianceStandards'] as String?,
);

Map<String, dynamic> _$UnitCodeGenerationRequestToJson(
  _UnitCodeGenerationRequest instance,
) => <String, dynamic>{
  'factoryId': instance.factoryId,
  'subscriptionPlanId': instance.subscriptionPlanId,
  'count': instance.count,
  'prefix': instance.prefix,
  'startSequence': instance.startSequence,
  'includeInternationalCodes': instance.includeInternationalCodes,
  'generateQrCodes': instance.generateQrCodes,
  'generateBarcodes': instance.generateBarcodes,
  'batchName': instance.batchName,
  'batchNotes': instance.batchNotes,
  'metadata': instance.metadata,
  'packetCode': instance.packetCode,
  'authenticationAlgorithm': instance.authenticationAlgorithm,
  'authenticationCodeLength': instance.authenticationCodeLength,
  'includeMasterCodes': instance.includeMasterCodes,
  'unitsPerMasterCode': instance.unitsPerMasterCode,
  'model': instance.model,
  'color': instance.color,
  'size': instance.size,
  'unitWeight': instance.unitWeight,
  'unitDimensions': instance.unitDimensions,
  'condition': instance.condition,
  'grade': instance.grade,
  'includeWarrantyCard': instance.includeWarrantyCard,
  'includeUserManual': instance.includeUserManual,
  'includeAccessories': instance.includeAccessories,
  'accessoriesList': instance.accessoriesList,
  'specialFeatures': instance.specialFeatures,
  'safetyCertifications': instance.safetyCertifications,
  'complianceStandards': instance.complianceStandards,
};

_BatchCodeGenerationRequest _$BatchCodeGenerationRequestFromJson(
  Map<String, dynamic> json,
) => _BatchCodeGenerationRequest(
  factoryId: json['factoryId'] as String,
  subscriptionPlanId: json['subscriptionPlanId'] as String,
  batchName: json['batchName'] as String,
  batchDescription: json['batchDescription'] as String?,
  bundleRequest: json['bundleRequest'] == null
      ? null
      : BundleCodeGenerationRequest.fromJson(
          json['bundleRequest'] as Map<String, dynamic>,
        ),
  cartonRequest: json['cartonRequest'] == null
      ? null
      : CartonCodeGenerationRequest.fromJson(
          json['cartonRequest'] as Map<String, dynamic>,
        ),
  packetRequest: json['packetRequest'] == null
      ? null
      : PacketCodeGenerationRequest.fromJson(
          json['packetRequest'] as Map<String, dynamic>,
        ),
  unitRequest: json['unitRequest'] == null
      ? null
      : UnitCodeGenerationRequest.fromJson(
          json['unitRequest'] as Map<String, dynamic>,
        ),
  generateHierarchical: json['generateHierarchical'] as bool? ?? false,
  hierarchicalConfig: json['hierarchicalConfig'] == null
      ? null
      : HierarchicalConfig.fromJson(
          json['hierarchicalConfig'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$BatchCodeGenerationRequestToJson(
  _BatchCodeGenerationRequest instance,
) => <String, dynamic>{
  'factoryId': instance.factoryId,
  'subscriptionPlanId': instance.subscriptionPlanId,
  'batchName': instance.batchName,
  'batchDescription': instance.batchDescription,
  'bundleRequest': instance.bundleRequest,
  'cartonRequest': instance.cartonRequest,
  'packetRequest': instance.packetRequest,
  'unitRequest': instance.unitRequest,
  'generateHierarchical': instance.generateHierarchical,
  'hierarchicalConfig': instance.hierarchicalConfig,
};

_HierarchicalConfig _$HierarchicalConfigFromJson(Map<String, dynamic> json) =>
    _HierarchicalConfig(
      bundleCount: (json['bundleCount'] as num).toInt(),
      cartonsPerBundle: (json['cartonsPerBundle'] as num).toInt(),
      packetsPerCarton: (json['packetsPerCarton'] as num).toInt(),
      unitsPerPacket: (json['unitsPerPacket'] as num).toInt(),
      bundlePrefix: json['bundlePrefix'] as String,
      cartonPrefix: json['cartonPrefix'] as String,
      packetPrefix: json['packetPrefix'] as String,
      unitPrefix: json['unitPrefix'] as String,
      bundleCategory: json['bundleCategory'] as String?,
      bundleWeight: (json['bundleWeight'] as num?)?.toDouble(),
      bundleDimensions: json['bundleDimensions'] as String?,
      cartonType: json['cartonType'] as String?,
      cartonWeight: (json['cartonWeight'] as num?)?.toDouble(),
      cartonDimensions: json['cartonDimensions'] as String?,
      packetType: json['packetType'] as String?,
      packetMaterial: json['packetMaterial'] as String?,
      packetWeight: (json['packetWeight'] as num?)?.toDouble(),
      packetDimensions: json['packetDimensions'] as String?,
      unitModel: json['unitModel'] as String?,
      unitColor: json['unitColor'] as String?,
      unitSize: json['unitSize'] as String?,
      unitWeight: (json['unitWeight'] as num?)?.toDouble(),
      unitDimensions: json['unitDimensions'] as String?,
    );

Map<String, dynamic> _$HierarchicalConfigToJson(_HierarchicalConfig instance) =>
    <String, dynamic>{
      'bundleCount': instance.bundleCount,
      'cartonsPerBundle': instance.cartonsPerBundle,
      'packetsPerCarton': instance.packetsPerCarton,
      'unitsPerPacket': instance.unitsPerPacket,
      'bundlePrefix': instance.bundlePrefix,
      'cartonPrefix': instance.cartonPrefix,
      'packetPrefix': instance.packetPrefix,
      'unitPrefix': instance.unitPrefix,
      'bundleCategory': instance.bundleCategory,
      'bundleWeight': instance.bundleWeight,
      'bundleDimensions': instance.bundleDimensions,
      'cartonType': instance.cartonType,
      'cartonWeight': instance.cartonWeight,
      'cartonDimensions': instance.cartonDimensions,
      'packetType': instance.packetType,
      'packetMaterial': instance.packetMaterial,
      'packetWeight': instance.packetWeight,
      'packetDimensions': instance.packetDimensions,
      'unitModel': instance.unitModel,
      'unitColor': instance.unitColor,
      'unitSize': instance.unitSize,
      'unitWeight': instance.unitWeight,
      'unitDimensions': instance.unitDimensions,
    };

_CodeGenerationResponse _$CodeGenerationResponseFromJson(
  Map<String, dynamic> json,
) => _CodeGenerationResponse(
  success: json['success'] as bool,
  batchId: json['batchId'] as String,
  codesGenerated: (json['codesGenerated'] as num).toInt(),
  totalCodesAfterGeneration: (json['totalCodesAfterGeneration'] as num).toInt(),
  remainingCodes: (json['remainingCodes'] as num).toInt(),
  generatedCodesPreview: (json['generatedCodesPreview'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  downloadUrl: json['downloadUrl'] as String?,
  qrCodesDownloadUrl: json['qrCodesDownloadUrl'] as String?,
  barcodesDownloadUrl: json['barcodesDownloadUrl'] as String?,
  generatedAt: DateTime.parse(json['generatedAt'] as String),
  estimatedBillingAmount: (json['estimatedBillingAmount'] as num?)?.toDouble(),
  error: json['error'] as String?,
);

Map<String, dynamic> _$CodeGenerationResponseToJson(
  _CodeGenerationResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'batchId': instance.batchId,
  'codesGenerated': instance.codesGenerated,
  'totalCodesAfterGeneration': instance.totalCodesAfterGeneration,
  'remainingCodes': instance.remainingCodes,
  'generatedCodesPreview': instance.generatedCodesPreview,
  'downloadUrl': instance.downloadUrl,
  'qrCodesDownloadUrl': instance.qrCodesDownloadUrl,
  'barcodesDownloadUrl': instance.barcodesDownloadUrl,
  'generatedAt': instance.generatedAt.toIso8601String(),
  'estimatedBillingAmount': instance.estimatedBillingAmount,
  'error': instance.error,
};

_CodeGenerationValidation _$CodeGenerationValidationFromJson(
  Map<String, dynamic> json,
) => _CodeGenerationValidation(
  isValid: json['isValid'] as bool,
  errors: (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList(),
  warnings: (json['warnings'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  estimatedCodeCount: (json['estimatedCodeCount'] as num?)?.toInt(),
  estimatedProcessingTime: (json['estimatedProcessingTime'] as num?)
      ?.toDouble(),
  estimatedStorageRequired: (json['estimatedStorageRequired'] as num?)
      ?.toDouble(),
  willExceedLimits: json['willExceedLimits'] as bool?,
  currentUsage: json['currentUsage'] == null
      ? null
      : SubscriptionUsage.fromJson(
          json['currentUsage'] as Map<String, dynamic>,
        ),
  proposedUsage: json['proposedUsage'] == null
      ? null
      : SubscriptionUsage.fromJson(
          json['proposedUsage'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$CodeGenerationValidationToJson(
  _CodeGenerationValidation instance,
) => <String, dynamic>{
  'isValid': instance.isValid,
  'errors': instance.errors,
  'warnings': instance.warnings,
  'estimatedCodeCount': instance.estimatedCodeCount,
  'estimatedProcessingTime': instance.estimatedProcessingTime,
  'estimatedStorageRequired': instance.estimatedStorageRequired,
  'willExceedLimits': instance.willExceedLimits,
  'currentUsage': instance.currentUsage,
  'proposedUsage': instance.proposedUsage,
};

_SubscriptionUsage _$SubscriptionUsageFromJson(Map<String, dynamic> json) =>
    _SubscriptionUsage(
      planId: json['planId'] as String,
      planName: json['planName'] as String,
      totalCodesAllowed: (json['totalCodesAllowed'] as num).toInt(),
      codesUsed: (json['codesUsed'] as num).toInt(),
      codesRemaining: (json['codesRemaining'] as num).toInt(),
      monthlyLimit: (json['monthlyLimit'] as num?)?.toInt(),
      monthlyUsage: (json['monthlyUsage'] as num?)?.toInt(),
      monthlyRemaining: (json['monthlyRemaining'] as num?)?.toInt(),
      monthlyResetDate: json['monthlyResetDate'] == null
          ? null
          : DateTime.parse(json['monthlyResetDate'] as String),
      yearlyLimit: (json['yearlyLimit'] as num?)?.toInt(),
      yearlyUsage: (json['yearlyUsage'] as num?)?.toInt(),
      yearlyRemaining: (json['yearlyRemaining'] as num?)?.toInt(),
      yearlyResetDate: json['yearlyResetDate'] == null
          ? null
          : DateTime.parse(json['yearlyResetDate'] as String),
      isActive: json['isActive'] as bool,
      expiryDate: json['expiryDate'] == null
          ? null
          : DateTime.parse(json['expiryDate'] as String),
      daysUntilExpiry: (json['daysUntilExpiry'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SubscriptionUsageToJson(_SubscriptionUsage instance) =>
    <String, dynamic>{
      'planId': instance.planId,
      'planName': instance.planName,
      'totalCodesAllowed': instance.totalCodesAllowed,
      'codesUsed': instance.codesUsed,
      'codesRemaining': instance.codesRemaining,
      'monthlyLimit': instance.monthlyLimit,
      'monthlyUsage': instance.monthlyUsage,
      'monthlyRemaining': instance.monthlyRemaining,
      'monthlyResetDate': instance.monthlyResetDate?.toIso8601String(),
      'yearlyLimit': instance.yearlyLimit,
      'yearlyUsage': instance.yearlyUsage,
      'yearlyRemaining': instance.yearlyRemaining,
      'yearlyResetDate': instance.yearlyResetDate?.toIso8601String(),
      'isActive': instance.isActive,
      'expiryDate': instance.expiryDate?.toIso8601String(),
      'daysUntilExpiry': instance.daysUntilExpiry,
    };

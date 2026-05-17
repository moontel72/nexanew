// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'code_generation_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BaseCodeGenerationRequest _$BaseCodeGenerationRequestFromJson(
  Map<String, dynamic> json,
) => _BaseCodeGenerationRequest(
  factoryId: json['factory_id'] as String,
  subscriptionPlanId: json['subscription_plan_id'] as String,
  count: (json['count'] as num).toInt(),
  prefix: json['prefix'] as String,
  startSequence: (json['start_sequence'] as num?)?.toInt() ?? 1,
  includeInternationalCodes:
      json['include_international_codes'] as bool? ?? true,
  generateQrCodes: json['generate_qr_codes'] as bool? ?? true,
  generateBarcodes: json['generate_barcodes'] as bool? ?? true,
  batchName: json['batch_name'] as String?,
  batchNotes: json['batch_notes'] as String?,
  metadata: json['metadata'] as String?,
);

Map<String, dynamic> _$BaseCodeGenerationRequestToJson(
  _BaseCodeGenerationRequest instance,
) => <String, dynamic>{
  'factory_id': instance.factoryId,
  'subscription_plan_id': instance.subscriptionPlanId,
  'count': instance.count,
  'prefix': instance.prefix,
  'start_sequence': instance.startSequence,
  'include_international_codes': instance.includeInternationalCodes,
  'generate_qr_codes': instance.generateQrCodes,
  'generate_barcodes': instance.generateBarcodes,
  'batch_name': instance.batchName,
  'batch_notes': instance.batchNotes,
  'metadata': instance.metadata,
};

_BundleCodeGenerationRequest _$BundleCodeGenerationRequestFromJson(
  Map<String, dynamic> json,
) => _BundleCodeGenerationRequest(
  factoryId: json['factory_id'] as String,
  subscriptionPlanId: json['subscription_plan_id'] as String,
  count: (json['count'] as num).toInt(),
  prefix: json['prefix'] as String,
  startSequence: (json['start_sequence'] as num?)?.toInt() ?? 1,
  includeInternationalCodes:
      json['include_international_codes'] as bool? ?? true,
  generateQrCodes: json['generate_qr_codes'] as bool? ?? true,
  generateBarcodes: json['generate_barcodes'] as bool? ?? true,
  batchName: json['batch_name'] as String?,
  batchNotes: json['batch_notes'] as String?,
  metadata: json['metadata'] as String?,
  cartonsPerBundle: (json['cartons_per_bundle'] as num).toInt(),
  bundleWeight: (json['bundle_weight'] as num?)?.toDouble(),
  bundleDimensions: json['bundle_dimensions'] as String?,
  storageLocation: json['storage_location'] as String?,
  shippingMethod: json['shipping_method'] as String?,
  expectedDeliveryDate: json['expected_delivery_date'] == null
      ? null
      : DateTime.parse(json['expected_delivery_date'] as String),
  category: json['category'] as String?,
  handlingInstructions: json['handling_instructions'] as String?,
  customsDeclarationNumber: json['customs_declaration_number'] as String?,
  insuranceValue: (json['insurance_value'] as num?)?.toDouble(),
  priority: (json['priority'] as num?)?.toInt() ?? 2,
);

Map<String, dynamic> _$BundleCodeGenerationRequestToJson(
  _BundleCodeGenerationRequest instance,
) => <String, dynamic>{
  'factory_id': instance.factoryId,
  'subscription_plan_id': instance.subscriptionPlanId,
  'count': instance.count,
  'prefix': instance.prefix,
  'start_sequence': instance.startSequence,
  'include_international_codes': instance.includeInternationalCodes,
  'generate_qr_codes': instance.generateQrCodes,
  'generate_barcodes': instance.generateBarcodes,
  'batch_name': instance.batchName,
  'batch_notes': instance.batchNotes,
  'metadata': instance.metadata,
  'cartons_per_bundle': instance.cartonsPerBundle,
  'bundle_weight': instance.bundleWeight,
  'bundle_dimensions': instance.bundleDimensions,
  'storage_location': instance.storageLocation,
  'shipping_method': instance.shippingMethod,
  'expected_delivery_date': instance.expectedDeliveryDate?.toIso8601String(),
  'category': instance.category,
  'handling_instructions': instance.handlingInstructions,
  'customs_declaration_number': instance.customsDeclarationNumber,
  'insurance_value': instance.insuranceValue,
  'priority': instance.priority,
};

_CartonCodeGenerationRequest _$CartonCodeGenerationRequestFromJson(
  Map<String, dynamic> json,
) => _CartonCodeGenerationRequest(
  factoryId: json['factory_id'] as String,
  subscriptionPlanId: json['subscription_plan_id'] as String,
  count: (json['count'] as num).toInt(),
  prefix: json['prefix'] as String,
  startSequence: (json['start_sequence'] as num?)?.toInt() ?? 1,
  includeInternationalCodes:
      json['include_international_codes'] as bool? ?? true,
  generateQrCodes: json['generate_qr_codes'] as bool? ?? true,
  generateBarcodes: json['generate_barcodes'] as bool? ?? true,
  batchName: json['batch_name'] as String?,
  batchNotes: json['batch_notes'] as String?,
  metadata: json['metadata'] as String?,
  bundleCode: json['bundle_code'] as String,
  packetsPerCarton: (json['packets_per_carton'] as num).toInt(),
  cartonWeight: (json['carton_weight'] as num?)?.toDouble(),
  cartonDimensions: json['carton_dimensions'] as String?,
  cartonType: json['carton_type'] as String?,
  grade: json['grade'] as String?,
  maxWeightCapacity: (json['max_weight_capacity'] as num?)?.toDouble(),
  temperatureRequirements: json['temperature_requirements'] as String?,
  handlingInstructions: json['handling_instructions'] as String?,
  generateCartonBarcode: json['generate_carton_barcode'] as bool? ?? true,
  generateCartonQrCode: json['generate_carton_qr_code'] as bool? ?? true,
  codeFormat: json['code_format'] as String? ?? 'qr',
);

Map<String, dynamic> _$CartonCodeGenerationRequestToJson(
  _CartonCodeGenerationRequest instance,
) => <String, dynamic>{
  'factory_id': instance.factoryId,
  'subscription_plan_id': instance.subscriptionPlanId,
  'count': instance.count,
  'prefix': instance.prefix,
  'start_sequence': instance.startSequence,
  'include_international_codes': instance.includeInternationalCodes,
  'generate_qr_codes': instance.generateQrCodes,
  'generate_barcodes': instance.generateBarcodes,
  'batch_name': instance.batchName,
  'batch_notes': instance.batchNotes,
  'metadata': instance.metadata,
  'bundle_code': instance.bundleCode,
  'packets_per_carton': instance.packetsPerCarton,
  'carton_weight': instance.cartonWeight,
  'carton_dimensions': instance.cartonDimensions,
  'carton_type': instance.cartonType,
  'grade': instance.grade,
  'max_weight_capacity': instance.maxWeightCapacity,
  'temperature_requirements': instance.temperatureRequirements,
  'handling_instructions': instance.handlingInstructions,
  'generate_carton_barcode': instance.generateCartonBarcode,
  'generate_carton_qr_code': instance.generateCartonQrCode,
  'code_format': instance.codeFormat,
};

_PacketCodeGenerationRequest _$PacketCodeGenerationRequestFromJson(
  Map<String, dynamic> json,
) => _PacketCodeGenerationRequest(
  factoryId: json['factory_id'] as String,
  subscriptionPlanId: json['subscription_plan_id'] as String,
  count: (json['count'] as num).toInt(),
  prefix: json['prefix'] as String,
  startSequence: (json['start_sequence'] as num?)?.toInt() ?? 1,
  includeInternationalCodes:
      json['include_international_codes'] as bool? ?? true,
  generateQrCodes: json['generate_qr_codes'] as bool? ?? true,
  generateBarcodes: json['generate_barcodes'] as bool? ?? true,
  batchName: json['batch_name'] as String?,
  batchNotes: json['batch_notes'] as String?,
  metadata: json['metadata'] as String?,
  cartonCode: json['carton_code'] as String,
  unitsPerPacket: (json['units_per_packet'] as num).toInt(),
  packetWeight: (json['packet_weight'] as num?)?.toDouble(),
  packetDimensions: json['packet_dimensions'] as String?,
  packetType: json['packet_type'] as String?,
  material: json['material'] as String?,
  sealingMethod: json['sealing_method'] as String?,
  includeTamperEvidence: json['include_tamper_evidence'] as bool? ?? false,
  includeChildSafety: json['include_child_safety'] as bool? ?? false,
  includeInstructions: json['include_instructions'] as bool? ?? true,
  color: json['color'] as String?,
  printingDetails: json['printing_details'] as String?,
  generatePacketBarcode: json['generate_packet_barcode'] as bool? ?? true,
  generatePacketQrCode: json['generate_packet_qr_code'] as bool? ?? true,
  codeFormat: json['code_format'] as String? ?? 'qr',
);

Map<String, dynamic> _$PacketCodeGenerationRequestToJson(
  _PacketCodeGenerationRequest instance,
) => <String, dynamic>{
  'factory_id': instance.factoryId,
  'subscription_plan_id': instance.subscriptionPlanId,
  'count': instance.count,
  'prefix': instance.prefix,
  'start_sequence': instance.startSequence,
  'include_international_codes': instance.includeInternationalCodes,
  'generate_qr_codes': instance.generateQrCodes,
  'generate_barcodes': instance.generateBarcodes,
  'batch_name': instance.batchName,
  'batch_notes': instance.batchNotes,
  'metadata': instance.metadata,
  'carton_code': instance.cartonCode,
  'units_per_packet': instance.unitsPerPacket,
  'packet_weight': instance.packetWeight,
  'packet_dimensions': instance.packetDimensions,
  'packet_type': instance.packetType,
  'material': instance.material,
  'sealing_method': instance.sealingMethod,
  'include_tamper_evidence': instance.includeTamperEvidence,
  'include_child_safety': instance.includeChildSafety,
  'include_instructions': instance.includeInstructions,
  'color': instance.color,
  'printing_details': instance.printingDetails,
  'generate_packet_barcode': instance.generatePacketBarcode,
  'generate_packet_qr_code': instance.generatePacketQrCode,
  'code_format': instance.codeFormat,
};

_UnitCodeGenerationRequest _$UnitCodeGenerationRequestFromJson(
  Map<String, dynamic> json,
) => _UnitCodeGenerationRequest(
  factoryId: json['factory_id'] as String,
  subscriptionPlanId: json['subscription_plan_id'] as String,
  count: (json['count'] as num).toInt(),
  prefix: json['prefix'] as String,
  startSequence: (json['start_sequence'] as num?)?.toInt() ?? 1,
  includeInternationalCodes:
      json['include_international_codes'] as bool? ?? false,
  generateQrCodes: json['generate_qr_codes'] as bool? ?? true,
  generateBarcodes: json['generate_barcodes'] as bool? ?? true,
  batchName: json['batch_name'] as String?,
  batchNotes: json['batch_notes'] as String?,
  metadata: json['metadata'] as String?,
  packetCode: json['packet_code'] as String,
  authenticationAlgorithm:
      json['authentication_algorithm'] as String? ?? 'secure_random',
  authenticationCodeLength:
      (json['authentication_code_length'] as num?)?.toInt() ?? 16,
  includeMasterCodes: json['include_master_codes'] as bool? ?? true,
  unitsPerMasterCode: (json['units_per_master_code'] as num?)?.toInt() ?? 100,
  model: json['model'] as String?,
  color: json['color'] as String?,
  size: json['size'] as String?,
  unitWeight: (json['unit_weight'] as num?)?.toDouble(),
  unitDimensions: json['unit_dimensions'] as String?,
  condition: json['condition'] as String? ?? 'New',
  grade: json['grade'] as String?,
  includeWarrantyCard: json['include_warranty_card'] as bool? ?? true,
  includeUserManual: json['include_user_manual'] as bool? ?? true,
  includeAccessories: json['include_accessories'] as bool? ?? false,
  accessoriesList: json['accessories_list'] as String?,
  specialFeatures: json['special_features'] as String?,
  safetyCertifications: json['safety_certifications'] as String?,
  complianceStandards: json['compliance_standards'] as String?,
  codeFormat: json['code_format'] as String? ?? 'qr',
);

Map<String, dynamic> _$UnitCodeGenerationRequestToJson(
  _UnitCodeGenerationRequest instance,
) => <String, dynamic>{
  'factory_id': instance.factoryId,
  'subscription_plan_id': instance.subscriptionPlanId,
  'count': instance.count,
  'prefix': instance.prefix,
  'start_sequence': instance.startSequence,
  'include_international_codes': instance.includeInternationalCodes,
  'generate_qr_codes': instance.generateQrCodes,
  'generate_barcodes': instance.generateBarcodes,
  'batch_name': instance.batchName,
  'batch_notes': instance.batchNotes,
  'metadata': instance.metadata,
  'packet_code': instance.packetCode,
  'authentication_algorithm': instance.authenticationAlgorithm,
  'authentication_code_length': instance.authenticationCodeLength,
  'include_master_codes': instance.includeMasterCodes,
  'units_per_master_code': instance.unitsPerMasterCode,
  'model': instance.model,
  'color': instance.color,
  'size': instance.size,
  'unit_weight': instance.unitWeight,
  'unit_dimensions': instance.unitDimensions,
  'condition': instance.condition,
  'grade': instance.grade,
  'include_warranty_card': instance.includeWarrantyCard,
  'include_user_manual': instance.includeUserManual,
  'include_accessories': instance.includeAccessories,
  'accessories_list': instance.accessoriesList,
  'special_features': instance.specialFeatures,
  'safety_certifications': instance.safetyCertifications,
  'compliance_standards': instance.complianceStandards,
  'code_format': instance.codeFormat,
};

_BatchCodeGenerationRequest _$BatchCodeGenerationRequestFromJson(
  Map<String, dynamic> json,
) => _BatchCodeGenerationRequest(
  factoryId: json['factory_id'] as String,
  subscriptionPlanId: json['subscription_plan_id'] as String,
  batchName: json['batch_name'] as String,
  batchDescription: json['batch_description'] as String?,
  bundleRequest: json['bundle_request'] == null
      ? null
      : BundleCodeGenerationRequest.fromJson(
          json['bundle_request'] as Map<String, dynamic>,
        ),
  cartonRequest: json['carton_request'] == null
      ? null
      : CartonCodeGenerationRequest.fromJson(
          json['carton_request'] as Map<String, dynamic>,
        ),
  packetRequest: json['packet_request'] == null
      ? null
      : PacketCodeGenerationRequest.fromJson(
          json['packet_request'] as Map<String, dynamic>,
        ),
  unitRequest: json['unit_request'] == null
      ? null
      : UnitCodeGenerationRequest.fromJson(
          json['unit_request'] as Map<String, dynamic>,
        ),
  generateHierarchical: json['generate_hierarchical'] as bool? ?? false,
  hierarchicalConfig: json['hierarchical_config'] == null
      ? null
      : HierarchicalConfig.fromJson(
          json['hierarchical_config'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$BatchCodeGenerationRequestToJson(
  _BatchCodeGenerationRequest instance,
) => <String, dynamic>{
  'factory_id': instance.factoryId,
  'subscription_plan_id': instance.subscriptionPlanId,
  'batch_name': instance.batchName,
  'batch_description': instance.batchDescription,
  'bundle_request': instance.bundleRequest?.toJson(),
  'carton_request': instance.cartonRequest?.toJson(),
  'packet_request': instance.packetRequest?.toJson(),
  'unit_request': instance.unitRequest?.toJson(),
  'generate_hierarchical': instance.generateHierarchical,
  'hierarchical_config': instance.hierarchicalConfig?.toJson(),
};

_HierarchicalConfig _$HierarchicalConfigFromJson(Map<String, dynamic> json) =>
    _HierarchicalConfig(
      bundleCount: (json['bundle_count'] as num).toInt(),
      cartonsPerBundle: (json['cartons_per_bundle'] as num).toInt(),
      packetsPerCarton: (json['packets_per_carton'] as num).toInt(),
      unitsPerPacket: (json['units_per_packet'] as num).toInt(),
      bundlePrefix: json['bundle_prefix'] as String,
      cartonPrefix: json['carton_prefix'] as String,
      packetPrefix: json['packet_prefix'] as String,
      unitPrefix: json['unit_prefix'] as String,
      bundleCategory: json['bundle_category'] as String?,
      bundleWeight: (json['bundle_weight'] as num?)?.toDouble(),
      bundleDimensions: json['bundle_dimensions'] as String?,
      cartonType: json['carton_type'] as String?,
      cartonWeight: (json['carton_weight'] as num?)?.toDouble(),
      cartonDimensions: json['carton_dimensions'] as String?,
      packetType: json['packet_type'] as String?,
      packetMaterial: json['packet_material'] as String?,
      packetWeight: (json['packet_weight'] as num?)?.toDouble(),
      packetDimensions: json['packet_dimensions'] as String?,
      unitModel: json['unit_model'] as String?,
      unitColor: json['unit_color'] as String?,
      unitSize: json['unit_size'] as String?,
      unitWeight: (json['unit_weight'] as num?)?.toDouble(),
      unitDimensions: json['unit_dimensions'] as String?,
    );

Map<String, dynamic> _$HierarchicalConfigToJson(_HierarchicalConfig instance) =>
    <String, dynamic>{
      'bundle_count': instance.bundleCount,
      'cartons_per_bundle': instance.cartonsPerBundle,
      'packets_per_carton': instance.packetsPerCarton,
      'units_per_packet': instance.unitsPerPacket,
      'bundle_prefix': instance.bundlePrefix,
      'carton_prefix': instance.cartonPrefix,
      'packet_prefix': instance.packetPrefix,
      'unit_prefix': instance.unitPrefix,
      'bundle_category': instance.bundleCategory,
      'bundle_weight': instance.bundleWeight,
      'bundle_dimensions': instance.bundleDimensions,
      'carton_type': instance.cartonType,
      'carton_weight': instance.cartonWeight,
      'carton_dimensions': instance.cartonDimensions,
      'packet_type': instance.packetType,
      'packet_material': instance.packetMaterial,
      'packet_weight': instance.packetWeight,
      'packet_dimensions': instance.packetDimensions,
      'unit_model': instance.unitModel,
      'unit_color': instance.unitColor,
      'unit_size': instance.unitSize,
      'unit_weight': instance.unitWeight,
      'unit_dimensions': instance.unitDimensions,
    };

_CodeGenerationResponse _$CodeGenerationResponseFromJson(
  Map<String, dynamic> json,
) => _CodeGenerationResponse(
  success: json['success'] as bool,
  batchId: json['batch_id'] as String,
  codesGenerated: (json['codes_generated'] as num).toInt(),
  totalCodesAfterGeneration: (json['total_codes_after_generation'] as num)
      .toInt(),
  remainingCodes: (json['remaining_codes'] as num).toInt(),
  generatedCodesPreview: (json['generated_codes_preview'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  downloadUrl: json['download_url'] as String?,
  qrCodesDownloadUrl: json['qr_codes_download_url'] as String?,
  barcodesDownloadUrl: json['barcodes_download_url'] as String?,
  generatedAt: DateTime.parse(json['generated_at'] as String),
  estimatedBillingAmount: (json['estimated_billing_amount'] as num?)
      ?.toDouble(),
  error: json['error'] as String?,
);

Map<String, dynamic> _$CodeGenerationResponseToJson(
  _CodeGenerationResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'batch_id': instance.batchId,
  'codes_generated': instance.codesGenerated,
  'total_codes_after_generation': instance.totalCodesAfterGeneration,
  'remaining_codes': instance.remainingCodes,
  'generated_codes_preview': instance.generatedCodesPreview,
  'download_url': instance.downloadUrl,
  'qr_codes_download_url': instance.qrCodesDownloadUrl,
  'barcodes_download_url': instance.barcodesDownloadUrl,
  'generated_at': instance.generatedAt.toIso8601String(),
  'estimated_billing_amount': instance.estimatedBillingAmount,
  'error': instance.error,
};

_CodeGenerationValidation _$CodeGenerationValidationFromJson(
  Map<String, dynamic> json,
) => _CodeGenerationValidation(
  isValid: json['is_valid'] as bool,
  errors: (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList(),
  warnings: (json['warnings'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  estimatedCodeCount: (json['estimated_code_count'] as num?)?.toInt(),
  estimatedProcessingTime: (json['estimated_processing_time'] as num?)
      ?.toDouble(),
  estimatedStorageRequired: (json['estimated_storage_required'] as num?)
      ?.toDouble(),
  willExceedLimits: json['will_exceed_limits'] as bool?,
  currentUsage: json['current_usage'] == null
      ? null
      : SubscriptionUsage.fromJson(
          json['current_usage'] as Map<String, dynamic>,
        ),
  proposedUsage: json['proposed_usage'] == null
      ? null
      : SubscriptionUsage.fromJson(
          json['proposed_usage'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$CodeGenerationValidationToJson(
  _CodeGenerationValidation instance,
) => <String, dynamic>{
  'is_valid': instance.isValid,
  'errors': instance.errors,
  'warnings': instance.warnings,
  'estimated_code_count': instance.estimatedCodeCount,
  'estimated_processing_time': instance.estimatedProcessingTime,
  'estimated_storage_required': instance.estimatedStorageRequired,
  'will_exceed_limits': instance.willExceedLimits,
  'current_usage': instance.currentUsage?.toJson(),
  'proposed_usage': instance.proposedUsage?.toJson(),
};

_SubscriptionUsage _$SubscriptionUsageFromJson(Map<String, dynamic> json) =>
    _SubscriptionUsage(
      planId: json['plan_id'] as String,
      planName: json['plan_name'] as String,
      totalCodesAllowed: (json['total_codes_allowed'] as num).toInt(),
      codesUsed: (json['codes_used'] as num).toInt(),
      codesRemaining: (json['codes_remaining'] as num).toInt(),
      monthlyLimit: (json['monthly_limit'] as num?)?.toInt(),
      monthlyUsage: (json['monthly_usage'] as num?)?.toInt(),
      monthlyRemaining: (json['monthly_remaining'] as num?)?.toInt(),
      monthlyResetDate: json['monthly_reset_date'] == null
          ? null
          : DateTime.parse(json['monthly_reset_date'] as String),
      yearlyLimit: (json['yearly_limit'] as num?)?.toInt(),
      yearlyUsage: (json['yearly_usage'] as num?)?.toInt(),
      yearlyRemaining: (json['yearly_remaining'] as num?)?.toInt(),
      yearlyResetDate: json['yearly_reset_date'] == null
          ? null
          : DateTime.parse(json['yearly_reset_date'] as String),
      isActive: json['is_active'] as bool,
      expiryDate: json['expiry_date'] == null
          ? null
          : DateTime.parse(json['expiry_date'] as String),
      daysUntilExpiry: (json['days_until_expiry'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SubscriptionUsageToJson(_SubscriptionUsage instance) =>
    <String, dynamic>{
      'plan_id': instance.planId,
      'plan_name': instance.planName,
      'total_codes_allowed': instance.totalCodesAllowed,
      'codes_used': instance.codesUsed,
      'codes_remaining': instance.codesRemaining,
      'monthly_limit': instance.monthlyLimit,
      'monthly_usage': instance.monthlyUsage,
      'monthly_remaining': instance.monthlyRemaining,
      'monthly_reset_date': instance.monthlyResetDate?.toIso8601String(),
      'yearly_limit': instance.yearlyLimit,
      'yearly_usage': instance.yearlyUsage,
      'yearly_remaining': instance.yearlyRemaining,
      'yearly_reset_date': instance.yearlyResetDate?.toIso8601String(),
      'is_active': instance.isActive,
      'expiry_date': instance.expiryDate?.toIso8601String(),
      'days_until_expiry': instance.daysUntilExpiry,
    };

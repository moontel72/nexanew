import 'package:freezed_annotation/freezed_annotation.dart';

part 'code_generation_request.freezed.dart';
part 'code_generation_request.g.dart';

/// Base Code Generation Request
/// Contains common parameters for all code types
@freezed
abstract class BaseCodeGenerationRequest with _$BaseCodeGenerationRequest {
  const factory BaseCodeGenerationRequest({
    /// Factory ID that owns these codes
    required String factoryId,

    /// Subscription plan ID for billing
    required String subscriptionPlanId,

    /// Number of codes to generate
    required int count,

    /// Code prefix (e.g., "A", "YY", "YBZ", "TSFG")
    required String prefix,

    /// Starting sequence number
    @Default(1) int startSequence,

    /// Should include international standard codes?
    @Default(true) bool includeInternationalCodes,

    /// Should generate QR codes?
    @Default(true) bool generateQrCodes,

    /// Should generate barcodes?
    @Default(true) bool generateBarcodes,

    /// Batch name/description
    String? batchName,

    /// Batch notes
    String? batchNotes,

    /// Metadata for additional information (JSON string)
    String? metadata,
  }) = _BaseCodeGenerationRequest;

  factory BaseCodeGenerationRequest.fromJson(Map<String, dynamic> json) =>
      _$BaseCodeGenerationRequestFromJson(json);
}

/// Bundle Code Generation Request
@freezed
abstract class BundleCodeGenerationRequest with _$BundleCodeGenerationRequest {
  const factory BundleCodeGenerationRequest({
    /// Base request parameters
    required String factoryId,
    required String subscriptionPlanId,
    required int count,
    required String prefix,
    @Default(1) int startSequence,
    @Default(true) bool includeInternationalCodes,
    @Default(true) bool generateQrCodes,
    @Default(true) bool generateBarcodes,
    String? batchName,
    String? batchNotes,
    String? metadata,

    /// Bundle-specific parameters
    /// Number of cartons per bundle
    required int cartonsPerBundle,

    /// Bundle weight in kilograms (optional)
    double? bundleWeight,

    /// Bundle dimensions (length x width x height in cm)
    String? bundleDimensions,

    /// Storage location
    String? storageLocation,

    /// Shipping method
    String? shippingMethod,

    /// Expected delivery date
    DateTime? expectedDeliveryDate,

    /// Bundle category
    String? category,

    /// Handling instructions
    String? handlingInstructions,

    /// Customs declaration number
    String? customsDeclarationNumber,

    /// Insurance value
    double? insuranceValue,

    /// Priority (1=High, 2=Medium, 3=Low)
    @Default(2) int priority,
  }) = _BundleCodeGenerationRequest;

  factory BundleCodeGenerationRequest.fromJson(Map<String, dynamic> json) =>
      _$BundleCodeGenerationRequestFromJson(json);
}

/// Carton Code Generation Request
@freezed
abstract class CartonCodeGenerationRequest with _$CartonCodeGenerationRequest {
  const factory CartonCodeGenerationRequest({
    /// Base request parameters
    required String factoryId,
    required String subscriptionPlanId,
    required int count,
    required String prefix,
    @Default(1) int startSequence,
    @Default(true) bool includeInternationalCodes,
    @Default(true) bool generateQrCodes,
    @Default(true) bool generateBarcodes,
    String? batchName,
    String? batchNotes,
    String? metadata,

    /// Carton-specific parameters
    /// Bundle code that will contain these cartons
    required String bundleCode,

    /// Number of packets per carton
    required int packetsPerCarton,

    /// Carton weight in kilograms (optional)
    double? cartonWeight,

    /// Carton dimensions (length x width x height in cm)
    String? cartonDimensions,

    /// Carton type (e.g., "Corrugated", "Cardboard", "Plastic")
    String? cartonType,

    /// Carton grade/quality
    String? grade,

    /// Maximum weight capacity
    double? maxWeightCapacity,

    /// Temperature requirements
    String? temperatureRequirements,

    /// Handling instructions
    String? handlingInstructions,

    /// Should generate separate carton barcode?
    @Default(true) bool generateCartonBarcode,

    /// Should generate separate carton QR code?
    @Default(true) bool generateCartonQrCode,

    /// Code format type (itf14, gs1_128, code128_industrial, qr, datamatrix, code128_label)
    @Default('qr') String codeFormat,
  }) = _CartonCodeGenerationRequest;

  factory CartonCodeGenerationRequest.fromJson(Map<String, dynamic> json) =>
      _$CartonCodeGenerationRequestFromJson(json);
}

/// Packet Code Generation Request
@freezed
abstract class PacketCodeGenerationRequest with _$PacketCodeGenerationRequest {
  const factory PacketCodeGenerationRequest({
    /// Base request parameters
    required String factoryId,
    required String subscriptionPlanId,
    required int count,
    required String prefix,
    @Default(1) int startSequence,
    @Default(true) bool includeInternationalCodes,
    @Default(true) bool generateQrCodes,
    @Default(true) bool generateBarcodes,
    String? batchName,
    String? batchNotes,
    String? metadata,

    /// Packet-specific parameters
    /// Carton code that will contain these packets
    required String cartonCode,

    /// Number of units per packet
    required int unitsPerPacket,

    /// Packet weight in grams (optional)
    double? packetWeight,

    /// Packet dimensions (length x width x height in cm)
    String? packetDimensions,

    /// Packet type (e.g., "Blister", "Box", "Pouch", "Bottle")
    String? packetType,

    /// Packet material (e.g., "Plastic", "Paper", "Aluminum")
    String? material,

    /// Sealing method (e.g., "Heat Seal", "Adhesive", "Clip")
    String? sealingMethod,

    /// Should include tamper evidence?
    @Default(false) bool includeTamperEvidence,

    /// Should include child safety features?
    @Default(false) bool includeChildSafety,

    /// Should include instructions?
    @Default(true) bool includeInstructions,

    /// Packet color
    String? color,

    /// Printing details
    String? printingDetails,

    /// Should generate separate packet barcode?
    @Default(true) bool generatePacketBarcode,

    /// Should generate separate packet QR code?
    @Default(true) bool generatePacketQrCode,
  }) = _PacketCodeGenerationRequest;

  factory PacketCodeGenerationRequest.fromJson(Map<String, dynamic> json) =>
      _$PacketCodeGenerationRequestFromJson(json);
}

/// Unit Code Generation Request
@freezed
abstract class UnitCodeGenerationRequest with _$UnitCodeGenerationRequest {
  const factory UnitCodeGenerationRequest({
    /// Base request parameters
    required String factoryId,
    required String subscriptionPlanId,
    required int count,
    required String prefix,
    @Default(1) int startSequence,
    @Default(false) bool includeInternationalCodes, // Usually false for units
    @Default(true) bool generateQrCodes,
    @Default(true) bool generateBarcodes,
    String? batchName,
    String? batchNotes,
    String? metadata,

    /// Unit-specific parameters
    /// Packet code that will contain these units
    required String packetCode,

    /// Authentication code algorithm
    @Default('secure_random') String authenticationAlgorithm,

    /// Authentication code length
    @Default(16) int authenticationCodeLength,

    /// Should include master authentication codes?
    @Default(true) bool includeMasterCodes,

    /// Number of units per master code
    @Default(100) int unitsPerMasterCode,

    /// Unit model/variant
    String? model,

    /// Unit color
    String? color,

    /// Unit size
    String? size,

    /// Unit weight in grams
    double? unitWeight,

    /// Unit dimensions (length x width x height in cm)
    String? unitDimensions,

    /// Unit condition
    @Default('New') String condition,

    /// Unit grade/quality
    String? grade,

    /// Should include warranty card?
    @Default(true) bool includeWarrantyCard,

    /// Should include user manual?
    @Default(true) bool includeUserManual,

    /// Should include accessories?
    @Default(false) bool includeAccessories,

    /// Accessories list (JSON string)
    String? accessoriesList,

    /// Special features (JSON string)
    String? specialFeatures,

    /// Safety certifications (JSON string)
    String? safetyCertifications,

    /// Compliance standards (JSON string)
    String? complianceStandards,
  }) = _UnitCodeGenerationRequest;

  factory UnitCodeGenerationRequest.fromJson(Map<String, dynamic> json) =>
      _$UnitCodeGenerationRequestFromJson(json);
}

/// Batch Code Generation Request
/// For generating multiple code types in a single batch
@freezed
abstract class BatchCodeGenerationRequest with _$BatchCodeGenerationRequest {
  const factory BatchCodeGenerationRequest({
    /// Factory ID
    required String factoryId,

    /// Subscription plan ID
    required String subscriptionPlanId,

    /// Batch name
    required String batchName,

    /// Batch description
    String? batchDescription,

    /// Bundle generation request (optional)
    BundleCodeGenerationRequest? bundleRequest,

    /// Carton generation request (optional)
    CartonCodeGenerationRequest? cartonRequest,

    /// Packet generation request (optional)
    PacketCodeGenerationRequest? packetRequest,

    /// Unit generation request (optional)
    UnitCodeGenerationRequest? unitRequest,

    /// Should generate hierarchical codes?
    /// If true, will generate codes in hierarchy: Bundle -> Carton -> Packet -> Unit
    @Default(false) bool generateHierarchical,

    /// Hierarchical configuration
    /// Only used if generateHierarchical is true
    HierarchicalConfig? hierarchicalConfig,
  }) = _BatchCodeGenerationRequest;

  factory BatchCodeGenerationRequest.fromJson(Map<String, dynamic> json) =>
      _$BatchCodeGenerationRequestFromJson(json);
}

/// Hierarchical Configuration
/// Defines the hierarchy for code generation
@freezed
abstract class HierarchicalConfig with _$HierarchicalConfig {
  const factory HierarchicalConfig({
    /// Number of bundles to generate
    required int bundleCount,

    /// Number of cartons per bundle
    required int cartonsPerBundle,

    /// Number of packets per carton
    required int packetsPerCarton,

    /// Number of units per packet
    required int unitsPerPacket,

    /// Bundle prefix
    required String bundlePrefix,

    /// Carton prefix
    required String cartonPrefix,

    /// Packet prefix
    required String packetPrefix,

    /// Unit prefix
    required String unitPrefix,

    /// Bundle-specific parameters
    String? bundleCategory,
    double? bundleWeight,
    String? bundleDimensions,

    /// Carton-specific parameters
    String? cartonType,
    double? cartonWeight,
    String? cartonDimensions,

    /// Packet-specific parameters
    String? packetType,
    String? packetMaterial,
    double? packetWeight,
    String? packetDimensions,

    /// Unit-specific parameters
    String? unitModel,
    String? unitColor,
    String? unitSize,
    double? unitWeight,
    String? unitDimensions,
  }) = _HierarchicalConfig;

  factory HierarchicalConfig.fromJson(Map<String, dynamic> json) =>
      _$HierarchicalConfigFromJson(json);
}

/// Code Generation Response
/// Response from code generation API
@freezed
abstract class CodeGenerationResponse with _$CodeGenerationResponse {
  const factory CodeGenerationResponse({
    /// Generation success status
    required bool success,

    /// Generated batch ID
    required String batchId,

    /// Number of codes generated
    required int codesGenerated,

    /// Total codes in subscription after this generation
    required int totalCodesAfterGeneration,

    /// Remaining codes in subscription
    required int remainingCodes,

    /// Generated codes (first 100 for preview)
    List<String>? generatedCodesPreview,

    /// Download URL for full code list
    String? downloadUrl,

    /// QR codes download URL
    String? qrCodesDownloadUrl,

    /// Barcodes download URL
    String? barcodesDownloadUrl,

    /// Generation timestamp
    required DateTime generatedAt,

    /// Estimated billing amount
    double? estimatedBillingAmount,

    /// Error message if generation failed
    String? error,
  }) = _CodeGenerationResponse;

  factory CodeGenerationResponse.fromJson(Map<String, dynamic> json) =>
      _$CodeGenerationResponseFromJson(json);
}

/// Code Generation Validation Result
/// Used to validate code generation requests before processing
@freezed
abstract class CodeGenerationValidation with _$CodeGenerationValidation {
  const factory CodeGenerationValidation({
    /// Is request valid?
    required bool isValid,

    /// Validation errors
    List<String>? errors,

    /// Validation warnings
    List<String>? warnings,

    /// Estimated code count
    int? estimatedCodeCount,

    /// Estimated processing time in seconds
    double? estimatedProcessingTime,

    /// Estimated storage required in KB
    double? estimatedStorageRequired,

    /// Will exceed subscription limits?
    bool? willExceedLimits,

    /// Current subscription usage
    SubscriptionUsage? currentUsage,

    /// Proposed subscription usage after generation
    SubscriptionUsage? proposedUsage,
  }) = _CodeGenerationValidation;

  factory CodeGenerationValidation.fromJson(Map<String, dynamic> json) =>
      _$CodeGenerationValidationFromJson(json);
}

/// Subscription Usage Information
@freezed
abstract class SubscriptionUsage with _$SubscriptionUsage {
  const factory SubscriptionUsage({
    /// Subscription plan ID
    required String planId,

    /// Plan name
    required String planName,

    /// Total codes allowed
    required int totalCodesAllowed,

    /// Codes used so far
    required int codesUsed,

    /// Codes remaining
    required int codesRemaining,

    /// Monthly limit
    int? monthlyLimit,

    /// Monthly usage
    int? monthlyUsage,

    /// Monthly remaining
    int? monthlyRemaining,

    /// Reset date for monthly limits
    DateTime? monthlyResetDate,

    /// Yearly limit
    int? yearlyLimit,

    /// Yearly usage
    int? yearlyUsage,

    /// Yearly remaining
    int? yearlyRemaining,

    /// Reset date for yearly limits
    DateTime? yearlyResetDate,

    /// Is subscription active?
    required bool isActive,

    /// Expiry date
    DateTime? expiryDate,

    /// Days until expiry
    int? daysUntilExpiry,
  }) = _SubscriptionUsage;

  factory SubscriptionUsage.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionUsageFromJson(json);
}

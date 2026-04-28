import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'base_code_model.dart';

part 'bundle_code_model.freezed.dart';
part 'bundle_code_model.g.dart';

DateTime _dateTimeFromJson(dynamic value) {
  if (value == null) {
    return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }
  if (value is DateTime) return value;
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
  }
  final text = value.toString();
  if (text.isEmpty) {
    return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }
  return DateTime.parse(text);
}

String _dateTimeToJson(DateTime value) => value.toIso8601String();

/// Bundle Code Model
/// Specialized model for Bundle Codes with bundle-specific properties
@freezed
@HiveType(typeId: 103)
abstract class BundleCodeModel with _$BundleCodeModel {
  const factory BundleCodeModel({
    /// Base code properties
    @HiveField(0) required String id,
    @HiveField(1) required String code,
    @HiveField(2) @Default(CodeType.bundle) CodeType type,
    @HiveField(3) @Default(CodeStatus.generated) CodeStatus status,
    @HiveField(4) @Default('') String factoryId,
    @HiveField(5) @Default('') String subscriptionPlanId,
    @HiveField(6) @Default('') String storeKeeperCode,
    @HiveField(7) @Default('') String internationalCode,
    @HiveField(8) @Default('') String batchId,
    @HiveField(9)
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    required DateTime generatedAt,
    @HiveField(10) DateTime? linkedAt,
    @HiveField(11) DateTime? publishedAt,
    @HiveField(12) DateTime? deactivatedAt,
    @HiveField(13) String? productId,
    @HiveField(14) String? productBatchNumber,
    @HiveField(15) DateTime? manufacturingDate,
    @HiveField(16) DateTime? expiryDate,
    @HiveField(17) int? warrantyMonths,
    @HiveField(18) String? qrCodeData,
    @HiveField(19) String? barcodeData,
    @HiveField(20) String? metadata,
    @HiveField(21) @Default(1) int version,
    @HiveField(22)
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    required DateTime createdAt,
    @HiveField(23)
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    required DateTime updatedAt,
    @HiveField(24) @Default(false) bool isDeleted,

    /// Bundle-specific properties
    /// Number of cartons in this bundle
    @HiveField(25) @Default(0) int cartonCount,

    /// List of carton codes contained in this bundle
    @HiveField(26) @Default(<String>[]) List<String> cartonCodes,

    /// Bundle weight in kilograms
    @HiveField(27) double? weight,

    /// Bundle dimensions (length x width x height in cm)
    @HiveField(28) String? dimensions,

    /// Storage location in warehouse
    @HiveField(29) String? storageLocation,

    /// Shipping method for this bundle
    @HiveField(30) String? shippingMethod,

    /// Expected delivery date
    @HiveField(31) DateTime? expectedDeliveryDate,

    /// Actual delivery date
    @HiveField(32) DateTime? actualDeliveryDate,

    /// Bundle sequence number (e.g., 1, 2, 3...)
    @HiveField(33) @Default(0) int sequenceNumber,

    /// Total units in this bundle (calculated: cartonCount * packetsPerCarton * unitsPerPacket)
    @HiveField(34) @Default(0) int totalUnits,

    /// Bundle category (e.g., "Electronics", "Food", "Medical")
    @HiveField(35) String? category,

    /// Special handling instructions
    @HiveField(36) String? handlingInstructions,

    /// Customs declaration number (for international shipping)
    @HiveField(37) String? customsDeclarationNumber,

    /// Insurance value of the bundle
    @HiveField(38) double? insuranceValue,

    /// Bundle priority (1=High, 2=Medium, 3=Low)
    @HiveField(39) @Default(2) int priority,
  }) = _BundleCodeModel;

  factory BundleCodeModel.fromJson(Map<String, dynamic> json) =>
      _$BundleCodeModelFromJson(json);

  const BundleCodeModel._();

  /// Check if code can be deleted
  bool get canDelete => status == CodeStatus.generated;

  /// Check if code can be linked to a product
  bool get canLink =>
      status == CodeStatus.generated || status == CodeStatus.linked;

  /// Check if code can be published
  bool get canPublish =>
      status == CodeStatus.generated || status == CodeStatus.linked;

  /// Check if code can be deactivated
  bool get canDeactivate => status == CodeStatus.published;

  /// Get display name for code status
  String get statusDisplayName {
    switch (status) {
      case CodeStatus.generated:
        return 'Generated';
      case CodeStatus.linked:
        return 'Linked';
      case CodeStatus.published:
        return 'Published';
      case CodeStatus.deactivated:
        return 'Deactivated';
      case CodeStatus.expired:
        return 'Expired';
    }
  }

  /// Create a BundleCodeModel from BaseCodeModel
  factory BundleCodeModel.fromBaseCodeModel(
    BaseCodeModel baseCode, {
    required int cartonCount,
    required List<String> cartonCodes,
    required int sequenceNumber,
    required int totalUnits,
    double? weight,
    String? dimensions,
    String? storageLocation,
    String? shippingMethod,
    DateTime? expectedDeliveryDate,
    DateTime? actualDeliveryDate,
    String? category,
    String? handlingInstructions,
    String? customsDeclarationNumber,
    double? insuranceValue,
    int priority = 2,
  }) {
    return BundleCodeModel(
      id: baseCode.id,
      code: baseCode.code,
      type: baseCode.type,
      status: baseCode.status,
      factoryId: baseCode.factoryId,
      subscriptionPlanId: baseCode.subscriptionPlanId,
      storeKeeperCode: baseCode.storeKeeperCode,
      internationalCode: baseCode.internationalCode ?? '',
      batchId: baseCode.batchId,
      generatedAt: baseCode.generatedAt,
      linkedAt: baseCode.linkedAt,
      publishedAt: baseCode.publishedAt,
      deactivatedAt: baseCode.deactivatedAt,
      productId: baseCode.productId,
      productBatchNumber: baseCode.productBatchNumber,
      manufacturingDate: baseCode.manufacturingDate,
      expiryDate: baseCode.expiryDate,
      warrantyMonths: baseCode.warrantyMonths,
      qrCodeData: baseCode.qrCodeData,
      barcodeData: baseCode.barcodeData,
      metadata: baseCode.metadata,
      version: baseCode.version,
      createdAt: baseCode.createdAt,
      updatedAt: baseCode.updatedAt,
      isDeleted: baseCode.isDeleted,
      cartonCount: cartonCount,
      cartonCodes: cartonCodes,
      sequenceNumber: sequenceNumber,
      totalUnits: totalUnits,
      weight: weight,
      dimensions: dimensions,
      storageLocation: storageLocation,
      shippingMethod: shippingMethod,
      expectedDeliveryDate: expectedDeliveryDate,
      actualDeliveryDate: actualDeliveryDate,
      category: category,
      handlingInstructions: handlingInstructions,
      customsDeclarationNumber: customsDeclarationNumber,
      insuranceValue: insuranceValue,
      priority: priority,
    );
  }

  /// Convert to BaseCodeModel
  BaseCodeModel toBaseCodeModel() {
    return BaseCodeModel(
      id: id,
      code: code,
      type: type,
      status: status,
      factoryId: factoryId,
      subscriptionPlanId: subscriptionPlanId,
      storeKeeperCode: storeKeeperCode,
      internationalCode: internationalCode,
      batchId: batchId,
      generatedAt: generatedAt,
      linkedAt: linkedAt,
      publishedAt: publishedAt,
      deactivatedAt: deactivatedAt,
      productId: productId,
      productBatchNumber: productBatchNumber,
      manufacturingDate: manufacturingDate,
      expiryDate: expiryDate,
      warrantyMonths: warrantyMonths,
      qrCodeData: qrCodeData,
      barcodeData: barcodeData,
      metadata: metadata,
      version: version,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isDeleted: isDeleted,
    );
  }

  /// Get bundle display info
  String get displayInfo {
    return 'Bundle $sequenceNumber: $code (Cartons: $cartonCount, Units: $totalUnits)';
  }

  /// Check if bundle is ready for shipping
  bool get isReadyForShipping {
    return status == CodeStatus.linked || status == CodeStatus.published;
  }

  /// Check if bundle has been delivered
  bool get isDelivered => actualDeliveryDate != null;

  /// Get delivery status
  String get deliveryStatus {
    if (isDelivered) return 'Delivered';
    if (expectedDeliveryDate != null &&
        DateTime.now().isAfter(expectedDeliveryDate!)) {
      return 'Delayed';
    }
    if (isReadyForShipping) return 'Ready for Shipping';
    return 'Not Ready';
  }

  /// Get priority display name
  String get priorityDisplayName {
    switch (priority) {
      case 1:
        return 'High Priority';
      case 2:
        return 'Medium Priority';
      case 3:
        return 'Low Priority';
      default:
        return 'Medium Priority';
    }
  }

  /// Get priority color
  String get priorityColor {
    switch (priority) {
      case 1:
        return '#F44336'; // Red for high priority
      case 2:
        return '#FF9800'; // Orange for medium priority
      case 3:
        return '#4CAF50'; // Green for low priority
      default:
        return '#FF9800';
    }
  }
}

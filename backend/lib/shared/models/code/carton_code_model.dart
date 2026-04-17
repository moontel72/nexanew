import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'base_code_model.dart';

part 'carton_code_model.freezed.dart';
part 'carton_code_model.g.dart';

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

/// Carton Code Model
/// Specialized model for Carton Codes with carton-specific properties
@freezed
@HiveType(typeId: 104)
abstract class CartonCodeModel with _$CartonCodeModel {
  const factory CartonCodeModel({
    /// Base code properties
    @HiveField(0) required String id,
    @HiveField(1) required String code,
    @HiveField(2) @Default(CodeType.carton) CodeType type,
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

    /// Carton-specific properties
    /// Bundle code that contains this carton
    @HiveField(25) @Default('') String bundleCode,

    /// Number of packets in this carton
    @HiveField(26) @Default(0) int packetCount,

    /// List of packet codes contained in this carton
    @HiveField(27) @Default(<String>[]) List<String> packetCodes,

    /// Carton weight in kilograms
    @HiveField(28) double? weight,

    /// Carton dimensions (length x width x height in cm)
    @HiveField(29) String? dimensions,

    /// Carton sequence number within bundle (e.g., 1, 2, 3...)
    @HiveField(30) @Default(0) int sequenceNumber,

    /// Total units in this carton (calculated: packetCount * unitsPerPacket)
    @HiveField(31) @Default(0) int totalUnits,

    /// Carton type (e.g., "Corrugated", "Cardboard", "Plastic")
    @HiveField(32) String? cartonType,

    /// Carton grade/quality
    @HiveField(33) String? grade,

    /// Maximum weight capacity of carton
    @HiveField(34) double? maxWeightCapacity,

    /// Is carton sealed?
    @HiveField(35) @Default(false) bool isSealed,

    /// Sealing date
    @HiveField(36) DateTime? sealedAt,

    /// Sealed by (user ID)
    @HiveField(37) String? sealedBy,

    /// Storage temperature requirements
    @HiveField(38) String? temperatureRequirements,

    /// Handling instructions specific to carton
    @HiveField(39) String? handlingInstructions,

    /// Carton barcode (separate from product barcode)
    @HiveField(40) String? cartonBarcode,

    /// Carton QR code (separate from product QR code)
    @HiveField(41) String? cartonQrCode,

    /// Carton condition (e.g., "New", "Good", "Damaged")
    @HiveField(42) @Default('New') String condition,

    /// Last inspection date
    @HiveField(43) DateTime? lastInspectionDate,

    /// Inspection notes
    @HiveField(44) String? inspectionNotes,
  }) = _CartonCodeModel;

  factory CartonCodeModel.fromJson(Map<String, dynamic> json) =>
      _$CartonCodeModelFromJson(json);

  const CartonCodeModel._();

  /// Check if code can be deleted
  bool get canDelete => status == CodeStatus.generated;

  /// Check if code can be linked to a product
  bool get canLink =>
      status == CodeStatus.generated || status == CodeStatus.linked;

  /// Check if code can be published
  bool get canPublish => status == CodeStatus.linked;

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

  /// Create a CartonCodeModel from BaseCodeModel
  factory CartonCodeModel.fromBaseCodeModel(
    BaseCodeModel baseCode, {
    required String bundleCode,
    required int packetCount,
    required List<String> packetCodes,
    required int sequenceNumber,
    required int totalUnits,
    double? weight,
    String? dimensions,
    String? cartonType,
    String? grade,
    double? maxWeightCapacity,
    bool isSealed = false,
    DateTime? sealedAt,
    String? sealedBy,
    String? temperatureRequirements,
    String? handlingInstructions,
    String? cartonBarcode,
    String? cartonQrCode,
    String condition = 'New',
    DateTime? lastInspectionDate,
    String? inspectionNotes,
  }) {
    return CartonCodeModel(
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
      bundleCode: bundleCode,
      packetCount: packetCount,
      packetCodes: packetCodes,
      sequenceNumber: sequenceNumber,
      totalUnits: totalUnits,
      weight: weight,
      dimensions: dimensions,
      cartonType: cartonType,
      grade: grade,
      maxWeightCapacity: maxWeightCapacity,
      isSealed: isSealed,
      sealedAt: sealedAt,
      sealedBy: sealedBy,
      temperatureRequirements: temperatureRequirements,
      handlingInstructions: handlingInstructions,
      cartonBarcode: cartonBarcode,
      cartonQrCode: cartonQrCode,
      condition: condition,
      lastInspectionDate: lastInspectionDate,
      inspectionNotes: inspectionNotes,
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

  /// Get carton display info
  String get displayInfo {
    return 'Carton $sequenceNumber: $code (Packets: $packetCount, Units: $totalUnits)';
  }

  /// Check if carton is sealed
  bool get isCartonSealed => isSealed && sealedAt != null;

  /// Get sealing status
  String get sealingStatus {
    if (isCartonSealed) {
      return 'Sealed on ${sealedAt!.toLocal().toString().split(' ')[0]}';
    }
    return 'Not Sealed';
  }

  /// Get carton condition color
  String get conditionColor {
    switch (condition.toLowerCase()) {
      case 'new':
        return '#4CAF50'; // Green
      case 'good':
        return '#2196F3'; // Blue
      case 'damaged':
        return '#F44336'; // Red
      case 'repair needed':
        return '#FF9800'; // Orange
      default:
        return '#9E9E9E'; // Grey
    }
  }

  /// Check if carton needs inspection
  bool get needsInspection {
    if (lastInspectionDate == null) return true;

    // If last inspection was more than 30 days ago
    final daysSinceInspection =
        DateTime.now().difference(lastInspectionDate!).inDays;
    return daysSinceInspection > 30;
  }

  /// Get inspection status
  String get inspectionStatus {
    if (lastInspectionDate == null) return 'Never Inspected';

    if (needsInspection) {
      return 'Due for Inspection';
    }

    return 'Inspected ${lastInspectionDate!.toLocal().toString().split(' ')[0]}';
  }

  /// Calculate carton volume (if dimensions provided)
  double? get volume {
    if (dimensions == null) return null;

    try {
      final parts = dimensions!.split('x');
      if (parts.length != 3) return null;

      final length = double.tryParse(parts[0].trim());
      final width = double.tryParse(parts[1].trim());
      final height = double.tryParse(parts[2].trim());

      if (length == null || width == null || height == null) return null;

      return length * width * height;
    } catch (e) {
      return null;
    }
  }

  /// Check if carton is overweight
  bool get isOverweight {
    if (weight == null || maxWeightCapacity == null) return false;
    return weight! > maxWeightCapacity!;
  }

  /// Get weight status
  String get weightStatus {
    if (weight == null) return 'Weight not specified';

    if (maxWeightCapacity == null) {
      return '$weight kg';
    }

    if (isOverweight) {
      return '$weight kg (OVERWEIGHT - Max: $maxWeightCapacity kg)';
    }

    return '$weight kg (Max: $maxWeightCapacity kg)';
  }
}

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'base_code_model.dart';

part 'packet_code_model.freezed.dart';
part 'packet_code_model.g.dart';

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

/// Packet Code Model
/// Specialized model for Packet Codes with packet-specific properties
@freezed
@HiveType(typeId: 105)
abstract class PacketCodeModel with _$PacketCodeModel {
  const factory PacketCodeModel({
    /// Base code properties
    @HiveField(0) required String id,
    @HiveField(1) required String code,
    @HiveField(2) @Default(CodeType.packet) CodeType type,
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

    /// Packet-specific properties
    /// Carton code that contains this packet
    @HiveField(25) @Default('') String cartonCode,

    /// Number of units in this packet
    @HiveField(26) @Default(0) int unitCount,

    /// List of unit codes contained in this packet
    @HiveField(27) @Default(<String>[]) List<String> unitCodes,

    /// Packet weight in grams
    @HiveField(28) double? weight,

    /// Packet dimensions (length x width x height in cm)
    @HiveField(29) String? dimensions,

    /// Packet sequence number within carton (e.g., 1, 2, 3...)
    @HiveField(30) @Default(0) int sequenceNumber,

    /// Packet type (e.g., "Blister", "Box", "Pouch", "Bottle")
    @HiveField(31) String? packetType,

    /// Packet material (e.g., "Plastic", "Paper", "Aluminum")
    @HiveField(32) String? material,

    /// Is packet sealed?
    @HiveField(33) @Default(false) bool isSealed,

    /// Sealing date
    @HiveField(34) DateTime? sealedAt,

    /// Sealed by (user ID)
    @HiveField(35) String? sealedBy,

    /// Sealing method (e.g., "Heat Seal", "Adhesive", "Clip")
    @HiveField(36) String? sealingMethod,

    /// Packet barcode (separate from product barcode)
    @HiveField(37) String? packetBarcode,

    /// Packet QR code (separate from product QR code)
    @HiveField(38) String? packetQrCode,

    /// Packet condition (e.g., "Intact", "Damaged", "Torn")
    @HiveField(39) @Default('Intact') String condition,

    /// Tamper evidence seal present?
    @HiveField(40) @Default(false) bool hasTamperEvidence,

    /// Child safety features present?
    @HiveField(41) @Default(false) bool hasChildSafety,

    /// Instructions for use included?
    @HiveField(42) @Default(false) bool hasInstructions,

    /// Batch number specific to this packet
    @HiveField(43) String? packetBatchNumber,

    /// Serial number specific to this packet
    @HiveField(44) String? serialNumber,

    /// Packet color (for identification)
    @HiveField(45) String? color,

    /// Packet printing details
    @HiveField(46) String? printingDetails,

    /// Quality control passed?
    @HiveField(47) @Default(false) bool qcPassed,

    /// QC passed date
    @HiveField(48) DateTime? qcPassedDate,

    /// QC passed by (user ID)
    @HiveField(49) String? qcPassedBy,

    /// QC notes
    @HiveField(50) String? qcNotes,

    /// Packet code format type (itf14, gs1_128, code128_industrial, qr, datamatrix, code128_label)
    @HiveField(51) @Default('qr') String codeFormat,
  }) = _PacketCodeModel;

  factory PacketCodeModel.fromJson(Map<String, dynamic> json) =>
      _$PacketCodeModelFromJson(json);

  const PacketCodeModel._();

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

  /// Create a PacketCodeModel from BaseCodeModel
  factory PacketCodeModel.fromBaseCodeModel(
    BaseCodeModel baseCode, {
    required String cartonCode,
    required int unitCount,
    required List<String> unitCodes,
    required int sequenceNumber,
    double? weight,
    String? dimensions,
    String? packetType,
    String? material,
    bool isSealed = false,
    DateTime? sealedAt,
    String? sealedBy,
    String? sealingMethod,
    String? packetBarcode,
    String? packetQrCode,
    String condition = 'Intact',
    bool hasTamperEvidence = false,
    bool hasChildSafety = false,
    bool hasInstructions = false,
    String? packetBatchNumber,
    String? serialNumber,
    String? color,
    String? printingDetails,
    bool qcPassed = false,
    DateTime? qcPassedDate,
    String? qcPassedBy,
    String? qcNotes,
  }) {
    return PacketCodeModel(
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
      cartonCode: cartonCode,
      unitCount: unitCount,
      unitCodes: unitCodes,
      sequenceNumber: sequenceNumber,
      weight: weight,
      dimensions: dimensions,
      packetType: packetType,
      material: material,
      isSealed: isSealed,
      sealedAt: sealedAt,
      sealedBy: sealedBy,
      sealingMethod: sealingMethod,
      packetBarcode: packetBarcode,
      packetQrCode: packetQrCode,
      condition: condition,
      hasTamperEvidence: hasTamperEvidence,
      hasChildSafety: hasChildSafety,
      hasInstructions: hasInstructions,
      packetBatchNumber: packetBatchNumber,
      serialNumber: serialNumber,
      color: color,
      printingDetails: printingDetails,
      qcPassed: qcPassed,
      qcPassedDate: qcPassedDate,
      qcPassedBy: qcPassedBy,
      qcNotes: qcNotes,
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

  /// Get packet display info
  String get displayInfo {
    return 'Packet $sequenceNumber: $code (Units: $unitCount)';
  }

  /// Check if packet is sealed
  bool get isPacketSealed => isSealed && sealedAt != null;

  /// Get sealing status
  String get sealingStatus {
    if (isPacketSealed) {
      return 'Sealed on ${sealedAt!.toLocal().toString().split(' ')[0]}';
    }
    return 'Not Sealed';
  }

  /// Get packet condition color
  String get conditionColor {
    switch (condition.toLowerCase()) {
      case 'intact':
        return '#4CAF50'; // Green
      case 'good':
        return '#2196F3'; // Blue
      case 'damaged':
        return '#F44336'; // Red
      case 'torn':
        return '#FF5722'; // Deep Orange
      case 'leaking':
        return '#9C27B0'; // Purple
      default:
        return '#9E9E9E'; // Grey
    }
  }

  /// Check if packet has passed quality control
  bool get hasPassedQC => qcPassed && qcPassedDate != null;

  /// Get QC status
  String get qcStatus {
    if (hasPassedQC) {
      return 'QC Passed on ${qcPassedDate!.toLocal().toString().split(' ')[0]}';
    }
    return 'QC Not Passed';
  }

  /// Get safety features summary
  String get safetyFeatures {
    final features = <String>[];
    if (hasTamperEvidence) features.add('Tamper Evidence');
    if (hasChildSafety) features.add('Child Safety');
    if (features.isEmpty) return 'No Safety Features';
    return features.join(', ');
  }

  /// Calculate packet volume (if dimensions provided)
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

  /// Get weight in different units
  Map<String, double> get weightInUnits {
    final Map<String, double> units = {};

    if (weight != null) {
      units['grams'] = weight!;
      units['kilograms'] = weight! / 1000;
      units['ounces'] = weight! * 0.035274;
      units['pounds'] = weight! * 0.00220462;
    }

    return units;
  }

  /// Check if packet is ready for distribution
  bool get isReadyForDistribution {
    return isPacketSealed && hasPassedQC && condition.toLowerCase() == 'intact';
  }

  /// Get distribution readiness status
  String get distributionStatus {
    if (!isPacketSealed) return 'Not Sealed';
    if (!hasPassedQC) return 'QC Not Passed';
    if (condition.toLowerCase() != 'intact') return 'Condition: $condition';
    return 'Ready for Distribution';
  }

  /// Get packet type icon (for UI)
  String get packetTypeIcon {
    switch (packetType?.toLowerCase()) {
      case 'blister':
        return '💊';
      case 'box':
        return '📦';
      case 'pouch':
        return '📁';
      case 'bottle':
        return '🍶';
      case 'tube':
        return '🧴';
      case 'jar':
        return '🫙';
      default:
        return '📄';
    }
  }
}

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'base_code_model.dart';

part 'unit_code_model.freezed.dart';
part 'unit_code_model.g.dart';

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

/// Unit Code Model
/// Specialized model for Unit Codes (Authentication Codes) with unit-specific properties
@freezed
@HiveType(typeId: 106)
abstract class UnitCodeModel with _$UnitCodeModel {
  const factory UnitCodeModel({
    /// Base code properties
    @HiveField(0) required String id,
    @HiveField(1) required String code,
    @HiveField(2) @Default(CodeType.unit) CodeType type,
    @HiveField(3) @Default(CodeStatus.generated) CodeStatus status,
    @HiveField(4) @Default('') String factoryId,
    @HiveField(5) @Default('') String subscriptionPlanId,
    @HiveField(6) @Default('') String storeKeeperCode,
    @HiveField(7) String? internationalCode, // Optional for unit codes
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

    /// Unit-specific properties
    /// Packet code that contains this unit
    @HiveField(25) @Default('') String packetCode,

    /// Unit sequence number within packet (e.g., 1, 2, 3...)
    @HiveField(26) @Default(0) int sequenceNumber,

    /// Authentication code (system-generated for verification)
    @HiveField(27) @Default('') String authenticationCode,

    /// Is this a master authentication code?
    @HiveField(28) @Default(false) bool isMasterCode,

    /// Master code ID (if this is a sub-code)
    @HiveField(29) String? masterCodeId,

    /// Verification count (how many times this code has been verified)
    @HiveField(30) @Default(0) int verificationCount,

    /// First verification date
    @HiveField(31) DateTime? firstVerifiedAt,

    /// Last verification date
    @HiveField(32) DateTime? lastVerifiedAt,

    /// Verification location (GPS coordinates or address)
    @HiveField(33) String? verificationLocation,

    /// Verified by (user ID or device ID)
    @HiveField(34) String? verifiedBy,

    /// Is code reported as fake/counterfeit?
    @HiveField(35) @Default(false) bool isReportedFake,

    /// Fake report date
    @HiveField(36) DateTime? fakeReportedAt,

    /// Fake reported by (user ID)
    @HiveField(37) String? fakeReportedBy,

    /// Fake report reason
    @HiveField(38) String? fakeReportReason,

    /// Is code blocked?
    @HiveField(39) @Default(false) bool isBlocked,

    /// Blocked date
    @HiveField(40) DateTime? blockedAt,

    /// Blocked by (user ID)
    @HiveField(41) String? blockedBy,

    /// Block reason
    @HiveField(42) String? blockReason,

    /// Unit serial number (unique per unit)
    @HiveField(43) @Default('') String serialNumber,

    /// Unit model/variant
    @HiveField(44) String? model,

    /// Unit color
    @HiveField(45) String? color,

    /// Unit size
    @HiveField(46) String? size,

    /// Unit weight in grams
    @HiveField(47) double? weight,

    /// Unit dimensions (length x width x height in cm)
    @HiveField(48) String? dimensions,

    /// Unit condition (e.g., "New", "Used", "Refurbished")
    @HiveField(49) @Default('New') String condition,

    /// Unit grade/quality
    @HiveField(50) String? grade,

    /// Has warranty card?
    @HiveField(51) @Default(false) bool hasWarrantyCard,

    /// Has user manual?
    @HiveField(52) @Default(false) bool hasUserManual,

    /// Has accessories?
    @HiveField(53) @Default(false) bool hasAccessories,

    /// Accessories list (JSON string)
    @HiveField(54) String? accessoriesList,

    /// Special features (JSON string)
    @HiveField(55) String? specialFeatures,

    /// Safety certifications (JSON string)
    @HiveField(56) String? safetyCertifications,

    /// Compliance standards (JSON string)
    @HiveField(57) String? complianceStandards,

    /// Last maintenance date
    @HiveField(58) DateTime? lastMaintenanceDate,

    /// Maintenance notes
    @HiveField(59) String? maintenanceNotes,

    /// Is unit activated?
    @HiveField(60) @Default(false) bool isActivated,

    /// Activation date
    @HiveField(61) DateTime? activatedAt,

    /// Activated by (user ID)
    @HiveField(62) String? activatedBy,

    /// Activation location
    @HiveField(63) String? activationLocation,

    /// Unit code format type (itf14, gs1_128, code128_industrial, qr, datamatrix, code128_label)
    @HiveField(64) @Default('qr') String codeFormat,
  }) = _UnitCodeModel;

  factory UnitCodeModel.fromJson(Map<String, dynamic> json) =>
      _$UnitCodeModelFromJson(json);

  const UnitCodeModel._();

  /// Check if code can be deleted
  bool get canDelete => status == CodeStatus.generated;

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

  /// Create a UnitCodeModel from BaseCodeModel
  factory UnitCodeModel.fromBaseCodeModel(
    BaseCodeModel baseCode, {
    required String packetCode,
    required int sequenceNumber,
    required String authenticationCode,
    required String serialNumber,
    bool isMasterCode = false,
    String? masterCodeId,
    int verificationCount = 0,
    DateTime? firstVerifiedAt,
    DateTime? lastVerifiedAt,
    String? verificationLocation,
    String? verifiedBy,
    bool isReportedFake = false,
    DateTime? fakeReportedAt,
    String? fakeReportedBy,
    String? fakeReportReason,
    bool isBlocked = false,
    DateTime? blockedAt,
    String? blockedBy,
    String? blockReason,
    String? model,
    String? color,
    String? size,
    double? weight,
    String? dimensions,
    String condition = 'New',
    String? grade,
    bool hasWarrantyCard = false,
    bool hasUserManual = false,
    bool hasAccessories = false,
    String? accessoriesList,
    String? specialFeatures,
    String? safetyCertifications,
    String? complianceStandards,
    DateTime? lastMaintenanceDate,
    String? maintenanceNotes,
    bool isActivated = false,
    DateTime? activatedAt,
    String? activatedBy,
    String? activationLocation,
  }) {
    return UnitCodeModel(
      id: baseCode.id,
      code: baseCode.code,
      type: baseCode.type,
      status: baseCode.status,
      factoryId: baseCode.factoryId,
      subscriptionPlanId: baseCode.subscriptionPlanId,
      storeKeeperCode: baseCode.storeKeeperCode,
      internationalCode: baseCode.internationalCode,
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
      packetCode: packetCode,
      sequenceNumber: sequenceNumber,
      authenticationCode: authenticationCode,
      isMasterCode: isMasterCode,
      masterCodeId: masterCodeId,
      verificationCount: verificationCount,
      firstVerifiedAt: firstVerifiedAt,
      lastVerifiedAt: lastVerifiedAt,
      verificationLocation: verificationLocation,
      verifiedBy: verifiedBy,
      isReportedFake: isReportedFake,
      fakeReportedAt: fakeReportedAt,
      fakeReportedBy: fakeReportedBy,
      fakeReportReason: fakeReportReason,
      isBlocked: isBlocked,
      blockedAt: blockedAt,
      blockedBy: blockedBy,
      blockReason: blockReason,
      serialNumber: serialNumber,
      model: model,
      color: color,
      size: size,
      weight: weight,
      dimensions: dimensions,
      condition: condition,
      grade: grade,
      hasWarrantyCard: hasWarrantyCard,
      hasUserManual: hasUserManual,
      hasAccessories: hasAccessories,
      accessoriesList: accessoriesList,
      specialFeatures: specialFeatures,
      safetyCertifications: safetyCertifications,
      complianceStandards: complianceStandards,
      lastMaintenanceDate: lastMaintenanceDate,
      maintenanceNotes: maintenanceNotes,
      isActivated: isActivated,
      activatedAt: activatedAt,
      activatedBy: activatedBy,
      activationLocation: activationLocation,
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

  /// Get unit display info
  String get displayInfo {
    return 'Unit $sequenceNumber: $code (Serial: $serialNumber)';
  }

  /// Check if unit has been verified
  bool get hasBeenVerified => verificationCount > 0;

  /// Get verification status
  String get verificationStatus {
    if (verificationCount == 0) return 'Never Verified';
    if (verificationCount == 1) return 'Verified Once';
    return 'Verified $verificationCount times';
  }

  /// Get last verification info
  String get lastVerificationInfo {
    if (lastVerifiedAt == null) return 'Never Verified';

    final lastVerified = lastVerifiedAt!.toLocal();
    final now = DateTime.now();
    final difference = now.difference(lastVerified);

    if (difference.inDays > 365) {
      return 'Last verified ${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return 'Last verified ${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return 'Last verified ${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return 'Last verified ${difference.inHours} hours ago';
    } else {
      return 'Last verified ${difference.inMinutes} minutes ago';
    }
  }

  /// Check if unit is authentic (not fake and not blocked)
  bool get isAuthentic => !isReportedFake && !isBlocked;

  /// Get authenticity status
  String get authenticityStatus {
    if (isReportedFake) return 'Reported as Fake';
    if (isBlocked) return 'Blocked';
    if (hasBeenVerified) return 'Authentic (Verified)';
    return 'Authentic (Not Yet Verified)';
  }

  /// Get authenticity color
  String get authenticityColor {
    if (isReportedFake) return '#F44336'; // Red for fake
    if (isBlocked) return '#FF9800'; // Orange for blocked
    if (hasBeenVerified) return '#4CAF50'; // Green for verified authentic
    return '#2196F3'; // Blue for not yet verified
  }

  /// Check if warranty is valid
  bool get isWarrantyValid {
    if (manufacturingDate == null) return false;
    if (warrantyMonths == null || warrantyMonths == 0) return false;

    final warrantyEndDate = manufacturingDate!.add(
      Duration(days: warrantyMonths! * 30),
    );
    return DateTime.now().isBefore(warrantyEndDate);
  }

  /// Get warranty status
  String get warrantyStatus {
    if (!isWarrantyValid) return 'No Warranty';

    final warrantyEndDate = manufacturingDate!.add(
      Duration(days: warrantyMonths! * 30),
    );
    final daysLeft = warrantyEndDate.difference(DateTime.now()).inDays;

    if (daysLeft > 365) {
      return 'Warranty: ${(daysLeft / 365).floor()} years left';
    } else if (daysLeft > 30) {
      return 'Warranty: ${(daysLeft / 30).floor()} months left';
    } else if (daysLeft > 0) {
      return 'Warranty: $daysLeft days left';
    } else {
      return 'Warranty Expired';
    }
  }

  /// Check if product is expired (for food/medical)
  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  /// Get expiry status
  String get expiryStatus {
    if (expiryDate == null) return 'No Expiry Date';

    if (isExpired) {
      return 'Expired on ${expiryDate!.toLocal().toString().split(' ')[0]}';
    }

    final daysLeft = expiryDate!.difference(DateTime.now()).inDays;
    if (daysLeft <= 7) {
      return 'Expires in $daysLeft days (URGENT)';
    } else if (daysLeft <= 30) {
      return 'Expires in $daysLeft days';
    } else if (daysLeft <= 90) {
      return 'Expires in ${(daysLeft / 30).floor()} months';
    } else {
      return 'Expires on ${expiryDate!.toLocal().toString().split(' ')[0]}';
    }
  }

  /// Calculate unit volume (if dimensions provided)
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

  /// Get unit condition color
  String get conditionColor {
    switch (condition.toLowerCase()) {
      case 'new':
        return '#4CAF50'; // Green
      case 'like new':
        return '#8BC34A'; // Light Green
      case 'used':
        return '#FFC107'; // Amber
      case 'refurbished':
        return '#2196F3'; // Blue
      case 'damaged':
        return '#F44336'; // Red
      case 'for parts':
        return '#9E9E9E'; // Grey
      default:
        return '#9E9E9E'; // Grey
    }
  }

  /// Check if unit is ready for sale
  bool get isReadyForSale {
    return isAuthentic &&
        !isExpired &&
        condition.toLowerCase() == 'new' &&
        hasWarrantyCard;
  }

  /// Get sale readiness status
  String get saleReadinessStatus {
    if (!isAuthentic) return 'Not Authentic';
    if (isExpired) return 'Expired';
    if (condition.toLowerCase() != 'new') return 'Condition: $condition';
    if (!hasWarrantyCard) return 'Missing Warranty Card';
    return 'Ready for Sale';
  }

  /// Generate verification QR code data
  String get verificationQrCodeData {
    return 'NEXATRACE|$code|$authenticationCode|$serialNumber|${factoryId.substring(0, 8)}';
  }

  /// Get authentication code format (for display)
  String get authenticationCodeFormatted {
    if (authenticationCode.length <= 8) return authenticationCode;

    // Format as XXXX-XXXX-XXXX-XXXX
    final chunks = <String>[];
    for (int i = 0; i < authenticationCode.length; i += 4) {
      final end = i + 4;
      chunks.add(
        authenticationCode.substring(
          i,
          end > authenticationCode.length ? authenticationCode.length : end,
        ),
      );
    }
    return chunks.join('-');
  }
}

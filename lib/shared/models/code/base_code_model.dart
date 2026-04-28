import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'base_code_model.freezed.dart';
part 'base_code_model.g.dart';

/// Code Status Enum
@HiveType(typeId: 100)
enum CodeStatus {
  @HiveField(0)
  generated,
  @HiveField(1)
  linked,
  @HiveField(2)
  published,
  @HiveField(3)
  deactivated,
  @HiveField(4)
  expired,
}

/// Code Type Enum
@HiveType(typeId: 101)
enum CodeType {
  @HiveField(0)
  bundle,
  @HiveField(1)
  carton,
  @HiveField(2)
  packet,
  @HiveField(3)
  unit,
}

/// Carton Code Format Enum
/// Defines the 6 independent carton code format types supported by the backend
enum CartonCodeFormat {
  itf14('itf14', 'ITF-14', 'Standard industrial barcode'),
  gs1_128('gs1_128', 'GS1-128', 'GS1-128 barcode'),
  code128Industrial(
    'code128_industrial',
    'Code 128 Industrial',
    'Code 128 (Industrial/factory)',
  ),
  qr('qr', 'QR Code', 'QR Code (default)'),
  datamatrix('datamatrix', 'DataMatrix', 'DataMatrix (pharma)'),
  code128Label('code128_label', 'Code 128 Label', 'Code 128 (Label printer)');

  const CartonCodeFormat(this.value, this.displayName, this.description);

  /// The API value sent to the backend
  final String value;

  /// Human-readable display name for the UI
  final String displayName;

  /// Description of the format
  final String description;

  /// Find a format by its API value, defaults to [CartonCodeFormat.qr]
  static CartonCodeFormat fromValue(String? value) {
    if (value == null) return CartonCodeFormat.qr;
    return CartonCodeFormat.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CartonCodeFormat.qr,
    );
  }
}

/// Base Code Model
/// This model contains common properties for all code types
@freezed
@HiveType(typeId: 102)
abstract class BaseCodeModel with _$BaseCodeModel {
  const factory BaseCodeModel({
    /// Unique identifier for the code
    @HiveField(0) required String id,

    /// The actual code value (e.g., "A-01", "YY-001", "YBZ-0001", "TSFG-00001")
    @HiveField(1) required String code,

    /// Code type (bundle, carton, packet, unit)
    @HiveField(2) required CodeType type,

    /// Current status of the code
    @HiveField(3) @Default(CodeStatus.generated) CodeStatus status,

    /// Factory ID that owns this code
    @HiveField(4) required String factoryId,

    /// Subscription plan ID under which this code was generated
    @HiveField(5) required String subscriptionPlanId,

    /// Store keeper code (internal tracking code)
    @HiveField(6) required String storeKeeperCode,

    /// International standard code (GS1, etc.) - optional for unit codes
    @HiveField(7) String? internationalCode,

    /// Batch ID - all codes generated together in one batch have same batchId
    @HiveField(8) required String batchId,

    /// Date and time when the code was generated
    @HiveField(9) required DateTime generatedAt,

    /// Date and time when the code was linked to a product
    @HiveField(10) DateTime? linkedAt,

    /// Date and time when the code was published
    @HiveField(11) DateTime? publishedAt,

    /// Date and time when the code was deactivated
    @HiveField(12) DateTime? deactivatedAt,

    /// Product ID this code is linked to (null if not linked)
    @HiveField(13) String? productId,

    /// Product batch number (if applicable)
    @HiveField(14) String? productBatchNumber,

    /// Manufacturing date (for food/medical products)
    @HiveField(15) DateTime? manufacturingDate,

    /// Expiry date (for food/medical products)
    @HiveField(16) DateTime? expiryDate,

    /// Warranty period in months (for other products)
    @HiveField(17) int? warrantyMonths,

    /// QR code data (encoded string)
    @HiveField(18) String? qrCodeData,

    /// Barcode data (encoded string)
    @HiveField(19) String? barcodeData,

    /// Metadata for additional information (JSON string)
    @HiveField(20) String? metadata,

    /// Version for optimistic concurrency control
    @HiveField(21) @Default(1) int version,

    /// Created timestamp
    @HiveField(22) required DateTime createdAt,

    /// Updated timestamp
    @HiveField(23) required DateTime updatedAt,

    /// Soft delete flag
    @HiveField(24) @Default(false) bool isDeleted,
  }) = _BaseCodeModel;

  factory BaseCodeModel.fromJson(Map<String, dynamic> json) =>
      _$BaseCodeModelFromJson(json);

  const BaseCodeModel._();

  /// Check if code can be deleted
  /// Codes can only be deleted before they are published
  bool get canDelete => status == CodeStatus.generated;

  /// Check if code can be linked to a product
  /// Codes can be linked when they are generated or already linked
  bool get canLink =>
      status == CodeStatus.generated || status == CodeStatus.linked;

  /// Check if code can be published
  /// Codes can be published when they are linked to a product
  bool get canPublish => status == CodeStatus.linked;

  /// Check if code can be deactivated
  /// Codes can be deactivated after they are published
  bool get canDeactivate => status == CodeStatus.published;

  /// Get display name for code type
  String get typeDisplayName {
    switch (type) {
      case CodeType.bundle:
        return 'Bundle Code';
      case CodeType.carton:
        return 'Carton Code';
      case CodeType.packet:
        return 'Packet Code';
      case CodeType.unit:
        return 'Unit Code';
    }
  }

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

  /// Get color for code status (for UI)
  String get statusColor {
    switch (status) {
      case CodeStatus.generated:
        return '#4CAF50'; // Green
      case CodeStatus.linked:
        return '#2196F3'; // Blue
      case CodeStatus.published:
        return '#9C27B0'; // Purple
      case CodeStatus.deactivated:
        return '#F44336'; // Red
      case CodeStatus.expired:
        return '#FF9800'; // Orange
    }
  }
}

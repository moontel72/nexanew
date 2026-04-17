import 'package:freezed_annotation/freezed_annotation.dart';

part 'invoice_item_model.freezed.dart';
part 'invoice_item_model.g.dart';

@freezed
abstract class InvoiceItemDetail with _$InvoiceItemDetail {
  const factory InvoiceItemDetail({
    required String id,
    required String invoiceId,
    required String description,
    required String itemType,
    required double quantity,
    required double unitPrice,
    required double totalAmount,
    required String currency,
    required DateTime periodStart,
    required DateTime periodEnd,
    // Item type specific fields
    String? codeType,
    int? codeCount,
    double? codeUnitPrice,
    String? planFeatureId,
    String? planFeatureName,
    double? usageAmount,
    double? overageRate,
    double? overageAmount,
    bool? isOverageCharge,
    // Tax and discount details
    double? taxRate,
    double? taxAmount,
    double? discountRate,
    double? discountAmount,
    // Metadata
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _InvoiceItemDetail;

  factory InvoiceItemDetail.fromJson(Map<String, dynamic> json) =>
      _$InvoiceItemDetailFromJson(json);

  factory InvoiceItemDetail.empty() => InvoiceItemDetail(
    id: '',
    invoiceId: '',
    description: '',
    itemType: '',
    quantity: 0.0,
    unitPrice: 0.0,
    totalAmount: 0.0,
    currency: 'USD',
    periodStart: DateTime.now(),
    periodEnd: DateTime.now(),
  );
}

@freezed
abstract class InvoiceItemBreakdown with _$InvoiceItemBreakdown {
  const factory InvoiceItemBreakdown({
    required String invoiceId,
    required String invoiceNumber,
    required DateTime invoiceDate,
    required String companyId,
    required String companyName,
    required List<InvoiceItemDetail> items,
    required double subtotal,
    required double totalTax,
    required double totalDiscount,
    required double grandTotal,
    required String currency,
    // Summary statistics
    int? totalItems,
    double? averageItemPrice,
    double? highestItemPrice,
    double? lowestItemPrice,
    // Categorization
    Map<String, double>? amountByItemType,
    Map<String, int>? countByItemType,
  }) = _InvoiceItemBreakdown;

  factory InvoiceItemBreakdown.fromJson(Map<String, dynamic> json) =>
      _$InvoiceItemBreakdownFromJson(json);
}

@freezed
abstract class ItemTypeSummary with _$ItemTypeSummary {
  const factory ItemTypeSummary({
    required String itemType,
    required String displayName,
    required double totalAmount,
    required int itemCount,
    required double averageAmount,
    required String currency,
    // Time period
    DateTime? periodStart,
    DateTime? periodEnd,
    // Breakdown by sub-type
    Map<String, double>? amountBySubType,
    Map<String, int>? countBySubType,
    // Trend data
    List<ItemTypeTrendData>? trendData,
  }) = _ItemTypeSummary;

  factory ItemTypeSummary.fromJson(Map<String, dynamic> json) =>
      _$ItemTypeSummaryFromJson(json);
}

@freezed
abstract class ItemTypeTrendData with _$ItemTypeTrendData {
  const factory ItemTypeTrendData({
    required DateTime date,
    required double amount,
    required int count,
    required String itemType,
  }) = _ItemTypeTrendData;

  factory ItemTypeTrendData.fromJson(Map<String, dynamic> json) =>
      _$ItemTypeTrendDataFromJson(json);
}

@freezed
abstract class OverageChargeDetail with _$OverageChargeDetail {
  const factory OverageChargeDetail({
    required String id,
    required String companyId,
    required String planFeatureId,
    required String planFeatureName,
    required double includedAmount,
    required double usedAmount,
    required double overageAmount,
    required double overageRate,
    required double chargeAmount,
    required DateTime periodStart,
    required DateTime periodEnd,
    required String currency,
    String? invoiceId,
    String? invoiceNumber,
    bool? isInvoiced,
    DateTime? invoicedAt,
    Map<String, dynamic>? usageMetadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _OverageChargeDetail;

  factory OverageChargeDetail.fromJson(Map<String, dynamic> json) =>
      _$OverageChargeDetailFromJson(json);
}

@freezed
abstract class UsageBasedCharge with _$UsageBasedCharge {
  const factory UsageBasedCharge({
    required String id,
    required String companyId,
    required String metricName,
    required String metricUnit,
    required double includedUnits,
    required double usedUnits,
    required double overageUnits,
    required double unitPrice,
    required double totalCharge,
    required DateTime periodStart,
    required DateTime periodEnd,
    required String currency,
    String? invoiceId,
    String? invoiceNumber,
    bool? isInvoiced,
    DateTime? invoicedAt,
    Map<String, dynamic>? usageData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UsageBasedCharge;

  factory UsageBasedCharge.fromJson(Map<String, dynamic> json) =>
      _$UsageBasedChargeFromJson(json);
}

// Enum for item types
enum InvoiceItemType {
  @JsonValue('subscription')
  subscription,
  @JsonValue('code_generation')
  codeGeneration,
  @JsonValue('overage')
  overage,
  @JsonValue('setup_fee')
  setupFee,
  @JsonValue('renewal_fee')
  renewalFee,
  @JsonValue('addon')
  addon,
  @JsonValue('credit')
  credit,
  @JsonValue('refund')
  refund,
  @JsonValue('other')
  other,
}

// Enum for code types
enum CodeType {
  @JsonValue('unit')
  unit,
  @JsonValue('packet')
  packet,
  @JsonValue('bundle')
  bundle,
  @JsonValue('carton')
  carton,
  @JsonValue('pallet')
  pallet,
  @JsonValue('other')
  other,
}

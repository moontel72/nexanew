import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nexatrace_system/shared/models/billing/invoice_model.dart'
    show InvoiceStatus, PaymentMethod;

part 'invoice_model.freezed.dart';
part 'invoice_model.g.dart';

@freezed
abstract class AdminInvoice with _$AdminInvoice {
  const factory AdminInvoice({
    required String id,
    required String invoiceNumber,
    required String companyId,
    required String companyName,
    required String subscriptionId,
    required String subscriptionName,
    required DateTime periodStart,
    required DateTime periodEnd,
    required DateTime issueDate,
    required DateTime dueDate,
    required double subtotal,
    required double taxAmount,
    required double discountAmount,
    required double totalAmount,
    @Default('USD') String currency,
    required List<AdminInvoiceItem> items,
    @Default(InvoiceStatus.pending) InvoiceStatus status,
    DateTime? paymentDate,
    PaymentMethod? paymentMethod,
    String? paymentReference,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    // Additional admin-specific fields
    String? adminNotes,
    bool? requiresFollowUp,
    String? followUpReason,
    DateTime? followUpDate,
    String? assignedToAdminId,
    String? assignedToAdminName,
  }) = _AdminInvoice;

  factory AdminInvoice.fromJson(Map<String, dynamic> json) =>
      _$AdminInvoiceFromJson(json);

  factory AdminInvoice.empty() => AdminInvoice(
        id: '',
        invoiceNumber: '',
        companyId: '',
        companyName: '',
        subscriptionId: '',
        subscriptionName: '',
        periodStart: DateTime.now(),
        periodEnd: DateTime.now(),
        issueDate: DateTime.now(),
        dueDate: DateTime.now(),
        subtotal: 0.0,
        taxAmount: 0.0,
        discountAmount: 0.0,
        totalAmount: 0.0,
        items: [],
      );
}

@freezed
abstract class AdminInvoiceItem with _$AdminInvoiceItem {
  const factory AdminInvoiceItem({
    required String id,
    required String description,
    required double quantity,
    required double unitPrice,
    required double total,
    required String currency,
    String? codeType,
    int? codeCount,
    DateTime? periodStart,
    DateTime? periodEnd,
    Map<String, dynamic>? metadata,
    // Additional admin-specific fields
    String? planFeatureId,
    String? planFeatureName,
    double? usageAmount,
    double? overageAmount,
    bool? isOverageCharge,
  }) = _AdminInvoiceItem;

  factory AdminInvoiceItem.fromJson(Map<String, dynamic> json) =>
      _$AdminInvoiceItemFromJson(json);
}

@freezed
abstract class PlatformRevenueSummary with _$PlatformRevenueSummary {
  const factory PlatformRevenueSummary({
    @Default(0.0) double totalRevenue,
    @Default(0.0) double collectedRevenue,
    @Default(0.0) double pendingRevenue,
    @Default(0.0) double overdueRevenue,
    @Default(0) int totalInvoices,
    @Default(0) int paidInvoices,
    @Default(0) int pendingInvoices,
    @Default(0) int overdueInvoices,
    @Default(0) int draftInvoices,
    @Default(0) int cancelledInvoices,
    DateTime? periodStart,
    DateTime? periodEnd,
    Map<String, double>? revenueByPlan,
    Map<String, double>? revenueByCompanyType,
    List<RevenueTrendData>? revenueTrend,
  }) = _PlatformRevenueSummary;

  factory PlatformRevenueSummary.fromJson(Map<String, dynamic> json) =>
      _$PlatformRevenueSummaryFromJson(json);
}

@freezed
abstract class RevenueTrendData with _$RevenueTrendData {
  const factory RevenueTrendData({
    required DateTime date,
    required double revenue,
    required int invoiceCount,
    required int paidCount,
  }) = _RevenueTrendData;

  factory RevenueTrendData.fromJson(Map<String, dynamic> json) =>
      _$RevenueTrendDataFromJson(json);
}

@freezed
abstract class CompanyRevenueSummary with _$CompanyRevenueSummary {
  const factory CompanyRevenueSummary({
    required String companyId,
    required String companyName,
    required String companyType,
    required double totalRevenue,
    required double paidAmount,
    required double pendingAmount,
    required double overdueAmount,
    required int totalInvoices,
    required int paidInvoices,
    required int pendingInvoices,
    required int overdueInvoices,
    DateTime? lastPaymentDate,
    double? averagePaymentDays,
    String? currentPlan,
    DateTime? subscriptionStartDate,
    DateTime? subscriptionEndDate,
  }) = _CompanyRevenueSummary;

  factory CompanyRevenueSummary.fromJson(Map<String, dynamic> json) =>
      _$CompanyRevenueSummaryFromJson(json);
}

@freezed
abstract class PaymentReconciliation with _$PaymentReconciliation {
  const factory PaymentReconciliation({
    required String id,
    required DateTime reconciliationDate,
    required DateTime periodStart,
    required DateTime periodEnd,
    required double expectedAmount,
    required double actualAmount,
    required double discrepancyAmount,
    required int totalTransactions,
    required int matchedTransactions,
    required int unmatchedTransactions,
    required ReconciliationStatus status,
    String? notes,
    String? performedByAdminId,
    String? performedByAdminName,
    List<ReconciliationItem>? items,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _PaymentReconciliation;

  factory PaymentReconciliation.fromJson(Map<String, dynamic> json) =>
      _$PaymentReconciliationFromJson(json);
}

enum ReconciliationStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
  @JsonValue('failed')
  failed,
  @JsonValue('requires_review')
  requiresReview,
}

@freezed
abstract class ReconciliationItem with _$ReconciliationItem {
  const factory ReconciliationItem({
    required String id,
    required String transactionId,
    required String invoiceId,
    required String invoiceNumber,
    required double expectedAmount,
    required double actualAmount,
    required double discrepancy,
    required ReconciliationItemStatus status,
    String? notes,
    DateTime? matchedAt,
    String? matchedByAdminId,
    Map<String, dynamic>? metadata,
  }) = _ReconciliationItem;

  factory ReconciliationItem.fromJson(Map<String, dynamic> json) =>
      _$ReconciliationItemFromJson(json);
}

enum ReconciliationItemStatus {
  @JsonValue('matched')
  matched,
  @JsonValue('unmatched')
  unmatched,
  @JsonValue('partial_match')
  partialMatch,
  @JsonValue('requires_review')
  requiresReview,
}

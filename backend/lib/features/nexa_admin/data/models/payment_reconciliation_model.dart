import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_reconciliation_model.freezed.dart';
part 'payment_reconciliation_model.g.dart';

@freezed
abstract class PaymentReconciliation with _$PaymentReconciliation {
  const factory PaymentReconciliation({
    required String id,
    required String reconciliationNumber,
    required DateTime reconciliationDate,
    required DateTime periodStart,
    required DateTime periodEnd,
    required ReconciliationStatus status,
    required double expectedAmount,
    required double actualAmount,
    required double discrepancyAmount,
    required int totalTransactions,
    required int matchedTransactions,
    required int unmatchedTransactions,
    required int partialMatchTransactions,
    required String currency,
    String? notes,
    String? performedByAdminId,
    String? performedByAdminName,
    DateTime? completedAt,
    DateTime? reviewedAt,
    String? reviewedByAdminId,
    String? reviewedByAdminName,
    List<ReconciliationTransaction>? transactions,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _PaymentReconciliation;

  factory PaymentReconciliation.fromJson(Map<String, dynamic> json) =>
      _$PaymentReconciliationFromJson(json);

  factory PaymentReconciliation.empty() => PaymentReconciliation(
    id: '',
    reconciliationNumber: '',
    reconciliationDate: DateTime.now(),
    periodStart: DateTime.now(),
    periodEnd: DateTime.now(),
    status: ReconciliationStatus.pending,
    expectedAmount: 0.0,
    actualAmount: 0.0,
    discrepancyAmount: 0.0,
    totalTransactions: 0,
    matchedTransactions: 0,
    unmatchedTransactions: 0,
    partialMatchTransactions: 0,
    currency: 'USD',
  );
}

enum ReconciliationStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
  @JsonValue('requires_review')
  requiresReview,
  @JsonValue('cancelled')
  cancelled,
}

@freezed
abstract class ReconciliationTransaction with _$ReconciliationTransaction {
  const factory ReconciliationTransaction({
    required String id,
    required String transactionId,
    required String transactionReference,
    required DateTime transactionDate,
    required double transactionAmount,
    required String transactionCurrency,
    required TransactionSource source,
    required TransactionStatus status,
    String? invoiceId,
    String? invoiceNumber,
    double? invoiceAmount,
    String? invoiceCurrency,
    DateTime? invoiceDate,
    String? companyId,
    String? companyName,
    double? matchedAmount,
    double? discrepancyAmount,
    ReconciliationMatchStatus? matchStatus,
    String? matchNotes,
    DateTime? matchedAt,
    String? matchedByAdminId,
    String? matchedByAdminName,
    Map<String, dynamic>? transactionMetadata,
    Map<String, dynamic>? matchMetadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ReconciliationTransaction;

  factory ReconciliationTransaction.fromJson(Map<String, dynamic> json) =>
      _$ReconciliationTransactionFromJson(json);
}

enum TransactionSource {
  @JsonValue('bank_transfer')
  bankTransfer,
  @JsonValue('credit_card')
  creditCard,
  @JsonValue('payment_gateway')
  paymentGateway,
  @JsonValue('wallet')
  wallet,
  @JsonValue('cash')
  cash,
  @JsonValue('other')
  other,
}

enum TransactionStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('completed')
  completed,
  @JsonValue('failed')
  failed,
  @JsonValue('refunded')
  refunded,
  @JsonValue('cancelled')
  cancelled,
}

enum ReconciliationMatchStatus {
  @JsonValue('matched')
  matched,
  @JsonValue('unmatched')
  unmatched,
  @JsonValue('partial_match')
  partialMatch,
  @JsonValue('requires_review')
  requiresReview,
}

@freezed
abstract class ReconciliationSummary with _$ReconciliationSummary {
  const factory ReconciliationSummary({
    @Default(0.0) double totalExpected,
    @Default(0.0) double totalActual,
    @Default(0.0) double totalDiscrepancy,
    @Default(0) int totalReconciliations,
    @Default(0) int pendingReconciliations,
    @Default(0) int completedReconciliations,
    @Default(0) int requiresReviewReconciliations,
    @Default(0) int totalTransactions,
    @Default(0) int matchedTransactions,
    @Default(0) int unmatchedTransactions,
    @Default(0) int partialMatchTransactions,
    DateTime? periodStart,
    DateTime? periodEnd,
    Map<TransactionSource, double>? amountBySource,
    Map<TransactionSource, int>? countBySource,
    List<ReconciliationTrendData>? trendData,
  }) = _ReconciliationSummary;

  factory ReconciliationSummary.fromJson(Map<String, dynamic> json) =>
      _$ReconciliationSummaryFromJson(json);
}

@freezed
abstract class ReconciliationTrendData with _$ReconciliationTrendData {
  const factory ReconciliationTrendData({
    required DateTime date,
    required double expectedAmount,
    required double actualAmount,
    required double discrepancyAmount,
    required int transactionCount,
    required int matchedCount,
    required int unmatchedCount,
  }) = _ReconciliationTrendData;

  factory ReconciliationTrendData.fromJson(Map<String, dynamic> json) =>
      _$ReconciliationTrendDataFromJson(json);
}

@freezed
abstract class ReconciliationDiscrepancy with _$ReconciliationDiscrepancy {
  const factory ReconciliationDiscrepancy({
    required String id,
    required String reconciliationId,
    required String transactionId,
    required String transactionReference,
    required DateTime transactionDate,
    required double transactionAmount,
    required double expectedAmount,
    required double discrepancyAmount,
    required DiscrepancyType type,
    required DiscrepancySeverity severity,
    String? invoiceId,
    String? invoiceNumber,
    String? companyId,
    String? companyName,
    String? notes,
    String? resolvedByAdminId,
    String? resolvedByAdminName,
    DateTime? resolvedAt,
    DiscrepancyResolution? resolution,
    String? resolutionNotes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ReconciliationDiscrepancy;

  factory ReconciliationDiscrepancy.fromJson(Map<String, dynamic> json) =>
      _$ReconciliationDiscrepancyFromJson(json);
}

enum DiscrepancyType {
  @JsonValue('amount_mismatch')
  amountMismatch,
  @JsonValue('currency_mismatch')
  currencyMismatch,
  @JsonValue('date_mismatch')
  dateMismatch,
  @JsonValue('missing_transaction')
  missingTransaction,
  @JsonValue('duplicate_transaction')
  duplicateTransaction,
  @JsonValue('unmatched_transaction')
  unmatchedTransaction,
  @JsonValue('other')
  other,
}

enum DiscrepancySeverity {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('critical')
  critical,
}

enum DiscrepancyResolution {
  @JsonValue('adjusted')
  adjusted,
  @JsonValue('waived')
  waived,
  @JsonValue('reconciled')
  reconciled,
  @JsonValue('requires_followup')
  requiresFollowup,
  @JsonValue('cancelled')
  cancelled,
}

@freezed
abstract class ReconciliationFilter with _$ReconciliationFilter {
  const factory ReconciliationFilter({
    DateTime? startDate,
    DateTime? endDate,
    List<ReconciliationStatus>? statuses,
    List<TransactionSource>? sources,
    String? searchQuery,
    double? minDiscrepancy,
    double? maxDiscrepancy,
    @Default('reconciliationDate') String sortBy,
    @Default(true) bool sortDesc,
    @Default(1) int page,
    @Default(20) int limit,
  }) = _ReconciliationFilter;

  factory ReconciliationFilter.fromJson(Map<String, dynamic> json) =>
      _$ReconciliationFilterFromJson(json);
}

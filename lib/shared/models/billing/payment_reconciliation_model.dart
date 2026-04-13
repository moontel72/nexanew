import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_reconciliation_model.freezed.dart';
part 'payment_reconciliation_model.g.dart';

enum ReconciliationStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('matched')
  matched,
  @JsonValue('discrepancy')
  discrepancy,
  @JsonValue('resolved')
  resolved,
  @JsonValue('cancelled')
  cancelled,
}

enum DiscrepancyType {
  @JsonValue('amount_mismatch')
  amountMismatch,
  @JsonValue('missing_payment')
  missingPayment,
  @JsonValue('duplicate_payment')
  duplicatePayment,
  @JsonValue('currency_mismatch')
  currencyMismatch,
  @JsonValue('date_mismatch')
  dateMismatch,
  @JsonValue('other')
  other,
}

@freezed
abstract class PaymentRecord with _$PaymentRecord {
  const factory PaymentRecord({
    required String id,
    required String transactionId,
    required double amount,
    required String currency,
    required DateTime transactionDate,
    required String paymentMethod,
    String? gatewayReference,
    String? customerReference,
    String? invoiceReference,
    String? description,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) = _PaymentRecord;

  factory PaymentRecord.fromJson(Map<String, dynamic> json) =>
      _$PaymentRecordFromJson(json);
}

@freezed
abstract class ReconciliationMatch with _$ReconciliationMatch {
  const factory ReconciliationMatch({
    required String paymentId,
    required String gatewayRecordId,
    required double matchedAmount,
    required String matchedCurrency,
    required DateTime matchDate,
    String? notes,
    Map<String, dynamic>? metadata,
  }) = _ReconciliationMatch;

  factory ReconciliationMatch.fromJson(Map<String, dynamic> json) =>
      _$ReconciliationMatchFromJson(json);
}

@freezed
abstract class ReconciliationDiscrepancy with _$ReconciliationDiscrepancy {
  const factory ReconciliationDiscrepancy({
    required String id,
    required DiscrepancyType type,
    required String description,
    required double internalAmount,
    required double gatewayAmount,
    required String currency,
    required DateTime transactionDate,
    String? paymentId,
    String? gatewayRecordId,
    String? suggestedResolution,
    String? resolvedBy,
    DateTime? resolvedAt,
    String? resolutionNotes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ReconciliationDiscrepancy;

  factory ReconciliationDiscrepancy.fromJson(Map<String, dynamic> json) =>
      _$ReconciliationDiscrepancyFromJson(json);
}

@freezed
abstract class PaymentReconciliation with _$PaymentReconciliation {
  const factory PaymentReconciliation({
    required String id,
    required DateTime reconciliationDate,
    required DateTime periodStart,
    required DateTime periodEnd,
    required ReconciliationStatus status,
    required double totalGatewayAmount,
    required double totalInternalAmount,
    required String currency,
    required List<PaymentRecord> gatewayRecords,
    required List<PaymentRecord> internalRecords,
    required List<ReconciliationMatch> matches,
    required List<ReconciliationDiscrepancy> discrepancies,
    String? notes,
    String? performedBy,
    DateTime? completedAt,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _PaymentReconciliation;

  factory PaymentReconciliation.fromJson(Map<String, dynamic> json) =>
      _$PaymentReconciliationFromJson(json);

  factory PaymentReconciliation.empty() => PaymentReconciliation(
    id: '',
    reconciliationDate: DateTime.now(),
    periodStart: DateTime.now(),
    periodEnd: DateTime.now(),
    status: ReconciliationStatus.pending,
    totalGatewayAmount: 0.0,
    totalInternalAmount: 0.0,
    currency: 'USD',
    gatewayRecords: [],
    internalRecords: [],
    matches: [],
    discrepancies: [],
  );
}

@freezed
abstract class ReconciliationSummary with _$ReconciliationSummary {
  const factory ReconciliationSummary({
    @Default(0.0) double totalReconciled,
    @Default(0.0) double totalDiscrepancies,
    @Default(0) int pendingReconciliations,
    @Default(0) int completedReconciliations,
    @Default(0) int totalDiscrepancyCount,
    @Default(0) int resolvedDiscrepancyCount,
    Map<String, int>? discrepanciesByType,
    Map<String, double>? discrepanciesByAmount,
    DateTime? lastReconciliationDate,
    DateTime? nextScheduledReconciliation,
  }) = _ReconciliationSummary;

  factory ReconciliationSummary.fromJson(Map<String, dynamic> json) =>
      _$ReconciliationSummaryFromJson(json);
}

@freezed
abstract class ReconciliationFilter with _$ReconciliationFilter {
  const factory ReconciliationFilter({
    DateTime? startDate,
    DateTime? endDate,
    List<ReconciliationStatus>? statuses,
    List<DiscrepancyType>? discrepancyTypes,
    double? minAmount,
    double? maxAmount,
    String? searchQuery,
    @Default('reconciliationDate') String sortBy,
    @Default(false) bool sortDesc,
    @Default(1) int page,
    @Default(20) int limit,
  }) = _ReconciliationFilter;

  factory ReconciliationFilter.fromJson(Map<String, dynamic> json) =>
      _$ReconciliationFilterFromJson(json);
}


// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_reconciliation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaymentReconciliation _$PaymentReconciliationFromJson(
  Map<String, dynamic> json,
) => _PaymentReconciliation(
  id: json['id'] as String,
  reconciliationNumber: json['reconciliation_number'] as String,
  reconciliationDate: DateTime.parse(json['reconciliation_date'] as String),
  periodStart: DateTime.parse(json['period_start'] as String),
  periodEnd: DateTime.parse(json['period_end'] as String),
  status: $enumDecode(_$ReconciliationStatusEnumMap, json['status']),
  expectedAmount: (json['expected_amount'] as num).toDouble(),
  actualAmount: (json['actual_amount'] as num).toDouble(),
  discrepancyAmount: (json['discrepancy_amount'] as num).toDouble(),
  totalTransactions: (json['total_transactions'] as num).toInt(),
  matchedTransactions: (json['matched_transactions'] as num).toInt(),
  unmatchedTransactions: (json['unmatched_transactions'] as num).toInt(),
  partialMatchTransactions: (json['partial_match_transactions'] as num).toInt(),
  currency: json['currency'] as String,
  notes: json['notes'] as String?,
  performedByAdminId: json['performed_by_admin_id'] as String?,
  performedByAdminName: json['performed_by_admin_name'] as String?,
  completedAt: json['completed_at'] == null
      ? null
      : DateTime.parse(json['completed_at'] as String),
  reviewedAt: json['reviewed_at'] == null
      ? null
      : DateTime.parse(json['reviewed_at'] as String),
  reviewedByAdminId: json['reviewed_by_admin_id'] as String?,
  reviewedByAdminName: json['reviewed_by_admin_name'] as String?,
  transactions: (json['transactions'] as List<dynamic>?)
      ?.map(
        (e) => ReconciliationTransaction.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$PaymentReconciliationToJson(
  _PaymentReconciliation instance,
) => <String, dynamic>{
  'id': instance.id,
  'reconciliation_number': instance.reconciliationNumber,
  'reconciliation_date': instance.reconciliationDate.toIso8601String(),
  'period_start': instance.periodStart.toIso8601String(),
  'period_end': instance.periodEnd.toIso8601String(),
  'status': _$ReconciliationStatusEnumMap[instance.status]!,
  'expected_amount': instance.expectedAmount,
  'actual_amount': instance.actualAmount,
  'discrepancy_amount': instance.discrepancyAmount,
  'total_transactions': instance.totalTransactions,
  'matched_transactions': instance.matchedTransactions,
  'unmatched_transactions': instance.unmatchedTransactions,
  'partial_match_transactions': instance.partialMatchTransactions,
  'currency': instance.currency,
  'notes': instance.notes,
  'performed_by_admin_id': instance.performedByAdminId,
  'performed_by_admin_name': instance.performedByAdminName,
  'completed_at': instance.completedAt?.toIso8601String(),
  'reviewed_at': instance.reviewedAt?.toIso8601String(),
  'reviewed_by_admin_id': instance.reviewedByAdminId,
  'reviewed_by_admin_name': instance.reviewedByAdminName,
  'transactions': instance.transactions?.map((e) => e.toJson()).toList(),
  'metadata': instance.metadata,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};

const _$ReconciliationStatusEnumMap = {
  ReconciliationStatus.pending: 'pending',
  ReconciliationStatus.inProgress: 'in_progress',
  ReconciliationStatus.completed: 'completed',
  ReconciliationStatus.requiresReview: 'requires_review',
  ReconciliationStatus.cancelled: 'cancelled',
};

_ReconciliationTransaction _$ReconciliationTransactionFromJson(
  Map<String, dynamic> json,
) => _ReconciliationTransaction(
  id: json['id'] as String,
  transactionId: json['transaction_id'] as String,
  transactionReference: json['transaction_reference'] as String,
  transactionDate: DateTime.parse(json['transaction_date'] as String),
  transactionAmount: (json['transaction_amount'] as num).toDouble(),
  transactionCurrency: json['transaction_currency'] as String,
  source: $enumDecode(_$TransactionSourceEnumMap, json['source']),
  status: $enumDecode(_$TransactionStatusEnumMap, json['status']),
  invoiceId: json['invoice_id'] as String?,
  invoiceNumber: json['invoice_number'] as String?,
  invoiceAmount: (json['invoice_amount'] as num?)?.toDouble(),
  invoiceCurrency: json['invoice_currency'] as String?,
  invoiceDate: json['invoice_date'] == null
      ? null
      : DateTime.parse(json['invoice_date'] as String),
  companyId: json['company_id'] as String?,
  companyName: json['company_name'] as String?,
  matchedAmount: (json['matched_amount'] as num?)?.toDouble(),
  discrepancyAmount: (json['discrepancy_amount'] as num?)?.toDouble(),
  matchStatus: $enumDecodeNullable(
    _$ReconciliationMatchStatusEnumMap,
    json['match_status'],
  ),
  matchNotes: json['match_notes'] as String?,
  matchedAt: json['matched_at'] == null
      ? null
      : DateTime.parse(json['matched_at'] as String),
  matchedByAdminId: json['matched_by_admin_id'] as String?,
  matchedByAdminName: json['matched_by_admin_name'] as String?,
  transactionMetadata: json['transaction_metadata'] as Map<String, dynamic>?,
  matchMetadata: json['match_metadata'] as Map<String, dynamic>?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ReconciliationTransactionToJson(
  _ReconciliationTransaction instance,
) => <String, dynamic>{
  'id': instance.id,
  'transaction_id': instance.transactionId,
  'transaction_reference': instance.transactionReference,
  'transaction_date': instance.transactionDate.toIso8601String(),
  'transaction_amount': instance.transactionAmount,
  'transaction_currency': instance.transactionCurrency,
  'source': _$TransactionSourceEnumMap[instance.source]!,
  'status': _$TransactionStatusEnumMap[instance.status]!,
  'invoice_id': instance.invoiceId,
  'invoice_number': instance.invoiceNumber,
  'invoice_amount': instance.invoiceAmount,
  'invoice_currency': instance.invoiceCurrency,
  'invoice_date': instance.invoiceDate?.toIso8601String(),
  'company_id': instance.companyId,
  'company_name': instance.companyName,
  'matched_amount': instance.matchedAmount,
  'discrepancy_amount': instance.discrepancyAmount,
  'match_status': _$ReconciliationMatchStatusEnumMap[instance.matchStatus],
  'match_notes': instance.matchNotes,
  'matched_at': instance.matchedAt?.toIso8601String(),
  'matched_by_admin_id': instance.matchedByAdminId,
  'matched_by_admin_name': instance.matchedByAdminName,
  'transaction_metadata': instance.transactionMetadata,
  'match_metadata': instance.matchMetadata,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};

const _$TransactionSourceEnumMap = {
  TransactionSource.bankTransfer: 'bank_transfer',
  TransactionSource.creditCard: 'credit_card',
  TransactionSource.paymentGateway: 'payment_gateway',
  TransactionSource.wallet: 'wallet',
  TransactionSource.cash: 'cash',
  TransactionSource.other: 'other',
};

const _$TransactionStatusEnumMap = {
  TransactionStatus.pending: 'pending',
  TransactionStatus.completed: 'completed',
  TransactionStatus.failed: 'failed',
  TransactionStatus.refunded: 'refunded',
  TransactionStatus.cancelled: 'cancelled',
};

const _$ReconciliationMatchStatusEnumMap = {
  ReconciliationMatchStatus.matched: 'matched',
  ReconciliationMatchStatus.unmatched: 'unmatched',
  ReconciliationMatchStatus.partialMatch: 'partial_match',
  ReconciliationMatchStatus.requiresReview: 'requires_review',
};

_ReconciliationSummary _$ReconciliationSummaryFromJson(
  Map<String, dynamic> json,
) => _ReconciliationSummary(
  totalExpected: (json['total_expected'] as num?)?.toDouble() ?? 0.0,
  totalActual: (json['total_actual'] as num?)?.toDouble() ?? 0.0,
  totalDiscrepancy: (json['total_discrepancy'] as num?)?.toDouble() ?? 0.0,
  totalReconciliations: (json['total_reconciliations'] as num?)?.toInt() ?? 0,
  pendingReconciliations:
      (json['pending_reconciliations'] as num?)?.toInt() ?? 0,
  completedReconciliations:
      (json['completed_reconciliations'] as num?)?.toInt() ?? 0,
  requiresReviewReconciliations:
      (json['requires_review_reconciliations'] as num?)?.toInt() ?? 0,
  totalTransactions: (json['total_transactions'] as num?)?.toInt() ?? 0,
  matchedTransactions: (json['matched_transactions'] as num?)?.toInt() ?? 0,
  unmatchedTransactions: (json['unmatched_transactions'] as num?)?.toInt() ?? 0,
  partialMatchTransactions:
      (json['partial_match_transactions'] as num?)?.toInt() ?? 0,
  periodStart: json['period_start'] == null
      ? null
      : DateTime.parse(json['period_start'] as String),
  periodEnd: json['period_end'] == null
      ? null
      : DateTime.parse(json['period_end'] as String),
  amountBySource: (json['amount_by_source'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(
      $enumDecode(_$TransactionSourceEnumMap, k),
      (e as num).toDouble(),
    ),
  ),
  countBySource: (json['count_by_source'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(
      $enumDecode(_$TransactionSourceEnumMap, k),
      (e as num).toInt(),
    ),
  ),
  trendData: (json['trend_data'] as List<dynamic>?)
      ?.map((e) => ReconciliationTrendData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ReconciliationSummaryToJson(
  _ReconciliationSummary instance,
) => <String, dynamic>{
  'total_expected': instance.totalExpected,
  'total_actual': instance.totalActual,
  'total_discrepancy': instance.totalDiscrepancy,
  'total_reconciliations': instance.totalReconciliations,
  'pending_reconciliations': instance.pendingReconciliations,
  'completed_reconciliations': instance.completedReconciliations,
  'requires_review_reconciliations': instance.requiresReviewReconciliations,
  'total_transactions': instance.totalTransactions,
  'matched_transactions': instance.matchedTransactions,
  'unmatched_transactions': instance.unmatchedTransactions,
  'partial_match_transactions': instance.partialMatchTransactions,
  'period_start': instance.periodStart?.toIso8601String(),
  'period_end': instance.periodEnd?.toIso8601String(),
  'amount_by_source': instance.amountBySource?.map(
    (k, e) => MapEntry(_$TransactionSourceEnumMap[k]!, e),
  ),
  'count_by_source': instance.countBySource?.map(
    (k, e) => MapEntry(_$TransactionSourceEnumMap[k]!, e),
  ),
  'trend_data': instance.trendData?.map((e) => e.toJson()).toList(),
};

_ReconciliationTrendData _$ReconciliationTrendDataFromJson(
  Map<String, dynamic> json,
) => _ReconciliationTrendData(
  date: DateTime.parse(json['date'] as String),
  expectedAmount: (json['expected_amount'] as num).toDouble(),
  actualAmount: (json['actual_amount'] as num).toDouble(),
  discrepancyAmount: (json['discrepancy_amount'] as num).toDouble(),
  transactionCount: (json['transaction_count'] as num).toInt(),
  matchedCount: (json['matched_count'] as num).toInt(),
  unmatchedCount: (json['unmatched_count'] as num).toInt(),
);

Map<String, dynamic> _$ReconciliationTrendDataToJson(
  _ReconciliationTrendData instance,
) => <String, dynamic>{
  'date': instance.date.toIso8601String(),
  'expected_amount': instance.expectedAmount,
  'actual_amount': instance.actualAmount,
  'discrepancy_amount': instance.discrepancyAmount,
  'transaction_count': instance.transactionCount,
  'matched_count': instance.matchedCount,
  'unmatched_count': instance.unmatchedCount,
};

_ReconciliationDiscrepancy _$ReconciliationDiscrepancyFromJson(
  Map<String, dynamic> json,
) => _ReconciliationDiscrepancy(
  id: json['id'] as String,
  reconciliationId: json['reconciliation_id'] as String,
  transactionId: json['transaction_id'] as String,
  transactionReference: json['transaction_reference'] as String,
  transactionDate: DateTime.parse(json['transaction_date'] as String),
  transactionAmount: (json['transaction_amount'] as num).toDouble(),
  expectedAmount: (json['expected_amount'] as num).toDouble(),
  discrepancyAmount: (json['discrepancy_amount'] as num).toDouble(),
  type: $enumDecode(_$DiscrepancyTypeEnumMap, json['type']),
  severity: $enumDecode(_$DiscrepancySeverityEnumMap, json['severity']),
  invoiceId: json['invoice_id'] as String?,
  invoiceNumber: json['invoice_number'] as String?,
  companyId: json['company_id'] as String?,
  companyName: json['company_name'] as String?,
  notes: json['notes'] as String?,
  resolvedByAdminId: json['resolved_by_admin_id'] as String?,
  resolvedByAdminName: json['resolved_by_admin_name'] as String?,
  resolvedAt: json['resolved_at'] == null
      ? null
      : DateTime.parse(json['resolved_at'] as String),
  resolution: $enumDecodeNullable(
    _$DiscrepancyResolutionEnumMap,
    json['resolution'],
  ),
  resolutionNotes: json['resolution_notes'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ReconciliationDiscrepancyToJson(
  _ReconciliationDiscrepancy instance,
) => <String, dynamic>{
  'id': instance.id,
  'reconciliation_id': instance.reconciliationId,
  'transaction_id': instance.transactionId,
  'transaction_reference': instance.transactionReference,
  'transaction_date': instance.transactionDate.toIso8601String(),
  'transaction_amount': instance.transactionAmount,
  'expected_amount': instance.expectedAmount,
  'discrepancy_amount': instance.discrepancyAmount,
  'type': _$DiscrepancyTypeEnumMap[instance.type]!,
  'severity': _$DiscrepancySeverityEnumMap[instance.severity]!,
  'invoice_id': instance.invoiceId,
  'invoice_number': instance.invoiceNumber,
  'company_id': instance.companyId,
  'company_name': instance.companyName,
  'notes': instance.notes,
  'resolved_by_admin_id': instance.resolvedByAdminId,
  'resolved_by_admin_name': instance.resolvedByAdminName,
  'resolved_at': instance.resolvedAt?.toIso8601String(),
  'resolution': _$DiscrepancyResolutionEnumMap[instance.resolution],
  'resolution_notes': instance.resolutionNotes,
  'metadata': instance.metadata,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};

const _$DiscrepancyTypeEnumMap = {
  DiscrepancyType.amountMismatch: 'amount_mismatch',
  DiscrepancyType.currencyMismatch: 'currency_mismatch',
  DiscrepancyType.dateMismatch: 'date_mismatch',
  DiscrepancyType.missingTransaction: 'missing_transaction',
  DiscrepancyType.duplicateTransaction: 'duplicate_transaction',
  DiscrepancyType.unmatchedTransaction: 'unmatched_transaction',
  DiscrepancyType.other: 'other',
};

const _$DiscrepancySeverityEnumMap = {
  DiscrepancySeverity.low: 'low',
  DiscrepancySeverity.medium: 'medium',
  DiscrepancySeverity.high: 'high',
  DiscrepancySeverity.critical: 'critical',
};

const _$DiscrepancyResolutionEnumMap = {
  DiscrepancyResolution.adjusted: 'adjusted',
  DiscrepancyResolution.waived: 'waived',
  DiscrepancyResolution.reconciled: 'reconciled',
  DiscrepancyResolution.requiresFollowup: 'requires_followup',
  DiscrepancyResolution.cancelled: 'cancelled',
};

_ReconciliationFilter _$ReconciliationFilterFromJson(
  Map<String, dynamic> json,
) => _ReconciliationFilter(
  startDate: json['start_date'] == null
      ? null
      : DateTime.parse(json['start_date'] as String),
  endDate: json['end_date'] == null
      ? null
      : DateTime.parse(json['end_date'] as String),
  statuses: (json['statuses'] as List<dynamic>?)
      ?.map((e) => $enumDecode(_$ReconciliationStatusEnumMap, e))
      .toList(),
  sources: (json['sources'] as List<dynamic>?)
      ?.map((e) => $enumDecode(_$TransactionSourceEnumMap, e))
      .toList(),
  searchQuery: json['search_query'] as String?,
  minDiscrepancy: (json['min_discrepancy'] as num?)?.toDouble(),
  maxDiscrepancy: (json['max_discrepancy'] as num?)?.toDouble(),
  sortBy: json['sort_by'] as String? ?? 'reconciliationDate',
  sortDesc: json['sort_desc'] as bool? ?? true,
  page: (json['page'] as num?)?.toInt() ?? 1,
  limit: (json['limit'] as num?)?.toInt() ?? 20,
);

Map<String, dynamic> _$ReconciliationFilterToJson(
  _ReconciliationFilter instance,
) => <String, dynamic>{
  'start_date': instance.startDate?.toIso8601String(),
  'end_date': instance.endDate?.toIso8601String(),
  'statuses': instance.statuses
      ?.map((e) => _$ReconciliationStatusEnumMap[e]!)
      .toList(),
  'sources': instance.sources
      ?.map((e) => _$TransactionSourceEnumMap[e]!)
      .toList(),
  'search_query': instance.searchQuery,
  'min_discrepancy': instance.minDiscrepancy,
  'max_discrepancy': instance.maxDiscrepancy,
  'sort_by': instance.sortBy,
  'sort_desc': instance.sortDesc,
  'page': instance.page,
  'limit': instance.limit,
};

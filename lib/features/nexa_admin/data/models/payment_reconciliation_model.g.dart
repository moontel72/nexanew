// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_reconciliation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaymentReconciliation _$PaymentReconciliationFromJson(
  Map<String, dynamic> json,
) => _PaymentReconciliation(
  id: json['id'] as String,
  reconciliationNumber: json['reconciliationNumber'] as String,
  reconciliationDate: DateTime.parse(json['reconciliationDate'] as String),
  periodStart: DateTime.parse(json['periodStart'] as String),
  periodEnd: DateTime.parse(json['periodEnd'] as String),
  status: $enumDecode(_$ReconciliationStatusEnumMap, json['status']),
  expectedAmount: (json['expectedAmount'] as num).toDouble(),
  actualAmount: (json['actualAmount'] as num).toDouble(),
  discrepancyAmount: (json['discrepancyAmount'] as num).toDouble(),
  totalTransactions: (json['totalTransactions'] as num).toInt(),
  matchedTransactions: (json['matchedTransactions'] as num).toInt(),
  unmatchedTransactions: (json['unmatchedTransactions'] as num).toInt(),
  partialMatchTransactions: (json['partialMatchTransactions'] as num).toInt(),
  currency: json['currency'] as String,
  notes: json['notes'] as String?,
  performedByAdminId: json['performedByAdminId'] as String?,
  performedByAdminName: json['performedByAdminName'] as String?,
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  reviewedAt: json['reviewedAt'] == null
      ? null
      : DateTime.parse(json['reviewedAt'] as String),
  reviewedByAdminId: json['reviewedByAdminId'] as String?,
  reviewedByAdminName: json['reviewedByAdminName'] as String?,
  transactions: (json['transactions'] as List<dynamic>?)
      ?.map(
        (e) => ReconciliationTransaction.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$PaymentReconciliationToJson(
  _PaymentReconciliation instance,
) => <String, dynamic>{
  'id': instance.id,
  'reconciliationNumber': instance.reconciliationNumber,
  'reconciliationDate': instance.reconciliationDate.toIso8601String(),
  'periodStart': instance.periodStart.toIso8601String(),
  'periodEnd': instance.periodEnd.toIso8601String(),
  'status': _$ReconciliationStatusEnumMap[instance.status]!,
  'expectedAmount': instance.expectedAmount,
  'actualAmount': instance.actualAmount,
  'discrepancyAmount': instance.discrepancyAmount,
  'totalTransactions': instance.totalTransactions,
  'matchedTransactions': instance.matchedTransactions,
  'unmatchedTransactions': instance.unmatchedTransactions,
  'partialMatchTransactions': instance.partialMatchTransactions,
  'currency': instance.currency,
  'notes': instance.notes,
  'performedByAdminId': instance.performedByAdminId,
  'performedByAdminName': instance.performedByAdminName,
  'completedAt': instance.completedAt?.toIso8601String(),
  'reviewedAt': instance.reviewedAt?.toIso8601String(),
  'reviewedByAdminId': instance.reviewedByAdminId,
  'reviewedByAdminName': instance.reviewedByAdminName,
  'transactions': instance.transactions,
  'metadata': instance.metadata,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
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
  transactionId: json['transactionId'] as String,
  transactionReference: json['transactionReference'] as String,
  transactionDate: DateTime.parse(json['transactionDate'] as String),
  transactionAmount: (json['transactionAmount'] as num).toDouble(),
  transactionCurrency: json['transactionCurrency'] as String,
  source: $enumDecode(_$TransactionSourceEnumMap, json['source']),
  status: $enumDecode(_$TransactionStatusEnumMap, json['status']),
  invoiceId: json['invoiceId'] as String?,
  invoiceNumber: json['invoiceNumber'] as String?,
  invoiceAmount: (json['invoiceAmount'] as num?)?.toDouble(),
  invoiceCurrency: json['invoiceCurrency'] as String?,
  invoiceDate: json['invoiceDate'] == null
      ? null
      : DateTime.parse(json['invoiceDate'] as String),
  companyId: json['companyId'] as String?,
  companyName: json['companyName'] as String?,
  matchedAmount: (json['matchedAmount'] as num?)?.toDouble(),
  discrepancyAmount: (json['discrepancyAmount'] as num?)?.toDouble(),
  matchStatus: $enumDecodeNullable(
    _$ReconciliationMatchStatusEnumMap,
    json['matchStatus'],
  ),
  matchNotes: json['matchNotes'] as String?,
  matchedAt: json['matchedAt'] == null
      ? null
      : DateTime.parse(json['matchedAt'] as String),
  matchedByAdminId: json['matchedByAdminId'] as String?,
  matchedByAdminName: json['matchedByAdminName'] as String?,
  transactionMetadata: json['transactionMetadata'] as Map<String, dynamic>?,
  matchMetadata: json['matchMetadata'] as Map<String, dynamic>?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ReconciliationTransactionToJson(
  _ReconciliationTransaction instance,
) => <String, dynamic>{
  'id': instance.id,
  'transactionId': instance.transactionId,
  'transactionReference': instance.transactionReference,
  'transactionDate': instance.transactionDate.toIso8601String(),
  'transactionAmount': instance.transactionAmount,
  'transactionCurrency': instance.transactionCurrency,
  'source': _$TransactionSourceEnumMap[instance.source]!,
  'status': _$TransactionStatusEnumMap[instance.status]!,
  'invoiceId': instance.invoiceId,
  'invoiceNumber': instance.invoiceNumber,
  'invoiceAmount': instance.invoiceAmount,
  'invoiceCurrency': instance.invoiceCurrency,
  'invoiceDate': instance.invoiceDate?.toIso8601String(),
  'companyId': instance.companyId,
  'companyName': instance.companyName,
  'matchedAmount': instance.matchedAmount,
  'discrepancyAmount': instance.discrepancyAmount,
  'matchStatus': _$ReconciliationMatchStatusEnumMap[instance.matchStatus],
  'matchNotes': instance.matchNotes,
  'matchedAt': instance.matchedAt?.toIso8601String(),
  'matchedByAdminId': instance.matchedByAdminId,
  'matchedByAdminName': instance.matchedByAdminName,
  'transactionMetadata': instance.transactionMetadata,
  'matchMetadata': instance.matchMetadata,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
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
  totalExpected: (json['totalExpected'] as num?)?.toDouble() ?? 0.0,
  totalActual: (json['totalActual'] as num?)?.toDouble() ?? 0.0,
  totalDiscrepancy: (json['totalDiscrepancy'] as num?)?.toDouble() ?? 0.0,
  totalReconciliations: (json['totalReconciliations'] as num?)?.toInt() ?? 0,
  pendingReconciliations:
      (json['pendingReconciliations'] as num?)?.toInt() ?? 0,
  completedReconciliations:
      (json['completedReconciliations'] as num?)?.toInt() ?? 0,
  requiresReviewReconciliations:
      (json['requiresReviewReconciliations'] as num?)?.toInt() ?? 0,
  totalTransactions: (json['totalTransactions'] as num?)?.toInt() ?? 0,
  matchedTransactions: (json['matchedTransactions'] as num?)?.toInt() ?? 0,
  unmatchedTransactions: (json['unmatchedTransactions'] as num?)?.toInt() ?? 0,
  partialMatchTransactions:
      (json['partialMatchTransactions'] as num?)?.toInt() ?? 0,
  periodStart: json['periodStart'] == null
      ? null
      : DateTime.parse(json['periodStart'] as String),
  periodEnd: json['periodEnd'] == null
      ? null
      : DateTime.parse(json['periodEnd'] as String),
  amountBySource: (json['amountBySource'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(
      $enumDecode(_$TransactionSourceEnumMap, k),
      (e as num).toDouble(),
    ),
  ),
  countBySource: (json['countBySource'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(
      $enumDecode(_$TransactionSourceEnumMap, k),
      (e as num).toInt(),
    ),
  ),
  trendData: (json['trendData'] as List<dynamic>?)
      ?.map((e) => ReconciliationTrendData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ReconciliationSummaryToJson(
  _ReconciliationSummary instance,
) => <String, dynamic>{
  'totalExpected': instance.totalExpected,
  'totalActual': instance.totalActual,
  'totalDiscrepancy': instance.totalDiscrepancy,
  'totalReconciliations': instance.totalReconciliations,
  'pendingReconciliations': instance.pendingReconciliations,
  'completedReconciliations': instance.completedReconciliations,
  'requiresReviewReconciliations': instance.requiresReviewReconciliations,
  'totalTransactions': instance.totalTransactions,
  'matchedTransactions': instance.matchedTransactions,
  'unmatchedTransactions': instance.unmatchedTransactions,
  'partialMatchTransactions': instance.partialMatchTransactions,
  'periodStart': instance.periodStart?.toIso8601String(),
  'periodEnd': instance.periodEnd?.toIso8601String(),
  'amountBySource': instance.amountBySource?.map(
    (k, e) => MapEntry(_$TransactionSourceEnumMap[k]!, e),
  ),
  'countBySource': instance.countBySource?.map(
    (k, e) => MapEntry(_$TransactionSourceEnumMap[k]!, e),
  ),
  'trendData': instance.trendData,
};

_ReconciliationTrendData _$ReconciliationTrendDataFromJson(
  Map<String, dynamic> json,
) => _ReconciliationTrendData(
  date: DateTime.parse(json['date'] as String),
  expectedAmount: (json['expectedAmount'] as num).toDouble(),
  actualAmount: (json['actualAmount'] as num).toDouble(),
  discrepancyAmount: (json['discrepancyAmount'] as num).toDouble(),
  transactionCount: (json['transactionCount'] as num).toInt(),
  matchedCount: (json['matchedCount'] as num).toInt(),
  unmatchedCount: (json['unmatchedCount'] as num).toInt(),
);

Map<String, dynamic> _$ReconciliationTrendDataToJson(
  _ReconciliationTrendData instance,
) => <String, dynamic>{
  'date': instance.date.toIso8601String(),
  'expectedAmount': instance.expectedAmount,
  'actualAmount': instance.actualAmount,
  'discrepancyAmount': instance.discrepancyAmount,
  'transactionCount': instance.transactionCount,
  'matchedCount': instance.matchedCount,
  'unmatchedCount': instance.unmatchedCount,
};

_ReconciliationDiscrepancy _$ReconciliationDiscrepancyFromJson(
  Map<String, dynamic> json,
) => _ReconciliationDiscrepancy(
  id: json['id'] as String,
  reconciliationId: json['reconciliationId'] as String,
  transactionId: json['transactionId'] as String,
  transactionReference: json['transactionReference'] as String,
  transactionDate: DateTime.parse(json['transactionDate'] as String),
  transactionAmount: (json['transactionAmount'] as num).toDouble(),
  expectedAmount: (json['expectedAmount'] as num).toDouble(),
  discrepancyAmount: (json['discrepancyAmount'] as num).toDouble(),
  type: $enumDecode(_$DiscrepancyTypeEnumMap, json['type']),
  severity: $enumDecode(_$DiscrepancySeverityEnumMap, json['severity']),
  invoiceId: json['invoiceId'] as String?,
  invoiceNumber: json['invoiceNumber'] as String?,
  companyId: json['companyId'] as String?,
  companyName: json['companyName'] as String?,
  notes: json['notes'] as String?,
  resolvedByAdminId: json['resolvedByAdminId'] as String?,
  resolvedByAdminName: json['resolvedByAdminName'] as String?,
  resolvedAt: json['resolvedAt'] == null
      ? null
      : DateTime.parse(json['resolvedAt'] as String),
  resolution: $enumDecodeNullable(
    _$DiscrepancyResolutionEnumMap,
    json['resolution'],
  ),
  resolutionNotes: json['resolutionNotes'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ReconciliationDiscrepancyToJson(
  _ReconciliationDiscrepancy instance,
) => <String, dynamic>{
  'id': instance.id,
  'reconciliationId': instance.reconciliationId,
  'transactionId': instance.transactionId,
  'transactionReference': instance.transactionReference,
  'transactionDate': instance.transactionDate.toIso8601String(),
  'transactionAmount': instance.transactionAmount,
  'expectedAmount': instance.expectedAmount,
  'discrepancyAmount': instance.discrepancyAmount,
  'type': _$DiscrepancyTypeEnumMap[instance.type]!,
  'severity': _$DiscrepancySeverityEnumMap[instance.severity]!,
  'invoiceId': instance.invoiceId,
  'invoiceNumber': instance.invoiceNumber,
  'companyId': instance.companyId,
  'companyName': instance.companyName,
  'notes': instance.notes,
  'resolvedByAdminId': instance.resolvedByAdminId,
  'resolvedByAdminName': instance.resolvedByAdminName,
  'resolvedAt': instance.resolvedAt?.toIso8601String(),
  'resolution': _$DiscrepancyResolutionEnumMap[instance.resolution],
  'resolutionNotes': instance.resolutionNotes,
  'metadata': instance.metadata,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
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
  startDate: json['startDate'] == null
      ? null
      : DateTime.parse(json['startDate'] as String),
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
  statuses: (json['statuses'] as List<dynamic>?)
      ?.map((e) => $enumDecode(_$ReconciliationStatusEnumMap, e))
      .toList(),
  sources: (json['sources'] as List<dynamic>?)
      ?.map((e) => $enumDecode(_$TransactionSourceEnumMap, e))
      .toList(),
  searchQuery: json['searchQuery'] as String?,
  minDiscrepancy: (json['minDiscrepancy'] as num?)?.toDouble(),
  maxDiscrepancy: (json['maxDiscrepancy'] as num?)?.toDouble(),
  sortBy: json['sortBy'] as String? ?? 'reconciliationDate',
  sortDesc: json['sortDesc'] as bool? ?? true,
  page: (json['page'] as num?)?.toInt() ?? 1,
  limit: (json['limit'] as num?)?.toInt() ?? 20,
);

Map<String, dynamic> _$ReconciliationFilterToJson(
  _ReconciliationFilter instance,
) => <String, dynamic>{
  'startDate': instance.startDate?.toIso8601String(),
  'endDate': instance.endDate?.toIso8601String(),
  'statuses': instance.statuses
      ?.map((e) => _$ReconciliationStatusEnumMap[e]!)
      .toList(),
  'sources': instance.sources
      ?.map((e) => _$TransactionSourceEnumMap[e]!)
      .toList(),
  'searchQuery': instance.searchQuery,
  'minDiscrepancy': instance.minDiscrepancy,
  'maxDiscrepancy': instance.maxDiscrepancy,
  'sortBy': instance.sortBy,
  'sortDesc': instance.sortDesc,
  'page': instance.page,
  'limit': instance.limit,
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_reconciliation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaymentRecord _$PaymentRecordFromJson(Map<String, dynamic> json) =>
    _PaymentRecord(
      id: json['id'] as String,
      transactionId: json['transaction_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      paymentMethod: json['payment_method'] as String,
      gatewayReference: json['gateway_reference'] as String?,
      customerReference: json['customer_reference'] as String?,
      invoiceReference: json['invoice_reference'] as String?,
      description: json['description'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$PaymentRecordToJson(_PaymentRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'transaction_id': instance.transactionId,
      'amount': instance.amount,
      'currency': instance.currency,
      'transaction_date': instance.transactionDate.toIso8601String(),
      'payment_method': instance.paymentMethod,
      'gateway_reference': instance.gatewayReference,
      'customer_reference': instance.customerReference,
      'invoice_reference': instance.invoiceReference,
      'description': instance.description,
      'metadata': instance.metadata,
      'created_at': instance.createdAt?.toIso8601String(),
    };

_ReconciliationMatch _$ReconciliationMatchFromJson(Map<String, dynamic> json) =>
    _ReconciliationMatch(
      paymentId: json['payment_id'] as String,
      gatewayRecordId: json['gateway_record_id'] as String,
      matchedAmount: (json['matched_amount'] as num).toDouble(),
      matchedCurrency: json['matched_currency'] as String,
      matchDate: DateTime.parse(json['match_date'] as String),
      notes: json['notes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ReconciliationMatchToJson(
  _ReconciliationMatch instance,
) => <String, dynamic>{
  'payment_id': instance.paymentId,
  'gateway_record_id': instance.gatewayRecordId,
  'matched_amount': instance.matchedAmount,
  'matched_currency': instance.matchedCurrency,
  'match_date': instance.matchDate.toIso8601String(),
  'notes': instance.notes,
  'metadata': instance.metadata,
};

_ReconciliationDiscrepancy _$ReconciliationDiscrepancyFromJson(
  Map<String, dynamic> json,
) => _ReconciliationDiscrepancy(
  id: json['id'] as String,
  type: $enumDecode(_$DiscrepancyTypeEnumMap, json['type']),
  description: json['description'] as String,
  internalAmount: (json['internal_amount'] as num).toDouble(),
  gatewayAmount: (json['gateway_amount'] as num).toDouble(),
  currency: json['currency'] as String,
  transactionDate: DateTime.parse(json['transaction_date'] as String),
  paymentId: json['payment_id'] as String?,
  gatewayRecordId: json['gateway_record_id'] as String?,
  suggestedResolution: json['suggested_resolution'] as String?,
  resolvedBy: json['resolved_by'] as String?,
  resolvedAt: json['resolved_at'] == null
      ? null
      : DateTime.parse(json['resolved_at'] as String),
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
  'type': _$DiscrepancyTypeEnumMap[instance.type]!,
  'description': instance.description,
  'internal_amount': instance.internalAmount,
  'gateway_amount': instance.gatewayAmount,
  'currency': instance.currency,
  'transaction_date': instance.transactionDate.toIso8601String(),
  'payment_id': instance.paymentId,
  'gateway_record_id': instance.gatewayRecordId,
  'suggested_resolution': instance.suggestedResolution,
  'resolved_by': instance.resolvedBy,
  'resolved_at': instance.resolvedAt?.toIso8601String(),
  'resolution_notes': instance.resolutionNotes,
  'metadata': instance.metadata,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};

const _$DiscrepancyTypeEnumMap = {
  DiscrepancyType.amountMismatch: 'amount_mismatch',
  DiscrepancyType.missingPayment: 'missing_payment',
  DiscrepancyType.duplicatePayment: 'duplicate_payment',
  DiscrepancyType.currencyMismatch: 'currency_mismatch',
  DiscrepancyType.dateMismatch: 'date_mismatch',
  DiscrepancyType.other: 'other',
};

_PaymentReconciliation _$PaymentReconciliationFromJson(
  Map<String, dynamic> json,
) => _PaymentReconciliation(
  id: json['id'] as String,
  reconciliationDate: DateTime.parse(json['reconciliation_date'] as String),
  periodStart: DateTime.parse(json['period_start'] as String),
  periodEnd: DateTime.parse(json['period_end'] as String),
  status: $enumDecode(_$ReconciliationStatusEnumMap, json['status']),
  totalGatewayAmount: (json['total_gateway_amount'] as num).toDouble(),
  totalInternalAmount: (json['total_internal_amount'] as num).toDouble(),
  currency: json['currency'] as String,
  gatewayRecords: (json['gateway_records'] as List<dynamic>)
      .map((e) => PaymentRecord.fromJson(e as Map<String, dynamic>))
      .toList(),
  internalRecords: (json['internal_records'] as List<dynamic>)
      .map((e) => PaymentRecord.fromJson(e as Map<String, dynamic>))
      .toList(),
  matches: (json['matches'] as List<dynamic>)
      .map((e) => ReconciliationMatch.fromJson(e as Map<String, dynamic>))
      .toList(),
  discrepancies: (json['discrepancies'] as List<dynamic>)
      .map((e) => ReconciliationDiscrepancy.fromJson(e as Map<String, dynamic>))
      .toList(),
  notes: json['notes'] as String?,
  performedBy: json['performed_by'] as String?,
  completedAt: json['completed_at'] == null
      ? null
      : DateTime.parse(json['completed_at'] as String),
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
  'reconciliation_date': instance.reconciliationDate.toIso8601String(),
  'period_start': instance.periodStart.toIso8601String(),
  'period_end': instance.periodEnd.toIso8601String(),
  'status': _$ReconciliationStatusEnumMap[instance.status]!,
  'total_gateway_amount': instance.totalGatewayAmount,
  'total_internal_amount': instance.totalInternalAmount,
  'currency': instance.currency,
  'gateway_records': instance.gatewayRecords.map((e) => e.toJson()).toList(),
  'internal_records': instance.internalRecords.map((e) => e.toJson()).toList(),
  'matches': instance.matches.map((e) => e.toJson()).toList(),
  'discrepancies': instance.discrepancies.map((e) => e.toJson()).toList(),
  'notes': instance.notes,
  'performed_by': instance.performedBy,
  'completed_at': instance.completedAt?.toIso8601String(),
  'metadata': instance.metadata,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};

const _$ReconciliationStatusEnumMap = {
  ReconciliationStatus.pending: 'pending',
  ReconciliationStatus.matched: 'matched',
  ReconciliationStatus.discrepancy: 'discrepancy',
  ReconciliationStatus.resolved: 'resolved',
  ReconciliationStatus.cancelled: 'cancelled',
};

_ReconciliationSummary _$ReconciliationSummaryFromJson(
  Map<String, dynamic> json,
) => _ReconciliationSummary(
  totalReconciled: (json['total_reconciled'] as num?)?.toDouble() ?? 0.0,
  totalDiscrepancies: (json['total_discrepancies'] as num?)?.toDouble() ?? 0.0,
  pendingReconciliations:
      (json['pending_reconciliations'] as num?)?.toInt() ?? 0,
  completedReconciliations:
      (json['completed_reconciliations'] as num?)?.toInt() ?? 0,
  totalDiscrepancyCount:
      (json['total_discrepancy_count'] as num?)?.toInt() ?? 0,
  resolvedDiscrepancyCount:
      (json['resolved_discrepancy_count'] as num?)?.toInt() ?? 0,
  discrepanciesByType: (json['discrepancies_by_type'] as Map<String, dynamic>?)
      ?.map((k, e) => MapEntry(k, (e as num).toInt())),
  discrepanciesByAmount:
      (json['discrepancies_by_amount'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
  lastReconciliationDate: json['last_reconciliation_date'] == null
      ? null
      : DateTime.parse(json['last_reconciliation_date'] as String),
  nextScheduledReconciliation: json['next_scheduled_reconciliation'] == null
      ? null
      : DateTime.parse(json['next_scheduled_reconciliation'] as String),
);

Map<String, dynamic> _$ReconciliationSummaryToJson(
  _ReconciliationSummary instance,
) => <String, dynamic>{
  'total_reconciled': instance.totalReconciled,
  'total_discrepancies': instance.totalDiscrepancies,
  'pending_reconciliations': instance.pendingReconciliations,
  'completed_reconciliations': instance.completedReconciliations,
  'total_discrepancy_count': instance.totalDiscrepancyCount,
  'resolved_discrepancy_count': instance.resolvedDiscrepancyCount,
  'discrepancies_by_type': instance.discrepanciesByType,
  'discrepancies_by_amount': instance.discrepanciesByAmount,
  'last_reconciliation_date': instance.lastReconciliationDate
      ?.toIso8601String(),
  'next_scheduled_reconciliation': instance.nextScheduledReconciliation
      ?.toIso8601String(),
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
  discrepancyTypes: (json['discrepancy_types'] as List<dynamic>?)
      ?.map((e) => $enumDecode(_$DiscrepancyTypeEnumMap, e))
      .toList(),
  minAmount: (json['min_amount'] as num?)?.toDouble(),
  maxAmount: (json['max_amount'] as num?)?.toDouble(),
  searchQuery: json['search_query'] as String?,
  sortBy: json['sort_by'] as String? ?? 'reconciliationDate',
  sortDesc: json['sort_desc'] as bool? ?? false,
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
  'discrepancy_types': instance.discrepancyTypes
      ?.map((e) => _$DiscrepancyTypeEnumMap[e]!)
      .toList(),
  'min_amount': instance.minAmount,
  'max_amount': instance.maxAmount,
  'search_query': instance.searchQuery,
  'sort_by': instance.sortBy,
  'sort_desc': instance.sortDesc,
  'page': instance.page,
  'limit': instance.limit,
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_reconciliation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaymentRecord _$PaymentRecordFromJson(Map<String, dynamic> json) =>
    _PaymentRecord(
      id: json['id'] as String,
      transactionId: json['transactionId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      paymentMethod: json['paymentMethod'] as String,
      gatewayReference: json['gatewayReference'] as String?,
      customerReference: json['customerReference'] as String?,
      invoiceReference: json['invoiceReference'] as String?,
      description: json['description'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$PaymentRecordToJson(_PaymentRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'transactionId': instance.transactionId,
      'amount': instance.amount,
      'currency': instance.currency,
      'transactionDate': instance.transactionDate.toIso8601String(),
      'paymentMethod': instance.paymentMethod,
      'gatewayReference': instance.gatewayReference,
      'customerReference': instance.customerReference,
      'invoiceReference': instance.invoiceReference,
      'description': instance.description,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_ReconciliationMatch _$ReconciliationMatchFromJson(Map<String, dynamic> json) =>
    _ReconciliationMatch(
      paymentId: json['paymentId'] as String,
      gatewayRecordId: json['gatewayRecordId'] as String,
      matchedAmount: (json['matchedAmount'] as num).toDouble(),
      matchedCurrency: json['matchedCurrency'] as String,
      matchDate: DateTime.parse(json['matchDate'] as String),
      notes: json['notes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ReconciliationMatchToJson(
  _ReconciliationMatch instance,
) => <String, dynamic>{
  'paymentId': instance.paymentId,
  'gatewayRecordId': instance.gatewayRecordId,
  'matchedAmount': instance.matchedAmount,
  'matchedCurrency': instance.matchedCurrency,
  'matchDate': instance.matchDate.toIso8601String(),
  'notes': instance.notes,
  'metadata': instance.metadata,
};

_ReconciliationDiscrepancy _$ReconciliationDiscrepancyFromJson(
  Map<String, dynamic> json,
) => _ReconciliationDiscrepancy(
  id: json['id'] as String,
  type: $enumDecode(_$DiscrepancyTypeEnumMap, json['type']),
  description: json['description'] as String,
  internalAmount: (json['internalAmount'] as num).toDouble(),
  gatewayAmount: (json['gatewayAmount'] as num).toDouble(),
  currency: json['currency'] as String,
  transactionDate: DateTime.parse(json['transactionDate'] as String),
  paymentId: json['paymentId'] as String?,
  gatewayRecordId: json['gatewayRecordId'] as String?,
  suggestedResolution: json['suggestedResolution'] as String?,
  resolvedBy: json['resolvedBy'] as String?,
  resolvedAt: json['resolvedAt'] == null
      ? null
      : DateTime.parse(json['resolvedAt'] as String),
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
  'type': _$DiscrepancyTypeEnumMap[instance.type]!,
  'description': instance.description,
  'internalAmount': instance.internalAmount,
  'gatewayAmount': instance.gatewayAmount,
  'currency': instance.currency,
  'transactionDate': instance.transactionDate.toIso8601String(),
  'paymentId': instance.paymentId,
  'gatewayRecordId': instance.gatewayRecordId,
  'suggestedResolution': instance.suggestedResolution,
  'resolvedBy': instance.resolvedBy,
  'resolvedAt': instance.resolvedAt?.toIso8601String(),
  'resolutionNotes': instance.resolutionNotes,
  'metadata': instance.metadata,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
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
  reconciliationDate: DateTime.parse(json['reconciliationDate'] as String),
  periodStart: DateTime.parse(json['periodStart'] as String),
  periodEnd: DateTime.parse(json['periodEnd'] as String),
  status: $enumDecode(_$ReconciliationStatusEnumMap, json['status']),
  totalGatewayAmount: (json['totalGatewayAmount'] as num).toDouble(),
  totalInternalAmount: (json['totalInternalAmount'] as num).toDouble(),
  currency: json['currency'] as String,
  gatewayRecords: (json['gatewayRecords'] as List<dynamic>)
      .map((e) => PaymentRecord.fromJson(e as Map<String, dynamic>))
      .toList(),
  internalRecords: (json['internalRecords'] as List<dynamic>)
      .map((e) => PaymentRecord.fromJson(e as Map<String, dynamic>))
      .toList(),
  matches: (json['matches'] as List<dynamic>)
      .map((e) => ReconciliationMatch.fromJson(e as Map<String, dynamic>))
      .toList(),
  discrepancies: (json['discrepancies'] as List<dynamic>)
      .map((e) => ReconciliationDiscrepancy.fromJson(e as Map<String, dynamic>))
      .toList(),
  notes: json['notes'] as String?,
  performedBy: json['performedBy'] as String?,
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
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
  'reconciliationDate': instance.reconciliationDate.toIso8601String(),
  'periodStart': instance.periodStart.toIso8601String(),
  'periodEnd': instance.periodEnd.toIso8601String(),
  'status': _$ReconciliationStatusEnumMap[instance.status]!,
  'totalGatewayAmount': instance.totalGatewayAmount,
  'totalInternalAmount': instance.totalInternalAmount,
  'currency': instance.currency,
  'gatewayRecords': instance.gatewayRecords,
  'internalRecords': instance.internalRecords,
  'matches': instance.matches,
  'discrepancies': instance.discrepancies,
  'notes': instance.notes,
  'performedBy': instance.performedBy,
  'completedAt': instance.completedAt?.toIso8601String(),
  'metadata': instance.metadata,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
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
  totalReconciled: (json['totalReconciled'] as num?)?.toDouble() ?? 0.0,
  totalDiscrepancies: (json['totalDiscrepancies'] as num?)?.toDouble() ?? 0.0,
  pendingReconciliations:
      (json['pendingReconciliations'] as num?)?.toInt() ?? 0,
  completedReconciliations:
      (json['completedReconciliations'] as num?)?.toInt() ?? 0,
  totalDiscrepancyCount: (json['totalDiscrepancyCount'] as num?)?.toInt() ?? 0,
  resolvedDiscrepancyCount:
      (json['resolvedDiscrepancyCount'] as num?)?.toInt() ?? 0,
  discrepanciesByType: (json['discrepanciesByType'] as Map<String, dynamic>?)
      ?.map((k, e) => MapEntry(k, (e as num).toInt())),
  discrepanciesByAmount:
      (json['discrepanciesByAmount'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
  lastReconciliationDate: json['lastReconciliationDate'] == null
      ? null
      : DateTime.parse(json['lastReconciliationDate'] as String),
  nextScheduledReconciliation: json['nextScheduledReconciliation'] == null
      ? null
      : DateTime.parse(json['nextScheduledReconciliation'] as String),
);

Map<String, dynamic> _$ReconciliationSummaryToJson(
  _ReconciliationSummary instance,
) => <String, dynamic>{
  'totalReconciled': instance.totalReconciled,
  'totalDiscrepancies': instance.totalDiscrepancies,
  'pendingReconciliations': instance.pendingReconciliations,
  'completedReconciliations': instance.completedReconciliations,
  'totalDiscrepancyCount': instance.totalDiscrepancyCount,
  'resolvedDiscrepancyCount': instance.resolvedDiscrepancyCount,
  'discrepanciesByType': instance.discrepanciesByType,
  'discrepanciesByAmount': instance.discrepanciesByAmount,
  'lastReconciliationDate': instance.lastReconciliationDate?.toIso8601String(),
  'nextScheduledReconciliation': instance.nextScheduledReconciliation
      ?.toIso8601String(),
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
  discrepancyTypes: (json['discrepancyTypes'] as List<dynamic>?)
      ?.map((e) => $enumDecode(_$DiscrepancyTypeEnumMap, e))
      .toList(),
  minAmount: (json['minAmount'] as num?)?.toDouble(),
  maxAmount: (json['maxAmount'] as num?)?.toDouble(),
  searchQuery: json['searchQuery'] as String?,
  sortBy: json['sortBy'] as String? ?? 'reconciliationDate',
  sortDesc: json['sortDesc'] as bool? ?? false,
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
  'discrepancyTypes': instance.discrepancyTypes
      ?.map((e) => _$DiscrepancyTypeEnumMap[e]!)
      .toList(),
  'minAmount': instance.minAmount,
  'maxAmount': instance.maxAmount,
  'searchQuery': instance.searchQuery,
  'sortBy': instance.sortBy,
  'sortDesc': instance.sortDesc,
  'page': instance.page,
  'limit': instance.limit,
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_note_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreditNote _$CreditNoteFromJson(Map<String, dynamic> json) => _CreditNote(
  id: json['id'] as String,
  creditNoteNumber: json['creditNoteNumber'] as String,
  invoiceId: json['invoiceId'] as String,
  invoiceNumber: json['invoiceNumber'] as String,
  companyId: json['companyId'] as String,
  companyName: json['companyName'] as String,
  amount: (json['amount'] as num).toDouble(),
  currency: json['currency'] as String,
  reason: $enumDecode(_$CreditNoteReasonEnumMap, json['reason']),
  issueDate: DateTime.parse(json['issueDate'] as String),
  status: $enumDecode(_$CreditNoteStatusEnumMap, json['status']),
  notes: json['notes'] as String?,
  adminNotes: json['adminNotes'] as String?,
  appliedToInvoiceId: json['appliedToInvoiceId'] as String?,
  appliedToInvoiceNumber: json['appliedToInvoiceNumber'] as String?,
  appliedDate: json['appliedDate'] == null
      ? null
      : DateTime.parse(json['appliedDate'] as String),
  remainingBalance: (json['remainingBalance'] as num?)?.toDouble(),
  issuedByAdminId: json['issuedByAdminId'] as String?,
  issuedByAdminName: json['issuedByAdminName'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$CreditNoteToJson(_CreditNote instance) =>
    <String, dynamic>{
      'id': instance.id,
      'creditNoteNumber': instance.creditNoteNumber,
      'invoiceId': instance.invoiceId,
      'invoiceNumber': instance.invoiceNumber,
      'companyId': instance.companyId,
      'companyName': instance.companyName,
      'amount': instance.amount,
      'currency': instance.currency,
      'reason': _$CreditNoteReasonEnumMap[instance.reason]!,
      'issueDate': instance.issueDate.toIso8601String(),
      'status': _$CreditNoteStatusEnumMap[instance.status]!,
      'notes': instance.notes,
      'adminNotes': instance.adminNotes,
      'appliedToInvoiceId': instance.appliedToInvoiceId,
      'appliedToInvoiceNumber': instance.appliedToInvoiceNumber,
      'appliedDate': instance.appliedDate?.toIso8601String(),
      'remainingBalance': instance.remainingBalance,
      'issuedByAdminId': instance.issuedByAdminId,
      'issuedByAdminName': instance.issuedByAdminName,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$CreditNoteReasonEnumMap = {
  CreditNoteReason.overpayment: 'overpayment',
  CreditNoteReason.serviceIssue: 'service_issue',
  CreditNoteReason.billingError: 'billing_error',
  CreditNoteReason.customerSatisfaction: 'customer_satisfaction',
  CreditNoteReason.promotional: 'promotional',
  CreditNoteReason.contractTermination: 'contract_termination',
  CreditNoteReason.priceAdjustment: 'price_adjustment',
  CreditNoteReason.other: 'other',
};

const _$CreditNoteStatusEnumMap = {
  CreditNoteStatus.draft: 'draft',
  CreditNoteStatus.issued: 'issued',
  CreditNoteStatus.applied: 'applied',
  CreditNoteStatus.cancelled: 'cancelled',
  CreditNoteStatus.expired: 'expired',
};

_CreditNoteApplication _$CreditNoteApplicationFromJson(
  Map<String, dynamic> json,
) => _CreditNoteApplication(
  id: json['id'] as String,
  creditNoteId: json['creditNoteId'] as String,
  invoiceId: json['invoiceId'] as String,
  appliedAmount: (json['appliedAmount'] as num).toDouble(),
  applicationDate: DateTime.parse(json['applicationDate'] as String),
  appliedByAdminId: json['appliedByAdminId'] as String,
  appliedByAdminName: json['appliedByAdminName'] as String,
  notes: json['notes'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$CreditNoteApplicationToJson(
  _CreditNoteApplication instance,
) => <String, dynamic>{
  'id': instance.id,
  'creditNoteId': instance.creditNoteId,
  'invoiceId': instance.invoiceId,
  'appliedAmount': instance.appliedAmount,
  'applicationDate': instance.applicationDate.toIso8601String(),
  'appliedByAdminId': instance.appliedByAdminId,
  'appliedByAdminName': instance.appliedByAdminName,
  'notes': instance.notes,
  'metadata': instance.metadata,
  'createdAt': instance.createdAt?.toIso8601String(),
};

_CreditNoteSummary _$CreditNoteSummaryFromJson(Map<String, dynamic> json) =>
    _CreditNoteSummary(
      totalIssued: (json['totalIssued'] as num?)?.toDouble() ?? 0.0,
      totalApplied: (json['totalApplied'] as num?)?.toDouble() ?? 0.0,
      totalUnused: (json['totalUnused'] as num?)?.toDouble() ?? 0.0,
      totalCancelled: (json['totalCancelled'] as num?)?.toDouble() ?? 0.0,
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      issuedCount: (json['issuedCount'] as num?)?.toInt() ?? 0,
      appliedCount: (json['appliedCount'] as num?)?.toInt() ?? 0,
      unusedCount: (json['unusedCount'] as num?)?.toInt() ?? 0,
      cancelledCount: (json['cancelledCount'] as num?)?.toInt() ?? 0,
      periodStart: json['periodStart'] == null
          ? null
          : DateTime.parse(json['periodStart'] as String),
      periodEnd: json['periodEnd'] == null
          ? null
          : DateTime.parse(json['periodEnd'] as String),
      amountByReason: (json['amountByReason'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          $enumDecode(_$CreditNoteReasonEnumMap, k),
          (e as num).toDouble(),
        ),
      ),
      countByReason: (json['countByReason'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          $enumDecode(_$CreditNoteReasonEnumMap, k),
          (e as num).toInt(),
        ),
      ),
    );

Map<String, dynamic> _$CreditNoteSummaryToJson(_CreditNoteSummary instance) =>
    <String, dynamic>{
      'totalIssued': instance.totalIssued,
      'totalApplied': instance.totalApplied,
      'totalUnused': instance.totalUnused,
      'totalCancelled': instance.totalCancelled,
      'totalCount': instance.totalCount,
      'issuedCount': instance.issuedCount,
      'appliedCount': instance.appliedCount,
      'unusedCount': instance.unusedCount,
      'cancelledCount': instance.cancelledCount,
      'periodStart': instance.periodStart?.toIso8601String(),
      'periodEnd': instance.periodEnd?.toIso8601String(),
      'amountByReason': instance.amountByReason?.map(
        (k, e) => MapEntry(_$CreditNoteReasonEnumMap[k]!, e),
      ),
      'countByReason': instance.countByReason?.map(
        (k, e) => MapEntry(_$CreditNoteReasonEnumMap[k]!, e),
      ),
    };

_CreditNoteFilter _$CreditNoteFilterFromJson(Map<String, dynamic> json) =>
    _CreditNoteFilter(
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      statuses: (json['statuses'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$CreditNoteStatusEnumMap, e))
          .toList(),
      reasons: (json['reasons'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$CreditNoteReasonEnumMap, e))
          .toList(),
      companyId: json['companyId'] as String?,
      searchQuery: json['searchQuery'] as String?,
      minAmount: (json['minAmount'] as num?)?.toDouble(),
      maxAmount: (json['maxAmount'] as num?)?.toDouble(),
      sortBy: json['sortBy'] as String? ?? 'issueDate',
      sortDesc: json['sortDesc'] as bool? ?? false,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
    );

Map<String, dynamic> _$CreditNoteFilterToJson(_CreditNoteFilter instance) =>
    <String, dynamic>{
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'statuses': instance.statuses
          ?.map((e) => _$CreditNoteStatusEnumMap[e]!)
          .toList(),
      'reasons': instance.reasons
          ?.map((e) => _$CreditNoteReasonEnumMap[e]!)
          .toList(),
      'companyId': instance.companyId,
      'searchQuery': instance.searchQuery,
      'minAmount': instance.minAmount,
      'maxAmount': instance.maxAmount,
      'sortBy': instance.sortBy,
      'sortDesc': instance.sortDesc,
      'page': instance.page,
      'limit': instance.limit,
    };

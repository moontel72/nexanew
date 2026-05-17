// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_note_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreditNote _$CreditNoteFromJson(Map<String, dynamic> json) => _CreditNote(
  id: json['id'] as String,
  creditNoteNumber: json['credit_note_number'] as String,
  invoiceId: json['invoice_id'] as String,
  invoiceNumber: json['invoice_number'] as String,
  companyId: json['company_id'] as String,
  companyName: json['company_name'] as String,
  amount: (json['amount'] as num).toDouble(),
  currency: json['currency'] as String,
  reason: $enumDecode(_$CreditNoteReasonEnumMap, json['reason']),
  issueDate: DateTime.parse(json['issue_date'] as String),
  status: $enumDecode(_$CreditNoteStatusEnumMap, json['status']),
  notes: json['notes'] as String?,
  adminNotes: json['admin_notes'] as String?,
  appliedToInvoiceId: json['applied_to_invoice_id'] as String?,
  appliedToInvoiceNumber: json['applied_to_invoice_number'] as String?,
  appliedDate: json['applied_date'] == null
      ? null
      : DateTime.parse(json['applied_date'] as String),
  remainingBalance: (json['remaining_balance'] as num?)?.toDouble(),
  issuedByAdminId: json['issued_by_admin_id'] as String?,
  issuedByAdminName: json['issued_by_admin_name'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$CreditNoteToJson(_CreditNote instance) =>
    <String, dynamic>{
      'id': instance.id,
      'credit_note_number': instance.creditNoteNumber,
      'invoice_id': instance.invoiceId,
      'invoice_number': instance.invoiceNumber,
      'company_id': instance.companyId,
      'company_name': instance.companyName,
      'amount': instance.amount,
      'currency': instance.currency,
      'reason': _$CreditNoteReasonEnumMap[instance.reason]!,
      'issue_date': instance.issueDate.toIso8601String(),
      'status': _$CreditNoteStatusEnumMap[instance.status]!,
      'notes': instance.notes,
      'admin_notes': instance.adminNotes,
      'applied_to_invoice_id': instance.appliedToInvoiceId,
      'applied_to_invoice_number': instance.appliedToInvoiceNumber,
      'applied_date': instance.appliedDate?.toIso8601String(),
      'remaining_balance': instance.remainingBalance,
      'issued_by_admin_id': instance.issuedByAdminId,
      'issued_by_admin_name': instance.issuedByAdminName,
      'metadata': instance.metadata,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
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
  creditNoteId: json['credit_note_id'] as String,
  invoiceId: json['invoice_id'] as String,
  appliedAmount: (json['applied_amount'] as num).toDouble(),
  applicationDate: DateTime.parse(json['application_date'] as String),
  appliedByAdminId: json['applied_by_admin_id'] as String,
  appliedByAdminName: json['applied_by_admin_name'] as String,
  notes: json['notes'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$CreditNoteApplicationToJson(
  _CreditNoteApplication instance,
) => <String, dynamic>{
  'id': instance.id,
  'credit_note_id': instance.creditNoteId,
  'invoice_id': instance.invoiceId,
  'applied_amount': instance.appliedAmount,
  'application_date': instance.applicationDate.toIso8601String(),
  'applied_by_admin_id': instance.appliedByAdminId,
  'applied_by_admin_name': instance.appliedByAdminName,
  'notes': instance.notes,
  'metadata': instance.metadata,
  'created_at': instance.createdAt?.toIso8601String(),
};

_CreditNoteSummary _$CreditNoteSummaryFromJson(Map<String, dynamic> json) =>
    _CreditNoteSummary(
      totalIssued: (json['total_issued'] as num?)?.toDouble() ?? 0.0,
      totalApplied: (json['total_applied'] as num?)?.toDouble() ?? 0.0,
      totalUnused: (json['total_unused'] as num?)?.toDouble() ?? 0.0,
      totalCancelled: (json['total_cancelled'] as num?)?.toDouble() ?? 0.0,
      totalCount: (json['total_count'] as num?)?.toInt() ?? 0,
      issuedCount: (json['issued_count'] as num?)?.toInt() ?? 0,
      appliedCount: (json['applied_count'] as num?)?.toInt() ?? 0,
      unusedCount: (json['unused_count'] as num?)?.toInt() ?? 0,
      cancelledCount: (json['cancelled_count'] as num?)?.toInt() ?? 0,
      periodStart: json['period_start'] == null
          ? null
          : DateTime.parse(json['period_start'] as String),
      periodEnd: json['period_end'] == null
          ? null
          : DateTime.parse(json['period_end'] as String),
      amountByReason: (json['amount_by_reason'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          $enumDecode(_$CreditNoteReasonEnumMap, k),
          (e as num).toDouble(),
        ),
      ),
      countByReason: (json['count_by_reason'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          $enumDecode(_$CreditNoteReasonEnumMap, k),
          (e as num).toInt(),
        ),
      ),
    );

Map<String, dynamic> _$CreditNoteSummaryToJson(_CreditNoteSummary instance) =>
    <String, dynamic>{
      'total_issued': instance.totalIssued,
      'total_applied': instance.totalApplied,
      'total_unused': instance.totalUnused,
      'total_cancelled': instance.totalCancelled,
      'total_count': instance.totalCount,
      'issued_count': instance.issuedCount,
      'applied_count': instance.appliedCount,
      'unused_count': instance.unusedCount,
      'cancelled_count': instance.cancelledCount,
      'period_start': instance.periodStart?.toIso8601String(),
      'period_end': instance.periodEnd?.toIso8601String(),
      'amount_by_reason': instance.amountByReason?.map(
        (k, e) => MapEntry(_$CreditNoteReasonEnumMap[k]!, e),
      ),
      'count_by_reason': instance.countByReason?.map(
        (k, e) => MapEntry(_$CreditNoteReasonEnumMap[k]!, e),
      ),
    };

_CreditNoteFilter _$CreditNoteFilterFromJson(Map<String, dynamic> json) =>
    _CreditNoteFilter(
      startDate: json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      statuses: (json['statuses'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$CreditNoteStatusEnumMap, e))
          .toList(),
      reasons: (json['reasons'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$CreditNoteReasonEnumMap, e))
          .toList(),
      companyId: json['company_id'] as String?,
      searchQuery: json['search_query'] as String?,
      minAmount: (json['min_amount'] as num?)?.toDouble(),
      maxAmount: (json['max_amount'] as num?)?.toDouble(),
      sortBy: json['sort_by'] as String? ?? 'issueDate',
      sortDesc: json['sort_desc'] as bool? ?? false,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
    );

Map<String, dynamic> _$CreditNoteFilterToJson(_CreditNoteFilter instance) =>
    <String, dynamic>{
      'start_date': instance.startDate?.toIso8601String(),
      'end_date': instance.endDate?.toIso8601String(),
      'statuses': instance.statuses
          ?.map((e) => _$CreditNoteStatusEnumMap[e]!)
          .toList(),
      'reasons': instance.reasons
          ?.map((e) => _$CreditNoteReasonEnumMap[e]!)
          .toList(),
      'company_id': instance.companyId,
      'search_query': instance.searchQuery,
      'min_amount': instance.minAmount,
      'max_amount': instance.maxAmount,
      'sort_by': instance.sortBy,
      'sort_desc': instance.sortDesc,
      'page': instance.page,
      'limit': instance.limit,
    };

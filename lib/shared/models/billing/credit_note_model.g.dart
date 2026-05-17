// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_note_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreditNoteItem _$CreditNoteItemFromJson(Map<String, dynamic> json) =>
    _CreditNoteItem(
      id: json['id'] as String,
      description: json['description'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: (json['unit_price'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      currency: json['currency'] as String,
      invoiceItemId: json['invoice_item_id'] as String?,
      reason: json['reason'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$CreditNoteItemToJson(_CreditNoteItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'quantity': instance.quantity,
      'unit_price': instance.unitPrice,
      'total': instance.total,
      'currency': instance.currency,
      'invoice_item_id': instance.invoiceItemId,
      'reason': instance.reason,
      'metadata': instance.metadata,
    };

_CreditNote _$CreditNoteFromJson(Map<String, dynamic> json) => _CreditNote(
  id: json['id'] as String,
  creditNoteNumber: json['credit_note_number'] as String,
  companyId: json['company_id'] as String,
  invoiceId: json['invoice_id'] as String?,
  type: $enumDecode(_$CreditNoteTypeEnumMap, json['type']),
  reason: json['reason'] as String,
  totalAmount: (json['total_amount'] as num).toDouble(),
  currency: json['currency'] as String? ?? 'USD',
  items: (json['items'] as List<dynamic>)
      .map((e) => CreditNoteItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  status:
      $enumDecodeNullable(_$CreditNoteStatusEnumMap, json['status']) ??
      CreditNoteStatus.draft,
  approvalDate: json['approval_date'] == null
      ? null
      : DateTime.parse(json['approval_date'] as String),
  approvedBy: json['approved_by'] as String?,
  applicationDate: json['application_date'] == null
      ? null
      : DateTime.parse(json['application_date'] as String),
  appliedToInvoiceId: json['applied_to_invoice_id'] as String?,
  expiryDate: json['expiry_date'] == null
      ? null
      : DateTime.parse(json['expiry_date'] as String),
  notes: json['notes'] as String?,
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
      'company_id': instance.companyId,
      'invoice_id': instance.invoiceId,
      'type': _$CreditNoteTypeEnumMap[instance.type]!,
      'reason': instance.reason,
      'total_amount': instance.totalAmount,
      'currency': instance.currency,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'status': _$CreditNoteStatusEnumMap[instance.status]!,
      'approval_date': instance.approvalDate?.toIso8601String(),
      'approved_by': instance.approvedBy,
      'application_date': instance.applicationDate?.toIso8601String(),
      'applied_to_invoice_id': instance.appliedToInvoiceId,
      'expiry_date': instance.expiryDate?.toIso8601String(),
      'notes': instance.notes,
      'metadata': instance.metadata,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$CreditNoteTypeEnumMap = {
  CreditNoteType.refund: 'refund',
  CreditNoteType.discount: 'discount',
  CreditNoteType.adjustment: 'adjustment',
  CreditNoteType.goodwill: 'goodwill',
  CreditNoteType.other: 'other',
};

const _$CreditNoteStatusEnumMap = {
  CreditNoteStatus.draft: 'draft',
  CreditNoteStatus.pendingApproval: 'pending_approval',
  CreditNoteStatus.approved: 'approved',
  CreditNoteStatus.applied: 'applied',
  CreditNoteStatus.cancelled: 'cancelled',
  CreditNoteStatus.expired: 'expired',
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
      types: (json['types'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$CreditNoteTypeEnumMap, e))
          .toList(),
      minAmount: (json['min_amount'] as num?)?.toDouble(),
      maxAmount: (json['max_amount'] as num?)?.toDouble(),
      searchQuery: json['search_query'] as String?,
      sortBy: json['sort_by'] as String? ?? 'createdAt',
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
      'types': instance.types?.map((e) => _$CreditNoteTypeEnumMap[e]!).toList(),
      'min_amount': instance.minAmount,
      'max_amount': instance.maxAmount,
      'search_query': instance.searchQuery,
      'sort_by': instance.sortBy,
      'sort_desc': instance.sortDesc,
      'page': instance.page,
      'limit': instance.limit,
    };

_CreditNoteSummary _$CreditNoteSummaryFromJson(Map<String, dynamic> json) =>
    _CreditNoteSummary(
      totalIssued: (json['total_issued'] as num?)?.toDouble() ?? 0.0,
      totalApplied: (json['total_applied'] as num?)?.toDouble() ?? 0.0,
      totalAvailable: (json['total_available'] as num?)?.toDouble() ?? 0.0,
      draftCount: (json['draft_count'] as num?)?.toInt() ?? 0,
      pendingApprovalCount:
          (json['pending_approval_count'] as num?)?.toInt() ?? 0,
      approvedCount: (json['approved_count'] as num?)?.toInt() ?? 0,
      appliedCount: (json['applied_count'] as num?)?.toInt() ?? 0,
      expiredCount: (json['expired_count'] as num?)?.toInt() ?? 0,
      byType: (json['by_type'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      byCompany: (json['by_company'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
    );

Map<String, dynamic> _$CreditNoteSummaryToJson(_CreditNoteSummary instance) =>
    <String, dynamic>{
      'total_issued': instance.totalIssued,
      'total_applied': instance.totalApplied,
      'total_available': instance.totalAvailable,
      'draft_count': instance.draftCount,
      'pending_approval_count': instance.pendingApprovalCount,
      'approved_count': instance.approvedCount,
      'applied_count': instance.appliedCount,
      'expired_count': instance.expiredCount,
      'by_type': instance.byType,
      'by_company': instance.byCompany,
    };

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
      unitPrice: (json['unitPrice'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      currency: json['currency'] as String,
      invoiceItemId: json['invoiceItemId'] as String?,
      reason: json['reason'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$CreditNoteItemToJson(_CreditNoteItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'total': instance.total,
      'currency': instance.currency,
      'invoiceItemId': instance.invoiceItemId,
      'reason': instance.reason,
      'metadata': instance.metadata,
    };

_CreditNote _$CreditNoteFromJson(Map<String, dynamic> json) => _CreditNote(
  id: json['id'] as String,
  creditNoteNumber: json['creditNoteNumber'] as String,
  companyId: json['companyId'] as String,
  invoiceId: json['invoiceId'] as String?,
  type: $enumDecode(_$CreditNoteTypeEnumMap, json['type']),
  reason: json['reason'] as String,
  totalAmount: (json['totalAmount'] as num).toDouble(),
  currency: json['currency'] as String? ?? 'USD',
  items: (json['items'] as List<dynamic>)
      .map((e) => CreditNoteItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  status:
      $enumDecodeNullable(_$CreditNoteStatusEnumMap, json['status']) ??
      CreditNoteStatus.draft,
  approvalDate: json['approvalDate'] == null
      ? null
      : DateTime.parse(json['approvalDate'] as String),
  approvedBy: json['approvedBy'] as String?,
  applicationDate: json['applicationDate'] == null
      ? null
      : DateTime.parse(json['applicationDate'] as String),
  appliedToInvoiceId: json['appliedToInvoiceId'] as String?,
  expiryDate: json['expiryDate'] == null
      ? null
      : DateTime.parse(json['expiryDate'] as String),
  notes: json['notes'] as String?,
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
      'companyId': instance.companyId,
      'invoiceId': instance.invoiceId,
      'type': _$CreditNoteTypeEnumMap[instance.type]!,
      'reason': instance.reason,
      'totalAmount': instance.totalAmount,
      'currency': instance.currency,
      'items': instance.items,
      'status': _$CreditNoteStatusEnumMap[instance.status]!,
      'approvalDate': instance.approvalDate?.toIso8601String(),
      'approvedBy': instance.approvedBy,
      'applicationDate': instance.applicationDate?.toIso8601String(),
      'appliedToInvoiceId': instance.appliedToInvoiceId,
      'expiryDate': instance.expiryDate?.toIso8601String(),
      'notes': instance.notes,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
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
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      statuses: (json['statuses'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$CreditNoteStatusEnumMap, e))
          .toList(),
      types: (json['types'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$CreditNoteTypeEnumMap, e))
          .toList(),
      minAmount: (json['minAmount'] as num?)?.toDouble(),
      maxAmount: (json['maxAmount'] as num?)?.toDouble(),
      searchQuery: json['searchQuery'] as String?,
      sortBy: json['sortBy'] as String? ?? 'createdAt',
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
      'types': instance.types?.map((e) => _$CreditNoteTypeEnumMap[e]!).toList(),
      'minAmount': instance.minAmount,
      'maxAmount': instance.maxAmount,
      'searchQuery': instance.searchQuery,
      'sortBy': instance.sortBy,
      'sortDesc': instance.sortDesc,
      'page': instance.page,
      'limit': instance.limit,
    };

_CreditNoteSummary _$CreditNoteSummaryFromJson(Map<String, dynamic> json) =>
    _CreditNoteSummary(
      totalIssued: (json['totalIssued'] as num?)?.toDouble() ?? 0.0,
      totalApplied: (json['totalApplied'] as num?)?.toDouble() ?? 0.0,
      totalAvailable: (json['totalAvailable'] as num?)?.toDouble() ?? 0.0,
      draftCount: (json['draftCount'] as num?)?.toInt() ?? 0,
      pendingApprovalCount:
          (json['pendingApprovalCount'] as num?)?.toInt() ?? 0,
      approvedCount: (json['approvedCount'] as num?)?.toInt() ?? 0,
      appliedCount: (json['appliedCount'] as num?)?.toInt() ?? 0,
      expiredCount: (json['expiredCount'] as num?)?.toInt() ?? 0,
      byType: (json['byType'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      byCompany: (json['byCompany'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
    );

Map<String, dynamic> _$CreditNoteSummaryToJson(_CreditNoteSummary instance) =>
    <String, dynamic>{
      'totalIssued': instance.totalIssued,
      'totalApplied': instance.totalApplied,
      'totalAvailable': instance.totalAvailable,
      'draftCount': instance.draftCount,
      'pendingApprovalCount': instance.pendingApprovalCount,
      'approvedCount': instance.approvedCount,
      'appliedCount': instance.appliedCount,
      'expiredCount': instance.expiredCount,
      'byType': instance.byType,
      'byCompany': instance.byCompany,
    };

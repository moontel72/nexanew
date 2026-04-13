// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AdminInvoice _$AdminInvoiceFromJson(Map<String, dynamic> json) =>
    _AdminInvoice(
      id: json['id'] as String,
      invoiceNumber: json['invoiceNumber'] as String,
      companyId: json['companyId'] as String,
      companyName: json['companyName'] as String,
      subscriptionId: json['subscriptionId'] as String,
      subscriptionName: json['subscriptionName'] as String,
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      issueDate: DateTime.parse(json['issueDate'] as String),
      dueDate: DateTime.parse(json['dueDate'] as String),
      subtotal: (json['subtotal'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      items: (json['items'] as List<dynamic>)
          .map((e) => AdminInvoiceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      status:
          $enumDecodeNullable(_$InvoiceStatusEnumMap, json['status']) ??
          InvoiceStatus.pending,
      paymentDate: json['paymentDate'] == null
          ? null
          : DateTime.parse(json['paymentDate'] as String),
      paymentMethod: $enumDecodeNullable(
        _$PaymentMethodEnumMap,
        json['paymentMethod'],
      ),
      paymentReference: json['paymentReference'] as String?,
      notes: json['notes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      adminNotes: json['adminNotes'] as String?,
      requiresFollowUp: json['requiresFollowUp'] as bool?,
      followUpReason: json['followUpReason'] as String?,
      followUpDate: json['followUpDate'] == null
          ? null
          : DateTime.parse(json['followUpDate'] as String),
      assignedToAdminId: json['assignedToAdminId'] as String?,
      assignedToAdminName: json['assignedToAdminName'] as String?,
    );

Map<String, dynamic> _$AdminInvoiceToJson(_AdminInvoice instance) =>
    <String, dynamic>{
      'id': instance.id,
      'invoiceNumber': instance.invoiceNumber,
      'companyId': instance.companyId,
      'companyName': instance.companyName,
      'subscriptionId': instance.subscriptionId,
      'subscriptionName': instance.subscriptionName,
      'periodStart': instance.periodStart.toIso8601String(),
      'periodEnd': instance.periodEnd.toIso8601String(),
      'issueDate': instance.issueDate.toIso8601String(),
      'dueDate': instance.dueDate.toIso8601String(),
      'subtotal': instance.subtotal,
      'taxAmount': instance.taxAmount,
      'discountAmount': instance.discountAmount,
      'totalAmount': instance.totalAmount,
      'currency': instance.currency,
      'items': instance.items,
      'status': _$InvoiceStatusEnumMap[instance.status]!,
      'paymentDate': instance.paymentDate?.toIso8601String(),
      'paymentMethod': _$PaymentMethodEnumMap[instance.paymentMethod],
      'paymentReference': instance.paymentReference,
      'notes': instance.notes,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'adminNotes': instance.adminNotes,
      'requiresFollowUp': instance.requiresFollowUp,
      'followUpReason': instance.followUpReason,
      'followUpDate': instance.followUpDate?.toIso8601String(),
      'assignedToAdminId': instance.assignedToAdminId,
      'assignedToAdminName': instance.assignedToAdminName,
    };

const _$InvoiceStatusEnumMap = {
  InvoiceStatus.draft: 'draft',
  InvoiceStatus.pending: 'pending',
  InvoiceStatus.paid: 'paid',
  InvoiceStatus.overdue: 'overdue',
  InvoiceStatus.cancelled: 'cancelled',
  InvoiceStatus.refunded: 'refunded',
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.wallet: 'wallet',
  PaymentMethod.creditCard: 'credit_card',
  PaymentMethod.bankTransfer: 'bank_transfer',
  PaymentMethod.cash: 'cash',
  PaymentMethod.other: 'other',
};

_AdminInvoiceItem _$AdminInvoiceItemFromJson(Map<String, dynamic> json) =>
    _AdminInvoiceItem(
      id: json['id'] as String,
      description: json['description'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      currency: json['currency'] as String,
      codeType: json['codeType'] as String?,
      codeCount: (json['codeCount'] as num?)?.toInt(),
      periodStart: json['periodStart'] == null
          ? null
          : DateTime.parse(json['periodStart'] as String),
      periodEnd: json['periodEnd'] == null
          ? null
          : DateTime.parse(json['periodEnd'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
      planFeatureId: json['planFeatureId'] as String?,
      planFeatureName: json['planFeatureName'] as String?,
      usageAmount: (json['usageAmount'] as num?)?.toDouble(),
      overageAmount: (json['overageAmount'] as num?)?.toDouble(),
      isOverageCharge: json['isOverageCharge'] as bool?,
    );

Map<String, dynamic> _$AdminInvoiceItemToJson(_AdminInvoiceItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'total': instance.total,
      'currency': instance.currency,
      'codeType': instance.codeType,
      'codeCount': instance.codeCount,
      'periodStart': instance.periodStart?.toIso8601String(),
      'periodEnd': instance.periodEnd?.toIso8601String(),
      'metadata': instance.metadata,
      'planFeatureId': instance.planFeatureId,
      'planFeatureName': instance.planFeatureName,
      'usageAmount': instance.usageAmount,
      'overageAmount': instance.overageAmount,
      'isOverageCharge': instance.isOverageCharge,
    };

_PlatformRevenueSummary _$PlatformRevenueSummaryFromJson(
  Map<String, dynamic> json,
) => _PlatformRevenueSummary(
  totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
  collectedRevenue: (json['collectedRevenue'] as num?)?.toDouble() ?? 0.0,
  pendingRevenue: (json['pendingRevenue'] as num?)?.toDouble() ?? 0.0,
  overdueRevenue: (json['overdueRevenue'] as num?)?.toDouble() ?? 0.0,
  totalInvoices: (json['totalInvoices'] as num?)?.toInt() ?? 0,
  paidInvoices: (json['paidInvoices'] as num?)?.toInt() ?? 0,
  pendingInvoices: (json['pendingInvoices'] as num?)?.toInt() ?? 0,
  overdueInvoices: (json['overdueInvoices'] as num?)?.toInt() ?? 0,
  draftInvoices: (json['draftInvoices'] as num?)?.toInt() ?? 0,
  cancelledInvoices: (json['cancelledInvoices'] as num?)?.toInt() ?? 0,
  periodStart: json['periodStart'] == null
      ? null
      : DateTime.parse(json['periodStart'] as String),
  periodEnd: json['periodEnd'] == null
      ? null
      : DateTime.parse(json['periodEnd'] as String),
  revenueByPlan: (json['revenueByPlan'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  revenueByCompanyType: (json['revenueByCompanyType'] as Map<String, dynamic>?)
      ?.map((k, e) => MapEntry(k, (e as num).toDouble())),
  revenueTrend: (json['revenueTrend'] as List<dynamic>?)
      ?.map((e) => RevenueTrendData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PlatformRevenueSummaryToJson(
  _PlatformRevenueSummary instance,
) => <String, dynamic>{
  'totalRevenue': instance.totalRevenue,
  'collectedRevenue': instance.collectedRevenue,
  'pendingRevenue': instance.pendingRevenue,
  'overdueRevenue': instance.overdueRevenue,
  'totalInvoices': instance.totalInvoices,
  'paidInvoices': instance.paidInvoices,
  'pendingInvoices': instance.pendingInvoices,
  'overdueInvoices': instance.overdueInvoices,
  'draftInvoices': instance.draftInvoices,
  'cancelledInvoices': instance.cancelledInvoices,
  'periodStart': instance.periodStart?.toIso8601String(),
  'periodEnd': instance.periodEnd?.toIso8601String(),
  'revenueByPlan': instance.revenueByPlan,
  'revenueByCompanyType': instance.revenueByCompanyType,
  'revenueTrend': instance.revenueTrend,
};

_RevenueTrendData _$RevenueTrendDataFromJson(Map<String, dynamic> json) =>
    _RevenueTrendData(
      date: DateTime.parse(json['date'] as String),
      revenue: (json['revenue'] as num).toDouble(),
      invoiceCount: (json['invoiceCount'] as num).toInt(),
      paidCount: (json['paidCount'] as num).toInt(),
    );

Map<String, dynamic> _$RevenueTrendDataToJson(_RevenueTrendData instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'revenue': instance.revenue,
      'invoiceCount': instance.invoiceCount,
      'paidCount': instance.paidCount,
    };

_CompanyRevenueSummary _$CompanyRevenueSummaryFromJson(
  Map<String, dynamic> json,
) => _CompanyRevenueSummary(
  companyId: json['companyId'] as String,
  companyName: json['companyName'] as String,
  companyType: json['companyType'] as String,
  totalRevenue: (json['totalRevenue'] as num).toDouble(),
  paidAmount: (json['paidAmount'] as num).toDouble(),
  pendingAmount: (json['pendingAmount'] as num).toDouble(),
  overdueAmount: (json['overdueAmount'] as num).toDouble(),
  totalInvoices: (json['totalInvoices'] as num).toInt(),
  paidInvoices: (json['paidInvoices'] as num).toInt(),
  pendingInvoices: (json['pendingInvoices'] as num).toInt(),
  overdueInvoices: (json['overdueInvoices'] as num).toInt(),
  lastPaymentDate: json['lastPaymentDate'] == null
      ? null
      : DateTime.parse(json['lastPaymentDate'] as String),
  averagePaymentDays: (json['averagePaymentDays'] as num?)?.toDouble(),
  currentPlan: json['currentPlan'] as String?,
  subscriptionStartDate: json['subscriptionStartDate'] == null
      ? null
      : DateTime.parse(json['subscriptionStartDate'] as String),
  subscriptionEndDate: json['subscriptionEndDate'] == null
      ? null
      : DateTime.parse(json['subscriptionEndDate'] as String),
);

Map<String, dynamic> _$CompanyRevenueSummaryToJson(
  _CompanyRevenueSummary instance,
) => <String, dynamic>{
  'companyId': instance.companyId,
  'companyName': instance.companyName,
  'companyType': instance.companyType,
  'totalRevenue': instance.totalRevenue,
  'paidAmount': instance.paidAmount,
  'pendingAmount': instance.pendingAmount,
  'overdueAmount': instance.overdueAmount,
  'totalInvoices': instance.totalInvoices,
  'paidInvoices': instance.paidInvoices,
  'pendingInvoices': instance.pendingInvoices,
  'overdueInvoices': instance.overdueInvoices,
  'lastPaymentDate': instance.lastPaymentDate?.toIso8601String(),
  'averagePaymentDays': instance.averagePaymentDays,
  'currentPlan': instance.currentPlan,
  'subscriptionStartDate': instance.subscriptionStartDate?.toIso8601String(),
  'subscriptionEndDate': instance.subscriptionEndDate?.toIso8601String(),
};

_PaymentReconciliation _$PaymentReconciliationFromJson(
  Map<String, dynamic> json,
) => _PaymentReconciliation(
  id: json['id'] as String,
  reconciliationDate: DateTime.parse(json['reconciliationDate'] as String),
  periodStart: DateTime.parse(json['periodStart'] as String),
  periodEnd: DateTime.parse(json['periodEnd'] as String),
  expectedAmount: (json['expectedAmount'] as num).toDouble(),
  actualAmount: (json['actualAmount'] as num).toDouble(),
  discrepancyAmount: (json['discrepancyAmount'] as num).toDouble(),
  totalTransactions: (json['totalTransactions'] as num).toInt(),
  matchedTransactions: (json['matchedTransactions'] as num).toInt(),
  unmatchedTransactions: (json['unmatchedTransactions'] as num).toInt(),
  status: $enumDecode(_$ReconciliationStatusEnumMap, json['status']),
  notes: json['notes'] as String?,
  performedByAdminId: json['performedByAdminId'] as String?,
  performedByAdminName: json['performedByAdminName'] as String?,
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => ReconciliationItem.fromJson(e as Map<String, dynamic>))
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
  'reconciliationDate': instance.reconciliationDate.toIso8601String(),
  'periodStart': instance.periodStart.toIso8601String(),
  'periodEnd': instance.periodEnd.toIso8601String(),
  'expectedAmount': instance.expectedAmount,
  'actualAmount': instance.actualAmount,
  'discrepancyAmount': instance.discrepancyAmount,
  'totalTransactions': instance.totalTransactions,
  'matchedTransactions': instance.matchedTransactions,
  'unmatchedTransactions': instance.unmatchedTransactions,
  'status': _$ReconciliationStatusEnumMap[instance.status]!,
  'notes': instance.notes,
  'performedByAdminId': instance.performedByAdminId,
  'performedByAdminName': instance.performedByAdminName,
  'items': instance.items,
  'metadata': instance.metadata,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

const _$ReconciliationStatusEnumMap = {
  ReconciliationStatus.pending: 'pending',
  ReconciliationStatus.inProgress: 'in_progress',
  ReconciliationStatus.completed: 'completed',
  ReconciliationStatus.failed: 'failed',
  ReconciliationStatus.requiresReview: 'requires_review',
};

_ReconciliationItem _$ReconciliationItemFromJson(Map<String, dynamic> json) =>
    _ReconciliationItem(
      id: json['id'] as String,
      transactionId: json['transactionId'] as String,
      invoiceId: json['invoiceId'] as String,
      invoiceNumber: json['invoiceNumber'] as String,
      expectedAmount: (json['expectedAmount'] as num).toDouble(),
      actualAmount: (json['actualAmount'] as num).toDouble(),
      discrepancy: (json['discrepancy'] as num).toDouble(),
      status: $enumDecode(_$ReconciliationItemStatusEnumMap, json['status']),
      notes: json['notes'] as String?,
      matchedAt: json['matchedAt'] == null
          ? null
          : DateTime.parse(json['matchedAt'] as String),
      matchedByAdminId: json['matchedByAdminId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ReconciliationItemToJson(_ReconciliationItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'transactionId': instance.transactionId,
      'invoiceId': instance.invoiceId,
      'invoiceNumber': instance.invoiceNumber,
      'expectedAmount': instance.expectedAmount,
      'actualAmount': instance.actualAmount,
      'discrepancy': instance.discrepancy,
      'status': _$ReconciliationItemStatusEnumMap[instance.status]!,
      'notes': instance.notes,
      'matchedAt': instance.matchedAt?.toIso8601String(),
      'matchedByAdminId': instance.matchedByAdminId,
      'metadata': instance.metadata,
    };

const _$ReconciliationItemStatusEnumMap = {
  ReconciliationItemStatus.matched: 'matched',
  ReconciliationItemStatus.unmatched: 'unmatched',
  ReconciliationItemStatus.partialMatch: 'partial_match',
  ReconciliationItemStatus.requiresReview: 'requires_review',
};

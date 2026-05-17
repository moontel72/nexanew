// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AdminInvoice _$AdminInvoiceFromJson(Map<String, dynamic> json) =>
    _AdminInvoice(
      id: json['id'] as String,
      invoiceNumber: json['invoice_number'] as String,
      companyId: json['company_id'] as String,
      companyName: json['company_name'] as String,
      subscriptionId: json['subscription_id'] as String,
      subscriptionName: json['subscription_name'] as String,
      periodStart: DateTime.parse(json['period_start'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
      issueDate: DateTime.parse(json['issue_date'] as String),
      dueDate: DateTime.parse(json['due_date'] as String),
      subtotal: (json['subtotal'] as num).toDouble(),
      taxAmount: (json['tax_amount'] as num).toDouble(),
      discountAmount: (json['discount_amount'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      items: (json['items'] as List<dynamic>)
          .map((e) => AdminInvoiceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      status:
          $enumDecodeNullable(_$InvoiceStatusEnumMap, json['status']) ??
          InvoiceStatus.pending,
      paymentDate: json['payment_date'] == null
          ? null
          : DateTime.parse(json['payment_date'] as String),
      paymentMethod: $enumDecodeNullable(
        _$PaymentMethodEnumMap,
        json['payment_method'],
      ),
      paymentReference: json['payment_reference'] as String?,
      notes: json['notes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      adminNotes: json['admin_notes'] as String?,
      requiresFollowUp: json['requires_follow_up'] as bool?,
      followUpReason: json['follow_up_reason'] as String?,
      followUpDate: json['follow_up_date'] == null
          ? null
          : DateTime.parse(json['follow_up_date'] as String),
      assignedToAdminId: json['assigned_to_admin_id'] as String?,
      assignedToAdminName: json['assigned_to_admin_name'] as String?,
    );

Map<String, dynamic> _$AdminInvoiceToJson(_AdminInvoice instance) =>
    <String, dynamic>{
      'id': instance.id,
      'invoice_number': instance.invoiceNumber,
      'company_id': instance.companyId,
      'company_name': instance.companyName,
      'subscription_id': instance.subscriptionId,
      'subscription_name': instance.subscriptionName,
      'period_start': instance.periodStart.toIso8601String(),
      'period_end': instance.periodEnd.toIso8601String(),
      'issue_date': instance.issueDate.toIso8601String(),
      'due_date': instance.dueDate.toIso8601String(),
      'subtotal': instance.subtotal,
      'tax_amount': instance.taxAmount,
      'discount_amount': instance.discountAmount,
      'total_amount': instance.totalAmount,
      'currency': instance.currency,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'status': _$InvoiceStatusEnumMap[instance.status]!,
      'payment_date': instance.paymentDate?.toIso8601String(),
      'payment_method': _$PaymentMethodEnumMap[instance.paymentMethod],
      'payment_reference': instance.paymentReference,
      'notes': instance.notes,
      'metadata': instance.metadata,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'admin_notes': instance.adminNotes,
      'requires_follow_up': instance.requiresFollowUp,
      'follow_up_reason': instance.followUpReason,
      'follow_up_date': instance.followUpDate?.toIso8601String(),
      'assigned_to_admin_id': instance.assignedToAdminId,
      'assigned_to_admin_name': instance.assignedToAdminName,
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
      unitPrice: (json['unit_price'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      currency: json['currency'] as String,
      codeType: json['code_type'] as String?,
      codeCount: (json['code_count'] as num?)?.toInt(),
      periodStart: json['period_start'] == null
          ? null
          : DateTime.parse(json['period_start'] as String),
      periodEnd: json['period_end'] == null
          ? null
          : DateTime.parse(json['period_end'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
      planFeatureId: json['plan_feature_id'] as String?,
      planFeatureName: json['plan_feature_name'] as String?,
      usageAmount: (json['usage_amount'] as num?)?.toDouble(),
      overageAmount: (json['overage_amount'] as num?)?.toDouble(),
      isOverageCharge: json['is_overage_charge'] as bool?,
    );

Map<String, dynamic> _$AdminInvoiceItemToJson(_AdminInvoiceItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'quantity': instance.quantity,
      'unit_price': instance.unitPrice,
      'total': instance.total,
      'currency': instance.currency,
      'code_type': instance.codeType,
      'code_count': instance.codeCount,
      'period_start': instance.periodStart?.toIso8601String(),
      'period_end': instance.periodEnd?.toIso8601String(),
      'metadata': instance.metadata,
      'plan_feature_id': instance.planFeatureId,
      'plan_feature_name': instance.planFeatureName,
      'usage_amount': instance.usageAmount,
      'overage_amount': instance.overageAmount,
      'is_overage_charge': instance.isOverageCharge,
    };

_PlatformRevenueSummary _$PlatformRevenueSummaryFromJson(
  Map<String, dynamic> json,
) => _PlatformRevenueSummary(
  totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
  collectedRevenue: (json['collected_revenue'] as num?)?.toDouble() ?? 0.0,
  pendingRevenue: (json['pending_revenue'] as num?)?.toDouble() ?? 0.0,
  overdueRevenue: (json['overdue_revenue'] as num?)?.toDouble() ?? 0.0,
  totalInvoices: (json['total_invoices'] as num?)?.toInt() ?? 0,
  paidInvoices: (json['paid_invoices'] as num?)?.toInt() ?? 0,
  pendingInvoices: (json['pending_invoices'] as num?)?.toInt() ?? 0,
  overdueInvoices: (json['overdue_invoices'] as num?)?.toInt() ?? 0,
  draftInvoices: (json['draft_invoices'] as num?)?.toInt() ?? 0,
  cancelledInvoices: (json['cancelled_invoices'] as num?)?.toInt() ?? 0,
  periodStart: json['period_start'] == null
      ? null
      : DateTime.parse(json['period_start'] as String),
  periodEnd: json['period_end'] == null
      ? null
      : DateTime.parse(json['period_end'] as String),
  revenueByPlan: (json['revenue_by_plan'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  revenueByCompanyType:
      (json['revenue_by_company_type'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
  revenueTrend: (json['revenue_trend'] as List<dynamic>?)
      ?.map((e) => RevenueTrendData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PlatformRevenueSummaryToJson(
  _PlatformRevenueSummary instance,
) => <String, dynamic>{
  'total_revenue': instance.totalRevenue,
  'collected_revenue': instance.collectedRevenue,
  'pending_revenue': instance.pendingRevenue,
  'overdue_revenue': instance.overdueRevenue,
  'total_invoices': instance.totalInvoices,
  'paid_invoices': instance.paidInvoices,
  'pending_invoices': instance.pendingInvoices,
  'overdue_invoices': instance.overdueInvoices,
  'draft_invoices': instance.draftInvoices,
  'cancelled_invoices': instance.cancelledInvoices,
  'period_start': instance.periodStart?.toIso8601String(),
  'period_end': instance.periodEnd?.toIso8601String(),
  'revenue_by_plan': instance.revenueByPlan,
  'revenue_by_company_type': instance.revenueByCompanyType,
  'revenue_trend': instance.revenueTrend?.map((e) => e.toJson()).toList(),
};

_RevenueTrendData _$RevenueTrendDataFromJson(Map<String, dynamic> json) =>
    _RevenueTrendData(
      date: DateTime.parse(json['date'] as String),
      revenue: (json['revenue'] as num).toDouble(),
      invoiceCount: (json['invoice_count'] as num).toInt(),
      paidCount: (json['paid_count'] as num).toInt(),
    );

Map<String, dynamic> _$RevenueTrendDataToJson(_RevenueTrendData instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'revenue': instance.revenue,
      'invoice_count': instance.invoiceCount,
      'paid_count': instance.paidCount,
    };

_CompanyRevenueSummary _$CompanyRevenueSummaryFromJson(
  Map<String, dynamic> json,
) => _CompanyRevenueSummary(
  companyId: json['company_id'] as String,
  companyName: json['company_name'] as String,
  companyType: json['company_type'] as String,
  totalRevenue: (json['total_revenue'] as num).toDouble(),
  paidAmount: (json['paid_amount'] as num).toDouble(),
  pendingAmount: (json['pending_amount'] as num).toDouble(),
  overdueAmount: (json['overdue_amount'] as num).toDouble(),
  totalInvoices: (json['total_invoices'] as num).toInt(),
  paidInvoices: (json['paid_invoices'] as num).toInt(),
  pendingInvoices: (json['pending_invoices'] as num).toInt(),
  overdueInvoices: (json['overdue_invoices'] as num).toInt(),
  lastPaymentDate: json['last_payment_date'] == null
      ? null
      : DateTime.parse(json['last_payment_date'] as String),
  averagePaymentDays: (json['average_payment_days'] as num?)?.toDouble(),
  currentPlan: json['current_plan'] as String?,
  subscriptionStartDate: json['subscription_start_date'] == null
      ? null
      : DateTime.parse(json['subscription_start_date'] as String),
  subscriptionEndDate: json['subscription_end_date'] == null
      ? null
      : DateTime.parse(json['subscription_end_date'] as String),
);

Map<String, dynamic> _$CompanyRevenueSummaryToJson(
  _CompanyRevenueSummary instance,
) => <String, dynamic>{
  'company_id': instance.companyId,
  'company_name': instance.companyName,
  'company_type': instance.companyType,
  'total_revenue': instance.totalRevenue,
  'paid_amount': instance.paidAmount,
  'pending_amount': instance.pendingAmount,
  'overdue_amount': instance.overdueAmount,
  'total_invoices': instance.totalInvoices,
  'paid_invoices': instance.paidInvoices,
  'pending_invoices': instance.pendingInvoices,
  'overdue_invoices': instance.overdueInvoices,
  'last_payment_date': instance.lastPaymentDate?.toIso8601String(),
  'average_payment_days': instance.averagePaymentDays,
  'current_plan': instance.currentPlan,
  'subscription_start_date': instance.subscriptionStartDate?.toIso8601String(),
  'subscription_end_date': instance.subscriptionEndDate?.toIso8601String(),
};

_PaymentReconciliation _$PaymentReconciliationFromJson(
  Map<String, dynamic> json,
) => _PaymentReconciliation(
  id: json['id'] as String,
  reconciliationDate: DateTime.parse(json['reconciliation_date'] as String),
  periodStart: DateTime.parse(json['period_start'] as String),
  periodEnd: DateTime.parse(json['period_end'] as String),
  expectedAmount: (json['expected_amount'] as num).toDouble(),
  actualAmount: (json['actual_amount'] as num).toDouble(),
  discrepancyAmount: (json['discrepancy_amount'] as num).toDouble(),
  totalTransactions: (json['total_transactions'] as num).toInt(),
  matchedTransactions: (json['matched_transactions'] as num).toInt(),
  unmatchedTransactions: (json['unmatched_transactions'] as num).toInt(),
  status: $enumDecode(_$ReconciliationStatusEnumMap, json['status']),
  notes: json['notes'] as String?,
  performedByAdminId: json['performed_by_admin_id'] as String?,
  performedByAdminName: json['performed_by_admin_name'] as String?,
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => ReconciliationItem.fromJson(e as Map<String, dynamic>))
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
  'reconciliation_date': instance.reconciliationDate.toIso8601String(),
  'period_start': instance.periodStart.toIso8601String(),
  'period_end': instance.periodEnd.toIso8601String(),
  'expected_amount': instance.expectedAmount,
  'actual_amount': instance.actualAmount,
  'discrepancy_amount': instance.discrepancyAmount,
  'total_transactions': instance.totalTransactions,
  'matched_transactions': instance.matchedTransactions,
  'unmatched_transactions': instance.unmatchedTransactions,
  'status': _$ReconciliationStatusEnumMap[instance.status]!,
  'notes': instance.notes,
  'performed_by_admin_id': instance.performedByAdminId,
  'performed_by_admin_name': instance.performedByAdminName,
  'items': instance.items?.map((e) => e.toJson()).toList(),
  'metadata': instance.metadata,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
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
      transactionId: json['transaction_id'] as String,
      invoiceId: json['invoice_id'] as String,
      invoiceNumber: json['invoice_number'] as String,
      expectedAmount: (json['expected_amount'] as num).toDouble(),
      actualAmount: (json['actual_amount'] as num).toDouble(),
      discrepancy: (json['discrepancy'] as num).toDouble(),
      status: $enumDecode(_$ReconciliationItemStatusEnumMap, json['status']),
      notes: json['notes'] as String?,
      matchedAt: json['matched_at'] == null
          ? null
          : DateTime.parse(json['matched_at'] as String),
      matchedByAdminId: json['matched_by_admin_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ReconciliationItemToJson(_ReconciliationItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'transaction_id': instance.transactionId,
      'invoice_id': instance.invoiceId,
      'invoice_number': instance.invoiceNumber,
      'expected_amount': instance.expectedAmount,
      'actual_amount': instance.actualAmount,
      'discrepancy': instance.discrepancy,
      'status': _$ReconciliationItemStatusEnumMap[instance.status]!,
      'notes': instance.notes,
      'matched_at': instance.matchedAt?.toIso8601String(),
      'matched_by_admin_id': instance.matchedByAdminId,
      'metadata': instance.metadata,
    };

const _$ReconciliationItemStatusEnumMap = {
  ReconciliationItemStatus.matched: 'matched',
  ReconciliationItemStatus.unmatched: 'unmatched',
  ReconciliationItemStatus.partialMatch: 'partial_match',
  ReconciliationItemStatus.requiresReview: 'requires_review',
};

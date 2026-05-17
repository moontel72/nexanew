// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billing_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BillingEntity _$BillingEntityFromJson(Map<String, dynamic> json) =>
    _BillingEntity(
      id: json['id'] as String,
      type: $enumDecode(_$BillingEntityTypeEnumMap, json['type']),
      referenceNumber: json['reference_number'] as String,
      companyId: json['company_id'] as String,
      companyName: json['company_name'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: $enumDecode(_$BillingEntityStatusEnumMap, json['status']),
      issueDate: DateTime.parse(json['issue_date'] as String),
      dueDate: json['due_date'] == null
          ? null
          : DateTime.parse(json['due_date'] as String),
      paymentDate: json['payment_date'] == null
          ? null
          : DateTime.parse(json['payment_date'] as String),
      settlementDate: json['settlement_date'] == null
          ? null
          : DateTime.parse(json['settlement_date'] as String),
      paymentMethod: $enumDecodeNullable(
        _$PaymentMethodEnumMap,
        json['payment_method'],
      ),
      paymentReference: json['payment_reference'] as String?,
      transactionId: json['transaction_id'] as String?,
      notes: json['notes'] as String?,
      adminNotes: json['admin_notes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      createdByAdminId: json['created_by_admin_id'] as String?,
      updatedByAdminId: json['updated_by_admin_id'] as String?,
    );

Map<String, dynamic> _$BillingEntityToJson(_BillingEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$BillingEntityTypeEnumMap[instance.type]!,
      'reference_number': instance.referenceNumber,
      'company_id': instance.companyId,
      'company_name': instance.companyName,
      'amount': instance.amount,
      'currency': instance.currency,
      'status': _$BillingEntityStatusEnumMap[instance.status]!,
      'issue_date': instance.issueDate.toIso8601String(),
      'due_date': instance.dueDate?.toIso8601String(),
      'payment_date': instance.paymentDate?.toIso8601String(),
      'settlement_date': instance.settlementDate?.toIso8601String(),
      'payment_method': _$PaymentMethodEnumMap[instance.paymentMethod],
      'payment_reference': instance.paymentReference,
      'transaction_id': instance.transactionId,
      'notes': instance.notes,
      'admin_notes': instance.adminNotes,
      'metadata': instance.metadata,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'created_by_admin_id': instance.createdByAdminId,
      'updated_by_admin_id': instance.updatedByAdminId,
    };

const _$BillingEntityTypeEnumMap = {
  BillingEntityType.invoice: 'invoice',
  BillingEntityType.creditNote: 'credit_note',
  BillingEntityType.payment: 'payment',
  BillingEntityType.refund: 'refund',
  BillingEntityType.adjustment: 'adjustment',
  BillingEntityType.reconciliation: 'reconciliation',
};

const _$BillingEntityStatusEnumMap = {
  BillingEntityStatus.draft: 'draft',
  BillingEntityStatus.pending: 'pending',
  BillingEntityStatus.paid: 'paid',
  BillingEntityStatus.overdue: 'overdue',
  BillingEntityStatus.cancelled: 'cancelled',
  BillingEntityStatus.refunded: 'refunded',
  BillingEntityStatus.partiallyPaid: 'partially_paid',
  BillingEntityStatus.inDispute: 'in_dispute',
  BillingEntityStatus.requiresReview: 'requires_review',
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.wallet: 'wallet',
  PaymentMethod.creditCard: 'credit_card',
  PaymentMethod.bankTransfer: 'bank_transfer',
  PaymentMethod.cash: 'cash',
  PaymentMethod.check: 'check',
  PaymentMethod.digitalWallet: 'digital_wallet',
  PaymentMethod.other: 'other',
};

_BillingPeriod _$BillingPeriodFromJson(Map<String, dynamic> json) =>
    _BillingPeriod(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      subscriptionId: json['subscription_id'] as String,
      periodStart: DateTime.parse(json['period_start'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
      status: $enumDecode(_$BillingPeriodStatusEnumMap, json['status']),
      estimatedAmount: (json['estimated_amount'] as num?)?.toDouble(),
      actualAmount: (json['actual_amount'] as num?)?.toDouble(),
      invoiceId: json['invoice_id'] as String?,
      invoicedAt: json['invoiced_at'] == null
          ? null
          : DateTime.parse(json['invoiced_at'] as String),
      paidAt: json['paid_at'] == null
          ? null
          : DateTime.parse(json['paid_at'] as String),
      usageData: json['usage_data'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$BillingPeriodToJson(_BillingPeriod instance) =>
    <String, dynamic>{
      'id': instance.id,
      'company_id': instance.companyId,
      'subscription_id': instance.subscriptionId,
      'period_start': instance.periodStart.toIso8601String(),
      'period_end': instance.periodEnd.toIso8601String(),
      'status': _$BillingPeriodStatusEnumMap[instance.status]!,
      'estimated_amount': instance.estimatedAmount,
      'actual_amount': instance.actualAmount,
      'invoice_id': instance.invoiceId,
      'invoiced_at': instance.invoicedAt?.toIso8601String(),
      'paid_at': instance.paidAt?.toIso8601String(),
      'usage_data': instance.usageData,
      'metadata': instance.metadata,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$BillingPeriodStatusEnumMap = {
  BillingPeriodStatus.upcoming: 'upcoming',
  BillingPeriodStatus.current: 'current',
  BillingPeriodStatus.invoiced: 'invoiced',
  BillingPeriodStatus.paid: 'paid',
  BillingPeriodStatus.overdue: 'overdue',
  BillingPeriodStatus.cancelled: 'cancelled',
};

_BillingConfiguration _$BillingConfigurationFromJson(
  Map<String, dynamic> json,
) => _BillingConfiguration(
  companyId: json['company_id'] as String,
  billingCycle: json['billing_cycle'] as String,
  billingDay: (json['billing_day'] as num).toInt(),
  currency: json['currency'] as String,
  autoGenerateInvoices: json['auto_generate_invoices'] as bool,
  sendPaymentReminders: json['send_payment_reminders'] as bool,
  paymentGracePeriodDays: (json['payment_grace_period_days'] as num?)?.toInt(),
  creditLimit: (json['credit_limit'] as num?)?.toDouble(),
  currentCreditUsed: (json['current_credit_used'] as num?)?.toDouble(),
  paymentMethods: (json['payment_methods'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  defaultPaymentMethod: json['default_payment_method'] as String?,
  billingContactEmail: json['billing_contact_email'] as String?,
  billingContactName: json['billing_contact_name'] as String?,
  billingContactPhone: json['billing_contact_phone'] as String?,
  taxSettings: json['tax_settings'] as Map<String, dynamic>?,
  invoiceSettings: json['invoice_settings'] as Map<String, dynamic>?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$BillingConfigurationToJson(
  _BillingConfiguration instance,
) => <String, dynamic>{
  'company_id': instance.companyId,
  'billing_cycle': instance.billingCycle,
  'billing_day': instance.billingDay,
  'currency': instance.currency,
  'auto_generate_invoices': instance.autoGenerateInvoices,
  'send_payment_reminders': instance.sendPaymentReminders,
  'payment_grace_period_days': instance.paymentGracePeriodDays,
  'credit_limit': instance.creditLimit,
  'current_credit_used': instance.currentCreditUsed,
  'payment_methods': instance.paymentMethods,
  'default_payment_method': instance.defaultPaymentMethod,
  'billing_contact_email': instance.billingContactEmail,
  'billing_contact_name': instance.billingContactName,
  'billing_contact_phone': instance.billingContactPhone,
  'tax_settings': instance.taxSettings,
  'invoice_settings': instance.invoiceSettings,
  'metadata': instance.metadata,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};

_BillingStatistics _$BillingStatisticsFromJson(Map<String, dynamic> json) =>
    _BillingStatistics(
      periodStart: DateTime.parse(json['period_start'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
      totalRevenue: (json['total_revenue'] as num).toDouble(),
      collectedRevenue: (json['collected_revenue'] as num).toDouble(),
      pendingRevenue: (json['pending_revenue'] as num).toDouble(),
      overdueRevenue: (json['overdue_revenue'] as num).toDouble(),
      totalInvoices: (json['total_invoices'] as num).toInt(),
      paidInvoices: (json['paid_invoices'] as num).toInt(),
      pendingInvoices: (json['pending_invoices'] as num).toInt(),
      overdueInvoices: (json['overdue_invoices'] as num).toInt(),
      averagePaymentTimeDays: (json['average_payment_time_days'] as num)
          .toDouble(),
      collectionRate: (json['collection_rate'] as num).toDouble(),
      revenueByPlan: (json['revenue_by_plan'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      revenueByCompanyType:
          (json['revenue_by_company_type'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ),
      invoiceCountByStatus:
          (json['invoice_count_by_status'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ),
      revenueTrend: (json['revenue_trend'] as List<dynamic>?)
          ?.map((e) => RevenueTrendPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      calculatedAt: json['calculated_at'] == null
          ? null
          : DateTime.parse(json['calculated_at'] as String),
    );

Map<String, dynamic> _$BillingStatisticsToJson(_BillingStatistics instance) =>
    <String, dynamic>{
      'period_start': instance.periodStart.toIso8601String(),
      'period_end': instance.periodEnd.toIso8601String(),
      'total_revenue': instance.totalRevenue,
      'collected_revenue': instance.collectedRevenue,
      'pending_revenue': instance.pendingRevenue,
      'overdue_revenue': instance.overdueRevenue,
      'total_invoices': instance.totalInvoices,
      'paid_invoices': instance.paidInvoices,
      'pending_invoices': instance.pendingInvoices,
      'overdue_invoices': instance.overdueInvoices,
      'average_payment_time_days': instance.averagePaymentTimeDays,
      'collection_rate': instance.collectionRate,
      'revenue_by_plan': instance.revenueByPlan,
      'revenue_by_company_type': instance.revenueByCompanyType,
      'invoice_count_by_status': instance.invoiceCountByStatus,
      'revenue_trend': instance.revenueTrend?.map((e) => e.toJson()).toList(),
      'calculated_at': instance.calculatedAt?.toIso8601String(),
    };

_RevenueTrendPoint _$RevenueTrendPointFromJson(Map<String, dynamic> json) =>
    _RevenueTrendPoint(
      date: DateTime.parse(json['date'] as String),
      revenue: (json['revenue'] as num).toDouble(),
      invoiceCount: (json['invoice_count'] as num).toInt(),
      paidCount: (json['paid_count'] as num).toInt(),
      averageAmount: (json['average_amount'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$RevenueTrendPointToJson(_RevenueTrendPoint instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'revenue': instance.revenue,
      'invoice_count': instance.invoiceCount,
      'paid_count': instance.paidCount,
      'average_amount': instance.averageAmount,
    };

_BillingAlert _$BillingAlertFromJson(Map<String, dynamic> json) =>
    _BillingAlert(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      type: $enumDecode(_$BillingAlertTypeEnumMap, json['type']),
      severity: $enumDecode(_$BillingAlertSeverityEnumMap, json['severity']),
      title: json['title'] as String,
      description: json['description'] as String,
      detectedAt: DateTime.parse(json['detected_at'] as String),
      isActive: json['is_active'] as bool,
      resolvedAt: json['resolved_at'] == null
          ? null
          : DateTime.parse(json['resolved_at'] as String),
      resolvedBy: json['resolved_by'] as String?,
      resolutionNotes: json['resolution_notes'] as String?,
      alertData: json['alert_data'] as Map<String, dynamic>?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$BillingAlertToJson(_BillingAlert instance) =>
    <String, dynamic>{
      'id': instance.id,
      'company_id': instance.companyId,
      'type': _$BillingAlertTypeEnumMap[instance.type]!,
      'severity': _$BillingAlertSeverityEnumMap[instance.severity]!,
      'title': instance.title,
      'description': instance.description,
      'detected_at': instance.detectedAt.toIso8601String(),
      'is_active': instance.isActive,
      'resolved_at': instance.resolvedAt?.toIso8601String(),
      'resolved_by': instance.resolvedBy,
      'resolution_notes': instance.resolutionNotes,
      'alert_data': instance.alertData,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$BillingAlertTypeEnumMap = {
  BillingAlertType.overdueInvoice: 'overdue_invoice',
  BillingAlertType.creditLimitExceeded: 'credit_limit_exceeded',
  BillingAlertType.paymentFailed: 'payment_failed',
  BillingAlertType.unusualActivity: 'unusual_activity',
  BillingAlertType.revenueDrop: 'revenue_drop',
  BillingAlertType.collectionIssue: 'collection_issue',
  BillingAlertType.systemError: 'system_error',
};

const _$BillingAlertSeverityEnumMap = {
  BillingAlertSeverity.info: 'info',
  BillingAlertSeverity.low: 'low',
  BillingAlertSeverity.medium: 'medium',
  BillingAlertSeverity.high: 'high',
  BillingAlertSeverity.critical: 'critical',
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billing_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BillingEntity _$BillingEntityFromJson(Map<String, dynamic> json) =>
    _BillingEntity(
      id: json['id'] as String,
      type: $enumDecode(_$BillingEntityTypeEnumMap, json['type']),
      referenceNumber: json['referenceNumber'] as String,
      companyId: json['companyId'] as String,
      companyName: json['companyName'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: $enumDecode(_$BillingEntityStatusEnumMap, json['status']),
      issueDate: DateTime.parse(json['issueDate'] as String),
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      paymentDate: json['paymentDate'] == null
          ? null
          : DateTime.parse(json['paymentDate'] as String),
      settlementDate: json['settlementDate'] == null
          ? null
          : DateTime.parse(json['settlementDate'] as String),
      paymentMethod: $enumDecodeNullable(
        _$PaymentMethodEnumMap,
        json['paymentMethod'],
      ),
      paymentReference: json['paymentReference'] as String?,
      transactionId: json['transactionId'] as String?,
      notes: json['notes'] as String?,
      adminNotes: json['adminNotes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      createdByAdminId: json['createdByAdminId'] as String?,
      updatedByAdminId: json['updatedByAdminId'] as String?,
    );

Map<String, dynamic> _$BillingEntityToJson(_BillingEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$BillingEntityTypeEnumMap[instance.type]!,
      'referenceNumber': instance.referenceNumber,
      'companyId': instance.companyId,
      'companyName': instance.companyName,
      'amount': instance.amount,
      'currency': instance.currency,
      'status': _$BillingEntityStatusEnumMap[instance.status]!,
      'issueDate': instance.issueDate.toIso8601String(),
      'dueDate': instance.dueDate?.toIso8601String(),
      'paymentDate': instance.paymentDate?.toIso8601String(),
      'settlementDate': instance.settlementDate?.toIso8601String(),
      'paymentMethod': _$PaymentMethodEnumMap[instance.paymentMethod],
      'paymentReference': instance.paymentReference,
      'transactionId': instance.transactionId,
      'notes': instance.notes,
      'adminNotes': instance.adminNotes,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'createdByAdminId': instance.createdByAdminId,
      'updatedByAdminId': instance.updatedByAdminId,
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
      companyId: json['companyId'] as String,
      subscriptionId: json['subscriptionId'] as String,
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      status: $enumDecode(_$BillingPeriodStatusEnumMap, json['status']),
      estimatedAmount: (json['estimatedAmount'] as num?)?.toDouble(),
      actualAmount: (json['actualAmount'] as num?)?.toDouble(),
      invoiceId: json['invoiceId'] as String?,
      invoicedAt: json['invoicedAt'] == null
          ? null
          : DateTime.parse(json['invoicedAt'] as String),
      paidAt: json['paidAt'] == null
          ? null
          : DateTime.parse(json['paidAt'] as String),
      usageData: json['usageData'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$BillingPeriodToJson(_BillingPeriod instance) =>
    <String, dynamic>{
      'id': instance.id,
      'companyId': instance.companyId,
      'subscriptionId': instance.subscriptionId,
      'periodStart': instance.periodStart.toIso8601String(),
      'periodEnd': instance.periodEnd.toIso8601String(),
      'status': _$BillingPeriodStatusEnumMap[instance.status]!,
      'estimatedAmount': instance.estimatedAmount,
      'actualAmount': instance.actualAmount,
      'invoiceId': instance.invoiceId,
      'invoicedAt': instance.invoicedAt?.toIso8601String(),
      'paidAt': instance.paidAt?.toIso8601String(),
      'usageData': instance.usageData,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
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
  companyId: json['companyId'] as String,
  billingCycle: json['billingCycle'] as String,
  billingDay: (json['billingDay'] as num).toInt(),
  currency: json['currency'] as String,
  autoGenerateInvoices: json['autoGenerateInvoices'] as bool,
  sendPaymentReminders: json['sendPaymentReminders'] as bool,
  paymentGracePeriodDays: (json['paymentGracePeriodDays'] as num?)?.toInt(),
  creditLimit: (json['creditLimit'] as num?)?.toDouble(),
  currentCreditUsed: (json['currentCreditUsed'] as num?)?.toDouble(),
  paymentMethods: (json['paymentMethods'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  defaultPaymentMethod: json['defaultPaymentMethod'] as String?,
  billingContactEmail: json['billingContactEmail'] as String?,
  billingContactName: json['billingContactName'] as String?,
  billingContactPhone: json['billingContactPhone'] as String?,
  taxSettings: json['taxSettings'] as Map<String, dynamic>?,
  invoiceSettings: json['invoiceSettings'] as Map<String, dynamic>?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$BillingConfigurationToJson(
  _BillingConfiguration instance,
) => <String, dynamic>{
  'companyId': instance.companyId,
  'billingCycle': instance.billingCycle,
  'billingDay': instance.billingDay,
  'currency': instance.currency,
  'autoGenerateInvoices': instance.autoGenerateInvoices,
  'sendPaymentReminders': instance.sendPaymentReminders,
  'paymentGracePeriodDays': instance.paymentGracePeriodDays,
  'creditLimit': instance.creditLimit,
  'currentCreditUsed': instance.currentCreditUsed,
  'paymentMethods': instance.paymentMethods,
  'defaultPaymentMethod': instance.defaultPaymentMethod,
  'billingContactEmail': instance.billingContactEmail,
  'billingContactName': instance.billingContactName,
  'billingContactPhone': instance.billingContactPhone,
  'taxSettings': instance.taxSettings,
  'invoiceSettings': instance.invoiceSettings,
  'metadata': instance.metadata,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

_BillingStatistics _$BillingStatisticsFromJson(
  Map<String, dynamic> json,
) => _BillingStatistics(
  periodStart: DateTime.parse(json['periodStart'] as String),
  periodEnd: DateTime.parse(json['periodEnd'] as String),
  totalRevenue: (json['totalRevenue'] as num).toDouble(),
  collectedRevenue: (json['collectedRevenue'] as num).toDouble(),
  pendingRevenue: (json['pendingRevenue'] as num).toDouble(),
  overdueRevenue: (json['overdueRevenue'] as num).toDouble(),
  totalInvoices: (json['totalInvoices'] as num).toInt(),
  paidInvoices: (json['paidInvoices'] as num).toInt(),
  pendingInvoices: (json['pendingInvoices'] as num).toInt(),
  overdueInvoices: (json['overdueInvoices'] as num).toInt(),
  averagePaymentTimeDays: (json['averagePaymentTimeDays'] as num).toDouble(),
  collectionRate: (json['collectionRate'] as num).toDouble(),
  revenueByPlan: (json['revenueByPlan'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  revenueByCompanyType: (json['revenueByCompanyType'] as Map<String, dynamic>?)
      ?.map((k, e) => MapEntry(k, (e as num).toDouble())),
  invoiceCountByStatus: (json['invoiceCountByStatus'] as Map<String, dynamic>?)
      ?.map((k, e) => MapEntry(k, (e as num).toInt())),
  revenueTrend: (json['revenueTrend'] as List<dynamic>?)
      ?.map((e) => RevenueTrendPoint.fromJson(e as Map<String, dynamic>))
      .toList(),
  calculatedAt: json['calculatedAt'] == null
      ? null
      : DateTime.parse(json['calculatedAt'] as String),
);

Map<String, dynamic> _$BillingStatisticsToJson(_BillingStatistics instance) =>
    <String, dynamic>{
      'periodStart': instance.periodStart.toIso8601String(),
      'periodEnd': instance.periodEnd.toIso8601String(),
      'totalRevenue': instance.totalRevenue,
      'collectedRevenue': instance.collectedRevenue,
      'pendingRevenue': instance.pendingRevenue,
      'overdueRevenue': instance.overdueRevenue,
      'totalInvoices': instance.totalInvoices,
      'paidInvoices': instance.paidInvoices,
      'pendingInvoices': instance.pendingInvoices,
      'overdueInvoices': instance.overdueInvoices,
      'averagePaymentTimeDays': instance.averagePaymentTimeDays,
      'collectionRate': instance.collectionRate,
      'revenueByPlan': instance.revenueByPlan,
      'revenueByCompanyType': instance.revenueByCompanyType,
      'invoiceCountByStatus': instance.invoiceCountByStatus,
      'revenueTrend': instance.revenueTrend,
      'calculatedAt': instance.calculatedAt?.toIso8601String(),
    };

_RevenueTrendPoint _$RevenueTrendPointFromJson(Map<String, dynamic> json) =>
    _RevenueTrendPoint(
      date: DateTime.parse(json['date'] as String),
      revenue: (json['revenue'] as num).toDouble(),
      invoiceCount: (json['invoiceCount'] as num).toInt(),
      paidCount: (json['paidCount'] as num).toInt(),
      averageAmount: (json['averageAmount'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$RevenueTrendPointToJson(_RevenueTrendPoint instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'revenue': instance.revenue,
      'invoiceCount': instance.invoiceCount,
      'paidCount': instance.paidCount,
      'averageAmount': instance.averageAmount,
    };

_BillingAlert _$BillingAlertFromJson(Map<String, dynamic> json) =>
    _BillingAlert(
      id: json['id'] as String,
      companyId: json['companyId'] as String,
      type: $enumDecode(_$BillingAlertTypeEnumMap, json['type']),
      severity: $enumDecode(_$BillingAlertSeverityEnumMap, json['severity']),
      title: json['title'] as String,
      description: json['description'] as String,
      detectedAt: DateTime.parse(json['detectedAt'] as String),
      isActive: json['isActive'] as bool,
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
      resolvedBy: json['resolvedBy'] as String?,
      resolutionNotes: json['resolutionNotes'] as String?,
      alertData: json['alertData'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$BillingAlertToJson(_BillingAlert instance) =>
    <String, dynamic>{
      'id': instance.id,
      'companyId': instance.companyId,
      'type': _$BillingAlertTypeEnumMap[instance.type]!,
      'severity': _$BillingAlertSeverityEnumMap[instance.severity]!,
      'title': instance.title,
      'description': instance.description,
      'detectedAt': instance.detectedAt.toIso8601String(),
      'isActive': instance.isActive,
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
      'resolvedBy': instance.resolvedBy,
      'resolutionNotes': instance.resolutionNotes,
      'alertData': instance.alertData,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InvoiceItem _$InvoiceItemFromJson(Map<String, dynamic> json) => _InvoiceItem(
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
);

Map<String, dynamic> _$InvoiceItemToJson(_InvoiceItem instance) =>
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
    };

_Invoice _$InvoiceFromJson(Map<String, dynamic> json) => _Invoice(
  id: json['id'] as String,
  invoiceNumber: json['invoice_number'] as String,
  companyId: json['company_id'] as String,
  subscriptionId: json['subscription_id'] as String?,
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
      .map((e) => InvoiceItem.fromJson(e as Map<String, dynamic>))
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
);

Map<String, dynamic> _$InvoiceToJson(_Invoice instance) => <String, dynamic>{
  'id': instance.id,
  'invoice_number': instance.invoiceNumber,
  'company_id': instance.companyId,
  'subscription_id': instance.subscriptionId,
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

_BillingSummary _$BillingSummaryFromJson(Map<String, dynamic> json) =>
    _BillingSummary(
      totalOwed: (json['total_owed'] as num?)?.toDouble() ?? 0.0,
      totalPaid: (json['total_paid'] as num?)?.toDouble() ?? 0.0,
      pendingInvoices: (json['pending_invoices'] as num?)?.toInt() ?? 0,
      paidInvoices: (json['paid_invoices'] as num?)?.toInt() ?? 0,
      overdueInvoices: (json['overdue_invoices'] as num?)?.toInt() ?? 0,
      nextPaymentDate: json['next_payment_date'] == null
          ? null
          : DateTime.parse(json['next_payment_date'] as String),
      nextPaymentAmount: (json['next_payment_amount'] as num?)?.toDouble(),
      nextPaymentCurrency: json['next_payment_currency'] as String?,
      usageSummary: json['usage_summary'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$BillingSummaryToJson(_BillingSummary instance) =>
    <String, dynamic>{
      'total_owed': instance.totalOwed,
      'total_paid': instance.totalPaid,
      'pending_invoices': instance.pendingInvoices,
      'paid_invoices': instance.paidInvoices,
      'overdue_invoices': instance.overdueInvoices,
      'next_payment_date': instance.nextPaymentDate?.toIso8601String(),
      'next_payment_amount': instance.nextPaymentAmount,
      'next_payment_currency': instance.nextPaymentCurrency,
      'usage_summary': instance.usageSummary,
    };

_Payment _$PaymentFromJson(Map<String, dynamic> json) => _Payment(
  id: json['id'] as String,
  invoiceId: json['invoice_id'] as String,
  amount: (json['amount'] as num).toDouble(),
  currency: json['currency'] as String,
  method: $enumDecode(_$PaymentMethodEnumMap, json['method']),
  paymentDate: DateTime.parse(json['payment_date'] as String),
  reference: json['reference'] as String?,
  transactionId: json['transaction_id'] as String?,
  notes: json['notes'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$PaymentToJson(_Payment instance) => <String, dynamic>{
  'id': instance.id,
  'invoice_id': instance.invoiceId,
  'amount': instance.amount,
  'currency': instance.currency,
  'method': _$PaymentMethodEnumMap[instance.method]!,
  'payment_date': instance.paymentDate.toIso8601String(),
  'reference': instance.reference,
  'transaction_id': instance.transactionId,
  'notes': instance.notes,
  'metadata': instance.metadata,
  'created_at': instance.createdAt?.toIso8601String(),
};

_BillingFilter _$BillingFilterFromJson(Map<String, dynamic> json) =>
    _BillingFilter(
      startDate: json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      statuses: (json['statuses'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$InvoiceStatusEnumMap, e))
          .toList(),
      minAmount: (json['min_amount'] as num?)?.toDouble(),
      maxAmount: (json['max_amount'] as num?)?.toDouble(),
      searchQuery: json['search_query'] as String?,
      sortBy: json['sort_by'] as String? ?? 'issueDate',
      sortDesc: json['sort_desc'] as bool? ?? false,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
    );

Map<String, dynamic> _$BillingFilterToJson(_BillingFilter instance) =>
    <String, dynamic>{
      'start_date': instance.startDate?.toIso8601String(),
      'end_date': instance.endDate?.toIso8601String(),
      'statuses': instance.statuses
          ?.map((e) => _$InvoiceStatusEnumMap[e]!)
          .toList(),
      'min_amount': instance.minAmount,
      'max_amount': instance.maxAmount,
      'search_query': instance.searchQuery,
      'sort_by': instance.sortBy,
      'sort_desc': instance.sortDesc,
      'page': instance.page,
      'limit': instance.limit,
    };

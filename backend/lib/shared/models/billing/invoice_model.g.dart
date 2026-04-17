// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InvoiceItem _$InvoiceItemFromJson(Map<String, dynamic> json) => _InvoiceItem(
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
);

Map<String, dynamic> _$InvoiceItemToJson(_InvoiceItem instance) =>
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
    };

_Invoice _$InvoiceFromJson(Map<String, dynamic> json) => _Invoice(
  id: json['id'] as String,
  invoiceNumber: json['invoiceNumber'] as String,
  companyId: json['companyId'] as String,
  subscriptionId: json['subscriptionId'] as String?,
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
      .map((e) => InvoiceItem.fromJson(e as Map<String, dynamic>))
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
);

Map<String, dynamic> _$InvoiceToJson(_Invoice instance) => <String, dynamic>{
  'id': instance.id,
  'invoiceNumber': instance.invoiceNumber,
  'companyId': instance.companyId,
  'subscriptionId': instance.subscriptionId,
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
      totalOwed: (json['totalOwed'] as num?)?.toDouble() ?? 0.0,
      totalPaid: (json['totalPaid'] as num?)?.toDouble() ?? 0.0,
      pendingInvoices: (json['pendingInvoices'] as num?)?.toInt() ?? 0,
      paidInvoices: (json['paidInvoices'] as num?)?.toInt() ?? 0,
      overdueInvoices: (json['overdueInvoices'] as num?)?.toInt() ?? 0,
      nextPaymentDate: json['nextPaymentDate'] == null
          ? null
          : DateTime.parse(json['nextPaymentDate'] as String),
      nextPaymentAmount: (json['nextPaymentAmount'] as num?)?.toDouble(),
      nextPaymentCurrency: json['nextPaymentCurrency'] as String?,
      usageSummary: json['usageSummary'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$BillingSummaryToJson(_BillingSummary instance) =>
    <String, dynamic>{
      'totalOwed': instance.totalOwed,
      'totalPaid': instance.totalPaid,
      'pendingInvoices': instance.pendingInvoices,
      'paidInvoices': instance.paidInvoices,
      'overdueInvoices': instance.overdueInvoices,
      'nextPaymentDate': instance.nextPaymentDate?.toIso8601String(),
      'nextPaymentAmount': instance.nextPaymentAmount,
      'nextPaymentCurrency': instance.nextPaymentCurrency,
      'usageSummary': instance.usageSummary,
    };

_Payment _$PaymentFromJson(Map<String, dynamic> json) => _Payment(
  id: json['id'] as String,
  invoiceId: json['invoiceId'] as String,
  amount: (json['amount'] as num).toDouble(),
  currency: json['currency'] as String,
  method: $enumDecode(_$PaymentMethodEnumMap, json['method']),
  paymentDate: DateTime.parse(json['paymentDate'] as String),
  reference: json['reference'] as String?,
  transactionId: json['transactionId'] as String?,
  notes: json['notes'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$PaymentToJson(_Payment instance) => <String, dynamic>{
  'id': instance.id,
  'invoiceId': instance.invoiceId,
  'amount': instance.amount,
  'currency': instance.currency,
  'method': _$PaymentMethodEnumMap[instance.method]!,
  'paymentDate': instance.paymentDate.toIso8601String(),
  'reference': instance.reference,
  'transactionId': instance.transactionId,
  'notes': instance.notes,
  'metadata': instance.metadata,
  'createdAt': instance.createdAt?.toIso8601String(),
};

_BillingFilter _$BillingFilterFromJson(Map<String, dynamic> json) =>
    _BillingFilter(
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      statuses: (json['statuses'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$InvoiceStatusEnumMap, e))
          .toList(),
      minAmount: (json['minAmount'] as num?)?.toDouble(),
      maxAmount: (json['maxAmount'] as num?)?.toDouble(),
      searchQuery: json['searchQuery'] as String?,
      sortBy: json['sortBy'] as String? ?? 'issueDate',
      sortDesc: json['sortDesc'] as bool? ?? false,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
    );

Map<String, dynamic> _$BillingFilterToJson(_BillingFilter instance) =>
    <String, dynamic>{
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'statuses': instance.statuses
          ?.map((e) => _$InvoiceStatusEnumMap[e]!)
          .toList(),
      'minAmount': instance.minAmount,
      'maxAmount': instance.maxAmount,
      'searchQuery': instance.searchQuery,
      'sortBy': instance.sortBy,
      'sortDesc': instance.sortDesc,
      'page': instance.page,
      'limit': instance.limit,
    };

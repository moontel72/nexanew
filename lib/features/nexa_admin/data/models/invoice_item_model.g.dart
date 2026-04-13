// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InvoiceItemDetail _$InvoiceItemDetailFromJson(Map<String, dynamic> json) =>
    _InvoiceItemDetail(
      id: json['id'] as String,
      invoiceId: json['invoiceId'] as String,
      description: json['description'] as String,
      itemType: json['itemType'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      currency: json['currency'] as String,
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      codeType: json['codeType'] as String?,
      codeCount: (json['codeCount'] as num?)?.toInt(),
      codeUnitPrice: (json['codeUnitPrice'] as num?)?.toDouble(),
      planFeatureId: json['planFeatureId'] as String?,
      planFeatureName: json['planFeatureName'] as String?,
      usageAmount: (json['usageAmount'] as num?)?.toDouble(),
      overageRate: (json['overageRate'] as num?)?.toDouble(),
      overageAmount: (json['overageAmount'] as num?)?.toDouble(),
      isOverageCharge: json['isOverageCharge'] as bool?,
      taxRate: (json['taxRate'] as num?)?.toDouble(),
      taxAmount: (json['taxAmount'] as num?)?.toDouble(),
      discountRate: (json['discountRate'] as num?)?.toDouble(),
      discountAmount: (json['discountAmount'] as num?)?.toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$InvoiceItemDetailToJson(_InvoiceItemDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'invoiceId': instance.invoiceId,
      'description': instance.description,
      'itemType': instance.itemType,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'totalAmount': instance.totalAmount,
      'currency': instance.currency,
      'periodStart': instance.periodStart.toIso8601String(),
      'periodEnd': instance.periodEnd.toIso8601String(),
      'codeType': instance.codeType,
      'codeCount': instance.codeCount,
      'codeUnitPrice': instance.codeUnitPrice,
      'planFeatureId': instance.planFeatureId,
      'planFeatureName': instance.planFeatureName,
      'usageAmount': instance.usageAmount,
      'overageRate': instance.overageRate,
      'overageAmount': instance.overageAmount,
      'isOverageCharge': instance.isOverageCharge,
      'taxRate': instance.taxRate,
      'taxAmount': instance.taxAmount,
      'discountRate': instance.discountRate,
      'discountAmount': instance.discountAmount,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_InvoiceItemBreakdown _$InvoiceItemBreakdownFromJson(
  Map<String, dynamic> json,
) => _InvoiceItemBreakdown(
  invoiceId: json['invoiceId'] as String,
  invoiceNumber: json['invoiceNumber'] as String,
  invoiceDate: DateTime.parse(json['invoiceDate'] as String),
  companyId: json['companyId'] as String,
  companyName: json['companyName'] as String,
  items: (json['items'] as List<dynamic>)
      .map((e) => InvoiceItemDetail.fromJson(e as Map<String, dynamic>))
      .toList(),
  subtotal: (json['subtotal'] as num).toDouble(),
  totalTax: (json['totalTax'] as num).toDouble(),
  totalDiscount: (json['totalDiscount'] as num).toDouble(),
  grandTotal: (json['grandTotal'] as num).toDouble(),
  currency: json['currency'] as String,
  totalItems: (json['totalItems'] as num?)?.toInt(),
  averageItemPrice: (json['averageItemPrice'] as num?)?.toDouble(),
  highestItemPrice: (json['highestItemPrice'] as num?)?.toDouble(),
  lowestItemPrice: (json['lowestItemPrice'] as num?)?.toDouble(),
  amountByItemType: (json['amountByItemType'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  countByItemType: (json['countByItemType'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toInt()),
  ),
);

Map<String, dynamic> _$InvoiceItemBreakdownToJson(
  _InvoiceItemBreakdown instance,
) => <String, dynamic>{
  'invoiceId': instance.invoiceId,
  'invoiceNumber': instance.invoiceNumber,
  'invoiceDate': instance.invoiceDate.toIso8601String(),
  'companyId': instance.companyId,
  'companyName': instance.companyName,
  'items': instance.items,
  'subtotal': instance.subtotal,
  'totalTax': instance.totalTax,
  'totalDiscount': instance.totalDiscount,
  'grandTotal': instance.grandTotal,
  'currency': instance.currency,
  'totalItems': instance.totalItems,
  'averageItemPrice': instance.averageItemPrice,
  'highestItemPrice': instance.highestItemPrice,
  'lowestItemPrice': instance.lowestItemPrice,
  'amountByItemType': instance.amountByItemType,
  'countByItemType': instance.countByItemType,
};

_ItemTypeSummary _$ItemTypeSummaryFromJson(Map<String, dynamic> json) =>
    _ItemTypeSummary(
      itemType: json['itemType'] as String,
      displayName: json['displayName'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      itemCount: (json['itemCount'] as num).toInt(),
      averageAmount: (json['averageAmount'] as num).toDouble(),
      currency: json['currency'] as String,
      periodStart: json['periodStart'] == null
          ? null
          : DateTime.parse(json['periodStart'] as String),
      periodEnd: json['periodEnd'] == null
          ? null
          : DateTime.parse(json['periodEnd'] as String),
      amountBySubType: (json['amountBySubType'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      countBySubType: (json['countBySubType'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
      trendData: (json['trendData'] as List<dynamic>?)
          ?.map((e) => ItemTypeTrendData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ItemTypeSummaryToJson(_ItemTypeSummary instance) =>
    <String, dynamic>{
      'itemType': instance.itemType,
      'displayName': instance.displayName,
      'totalAmount': instance.totalAmount,
      'itemCount': instance.itemCount,
      'averageAmount': instance.averageAmount,
      'currency': instance.currency,
      'periodStart': instance.periodStart?.toIso8601String(),
      'periodEnd': instance.periodEnd?.toIso8601String(),
      'amountBySubType': instance.amountBySubType,
      'countBySubType': instance.countBySubType,
      'trendData': instance.trendData,
    };

_ItemTypeTrendData _$ItemTypeTrendDataFromJson(Map<String, dynamic> json) =>
    _ItemTypeTrendData(
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
      count: (json['count'] as num).toInt(),
      itemType: json['itemType'] as String,
    );

Map<String, dynamic> _$ItemTypeTrendDataToJson(_ItemTypeTrendData instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'amount': instance.amount,
      'count': instance.count,
      'itemType': instance.itemType,
    };

_OverageChargeDetail _$OverageChargeDetailFromJson(Map<String, dynamic> json) =>
    _OverageChargeDetail(
      id: json['id'] as String,
      companyId: json['companyId'] as String,
      planFeatureId: json['planFeatureId'] as String,
      planFeatureName: json['planFeatureName'] as String,
      includedAmount: (json['includedAmount'] as num).toDouble(),
      usedAmount: (json['usedAmount'] as num).toDouble(),
      overageAmount: (json['overageAmount'] as num).toDouble(),
      overageRate: (json['overageRate'] as num).toDouble(),
      chargeAmount: (json['chargeAmount'] as num).toDouble(),
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      currency: json['currency'] as String,
      invoiceId: json['invoiceId'] as String?,
      invoiceNumber: json['invoiceNumber'] as String?,
      isInvoiced: json['isInvoiced'] as bool?,
      invoicedAt: json['invoicedAt'] == null
          ? null
          : DateTime.parse(json['invoicedAt'] as String),
      usageMetadata: json['usageMetadata'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$OverageChargeDetailToJson(
  _OverageChargeDetail instance,
) => <String, dynamic>{
  'id': instance.id,
  'companyId': instance.companyId,
  'planFeatureId': instance.planFeatureId,
  'planFeatureName': instance.planFeatureName,
  'includedAmount': instance.includedAmount,
  'usedAmount': instance.usedAmount,
  'overageAmount': instance.overageAmount,
  'overageRate': instance.overageRate,
  'chargeAmount': instance.chargeAmount,
  'periodStart': instance.periodStart.toIso8601String(),
  'periodEnd': instance.periodEnd.toIso8601String(),
  'currency': instance.currency,
  'invoiceId': instance.invoiceId,
  'invoiceNumber': instance.invoiceNumber,
  'isInvoiced': instance.isInvoiced,
  'invoicedAt': instance.invoicedAt?.toIso8601String(),
  'usageMetadata': instance.usageMetadata,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

_UsageBasedCharge _$UsageBasedChargeFromJson(Map<String, dynamic> json) =>
    _UsageBasedCharge(
      id: json['id'] as String,
      companyId: json['companyId'] as String,
      metricName: json['metricName'] as String,
      metricUnit: json['metricUnit'] as String,
      includedUnits: (json['includedUnits'] as num).toDouble(),
      usedUnits: (json['usedUnits'] as num).toDouble(),
      overageUnits: (json['overageUnits'] as num).toDouble(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalCharge: (json['totalCharge'] as num).toDouble(),
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      currency: json['currency'] as String,
      invoiceId: json['invoiceId'] as String?,
      invoiceNumber: json['invoiceNumber'] as String?,
      isInvoiced: json['isInvoiced'] as bool?,
      invoicedAt: json['invoicedAt'] == null
          ? null
          : DateTime.parse(json['invoicedAt'] as String),
      usageData: json['usageData'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$UsageBasedChargeToJson(_UsageBasedCharge instance) =>
    <String, dynamic>{
      'id': instance.id,
      'companyId': instance.companyId,
      'metricName': instance.metricName,
      'metricUnit': instance.metricUnit,
      'includedUnits': instance.includedUnits,
      'usedUnits': instance.usedUnits,
      'overageUnits': instance.overageUnits,
      'unitPrice': instance.unitPrice,
      'totalCharge': instance.totalCharge,
      'periodStart': instance.periodStart.toIso8601String(),
      'periodEnd': instance.periodEnd.toIso8601String(),
      'currency': instance.currency,
      'invoiceId': instance.invoiceId,
      'invoiceNumber': instance.invoiceNumber,
      'isInvoiced': instance.isInvoiced,
      'invoicedAt': instance.invoicedAt?.toIso8601String(),
      'usageData': instance.usageData,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

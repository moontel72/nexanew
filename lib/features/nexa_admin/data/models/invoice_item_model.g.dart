// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InvoiceItemDetail _$InvoiceItemDetailFromJson(Map<String, dynamic> json) =>
    _InvoiceItemDetail(
      id: json['id'] as String,
      invoiceId: json['invoice_id'] as String,
      description: json['description'] as String,
      itemType: json['item_type'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: (json['unit_price'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      currency: json['currency'] as String,
      periodStart: DateTime.parse(json['period_start'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
      codeType: json['code_type'] as String?,
      codeCount: (json['code_count'] as num?)?.toInt(),
      codeUnitPrice: (json['code_unit_price'] as num?)?.toDouble(),
      planFeatureId: json['plan_feature_id'] as String?,
      planFeatureName: json['plan_feature_name'] as String?,
      usageAmount: (json['usage_amount'] as num?)?.toDouble(),
      overageRate: (json['overage_rate'] as num?)?.toDouble(),
      overageAmount: (json['overage_amount'] as num?)?.toDouble(),
      isOverageCharge: json['is_overage_charge'] as bool?,
      taxRate: (json['tax_rate'] as num?)?.toDouble(),
      taxAmount: (json['tax_amount'] as num?)?.toDouble(),
      discountRate: (json['discount_rate'] as num?)?.toDouble(),
      discountAmount: (json['discount_amount'] as num?)?.toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$InvoiceItemDetailToJson(_InvoiceItemDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'invoice_id': instance.invoiceId,
      'description': instance.description,
      'item_type': instance.itemType,
      'quantity': instance.quantity,
      'unit_price': instance.unitPrice,
      'total_amount': instance.totalAmount,
      'currency': instance.currency,
      'period_start': instance.periodStart.toIso8601String(),
      'period_end': instance.periodEnd.toIso8601String(),
      'code_type': instance.codeType,
      'code_count': instance.codeCount,
      'code_unit_price': instance.codeUnitPrice,
      'plan_feature_id': instance.planFeatureId,
      'plan_feature_name': instance.planFeatureName,
      'usage_amount': instance.usageAmount,
      'overage_rate': instance.overageRate,
      'overage_amount': instance.overageAmount,
      'is_overage_charge': instance.isOverageCharge,
      'tax_rate': instance.taxRate,
      'tax_amount': instance.taxAmount,
      'discount_rate': instance.discountRate,
      'discount_amount': instance.discountAmount,
      'metadata': instance.metadata,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

_InvoiceItemBreakdown _$InvoiceItemBreakdownFromJson(
  Map<String, dynamic> json,
) => _InvoiceItemBreakdown(
  invoiceId: json['invoice_id'] as String,
  invoiceNumber: json['invoice_number'] as String,
  invoiceDate: DateTime.parse(json['invoice_date'] as String),
  companyId: json['company_id'] as String,
  companyName: json['company_name'] as String,
  items: (json['items'] as List<dynamic>)
      .map((e) => InvoiceItemDetail.fromJson(e as Map<String, dynamic>))
      .toList(),
  subtotal: (json['subtotal'] as num).toDouble(),
  totalTax: (json['total_tax'] as num).toDouble(),
  totalDiscount: (json['total_discount'] as num).toDouble(),
  grandTotal: (json['grand_total'] as num).toDouble(),
  currency: json['currency'] as String,
  totalItems: (json['total_items'] as num?)?.toInt(),
  averageItemPrice: (json['average_item_price'] as num?)?.toDouble(),
  highestItemPrice: (json['highest_item_price'] as num?)?.toDouble(),
  lowestItemPrice: (json['lowest_item_price'] as num?)?.toDouble(),
  amountByItemType: (json['amount_by_item_type'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  countByItemType: (json['count_by_item_type'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toInt()),
  ),
);

Map<String, dynamic> _$InvoiceItemBreakdownToJson(
  _InvoiceItemBreakdown instance,
) => <String, dynamic>{
  'invoice_id': instance.invoiceId,
  'invoice_number': instance.invoiceNumber,
  'invoice_date': instance.invoiceDate.toIso8601String(),
  'company_id': instance.companyId,
  'company_name': instance.companyName,
  'items': instance.items.map((e) => e.toJson()).toList(),
  'subtotal': instance.subtotal,
  'total_tax': instance.totalTax,
  'total_discount': instance.totalDiscount,
  'grand_total': instance.grandTotal,
  'currency': instance.currency,
  'total_items': instance.totalItems,
  'average_item_price': instance.averageItemPrice,
  'highest_item_price': instance.highestItemPrice,
  'lowest_item_price': instance.lowestItemPrice,
  'amount_by_item_type': instance.amountByItemType,
  'count_by_item_type': instance.countByItemType,
};

_ItemTypeSummary _$ItemTypeSummaryFromJson(Map<String, dynamic> json) =>
    _ItemTypeSummary(
      itemType: json['item_type'] as String,
      displayName: json['display_name'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      itemCount: (json['item_count'] as num).toInt(),
      averageAmount: (json['average_amount'] as num).toDouble(),
      currency: json['currency'] as String,
      periodStart: json['period_start'] == null
          ? null
          : DateTime.parse(json['period_start'] as String),
      periodEnd: json['period_end'] == null
          ? null
          : DateTime.parse(json['period_end'] as String),
      amountBySubType: (json['amount_by_sub_type'] as Map<String, dynamic>?)
          ?.map((k, e) => MapEntry(k, (e as num).toDouble())),
      countBySubType: (json['count_by_sub_type'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
      trendData: (json['trend_data'] as List<dynamic>?)
          ?.map((e) => ItemTypeTrendData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ItemTypeSummaryToJson(_ItemTypeSummary instance) =>
    <String, dynamic>{
      'item_type': instance.itemType,
      'display_name': instance.displayName,
      'total_amount': instance.totalAmount,
      'item_count': instance.itemCount,
      'average_amount': instance.averageAmount,
      'currency': instance.currency,
      'period_start': instance.periodStart?.toIso8601String(),
      'period_end': instance.periodEnd?.toIso8601String(),
      'amount_by_sub_type': instance.amountBySubType,
      'count_by_sub_type': instance.countBySubType,
      'trend_data': instance.trendData?.map((e) => e.toJson()).toList(),
    };

_ItemTypeTrendData _$ItemTypeTrendDataFromJson(Map<String, dynamic> json) =>
    _ItemTypeTrendData(
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
      count: (json['count'] as num).toInt(),
      itemType: json['item_type'] as String,
    );

Map<String, dynamic> _$ItemTypeTrendDataToJson(_ItemTypeTrendData instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'amount': instance.amount,
      'count': instance.count,
      'item_type': instance.itemType,
    };

_OverageChargeDetail _$OverageChargeDetailFromJson(Map<String, dynamic> json) =>
    _OverageChargeDetail(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      planFeatureId: json['plan_feature_id'] as String,
      planFeatureName: json['plan_feature_name'] as String,
      includedAmount: (json['included_amount'] as num).toDouble(),
      usedAmount: (json['used_amount'] as num).toDouble(),
      overageAmount: (json['overage_amount'] as num).toDouble(),
      overageRate: (json['overage_rate'] as num).toDouble(),
      chargeAmount: (json['charge_amount'] as num).toDouble(),
      periodStart: DateTime.parse(json['period_start'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
      currency: json['currency'] as String,
      invoiceId: json['invoice_id'] as String?,
      invoiceNumber: json['invoice_number'] as String?,
      isInvoiced: json['is_invoiced'] as bool?,
      invoicedAt: json['invoiced_at'] == null
          ? null
          : DateTime.parse(json['invoiced_at'] as String),
      usageMetadata: json['usage_metadata'] as Map<String, dynamic>?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$OverageChargeDetailToJson(
  _OverageChargeDetail instance,
) => <String, dynamic>{
  'id': instance.id,
  'company_id': instance.companyId,
  'plan_feature_id': instance.planFeatureId,
  'plan_feature_name': instance.planFeatureName,
  'included_amount': instance.includedAmount,
  'used_amount': instance.usedAmount,
  'overage_amount': instance.overageAmount,
  'overage_rate': instance.overageRate,
  'charge_amount': instance.chargeAmount,
  'period_start': instance.periodStart.toIso8601String(),
  'period_end': instance.periodEnd.toIso8601String(),
  'currency': instance.currency,
  'invoice_id': instance.invoiceId,
  'invoice_number': instance.invoiceNumber,
  'is_invoiced': instance.isInvoiced,
  'invoiced_at': instance.invoicedAt?.toIso8601String(),
  'usage_metadata': instance.usageMetadata,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};

_UsageBasedCharge _$UsageBasedChargeFromJson(Map<String, dynamic> json) =>
    _UsageBasedCharge(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      metricName: json['metric_name'] as String,
      metricUnit: json['metric_unit'] as String,
      includedUnits: (json['included_units'] as num).toDouble(),
      usedUnits: (json['used_units'] as num).toDouble(),
      overageUnits: (json['overage_units'] as num).toDouble(),
      unitPrice: (json['unit_price'] as num).toDouble(),
      totalCharge: (json['total_charge'] as num).toDouble(),
      periodStart: DateTime.parse(json['period_start'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
      currency: json['currency'] as String,
      invoiceId: json['invoice_id'] as String?,
      invoiceNumber: json['invoice_number'] as String?,
      isInvoiced: json['is_invoiced'] as bool?,
      invoicedAt: json['invoiced_at'] == null
          ? null
          : DateTime.parse(json['invoiced_at'] as String),
      usageData: json['usage_data'] as Map<String, dynamic>?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$UsageBasedChargeToJson(_UsageBasedCharge instance) =>
    <String, dynamic>{
      'id': instance.id,
      'company_id': instance.companyId,
      'metric_name': instance.metricName,
      'metric_unit': instance.metricUnit,
      'included_units': instance.includedUnits,
      'used_units': instance.usedUnits,
      'overage_units': instance.overageUnits,
      'unit_price': instance.unitPrice,
      'total_charge': instance.totalCharge,
      'period_start': instance.periodStart.toIso8601String(),
      'period_end': instance.periodEnd.toIso8601String(),
      'currency': instance.currency,
      'invoice_id': instance.invoiceId,
      'invoice_number': instance.invoiceNumber,
      'is_invoiced': instance.isInvoiced,
      'invoiced_at': instance.invoicedAt?.toIso8601String(),
      'usage_data': instance.usageData,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

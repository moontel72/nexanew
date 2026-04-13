// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'revenue_report_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RevenueDataPoint _$RevenueDataPointFromJson(Map<String, dynamic> json) =>
    _RevenueDataPoint(
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      type: $enumDecode(_$RevenueTypeEnumMap, json['type']),
      companyId: json['companyId'] as String?,
      planId: json['planId'] as String?,
      region: json['region'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$RevenueDataPointToJson(_RevenueDataPoint instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'amount': instance.amount,
      'currency': instance.currency,
      'type': _$RevenueTypeEnumMap[instance.type]!,
      'companyId': instance.companyId,
      'planId': instance.planId,
      'region': instance.region,
      'metadata': instance.metadata,
    };

const _$RevenueTypeEnumMap = {
  RevenueType.subscription: 'subscription',
  RevenueType.usage: 'usage',
  RevenueType.commission: 'commission',
  RevenueType.oneTime: 'one_time',
  RevenueType.refund: 'refund',
  RevenueType.creditNote: 'credit_note',
  RevenueType.other: 'other',
};

_RevenueBreakdown _$RevenueBreakdownFromJson(Map<String, dynamic> json) =>
    _RevenueBreakdown(
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      subscriptionRevenue:
          (json['subscriptionRevenue'] as num?)?.toDouble() ?? 0.0,
      usageRevenue: (json['usageRevenue'] as num?)?.toDouble() ?? 0.0,
      commissionRevenue: (json['commissionRevenue'] as num?)?.toDouble() ?? 0.0,
      oneTimeRevenue: (json['oneTimeRevenue'] as num?)?.toDouble() ?? 0.0,
      refundAmount: (json['refundAmount'] as num?)?.toDouble() ?? 0.0,
      creditNoteAmount: (json['creditNoteAmount'] as num?)?.toDouble() ?? 0.0,
      netRevenue: (json['netRevenue'] as num?)?.toDouble() ?? 0.0,
      revenueByCompany: (json['revenueByCompany'] as Map<String, dynamic>?)
          ?.map((k, e) => MapEntry(k, (e as num).toDouble())),
      revenueByPlan: (json['revenueByPlan'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      revenueByRegion: (json['revenueByRegion'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      revenueByType: (json['revenueByType'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      dataPoints: (json['dataPoints'] as List<dynamic>?)
          ?.map((e) => RevenueDataPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RevenueBreakdownToJson(_RevenueBreakdown instance) =>
    <String, dynamic>{
      'totalRevenue': instance.totalRevenue,
      'currency': instance.currency,
      'subscriptionRevenue': instance.subscriptionRevenue,
      'usageRevenue': instance.usageRevenue,
      'commissionRevenue': instance.commissionRevenue,
      'oneTimeRevenue': instance.oneTimeRevenue,
      'refundAmount': instance.refundAmount,
      'creditNoteAmount': instance.creditNoteAmount,
      'netRevenue': instance.netRevenue,
      'revenueByCompany': instance.revenueByCompany,
      'revenueByPlan': instance.revenueByPlan,
      'revenueByRegion': instance.revenueByRegion,
      'revenueByType': instance.revenueByType,
      'dataPoints': instance.dataPoints,
    };

_FinancialReport _$FinancialReportFromJson(Map<String, dynamic> json) =>
    _FinancialReport(
      id: json['id'] as String,
      reportName: json['reportName'] as String,
      period: $enumDecode(_$ReportPeriodEnumMap, json['period']),
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      revenue: RevenueBreakdown.fromJson(
        json['revenue'] as Map<String, dynamic>,
      ),
      totalExpenses: (json['totalExpenses'] as num?)?.toDouble() ?? 0.0,
      grossProfit: (json['grossProfit'] as num?)?.toDouble() ?? 0.0,
      operatingProfit: (json['operatingProfit'] as num?)?.toDouble() ?? 0.0,
      netProfit: (json['netProfit'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      taxRate: (json['taxRate'] as num?)?.toDouble() ?? 0.0,
      totalInvoices: (json['totalInvoices'] as num?)?.toInt() ?? 0,
      paidInvoices: (json['paidInvoices'] as num?)?.toInt() ?? 0,
      overdueInvoices: (json['overdueInvoices'] as num?)?.toInt() ?? 0,
      newCustomers: (json['newCustomers'] as num?)?.toInt() ?? 0,
      churnedCustomers: (json['churnedCustomers'] as num?)?.toInt() ?? 0,
      customerLifetimeValue:
          (json['customerLifetimeValue'] as num?)?.toDouble() ?? 0.0,
      monthlyRecurringRevenue:
          (json['monthlyRecurringRevenue'] as num?)?.toDouble() ?? 0.0,
      annualRecurringRevenue:
          (json['annualRecurringRevenue'] as num?)?.toDouble() ?? 0.0,
      churnRate: (json['churnRate'] as num?)?.toDouble() ?? 0.0,
      growthRate: (json['growthRate'] as num?)?.toDouble() ?? 0.0,
      metrics: json['metrics'] as Map<String, dynamic>?,
      comparisons: json['comparisons'] as Map<String, dynamic>?,
      notes: json['notes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$FinancialReportToJson(_FinancialReport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reportName': instance.reportName,
      'period': _$ReportPeriodEnumMap[instance.period]!,
      'periodStart': instance.periodStart.toIso8601String(),
      'periodEnd': instance.periodEnd.toIso8601String(),
      'generatedAt': instance.generatedAt.toIso8601String(),
      'revenue': instance.revenue,
      'totalExpenses': instance.totalExpenses,
      'grossProfit': instance.grossProfit,
      'operatingProfit': instance.operatingProfit,
      'netProfit': instance.netProfit,
      'taxAmount': instance.taxAmount,
      'taxRate': instance.taxRate,
      'totalInvoices': instance.totalInvoices,
      'paidInvoices': instance.paidInvoices,
      'overdueInvoices': instance.overdueInvoices,
      'newCustomers': instance.newCustomers,
      'churnedCustomers': instance.churnedCustomers,
      'customerLifetimeValue': instance.customerLifetimeValue,
      'monthlyRecurringRevenue': instance.monthlyRecurringRevenue,
      'annualRecurringRevenue': instance.annualRecurringRevenue,
      'churnRate': instance.churnRate,
      'growthRate': instance.growthRate,
      'metrics': instance.metrics,
      'comparisons': instance.comparisons,
      'notes': instance.notes,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$ReportPeriodEnumMap = {
  ReportPeriod.daily: 'daily',
  ReportPeriod.weekly: 'weekly',
  ReportPeriod.monthly: 'monthly',
  ReportPeriod.quarterly: 'quarterly',
  ReportPeriod.yearly: 'yearly',
  ReportPeriod.custom: 'custom',
};

_RevenueForecast _$RevenueForecastFromJson(Map<String, dynamic> json) =>
    _RevenueForecast(
      forecastDate: DateTime.parse(json['forecastDate'] as String),
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      forecastedRevenue: (json['forecastedRevenue'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      lowerBound: (json['lowerBound'] as num?)?.toDouble() ?? 0.0,
      upperBound: (json['upperBound'] as num?)?.toDouble() ?? 0.0,
      confidenceLevel: (json['confidenceLevel'] as num?)?.toDouble() ?? 0.0,
      forecastByType: (json['forecastByType'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      forecastByCompany: (json['forecastByCompany'] as Map<String, dynamic>?)
          ?.map((k, e) => MapEntry(k, (e as num).toDouble())),
      historicalData: (json['historicalData'] as List<dynamic>?)
          ?.map((e) => RevenueDataPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      forecastData: (json['forecastData'] as List<dynamic>?)
          ?.map((e) => RevenueDataPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      methodology: json['methodology'] as String?,
      assumptions: json['assumptions'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$RevenueForecastToJson(_RevenueForecast instance) =>
    <String, dynamic>{
      'forecastDate': instance.forecastDate.toIso8601String(),
      'periodStart': instance.periodStart.toIso8601String(),
      'periodEnd': instance.periodEnd.toIso8601String(),
      'forecastedRevenue': instance.forecastedRevenue,
      'currency': instance.currency,
      'lowerBound': instance.lowerBound,
      'upperBound': instance.upperBound,
      'confidenceLevel': instance.confidenceLevel,
      'forecastByType': instance.forecastByType,
      'forecastByCompany': instance.forecastByCompany,
      'historicalData': instance.historicalData,
      'forecastData': instance.forecastData,
      'methodology': instance.methodology,
      'assumptions': instance.assumptions,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_TaxSummary _$TaxSummaryFromJson(Map<String, dynamic> json) => _TaxSummary(
  periodStart: DateTime.parse(json['periodStart'] as String),
  periodEnd: DateTime.parse(json['periodEnd'] as String),
  taxableRevenue: (json['taxableRevenue'] as num?)?.toDouble() ?? 0.0,
  taxCollected: (json['taxCollected'] as num?)?.toDouble() ?? 0.0,
  currency: json['currency'] as String? ?? 'USD',
  taxRate: (json['taxRate'] as num?)?.toDouble() ?? 0.0,
  taxByJurisdiction: (json['taxByJurisdiction'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  taxByCompany: (json['taxByCompany'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  taxByRevenueType: (json['taxByRevenueType'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  transactions: (json['transactions'] as List<dynamic>?)
      ?.map((e) => TaxTransaction.fromJson(e as Map<String, dynamic>))
      .toList(),
  notes: json['notes'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  generatedAt: json['generatedAt'] == null
      ? null
      : DateTime.parse(json['generatedAt'] as String),
);

Map<String, dynamic> _$TaxSummaryToJson(_TaxSummary instance) =>
    <String, dynamic>{
      'periodStart': instance.periodStart.toIso8601String(),
      'periodEnd': instance.periodEnd.toIso8601String(),
      'taxableRevenue': instance.taxableRevenue,
      'taxCollected': instance.taxCollected,
      'currency': instance.currency,
      'taxRate': instance.taxRate,
      'taxByJurisdiction': instance.taxByJurisdiction,
      'taxByCompany': instance.taxByCompany,
      'taxByRevenueType': instance.taxByRevenueType,
      'transactions': instance.transactions,
      'notes': instance.notes,
      'metadata': instance.metadata,
      'generatedAt': instance.generatedAt?.toIso8601String(),
    };

_TaxTransaction _$TaxTransactionFromJson(Map<String, dynamic> json) =>
    _TaxTransaction(
      id: json['id'] as String,
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      amount: (json['amount'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num).toDouble(),
      currency: json['currency'] as String,
      taxRate: (json['taxRate'] as num).toDouble(),
      companyId: json['companyId'] as String?,
      invoiceId: json['invoiceId'] as String?,
      revenueType: $enumDecodeNullable(
        _$RevenueTypeEnumMap,
        json['revenueType'],
      ),
      jurisdiction: json['jurisdiction'] as String?,
      taxCode: json['taxCode'] as String?,
      description: json['description'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$TaxTransactionToJson(_TaxTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'transactionDate': instance.transactionDate.toIso8601String(),
      'amount': instance.amount,
      'taxAmount': instance.taxAmount,
      'currency': instance.currency,
      'taxRate': instance.taxRate,
      'companyId': instance.companyId,
      'invoiceId': instance.invoiceId,
      'revenueType': _$RevenueTypeEnumMap[instance.revenueType],
      'jurisdiction': instance.jurisdiction,
      'taxCode': instance.taxCode,
      'description': instance.description,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_ReportFilter _$ReportFilterFromJson(Map<String, dynamic> json) =>
    _ReportFilter(
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      revenueTypes: (json['revenueTypes'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$RevenueTypeEnumMap, e))
          .toList(),
      companyIds: (json['companyIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      planIds: (json['planIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      regions: (json['regions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      period: $enumDecodeNullable(_$ReportPeriodEnumMap, json['period']),
      sortBy: json['sortBy'] as String? ?? 'generatedAt',
      sortDesc: json['sortDesc'] as bool? ?? false,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
    );

Map<String, dynamic> _$ReportFilterToJson(_ReportFilter instance) =>
    <String, dynamic>{
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'revenueTypes': instance.revenueTypes
          ?.map((e) => _$RevenueTypeEnumMap[e]!)
          .toList(),
      'companyIds': instance.companyIds,
      'planIds': instance.planIds,
      'regions': instance.regions,
      'period': _$ReportPeriodEnumMap[instance.period],
      'sortBy': instance.sortBy,
      'sortDesc': instance.sortDesc,
      'page': instance.page,
      'limit': instance.limit,
    };

_ExportRequest _$ExportRequestFromJson(Map<String, dynamic> json) =>
    _ExportRequest(
      format: json['format'] as String,
      filter: ReportFilter.fromJson(json['filter'] as Map<String, dynamic>),
      columns: (json['columns'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      includeCharts: json['includeCharts'] as bool? ?? false,
      fileName: json['fileName'] as String?,
      options: json['options'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ExportRequestToJson(_ExportRequest instance) =>
    <String, dynamic>{
      'format': instance.format,
      'filter': instance.filter,
      'columns': instance.columns,
      'includeCharts': instance.includeCharts,
      'fileName': instance.fileName,
      'options': instance.options,
    };

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
      companyId: json['company_id'] as String?,
      planId: json['plan_id'] as String?,
      region: json['region'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$RevenueDataPointToJson(_RevenueDataPoint instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'amount': instance.amount,
      'currency': instance.currency,
      'type': _$RevenueTypeEnumMap[instance.type]!,
      'company_id': instance.companyId,
      'plan_id': instance.planId,
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
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      subscriptionRevenue:
          (json['subscription_revenue'] as num?)?.toDouble() ?? 0.0,
      usageRevenue: (json['usage_revenue'] as num?)?.toDouble() ?? 0.0,
      commissionRevenue:
          (json['commission_revenue'] as num?)?.toDouble() ?? 0.0,
      oneTimeRevenue: (json['one_time_revenue'] as num?)?.toDouble() ?? 0.0,
      refundAmount: (json['refund_amount'] as num?)?.toDouble() ?? 0.0,
      creditNoteAmount: (json['credit_note_amount'] as num?)?.toDouble() ?? 0.0,
      netRevenue: (json['net_revenue'] as num?)?.toDouble() ?? 0.0,
      revenueByCompany: (json['revenue_by_company'] as Map<String, dynamic>?)
          ?.map((k, e) => MapEntry(k, (e as num).toDouble())),
      revenueByPlan: (json['revenue_by_plan'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      revenueByRegion: (json['revenue_by_region'] as Map<String, dynamic>?)
          ?.map((k, e) => MapEntry(k, (e as num).toDouble())),
      revenueByType: (json['revenue_by_type'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      dataPoints: (json['data_points'] as List<dynamic>?)
          ?.map((e) => RevenueDataPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RevenueBreakdownToJson(_RevenueBreakdown instance) =>
    <String, dynamic>{
      'total_revenue': instance.totalRevenue,
      'currency': instance.currency,
      'subscription_revenue': instance.subscriptionRevenue,
      'usage_revenue': instance.usageRevenue,
      'commission_revenue': instance.commissionRevenue,
      'one_time_revenue': instance.oneTimeRevenue,
      'refund_amount': instance.refundAmount,
      'credit_note_amount': instance.creditNoteAmount,
      'net_revenue': instance.netRevenue,
      'revenue_by_company': instance.revenueByCompany,
      'revenue_by_plan': instance.revenueByPlan,
      'revenue_by_region': instance.revenueByRegion,
      'revenue_by_type': instance.revenueByType,
      'data_points': instance.dataPoints?.map((e) => e.toJson()).toList(),
    };

_FinancialReport _$FinancialReportFromJson(Map<String, dynamic> json) =>
    _FinancialReport(
      id: json['id'] as String,
      reportName: json['report_name'] as String,
      period: $enumDecode(_$ReportPeriodEnumMap, json['period']),
      periodStart: DateTime.parse(json['period_start'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
      generatedAt: DateTime.parse(json['generated_at'] as String),
      revenue: RevenueBreakdown.fromJson(
        json['revenue'] as Map<String, dynamic>,
      ),
      totalExpenses: (json['total_expenses'] as num?)?.toDouble() ?? 0.0,
      grossProfit: (json['gross_profit'] as num?)?.toDouble() ?? 0.0,
      operatingProfit: (json['operating_profit'] as num?)?.toDouble() ?? 0.0,
      netProfit: (json['net_profit'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['tax_amount'] as num?)?.toDouble() ?? 0.0,
      taxRate: (json['tax_rate'] as num?)?.toDouble() ?? 0.0,
      totalInvoices: (json['total_invoices'] as num?)?.toInt() ?? 0,
      paidInvoices: (json['paid_invoices'] as num?)?.toInt() ?? 0,
      overdueInvoices: (json['overdue_invoices'] as num?)?.toInt() ?? 0,
      newCustomers: (json['new_customers'] as num?)?.toInt() ?? 0,
      churnedCustomers: (json['churned_customers'] as num?)?.toInt() ?? 0,
      customerLifetimeValue:
          (json['customer_lifetime_value'] as num?)?.toDouble() ?? 0.0,
      monthlyRecurringRevenue:
          (json['monthly_recurring_revenue'] as num?)?.toDouble() ?? 0.0,
      annualRecurringRevenue:
          (json['annual_recurring_revenue'] as num?)?.toDouble() ?? 0.0,
      churnRate: (json['churn_rate'] as num?)?.toDouble() ?? 0.0,
      growthRate: (json['growth_rate'] as num?)?.toDouble() ?? 0.0,
      metrics: json['metrics'] as Map<String, dynamic>?,
      comparisons: json['comparisons'] as Map<String, dynamic>?,
      notes: json['notes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$FinancialReportToJson(_FinancialReport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'report_name': instance.reportName,
      'period': _$ReportPeriodEnumMap[instance.period]!,
      'period_start': instance.periodStart.toIso8601String(),
      'period_end': instance.periodEnd.toIso8601String(),
      'generated_at': instance.generatedAt.toIso8601String(),
      'revenue': instance.revenue.toJson(),
      'total_expenses': instance.totalExpenses,
      'gross_profit': instance.grossProfit,
      'operating_profit': instance.operatingProfit,
      'net_profit': instance.netProfit,
      'tax_amount': instance.taxAmount,
      'tax_rate': instance.taxRate,
      'total_invoices': instance.totalInvoices,
      'paid_invoices': instance.paidInvoices,
      'overdue_invoices': instance.overdueInvoices,
      'new_customers': instance.newCustomers,
      'churned_customers': instance.churnedCustomers,
      'customer_lifetime_value': instance.customerLifetimeValue,
      'monthly_recurring_revenue': instance.monthlyRecurringRevenue,
      'annual_recurring_revenue': instance.annualRecurringRevenue,
      'churn_rate': instance.churnRate,
      'growth_rate': instance.growthRate,
      'metrics': instance.metrics,
      'comparisons': instance.comparisons,
      'notes': instance.notes,
      'metadata': instance.metadata,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
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
      forecastDate: DateTime.parse(json['forecast_date'] as String),
      periodStart: DateTime.parse(json['period_start'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
      forecastedRevenue:
          (json['forecasted_revenue'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      lowerBound: (json['lower_bound'] as num?)?.toDouble() ?? 0.0,
      upperBound: (json['upper_bound'] as num?)?.toDouble() ?? 0.0,
      confidenceLevel: (json['confidence_level'] as num?)?.toDouble() ?? 0.0,
      forecastByType: (json['forecast_by_type'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      forecastByCompany: (json['forecast_by_company'] as Map<String, dynamic>?)
          ?.map((k, e) => MapEntry(k, (e as num).toDouble())),
      historicalData: (json['historical_data'] as List<dynamic>?)
          ?.map((e) => RevenueDataPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      forecastData: (json['forecast_data'] as List<dynamic>?)
          ?.map((e) => RevenueDataPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      methodology: json['methodology'] as String?,
      assumptions: json['assumptions'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$RevenueForecastToJson(
  _RevenueForecast instance,
) => <String, dynamic>{
  'forecast_date': instance.forecastDate.toIso8601String(),
  'period_start': instance.periodStart.toIso8601String(),
  'period_end': instance.periodEnd.toIso8601String(),
  'forecasted_revenue': instance.forecastedRevenue,
  'currency': instance.currency,
  'lower_bound': instance.lowerBound,
  'upper_bound': instance.upperBound,
  'confidence_level': instance.confidenceLevel,
  'forecast_by_type': instance.forecastByType,
  'forecast_by_company': instance.forecastByCompany,
  'historical_data': instance.historicalData?.map((e) => e.toJson()).toList(),
  'forecast_data': instance.forecastData?.map((e) => e.toJson()).toList(),
  'methodology': instance.methodology,
  'assumptions': instance.assumptions,
  'metadata': instance.metadata,
  'created_at': instance.createdAt?.toIso8601String(),
};

_TaxSummary _$TaxSummaryFromJson(Map<String, dynamic> json) => _TaxSummary(
  periodStart: DateTime.parse(json['period_start'] as String),
  periodEnd: DateTime.parse(json['period_end'] as String),
  taxableRevenue: (json['taxable_revenue'] as num?)?.toDouble() ?? 0.0,
  taxCollected: (json['tax_collected'] as num?)?.toDouble() ?? 0.0,
  currency: json['currency'] as String? ?? 'USD',
  taxRate: (json['tax_rate'] as num?)?.toDouble() ?? 0.0,
  taxByJurisdiction: (json['tax_by_jurisdiction'] as Map<String, dynamic>?)
      ?.map((k, e) => MapEntry(k, (e as num).toDouble())),
  taxByCompany: (json['tax_by_company'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  taxByRevenueType: (json['tax_by_revenue_type'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  transactions: (json['transactions'] as List<dynamic>?)
      ?.map((e) => TaxTransaction.fromJson(e as Map<String, dynamic>))
      .toList(),
  notes: json['notes'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  generatedAt: json['generated_at'] == null
      ? null
      : DateTime.parse(json['generated_at'] as String),
);

Map<String, dynamic> _$TaxSummaryToJson(_TaxSummary instance) =>
    <String, dynamic>{
      'period_start': instance.periodStart.toIso8601String(),
      'period_end': instance.periodEnd.toIso8601String(),
      'taxable_revenue': instance.taxableRevenue,
      'tax_collected': instance.taxCollected,
      'currency': instance.currency,
      'tax_rate': instance.taxRate,
      'tax_by_jurisdiction': instance.taxByJurisdiction,
      'tax_by_company': instance.taxByCompany,
      'tax_by_revenue_type': instance.taxByRevenueType,
      'transactions': instance.transactions?.map((e) => e.toJson()).toList(),
      'notes': instance.notes,
      'metadata': instance.metadata,
      'generated_at': instance.generatedAt?.toIso8601String(),
    };

_TaxTransaction _$TaxTransactionFromJson(Map<String, dynamic> json) =>
    _TaxTransaction(
      id: json['id'] as String,
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      amount: (json['amount'] as num).toDouble(),
      taxAmount: (json['tax_amount'] as num).toDouble(),
      currency: json['currency'] as String,
      taxRate: (json['tax_rate'] as num).toDouble(),
      companyId: json['company_id'] as String?,
      invoiceId: json['invoice_id'] as String?,
      revenueType: $enumDecodeNullable(
        _$RevenueTypeEnumMap,
        json['revenue_type'],
      ),
      jurisdiction: json['jurisdiction'] as String?,
      taxCode: json['tax_code'] as String?,
      description: json['description'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$TaxTransactionToJson(_TaxTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'transaction_date': instance.transactionDate.toIso8601String(),
      'amount': instance.amount,
      'tax_amount': instance.taxAmount,
      'currency': instance.currency,
      'tax_rate': instance.taxRate,
      'company_id': instance.companyId,
      'invoice_id': instance.invoiceId,
      'revenue_type': _$RevenueTypeEnumMap[instance.revenueType],
      'jurisdiction': instance.jurisdiction,
      'tax_code': instance.taxCode,
      'description': instance.description,
      'metadata': instance.metadata,
      'created_at': instance.createdAt?.toIso8601String(),
    };

_ReportFilter _$ReportFilterFromJson(Map<String, dynamic> json) =>
    _ReportFilter(
      startDate: json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      revenueTypes: (json['revenue_types'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$RevenueTypeEnumMap, e))
          .toList(),
      companyIds: (json['company_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      planIds: (json['plan_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      regions: (json['regions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      period: $enumDecodeNullable(_$ReportPeriodEnumMap, json['period']),
      sortBy: json['sort_by'] as String? ?? 'generatedAt',
      sortDesc: json['sort_desc'] as bool? ?? false,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
    );

Map<String, dynamic> _$ReportFilterToJson(_ReportFilter instance) =>
    <String, dynamic>{
      'start_date': instance.startDate?.toIso8601String(),
      'end_date': instance.endDate?.toIso8601String(),
      'revenue_types': instance.revenueTypes
          ?.map((e) => _$RevenueTypeEnumMap[e]!)
          .toList(),
      'company_ids': instance.companyIds,
      'plan_ids': instance.planIds,
      'regions': instance.regions,
      'period': _$ReportPeriodEnumMap[instance.period],
      'sort_by': instance.sortBy,
      'sort_desc': instance.sortDesc,
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
      includeCharts: json['include_charts'] as bool? ?? false,
      fileName: json['file_name'] as String?,
      options: json['options'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ExportRequestToJson(_ExportRequest instance) =>
    <String, dynamic>{
      'format': instance.format,
      'filter': instance.filter.toJson(),
      'columns': instance.columns,
      'include_charts': instance.includeCharts,
      'file_name': instance.fileName,
      'options': instance.options,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'revenue_report_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RevenueReport _$RevenueReportFromJson(
  Map<String, dynamic> json,
) => _RevenueReport(
  id: json['id'] as String,
  reportNumber: json['report_number'] as String,
  reportName: json['report_name'] as String,
  type: $enumDecode(_$ReportTypeEnumMap, json['type']),
  periodStart: DateTime.parse(json['period_start'] as String),
  periodEnd: DateTime.parse(json['period_end'] as String),
  generatedAt: DateTime.parse(json['generated_at'] as String),
  generatedByAdminId: json['generated_by_admin_id'] as String,
  generatedByAdminName: json['generated_by_admin_name'] as String,
  status: $enumDecode(_$ReportStatusEnumMap, json['status']),
  totalRevenue: (json['total_revenue'] as num).toDouble(),
  collectedRevenue: (json['collected_revenue'] as num).toDouble(),
  pendingRevenue: (json['pending_revenue'] as num).toDouble(),
  overdueRevenue: (json['overdue_revenue'] as num).toDouble(),
  refundedRevenue: (json['refunded_revenue'] as num).toDouble(),
  creditNoteAmount: (json['credit_note_amount'] as num).toDouble(),
  totalInvoices: (json['total_invoices'] as num).toInt(),
  paidInvoices: (json['paid_invoices'] as num).toInt(),
  pendingInvoices: (json['pending_invoices'] as num).toInt(),
  overdueInvoices: (json['overdue_invoices'] as num).toInt(),
  draftInvoices: (json['draft_invoices'] as num).toInt(),
  cancelledInvoices: (json['cancelled_invoices'] as num).toInt(),
  refundedInvoices: (json['refunded_invoices'] as num).toInt(),
  totalPayments: (json['total_payments'] as num).toInt(),
  averagePaymentAmount: (json['average_payment_amount'] as num).toDouble(),
  medianPaymentAmount: (json['median_payment_amount'] as num).toDouble(),
  averagePaymentDays: (json['average_payment_days'] as num).toInt(),
  activeCompanies: (json['active_companies'] as num).toInt(),
  companiesWithOverdue: (json['companies_with_overdue'] as num).toInt(),
  companiesWithCredit: (json['companies_with_credit'] as num).toInt(),
  revenueByPlan: (json['revenue_by_plan'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  revenueByCompanyType:
      (json['revenue_by_company_type'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
  revenueByPaymentMethod:
      (json['revenue_by_payment_method'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
  invoiceCountByStatus:
      (json['invoice_count_by_status'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
  revenueByMonth: (json['revenue_by_month'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  monthlyTrends: (json['monthly_trends'] as List<dynamic>?)
      ?.map((e) => MonthlyRevenueTrend.fromJson(e as Map<String, dynamic>))
      .toList(),
  topCompaniesByRevenue: (json['top_companies_by_revenue'] as List<dynamic>?)
      ?.map((e) => CompanyRevenueRanking.fromJson(e as Map<String, dynamic>))
      .toList(),
  topPlansByRevenue: (json['top_plans_by_revenue'] as List<dynamic>?)
      ?.map((e) => PlanRevenueRanking.fromJson(e as Map<String, dynamic>))
      .toList(),
  notes: json['notes'] as String?,
  reportData: json['report_data'] as Map<String, dynamic>?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$RevenueReportToJson(_RevenueReport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'report_number': instance.reportNumber,
      'report_name': instance.reportName,
      'type': _$ReportTypeEnumMap[instance.type]!,
      'period_start': instance.periodStart.toIso8601String(),
      'period_end': instance.periodEnd.toIso8601String(),
      'generated_at': instance.generatedAt.toIso8601String(),
      'generated_by_admin_id': instance.generatedByAdminId,
      'generated_by_admin_name': instance.generatedByAdminName,
      'status': _$ReportStatusEnumMap[instance.status]!,
      'total_revenue': instance.totalRevenue,
      'collected_revenue': instance.collectedRevenue,
      'pending_revenue': instance.pendingRevenue,
      'overdue_revenue': instance.overdueRevenue,
      'refunded_revenue': instance.refundedRevenue,
      'credit_note_amount': instance.creditNoteAmount,
      'total_invoices': instance.totalInvoices,
      'paid_invoices': instance.paidInvoices,
      'pending_invoices': instance.pendingInvoices,
      'overdue_invoices': instance.overdueInvoices,
      'draft_invoices': instance.draftInvoices,
      'cancelled_invoices': instance.cancelledInvoices,
      'refunded_invoices': instance.refundedInvoices,
      'total_payments': instance.totalPayments,
      'average_payment_amount': instance.averagePaymentAmount,
      'median_payment_amount': instance.medianPaymentAmount,
      'average_payment_days': instance.averagePaymentDays,
      'active_companies': instance.activeCompanies,
      'companies_with_overdue': instance.companiesWithOverdue,
      'companies_with_credit': instance.companiesWithCredit,
      'revenue_by_plan': instance.revenueByPlan,
      'revenue_by_company_type': instance.revenueByCompanyType,
      'revenue_by_payment_method': instance.revenueByPaymentMethod,
      'invoice_count_by_status': instance.invoiceCountByStatus,
      'revenue_by_month': instance.revenueByMonth,
      'monthly_trends': instance.monthlyTrends?.map((e) => e.toJson()).toList(),
      'top_companies_by_revenue': instance.topCompaniesByRevenue
          ?.map((e) => e.toJson())
          .toList(),
      'top_plans_by_revenue': instance.topPlansByRevenue
          ?.map((e) => e.toJson())
          .toList(),
      'notes': instance.notes,
      'report_data': instance.reportData,
      'metadata': instance.metadata,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$ReportTypeEnumMap = {
  ReportType.daily: 'daily',
  ReportType.weekly: 'weekly',
  ReportType.monthly: 'monthly',
  ReportType.quarterly: 'quarterly',
  ReportType.yearly: 'yearly',
  ReportType.custom: 'custom',
  ReportType.adHoc: 'ad_hoc',
};

const _$ReportStatusEnumMap = {
  ReportStatus.draft: 'draft',
  ReportStatus.generating: 'generating',
  ReportStatus.completed: 'completed',
  ReportStatus.failed: 'failed',
  ReportStatus.archived: 'archived',
};

_MonthlyRevenueTrend _$MonthlyRevenueTrendFromJson(Map<String, dynamic> json) =>
    _MonthlyRevenueTrend(
      year: (json['year'] as num).toInt(),
      month: (json['month'] as num).toInt(),
      monthName: json['month_name'] as String,
      revenue: (json['revenue'] as num).toDouble(),
      collectedRevenue: (json['collected_revenue'] as num).toDouble(),
      pendingRevenue: (json['pending_revenue'] as num).toDouble(),
      invoiceCount: (json['invoice_count'] as num).toInt(),
      paidInvoiceCount: (json['paid_invoice_count'] as num).toInt(),
      newCompanies: (json['new_companies'] as num).toInt(),
      activeCompanies: (json['active_companies'] as num).toInt(),
      growthRate: (json['growth_rate'] as num?)?.toDouble(),
      collectionRate: (json['collection_rate'] as num?)?.toDouble(),
      revenueByPlan: (json['revenue_by_plan'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      revenueByCompanyType:
          (json['revenue_by_company_type'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ),
    );

Map<String, dynamic> _$MonthlyRevenueTrendToJson(
  _MonthlyRevenueTrend instance,
) => <String, dynamic>{
  'year': instance.year,
  'month': instance.month,
  'month_name': instance.monthName,
  'revenue': instance.revenue,
  'collected_revenue': instance.collectedRevenue,
  'pending_revenue': instance.pendingRevenue,
  'invoice_count': instance.invoiceCount,
  'paid_invoice_count': instance.paidInvoiceCount,
  'new_companies': instance.newCompanies,
  'active_companies': instance.activeCompanies,
  'growth_rate': instance.growthRate,
  'collection_rate': instance.collectionRate,
  'revenue_by_plan': instance.revenueByPlan,
  'revenue_by_company_type': instance.revenueByCompanyType,
};

_CompanyRevenueRanking _$CompanyRevenueRankingFromJson(
  Map<String, dynamic> json,
) => _CompanyRevenueRanking(
  companyId: json['company_id'] as String,
  companyName: json['company_name'] as String,
  companyType: json['company_type'] as String,
  totalRevenue: (json['total_revenue'] as num).toDouble(),
  paidRevenue: (json['paid_revenue'] as num).toDouble(),
  pendingRevenue: (json['pending_revenue'] as num).toDouble(),
  overdueRevenue: (json['overdue_revenue'] as num).toDouble(),
  totalInvoices: (json['total_invoices'] as num).toInt(),
  paidInvoices: (json['paid_invoices'] as num).toInt(),
  overdueInvoices: (json['overdue_invoices'] as num).toInt(),
  currentPlan: json['current_plan'] as String,
  subscriptionStart: json['subscription_start'] == null
      ? null
      : DateTime.parse(json['subscription_start'] as String),
  subscriptionEnd: json['subscription_end'] == null
      ? null
      : DateTime.parse(json['subscription_end'] as String),
  averagePaymentDays: (json['average_payment_days'] as num?)?.toDouble(),
  ranking: (json['ranking'] as num?)?.toInt(),
  marketShare: (json['market_share'] as num?)?.toDouble(),
);

Map<String, dynamic> _$CompanyRevenueRankingToJson(
  _CompanyRevenueRanking instance,
) => <String, dynamic>{
  'company_id': instance.companyId,
  'company_name': instance.companyName,
  'company_type': instance.companyType,
  'total_revenue': instance.totalRevenue,
  'paid_revenue': instance.paidRevenue,
  'pending_revenue': instance.pendingRevenue,
  'overdue_revenue': instance.overdueRevenue,
  'total_invoices': instance.totalInvoices,
  'paid_invoices': instance.paidInvoices,
  'overdue_invoices': instance.overdueInvoices,
  'current_plan': instance.currentPlan,
  'subscription_start': instance.subscriptionStart?.toIso8601String(),
  'subscription_end': instance.subscriptionEnd?.toIso8601String(),
  'average_payment_days': instance.averagePaymentDays,
  'ranking': instance.ranking,
  'market_share': instance.marketShare,
};

_PlanRevenueRanking _$PlanRevenueRankingFromJson(Map<String, dynamic> json) =>
    _PlanRevenueRanking(
      planId: json['plan_id'] as String,
      planName: json['plan_name'] as String,
      planType: json['plan_type'] as String,
      totalRevenue: (json['total_revenue'] as num).toDouble(),
      totalSubscriptions: (json['total_subscriptions'] as num).toInt(),
      activeSubscriptions: (json['active_subscriptions'] as num).toInt(),
      cancelledSubscriptions: (json['cancelled_subscriptions'] as num).toInt(),
      averageRevenuePerSubscription:
          (json['average_revenue_per_subscription'] as num).toDouble(),
      monthlyRecurringRevenue: (json['monthly_recurring_revenue'] as num)
          .toDouble(),
      annualRecurringRevenue: (json['annual_recurring_revenue'] as num)
          .toDouble(),
      churnRate: (json['churn_rate'] as num?)?.toDouble(),
      upgradeRate: (json['upgrade_rate'] as num?)?.toDouble(),
      downgradeRate: (json['downgrade_rate'] as num?)?.toDouble(),
      ranking: (json['ranking'] as num?)?.toInt(),
      marketShare: (json['market_share'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PlanRevenueRankingToJson(
  _PlanRevenueRanking instance,
) => <String, dynamic>{
  'plan_id': instance.planId,
  'plan_name': instance.planName,
  'plan_type': instance.planType,
  'total_revenue': instance.totalRevenue,
  'total_subscriptions': instance.totalSubscriptions,
  'active_subscriptions': instance.activeSubscriptions,
  'cancelled_subscriptions': instance.cancelledSubscriptions,
  'average_revenue_per_subscription': instance.averageRevenuePerSubscription,
  'monthly_recurring_revenue': instance.monthlyRecurringRevenue,
  'annual_recurring_revenue': instance.annualRecurringRevenue,
  'churn_rate': instance.churnRate,
  'upgrade_rate': instance.upgradeRate,
  'downgrade_rate': instance.downgradeRate,
  'ranking': instance.ranking,
  'market_share': instance.marketShare,
};

_RevenueForecast _$RevenueForecastFromJson(Map<String, dynamic> json) =>
    _RevenueForecast(
      forecastDate: DateTime.parse(json['forecast_date'] as String),
      method: $enumDecode(_$ForecastMethodEnumMap, json['method']),
      forecastedRevenue: (json['forecasted_revenue'] as num).toDouble(),
      lowerBound: (json['lower_bound'] as num).toDouble(),
      upperBound: (json['upper_bound'] as num).toDouble(),
      confidenceLevel: (json['confidence_level'] as num).toDouble(),
      forecastByPlan: (json['forecast_by_plan'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      forecastByCompanyType:
          (json['forecast_by_company_type'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ),
      historicalData: (json['historical_data'] as List<dynamic>?)
          ?.map((e) => ForecastDataPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      forecastData: (json['forecast_data'] as List<dynamic>?)
          ?.map((e) => ForecastDataPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
      forecastParameters: json['forecast_parameters'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$RevenueForecastToJson(
  _RevenueForecast instance,
) => <String, dynamic>{
  'forecast_date': instance.forecastDate.toIso8601String(),
  'method': _$ForecastMethodEnumMap[instance.method]!,
  'forecasted_revenue': instance.forecastedRevenue,
  'lower_bound': instance.lowerBound,
  'upper_bound': instance.upperBound,
  'confidence_level': instance.confidenceLevel,
  'forecast_by_plan': instance.forecastByPlan,
  'forecast_by_company_type': instance.forecastByCompanyType,
  'historical_data': instance.historicalData?.map((e) => e.toJson()).toList(),
  'forecast_data': instance.forecastData?.map((e) => e.toJson()).toList(),
  'notes': instance.notes,
  'forecast_parameters': instance.forecastParameters,
};

const _$ForecastMethodEnumMap = {
  ForecastMethod.movingAverage: 'moving_average',
  ForecastMethod.exponentialSmoothing: 'exponential_smoothing',
  ForecastMethod.arima: 'arima',
  ForecastMethod.linearRegression: 'linear_regression',
  ForecastMethod.machineLearning: 'machine_learning',
  ForecastMethod.manual: 'manual',
};

_ForecastDataPoint _$ForecastDataPointFromJson(Map<String, dynamic> json) =>
    _ForecastDataPoint(
      date: DateTime.parse(json['date'] as String),
      actualRevenue: (json['actual_revenue'] as num).toDouble(),
      forecastedRevenue: (json['forecasted_revenue'] as num?)?.toDouble(),
      forecastError: (json['forecast_error'] as num?)?.toDouble(),
      lowerBound: (json['lower_bound'] as num?)?.toDouble(),
      upperBound: (json['upper_bound'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ForecastDataPointToJson(_ForecastDataPoint instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'actual_revenue': instance.actualRevenue,
      'forecasted_revenue': instance.forecastedRevenue,
      'forecast_error': instance.forecastError,
      'lower_bound': instance.lowerBound,
      'upper_bound': instance.upperBound,
    };

_RevenueAnalysis _$RevenueAnalysisFromJson(
  Map<String, dynamic> json,
) => _RevenueAnalysis(
  analysisDate: DateTime.parse(json['analysis_date'] as String),
  period: $enumDecode(_$AnalysisPeriodEnumMap, json['period']),
  totalRevenue: (json['total_revenue'] as num).toDouble(),
  revenueGrowth: (json['revenue_growth'] as num).toDouble(),
  revenueGrowthRate: (json['revenue_growth_rate'] as num).toDouble(),
  collectionRate: (json['collection_rate'] as num).toDouble(),
  churnRate: (json['churn_rate'] as num).toDouble(),
  expansionRate: (json['expansion_rate'] as num).toDouble(),
  netRevenueRetention: (json['net_revenue_retention'] as num).toDouble(),
  grossRevenueRetention: (json['gross_revenue_retention'] as num).toDouble(),
  monthlyRecurringRevenue: (json['monthly_recurring_revenue'] as num)
      .toDouble(),
  annualRecurringRevenue: (json['annual_recurring_revenue'] as num).toDouble(),
  averageRevenuePerUser: (json['average_revenue_per_user'] as num).toDouble(),
  lifetimeValue: (json['lifetime_value'] as num).toDouble(),
  customerAcquisitionCost: (json['customer_acquisition_cost'] as num)
      .toDouble(),
  revenueBySegment: (json['revenue_by_segment'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  growthBySegment: (json['growth_by_segment'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  churnBySegment: (json['churn_by_segment'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  metricTrends: (json['metric_trends'] as List<dynamic>?)
      ?.map((e) => RevenueMetricTrend.fromJson(e as Map<String, dynamic>))
      .toList(),
  driverAnalysis: (json['driver_analysis'] as List<dynamic>?)
      ?.map((e) => RevenueDriverAnalysis.fromJson(e as Map<String, dynamic>))
      .toList(),
  insights: (json['insights'] as List<dynamic>?)
      ?.map((e) => RevenueInsight.fromJson(e as Map<String, dynamic>))
      .toList(),
  recommendations: (json['recommendations'] as List<dynamic>?)
      ?.map((e) => RevenueRecommendation.fromJson(e as Map<String, dynamic>))
      .toList(),
  summary: json['summary'] as String?,
  analysisData: json['analysis_data'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$RevenueAnalysisToJson(
  _RevenueAnalysis instance,
) => <String, dynamic>{
  'analysis_date': instance.analysisDate.toIso8601String(),
  'period': _$AnalysisPeriodEnumMap[instance.period]!,
  'total_revenue': instance.totalRevenue,
  'revenue_growth': instance.revenueGrowth,
  'revenue_growth_rate': instance.revenueGrowthRate,
  'collection_rate': instance.collectionRate,
  'churn_rate': instance.churnRate,
  'expansion_rate': instance.expansionRate,
  'net_revenue_retention': instance.netRevenueRetention,
  'gross_revenue_retention': instance.grossRevenueRetention,
  'monthly_recurring_revenue': instance.monthlyRecurringRevenue,
  'annual_recurring_revenue': instance.annualRecurringRevenue,
  'average_revenue_per_user': instance.averageRevenuePerUser,
  'lifetime_value': instance.lifetimeValue,
  'customer_acquisition_cost': instance.customerAcquisitionCost,
  'revenue_by_segment': instance.revenueBySegment,
  'growth_by_segment': instance.growthBySegment,
  'churn_by_segment': instance.churnBySegment,
  'metric_trends': instance.metricTrends?.map((e) => e.toJson()).toList(),
  'driver_analysis': instance.driverAnalysis?.map((e) => e.toJson()).toList(),
  'insights': instance.insights?.map((e) => e.toJson()).toList(),
  'recommendations': instance.recommendations?.map((e) => e.toJson()).toList(),
  'summary': instance.summary,
  'analysis_data': instance.analysisData,
};

const _$AnalysisPeriodEnumMap = {
  AnalysisPeriod.day: 'day',
  AnalysisPeriod.week: 'week',
  AnalysisPeriod.month: 'month',
  AnalysisPeriod.quarter: 'quarter',
  AnalysisPeriod.year: 'year',
};

_RevenueMetricTrend _$RevenueMetricTrendFromJson(Map<String, dynamic> json) =>
    _RevenueMetricTrend(
      metricName: json['metric_name'] as String,
      metricDisplayName: json['metric_display_name'] as String,
      metricUnit: json['metric_unit'] as String,
      dataPoints: (json['data_points'] as List<dynamic>)
          .map((e) => MetricDataPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentValue: (json['current_value'] as num).toDouble(),
      previousValue: (json['previous_value'] as num).toDouble(),
      changeAmount: (json['change_amount'] as num).toDouble(),
      changePercentage: (json['change_percentage'] as num).toDouble(),
      direction: $enumDecode(_$TrendDirectionEnumMap, json['direction']),
      insight: json['insight'] as String?,
    );

Map<String, dynamic> _$RevenueMetricTrendToJson(_RevenueMetricTrend instance) =>
    <String, dynamic>{
      'metric_name': instance.metricName,
      'metric_display_name': instance.metricDisplayName,
      'metric_unit': instance.metricUnit,
      'data_points': instance.dataPoints.map((e) => e.toJson()).toList(),
      'current_value': instance.currentValue,
      'previous_value': instance.previousValue,
      'change_amount': instance.changeAmount,
      'change_percentage': instance.changePercentage,
      'direction': _$TrendDirectionEnumMap[instance.direction]!,
      'insight': instance.insight,
    };

const _$TrendDirectionEnumMap = {
  TrendDirection.up: 'up',
  TrendDirection.down: 'down',
  TrendDirection.stable: 'stable',
  TrendDirection.volatile: 'volatile',
};

_MetricDataPoint _$MetricDataPointFromJson(Map<String, dynamic> json) =>
    _MetricDataPoint(
      date: DateTime.parse(json['date'] as String),
      value: (json['value'] as num).toDouble(),
      targetValue: (json['target_value'] as num?)?.toDouble(),
      forecastValue: (json['forecast_value'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$MetricDataPointToJson(_MetricDataPoint instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'value': instance.value,
      'target_value': instance.targetValue,
      'forecast_value': instance.forecastValue,
    };

_RevenueDriverAnalysis _$RevenueDriverAnalysisFromJson(
  Map<String, dynamic> json,
) => _RevenueDriverAnalysis(
  driverName: json['driver_name'] as String,
  driverDisplayName: json['driver_display_name'] as String,
  type: $enumDecode(_$DriverTypeEnumMap, json['type']),
  impactScore: (json['impact_score'] as num).toDouble(),
  correlationCoefficient: (json['correlation_coefficient'] as num).toDouble(),
  dataPoints: (json['data_points'] as List<dynamic>)
      .map((e) => DriverDataPoint.fromJson(e as Map<String, dynamic>))
      .toList(),
  explanation: json['explanation'] as String?,
  recommendations: (json['recommendations'] as List<dynamic>?)
      ?.map((e) => DriverRecommendation.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$RevenueDriverAnalysisToJson(
  _RevenueDriverAnalysis instance,
) => <String, dynamic>{
  'driver_name': instance.driverName,
  'driver_display_name': instance.driverDisplayName,
  'type': _$DriverTypeEnumMap[instance.type]!,
  'impact_score': instance.impactScore,
  'correlation_coefficient': instance.correlationCoefficient,
  'data_points': instance.dataPoints.map((e) => e.toJson()).toList(),
  'explanation': instance.explanation,
  'recommendations': instance.recommendations?.map((e) => e.toJson()).toList(),
};

const _$DriverTypeEnumMap = {
  DriverType.internal: 'internal',
  DriverType.external: 'external',
  DriverType.market: 'market',
  DriverType.seasonal: 'seasonal',
  DriverType.campaign: 'campaign',
};

_DriverDataPoint _$DriverDataPointFromJson(Map<String, dynamic> json) =>
    _DriverDataPoint(
      date: DateTime.parse(json['date'] as String),
      driverValue: (json['driver_value'] as num).toDouble(),
      revenueValue: (json['revenue_value'] as num).toDouble(),
      expectedRevenue: (json['expected_revenue'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$DriverDataPointToJson(_DriverDataPoint instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'driver_value': instance.driverValue,
      'revenue_value': instance.revenueValue,
      'expected_revenue': instance.expectedRevenue,
    };

_DriverRecommendation _$DriverRecommendationFromJson(
  Map<String, dynamic> json,
) => _DriverRecommendation(
  action: json['action'] as String,
  description: json['description'] as String,
  priority: $enumDecode(_$PriorityEnumMap, json['priority']),
  expectedImpact: (json['expected_impact'] as num).toDouble(),
  requiredResources: (json['required_resources'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  targetCompletionDate: json['target_completion_date'] == null
      ? null
      : DateTime.parse(json['target_completion_date'] as String),
  responsibleTeam: json['responsible_team'] as String?,
);

Map<String, dynamic> _$DriverRecommendationToJson(
  _DriverRecommendation instance,
) => <String, dynamic>{
  'action': instance.action,
  'description': instance.description,
  'priority': _$PriorityEnumMap[instance.priority]!,
  'expected_impact': instance.expectedImpact,
  'required_resources': instance.requiredResources,
  'target_completion_date': instance.targetCompletionDate?.toIso8601String(),
  'responsible_team': instance.responsibleTeam,
};

const _$PriorityEnumMap = {
  Priority.low: 'low',
  Priority.medium: 'medium',
  Priority.high: 'high',
  Priority.critical: 'critical',
};

_RevenueInsight _$RevenueInsightFromJson(Map<String, dynamic> json) =>
    _RevenueInsight(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$InsightTypeEnumMap, json['type']),
      severity: $enumDecode(_$InsightSeverityEnumMap, json['severity']),
      detectedAt: DateTime.parse(json['detected_at'] as String),
      confidenceScore: (json['confidence_score'] as num).toDouble(),
      affectedSegments: (json['affected_segments'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      contributingFactors: (json['contributing_factors'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      suggestedActions: (json['suggested_actions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      insightData: json['insight_data'] as Map<String, dynamic>?,
      acknowledgedAt: json['acknowledged_at'] == null
          ? null
          : DateTime.parse(json['acknowledged_at'] as String),
      acknowledgedBy: json['acknowledged_by'] as String?,
      resolvedAt: json['resolved_at'] == null
          ? null
          : DateTime.parse(json['resolved_at'] as String),
      resolvedBy: json['resolved_by'] as String?,
      resolutionNotes: json['resolution_notes'] as String?,
    );

Map<String, dynamic> _$RevenueInsightToJson(_RevenueInsight instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'type': _$InsightTypeEnumMap[instance.type]!,
      'severity': _$InsightSeverityEnumMap[instance.severity]!,
      'detected_at': instance.detectedAt.toIso8601String(),
      'confidence_score': instance.confidenceScore,
      'affected_segments': instance.affectedSegments,
      'contributing_factors': instance.contributingFactors,
      'suggested_actions': instance.suggestedActions,
      'insight_data': instance.insightData,
      'acknowledged_at': instance.acknowledgedAt?.toIso8601String(),
      'acknowledged_by': instance.acknowledgedBy,
      'resolved_at': instance.resolvedAt?.toIso8601String(),
      'resolved_by': instance.resolvedBy,
      'resolution_notes': instance.resolutionNotes,
    };

const _$InsightTypeEnumMap = {
  InsightType.opportunity: 'opportunity',
  InsightType.risk: 'risk',
  InsightType.anomaly: 'anomaly',
  InsightType.trend: 'trend',
  InsightType.performance: 'performance',
};

const _$InsightSeverityEnumMap = {
  InsightSeverity.info: 'info',
  InsightSeverity.low: 'low',
  InsightSeverity.medium: 'medium',
  InsightSeverity.high: 'high',
  InsightSeverity.critical: 'critical',
};

_RevenueRecommendation _$RevenueRecommendationFromJson(
  Map<String, dynamic> json,
) => _RevenueRecommendation(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  category: $enumDecode(_$RecommendationCategoryEnumMap, json['category']),
  priority: $enumDecode(_$PriorityEnumMap, json['priority']),
  expectedImpact: (json['expected_impact'] as num).toDouble(),
  implementationSteps: (json['implementation_steps'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  requiredResources: (json['required_resources'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  targetCompletionDate: json['target_completion_date'] == null
      ? null
      : DateTime.parse(json['target_completion_date'] as String),
  responsibleTeam: json['responsible_team'] as String?,
  status: json['status'] as String?,
  implementedAt: json['implemented_at'] == null
      ? null
      : DateTime.parse(json['implemented_at'] as String),
  implementedBy: json['implemented_by'] as String?,
  actualImpact: (json['actual_impact'] as num?)?.toDouble(),
  implementationNotes: json['implementation_notes'] as String?,
);

Map<String, dynamic> _$RevenueRecommendationToJson(
  _RevenueRecommendation instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'category': _$RecommendationCategoryEnumMap[instance.category]!,
  'priority': _$PriorityEnumMap[instance.priority]!,
  'expected_impact': instance.expectedImpact,
  'implementation_steps': instance.implementationSteps,
  'required_resources': instance.requiredResources,
  'target_completion_date': instance.targetCompletionDate?.toIso8601String(),
  'responsible_team': instance.responsibleTeam,
  'status': instance.status,
  'implemented_at': instance.implementedAt?.toIso8601String(),
  'implemented_by': instance.implementedBy,
  'actual_impact': instance.actualImpact,
  'implementation_notes': instance.implementationNotes,
};

const _$RecommendationCategoryEnumMap = {
  RecommendationCategory.pricing: 'pricing',
  RecommendationCategory.product: 'product',
  RecommendationCategory.sales: 'sales',
  RecommendationCategory.marketing: 'marketing',
  RecommendationCategory.customerSuccess: 'customer_success',
  RecommendationCategory.operations: 'operations',
  RecommendationCategory.finance: 'finance',
};

_ReportFilter _$ReportFilterFromJson(Map<String, dynamic> json) =>
    _ReportFilter(
      startDate: json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      types: (json['types'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$ReportTypeEnumMap, e))
          .toList(),
      statuses: (json['statuses'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$ReportStatusEnumMap, e))
          .toList(),
      generatedByAdminId: json['generated_by_admin_id'] as String?,
      searchQuery: json['search_query'] as String?,
      sortBy: json['sort_by'] as String? ?? 'generatedAt',
      sortDesc: json['sort_desc'] as bool? ?? true,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
    );

Map<String, dynamic> _$ReportFilterToJson(
  _ReportFilter instance,
) => <String, dynamic>{
  'start_date': instance.startDate?.toIso8601String(),
  'end_date': instance.endDate?.toIso8601String(),
  'types': instance.types?.map((e) => _$ReportTypeEnumMap[e]!).toList(),
  'statuses': instance.statuses?.map((e) => _$ReportStatusEnumMap[e]!).toList(),
  'generated_by_admin_id': instance.generatedByAdminId,
  'search_query': instance.searchQuery,
  'sort_by': instance.sortBy,
  'sort_desc': instance.sortDesc,
  'page': instance.page,
  'limit': instance.limit,
};

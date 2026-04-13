// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'revenue_report_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RevenueReport _$RevenueReportFromJson(
  Map<String, dynamic> json,
) => _RevenueReport(
  id: json['id'] as String,
  reportNumber: json['reportNumber'] as String,
  reportName: json['reportName'] as String,
  type: $enumDecode(_$ReportTypeEnumMap, json['type']),
  periodStart: DateTime.parse(json['periodStart'] as String),
  periodEnd: DateTime.parse(json['periodEnd'] as String),
  generatedAt: DateTime.parse(json['generatedAt'] as String),
  generatedByAdminId: json['generatedByAdminId'] as String,
  generatedByAdminName: json['generatedByAdminName'] as String,
  status: $enumDecode(_$ReportStatusEnumMap, json['status']),
  totalRevenue: (json['totalRevenue'] as num).toDouble(),
  collectedRevenue: (json['collectedRevenue'] as num).toDouble(),
  pendingRevenue: (json['pendingRevenue'] as num).toDouble(),
  overdueRevenue: (json['overdueRevenue'] as num).toDouble(),
  refundedRevenue: (json['refundedRevenue'] as num).toDouble(),
  creditNoteAmount: (json['creditNoteAmount'] as num).toDouble(),
  totalInvoices: (json['totalInvoices'] as num).toInt(),
  paidInvoices: (json['paidInvoices'] as num).toInt(),
  pendingInvoices: (json['pendingInvoices'] as num).toInt(),
  overdueInvoices: (json['overdueInvoices'] as num).toInt(),
  draftInvoices: (json['draftInvoices'] as num).toInt(),
  cancelledInvoices: (json['cancelledInvoices'] as num).toInt(),
  refundedInvoices: (json['refundedInvoices'] as num).toInt(),
  totalPayments: (json['totalPayments'] as num).toInt(),
  averagePaymentAmount: (json['averagePaymentAmount'] as num).toDouble(),
  medianPaymentAmount: (json['medianPaymentAmount'] as num).toDouble(),
  averagePaymentDays: (json['averagePaymentDays'] as num).toInt(),
  activeCompanies: (json['activeCompanies'] as num).toInt(),
  companiesWithOverdue: (json['companiesWithOverdue'] as num).toInt(),
  companiesWithCredit: (json['companiesWithCredit'] as num).toInt(),
  revenueByPlan: (json['revenueByPlan'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  revenueByCompanyType: (json['revenueByCompanyType'] as Map<String, dynamic>?)
      ?.map((k, e) => MapEntry(k, (e as num).toDouble())),
  revenueByPaymentMethod:
      (json['revenueByPaymentMethod'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
  invoiceCountByStatus: (json['invoiceCountByStatus'] as Map<String, dynamic>?)
      ?.map((k, e) => MapEntry(k, (e as num).toInt())),
  revenueByMonth: (json['revenueByMonth'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  monthlyTrends: (json['monthlyTrends'] as List<dynamic>?)
      ?.map((e) => MonthlyRevenueTrend.fromJson(e as Map<String, dynamic>))
      .toList(),
  topCompaniesByRevenue: (json['topCompaniesByRevenue'] as List<dynamic>?)
      ?.map((e) => CompanyRevenueRanking.fromJson(e as Map<String, dynamic>))
      .toList(),
  topPlansByRevenue: (json['topPlansByRevenue'] as List<dynamic>?)
      ?.map((e) => PlanRevenueRanking.fromJson(e as Map<String, dynamic>))
      .toList(),
  notes: json['notes'] as String?,
  reportData: json['reportData'] as Map<String, dynamic>?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$RevenueReportToJson(_RevenueReport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reportNumber': instance.reportNumber,
      'reportName': instance.reportName,
      'type': _$ReportTypeEnumMap[instance.type]!,
      'periodStart': instance.periodStart.toIso8601String(),
      'periodEnd': instance.periodEnd.toIso8601String(),
      'generatedAt': instance.generatedAt.toIso8601String(),
      'generatedByAdminId': instance.generatedByAdminId,
      'generatedByAdminName': instance.generatedByAdminName,
      'status': _$ReportStatusEnumMap[instance.status]!,
      'totalRevenue': instance.totalRevenue,
      'collectedRevenue': instance.collectedRevenue,
      'pendingRevenue': instance.pendingRevenue,
      'overdueRevenue': instance.overdueRevenue,
      'refundedRevenue': instance.refundedRevenue,
      'creditNoteAmount': instance.creditNoteAmount,
      'totalInvoices': instance.totalInvoices,
      'paidInvoices': instance.paidInvoices,
      'pendingInvoices': instance.pendingInvoices,
      'overdueInvoices': instance.overdueInvoices,
      'draftInvoices': instance.draftInvoices,
      'cancelledInvoices': instance.cancelledInvoices,
      'refundedInvoices': instance.refundedInvoices,
      'totalPayments': instance.totalPayments,
      'averagePaymentAmount': instance.averagePaymentAmount,
      'medianPaymentAmount': instance.medianPaymentAmount,
      'averagePaymentDays': instance.averagePaymentDays,
      'activeCompanies': instance.activeCompanies,
      'companiesWithOverdue': instance.companiesWithOverdue,
      'companiesWithCredit': instance.companiesWithCredit,
      'revenueByPlan': instance.revenueByPlan,
      'revenueByCompanyType': instance.revenueByCompanyType,
      'revenueByPaymentMethod': instance.revenueByPaymentMethod,
      'invoiceCountByStatus': instance.invoiceCountByStatus,
      'revenueByMonth': instance.revenueByMonth,
      'monthlyTrends': instance.monthlyTrends,
      'topCompaniesByRevenue': instance.topCompaniesByRevenue,
      'topPlansByRevenue': instance.topPlansByRevenue,
      'notes': instance.notes,
      'reportData': instance.reportData,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
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
      monthName: json['monthName'] as String,
      revenue: (json['revenue'] as num).toDouble(),
      collectedRevenue: (json['collectedRevenue'] as num).toDouble(),
      pendingRevenue: (json['pendingRevenue'] as num).toDouble(),
      invoiceCount: (json['invoiceCount'] as num).toInt(),
      paidInvoiceCount: (json['paidInvoiceCount'] as num).toInt(),
      newCompanies: (json['newCompanies'] as num).toInt(),
      activeCompanies: (json['activeCompanies'] as num).toInt(),
      growthRate: (json['growthRate'] as num?)?.toDouble(),
      collectionRate: (json['collectionRate'] as num?)?.toDouble(),
      revenueByPlan: (json['revenueByPlan'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      revenueByCompanyType:
          (json['revenueByCompanyType'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ),
    );

Map<String, dynamic> _$MonthlyRevenueTrendToJson(
  _MonthlyRevenueTrend instance,
) => <String, dynamic>{
  'year': instance.year,
  'month': instance.month,
  'monthName': instance.monthName,
  'revenue': instance.revenue,
  'collectedRevenue': instance.collectedRevenue,
  'pendingRevenue': instance.pendingRevenue,
  'invoiceCount': instance.invoiceCount,
  'paidInvoiceCount': instance.paidInvoiceCount,
  'newCompanies': instance.newCompanies,
  'activeCompanies': instance.activeCompanies,
  'growthRate': instance.growthRate,
  'collectionRate': instance.collectionRate,
  'revenueByPlan': instance.revenueByPlan,
  'revenueByCompanyType': instance.revenueByCompanyType,
};

_CompanyRevenueRanking _$CompanyRevenueRankingFromJson(
  Map<String, dynamic> json,
) => _CompanyRevenueRanking(
  companyId: json['companyId'] as String,
  companyName: json['companyName'] as String,
  companyType: json['companyType'] as String,
  totalRevenue: (json['totalRevenue'] as num).toDouble(),
  paidRevenue: (json['paidRevenue'] as num).toDouble(),
  pendingRevenue: (json['pendingRevenue'] as num).toDouble(),
  overdueRevenue: (json['overdueRevenue'] as num).toDouble(),
  totalInvoices: (json['totalInvoices'] as num).toInt(),
  paidInvoices: (json['paidInvoices'] as num).toInt(),
  overdueInvoices: (json['overdueInvoices'] as num).toInt(),
  currentPlan: json['currentPlan'] as String,
  subscriptionStart: json['subscriptionStart'] == null
      ? null
      : DateTime.parse(json['subscriptionStart'] as String),
  subscriptionEnd: json['subscriptionEnd'] == null
      ? null
      : DateTime.parse(json['subscriptionEnd'] as String),
  averagePaymentDays: (json['averagePaymentDays'] as num?)?.toDouble(),
  ranking: (json['ranking'] as num?)?.toInt(),
  marketShare: (json['marketShare'] as num?)?.toDouble(),
);

Map<String, dynamic> _$CompanyRevenueRankingToJson(
  _CompanyRevenueRanking instance,
) => <String, dynamic>{
  'companyId': instance.companyId,
  'companyName': instance.companyName,
  'companyType': instance.companyType,
  'totalRevenue': instance.totalRevenue,
  'paidRevenue': instance.paidRevenue,
  'pendingRevenue': instance.pendingRevenue,
  'overdueRevenue': instance.overdueRevenue,
  'totalInvoices': instance.totalInvoices,
  'paidInvoices': instance.paidInvoices,
  'overdueInvoices': instance.overdueInvoices,
  'currentPlan': instance.currentPlan,
  'subscriptionStart': instance.subscriptionStart?.toIso8601String(),
  'subscriptionEnd': instance.subscriptionEnd?.toIso8601String(),
  'averagePaymentDays': instance.averagePaymentDays,
  'ranking': instance.ranking,
  'marketShare': instance.marketShare,
};

_PlanRevenueRanking _$PlanRevenueRankingFromJson(
  Map<String, dynamic> json,
) => _PlanRevenueRanking(
  planId: json['planId'] as String,
  planName: json['planName'] as String,
  planType: json['planType'] as String,
  totalRevenue: (json['totalRevenue'] as num).toDouble(),
  totalSubscriptions: (json['totalSubscriptions'] as num).toInt(),
  activeSubscriptions: (json['activeSubscriptions'] as num).toInt(),
  cancelledSubscriptions: (json['cancelledSubscriptions'] as num).toInt(),
  averageRevenuePerSubscription: (json['averageRevenuePerSubscription'] as num)
      .toDouble(),
  monthlyRecurringRevenue: (json['monthlyRecurringRevenue'] as num).toDouble(),
  annualRecurringRevenue: (json['annualRecurringRevenue'] as num).toDouble(),
  churnRate: (json['churnRate'] as num?)?.toDouble(),
  upgradeRate: (json['upgradeRate'] as num?)?.toDouble(),
  downgradeRate: (json['downgradeRate'] as num?)?.toDouble(),
  ranking: (json['ranking'] as num?)?.toInt(),
  marketShare: (json['marketShare'] as num?)?.toDouble(),
);

Map<String, dynamic> _$PlanRevenueRankingToJson(_PlanRevenueRanking instance) =>
    <String, dynamic>{
      'planId': instance.planId,
      'planName': instance.planName,
      'planType': instance.planType,
      'totalRevenue': instance.totalRevenue,
      'totalSubscriptions': instance.totalSubscriptions,
      'activeSubscriptions': instance.activeSubscriptions,
      'cancelledSubscriptions': instance.cancelledSubscriptions,
      'averageRevenuePerSubscription': instance.averageRevenuePerSubscription,
      'monthlyRecurringRevenue': instance.monthlyRecurringRevenue,
      'annualRecurringRevenue': instance.annualRecurringRevenue,
      'churnRate': instance.churnRate,
      'upgradeRate': instance.upgradeRate,
      'downgradeRate': instance.downgradeRate,
      'ranking': instance.ranking,
      'marketShare': instance.marketShare,
    };

_RevenueForecast _$RevenueForecastFromJson(Map<String, dynamic> json) =>
    _RevenueForecast(
      forecastDate: DateTime.parse(json['forecastDate'] as String),
      method: $enumDecode(_$ForecastMethodEnumMap, json['method']),
      forecastedRevenue: (json['forecastedRevenue'] as num).toDouble(),
      lowerBound: (json['lowerBound'] as num).toDouble(),
      upperBound: (json['upperBound'] as num).toDouble(),
      confidenceLevel: (json['confidenceLevel'] as num).toDouble(),
      forecastByPlan: (json['forecastByPlan'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      forecastByCompanyType:
          (json['forecastByCompanyType'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ),
      historicalData: (json['historicalData'] as List<dynamic>?)
          ?.map((e) => ForecastDataPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      forecastData: (json['forecastData'] as List<dynamic>?)
          ?.map((e) => ForecastDataPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
      forecastParameters: json['forecastParameters'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$RevenueForecastToJson(_RevenueForecast instance) =>
    <String, dynamic>{
      'forecastDate': instance.forecastDate.toIso8601String(),
      'method': _$ForecastMethodEnumMap[instance.method]!,
      'forecastedRevenue': instance.forecastedRevenue,
      'lowerBound': instance.lowerBound,
      'upperBound': instance.upperBound,
      'confidenceLevel': instance.confidenceLevel,
      'forecastByPlan': instance.forecastByPlan,
      'forecastByCompanyType': instance.forecastByCompanyType,
      'historicalData': instance.historicalData,
      'forecastData': instance.forecastData,
      'notes': instance.notes,
      'forecastParameters': instance.forecastParameters,
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
      actualRevenue: (json['actualRevenue'] as num).toDouble(),
      forecastedRevenue: (json['forecastedRevenue'] as num?)?.toDouble(),
      forecastError: (json['forecastError'] as num?)?.toDouble(),
      lowerBound: (json['lowerBound'] as num?)?.toDouble(),
      upperBound: (json['upperBound'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ForecastDataPointToJson(_ForecastDataPoint instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'actualRevenue': instance.actualRevenue,
      'forecastedRevenue': instance.forecastedRevenue,
      'forecastError': instance.forecastError,
      'lowerBound': instance.lowerBound,
      'upperBound': instance.upperBound,
    };

_RevenueAnalysis _$RevenueAnalysisFromJson(
  Map<String, dynamic> json,
) => _RevenueAnalysis(
  analysisDate: DateTime.parse(json['analysisDate'] as String),
  period: $enumDecode(_$AnalysisPeriodEnumMap, json['period']),
  totalRevenue: (json['totalRevenue'] as num).toDouble(),
  revenueGrowth: (json['revenueGrowth'] as num).toDouble(),
  revenueGrowthRate: (json['revenueGrowthRate'] as num).toDouble(),
  collectionRate: (json['collectionRate'] as num).toDouble(),
  churnRate: (json['churnRate'] as num).toDouble(),
  expansionRate: (json['expansionRate'] as num).toDouble(),
  netRevenueRetention: (json['netRevenueRetention'] as num).toDouble(),
  grossRevenueRetention: (json['grossRevenueRetention'] as num).toDouble(),
  monthlyRecurringRevenue: (json['monthlyRecurringRevenue'] as num).toDouble(),
  annualRecurringRevenue: (json['annualRecurringRevenue'] as num).toDouble(),
  averageRevenuePerUser: (json['averageRevenuePerUser'] as num).toDouble(),
  lifetimeValue: (json['lifetimeValue'] as num).toDouble(),
  customerAcquisitionCost: (json['customerAcquisitionCost'] as num).toDouble(),
  revenueBySegment: (json['revenueBySegment'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  growthBySegment: (json['growthBySegment'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  churnBySegment: (json['churnBySegment'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  metricTrends: (json['metricTrends'] as List<dynamic>?)
      ?.map((e) => RevenueMetricTrend.fromJson(e as Map<String, dynamic>))
      .toList(),
  driverAnalysis: (json['driverAnalysis'] as List<dynamic>?)
      ?.map((e) => RevenueDriverAnalysis.fromJson(e as Map<String, dynamic>))
      .toList(),
  insights: (json['insights'] as List<dynamic>?)
      ?.map((e) => RevenueInsight.fromJson(e as Map<String, dynamic>))
      .toList(),
  recommendations: (json['recommendations'] as List<dynamic>?)
      ?.map((e) => RevenueRecommendation.fromJson(e as Map<String, dynamic>))
      .toList(),
  summary: json['summary'] as String?,
  analysisData: json['analysisData'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$RevenueAnalysisToJson(_RevenueAnalysis instance) =>
    <String, dynamic>{
      'analysisDate': instance.analysisDate.toIso8601String(),
      'period': _$AnalysisPeriodEnumMap[instance.period]!,
      'totalRevenue': instance.totalRevenue,
      'revenueGrowth': instance.revenueGrowth,
      'revenueGrowthRate': instance.revenueGrowthRate,
      'collectionRate': instance.collectionRate,
      'churnRate': instance.churnRate,
      'expansionRate': instance.expansionRate,
      'netRevenueRetention': instance.netRevenueRetention,
      'grossRevenueRetention': instance.grossRevenueRetention,
      'monthlyRecurringRevenue': instance.monthlyRecurringRevenue,
      'annualRecurringRevenue': instance.annualRecurringRevenue,
      'averageRevenuePerUser': instance.averageRevenuePerUser,
      'lifetimeValue': instance.lifetimeValue,
      'customerAcquisitionCost': instance.customerAcquisitionCost,
      'revenueBySegment': instance.revenueBySegment,
      'growthBySegment': instance.growthBySegment,
      'churnBySegment': instance.churnBySegment,
      'metricTrends': instance.metricTrends,
      'driverAnalysis': instance.driverAnalysis,
      'insights': instance.insights,
      'recommendations': instance.recommendations,
      'summary': instance.summary,
      'analysisData': instance.analysisData,
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
      metricName: json['metricName'] as String,
      metricDisplayName: json['metricDisplayName'] as String,
      metricUnit: json['metricUnit'] as String,
      dataPoints: (json['dataPoints'] as List<dynamic>)
          .map((e) => MetricDataPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentValue: (json['currentValue'] as num).toDouble(),
      previousValue: (json['previousValue'] as num).toDouble(),
      changeAmount: (json['changeAmount'] as num).toDouble(),
      changePercentage: (json['changePercentage'] as num).toDouble(),
      direction: $enumDecode(_$TrendDirectionEnumMap, json['direction']),
      insight: json['insight'] as String?,
    );

Map<String, dynamic> _$RevenueMetricTrendToJson(_RevenueMetricTrend instance) =>
    <String, dynamic>{
      'metricName': instance.metricName,
      'metricDisplayName': instance.metricDisplayName,
      'metricUnit': instance.metricUnit,
      'dataPoints': instance.dataPoints,
      'currentValue': instance.currentValue,
      'previousValue': instance.previousValue,
      'changeAmount': instance.changeAmount,
      'changePercentage': instance.changePercentage,
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
      targetValue: (json['targetValue'] as num?)?.toDouble(),
      forecastValue: (json['forecastValue'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$MetricDataPointToJson(_MetricDataPoint instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'value': instance.value,
      'targetValue': instance.targetValue,
      'forecastValue': instance.forecastValue,
    };

_RevenueDriverAnalysis _$RevenueDriverAnalysisFromJson(
  Map<String, dynamic> json,
) => _RevenueDriverAnalysis(
  driverName: json['driverName'] as String,
  driverDisplayName: json['driverDisplayName'] as String,
  type: $enumDecode(_$DriverTypeEnumMap, json['type']),
  impactScore: (json['impactScore'] as num).toDouble(),
  correlationCoefficient: (json['correlationCoefficient'] as num).toDouble(),
  dataPoints: (json['dataPoints'] as List<dynamic>)
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
  'driverName': instance.driverName,
  'driverDisplayName': instance.driverDisplayName,
  'type': _$DriverTypeEnumMap[instance.type]!,
  'impactScore': instance.impactScore,
  'correlationCoefficient': instance.correlationCoefficient,
  'dataPoints': instance.dataPoints,
  'explanation': instance.explanation,
  'recommendations': instance.recommendations,
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
      driverValue: (json['driverValue'] as num).toDouble(),
      revenueValue: (json['revenueValue'] as num).toDouble(),
      expectedRevenue: (json['expectedRevenue'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$DriverDataPointToJson(_DriverDataPoint instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'driverValue': instance.driverValue,
      'revenueValue': instance.revenueValue,
      'expectedRevenue': instance.expectedRevenue,
    };

_DriverRecommendation _$DriverRecommendationFromJson(
  Map<String, dynamic> json,
) => _DriverRecommendation(
  action: json['action'] as String,
  description: json['description'] as String,
  priority: $enumDecode(_$PriorityEnumMap, json['priority']),
  expectedImpact: (json['expectedImpact'] as num).toDouble(),
  requiredResources: (json['requiredResources'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  targetCompletionDate: json['targetCompletionDate'] == null
      ? null
      : DateTime.parse(json['targetCompletionDate'] as String),
  responsibleTeam: json['responsibleTeam'] as String?,
);

Map<String, dynamic> _$DriverRecommendationToJson(
  _DriverRecommendation instance,
) => <String, dynamic>{
  'action': instance.action,
  'description': instance.description,
  'priority': _$PriorityEnumMap[instance.priority]!,
  'expectedImpact': instance.expectedImpact,
  'requiredResources': instance.requiredResources,
  'targetCompletionDate': instance.targetCompletionDate?.toIso8601String(),
  'responsibleTeam': instance.responsibleTeam,
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
      detectedAt: DateTime.parse(json['detectedAt'] as String),
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
      affectedSegments: (json['affectedSegments'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      contributingFactors: (json['contributingFactors'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      suggestedActions: (json['suggestedActions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      insightData: json['insightData'] as Map<String, dynamic>?,
      acknowledgedAt: json['acknowledgedAt'] == null
          ? null
          : DateTime.parse(json['acknowledgedAt'] as String),
      acknowledgedBy: json['acknowledgedBy'] as String?,
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
      resolvedBy: json['resolvedBy'] as String?,
      resolutionNotes: json['resolutionNotes'] as String?,
    );

Map<String, dynamic> _$RevenueInsightToJson(_RevenueInsight instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'type': _$InsightTypeEnumMap[instance.type]!,
      'severity': _$InsightSeverityEnumMap[instance.severity]!,
      'detectedAt': instance.detectedAt.toIso8601String(),
      'confidenceScore': instance.confidenceScore,
      'affectedSegments': instance.affectedSegments,
      'contributingFactors': instance.contributingFactors,
      'suggestedActions': instance.suggestedActions,
      'insightData': instance.insightData,
      'acknowledgedAt': instance.acknowledgedAt?.toIso8601String(),
      'acknowledgedBy': instance.acknowledgedBy,
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
      'resolvedBy': instance.resolvedBy,
      'resolutionNotes': instance.resolutionNotes,
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
  expectedImpact: (json['expectedImpact'] as num).toDouble(),
  implementationSteps: (json['implementationSteps'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  requiredResources: (json['requiredResources'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  targetCompletionDate: json['targetCompletionDate'] == null
      ? null
      : DateTime.parse(json['targetCompletionDate'] as String),
  responsibleTeam: json['responsibleTeam'] as String?,
  status: json['status'] as String?,
  implementedAt: json['implementedAt'] == null
      ? null
      : DateTime.parse(json['implementedAt'] as String),
  implementedBy: json['implementedBy'] as String?,
  actualImpact: (json['actualImpact'] as num?)?.toDouble(),
  implementationNotes: json['implementationNotes'] as String?,
);

Map<String, dynamic> _$RevenueRecommendationToJson(
  _RevenueRecommendation instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'category': _$RecommendationCategoryEnumMap[instance.category]!,
  'priority': _$PriorityEnumMap[instance.priority]!,
  'expectedImpact': instance.expectedImpact,
  'implementationSteps': instance.implementationSteps,
  'requiredResources': instance.requiredResources,
  'targetCompletionDate': instance.targetCompletionDate?.toIso8601String(),
  'responsibleTeam': instance.responsibleTeam,
  'status': instance.status,
  'implementedAt': instance.implementedAt?.toIso8601String(),
  'implementedBy': instance.implementedBy,
  'actualImpact': instance.actualImpact,
  'implementationNotes': instance.implementationNotes,
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
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      types: (json['types'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$ReportTypeEnumMap, e))
          .toList(),
      statuses: (json['statuses'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$ReportStatusEnumMap, e))
          .toList(),
      generatedByAdminId: json['generatedByAdminId'] as String?,
      searchQuery: json['searchQuery'] as String?,
      sortBy: json['sortBy'] as String? ?? 'generatedAt',
      sortDesc: json['sortDesc'] as bool? ?? true,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
    );

Map<String, dynamic> _$ReportFilterToJson(
  _ReportFilter instance,
) => <String, dynamic>{
  'startDate': instance.startDate?.toIso8601String(),
  'endDate': instance.endDate?.toIso8601String(),
  'types': instance.types?.map((e) => _$ReportTypeEnumMap[e]!).toList(),
  'statuses': instance.statuses?.map((e) => _$ReportStatusEnumMap[e]!).toList(),
  'generatedByAdminId': instance.generatedByAdminId,
  'searchQuery': instance.searchQuery,
  'sortBy': instance.sortBy,
  'sortDesc': instance.sortDesc,
  'page': instance.page,
  'limit': instance.limit,
};

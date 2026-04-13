import 'package:freezed_annotation/freezed_annotation.dart';

part 'revenue_report_model.freezed.dart';
part 'revenue_report_model.g.dart';

@freezed
abstract class RevenueReport with _$RevenueReport {
  const factory RevenueReport({
    required String id,
    required String reportNumber,
    required String reportName,
    required ReportType type,
    required DateTime periodStart,
    required DateTime periodEnd,
    required DateTime generatedAt,
    required String generatedByAdminId,
    required String generatedByAdminName,
    required ReportStatus status,
    // Revenue summary
    required double totalRevenue,
    required double collectedRevenue,
    required double pendingRevenue,
    required double overdueRevenue,
    required double refundedRevenue,
    required double creditNoteAmount,
    // Invoice statistics
    required int totalInvoices,
    required int paidInvoices,
    required int pendingInvoices,
    required int overdueInvoices,
    required int draftInvoices,
    required int cancelledInvoices,
    required int refundedInvoices,
    // Payment statistics
    required int totalPayments,
    required double averagePaymentAmount,
    required double medianPaymentAmount,
    required int averagePaymentDays,
    // Company statistics
    required int activeCompanies,
    required int companiesWithOverdue,
    required int companiesWithCredit,
    // Breakdowns
    Map<String, double>? revenueByPlan,
    Map<String, double>? revenueByCompanyType,
    Map<String, double>? revenueByPaymentMethod,
    Map<String, int>? invoiceCountByStatus,
    Map<String, double>? revenueByMonth,
    // Trend data
    List<MonthlyRevenueTrend>? monthlyTrends,
    List<CompanyRevenueRanking>? topCompaniesByRevenue,
    List<PlanRevenueRanking>? topPlansByRevenue,
    // Report details
    String? notes,
    Map<String, dynamic>? reportData,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _RevenueReport;

  factory RevenueReport.fromJson(Map<String, dynamic> json) =>
      _$RevenueReportFromJson(json);

  factory RevenueReport.empty() => RevenueReport(
        id: '',
        reportNumber: '',
        reportName: '',
        type: ReportType.monthly,
        periodStart: DateTime.now(),
        periodEnd: DateTime.now(),
        generatedAt: DateTime.now(),
        generatedByAdminId: '',
        generatedByAdminName: '',
        status: ReportStatus.draft,
        totalRevenue: 0.0,
        collectedRevenue: 0.0,
        pendingRevenue: 0.0,
        overdueRevenue: 0.0,
        refundedRevenue: 0.0,
        creditNoteAmount: 0.0,
        totalInvoices: 0,
        paidInvoices: 0,
        pendingInvoices: 0,
        overdueInvoices: 0,
        draftInvoices: 0,
        cancelledInvoices: 0,
        refundedInvoices: 0,
        totalPayments: 0,
        averagePaymentAmount: 0.0,
        medianPaymentAmount: 0.0,
        averagePaymentDays: 0,
        activeCompanies: 0,
        companiesWithOverdue: 0,
        companiesWithCredit: 0,
      );
}

enum ReportType {
  @JsonValue('daily')
  daily,
  @JsonValue('weekly')
  weekly,
  @JsonValue('monthly')
  monthly,
  @JsonValue('quarterly')
  quarterly,
  @JsonValue('yearly')
  yearly,
  @JsonValue('custom')
  custom,
  @JsonValue('ad_hoc')
  adHoc,
}

enum ReportStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('generating')
  generating,
  @JsonValue('completed')
  completed,
  @JsonValue('failed')
  failed,
  @JsonValue('archived')
  archived,
}

@freezed
abstract class MonthlyRevenueTrend with _$MonthlyRevenueTrend {
  const factory MonthlyRevenueTrend({
    required int year,
    required int month,
    required String monthName,
    required double revenue,
    required double collectedRevenue,
    required double pendingRevenue,
    required int invoiceCount,
    required int paidInvoiceCount,
    required int newCompanies,
    required int activeCompanies,
    double? growthRate,
    double? collectionRate,
    Map<String, double>? revenueByPlan,
    Map<String, double>? revenueByCompanyType,
  }) = _MonthlyRevenueTrend;

  factory MonthlyRevenueTrend.fromJson(Map<String, dynamic> json) =>
      _$MonthlyRevenueTrendFromJson(json);
}

@freezed
abstract class CompanyRevenueRanking with _$CompanyRevenueRanking {
  const factory CompanyRevenueRanking({
    required String companyId,
    required String companyName,
    required String companyType,
    required double totalRevenue,
    required double paidRevenue,
    required double pendingRevenue,
    required double overdueRevenue,
    required int totalInvoices,
    required int paidInvoices,
    required int overdueInvoices,
    required String currentPlan,
    DateTime? subscriptionStart,
    DateTime? subscriptionEnd,
    double? averagePaymentDays,
    int? ranking,
    double? marketShare,
  }) = _CompanyRevenueRanking;

  factory CompanyRevenueRanking.fromJson(Map<String, dynamic> json) =>
      _$CompanyRevenueRankingFromJson(json);
}

@freezed
abstract class PlanRevenueRanking with _$PlanRevenueRanking {
  const factory PlanRevenueRanking({
    required String planId,
    required String planName,
    required String planType,
    required double totalRevenue,
    required int totalSubscriptions,
    required int activeSubscriptions,
    required int cancelledSubscriptions,
    required double averageRevenuePerSubscription,
    required double monthlyRecurringRevenue,
    required double annualRecurringRevenue,
    double? churnRate,
    double? upgradeRate,
    double? downgradeRate,
    int? ranking,
    double? marketShare,
  }) = _PlanRevenueRanking;

  factory PlanRevenueRanking.fromJson(Map<String, dynamic> json) =>
      _$PlanRevenueRankingFromJson(json);
}

@freezed
abstract class RevenueForecast with _$RevenueForecast {
  const factory RevenueForecast({
    required DateTime forecastDate,
    required ForecastMethod method,
    required double forecastedRevenue,
    required double lowerBound,
    required double upperBound,
    required double confidenceLevel,
    Map<String, double>? forecastByPlan,
    Map<String, double>? forecastByCompanyType,
    List<ForecastDataPoint>? historicalData,
    List<ForecastDataPoint>? forecastData,
    String? notes,
    Map<String, dynamic>? forecastParameters,
  }) = _RevenueForecast;

  factory RevenueForecast.fromJson(Map<String, dynamic> json) =>
      _$RevenueForecastFromJson(json);
}

enum ForecastMethod {
  @JsonValue('moving_average')
  movingAverage,
  @JsonValue('exponential_smoothing')
  exponentialSmoothing,
  @JsonValue('arima')
  arima,
  @JsonValue('linear_regression')
  linearRegression,
  @JsonValue('machine_learning')
  machineLearning,
  @JsonValue('manual')
  manual,
}

@freezed
abstract class ForecastDataPoint with _$ForecastDataPoint {
  const factory ForecastDataPoint({
    required DateTime date,
    required double actualRevenue,
    double? forecastedRevenue,
    double? forecastError,
    double? lowerBound,
    double? upperBound,
  }) = _ForecastDataPoint;

  factory ForecastDataPoint.fromJson(Map<String, dynamic> json) =>
      _$ForecastDataPointFromJson(json);
}

@freezed
abstract class RevenueAnalysis with _$RevenueAnalysis {
  const factory RevenueAnalysis({
    required DateTime analysisDate,
    required AnalysisPeriod period,
    required double totalRevenue,
    required double revenueGrowth,
    required double revenueGrowthRate,
    required double collectionRate,
    required double churnRate,
    required double expansionRate,
    required double netRevenueRetention,
    required double grossRevenueRetention,
    // Key metrics
    required double monthlyRecurringRevenue,
    required double annualRecurringRevenue,
    required double averageRevenuePerUser,
    required double lifetimeValue,
    required double customerAcquisitionCost,
    // Segment analysis
    Map<String, double>? revenueBySegment,
    Map<String, double>? growthBySegment,
    Map<String, double>? churnBySegment,
    // Trend analysis
    List<RevenueMetricTrend>? metricTrends,
    List<RevenueDriverAnalysis>? driverAnalysis,
    // Insights
    List<RevenueInsight>? insights,
    List<RevenueRecommendation>? recommendations,
    String? summary,
    Map<String, dynamic>? analysisData,
  }) = _RevenueAnalysis;

  factory RevenueAnalysis.fromJson(Map<String, dynamic> json) =>
      _$RevenueAnalysisFromJson(json);
}

enum AnalysisPeriod {
  @JsonValue('day')
  day,
  @JsonValue('week')
  week,
  @JsonValue('month')
  month,
  @JsonValue('quarter')
  quarter,
  @JsonValue('year')
  year,
}

@freezed
abstract class RevenueMetricTrend with _$RevenueMetricTrend {
  const factory RevenueMetricTrend({
    required String metricName,
    required String metricDisplayName,
    required String metricUnit,
    required List<MetricDataPoint> dataPoints,
    required double currentValue,
    required double previousValue,
    required double changeAmount,
    required double changePercentage,
    required TrendDirection direction,
    String? insight,
  }) = _RevenueMetricTrend;

  factory RevenueMetricTrend.fromJson(Map<String, dynamic> json) =>
      _$RevenueMetricTrendFromJson(json);
}

@freezed
abstract class MetricDataPoint with _$MetricDataPoint {
  const factory MetricDataPoint({
    required DateTime date,
    required double value,
    double? targetValue,
    double? forecastValue,
  }) = _MetricDataPoint;

  factory MetricDataPoint.fromJson(Map<String, dynamic> json) =>
      _$MetricDataPointFromJson(json);
}

enum TrendDirection {
  @JsonValue('up')
  up,
  @JsonValue('down')
  down,
  @JsonValue('stable')
  stable,
  @JsonValue('volatile')
  volatile,
}

@freezed
abstract class RevenueDriverAnalysis with _$RevenueDriverAnalysis {
  const factory RevenueDriverAnalysis({
    required String driverName,
    required String driverDisplayName,
    required DriverType type,
    required double impactScore,
    required double correlationCoefficient,
    required List<DriverDataPoint> dataPoints,
    String? explanation,
    List<DriverRecommendation>? recommendations,
  }) = _RevenueDriverAnalysis;

  factory RevenueDriverAnalysis.fromJson(Map<String, dynamic> json) =>
      _$RevenueDriverAnalysisFromJson(json);
}

enum DriverType {
  @JsonValue('internal')
  internal,
  @JsonValue('external')
  external,
  @JsonValue('market')
  market,
  @JsonValue('seasonal')
  seasonal,
  @JsonValue('campaign')
  campaign,
}

@freezed
abstract class DriverDataPoint with _$DriverDataPoint {
  const factory DriverDataPoint({
    required DateTime date,
    required double driverValue,
    required double revenueValue,
    double? expectedRevenue,
  }) = _DriverDataPoint;

  factory DriverDataPoint.fromJson(Map<String, dynamic> json) =>
      _$DriverDataPointFromJson(json);
}

@freezed
abstract class DriverRecommendation with _$DriverRecommendation {
  const factory DriverRecommendation({
    required String action,
    required String description,
    required Priority priority,
    required double expectedImpact,
    required List<String> requiredResources,
    DateTime? targetCompletionDate,
    String? responsibleTeam,
  }) = _DriverRecommendation;

  factory DriverRecommendation.fromJson(Map<String, dynamic> json) =>
      _$DriverRecommendationFromJson(json);
}

enum Priority {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('critical')
  critical,
}

@freezed
abstract class RevenueInsight with _$RevenueInsight {
  const factory RevenueInsight({
    required String id,
    required String title,
    required String description,
    required InsightType type,
    required InsightSeverity severity,
    required DateTime detectedAt,
    required double confidenceScore,
    List<String>? affectedSegments,
    List<String>? contributingFactors,
    List<String>? suggestedActions,
    Map<String, dynamic>? insightData,
    DateTime? acknowledgedAt,
    String? acknowledgedBy,
    DateTime? resolvedAt,
    String? resolvedBy,
    String? resolutionNotes,
  }) = _RevenueInsight;

  factory RevenueInsight.fromJson(Map<String, dynamic> json) =>
      _$RevenueInsightFromJson(json);
}

enum InsightType {
  @JsonValue('opportunity')
  opportunity,
  @JsonValue('risk')
  risk,
  @JsonValue('anomaly')
  anomaly,
  @JsonValue('trend')
  trend,
  @JsonValue('performance')
  performance,
}

enum InsightSeverity {
  @JsonValue('info')
  info,
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('critical')
  critical,
}

@freezed
abstract class RevenueRecommendation with _$RevenueRecommendation {
  const factory RevenueRecommendation({
    required String id,
    required String title,
    required String description,
    required RecommendationCategory category,
    required Priority priority,
    required double expectedImpact,
    required List<String> implementationSteps,
    required List<String> requiredResources,
    DateTime? targetCompletionDate,
    String? responsibleTeam,
    String? status,
    DateTime? implementedAt,
    String? implementedBy,
    double? actualImpact,
    String? implementationNotes,
  }) = _RevenueRecommendation;

  factory RevenueRecommendation.fromJson(Map<String, dynamic> json) =>
      _$RevenueRecommendationFromJson(json);
}

enum RecommendationCategory {
  @JsonValue('pricing')
  pricing,
  @JsonValue('product')
  product,
  @JsonValue('sales')
  sales,
  @JsonValue('marketing')
  marketing,
  @JsonValue('customer_success')
  customerSuccess,
  @JsonValue('operations')
  operations,
  @JsonValue('finance')
  finance,
}

@freezed
abstract class ReportFilter with _$ReportFilter {
  const factory ReportFilter({
    DateTime? startDate,
    DateTime? endDate,
    List<ReportType>? types,
    List<ReportStatus>? statuses,
    String? generatedByAdminId,
    String? searchQuery,
    @Default('generatedAt') String sortBy,
    @Default(true) bool sortDesc,
    @Default(1) int page,
    @Default(20) int limit,
  }) = _ReportFilter;

  factory ReportFilter.fromJson(Map<String, dynamic> json) =>
      _$ReportFilterFromJson(json);
}

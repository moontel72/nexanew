import 'package:freezed_annotation/freezed_annotation.dart';

part 'revenue_report_model.freezed.dart';
part 'revenue_report_model.g.dart';

enum RevenueType {
  @JsonValue('subscription')
  subscription,
  @JsonValue('usage')
  usage,
  @JsonValue('commission')
  commission,
  @JsonValue('one_time')
  oneTime,
  @JsonValue('refund')
  refund,
  @JsonValue('credit_note')
  creditNote,
  @JsonValue('other')
  other,
}

enum ReportPeriod {
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
}

@freezed
abstract class RevenueDataPoint with _$RevenueDataPoint {
  const factory RevenueDataPoint({
    required DateTime date,
    required double amount,
    required String currency,
    required RevenueType type,
    String? companyId,
    String? planId,
    String? region,
    Map<String, dynamic>? metadata,
  }) = _RevenueDataPoint;

  factory RevenueDataPoint.fromJson(Map<String, dynamic> json) =>
      _$RevenueDataPointFromJson(json);
}

@freezed
abstract class RevenueBreakdown with _$RevenueBreakdown {
  const factory RevenueBreakdown({
    @Default(0.0) double totalRevenue,
    @Default('USD') String currency,
    @Default(0.0) double subscriptionRevenue,
    @Default(0.0) double usageRevenue,
    @Default(0.0) double commissionRevenue,
    @Default(0.0) double oneTimeRevenue,
    @Default(0.0) double refundAmount,
    @Default(0.0) double creditNoteAmount,
    @Default(0.0) double netRevenue,
    Map<String, double>? revenueByCompany,
    Map<String, double>? revenueByPlan,
    Map<String, double>? revenueByRegion,
    Map<String, double>? revenueByType,
    List<RevenueDataPoint>? dataPoints,
  }) = _RevenueBreakdown;

  factory RevenueBreakdown.fromJson(Map<String, dynamic> json) =>
      _$RevenueBreakdownFromJson(json);
}

@freezed
abstract class FinancialReport with _$FinancialReport {
  const factory FinancialReport({
    required String id,
    required String reportName,
    required ReportPeriod period,
    required DateTime periodStart,
    required DateTime periodEnd,
    required DateTime generatedAt,
    required RevenueBreakdown revenue,
    @Default(0.0) double totalExpenses,
    @Default(0.0) double grossProfit,
    @Default(0.0) double operatingProfit,
    @Default(0.0) double netProfit,
    @Default(0.0) double taxAmount,
    @Default(0.0) double taxRate,
    @Default(0) int totalInvoices,
    @Default(0) int paidInvoices,
    @Default(0) int overdueInvoices,
    @Default(0) int newCustomers,
    @Default(0) int churnedCustomers,
    @Default(0.0) double customerLifetimeValue,
    @Default(0.0) double monthlyRecurringRevenue,
    @Default(0.0) double annualRecurringRevenue,
    @Default(0.0) double churnRate,
    @Default(0.0) double growthRate,
    Map<String, dynamic>? metrics,
    Map<String, dynamic>? comparisons,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _FinancialReport;

  factory FinancialReport.fromJson(Map<String, dynamic> json) =>
      _$FinancialReportFromJson(json);

  factory FinancialReport.empty() => FinancialReport(
    id: '',
    reportName: '',
    period: ReportPeriod.monthly,
    periodStart: DateTime.now(),
    periodEnd: DateTime.now(),
    generatedAt: DateTime.now(),
    revenue: RevenueBreakdown(),
  );
}

@freezed
abstract class RevenueForecast with _$RevenueForecast {
  const factory RevenueForecast({
    required DateTime forecastDate,
    required DateTime periodStart,
    required DateTime periodEnd,
    @Default(0.0) double forecastedRevenue,
    @Default('USD') String currency,
    @Default(0.0) double lowerBound,
    @Default(0.0) double upperBound,
    @Default(0.0) double confidenceLevel,
    Map<String, double>? forecastByType,
    Map<String, double>? forecastByCompany,
    List<RevenueDataPoint>? historicalData,
    List<RevenueDataPoint>? forecastData,
    String? methodology,
    Map<String, dynamic>? assumptions,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) = _RevenueForecast;

  factory RevenueForecast.fromJson(Map<String, dynamic> json) =>
      _$RevenueForecastFromJson(json);
}

@freezed
abstract class TaxSummary with _$TaxSummary {
  const factory TaxSummary({
    required DateTime periodStart,
    required DateTime periodEnd,
    @Default(0.0) double taxableRevenue,
    @Default(0.0) double taxCollected,
    @Default('USD') String currency,
    @Default(0.0) double taxRate,
    Map<String, double>? taxByJurisdiction,
    Map<String, double>? taxByCompany,
    Map<String, double>? taxByRevenueType,
    List<TaxTransaction>? transactions,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? generatedAt,
  }) = _TaxSummary;

  factory TaxSummary.fromJson(Map<String, dynamic> json) =>
      _$TaxSummaryFromJson(json);
}

@freezed
abstract class TaxTransaction with _$TaxTransaction {
  const factory TaxTransaction({
    required String id,
    required DateTime transactionDate,
    required double amount,
    required double taxAmount,
    required String currency,
    required double taxRate,
    String? companyId,
    String? invoiceId,
    RevenueType? revenueType,
    String? jurisdiction,
    String? taxCode,
    String? description,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) = _TaxTransaction;

  factory TaxTransaction.fromJson(Map<String, dynamic> json) =>
      _$TaxTransactionFromJson(json);
}

@freezed
abstract class ReportFilter with _$ReportFilter {
  const factory ReportFilter({
    DateTime? startDate,
    DateTime? endDate,
    List<RevenueType>? revenueTypes,
    List<String>? companyIds,
    List<String>? planIds,
    List<String>? regions,
    ReportPeriod? period,
    @Default('generatedAt') String sortBy,
    @Default(false) bool sortDesc,
    @Default(1) int page,
    @Default(20) int limit,
  }) = _ReportFilter;

  factory ReportFilter.fromJson(Map<String, dynamic> json) =>
      _$ReportFilterFromJson(json);
}

@freezed
abstract class ExportRequest with _$ExportRequest {
  const factory ExportRequest({
    required String format,
    required ReportFilter filter,
    List<String>? columns,
    @Default(false) bool includeCharts,
    String? fileName,
    Map<String, dynamic>? options,
  }) = _ExportRequest;

  factory ExportRequest.fromJson(Map<String, dynamic> json) =>
      _$ExportRequestFromJson(json);
}

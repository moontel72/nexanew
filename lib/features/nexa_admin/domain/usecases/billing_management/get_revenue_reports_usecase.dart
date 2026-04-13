import 'package:dartz/dartz.dart';
import 'package:nexatrace_system/core/errors/failures.dart';
import 'package:nexatrace_system/core/usecase/usecase.dart';
import 'package:nexatrace_system/features/nexa_admin/data/repositories/billing_repository.dart';
import 'package:nexatrace_system/shared/models/billing/revenue_report_model.dart'
    as shared;

/// Parameters for getting revenue reports
class GetRevenueReportsParams {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<shared.RevenueType>? revenueTypes;
  final List<String>? companyIds;
  final List<String>? planIds;
  final List<String>? regions;
  final shared.ReportPeriod? period;
  final int page;
  final int limit;

  const GetRevenueReportsParams({
    this.startDate,
    this.endDate,
    this.revenueTypes,
    this.companyIds,
    this.planIds,
    this.regions,
    this.period,
    this.page = 1,
    this.limit = 20,
  });

  /// Convert to filter for repository
  shared.ReportFilter toFilter() {
    return shared.ReportFilter(
      startDate: startDate,
      endDate: endDate,
      revenueTypes: revenueTypes,
      companyIds: companyIds,
      planIds: planIds,
      regions: regions,
      period: period,
      page: page,
      limit: limit,
      sortBy: 'generatedAt',
      sortDesc: true,
    );
  }

  /// Validates the parameters for getting revenue reports
  List<String> validate() {
    final errors = <String>[];

    if (startDate != null && endDate != null) {
      if (startDate!.isAfter(endDate!)) {
        errors.add('Start date cannot be after end date');
      }
    }

    if (page < 1) {
      errors.add('Page must be greater than 0');
    }

    if (limit < 1 || limit > 100) {
      errors.add('Limit must be between 1 and 100');
    }

    return errors;
  }
}

/// Use case for getting revenue reports
class GetRevenueReportsUseCase
    implements UseCase<List<FinancialReport>, GetRevenueReportsParams> {
  final BillingRepository repository;

  const GetRevenueReportsUseCase(this.repository);

  @override
  Future<Either<Failure, List<FinancialReport>>> call(
    GetRevenueReportsParams params,
  ) async {
    try {
      // Validate parameters
      final validationErrors = params.validate();
      if (validationErrors.isNotEmpty) {
        return Left(InvalidParamsFailure(validationErrors));
      }

      // Get revenue reports from repository
      final result = await repository.getRevenueReports(params.toFilter());
      return result;
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

/// Parameters for generating a financial report
class GenerateFinancialReportParams {
  final String reportName;
  final shared.ReportPeriod period;
  final DateTime periodStart;
  final DateTime periodEnd;
  final List<shared.RevenueType>? includeTypes;
  final List<String>? companyIds;
  final bool includeForecast;
  final bool includeTaxSummary;
  final String? notes;

  const GenerateFinancialReportParams({
    required this.reportName,
    required this.period,
    required this.periodStart,
    required this.periodEnd,
    this.includeTypes,
    this.companyIds,
    this.includeForecast = false,
    this.includeTaxSummary = false,
    this.notes,
  });

  /// Validates the parameters for generating a financial report
  List<String> validate() {
    final errors = <String>[];

    if (reportName.isEmpty) {
      errors.add('Report name is required');
    }

    if (periodStart.isAfter(periodEnd)) {
      errors.add('Period start cannot be after period end');
    }

    // Validate period based on the selected period type
    final duration = periodEnd.difference(periodStart);
    switch (period) {
      case shared.ReportPeriod.daily:
        if (duration.inDays > 1) {
          errors.add('Daily report period should not exceed 1 day');
        }
        break;
      case shared.ReportPeriod.weekly:
        if (duration.inDays > 7) {
          errors.add('Weekly report period should not exceed 7 days');
        }
        break;
      case shared.ReportPeriod.monthly:
        if (duration.inDays > 31) {
          errors.add('Monthly report period should not exceed 31 days');
        }
        break;
      case shared.ReportPeriod.quarterly:
        if (duration.inDays > 93) {
          errors.add('Quarterly report period should not exceed 93 days');
        }
        break;
      case shared.ReportPeriod.yearly:
        if (duration.inDays > 366) {
          errors.add('Yearly report period should not exceed 366 days');
        }
        break;
      case shared.ReportPeriod.custom:
        // No specific validation for custom period
        break;
    }

    return errors;
  }
}

/// Use case for generating a financial report
class GenerateFinancialReportUseCase
    implements UseCase<FinancialReport, GenerateFinancialReportParams> {
  final BillingRepository repository;

  const GenerateFinancialReportUseCase(this.repository);

  @override
  Future<Either<Failure, FinancialReport>> call(
    GenerateFinancialReportParams params,
  ) async {
    try {
      // Validate parameters
      final validationErrors = params.validate();
      if (validationErrors.isNotEmpty) {
        return Left(InvalidParamsFailure(validationErrors));
      }

      // Generate financial report through repository
      final result = await repository.generateFinancialReport(
        reportName: params.reportName,
        period: params.period,
        periodStart: params.periodStart,
        periodEnd: params.periodEnd,
        includeTypes: params.includeTypes,
        companyIds: params.companyIds,
        includeForecast: params.includeForecast,
        includeTaxSummary: params.includeTaxSummary,
        notes: params.notes,
      );
      return result;
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

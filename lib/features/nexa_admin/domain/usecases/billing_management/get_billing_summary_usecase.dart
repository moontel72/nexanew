import 'package:dartz/dartz.dart';
import 'package:nexatrace_system/core/errors/failures.dart';
import 'package:nexatrace_system/core/usecase/usecase.dart';
import 'package:nexatrace_system/features/nexa_admin/domain/entities/billing_entity.dart';
import 'package:nexatrace_system/features/nexa_admin/data/repositories/billing_repository.dart';
import 'package:nexatrace_system/shared/models/billing/invoice_model.dart'
    as shared;

/// Parameters for getting billing summary
class GetBillingSummaryParams {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? companyIds;
  final List<shared.InvoiceStatus>? statuses;

  const GetBillingSummaryParams({
    this.startDate,
    this.endDate,
    this.companyIds,
    this.statuses,
  });

  /// Convert to filter for repository
  shared.BillingFilter toFilter() {
    return shared.BillingFilter(
      startDate: startDate,
      endDate: endDate,
      statuses: statuses,
      sortBy: 'issueDate',
      sortDesc: true,
    );
  }
}

/// Use case for getting billing summary
class GetBillingSummaryUseCase
    implements UseCase<BillingSummary, GetBillingSummaryParams> {
  final BillingRepository repository;

  const GetBillingSummaryUseCase(this.repository);

  @override
  Future<Either<Failure, BillingSummary>> call(
    GetBillingSummaryParams params,
  ) async {
    try {
      // Validate parameters
      final validationErrors = _validateParams(params);
      if (validationErrors.isNotEmpty) {
        return Left(InvalidParamsFailure(validationErrors));
      }

      // Get billing summary from repository
      final result = await repository.getBillingSummary(params.toFilter());
      return result;
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Validate the parameters
  List<String> _validateParams(GetBillingSummaryParams params) {
    final errors = <String>[];

    if (params.startDate != null && params.endDate != null) {
      if (params.startDate!.isAfter(params.endDate!)) {
        errors.add('Start date cannot be after end date');
      }
    }

    return errors;
  }
}

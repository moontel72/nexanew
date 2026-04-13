import 'package:dartz/dartz.dart';
import 'package:nexatrace_system/core/errors/failures.dart';
import 'package:nexatrace_system/core/usecase/usecase.dart';
import 'package:nexatrace_system/features/nexa_admin/domain/entities/billing_entity.dart';
import 'package:nexatrace_system/features/nexa_admin/data/repositories/billing_repository.dart';
import 'package:nexatrace_system/shared/models/billing/invoice_model.dart'
    as shared;

/// Parameters for updating invoice status
class UpdateInvoiceStatusParams {
  final String invoiceId;
  final shared.InvoiceStatus newStatus;
  final String? paymentMethod;
  final String? paymentReference;
  final DateTime? paymentDate;
  final String? notes;

  const UpdateInvoiceStatusParams({
    required this.invoiceId,
    required this.newStatus,
    this.paymentMethod,
    this.paymentReference,
    this.paymentDate,
    this.notes,
  });

  /// Validates the parameters for updating invoice status
  List<String> validate() {
    final errors = <String>[];

    if (invoiceId.isEmpty) {
      errors.add('Invoice ID is required');
    }

    // Validate payment-related fields when marking as paid
    if (newStatus == shared.InvoiceStatus.paid) {
      if (paymentMethod == null || paymentMethod!.isEmpty) {
        errors.add('Payment method is required when marking invoice as paid');
      }
      if (paymentDate == null) {
        errors.add('Payment date is required when marking invoice as paid');
      }
    }

    // Validate payment reference for certain payment methods
    if (paymentMethod != null &&
        paymentMethod!.isNotEmpty &&
        paymentMethod != 'cash' &&
        (paymentReference == null || paymentReference!.isEmpty)) {
      errors.add('Payment reference is required for non-cash payment methods');
    }

    return errors;
  }
}

/// Use case for updating invoice status
class UpdateInvoiceStatusUseCase
    implements UseCase<Invoice, UpdateInvoiceStatusParams> {
  final BillingRepository repository;

  const UpdateInvoiceStatusUseCase(this.repository);

  @override
  Future<Either<Failure, Invoice>> call(
    UpdateInvoiceStatusParams params,
  ) async {
    try {
      // Validate parameters
      final validationErrors = params.validate();
      if (validationErrors.isNotEmpty) {
        return Left(InvalidParamsFailure(validationErrors));
      }

      // Update invoice status through repository
      final result = await repository.updateInvoiceStatus(
        invoiceId: params.invoiceId,
        newStatus: params.newStatus,
        paymentMethod: params.paymentMethod,
        paymentReference: params.paymentReference,
        paymentDate: params.paymentDate,
        notes: params.notes,
      );
      return result;
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

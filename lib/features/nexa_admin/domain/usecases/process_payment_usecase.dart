import 'package:dartz/dartz.dart';
import 'package:nexatrace_system/core/errors/failures.dart';
import 'package:nexatrace_system/core/usecase/usecase.dart';
import 'package:nexatrace_system/features/nexa_admin/domain/entities/billing_entity.dart';
import 'package:nexatrace_system/features/nexa_admin/domain/repositories/billing_repository.dart';
import 'package:nexatrace_system/shared/models/billing/invoice_model.dart'
    as shared;

/// Parameters for processing a payment
class ProcessPaymentParams {
  final String invoiceId;
  final double amount;
  final shared.PaymentMethod method;
  final DateTime paymentDate;
  final String? reference;
  final String? transactionId;
  final String? notes;
  final bool sendNotification;

  const ProcessPaymentParams({
    required this.invoiceId,
    required this.amount,
    required this.method,
    required this.paymentDate,
    this.reference,
    this.transactionId,
    this.notes,
    this.sendNotification = true,
  });

  /// Validates the payment parameters
  List<String> validate() {
    final errors = <String>[];

    if (invoiceId.isEmpty) {
      errors.add('Invoice ID is required');
    }

    if (amount <= 0) {
      errors.add('Amount must be greater than 0');
    }

    if (paymentDate.isAfter(DateTime.now())) {
      errors.add('Payment date cannot be in the future');
    }

    // Validate reference based on payment method
    if (method == shared.PaymentMethod.bankTransfer && reference == null) {
      errors.add('Reference is required for bank transfers');
    }

    if (method == shared.PaymentMethod.creditCard && transactionId == null) {
      errors.add('Transaction ID is required for credit card payments');
    }

    return errors;
  }

  /// Creates a copy with updated values
  ProcessPaymentParams copyWith({
    String? invoiceId,
    double? amount,
    shared.PaymentMethod? method,
    DateTime? paymentDate,
    String? reference,
    String? transactionId,
    String? notes,
    bool? sendNotification,
  }) {
    return ProcessPaymentParams(
      invoiceId: invoiceId ?? this.invoiceId,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      paymentDate: paymentDate ?? this.paymentDate,
      reference: reference ?? this.reference,
      transactionId: transactionId ?? this.transactionId,
      notes: notes ?? this.notes,
      sendNotification: sendNotification ?? this.sendNotification,
    );
  }
}

/// Use case for processing a payment
class ProcessPaymentUseCase
    implements UseCase<BillingEntity, ProcessPaymentParams> {
  final BillingRepository repository;

  ProcessPaymentUseCase(this.repository);

  @override
  Future<Either<Failure, BillingEntity>> call(
    ProcessPaymentParams params,
  ) async {
    // Validate parameters
    final validationErrors = params.validate();
    if (validationErrors.isNotEmpty) {
      return Left(
        ValidationFailure(
          message: 'Invalid payment parameters',
          errors: validationErrors,
        ),
      );
    }

    try {
      // Record the payment through repository
      final paymentResult = await repository.recordPayment(
        invoiceId: params.invoiceId,
        amount: params.amount,
        method: params.method,
        paymentDate: params.paymentDate,
        reference: params.reference,
        transactionId: params.transactionId,
        notes: params.notes,
      );

      return paymentResult.fold((failure) => Left(failure), (payment) async {
        // Get the updated invoice to reflect payment status
        final invoiceResult = await repository.getInvoiceById(params.invoiceId);

        return invoiceResult.fold((failure) => Left(failure), (invoice) {
          // Convert AdminInvoice to BillingEntity
          final billingEntity = BillingEntity(
            id: invoice.id,
            type: BillingEntityType.payment,
            referenceNumber: payment.reference ?? payment.id,
            companyId: invoice.companyId,
            companyName: invoice.companyName,
            amount: params.amount,
            currency: payment.currency,
            status: BillingEntityStatus.paid,
            issueDate: payment.paymentDate,
            paymentDate: payment.paymentDate,
            paymentMethod: payment.method,
            paymentReference: payment.reference,
            transactionId: payment.transactionId,
            notes: params.notes,
            metadata: payment.metadata,
            createdAt: payment.createdAt,
          );

          // Send notification if requested
          if (params.sendNotification) {
            // In a real implementation, this would trigger a notification
            print(
              'Payment notification sent for invoice ${invoice.invoiceNumber}',
            );
          }

          return Right(billingEntity);
        });
      });
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'Failed to process payment: ${e.toString()}',
          originalError: e,
        ),
      );
    }
  }
}

/// Use case for processing partial payments
class ProcessPartialPaymentUseCase
    implements UseCase<BillingEntity, ProcessPaymentParams> {
  final BillingRepository repository;

  ProcessPartialPaymentUseCase(this.repository);

  @override
  Future<Either<Failure, BillingEntity>> call(
    ProcessPaymentParams params,
  ) async {
    // Validate parameters for partial payment
    final validationErrors = params.validate();
    if (validationErrors.isNotEmpty) {
      return Left(
        ValidationFailure(
          message: 'Invalid partial payment parameters',
          errors: validationErrors,
        ),
      );
    }

    try {
      // Get the invoice to check current status and amount
      final invoiceResult = await repository.getInvoiceById(params.invoiceId);

      return invoiceResult.fold((failure) => Left(failure), (invoice) async {
        // Check if invoice can accept partial payments
        if (invoice.status != shared.InvoiceStatus.pending &&
            invoice.status != shared.InvoiceStatus.overdue) {
          return Left(
            ValidationFailure(
              message: 'Invoice cannot accept partial payments',
              errors: ['Invoice status is ${invoice.status}'],
            ),
          );
        }

        // Check if payment amount is valid
        if (params.amount > invoice.totalAmount) {
          return Left(
            ValidationFailure(
              message: 'Payment amount exceeds invoice total',
              errors: [
                'Payment: \$${params.amount}, Invoice: \$${invoice.totalAmount}',
              ],
            ),
          );
        }

        // Record the partial payment
        final paymentResult = await repository.recordPayment(
          invoiceId: params.invoiceId,
          amount: params.amount,
          method: params.method,
          paymentDate: params.paymentDate,
          reference: params.reference,
          transactionId: params.transactionId,
          notes: params.notes,
        );

        return paymentResult.fold((failure) => Left(failure), (payment) {
          // Determine new invoice status
          final remainingBalance = invoice.totalAmount - params.amount;
          final newStatus = remainingBalance > 0
              ? BillingEntityStatus.partiallyPaid
              : BillingEntityStatus.paid;

          // Create billing entity for partial payment
          final billingEntity = BillingEntity(
            id: payment.id,
            type: BillingEntityType.payment,
            referenceNumber: payment.reference ?? payment.id,
            companyId: invoice.companyId,
            companyName: invoice.companyName,
            amount: params.amount,
            currency: payment.currency,
            status: newStatus,
            issueDate: payment.paymentDate,
            paymentDate: payment.paymentDate,
            paymentMethod: payment.method,
            paymentReference: payment.reference,
            transactionId: payment.transactionId,
            notes: 'Partial payment - Remaining: \$$remainingBalance',
            metadata: {
              ...?payment.metadata,
              'remaining_balance': remainingBalance,
              'original_invoice_amount': invoice.totalAmount,
              'is_partial_payment': true,
            },
            createdAt: payment.createdAt,
          );

          return Right(billingEntity);
        });
      });
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'Failed to process partial payment: ${e.toString()}',
          originalError: e,
        ),
      );
    }
  }
}

/// Use case for processing bulk payments
class ProcessBulkPaymentsUseCase
    implements UseCase<List<BillingEntity>, List<ProcessPaymentParams>> {
  final BillingRepository repository;

  ProcessBulkPaymentsUseCase(this.repository);

  @override
  Future<Either<Failure, List<BillingEntity>>> call(
    List<ProcessPaymentParams> paramsList,
  ) async {
    final results = <BillingEntity>[];
    final errors = <String>[];

    // Validate all parameters first
    for (var i = 0; i < paramsList.length; i++) {
      final params = paramsList[i];
      final validationErrors = params.validate();
      if (validationErrors.isNotEmpty) {
        errors.add('Payment ${i + 1}: ${validationErrors.join(", ")}');
      }
    }

    if (errors.isNotEmpty) {
      return Left(
        ValidationFailure(
          message: 'Invalid parameters for bulk payment processing',
          errors: errors,
        ),
      );
    }

    // Process payments sequentially
    for (final params in paramsList) {
      final result = await ProcessPaymentUseCase(repository).call(params);

      result.fold(
        (failure) {
          errors.add(
            'Failed to process payment for invoice ${params.invoiceId}: ${failure.message}',
          );
        },
        (payment) {
          results.add(payment);
        },
      );
    }

    if (errors.isNotEmpty && results.isEmpty) {
      return Left(
        BulkOperationFailure(
          message: 'Failed to process any payments',
          errors: errors,
        ),
      );
    }

    if (errors.isNotEmpty) {
      // Some succeeded, some failed - return partial success
      return Right(results);
    }

    return Right(results);
  }
}

/// Use case for validating payment reversal/refund
class ValidatePaymentReversalUseCase
    implements UseCase<PaymentReversalValidation, String> {
  final BillingRepository repository;

  ValidatePaymentReversalUseCase(this.repository);

  @override
  Future<Either<Failure, PaymentReversalValidation>> call(
    String paymentId,
  ) async {
    try {
      // In a real implementation, this would:
      // 1. Fetch the payment details
      // 2. Check if reversal is allowed (time limits, status, etc.)
      // 3. Calculate any fees or restrictions

      // For now, return a mock validation
      final validation = PaymentReversalValidation(
        paymentId: paymentId,
        canReverse: true,
        reversalDeadline: DateTime.now().add(const Duration(days: 30)),
        reversalFee: 0.0,
        restrictions: [],
        warnings: ['Ensure customer has been notified'],
      );

      return Right(validation);
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'Failed to validate payment reversal: ${e.toString()}',
          originalError: e,
        ),
      );
    }
  }
}

/// Validation result for payment reversal
class PaymentReversalValidation {
  final String paymentId;
  final bool canReverse;
  final DateTime reversalDeadline;
  final double reversalFee;
  final List<String> restrictions;
  final List<String> warnings;

  const PaymentReversalValidation({
    required this.paymentId,
    required this.canReverse,
    required this.reversalDeadline,
    required this.reversalFee,
    required this.restrictions,
    required this.warnings,
  });

  Map<String, dynamic> toJson() => {
    'paymentId': paymentId,
    'canReverse': canReverse,
    'reversalDeadline': reversalDeadline.toIso8601String(),
    'reversalFee': reversalFee,
    'restrictions': restrictions,
    'warnings': warnings,
  };
}

/// Use case for calculating payment allocation
class CalculatePaymentAllocationUseCase
    implements UseCase<PaymentAllocation, PaymentAllocationParams> {
  @override
  Future<Either<Failure, PaymentAllocation>> call(
    PaymentAllocationParams params,
  ) async {
    try {
      // Calculate allocation based on strategy
      double remainingAmount = params.paymentAmount;
      final allocations = <InvoiceAllocation>[];

      for (final invoice in params.invoices) {
        if (remainingAmount <= 0) break;

        final allocationAmount = switch (params.allocationStrategy) {
          AllocationStrategy.oldestFirst => _allocateOldestFirst(
            invoice,
            remainingAmount,
            params,
          ),
          AllocationStrategy.highestAmountFirst => _allocateHighestFirst(
            invoice,
            remainingAmount,
            params,
          ),
          AllocationStrategy.proportional => _allocateProportional(
            invoice,
            remainingAmount,
            params,
          ),
          AllocationStrategy.custom => _allocateCustom(
            invoice,
            remainingAmount,
            params,
          ),
        };

        if (allocationAmount > 0) {
          allocations.add(
            InvoiceAllocation(
              invoiceId: invoice.id,
              invoiceNumber: invoice.invoiceNumber,
              allocatedAmount: allocationAmount,
              remainingBalance: invoice.totalAmount - allocationAmount,
            ),
          );
          remainingAmount -= allocationAmount;
        }
      }

      final allocation = PaymentAllocation(
        paymentAmount: params.paymentAmount,
        totalAllocated: params.paymentAmount - remainingAmount,
        remainingAmount: remainingAmount,
        allocations: allocations,
        allocationStrategy: params.allocationStrategy,
      );

      return Right(allocation);
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'Failed to calculate payment allocation: ${e.toString()}',
          originalError: e,
        ),
      );
    }
  }

  double _allocateOldestFirst(
    shared.Invoice invoice,
    double remainingAmount,
    PaymentAllocationParams params,
  ) {
    final invoiceBalance = invoice.totalAmount;
    return remainingAmount >= invoiceBalance ? invoiceBalance : remainingAmount;
  }

  double _allocateHighestFirst(
    shared.Invoice invoice,
    double remainingAmount,
    PaymentAllocationParams params,
  ) {
    // Sort invoices by amount descending before calling this
    final invoiceBalance = invoice.totalAmount;
    return remainingAmount >= invoiceBalance ? invoiceBalance : remainingAmount;
  }

  double _allocateProportional(
    shared.Invoice invoice,
    double remainingAmount,
    PaymentAllocationParams params,
  ) {
    final totalInvoiceAmount = params.invoices.fold(
      0.0,
      (sum, inv) => sum + inv.totalAmount,
    );
    final proportion = invoice.totalAmount / totalInvoiceAmount;
    return params.paymentAmount * proportion;
  }

  double _allocateCustom(
    shared.Invoice invoice,
    double remainingAmount,
    PaymentAllocationParams params,
  ) {
    // Custom allocation would use params.customAllocations map
    final customAmount = params.customAllocations?[invoice.id] ?? 0.0;
    return customAmount <= remainingAmount ? customAmount : remainingAmount;
  }
}

/// Parameters for payment allocation calculation
class PaymentAllocationParams {
  final double paymentAmount;
  final List<shared.Invoice> invoices;
  final AllocationStrategy allocationStrategy;
  final Map<String, double>? customAllocations;

  const PaymentAllocationParams({
    required this.paymentAmount,
    required this.invoices,
    required this.allocationStrategy,
    this.customAllocations,
  });
}

/// Payment allocation strategies
enum AllocationStrategy {
  oldestFirst,
  highestAmountFirst,
  proportional,
  custom,
}

/// Result of payment allocation calculation
class PaymentAllocation {
  final double paymentAmount;
  final double totalAllocated;
  final double remainingAmount;
  final List<InvoiceAllocation> allocations;
  final AllocationStrategy allocationStrategy;

  const PaymentAllocation({
    required this.paymentAmount,
    required this.totalAllocated,
    required this.remainingAmount,
    required this.allocations,
    required this.allocationStrategy,
  });

  Map<String, dynamic> toJson() => {
    'paymentAmount': paymentAmount,
    'totalAllocated': totalAllocated,
    'remainingAmount': remainingAmount,
    'allocations': allocations.map((a) => a.toJson()).toList(),
    'allocationStrategy': allocationStrategy.toString(),
  };
}

/// Allocation for a specific invoice
class InvoiceAllocation {
  final String invoiceId;
  final String invoiceNumber;
  final double allocatedAmount;
  final double remainingBalance;

  const InvoiceAllocation({
    required this.invoiceId,
    required this.invoiceNumber,
    required this.allocatedAmount,
    required this.remainingBalance,
  });

  Map<String, dynamic> toJson() => {
    'invoiceId': invoiceId,
    'invoiceNumber': invoiceNumber,
    'allocatedAmount': allocatedAmount,
    'remainingBalance': remainingBalance,
  };
}

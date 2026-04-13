import 'package:dartz/dartz.dart';
import 'package:nexatrace_system/core/errors/failures.dart';
import 'package:nexatrace_system/core/usecase/usecase.dart';
import 'package:nexatrace_system/features/nexa_admin/domain/entities/billing_entity.dart';
import 'package:nexatrace_system/features/nexa_admin/data/repositories/billing_repository.dart';
import 'package:nexatrace_system/shared/models/billing/invoice_model.dart'
    as shared;

/// Parameters for generating an invoice
class GenerateInvoiceParams {
  final String companyId;
  final String subscriptionId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final List<shared.InvoiceItem> items;
  final String? notes;
  final bool sendNotification;

  const GenerateInvoiceParams({
    required this.companyId,
    required this.subscriptionId,
    required this.periodStart,
    required this.periodEnd,
    required this.items,
    this.notes,
    this.sendNotification = true,
  });

  /// Validates the parameters for invoice generation
  List<String> validate() {
    final errors = <String>[];

    if (companyId.isEmpty) {
      errors.add('Company ID is required');
    }

    if (subscriptionId.isEmpty) {
      errors.add('Subscription ID is required');
    }

    if (periodStart.isAfter(periodEnd)) {
      errors.add('Period start cannot be after period end');
    }

    if (items.isEmpty) {
      errors.add('At least one invoice item is required');
    }

    // Validate each item
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      if (item.description.isEmpty) {
        errors.add('Item ${i + 1}: Description is required');
      }
      if (item.quantity <= 0) {
        errors.add('Item ${i + 1}: Quantity must be greater than 0');
      }
      if (item.unitPrice <= 0) {
        errors.add('Item ${i + 1}: Unit price must be greater than 0');
      }
      if (item.total <= 0) {
        errors.add('Item ${i + 1}: Total must be greater than 0');
      }
      if (item.currency.isEmpty) {
        errors.add('Item ${i + 1}: Currency is required');
      }
    }

    // Calculate total to ensure it matches sum of items
    final calculatedTotal = items.fold(0.0, (sum, item) => sum + item.total);
    final expectedTotal = items.fold(
      0.0,
      (sum, item) => sum + (item.quantity * item.unitPrice),
    );

    if ((calculatedTotal - expectedTotal).abs() > 0.01) {
      errors.add('Item totals do not match calculated amounts');
    }

    return errors;
  }

  /// Creates a copy with updated values
  GenerateInvoiceParams copyWith({
    String? companyId,
    String? subscriptionId,
    DateTime? periodStart,
    DateTime? periodEnd,
    List<shared.InvoiceItem>? items,
    String? notes,
    bool? sendNotification,
  }) {
    return GenerateInvoiceParams(
      companyId: companyId ?? this.companyId,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      items: items ?? this.items,
      notes: notes ?? this.notes,
      sendNotification: sendNotification ?? this.sendNotification,
    );
  }
}

/// Use case for generating an invoice
class GenerateInvoiceUseCase
    implements UseCase<BillingEntity, GenerateInvoiceParams> {
  final BillingRepository repository;

  GenerateInvoiceUseCase(this.repository);

  @override
  Future<Either<Failure, BillingEntity>> call(
    GenerateInvoiceParams params,
  ) async {
    // Validate parameters
    final validationErrors = params.validate();
    if (validationErrors.isNotEmpty) {
      return Left(
        ValidationFailure(
          message: 'Invalid invoice parameters',
          errors: validationErrors,
        ),
      );
    }

    try {
      // Generate the invoice through repository
      final invoiceResult = await repository.generateInvoice(
        companyId: params.companyId,
        subscriptionId: params.subscriptionId,
        periodStart: params.periodStart,
        periodEnd: params.periodEnd,
        items: params.items,
        notes: params.notes,
      );

      return invoiceResult.fold((failure) => Left(failure), (invoice) async {
        // Convert AdminInvoice to BillingEntity
        final billingEntity = BillingEntity(
          id: invoice.id,
          type: BillingEntityType.invoice,
          referenceNumber: invoice.invoiceNumber,
          companyId: invoice.companyId,
          companyName: invoice.companyName,
          amount: invoice.totalAmount,
          currency: invoice.currency,
          status: _mapInvoiceStatus(invoice.status),
          issueDate: invoice.issueDate,
          dueDate: invoice.dueDate,
          paymentDate: invoice.paymentDate,
          paymentMethod: invoice.paymentMethod,
          paymentReference: invoice.paymentReference,
          notes: invoice.notes,
          adminNotes: invoice.adminNotes,
          metadata: invoice.metadata,
          createdAt: invoice.createdAt,
          updatedAt: invoice.updatedAt,
        );

        // Send notification if requested
        if (params.sendNotification) {
          final notificationResult = await repository.sendInvoiceNotification(
            invoice.id,
          );
          if (notificationResult.isLeft()) {
            // Log the notification failure but don't fail the invoice generation
            print(
              'Failed to send invoice notification: ${notificationResult.left}',
            );
          }
        }

        return Right(billingEntity);
      });
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'Failed to generate invoice: ${e.toString()}',
          originalError: e,
        ),
      );
    }
  }

  /// Maps shared InvoiceStatus to BillingEntityStatus
  BillingEntityStatus _mapInvoiceStatus(shared.InvoiceStatus status) {
    switch (status) {
      case shared.InvoiceStatus.draft:
        return BillingEntityStatus.draft;
      case shared.InvoiceStatus.pending:
        return BillingEntityStatus.pending;
      case shared.InvoiceStatus.paid:
        return BillingEntityStatus.paid;
      case shared.InvoiceStatus.overdue:
        return BillingEntityStatus.overdue;
      case shared.InvoiceStatus.cancelled:
        return BillingEntityStatus.cancelled;
      case shared.InvoiceStatus.refunded:
        return BillingEntityStatus.refunded;
    }
  }
}

/// Use case for generating invoices in bulk for multiple companies
class GenerateBulkInvoicesUseCase
    implements UseCase<List<BillingEntity>, List<GenerateInvoiceParams>> {
  final BillingRepository repository;

  GenerateBulkInvoicesUseCase(this.repository);

  @override
  Future<Either<Failure, List<BillingEntity>>> call(
    List<GenerateInvoiceParams> paramsList,
  ) async {
    final results = <BillingEntity>[];
    final errors = <String>[];

    // Validate all parameters first
    for (var i = 0; i < paramsList.length; i++) {
      final params = paramsList[i];
      final validationErrors = params.validate();
      if (validationErrors.isNotEmpty) {
        errors.add(
          'Company ${params.companyId}: ${validationErrors.join(", ")}',
        );
      }
    }

    if (errors.isNotEmpty) {
      return Left(
        ValidationFailure(
          message: 'Invalid parameters for bulk invoice generation',
          errors: errors,
        ),
      );
    }

    // Generate invoices sequentially to avoid overwhelming the system
    for (final params in paramsList) {
      final result = await GenerateInvoiceUseCase(repository).call(params);

      result.fold(
        (failure) {
          errors.add(
            'Failed to generate invoice for company ${params.companyId}: ${failure.message}',
          );
        },
        (invoice) {
          results.add(invoice);
        },
      );
    }

    if (errors.isNotEmpty && results.isEmpty) {
      return Left(
        BulkOperationFailure(
          message: 'Failed to generate any invoices',
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

/// Use case for validating invoice parameters without generating
class ValidateInvoiceParamsUseCase
    implements UseCase<List<String>, GenerateInvoiceParams> {
  @override
  Future<Either<Failure, List<String>>> call(
    GenerateInvoiceParams params,
  ) async {
    final errors = params.validate();

    if (errors.isEmpty) {
      return const Right([]);
    } else {
      return Left(
        ValidationFailure(
          message: 'Invoice parameters validation failed',
          errors: errors,
        ),
      );
    }
  }
}

/// Use case for calculating invoice totals
class CalculateInvoiceTotalsUseCase
    implements UseCase<InvoiceTotals, List<shared.InvoiceItem>> {
  @override
  Future<Either<Failure, InvoiceTotals>> call(
    List<shared.InvoiceItem> items,
  ) async {
    if (items.isEmpty) {
      return Left(
        ValidationFailure(
          message: 'No items provided for calculation',
          errors: ['At least one item is required'],
        ),
      );
    }

    try {
      final subtotal = items.fold(0.0, (sum, item) => sum + item.total);
      final taxAmount = items.fold(
        0.0,
        (sum, item) => sum + (item.total * 0.1),
      ); // Assuming 10% tax
      const discountAmount = 0.0; // Could be calculated based on business rules
      final totalAmount = subtotal + taxAmount - discountAmount;

      // Check for currency consistency
      final currencies = items.map((item) => item.currency).toSet();
      if (currencies.length > 1) {
        return Left(
          ValidationFailure(
            message: 'Multiple currencies in invoice items',
            errors: ['All items must use the same currency'],
          ),
        );
      }

      final currency = currencies.firstOrNull ?? 'USD';

      return Right(
        InvoiceTotals(
          subtotal: subtotal,
          taxAmount: taxAmount,
          discountAmount: discountAmount,
          totalAmount: totalAmount,
          currency: currency,
          itemCount: items.length,
        ),
      );
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'Failed to calculate invoice totals: ${e.toString()}',
          originalError: e,
        ),
      );
    }
  }
}

/// Represents calculated invoice totals
class InvoiceTotals {
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final String currency;
  final int itemCount;

  const InvoiceTotals({
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.currency,
    required this.itemCount,
  });

  Map<String, dynamic> toJson() => {
    'subtotal': subtotal,
    'taxAmount': taxAmount,
    'discountAmount': discountAmount,
    'totalAmount': totalAmount,
    'currency': currency,
    'itemCount': itemCount,
  };
}

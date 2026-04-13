import 'package:dartz/dartz.dart';
import 'package:nexatrace_system/core/errors/failures.dart';
import 'package:nexatrace_system/core/usecase/usecase.dart';
import 'package:nexatrace_system/features/nexa_admin/data/repositories/billing_repository.dart';
import 'package:nexatrace_system/features/nexa_admin/data/models/payment_reconciliation_model.dart';

/// Parameters for payment reconciliation
class ReconcilePaymentsParams {
  final DateTime reconciliationDate;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String? notes;
  final bool autoMatchTransactions;
  final double matchTolerance;

  const ReconcilePaymentsParams({
    required this.reconciliationDate,
    required this.periodStart,
    required this.periodEnd,
    this.notes,
    this.autoMatchTransactions = true,
    this.matchTolerance = 0.01, // 1% tolerance for amount matching
  });

  /// Validates the reconciliation parameters
  List<String> validate() {
    final errors = <String>[];

    if (reconciliationDate.isAfter(DateTime.now())) {
      errors.add('Reconciliation date cannot be in the future');
    }

    if (periodStart.isAfter(periodEnd)) {
      errors.add('Period start cannot be after period end');
    }

    if (periodStart.isAfter(reconciliationDate)) {
      errors.add('Period start cannot be after reconciliation date');
    }

    if (matchTolerance < 0 || matchTolerance > 1) {
      errors.add('Match tolerance must be between 0 and 1 (0% to 100%)');
    }

    return errors;
  }

  /// Creates a copy with updated values
  ReconcilePaymentsParams copyWith({
    DateTime? reconciliationDate,
    DateTime? periodStart,
    DateTime? periodEnd,
    String? notes,
    bool? autoMatchTransactions,
    double? matchTolerance,
  }) {
    return ReconcilePaymentsParams(
      reconciliationDate: reconciliationDate ?? this.reconciliationDate,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      notes: notes ?? this.notes,
      autoMatchTransactions:
          autoMatchTransactions ?? this.autoMatchTransactions,
      matchTolerance: matchTolerance ?? this.matchTolerance,
    );
  }
}

/// Use case for reconciling payments
class ReconcilePaymentsUseCase
    implements UseCase<PaymentReconciliation, ReconcilePaymentsParams> {
  final BillingRepository repository;

  ReconcilePaymentsUseCase(this.repository);

  @override
  Future<Either<Failure, PaymentReconciliation>> call(
    ReconcilePaymentsParams params,
  ) async {
    // Validate parameters
    final validationErrors = params.validate();
    if (validationErrors.isNotEmpty) {
      return Left(
        ValidationFailure(
          message: 'Invalid reconciliation parameters',
          errors: validationErrors,
        ),
      );
    }

    try {
      // Start reconciliation through repository
      final reconciliationResult = await repository.startReconciliation(
        reconciliationDate: params.reconciliationDate,
        periodStart: params.periodStart,
        periodEnd: params.periodEnd,
        notes: params.notes,
      );

      return reconciliationResult.fold((failure) => Left(failure), (
        reconciliation,
      ) async {
        // Process reconciliation if auto-matching is enabled
        if (params.autoMatchTransactions) {
          final processResult = await repository.processReconciliation(
            reconciliation.id,
          );

          if (processResult.isLeft()) {
            return Left(processResult.left);
          }

          // Get updated reconciliation status
          final updatedResult = await repository.getReconciliationById(
            reconciliation.id,
          );

          return updatedResult.fold(
            (failure) => Left(failure),
            (updatedReconciliation) => Right(updatedReconciliation),
          );
        }

        return Right(reconciliation);
      });
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'Failed to reconcile payments: ${e.toString()}',
          originalError: e,
        ),
      );
    }
  }
}

/// Use case for analyzing reconciliation discrepancies
class AnalyzeReconciliationDiscrepanciesUseCase
    implements UseCase<ReconciliationAnalysis, String> {
  final BillingRepository repository;

  AnalyzeReconciliationDiscrepanciesUseCase(this.repository);

  @override
  Future<Either<Failure, ReconciliationAnalysis>> call(
    String reconciliationId,
  ) async {
    try {
      // Get reconciliation details
      final reconciliationResult = await repository.getReconciliationById(
        reconciliationId,
      );

      return reconciliationResult.fold((failure) => Left(failure), (
        reconciliation,
      ) {
        // Analyze discrepancies
        final totalDiscrepancy = reconciliation.discrepancyAmount.abs();
        final discrepancyPercentage = reconciliation.expectedAmount > 0
            ? (totalDiscrepancy / reconciliation.expectedAmount) * 100
            : 0.0;

        final analysis = ReconciliationAnalysis(
          reconciliationId: reconciliationId,
          totalExpected: reconciliation.expectedAmount,
          totalActual: reconciliation.actualAmount,
          totalDiscrepancy: reconciliation.discrepancyAmount,
          discrepancyPercentage: discrepancyPercentage,
          totalTransactions: reconciliation.totalTransactions,
          matchedTransactions: reconciliation.matchedTransactions,
          unmatchedTransactions: reconciliation.unmatchedTransactions,
          partialMatchTransactions: reconciliation.partialMatchTransactions,
          status: reconciliation.status,
          reconciliationDate: reconciliation.reconciliationDate,
          periodStart: reconciliation.periodStart,
          periodEnd: reconciliation.periodEnd,
          // Categorize discrepancies
          amountDiscrepancies: _categorizeAmountDiscrepancies(reconciliation),
          dateDiscrepancies: _categorizeDateDiscrepancies(reconciliation),
          missingTransactions: _identifyMissingTransactions(reconciliation),
          duplicateTransactions: _identifyDuplicateTransactions(reconciliation),
          recommendations: _generateRecommendations(reconciliation),
        );

        return Right(analysis);
      });
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message:
              'Failed to analyze reconciliation discrepancies: ${e.toString()}',
          originalError: e,
        ),
      );
    }
  }

  List<AmountDiscrepancy> _categorizeAmountDiscrepancies(
    PaymentReconciliation reconciliation,
  ) {
    // In a real implementation, this would analyze transaction-level discrepancies
    // For now, return a simplified analysis
    return [
      AmountDiscrepancy(
        type: DiscrepancyType.amountMismatch,
        count: reconciliation.unmatchedTransactions,
        totalAmount: reconciliation.discrepancyAmount.abs(),
        averageAmount: reconciliation.unmatchedTransactions > 0
            ? reconciliation.discrepancyAmount.abs() /
                  reconciliation.unmatchedTransactions
            : 0.0,
        severity: _determineSeverity(reconciliation.discrepancyAmount.abs()),
      ),
    ];
  }

  List<DateDiscrepancy> _categorizeDateDiscrepancies(
    PaymentReconciliation reconciliation,
  ) {
    // In a real implementation, this would analyze date mismatches
    return [];
  }

  List<MissingTransaction> _identifyMissingTransactions(
    PaymentReconciliation reconciliation,
  ) {
    // In a real implementation, this would identify expected but missing transactions
    return [];
  }

  List<DuplicateTransaction> _identifyDuplicateTransactions(
    PaymentReconciliation reconciliation,
  ) {
    // In a real implementation, this would identify duplicate transactions
    return [];
  }

  List<ReconciliationRecommendation> _generateRecommendations(
    PaymentReconciliation reconciliation,
  ) {
    final recommendations = <ReconciliationRecommendation>[];

    if (reconciliation.discrepancyAmount.abs() > 1000) {
      recommendations.add(
        ReconciliationRecommendation(
          action: 'Review large discrepancies',
          description: 'Discrepancy amount exceeds \$1000 threshold',
          priority: Priority.high,
          expectedImpact: 'Reduce discrepancy by 90%',
          requiredResources: ['Finance team review'],
        ),
      );
    }

    if (reconciliation.unmatchedTransactions > 5) {
      recommendations.add(
        ReconciliationRecommendation(
          action: 'Investigate unmatched transactions',
          description:
              '${reconciliation.unmatchedTransactions} transactions remain unmatched',
          priority: Priority.medium,
          expectedImpact: 'Match remaining transactions',
          requiredResources: ['Transaction data', 'Bank statements'],
        ),
      );
    }

    if (reconciliation.status == ReconciliationStatus.requiresReview) {
      recommendations.add(
        ReconciliationRecommendation(
          action: 'Complete reconciliation review',
          description: 'Reconciliation requires manual review',
          priority: Priority.high,
          expectedImpact: 'Finalize reconciliation',
          requiredResources: ['Manager approval'],
        ),
      );
    }

    return recommendations;
  }

  DiscrepancySeverity _determineSeverity(double amount) {
    if (amount >= 10000) return DiscrepancySeverity.critical;
    if (amount >= 1000) return DiscrepancySeverity.high;
    if (amount >= 100) return DiscrepancySeverity.medium;
    if (amount >= 10) return DiscrepancySeverity.low;
    return DiscrepancySeverity.low;
  }
}

/// Analysis result for reconciliation discrepancies
class ReconciliationAnalysis {
  final String reconciliationId;
  final double totalExpected;
  final double totalActual;
  final double totalDiscrepancy;
  final double discrepancyPercentage;
  final int totalTransactions;
  final int matchedTransactions;
  final int unmatchedTransactions;
  final int partialMatchTransactions;
  final ReconciliationStatus status;
  final DateTime reconciliationDate;
  final DateTime periodStart;
  final DateTime periodEnd;
  final List<AmountDiscrepancy> amountDiscrepancies;
  final List<DateDiscrepancy> dateDiscrepancies;
  final List<MissingTransaction> missingTransactions;
  final List<DuplicateTransaction> duplicateTransactions;
  final List<ReconciliationRecommendation> recommendations;

  const ReconciliationAnalysis({
    required this.reconciliationId,
    required this.totalExpected,
    required this.totalActual,
    required this.totalDiscrepancy,
    required this.discrepancyPercentage,
    required this.totalTransactions,
    required this.matchedTransactions,
    required this.unmatchedTransactions,
    required this.partialMatchTransactions,
    required this.status,
    required this.reconciliationDate,
    required this.periodStart,
    required this.periodEnd,
    required this.amountDiscrepancies,
    required this.dateDiscrepancies,
    required this.missingTransactions,
    required this.duplicateTransactions,
    required this.recommendations,
  });

  Map<String, dynamic> toJson() => {
    'reconciliationId': reconciliationId,
    'totalExpected': totalExpected,
    'totalActual': totalActual,
    'totalDiscrepancy': totalDiscrepancy,
    'discrepancyPercentage': discrepancyPercentage,
    'totalTransactions': totalTransactions,
    'matchedTransactions': matchedTransactions,
    'unmatchedTransactions': unmatchedTransactions,
    'partialMatchTransactions': partialMatchTransactions,
    'status': status.toString(),
    'reconciliationDate': reconciliationDate.toIso8601String(),
    'periodStart': periodStart.toIso8601String(),
    'periodEnd': periodEnd.toIso8601String(),
    'amountDiscrepancies': amountDiscrepancies.map((a) => a.toJson()).toList(),
    'dateDiscrepancies': dateDiscrepancies.map((d) => d.toJson()).toList(),
    'missingTransactions': missingTransactions.map((m) => m.toJson()).toList(),
    'duplicateTransactions': duplicateTransactions
        .map((d) => d.toJson())
        .toList(),
    'recommendations': recommendations.map((r) => r.toJson()).toList(),
  };
}

/// Amount discrepancy analysis
class AmountDiscrepancy {
  final DiscrepancyType type;
  final int count;
  final double totalAmount;
  final double averageAmount;
  final DiscrepancySeverity severity;

  const AmountDiscrepancy({
    required this.type,
    required this.count,
    required this.totalAmount,
    required this.averageAmount,
    required this.severity,
  });

  Map<String, dynamic> toJson() => {
    'type': type.toString(),
    'count': count,
    'totalAmount': totalAmount,
    'averageAmount': averageAmount,
    'severity': severity.toString(),
  };
}

/// Date discrepancy analysis
class DateDiscrepancy {
  final int count;
  final int averageDaysDifference;
  final DiscrepancySeverity severity;

  const DateDiscrepancy({
    required this.count,
    required this.averageDaysDifference,
    required this.severity,
  });

  Map<String, dynamic> toJson() => {
    'count': count,
    'averageDaysDifference': averageDaysDifference,
    'severity': severity.toString(),
  };
}

/// Missing transaction analysis
class MissingTransaction {
  final String expectedReference;
  final double expectedAmount;
  final DateTime expectedDate;
  final String reason;

  const MissingTransaction({
    required this.expectedReference,
    required this.expectedAmount,
    required this.expectedDate,
    required this.reason,
  });

  Map<String, dynamic> toJson() => {
    'expectedReference': expectedReference,
    'expectedAmount': expectedAmount,
    'expectedDate': expectedDate.toIso8601String(),
    'reason': reason,
  };
}

/// Duplicate transaction analysis
class DuplicateTransaction {
  final String transactionReference;
  final int duplicateCount;
  final double totalAmount;
  final List<DateTime> transactionDates;

  const DuplicateTransaction({
    required this.transactionReference,
    required this.duplicateCount,
    required this.totalAmount,
    required this.transactionDates,
  });

  Map<String, dynamic> toJson() => {
    'transactionReference': transactionReference,
    'duplicateCount': duplicateCount,
    'totalAmount': totalAmount,
    'transactionDates': transactionDates
        .map((d) => d.toIso8601String())
        .toList(),
  };
}

/// Reconciliation recommendation
class ReconciliationRecommendation {
  final String action;
  final String description;
  final Priority priority;
  final String expectedImpact;
  final List<String> requiredResources;

  const ReconciliationRecommendation({
    required this.action,
    required this.description,
    required this.priority,
    required this.expectedImpact,
    required this.requiredResources,
  });

  Map<String, dynamic> toJson() => {
    'action': action,
    'description': description,
    'priority': priority.toString(),
    'expectedImpact': expectedImpact,
    'requiredResources': requiredResources,
  };
}

enum Priority { low, medium, high }

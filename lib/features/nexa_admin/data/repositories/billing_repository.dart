import 'dart:async';
import 'package:nexatrace_system/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:nexatrace_system/features/nexa_admin/data/datasources/billing_datasource.dart';
import 'package:nexatrace_system/features/nexa_admin/data/models/invoice_model.dart';
import 'package:nexatrace_system/features/nexa_admin/data/models/credit_note_model.dart';
import 'package:nexatrace_system/features/nexa_admin/data/models/payment_reconciliation_model.dart';
import 'package:nexatrace_system/features/nexa_admin/data/models/revenue_report_model.dart';
import 'package:nexatrace_system/shared/models/billing/invoice_model.dart'
    as shared;
import 'package:nexatrace_system/shared/models/company/company_model.dart';

abstract class BillingRepository {
  // Platform invoices
  Future<Either<Failure, List<AdminInvoice>>> getPlatformInvoices({
    DateTime? startDate,
    DateTime? endDate,
    List<shared.InvoiceStatus>? statuses,
    String? searchQuery,
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, AdminInvoice>> getInvoiceById(String invoiceId);

  Future<Either<Failure, List<AdminInvoice>>> getCompanyInvoices(
    String companyId, {
    DateTime? startDate,
    DateTime? endDate,
    List<shared.InvoiceStatus>? statuses,
    int page = 1,
    int limit = 20,
  });

  // Invoice management
  Future<Either<Failure, AdminInvoice>> generateInvoice({
    required String companyId,
    required String subscriptionId,
    required DateTime periodStart,
    required DateTime periodEnd,
    required List<shared.InvoiceItem> items,
    String? notes,
  });

  Future<Either<Failure, AdminInvoice>> updateInvoiceStatus(
    String invoiceId,
    shared.InvoiceStatus status,
  );

  Future<Either<Failure, Unit>> sendInvoiceNotification(String invoiceId);

  // Payments
  Future<Either<Failure, List<shared.Payment>>> getInvoicePayments(
    String invoiceId,
  );

  Future<Either<Failure, shared.Payment>> recordPayment({
    required String invoiceId,
    required double amount,
    required shared.PaymentMethod method,
    required DateTime paymentDate,
    String? reference,
    String? transactionId,
    String? notes,
  });

  // Company billing
  Future<Either<Failure, List<Company>>> getCompaniesWithOverdueInvoices();

  Future<Either<Failure, PlatformRevenueSummary>> getPlatformRevenueSummary({
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Either<Failure, List<CompanyRevenueSummary>>> getRevenueByCompany({
    DateTime? startDate,
    DateTime? endDate,
  });

  // Credit notes
  Future<Either<Failure, CreditNote>> createCreditNote({
    required String invoiceId,
    required double amount,
    required CreditNoteReason reason,
    String? notes,
  });

  Future<Either<Failure, List<CreditNote>>> getCreditNotes({
    DateTime? startDate,
    DateTime? endDate,
    String? companyId,
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, CreditNoteSummary>> getCreditNoteSummary({
    DateTime? startDate,
    DateTime? endDate,
  });

  // Payment reconciliation
  Future<Either<Failure, PaymentReconciliation>> startReconciliation({
    required DateTime reconciliationDate,
    required DateTime periodStart,
    required DateTime periodEnd,
    String? notes,
  });

  Future<Either<Failure, PaymentReconciliation>> getReconciliationById(
    String reconciliationId,
  );

  Future<Either<Failure, List<PaymentReconciliation>>> getReconciliations({
    DateTime? startDate,
    DateTime? endDate,
    List<ReconciliationStatus>? statuses,
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, ReconciliationSummary>> getReconciliationSummary({
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Either<Failure, Unit>> processReconciliation(String reconciliationId);

  // Revenue reports
  Future<Either<Failure, RevenueReport>> generateRevenueReport({
    required ReportType type,
    required DateTime periodStart,
    required DateTime periodEnd,
    String? reportName,
    String? notes,
  });

  Future<Either<Failure, RevenueReport>> getRevenueReportById(String reportId);

  Future<Either<Failure, List<RevenueReport>>> getRevenueReports({
    DateTime? startDate,
    DateTime? endDate,
    List<ReportType>? types,
    List<ReportStatus>? statuses,
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, RevenueAnalysis>> analyzeRevenue({
    required AnalysisPeriod period,
    required DateTime analysisDate,
  });

  Future<Either<Failure, RevenueForecast>> forecastRevenue({
    required ForecastMethod method,
    required int forecastPeriods,
    DateTime? startDate,
  });

  // Financial operations
  Future<Either<Failure, Unit>> reconcilePayments(DateTime reconciliationDate);

  Future<Either<Failure, Map<String, dynamic>>> getFinancialDashboardData({
    DateTime? startDate,
    DateTime? endDate,
  });

  // Export operations
  Future<Either<Failure, String>> exportInvoices({
    DateTime? startDate,
    DateTime? endDate,
    List<shared.InvoiceStatus>? statuses,
    String format = 'csv',
  });

  Future<Either<Failure, String>> exportRevenueReport(
    String reportId,
    String format,
  );
}

class BillingRepositoryImpl implements BillingRepository {
  final BillingDataSource dataSource;

  BillingRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<AdminInvoice>>> getPlatformInvoices({
    DateTime? startDate,
    DateTime? endDate,
    List<shared.InvoiceStatus>? statuses,
    String? searchQuery,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final invoices = await dataSource.getPlatformInvoices(
        startDate: startDate,
        endDate: endDate,
        statuses: statuses,
        searchQuery: searchQuery,
        page: page,
        limit: limit,
      );
      return Right(invoices.cast<AdminInvoice>());
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, AdminInvoice>> getInvoiceById(String invoiceId) async {
    try {
      final invoice = await dataSource.getInvoiceById(invoiceId);
      return Right(invoice);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<AdminInvoice>>> getCompanyInvoices(
    String companyId, {
    DateTime? startDate,
    DateTime? endDate,
    List<shared.InvoiceStatus>? statuses,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final invoices = await dataSource.getCompanyInvoices(
        companyId,
        startDate: startDate,
        endDate: endDate,
        statuses: statuses,
        page: page,
        limit: limit,
      );
      return Right(invoices.cast<AdminInvoice>());
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, AdminInvoice>> generateInvoice({
    required String companyId,
    required String subscriptionId,
    required DateTime periodStart,
    required DateTime periodEnd,
    required List<shared.InvoiceItem> items,
    String? notes,
  }) async {
    try {
      final invoice = await dataSource.generateInvoice(
        companyId: companyId,
        subscriptionId: subscriptionId,
        periodStart: periodStart,
        periodEnd: periodEnd,
        items: items,
        notes: notes,
      );
      return Right(invoice);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, AdminInvoice>> updateInvoiceStatus(
    String invoiceId,
    shared.InvoiceStatus status,
  ) async {
    try {
      final invoice = await dataSource.updateInvoiceStatus(invoiceId, status);
      return Right(invoice);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> sendInvoiceNotification(
    String invoiceId,
  ) async {
    try {
      await dataSource.sendInvoiceNotification(invoiceId);
      return const Right(unit);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<shared.Payment>>> getInvoicePayments(
    String invoiceId,
  ) async {
    try {
      final payments = await dataSource.getInvoicePayments(invoiceId);
      return Right(payments);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, shared.Payment>> recordPayment({
    required String invoiceId,
    required double amount,
    required shared.PaymentMethod method,
    required DateTime paymentDate,
    String? reference,
    String? transactionId,
    String? notes,
  }) async {
    try {
      final payment = await dataSource.recordPayment(
        invoiceId: invoiceId,
        amount: amount,
        method: method,
        paymentDate: paymentDate,
        reference: reference,
        transactionId: transactionId,
        notes: notes,
      );
      return Right(payment);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<Company>>>
  getCompaniesWithOverdueInvoices() async {
    try {
      final companies = await dataSource.getCompaniesWithOverdueInvoices();
      return Right(companies);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, PlatformRevenueSummary>> getPlatformRevenueSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final data = await dataSource.getPlatformRevenueSummary(
        startDate: startDate,
        endDate: endDate,
      );
      // Convert map data to PlatformRevenueSummary
      final summary = PlatformRevenueSummary.fromJson(data);
      return Right(summary);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<CompanyRevenueSummary>>> getRevenueByCompany({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final data = await dataSource.getRevenueByCompany(
        startDate: startDate,
        endDate: endDate,
      );
      final summaries = data
          .map((item) => CompanyRevenueSummary.fromJson(item))
          .toList();
      return Right(summaries);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, CreditNote>> createCreditNote({
    required String invoiceId,
    required double amount,
    required CreditNoteReason reason,
    String? notes,
  }) async {
    try {
      final creditNote = await dataSource.createCreditNote(
        invoiceId: invoiceId,
        amount: amount,
        reason: reason.toString().split('.').last,
        notes: notes,
      );
      return Right(creditNote);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<CreditNote>>> getCreditNotes({
    DateTime? startDate,
    DateTime? endDate,
    String? companyId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final creditNotes = await dataSource.getCreditNotes(
        startDate: startDate,
        endDate: endDate,
        companyId: companyId,
        page: page,
        limit: limit,
      );
      return Right(creditNotes);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, CreditNoteSummary>> getCreditNoteSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // This would typically call a dedicated endpoint
      // For now, we'll get all credit notes and summarize
      final creditNotes = await dataSource.getCreditNotes(
        startDate: startDate,
        endDate: endDate,
      );

      final summary = CreditNoteSummary(
        totalIssued: creditNotes.fold(0.0, (sum, note) => sum + note.amount),
        totalApplied: creditNotes
            .where((note) => note.status == CreditNoteStatus.applied)
            .fold(0.0, (sum, note) => sum + note.amount),
        totalUnused: creditNotes
            .where((note) => note.status == CreditNoteStatus.issued)
            .fold(0.0, (sum, note) => sum + note.amount),
        totalCancelled: creditNotes
            .where((note) => note.status == CreditNoteStatus.cancelled)
            .fold(0.0, (sum, note) => sum + note.amount),
        totalCount: creditNotes.length,
        issuedCount: creditNotes
            .where((note) => note.status == CreditNoteStatus.issued)
            .length,
        appliedCount: creditNotes
            .where((note) => note.status == CreditNoteStatus.applied)
            .length,
        unusedCount: creditNotes
            .where((note) => note.status == CreditNoteStatus.issued)
            .length,
        cancelledCount: creditNotes
            .where((note) => note.status == CreditNoteStatus.cancelled)
            .length,
        periodStart: startDate,
        periodEnd: endDate,
      );

      return Right(summary);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, PaymentReconciliation>> startReconciliation({
    required DateTime reconciliationDate,
    required DateTime periodStart,
    required DateTime periodEnd,
    String? notes,
  }) async {
    try {
      // This would typically call a dedicated endpoint
      // For now, return a mock reconciliation
      final reconciliation = PaymentReconciliation.empty();
      return Right(reconciliation);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, PaymentReconciliation>> getReconciliationById(
    String reconciliationId,
  ) async {
    try {
      // This would typically call a dedicated endpoint
      // For now, return a mock reconciliation
      final reconciliation = PaymentReconciliation.empty();
      return Right(reconciliation);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<PaymentReconciliation>>> getReconciliations({
    DateTime? startDate,
    DateTime? endDate,
    List<ReconciliationStatus>? statuses,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // This would typically call a dedicated endpoint
      // For now, return empty list
      return const Right([]);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, ReconciliationSummary>> getReconciliationSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // This would typically call a dedicated endpoint
      // For now, return empty summary
      final summary = ReconciliationSummary();
      return Right(summary);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> processReconciliation(
    String reconciliationId,
  ) async {
    try {
      // This would typically call a dedicated endpoint
      return const Right(unit);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, RevenueReport>> generateRevenueReport({
    required ReportType type,
    required DateTime periodStart,
    required DateTime periodEnd,
    String? reportName,
    String? notes,
  }) async {
    try {
      // This would typically call a dedicated endpoint
      // For now, return a mock report
      final report = RevenueReport.empty();
      return Right(report);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, RevenueReport>> getRevenueReportById(
    String reportId,
  ) async {
    try {
      // This would typically call a dedicated endpoint
      // For now, return a mock report
      final report = RevenueReport.empty();
      return Right(report);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<RevenueReport>>> getRevenueReports({
    DateTime? startDate,
    DateTime? endDate,
    List<ReportType>? types,
    List<ReportStatus>? statuses,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // This would typically call a dedicated endpoint
      // For now, return empty list
      return const Right([]);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, RevenueAnalysis>> analyzeRevenue({
    required AnalysisPeriod period,
    required DateTime analysisDate,
  }) async {
    try {
      // This would typically call a dedicated endpoint
      // For now, return empty analysis
      final analysis = RevenueAnalysis(
        analysisDate: analysisDate,
        period: period,
        totalRevenue: 0.0,
        revenueGrowth: 0.0,
        revenueGrowthRate: 0.0,
        collectionRate: 0.0,
        churnRate: 0.0,
        expansionRate: 0.0,
        netRevenueRetention: 0.0,
        grossRevenueRetention: 0.0,
        monthlyRecurringRevenue: 0.0,
        annualRecurringRevenue: 0.0,
        averageRevenuePerUser: 0.0,
        lifetimeValue: 0.0,
        customerAcquisitionCost: 0.0,
      );
      return Right(analysis);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, RevenueForecast>> forecastRevenue({
    required ForecastMethod method,
    required int forecastPeriods,
    DateTime? startDate,
  }) async {
    try {
      // This would typically call a dedicated endpoint
      // For now, return a mock forecast
      final forecast = RevenueForecast(
        forecastDate: startDate ?? DateTime.now(),
        method: method,
        forecastedRevenue: 0.0,
        lowerBound: 0.0,
        upperBound: 0.0,
        confidenceLevel: 0.0,
      );
      return Right(forecast);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> reconcilePayments(
    DateTime reconciliationDate,
  ) async {
    try {
      await dataSource.reconcilePayments(reconciliationDate);
      return const Right(unit);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getFinancialDashboardData({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Get multiple data sources for dashboard
      final revenueSummary = await dataSource.getPlatformRevenueSummary(
        startDate: startDate,
        endDate: endDate,
      );

      final companiesOverdue = await dataSource
          .getCompaniesWithOverdueInvoices();

      final revenueByCompany = await dataSource.getRevenueByCompany(
        startDate: startDate,
        endDate: endDate,
      );

      final platformInvoices = await dataSource.getPlatformInvoices(
        startDate: startDate,
        endDate: endDate,
        limit: 10,
      );

      return Right({
        'revenue_summary': revenueSummary,
        'companies_overdue': companiesOverdue.length,
        'revenue_by_company': revenueByCompany,
        'recent_invoices': platformInvoices,
        'dashboard_updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, String>> exportInvoices({
    DateTime? startDate,
    DateTime? endDate,
    List<shared.InvoiceStatus>? statuses,
    String format = 'csv',
  }) async {
    try {
      // This would typically call a dedicated export endpoint
      // For now, return a mock export URL
      return Right(
        'https://api.example.com/exports/invoices_${DateTime.now().millisecondsSinceEpoch}.$format',
      );
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, String>> exportRevenueReport(
    String reportId,
    String format,
  ) async {
    try {
      // This would typically call a dedicated export endpoint
      // For now, return a mock export URL
      return Right(
        'https://api.example.com/exports/report_${reportId}_${DateTime.now().millisecondsSinceEpoch}.$format',
      );
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  // Helper method to convert exceptions to failures
  Failure _handleError(dynamic error) {
    if (error is ServerException) {
      return ServerFailure(
        message: error.message,
        statusCode: error.statusCode,
      );
    } else if (error is NetworkException) {
      return NetworkFailure(message: error.message);
    } else if (error is UnauthorizedException) {
      return UnauthorizedFailure(message: error.message);
    } else {
      return UnexpectedFailure(message: error.toString(), originalError: error);
    }
  }
}

//lib/features/nexa_admin/presentation/bloc/billing/billing_bloc.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:nexatrace_system/core/errors/failures.dart';
import 'package:nexatrace_system/features/nexa_admin/domain/usecases/generate_invoice_usecase.dart';
import 'package:nexatrace_system/features/nexa_admin/domain/usecases/process_payment_usecase.dart';
import 'package:nexatrace_system/features/nexa_admin/domain/usecases/reconcile_payments_usecase.dart';
import 'package:nexatrace_system/features/nexa_admin/data/repositories/billing_repository.dart';

import 'billing_event.dart';
import 'billing_state.dart';
export 'billing_event.dart';
export 'billing_state.dart';

/// Bloc for managing billing operations in the super admin panel
class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final GenerateInvoiceUseCase _generateInvoiceUseCase;
  final ProcessPaymentUseCase _processPaymentUseCase;
  final ReconcilePaymentsUseCase _reconcilePaymentsUseCase;
  final BillingRepository _billingRepository;

  BillingBloc({
    required GenerateInvoiceUseCase generateInvoiceUseCase,
    required ProcessPaymentUseCase processPaymentUseCase,
    required ReconcilePaymentsUseCase reconcilePaymentsUseCase,
    required BillingRepository billingRepository,
  }) : _generateInvoiceUseCase = generateInvoiceUseCase,
       _processPaymentUseCase = processPaymentUseCase,
       _reconcilePaymentsUseCase = reconcilePaymentsUseCase,
       _billingRepository = billingRepository,
       super(const BillingState.initial()) {
    on<LoadPlatformInvoices>(_onLoadPlatformInvoices);
    on<LoadCompanyInvoices>(_onLoadCompanyInvoices);
    on<GenerateInvoice>(_onGenerateInvoice);
    on<GenerateBulkInvoices>(_onGenerateBulkInvoices);
    on<ProcessPayment>(_onProcessPayment);
    on<ProcessPartialPayment>(_onProcessPartialPayment);
    on<ProcessBulkPayments>(_onProcessBulkPayments);
    on<ReconcilePayments>(_onReconcilePayments);
    on<AnalyzeReconciliation>(_onAnalyzeReconciliation);
    on<GenerateRevenueReport>(_onGenerateRevenueReport);
    on<GetFinancialDashboardData>(_onGetFinancialDashboardData);
    on<ExportInvoices>(_onExportInvoices);
    on<ExportRevenueReport>(_onExportRevenueReport);
    on<UpdateInvoiceStatus>(_onUpdateInvoiceStatus);
    on<SendInvoiceNotification>(_onSendInvoiceNotification);
    on<CreateCreditNote>(_onCreateCreditNote);
    on<GetCreditNotes>(_onGetCreditNotes);
    on<GetCompaniesWithOverdueInvoices>(_onGetCompaniesWithOverdueInvoices);
    on<GetPlatformRevenueSummary>(_onGetPlatformRevenueSummary);
    on<GetRevenueByCompany>(_onGetRevenueByCompany);
    on<ResetBillingState>(_onResetBillingState);
  }

  /// Handles loading platform invoices
  Future<void> _onLoadPlatformInvoices(
    LoadPlatformInvoices event,
    Emitter<BillingState> emit,
  ) async {
    emit(const BillingState.loading());

    try {
      final result = await _billingRepository.getPlatformInvoices(
        startDate: event.startDate,
        endDate: event.endDate,
        statuses: event.statuses,
        searchQuery: event.searchQuery,
        page: event.page,
        limit: event.limit,
      );

      result.fold(
        (failure) {
          emit(BillingState.error(message: failure.message, error: failure));
        },
        (invoices) {
          emit(
            BillingState.platformInvoicesLoaded(
              invoices: invoices,
              hasMore: invoices.length == event.limit,
              currentPage: event.page,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        BillingState.error(
          message: 'Failed to load platform invoices: ${e.toString()}',
          error: UnknownFailure(e.toString()),
        ),
      );
    }
  }

  /// Handles loading company invoices
  Future<void> _onLoadCompanyInvoices(
    LoadCompanyInvoices event,
    Emitter<BillingState> emit,
  ) async {
    emit(const BillingState.loading());

    try {
      final result = await _billingRepository.getCompanyInvoices(
        event.companyId,
        startDate: event.startDate,
        endDate: event.endDate,
        statuses: event.statuses,
        page: event.page,
        limit: event.limit,
      );

      result.fold(
        (failure) {
          emit(BillingState.error(message: failure.message, error: failure));
        },
        (invoices) {
          emit(
            BillingState.companyInvoicesLoaded(
              companyId: event.companyId,
              invoices: invoices,
              hasMore: invoices.length == event.limit,
              currentPage: event.page,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        BillingState.error(
          message: 'Failed to load company invoices: ${e.toString()}',
          error: UnknownFailure(e.toString()),
        ),
      );
    }
  }

  /// Handles generating a single invoice
  Future<void> _onGenerateInvoice(
    GenerateInvoice event,
    Emitter<BillingState> emit,
  ) async {
    emit(const BillingState.processing());

    final params = GenerateInvoiceParams(
      companyId: event.companyId,
      subscriptionId: event.subscriptionId,
      periodStart: event.periodStart,
      periodEnd: event.periodEnd,
      items: event.items,
      notes: event.notes,
      sendNotification: event.sendNotification,
    );

    final result = await _generateInvoiceUseCase.call(params);

    result.fold(
      (failure) {
        emit(BillingState.error(message: failure.message, error: failure));
      },
      (invoice) {
        emit(
          BillingState.invoiceGenerated(
            invoice: invoice,
            message: 'Invoice generated successfully',
          ),
        );
      },
    );
  }

  /// Handles generating bulk invoices
  Future<void> _onGenerateBulkInvoices(
    GenerateBulkInvoices event,
    Emitter<BillingState> emit,
  ) async {
    emit(const BillingState.processing());

    final paramsList = event.paramsList;
    final useCase = GenerateBulkInvoicesUseCase(_billingRepository);
    final result = await useCase.call(paramsList);

    result.fold(
      (failure) {
        emit(BillingState.error(message: failure.message, error: failure));
      },
      (invoices) {
        emit(
          BillingState.bulkInvoicesGenerated(
            invoices: invoices,
            message: 'Generated ${invoices.length} invoices successfully',
            failedCount: paramsList.length - invoices.length,
          ),
        );
      },
    );
  }

  /// Handles processing a payment
  Future<void> _onProcessPayment(
    ProcessPayment event,
    Emitter<BillingState> emit,
  ) async {
    emit(const BillingState.processing());

    final params = ProcessPaymentParams(
      invoiceId: event.invoiceId,
      amount: event.amount,
      method: event.method,
      paymentDate: event.paymentDate,
      reference: event.reference,
      transactionId: event.transactionId,
      notes: event.notes,
      sendNotification: event.sendNotification,
    );

    final result = await _processPaymentUseCase.call(params);

    result.fold(
      (failure) {
        emit(BillingState.error(message: failure.message, error: failure));
      },
      (payment) {
        emit(
          BillingState.paymentProcessed(
            payment: payment,
            message: 'Payment processed successfully',
          ),
        );
      },
    );
  }

  /// Handles processing a partial payment
  Future<void> _onProcessPartialPayment(
    ProcessPartialPayment event,
    Emitter<BillingState> emit,
  ) async {
    emit(const BillingState.processing());

    final params = ProcessPaymentParams(
      invoiceId: event.invoiceId,
      amount: event.amount,
      method: event.method,
      paymentDate: event.paymentDate,
      reference: event.reference,
      transactionId: event.transactionId,
      notes: event.notes,
      sendNotification: event.sendNotification,
    );

    final useCase = ProcessPartialPaymentUseCase(_billingRepository);
    final result = await useCase.call(params);

    result.fold(
      (failure) {
        emit(BillingState.error(message: failure.message, error: failure));
      },
      (payment) {
        emit(
          BillingState.partialPaymentProcessed(
            payment: payment,
            message: 'Partial payment processed successfully',
          ),
        );
      },
    );
  }

  /// Handles processing bulk payments
  Future<void> _onProcessBulkPayments(
    ProcessBulkPayments event,
    Emitter<BillingState> emit,
  ) async {
    emit(const BillingState.processing());

    final paramsList = event.paramsList;
    final useCase = ProcessBulkPaymentsUseCase(_billingRepository);
    final result = await useCase.call(paramsList);

    result.fold(
      (failure) {
        emit(BillingState.error(message: failure.message, error: failure));
      },
      (payments) {
        emit(
          BillingState.bulkPaymentsProcessed(
            payments: payments,
            message: 'Processed ${payments.length} payments successfully',
            failedCount: paramsList.length - payments.length,
          ),
        );
      },
    );
  }

  /// Handles payment reconciliation
  Future<void> _onReconcilePayments(
    ReconcilePayments event,
    Emitter<BillingState> emit,
  ) async {
    emit(const BillingState.processing());

    final params = ReconcilePaymentsParams(
      reconciliationDate: event.reconciliationDate,
      periodStart: event.periodStart,
      periodEnd: event.periodEnd,
      notes: event.notes,
      autoMatchTransactions: event.autoMatchTransactions,
      matchTolerance: event.matchTolerance,
    );

    final result = await _reconcilePaymentsUseCase.call(params);

    result.fold(
      (failure) {
        emit(BillingState.error(message: failure.message, error: failure));
      },
      (reconciliation) {
        emit(
          BillingState.paymentsReconciled(
            reconciliation: reconciliation,
            message: 'Payments reconciled successfully',
          ),
        );
      },
    );
  }

  /// Handles reconciliation analysis
  Future<void> _onAnalyzeReconciliation(
    AnalyzeReconciliation event,
    Emitter<BillingState> emit,
  ) async {
    emit(const BillingState.processing());

    final useCase = AnalyzeReconciliationDiscrepanciesUseCase(
      _billingRepository,
    );
    final result = await useCase.call(event.reconciliationId);

    result.fold(
      (failure) {
        emit(BillingState.error(message: failure.message, error: failure));
      },
      (analysis) {
        emit(
          BillingState.reconciliationAnalyzed(
            analysis: analysis,
            message: 'Reconciliation analysis completed',
          ),
        );
      },
    );
  }

  /// Handles generating revenue reports
  Future<void> _onGenerateRevenueReport(
    GenerateRevenueReport event,
    Emitter<BillingState> emit,
  ) async {
    emit(const BillingState.processing());

    try {
      final result = await _billingRepository.generateRevenueReport(
        type: event.type,
        periodStart: event.periodStart,
        periodEnd: event.periodEnd,
        reportName: event.reportName,
        notes: event.notes,
      );

      result.fold(
        (failure) {
          emit(BillingState.error(message: failure.message, error: failure));
        },
        (report) {
          emit(
            BillingState.revenueReportGenerated(
              report: report,
              message: 'Revenue report generated successfully',
            ),
          );
        },
      );
    } catch (e) {
      emit(
        BillingState.error(
          message: 'Failed to generate revenue report: ${e.toString()}',
          error: UnknownFailure(e.toString()),
        ),
      );
    }
  }

  /// Handles getting financial dashboard data
  Future<void> _onGetFinancialDashboardData(
    GetFinancialDashboardData event,
    Emitter<BillingState> emit,
  ) async {
    emit(const BillingState.loading());

    try {
      final result = await _billingRepository.getFinancialDashboardData(
        startDate: event.startDate,
        endDate: event.endDate,
      );

      result.fold(
        (failure) {
          emit(BillingState.error(message: failure.message, error: failure));
        },
        (dashboardData) {
          emit(
            BillingState.financialDashboardLoaded(
              dashboardData: dashboardData,
              message: 'Dashboard data loaded successfully',
            ),
          );
        },
      );
    } catch (e) {
      emit(
        BillingState.error(
          message: 'Failed to load financial dashboard: ${e.toString()}',
          error: UnknownFailure(e.toString()),
        ),
      );
    }
  }

  /// Handles exporting invoices
  Future<void> _onExportInvoices(
    ExportInvoices event,
    Emitter<BillingState> emit,
  ) async {
    emit(const BillingState.processing());

    try {
      final result = await _billingRepository.exportInvoices(
        startDate: event.startDate,
        endDate: event.endDate,
        statuses: event.statuses,
        format: event.format,
      );

      result.fold(
        (failure) {
          emit(BillingState.error(message: failure.message, error: failure));
        },
        (exportUrl) {
          emit(
            BillingState.invoicesExported(
              exportUrl: exportUrl,
              message: 'Invoices exported successfully',
            ),
          );
        },
      );
    } catch (e) {
      emit(
        BillingState.error(
          message: 'Failed to export invoices: ${e.toString()}',
          error: UnknownFailure(e.toString()),
        ),
      );
    }
  }

  /// Handles exporting revenue reports
  Future<void> _onExportRevenueReport(
    ExportRevenueReport event,
    Emitter<BillingState> emit,
  ) async {
    emit(const BillingState.processing());

    try {
      final result = await _billingRepository.exportRevenueReport(
        event.reportId,
        event.format,
      );

      result.fold(
        (failure) {
          emit(BillingState.error(message: failure.message, error: failure));
        },
        (exportUrl) {
          emit(
            BillingState.revenueReportExported(
              exportUrl: exportUrl,
              message: 'Revenue report exported successfully',
            ),
          );
        },
      );
    } catch (e) {
      emit(
        BillingState.error(
          message: 'Failed to export revenue report: ${e.toString()}',
          error: UnknownFailure(e.toString()),
        ),
      );
    }
  }

  /// Handles updating invoice status
  Future<void> _onUpdateInvoiceStatus(
    UpdateInvoiceStatus event,
    Emitter<BillingState> emit,
  ) async {
    emit(const BillingState.processing());

    try {
      final result = await _billingRepository.updateInvoiceStatus(
        event.invoiceId,
        event.status,
      );

      result.fold(
        (failure) {
          emit(BillingState.error(message: failure.message, error: failure));
        },
        (invoice) {
          emit(
            BillingState.invoiceStatusUpdated(
              invoice: invoice,
              message: 'Invoice status updated successfully',
            ),
          );
        },
      );
    } catch (e) {
      emit(
        BillingState.error(
          message: 'Failed to update invoice status: ${e.toString()}',
          error: UnknownFailure(e.toString()),
        ),
      );
    }
  }

  /// Handles sending invoice notifications
  Future<void> _onSendInvoiceNotification(
    SendInvoiceNotification event,
    Emitter<BillingState> emit,
  ) async {
    emit(const BillingState.processing());

    try {
      final result = await _billingRepository.sendInvoiceNotification(
        event.invoiceId,
      );

      result.fold(
        (failure) {
          emit(BillingState.error(message: failure.message, error: failure));
        },
        (_) {
          emit(
            const BillingState.success(
              message: 'Invoice notification sent successfully',
            ),
          );
        },
      );
    } catch (e) {
      emit(
        BillingState.error(
          message: 'Failed to send invoice notification: ${e.toString()}',
          error: UnknownFailure(e.toString()),
        ),
      );
    }
  }

  /// Handles creating credit notes
  Future<void> _onCreateCreditNote(
    CreateCreditNote event,
    Emitter<BillingState> emit,
  ) async {
    emit(const BillingState.processing());

    try {
      final result = await _billingRepository.createCreditNote(
        invoiceId: event.invoiceId,
        amount: event.amount,
        reason: event.reason,
        notes: event.notes,
      );

      result.fold(
        (failure) {
          emit(BillingState.error(message: failure.message, error: failure));
        },
        (creditNote) {
          emit(
            BillingState.creditNoteCreated(
              creditNote: creditNote,
              message: 'Credit note created successfully',
            ),
          );
        },
      );
    } catch (e) {
      emit(
        BillingState.error(
          message: 'Failed to create credit note: ${e.toString()}',
          error: UnknownFailure(e.toString()),
        ),
      );
    }
  }

  /// Handles getting credit notes
  Future<void> _onGetCreditNotes(
    GetCreditNotes event,
    Emitter<BillingState> emit,
  ) async {
    emit(const BillingState.loading());

    try {
      final result = await _billingRepository.getCreditNotes(
        startDate: event.startDate,
        endDate: event.endDate,
        companyId: event.companyId,
        page: event.page,
        limit: event.limit,
      );

      result.fold(
        (failure) {
          emit(BillingState.error(message: failure.message, error: failure));
        },
        (creditNotes) {
          emit(
            BillingState.creditNotesLoaded(
              creditNotes: creditNotes,
              hasMore: creditNotes.length == event.limit,
              currentPage: event.page,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        BillingState.error(
          message: 'Failed to load credit notes: ${e.toString()}',
          error: UnknownFailure(e.toString()),
        ),
      );
    }
  }

  /// Handles getting companies with overdue invoices
  Future<void> _onGetCompaniesWithOverdueInvoices(
    GetCompaniesWithOverdueInvoices event,
    Emitter<BillingState> emit,
  ) async {
    emit(const BillingState.loading());

    try {
      final result = await _billingRepository.getCompaniesWithOverdueInvoices();

      result.fold(
        (failure) {
          emit(BillingState.error(message: failure.message, error: failure));
        },
        (companies) {
          emit(
            BillingState.companiesWithOverdueLoaded(
              companies: companies,
              message:
                  'Loaded ${companies.length} companies with overdue invoices',
            ),
          );
        },
      );
    } catch (e) {
      emit(
        BillingState.error(
          message:
              'Failed to load companies with overdue invoices: ${e.toString()}',
          error: UnknownFailure(e.toString()),
        ),
      );
    }
  }

  /// Handles getting platform revenue summary
  Future<void> _onGetPlatformRevenueSummary(
    GetPlatformRevenueSummary event,
    Emitter<BillingState> emit,
  ) async {
    emit(const BillingState.loading());

    try {
      final result = await _billingRepository.getPlatformRevenueSummary(
        startDate: event.startDate,
        endDate: event.endDate,
      );

      result.fold(
        (failure) {
          emit(BillingState.error(message: failure.message, error: failure));
        },
        (revenueSummary) {
          emit(
            BillingState.platformRevenueSummaryLoaded(
              revenueSummary: revenueSummary,
              message: 'Revenue summary loaded successfully',
            ),
          );
        },
      );
    } catch (e) {
      emit(
        BillingState.error(
          message: 'Failed to load platform revenue summary: ${e.toString()}',
          error: UnknownFailure(e.toString()),
        ),
      );
    }
  }

  /// Handles getting revenue by company
  Future<void> _onGetRevenueByCompany(
    GetRevenueByCompany event,
    Emitter<BillingState> emit,
  ) async {
    emit(const BillingState.loading());

    try {
      final result = await _billingRepository.getRevenueByCompany(
        startDate: event.startDate,
        endDate: event.endDate,
      );

      result.fold(
        (failure) {
          emit(BillingState.error(message: failure.message, error: failure));
        },
        (revenueByCompany) {
          emit(
            BillingState.revenueByCompanyLoaded(
              revenueByCompany: revenueByCompany,
              message: 'Revenue by company loaded successfully',
            ),
          );
        },
      );
    } catch (e) {
      emit(
        BillingState.error(
          message: 'Failed to load revenue by company: ${e.toString()}',
          error: UnknownFailure(e.toString()),
        ),
      );
    }
  }

  /// Handles resetting billing state
  Future<void> _onResetBillingState(
    ResetBillingState event,
    Emitter<BillingState> emit,
  ) async {
    emit(const BillingState.initial());
  }
}

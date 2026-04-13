import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nexatrace_system/core/errors/failures.dart';
import 'package:nexatrace_system/features/nexa_admin/domain/entities/billing_entity.dart';
import 'package:nexatrace_system/features/nexa_admin/data/models/invoice_model.dart';
import 'package:nexatrace_system/features/nexa_admin/data/models/credit_note_model.dart';
import 'package:nexatrace_system/features/nexa_admin/data/models/payment_reconciliation_model.dart';
import 'package:nexatrace_system/features/nexa_admin/data/models/revenue_report_model.dart';
import 'package:nexatrace_system/features/nexa_admin/domain/usecases/reconcile_payments_usecase.dart';
import 'package:nexatrace_system/shared/models/company/company_model.dart';

part 'billing_state.freezed.dart';

/// States for the BillingBloc
@freezed
abstract class BillingState with _$BillingState {
  /// Initial state
  const factory BillingState.initial() = _Initial;

  /// Loading state
  const factory BillingState.loading() = _Loading;

  /// Processing state (for operations that take time)
  const factory BillingState.processing() = _Processing;

  /// Platform invoices loaded successfully
  const factory BillingState.platformInvoicesLoaded({
    required List<AdminInvoice> invoices,
    required bool hasMore,
    required int currentPage,
  }) = _PlatformInvoicesLoaded;

  /// Company invoices loaded successfully
  const factory BillingState.companyInvoicesLoaded({
    required String companyId,
    required List<AdminInvoice> invoices,
    required bool hasMore,
    required int currentPage,
  }) = _CompanyInvoicesLoaded;

  /// Invoice generated successfully
  const factory BillingState.invoiceGenerated({
    required BillingEntity invoice,
    required String message,
  }) = _InvoiceGenerated;

  /// Bulk invoices generated successfully
  const factory BillingState.bulkInvoicesGenerated({
    required List<BillingEntity> invoices,
    required String message,
    required int failedCount,
  }) = _BulkInvoicesGenerated;

  /// Payment processed successfully
  const factory BillingState.paymentProcessed({
    required BillingEntity payment,
    required String message,
  }) = _PaymentProcessed;

  /// Partial payment processed successfully
  const factory BillingState.partialPaymentProcessed({
    required BillingEntity payment,
    required String message,
  }) = _PartialPaymentProcessed;

  /// Bulk payments processed successfully
  const factory BillingState.bulkPaymentsProcessed({
    required List<BillingEntity> payments,
    required String message,
    required int failedCount,
  }) = _BulkPaymentsProcessed;

  /// Payments reconciled successfully
  const factory BillingState.paymentsReconciled({
    required PaymentReconciliation reconciliation,
    required String message,
  }) = _PaymentsReconciled;

  /// Reconciliation analyzed successfully
  const factory BillingState.reconciliationAnalyzed({
    required ReconciliationAnalysis analysis,
    required String message,
  }) = _ReconciliationAnalyzed;

  /// Revenue report generated successfully
  const factory BillingState.revenueReportGenerated({
    required RevenueReport report,
    required String message,
  }) = _RevenueReportGenerated;

  /// Financial dashboard data loaded successfully
  const factory BillingState.financialDashboardLoaded({
    required Map<String, dynamic> dashboardData,
    required String message,
  }) = _FinancialDashboardLoaded;

  /// Invoices exported successfully
  const factory BillingState.invoicesExported({
    required String exportUrl,
    required String message,
  }) = _InvoicesExported;

  /// Revenue report exported successfully
  const factory BillingState.revenueReportExported({
    required String exportUrl,
    required String message,
  }) = _RevenueReportExported;

  /// Invoice status updated successfully
  const factory BillingState.invoiceStatusUpdated({
    required AdminInvoice invoice,
    required String message,
  }) = _InvoiceStatusUpdated;

  /// Credit note created successfully
  const factory BillingState.creditNoteCreated({
    required CreditNote creditNote,
    required String message,
  }) = _CreditNoteCreated;

  /// Credit notes loaded successfully
  const factory BillingState.creditNotesLoaded({
    required List<CreditNote> creditNotes,
    required bool hasMore,
    required int currentPage,
  }) = _CreditNotesLoaded;

  /// Companies with overdue invoices loaded successfully
  const factory BillingState.companiesWithOverdueLoaded({
    required List<Company> companies,
    required String message,
  }) = _CompaniesWithOverdueLoaded;

  /// Platform revenue summary loaded successfully
  const factory BillingState.platformRevenueSummaryLoaded({
    required PlatformRevenueSummary revenueSummary,
    required String message,
  }) = _PlatformRevenueSummaryLoaded;

  /// Revenue by company loaded successfully
  const factory BillingState.revenueByCompanyLoaded({
    required List<CompanyRevenueSummary> revenueByCompany,
    required String message,
  }) = _RevenueByCompanyLoaded;

  /// General success state
  const factory BillingState.success({required String message}) = _Success;

  /// Error state
  const factory BillingState.error({
    required String message,
    required Failure error,
  }) = _Error;

  /// Empty state (no data available)
  const factory BillingState.empty({required String message}) = _Empty;
}

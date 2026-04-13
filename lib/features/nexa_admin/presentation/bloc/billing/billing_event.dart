//lib/features/nexa_admin/presentation/bloc/billing/billing_event.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nexatrace_system/features/nexa_admin/domain/usecases/generate_invoice_usecase.dart';
import 'package:nexatrace_system/features/nexa_admin/domain/usecases/process_payment_usecase.dart';
import 'package:nexatrace_system/shared/models/billing/invoice_model.dart'
    as shared;
import 'package:nexatrace_system/features/nexa_admin/data/models/credit_note_model.dart';
import 'package:nexatrace_system/features/nexa_admin/data/models/revenue_report_model.dart';

part 'billing_event.freezed.dart';

/// Events for the BillingBloc
@freezed
abstract class BillingEvent with _$BillingEvent {
  /// Initial event to load platform invoices
  const factory BillingEvent.loadPlatformInvoices({
    DateTime? startDate,
    DateTime? endDate,
    List<shared.InvoiceStatus>? statuses,
    String? searchQuery,
    @Default(1) int page,
    @Default(20) int limit,
  }) = LoadPlatformInvoices;

  /// Event to load invoices for a specific company
  const factory BillingEvent.loadCompanyInvoices({
    required String companyId,
    DateTime? startDate,
    DateTime? endDate,
    List<shared.InvoiceStatus>? statuses,
    @Default(1) int page,
    @Default(20) int limit,
  }) = LoadCompanyInvoices;

  /// Event to generate a single invoice
  const factory BillingEvent.generateInvoice({
    required String companyId,
    required String subscriptionId,
    required DateTime periodStart,
    required DateTime periodEnd,
    required List<shared.InvoiceItem> items,
    String? notes,
    @Default(true) bool sendNotification,
  }) = GenerateInvoice;

  /// Event to generate invoices in bulk
  const factory BillingEvent.generateBulkInvoices({
    required List<GenerateInvoiceParams> paramsList,
  }) = GenerateBulkInvoices;

  /// Event to process a payment
  const factory BillingEvent.processPayment({
    required String invoiceId,
    required double amount,
    required shared.PaymentMethod method,
    required DateTime paymentDate,
    String? reference,
    String? transactionId,
    String? notes,
    @Default(true) bool sendNotification,
  }) = ProcessPayment;

  /// Event to process a partial payment
  const factory BillingEvent.processPartialPayment({
    required String invoiceId,
    required double amount,
    required shared.PaymentMethod method,
    required DateTime paymentDate,
    String? reference,
    String? transactionId,
    String? notes,
    @Default(true) bool sendNotification,
  }) = ProcessPartialPayment;

  /// Event to process payments in bulk
  const factory BillingEvent.processBulkPayments({
    required List<ProcessPaymentParams> paramsList,
  }) = ProcessBulkPayments;

  /// Event to reconcile payments
  const factory BillingEvent.reconcilePayments({
    required DateTime reconciliationDate,
    required DateTime periodStart,
    required DateTime periodEnd,
    String? notes,
    @Default(true) bool autoMatchTransactions,
    @Default(0.01) double matchTolerance,
  }) = ReconcilePayments;

  /// Event to analyze reconciliation discrepancies
  const factory BillingEvent.analyzeReconciliation({
    required String reconciliationId,
  }) = AnalyzeReconciliation;

  /// Event to generate a revenue report
  const factory BillingEvent.generateRevenueReport({
    required ReportType type,
    required DateTime periodStart,
    required DateTime periodEnd,
    String? reportName,
    String? notes,
  }) = GenerateRevenueReport;

  /// Event to get financial dashboard data
  const factory BillingEvent.getFinancialDashboardData({
    DateTime? startDate,
    DateTime? endDate,
  }) = GetFinancialDashboardData;

  /// Event to export invoices
  const factory BillingEvent.exportInvoices({
    DateTime? startDate,
    DateTime? endDate,
    List<shared.InvoiceStatus>? statuses,
    @Default('csv') String format,
  }) = ExportInvoices;

  /// Event to export a revenue report
  const factory BillingEvent.exportRevenueReport({
    required String reportId,
    @Default('pdf') String format,
  }) = ExportRevenueReport;

  /// Event to update invoice status
  const factory BillingEvent.updateInvoiceStatus({
    required String invoiceId,
    required shared.InvoiceStatus status,
  }) = UpdateInvoiceStatus;

  /// Event to send invoice notification
  const factory BillingEvent.sendInvoiceNotification({
    required String invoiceId,
  }) = SendInvoiceNotification;

  /// Event to create a credit note
  const factory BillingEvent.createCreditNote({
    required String invoiceId,
    required double amount,
    required CreditNoteReason reason,
    String? notes,
  }) = CreateCreditNote;

  /// Event to get credit notes
  const factory BillingEvent.getCreditNotes({
    DateTime? startDate,
    DateTime? endDate,
    String? companyId,
    @Default(1) int page,
    @Default(20) int limit,
  }) = GetCreditNotes;

  /// Event to get companies with overdue invoices
  const factory BillingEvent.getCompaniesWithOverdueInvoices() =
      GetCompaniesWithOverdueInvoices;

  /// Event to get platform revenue summary
  const factory BillingEvent.getPlatformRevenueSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) = GetPlatformRevenueSummary;

  /// Event to get revenue by company
  const factory BillingEvent.getRevenueByCompany({
    DateTime? startDate,
    DateTime? endDate,
  }) = GetRevenueByCompany;

  /// Event to reset billing state
  const factory BillingEvent.resetBillingState() = ResetBillingState;
}

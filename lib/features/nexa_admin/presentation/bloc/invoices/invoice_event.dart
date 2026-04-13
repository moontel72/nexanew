import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nexatrace_system/shared/models/billing/invoice_model.dart'
    as shared;

part 'invoice_event.freezed.dart';

/// Events for the InvoiceBloc
@freezed
abstract class InvoiceEvent with _$InvoiceEvent {
  /// Event to load invoice detail
  const factory InvoiceEvent.loadInvoiceDetail({required String invoiceId}) =
      LoadInvoiceDetail;

  /// Event to load invoice payments
  const factory InvoiceEvent.loadInvoicePayments({required String invoiceId}) =
      LoadInvoicePayments;

  /// Event to validate an invoice
  const factory InvoiceEvent.validateInvoice({required String invoiceId}) =
      ValidateInvoice;

  /// Event to calculate invoice totals
  const factory InvoiceEvent.calculateInvoiceTotals({
    required List<shared.InvoiceItem> items,
    double? discountPercentage,
  }) = CalculateInvoiceTotals;

  /// Event to search invoices
  const factory InvoiceEvent.searchInvoices({
    required String query,
    @Default(1) int page,
    @Default(20) int limit,
  }) = SearchInvoices;

  /// Event to filter invoices
  const factory InvoiceEvent.filterInvoices({
    DateTime? startDate,
    DateTime? endDate,
    List<shared.InvoiceStatus>? statuses,
    @Default(1) int page,
    @Default(20) int limit,
  }) = FilterInvoices;

  /// Event to sort invoices
  const factory InvoiceEvent.sortInvoices({
    required String sortBy,
    @Default(true) bool sortDesc,
    DateTime? startDate,
    DateTime? endDate,
    List<shared.InvoiceStatus>? statuses,
    @Default(1) int page,
    @Default(20) int limit,
  }) = SortInvoices;

  /// Event to export invoice detail
  const factory InvoiceEvent.exportInvoiceDetail({
    required String invoiceId,
    @Default('pdf') String format,
  }) = ExportInvoiceDetail;

  /// Event to send invoice reminder
  const factory InvoiceEvent.sendInvoiceReminder({
    required String invoiceId,
    @Default('payment_due') String reminderType,
  }) = SendInvoiceReminder;

  /// Event to apply discount to invoice
  const factory InvoiceEvent.applyDiscount({
    required String invoiceId,
    required double discountPercentage,
  }) = ApplyDiscount;

  /// Event to add note to invoice
  const factory InvoiceEvent.addInvoiceNote({
    required String invoiceId,
    required String note,
    @Default(false) bool isAdminNote,
  }) = AddInvoiceNote;

  /// Event to get invoice statistics
  const factory InvoiceEvent.getInvoiceStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) = GetInvoiceStatistics;

  /// Event to get invoice trends
  const factory InvoiceEvent.getInvoiceTrends({
    DateTime? startDate,
    DateTime? endDate,
  }) = GetInvoiceTrends;

  /// Event to reset invoice state
  const factory InvoiceEvent.resetInvoiceState() = ResetInvoiceState;
}

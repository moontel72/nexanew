import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:trace_odd/core/errors/failures.dart';
import 'package:trace_odd/features/nexa_admin/data/models/invoice_model.dart';
import 'package:trace_odd/shared/models/billing/invoice_model.dart'
    as shared;

part 'invoice_state.freezed.dart';

/// States for the InvoiceBloc
@freezed
abstract class InvoiceState with _$InvoiceState {
  /// Initial state
  const factory InvoiceState.initial() = _Initial;

  /// Loading state
  const factory InvoiceState.loading() = _Loading;

  /// Processing state (for operations that take time)
  const factory InvoiceState.processing() = _Processing;

  /// Invoice detail loaded successfully
  const factory InvoiceState.invoiceDetailLoaded({
    required AdminInvoice invoice,
    required List<shared.Payment> payments,
    required String message,
  }) = _InvoiceDetailLoaded;

  /// Invoice payments loaded successfully
  const factory InvoiceState.invoicePaymentsLoaded({
    required String invoiceId,
    required List<shared.Payment> payments,
    required String message,
  }) = _InvoicePaymentsLoaded;

  /// Invoice validated successfully
  const factory InvoiceState.invoiceValidated({
    required String invoiceId,
    required bool isValid,
    required String message,
    required List<String> warnings,
  }) = _InvoiceValidated;

  /// Invoice totals calculated successfully
  const factory InvoiceState.invoiceTotalsCalculated({
    required double subtotal,
    required double taxAmount,
    required double discountAmount,
    required double totalAmount,
    required String currency,
    required int itemCount,
    required String message,
  }) = _InvoiceTotalsCalculated;

  /// Invoices searched successfully
  const factory InvoiceState.invoicesSearched({
    required String query,
    required List<AdminInvoice> invoices,
    required bool hasMore,
    required int currentPage,
    required String message,
  }) = _InvoicesSearched;

  /// Invoices filtered successfully
  const factory InvoiceState.invoicesFiltered({
    required Map<String, dynamic> filters,
    required List<AdminInvoice> invoices,
    required bool hasMore,
    required int currentPage,
    required String message,
  }) = _InvoicesFiltered;

  /// Invoices sorted successfully
  const factory InvoiceState.invoicesSorted({
    required String sortBy,
    required bool sortDesc,
    required List<AdminInvoice> invoices,
    required String message,
  }) = _InvoicesSorted;

  /// Invoice exported successfully
  const factory InvoiceState.invoiceExported({
    required String invoiceId,
    required String format,
    required Map<String, dynamic> exportData,
    required String message,
  }) = _InvoiceExported;

  /// Invoice reminder sent successfully
  const factory InvoiceState.invoiceReminderSent({
    required String invoiceId,
    required String reminderType,
    required String message,
  }) = _InvoiceReminderSent;

  /// Discount applied successfully
  const factory InvoiceState.discountApplied({
    required String invoiceId,
    required double discountPercentage,
    required double discountAmount,
    required double newTotalAmount,
    required String message,
  }) = _DiscountApplied;

  /// Note added to invoice successfully
  const factory InvoiceState.noteAdded({
    required String invoiceId,
    required String note,
    required bool isAdminNote,
    required String message,
  }) = _NoteAdded;

  /// Invoice statistics loaded successfully
  const factory InvoiceState.invoiceStatisticsLoaded({
    required Map<String, dynamic> statistics,
    required String message,
  }) = _InvoiceStatisticsLoaded;

  /// Invoice trends loaded successfully
  const factory InvoiceState.invoiceTrendsLoaded({
    required Map<String, dynamic> trends,
    required String message,
  }) = _InvoiceTrendsLoaded;

  /// General success state
  const factory InvoiceState.success({required String message}) = _Success;

  /// Error state
  const factory InvoiceState.error({
    required String message,
    required Failure error,
  }) = _Error;

  /// Empty state (no data available)
  const factory InvoiceState.empty({required String message}) = _Empty;
}

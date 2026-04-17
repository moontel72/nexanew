// Billing States for Factory Admin Portal
// States for managing factory billing operations

part of 'billing_bloc.dart';

@freezed
abstract class BillingState with _$BillingState {
  // Initial state
  const factory BillingState.initial() = BillingInitial;

  // Loading state
  const factory BillingState.loading() = BillingLoading;

  // Loaded billing summary
  const factory BillingState.summaryLoaded({
    required BillingSummary summary,
    required List<Invoice> recentInvoices,
    @Default(false) bool hasMoreInvoices,
  }) = BillingSummaryLoaded;

  // Invoices loaded state
  const factory BillingState.invoicesLoaded({
    required List<Invoice> invoices,
    required BillingFilter filter,
    @Default(false) bool hasMore,
    @Default(0) int totalCount,
  }) = BillingInvoicesLoaded;

  // Invoice detail loaded state
  const factory BillingState.invoiceDetailLoaded({
    required Invoice invoice,
    List<Payment>? payments,
  }) = BillingInvoiceDetailLoaded;

  // Payment history loaded state
  const factory BillingState.paymentHistoryLoaded({
    required List<Payment> payments,
    required BillingFilter filter,
    @Default(false) bool hasMore,
    @Default(0) int totalCount,
  }) = BillingPaymentHistoryLoaded;

  // Payment processing state
  const factory BillingState.paymentProcessing({
    required String invoiceId,
  }) = BillingPaymentProcessing;

  // Payment success state
  const factory BillingState.paymentSuccess({
    required Payment payment,
    required Invoice updatedInvoice,
  }) = BillingPaymentSuccess;

  // Invoice download state
  const factory BillingState.invoiceDownloading({
    required String invoiceId,
  }) = BillingInvoiceDownloading;

  // Invoice download success state
  const factory BillingState.invoiceDownloadSuccess({
    required String invoiceId,
    required String filePath,
  }) = BillingInvoiceDownloadSuccess;

  // Invoice email sending state
  const factory BillingState.invoiceEmailSending({
    required String invoiceId,
  }) = BillingInvoiceEmailSending;

  // Invoice email sent state
  const factory BillingState.invoiceEmailSent({
    required String invoiceId,
  }) = BillingInvoiceEmailSent;

  // Error state
  const factory BillingState.error({
    required String message,
    @Default(false) bool isNetworkError,
    @Default(false) bool isPaymentError,
    @Default(false) bool isInvoiceLocked,
    BillingEvent? retryEvent,
  }) = BillingError;

  // Empty state (no invoices)
  const factory BillingState.empty({
    required String message,
  }) = BillingEmpty;
}

// Billing Events for Factory Admin Portal
// Events for managing factory billing operations

part of 'billing_bloc.dart';

@freezed
abstract class BillingEvent with _$BillingEvent {
  // Load billing summary and invoices
  const factory BillingEvent.loadBillingSummary() = LoadBillingSummary;

  // Load invoices with optional filtering
  const factory BillingEvent.loadInvoices({
    BillingFilter? filter,
  }) = LoadInvoices;

  // Load specific invoice by ID
  const factory BillingEvent.loadInvoice({
    required String invoiceId,
  }) = LoadInvoice;

  // Load payment history
  const factory BillingEvent.loadPaymentHistory({
    BillingFilter? filter,
  }) = LoadPaymentHistory;

  // Make payment for an invoice
  const factory BillingEvent.makePayment({
    required String invoiceId,
    required double amount,
    required PaymentMethod paymentMethod,
    String? reference,
    String? notes,
  }) = MakePayment;

  // Download invoice PDF
  const factory BillingEvent.downloadInvoice({
    required String invoiceId,
  }) = DownloadInvoice;

  // Send invoice via email
  const factory BillingEvent.sendInvoiceEmail({
    required String invoiceId,
    String? email,
  }) = SendInvoiceEmail;

  // Refresh billing data
  const factory BillingEvent.refresh() = RefreshBilling;

  // Clear billing errors
  const factory BillingEvent.clearError() = ClearBillingError;

  // Reset billing state
  const factory BillingEvent.reset() = ResetBilling;
}

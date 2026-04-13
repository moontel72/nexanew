// Billing Repository Interface for Factory Admin Portal
// Defines the contract for billing data operations

import 'package:nexatrace_system/shared/models/billing/invoice_model.dart';

abstract class BillingRepository {
  // Get billing summary for the current factory
  Future<BillingSummary> getBillingSummary();

  // Get invoices with optional filtering
  Future<List<Invoice>> getInvoices(BillingFilter filter);

  // Get specific invoice by ID
  Future<Invoice> getInvoice(String invoiceId);

  // Get payment history with optional filtering
  Future<List<Payment>> getPaymentHistory(BillingFilter filter);

  // Get payments for a specific invoice
  Future<List<Payment>> getInvoicePayments(String invoiceId);

  // Make a payment for an invoice
  Future<PaymentResult> makePayment({
    required String invoiceId,
    required double amount,
    required PaymentMethod paymentMethod,
    String? reference,
    String? notes,
  });

  // Download invoice as PDF
  Future<String> downloadInvoice(String invoiceId);

  // Send invoice via email
  Future<void> sendInvoiceEmail({
    required String invoiceId,
    String? email,
  });

  // Get invoice statistics
  Future<InvoiceStatistics> getInvoiceStatistics();

  // Check if invoice is downloadable (paid invoices only)
  Future<bool> canDownloadInvoice(String invoiceId);
}

// Payment result model
class PaymentResult {
  final Payment payment;
  final Invoice updatedInvoice;

  PaymentResult({
    required this.payment,
    required this.updatedInvoice,
  });
}

// Invoice statistics model
class InvoiceStatistics {
  final double totalRevenue;
  final double averageInvoiceAmount;
  final int totalInvoices;
  final int paidInvoices;
  final int pendingInvoices;
  final int overdueInvoices;
  final Map<String, double> monthlyRevenue;
  final Map<String, int> invoiceStatusCount;

  InvoiceStatistics({
    required this.totalRevenue,
    required this.averageInvoiceAmount,
    required this.totalInvoices,
    required this.paidInvoices,
    required this.pendingInvoices,
    required this.overdueInvoices,
    required this.monthlyRevenue,
    required this.invoiceStatusCount,
  });
}

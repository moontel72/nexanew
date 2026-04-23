// Billing Repository Implementation for Factory Admin Portal
// Implements billing data operations using remote datasource

import 'package:nexatrace_system/core/services/api_client.dart';
import 'package:nexatrace_system/core/utils/auth_state.dart';
import 'package:nexatrace_system/shared/models/billing/invoice_model.dart';
import 'package:nexatrace_system/features/factory/admin/domain/repositories/billing_repository.dart';

class BillingRepositoryImpl implements BillingRepository {
  final ApiClient _apiClient;

  BillingRepositoryImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<BillingSummary> getBillingSummary() async {
    try {
      final response = await _apiClient.get(
        '/factory/billing/summary',
        headers: _getAuthHeaders(),
      );

      return BillingSummary.fromJson(response['data']);
    } catch (error) {
      throw Exception('Failed to load billing summary: $error');
    }
  }

  @override
  Future<List<Invoice>> getInvoices(BillingFilter filter) async {
    try {
      final queryParams = _buildFilterQueryParams(filter);

      final response = await _apiClient.get(
        '/factory/billing/invoices',
        queryParameters: queryParams,
        headers: _getAuthHeaders(),
      );

      final List<dynamic> invoicesData = response['data'] ?? [];
      return invoicesData.map((json) => Invoice.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to load invoices: $error');
    }
  }

  @override
  Future<Invoice> getInvoice(String invoiceId) async {
    try {
      final response = await _apiClient.get(
        '/factory/billing/invoices/$invoiceId',
        headers: _getAuthHeaders(),
      );

      return Invoice.fromJson(response['data']);
    } catch (error) {
      throw Exception('Failed to load invoice: $error');
    }
  }

  @override
  Future<List<Payment>> getPaymentHistory(BillingFilter filter) async {
    try {
      final queryParams = _buildFilterQueryParams(filter);

      final response = await _apiClient.get(
        '/factory/billing/payments',
        queryParameters: queryParams,
        headers: _getAuthHeaders(),
      );

      final List<dynamic> paymentsData = response['data'] ?? [];
      return paymentsData.map((json) => Payment.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to load payment history: $error');
    }
  }

  @override
  Future<List<Payment>> getInvoicePayments(String invoiceId) async {
    try {
      final response = await _apiClient.get(
        '/factory/billing/invoices/$invoiceId/payments',
        headers: _getAuthHeaders(),
      );

      final List<dynamic> paymentsData = response['data'] ?? [];
      return paymentsData.map((json) => Payment.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to load invoice payments: $error');
    }
  }

  @override
  Future<PaymentResult> makePayment({
    required String invoiceId,
    required double amount,
    required PaymentMethod paymentMethod,
    String? reference,
    String? notes,
  }) async {
    try {
      final payload = {
        'invoice_id': invoiceId,
        'amount': amount,
        'payment_method': paymentMethod.name,
        'reference': reference,
        'notes': notes,
      };

      final response = await _apiClient.post(
        '/factory/billing/payments',
        data: payload,
        headers: _getAuthHeaders(),
      );

      final payment = Payment.fromJson(response['data']['payment']);
      final updatedInvoice = Invoice.fromJson(response['data']['invoice']);

      return PaymentResult(payment: payment, updatedInvoice: updatedInvoice);
    } catch (error) {
      throw Exception('Failed to make payment: $error');
    }
  }

  @override
  Future<String> downloadInvoice(String invoiceId) async {
    try {
      final response = await _apiClient.get(
        '/factory/billing/invoices/$invoiceId/download',
        headers: _getAuthHeaders(),
      );

      // In a real implementation, this would handle file download
      // For now, return a placeholder file path
      return response['data']['file_path'] ??
          '/downloads/invoice_$invoiceId.pdf';
    } catch (error) {
      throw Exception('Failed to download invoice: $error');
    }
  }

  @override
  Future<void> sendInvoiceEmail({
    required String invoiceId,
    String? email,
  }) async {
    try {
      final payload = {
        'invoice_id': invoiceId,
        if (email != null && email.isNotEmpty) 'email': email,
      };

      await _apiClient.post(
        '/factory/billing/invoices/$invoiceId/send-email',
        data: payload,
        headers: _getAuthHeaders(),
      );
    } catch (error) {
      throw Exception('Failed to send invoice email: $error');
    }
  }

  @override
  Future<InvoiceStatistics> getInvoiceStatistics() async {
    try {
      final response = await _apiClient.get(
        '/factory/billing/statistics',
        headers: _getAuthHeaders(),
      );

      final data = response['data'];
      return InvoiceStatistics(
        totalRevenue: (data['total_revenue'] ?? 0).toDouble(),
        averageInvoiceAmount: (data['average_invoice_amount'] ?? 0).toDouble(),
        totalInvoices: data['total_invoices'] ?? 0,
        paidInvoices: data['paid_invoices'] ?? 0,
        pendingInvoices: data['pending_invoices'] ?? 0,
        overdueInvoices: data['overdue_invoices'] ?? 0,
        monthlyRevenue: Map<String, double>.from(data['monthly_revenue'] ?? {}),
        invoiceStatusCount: Map<String, int>.from(
          data['invoice_status_count'] ?? {},
        ),
      );
    } catch (error) {
      throw Exception('Failed to load invoice statistics: $error');
    }
  }

  @override
  Future<bool> canDownloadInvoice(String invoiceId) async {
    try {
      final response = await _apiClient.get(
        '/factory/billing/invoices/$invoiceId/downloadable',
        headers: _getAuthHeaders(),
      );

      return response['data']['downloadable'] ?? false;
    } catch (error) {
      return false;
    }
  }

  // Helper methods

  Map<String, String> _getAuthHeaders() {
    final token = getFactoryAuthToken();
    final factoryId = getFactoryId();

    if (factoryId == null) {
      throw Exception('Factory ID not found. Please login again.');
    }

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'X-Factory-ID': factoryId,
    };
  }

  Map<String, dynamic> _buildFilterQueryParams(BillingFilter filter) {
    final params = <String, dynamic>{};

    if (filter.startDate != null) {
      params['start_date'] = filter.startDate!.toIso8601String();
    }
    if (filter.endDate != null) {
      params['end_date'] = filter.endDate!.toIso8601String();
    }
    if (filter.statuses != null && filter.statuses!.isNotEmpty) {
      params['statuses'] = filter.statuses!.map((s) => s.name).join(',');
    }
    if (filter.minAmount != null) {
      params['min_amount'] = filter.minAmount;
    }
    if (filter.maxAmount != null) {
      params['max_amount'] = filter.maxAmount;
    }
    if (filter.searchQuery != null) {
      params['search'] = filter.searchQuery;
    }
    String sortBy = filter.sortBy;
    switch (sortBy) {
      case 'issueDate':
        sortBy = 'issue_date';
        break;
      case 'dueDate':
        sortBy = 'due_date';
        break;
      case 'totalAmount':
        sortBy = 'total_amount';
        break;
      case 'invoiceNumber':
        sortBy = 'invoice_number';
        break;
      case 'createdAt':
        sortBy = 'created_at';
        break;
      case 'updatedAt':
        sortBy = 'updated_at';
        break;
    }
    params['sort_by'] = sortBy;
    params['sort_desc'] = filter.sortDesc ? 'true' : 'false';
    params['page'] = filter.page;
    params['limit'] = filter.limit;

    return params;
  }
}

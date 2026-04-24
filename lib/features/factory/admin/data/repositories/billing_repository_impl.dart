// Billing Repository Implementation for Factory Admin Portal
// Implements billing data operations using remote datasource

import 'package:nexatrace_system/core/services/api_client.dart';
import 'package:nexatrace_system/shared/models/billing/invoice_model.dart';
import 'package:nexatrace_system/features/factory/admin/domain/repositories/billing_repository.dart';

class BillingRepositoryImpl implements BillingRepository {
  final ApiClient _apiClient;

  BillingRepositoryImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().trim()) ?? 0.0;
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString().trim()) ?? 0;
  }

  String _toStringValue(dynamic value, {String fallback = ''}) {
    final s = value?.toString().trim() ?? '';
    return s.isEmpty ? fallback : s;
  }

  String _toIsoDate(dynamic value) {
    if (value == null) return DateTime.now().toIso8601String();
    if (value is DateTime) return value.toIso8601String();
    final s = value.toString().trim();
    if (s.isEmpty) return DateTime.now().toIso8601String();
    return s;
  }

  Map<String, dynamic> _normalizeBillingSummaryJson(Map<String, dynamic> json) {
    final m = Map<String, dynamic>.from(json);
    return {
      'totalOwed': _toDouble(m['totalOwed'] ?? m['total_owed']),
      'totalPaid': _toDouble(m['totalPaid'] ?? m['total_paid']),
      'pendingInvoices': _toInt(m['pendingInvoices'] ?? m['pending_invoices']),
      'paidInvoices': _toInt(m['paidInvoices'] ?? m['paid_invoices']),
      'overdueInvoices': _toInt(m['overdueInvoices'] ?? m['overdue_invoices']),
      'nextPaymentDate': m['nextPaymentDate'] ?? m['next_payment_date'],
      'nextPaymentAmount': _toDouble(
        m['nextPaymentAmount'] ?? m['next_payment_amount'],
      ),
      'nextPaymentCurrency':
          m['nextPaymentCurrency'] ?? m['next_payment_currency'],
      'usageSummary': m['usageSummary'] ?? m['usage_summary'],
    };
  }

  Map<String, dynamic> _normalizeInvoiceItemJson(Map<String, dynamic> json) {
    final m = Map<String, dynamic>.from(json);
    return {
      'id': _toStringValue(m['id']),
      'description': _toStringValue(m['description']),
      'quantity': _toDouble(m['quantity']),
      'unitPrice': _toDouble(m['unitPrice'] ?? m['unit_price']),
      'total': _toDouble(m['total']),
      'currency': _toStringValue(m['currency'], fallback: 'USD'),
      'codeType': m['codeType'] ?? m['code_type'],
      'codeCount': _toInt(m['codeCount'] ?? m['code_count']),
      'periodStart': m['periodStart'] ?? m['period_start'],
      'periodEnd': m['periodEnd'] ?? m['period_end'],
      'metadata': m['metadata'],
    };
  }

  Map<String, dynamic> _normalizeInvoiceJson(Map<String, dynamic> json) {
    final m = Map<String, dynamic>.from(json);

    final rawItems = m['items'];
    final items = rawItems is List
        ? rawItems
            .whereType<Map>()
            .map((e) => _normalizeInvoiceItemJson(
                  Map<String, dynamic>.from(e.cast<String, dynamic>()),
                ))
            .toList()
        : const <Map<String, dynamic>>[];

    final issueDate = _toIsoDate(m['issueDate'] ?? m['issue_date'] ?? m['created_at']);
    final dueDate = _toIsoDate(m['dueDate'] ?? m['due_date'] ?? issueDate);
    final periodStart = _toIsoDate(m['periodStart'] ?? m['period_start'] ?? issueDate);
    final periodEnd = _toIsoDate(m['periodEnd'] ?? m['period_end'] ?? dueDate);

    return {
      'id': _toStringValue(m['id']),
      'invoiceNumber': _toStringValue(m['invoiceNumber'] ?? m['invoice_number']),
      'companyId': _toStringValue(m['companyId'] ?? m['company_id']),
      'subscriptionId': m['subscriptionId'] ?? m['subscription_id'],
      'periodStart': periodStart,
      'periodEnd': periodEnd,
      'issueDate': issueDate,
      'dueDate': dueDate,
      'subtotal': _toDouble(m['subtotal']),
      'taxAmount': _toDouble(m['taxAmount'] ?? m['tax_amount']),
      'discountAmount': _toDouble(m['discountAmount'] ?? m['discount_amount']),
      'totalAmount': _toDouble(m['totalAmount'] ?? m['total_amount']),
      'currency': _toStringValue(m['currency'], fallback: 'USD'),
      'items': items,
      'status': m['status'] ?? 'pending',
      'paymentDate': m['paymentDate'] ?? m['payment_date'],
      'paymentMethod': m['paymentMethod'] ?? m['payment_method'],
      'paymentReference': m['paymentReference'] ?? m['payment_reference'],
      'notes': m['notes'],
      'metadata': m['metadata'],
      'createdAt': m['createdAt'] ?? m['created_at'],
      'updatedAt': m['updatedAt'] ?? m['updated_at'],
    };
  }

  @override
  Future<BillingSummary> getBillingSummary() async {
    try {
      final response = await _apiClient.get(
        '/factory/billing/summary',
        headers: _getAuthHeaders(),
      );

      if (response is! Map) {
        throw Exception('Invalid response format');
      }
      final data = response['data'];
      if (data is! Map) {
        throw Exception('Invalid billing summary data format');
      }

      return BillingSummary.fromJson(
        _normalizeBillingSummaryJson(
          Map<String, dynamic>.from(data.cast<String, dynamic>()),
        ),
      );
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

      if (response is! Map) {
        throw Exception('Invalid response format');
      }

      final rawData = response['data'];
      final List<dynamic> invoicesData = rawData is List
          ? rawData
          : (rawData is Map && rawData['invoices'] is List)
              ? (rawData['invoices'] as List)
              : const [];

      return invoicesData.map((json) {
        if (json is! Map) return Invoice.empty();
        final normalized = _normalizeInvoiceJson(
          Map<String, dynamic>.from(json.cast<String, dynamic>()),
        );
        return Invoice.fromJson(normalized);
      }).toList();
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

      if (response is! Map) {
        throw Exception('Invalid response format');
      }
      final data = response['data'];
      if (data is! Map) {
        throw Exception('Invalid invoice data format');
      }
      return Invoice.fromJson(
        _normalizeInvoiceJson(
          Map<String, dynamic>.from(data.cast<String, dynamic>()),
        ),
      );
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
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
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

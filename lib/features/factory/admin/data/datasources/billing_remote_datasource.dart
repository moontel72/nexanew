// Billing Remote Datasource for Factory Admin Portal
// Handles direct API calls for billing operations

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trace_odd/core/config/api_config.dart';
import 'package:trace_odd/core/utils/auth_state.dart';
import 'package:trace_odd/shared/models/billing/invoice_model.dart';

class BillingRemoteDatasource {
  final String _baseUrl;

  BillingRemoteDatasource({String? baseUrl})
    : _baseUrl = baseUrl ?? ApiConfig.apiBaseUrl;

  // Get billing summary
  Future<Map<String, dynamic>> getBillingSummary() async {
    final uri = Uri.parse('$_baseUrl/factory/billing/summary');
    final headers = await _getAuthHeaders();

    final response = await http.get(uri, headers: headers);
    return _handleResponse(response);
  }

  // Get invoices with filtering
  Future<Map<String, dynamic>> getInvoices(
    Map<String, dynamic> queryParams,
  ) async {
    final uri = Uri.parse(
      '$_baseUrl/factory/billing/invoices',
    ).replace(queryParameters: queryParams);
    final headers = await _getAuthHeaders();

    final response = await http.get(uri, headers: headers);
    return _handleResponse(response);
  }

  // Get specific invoice
  Future<Map<String, dynamic>> getInvoice(String invoiceId) async {
    final uri = Uri.parse('$_baseUrl/factory/billing/invoices/$invoiceId');
    final headers = await _getAuthHeaders();

    final response = await http.get(uri, headers: headers);
    return _handleResponse(response);
  }

  // Get payment history
  Future<Map<String, dynamic>> getPaymentHistory(
    Map<String, dynamic> queryParams,
  ) async {
    final uri = Uri.parse(
      '$_baseUrl/factory/billing/payments',
    ).replace(queryParameters: queryParams);
    final headers = await _getAuthHeaders();

    final response = await http.get(uri, headers: headers);
    return _handleResponse(response);
  }

  // Get invoice payments
  Future<Map<String, dynamic>> getInvoicePayments(String invoiceId) async {
    final uri = Uri.parse(
      '$_baseUrl/factory/billing/invoices/$invoiceId/payments',
    );
    final headers = await _getAuthHeaders();

    final response = await http.get(uri, headers: headers);
    return _handleResponse(response);
  }

  // Make payment
  Future<Map<String, dynamic>> makePayment({
    required String invoiceId,
    required double amount,
    required PaymentMethod paymentMethod,
    String? reference,
    String? notes,
  }) async {
    final uri = Uri.parse('$_baseUrl/factory/billing/payments');
    final headers = await _getAuthHeaders();

    final payload = {
      'invoice_id': invoiceId,
      'amount': amount,
      'payment_method': paymentMethod.name,
      'reference': reference,
      'notes': notes,
    };

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(payload),
    );

    return _handleResponse(response);
  }

  // Download invoice
  Future<Map<String, dynamic>> downloadInvoice(String invoiceId) async {
    final uri = Uri.parse(
      '$_baseUrl/factory/billing/invoices/$invoiceId/download',
    );
    final headers = await _getAuthHeaders();

    final response = await http.get(uri, headers: headers);
    return _handleResponse(response);
  }

  // Send invoice email
  Future<Map<String, dynamic>> sendInvoiceEmail({
    required String invoiceId,
    String? email,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/factory/billing/invoices/$invoiceId/send-email',
    );
    final headers = await _getAuthHeaders();

    final payload = {
      'invoice_id': invoiceId,
      if (email != null && email.isNotEmpty) 'email': email,
    };

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(payload),
    );

    return _handleResponse(response);
  }

  // Get invoice statistics
  Future<Map<String, dynamic>> getInvoiceStatistics() async {
    final uri = Uri.parse('$_baseUrl/factory/billing/statistics');
    final headers = await _getAuthHeaders();

    final response = await http.get(uri, headers: headers);
    return _handleResponse(response);
  }

  // Check if invoice is downloadable
  Future<Map<String, dynamic>> checkInvoiceDownloadable(
    String invoiceId,
  ) async {
    final uri = Uri.parse(
      '$_baseUrl/factory/billing/invoices/$invoiceId/downloadable',
    );
    final headers = await _getAuthHeaders();

    final response = await http.get(uri, headers: headers);
    return _handleResponse(response);
  }

  // Helper methods

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = getFactoryAuthToken();
    final factoryId = getFactoryId();

    if (factoryId == null) {
      throw Exception('Factory ID not found. Please login again.');
    }

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'X-Factory-ID': factoryId,
      'Accept': 'application/json',
    };
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final data = jsonDecode(response.body);
        return data;
      } catch (e) {
        throw Exception('Failed to parse response: $e');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Authentication failed. Please login again.');
    } else if (response.statusCode == 403) {
      throw Exception('You do not have permission to access billing data.');
    } else if (response.statusCode == 404) {
      throw Exception('Billing resource not found.');
    } else if (response.statusCode == 422) {
      final errorData = jsonDecode(response.body);
      final errors = errorData['errors'] ?? {};
      final errorMessage = errors.isNotEmpty
          ? errors.values.first.join(', ')
          : 'Validation failed';
      throw Exception(errorMessage);
    } else if (response.statusCode >= 500) {
      throw Exception('Server error. Please try again later.');
    } else {
      throw Exception('Request failed with status: ${response.statusCode}');
    }
  }
}

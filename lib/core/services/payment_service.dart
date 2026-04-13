// Payment Service for NexaTrace System
// This file handles payment processing and subscription management

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import '../errors/app_exceptions.dart';
import '../errors/error_logger.dart';

class PaymentService {
  final String _baseUrl = ApiEndpoints.baseUrl;
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Add authentication token to headers
  void setAuthToken(String token) {
    _headers['Authorization'] = 'Bearer $token';
  }

  // Get subscription plans
  Future<List<Map<String, dynamic>>> getSubscriptionPlans() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/subscription/plans'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['plans']);
      } else {
        throw ServerException(
          'Failed to fetch subscription plans',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      ErrorLogger.error('Error fetching subscription plans', e);
      rethrow;
    }
  }

  // Get current subscription
  Future<Map<String, dynamic>> getCurrentSubscription(String factoryId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/factories/$factoryId/subscription'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw ServerException(
          'Failed to fetch current subscription',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      ErrorLogger.error('Error fetching current subscription', e);
      rethrow;
    }
  }

  // Subscribe to a plan
  Future<Map<String, dynamic>> subscribeToPlan({
    required String factoryId,
    required String planId,
    required String paymentMethodId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/subscription/subscribe'),
        headers: _headers,
        body: jsonEncode({
          'factory_id': factoryId,
          'plan_id': planId,
          'payment_method_id': paymentMethodId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw ServerException(
          'Failed to subscribe to plan',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      ErrorLogger.error('Error subscribing to plan', e);
      rethrow;
    }
  }

  // Update subscription
  Future<Map<String, dynamic>> updateSubscription({
    required String factoryId,
    required String newPlanId,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/subscription/update'),
        headers: _headers,
        body: jsonEncode({'factory_id': factoryId, 'new_plan_id': newPlanId}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw ServerException(
          'Failed to update subscription',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      ErrorLogger.error('Error updating subscription', e);
      rethrow;
    }
  }

  // Cancel subscription
  Future<Map<String, dynamic>> cancelSubscription(String factoryId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/subscription/cancel'),
        headers: _headers,
        body: jsonEncode({'factory_id': factoryId}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw ServerException(
          'Failed to cancel subscription',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      ErrorLogger.error('Error canceling subscription', e);
      rethrow;
    }
  }

  // Get payment history
  Future<List<Map<String, dynamic>>> getPaymentHistory(String factoryId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/payments/history/$factoryId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['payments']);
      } else {
        throw ServerException(
          'Failed to fetch payment history',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      ErrorLogger.error('Error fetching payment history', e);
      rethrow;
    }
  }

  // Create payment intent
  Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String currency,
    required String factoryId,
    required String planId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payments/create-intent'),
        headers: _headers,
        body: jsonEncode({
          'amount': amount,
          'currency': currency,
          'factory_id': factoryId,
          'plan_id': planId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw ServerException(
          'Failed to create payment intent',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      ErrorLogger.error('Error creating payment intent', e);
      rethrow;
    }
  }

  // Confirm payment
  Future<Map<String, dynamic>> confirmPayment({
    required String paymentIntentId,
    required String paymentMethodId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payments/confirm'),
        headers: _headers,
        body: jsonEncode({
          'payment_intent_id': paymentIntentId,
          'payment_method_id': paymentMethodId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw ServerException(
          'Failed to confirm payment',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      ErrorLogger.error('Error confirming payment', e);
      rethrow;
    }
  }

  // Get invoice
  Future<Map<String, dynamic>> getInvoice(String invoiceId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/payments/invoice/$invoiceId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw ServerException(
          'Failed to fetch invoice',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      ErrorLogger.error('Error fetching invoice', e);
      rethrow;
    }
  }

  // Download invoice PDF
  Future<List<int>> downloadInvoicePdf(String invoiceId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/payments/invoice/$invoiceId/pdf'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw ServerException(
          'Failed to download invoice PDF',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      ErrorLogger.error('Error downloading invoice PDF', e);
      rethrow;
    }
  }

  // Get usage statistics
  Future<Map<String, dynamic>> getUsageStatistics(String factoryId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/subscription/usage/$factoryId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw ServerException(
          'Failed to fetch usage statistics',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      ErrorLogger.error('Error fetching usage statistics', e);
      rethrow;
    }
  }

  // Check if factory can generate more codes
  Future<bool> canGenerateMoreCodes({
    required String factoryId,
    required String codeType,
    required int requestedCount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/subscription/check-limit'),
        headers: _headers,
        body: jsonEncode({
          'factory_id': factoryId,
          'code_type': codeType,
          'requested_count': requestedCount,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['can_generate'] ?? false;
      } else {
        throw ServerException(
          'Failed to check code generation limit',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      ErrorLogger.error('Error checking code generation limit', e);
      rethrow;
    }
  }

  // Get upcoming payment
  Future<Map<String, dynamic>> getUpcomingPayment(String factoryId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/subscription/upcoming-payment/$factoryId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw ServerException(
          'Failed to fetch upcoming payment',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      ErrorLogger.error('Error fetching upcoming payment', e);
      rethrow;
    }
  }

  // Update payment method
  Future<Map<String, dynamic>> updatePaymentMethod({
    required String factoryId,
    required String paymentMethodId,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/subscription/payment-method'),
        headers: _headers,
        body: jsonEncode({
          'factory_id': factoryId,
          'payment_method_id': paymentMethodId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw ServerException(
          'Failed to update payment method',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      ErrorLogger.error('Error updating payment method', e);
      rethrow;
    }
  }

  // Get subscription analytics
  Future<Map<String, dynamic>> getSubscriptionAnalytics({
    required String factoryId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final params = <String, String>{'factory_id': factoryId};
      if (startDate != null) {
        params['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        params['end_date'] = endDate.toIso8601String();
      }

      final uri = Uri.parse(
        '$_baseUrl/subscription/analytics',
      ).replace(queryParameters: params);

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw ServerException(
          'Failed to fetch subscription analytics',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      ErrorLogger.error('Error fetching subscription analytics', e);
      rethrow;
    }
  }
}

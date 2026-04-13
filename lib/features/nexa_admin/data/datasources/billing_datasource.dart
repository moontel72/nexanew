import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nexatrace_system/core/errors/app_exceptions.dart';
import 'package:nexatrace_system/core/services/api_client.dart';
import 'package:nexatrace_system/features/nexa_admin/data/models/invoice_model.dart';
import 'package:nexatrace_system/shared/models/billing/invoice_model.dart'
    as shared;
import 'package:nexatrace_system/shared/models/company/company_model.dart';

part 'billing_datasource.freezed.dart';
part 'billing_datasource.g.dart';

abstract class BillingDataSource {
  Future<List<AdminInvoice>> getPlatformInvoices({
    DateTime? startDate,
    DateTime? endDate,
    List<shared.InvoiceStatus>? statuses,
    String? searchQuery,
    int page = 1,
    int limit = 20,
  });

  Future<AdminInvoice> getInvoiceById(String invoiceId);

  Future<List<AdminInvoice>> getCompanyInvoices(
    String companyId, {
    DateTime? startDate,
    DateTime? endDate,
    List<shared.InvoiceStatus>? statuses,
    int page = 1,
    int limit = 20,
  });

  Future<AdminInvoice> generateInvoice({
    required String companyId,
    required String subscriptionId,
    required DateTime periodStart,
    required DateTime periodEnd,
    required List<shared.InvoiceItem> items,
    String? notes,
  });

  Future<AdminInvoice> updateInvoiceStatus(
    String invoiceId,
    shared.InvoiceStatus status,
  );

  Future<void> sendInvoiceNotification(String invoiceId);

  Future<List<shared.Payment>> getInvoicePayments(String invoiceId);

  Future<shared.Payment> recordPayment({
    required String invoiceId,
    required double amount,
    required shared.PaymentMethod method,
    required DateTime paymentDate,
    String? reference,
    String? transactionId,
    String? notes,
  });

  Future<List<Company>> getCompaniesWithOverdueInvoices();

  Future<Map<String, dynamic>> getPlatformRevenueSummary({
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<List<Map<String, dynamic>>> getRevenueByCompany({
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<CreditNote> createCreditNote({
    required String invoiceId,
    required double amount,
    required String reason,
    String? notes,
  });

  Future<List<CreditNote>> getCreditNotes({
    DateTime? startDate,
    DateTime? endDate,
    String? companyId,
    int page = 1,
    int limit = 20,
  });

  Future<void> reconcilePayments(DateTime reconciliationDate);
}

class BillingDataSourceImpl implements BillingDataSource {
  final ApiClient _apiClient;

  BillingDataSourceImpl(this._apiClient);

  List<dynamic> _extractList(dynamic responseData, {String? key}) {
    if (responseData is! Map) {
      return const [];
    }

    final data = responseData['data'];
    if (data is Map) {
      final list = key != null ? data[key] : data;
      return list is List ? list : const [];
    }
    if (data is List) {
      return data;
    }
    return const [];
  }

  Map<String, dynamic> _extractMap(dynamic responseData, {String? key}) {
    if (responseData is! Map) {
      return <String, dynamic>{};
    }

    final data = responseData['data'];
    if (data is Map) {
      if (key == null) {
        return Map<String, dynamic>.from(data);
      }
      final inner = data[key];
      if (inner is Map) {
        return Map<String, dynamic>.from(inner);
      }
      return Map<String, dynamic>.from(data);
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return <String, dynamic>{};
  }

  @override
  Future<List<AdminInvoice>> getPlatformInvoices({
    DateTime? startDate,
    DateTime? endDate,
    List<shared.InvoiceStatus>? statuses,
    String? searchQuery,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final params = {
        'page': page,
        'limit': limit,
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
        if (statuses != null && statuses.isNotEmpty)
          'statuses': statuses
              .map((s) => s.toString().split('.').last)
              .toList(),
        if (searchQuery != null && searchQuery.isNotEmpty)
          'search': searchQuery,
      };

      final response = await _apiClient.get(
        '/admin/billing/invoices',
        queryParams: params,
      );

      final list = _extractList(response, key: 'invoices');
      return list
          .whereType<Map>()
          .map((item) => AdminInvoice.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<AdminInvoice> getInvoiceById(String invoiceId) async {
    try {
      final response = await _apiClient.get(
        '/admin/billing/invoices/$invoiceId',
      );
      return AdminInvoice.fromJson(_extractMap(response, key: 'invoice'));
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<List<AdminInvoice>> getCompanyInvoices(
    String companyId, {
    DateTime? startDate,
    DateTime? endDate,
    List<shared.InvoiceStatus>? statuses,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final params = {
        'page': page,
        'limit': limit,
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
        if (statuses != null && statuses.isNotEmpty)
          'statuses': statuses
              .map((s) => s.toString().split('.').last)
              .toList(),
      };

      final response = await _apiClient.get(
        '/admin/billing/companies/$companyId/invoices',
        queryParams: params,
      );

      final list = _extractList(response, key: 'invoices');
      return list
          .whereType<Map>()
          .map((item) => AdminInvoice.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<AdminInvoice> generateInvoice({
    required String companyId,
    required String subscriptionId,
    required DateTime periodStart,
    required DateTime periodEnd,
    required List<shared.InvoiceItem> items,
    String? notes,
  }) async {
    try {
      final data = {
        'company_id': companyId,
        'subscription_id': subscriptionId,
        'period_start': periodStart.toIso8601String(),
        'period_end': periodEnd.toIso8601String(),
        'items': items.map((item) => item.toJson()).toList(),
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };

      final response = await _apiClient.post(
        '/admin/billing/invoices/generate',
        body: data,
      );

      return AdminInvoice.fromJson(_extractMap(response, key: 'invoice'));
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<AdminInvoice> updateInvoiceStatus(
    String invoiceId,
    shared.InvoiceStatus status,
  ) async {
    try {
      final response = await _apiClient.put(
        '/admin/billing/invoices/$invoiceId/status',
        body: {'status': status.toString().split('.').last},
      );

      return AdminInvoice.fromJson(_extractMap(response, key: 'invoice'));
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<void> sendInvoiceNotification(String invoiceId) async {
    try {
      await _apiClient.post('/admin/billing/invoices/$invoiceId/notify');
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<List<shared.Payment>> getInvoicePayments(String invoiceId) async {
    try {
      final response = await _apiClient.get(
        '/admin/billing/invoices/$invoiceId/payments',
      );
      final list = _extractList(response, key: 'payments');
      return list
          .whereType<Map>()
          .map((item) => shared.Payment.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<shared.Payment> recordPayment({
    required String invoiceId,
    required double amount,
    required shared.PaymentMethod method,
    required DateTime paymentDate,
    String? reference,
    String? transactionId,
    String? notes,
  }) async {
    try {
      final data = {
        'amount': amount,
        'method': method.toString().split('.').last,
        'payment_date': paymentDate.toIso8601String(),
        if (reference != null && reference.isNotEmpty) 'reference': reference,
        if (transactionId != null && transactionId.isNotEmpty)
          'transaction_id': transactionId,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };

      final response = await _apiClient.post(
        '/admin/billing/invoices/$invoiceId/payments',
        body: data,
      );

      final paymentMap = _extractMap(response, key: 'payment');
      return shared.Payment.fromJson(
        paymentMap.isEmpty ? _extractMap(response) : paymentMap,
      );
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<List<Company>> getCompaniesWithOverdueInvoices() async {
    try {
      final response = await _apiClient.get('/admin/billing/companies/overdue');
      final list = _extractList(response, key: 'companies');
      return list
          .whereType<Map>()
          .map((item) => Company.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getPlatformRevenueSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final params = {
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      };

      final response = await _apiClient.get(
        '/admin/billing/revenue/summary',
        queryParams: params,
      );

      return _extractMap(response, key: 'summary');
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getRevenueByCompany({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final params = {
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      };

      final response = await _apiClient.get(
        '/admin/billing/revenue/by-company',
        queryParams: params,
      );

      final list = _extractList(response, key: 'companies');
      return list.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<CreditNote> createCreditNote({
    required String invoiceId,
    required double amount,
    required String reason,
    String? notes,
  }) async {
    try {
      final data = {
        'invoice_id': invoiceId,
        'amount': amount,
        'reason': reason,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };

      final response = await _apiClient.post(
        '/admin/billing/credit-notes',
        body: data,
      );

      return CreditNote.fromJson(_extractMap(response, key: 'credit_note'));
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<List<CreditNote>> getCreditNotes({
    DateTime? startDate,
    DateTime? endDate,
    String? companyId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final params = {
        'page': page,
        'limit': limit,
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
        if (companyId != null && companyId.isNotEmpty) 'company_id': companyId,
      };

      final response = await _apiClient.get(
        '/admin/billing/credit-notes',
        queryParams: params,
      );

      final list = _extractList(response, key: 'credit_notes');
      return list
          .whereType<Map>()
          .map((item) => CreditNote.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<void> reconcilePayments(DateTime reconciliationDate) async {
    try {
      await _apiClient.post(
        '/admin/billing/reconcile',
        data: {'reconciliation_date': reconciliationDate.toIso8601String()},
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to reconcile payments',
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }
}

@freezed
abstract class CreditNote with _$CreditNote {
  const factory CreditNote({
    required String id,
    required String invoiceId,
    required String creditNoteNumber,
    required double amount,
    required String reason,
    required DateTime issueDate,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _CreditNote;

  factory CreditNote.fromJson(Map<String, dynamic> json) =>
      _$CreditNoteFromJson(json);
}

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:trace_odd/core/errors/app_exceptions.dart';
import 'package:trace_odd/core/services/api_client.dart';
import 'package:trace_odd/features/nexa_admin/data/models/invoice_model.dart';
import 'package:trace_odd/shared/models/billing/invoice_model.dart'
    as shared;
import 'package:trace_odd/shared/models/company/company_model.dart';

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

  String _paymentMethodToWireValue(shared.PaymentMethod method) {
    switch (method) {
      case shared.PaymentMethod.wallet:
        return 'wallet';
      case shared.PaymentMethod.creditCard:
        return 'credit_card';
      case shared.PaymentMethod.bankTransfer:
        return 'bank_transfer';
      case shared.PaymentMethod.cash:
        return 'cash';
      case shared.PaymentMethod.other:
        return 'other';
    }
  }

  String _normalizePaymentMethodWireValue(dynamic value) {
    final raw = value?.toString().trim() ?? '';
    if (raw.isEmpty || raw.toLowerCase() == 'null') return 'bank_transfer';

    final lowered = raw.toLowerCase();
    if (lowered == 'system') return 'bank_transfer';

    final compact = lowered.replaceAll(RegExp(r'[\s_-]'), '');
    switch (compact) {
      case 'wallet':
        return 'wallet';
      case 'cash':
        return 'cash';
      case 'other':
        return 'other';
      case 'creditcard':
        return 'credit_card';
      case 'banktransfer':
        return 'bank_transfer';
    }

    if (shared.PaymentMethod.values.any((e) => e.name.toLowerCase() == compact)) {
      if (compact == shared.PaymentMethod.creditCard.name.toLowerCase()) {
        return 'credit_card';
      }
      if (compact == shared.PaymentMethod.bankTransfer.name.toLowerCase()) {
        return 'bank_transfer';
      }
      if (compact == shared.PaymentMethod.wallet.name.toLowerCase()) return 'wallet';
      if (compact == shared.PaymentMethod.cash.name.toLowerCase()) return 'cash';
      if (compact == shared.PaymentMethod.other.name.toLowerCase()) return 'other';
    }

    return 'other';
  }

  Map<String, dynamic> _normalizeAdminInvoiceJson(Map<String, dynamic> json) {
    final m = Map<String, dynamic>.from(json);

    final issueDate = _toIsoDate(m['issueDate'] ?? m['issue_date'] ?? m['created_at']);
    final dueDate = _toIsoDate(m['dueDate'] ?? m['due_date'] ?? issueDate);
    final periodStart = _toIsoDate(m['periodStart'] ?? m['period_start'] ?? issueDate);
    final periodEnd = _toIsoDate(m['periodEnd'] ?? m['period_end'] ?? dueDate);

    final rawItems = m['items'];
    final items = rawItems is List
        ? rawItems
            .whereType<Map>()
            .map((e) {
              final item = Map<String, dynamic>.from(e.cast<String, dynamic>());
              return {
                'id': _toStringValue(item['id']),
                'description': _toStringValue(item['description']),
                'quantity': _toDouble(item['quantity']),
                'unitPrice': _toDouble(item['unitPrice'] ?? item['unit_price']),
                'total': _toDouble(
                  item['total'] ?? item['total_price'] ?? item['totalPrice'],
                ),
                'currency': _toStringValue(item['currency'], fallback: 'USD'),
                'codeType': item['codeType'] ?? item['code_type'],
                'codeCount': (item['codeCount'] ?? item['code_count']) == null
                    ? null
                    : _toInt(item['codeCount'] ?? item['code_count']),
                'periodStart': item['periodStart'] ?? item['period_start'],
                'periodEnd': item['periodEnd'] ?? item['period_end'],
                'metadata': item['metadata'],
              };
            })
            .toList()
        : const <Map<String, dynamic>>[];

    return {
      'id': _toStringValue(m['id']),
      'invoiceNumber': _toStringValue(m['invoiceNumber'] ?? m['invoice_number']),
      'companyId': _toStringValue(m['companyId'] ?? m['company_id']),
      'companyName': _toStringValue(m['companyName'] ?? m['company_name']),
      'subscriptionId': _toStringValue(m['subscriptionId'] ?? m['subscription_id']),
      'subscriptionName': _toStringValue(
        m['subscriptionName'] ?? m['subscription_name'],
      ),
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
      'paymentMethod': _normalizePaymentMethodWireValue(
        m['paymentMethod'] ?? m['payment_method'],
      ),
      'paymentReference': m['paymentReference'] ?? m['payment_reference'],
      'notes': m['notes'],
      'metadata': m['metadata'],
      'createdAt': m['createdAt'] ?? m['created_at'],
      'updatedAt': m['updatedAt'] ?? m['updated_at'],
      'adminNotes': m['adminNotes'] ?? m['admin_notes'],
      'requiresFollowUp': m['requiresFollowUp'] ?? m['requires_follow_up'],
      'followUpReason': m['followUpReason'] ?? m['follow_up_reason'],
      'followUpDate': m['followUpDate'] ?? m['follow_up_date'],
      'assignedToAdminId': m['assignedToAdminId'] ?? m['assigned_to_admin_id'],
      'assignedToAdminName': m['assignedToAdminName'] ?? m['assigned_to_admin_name'],
    };
  }

  Map<String, dynamic> _normalizeSharedPaymentJson(Map<String, dynamic> json) {
    final m = Map<String, dynamic>.from(json);
    m['method'] = _normalizePaymentMethodWireValue(m['method'] ?? m['payment_method']);

    if (!m.containsKey('invoiceId') && m['invoice_id'] != null) {
      m['invoiceId'] = m['invoice_id'];
    }
    if (!m.containsKey('paymentDate') && m['payment_date'] != null) {
      m['paymentDate'] = m['payment_date'];
    }
    if (!m.containsKey('createdAt') && m['created_at'] != null) {
      m['createdAt'] = m['created_at'];
    }
    if (!m.containsKey('transactionId') && m['transaction_id'] != null) {
      m['transactionId'] = m['transaction_id'];
    }
    return m;
  }

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
          .map(
            (item) => AdminInvoice.fromJson(
              _normalizeAdminInvoiceJson(Map<String, dynamic>.from(item)),
            ),
          )
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
      return AdminInvoice.fromJson(
        _normalizeAdminInvoiceJson(_extractMap(response, key: 'invoice')),
      );
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
          .map(
            (item) => AdminInvoice.fromJson(
              _normalizeAdminInvoiceJson(Map<String, dynamic>.from(item)),
            ),
          )
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

      return AdminInvoice.fromJson(
        _normalizeAdminInvoiceJson(_extractMap(response, key: 'invoice')),
      );
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
      await _apiClient.put(
        '/admin/billing/invoices/$invoiceId/status',
        body: {'status': status.toString().split('.').last},
      );

      return getInvoiceById(invoiceId);
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<void> sendInvoiceNotification(String invoiceId) async {
    try {
      await _apiClient.post('/admin/billing/invoices/$invoiceId/send');
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
          .map(
            (item) => shared.Payment.fromJson(
              _normalizeSharedPaymentJson(Map<String, dynamic>.from(item)),
            ),
          )
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
        'method': _paymentMethodToWireValue(method),
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
        _normalizeSharedPaymentJson(
          paymentMap.isEmpty ? _extractMap(response) : paymentMap,
        ),
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
      return list
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
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
    } on AppException {
      rethrow;
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

import 'package:freezed_annotation/freezed_annotation.dart';

part 'invoice_model.freezed.dart';
part 'invoice_model.g.dart';

enum InvoiceStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('pending')
  pending,
  @JsonValue('paid')
  paid,
  @JsonValue('overdue')
  overdue,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('refunded')
  refunded,
}

enum PaymentMethod {
  @JsonValue('wallet')
  wallet,
  @JsonValue('credit_card')
  creditCard,
  @JsonValue('bank_transfer')
  bankTransfer,
  @JsonValue('cash')
  cash,
  @JsonValue('other')
  other,
}

@freezed
abstract class InvoiceItem with _$InvoiceItem {
  const factory InvoiceItem({
    required String id,
    required String description,
    required double quantity,
    required double unitPrice,
    required double total,
    required String currency,
    String? codeType,
    int? codeCount,
    DateTime? periodStart,
    DateTime? periodEnd,
    Map<String, dynamic>? metadata,
  }) = _InvoiceItem;

  factory InvoiceItem.fromJson(Map<String, dynamic> json) =>
      _$InvoiceItemFromJson(json);
}

@freezed
abstract class Invoice with _$Invoice {
  const factory Invoice({
    required String id,
    required String invoiceNumber,
    required String companyId,
    String? subscriptionId,
    required DateTime periodStart,
    required DateTime periodEnd,
    required DateTime issueDate,
    required DateTime dueDate,
    required double subtotal,
    required double taxAmount,
    required double discountAmount,
    required double totalAmount,
    @Default('USD') String currency,
    required List<InvoiceItem> items,
    @Default(InvoiceStatus.pending) InvoiceStatus status,
    DateTime? paymentDate,
    PaymentMethod? paymentMethod,
    String? paymentReference,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Invoice;

  factory Invoice.fromJson(Map<String, dynamic> json) =>
      _$InvoiceFromJson(json);

  factory Invoice.empty() => Invoice(
        id: '',
        invoiceNumber: '',
        companyId: '',
        periodStart: DateTime.now(),
        periodEnd: DateTime.now(),
        issueDate: DateTime.now(),
        dueDate: DateTime.now(),
        subtotal: 0.0,
        taxAmount: 0.0,
        discountAmount: 0.0,
        totalAmount: 0.0,
        items: [],
      );
}

@freezed
abstract class BillingSummary with _$BillingSummary {
  const factory BillingSummary({
    @Default(0.0) double totalOwed,
    @Default(0.0) double totalPaid,
    @Default(0) int pendingInvoices,
    @Default(0) int paidInvoices,
    @Default(0) int overdueInvoices,
    DateTime? nextPaymentDate,
    double? nextPaymentAmount,
    String? nextPaymentCurrency,
    Map<String, dynamic>? usageSummary,
  }) = _BillingSummary;

  factory BillingSummary.fromJson(Map<String, dynamic> json) =>
      _$BillingSummaryFromJson(json);
}

@freezed
abstract class Payment with _$Payment {
  const factory Payment({
    required String id,
    required String invoiceId,
    required double amount,
    required String currency,
    required PaymentMethod method,
    required DateTime paymentDate,
    String? reference,
    String? transactionId,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) = _Payment;

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);
}

@freezed
abstract class BillingFilter with _$BillingFilter {
  const factory BillingFilter({
    DateTime? startDate,
    DateTime? endDate,
    List<InvoiceStatus>? statuses,
    double? minAmount,
    double? maxAmount,
    String? searchQuery,
    @Default('issueDate') String sortBy,
    @Default(false) bool sortDesc,
    @Default(1) int page,
    @Default(20) int limit,
  }) = _BillingFilter;

  factory BillingFilter.fromJson(Map<String, dynamic> json) =>
      _$BillingFilterFromJson(json);
}

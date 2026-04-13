import 'package:freezed_annotation/freezed_annotation.dart';

part 'billing_entity.freezed.dart';
part 'billing_entity.g.dart';

/// Core billing entity representing the fundamental billing concepts
/// in the super admin domain. This entity is independent of data source
/// details and focuses on business rules and validation.

@freezed
abstract class BillingEntity with _$BillingEntity {
  const factory BillingEntity({
    /// Unique identifier for the billing entity
    required String id,

    /// Type of billing entity (invoice, credit note, payment, etc.)
    required BillingEntityType type,

    /// Reference number for the entity (invoice number, credit note number, etc.)
    required String referenceNumber,

    /// Company associated with this billing entity
    required String companyId,
    required String companyName,

    /// Financial amounts
    required double amount,
    required String currency,

    /// Status of the billing entity
    required BillingEntityStatus status,

    /// Dates
    required DateTime issueDate,
    DateTime? dueDate,
    DateTime? paymentDate,
    DateTime? settlementDate,

    /// Payment information
    PaymentMethod? paymentMethod,
    String? paymentReference,
    String? transactionId,

    /// Notes and metadata
    String? notes,
    String? adminNotes,
    Map<String, dynamic>? metadata,

    /// Audit fields
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdByAdminId,
    String? updatedByAdminId,
  }) = _BillingEntity;

  const BillingEntity._();

  factory BillingEntity.fromJson(Map<String, dynamic> json) =>
      _$BillingEntityFromJson(json);

  /// Creates an empty billing entity for initialization
  factory BillingEntity.empty() => BillingEntity(
    id: '',
    type: BillingEntityType.invoice,
    referenceNumber: '',
    companyId: '',
    companyName: '',
    amount: 0.0,
    currency: 'USD',
    status: BillingEntityStatus.draft,
    issueDate: DateTime.now(),
  );

  /// Validates the billing entity according to business rules
  List<String> validate() {
    final errors = <String>[];

    if (id.isEmpty) {
      errors.add('Billing entity ID is required');
    }

    if (referenceNumber.isEmpty) {
      errors.add('Reference number is required');
    }

    if (companyId.isEmpty) {
      errors.add('Company ID is required');
    }

    if (companyName.isEmpty) {
      errors.add('Company name is required');
    }

    if (amount <= 0) {
      errors.add('Amount must be greater than 0');
    }

    if (currency.isEmpty) {
      errors.add('Currency is required');
    }

    if (dueDate != null && issueDate.isAfter(dueDate!)) {
      errors.add('Issue date cannot be after due date');
    }

    if (paymentDate != null && issueDate.isAfter(paymentDate!)) {
      errors.add('Issue date cannot be after payment date');
    }

    // Validate payment information based on status
    if (status == BillingEntityStatus.paid && paymentMethod == null) {
      errors.add('Payment method is required for paid entities');
    }

    if (status == BillingEntityStatus.paid && paymentDate == null) {
      errors.add('Payment date is required for paid entities');
    }

    return errors;
  }

  /// Checks if the billing entity is overdue
  bool get isOverdue {
    if (dueDate == null) return false;
    if (status == BillingEntityStatus.paid ||
        status == BillingEntityStatus.cancelled ||
        status == BillingEntityStatus.refunded) {
      return false;
    }
    return DateTime.now().isAfter(dueDate!);
  }

  /// Calculates days overdue (negative if not overdue)
  int get daysOverdue {
    if (!isOverdue || dueDate == null) return 0;
    return DateTime.now().difference(dueDate!).inDays;
  }

  /// Checks if the billing entity can be edited
  bool get canEdit {
    return status == BillingEntityStatus.draft ||
        status == BillingEntityStatus.pending;
  }

  /// Checks if the billing entity can be cancelled
  bool get canCancel {
    return status != BillingEntityStatus.cancelled &&
        status != BillingEntityStatus.refunded &&
        status != BillingEntityStatus.paid;
  }

  /// Checks if the billing entity can be marked as paid
  bool get canMarkAsPaid {
    return status == BillingEntityStatus.pending ||
        status == BillingEntityStatus.overdue;
  }

  /// Creates a copy with updated status
  BillingEntity withStatus(BillingEntityStatus newStatus) {
    return copyWith(status: newStatus);
  }

  /// Creates a copy with payment information
  BillingEntity withPayment({
    required PaymentMethod method,
    required DateTime paymentDate,
    String? reference,
    String? transactionId,
  }) {
    return copyWith(
      status: BillingEntityStatus.paid,
      paymentMethod: method,
      paymentDate: paymentDate,
      paymentReference: reference,
      transactionId: transactionId,
    );
  }
}

/// Types of billing entities in the system
enum BillingEntityType {
  @JsonValue('invoice')
  invoice,

  @JsonValue('credit_note')
  creditNote,

  @JsonValue('payment')
  payment,

  @JsonValue('refund')
  refund,

  @JsonValue('adjustment')
  adjustment,

  @JsonValue('reconciliation')
  reconciliation,
}

/// Status of billing entities
enum BillingEntityStatus {
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

  @JsonValue('partially_paid')
  partiallyPaid,

  @JsonValue('in_dispute')
  inDispute,

  @JsonValue('requires_review')
  requiresReview,
}

/// Payment methods accepted by the system
enum PaymentMethod {
  @JsonValue('wallet')
  wallet,

  @JsonValue('credit_card')
  creditCard,

  @JsonValue('bank_transfer')
  bankTransfer,

  @JsonValue('cash')
  cash,

  @JsonValue('check')
  check,

  @JsonValue('digital_wallet')
  digitalWallet,

  @JsonValue('other')
  other,
}

/// Billing period entity for recurring billing
@freezed
abstract class BillingPeriod with _$BillingPeriod {
  const factory BillingPeriod({
    required String id,
    required String companyId,
    required String subscriptionId,
    required DateTime periodStart,
    required DateTime periodEnd,
    required BillingPeriodStatus status,
    double? estimatedAmount,
    double? actualAmount,
    String? invoiceId,
    DateTime? invoicedAt,
    DateTime? paidAt,
    Map<String, dynamic>? usageData,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _BillingPeriod;

  factory BillingPeriod.fromJson(Map<String, dynamic> json) =>
      _$BillingPeriodFromJson(json);
}

enum BillingPeriodStatus {
  @JsonValue('upcoming')
  upcoming,

  @JsonValue('current')
  current,

  @JsonValue('invoiced')
  invoiced,

  @JsonValue('paid')
  paid,

  @JsonValue('overdue')
  overdue,

  @JsonValue('cancelled')
  cancelled,
}

/// Billing configuration for a company
@freezed
abstract class BillingConfiguration with _$BillingConfiguration {
  const factory BillingConfiguration({
    required String companyId,
    required String billingCycle, // monthly, quarterly, annually
    required int billingDay, // Day of month when billing occurs
    required String currency,
    required bool autoGenerateInvoices,
    required bool sendPaymentReminders,
    int? paymentGracePeriodDays,
    double? creditLimit,
    double? currentCreditUsed,
    List<String>? paymentMethods,
    String? defaultPaymentMethod,
    String? billingContactEmail,
    String? billingContactName,
    String? billingContactPhone,
    Map<String, dynamic>? taxSettings,
    Map<String, dynamic>? invoiceSettings,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _BillingConfiguration;

  factory BillingConfiguration.fromJson(Map<String, dynamic> json) =>
      _$BillingConfigurationFromJson(json);
}

/// Billing statistics for reporting and analytics
@freezed
abstract class BillingStatistics with _$BillingStatistics {
  const factory BillingStatistics({
    required DateTime periodStart,
    required DateTime periodEnd,
    required double totalRevenue,
    required double collectedRevenue,
    required double pendingRevenue,
    required double overdueRevenue,
    required int totalInvoices,
    required int paidInvoices,
    required int pendingInvoices,
    required int overdueInvoices,
    required double averagePaymentTimeDays,
    required double collectionRate,
    Map<String, double>? revenueByPlan,
    Map<String, double>? revenueByCompanyType,
    Map<String, int>? invoiceCountByStatus,
    List<RevenueTrendPoint>? revenueTrend,
    DateTime? calculatedAt,
  }) = _BillingStatistics;

  factory BillingStatistics.fromJson(Map<String, dynamic> json) =>
      _$BillingStatisticsFromJson(json);
}

@freezed
abstract class RevenueTrendPoint with _$RevenueTrendPoint {
  const factory RevenueTrendPoint({
    required DateTime date,
    required double revenue,
    required int invoiceCount,
    required int paidCount,
    double? averageAmount,
  }) = _RevenueTrendPoint;

  factory RevenueTrendPoint.fromJson(Map<String, dynamic> json) =>
      _$RevenueTrendPointFromJson(json);
}

/// Billing alert for monitoring and notifications
@freezed
abstract class BillingAlert with _$BillingAlert {
  const factory BillingAlert({
    required String id,
    required String companyId,
    required BillingAlertType type,
    required BillingAlertSeverity severity,
    required String title,
    required String description,
    required DateTime detectedAt,
    required bool isActive,
    DateTime? resolvedAt,
    String? resolvedBy,
    String? resolutionNotes,
    Map<String, dynamic>? alertData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _BillingAlert;

  factory BillingAlert.fromJson(Map<String, dynamic> json) =>
      _$BillingAlertFromJson(json);
}

enum BillingAlertType {
  @JsonValue('overdue_invoice')
  overdueInvoice,

  @JsonValue('credit_limit_exceeded')
  creditLimitExceeded,

  @JsonValue('payment_failed')
  paymentFailed,

  @JsonValue('unusual_activity')
  unusualActivity,

  @JsonValue('revenue_drop')
  revenueDrop,

  @JsonValue('collection_issue')
  collectionIssue,

  @JsonValue('system_error')
  systemError,
}

enum BillingAlertSeverity {
  @JsonValue('info')
  info,

  @JsonValue('low')
  low,

  @JsonValue('medium')
  medium,

  @JsonValue('high')
  high,

  @JsonValue('critical')
  critical,
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'credit_note_model.freezed.dart';
part 'credit_note_model.g.dart';

@freezed
abstract class CreditNote with _$CreditNote {
  const factory CreditNote({
    required String id,
    required String creditNoteNumber,
    required String invoiceId,
    required String invoiceNumber,
    required String companyId,
    required String companyName,
    required double amount,
    required String currency,
    required CreditNoteReason reason,
    required DateTime issueDate,
    required CreditNoteStatus status,
    String? notes,
    String? adminNotes,
    String? appliedToInvoiceId,
    String? appliedToInvoiceNumber,
    DateTime? appliedDate,
    double? remainingBalance,
    String? issuedByAdminId,
    String? issuedByAdminName,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _CreditNote;

  factory CreditNote.fromJson(Map<String, dynamic> json) =>
      _$CreditNoteFromJson(json);

  factory CreditNote.empty() => CreditNote(
    id: '',
    creditNoteNumber: '',
    invoiceId: '',
    invoiceNumber: '',
    companyId: '',
    companyName: '',
    amount: 0.0,
    currency: 'USD',
    reason: CreditNoteReason.other,
    issueDate: DateTime.now(),
    status: CreditNoteStatus.draft,
  );
}

enum CreditNoteStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('issued')
  issued,
  @JsonValue('applied')
  applied,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('expired')
  expired,
}

enum CreditNoteReason {
  @JsonValue('overpayment')
  overpayment,
  @JsonValue('service_issue')
  serviceIssue,
  @JsonValue('billing_error')
  billingError,
  @JsonValue('customer_satisfaction')
  customerSatisfaction,
  @JsonValue('promotional')
  promotional,
  @JsonValue('contract_termination')
  contractTermination,
  @JsonValue('price_adjustment')
  priceAdjustment,
  @JsonValue('other')
  other,
}

@freezed
abstract class CreditNoteApplication with _$CreditNoteApplication {
  const factory CreditNoteApplication({
    required String id,
    required String creditNoteId,
    required String invoiceId,
    required double appliedAmount,
    required DateTime applicationDate,
    required String appliedByAdminId,
    required String appliedByAdminName,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) = _CreditNoteApplication;

  factory CreditNoteApplication.fromJson(Map<String, dynamic> json) =>
      _$CreditNoteApplicationFromJson(json);
}

@freezed
abstract class CreditNoteSummary with _$CreditNoteSummary {
  const factory CreditNoteSummary({
    @Default(0.0) double totalIssued,
    @Default(0.0) double totalApplied,
    @Default(0.0) double totalUnused,
    @Default(0.0) double totalCancelled,
    @Default(0) int totalCount,
    @Default(0) int issuedCount,
    @Default(0) int appliedCount,
    @Default(0) int unusedCount,
    @Default(0) int cancelledCount,
    DateTime? periodStart,
    DateTime? periodEnd,
    Map<CreditNoteReason, double>? amountByReason,
    Map<CreditNoteReason, int>? countByReason,
  }) = _CreditNoteSummary;

  factory CreditNoteSummary.fromJson(Map<String, dynamic> json) =>
      _$CreditNoteSummaryFromJson(json);
}

@freezed
abstract class CreditNoteFilter with _$CreditNoteFilter {
  const factory CreditNoteFilter({
    DateTime? startDate,
    DateTime? endDate,
    List<CreditNoteStatus>? statuses,
    List<CreditNoteReason>? reasons,
    String? companyId,
    String? searchQuery,
    double? minAmount,
    double? maxAmount,
    @Default('issueDate') String sortBy,
    @Default(false) bool sortDesc,
    @Default(1) int page,
    @Default(20) int limit,
  }) = _CreditNoteFilter;

  factory CreditNoteFilter.fromJson(Map<String, dynamic> json) =>
      _$CreditNoteFilterFromJson(json);
}

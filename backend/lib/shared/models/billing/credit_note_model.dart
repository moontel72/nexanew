import 'package:freezed_annotation/freezed_annotation.dart';

part 'credit_note_model.freezed.dart';
part 'credit_note_model.g.dart';

enum CreditNoteStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('pending_approval')
  pendingApproval,
  @JsonValue('approved')
  approved,
  @JsonValue('applied')
  applied,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('expired')
  expired,
}

enum CreditNoteType {
  @JsonValue('refund')
  refund,
  @JsonValue('discount')
  discount,
  @JsonValue('adjustment')
  adjustment,
  @JsonValue('goodwill')
  goodwill,
  @JsonValue('other')
  other,
}

@freezed
abstract class CreditNoteItem with _$CreditNoteItem {
  const factory CreditNoteItem({
    required String id,
    required String description,
    required double quantity,
    required double unitPrice,
    required double total,
    required String currency,
    String? invoiceItemId,
    String? reason,
    Map<String, dynamic>? metadata,
  }) = _CreditNoteItem;

  factory CreditNoteItem.fromJson(Map<String, dynamic> json) =>
      _$CreditNoteItemFromJson(json);
}

@freezed
abstract class CreditNote with _$CreditNote {
  const factory CreditNote({
    required String id,
    required String creditNoteNumber,
    required String companyId,
    String? invoiceId,
    required CreditNoteType type,
    required String reason,
    required double totalAmount,
    @Default('USD') String currency,
    required List<CreditNoteItem> items,
    @Default(CreditNoteStatus.draft) CreditNoteStatus status,
    DateTime? approvalDate,
    String? approvedBy,
    DateTime? applicationDate,
    String? appliedToInvoiceId,
    DateTime? expiryDate,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _CreditNote;

  factory CreditNote.fromJson(Map<String, dynamic> json) =>
      _$CreditNoteFromJson(json);

  factory CreditNote.empty() => CreditNote(
    id: '',
    creditNoteNumber: '',
    companyId: '',
    type: CreditNoteType.other,
    reason: '',
    totalAmount: 0.0,
    items: [],
  );
}

@freezed
abstract class CreditNoteFilter with _$CreditNoteFilter {
  const factory CreditNoteFilter({
    DateTime? startDate,
    DateTime? endDate,
    List<CreditNoteStatus>? statuses,
    List<CreditNoteType>? types,
    double? minAmount,
    double? maxAmount,
    String? searchQuery,
    @Default('createdAt') String sortBy,
    @Default(false) bool sortDesc,
    @Default(1) int page,
    @Default(20) int limit,
  }) = _CreditNoteFilter;

  factory CreditNoteFilter.fromJson(Map<String, dynamic> json) =>
      _$CreditNoteFilterFromJson(json);
}

@freezed
abstract class CreditNoteSummary with _$CreditNoteSummary {
  const factory CreditNoteSummary({
    @Default(0.0) double totalIssued,
    @Default(0.0) double totalApplied,
    @Default(0.0) double totalAvailable,
    @Default(0) int draftCount,
    @Default(0) int pendingApprovalCount,
    @Default(0) int approvedCount,
    @Default(0) int appliedCount,
    @Default(0) int expiredCount,
    Map<String, double>? byType,
    Map<String, double>? byCompany,
  }) = _CreditNoteSummary;

  factory CreditNoteSummary.fromJson(Map<String, dynamic> json) =>
      _$CreditNoteSummaryFromJson(json);
}

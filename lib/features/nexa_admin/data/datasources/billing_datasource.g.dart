// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billing_datasource.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreditNote _$CreditNoteFromJson(Map<String, dynamic> json) => _CreditNote(
  id: json['id'] as String,
  invoiceId: json['invoice_id'] as String,
  creditNoteNumber: json['credit_note_number'] as String,
  amount: (json['amount'] as num).toDouble(),
  reason: json['reason'] as String,
  issueDate: DateTime.parse(json['issue_date'] as String),
  notes: json['notes'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$CreditNoteToJson(_CreditNote instance) =>
    <String, dynamic>{
      'id': instance.id,
      'invoice_id': instance.invoiceId,
      'credit_note_number': instance.creditNoteNumber,
      'amount': instance.amount,
      'reason': instance.reason,
      'issue_date': instance.issueDate.toIso8601String(),
      'notes': instance.notes,
      'metadata': instance.metadata,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

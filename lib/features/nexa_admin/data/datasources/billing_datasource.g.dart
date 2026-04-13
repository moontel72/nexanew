// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billing_datasource.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreditNote _$CreditNoteFromJson(Map<String, dynamic> json) => _CreditNote(
  id: json['id'] as String,
  invoiceId: json['invoiceId'] as String,
  creditNoteNumber: json['creditNoteNumber'] as String,
  amount: (json['amount'] as num).toDouble(),
  reason: json['reason'] as String,
  issueDate: DateTime.parse(json['issueDate'] as String),
  notes: json['notes'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$CreditNoteToJson(_CreditNote instance) =>
    <String, dynamic>{
      'id': instance.id,
      'invoiceId': instance.invoiceId,
      'creditNoteNumber': instance.creditNoteNumber,
      'amount': instance.amount,
      'reason': instance.reason,
      'issueDate': instance.issueDate.toIso8601String(),
      'notes': instance.notes,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

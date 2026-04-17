// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credit_note_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreditNote {

 String get id; String get creditNoteNumber; String get invoiceId; String get invoiceNumber; String get companyId; String get companyName; double get amount; String get currency; CreditNoteReason get reason; DateTime get issueDate; CreditNoteStatus get status; String? get notes; String? get adminNotes; String? get appliedToInvoiceId; String? get appliedToInvoiceNumber; DateTime? get appliedDate; double? get remainingBalance; String? get issuedByAdminId; String? get issuedByAdminName; Map<String, dynamic>? get metadata; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of CreditNote
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreditNoteCopyWith<CreditNote> get copyWith => _$CreditNoteCopyWithImpl<CreditNote>(this as CreditNote, _$identity);

  /// Serializes this CreditNote to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreditNote&&(identical(other.id, id) || other.id == id)&&(identical(other.creditNoteNumber, creditNoteNumber) || other.creditNoteNumber == creditNoteNumber)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.invoiceNumber, invoiceNumber) || other.invoiceNumber == invoiceNumber)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.issueDate, issueDate) || other.issueDate == issueDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.adminNotes, adminNotes) || other.adminNotes == adminNotes)&&(identical(other.appliedToInvoiceId, appliedToInvoiceId) || other.appliedToInvoiceId == appliedToInvoiceId)&&(identical(other.appliedToInvoiceNumber, appliedToInvoiceNumber) || other.appliedToInvoiceNumber == appliedToInvoiceNumber)&&(identical(other.appliedDate, appliedDate) || other.appliedDate == appliedDate)&&(identical(other.remainingBalance, remainingBalance) || other.remainingBalance == remainingBalance)&&(identical(other.issuedByAdminId, issuedByAdminId) || other.issuedByAdminId == issuedByAdminId)&&(identical(other.issuedByAdminName, issuedByAdminName) || other.issuedByAdminName == issuedByAdminName)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,creditNoteNumber,invoiceId,invoiceNumber,companyId,companyName,amount,currency,reason,issueDate,status,notes,adminNotes,appliedToInvoiceId,appliedToInvoiceNumber,appliedDate,remainingBalance,issuedByAdminId,issuedByAdminName,const DeepCollectionEquality().hash(metadata),createdAt,updatedAt]);

@override
String toString() {
  return 'CreditNote(id: $id, creditNoteNumber: $creditNoteNumber, invoiceId: $invoiceId, invoiceNumber: $invoiceNumber, companyId: $companyId, companyName: $companyName, amount: $amount, currency: $currency, reason: $reason, issueDate: $issueDate, status: $status, notes: $notes, adminNotes: $adminNotes, appliedToInvoiceId: $appliedToInvoiceId, appliedToInvoiceNumber: $appliedToInvoiceNumber, appliedDate: $appliedDate, remainingBalance: $remainingBalance, issuedByAdminId: $issuedByAdminId, issuedByAdminName: $issuedByAdminName, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CreditNoteCopyWith<$Res>  {
  factory $CreditNoteCopyWith(CreditNote value, $Res Function(CreditNote) _then) = _$CreditNoteCopyWithImpl;
@useResult
$Res call({
 String id, String creditNoteNumber, String invoiceId, String invoiceNumber, String companyId, String companyName, double amount, String currency, CreditNoteReason reason, DateTime issueDate, CreditNoteStatus status, String? notes, String? adminNotes, String? appliedToInvoiceId, String? appliedToInvoiceNumber, DateTime? appliedDate, double? remainingBalance, String? issuedByAdminId, String? issuedByAdminName, Map<String, dynamic>? metadata, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$CreditNoteCopyWithImpl<$Res>
    implements $CreditNoteCopyWith<$Res> {
  _$CreditNoteCopyWithImpl(this._self, this._then);

  final CreditNote _self;
  final $Res Function(CreditNote) _then;

/// Create a copy of CreditNote
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? creditNoteNumber = null,Object? invoiceId = null,Object? invoiceNumber = null,Object? companyId = null,Object? companyName = null,Object? amount = null,Object? currency = null,Object? reason = null,Object? issueDate = null,Object? status = null,Object? notes = freezed,Object? adminNotes = freezed,Object? appliedToInvoiceId = freezed,Object? appliedToInvoiceNumber = freezed,Object? appliedDate = freezed,Object? remainingBalance = freezed,Object? issuedByAdminId = freezed,Object? issuedByAdminName = freezed,Object? metadata = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,creditNoteNumber: null == creditNoteNumber ? _self.creditNoteNumber : creditNoteNumber // ignore: cast_nullable_to_non_nullable
as String,invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,invoiceNumber: null == invoiceNumber ? _self.invoiceNumber : invoiceNumber // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,companyName: null == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as CreditNoteReason,issueDate: null == issueDate ? _self.issueDate : issueDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CreditNoteStatus,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,adminNotes: freezed == adminNotes ? _self.adminNotes : adminNotes // ignore: cast_nullable_to_non_nullable
as String?,appliedToInvoiceId: freezed == appliedToInvoiceId ? _self.appliedToInvoiceId : appliedToInvoiceId // ignore: cast_nullable_to_non_nullable
as String?,appliedToInvoiceNumber: freezed == appliedToInvoiceNumber ? _self.appliedToInvoiceNumber : appliedToInvoiceNumber // ignore: cast_nullable_to_non_nullable
as String?,appliedDate: freezed == appliedDate ? _self.appliedDate : appliedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,remainingBalance: freezed == remainingBalance ? _self.remainingBalance : remainingBalance // ignore: cast_nullable_to_non_nullable
as double?,issuedByAdminId: freezed == issuedByAdminId ? _self.issuedByAdminId : issuedByAdminId // ignore: cast_nullable_to_non_nullable
as String?,issuedByAdminName: freezed == issuedByAdminName ? _self.issuedByAdminName : issuedByAdminName // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreditNote].
extension CreditNotePatterns on CreditNote {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreditNote value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreditNote() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreditNote value)  $default,){
final _that = this;
switch (_that) {
case _CreditNote():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreditNote value)?  $default,){
final _that = this;
switch (_that) {
case _CreditNote() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String creditNoteNumber,  String invoiceId,  String invoiceNumber,  String companyId,  String companyName,  double amount,  String currency,  CreditNoteReason reason,  DateTime issueDate,  CreditNoteStatus status,  String? notes,  String? adminNotes,  String? appliedToInvoiceId,  String? appliedToInvoiceNumber,  DateTime? appliedDate,  double? remainingBalance,  String? issuedByAdminId,  String? issuedByAdminName,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreditNote() when $default != null:
return $default(_that.id,_that.creditNoteNumber,_that.invoiceId,_that.invoiceNumber,_that.companyId,_that.companyName,_that.amount,_that.currency,_that.reason,_that.issueDate,_that.status,_that.notes,_that.adminNotes,_that.appliedToInvoiceId,_that.appliedToInvoiceNumber,_that.appliedDate,_that.remainingBalance,_that.issuedByAdminId,_that.issuedByAdminName,_that.metadata,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String creditNoteNumber,  String invoiceId,  String invoiceNumber,  String companyId,  String companyName,  double amount,  String currency,  CreditNoteReason reason,  DateTime issueDate,  CreditNoteStatus status,  String? notes,  String? adminNotes,  String? appliedToInvoiceId,  String? appliedToInvoiceNumber,  DateTime? appliedDate,  double? remainingBalance,  String? issuedByAdminId,  String? issuedByAdminName,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _CreditNote():
return $default(_that.id,_that.creditNoteNumber,_that.invoiceId,_that.invoiceNumber,_that.companyId,_that.companyName,_that.amount,_that.currency,_that.reason,_that.issueDate,_that.status,_that.notes,_that.adminNotes,_that.appliedToInvoiceId,_that.appliedToInvoiceNumber,_that.appliedDate,_that.remainingBalance,_that.issuedByAdminId,_that.issuedByAdminName,_that.metadata,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String creditNoteNumber,  String invoiceId,  String invoiceNumber,  String companyId,  String companyName,  double amount,  String currency,  CreditNoteReason reason,  DateTime issueDate,  CreditNoteStatus status,  String? notes,  String? adminNotes,  String? appliedToInvoiceId,  String? appliedToInvoiceNumber,  DateTime? appliedDate,  double? remainingBalance,  String? issuedByAdminId,  String? issuedByAdminName,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _CreditNote() when $default != null:
return $default(_that.id,_that.creditNoteNumber,_that.invoiceId,_that.invoiceNumber,_that.companyId,_that.companyName,_that.amount,_that.currency,_that.reason,_that.issueDate,_that.status,_that.notes,_that.adminNotes,_that.appliedToInvoiceId,_that.appliedToInvoiceNumber,_that.appliedDate,_that.remainingBalance,_that.issuedByAdminId,_that.issuedByAdminName,_that.metadata,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreditNote implements CreditNote {
  const _CreditNote({required this.id, required this.creditNoteNumber, required this.invoiceId, required this.invoiceNumber, required this.companyId, required this.companyName, required this.amount, required this.currency, required this.reason, required this.issueDate, required this.status, this.notes, this.adminNotes, this.appliedToInvoiceId, this.appliedToInvoiceNumber, this.appliedDate, this.remainingBalance, this.issuedByAdminId, this.issuedByAdminName, final  Map<String, dynamic>? metadata, this.createdAt, this.updatedAt}): _metadata = metadata;
  factory _CreditNote.fromJson(Map<String, dynamic> json) => _$CreditNoteFromJson(json);

@override final  String id;
@override final  String creditNoteNumber;
@override final  String invoiceId;
@override final  String invoiceNumber;
@override final  String companyId;
@override final  String companyName;
@override final  double amount;
@override final  String currency;
@override final  CreditNoteReason reason;
@override final  DateTime issueDate;
@override final  CreditNoteStatus status;
@override final  String? notes;
@override final  String? adminNotes;
@override final  String? appliedToInvoiceId;
@override final  String? appliedToInvoiceNumber;
@override final  DateTime? appliedDate;
@override final  double? remainingBalance;
@override final  String? issuedByAdminId;
@override final  String? issuedByAdminName;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of CreditNote
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreditNoteCopyWith<_CreditNote> get copyWith => __$CreditNoteCopyWithImpl<_CreditNote>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreditNoteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreditNote&&(identical(other.id, id) || other.id == id)&&(identical(other.creditNoteNumber, creditNoteNumber) || other.creditNoteNumber == creditNoteNumber)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.invoiceNumber, invoiceNumber) || other.invoiceNumber == invoiceNumber)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.issueDate, issueDate) || other.issueDate == issueDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.adminNotes, adminNotes) || other.adminNotes == adminNotes)&&(identical(other.appliedToInvoiceId, appliedToInvoiceId) || other.appliedToInvoiceId == appliedToInvoiceId)&&(identical(other.appliedToInvoiceNumber, appliedToInvoiceNumber) || other.appliedToInvoiceNumber == appliedToInvoiceNumber)&&(identical(other.appliedDate, appliedDate) || other.appliedDate == appliedDate)&&(identical(other.remainingBalance, remainingBalance) || other.remainingBalance == remainingBalance)&&(identical(other.issuedByAdminId, issuedByAdminId) || other.issuedByAdminId == issuedByAdminId)&&(identical(other.issuedByAdminName, issuedByAdminName) || other.issuedByAdminName == issuedByAdminName)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,creditNoteNumber,invoiceId,invoiceNumber,companyId,companyName,amount,currency,reason,issueDate,status,notes,adminNotes,appliedToInvoiceId,appliedToInvoiceNumber,appliedDate,remainingBalance,issuedByAdminId,issuedByAdminName,const DeepCollectionEquality().hash(_metadata),createdAt,updatedAt]);

@override
String toString() {
  return 'CreditNote(id: $id, creditNoteNumber: $creditNoteNumber, invoiceId: $invoiceId, invoiceNumber: $invoiceNumber, companyId: $companyId, companyName: $companyName, amount: $amount, currency: $currency, reason: $reason, issueDate: $issueDate, status: $status, notes: $notes, adminNotes: $adminNotes, appliedToInvoiceId: $appliedToInvoiceId, appliedToInvoiceNumber: $appliedToInvoiceNumber, appliedDate: $appliedDate, remainingBalance: $remainingBalance, issuedByAdminId: $issuedByAdminId, issuedByAdminName: $issuedByAdminName, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CreditNoteCopyWith<$Res> implements $CreditNoteCopyWith<$Res> {
  factory _$CreditNoteCopyWith(_CreditNote value, $Res Function(_CreditNote) _then) = __$CreditNoteCopyWithImpl;
@override @useResult
$Res call({
 String id, String creditNoteNumber, String invoiceId, String invoiceNumber, String companyId, String companyName, double amount, String currency, CreditNoteReason reason, DateTime issueDate, CreditNoteStatus status, String? notes, String? adminNotes, String? appliedToInvoiceId, String? appliedToInvoiceNumber, DateTime? appliedDate, double? remainingBalance, String? issuedByAdminId, String? issuedByAdminName, Map<String, dynamic>? metadata, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$CreditNoteCopyWithImpl<$Res>
    implements _$CreditNoteCopyWith<$Res> {
  __$CreditNoteCopyWithImpl(this._self, this._then);

  final _CreditNote _self;
  final $Res Function(_CreditNote) _then;

/// Create a copy of CreditNote
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? creditNoteNumber = null,Object? invoiceId = null,Object? invoiceNumber = null,Object? companyId = null,Object? companyName = null,Object? amount = null,Object? currency = null,Object? reason = null,Object? issueDate = null,Object? status = null,Object? notes = freezed,Object? adminNotes = freezed,Object? appliedToInvoiceId = freezed,Object? appliedToInvoiceNumber = freezed,Object? appliedDate = freezed,Object? remainingBalance = freezed,Object? issuedByAdminId = freezed,Object? issuedByAdminName = freezed,Object? metadata = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_CreditNote(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,creditNoteNumber: null == creditNoteNumber ? _self.creditNoteNumber : creditNoteNumber // ignore: cast_nullable_to_non_nullable
as String,invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,invoiceNumber: null == invoiceNumber ? _self.invoiceNumber : invoiceNumber // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,companyName: null == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as CreditNoteReason,issueDate: null == issueDate ? _self.issueDate : issueDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CreditNoteStatus,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,adminNotes: freezed == adminNotes ? _self.adminNotes : adminNotes // ignore: cast_nullable_to_non_nullable
as String?,appliedToInvoiceId: freezed == appliedToInvoiceId ? _self.appliedToInvoiceId : appliedToInvoiceId // ignore: cast_nullable_to_non_nullable
as String?,appliedToInvoiceNumber: freezed == appliedToInvoiceNumber ? _self.appliedToInvoiceNumber : appliedToInvoiceNumber // ignore: cast_nullable_to_non_nullable
as String?,appliedDate: freezed == appliedDate ? _self.appliedDate : appliedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,remainingBalance: freezed == remainingBalance ? _self.remainingBalance : remainingBalance // ignore: cast_nullable_to_non_nullable
as double?,issuedByAdminId: freezed == issuedByAdminId ? _self.issuedByAdminId : issuedByAdminId // ignore: cast_nullable_to_non_nullable
as String?,issuedByAdminName: freezed == issuedByAdminName ? _self.issuedByAdminName : issuedByAdminName // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$CreditNoteApplication {

 String get id; String get creditNoteId; String get invoiceId; double get appliedAmount; DateTime get applicationDate; String get appliedByAdminId; String get appliedByAdminName; String? get notes; Map<String, dynamic>? get metadata; DateTime? get createdAt;
/// Create a copy of CreditNoteApplication
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreditNoteApplicationCopyWith<CreditNoteApplication> get copyWith => _$CreditNoteApplicationCopyWithImpl<CreditNoteApplication>(this as CreditNoteApplication, _$identity);

  /// Serializes this CreditNoteApplication to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreditNoteApplication&&(identical(other.id, id) || other.id == id)&&(identical(other.creditNoteId, creditNoteId) || other.creditNoteId == creditNoteId)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.appliedAmount, appliedAmount) || other.appliedAmount == appliedAmount)&&(identical(other.applicationDate, applicationDate) || other.applicationDate == applicationDate)&&(identical(other.appliedByAdminId, appliedByAdminId) || other.appliedByAdminId == appliedByAdminId)&&(identical(other.appliedByAdminName, appliedByAdminName) || other.appliedByAdminName == appliedByAdminName)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,creditNoteId,invoiceId,appliedAmount,applicationDate,appliedByAdminId,appliedByAdminName,notes,const DeepCollectionEquality().hash(metadata),createdAt);

@override
String toString() {
  return 'CreditNoteApplication(id: $id, creditNoteId: $creditNoteId, invoiceId: $invoiceId, appliedAmount: $appliedAmount, applicationDate: $applicationDate, appliedByAdminId: $appliedByAdminId, appliedByAdminName: $appliedByAdminName, notes: $notes, metadata: $metadata, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $CreditNoteApplicationCopyWith<$Res>  {
  factory $CreditNoteApplicationCopyWith(CreditNoteApplication value, $Res Function(CreditNoteApplication) _then) = _$CreditNoteApplicationCopyWithImpl;
@useResult
$Res call({
 String id, String creditNoteId, String invoiceId, double appliedAmount, DateTime applicationDate, String appliedByAdminId, String appliedByAdminName, String? notes, Map<String, dynamic>? metadata, DateTime? createdAt
});




}
/// @nodoc
class _$CreditNoteApplicationCopyWithImpl<$Res>
    implements $CreditNoteApplicationCopyWith<$Res> {
  _$CreditNoteApplicationCopyWithImpl(this._self, this._then);

  final CreditNoteApplication _self;
  final $Res Function(CreditNoteApplication) _then;

/// Create a copy of CreditNoteApplication
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? creditNoteId = null,Object? invoiceId = null,Object? appliedAmount = null,Object? applicationDate = null,Object? appliedByAdminId = null,Object? appliedByAdminName = null,Object? notes = freezed,Object? metadata = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,creditNoteId: null == creditNoteId ? _self.creditNoteId : creditNoteId // ignore: cast_nullable_to_non_nullable
as String,invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,appliedAmount: null == appliedAmount ? _self.appliedAmount : appliedAmount // ignore: cast_nullable_to_non_nullable
as double,applicationDate: null == applicationDate ? _self.applicationDate : applicationDate // ignore: cast_nullable_to_non_nullable
as DateTime,appliedByAdminId: null == appliedByAdminId ? _self.appliedByAdminId : appliedByAdminId // ignore: cast_nullable_to_non_nullable
as String,appliedByAdminName: null == appliedByAdminName ? _self.appliedByAdminName : appliedByAdminName // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreditNoteApplication].
extension CreditNoteApplicationPatterns on CreditNoteApplication {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreditNoteApplication value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreditNoteApplication() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreditNoteApplication value)  $default,){
final _that = this;
switch (_that) {
case _CreditNoteApplication():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreditNoteApplication value)?  $default,){
final _that = this;
switch (_that) {
case _CreditNoteApplication() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String creditNoteId,  String invoiceId,  double appliedAmount,  DateTime applicationDate,  String appliedByAdminId,  String appliedByAdminName,  String? notes,  Map<String, dynamic>? metadata,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreditNoteApplication() when $default != null:
return $default(_that.id,_that.creditNoteId,_that.invoiceId,_that.appliedAmount,_that.applicationDate,_that.appliedByAdminId,_that.appliedByAdminName,_that.notes,_that.metadata,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String creditNoteId,  String invoiceId,  double appliedAmount,  DateTime applicationDate,  String appliedByAdminId,  String appliedByAdminName,  String? notes,  Map<String, dynamic>? metadata,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _CreditNoteApplication():
return $default(_that.id,_that.creditNoteId,_that.invoiceId,_that.appliedAmount,_that.applicationDate,_that.appliedByAdminId,_that.appliedByAdminName,_that.notes,_that.metadata,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String creditNoteId,  String invoiceId,  double appliedAmount,  DateTime applicationDate,  String appliedByAdminId,  String appliedByAdminName,  String? notes,  Map<String, dynamic>? metadata,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _CreditNoteApplication() when $default != null:
return $default(_that.id,_that.creditNoteId,_that.invoiceId,_that.appliedAmount,_that.applicationDate,_that.appliedByAdminId,_that.appliedByAdminName,_that.notes,_that.metadata,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreditNoteApplication implements CreditNoteApplication {
  const _CreditNoteApplication({required this.id, required this.creditNoteId, required this.invoiceId, required this.appliedAmount, required this.applicationDate, required this.appliedByAdminId, required this.appliedByAdminName, this.notes, final  Map<String, dynamic>? metadata, this.createdAt}): _metadata = metadata;
  factory _CreditNoteApplication.fromJson(Map<String, dynamic> json) => _$CreditNoteApplicationFromJson(json);

@override final  String id;
@override final  String creditNoteId;
@override final  String invoiceId;
@override final  double appliedAmount;
@override final  DateTime applicationDate;
@override final  String appliedByAdminId;
@override final  String appliedByAdminName;
@override final  String? notes;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  DateTime? createdAt;

/// Create a copy of CreditNoteApplication
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreditNoteApplicationCopyWith<_CreditNoteApplication> get copyWith => __$CreditNoteApplicationCopyWithImpl<_CreditNoteApplication>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreditNoteApplicationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreditNoteApplication&&(identical(other.id, id) || other.id == id)&&(identical(other.creditNoteId, creditNoteId) || other.creditNoteId == creditNoteId)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.appliedAmount, appliedAmount) || other.appliedAmount == appliedAmount)&&(identical(other.applicationDate, applicationDate) || other.applicationDate == applicationDate)&&(identical(other.appliedByAdminId, appliedByAdminId) || other.appliedByAdminId == appliedByAdminId)&&(identical(other.appliedByAdminName, appliedByAdminName) || other.appliedByAdminName == appliedByAdminName)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,creditNoteId,invoiceId,appliedAmount,applicationDate,appliedByAdminId,appliedByAdminName,notes,const DeepCollectionEquality().hash(_metadata),createdAt);

@override
String toString() {
  return 'CreditNoteApplication(id: $id, creditNoteId: $creditNoteId, invoiceId: $invoiceId, appliedAmount: $appliedAmount, applicationDate: $applicationDate, appliedByAdminId: $appliedByAdminId, appliedByAdminName: $appliedByAdminName, notes: $notes, metadata: $metadata, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$CreditNoteApplicationCopyWith<$Res> implements $CreditNoteApplicationCopyWith<$Res> {
  factory _$CreditNoteApplicationCopyWith(_CreditNoteApplication value, $Res Function(_CreditNoteApplication) _then) = __$CreditNoteApplicationCopyWithImpl;
@override @useResult
$Res call({
 String id, String creditNoteId, String invoiceId, double appliedAmount, DateTime applicationDate, String appliedByAdminId, String appliedByAdminName, String? notes, Map<String, dynamic>? metadata, DateTime? createdAt
});




}
/// @nodoc
class __$CreditNoteApplicationCopyWithImpl<$Res>
    implements _$CreditNoteApplicationCopyWith<$Res> {
  __$CreditNoteApplicationCopyWithImpl(this._self, this._then);

  final _CreditNoteApplication _self;
  final $Res Function(_CreditNoteApplication) _then;

/// Create a copy of CreditNoteApplication
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? creditNoteId = null,Object? invoiceId = null,Object? appliedAmount = null,Object? applicationDate = null,Object? appliedByAdminId = null,Object? appliedByAdminName = null,Object? notes = freezed,Object? metadata = freezed,Object? createdAt = freezed,}) {
  return _then(_CreditNoteApplication(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,creditNoteId: null == creditNoteId ? _self.creditNoteId : creditNoteId // ignore: cast_nullable_to_non_nullable
as String,invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,appliedAmount: null == appliedAmount ? _self.appliedAmount : appliedAmount // ignore: cast_nullable_to_non_nullable
as double,applicationDate: null == applicationDate ? _self.applicationDate : applicationDate // ignore: cast_nullable_to_non_nullable
as DateTime,appliedByAdminId: null == appliedByAdminId ? _self.appliedByAdminId : appliedByAdminId // ignore: cast_nullable_to_non_nullable
as String,appliedByAdminName: null == appliedByAdminName ? _self.appliedByAdminName : appliedByAdminName // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$CreditNoteSummary {

 double get totalIssued; double get totalApplied; double get totalUnused; double get totalCancelled; int get totalCount; int get issuedCount; int get appliedCount; int get unusedCount; int get cancelledCount; DateTime? get periodStart; DateTime? get periodEnd; Map<CreditNoteReason, double>? get amountByReason; Map<CreditNoteReason, int>? get countByReason;
/// Create a copy of CreditNoteSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreditNoteSummaryCopyWith<CreditNoteSummary> get copyWith => _$CreditNoteSummaryCopyWithImpl<CreditNoteSummary>(this as CreditNoteSummary, _$identity);

  /// Serializes this CreditNoteSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreditNoteSummary&&(identical(other.totalIssued, totalIssued) || other.totalIssued == totalIssued)&&(identical(other.totalApplied, totalApplied) || other.totalApplied == totalApplied)&&(identical(other.totalUnused, totalUnused) || other.totalUnused == totalUnused)&&(identical(other.totalCancelled, totalCancelled) || other.totalCancelled == totalCancelled)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.issuedCount, issuedCount) || other.issuedCount == issuedCount)&&(identical(other.appliedCount, appliedCount) || other.appliedCount == appliedCount)&&(identical(other.unusedCount, unusedCount) || other.unusedCount == unusedCount)&&(identical(other.cancelledCount, cancelledCount) || other.cancelledCount == cancelledCount)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&const DeepCollectionEquality().equals(other.amountByReason, amountByReason)&&const DeepCollectionEquality().equals(other.countByReason, countByReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalIssued,totalApplied,totalUnused,totalCancelled,totalCount,issuedCount,appliedCount,unusedCount,cancelledCount,periodStart,periodEnd,const DeepCollectionEquality().hash(amountByReason),const DeepCollectionEquality().hash(countByReason));

@override
String toString() {
  return 'CreditNoteSummary(totalIssued: $totalIssued, totalApplied: $totalApplied, totalUnused: $totalUnused, totalCancelled: $totalCancelled, totalCount: $totalCount, issuedCount: $issuedCount, appliedCount: $appliedCount, unusedCount: $unusedCount, cancelledCount: $cancelledCount, periodStart: $periodStart, periodEnd: $periodEnd, amountByReason: $amountByReason, countByReason: $countByReason)';
}


}

/// @nodoc
abstract mixin class $CreditNoteSummaryCopyWith<$Res>  {
  factory $CreditNoteSummaryCopyWith(CreditNoteSummary value, $Res Function(CreditNoteSummary) _then) = _$CreditNoteSummaryCopyWithImpl;
@useResult
$Res call({
 double totalIssued, double totalApplied, double totalUnused, double totalCancelled, int totalCount, int issuedCount, int appliedCount, int unusedCount, int cancelledCount, DateTime? periodStart, DateTime? periodEnd, Map<CreditNoteReason, double>? amountByReason, Map<CreditNoteReason, int>? countByReason
});




}
/// @nodoc
class _$CreditNoteSummaryCopyWithImpl<$Res>
    implements $CreditNoteSummaryCopyWith<$Res> {
  _$CreditNoteSummaryCopyWithImpl(this._self, this._then);

  final CreditNoteSummary _self;
  final $Res Function(CreditNoteSummary) _then;

/// Create a copy of CreditNoteSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalIssued = null,Object? totalApplied = null,Object? totalUnused = null,Object? totalCancelled = null,Object? totalCount = null,Object? issuedCount = null,Object? appliedCount = null,Object? unusedCount = null,Object? cancelledCount = null,Object? periodStart = freezed,Object? periodEnd = freezed,Object? amountByReason = freezed,Object? countByReason = freezed,}) {
  return _then(_self.copyWith(
totalIssued: null == totalIssued ? _self.totalIssued : totalIssued // ignore: cast_nullable_to_non_nullable
as double,totalApplied: null == totalApplied ? _self.totalApplied : totalApplied // ignore: cast_nullable_to_non_nullable
as double,totalUnused: null == totalUnused ? _self.totalUnused : totalUnused // ignore: cast_nullable_to_non_nullable
as double,totalCancelled: null == totalCancelled ? _self.totalCancelled : totalCancelled // ignore: cast_nullable_to_non_nullable
as double,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,issuedCount: null == issuedCount ? _self.issuedCount : issuedCount // ignore: cast_nullable_to_non_nullable
as int,appliedCount: null == appliedCount ? _self.appliedCount : appliedCount // ignore: cast_nullable_to_non_nullable
as int,unusedCount: null == unusedCount ? _self.unusedCount : unusedCount // ignore: cast_nullable_to_non_nullable
as int,cancelledCount: null == cancelledCount ? _self.cancelledCount : cancelledCount // ignore: cast_nullable_to_non_nullable
as int,periodStart: freezed == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime?,periodEnd: freezed == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,amountByReason: freezed == amountByReason ? _self.amountByReason : amountByReason // ignore: cast_nullable_to_non_nullable
as Map<CreditNoteReason, double>?,countByReason: freezed == countByReason ? _self.countByReason : countByReason // ignore: cast_nullable_to_non_nullable
as Map<CreditNoteReason, int>?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreditNoteSummary].
extension CreditNoteSummaryPatterns on CreditNoteSummary {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreditNoteSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreditNoteSummary() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreditNoteSummary value)  $default,){
final _that = this;
switch (_that) {
case _CreditNoteSummary():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreditNoteSummary value)?  $default,){
final _that = this;
switch (_that) {
case _CreditNoteSummary() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double totalIssued,  double totalApplied,  double totalUnused,  double totalCancelled,  int totalCount,  int issuedCount,  int appliedCount,  int unusedCount,  int cancelledCount,  DateTime? periodStart,  DateTime? periodEnd,  Map<CreditNoteReason, double>? amountByReason,  Map<CreditNoteReason, int>? countByReason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreditNoteSummary() when $default != null:
return $default(_that.totalIssued,_that.totalApplied,_that.totalUnused,_that.totalCancelled,_that.totalCount,_that.issuedCount,_that.appliedCount,_that.unusedCount,_that.cancelledCount,_that.periodStart,_that.periodEnd,_that.amountByReason,_that.countByReason);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double totalIssued,  double totalApplied,  double totalUnused,  double totalCancelled,  int totalCount,  int issuedCount,  int appliedCount,  int unusedCount,  int cancelledCount,  DateTime? periodStart,  DateTime? periodEnd,  Map<CreditNoteReason, double>? amountByReason,  Map<CreditNoteReason, int>? countByReason)  $default,) {final _that = this;
switch (_that) {
case _CreditNoteSummary():
return $default(_that.totalIssued,_that.totalApplied,_that.totalUnused,_that.totalCancelled,_that.totalCount,_that.issuedCount,_that.appliedCount,_that.unusedCount,_that.cancelledCount,_that.periodStart,_that.periodEnd,_that.amountByReason,_that.countByReason);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double totalIssued,  double totalApplied,  double totalUnused,  double totalCancelled,  int totalCount,  int issuedCount,  int appliedCount,  int unusedCount,  int cancelledCount,  DateTime? periodStart,  DateTime? periodEnd,  Map<CreditNoteReason, double>? amountByReason,  Map<CreditNoteReason, int>? countByReason)?  $default,) {final _that = this;
switch (_that) {
case _CreditNoteSummary() when $default != null:
return $default(_that.totalIssued,_that.totalApplied,_that.totalUnused,_that.totalCancelled,_that.totalCount,_that.issuedCount,_that.appliedCount,_that.unusedCount,_that.cancelledCount,_that.periodStart,_that.periodEnd,_that.amountByReason,_that.countByReason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreditNoteSummary implements CreditNoteSummary {
  const _CreditNoteSummary({this.totalIssued = 0.0, this.totalApplied = 0.0, this.totalUnused = 0.0, this.totalCancelled = 0.0, this.totalCount = 0, this.issuedCount = 0, this.appliedCount = 0, this.unusedCount = 0, this.cancelledCount = 0, this.periodStart, this.periodEnd, final  Map<CreditNoteReason, double>? amountByReason, final  Map<CreditNoteReason, int>? countByReason}): _amountByReason = amountByReason,_countByReason = countByReason;
  factory _CreditNoteSummary.fromJson(Map<String, dynamic> json) => _$CreditNoteSummaryFromJson(json);

@override@JsonKey() final  double totalIssued;
@override@JsonKey() final  double totalApplied;
@override@JsonKey() final  double totalUnused;
@override@JsonKey() final  double totalCancelled;
@override@JsonKey() final  int totalCount;
@override@JsonKey() final  int issuedCount;
@override@JsonKey() final  int appliedCount;
@override@JsonKey() final  int unusedCount;
@override@JsonKey() final  int cancelledCount;
@override final  DateTime? periodStart;
@override final  DateTime? periodEnd;
 final  Map<CreditNoteReason, double>? _amountByReason;
@override Map<CreditNoteReason, double>? get amountByReason {
  final value = _amountByReason;
  if (value == null) return null;
  if (_amountByReason is EqualUnmodifiableMapView) return _amountByReason;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<CreditNoteReason, int>? _countByReason;
@override Map<CreditNoteReason, int>? get countByReason {
  final value = _countByReason;
  if (value == null) return null;
  if (_countByReason is EqualUnmodifiableMapView) return _countByReason;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of CreditNoteSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreditNoteSummaryCopyWith<_CreditNoteSummary> get copyWith => __$CreditNoteSummaryCopyWithImpl<_CreditNoteSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreditNoteSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreditNoteSummary&&(identical(other.totalIssued, totalIssued) || other.totalIssued == totalIssued)&&(identical(other.totalApplied, totalApplied) || other.totalApplied == totalApplied)&&(identical(other.totalUnused, totalUnused) || other.totalUnused == totalUnused)&&(identical(other.totalCancelled, totalCancelled) || other.totalCancelled == totalCancelled)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.issuedCount, issuedCount) || other.issuedCount == issuedCount)&&(identical(other.appliedCount, appliedCount) || other.appliedCount == appliedCount)&&(identical(other.unusedCount, unusedCount) || other.unusedCount == unusedCount)&&(identical(other.cancelledCount, cancelledCount) || other.cancelledCount == cancelledCount)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&const DeepCollectionEquality().equals(other._amountByReason, _amountByReason)&&const DeepCollectionEquality().equals(other._countByReason, _countByReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalIssued,totalApplied,totalUnused,totalCancelled,totalCount,issuedCount,appliedCount,unusedCount,cancelledCount,periodStart,periodEnd,const DeepCollectionEquality().hash(_amountByReason),const DeepCollectionEquality().hash(_countByReason));

@override
String toString() {
  return 'CreditNoteSummary(totalIssued: $totalIssued, totalApplied: $totalApplied, totalUnused: $totalUnused, totalCancelled: $totalCancelled, totalCount: $totalCount, issuedCount: $issuedCount, appliedCount: $appliedCount, unusedCount: $unusedCount, cancelledCount: $cancelledCount, periodStart: $periodStart, periodEnd: $periodEnd, amountByReason: $amountByReason, countByReason: $countByReason)';
}


}

/// @nodoc
abstract mixin class _$CreditNoteSummaryCopyWith<$Res> implements $CreditNoteSummaryCopyWith<$Res> {
  factory _$CreditNoteSummaryCopyWith(_CreditNoteSummary value, $Res Function(_CreditNoteSummary) _then) = __$CreditNoteSummaryCopyWithImpl;
@override @useResult
$Res call({
 double totalIssued, double totalApplied, double totalUnused, double totalCancelled, int totalCount, int issuedCount, int appliedCount, int unusedCount, int cancelledCount, DateTime? periodStart, DateTime? periodEnd, Map<CreditNoteReason, double>? amountByReason, Map<CreditNoteReason, int>? countByReason
});




}
/// @nodoc
class __$CreditNoteSummaryCopyWithImpl<$Res>
    implements _$CreditNoteSummaryCopyWith<$Res> {
  __$CreditNoteSummaryCopyWithImpl(this._self, this._then);

  final _CreditNoteSummary _self;
  final $Res Function(_CreditNoteSummary) _then;

/// Create a copy of CreditNoteSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalIssued = null,Object? totalApplied = null,Object? totalUnused = null,Object? totalCancelled = null,Object? totalCount = null,Object? issuedCount = null,Object? appliedCount = null,Object? unusedCount = null,Object? cancelledCount = null,Object? periodStart = freezed,Object? periodEnd = freezed,Object? amountByReason = freezed,Object? countByReason = freezed,}) {
  return _then(_CreditNoteSummary(
totalIssued: null == totalIssued ? _self.totalIssued : totalIssued // ignore: cast_nullable_to_non_nullable
as double,totalApplied: null == totalApplied ? _self.totalApplied : totalApplied // ignore: cast_nullable_to_non_nullable
as double,totalUnused: null == totalUnused ? _self.totalUnused : totalUnused // ignore: cast_nullable_to_non_nullable
as double,totalCancelled: null == totalCancelled ? _self.totalCancelled : totalCancelled // ignore: cast_nullable_to_non_nullable
as double,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,issuedCount: null == issuedCount ? _self.issuedCount : issuedCount // ignore: cast_nullable_to_non_nullable
as int,appliedCount: null == appliedCount ? _self.appliedCount : appliedCount // ignore: cast_nullable_to_non_nullable
as int,unusedCount: null == unusedCount ? _self.unusedCount : unusedCount // ignore: cast_nullable_to_non_nullable
as int,cancelledCount: null == cancelledCount ? _self.cancelledCount : cancelledCount // ignore: cast_nullable_to_non_nullable
as int,periodStart: freezed == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime?,periodEnd: freezed == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,amountByReason: freezed == amountByReason ? _self._amountByReason : amountByReason // ignore: cast_nullable_to_non_nullable
as Map<CreditNoteReason, double>?,countByReason: freezed == countByReason ? _self._countByReason : countByReason // ignore: cast_nullable_to_non_nullable
as Map<CreditNoteReason, int>?,
  ));
}


}


/// @nodoc
mixin _$CreditNoteFilter {

 DateTime? get startDate; DateTime? get endDate; List<CreditNoteStatus>? get statuses; List<CreditNoteReason>? get reasons; String? get companyId; String? get searchQuery; double? get minAmount; double? get maxAmount; String get sortBy; bool get sortDesc; int get page; int get limit;
/// Create a copy of CreditNoteFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreditNoteFilterCopyWith<CreditNoteFilter> get copyWith => _$CreditNoteFilterCopyWithImpl<CreditNoteFilter>(this as CreditNoteFilter, _$identity);

  /// Serializes this CreditNoteFilter to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreditNoteFilter&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other.statuses, statuses)&&const DeepCollectionEquality().equals(other.reasons, reasons)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.minAmount, minAmount) || other.minAmount == minAmount)&&(identical(other.maxAmount, maxAmount) || other.maxAmount == maxAmount)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.sortDesc, sortDesc) || other.sortDesc == sortDesc)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startDate,endDate,const DeepCollectionEquality().hash(statuses),const DeepCollectionEquality().hash(reasons),companyId,searchQuery,minAmount,maxAmount,sortBy,sortDesc,page,limit);

@override
String toString() {
  return 'CreditNoteFilter(startDate: $startDate, endDate: $endDate, statuses: $statuses, reasons: $reasons, companyId: $companyId, searchQuery: $searchQuery, minAmount: $minAmount, maxAmount: $maxAmount, sortBy: $sortBy, sortDesc: $sortDesc, page: $page, limit: $limit)';
}


}

/// @nodoc
abstract mixin class $CreditNoteFilterCopyWith<$Res>  {
  factory $CreditNoteFilterCopyWith(CreditNoteFilter value, $Res Function(CreditNoteFilter) _then) = _$CreditNoteFilterCopyWithImpl;
@useResult
$Res call({
 DateTime? startDate, DateTime? endDate, List<CreditNoteStatus>? statuses, List<CreditNoteReason>? reasons, String? companyId, String? searchQuery, double? minAmount, double? maxAmount, String sortBy, bool sortDesc, int page, int limit
});




}
/// @nodoc
class _$CreditNoteFilterCopyWithImpl<$Res>
    implements $CreditNoteFilterCopyWith<$Res> {
  _$CreditNoteFilterCopyWithImpl(this._self, this._then);

  final CreditNoteFilter _self;
  final $Res Function(CreditNoteFilter) _then;

/// Create a copy of CreditNoteFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? startDate = freezed,Object? endDate = freezed,Object? statuses = freezed,Object? reasons = freezed,Object? companyId = freezed,Object? searchQuery = freezed,Object? minAmount = freezed,Object? maxAmount = freezed,Object? sortBy = null,Object? sortDesc = null,Object? page = null,Object? limit = null,}) {
  return _then(_self.copyWith(
startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,statuses: freezed == statuses ? _self.statuses : statuses // ignore: cast_nullable_to_non_nullable
as List<CreditNoteStatus>?,reasons: freezed == reasons ? _self.reasons : reasons // ignore: cast_nullable_to_non_nullable
as List<CreditNoteReason>?,companyId: freezed == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String?,searchQuery: freezed == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String?,minAmount: freezed == minAmount ? _self.minAmount : minAmount // ignore: cast_nullable_to_non_nullable
as double?,maxAmount: freezed == maxAmount ? _self.maxAmount : maxAmount // ignore: cast_nullable_to_non_nullable
as double?,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as String,sortDesc: null == sortDesc ? _self.sortDesc : sortDesc // ignore: cast_nullable_to_non_nullable
as bool,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CreditNoteFilter].
extension CreditNoteFilterPatterns on CreditNoteFilter {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreditNoteFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreditNoteFilter() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreditNoteFilter value)  $default,){
final _that = this;
switch (_that) {
case _CreditNoteFilter():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreditNoteFilter value)?  $default,){
final _that = this;
switch (_that) {
case _CreditNoteFilter() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime? startDate,  DateTime? endDate,  List<CreditNoteStatus>? statuses,  List<CreditNoteReason>? reasons,  String? companyId,  String? searchQuery,  double? minAmount,  double? maxAmount,  String sortBy,  bool sortDesc,  int page,  int limit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreditNoteFilter() when $default != null:
return $default(_that.startDate,_that.endDate,_that.statuses,_that.reasons,_that.companyId,_that.searchQuery,_that.minAmount,_that.maxAmount,_that.sortBy,_that.sortDesc,_that.page,_that.limit);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime? startDate,  DateTime? endDate,  List<CreditNoteStatus>? statuses,  List<CreditNoteReason>? reasons,  String? companyId,  String? searchQuery,  double? minAmount,  double? maxAmount,  String sortBy,  bool sortDesc,  int page,  int limit)  $default,) {final _that = this;
switch (_that) {
case _CreditNoteFilter():
return $default(_that.startDate,_that.endDate,_that.statuses,_that.reasons,_that.companyId,_that.searchQuery,_that.minAmount,_that.maxAmount,_that.sortBy,_that.sortDesc,_that.page,_that.limit);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime? startDate,  DateTime? endDate,  List<CreditNoteStatus>? statuses,  List<CreditNoteReason>? reasons,  String? companyId,  String? searchQuery,  double? minAmount,  double? maxAmount,  String sortBy,  bool sortDesc,  int page,  int limit)?  $default,) {final _that = this;
switch (_that) {
case _CreditNoteFilter() when $default != null:
return $default(_that.startDate,_that.endDate,_that.statuses,_that.reasons,_that.companyId,_that.searchQuery,_that.minAmount,_that.maxAmount,_that.sortBy,_that.sortDesc,_that.page,_that.limit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreditNoteFilter implements CreditNoteFilter {
  const _CreditNoteFilter({this.startDate, this.endDate, final  List<CreditNoteStatus>? statuses, final  List<CreditNoteReason>? reasons, this.companyId, this.searchQuery, this.minAmount, this.maxAmount, this.sortBy = 'issueDate', this.sortDesc = false, this.page = 1, this.limit = 20}): _statuses = statuses,_reasons = reasons;
  factory _CreditNoteFilter.fromJson(Map<String, dynamic> json) => _$CreditNoteFilterFromJson(json);

@override final  DateTime? startDate;
@override final  DateTime? endDate;
 final  List<CreditNoteStatus>? _statuses;
@override List<CreditNoteStatus>? get statuses {
  final value = _statuses;
  if (value == null) return null;
  if (_statuses is EqualUnmodifiableListView) return _statuses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<CreditNoteReason>? _reasons;
@override List<CreditNoteReason>? get reasons {
  final value = _reasons;
  if (value == null) return null;
  if (_reasons is EqualUnmodifiableListView) return _reasons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? companyId;
@override final  String? searchQuery;
@override final  double? minAmount;
@override final  double? maxAmount;
@override@JsonKey() final  String sortBy;
@override@JsonKey() final  bool sortDesc;
@override@JsonKey() final  int page;
@override@JsonKey() final  int limit;

/// Create a copy of CreditNoteFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreditNoteFilterCopyWith<_CreditNoteFilter> get copyWith => __$CreditNoteFilterCopyWithImpl<_CreditNoteFilter>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreditNoteFilterToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreditNoteFilter&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other._statuses, _statuses)&&const DeepCollectionEquality().equals(other._reasons, _reasons)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.minAmount, minAmount) || other.minAmount == minAmount)&&(identical(other.maxAmount, maxAmount) || other.maxAmount == maxAmount)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.sortDesc, sortDesc) || other.sortDesc == sortDesc)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startDate,endDate,const DeepCollectionEquality().hash(_statuses),const DeepCollectionEquality().hash(_reasons),companyId,searchQuery,minAmount,maxAmount,sortBy,sortDesc,page,limit);

@override
String toString() {
  return 'CreditNoteFilter(startDate: $startDate, endDate: $endDate, statuses: $statuses, reasons: $reasons, companyId: $companyId, searchQuery: $searchQuery, minAmount: $minAmount, maxAmount: $maxAmount, sortBy: $sortBy, sortDesc: $sortDesc, page: $page, limit: $limit)';
}


}

/// @nodoc
abstract mixin class _$CreditNoteFilterCopyWith<$Res> implements $CreditNoteFilterCopyWith<$Res> {
  factory _$CreditNoteFilterCopyWith(_CreditNoteFilter value, $Res Function(_CreditNoteFilter) _then) = __$CreditNoteFilterCopyWithImpl;
@override @useResult
$Res call({
 DateTime? startDate, DateTime? endDate, List<CreditNoteStatus>? statuses, List<CreditNoteReason>? reasons, String? companyId, String? searchQuery, double? minAmount, double? maxAmount, String sortBy, bool sortDesc, int page, int limit
});




}
/// @nodoc
class __$CreditNoteFilterCopyWithImpl<$Res>
    implements _$CreditNoteFilterCopyWith<$Res> {
  __$CreditNoteFilterCopyWithImpl(this._self, this._then);

  final _CreditNoteFilter _self;
  final $Res Function(_CreditNoteFilter) _then;

/// Create a copy of CreditNoteFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? startDate = freezed,Object? endDate = freezed,Object? statuses = freezed,Object? reasons = freezed,Object? companyId = freezed,Object? searchQuery = freezed,Object? minAmount = freezed,Object? maxAmount = freezed,Object? sortBy = null,Object? sortDesc = null,Object? page = null,Object? limit = null,}) {
  return _then(_CreditNoteFilter(
startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,statuses: freezed == statuses ? _self._statuses : statuses // ignore: cast_nullable_to_non_nullable
as List<CreditNoteStatus>?,reasons: freezed == reasons ? _self._reasons : reasons // ignore: cast_nullable_to_non_nullable
as List<CreditNoteReason>?,companyId: freezed == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String?,searchQuery: freezed == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String?,minAmount: freezed == minAmount ? _self.minAmount : minAmount // ignore: cast_nullable_to_non_nullable
as double?,maxAmount: freezed == maxAmount ? _self.maxAmount : maxAmount // ignore: cast_nullable_to_non_nullable
as double?,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as String,sortDesc: null == sortDesc ? _self.sortDesc : sortDesc // ignore: cast_nullable_to_non_nullable
as bool,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on

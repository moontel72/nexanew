// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'billing_datasource.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreditNote {

 String get id; String get invoiceId; String get creditNoteNumber; double get amount; String get reason; DateTime get issueDate; String? get notes; Map<String, dynamic>? get metadata; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of CreditNote
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreditNoteCopyWith<CreditNote> get copyWith => _$CreditNoteCopyWithImpl<CreditNote>(this as CreditNote, _$identity);

  /// Serializes this CreditNote to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreditNote&&(identical(other.id, id) || other.id == id)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.creditNoteNumber, creditNoteNumber) || other.creditNoteNumber == creditNoteNumber)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.issueDate, issueDate) || other.issueDate == issueDate)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,invoiceId,creditNoteNumber,amount,reason,issueDate,notes,const DeepCollectionEquality().hash(metadata),createdAt,updatedAt);

@override
String toString() {
  return 'CreditNote(id: $id, invoiceId: $invoiceId, creditNoteNumber: $creditNoteNumber, amount: $amount, reason: $reason, issueDate: $issueDate, notes: $notes, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CreditNoteCopyWith<$Res>  {
  factory $CreditNoteCopyWith(CreditNote value, $Res Function(CreditNote) _then) = _$CreditNoteCopyWithImpl;
@useResult
$Res call({
 String id, String invoiceId, String creditNoteNumber, double amount, String reason, DateTime issueDate, String? notes, Map<String, dynamic>? metadata, DateTime? createdAt, DateTime? updatedAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? invoiceId = null,Object? creditNoteNumber = null,Object? amount = null,Object? reason = null,Object? issueDate = null,Object? notes = freezed,Object? metadata = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,creditNoteNumber: null == creditNoteNumber ? _self.creditNoteNumber : creditNoteNumber // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,issueDate: null == issueDate ? _self.issueDate : issueDate // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String invoiceId,  String creditNoteNumber,  double amount,  String reason,  DateTime issueDate,  String? notes,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreditNote() when $default != null:
return $default(_that.id,_that.invoiceId,_that.creditNoteNumber,_that.amount,_that.reason,_that.issueDate,_that.notes,_that.metadata,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String invoiceId,  String creditNoteNumber,  double amount,  String reason,  DateTime issueDate,  String? notes,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _CreditNote():
return $default(_that.id,_that.invoiceId,_that.creditNoteNumber,_that.amount,_that.reason,_that.issueDate,_that.notes,_that.metadata,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String invoiceId,  String creditNoteNumber,  double amount,  String reason,  DateTime issueDate,  String? notes,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _CreditNote() when $default != null:
return $default(_that.id,_that.invoiceId,_that.creditNoteNumber,_that.amount,_that.reason,_that.issueDate,_that.notes,_that.metadata,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreditNote implements CreditNote {
  const _CreditNote({required this.id, required this.invoiceId, required this.creditNoteNumber, required this.amount, required this.reason, required this.issueDate, this.notes, final  Map<String, dynamic>? metadata, this.createdAt, this.updatedAt}): _metadata = metadata;
  factory _CreditNote.fromJson(Map<String, dynamic> json) => _$CreditNoteFromJson(json);

@override final  String id;
@override final  String invoiceId;
@override final  String creditNoteNumber;
@override final  double amount;
@override final  String reason;
@override final  DateTime issueDate;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreditNote&&(identical(other.id, id) || other.id == id)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.creditNoteNumber, creditNoteNumber) || other.creditNoteNumber == creditNoteNumber)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.issueDate, issueDate) || other.issueDate == issueDate)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,invoiceId,creditNoteNumber,amount,reason,issueDate,notes,const DeepCollectionEquality().hash(_metadata),createdAt,updatedAt);

@override
String toString() {
  return 'CreditNote(id: $id, invoiceId: $invoiceId, creditNoteNumber: $creditNoteNumber, amount: $amount, reason: $reason, issueDate: $issueDate, notes: $notes, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CreditNoteCopyWith<$Res> implements $CreditNoteCopyWith<$Res> {
  factory _$CreditNoteCopyWith(_CreditNote value, $Res Function(_CreditNote) _then) = __$CreditNoteCopyWithImpl;
@override @useResult
$Res call({
 String id, String invoiceId, String creditNoteNumber, double amount, String reason, DateTime issueDate, String? notes, Map<String, dynamic>? metadata, DateTime? createdAt, DateTime? updatedAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? invoiceId = null,Object? creditNoteNumber = null,Object? amount = null,Object? reason = null,Object? issueDate = null,Object? notes = freezed,Object? metadata = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_CreditNote(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,creditNoteNumber: null == creditNoteNumber ? _self.creditNoteNumber : creditNoteNumber // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,issueDate: null == issueDate ? _self.issueDate : issueDate // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on

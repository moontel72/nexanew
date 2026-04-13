// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_reconciliation_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PaymentRecord {

 String get id; String get transactionId; double get amount; String get currency; DateTime get transactionDate; String get paymentMethod; String? get gatewayReference; String? get customerReference; String? get invoiceReference; String? get description; Map<String, dynamic>? get metadata; DateTime? get createdAt;
/// Create a copy of PaymentRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentRecordCopyWith<PaymentRecord> get copyWith => _$PaymentRecordCopyWithImpl<PaymentRecord>(this as PaymentRecord, _$identity);

  /// Serializes this PaymentRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.transactionDate, transactionDate) || other.transactionDate == transactionDate)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.gatewayReference, gatewayReference) || other.gatewayReference == gatewayReference)&&(identical(other.customerReference, customerReference) || other.customerReference == customerReference)&&(identical(other.invoiceReference, invoiceReference) || other.invoiceReference == invoiceReference)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,transactionId,amount,currency,transactionDate,paymentMethod,gatewayReference,customerReference,invoiceReference,description,const DeepCollectionEquality().hash(metadata),createdAt);

@override
String toString() {
  return 'PaymentRecord(id: $id, transactionId: $transactionId, amount: $amount, currency: $currency, transactionDate: $transactionDate, paymentMethod: $paymentMethod, gatewayReference: $gatewayReference, customerReference: $customerReference, invoiceReference: $invoiceReference, description: $description, metadata: $metadata, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PaymentRecordCopyWith<$Res>  {
  factory $PaymentRecordCopyWith(PaymentRecord value, $Res Function(PaymentRecord) _then) = _$PaymentRecordCopyWithImpl;
@useResult
$Res call({
 String id, String transactionId, double amount, String currency, DateTime transactionDate, String paymentMethod, String? gatewayReference, String? customerReference, String? invoiceReference, String? description, Map<String, dynamic>? metadata, DateTime? createdAt
});




}
/// @nodoc
class _$PaymentRecordCopyWithImpl<$Res>
    implements $PaymentRecordCopyWith<$Res> {
  _$PaymentRecordCopyWithImpl(this._self, this._then);

  final PaymentRecord _self;
  final $Res Function(PaymentRecord) _then;

/// Create a copy of PaymentRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? transactionId = null,Object? amount = null,Object? currency = null,Object? transactionDate = null,Object? paymentMethod = null,Object? gatewayReference = freezed,Object? customerReference = freezed,Object? invoiceReference = freezed,Object? description = freezed,Object? metadata = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,transactionId: null == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,transactionDate: null == transactionDate ? _self.transactionDate : transactionDate // ignore: cast_nullable_to_non_nullable
as DateTime,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String,gatewayReference: freezed == gatewayReference ? _self.gatewayReference : gatewayReference // ignore: cast_nullable_to_non_nullable
as String?,customerReference: freezed == customerReference ? _self.customerReference : customerReference // ignore: cast_nullable_to_non_nullable
as String?,invoiceReference: freezed == invoiceReference ? _self.invoiceReference : invoiceReference // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentRecord].
extension PaymentRecordPatterns on PaymentRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentRecord value)  $default,){
final _that = this;
switch (_that) {
case _PaymentRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentRecord value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String transactionId,  double amount,  String currency,  DateTime transactionDate,  String paymentMethod,  String? gatewayReference,  String? customerReference,  String? invoiceReference,  String? description,  Map<String, dynamic>? metadata,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentRecord() when $default != null:
return $default(_that.id,_that.transactionId,_that.amount,_that.currency,_that.transactionDate,_that.paymentMethod,_that.gatewayReference,_that.customerReference,_that.invoiceReference,_that.description,_that.metadata,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String transactionId,  double amount,  String currency,  DateTime transactionDate,  String paymentMethod,  String? gatewayReference,  String? customerReference,  String? invoiceReference,  String? description,  Map<String, dynamic>? metadata,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _PaymentRecord():
return $default(_that.id,_that.transactionId,_that.amount,_that.currency,_that.transactionDate,_that.paymentMethod,_that.gatewayReference,_that.customerReference,_that.invoiceReference,_that.description,_that.metadata,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String transactionId,  double amount,  String currency,  DateTime transactionDate,  String paymentMethod,  String? gatewayReference,  String? customerReference,  String? invoiceReference,  String? description,  Map<String, dynamic>? metadata,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _PaymentRecord() when $default != null:
return $default(_that.id,_that.transactionId,_that.amount,_that.currency,_that.transactionDate,_that.paymentMethod,_that.gatewayReference,_that.customerReference,_that.invoiceReference,_that.description,_that.metadata,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentRecord implements PaymentRecord {
  const _PaymentRecord({required this.id, required this.transactionId, required this.amount, required this.currency, required this.transactionDate, required this.paymentMethod, this.gatewayReference, this.customerReference, this.invoiceReference, this.description, final  Map<String, dynamic>? metadata, this.createdAt}): _metadata = metadata;
  factory _PaymentRecord.fromJson(Map<String, dynamic> json) => _$PaymentRecordFromJson(json);

@override final  String id;
@override final  String transactionId;
@override final  double amount;
@override final  String currency;
@override final  DateTime transactionDate;
@override final  String paymentMethod;
@override final  String? gatewayReference;
@override final  String? customerReference;
@override final  String? invoiceReference;
@override final  String? description;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  DateTime? createdAt;

/// Create a copy of PaymentRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentRecordCopyWith<_PaymentRecord> get copyWith => __$PaymentRecordCopyWithImpl<_PaymentRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.transactionDate, transactionDate) || other.transactionDate == transactionDate)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.gatewayReference, gatewayReference) || other.gatewayReference == gatewayReference)&&(identical(other.customerReference, customerReference) || other.customerReference == customerReference)&&(identical(other.invoiceReference, invoiceReference) || other.invoiceReference == invoiceReference)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,transactionId,amount,currency,transactionDate,paymentMethod,gatewayReference,customerReference,invoiceReference,description,const DeepCollectionEquality().hash(_metadata),createdAt);

@override
String toString() {
  return 'PaymentRecord(id: $id, transactionId: $transactionId, amount: $amount, currency: $currency, transactionDate: $transactionDate, paymentMethod: $paymentMethod, gatewayReference: $gatewayReference, customerReference: $customerReference, invoiceReference: $invoiceReference, description: $description, metadata: $metadata, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PaymentRecordCopyWith<$Res> implements $PaymentRecordCopyWith<$Res> {
  factory _$PaymentRecordCopyWith(_PaymentRecord value, $Res Function(_PaymentRecord) _then) = __$PaymentRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, String transactionId, double amount, String currency, DateTime transactionDate, String paymentMethod, String? gatewayReference, String? customerReference, String? invoiceReference, String? description, Map<String, dynamic>? metadata, DateTime? createdAt
});




}
/// @nodoc
class __$PaymentRecordCopyWithImpl<$Res>
    implements _$PaymentRecordCopyWith<$Res> {
  __$PaymentRecordCopyWithImpl(this._self, this._then);

  final _PaymentRecord _self;
  final $Res Function(_PaymentRecord) _then;

/// Create a copy of PaymentRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? transactionId = null,Object? amount = null,Object? currency = null,Object? transactionDate = null,Object? paymentMethod = null,Object? gatewayReference = freezed,Object? customerReference = freezed,Object? invoiceReference = freezed,Object? description = freezed,Object? metadata = freezed,Object? createdAt = freezed,}) {
  return _then(_PaymentRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,transactionId: null == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,transactionDate: null == transactionDate ? _self.transactionDate : transactionDate // ignore: cast_nullable_to_non_nullable
as DateTime,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String,gatewayReference: freezed == gatewayReference ? _self.gatewayReference : gatewayReference // ignore: cast_nullable_to_non_nullable
as String?,customerReference: freezed == customerReference ? _self.customerReference : customerReference // ignore: cast_nullable_to_non_nullable
as String?,invoiceReference: freezed == invoiceReference ? _self.invoiceReference : invoiceReference // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ReconciliationMatch {

 String get paymentId; String get gatewayRecordId; double get matchedAmount; String get matchedCurrency; DateTime get matchDate; String? get notes; Map<String, dynamic>? get metadata;
/// Create a copy of ReconciliationMatch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReconciliationMatchCopyWith<ReconciliationMatch> get copyWith => _$ReconciliationMatchCopyWithImpl<ReconciliationMatch>(this as ReconciliationMatch, _$identity);

  /// Serializes this ReconciliationMatch to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReconciliationMatch&&(identical(other.paymentId, paymentId) || other.paymentId == paymentId)&&(identical(other.gatewayRecordId, gatewayRecordId) || other.gatewayRecordId == gatewayRecordId)&&(identical(other.matchedAmount, matchedAmount) || other.matchedAmount == matchedAmount)&&(identical(other.matchedCurrency, matchedCurrency) || other.matchedCurrency == matchedCurrency)&&(identical(other.matchDate, matchDate) || other.matchDate == matchDate)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,paymentId,gatewayRecordId,matchedAmount,matchedCurrency,matchDate,notes,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'ReconciliationMatch(paymentId: $paymentId, gatewayRecordId: $gatewayRecordId, matchedAmount: $matchedAmount, matchedCurrency: $matchedCurrency, matchDate: $matchDate, notes: $notes, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $ReconciliationMatchCopyWith<$Res>  {
  factory $ReconciliationMatchCopyWith(ReconciliationMatch value, $Res Function(ReconciliationMatch) _then) = _$ReconciliationMatchCopyWithImpl;
@useResult
$Res call({
 String paymentId, String gatewayRecordId, double matchedAmount, String matchedCurrency, DateTime matchDate, String? notes, Map<String, dynamic>? metadata
});




}
/// @nodoc
class _$ReconciliationMatchCopyWithImpl<$Res>
    implements $ReconciliationMatchCopyWith<$Res> {
  _$ReconciliationMatchCopyWithImpl(this._self, this._then);

  final ReconciliationMatch _self;
  final $Res Function(ReconciliationMatch) _then;

/// Create a copy of ReconciliationMatch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? paymentId = null,Object? gatewayRecordId = null,Object? matchedAmount = null,Object? matchedCurrency = null,Object? matchDate = null,Object? notes = freezed,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
paymentId: null == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String,gatewayRecordId: null == gatewayRecordId ? _self.gatewayRecordId : gatewayRecordId // ignore: cast_nullable_to_non_nullable
as String,matchedAmount: null == matchedAmount ? _self.matchedAmount : matchedAmount // ignore: cast_nullable_to_non_nullable
as double,matchedCurrency: null == matchedCurrency ? _self.matchedCurrency : matchedCurrency // ignore: cast_nullable_to_non_nullable
as String,matchDate: null == matchDate ? _self.matchDate : matchDate // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReconciliationMatch].
extension ReconciliationMatchPatterns on ReconciliationMatch {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReconciliationMatch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReconciliationMatch() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReconciliationMatch value)  $default,){
final _that = this;
switch (_that) {
case _ReconciliationMatch():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReconciliationMatch value)?  $default,){
final _that = this;
switch (_that) {
case _ReconciliationMatch() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String paymentId,  String gatewayRecordId,  double matchedAmount,  String matchedCurrency,  DateTime matchDate,  String? notes,  Map<String, dynamic>? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReconciliationMatch() when $default != null:
return $default(_that.paymentId,_that.gatewayRecordId,_that.matchedAmount,_that.matchedCurrency,_that.matchDate,_that.notes,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String paymentId,  String gatewayRecordId,  double matchedAmount,  String matchedCurrency,  DateTime matchDate,  String? notes,  Map<String, dynamic>? metadata)  $default,) {final _that = this;
switch (_that) {
case _ReconciliationMatch():
return $default(_that.paymentId,_that.gatewayRecordId,_that.matchedAmount,_that.matchedCurrency,_that.matchDate,_that.notes,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String paymentId,  String gatewayRecordId,  double matchedAmount,  String matchedCurrency,  DateTime matchDate,  String? notes,  Map<String, dynamic>? metadata)?  $default,) {final _that = this;
switch (_that) {
case _ReconciliationMatch() when $default != null:
return $default(_that.paymentId,_that.gatewayRecordId,_that.matchedAmount,_that.matchedCurrency,_that.matchDate,_that.notes,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReconciliationMatch implements ReconciliationMatch {
  const _ReconciliationMatch({required this.paymentId, required this.gatewayRecordId, required this.matchedAmount, required this.matchedCurrency, required this.matchDate, this.notes, final  Map<String, dynamic>? metadata}): _metadata = metadata;
  factory _ReconciliationMatch.fromJson(Map<String, dynamic> json) => _$ReconciliationMatchFromJson(json);

@override final  String paymentId;
@override final  String gatewayRecordId;
@override final  double matchedAmount;
@override final  String matchedCurrency;
@override final  DateTime matchDate;
@override final  String? notes;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of ReconciliationMatch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReconciliationMatchCopyWith<_ReconciliationMatch> get copyWith => __$ReconciliationMatchCopyWithImpl<_ReconciliationMatch>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReconciliationMatchToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReconciliationMatch&&(identical(other.paymentId, paymentId) || other.paymentId == paymentId)&&(identical(other.gatewayRecordId, gatewayRecordId) || other.gatewayRecordId == gatewayRecordId)&&(identical(other.matchedAmount, matchedAmount) || other.matchedAmount == matchedAmount)&&(identical(other.matchedCurrency, matchedCurrency) || other.matchedCurrency == matchedCurrency)&&(identical(other.matchDate, matchDate) || other.matchDate == matchDate)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,paymentId,gatewayRecordId,matchedAmount,matchedCurrency,matchDate,notes,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'ReconciliationMatch(paymentId: $paymentId, gatewayRecordId: $gatewayRecordId, matchedAmount: $matchedAmount, matchedCurrency: $matchedCurrency, matchDate: $matchDate, notes: $notes, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$ReconciliationMatchCopyWith<$Res> implements $ReconciliationMatchCopyWith<$Res> {
  factory _$ReconciliationMatchCopyWith(_ReconciliationMatch value, $Res Function(_ReconciliationMatch) _then) = __$ReconciliationMatchCopyWithImpl;
@override @useResult
$Res call({
 String paymentId, String gatewayRecordId, double matchedAmount, String matchedCurrency, DateTime matchDate, String? notes, Map<String, dynamic>? metadata
});




}
/// @nodoc
class __$ReconciliationMatchCopyWithImpl<$Res>
    implements _$ReconciliationMatchCopyWith<$Res> {
  __$ReconciliationMatchCopyWithImpl(this._self, this._then);

  final _ReconciliationMatch _self;
  final $Res Function(_ReconciliationMatch) _then;

/// Create a copy of ReconciliationMatch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? paymentId = null,Object? gatewayRecordId = null,Object? matchedAmount = null,Object? matchedCurrency = null,Object? matchDate = null,Object? notes = freezed,Object? metadata = freezed,}) {
  return _then(_ReconciliationMatch(
paymentId: null == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String,gatewayRecordId: null == gatewayRecordId ? _self.gatewayRecordId : gatewayRecordId // ignore: cast_nullable_to_non_nullable
as String,matchedAmount: null == matchedAmount ? _self.matchedAmount : matchedAmount // ignore: cast_nullable_to_non_nullable
as double,matchedCurrency: null == matchedCurrency ? _self.matchedCurrency : matchedCurrency // ignore: cast_nullable_to_non_nullable
as String,matchDate: null == matchDate ? _self.matchDate : matchDate // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}


/// @nodoc
mixin _$ReconciliationDiscrepancy {

 String get id; DiscrepancyType get type; String get description; double get internalAmount; double get gatewayAmount; String get currency; DateTime get transactionDate; String? get paymentId; String? get gatewayRecordId; String? get suggestedResolution; String? get resolvedBy; DateTime? get resolvedAt; String? get resolutionNotes; Map<String, dynamic>? get metadata; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of ReconciliationDiscrepancy
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReconciliationDiscrepancyCopyWith<ReconciliationDiscrepancy> get copyWith => _$ReconciliationDiscrepancyCopyWithImpl<ReconciliationDiscrepancy>(this as ReconciliationDiscrepancy, _$identity);

  /// Serializes this ReconciliationDiscrepancy to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReconciliationDiscrepancy&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.description, description) || other.description == description)&&(identical(other.internalAmount, internalAmount) || other.internalAmount == internalAmount)&&(identical(other.gatewayAmount, gatewayAmount) || other.gatewayAmount == gatewayAmount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.transactionDate, transactionDate) || other.transactionDate == transactionDate)&&(identical(other.paymentId, paymentId) || other.paymentId == paymentId)&&(identical(other.gatewayRecordId, gatewayRecordId) || other.gatewayRecordId == gatewayRecordId)&&(identical(other.suggestedResolution, suggestedResolution) || other.suggestedResolution == suggestedResolution)&&(identical(other.resolvedBy, resolvedBy) || other.resolvedBy == resolvedBy)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.resolutionNotes, resolutionNotes) || other.resolutionNotes == resolutionNotes)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,description,internalAmount,gatewayAmount,currency,transactionDate,paymentId,gatewayRecordId,suggestedResolution,resolvedBy,resolvedAt,resolutionNotes,const DeepCollectionEquality().hash(metadata),createdAt,updatedAt);

@override
String toString() {
  return 'ReconciliationDiscrepancy(id: $id, type: $type, description: $description, internalAmount: $internalAmount, gatewayAmount: $gatewayAmount, currency: $currency, transactionDate: $transactionDate, paymentId: $paymentId, gatewayRecordId: $gatewayRecordId, suggestedResolution: $suggestedResolution, resolvedBy: $resolvedBy, resolvedAt: $resolvedAt, resolutionNotes: $resolutionNotes, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ReconciliationDiscrepancyCopyWith<$Res>  {
  factory $ReconciliationDiscrepancyCopyWith(ReconciliationDiscrepancy value, $Res Function(ReconciliationDiscrepancy) _then) = _$ReconciliationDiscrepancyCopyWithImpl;
@useResult
$Res call({
 String id, DiscrepancyType type, String description, double internalAmount, double gatewayAmount, String currency, DateTime transactionDate, String? paymentId, String? gatewayRecordId, String? suggestedResolution, String? resolvedBy, DateTime? resolvedAt, String? resolutionNotes, Map<String, dynamic>? metadata, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$ReconciliationDiscrepancyCopyWithImpl<$Res>
    implements $ReconciliationDiscrepancyCopyWith<$Res> {
  _$ReconciliationDiscrepancyCopyWithImpl(this._self, this._then);

  final ReconciliationDiscrepancy _self;
  final $Res Function(ReconciliationDiscrepancy) _then;

/// Create a copy of ReconciliationDiscrepancy
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? description = null,Object? internalAmount = null,Object? gatewayAmount = null,Object? currency = null,Object? transactionDate = null,Object? paymentId = freezed,Object? gatewayRecordId = freezed,Object? suggestedResolution = freezed,Object? resolvedBy = freezed,Object? resolvedAt = freezed,Object? resolutionNotes = freezed,Object? metadata = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DiscrepancyType,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,internalAmount: null == internalAmount ? _self.internalAmount : internalAmount // ignore: cast_nullable_to_non_nullable
as double,gatewayAmount: null == gatewayAmount ? _self.gatewayAmount : gatewayAmount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,transactionDate: null == transactionDate ? _self.transactionDate : transactionDate // ignore: cast_nullable_to_non_nullable
as DateTime,paymentId: freezed == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String?,gatewayRecordId: freezed == gatewayRecordId ? _self.gatewayRecordId : gatewayRecordId // ignore: cast_nullable_to_non_nullable
as String?,suggestedResolution: freezed == suggestedResolution ? _self.suggestedResolution : suggestedResolution // ignore: cast_nullable_to_non_nullable
as String?,resolvedBy: freezed == resolvedBy ? _self.resolvedBy : resolvedBy // ignore: cast_nullable_to_non_nullable
as String?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,resolutionNotes: freezed == resolutionNotes ? _self.resolutionNotes : resolutionNotes // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReconciliationDiscrepancy].
extension ReconciliationDiscrepancyPatterns on ReconciliationDiscrepancy {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReconciliationDiscrepancy value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReconciliationDiscrepancy() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReconciliationDiscrepancy value)  $default,){
final _that = this;
switch (_that) {
case _ReconciliationDiscrepancy():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReconciliationDiscrepancy value)?  $default,){
final _that = this;
switch (_that) {
case _ReconciliationDiscrepancy() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DiscrepancyType type,  String description,  double internalAmount,  double gatewayAmount,  String currency,  DateTime transactionDate,  String? paymentId,  String? gatewayRecordId,  String? suggestedResolution,  String? resolvedBy,  DateTime? resolvedAt,  String? resolutionNotes,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReconciliationDiscrepancy() when $default != null:
return $default(_that.id,_that.type,_that.description,_that.internalAmount,_that.gatewayAmount,_that.currency,_that.transactionDate,_that.paymentId,_that.gatewayRecordId,_that.suggestedResolution,_that.resolvedBy,_that.resolvedAt,_that.resolutionNotes,_that.metadata,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DiscrepancyType type,  String description,  double internalAmount,  double gatewayAmount,  String currency,  DateTime transactionDate,  String? paymentId,  String? gatewayRecordId,  String? suggestedResolution,  String? resolvedBy,  DateTime? resolvedAt,  String? resolutionNotes,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ReconciliationDiscrepancy():
return $default(_that.id,_that.type,_that.description,_that.internalAmount,_that.gatewayAmount,_that.currency,_that.transactionDate,_that.paymentId,_that.gatewayRecordId,_that.suggestedResolution,_that.resolvedBy,_that.resolvedAt,_that.resolutionNotes,_that.metadata,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DiscrepancyType type,  String description,  double internalAmount,  double gatewayAmount,  String currency,  DateTime transactionDate,  String? paymentId,  String? gatewayRecordId,  String? suggestedResolution,  String? resolvedBy,  DateTime? resolvedAt,  String? resolutionNotes,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ReconciliationDiscrepancy() when $default != null:
return $default(_that.id,_that.type,_that.description,_that.internalAmount,_that.gatewayAmount,_that.currency,_that.transactionDate,_that.paymentId,_that.gatewayRecordId,_that.suggestedResolution,_that.resolvedBy,_that.resolvedAt,_that.resolutionNotes,_that.metadata,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReconciliationDiscrepancy implements ReconciliationDiscrepancy {
  const _ReconciliationDiscrepancy({required this.id, required this.type, required this.description, required this.internalAmount, required this.gatewayAmount, required this.currency, required this.transactionDate, this.paymentId, this.gatewayRecordId, this.suggestedResolution, this.resolvedBy, this.resolvedAt, this.resolutionNotes, final  Map<String, dynamic>? metadata, this.createdAt, this.updatedAt}): _metadata = metadata;
  factory _ReconciliationDiscrepancy.fromJson(Map<String, dynamic> json) => _$ReconciliationDiscrepancyFromJson(json);

@override final  String id;
@override final  DiscrepancyType type;
@override final  String description;
@override final  double internalAmount;
@override final  double gatewayAmount;
@override final  String currency;
@override final  DateTime transactionDate;
@override final  String? paymentId;
@override final  String? gatewayRecordId;
@override final  String? suggestedResolution;
@override final  String? resolvedBy;
@override final  DateTime? resolvedAt;
@override final  String? resolutionNotes;
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

/// Create a copy of ReconciliationDiscrepancy
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReconciliationDiscrepancyCopyWith<_ReconciliationDiscrepancy> get copyWith => __$ReconciliationDiscrepancyCopyWithImpl<_ReconciliationDiscrepancy>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReconciliationDiscrepancyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReconciliationDiscrepancy&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.description, description) || other.description == description)&&(identical(other.internalAmount, internalAmount) || other.internalAmount == internalAmount)&&(identical(other.gatewayAmount, gatewayAmount) || other.gatewayAmount == gatewayAmount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.transactionDate, transactionDate) || other.transactionDate == transactionDate)&&(identical(other.paymentId, paymentId) || other.paymentId == paymentId)&&(identical(other.gatewayRecordId, gatewayRecordId) || other.gatewayRecordId == gatewayRecordId)&&(identical(other.suggestedResolution, suggestedResolution) || other.suggestedResolution == suggestedResolution)&&(identical(other.resolvedBy, resolvedBy) || other.resolvedBy == resolvedBy)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.resolutionNotes, resolutionNotes) || other.resolutionNotes == resolutionNotes)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,description,internalAmount,gatewayAmount,currency,transactionDate,paymentId,gatewayRecordId,suggestedResolution,resolvedBy,resolvedAt,resolutionNotes,const DeepCollectionEquality().hash(_metadata),createdAt,updatedAt);

@override
String toString() {
  return 'ReconciliationDiscrepancy(id: $id, type: $type, description: $description, internalAmount: $internalAmount, gatewayAmount: $gatewayAmount, currency: $currency, transactionDate: $transactionDate, paymentId: $paymentId, gatewayRecordId: $gatewayRecordId, suggestedResolution: $suggestedResolution, resolvedBy: $resolvedBy, resolvedAt: $resolvedAt, resolutionNotes: $resolutionNotes, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ReconciliationDiscrepancyCopyWith<$Res> implements $ReconciliationDiscrepancyCopyWith<$Res> {
  factory _$ReconciliationDiscrepancyCopyWith(_ReconciliationDiscrepancy value, $Res Function(_ReconciliationDiscrepancy) _then) = __$ReconciliationDiscrepancyCopyWithImpl;
@override @useResult
$Res call({
 String id, DiscrepancyType type, String description, double internalAmount, double gatewayAmount, String currency, DateTime transactionDate, String? paymentId, String? gatewayRecordId, String? suggestedResolution, String? resolvedBy, DateTime? resolvedAt, String? resolutionNotes, Map<String, dynamic>? metadata, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$ReconciliationDiscrepancyCopyWithImpl<$Res>
    implements _$ReconciliationDiscrepancyCopyWith<$Res> {
  __$ReconciliationDiscrepancyCopyWithImpl(this._self, this._then);

  final _ReconciliationDiscrepancy _self;
  final $Res Function(_ReconciliationDiscrepancy) _then;

/// Create a copy of ReconciliationDiscrepancy
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? description = null,Object? internalAmount = null,Object? gatewayAmount = null,Object? currency = null,Object? transactionDate = null,Object? paymentId = freezed,Object? gatewayRecordId = freezed,Object? suggestedResolution = freezed,Object? resolvedBy = freezed,Object? resolvedAt = freezed,Object? resolutionNotes = freezed,Object? metadata = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_ReconciliationDiscrepancy(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DiscrepancyType,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,internalAmount: null == internalAmount ? _self.internalAmount : internalAmount // ignore: cast_nullable_to_non_nullable
as double,gatewayAmount: null == gatewayAmount ? _self.gatewayAmount : gatewayAmount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,transactionDate: null == transactionDate ? _self.transactionDate : transactionDate // ignore: cast_nullable_to_non_nullable
as DateTime,paymentId: freezed == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String?,gatewayRecordId: freezed == gatewayRecordId ? _self.gatewayRecordId : gatewayRecordId // ignore: cast_nullable_to_non_nullable
as String?,suggestedResolution: freezed == suggestedResolution ? _self.suggestedResolution : suggestedResolution // ignore: cast_nullable_to_non_nullable
as String?,resolvedBy: freezed == resolvedBy ? _self.resolvedBy : resolvedBy // ignore: cast_nullable_to_non_nullable
as String?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,resolutionNotes: freezed == resolutionNotes ? _self.resolutionNotes : resolutionNotes // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$PaymentReconciliation {

 String get id; DateTime get reconciliationDate; DateTime get periodStart; DateTime get periodEnd; ReconciliationStatus get status; double get totalGatewayAmount; double get totalInternalAmount; String get currency; List<PaymentRecord> get gatewayRecords; List<PaymentRecord> get internalRecords; List<ReconciliationMatch> get matches; List<ReconciliationDiscrepancy> get discrepancies; String? get notes; String? get performedBy; DateTime? get completedAt; Map<String, dynamic>? get metadata; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of PaymentReconciliation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentReconciliationCopyWith<PaymentReconciliation> get copyWith => _$PaymentReconciliationCopyWithImpl<PaymentReconciliation>(this as PaymentReconciliation, _$identity);

  /// Serializes this PaymentReconciliation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentReconciliation&&(identical(other.id, id) || other.id == id)&&(identical(other.reconciliationDate, reconciliationDate) || other.reconciliationDate == reconciliationDate)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.status, status) || other.status == status)&&(identical(other.totalGatewayAmount, totalGatewayAmount) || other.totalGatewayAmount == totalGatewayAmount)&&(identical(other.totalInternalAmount, totalInternalAmount) || other.totalInternalAmount == totalInternalAmount)&&(identical(other.currency, currency) || other.currency == currency)&&const DeepCollectionEquality().equals(other.gatewayRecords, gatewayRecords)&&const DeepCollectionEquality().equals(other.internalRecords, internalRecords)&&const DeepCollectionEquality().equals(other.matches, matches)&&const DeepCollectionEquality().equals(other.discrepancies, discrepancies)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.performedBy, performedBy) || other.performedBy == performedBy)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reconciliationDate,periodStart,periodEnd,status,totalGatewayAmount,totalInternalAmount,currency,const DeepCollectionEquality().hash(gatewayRecords),const DeepCollectionEquality().hash(internalRecords),const DeepCollectionEquality().hash(matches),const DeepCollectionEquality().hash(discrepancies),notes,performedBy,completedAt,const DeepCollectionEquality().hash(metadata),createdAt,updatedAt);

@override
String toString() {
  return 'PaymentReconciliation(id: $id, reconciliationDate: $reconciliationDate, periodStart: $periodStart, periodEnd: $periodEnd, status: $status, totalGatewayAmount: $totalGatewayAmount, totalInternalAmount: $totalInternalAmount, currency: $currency, gatewayRecords: $gatewayRecords, internalRecords: $internalRecords, matches: $matches, discrepancies: $discrepancies, notes: $notes, performedBy: $performedBy, completedAt: $completedAt, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PaymentReconciliationCopyWith<$Res>  {
  factory $PaymentReconciliationCopyWith(PaymentReconciliation value, $Res Function(PaymentReconciliation) _then) = _$PaymentReconciliationCopyWithImpl;
@useResult
$Res call({
 String id, DateTime reconciliationDate, DateTime periodStart, DateTime periodEnd, ReconciliationStatus status, double totalGatewayAmount, double totalInternalAmount, String currency, List<PaymentRecord> gatewayRecords, List<PaymentRecord> internalRecords, List<ReconciliationMatch> matches, List<ReconciliationDiscrepancy> discrepancies, String? notes, String? performedBy, DateTime? completedAt, Map<String, dynamic>? metadata, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$PaymentReconciliationCopyWithImpl<$Res>
    implements $PaymentReconciliationCopyWith<$Res> {
  _$PaymentReconciliationCopyWithImpl(this._self, this._then);

  final PaymentReconciliation _self;
  final $Res Function(PaymentReconciliation) _then;

/// Create a copy of PaymentReconciliation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reconciliationDate = null,Object? periodStart = null,Object? periodEnd = null,Object? status = null,Object? totalGatewayAmount = null,Object? totalInternalAmount = null,Object? currency = null,Object? gatewayRecords = null,Object? internalRecords = null,Object? matches = null,Object? discrepancies = null,Object? notes = freezed,Object? performedBy = freezed,Object? completedAt = freezed,Object? metadata = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reconciliationDate: null == reconciliationDate ? _self.reconciliationDate : reconciliationDate // ignore: cast_nullable_to_non_nullable
as DateTime,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReconciliationStatus,totalGatewayAmount: null == totalGatewayAmount ? _self.totalGatewayAmount : totalGatewayAmount // ignore: cast_nullable_to_non_nullable
as double,totalInternalAmount: null == totalInternalAmount ? _self.totalInternalAmount : totalInternalAmount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,gatewayRecords: null == gatewayRecords ? _self.gatewayRecords : gatewayRecords // ignore: cast_nullable_to_non_nullable
as List<PaymentRecord>,internalRecords: null == internalRecords ? _self.internalRecords : internalRecords // ignore: cast_nullable_to_non_nullable
as List<PaymentRecord>,matches: null == matches ? _self.matches : matches // ignore: cast_nullable_to_non_nullable
as List<ReconciliationMatch>,discrepancies: null == discrepancies ? _self.discrepancies : discrepancies // ignore: cast_nullable_to_non_nullable
as List<ReconciliationDiscrepancy>,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,performedBy: freezed == performedBy ? _self.performedBy : performedBy // ignore: cast_nullable_to_non_nullable
as String?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentReconciliation].
extension PaymentReconciliationPatterns on PaymentReconciliation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentReconciliation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentReconciliation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentReconciliation value)  $default,){
final _that = this;
switch (_that) {
case _PaymentReconciliation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentReconciliation value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentReconciliation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime reconciliationDate,  DateTime periodStart,  DateTime periodEnd,  ReconciliationStatus status,  double totalGatewayAmount,  double totalInternalAmount,  String currency,  List<PaymentRecord> gatewayRecords,  List<PaymentRecord> internalRecords,  List<ReconciliationMatch> matches,  List<ReconciliationDiscrepancy> discrepancies,  String? notes,  String? performedBy,  DateTime? completedAt,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentReconciliation() when $default != null:
return $default(_that.id,_that.reconciliationDate,_that.periodStart,_that.periodEnd,_that.status,_that.totalGatewayAmount,_that.totalInternalAmount,_that.currency,_that.gatewayRecords,_that.internalRecords,_that.matches,_that.discrepancies,_that.notes,_that.performedBy,_that.completedAt,_that.metadata,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime reconciliationDate,  DateTime periodStart,  DateTime periodEnd,  ReconciliationStatus status,  double totalGatewayAmount,  double totalInternalAmount,  String currency,  List<PaymentRecord> gatewayRecords,  List<PaymentRecord> internalRecords,  List<ReconciliationMatch> matches,  List<ReconciliationDiscrepancy> discrepancies,  String? notes,  String? performedBy,  DateTime? completedAt,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PaymentReconciliation():
return $default(_that.id,_that.reconciliationDate,_that.periodStart,_that.periodEnd,_that.status,_that.totalGatewayAmount,_that.totalInternalAmount,_that.currency,_that.gatewayRecords,_that.internalRecords,_that.matches,_that.discrepancies,_that.notes,_that.performedBy,_that.completedAt,_that.metadata,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime reconciliationDate,  DateTime periodStart,  DateTime periodEnd,  ReconciliationStatus status,  double totalGatewayAmount,  double totalInternalAmount,  String currency,  List<PaymentRecord> gatewayRecords,  List<PaymentRecord> internalRecords,  List<ReconciliationMatch> matches,  List<ReconciliationDiscrepancy> discrepancies,  String? notes,  String? performedBy,  DateTime? completedAt,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PaymentReconciliation() when $default != null:
return $default(_that.id,_that.reconciliationDate,_that.periodStart,_that.periodEnd,_that.status,_that.totalGatewayAmount,_that.totalInternalAmount,_that.currency,_that.gatewayRecords,_that.internalRecords,_that.matches,_that.discrepancies,_that.notes,_that.performedBy,_that.completedAt,_that.metadata,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentReconciliation implements PaymentReconciliation {
  const _PaymentReconciliation({required this.id, required this.reconciliationDate, required this.periodStart, required this.periodEnd, required this.status, required this.totalGatewayAmount, required this.totalInternalAmount, required this.currency, required final  List<PaymentRecord> gatewayRecords, required final  List<PaymentRecord> internalRecords, required final  List<ReconciliationMatch> matches, required final  List<ReconciliationDiscrepancy> discrepancies, this.notes, this.performedBy, this.completedAt, final  Map<String, dynamic>? metadata, this.createdAt, this.updatedAt}): _gatewayRecords = gatewayRecords,_internalRecords = internalRecords,_matches = matches,_discrepancies = discrepancies,_metadata = metadata;
  factory _PaymentReconciliation.fromJson(Map<String, dynamic> json) => _$PaymentReconciliationFromJson(json);

@override final  String id;
@override final  DateTime reconciliationDate;
@override final  DateTime periodStart;
@override final  DateTime periodEnd;
@override final  ReconciliationStatus status;
@override final  double totalGatewayAmount;
@override final  double totalInternalAmount;
@override final  String currency;
 final  List<PaymentRecord> _gatewayRecords;
@override List<PaymentRecord> get gatewayRecords {
  if (_gatewayRecords is EqualUnmodifiableListView) return _gatewayRecords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_gatewayRecords);
}

 final  List<PaymentRecord> _internalRecords;
@override List<PaymentRecord> get internalRecords {
  if (_internalRecords is EqualUnmodifiableListView) return _internalRecords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_internalRecords);
}

 final  List<ReconciliationMatch> _matches;
@override List<ReconciliationMatch> get matches {
  if (_matches is EqualUnmodifiableListView) return _matches;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_matches);
}

 final  List<ReconciliationDiscrepancy> _discrepancies;
@override List<ReconciliationDiscrepancy> get discrepancies {
  if (_discrepancies is EqualUnmodifiableListView) return _discrepancies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_discrepancies);
}

@override final  String? notes;
@override final  String? performedBy;
@override final  DateTime? completedAt;
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

/// Create a copy of PaymentReconciliation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentReconciliationCopyWith<_PaymentReconciliation> get copyWith => __$PaymentReconciliationCopyWithImpl<_PaymentReconciliation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentReconciliationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentReconciliation&&(identical(other.id, id) || other.id == id)&&(identical(other.reconciliationDate, reconciliationDate) || other.reconciliationDate == reconciliationDate)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.status, status) || other.status == status)&&(identical(other.totalGatewayAmount, totalGatewayAmount) || other.totalGatewayAmount == totalGatewayAmount)&&(identical(other.totalInternalAmount, totalInternalAmount) || other.totalInternalAmount == totalInternalAmount)&&(identical(other.currency, currency) || other.currency == currency)&&const DeepCollectionEquality().equals(other._gatewayRecords, _gatewayRecords)&&const DeepCollectionEquality().equals(other._internalRecords, _internalRecords)&&const DeepCollectionEquality().equals(other._matches, _matches)&&const DeepCollectionEquality().equals(other._discrepancies, _discrepancies)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.performedBy, performedBy) || other.performedBy == performedBy)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reconciliationDate,periodStart,periodEnd,status,totalGatewayAmount,totalInternalAmount,currency,const DeepCollectionEquality().hash(_gatewayRecords),const DeepCollectionEquality().hash(_internalRecords),const DeepCollectionEquality().hash(_matches),const DeepCollectionEquality().hash(_discrepancies),notes,performedBy,completedAt,const DeepCollectionEquality().hash(_metadata),createdAt,updatedAt);

@override
String toString() {
  return 'PaymentReconciliation(id: $id, reconciliationDate: $reconciliationDate, periodStart: $periodStart, periodEnd: $periodEnd, status: $status, totalGatewayAmount: $totalGatewayAmount, totalInternalAmount: $totalInternalAmount, currency: $currency, gatewayRecords: $gatewayRecords, internalRecords: $internalRecords, matches: $matches, discrepancies: $discrepancies, notes: $notes, performedBy: $performedBy, completedAt: $completedAt, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PaymentReconciliationCopyWith<$Res> implements $PaymentReconciliationCopyWith<$Res> {
  factory _$PaymentReconciliationCopyWith(_PaymentReconciliation value, $Res Function(_PaymentReconciliation) _then) = __$PaymentReconciliationCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime reconciliationDate, DateTime periodStart, DateTime periodEnd, ReconciliationStatus status, double totalGatewayAmount, double totalInternalAmount, String currency, List<PaymentRecord> gatewayRecords, List<PaymentRecord> internalRecords, List<ReconciliationMatch> matches, List<ReconciliationDiscrepancy> discrepancies, String? notes, String? performedBy, DateTime? completedAt, Map<String, dynamic>? metadata, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$PaymentReconciliationCopyWithImpl<$Res>
    implements _$PaymentReconciliationCopyWith<$Res> {
  __$PaymentReconciliationCopyWithImpl(this._self, this._then);

  final _PaymentReconciliation _self;
  final $Res Function(_PaymentReconciliation) _then;

/// Create a copy of PaymentReconciliation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reconciliationDate = null,Object? periodStart = null,Object? periodEnd = null,Object? status = null,Object? totalGatewayAmount = null,Object? totalInternalAmount = null,Object? currency = null,Object? gatewayRecords = null,Object? internalRecords = null,Object? matches = null,Object? discrepancies = null,Object? notes = freezed,Object? performedBy = freezed,Object? completedAt = freezed,Object? metadata = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_PaymentReconciliation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reconciliationDate: null == reconciliationDate ? _self.reconciliationDate : reconciliationDate // ignore: cast_nullable_to_non_nullable
as DateTime,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReconciliationStatus,totalGatewayAmount: null == totalGatewayAmount ? _self.totalGatewayAmount : totalGatewayAmount // ignore: cast_nullable_to_non_nullable
as double,totalInternalAmount: null == totalInternalAmount ? _self.totalInternalAmount : totalInternalAmount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,gatewayRecords: null == gatewayRecords ? _self._gatewayRecords : gatewayRecords // ignore: cast_nullable_to_non_nullable
as List<PaymentRecord>,internalRecords: null == internalRecords ? _self._internalRecords : internalRecords // ignore: cast_nullable_to_non_nullable
as List<PaymentRecord>,matches: null == matches ? _self._matches : matches // ignore: cast_nullable_to_non_nullable
as List<ReconciliationMatch>,discrepancies: null == discrepancies ? _self._discrepancies : discrepancies // ignore: cast_nullable_to_non_nullable
as List<ReconciliationDiscrepancy>,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,performedBy: freezed == performedBy ? _self.performedBy : performedBy // ignore: cast_nullable_to_non_nullable
as String?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ReconciliationSummary {

 double get totalReconciled; double get totalDiscrepancies; int get pendingReconciliations; int get completedReconciliations; int get totalDiscrepancyCount; int get resolvedDiscrepancyCount; Map<String, int>? get discrepanciesByType; Map<String, double>? get discrepanciesByAmount; DateTime? get lastReconciliationDate; DateTime? get nextScheduledReconciliation;
/// Create a copy of ReconciliationSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReconciliationSummaryCopyWith<ReconciliationSummary> get copyWith => _$ReconciliationSummaryCopyWithImpl<ReconciliationSummary>(this as ReconciliationSummary, _$identity);

  /// Serializes this ReconciliationSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReconciliationSummary&&(identical(other.totalReconciled, totalReconciled) || other.totalReconciled == totalReconciled)&&(identical(other.totalDiscrepancies, totalDiscrepancies) || other.totalDiscrepancies == totalDiscrepancies)&&(identical(other.pendingReconciliations, pendingReconciliations) || other.pendingReconciliations == pendingReconciliations)&&(identical(other.completedReconciliations, completedReconciliations) || other.completedReconciliations == completedReconciliations)&&(identical(other.totalDiscrepancyCount, totalDiscrepancyCount) || other.totalDiscrepancyCount == totalDiscrepancyCount)&&(identical(other.resolvedDiscrepancyCount, resolvedDiscrepancyCount) || other.resolvedDiscrepancyCount == resolvedDiscrepancyCount)&&const DeepCollectionEquality().equals(other.discrepanciesByType, discrepanciesByType)&&const DeepCollectionEquality().equals(other.discrepanciesByAmount, discrepanciesByAmount)&&(identical(other.lastReconciliationDate, lastReconciliationDate) || other.lastReconciliationDate == lastReconciliationDate)&&(identical(other.nextScheduledReconciliation, nextScheduledReconciliation) || other.nextScheduledReconciliation == nextScheduledReconciliation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalReconciled,totalDiscrepancies,pendingReconciliations,completedReconciliations,totalDiscrepancyCount,resolvedDiscrepancyCount,const DeepCollectionEquality().hash(discrepanciesByType),const DeepCollectionEquality().hash(discrepanciesByAmount),lastReconciliationDate,nextScheduledReconciliation);

@override
String toString() {
  return 'ReconciliationSummary(totalReconciled: $totalReconciled, totalDiscrepancies: $totalDiscrepancies, pendingReconciliations: $pendingReconciliations, completedReconciliations: $completedReconciliations, totalDiscrepancyCount: $totalDiscrepancyCount, resolvedDiscrepancyCount: $resolvedDiscrepancyCount, discrepanciesByType: $discrepanciesByType, discrepanciesByAmount: $discrepanciesByAmount, lastReconciliationDate: $lastReconciliationDate, nextScheduledReconciliation: $nextScheduledReconciliation)';
}


}

/// @nodoc
abstract mixin class $ReconciliationSummaryCopyWith<$Res>  {
  factory $ReconciliationSummaryCopyWith(ReconciliationSummary value, $Res Function(ReconciliationSummary) _then) = _$ReconciliationSummaryCopyWithImpl;
@useResult
$Res call({
 double totalReconciled, double totalDiscrepancies, int pendingReconciliations, int completedReconciliations, int totalDiscrepancyCount, int resolvedDiscrepancyCount, Map<String, int>? discrepanciesByType, Map<String, double>? discrepanciesByAmount, DateTime? lastReconciliationDate, DateTime? nextScheduledReconciliation
});




}
/// @nodoc
class _$ReconciliationSummaryCopyWithImpl<$Res>
    implements $ReconciliationSummaryCopyWith<$Res> {
  _$ReconciliationSummaryCopyWithImpl(this._self, this._then);

  final ReconciliationSummary _self;
  final $Res Function(ReconciliationSummary) _then;

/// Create a copy of ReconciliationSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalReconciled = null,Object? totalDiscrepancies = null,Object? pendingReconciliations = null,Object? completedReconciliations = null,Object? totalDiscrepancyCount = null,Object? resolvedDiscrepancyCount = null,Object? discrepanciesByType = freezed,Object? discrepanciesByAmount = freezed,Object? lastReconciliationDate = freezed,Object? nextScheduledReconciliation = freezed,}) {
  return _then(_self.copyWith(
totalReconciled: null == totalReconciled ? _self.totalReconciled : totalReconciled // ignore: cast_nullable_to_non_nullable
as double,totalDiscrepancies: null == totalDiscrepancies ? _self.totalDiscrepancies : totalDiscrepancies // ignore: cast_nullable_to_non_nullable
as double,pendingReconciliations: null == pendingReconciliations ? _self.pendingReconciliations : pendingReconciliations // ignore: cast_nullable_to_non_nullable
as int,completedReconciliations: null == completedReconciliations ? _self.completedReconciliations : completedReconciliations // ignore: cast_nullable_to_non_nullable
as int,totalDiscrepancyCount: null == totalDiscrepancyCount ? _self.totalDiscrepancyCount : totalDiscrepancyCount // ignore: cast_nullable_to_non_nullable
as int,resolvedDiscrepancyCount: null == resolvedDiscrepancyCount ? _self.resolvedDiscrepancyCount : resolvedDiscrepancyCount // ignore: cast_nullable_to_non_nullable
as int,discrepanciesByType: freezed == discrepanciesByType ? _self.discrepanciesByType : discrepanciesByType // ignore: cast_nullable_to_non_nullable
as Map<String, int>?,discrepanciesByAmount: freezed == discrepanciesByAmount ? _self.discrepanciesByAmount : discrepanciesByAmount // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,lastReconciliationDate: freezed == lastReconciliationDate ? _self.lastReconciliationDate : lastReconciliationDate // ignore: cast_nullable_to_non_nullable
as DateTime?,nextScheduledReconciliation: freezed == nextScheduledReconciliation ? _self.nextScheduledReconciliation : nextScheduledReconciliation // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReconciliationSummary].
extension ReconciliationSummaryPatterns on ReconciliationSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReconciliationSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReconciliationSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReconciliationSummary value)  $default,){
final _that = this;
switch (_that) {
case _ReconciliationSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReconciliationSummary value)?  $default,){
final _that = this;
switch (_that) {
case _ReconciliationSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double totalReconciled,  double totalDiscrepancies,  int pendingReconciliations,  int completedReconciliations,  int totalDiscrepancyCount,  int resolvedDiscrepancyCount,  Map<String, int>? discrepanciesByType,  Map<String, double>? discrepanciesByAmount,  DateTime? lastReconciliationDate,  DateTime? nextScheduledReconciliation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReconciliationSummary() when $default != null:
return $default(_that.totalReconciled,_that.totalDiscrepancies,_that.pendingReconciliations,_that.completedReconciliations,_that.totalDiscrepancyCount,_that.resolvedDiscrepancyCount,_that.discrepanciesByType,_that.discrepanciesByAmount,_that.lastReconciliationDate,_that.nextScheduledReconciliation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double totalReconciled,  double totalDiscrepancies,  int pendingReconciliations,  int completedReconciliations,  int totalDiscrepancyCount,  int resolvedDiscrepancyCount,  Map<String, int>? discrepanciesByType,  Map<String, double>? discrepanciesByAmount,  DateTime? lastReconciliationDate,  DateTime? nextScheduledReconciliation)  $default,) {final _that = this;
switch (_that) {
case _ReconciliationSummary():
return $default(_that.totalReconciled,_that.totalDiscrepancies,_that.pendingReconciliations,_that.completedReconciliations,_that.totalDiscrepancyCount,_that.resolvedDiscrepancyCount,_that.discrepanciesByType,_that.discrepanciesByAmount,_that.lastReconciliationDate,_that.nextScheduledReconciliation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double totalReconciled,  double totalDiscrepancies,  int pendingReconciliations,  int completedReconciliations,  int totalDiscrepancyCount,  int resolvedDiscrepancyCount,  Map<String, int>? discrepanciesByType,  Map<String, double>? discrepanciesByAmount,  DateTime? lastReconciliationDate,  DateTime? nextScheduledReconciliation)?  $default,) {final _that = this;
switch (_that) {
case _ReconciliationSummary() when $default != null:
return $default(_that.totalReconciled,_that.totalDiscrepancies,_that.pendingReconciliations,_that.completedReconciliations,_that.totalDiscrepancyCount,_that.resolvedDiscrepancyCount,_that.discrepanciesByType,_that.discrepanciesByAmount,_that.lastReconciliationDate,_that.nextScheduledReconciliation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReconciliationSummary implements ReconciliationSummary {
  const _ReconciliationSummary({this.totalReconciled = 0.0, this.totalDiscrepancies = 0.0, this.pendingReconciliations = 0, this.completedReconciliations = 0, this.totalDiscrepancyCount = 0, this.resolvedDiscrepancyCount = 0, final  Map<String, int>? discrepanciesByType, final  Map<String, double>? discrepanciesByAmount, this.lastReconciliationDate, this.nextScheduledReconciliation}): _discrepanciesByType = discrepanciesByType,_discrepanciesByAmount = discrepanciesByAmount;
  factory _ReconciliationSummary.fromJson(Map<String, dynamic> json) => _$ReconciliationSummaryFromJson(json);

@override@JsonKey() final  double totalReconciled;
@override@JsonKey() final  double totalDiscrepancies;
@override@JsonKey() final  int pendingReconciliations;
@override@JsonKey() final  int completedReconciliations;
@override@JsonKey() final  int totalDiscrepancyCount;
@override@JsonKey() final  int resolvedDiscrepancyCount;
 final  Map<String, int>? _discrepanciesByType;
@override Map<String, int>? get discrepanciesByType {
  final value = _discrepanciesByType;
  if (value == null) return null;
  if (_discrepanciesByType is EqualUnmodifiableMapView) return _discrepanciesByType;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, double>? _discrepanciesByAmount;
@override Map<String, double>? get discrepanciesByAmount {
  final value = _discrepanciesByAmount;
  if (value == null) return null;
  if (_discrepanciesByAmount is EqualUnmodifiableMapView) return _discrepanciesByAmount;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  DateTime? lastReconciliationDate;
@override final  DateTime? nextScheduledReconciliation;

/// Create a copy of ReconciliationSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReconciliationSummaryCopyWith<_ReconciliationSummary> get copyWith => __$ReconciliationSummaryCopyWithImpl<_ReconciliationSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReconciliationSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReconciliationSummary&&(identical(other.totalReconciled, totalReconciled) || other.totalReconciled == totalReconciled)&&(identical(other.totalDiscrepancies, totalDiscrepancies) || other.totalDiscrepancies == totalDiscrepancies)&&(identical(other.pendingReconciliations, pendingReconciliations) || other.pendingReconciliations == pendingReconciliations)&&(identical(other.completedReconciliations, completedReconciliations) || other.completedReconciliations == completedReconciliations)&&(identical(other.totalDiscrepancyCount, totalDiscrepancyCount) || other.totalDiscrepancyCount == totalDiscrepancyCount)&&(identical(other.resolvedDiscrepancyCount, resolvedDiscrepancyCount) || other.resolvedDiscrepancyCount == resolvedDiscrepancyCount)&&const DeepCollectionEquality().equals(other._discrepanciesByType, _discrepanciesByType)&&const DeepCollectionEquality().equals(other._discrepanciesByAmount, _discrepanciesByAmount)&&(identical(other.lastReconciliationDate, lastReconciliationDate) || other.lastReconciliationDate == lastReconciliationDate)&&(identical(other.nextScheduledReconciliation, nextScheduledReconciliation) || other.nextScheduledReconciliation == nextScheduledReconciliation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalReconciled,totalDiscrepancies,pendingReconciliations,completedReconciliations,totalDiscrepancyCount,resolvedDiscrepancyCount,const DeepCollectionEquality().hash(_discrepanciesByType),const DeepCollectionEquality().hash(_discrepanciesByAmount),lastReconciliationDate,nextScheduledReconciliation);

@override
String toString() {
  return 'ReconciliationSummary(totalReconciled: $totalReconciled, totalDiscrepancies: $totalDiscrepancies, pendingReconciliations: $pendingReconciliations, completedReconciliations: $completedReconciliations, totalDiscrepancyCount: $totalDiscrepancyCount, resolvedDiscrepancyCount: $resolvedDiscrepancyCount, discrepanciesByType: $discrepanciesByType, discrepanciesByAmount: $discrepanciesByAmount, lastReconciliationDate: $lastReconciliationDate, nextScheduledReconciliation: $nextScheduledReconciliation)';
}


}

/// @nodoc
abstract mixin class _$ReconciliationSummaryCopyWith<$Res> implements $ReconciliationSummaryCopyWith<$Res> {
  factory _$ReconciliationSummaryCopyWith(_ReconciliationSummary value, $Res Function(_ReconciliationSummary) _then) = __$ReconciliationSummaryCopyWithImpl;
@override @useResult
$Res call({
 double totalReconciled, double totalDiscrepancies, int pendingReconciliations, int completedReconciliations, int totalDiscrepancyCount, int resolvedDiscrepancyCount, Map<String, int>? discrepanciesByType, Map<String, double>? discrepanciesByAmount, DateTime? lastReconciliationDate, DateTime? nextScheduledReconciliation
});




}
/// @nodoc
class __$ReconciliationSummaryCopyWithImpl<$Res>
    implements _$ReconciliationSummaryCopyWith<$Res> {
  __$ReconciliationSummaryCopyWithImpl(this._self, this._then);

  final _ReconciliationSummary _self;
  final $Res Function(_ReconciliationSummary) _then;

/// Create a copy of ReconciliationSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalReconciled = null,Object? totalDiscrepancies = null,Object? pendingReconciliations = null,Object? completedReconciliations = null,Object? totalDiscrepancyCount = null,Object? resolvedDiscrepancyCount = null,Object? discrepanciesByType = freezed,Object? discrepanciesByAmount = freezed,Object? lastReconciliationDate = freezed,Object? nextScheduledReconciliation = freezed,}) {
  return _then(_ReconciliationSummary(
totalReconciled: null == totalReconciled ? _self.totalReconciled : totalReconciled // ignore: cast_nullable_to_non_nullable
as double,totalDiscrepancies: null == totalDiscrepancies ? _self.totalDiscrepancies : totalDiscrepancies // ignore: cast_nullable_to_non_nullable
as double,pendingReconciliations: null == pendingReconciliations ? _self.pendingReconciliations : pendingReconciliations // ignore: cast_nullable_to_non_nullable
as int,completedReconciliations: null == completedReconciliations ? _self.completedReconciliations : completedReconciliations // ignore: cast_nullable_to_non_nullable
as int,totalDiscrepancyCount: null == totalDiscrepancyCount ? _self.totalDiscrepancyCount : totalDiscrepancyCount // ignore: cast_nullable_to_non_nullable
as int,resolvedDiscrepancyCount: null == resolvedDiscrepancyCount ? _self.resolvedDiscrepancyCount : resolvedDiscrepancyCount // ignore: cast_nullable_to_non_nullable
as int,discrepanciesByType: freezed == discrepanciesByType ? _self._discrepanciesByType : discrepanciesByType // ignore: cast_nullable_to_non_nullable
as Map<String, int>?,discrepanciesByAmount: freezed == discrepanciesByAmount ? _self._discrepanciesByAmount : discrepanciesByAmount // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,lastReconciliationDate: freezed == lastReconciliationDate ? _self.lastReconciliationDate : lastReconciliationDate // ignore: cast_nullable_to_non_nullable
as DateTime?,nextScheduledReconciliation: freezed == nextScheduledReconciliation ? _self.nextScheduledReconciliation : nextScheduledReconciliation // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ReconciliationFilter {

 DateTime? get startDate; DateTime? get endDate; List<ReconciliationStatus>? get statuses; List<DiscrepancyType>? get discrepancyTypes; double? get minAmount; double? get maxAmount; String? get searchQuery; String get sortBy; bool get sortDesc; int get page; int get limit;
/// Create a copy of ReconciliationFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReconciliationFilterCopyWith<ReconciliationFilter> get copyWith => _$ReconciliationFilterCopyWithImpl<ReconciliationFilter>(this as ReconciliationFilter, _$identity);

  /// Serializes this ReconciliationFilter to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReconciliationFilter&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other.statuses, statuses)&&const DeepCollectionEquality().equals(other.discrepancyTypes, discrepancyTypes)&&(identical(other.minAmount, minAmount) || other.minAmount == minAmount)&&(identical(other.maxAmount, maxAmount) || other.maxAmount == maxAmount)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.sortDesc, sortDesc) || other.sortDesc == sortDesc)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startDate,endDate,const DeepCollectionEquality().hash(statuses),const DeepCollectionEquality().hash(discrepancyTypes),minAmount,maxAmount,searchQuery,sortBy,sortDesc,page,limit);

@override
String toString() {
  return 'ReconciliationFilter(startDate: $startDate, endDate: $endDate, statuses: $statuses, discrepancyTypes: $discrepancyTypes, minAmount: $minAmount, maxAmount: $maxAmount, searchQuery: $searchQuery, sortBy: $sortBy, sortDesc: $sortDesc, page: $page, limit: $limit)';
}


}

/// @nodoc
abstract mixin class $ReconciliationFilterCopyWith<$Res>  {
  factory $ReconciliationFilterCopyWith(ReconciliationFilter value, $Res Function(ReconciliationFilter) _then) = _$ReconciliationFilterCopyWithImpl;
@useResult
$Res call({
 DateTime? startDate, DateTime? endDate, List<ReconciliationStatus>? statuses, List<DiscrepancyType>? discrepancyTypes, double? minAmount, double? maxAmount, String? searchQuery, String sortBy, bool sortDesc, int page, int limit
});




}
/// @nodoc
class _$ReconciliationFilterCopyWithImpl<$Res>
    implements $ReconciliationFilterCopyWith<$Res> {
  _$ReconciliationFilterCopyWithImpl(this._self, this._then);

  final ReconciliationFilter _self;
  final $Res Function(ReconciliationFilter) _then;

/// Create a copy of ReconciliationFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? startDate = freezed,Object? endDate = freezed,Object? statuses = freezed,Object? discrepancyTypes = freezed,Object? minAmount = freezed,Object? maxAmount = freezed,Object? searchQuery = freezed,Object? sortBy = null,Object? sortDesc = null,Object? page = null,Object? limit = null,}) {
  return _then(_self.copyWith(
startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,statuses: freezed == statuses ? _self.statuses : statuses // ignore: cast_nullable_to_non_nullable
as List<ReconciliationStatus>?,discrepancyTypes: freezed == discrepancyTypes ? _self.discrepancyTypes : discrepancyTypes // ignore: cast_nullable_to_non_nullable
as List<DiscrepancyType>?,minAmount: freezed == minAmount ? _self.minAmount : minAmount // ignore: cast_nullable_to_non_nullable
as double?,maxAmount: freezed == maxAmount ? _self.maxAmount : maxAmount // ignore: cast_nullable_to_non_nullable
as double?,searchQuery: freezed == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String?,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as String,sortDesc: null == sortDesc ? _self.sortDesc : sortDesc // ignore: cast_nullable_to_non_nullable
as bool,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ReconciliationFilter].
extension ReconciliationFilterPatterns on ReconciliationFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReconciliationFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReconciliationFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReconciliationFilter value)  $default,){
final _that = this;
switch (_that) {
case _ReconciliationFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReconciliationFilter value)?  $default,){
final _that = this;
switch (_that) {
case _ReconciliationFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime? startDate,  DateTime? endDate,  List<ReconciliationStatus>? statuses,  List<DiscrepancyType>? discrepancyTypes,  double? minAmount,  double? maxAmount,  String? searchQuery,  String sortBy,  bool sortDesc,  int page,  int limit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReconciliationFilter() when $default != null:
return $default(_that.startDate,_that.endDate,_that.statuses,_that.discrepancyTypes,_that.minAmount,_that.maxAmount,_that.searchQuery,_that.sortBy,_that.sortDesc,_that.page,_that.limit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime? startDate,  DateTime? endDate,  List<ReconciliationStatus>? statuses,  List<DiscrepancyType>? discrepancyTypes,  double? minAmount,  double? maxAmount,  String? searchQuery,  String sortBy,  bool sortDesc,  int page,  int limit)  $default,) {final _that = this;
switch (_that) {
case _ReconciliationFilter():
return $default(_that.startDate,_that.endDate,_that.statuses,_that.discrepancyTypes,_that.minAmount,_that.maxAmount,_that.searchQuery,_that.sortBy,_that.sortDesc,_that.page,_that.limit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime? startDate,  DateTime? endDate,  List<ReconciliationStatus>? statuses,  List<DiscrepancyType>? discrepancyTypes,  double? minAmount,  double? maxAmount,  String? searchQuery,  String sortBy,  bool sortDesc,  int page,  int limit)?  $default,) {final _that = this;
switch (_that) {
case _ReconciliationFilter() when $default != null:
return $default(_that.startDate,_that.endDate,_that.statuses,_that.discrepancyTypes,_that.minAmount,_that.maxAmount,_that.searchQuery,_that.sortBy,_that.sortDesc,_that.page,_that.limit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReconciliationFilter implements ReconciliationFilter {
  const _ReconciliationFilter({this.startDate, this.endDate, final  List<ReconciliationStatus>? statuses, final  List<DiscrepancyType>? discrepancyTypes, this.minAmount, this.maxAmount, this.searchQuery, this.sortBy = 'reconciliationDate', this.sortDesc = false, this.page = 1, this.limit = 20}): _statuses = statuses,_discrepancyTypes = discrepancyTypes;
  factory _ReconciliationFilter.fromJson(Map<String, dynamic> json) => _$ReconciliationFilterFromJson(json);

@override final  DateTime? startDate;
@override final  DateTime? endDate;
 final  List<ReconciliationStatus>? _statuses;
@override List<ReconciliationStatus>? get statuses {
  final value = _statuses;
  if (value == null) return null;
  if (_statuses is EqualUnmodifiableListView) return _statuses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<DiscrepancyType>? _discrepancyTypes;
@override List<DiscrepancyType>? get discrepancyTypes {
  final value = _discrepancyTypes;
  if (value == null) return null;
  if (_discrepancyTypes is EqualUnmodifiableListView) return _discrepancyTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  double? minAmount;
@override final  double? maxAmount;
@override final  String? searchQuery;
@override@JsonKey() final  String sortBy;
@override@JsonKey() final  bool sortDesc;
@override@JsonKey() final  int page;
@override@JsonKey() final  int limit;

/// Create a copy of ReconciliationFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReconciliationFilterCopyWith<_ReconciliationFilter> get copyWith => __$ReconciliationFilterCopyWithImpl<_ReconciliationFilter>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReconciliationFilterToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReconciliationFilter&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other._statuses, _statuses)&&const DeepCollectionEquality().equals(other._discrepancyTypes, _discrepancyTypes)&&(identical(other.minAmount, minAmount) || other.minAmount == minAmount)&&(identical(other.maxAmount, maxAmount) || other.maxAmount == maxAmount)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.sortDesc, sortDesc) || other.sortDesc == sortDesc)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startDate,endDate,const DeepCollectionEquality().hash(_statuses),const DeepCollectionEquality().hash(_discrepancyTypes),minAmount,maxAmount,searchQuery,sortBy,sortDesc,page,limit);

@override
String toString() {
  return 'ReconciliationFilter(startDate: $startDate, endDate: $endDate, statuses: $statuses, discrepancyTypes: $discrepancyTypes, minAmount: $minAmount, maxAmount: $maxAmount, searchQuery: $searchQuery, sortBy: $sortBy, sortDesc: $sortDesc, page: $page, limit: $limit)';
}


}

/// @nodoc
abstract mixin class _$ReconciliationFilterCopyWith<$Res> implements $ReconciliationFilterCopyWith<$Res> {
  factory _$ReconciliationFilterCopyWith(_ReconciliationFilter value, $Res Function(_ReconciliationFilter) _then) = __$ReconciliationFilterCopyWithImpl;
@override @useResult
$Res call({
 DateTime? startDate, DateTime? endDate, List<ReconciliationStatus>? statuses, List<DiscrepancyType>? discrepancyTypes, double? minAmount, double? maxAmount, String? searchQuery, String sortBy, bool sortDesc, int page, int limit
});




}
/// @nodoc
class __$ReconciliationFilterCopyWithImpl<$Res>
    implements _$ReconciliationFilterCopyWith<$Res> {
  __$ReconciliationFilterCopyWithImpl(this._self, this._then);

  final _ReconciliationFilter _self;
  final $Res Function(_ReconciliationFilter) _then;

/// Create a copy of ReconciliationFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? startDate = freezed,Object? endDate = freezed,Object? statuses = freezed,Object? discrepancyTypes = freezed,Object? minAmount = freezed,Object? maxAmount = freezed,Object? searchQuery = freezed,Object? sortBy = null,Object? sortDesc = null,Object? page = null,Object? limit = null,}) {
  return _then(_ReconciliationFilter(
startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,statuses: freezed == statuses ? _self._statuses : statuses // ignore: cast_nullable_to_non_nullable
as List<ReconciliationStatus>?,discrepancyTypes: freezed == discrepancyTypes ? _self._discrepancyTypes : discrepancyTypes // ignore: cast_nullable_to_non_nullable
as List<DiscrepancyType>?,minAmount: freezed == minAmount ? _self.minAmount : minAmount // ignore: cast_nullable_to_non_nullable
as double?,maxAmount: freezed == maxAmount ? _self.maxAmount : maxAmount // ignore: cast_nullable_to_non_nullable
as double?,searchQuery: freezed == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String?,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as String,sortDesc: null == sortDesc ? _self.sortDesc : sortDesc // ignore: cast_nullable_to_non_nullable
as bool,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on

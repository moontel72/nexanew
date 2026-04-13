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
mixin _$PaymentReconciliation {

 String get id; String get reconciliationNumber; DateTime get reconciliationDate; DateTime get periodStart; DateTime get periodEnd; ReconciliationStatus get status; double get expectedAmount; double get actualAmount; double get discrepancyAmount; int get totalTransactions; int get matchedTransactions; int get unmatchedTransactions; int get partialMatchTransactions; String get currency; String? get notes; String? get performedByAdminId; String? get performedByAdminName; DateTime? get completedAt; DateTime? get reviewedAt; String? get reviewedByAdminId; String? get reviewedByAdminName; List<ReconciliationTransaction>? get transactions; Map<String, dynamic>? get metadata; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of PaymentReconciliation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentReconciliationCopyWith<PaymentReconciliation> get copyWith => _$PaymentReconciliationCopyWithImpl<PaymentReconciliation>(this as PaymentReconciliation, _$identity);

  /// Serializes this PaymentReconciliation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentReconciliation&&(identical(other.id, id) || other.id == id)&&(identical(other.reconciliationNumber, reconciliationNumber) || other.reconciliationNumber == reconciliationNumber)&&(identical(other.reconciliationDate, reconciliationDate) || other.reconciliationDate == reconciliationDate)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.status, status) || other.status == status)&&(identical(other.expectedAmount, expectedAmount) || other.expectedAmount == expectedAmount)&&(identical(other.actualAmount, actualAmount) || other.actualAmount == actualAmount)&&(identical(other.discrepancyAmount, discrepancyAmount) || other.discrepancyAmount == discrepancyAmount)&&(identical(other.totalTransactions, totalTransactions) || other.totalTransactions == totalTransactions)&&(identical(other.matchedTransactions, matchedTransactions) || other.matchedTransactions == matchedTransactions)&&(identical(other.unmatchedTransactions, unmatchedTransactions) || other.unmatchedTransactions == unmatchedTransactions)&&(identical(other.partialMatchTransactions, partialMatchTransactions) || other.partialMatchTransactions == partialMatchTransactions)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.performedByAdminId, performedByAdminId) || other.performedByAdminId == performedByAdminId)&&(identical(other.performedByAdminName, performedByAdminName) || other.performedByAdminName == performedByAdminName)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.reviewedByAdminId, reviewedByAdminId) || other.reviewedByAdminId == reviewedByAdminId)&&(identical(other.reviewedByAdminName, reviewedByAdminName) || other.reviewedByAdminName == reviewedByAdminName)&&const DeepCollectionEquality().equals(other.transactions, transactions)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,reconciliationNumber,reconciliationDate,periodStart,periodEnd,status,expectedAmount,actualAmount,discrepancyAmount,totalTransactions,matchedTransactions,unmatchedTransactions,partialMatchTransactions,currency,notes,performedByAdminId,performedByAdminName,completedAt,reviewedAt,reviewedByAdminId,reviewedByAdminName,const DeepCollectionEquality().hash(transactions),const DeepCollectionEquality().hash(metadata),createdAt,updatedAt]);

@override
String toString() {
  return 'PaymentReconciliation(id: $id, reconciliationNumber: $reconciliationNumber, reconciliationDate: $reconciliationDate, periodStart: $periodStart, periodEnd: $periodEnd, status: $status, expectedAmount: $expectedAmount, actualAmount: $actualAmount, discrepancyAmount: $discrepancyAmount, totalTransactions: $totalTransactions, matchedTransactions: $matchedTransactions, unmatchedTransactions: $unmatchedTransactions, partialMatchTransactions: $partialMatchTransactions, currency: $currency, notes: $notes, performedByAdminId: $performedByAdminId, performedByAdminName: $performedByAdminName, completedAt: $completedAt, reviewedAt: $reviewedAt, reviewedByAdminId: $reviewedByAdminId, reviewedByAdminName: $reviewedByAdminName, transactions: $transactions, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PaymentReconciliationCopyWith<$Res>  {
  factory $PaymentReconciliationCopyWith(PaymentReconciliation value, $Res Function(PaymentReconciliation) _then) = _$PaymentReconciliationCopyWithImpl;
@useResult
$Res call({
 String id, String reconciliationNumber, DateTime reconciliationDate, DateTime periodStart, DateTime periodEnd, ReconciliationStatus status, double expectedAmount, double actualAmount, double discrepancyAmount, int totalTransactions, int matchedTransactions, int unmatchedTransactions, int partialMatchTransactions, String currency, String? notes, String? performedByAdminId, String? performedByAdminName, DateTime? completedAt, DateTime? reviewedAt, String? reviewedByAdminId, String? reviewedByAdminName, List<ReconciliationTransaction>? transactions, Map<String, dynamic>? metadata, DateTime? createdAt, DateTime? updatedAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reconciliationNumber = null,Object? reconciliationDate = null,Object? periodStart = null,Object? periodEnd = null,Object? status = null,Object? expectedAmount = null,Object? actualAmount = null,Object? discrepancyAmount = null,Object? totalTransactions = null,Object? matchedTransactions = null,Object? unmatchedTransactions = null,Object? partialMatchTransactions = null,Object? currency = null,Object? notes = freezed,Object? performedByAdminId = freezed,Object? performedByAdminName = freezed,Object? completedAt = freezed,Object? reviewedAt = freezed,Object? reviewedByAdminId = freezed,Object? reviewedByAdminName = freezed,Object? transactions = freezed,Object? metadata = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reconciliationNumber: null == reconciliationNumber ? _self.reconciliationNumber : reconciliationNumber // ignore: cast_nullable_to_non_nullable
as String,reconciliationDate: null == reconciliationDate ? _self.reconciliationDate : reconciliationDate // ignore: cast_nullable_to_non_nullable
as DateTime,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReconciliationStatus,expectedAmount: null == expectedAmount ? _self.expectedAmount : expectedAmount // ignore: cast_nullable_to_non_nullable
as double,actualAmount: null == actualAmount ? _self.actualAmount : actualAmount // ignore: cast_nullable_to_non_nullable
as double,discrepancyAmount: null == discrepancyAmount ? _self.discrepancyAmount : discrepancyAmount // ignore: cast_nullable_to_non_nullable
as double,totalTransactions: null == totalTransactions ? _self.totalTransactions : totalTransactions // ignore: cast_nullable_to_non_nullable
as int,matchedTransactions: null == matchedTransactions ? _self.matchedTransactions : matchedTransactions // ignore: cast_nullable_to_non_nullable
as int,unmatchedTransactions: null == unmatchedTransactions ? _self.unmatchedTransactions : unmatchedTransactions // ignore: cast_nullable_to_non_nullable
as int,partialMatchTransactions: null == partialMatchTransactions ? _self.partialMatchTransactions : partialMatchTransactions // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,performedByAdminId: freezed == performedByAdminId ? _self.performedByAdminId : performedByAdminId // ignore: cast_nullable_to_non_nullable
as String?,performedByAdminName: freezed == performedByAdminName ? _self.performedByAdminName : performedByAdminName // ignore: cast_nullable_to_non_nullable
as String?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewedByAdminId: freezed == reviewedByAdminId ? _self.reviewedByAdminId : reviewedByAdminId // ignore: cast_nullable_to_non_nullable
as String?,reviewedByAdminName: freezed == reviewedByAdminName ? _self.reviewedByAdminName : reviewedByAdminName // ignore: cast_nullable_to_non_nullable
as String?,transactions: freezed == transactions ? _self.transactions : transactions // ignore: cast_nullable_to_non_nullable
as List<ReconciliationTransaction>?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String reconciliationNumber,  DateTime reconciliationDate,  DateTime periodStart,  DateTime periodEnd,  ReconciliationStatus status,  double expectedAmount,  double actualAmount,  double discrepancyAmount,  int totalTransactions,  int matchedTransactions,  int unmatchedTransactions,  int partialMatchTransactions,  String currency,  String? notes,  String? performedByAdminId,  String? performedByAdminName,  DateTime? completedAt,  DateTime? reviewedAt,  String? reviewedByAdminId,  String? reviewedByAdminName,  List<ReconciliationTransaction>? transactions,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentReconciliation() when $default != null:
return $default(_that.id,_that.reconciliationNumber,_that.reconciliationDate,_that.periodStart,_that.periodEnd,_that.status,_that.expectedAmount,_that.actualAmount,_that.discrepancyAmount,_that.totalTransactions,_that.matchedTransactions,_that.unmatchedTransactions,_that.partialMatchTransactions,_that.currency,_that.notes,_that.performedByAdminId,_that.performedByAdminName,_that.completedAt,_that.reviewedAt,_that.reviewedByAdminId,_that.reviewedByAdminName,_that.transactions,_that.metadata,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String reconciliationNumber,  DateTime reconciliationDate,  DateTime periodStart,  DateTime periodEnd,  ReconciliationStatus status,  double expectedAmount,  double actualAmount,  double discrepancyAmount,  int totalTransactions,  int matchedTransactions,  int unmatchedTransactions,  int partialMatchTransactions,  String currency,  String? notes,  String? performedByAdminId,  String? performedByAdminName,  DateTime? completedAt,  DateTime? reviewedAt,  String? reviewedByAdminId,  String? reviewedByAdminName,  List<ReconciliationTransaction>? transactions,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PaymentReconciliation():
return $default(_that.id,_that.reconciliationNumber,_that.reconciliationDate,_that.periodStart,_that.periodEnd,_that.status,_that.expectedAmount,_that.actualAmount,_that.discrepancyAmount,_that.totalTransactions,_that.matchedTransactions,_that.unmatchedTransactions,_that.partialMatchTransactions,_that.currency,_that.notes,_that.performedByAdminId,_that.performedByAdminName,_that.completedAt,_that.reviewedAt,_that.reviewedByAdminId,_that.reviewedByAdminName,_that.transactions,_that.metadata,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String reconciliationNumber,  DateTime reconciliationDate,  DateTime periodStart,  DateTime periodEnd,  ReconciliationStatus status,  double expectedAmount,  double actualAmount,  double discrepancyAmount,  int totalTransactions,  int matchedTransactions,  int unmatchedTransactions,  int partialMatchTransactions,  String currency,  String? notes,  String? performedByAdminId,  String? performedByAdminName,  DateTime? completedAt,  DateTime? reviewedAt,  String? reviewedByAdminId,  String? reviewedByAdminName,  List<ReconciliationTransaction>? transactions,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PaymentReconciliation() when $default != null:
return $default(_that.id,_that.reconciliationNumber,_that.reconciliationDate,_that.periodStart,_that.periodEnd,_that.status,_that.expectedAmount,_that.actualAmount,_that.discrepancyAmount,_that.totalTransactions,_that.matchedTransactions,_that.unmatchedTransactions,_that.partialMatchTransactions,_that.currency,_that.notes,_that.performedByAdminId,_that.performedByAdminName,_that.completedAt,_that.reviewedAt,_that.reviewedByAdminId,_that.reviewedByAdminName,_that.transactions,_that.metadata,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentReconciliation implements PaymentReconciliation {
  const _PaymentReconciliation({required this.id, required this.reconciliationNumber, required this.reconciliationDate, required this.periodStart, required this.periodEnd, required this.status, required this.expectedAmount, required this.actualAmount, required this.discrepancyAmount, required this.totalTransactions, required this.matchedTransactions, required this.unmatchedTransactions, required this.partialMatchTransactions, required this.currency, this.notes, this.performedByAdminId, this.performedByAdminName, this.completedAt, this.reviewedAt, this.reviewedByAdminId, this.reviewedByAdminName, final  List<ReconciliationTransaction>? transactions, final  Map<String, dynamic>? metadata, this.createdAt, this.updatedAt}): _transactions = transactions,_metadata = metadata;
  factory _PaymentReconciliation.fromJson(Map<String, dynamic> json) => _$PaymentReconciliationFromJson(json);

@override final  String id;
@override final  String reconciliationNumber;
@override final  DateTime reconciliationDate;
@override final  DateTime periodStart;
@override final  DateTime periodEnd;
@override final  ReconciliationStatus status;
@override final  double expectedAmount;
@override final  double actualAmount;
@override final  double discrepancyAmount;
@override final  int totalTransactions;
@override final  int matchedTransactions;
@override final  int unmatchedTransactions;
@override final  int partialMatchTransactions;
@override final  String currency;
@override final  String? notes;
@override final  String? performedByAdminId;
@override final  String? performedByAdminName;
@override final  DateTime? completedAt;
@override final  DateTime? reviewedAt;
@override final  String? reviewedByAdminId;
@override final  String? reviewedByAdminName;
 final  List<ReconciliationTransaction>? _transactions;
@override List<ReconciliationTransaction>? get transactions {
  final value = _transactions;
  if (value == null) return null;
  if (_transactions is EqualUnmodifiableListView) return _transactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentReconciliation&&(identical(other.id, id) || other.id == id)&&(identical(other.reconciliationNumber, reconciliationNumber) || other.reconciliationNumber == reconciliationNumber)&&(identical(other.reconciliationDate, reconciliationDate) || other.reconciliationDate == reconciliationDate)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.status, status) || other.status == status)&&(identical(other.expectedAmount, expectedAmount) || other.expectedAmount == expectedAmount)&&(identical(other.actualAmount, actualAmount) || other.actualAmount == actualAmount)&&(identical(other.discrepancyAmount, discrepancyAmount) || other.discrepancyAmount == discrepancyAmount)&&(identical(other.totalTransactions, totalTransactions) || other.totalTransactions == totalTransactions)&&(identical(other.matchedTransactions, matchedTransactions) || other.matchedTransactions == matchedTransactions)&&(identical(other.unmatchedTransactions, unmatchedTransactions) || other.unmatchedTransactions == unmatchedTransactions)&&(identical(other.partialMatchTransactions, partialMatchTransactions) || other.partialMatchTransactions == partialMatchTransactions)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.performedByAdminId, performedByAdminId) || other.performedByAdminId == performedByAdminId)&&(identical(other.performedByAdminName, performedByAdminName) || other.performedByAdminName == performedByAdminName)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.reviewedByAdminId, reviewedByAdminId) || other.reviewedByAdminId == reviewedByAdminId)&&(identical(other.reviewedByAdminName, reviewedByAdminName) || other.reviewedByAdminName == reviewedByAdminName)&&const DeepCollectionEquality().equals(other._transactions, _transactions)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,reconciliationNumber,reconciliationDate,periodStart,periodEnd,status,expectedAmount,actualAmount,discrepancyAmount,totalTransactions,matchedTransactions,unmatchedTransactions,partialMatchTransactions,currency,notes,performedByAdminId,performedByAdminName,completedAt,reviewedAt,reviewedByAdminId,reviewedByAdminName,const DeepCollectionEquality().hash(_transactions),const DeepCollectionEquality().hash(_metadata),createdAt,updatedAt]);

@override
String toString() {
  return 'PaymentReconciliation(id: $id, reconciliationNumber: $reconciliationNumber, reconciliationDate: $reconciliationDate, periodStart: $periodStart, periodEnd: $periodEnd, status: $status, expectedAmount: $expectedAmount, actualAmount: $actualAmount, discrepancyAmount: $discrepancyAmount, totalTransactions: $totalTransactions, matchedTransactions: $matchedTransactions, unmatchedTransactions: $unmatchedTransactions, partialMatchTransactions: $partialMatchTransactions, currency: $currency, notes: $notes, performedByAdminId: $performedByAdminId, performedByAdminName: $performedByAdminName, completedAt: $completedAt, reviewedAt: $reviewedAt, reviewedByAdminId: $reviewedByAdminId, reviewedByAdminName: $reviewedByAdminName, transactions: $transactions, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PaymentReconciliationCopyWith<$Res> implements $PaymentReconciliationCopyWith<$Res> {
  factory _$PaymentReconciliationCopyWith(_PaymentReconciliation value, $Res Function(_PaymentReconciliation) _then) = __$PaymentReconciliationCopyWithImpl;
@override @useResult
$Res call({
 String id, String reconciliationNumber, DateTime reconciliationDate, DateTime periodStart, DateTime periodEnd, ReconciliationStatus status, double expectedAmount, double actualAmount, double discrepancyAmount, int totalTransactions, int matchedTransactions, int unmatchedTransactions, int partialMatchTransactions, String currency, String? notes, String? performedByAdminId, String? performedByAdminName, DateTime? completedAt, DateTime? reviewedAt, String? reviewedByAdminId, String? reviewedByAdminName, List<ReconciliationTransaction>? transactions, Map<String, dynamic>? metadata, DateTime? createdAt, DateTime? updatedAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reconciliationNumber = null,Object? reconciliationDate = null,Object? periodStart = null,Object? periodEnd = null,Object? status = null,Object? expectedAmount = null,Object? actualAmount = null,Object? discrepancyAmount = null,Object? totalTransactions = null,Object? matchedTransactions = null,Object? unmatchedTransactions = null,Object? partialMatchTransactions = null,Object? currency = null,Object? notes = freezed,Object? performedByAdminId = freezed,Object? performedByAdminName = freezed,Object? completedAt = freezed,Object? reviewedAt = freezed,Object? reviewedByAdminId = freezed,Object? reviewedByAdminName = freezed,Object? transactions = freezed,Object? metadata = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_PaymentReconciliation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reconciliationNumber: null == reconciliationNumber ? _self.reconciliationNumber : reconciliationNumber // ignore: cast_nullable_to_non_nullable
as String,reconciliationDate: null == reconciliationDate ? _self.reconciliationDate : reconciliationDate // ignore: cast_nullable_to_non_nullable
as DateTime,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReconciliationStatus,expectedAmount: null == expectedAmount ? _self.expectedAmount : expectedAmount // ignore: cast_nullable_to_non_nullable
as double,actualAmount: null == actualAmount ? _self.actualAmount : actualAmount // ignore: cast_nullable_to_non_nullable
as double,discrepancyAmount: null == discrepancyAmount ? _self.discrepancyAmount : discrepancyAmount // ignore: cast_nullable_to_non_nullable
as double,totalTransactions: null == totalTransactions ? _self.totalTransactions : totalTransactions // ignore: cast_nullable_to_non_nullable
as int,matchedTransactions: null == matchedTransactions ? _self.matchedTransactions : matchedTransactions // ignore: cast_nullable_to_non_nullable
as int,unmatchedTransactions: null == unmatchedTransactions ? _self.unmatchedTransactions : unmatchedTransactions // ignore: cast_nullable_to_non_nullable
as int,partialMatchTransactions: null == partialMatchTransactions ? _self.partialMatchTransactions : partialMatchTransactions // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,performedByAdminId: freezed == performedByAdminId ? _self.performedByAdminId : performedByAdminId // ignore: cast_nullable_to_non_nullable
as String?,performedByAdminName: freezed == performedByAdminName ? _self.performedByAdminName : performedByAdminName // ignore: cast_nullable_to_non_nullable
as String?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewedByAdminId: freezed == reviewedByAdminId ? _self.reviewedByAdminId : reviewedByAdminId // ignore: cast_nullable_to_non_nullable
as String?,reviewedByAdminName: freezed == reviewedByAdminName ? _self.reviewedByAdminName : reviewedByAdminName // ignore: cast_nullable_to_non_nullable
as String?,transactions: freezed == transactions ? _self._transactions : transactions // ignore: cast_nullable_to_non_nullable
as List<ReconciliationTransaction>?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ReconciliationTransaction {

 String get id; String get transactionId; String get transactionReference; DateTime get transactionDate; double get transactionAmount; String get transactionCurrency; TransactionSource get source; TransactionStatus get status; String? get invoiceId; String? get invoiceNumber; double? get invoiceAmount; String? get invoiceCurrency; DateTime? get invoiceDate; String? get companyId; String? get companyName; double? get matchedAmount; double? get discrepancyAmount; ReconciliationMatchStatus? get matchStatus; String? get matchNotes; DateTime? get matchedAt; String? get matchedByAdminId; String? get matchedByAdminName; Map<String, dynamic>? get transactionMetadata; Map<String, dynamic>? get matchMetadata; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of ReconciliationTransaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReconciliationTransactionCopyWith<ReconciliationTransaction> get copyWith => _$ReconciliationTransactionCopyWithImpl<ReconciliationTransaction>(this as ReconciliationTransaction, _$identity);

  /// Serializes this ReconciliationTransaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReconciliationTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.transactionReference, transactionReference) || other.transactionReference == transactionReference)&&(identical(other.transactionDate, transactionDate) || other.transactionDate == transactionDate)&&(identical(other.transactionAmount, transactionAmount) || other.transactionAmount == transactionAmount)&&(identical(other.transactionCurrency, transactionCurrency) || other.transactionCurrency == transactionCurrency)&&(identical(other.source, source) || other.source == source)&&(identical(other.status, status) || other.status == status)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.invoiceNumber, invoiceNumber) || other.invoiceNumber == invoiceNumber)&&(identical(other.invoiceAmount, invoiceAmount) || other.invoiceAmount == invoiceAmount)&&(identical(other.invoiceCurrency, invoiceCurrency) || other.invoiceCurrency == invoiceCurrency)&&(identical(other.invoiceDate, invoiceDate) || other.invoiceDate == invoiceDate)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.matchedAmount, matchedAmount) || other.matchedAmount == matchedAmount)&&(identical(other.discrepancyAmount, discrepancyAmount) || other.discrepancyAmount == discrepancyAmount)&&(identical(other.matchStatus, matchStatus) || other.matchStatus == matchStatus)&&(identical(other.matchNotes, matchNotes) || other.matchNotes == matchNotes)&&(identical(other.matchedAt, matchedAt) || other.matchedAt == matchedAt)&&(identical(other.matchedByAdminId, matchedByAdminId) || other.matchedByAdminId == matchedByAdminId)&&(identical(other.matchedByAdminName, matchedByAdminName) || other.matchedByAdminName == matchedByAdminName)&&const DeepCollectionEquality().equals(other.transactionMetadata, transactionMetadata)&&const DeepCollectionEquality().equals(other.matchMetadata, matchMetadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,transactionId,transactionReference,transactionDate,transactionAmount,transactionCurrency,source,status,invoiceId,invoiceNumber,invoiceAmount,invoiceCurrency,invoiceDate,companyId,companyName,matchedAmount,discrepancyAmount,matchStatus,matchNotes,matchedAt,matchedByAdminId,matchedByAdminName,const DeepCollectionEquality().hash(transactionMetadata),const DeepCollectionEquality().hash(matchMetadata),createdAt,updatedAt]);

@override
String toString() {
  return 'ReconciliationTransaction(id: $id, transactionId: $transactionId, transactionReference: $transactionReference, transactionDate: $transactionDate, transactionAmount: $transactionAmount, transactionCurrency: $transactionCurrency, source: $source, status: $status, invoiceId: $invoiceId, invoiceNumber: $invoiceNumber, invoiceAmount: $invoiceAmount, invoiceCurrency: $invoiceCurrency, invoiceDate: $invoiceDate, companyId: $companyId, companyName: $companyName, matchedAmount: $matchedAmount, discrepancyAmount: $discrepancyAmount, matchStatus: $matchStatus, matchNotes: $matchNotes, matchedAt: $matchedAt, matchedByAdminId: $matchedByAdminId, matchedByAdminName: $matchedByAdminName, transactionMetadata: $transactionMetadata, matchMetadata: $matchMetadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ReconciliationTransactionCopyWith<$Res>  {
  factory $ReconciliationTransactionCopyWith(ReconciliationTransaction value, $Res Function(ReconciliationTransaction) _then) = _$ReconciliationTransactionCopyWithImpl;
@useResult
$Res call({
 String id, String transactionId, String transactionReference, DateTime transactionDate, double transactionAmount, String transactionCurrency, TransactionSource source, TransactionStatus status, String? invoiceId, String? invoiceNumber, double? invoiceAmount, String? invoiceCurrency, DateTime? invoiceDate, String? companyId, String? companyName, double? matchedAmount, double? discrepancyAmount, ReconciliationMatchStatus? matchStatus, String? matchNotes, DateTime? matchedAt, String? matchedByAdminId, String? matchedByAdminName, Map<String, dynamic>? transactionMetadata, Map<String, dynamic>? matchMetadata, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$ReconciliationTransactionCopyWithImpl<$Res>
    implements $ReconciliationTransactionCopyWith<$Res> {
  _$ReconciliationTransactionCopyWithImpl(this._self, this._then);

  final ReconciliationTransaction _self;
  final $Res Function(ReconciliationTransaction) _then;

/// Create a copy of ReconciliationTransaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? transactionId = null,Object? transactionReference = null,Object? transactionDate = null,Object? transactionAmount = null,Object? transactionCurrency = null,Object? source = null,Object? status = null,Object? invoiceId = freezed,Object? invoiceNumber = freezed,Object? invoiceAmount = freezed,Object? invoiceCurrency = freezed,Object? invoiceDate = freezed,Object? companyId = freezed,Object? companyName = freezed,Object? matchedAmount = freezed,Object? discrepancyAmount = freezed,Object? matchStatus = freezed,Object? matchNotes = freezed,Object? matchedAt = freezed,Object? matchedByAdminId = freezed,Object? matchedByAdminName = freezed,Object? transactionMetadata = freezed,Object? matchMetadata = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,transactionId: null == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String,transactionReference: null == transactionReference ? _self.transactionReference : transactionReference // ignore: cast_nullable_to_non_nullable
as String,transactionDate: null == transactionDate ? _self.transactionDate : transactionDate // ignore: cast_nullable_to_non_nullable
as DateTime,transactionAmount: null == transactionAmount ? _self.transactionAmount : transactionAmount // ignore: cast_nullable_to_non_nullable
as double,transactionCurrency: null == transactionCurrency ? _self.transactionCurrency : transactionCurrency // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as TransactionSource,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TransactionStatus,invoiceId: freezed == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String?,invoiceNumber: freezed == invoiceNumber ? _self.invoiceNumber : invoiceNumber // ignore: cast_nullable_to_non_nullable
as String?,invoiceAmount: freezed == invoiceAmount ? _self.invoiceAmount : invoiceAmount // ignore: cast_nullable_to_non_nullable
as double?,invoiceCurrency: freezed == invoiceCurrency ? _self.invoiceCurrency : invoiceCurrency // ignore: cast_nullable_to_non_nullable
as String?,invoiceDate: freezed == invoiceDate ? _self.invoiceDate : invoiceDate // ignore: cast_nullable_to_non_nullable
as DateTime?,companyId: freezed == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String?,companyName: freezed == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String?,matchedAmount: freezed == matchedAmount ? _self.matchedAmount : matchedAmount // ignore: cast_nullable_to_non_nullable
as double?,discrepancyAmount: freezed == discrepancyAmount ? _self.discrepancyAmount : discrepancyAmount // ignore: cast_nullable_to_non_nullable
as double?,matchStatus: freezed == matchStatus ? _self.matchStatus : matchStatus // ignore: cast_nullable_to_non_nullable
as ReconciliationMatchStatus?,matchNotes: freezed == matchNotes ? _self.matchNotes : matchNotes // ignore: cast_nullable_to_non_nullable
as String?,matchedAt: freezed == matchedAt ? _self.matchedAt : matchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,matchedByAdminId: freezed == matchedByAdminId ? _self.matchedByAdminId : matchedByAdminId // ignore: cast_nullable_to_non_nullable
as String?,matchedByAdminName: freezed == matchedByAdminName ? _self.matchedByAdminName : matchedByAdminName // ignore: cast_nullable_to_non_nullable
as String?,transactionMetadata: freezed == transactionMetadata ? _self.transactionMetadata : transactionMetadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,matchMetadata: freezed == matchMetadata ? _self.matchMetadata : matchMetadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReconciliationTransaction].
extension ReconciliationTransactionPatterns on ReconciliationTransaction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReconciliationTransaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReconciliationTransaction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReconciliationTransaction value)  $default,){
final _that = this;
switch (_that) {
case _ReconciliationTransaction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReconciliationTransaction value)?  $default,){
final _that = this;
switch (_that) {
case _ReconciliationTransaction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String transactionId,  String transactionReference,  DateTime transactionDate,  double transactionAmount,  String transactionCurrency,  TransactionSource source,  TransactionStatus status,  String? invoiceId,  String? invoiceNumber,  double? invoiceAmount,  String? invoiceCurrency,  DateTime? invoiceDate,  String? companyId,  String? companyName,  double? matchedAmount,  double? discrepancyAmount,  ReconciliationMatchStatus? matchStatus,  String? matchNotes,  DateTime? matchedAt,  String? matchedByAdminId,  String? matchedByAdminName,  Map<String, dynamic>? transactionMetadata,  Map<String, dynamic>? matchMetadata,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReconciliationTransaction() when $default != null:
return $default(_that.id,_that.transactionId,_that.transactionReference,_that.transactionDate,_that.transactionAmount,_that.transactionCurrency,_that.source,_that.status,_that.invoiceId,_that.invoiceNumber,_that.invoiceAmount,_that.invoiceCurrency,_that.invoiceDate,_that.companyId,_that.companyName,_that.matchedAmount,_that.discrepancyAmount,_that.matchStatus,_that.matchNotes,_that.matchedAt,_that.matchedByAdminId,_that.matchedByAdminName,_that.transactionMetadata,_that.matchMetadata,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String transactionId,  String transactionReference,  DateTime transactionDate,  double transactionAmount,  String transactionCurrency,  TransactionSource source,  TransactionStatus status,  String? invoiceId,  String? invoiceNumber,  double? invoiceAmount,  String? invoiceCurrency,  DateTime? invoiceDate,  String? companyId,  String? companyName,  double? matchedAmount,  double? discrepancyAmount,  ReconciliationMatchStatus? matchStatus,  String? matchNotes,  DateTime? matchedAt,  String? matchedByAdminId,  String? matchedByAdminName,  Map<String, dynamic>? transactionMetadata,  Map<String, dynamic>? matchMetadata,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ReconciliationTransaction():
return $default(_that.id,_that.transactionId,_that.transactionReference,_that.transactionDate,_that.transactionAmount,_that.transactionCurrency,_that.source,_that.status,_that.invoiceId,_that.invoiceNumber,_that.invoiceAmount,_that.invoiceCurrency,_that.invoiceDate,_that.companyId,_that.companyName,_that.matchedAmount,_that.discrepancyAmount,_that.matchStatus,_that.matchNotes,_that.matchedAt,_that.matchedByAdminId,_that.matchedByAdminName,_that.transactionMetadata,_that.matchMetadata,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String transactionId,  String transactionReference,  DateTime transactionDate,  double transactionAmount,  String transactionCurrency,  TransactionSource source,  TransactionStatus status,  String? invoiceId,  String? invoiceNumber,  double? invoiceAmount,  String? invoiceCurrency,  DateTime? invoiceDate,  String? companyId,  String? companyName,  double? matchedAmount,  double? discrepancyAmount,  ReconciliationMatchStatus? matchStatus,  String? matchNotes,  DateTime? matchedAt,  String? matchedByAdminId,  String? matchedByAdminName,  Map<String, dynamic>? transactionMetadata,  Map<String, dynamic>? matchMetadata,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ReconciliationTransaction() when $default != null:
return $default(_that.id,_that.transactionId,_that.transactionReference,_that.transactionDate,_that.transactionAmount,_that.transactionCurrency,_that.source,_that.status,_that.invoiceId,_that.invoiceNumber,_that.invoiceAmount,_that.invoiceCurrency,_that.invoiceDate,_that.companyId,_that.companyName,_that.matchedAmount,_that.discrepancyAmount,_that.matchStatus,_that.matchNotes,_that.matchedAt,_that.matchedByAdminId,_that.matchedByAdminName,_that.transactionMetadata,_that.matchMetadata,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReconciliationTransaction implements ReconciliationTransaction {
  const _ReconciliationTransaction({required this.id, required this.transactionId, required this.transactionReference, required this.transactionDate, required this.transactionAmount, required this.transactionCurrency, required this.source, required this.status, this.invoiceId, this.invoiceNumber, this.invoiceAmount, this.invoiceCurrency, this.invoiceDate, this.companyId, this.companyName, this.matchedAmount, this.discrepancyAmount, this.matchStatus, this.matchNotes, this.matchedAt, this.matchedByAdminId, this.matchedByAdminName, final  Map<String, dynamic>? transactionMetadata, final  Map<String, dynamic>? matchMetadata, this.createdAt, this.updatedAt}): _transactionMetadata = transactionMetadata,_matchMetadata = matchMetadata;
  factory _ReconciliationTransaction.fromJson(Map<String, dynamic> json) => _$ReconciliationTransactionFromJson(json);

@override final  String id;
@override final  String transactionId;
@override final  String transactionReference;
@override final  DateTime transactionDate;
@override final  double transactionAmount;
@override final  String transactionCurrency;
@override final  TransactionSource source;
@override final  TransactionStatus status;
@override final  String? invoiceId;
@override final  String? invoiceNumber;
@override final  double? invoiceAmount;
@override final  String? invoiceCurrency;
@override final  DateTime? invoiceDate;
@override final  String? companyId;
@override final  String? companyName;
@override final  double? matchedAmount;
@override final  double? discrepancyAmount;
@override final  ReconciliationMatchStatus? matchStatus;
@override final  String? matchNotes;
@override final  DateTime? matchedAt;
@override final  String? matchedByAdminId;
@override final  String? matchedByAdminName;
 final  Map<String, dynamic>? _transactionMetadata;
@override Map<String, dynamic>? get transactionMetadata {
  final value = _transactionMetadata;
  if (value == null) return null;
  if (_transactionMetadata is EqualUnmodifiableMapView) return _transactionMetadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _matchMetadata;
@override Map<String, dynamic>? get matchMetadata {
  final value = _matchMetadata;
  if (value == null) return null;
  if (_matchMetadata is EqualUnmodifiableMapView) return _matchMetadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of ReconciliationTransaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReconciliationTransactionCopyWith<_ReconciliationTransaction> get copyWith => __$ReconciliationTransactionCopyWithImpl<_ReconciliationTransaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReconciliationTransactionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReconciliationTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.transactionReference, transactionReference) || other.transactionReference == transactionReference)&&(identical(other.transactionDate, transactionDate) || other.transactionDate == transactionDate)&&(identical(other.transactionAmount, transactionAmount) || other.transactionAmount == transactionAmount)&&(identical(other.transactionCurrency, transactionCurrency) || other.transactionCurrency == transactionCurrency)&&(identical(other.source, source) || other.source == source)&&(identical(other.status, status) || other.status == status)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.invoiceNumber, invoiceNumber) || other.invoiceNumber == invoiceNumber)&&(identical(other.invoiceAmount, invoiceAmount) || other.invoiceAmount == invoiceAmount)&&(identical(other.invoiceCurrency, invoiceCurrency) || other.invoiceCurrency == invoiceCurrency)&&(identical(other.invoiceDate, invoiceDate) || other.invoiceDate == invoiceDate)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.matchedAmount, matchedAmount) || other.matchedAmount == matchedAmount)&&(identical(other.discrepancyAmount, discrepancyAmount) || other.discrepancyAmount == discrepancyAmount)&&(identical(other.matchStatus, matchStatus) || other.matchStatus == matchStatus)&&(identical(other.matchNotes, matchNotes) || other.matchNotes == matchNotes)&&(identical(other.matchedAt, matchedAt) || other.matchedAt == matchedAt)&&(identical(other.matchedByAdminId, matchedByAdminId) || other.matchedByAdminId == matchedByAdminId)&&(identical(other.matchedByAdminName, matchedByAdminName) || other.matchedByAdminName == matchedByAdminName)&&const DeepCollectionEquality().equals(other._transactionMetadata, _transactionMetadata)&&const DeepCollectionEquality().equals(other._matchMetadata, _matchMetadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,transactionId,transactionReference,transactionDate,transactionAmount,transactionCurrency,source,status,invoiceId,invoiceNumber,invoiceAmount,invoiceCurrency,invoiceDate,companyId,companyName,matchedAmount,discrepancyAmount,matchStatus,matchNotes,matchedAt,matchedByAdminId,matchedByAdminName,const DeepCollectionEquality().hash(_transactionMetadata),const DeepCollectionEquality().hash(_matchMetadata),createdAt,updatedAt]);

@override
String toString() {
  return 'ReconciliationTransaction(id: $id, transactionId: $transactionId, transactionReference: $transactionReference, transactionDate: $transactionDate, transactionAmount: $transactionAmount, transactionCurrency: $transactionCurrency, source: $source, status: $status, invoiceId: $invoiceId, invoiceNumber: $invoiceNumber, invoiceAmount: $invoiceAmount, invoiceCurrency: $invoiceCurrency, invoiceDate: $invoiceDate, companyId: $companyId, companyName: $companyName, matchedAmount: $matchedAmount, discrepancyAmount: $discrepancyAmount, matchStatus: $matchStatus, matchNotes: $matchNotes, matchedAt: $matchedAt, matchedByAdminId: $matchedByAdminId, matchedByAdminName: $matchedByAdminName, transactionMetadata: $transactionMetadata, matchMetadata: $matchMetadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ReconciliationTransactionCopyWith<$Res> implements $ReconciliationTransactionCopyWith<$Res> {
  factory _$ReconciliationTransactionCopyWith(_ReconciliationTransaction value, $Res Function(_ReconciliationTransaction) _then) = __$ReconciliationTransactionCopyWithImpl;
@override @useResult
$Res call({
 String id, String transactionId, String transactionReference, DateTime transactionDate, double transactionAmount, String transactionCurrency, TransactionSource source, TransactionStatus status, String? invoiceId, String? invoiceNumber, double? invoiceAmount, String? invoiceCurrency, DateTime? invoiceDate, String? companyId, String? companyName, double? matchedAmount, double? discrepancyAmount, ReconciliationMatchStatus? matchStatus, String? matchNotes, DateTime? matchedAt, String? matchedByAdminId, String? matchedByAdminName, Map<String, dynamic>? transactionMetadata, Map<String, dynamic>? matchMetadata, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$ReconciliationTransactionCopyWithImpl<$Res>
    implements _$ReconciliationTransactionCopyWith<$Res> {
  __$ReconciliationTransactionCopyWithImpl(this._self, this._then);

  final _ReconciliationTransaction _self;
  final $Res Function(_ReconciliationTransaction) _then;

/// Create a copy of ReconciliationTransaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? transactionId = null,Object? transactionReference = null,Object? transactionDate = null,Object? transactionAmount = null,Object? transactionCurrency = null,Object? source = null,Object? status = null,Object? invoiceId = freezed,Object? invoiceNumber = freezed,Object? invoiceAmount = freezed,Object? invoiceCurrency = freezed,Object? invoiceDate = freezed,Object? companyId = freezed,Object? companyName = freezed,Object? matchedAmount = freezed,Object? discrepancyAmount = freezed,Object? matchStatus = freezed,Object? matchNotes = freezed,Object? matchedAt = freezed,Object? matchedByAdminId = freezed,Object? matchedByAdminName = freezed,Object? transactionMetadata = freezed,Object? matchMetadata = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_ReconciliationTransaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,transactionId: null == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String,transactionReference: null == transactionReference ? _self.transactionReference : transactionReference // ignore: cast_nullable_to_non_nullable
as String,transactionDate: null == transactionDate ? _self.transactionDate : transactionDate // ignore: cast_nullable_to_non_nullable
as DateTime,transactionAmount: null == transactionAmount ? _self.transactionAmount : transactionAmount // ignore: cast_nullable_to_non_nullable
as double,transactionCurrency: null == transactionCurrency ? _self.transactionCurrency : transactionCurrency // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as TransactionSource,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TransactionStatus,invoiceId: freezed == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String?,invoiceNumber: freezed == invoiceNumber ? _self.invoiceNumber : invoiceNumber // ignore: cast_nullable_to_non_nullable
as String?,invoiceAmount: freezed == invoiceAmount ? _self.invoiceAmount : invoiceAmount // ignore: cast_nullable_to_non_nullable
as double?,invoiceCurrency: freezed == invoiceCurrency ? _self.invoiceCurrency : invoiceCurrency // ignore: cast_nullable_to_non_nullable
as String?,invoiceDate: freezed == invoiceDate ? _self.invoiceDate : invoiceDate // ignore: cast_nullable_to_non_nullable
as DateTime?,companyId: freezed == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String?,companyName: freezed == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String?,matchedAmount: freezed == matchedAmount ? _self.matchedAmount : matchedAmount // ignore: cast_nullable_to_non_nullable
as double?,discrepancyAmount: freezed == discrepancyAmount ? _self.discrepancyAmount : discrepancyAmount // ignore: cast_nullable_to_non_nullable
as double?,matchStatus: freezed == matchStatus ? _self.matchStatus : matchStatus // ignore: cast_nullable_to_non_nullable
as ReconciliationMatchStatus?,matchNotes: freezed == matchNotes ? _self.matchNotes : matchNotes // ignore: cast_nullable_to_non_nullable
as String?,matchedAt: freezed == matchedAt ? _self.matchedAt : matchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,matchedByAdminId: freezed == matchedByAdminId ? _self.matchedByAdminId : matchedByAdminId // ignore: cast_nullable_to_non_nullable
as String?,matchedByAdminName: freezed == matchedByAdminName ? _self.matchedByAdminName : matchedByAdminName // ignore: cast_nullable_to_non_nullable
as String?,transactionMetadata: freezed == transactionMetadata ? _self._transactionMetadata : transactionMetadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,matchMetadata: freezed == matchMetadata ? _self._matchMetadata : matchMetadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ReconciliationSummary {

 double get totalExpected; double get totalActual; double get totalDiscrepancy; int get totalReconciliations; int get pendingReconciliations; int get completedReconciliations; int get requiresReviewReconciliations; int get totalTransactions; int get matchedTransactions; int get unmatchedTransactions; int get partialMatchTransactions; DateTime? get periodStart; DateTime? get periodEnd; Map<TransactionSource, double>? get amountBySource; Map<TransactionSource, int>? get countBySource; List<ReconciliationTrendData>? get trendData;
/// Create a copy of ReconciliationSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReconciliationSummaryCopyWith<ReconciliationSummary> get copyWith => _$ReconciliationSummaryCopyWithImpl<ReconciliationSummary>(this as ReconciliationSummary, _$identity);

  /// Serializes this ReconciliationSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReconciliationSummary&&(identical(other.totalExpected, totalExpected) || other.totalExpected == totalExpected)&&(identical(other.totalActual, totalActual) || other.totalActual == totalActual)&&(identical(other.totalDiscrepancy, totalDiscrepancy) || other.totalDiscrepancy == totalDiscrepancy)&&(identical(other.totalReconciliations, totalReconciliations) || other.totalReconciliations == totalReconciliations)&&(identical(other.pendingReconciliations, pendingReconciliations) || other.pendingReconciliations == pendingReconciliations)&&(identical(other.completedReconciliations, completedReconciliations) || other.completedReconciliations == completedReconciliations)&&(identical(other.requiresReviewReconciliations, requiresReviewReconciliations) || other.requiresReviewReconciliations == requiresReviewReconciliations)&&(identical(other.totalTransactions, totalTransactions) || other.totalTransactions == totalTransactions)&&(identical(other.matchedTransactions, matchedTransactions) || other.matchedTransactions == matchedTransactions)&&(identical(other.unmatchedTransactions, unmatchedTransactions) || other.unmatchedTransactions == unmatchedTransactions)&&(identical(other.partialMatchTransactions, partialMatchTransactions) || other.partialMatchTransactions == partialMatchTransactions)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&const DeepCollectionEquality().equals(other.amountBySource, amountBySource)&&const DeepCollectionEquality().equals(other.countBySource, countBySource)&&const DeepCollectionEquality().equals(other.trendData, trendData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalExpected,totalActual,totalDiscrepancy,totalReconciliations,pendingReconciliations,completedReconciliations,requiresReviewReconciliations,totalTransactions,matchedTransactions,unmatchedTransactions,partialMatchTransactions,periodStart,periodEnd,const DeepCollectionEquality().hash(amountBySource),const DeepCollectionEquality().hash(countBySource),const DeepCollectionEquality().hash(trendData));

@override
String toString() {
  return 'ReconciliationSummary(totalExpected: $totalExpected, totalActual: $totalActual, totalDiscrepancy: $totalDiscrepancy, totalReconciliations: $totalReconciliations, pendingReconciliations: $pendingReconciliations, completedReconciliations: $completedReconciliations, requiresReviewReconciliations: $requiresReviewReconciliations, totalTransactions: $totalTransactions, matchedTransactions: $matchedTransactions, unmatchedTransactions: $unmatchedTransactions, partialMatchTransactions: $partialMatchTransactions, periodStart: $periodStart, periodEnd: $periodEnd, amountBySource: $amountBySource, countBySource: $countBySource, trendData: $trendData)';
}


}

/// @nodoc
abstract mixin class $ReconciliationSummaryCopyWith<$Res>  {
  factory $ReconciliationSummaryCopyWith(ReconciliationSummary value, $Res Function(ReconciliationSummary) _then) = _$ReconciliationSummaryCopyWithImpl;
@useResult
$Res call({
 double totalExpected, double totalActual, double totalDiscrepancy, int totalReconciliations, int pendingReconciliations, int completedReconciliations, int requiresReviewReconciliations, int totalTransactions, int matchedTransactions, int unmatchedTransactions, int partialMatchTransactions, DateTime? periodStart, DateTime? periodEnd, Map<TransactionSource, double>? amountBySource, Map<TransactionSource, int>? countBySource, List<ReconciliationTrendData>? trendData
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
@pragma('vm:prefer-inline') @override $Res call({Object? totalExpected = null,Object? totalActual = null,Object? totalDiscrepancy = null,Object? totalReconciliations = null,Object? pendingReconciliations = null,Object? completedReconciliations = null,Object? requiresReviewReconciliations = null,Object? totalTransactions = null,Object? matchedTransactions = null,Object? unmatchedTransactions = null,Object? partialMatchTransactions = null,Object? periodStart = freezed,Object? periodEnd = freezed,Object? amountBySource = freezed,Object? countBySource = freezed,Object? trendData = freezed,}) {
  return _then(_self.copyWith(
totalExpected: null == totalExpected ? _self.totalExpected : totalExpected // ignore: cast_nullable_to_non_nullable
as double,totalActual: null == totalActual ? _self.totalActual : totalActual // ignore: cast_nullable_to_non_nullable
as double,totalDiscrepancy: null == totalDiscrepancy ? _self.totalDiscrepancy : totalDiscrepancy // ignore: cast_nullable_to_non_nullable
as double,totalReconciliations: null == totalReconciliations ? _self.totalReconciliations : totalReconciliations // ignore: cast_nullable_to_non_nullable
as int,pendingReconciliations: null == pendingReconciliations ? _self.pendingReconciliations : pendingReconciliations // ignore: cast_nullable_to_non_nullable
as int,completedReconciliations: null == completedReconciliations ? _self.completedReconciliations : completedReconciliations // ignore: cast_nullable_to_non_nullable
as int,requiresReviewReconciliations: null == requiresReviewReconciliations ? _self.requiresReviewReconciliations : requiresReviewReconciliations // ignore: cast_nullable_to_non_nullable
as int,totalTransactions: null == totalTransactions ? _self.totalTransactions : totalTransactions // ignore: cast_nullable_to_non_nullable
as int,matchedTransactions: null == matchedTransactions ? _self.matchedTransactions : matchedTransactions // ignore: cast_nullable_to_non_nullable
as int,unmatchedTransactions: null == unmatchedTransactions ? _self.unmatchedTransactions : unmatchedTransactions // ignore: cast_nullable_to_non_nullable
as int,partialMatchTransactions: null == partialMatchTransactions ? _self.partialMatchTransactions : partialMatchTransactions // ignore: cast_nullable_to_non_nullable
as int,periodStart: freezed == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime?,periodEnd: freezed == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,amountBySource: freezed == amountBySource ? _self.amountBySource : amountBySource // ignore: cast_nullable_to_non_nullable
as Map<TransactionSource, double>?,countBySource: freezed == countBySource ? _self.countBySource : countBySource // ignore: cast_nullable_to_non_nullable
as Map<TransactionSource, int>?,trendData: freezed == trendData ? _self.trendData : trendData // ignore: cast_nullable_to_non_nullable
as List<ReconciliationTrendData>?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double totalExpected,  double totalActual,  double totalDiscrepancy,  int totalReconciliations,  int pendingReconciliations,  int completedReconciliations,  int requiresReviewReconciliations,  int totalTransactions,  int matchedTransactions,  int unmatchedTransactions,  int partialMatchTransactions,  DateTime? periodStart,  DateTime? periodEnd,  Map<TransactionSource, double>? amountBySource,  Map<TransactionSource, int>? countBySource,  List<ReconciliationTrendData>? trendData)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReconciliationSummary() when $default != null:
return $default(_that.totalExpected,_that.totalActual,_that.totalDiscrepancy,_that.totalReconciliations,_that.pendingReconciliations,_that.completedReconciliations,_that.requiresReviewReconciliations,_that.totalTransactions,_that.matchedTransactions,_that.unmatchedTransactions,_that.partialMatchTransactions,_that.periodStart,_that.periodEnd,_that.amountBySource,_that.countBySource,_that.trendData);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double totalExpected,  double totalActual,  double totalDiscrepancy,  int totalReconciliations,  int pendingReconciliations,  int completedReconciliations,  int requiresReviewReconciliations,  int totalTransactions,  int matchedTransactions,  int unmatchedTransactions,  int partialMatchTransactions,  DateTime? periodStart,  DateTime? periodEnd,  Map<TransactionSource, double>? amountBySource,  Map<TransactionSource, int>? countBySource,  List<ReconciliationTrendData>? trendData)  $default,) {final _that = this;
switch (_that) {
case _ReconciliationSummary():
return $default(_that.totalExpected,_that.totalActual,_that.totalDiscrepancy,_that.totalReconciliations,_that.pendingReconciliations,_that.completedReconciliations,_that.requiresReviewReconciliations,_that.totalTransactions,_that.matchedTransactions,_that.unmatchedTransactions,_that.partialMatchTransactions,_that.periodStart,_that.periodEnd,_that.amountBySource,_that.countBySource,_that.trendData);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double totalExpected,  double totalActual,  double totalDiscrepancy,  int totalReconciliations,  int pendingReconciliations,  int completedReconciliations,  int requiresReviewReconciliations,  int totalTransactions,  int matchedTransactions,  int unmatchedTransactions,  int partialMatchTransactions,  DateTime? periodStart,  DateTime? periodEnd,  Map<TransactionSource, double>? amountBySource,  Map<TransactionSource, int>? countBySource,  List<ReconciliationTrendData>? trendData)?  $default,) {final _that = this;
switch (_that) {
case _ReconciliationSummary() when $default != null:
return $default(_that.totalExpected,_that.totalActual,_that.totalDiscrepancy,_that.totalReconciliations,_that.pendingReconciliations,_that.completedReconciliations,_that.requiresReviewReconciliations,_that.totalTransactions,_that.matchedTransactions,_that.unmatchedTransactions,_that.partialMatchTransactions,_that.periodStart,_that.periodEnd,_that.amountBySource,_that.countBySource,_that.trendData);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReconciliationSummary implements ReconciliationSummary {
  const _ReconciliationSummary({this.totalExpected = 0.0, this.totalActual = 0.0, this.totalDiscrepancy = 0.0, this.totalReconciliations = 0, this.pendingReconciliations = 0, this.completedReconciliations = 0, this.requiresReviewReconciliations = 0, this.totalTransactions = 0, this.matchedTransactions = 0, this.unmatchedTransactions = 0, this.partialMatchTransactions = 0, this.periodStart, this.periodEnd, final  Map<TransactionSource, double>? amountBySource, final  Map<TransactionSource, int>? countBySource, final  List<ReconciliationTrendData>? trendData}): _amountBySource = amountBySource,_countBySource = countBySource,_trendData = trendData;
  factory _ReconciliationSummary.fromJson(Map<String, dynamic> json) => _$ReconciliationSummaryFromJson(json);

@override@JsonKey() final  double totalExpected;
@override@JsonKey() final  double totalActual;
@override@JsonKey() final  double totalDiscrepancy;
@override@JsonKey() final  int totalReconciliations;
@override@JsonKey() final  int pendingReconciliations;
@override@JsonKey() final  int completedReconciliations;
@override@JsonKey() final  int requiresReviewReconciliations;
@override@JsonKey() final  int totalTransactions;
@override@JsonKey() final  int matchedTransactions;
@override@JsonKey() final  int unmatchedTransactions;
@override@JsonKey() final  int partialMatchTransactions;
@override final  DateTime? periodStart;
@override final  DateTime? periodEnd;
 final  Map<TransactionSource, double>? _amountBySource;
@override Map<TransactionSource, double>? get amountBySource {
  final value = _amountBySource;
  if (value == null) return null;
  if (_amountBySource is EqualUnmodifiableMapView) return _amountBySource;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<TransactionSource, int>? _countBySource;
@override Map<TransactionSource, int>? get countBySource {
  final value = _countBySource;
  if (value == null) return null;
  if (_countBySource is EqualUnmodifiableMapView) return _countBySource;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<ReconciliationTrendData>? _trendData;
@override List<ReconciliationTrendData>? get trendData {
  final value = _trendData;
  if (value == null) return null;
  if (_trendData is EqualUnmodifiableListView) return _trendData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReconciliationSummary&&(identical(other.totalExpected, totalExpected) || other.totalExpected == totalExpected)&&(identical(other.totalActual, totalActual) || other.totalActual == totalActual)&&(identical(other.totalDiscrepancy, totalDiscrepancy) || other.totalDiscrepancy == totalDiscrepancy)&&(identical(other.totalReconciliations, totalReconciliations) || other.totalReconciliations == totalReconciliations)&&(identical(other.pendingReconciliations, pendingReconciliations) || other.pendingReconciliations == pendingReconciliations)&&(identical(other.completedReconciliations, completedReconciliations) || other.completedReconciliations == completedReconciliations)&&(identical(other.requiresReviewReconciliations, requiresReviewReconciliations) || other.requiresReviewReconciliations == requiresReviewReconciliations)&&(identical(other.totalTransactions, totalTransactions) || other.totalTransactions == totalTransactions)&&(identical(other.matchedTransactions, matchedTransactions) || other.matchedTransactions == matchedTransactions)&&(identical(other.unmatchedTransactions, unmatchedTransactions) || other.unmatchedTransactions == unmatchedTransactions)&&(identical(other.partialMatchTransactions, partialMatchTransactions) || other.partialMatchTransactions == partialMatchTransactions)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&const DeepCollectionEquality().equals(other._amountBySource, _amountBySource)&&const DeepCollectionEquality().equals(other._countBySource, _countBySource)&&const DeepCollectionEquality().equals(other._trendData, _trendData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalExpected,totalActual,totalDiscrepancy,totalReconciliations,pendingReconciliations,completedReconciliations,requiresReviewReconciliations,totalTransactions,matchedTransactions,unmatchedTransactions,partialMatchTransactions,periodStart,periodEnd,const DeepCollectionEquality().hash(_amountBySource),const DeepCollectionEquality().hash(_countBySource),const DeepCollectionEquality().hash(_trendData));

@override
String toString() {
  return 'ReconciliationSummary(totalExpected: $totalExpected, totalActual: $totalActual, totalDiscrepancy: $totalDiscrepancy, totalReconciliations: $totalReconciliations, pendingReconciliations: $pendingReconciliations, completedReconciliations: $completedReconciliations, requiresReviewReconciliations: $requiresReviewReconciliations, totalTransactions: $totalTransactions, matchedTransactions: $matchedTransactions, unmatchedTransactions: $unmatchedTransactions, partialMatchTransactions: $partialMatchTransactions, periodStart: $periodStart, periodEnd: $periodEnd, amountBySource: $amountBySource, countBySource: $countBySource, trendData: $trendData)';
}


}

/// @nodoc
abstract mixin class _$ReconciliationSummaryCopyWith<$Res> implements $ReconciliationSummaryCopyWith<$Res> {
  factory _$ReconciliationSummaryCopyWith(_ReconciliationSummary value, $Res Function(_ReconciliationSummary) _then) = __$ReconciliationSummaryCopyWithImpl;
@override @useResult
$Res call({
 double totalExpected, double totalActual, double totalDiscrepancy, int totalReconciliations, int pendingReconciliations, int completedReconciliations, int requiresReviewReconciliations, int totalTransactions, int matchedTransactions, int unmatchedTransactions, int partialMatchTransactions, DateTime? periodStart, DateTime? periodEnd, Map<TransactionSource, double>? amountBySource, Map<TransactionSource, int>? countBySource, List<ReconciliationTrendData>? trendData
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
@override @pragma('vm:prefer-inline') $Res call({Object? totalExpected = null,Object? totalActual = null,Object? totalDiscrepancy = null,Object? totalReconciliations = null,Object? pendingReconciliations = null,Object? completedReconciliations = null,Object? requiresReviewReconciliations = null,Object? totalTransactions = null,Object? matchedTransactions = null,Object? unmatchedTransactions = null,Object? partialMatchTransactions = null,Object? periodStart = freezed,Object? periodEnd = freezed,Object? amountBySource = freezed,Object? countBySource = freezed,Object? trendData = freezed,}) {
  return _then(_ReconciliationSummary(
totalExpected: null == totalExpected ? _self.totalExpected : totalExpected // ignore: cast_nullable_to_non_nullable
as double,totalActual: null == totalActual ? _self.totalActual : totalActual // ignore: cast_nullable_to_non_nullable
as double,totalDiscrepancy: null == totalDiscrepancy ? _self.totalDiscrepancy : totalDiscrepancy // ignore: cast_nullable_to_non_nullable
as double,totalReconciliations: null == totalReconciliations ? _self.totalReconciliations : totalReconciliations // ignore: cast_nullable_to_non_nullable
as int,pendingReconciliations: null == pendingReconciliations ? _self.pendingReconciliations : pendingReconciliations // ignore: cast_nullable_to_non_nullable
as int,completedReconciliations: null == completedReconciliations ? _self.completedReconciliations : completedReconciliations // ignore: cast_nullable_to_non_nullable
as int,requiresReviewReconciliations: null == requiresReviewReconciliations ? _self.requiresReviewReconciliations : requiresReviewReconciliations // ignore: cast_nullable_to_non_nullable
as int,totalTransactions: null == totalTransactions ? _self.totalTransactions : totalTransactions // ignore: cast_nullable_to_non_nullable
as int,matchedTransactions: null == matchedTransactions ? _self.matchedTransactions : matchedTransactions // ignore: cast_nullable_to_non_nullable
as int,unmatchedTransactions: null == unmatchedTransactions ? _self.unmatchedTransactions : unmatchedTransactions // ignore: cast_nullable_to_non_nullable
as int,partialMatchTransactions: null == partialMatchTransactions ? _self.partialMatchTransactions : partialMatchTransactions // ignore: cast_nullable_to_non_nullable
as int,periodStart: freezed == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime?,periodEnd: freezed == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,amountBySource: freezed == amountBySource ? _self._amountBySource : amountBySource // ignore: cast_nullable_to_non_nullable
as Map<TransactionSource, double>?,countBySource: freezed == countBySource ? _self._countBySource : countBySource // ignore: cast_nullable_to_non_nullable
as Map<TransactionSource, int>?,trendData: freezed == trendData ? _self._trendData : trendData // ignore: cast_nullable_to_non_nullable
as List<ReconciliationTrendData>?,
  ));
}


}


/// @nodoc
mixin _$ReconciliationTrendData {

 DateTime get date; double get expectedAmount; double get actualAmount; double get discrepancyAmount; int get transactionCount; int get matchedCount; int get unmatchedCount;
/// Create a copy of ReconciliationTrendData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReconciliationTrendDataCopyWith<ReconciliationTrendData> get copyWith => _$ReconciliationTrendDataCopyWithImpl<ReconciliationTrendData>(this as ReconciliationTrendData, _$identity);

  /// Serializes this ReconciliationTrendData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReconciliationTrendData&&(identical(other.date, date) || other.date == date)&&(identical(other.expectedAmount, expectedAmount) || other.expectedAmount == expectedAmount)&&(identical(other.actualAmount, actualAmount) || other.actualAmount == actualAmount)&&(identical(other.discrepancyAmount, discrepancyAmount) || other.discrepancyAmount == discrepancyAmount)&&(identical(other.transactionCount, transactionCount) || other.transactionCount == transactionCount)&&(identical(other.matchedCount, matchedCount) || other.matchedCount == matchedCount)&&(identical(other.unmatchedCount, unmatchedCount) || other.unmatchedCount == unmatchedCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,expectedAmount,actualAmount,discrepancyAmount,transactionCount,matchedCount,unmatchedCount);

@override
String toString() {
  return 'ReconciliationTrendData(date: $date, expectedAmount: $expectedAmount, actualAmount: $actualAmount, discrepancyAmount: $discrepancyAmount, transactionCount: $transactionCount, matchedCount: $matchedCount, unmatchedCount: $unmatchedCount)';
}


}

/// @nodoc
abstract mixin class $ReconciliationTrendDataCopyWith<$Res>  {
  factory $ReconciliationTrendDataCopyWith(ReconciliationTrendData value, $Res Function(ReconciliationTrendData) _then) = _$ReconciliationTrendDataCopyWithImpl;
@useResult
$Res call({
 DateTime date, double expectedAmount, double actualAmount, double discrepancyAmount, int transactionCount, int matchedCount, int unmatchedCount
});




}
/// @nodoc
class _$ReconciliationTrendDataCopyWithImpl<$Res>
    implements $ReconciliationTrendDataCopyWith<$Res> {
  _$ReconciliationTrendDataCopyWithImpl(this._self, this._then);

  final ReconciliationTrendData _self;
  final $Res Function(ReconciliationTrendData) _then;

/// Create a copy of ReconciliationTrendData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? expectedAmount = null,Object? actualAmount = null,Object? discrepancyAmount = null,Object? transactionCount = null,Object? matchedCount = null,Object? unmatchedCount = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,expectedAmount: null == expectedAmount ? _self.expectedAmount : expectedAmount // ignore: cast_nullable_to_non_nullable
as double,actualAmount: null == actualAmount ? _self.actualAmount : actualAmount // ignore: cast_nullable_to_non_nullable
as double,discrepancyAmount: null == discrepancyAmount ? _self.discrepancyAmount : discrepancyAmount // ignore: cast_nullable_to_non_nullable
as double,transactionCount: null == transactionCount ? _self.transactionCount : transactionCount // ignore: cast_nullable_to_non_nullable
as int,matchedCount: null == matchedCount ? _self.matchedCount : matchedCount // ignore: cast_nullable_to_non_nullable
as int,unmatchedCount: null == unmatchedCount ? _self.unmatchedCount : unmatchedCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ReconciliationTrendData].
extension ReconciliationTrendDataPatterns on ReconciliationTrendData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReconciliationTrendData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReconciliationTrendData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReconciliationTrendData value)  $default,){
final _that = this;
switch (_that) {
case _ReconciliationTrendData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReconciliationTrendData value)?  $default,){
final _that = this;
switch (_that) {
case _ReconciliationTrendData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  double expectedAmount,  double actualAmount,  double discrepancyAmount,  int transactionCount,  int matchedCount,  int unmatchedCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReconciliationTrendData() when $default != null:
return $default(_that.date,_that.expectedAmount,_that.actualAmount,_that.discrepancyAmount,_that.transactionCount,_that.matchedCount,_that.unmatchedCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  double expectedAmount,  double actualAmount,  double discrepancyAmount,  int transactionCount,  int matchedCount,  int unmatchedCount)  $default,) {final _that = this;
switch (_that) {
case _ReconciliationTrendData():
return $default(_that.date,_that.expectedAmount,_that.actualAmount,_that.discrepancyAmount,_that.transactionCount,_that.matchedCount,_that.unmatchedCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  double expectedAmount,  double actualAmount,  double discrepancyAmount,  int transactionCount,  int matchedCount,  int unmatchedCount)?  $default,) {final _that = this;
switch (_that) {
case _ReconciliationTrendData() when $default != null:
return $default(_that.date,_that.expectedAmount,_that.actualAmount,_that.discrepancyAmount,_that.transactionCount,_that.matchedCount,_that.unmatchedCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReconciliationTrendData implements ReconciliationTrendData {
  const _ReconciliationTrendData({required this.date, required this.expectedAmount, required this.actualAmount, required this.discrepancyAmount, required this.transactionCount, required this.matchedCount, required this.unmatchedCount});
  factory _ReconciliationTrendData.fromJson(Map<String, dynamic> json) => _$ReconciliationTrendDataFromJson(json);

@override final  DateTime date;
@override final  double expectedAmount;
@override final  double actualAmount;
@override final  double discrepancyAmount;
@override final  int transactionCount;
@override final  int matchedCount;
@override final  int unmatchedCount;

/// Create a copy of ReconciliationTrendData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReconciliationTrendDataCopyWith<_ReconciliationTrendData> get copyWith => __$ReconciliationTrendDataCopyWithImpl<_ReconciliationTrendData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReconciliationTrendDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReconciliationTrendData&&(identical(other.date, date) || other.date == date)&&(identical(other.expectedAmount, expectedAmount) || other.expectedAmount == expectedAmount)&&(identical(other.actualAmount, actualAmount) || other.actualAmount == actualAmount)&&(identical(other.discrepancyAmount, discrepancyAmount) || other.discrepancyAmount == discrepancyAmount)&&(identical(other.transactionCount, transactionCount) || other.transactionCount == transactionCount)&&(identical(other.matchedCount, matchedCount) || other.matchedCount == matchedCount)&&(identical(other.unmatchedCount, unmatchedCount) || other.unmatchedCount == unmatchedCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,expectedAmount,actualAmount,discrepancyAmount,transactionCount,matchedCount,unmatchedCount);

@override
String toString() {
  return 'ReconciliationTrendData(date: $date, expectedAmount: $expectedAmount, actualAmount: $actualAmount, discrepancyAmount: $discrepancyAmount, transactionCount: $transactionCount, matchedCount: $matchedCount, unmatchedCount: $unmatchedCount)';
}


}

/// @nodoc
abstract mixin class _$ReconciliationTrendDataCopyWith<$Res> implements $ReconciliationTrendDataCopyWith<$Res> {
  factory _$ReconciliationTrendDataCopyWith(_ReconciliationTrendData value, $Res Function(_ReconciliationTrendData) _then) = __$ReconciliationTrendDataCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, double expectedAmount, double actualAmount, double discrepancyAmount, int transactionCount, int matchedCount, int unmatchedCount
});




}
/// @nodoc
class __$ReconciliationTrendDataCopyWithImpl<$Res>
    implements _$ReconciliationTrendDataCopyWith<$Res> {
  __$ReconciliationTrendDataCopyWithImpl(this._self, this._then);

  final _ReconciliationTrendData _self;
  final $Res Function(_ReconciliationTrendData) _then;

/// Create a copy of ReconciliationTrendData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? expectedAmount = null,Object? actualAmount = null,Object? discrepancyAmount = null,Object? transactionCount = null,Object? matchedCount = null,Object? unmatchedCount = null,}) {
  return _then(_ReconciliationTrendData(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,expectedAmount: null == expectedAmount ? _self.expectedAmount : expectedAmount // ignore: cast_nullable_to_non_nullable
as double,actualAmount: null == actualAmount ? _self.actualAmount : actualAmount // ignore: cast_nullable_to_non_nullable
as double,discrepancyAmount: null == discrepancyAmount ? _self.discrepancyAmount : discrepancyAmount // ignore: cast_nullable_to_non_nullable
as double,transactionCount: null == transactionCount ? _self.transactionCount : transactionCount // ignore: cast_nullable_to_non_nullable
as int,matchedCount: null == matchedCount ? _self.matchedCount : matchedCount // ignore: cast_nullable_to_non_nullable
as int,unmatchedCount: null == unmatchedCount ? _self.unmatchedCount : unmatchedCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ReconciliationDiscrepancy {

 String get id; String get reconciliationId; String get transactionId; String get transactionReference; DateTime get transactionDate; double get transactionAmount; double get expectedAmount; double get discrepancyAmount; DiscrepancyType get type; DiscrepancySeverity get severity; String? get invoiceId; String? get invoiceNumber; String? get companyId; String? get companyName; String? get notes; String? get resolvedByAdminId; String? get resolvedByAdminName; DateTime? get resolvedAt; DiscrepancyResolution? get resolution; String? get resolutionNotes; Map<String, dynamic>? get metadata; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of ReconciliationDiscrepancy
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReconciliationDiscrepancyCopyWith<ReconciliationDiscrepancy> get copyWith => _$ReconciliationDiscrepancyCopyWithImpl<ReconciliationDiscrepancy>(this as ReconciliationDiscrepancy, _$identity);

  /// Serializes this ReconciliationDiscrepancy to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReconciliationDiscrepancy&&(identical(other.id, id) || other.id == id)&&(identical(other.reconciliationId, reconciliationId) || other.reconciliationId == reconciliationId)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.transactionReference, transactionReference) || other.transactionReference == transactionReference)&&(identical(other.transactionDate, transactionDate) || other.transactionDate == transactionDate)&&(identical(other.transactionAmount, transactionAmount) || other.transactionAmount == transactionAmount)&&(identical(other.expectedAmount, expectedAmount) || other.expectedAmount == expectedAmount)&&(identical(other.discrepancyAmount, discrepancyAmount) || other.discrepancyAmount == discrepancyAmount)&&(identical(other.type, type) || other.type == type)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.invoiceNumber, invoiceNumber) || other.invoiceNumber == invoiceNumber)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.resolvedByAdminId, resolvedByAdminId) || other.resolvedByAdminId == resolvedByAdminId)&&(identical(other.resolvedByAdminName, resolvedByAdminName) || other.resolvedByAdminName == resolvedByAdminName)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.resolution, resolution) || other.resolution == resolution)&&(identical(other.resolutionNotes, resolutionNotes) || other.resolutionNotes == resolutionNotes)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,reconciliationId,transactionId,transactionReference,transactionDate,transactionAmount,expectedAmount,discrepancyAmount,type,severity,invoiceId,invoiceNumber,companyId,companyName,notes,resolvedByAdminId,resolvedByAdminName,resolvedAt,resolution,resolutionNotes,const DeepCollectionEquality().hash(metadata),createdAt,updatedAt]);

@override
String toString() {
  return 'ReconciliationDiscrepancy(id: $id, reconciliationId: $reconciliationId, transactionId: $transactionId, transactionReference: $transactionReference, transactionDate: $transactionDate, transactionAmount: $transactionAmount, expectedAmount: $expectedAmount, discrepancyAmount: $discrepancyAmount, type: $type, severity: $severity, invoiceId: $invoiceId, invoiceNumber: $invoiceNumber, companyId: $companyId, companyName: $companyName, notes: $notes, resolvedByAdminId: $resolvedByAdminId, resolvedByAdminName: $resolvedByAdminName, resolvedAt: $resolvedAt, resolution: $resolution, resolutionNotes: $resolutionNotes, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ReconciliationDiscrepancyCopyWith<$Res>  {
  factory $ReconciliationDiscrepancyCopyWith(ReconciliationDiscrepancy value, $Res Function(ReconciliationDiscrepancy) _then) = _$ReconciliationDiscrepancyCopyWithImpl;
@useResult
$Res call({
 String id, String reconciliationId, String transactionId, String transactionReference, DateTime transactionDate, double transactionAmount, double expectedAmount, double discrepancyAmount, DiscrepancyType type, DiscrepancySeverity severity, String? invoiceId, String? invoiceNumber, String? companyId, String? companyName, String? notes, String? resolvedByAdminId, String? resolvedByAdminName, DateTime? resolvedAt, DiscrepancyResolution? resolution, String? resolutionNotes, Map<String, dynamic>? metadata, DateTime? createdAt, DateTime? updatedAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reconciliationId = null,Object? transactionId = null,Object? transactionReference = null,Object? transactionDate = null,Object? transactionAmount = null,Object? expectedAmount = null,Object? discrepancyAmount = null,Object? type = null,Object? severity = null,Object? invoiceId = freezed,Object? invoiceNumber = freezed,Object? companyId = freezed,Object? companyName = freezed,Object? notes = freezed,Object? resolvedByAdminId = freezed,Object? resolvedByAdminName = freezed,Object? resolvedAt = freezed,Object? resolution = freezed,Object? resolutionNotes = freezed,Object? metadata = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reconciliationId: null == reconciliationId ? _self.reconciliationId : reconciliationId // ignore: cast_nullable_to_non_nullable
as String,transactionId: null == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String,transactionReference: null == transactionReference ? _self.transactionReference : transactionReference // ignore: cast_nullable_to_non_nullable
as String,transactionDate: null == transactionDate ? _self.transactionDate : transactionDate // ignore: cast_nullable_to_non_nullable
as DateTime,transactionAmount: null == transactionAmount ? _self.transactionAmount : transactionAmount // ignore: cast_nullable_to_non_nullable
as double,expectedAmount: null == expectedAmount ? _self.expectedAmount : expectedAmount // ignore: cast_nullable_to_non_nullable
as double,discrepancyAmount: null == discrepancyAmount ? _self.discrepancyAmount : discrepancyAmount // ignore: cast_nullable_to_non_nullable
as double,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DiscrepancyType,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as DiscrepancySeverity,invoiceId: freezed == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String?,invoiceNumber: freezed == invoiceNumber ? _self.invoiceNumber : invoiceNumber // ignore: cast_nullable_to_non_nullable
as String?,companyId: freezed == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String?,companyName: freezed == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,resolvedByAdminId: freezed == resolvedByAdminId ? _self.resolvedByAdminId : resolvedByAdminId // ignore: cast_nullable_to_non_nullable
as String?,resolvedByAdminName: freezed == resolvedByAdminName ? _self.resolvedByAdminName : resolvedByAdminName // ignore: cast_nullable_to_non_nullable
as String?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,resolution: freezed == resolution ? _self.resolution : resolution // ignore: cast_nullable_to_non_nullable
as DiscrepancyResolution?,resolutionNotes: freezed == resolutionNotes ? _self.resolutionNotes : resolutionNotes // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String reconciliationId,  String transactionId,  String transactionReference,  DateTime transactionDate,  double transactionAmount,  double expectedAmount,  double discrepancyAmount,  DiscrepancyType type,  DiscrepancySeverity severity,  String? invoiceId,  String? invoiceNumber,  String? companyId,  String? companyName,  String? notes,  String? resolvedByAdminId,  String? resolvedByAdminName,  DateTime? resolvedAt,  DiscrepancyResolution? resolution,  String? resolutionNotes,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReconciliationDiscrepancy() when $default != null:
return $default(_that.id,_that.reconciliationId,_that.transactionId,_that.transactionReference,_that.transactionDate,_that.transactionAmount,_that.expectedAmount,_that.discrepancyAmount,_that.type,_that.severity,_that.invoiceId,_that.invoiceNumber,_that.companyId,_that.companyName,_that.notes,_that.resolvedByAdminId,_that.resolvedByAdminName,_that.resolvedAt,_that.resolution,_that.resolutionNotes,_that.metadata,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String reconciliationId,  String transactionId,  String transactionReference,  DateTime transactionDate,  double transactionAmount,  double expectedAmount,  double discrepancyAmount,  DiscrepancyType type,  DiscrepancySeverity severity,  String? invoiceId,  String? invoiceNumber,  String? companyId,  String? companyName,  String? notes,  String? resolvedByAdminId,  String? resolvedByAdminName,  DateTime? resolvedAt,  DiscrepancyResolution? resolution,  String? resolutionNotes,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ReconciliationDiscrepancy():
return $default(_that.id,_that.reconciliationId,_that.transactionId,_that.transactionReference,_that.transactionDate,_that.transactionAmount,_that.expectedAmount,_that.discrepancyAmount,_that.type,_that.severity,_that.invoiceId,_that.invoiceNumber,_that.companyId,_that.companyName,_that.notes,_that.resolvedByAdminId,_that.resolvedByAdminName,_that.resolvedAt,_that.resolution,_that.resolutionNotes,_that.metadata,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String reconciliationId,  String transactionId,  String transactionReference,  DateTime transactionDate,  double transactionAmount,  double expectedAmount,  double discrepancyAmount,  DiscrepancyType type,  DiscrepancySeverity severity,  String? invoiceId,  String? invoiceNumber,  String? companyId,  String? companyName,  String? notes,  String? resolvedByAdminId,  String? resolvedByAdminName,  DateTime? resolvedAt,  DiscrepancyResolution? resolution,  String? resolutionNotes,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ReconciliationDiscrepancy() when $default != null:
return $default(_that.id,_that.reconciliationId,_that.transactionId,_that.transactionReference,_that.transactionDate,_that.transactionAmount,_that.expectedAmount,_that.discrepancyAmount,_that.type,_that.severity,_that.invoiceId,_that.invoiceNumber,_that.companyId,_that.companyName,_that.notes,_that.resolvedByAdminId,_that.resolvedByAdminName,_that.resolvedAt,_that.resolution,_that.resolutionNotes,_that.metadata,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReconciliationDiscrepancy implements ReconciliationDiscrepancy {
  const _ReconciliationDiscrepancy({required this.id, required this.reconciliationId, required this.transactionId, required this.transactionReference, required this.transactionDate, required this.transactionAmount, required this.expectedAmount, required this.discrepancyAmount, required this.type, required this.severity, this.invoiceId, this.invoiceNumber, this.companyId, this.companyName, this.notes, this.resolvedByAdminId, this.resolvedByAdminName, this.resolvedAt, this.resolution, this.resolutionNotes, final  Map<String, dynamic>? metadata, this.createdAt, this.updatedAt}): _metadata = metadata;
  factory _ReconciliationDiscrepancy.fromJson(Map<String, dynamic> json) => _$ReconciliationDiscrepancyFromJson(json);

@override final  String id;
@override final  String reconciliationId;
@override final  String transactionId;
@override final  String transactionReference;
@override final  DateTime transactionDate;
@override final  double transactionAmount;
@override final  double expectedAmount;
@override final  double discrepancyAmount;
@override final  DiscrepancyType type;
@override final  DiscrepancySeverity severity;
@override final  String? invoiceId;
@override final  String? invoiceNumber;
@override final  String? companyId;
@override final  String? companyName;
@override final  String? notes;
@override final  String? resolvedByAdminId;
@override final  String? resolvedByAdminName;
@override final  DateTime? resolvedAt;
@override final  DiscrepancyResolution? resolution;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReconciliationDiscrepancy&&(identical(other.id, id) || other.id == id)&&(identical(other.reconciliationId, reconciliationId) || other.reconciliationId == reconciliationId)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.transactionReference, transactionReference) || other.transactionReference == transactionReference)&&(identical(other.transactionDate, transactionDate) || other.transactionDate == transactionDate)&&(identical(other.transactionAmount, transactionAmount) || other.transactionAmount == transactionAmount)&&(identical(other.expectedAmount, expectedAmount) || other.expectedAmount == expectedAmount)&&(identical(other.discrepancyAmount, discrepancyAmount) || other.discrepancyAmount == discrepancyAmount)&&(identical(other.type, type) || other.type == type)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.invoiceNumber, invoiceNumber) || other.invoiceNumber == invoiceNumber)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.resolvedByAdminId, resolvedByAdminId) || other.resolvedByAdminId == resolvedByAdminId)&&(identical(other.resolvedByAdminName, resolvedByAdminName) || other.resolvedByAdminName == resolvedByAdminName)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.resolution, resolution) || other.resolution == resolution)&&(identical(other.resolutionNotes, resolutionNotes) || other.resolutionNotes == resolutionNotes)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,reconciliationId,transactionId,transactionReference,transactionDate,transactionAmount,expectedAmount,discrepancyAmount,type,severity,invoiceId,invoiceNumber,companyId,companyName,notes,resolvedByAdminId,resolvedByAdminName,resolvedAt,resolution,resolutionNotes,const DeepCollectionEquality().hash(_metadata),createdAt,updatedAt]);

@override
String toString() {
  return 'ReconciliationDiscrepancy(id: $id, reconciliationId: $reconciliationId, transactionId: $transactionId, transactionReference: $transactionReference, transactionDate: $transactionDate, transactionAmount: $transactionAmount, expectedAmount: $expectedAmount, discrepancyAmount: $discrepancyAmount, type: $type, severity: $severity, invoiceId: $invoiceId, invoiceNumber: $invoiceNumber, companyId: $companyId, companyName: $companyName, notes: $notes, resolvedByAdminId: $resolvedByAdminId, resolvedByAdminName: $resolvedByAdminName, resolvedAt: $resolvedAt, resolution: $resolution, resolutionNotes: $resolutionNotes, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ReconciliationDiscrepancyCopyWith<$Res> implements $ReconciliationDiscrepancyCopyWith<$Res> {
  factory _$ReconciliationDiscrepancyCopyWith(_ReconciliationDiscrepancy value, $Res Function(_ReconciliationDiscrepancy) _then) = __$ReconciliationDiscrepancyCopyWithImpl;
@override @useResult
$Res call({
 String id, String reconciliationId, String transactionId, String transactionReference, DateTime transactionDate, double transactionAmount, double expectedAmount, double discrepancyAmount, DiscrepancyType type, DiscrepancySeverity severity, String? invoiceId, String? invoiceNumber, String? companyId, String? companyName, String? notes, String? resolvedByAdminId, String? resolvedByAdminName, DateTime? resolvedAt, DiscrepancyResolution? resolution, String? resolutionNotes, Map<String, dynamic>? metadata, DateTime? createdAt, DateTime? updatedAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reconciliationId = null,Object? transactionId = null,Object? transactionReference = null,Object? transactionDate = null,Object? transactionAmount = null,Object? expectedAmount = null,Object? discrepancyAmount = null,Object? type = null,Object? severity = null,Object? invoiceId = freezed,Object? invoiceNumber = freezed,Object? companyId = freezed,Object? companyName = freezed,Object? notes = freezed,Object? resolvedByAdminId = freezed,Object? resolvedByAdminName = freezed,Object? resolvedAt = freezed,Object? resolution = freezed,Object? resolutionNotes = freezed,Object? metadata = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_ReconciliationDiscrepancy(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reconciliationId: null == reconciliationId ? _self.reconciliationId : reconciliationId // ignore: cast_nullable_to_non_nullable
as String,transactionId: null == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String,transactionReference: null == transactionReference ? _self.transactionReference : transactionReference // ignore: cast_nullable_to_non_nullable
as String,transactionDate: null == transactionDate ? _self.transactionDate : transactionDate // ignore: cast_nullable_to_non_nullable
as DateTime,transactionAmount: null == transactionAmount ? _self.transactionAmount : transactionAmount // ignore: cast_nullable_to_non_nullable
as double,expectedAmount: null == expectedAmount ? _self.expectedAmount : expectedAmount // ignore: cast_nullable_to_non_nullable
as double,discrepancyAmount: null == discrepancyAmount ? _self.discrepancyAmount : discrepancyAmount // ignore: cast_nullable_to_non_nullable
as double,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DiscrepancyType,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as DiscrepancySeverity,invoiceId: freezed == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String?,invoiceNumber: freezed == invoiceNumber ? _self.invoiceNumber : invoiceNumber // ignore: cast_nullable_to_non_nullable
as String?,companyId: freezed == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String?,companyName: freezed == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,resolvedByAdminId: freezed == resolvedByAdminId ? _self.resolvedByAdminId : resolvedByAdminId // ignore: cast_nullable_to_non_nullable
as String?,resolvedByAdminName: freezed == resolvedByAdminName ? _self.resolvedByAdminName : resolvedByAdminName // ignore: cast_nullable_to_non_nullable
as String?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,resolution: freezed == resolution ? _self.resolution : resolution // ignore: cast_nullable_to_non_nullable
as DiscrepancyResolution?,resolutionNotes: freezed == resolutionNotes ? _self.resolutionNotes : resolutionNotes // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ReconciliationFilter {

 DateTime? get startDate; DateTime? get endDate; List<ReconciliationStatus>? get statuses; List<TransactionSource>? get sources; String? get searchQuery; double? get minDiscrepancy; double? get maxDiscrepancy; String get sortBy; bool get sortDesc; int get page; int get limit;
/// Create a copy of ReconciliationFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReconciliationFilterCopyWith<ReconciliationFilter> get copyWith => _$ReconciliationFilterCopyWithImpl<ReconciliationFilter>(this as ReconciliationFilter, _$identity);

  /// Serializes this ReconciliationFilter to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReconciliationFilter&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other.statuses, statuses)&&const DeepCollectionEquality().equals(other.sources, sources)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.minDiscrepancy, minDiscrepancy) || other.minDiscrepancy == minDiscrepancy)&&(identical(other.maxDiscrepancy, maxDiscrepancy) || other.maxDiscrepancy == maxDiscrepancy)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.sortDesc, sortDesc) || other.sortDesc == sortDesc)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startDate,endDate,const DeepCollectionEquality().hash(statuses),const DeepCollectionEquality().hash(sources),searchQuery,minDiscrepancy,maxDiscrepancy,sortBy,sortDesc,page,limit);

@override
String toString() {
  return 'ReconciliationFilter(startDate: $startDate, endDate: $endDate, statuses: $statuses, sources: $sources, searchQuery: $searchQuery, minDiscrepancy: $minDiscrepancy, maxDiscrepancy: $maxDiscrepancy, sortBy: $sortBy, sortDesc: $sortDesc, page: $page, limit: $limit)';
}


}

/// @nodoc
abstract mixin class $ReconciliationFilterCopyWith<$Res>  {
  factory $ReconciliationFilterCopyWith(ReconciliationFilter value, $Res Function(ReconciliationFilter) _then) = _$ReconciliationFilterCopyWithImpl;
@useResult
$Res call({
 DateTime? startDate, DateTime? endDate, List<ReconciliationStatus>? statuses, List<TransactionSource>? sources, String? searchQuery, double? minDiscrepancy, double? maxDiscrepancy, String sortBy, bool sortDesc, int page, int limit
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
@pragma('vm:prefer-inline') @override $Res call({Object? startDate = freezed,Object? endDate = freezed,Object? statuses = freezed,Object? sources = freezed,Object? searchQuery = freezed,Object? minDiscrepancy = freezed,Object? maxDiscrepancy = freezed,Object? sortBy = null,Object? sortDesc = null,Object? page = null,Object? limit = null,}) {
  return _then(_self.copyWith(
startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,statuses: freezed == statuses ? _self.statuses : statuses // ignore: cast_nullable_to_non_nullable
as List<ReconciliationStatus>?,sources: freezed == sources ? _self.sources : sources // ignore: cast_nullable_to_non_nullable
as List<TransactionSource>?,searchQuery: freezed == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String?,minDiscrepancy: freezed == minDiscrepancy ? _self.minDiscrepancy : minDiscrepancy // ignore: cast_nullable_to_non_nullable
as double?,maxDiscrepancy: freezed == maxDiscrepancy ? _self.maxDiscrepancy : maxDiscrepancy // ignore: cast_nullable_to_non_nullable
as double?,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime? startDate,  DateTime? endDate,  List<ReconciliationStatus>? statuses,  List<TransactionSource>? sources,  String? searchQuery,  double? minDiscrepancy,  double? maxDiscrepancy,  String sortBy,  bool sortDesc,  int page,  int limit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReconciliationFilter() when $default != null:
return $default(_that.startDate,_that.endDate,_that.statuses,_that.sources,_that.searchQuery,_that.minDiscrepancy,_that.maxDiscrepancy,_that.sortBy,_that.sortDesc,_that.page,_that.limit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime? startDate,  DateTime? endDate,  List<ReconciliationStatus>? statuses,  List<TransactionSource>? sources,  String? searchQuery,  double? minDiscrepancy,  double? maxDiscrepancy,  String sortBy,  bool sortDesc,  int page,  int limit)  $default,) {final _that = this;
switch (_that) {
case _ReconciliationFilter():
return $default(_that.startDate,_that.endDate,_that.statuses,_that.sources,_that.searchQuery,_that.minDiscrepancy,_that.maxDiscrepancy,_that.sortBy,_that.sortDesc,_that.page,_that.limit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime? startDate,  DateTime? endDate,  List<ReconciliationStatus>? statuses,  List<TransactionSource>? sources,  String? searchQuery,  double? minDiscrepancy,  double? maxDiscrepancy,  String sortBy,  bool sortDesc,  int page,  int limit)?  $default,) {final _that = this;
switch (_that) {
case _ReconciliationFilter() when $default != null:
return $default(_that.startDate,_that.endDate,_that.statuses,_that.sources,_that.searchQuery,_that.minDiscrepancy,_that.maxDiscrepancy,_that.sortBy,_that.sortDesc,_that.page,_that.limit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReconciliationFilter implements ReconciliationFilter {
  const _ReconciliationFilter({this.startDate, this.endDate, final  List<ReconciliationStatus>? statuses, final  List<TransactionSource>? sources, this.searchQuery, this.minDiscrepancy, this.maxDiscrepancy, this.sortBy = 'reconciliationDate', this.sortDesc = true, this.page = 1, this.limit = 20}): _statuses = statuses,_sources = sources;
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

 final  List<TransactionSource>? _sources;
@override List<TransactionSource>? get sources {
  final value = _sources;
  if (value == null) return null;
  if (_sources is EqualUnmodifiableListView) return _sources;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? searchQuery;
@override final  double? minDiscrepancy;
@override final  double? maxDiscrepancy;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReconciliationFilter&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other._statuses, _statuses)&&const DeepCollectionEquality().equals(other._sources, _sources)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.minDiscrepancy, minDiscrepancy) || other.minDiscrepancy == minDiscrepancy)&&(identical(other.maxDiscrepancy, maxDiscrepancy) || other.maxDiscrepancy == maxDiscrepancy)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.sortDesc, sortDesc) || other.sortDesc == sortDesc)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startDate,endDate,const DeepCollectionEquality().hash(_statuses),const DeepCollectionEquality().hash(_sources),searchQuery,minDiscrepancy,maxDiscrepancy,sortBy,sortDesc,page,limit);

@override
String toString() {
  return 'ReconciliationFilter(startDate: $startDate, endDate: $endDate, statuses: $statuses, sources: $sources, searchQuery: $searchQuery, minDiscrepancy: $minDiscrepancy, maxDiscrepancy: $maxDiscrepancy, sortBy: $sortBy, sortDesc: $sortDesc, page: $page, limit: $limit)';
}


}

/// @nodoc
abstract mixin class _$ReconciliationFilterCopyWith<$Res> implements $ReconciliationFilterCopyWith<$Res> {
  factory _$ReconciliationFilterCopyWith(_ReconciliationFilter value, $Res Function(_ReconciliationFilter) _then) = __$ReconciliationFilterCopyWithImpl;
@override @useResult
$Res call({
 DateTime? startDate, DateTime? endDate, List<ReconciliationStatus>? statuses, List<TransactionSource>? sources, String? searchQuery, double? minDiscrepancy, double? maxDiscrepancy, String sortBy, bool sortDesc, int page, int limit
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
@override @pragma('vm:prefer-inline') $Res call({Object? startDate = freezed,Object? endDate = freezed,Object? statuses = freezed,Object? sources = freezed,Object? searchQuery = freezed,Object? minDiscrepancy = freezed,Object? maxDiscrepancy = freezed,Object? sortBy = null,Object? sortDesc = null,Object? page = null,Object? limit = null,}) {
  return _then(_ReconciliationFilter(
startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,statuses: freezed == statuses ? _self._statuses : statuses // ignore: cast_nullable_to_non_nullable
as List<ReconciliationStatus>?,sources: freezed == sources ? _self._sources : sources // ignore: cast_nullable_to_non_nullable
as List<TransactionSource>?,searchQuery: freezed == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String?,minDiscrepancy: freezed == minDiscrepancy ? _self.minDiscrepancy : minDiscrepancy // ignore: cast_nullable_to_non_nullable
as double?,maxDiscrepancy: freezed == maxDiscrepancy ? _self.maxDiscrepancy : maxDiscrepancy // ignore: cast_nullable_to_non_nullable
as double?,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as String,sortDesc: null == sortDesc ? _self.sortDesc : sortDesc // ignore: cast_nullable_to_non_nullable
as bool,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on

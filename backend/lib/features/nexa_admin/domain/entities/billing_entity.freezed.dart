// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'billing_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BillingEntity {

/// Unique identifier for the billing entity
 String get id;/// Type of billing entity (invoice, credit note, payment, etc.)
 BillingEntityType get type;/// Reference number for the entity (invoice number, credit note number, etc.)
 String get referenceNumber;/// Company associated with this billing entity
 String get companyId; String get companyName;/// Financial amounts
 double get amount; String get currency;/// Status of the billing entity
 BillingEntityStatus get status;/// Dates
 DateTime get issueDate; DateTime? get dueDate; DateTime? get paymentDate; DateTime? get settlementDate;/// Payment information
 PaymentMethod? get paymentMethod; String? get paymentReference; String? get transactionId;/// Notes and metadata
 String? get notes; String? get adminNotes; Map<String, dynamic>? get metadata;/// Audit fields
 DateTime? get createdAt; DateTime? get updatedAt; String? get createdByAdminId; String? get updatedByAdminId;
/// Create a copy of BillingEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillingEntityCopyWith<BillingEntity> get copyWith => _$BillingEntityCopyWithImpl<BillingEntity>(this as BillingEntity, _$identity);

  /// Serializes this BillingEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillingEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.referenceNumber, referenceNumber) || other.referenceNumber == referenceNumber)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.issueDate, issueDate) || other.issueDate == issueDate)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.paymentDate, paymentDate) || other.paymentDate == paymentDate)&&(identical(other.settlementDate, settlementDate) || other.settlementDate == settlementDate)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.paymentReference, paymentReference) || other.paymentReference == paymentReference)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.adminNotes, adminNotes) || other.adminNotes == adminNotes)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.createdByAdminId, createdByAdminId) || other.createdByAdminId == createdByAdminId)&&(identical(other.updatedByAdminId, updatedByAdminId) || other.updatedByAdminId == updatedByAdminId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,type,referenceNumber,companyId,companyName,amount,currency,status,issueDate,dueDate,paymentDate,settlementDate,paymentMethod,paymentReference,transactionId,notes,adminNotes,const DeepCollectionEquality().hash(metadata),createdAt,updatedAt,createdByAdminId,updatedByAdminId]);

@override
String toString() {
  return 'BillingEntity(id: $id, type: $type, referenceNumber: $referenceNumber, companyId: $companyId, companyName: $companyName, amount: $amount, currency: $currency, status: $status, issueDate: $issueDate, dueDate: $dueDate, paymentDate: $paymentDate, settlementDate: $settlementDate, paymentMethod: $paymentMethod, paymentReference: $paymentReference, transactionId: $transactionId, notes: $notes, adminNotes: $adminNotes, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt, createdByAdminId: $createdByAdminId, updatedByAdminId: $updatedByAdminId)';
}


}

/// @nodoc
abstract mixin class $BillingEntityCopyWith<$Res>  {
  factory $BillingEntityCopyWith(BillingEntity value, $Res Function(BillingEntity) _then) = _$BillingEntityCopyWithImpl;
@useResult
$Res call({
 String id, BillingEntityType type, String referenceNumber, String companyId, String companyName, double amount, String currency, BillingEntityStatus status, DateTime issueDate, DateTime? dueDate, DateTime? paymentDate, DateTime? settlementDate, PaymentMethod? paymentMethod, String? paymentReference, String? transactionId, String? notes, String? adminNotes, Map<String, dynamic>? metadata, DateTime? createdAt, DateTime? updatedAt, String? createdByAdminId, String? updatedByAdminId
});




}
/// @nodoc
class _$BillingEntityCopyWithImpl<$Res>
    implements $BillingEntityCopyWith<$Res> {
  _$BillingEntityCopyWithImpl(this._self, this._then);

  final BillingEntity _self;
  final $Res Function(BillingEntity) _then;

/// Create a copy of BillingEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? referenceNumber = null,Object? companyId = null,Object? companyName = null,Object? amount = null,Object? currency = null,Object? status = null,Object? issueDate = null,Object? dueDate = freezed,Object? paymentDate = freezed,Object? settlementDate = freezed,Object? paymentMethod = freezed,Object? paymentReference = freezed,Object? transactionId = freezed,Object? notes = freezed,Object? adminNotes = freezed,Object? metadata = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? createdByAdminId = freezed,Object? updatedByAdminId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as BillingEntityType,referenceNumber: null == referenceNumber ? _self.referenceNumber : referenceNumber // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,companyName: null == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BillingEntityStatus,issueDate: null == issueDate ? _self.issueDate : issueDate // ignore: cast_nullable_to_non_nullable
as DateTime,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,paymentDate: freezed == paymentDate ? _self.paymentDate : paymentDate // ignore: cast_nullable_to_non_nullable
as DateTime?,settlementDate: freezed == settlementDate ? _self.settlementDate : settlementDate // ignore: cast_nullable_to_non_nullable
as DateTime?,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod?,paymentReference: freezed == paymentReference ? _self.paymentReference : paymentReference // ignore: cast_nullable_to_non_nullable
as String?,transactionId: freezed == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,adminNotes: freezed == adminNotes ? _self.adminNotes : adminNotes // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdByAdminId: freezed == createdByAdminId ? _self.createdByAdminId : createdByAdminId // ignore: cast_nullable_to_non_nullable
as String?,updatedByAdminId: freezed == updatedByAdminId ? _self.updatedByAdminId : updatedByAdminId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BillingEntity].
extension BillingEntityPatterns on BillingEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BillingEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BillingEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BillingEntity value)  $default,){
final _that = this;
switch (_that) {
case _BillingEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BillingEntity value)?  $default,){
final _that = this;
switch (_that) {
case _BillingEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  BillingEntityType type,  String referenceNumber,  String companyId,  String companyName,  double amount,  String currency,  BillingEntityStatus status,  DateTime issueDate,  DateTime? dueDate,  DateTime? paymentDate,  DateTime? settlementDate,  PaymentMethod? paymentMethod,  String? paymentReference,  String? transactionId,  String? notes,  String? adminNotes,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt,  String? createdByAdminId,  String? updatedByAdminId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BillingEntity() when $default != null:
return $default(_that.id,_that.type,_that.referenceNumber,_that.companyId,_that.companyName,_that.amount,_that.currency,_that.status,_that.issueDate,_that.dueDate,_that.paymentDate,_that.settlementDate,_that.paymentMethod,_that.paymentReference,_that.transactionId,_that.notes,_that.adminNotes,_that.metadata,_that.createdAt,_that.updatedAt,_that.createdByAdminId,_that.updatedByAdminId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  BillingEntityType type,  String referenceNumber,  String companyId,  String companyName,  double amount,  String currency,  BillingEntityStatus status,  DateTime issueDate,  DateTime? dueDate,  DateTime? paymentDate,  DateTime? settlementDate,  PaymentMethod? paymentMethod,  String? paymentReference,  String? transactionId,  String? notes,  String? adminNotes,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt,  String? createdByAdminId,  String? updatedByAdminId)  $default,) {final _that = this;
switch (_that) {
case _BillingEntity():
return $default(_that.id,_that.type,_that.referenceNumber,_that.companyId,_that.companyName,_that.amount,_that.currency,_that.status,_that.issueDate,_that.dueDate,_that.paymentDate,_that.settlementDate,_that.paymentMethod,_that.paymentReference,_that.transactionId,_that.notes,_that.adminNotes,_that.metadata,_that.createdAt,_that.updatedAt,_that.createdByAdminId,_that.updatedByAdminId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  BillingEntityType type,  String referenceNumber,  String companyId,  String companyName,  double amount,  String currency,  BillingEntityStatus status,  DateTime issueDate,  DateTime? dueDate,  DateTime? paymentDate,  DateTime? settlementDate,  PaymentMethod? paymentMethod,  String? paymentReference,  String? transactionId,  String? notes,  String? adminNotes,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt,  String? createdByAdminId,  String? updatedByAdminId)?  $default,) {final _that = this;
switch (_that) {
case _BillingEntity() when $default != null:
return $default(_that.id,_that.type,_that.referenceNumber,_that.companyId,_that.companyName,_that.amount,_that.currency,_that.status,_that.issueDate,_that.dueDate,_that.paymentDate,_that.settlementDate,_that.paymentMethod,_that.paymentReference,_that.transactionId,_that.notes,_that.adminNotes,_that.metadata,_that.createdAt,_that.updatedAt,_that.createdByAdminId,_that.updatedByAdminId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BillingEntity extends BillingEntity {
  const _BillingEntity({required this.id, required this.type, required this.referenceNumber, required this.companyId, required this.companyName, required this.amount, required this.currency, required this.status, required this.issueDate, this.dueDate, this.paymentDate, this.settlementDate, this.paymentMethod, this.paymentReference, this.transactionId, this.notes, this.adminNotes, final  Map<String, dynamic>? metadata, this.createdAt, this.updatedAt, this.createdByAdminId, this.updatedByAdminId}): _metadata = metadata,super._();
  factory _BillingEntity.fromJson(Map<String, dynamic> json) => _$BillingEntityFromJson(json);

/// Unique identifier for the billing entity
@override final  String id;
/// Type of billing entity (invoice, credit note, payment, etc.)
@override final  BillingEntityType type;
/// Reference number for the entity (invoice number, credit note number, etc.)
@override final  String referenceNumber;
/// Company associated with this billing entity
@override final  String companyId;
@override final  String companyName;
/// Financial amounts
@override final  double amount;
@override final  String currency;
/// Status of the billing entity
@override final  BillingEntityStatus status;
/// Dates
@override final  DateTime issueDate;
@override final  DateTime? dueDate;
@override final  DateTime? paymentDate;
@override final  DateTime? settlementDate;
/// Payment information
@override final  PaymentMethod? paymentMethod;
@override final  String? paymentReference;
@override final  String? transactionId;
/// Notes and metadata
@override final  String? notes;
@override final  String? adminNotes;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// Audit fields
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
@override final  String? createdByAdminId;
@override final  String? updatedByAdminId;

/// Create a copy of BillingEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BillingEntityCopyWith<_BillingEntity> get copyWith => __$BillingEntityCopyWithImpl<_BillingEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BillingEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BillingEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.referenceNumber, referenceNumber) || other.referenceNumber == referenceNumber)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.issueDate, issueDate) || other.issueDate == issueDate)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.paymentDate, paymentDate) || other.paymentDate == paymentDate)&&(identical(other.settlementDate, settlementDate) || other.settlementDate == settlementDate)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.paymentReference, paymentReference) || other.paymentReference == paymentReference)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.adminNotes, adminNotes) || other.adminNotes == adminNotes)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.createdByAdminId, createdByAdminId) || other.createdByAdminId == createdByAdminId)&&(identical(other.updatedByAdminId, updatedByAdminId) || other.updatedByAdminId == updatedByAdminId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,type,referenceNumber,companyId,companyName,amount,currency,status,issueDate,dueDate,paymentDate,settlementDate,paymentMethod,paymentReference,transactionId,notes,adminNotes,const DeepCollectionEquality().hash(_metadata),createdAt,updatedAt,createdByAdminId,updatedByAdminId]);

@override
String toString() {
  return 'BillingEntity(id: $id, type: $type, referenceNumber: $referenceNumber, companyId: $companyId, companyName: $companyName, amount: $amount, currency: $currency, status: $status, issueDate: $issueDate, dueDate: $dueDate, paymentDate: $paymentDate, settlementDate: $settlementDate, paymentMethod: $paymentMethod, paymentReference: $paymentReference, transactionId: $transactionId, notes: $notes, adminNotes: $adminNotes, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt, createdByAdminId: $createdByAdminId, updatedByAdminId: $updatedByAdminId)';
}


}

/// @nodoc
abstract mixin class _$BillingEntityCopyWith<$Res> implements $BillingEntityCopyWith<$Res> {
  factory _$BillingEntityCopyWith(_BillingEntity value, $Res Function(_BillingEntity) _then) = __$BillingEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, BillingEntityType type, String referenceNumber, String companyId, String companyName, double amount, String currency, BillingEntityStatus status, DateTime issueDate, DateTime? dueDate, DateTime? paymentDate, DateTime? settlementDate, PaymentMethod? paymentMethod, String? paymentReference, String? transactionId, String? notes, String? adminNotes, Map<String, dynamic>? metadata, DateTime? createdAt, DateTime? updatedAt, String? createdByAdminId, String? updatedByAdminId
});




}
/// @nodoc
class __$BillingEntityCopyWithImpl<$Res>
    implements _$BillingEntityCopyWith<$Res> {
  __$BillingEntityCopyWithImpl(this._self, this._then);

  final _BillingEntity _self;
  final $Res Function(_BillingEntity) _then;

/// Create a copy of BillingEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? referenceNumber = null,Object? companyId = null,Object? companyName = null,Object? amount = null,Object? currency = null,Object? status = null,Object? issueDate = null,Object? dueDate = freezed,Object? paymentDate = freezed,Object? settlementDate = freezed,Object? paymentMethod = freezed,Object? paymentReference = freezed,Object? transactionId = freezed,Object? notes = freezed,Object? adminNotes = freezed,Object? metadata = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? createdByAdminId = freezed,Object? updatedByAdminId = freezed,}) {
  return _then(_BillingEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as BillingEntityType,referenceNumber: null == referenceNumber ? _self.referenceNumber : referenceNumber // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,companyName: null == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BillingEntityStatus,issueDate: null == issueDate ? _self.issueDate : issueDate // ignore: cast_nullable_to_non_nullable
as DateTime,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,paymentDate: freezed == paymentDate ? _self.paymentDate : paymentDate // ignore: cast_nullable_to_non_nullable
as DateTime?,settlementDate: freezed == settlementDate ? _self.settlementDate : settlementDate // ignore: cast_nullable_to_non_nullable
as DateTime?,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod?,paymentReference: freezed == paymentReference ? _self.paymentReference : paymentReference // ignore: cast_nullable_to_non_nullable
as String?,transactionId: freezed == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,adminNotes: freezed == adminNotes ? _self.adminNotes : adminNotes // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdByAdminId: freezed == createdByAdminId ? _self.createdByAdminId : createdByAdminId // ignore: cast_nullable_to_non_nullable
as String?,updatedByAdminId: freezed == updatedByAdminId ? _self.updatedByAdminId : updatedByAdminId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$BillingPeriod {

 String get id; String get companyId; String get subscriptionId; DateTime get periodStart; DateTime get periodEnd; BillingPeriodStatus get status; double? get estimatedAmount; double? get actualAmount; String? get invoiceId; DateTime? get invoicedAt; DateTime? get paidAt; Map<String, dynamic>? get usageData; Map<String, dynamic>? get metadata; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of BillingPeriod
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillingPeriodCopyWith<BillingPeriod> get copyWith => _$BillingPeriodCopyWithImpl<BillingPeriod>(this as BillingPeriod, _$identity);

  /// Serializes this BillingPeriod to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillingPeriod&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.subscriptionId, subscriptionId) || other.subscriptionId == subscriptionId)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.status, status) || other.status == status)&&(identical(other.estimatedAmount, estimatedAmount) || other.estimatedAmount == estimatedAmount)&&(identical(other.actualAmount, actualAmount) || other.actualAmount == actualAmount)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.invoicedAt, invoicedAt) || other.invoicedAt == invoicedAt)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&const DeepCollectionEquality().equals(other.usageData, usageData)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,companyId,subscriptionId,periodStart,periodEnd,status,estimatedAmount,actualAmount,invoiceId,invoicedAt,paidAt,const DeepCollectionEquality().hash(usageData),const DeepCollectionEquality().hash(metadata),createdAt,updatedAt);

@override
String toString() {
  return 'BillingPeriod(id: $id, companyId: $companyId, subscriptionId: $subscriptionId, periodStart: $periodStart, periodEnd: $periodEnd, status: $status, estimatedAmount: $estimatedAmount, actualAmount: $actualAmount, invoiceId: $invoiceId, invoicedAt: $invoicedAt, paidAt: $paidAt, usageData: $usageData, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $BillingPeriodCopyWith<$Res>  {
  factory $BillingPeriodCopyWith(BillingPeriod value, $Res Function(BillingPeriod) _then) = _$BillingPeriodCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String subscriptionId, DateTime periodStart, DateTime periodEnd, BillingPeriodStatus status, double? estimatedAmount, double? actualAmount, String? invoiceId, DateTime? invoicedAt, DateTime? paidAt, Map<String, dynamic>? usageData, Map<String, dynamic>? metadata, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$BillingPeriodCopyWithImpl<$Res>
    implements $BillingPeriodCopyWith<$Res> {
  _$BillingPeriodCopyWithImpl(this._self, this._then);

  final BillingPeriod _self;
  final $Res Function(BillingPeriod) _then;

/// Create a copy of BillingPeriod
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? subscriptionId = null,Object? periodStart = null,Object? periodEnd = null,Object? status = null,Object? estimatedAmount = freezed,Object? actualAmount = freezed,Object? invoiceId = freezed,Object? invoicedAt = freezed,Object? paidAt = freezed,Object? usageData = freezed,Object? metadata = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,subscriptionId: null == subscriptionId ? _self.subscriptionId : subscriptionId // ignore: cast_nullable_to_non_nullable
as String,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BillingPeriodStatus,estimatedAmount: freezed == estimatedAmount ? _self.estimatedAmount : estimatedAmount // ignore: cast_nullable_to_non_nullable
as double?,actualAmount: freezed == actualAmount ? _self.actualAmount : actualAmount // ignore: cast_nullable_to_non_nullable
as double?,invoiceId: freezed == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String?,invoicedAt: freezed == invoicedAt ? _self.invoicedAt : invoicedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,usageData: freezed == usageData ? _self.usageData : usageData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [BillingPeriod].
extension BillingPeriodPatterns on BillingPeriod {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BillingPeriod value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BillingPeriod() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BillingPeriod value)  $default,){
final _that = this;
switch (_that) {
case _BillingPeriod():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BillingPeriod value)?  $default,){
final _that = this;
switch (_that) {
case _BillingPeriod() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String subscriptionId,  DateTime periodStart,  DateTime periodEnd,  BillingPeriodStatus status,  double? estimatedAmount,  double? actualAmount,  String? invoiceId,  DateTime? invoicedAt,  DateTime? paidAt,  Map<String, dynamic>? usageData,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BillingPeriod() when $default != null:
return $default(_that.id,_that.companyId,_that.subscriptionId,_that.periodStart,_that.periodEnd,_that.status,_that.estimatedAmount,_that.actualAmount,_that.invoiceId,_that.invoicedAt,_that.paidAt,_that.usageData,_that.metadata,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String subscriptionId,  DateTime periodStart,  DateTime periodEnd,  BillingPeriodStatus status,  double? estimatedAmount,  double? actualAmount,  String? invoiceId,  DateTime? invoicedAt,  DateTime? paidAt,  Map<String, dynamic>? usageData,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _BillingPeriod():
return $default(_that.id,_that.companyId,_that.subscriptionId,_that.periodStart,_that.periodEnd,_that.status,_that.estimatedAmount,_that.actualAmount,_that.invoiceId,_that.invoicedAt,_that.paidAt,_that.usageData,_that.metadata,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String subscriptionId,  DateTime periodStart,  DateTime periodEnd,  BillingPeriodStatus status,  double? estimatedAmount,  double? actualAmount,  String? invoiceId,  DateTime? invoicedAt,  DateTime? paidAt,  Map<String, dynamic>? usageData,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _BillingPeriod() when $default != null:
return $default(_that.id,_that.companyId,_that.subscriptionId,_that.periodStart,_that.periodEnd,_that.status,_that.estimatedAmount,_that.actualAmount,_that.invoiceId,_that.invoicedAt,_that.paidAt,_that.usageData,_that.metadata,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BillingPeriod implements BillingPeriod {
  const _BillingPeriod({required this.id, required this.companyId, required this.subscriptionId, required this.periodStart, required this.periodEnd, required this.status, this.estimatedAmount, this.actualAmount, this.invoiceId, this.invoicedAt, this.paidAt, final  Map<String, dynamic>? usageData, final  Map<String, dynamic>? metadata, this.createdAt, this.updatedAt}): _usageData = usageData,_metadata = metadata;
  factory _BillingPeriod.fromJson(Map<String, dynamic> json) => _$BillingPeriodFromJson(json);

@override final  String id;
@override final  String companyId;
@override final  String subscriptionId;
@override final  DateTime periodStart;
@override final  DateTime periodEnd;
@override final  BillingPeriodStatus status;
@override final  double? estimatedAmount;
@override final  double? actualAmount;
@override final  String? invoiceId;
@override final  DateTime? invoicedAt;
@override final  DateTime? paidAt;
 final  Map<String, dynamic>? _usageData;
@override Map<String, dynamic>? get usageData {
  final value = _usageData;
  if (value == null) return null;
  if (_usageData is EqualUnmodifiableMapView) return _usageData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
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

/// Create a copy of BillingPeriod
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BillingPeriodCopyWith<_BillingPeriod> get copyWith => __$BillingPeriodCopyWithImpl<_BillingPeriod>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BillingPeriodToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BillingPeriod&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.subscriptionId, subscriptionId) || other.subscriptionId == subscriptionId)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.status, status) || other.status == status)&&(identical(other.estimatedAmount, estimatedAmount) || other.estimatedAmount == estimatedAmount)&&(identical(other.actualAmount, actualAmount) || other.actualAmount == actualAmount)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.invoicedAt, invoicedAt) || other.invoicedAt == invoicedAt)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&const DeepCollectionEquality().equals(other._usageData, _usageData)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,companyId,subscriptionId,periodStart,periodEnd,status,estimatedAmount,actualAmount,invoiceId,invoicedAt,paidAt,const DeepCollectionEquality().hash(_usageData),const DeepCollectionEquality().hash(_metadata),createdAt,updatedAt);

@override
String toString() {
  return 'BillingPeriod(id: $id, companyId: $companyId, subscriptionId: $subscriptionId, periodStart: $periodStart, periodEnd: $periodEnd, status: $status, estimatedAmount: $estimatedAmount, actualAmount: $actualAmount, invoiceId: $invoiceId, invoicedAt: $invoicedAt, paidAt: $paidAt, usageData: $usageData, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$BillingPeriodCopyWith<$Res> implements $BillingPeriodCopyWith<$Res> {
  factory _$BillingPeriodCopyWith(_BillingPeriod value, $Res Function(_BillingPeriod) _then) = __$BillingPeriodCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String subscriptionId, DateTime periodStart, DateTime periodEnd, BillingPeriodStatus status, double? estimatedAmount, double? actualAmount, String? invoiceId, DateTime? invoicedAt, DateTime? paidAt, Map<String, dynamic>? usageData, Map<String, dynamic>? metadata, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$BillingPeriodCopyWithImpl<$Res>
    implements _$BillingPeriodCopyWith<$Res> {
  __$BillingPeriodCopyWithImpl(this._self, this._then);

  final _BillingPeriod _self;
  final $Res Function(_BillingPeriod) _then;

/// Create a copy of BillingPeriod
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? subscriptionId = null,Object? periodStart = null,Object? periodEnd = null,Object? status = null,Object? estimatedAmount = freezed,Object? actualAmount = freezed,Object? invoiceId = freezed,Object? invoicedAt = freezed,Object? paidAt = freezed,Object? usageData = freezed,Object? metadata = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_BillingPeriod(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,subscriptionId: null == subscriptionId ? _self.subscriptionId : subscriptionId // ignore: cast_nullable_to_non_nullable
as String,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BillingPeriodStatus,estimatedAmount: freezed == estimatedAmount ? _self.estimatedAmount : estimatedAmount // ignore: cast_nullable_to_non_nullable
as double?,actualAmount: freezed == actualAmount ? _self.actualAmount : actualAmount // ignore: cast_nullable_to_non_nullable
as double?,invoiceId: freezed == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String?,invoicedAt: freezed == invoicedAt ? _self.invoicedAt : invoicedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,usageData: freezed == usageData ? _self._usageData : usageData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$BillingConfiguration {

 String get companyId; String get billingCycle;// monthly, quarterly, annually
 int get billingDay;// Day of month when billing occurs
 String get currency; bool get autoGenerateInvoices; bool get sendPaymentReminders; int? get paymentGracePeriodDays; double? get creditLimit; double? get currentCreditUsed; List<String>? get paymentMethods; String? get defaultPaymentMethod; String? get billingContactEmail; String? get billingContactName; String? get billingContactPhone; Map<String, dynamic>? get taxSettings; Map<String, dynamic>? get invoiceSettings; Map<String, dynamic>? get metadata; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of BillingConfiguration
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillingConfigurationCopyWith<BillingConfiguration> get copyWith => _$BillingConfigurationCopyWithImpl<BillingConfiguration>(this as BillingConfiguration, _$identity);

  /// Serializes this BillingConfiguration to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillingConfiguration&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.billingCycle, billingCycle) || other.billingCycle == billingCycle)&&(identical(other.billingDay, billingDay) || other.billingDay == billingDay)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.autoGenerateInvoices, autoGenerateInvoices) || other.autoGenerateInvoices == autoGenerateInvoices)&&(identical(other.sendPaymentReminders, sendPaymentReminders) || other.sendPaymentReminders == sendPaymentReminders)&&(identical(other.paymentGracePeriodDays, paymentGracePeriodDays) || other.paymentGracePeriodDays == paymentGracePeriodDays)&&(identical(other.creditLimit, creditLimit) || other.creditLimit == creditLimit)&&(identical(other.currentCreditUsed, currentCreditUsed) || other.currentCreditUsed == currentCreditUsed)&&const DeepCollectionEquality().equals(other.paymentMethods, paymentMethods)&&(identical(other.defaultPaymentMethod, defaultPaymentMethod) || other.defaultPaymentMethod == defaultPaymentMethod)&&(identical(other.billingContactEmail, billingContactEmail) || other.billingContactEmail == billingContactEmail)&&(identical(other.billingContactName, billingContactName) || other.billingContactName == billingContactName)&&(identical(other.billingContactPhone, billingContactPhone) || other.billingContactPhone == billingContactPhone)&&const DeepCollectionEquality().equals(other.taxSettings, taxSettings)&&const DeepCollectionEquality().equals(other.invoiceSettings, invoiceSettings)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,companyId,billingCycle,billingDay,currency,autoGenerateInvoices,sendPaymentReminders,paymentGracePeriodDays,creditLimit,currentCreditUsed,const DeepCollectionEquality().hash(paymentMethods),defaultPaymentMethod,billingContactEmail,billingContactName,billingContactPhone,const DeepCollectionEquality().hash(taxSettings),const DeepCollectionEquality().hash(invoiceSettings),const DeepCollectionEquality().hash(metadata),createdAt,updatedAt]);

@override
String toString() {
  return 'BillingConfiguration(companyId: $companyId, billingCycle: $billingCycle, billingDay: $billingDay, currency: $currency, autoGenerateInvoices: $autoGenerateInvoices, sendPaymentReminders: $sendPaymentReminders, paymentGracePeriodDays: $paymentGracePeriodDays, creditLimit: $creditLimit, currentCreditUsed: $currentCreditUsed, paymentMethods: $paymentMethods, defaultPaymentMethod: $defaultPaymentMethod, billingContactEmail: $billingContactEmail, billingContactName: $billingContactName, billingContactPhone: $billingContactPhone, taxSettings: $taxSettings, invoiceSettings: $invoiceSettings, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $BillingConfigurationCopyWith<$Res>  {
  factory $BillingConfigurationCopyWith(BillingConfiguration value, $Res Function(BillingConfiguration) _then) = _$BillingConfigurationCopyWithImpl;
@useResult
$Res call({
 String companyId, String billingCycle, int billingDay, String currency, bool autoGenerateInvoices, bool sendPaymentReminders, int? paymentGracePeriodDays, double? creditLimit, double? currentCreditUsed, List<String>? paymentMethods, String? defaultPaymentMethod, String? billingContactEmail, String? billingContactName, String? billingContactPhone, Map<String, dynamic>? taxSettings, Map<String, dynamic>? invoiceSettings, Map<String, dynamic>? metadata, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$BillingConfigurationCopyWithImpl<$Res>
    implements $BillingConfigurationCopyWith<$Res> {
  _$BillingConfigurationCopyWithImpl(this._self, this._then);

  final BillingConfiguration _self;
  final $Res Function(BillingConfiguration) _then;

/// Create a copy of BillingConfiguration
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? companyId = null,Object? billingCycle = null,Object? billingDay = null,Object? currency = null,Object? autoGenerateInvoices = null,Object? sendPaymentReminders = null,Object? paymentGracePeriodDays = freezed,Object? creditLimit = freezed,Object? currentCreditUsed = freezed,Object? paymentMethods = freezed,Object? defaultPaymentMethod = freezed,Object? billingContactEmail = freezed,Object? billingContactName = freezed,Object? billingContactPhone = freezed,Object? taxSettings = freezed,Object? invoiceSettings = freezed,Object? metadata = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,billingCycle: null == billingCycle ? _self.billingCycle : billingCycle // ignore: cast_nullable_to_non_nullable
as String,billingDay: null == billingDay ? _self.billingDay : billingDay // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,autoGenerateInvoices: null == autoGenerateInvoices ? _self.autoGenerateInvoices : autoGenerateInvoices // ignore: cast_nullable_to_non_nullable
as bool,sendPaymentReminders: null == sendPaymentReminders ? _self.sendPaymentReminders : sendPaymentReminders // ignore: cast_nullable_to_non_nullable
as bool,paymentGracePeriodDays: freezed == paymentGracePeriodDays ? _self.paymentGracePeriodDays : paymentGracePeriodDays // ignore: cast_nullable_to_non_nullable
as int?,creditLimit: freezed == creditLimit ? _self.creditLimit : creditLimit // ignore: cast_nullable_to_non_nullable
as double?,currentCreditUsed: freezed == currentCreditUsed ? _self.currentCreditUsed : currentCreditUsed // ignore: cast_nullable_to_non_nullable
as double?,paymentMethods: freezed == paymentMethods ? _self.paymentMethods : paymentMethods // ignore: cast_nullable_to_non_nullable
as List<String>?,defaultPaymentMethod: freezed == defaultPaymentMethod ? _self.defaultPaymentMethod : defaultPaymentMethod // ignore: cast_nullable_to_non_nullable
as String?,billingContactEmail: freezed == billingContactEmail ? _self.billingContactEmail : billingContactEmail // ignore: cast_nullable_to_non_nullable
as String?,billingContactName: freezed == billingContactName ? _self.billingContactName : billingContactName // ignore: cast_nullable_to_non_nullable
as String?,billingContactPhone: freezed == billingContactPhone ? _self.billingContactPhone : billingContactPhone // ignore: cast_nullable_to_non_nullable
as String?,taxSettings: freezed == taxSettings ? _self.taxSettings : taxSettings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,invoiceSettings: freezed == invoiceSettings ? _self.invoiceSettings : invoiceSettings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [BillingConfiguration].
extension BillingConfigurationPatterns on BillingConfiguration {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BillingConfiguration value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BillingConfiguration() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BillingConfiguration value)  $default,){
final _that = this;
switch (_that) {
case _BillingConfiguration():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BillingConfiguration value)?  $default,){
final _that = this;
switch (_that) {
case _BillingConfiguration() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String companyId,  String billingCycle,  int billingDay,  String currency,  bool autoGenerateInvoices,  bool sendPaymentReminders,  int? paymentGracePeriodDays,  double? creditLimit,  double? currentCreditUsed,  List<String>? paymentMethods,  String? defaultPaymentMethod,  String? billingContactEmail,  String? billingContactName,  String? billingContactPhone,  Map<String, dynamic>? taxSettings,  Map<String, dynamic>? invoiceSettings,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BillingConfiguration() when $default != null:
return $default(_that.companyId,_that.billingCycle,_that.billingDay,_that.currency,_that.autoGenerateInvoices,_that.sendPaymentReminders,_that.paymentGracePeriodDays,_that.creditLimit,_that.currentCreditUsed,_that.paymentMethods,_that.defaultPaymentMethod,_that.billingContactEmail,_that.billingContactName,_that.billingContactPhone,_that.taxSettings,_that.invoiceSettings,_that.metadata,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String companyId,  String billingCycle,  int billingDay,  String currency,  bool autoGenerateInvoices,  bool sendPaymentReminders,  int? paymentGracePeriodDays,  double? creditLimit,  double? currentCreditUsed,  List<String>? paymentMethods,  String? defaultPaymentMethod,  String? billingContactEmail,  String? billingContactName,  String? billingContactPhone,  Map<String, dynamic>? taxSettings,  Map<String, dynamic>? invoiceSettings,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _BillingConfiguration():
return $default(_that.companyId,_that.billingCycle,_that.billingDay,_that.currency,_that.autoGenerateInvoices,_that.sendPaymentReminders,_that.paymentGracePeriodDays,_that.creditLimit,_that.currentCreditUsed,_that.paymentMethods,_that.defaultPaymentMethod,_that.billingContactEmail,_that.billingContactName,_that.billingContactPhone,_that.taxSettings,_that.invoiceSettings,_that.metadata,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String companyId,  String billingCycle,  int billingDay,  String currency,  bool autoGenerateInvoices,  bool sendPaymentReminders,  int? paymentGracePeriodDays,  double? creditLimit,  double? currentCreditUsed,  List<String>? paymentMethods,  String? defaultPaymentMethod,  String? billingContactEmail,  String? billingContactName,  String? billingContactPhone,  Map<String, dynamic>? taxSettings,  Map<String, dynamic>? invoiceSettings,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _BillingConfiguration() when $default != null:
return $default(_that.companyId,_that.billingCycle,_that.billingDay,_that.currency,_that.autoGenerateInvoices,_that.sendPaymentReminders,_that.paymentGracePeriodDays,_that.creditLimit,_that.currentCreditUsed,_that.paymentMethods,_that.defaultPaymentMethod,_that.billingContactEmail,_that.billingContactName,_that.billingContactPhone,_that.taxSettings,_that.invoiceSettings,_that.metadata,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BillingConfiguration implements BillingConfiguration {
  const _BillingConfiguration({required this.companyId, required this.billingCycle, required this.billingDay, required this.currency, required this.autoGenerateInvoices, required this.sendPaymentReminders, this.paymentGracePeriodDays, this.creditLimit, this.currentCreditUsed, final  List<String>? paymentMethods, this.defaultPaymentMethod, this.billingContactEmail, this.billingContactName, this.billingContactPhone, final  Map<String, dynamic>? taxSettings, final  Map<String, dynamic>? invoiceSettings, final  Map<String, dynamic>? metadata, this.createdAt, this.updatedAt}): _paymentMethods = paymentMethods,_taxSettings = taxSettings,_invoiceSettings = invoiceSettings,_metadata = metadata;
  factory _BillingConfiguration.fromJson(Map<String, dynamic> json) => _$BillingConfigurationFromJson(json);

@override final  String companyId;
@override final  String billingCycle;
// monthly, quarterly, annually
@override final  int billingDay;
// Day of month when billing occurs
@override final  String currency;
@override final  bool autoGenerateInvoices;
@override final  bool sendPaymentReminders;
@override final  int? paymentGracePeriodDays;
@override final  double? creditLimit;
@override final  double? currentCreditUsed;
 final  List<String>? _paymentMethods;
@override List<String>? get paymentMethods {
  final value = _paymentMethods;
  if (value == null) return null;
  if (_paymentMethods is EqualUnmodifiableListView) return _paymentMethods;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? defaultPaymentMethod;
@override final  String? billingContactEmail;
@override final  String? billingContactName;
@override final  String? billingContactPhone;
 final  Map<String, dynamic>? _taxSettings;
@override Map<String, dynamic>? get taxSettings {
  final value = _taxSettings;
  if (value == null) return null;
  if (_taxSettings is EqualUnmodifiableMapView) return _taxSettings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _invoiceSettings;
@override Map<String, dynamic>? get invoiceSettings {
  final value = _invoiceSettings;
  if (value == null) return null;
  if (_invoiceSettings is EqualUnmodifiableMapView) return _invoiceSettings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
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

/// Create a copy of BillingConfiguration
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BillingConfigurationCopyWith<_BillingConfiguration> get copyWith => __$BillingConfigurationCopyWithImpl<_BillingConfiguration>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BillingConfigurationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BillingConfiguration&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.billingCycle, billingCycle) || other.billingCycle == billingCycle)&&(identical(other.billingDay, billingDay) || other.billingDay == billingDay)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.autoGenerateInvoices, autoGenerateInvoices) || other.autoGenerateInvoices == autoGenerateInvoices)&&(identical(other.sendPaymentReminders, sendPaymentReminders) || other.sendPaymentReminders == sendPaymentReminders)&&(identical(other.paymentGracePeriodDays, paymentGracePeriodDays) || other.paymentGracePeriodDays == paymentGracePeriodDays)&&(identical(other.creditLimit, creditLimit) || other.creditLimit == creditLimit)&&(identical(other.currentCreditUsed, currentCreditUsed) || other.currentCreditUsed == currentCreditUsed)&&const DeepCollectionEquality().equals(other._paymentMethods, _paymentMethods)&&(identical(other.defaultPaymentMethod, defaultPaymentMethod) || other.defaultPaymentMethod == defaultPaymentMethod)&&(identical(other.billingContactEmail, billingContactEmail) || other.billingContactEmail == billingContactEmail)&&(identical(other.billingContactName, billingContactName) || other.billingContactName == billingContactName)&&(identical(other.billingContactPhone, billingContactPhone) || other.billingContactPhone == billingContactPhone)&&const DeepCollectionEquality().equals(other._taxSettings, _taxSettings)&&const DeepCollectionEquality().equals(other._invoiceSettings, _invoiceSettings)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,companyId,billingCycle,billingDay,currency,autoGenerateInvoices,sendPaymentReminders,paymentGracePeriodDays,creditLimit,currentCreditUsed,const DeepCollectionEquality().hash(_paymentMethods),defaultPaymentMethod,billingContactEmail,billingContactName,billingContactPhone,const DeepCollectionEquality().hash(_taxSettings),const DeepCollectionEquality().hash(_invoiceSettings),const DeepCollectionEquality().hash(_metadata),createdAt,updatedAt]);

@override
String toString() {
  return 'BillingConfiguration(companyId: $companyId, billingCycle: $billingCycle, billingDay: $billingDay, currency: $currency, autoGenerateInvoices: $autoGenerateInvoices, sendPaymentReminders: $sendPaymentReminders, paymentGracePeriodDays: $paymentGracePeriodDays, creditLimit: $creditLimit, currentCreditUsed: $currentCreditUsed, paymentMethods: $paymentMethods, defaultPaymentMethod: $defaultPaymentMethod, billingContactEmail: $billingContactEmail, billingContactName: $billingContactName, billingContactPhone: $billingContactPhone, taxSettings: $taxSettings, invoiceSettings: $invoiceSettings, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$BillingConfigurationCopyWith<$Res> implements $BillingConfigurationCopyWith<$Res> {
  factory _$BillingConfigurationCopyWith(_BillingConfiguration value, $Res Function(_BillingConfiguration) _then) = __$BillingConfigurationCopyWithImpl;
@override @useResult
$Res call({
 String companyId, String billingCycle, int billingDay, String currency, bool autoGenerateInvoices, bool sendPaymentReminders, int? paymentGracePeriodDays, double? creditLimit, double? currentCreditUsed, List<String>? paymentMethods, String? defaultPaymentMethod, String? billingContactEmail, String? billingContactName, String? billingContactPhone, Map<String, dynamic>? taxSettings, Map<String, dynamic>? invoiceSettings, Map<String, dynamic>? metadata, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$BillingConfigurationCopyWithImpl<$Res>
    implements _$BillingConfigurationCopyWith<$Res> {
  __$BillingConfigurationCopyWithImpl(this._self, this._then);

  final _BillingConfiguration _self;
  final $Res Function(_BillingConfiguration) _then;

/// Create a copy of BillingConfiguration
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? companyId = null,Object? billingCycle = null,Object? billingDay = null,Object? currency = null,Object? autoGenerateInvoices = null,Object? sendPaymentReminders = null,Object? paymentGracePeriodDays = freezed,Object? creditLimit = freezed,Object? currentCreditUsed = freezed,Object? paymentMethods = freezed,Object? defaultPaymentMethod = freezed,Object? billingContactEmail = freezed,Object? billingContactName = freezed,Object? billingContactPhone = freezed,Object? taxSettings = freezed,Object? invoiceSettings = freezed,Object? metadata = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_BillingConfiguration(
companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,billingCycle: null == billingCycle ? _self.billingCycle : billingCycle // ignore: cast_nullable_to_non_nullable
as String,billingDay: null == billingDay ? _self.billingDay : billingDay // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,autoGenerateInvoices: null == autoGenerateInvoices ? _self.autoGenerateInvoices : autoGenerateInvoices // ignore: cast_nullable_to_non_nullable
as bool,sendPaymentReminders: null == sendPaymentReminders ? _self.sendPaymentReminders : sendPaymentReminders // ignore: cast_nullable_to_non_nullable
as bool,paymentGracePeriodDays: freezed == paymentGracePeriodDays ? _self.paymentGracePeriodDays : paymentGracePeriodDays // ignore: cast_nullable_to_non_nullable
as int?,creditLimit: freezed == creditLimit ? _self.creditLimit : creditLimit // ignore: cast_nullable_to_non_nullable
as double?,currentCreditUsed: freezed == currentCreditUsed ? _self.currentCreditUsed : currentCreditUsed // ignore: cast_nullable_to_non_nullable
as double?,paymentMethods: freezed == paymentMethods ? _self._paymentMethods : paymentMethods // ignore: cast_nullable_to_non_nullable
as List<String>?,defaultPaymentMethod: freezed == defaultPaymentMethod ? _self.defaultPaymentMethod : defaultPaymentMethod // ignore: cast_nullable_to_non_nullable
as String?,billingContactEmail: freezed == billingContactEmail ? _self.billingContactEmail : billingContactEmail // ignore: cast_nullable_to_non_nullable
as String?,billingContactName: freezed == billingContactName ? _self.billingContactName : billingContactName // ignore: cast_nullable_to_non_nullable
as String?,billingContactPhone: freezed == billingContactPhone ? _self.billingContactPhone : billingContactPhone // ignore: cast_nullable_to_non_nullable
as String?,taxSettings: freezed == taxSettings ? _self._taxSettings : taxSettings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,invoiceSettings: freezed == invoiceSettings ? _self._invoiceSettings : invoiceSettings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$BillingStatistics {

 DateTime get periodStart; DateTime get periodEnd; double get totalRevenue; double get collectedRevenue; double get pendingRevenue; double get overdueRevenue; int get totalInvoices; int get paidInvoices; int get pendingInvoices; int get overdueInvoices; double get averagePaymentTimeDays; double get collectionRate; Map<String, double>? get revenueByPlan; Map<String, double>? get revenueByCompanyType; Map<String, int>? get invoiceCountByStatus; List<RevenueTrendPoint>? get revenueTrend; DateTime? get calculatedAt;
/// Create a copy of BillingStatistics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillingStatisticsCopyWith<BillingStatistics> get copyWith => _$BillingStatisticsCopyWithImpl<BillingStatistics>(this as BillingStatistics, _$identity);

  /// Serializes this BillingStatistics to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillingStatistics&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.collectedRevenue, collectedRevenue) || other.collectedRevenue == collectedRevenue)&&(identical(other.pendingRevenue, pendingRevenue) || other.pendingRevenue == pendingRevenue)&&(identical(other.overdueRevenue, overdueRevenue) || other.overdueRevenue == overdueRevenue)&&(identical(other.totalInvoices, totalInvoices) || other.totalInvoices == totalInvoices)&&(identical(other.paidInvoices, paidInvoices) || other.paidInvoices == paidInvoices)&&(identical(other.pendingInvoices, pendingInvoices) || other.pendingInvoices == pendingInvoices)&&(identical(other.overdueInvoices, overdueInvoices) || other.overdueInvoices == overdueInvoices)&&(identical(other.averagePaymentTimeDays, averagePaymentTimeDays) || other.averagePaymentTimeDays == averagePaymentTimeDays)&&(identical(other.collectionRate, collectionRate) || other.collectionRate == collectionRate)&&const DeepCollectionEquality().equals(other.revenueByPlan, revenueByPlan)&&const DeepCollectionEquality().equals(other.revenueByCompanyType, revenueByCompanyType)&&const DeepCollectionEquality().equals(other.invoiceCountByStatus, invoiceCountByStatus)&&const DeepCollectionEquality().equals(other.revenueTrend, revenueTrend)&&(identical(other.calculatedAt, calculatedAt) || other.calculatedAt == calculatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,periodStart,periodEnd,totalRevenue,collectedRevenue,pendingRevenue,overdueRevenue,totalInvoices,paidInvoices,pendingInvoices,overdueInvoices,averagePaymentTimeDays,collectionRate,const DeepCollectionEquality().hash(revenueByPlan),const DeepCollectionEquality().hash(revenueByCompanyType),const DeepCollectionEquality().hash(invoiceCountByStatus),const DeepCollectionEquality().hash(revenueTrend),calculatedAt);

@override
String toString() {
  return 'BillingStatistics(periodStart: $periodStart, periodEnd: $periodEnd, totalRevenue: $totalRevenue, collectedRevenue: $collectedRevenue, pendingRevenue: $pendingRevenue, overdueRevenue: $overdueRevenue, totalInvoices: $totalInvoices, paidInvoices: $paidInvoices, pendingInvoices: $pendingInvoices, overdueInvoices: $overdueInvoices, averagePaymentTimeDays: $averagePaymentTimeDays, collectionRate: $collectionRate, revenueByPlan: $revenueByPlan, revenueByCompanyType: $revenueByCompanyType, invoiceCountByStatus: $invoiceCountByStatus, revenueTrend: $revenueTrend, calculatedAt: $calculatedAt)';
}


}

/// @nodoc
abstract mixin class $BillingStatisticsCopyWith<$Res>  {
  factory $BillingStatisticsCopyWith(BillingStatistics value, $Res Function(BillingStatistics) _then) = _$BillingStatisticsCopyWithImpl;
@useResult
$Res call({
 DateTime periodStart, DateTime periodEnd, double totalRevenue, double collectedRevenue, double pendingRevenue, double overdueRevenue, int totalInvoices, int paidInvoices, int pendingInvoices, int overdueInvoices, double averagePaymentTimeDays, double collectionRate, Map<String, double>? revenueByPlan, Map<String, double>? revenueByCompanyType, Map<String, int>? invoiceCountByStatus, List<RevenueTrendPoint>? revenueTrend, DateTime? calculatedAt
});




}
/// @nodoc
class _$BillingStatisticsCopyWithImpl<$Res>
    implements $BillingStatisticsCopyWith<$Res> {
  _$BillingStatisticsCopyWithImpl(this._self, this._then);

  final BillingStatistics _self;
  final $Res Function(BillingStatistics) _then;

/// Create a copy of BillingStatistics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? periodStart = null,Object? periodEnd = null,Object? totalRevenue = null,Object? collectedRevenue = null,Object? pendingRevenue = null,Object? overdueRevenue = null,Object? totalInvoices = null,Object? paidInvoices = null,Object? pendingInvoices = null,Object? overdueInvoices = null,Object? averagePaymentTimeDays = null,Object? collectionRate = null,Object? revenueByPlan = freezed,Object? revenueByCompanyType = freezed,Object? invoiceCountByStatus = freezed,Object? revenueTrend = freezed,Object? calculatedAt = freezed,}) {
  return _then(_self.copyWith(
periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,collectedRevenue: null == collectedRevenue ? _self.collectedRevenue : collectedRevenue // ignore: cast_nullable_to_non_nullable
as double,pendingRevenue: null == pendingRevenue ? _self.pendingRevenue : pendingRevenue // ignore: cast_nullable_to_non_nullable
as double,overdueRevenue: null == overdueRevenue ? _self.overdueRevenue : overdueRevenue // ignore: cast_nullable_to_non_nullable
as double,totalInvoices: null == totalInvoices ? _self.totalInvoices : totalInvoices // ignore: cast_nullable_to_non_nullable
as int,paidInvoices: null == paidInvoices ? _self.paidInvoices : paidInvoices // ignore: cast_nullable_to_non_nullable
as int,pendingInvoices: null == pendingInvoices ? _self.pendingInvoices : pendingInvoices // ignore: cast_nullable_to_non_nullable
as int,overdueInvoices: null == overdueInvoices ? _self.overdueInvoices : overdueInvoices // ignore: cast_nullable_to_non_nullable
as int,averagePaymentTimeDays: null == averagePaymentTimeDays ? _self.averagePaymentTimeDays : averagePaymentTimeDays // ignore: cast_nullable_to_non_nullable
as double,collectionRate: null == collectionRate ? _self.collectionRate : collectionRate // ignore: cast_nullable_to_non_nullable
as double,revenueByPlan: freezed == revenueByPlan ? _self.revenueByPlan : revenueByPlan // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,revenueByCompanyType: freezed == revenueByCompanyType ? _self.revenueByCompanyType : revenueByCompanyType // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,invoiceCountByStatus: freezed == invoiceCountByStatus ? _self.invoiceCountByStatus : invoiceCountByStatus // ignore: cast_nullable_to_non_nullable
as Map<String, int>?,revenueTrend: freezed == revenueTrend ? _self.revenueTrend : revenueTrend // ignore: cast_nullable_to_non_nullable
as List<RevenueTrendPoint>?,calculatedAt: freezed == calculatedAt ? _self.calculatedAt : calculatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [BillingStatistics].
extension BillingStatisticsPatterns on BillingStatistics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BillingStatistics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BillingStatistics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BillingStatistics value)  $default,){
final _that = this;
switch (_that) {
case _BillingStatistics():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BillingStatistics value)?  $default,){
final _that = this;
switch (_that) {
case _BillingStatistics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime periodStart,  DateTime periodEnd,  double totalRevenue,  double collectedRevenue,  double pendingRevenue,  double overdueRevenue,  int totalInvoices,  int paidInvoices,  int pendingInvoices,  int overdueInvoices,  double averagePaymentTimeDays,  double collectionRate,  Map<String, double>? revenueByPlan,  Map<String, double>? revenueByCompanyType,  Map<String, int>? invoiceCountByStatus,  List<RevenueTrendPoint>? revenueTrend,  DateTime? calculatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BillingStatistics() when $default != null:
return $default(_that.periodStart,_that.periodEnd,_that.totalRevenue,_that.collectedRevenue,_that.pendingRevenue,_that.overdueRevenue,_that.totalInvoices,_that.paidInvoices,_that.pendingInvoices,_that.overdueInvoices,_that.averagePaymentTimeDays,_that.collectionRate,_that.revenueByPlan,_that.revenueByCompanyType,_that.invoiceCountByStatus,_that.revenueTrend,_that.calculatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime periodStart,  DateTime periodEnd,  double totalRevenue,  double collectedRevenue,  double pendingRevenue,  double overdueRevenue,  int totalInvoices,  int paidInvoices,  int pendingInvoices,  int overdueInvoices,  double averagePaymentTimeDays,  double collectionRate,  Map<String, double>? revenueByPlan,  Map<String, double>? revenueByCompanyType,  Map<String, int>? invoiceCountByStatus,  List<RevenueTrendPoint>? revenueTrend,  DateTime? calculatedAt)  $default,) {final _that = this;
switch (_that) {
case _BillingStatistics():
return $default(_that.periodStart,_that.periodEnd,_that.totalRevenue,_that.collectedRevenue,_that.pendingRevenue,_that.overdueRevenue,_that.totalInvoices,_that.paidInvoices,_that.pendingInvoices,_that.overdueInvoices,_that.averagePaymentTimeDays,_that.collectionRate,_that.revenueByPlan,_that.revenueByCompanyType,_that.invoiceCountByStatus,_that.revenueTrend,_that.calculatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime periodStart,  DateTime periodEnd,  double totalRevenue,  double collectedRevenue,  double pendingRevenue,  double overdueRevenue,  int totalInvoices,  int paidInvoices,  int pendingInvoices,  int overdueInvoices,  double averagePaymentTimeDays,  double collectionRate,  Map<String, double>? revenueByPlan,  Map<String, double>? revenueByCompanyType,  Map<String, int>? invoiceCountByStatus,  List<RevenueTrendPoint>? revenueTrend,  DateTime? calculatedAt)?  $default,) {final _that = this;
switch (_that) {
case _BillingStatistics() when $default != null:
return $default(_that.periodStart,_that.periodEnd,_that.totalRevenue,_that.collectedRevenue,_that.pendingRevenue,_that.overdueRevenue,_that.totalInvoices,_that.paidInvoices,_that.pendingInvoices,_that.overdueInvoices,_that.averagePaymentTimeDays,_that.collectionRate,_that.revenueByPlan,_that.revenueByCompanyType,_that.invoiceCountByStatus,_that.revenueTrend,_that.calculatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BillingStatistics implements BillingStatistics {
  const _BillingStatistics({required this.periodStart, required this.periodEnd, required this.totalRevenue, required this.collectedRevenue, required this.pendingRevenue, required this.overdueRevenue, required this.totalInvoices, required this.paidInvoices, required this.pendingInvoices, required this.overdueInvoices, required this.averagePaymentTimeDays, required this.collectionRate, final  Map<String, double>? revenueByPlan, final  Map<String, double>? revenueByCompanyType, final  Map<String, int>? invoiceCountByStatus, final  List<RevenueTrendPoint>? revenueTrend, this.calculatedAt}): _revenueByPlan = revenueByPlan,_revenueByCompanyType = revenueByCompanyType,_invoiceCountByStatus = invoiceCountByStatus,_revenueTrend = revenueTrend;
  factory _BillingStatistics.fromJson(Map<String, dynamic> json) => _$BillingStatisticsFromJson(json);

@override final  DateTime periodStart;
@override final  DateTime periodEnd;
@override final  double totalRevenue;
@override final  double collectedRevenue;
@override final  double pendingRevenue;
@override final  double overdueRevenue;
@override final  int totalInvoices;
@override final  int paidInvoices;
@override final  int pendingInvoices;
@override final  int overdueInvoices;
@override final  double averagePaymentTimeDays;
@override final  double collectionRate;
 final  Map<String, double>? _revenueByPlan;
@override Map<String, double>? get revenueByPlan {
  final value = _revenueByPlan;
  if (value == null) return null;
  if (_revenueByPlan is EqualUnmodifiableMapView) return _revenueByPlan;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, double>? _revenueByCompanyType;
@override Map<String, double>? get revenueByCompanyType {
  final value = _revenueByCompanyType;
  if (value == null) return null;
  if (_revenueByCompanyType is EqualUnmodifiableMapView) return _revenueByCompanyType;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, int>? _invoiceCountByStatus;
@override Map<String, int>? get invoiceCountByStatus {
  final value = _invoiceCountByStatus;
  if (value == null) return null;
  if (_invoiceCountByStatus is EqualUnmodifiableMapView) return _invoiceCountByStatus;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<RevenueTrendPoint>? _revenueTrend;
@override List<RevenueTrendPoint>? get revenueTrend {
  final value = _revenueTrend;
  if (value == null) return null;
  if (_revenueTrend is EqualUnmodifiableListView) return _revenueTrend;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  DateTime? calculatedAt;

/// Create a copy of BillingStatistics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BillingStatisticsCopyWith<_BillingStatistics> get copyWith => __$BillingStatisticsCopyWithImpl<_BillingStatistics>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BillingStatisticsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BillingStatistics&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.collectedRevenue, collectedRevenue) || other.collectedRevenue == collectedRevenue)&&(identical(other.pendingRevenue, pendingRevenue) || other.pendingRevenue == pendingRevenue)&&(identical(other.overdueRevenue, overdueRevenue) || other.overdueRevenue == overdueRevenue)&&(identical(other.totalInvoices, totalInvoices) || other.totalInvoices == totalInvoices)&&(identical(other.paidInvoices, paidInvoices) || other.paidInvoices == paidInvoices)&&(identical(other.pendingInvoices, pendingInvoices) || other.pendingInvoices == pendingInvoices)&&(identical(other.overdueInvoices, overdueInvoices) || other.overdueInvoices == overdueInvoices)&&(identical(other.averagePaymentTimeDays, averagePaymentTimeDays) || other.averagePaymentTimeDays == averagePaymentTimeDays)&&(identical(other.collectionRate, collectionRate) || other.collectionRate == collectionRate)&&const DeepCollectionEquality().equals(other._revenueByPlan, _revenueByPlan)&&const DeepCollectionEquality().equals(other._revenueByCompanyType, _revenueByCompanyType)&&const DeepCollectionEquality().equals(other._invoiceCountByStatus, _invoiceCountByStatus)&&const DeepCollectionEquality().equals(other._revenueTrend, _revenueTrend)&&(identical(other.calculatedAt, calculatedAt) || other.calculatedAt == calculatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,periodStart,periodEnd,totalRevenue,collectedRevenue,pendingRevenue,overdueRevenue,totalInvoices,paidInvoices,pendingInvoices,overdueInvoices,averagePaymentTimeDays,collectionRate,const DeepCollectionEquality().hash(_revenueByPlan),const DeepCollectionEquality().hash(_revenueByCompanyType),const DeepCollectionEquality().hash(_invoiceCountByStatus),const DeepCollectionEquality().hash(_revenueTrend),calculatedAt);

@override
String toString() {
  return 'BillingStatistics(periodStart: $periodStart, periodEnd: $periodEnd, totalRevenue: $totalRevenue, collectedRevenue: $collectedRevenue, pendingRevenue: $pendingRevenue, overdueRevenue: $overdueRevenue, totalInvoices: $totalInvoices, paidInvoices: $paidInvoices, pendingInvoices: $pendingInvoices, overdueInvoices: $overdueInvoices, averagePaymentTimeDays: $averagePaymentTimeDays, collectionRate: $collectionRate, revenueByPlan: $revenueByPlan, revenueByCompanyType: $revenueByCompanyType, invoiceCountByStatus: $invoiceCountByStatus, revenueTrend: $revenueTrend, calculatedAt: $calculatedAt)';
}


}

/// @nodoc
abstract mixin class _$BillingStatisticsCopyWith<$Res> implements $BillingStatisticsCopyWith<$Res> {
  factory _$BillingStatisticsCopyWith(_BillingStatistics value, $Res Function(_BillingStatistics) _then) = __$BillingStatisticsCopyWithImpl;
@override @useResult
$Res call({
 DateTime periodStart, DateTime periodEnd, double totalRevenue, double collectedRevenue, double pendingRevenue, double overdueRevenue, int totalInvoices, int paidInvoices, int pendingInvoices, int overdueInvoices, double averagePaymentTimeDays, double collectionRate, Map<String, double>? revenueByPlan, Map<String, double>? revenueByCompanyType, Map<String, int>? invoiceCountByStatus, List<RevenueTrendPoint>? revenueTrend, DateTime? calculatedAt
});




}
/// @nodoc
class __$BillingStatisticsCopyWithImpl<$Res>
    implements _$BillingStatisticsCopyWith<$Res> {
  __$BillingStatisticsCopyWithImpl(this._self, this._then);

  final _BillingStatistics _self;
  final $Res Function(_BillingStatistics) _then;

/// Create a copy of BillingStatistics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? periodStart = null,Object? periodEnd = null,Object? totalRevenue = null,Object? collectedRevenue = null,Object? pendingRevenue = null,Object? overdueRevenue = null,Object? totalInvoices = null,Object? paidInvoices = null,Object? pendingInvoices = null,Object? overdueInvoices = null,Object? averagePaymentTimeDays = null,Object? collectionRate = null,Object? revenueByPlan = freezed,Object? revenueByCompanyType = freezed,Object? invoiceCountByStatus = freezed,Object? revenueTrend = freezed,Object? calculatedAt = freezed,}) {
  return _then(_BillingStatistics(
periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,collectedRevenue: null == collectedRevenue ? _self.collectedRevenue : collectedRevenue // ignore: cast_nullable_to_non_nullable
as double,pendingRevenue: null == pendingRevenue ? _self.pendingRevenue : pendingRevenue // ignore: cast_nullable_to_non_nullable
as double,overdueRevenue: null == overdueRevenue ? _self.overdueRevenue : overdueRevenue // ignore: cast_nullable_to_non_nullable
as double,totalInvoices: null == totalInvoices ? _self.totalInvoices : totalInvoices // ignore: cast_nullable_to_non_nullable
as int,paidInvoices: null == paidInvoices ? _self.paidInvoices : paidInvoices // ignore: cast_nullable_to_non_nullable
as int,pendingInvoices: null == pendingInvoices ? _self.pendingInvoices : pendingInvoices // ignore: cast_nullable_to_non_nullable
as int,overdueInvoices: null == overdueInvoices ? _self.overdueInvoices : overdueInvoices // ignore: cast_nullable_to_non_nullable
as int,averagePaymentTimeDays: null == averagePaymentTimeDays ? _self.averagePaymentTimeDays : averagePaymentTimeDays // ignore: cast_nullable_to_non_nullable
as double,collectionRate: null == collectionRate ? _self.collectionRate : collectionRate // ignore: cast_nullable_to_non_nullable
as double,revenueByPlan: freezed == revenueByPlan ? _self._revenueByPlan : revenueByPlan // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,revenueByCompanyType: freezed == revenueByCompanyType ? _self._revenueByCompanyType : revenueByCompanyType // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,invoiceCountByStatus: freezed == invoiceCountByStatus ? _self._invoiceCountByStatus : invoiceCountByStatus // ignore: cast_nullable_to_non_nullable
as Map<String, int>?,revenueTrend: freezed == revenueTrend ? _self._revenueTrend : revenueTrend // ignore: cast_nullable_to_non_nullable
as List<RevenueTrendPoint>?,calculatedAt: freezed == calculatedAt ? _self.calculatedAt : calculatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$RevenueTrendPoint {

 DateTime get date; double get revenue; int get invoiceCount; int get paidCount; double? get averageAmount;
/// Create a copy of RevenueTrendPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RevenueTrendPointCopyWith<RevenueTrendPoint> get copyWith => _$RevenueTrendPointCopyWithImpl<RevenueTrendPoint>(this as RevenueTrendPoint, _$identity);

  /// Serializes this RevenueTrendPoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RevenueTrendPoint&&(identical(other.date, date) || other.date == date)&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.invoiceCount, invoiceCount) || other.invoiceCount == invoiceCount)&&(identical(other.paidCount, paidCount) || other.paidCount == paidCount)&&(identical(other.averageAmount, averageAmount) || other.averageAmount == averageAmount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,revenue,invoiceCount,paidCount,averageAmount);

@override
String toString() {
  return 'RevenueTrendPoint(date: $date, revenue: $revenue, invoiceCount: $invoiceCount, paidCount: $paidCount, averageAmount: $averageAmount)';
}


}

/// @nodoc
abstract mixin class $RevenueTrendPointCopyWith<$Res>  {
  factory $RevenueTrendPointCopyWith(RevenueTrendPoint value, $Res Function(RevenueTrendPoint) _then) = _$RevenueTrendPointCopyWithImpl;
@useResult
$Res call({
 DateTime date, double revenue, int invoiceCount, int paidCount, double? averageAmount
});




}
/// @nodoc
class _$RevenueTrendPointCopyWithImpl<$Res>
    implements $RevenueTrendPointCopyWith<$Res> {
  _$RevenueTrendPointCopyWithImpl(this._self, this._then);

  final RevenueTrendPoint _self;
  final $Res Function(RevenueTrendPoint) _then;

/// Create a copy of RevenueTrendPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? revenue = null,Object? invoiceCount = null,Object? paidCount = null,Object? averageAmount = freezed,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as double,invoiceCount: null == invoiceCount ? _self.invoiceCount : invoiceCount // ignore: cast_nullable_to_non_nullable
as int,paidCount: null == paidCount ? _self.paidCount : paidCount // ignore: cast_nullable_to_non_nullable
as int,averageAmount: freezed == averageAmount ? _self.averageAmount : averageAmount // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [RevenueTrendPoint].
extension RevenueTrendPointPatterns on RevenueTrendPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RevenueTrendPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RevenueTrendPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RevenueTrendPoint value)  $default,){
final _that = this;
switch (_that) {
case _RevenueTrendPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RevenueTrendPoint value)?  $default,){
final _that = this;
switch (_that) {
case _RevenueTrendPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  double revenue,  int invoiceCount,  int paidCount,  double? averageAmount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RevenueTrendPoint() when $default != null:
return $default(_that.date,_that.revenue,_that.invoiceCount,_that.paidCount,_that.averageAmount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  double revenue,  int invoiceCount,  int paidCount,  double? averageAmount)  $default,) {final _that = this;
switch (_that) {
case _RevenueTrendPoint():
return $default(_that.date,_that.revenue,_that.invoiceCount,_that.paidCount,_that.averageAmount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  double revenue,  int invoiceCount,  int paidCount,  double? averageAmount)?  $default,) {final _that = this;
switch (_that) {
case _RevenueTrendPoint() when $default != null:
return $default(_that.date,_that.revenue,_that.invoiceCount,_that.paidCount,_that.averageAmount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RevenueTrendPoint implements RevenueTrendPoint {
  const _RevenueTrendPoint({required this.date, required this.revenue, required this.invoiceCount, required this.paidCount, this.averageAmount});
  factory _RevenueTrendPoint.fromJson(Map<String, dynamic> json) => _$RevenueTrendPointFromJson(json);

@override final  DateTime date;
@override final  double revenue;
@override final  int invoiceCount;
@override final  int paidCount;
@override final  double? averageAmount;

/// Create a copy of RevenueTrendPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RevenueTrendPointCopyWith<_RevenueTrendPoint> get copyWith => __$RevenueTrendPointCopyWithImpl<_RevenueTrendPoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RevenueTrendPointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RevenueTrendPoint&&(identical(other.date, date) || other.date == date)&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.invoiceCount, invoiceCount) || other.invoiceCount == invoiceCount)&&(identical(other.paidCount, paidCount) || other.paidCount == paidCount)&&(identical(other.averageAmount, averageAmount) || other.averageAmount == averageAmount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,revenue,invoiceCount,paidCount,averageAmount);

@override
String toString() {
  return 'RevenueTrendPoint(date: $date, revenue: $revenue, invoiceCount: $invoiceCount, paidCount: $paidCount, averageAmount: $averageAmount)';
}


}

/// @nodoc
abstract mixin class _$RevenueTrendPointCopyWith<$Res> implements $RevenueTrendPointCopyWith<$Res> {
  factory _$RevenueTrendPointCopyWith(_RevenueTrendPoint value, $Res Function(_RevenueTrendPoint) _then) = __$RevenueTrendPointCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, double revenue, int invoiceCount, int paidCount, double? averageAmount
});




}
/// @nodoc
class __$RevenueTrendPointCopyWithImpl<$Res>
    implements _$RevenueTrendPointCopyWith<$Res> {
  __$RevenueTrendPointCopyWithImpl(this._self, this._then);

  final _RevenueTrendPoint _self;
  final $Res Function(_RevenueTrendPoint) _then;

/// Create a copy of RevenueTrendPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? revenue = null,Object? invoiceCount = null,Object? paidCount = null,Object? averageAmount = freezed,}) {
  return _then(_RevenueTrendPoint(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as double,invoiceCount: null == invoiceCount ? _self.invoiceCount : invoiceCount // ignore: cast_nullable_to_non_nullable
as int,paidCount: null == paidCount ? _self.paidCount : paidCount // ignore: cast_nullable_to_non_nullable
as int,averageAmount: freezed == averageAmount ? _self.averageAmount : averageAmount // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$BillingAlert {

 String get id; String get companyId; BillingAlertType get type; BillingAlertSeverity get severity; String get title; String get description; DateTime get detectedAt; bool get isActive; DateTime? get resolvedAt; String? get resolvedBy; String? get resolutionNotes; Map<String, dynamic>? get alertData; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of BillingAlert
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillingAlertCopyWith<BillingAlert> get copyWith => _$BillingAlertCopyWithImpl<BillingAlert>(this as BillingAlert, _$identity);

  /// Serializes this BillingAlert to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillingAlert&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.type, type) || other.type == type)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.detectedAt, detectedAt) || other.detectedAt == detectedAt)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.resolvedBy, resolvedBy) || other.resolvedBy == resolvedBy)&&(identical(other.resolutionNotes, resolutionNotes) || other.resolutionNotes == resolutionNotes)&&const DeepCollectionEquality().equals(other.alertData, alertData)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,companyId,type,severity,title,description,detectedAt,isActive,resolvedAt,resolvedBy,resolutionNotes,const DeepCollectionEquality().hash(alertData),createdAt,updatedAt);

@override
String toString() {
  return 'BillingAlert(id: $id, companyId: $companyId, type: $type, severity: $severity, title: $title, description: $description, detectedAt: $detectedAt, isActive: $isActive, resolvedAt: $resolvedAt, resolvedBy: $resolvedBy, resolutionNotes: $resolutionNotes, alertData: $alertData, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $BillingAlertCopyWith<$Res>  {
  factory $BillingAlertCopyWith(BillingAlert value, $Res Function(BillingAlert) _then) = _$BillingAlertCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, BillingAlertType type, BillingAlertSeverity severity, String title, String description, DateTime detectedAt, bool isActive, DateTime? resolvedAt, String? resolvedBy, String? resolutionNotes, Map<String, dynamic>? alertData, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$BillingAlertCopyWithImpl<$Res>
    implements $BillingAlertCopyWith<$Res> {
  _$BillingAlertCopyWithImpl(this._self, this._then);

  final BillingAlert _self;
  final $Res Function(BillingAlert) _then;

/// Create a copy of BillingAlert
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? type = null,Object? severity = null,Object? title = null,Object? description = null,Object? detectedAt = null,Object? isActive = null,Object? resolvedAt = freezed,Object? resolvedBy = freezed,Object? resolutionNotes = freezed,Object? alertData = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as BillingAlertType,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as BillingAlertSeverity,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,detectedAt: null == detectedAt ? _self.detectedAt : detectedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,resolvedBy: freezed == resolvedBy ? _self.resolvedBy : resolvedBy // ignore: cast_nullable_to_non_nullable
as String?,resolutionNotes: freezed == resolutionNotes ? _self.resolutionNotes : resolutionNotes // ignore: cast_nullable_to_non_nullable
as String?,alertData: freezed == alertData ? _self.alertData : alertData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [BillingAlert].
extension BillingAlertPatterns on BillingAlert {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BillingAlert value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BillingAlert() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BillingAlert value)  $default,){
final _that = this;
switch (_that) {
case _BillingAlert():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BillingAlert value)?  $default,){
final _that = this;
switch (_that) {
case _BillingAlert() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  BillingAlertType type,  BillingAlertSeverity severity,  String title,  String description,  DateTime detectedAt,  bool isActive,  DateTime? resolvedAt,  String? resolvedBy,  String? resolutionNotes,  Map<String, dynamic>? alertData,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BillingAlert() when $default != null:
return $default(_that.id,_that.companyId,_that.type,_that.severity,_that.title,_that.description,_that.detectedAt,_that.isActive,_that.resolvedAt,_that.resolvedBy,_that.resolutionNotes,_that.alertData,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  BillingAlertType type,  BillingAlertSeverity severity,  String title,  String description,  DateTime detectedAt,  bool isActive,  DateTime? resolvedAt,  String? resolvedBy,  String? resolutionNotes,  Map<String, dynamic>? alertData,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _BillingAlert():
return $default(_that.id,_that.companyId,_that.type,_that.severity,_that.title,_that.description,_that.detectedAt,_that.isActive,_that.resolvedAt,_that.resolvedBy,_that.resolutionNotes,_that.alertData,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  BillingAlertType type,  BillingAlertSeverity severity,  String title,  String description,  DateTime detectedAt,  bool isActive,  DateTime? resolvedAt,  String? resolvedBy,  String? resolutionNotes,  Map<String, dynamic>? alertData,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _BillingAlert() when $default != null:
return $default(_that.id,_that.companyId,_that.type,_that.severity,_that.title,_that.description,_that.detectedAt,_that.isActive,_that.resolvedAt,_that.resolvedBy,_that.resolutionNotes,_that.alertData,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BillingAlert implements BillingAlert {
  const _BillingAlert({required this.id, required this.companyId, required this.type, required this.severity, required this.title, required this.description, required this.detectedAt, required this.isActive, this.resolvedAt, this.resolvedBy, this.resolutionNotes, final  Map<String, dynamic>? alertData, this.createdAt, this.updatedAt}): _alertData = alertData;
  factory _BillingAlert.fromJson(Map<String, dynamic> json) => _$BillingAlertFromJson(json);

@override final  String id;
@override final  String companyId;
@override final  BillingAlertType type;
@override final  BillingAlertSeverity severity;
@override final  String title;
@override final  String description;
@override final  DateTime detectedAt;
@override final  bool isActive;
@override final  DateTime? resolvedAt;
@override final  String? resolvedBy;
@override final  String? resolutionNotes;
 final  Map<String, dynamic>? _alertData;
@override Map<String, dynamic>? get alertData {
  final value = _alertData;
  if (value == null) return null;
  if (_alertData is EqualUnmodifiableMapView) return _alertData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of BillingAlert
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BillingAlertCopyWith<_BillingAlert> get copyWith => __$BillingAlertCopyWithImpl<_BillingAlert>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BillingAlertToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BillingAlert&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.type, type) || other.type == type)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.detectedAt, detectedAt) || other.detectedAt == detectedAt)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.resolvedBy, resolvedBy) || other.resolvedBy == resolvedBy)&&(identical(other.resolutionNotes, resolutionNotes) || other.resolutionNotes == resolutionNotes)&&const DeepCollectionEquality().equals(other._alertData, _alertData)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,companyId,type,severity,title,description,detectedAt,isActive,resolvedAt,resolvedBy,resolutionNotes,const DeepCollectionEquality().hash(_alertData),createdAt,updatedAt);

@override
String toString() {
  return 'BillingAlert(id: $id, companyId: $companyId, type: $type, severity: $severity, title: $title, description: $description, detectedAt: $detectedAt, isActive: $isActive, resolvedAt: $resolvedAt, resolvedBy: $resolvedBy, resolutionNotes: $resolutionNotes, alertData: $alertData, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$BillingAlertCopyWith<$Res> implements $BillingAlertCopyWith<$Res> {
  factory _$BillingAlertCopyWith(_BillingAlert value, $Res Function(_BillingAlert) _then) = __$BillingAlertCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, BillingAlertType type, BillingAlertSeverity severity, String title, String description, DateTime detectedAt, bool isActive, DateTime? resolvedAt, String? resolvedBy, String? resolutionNotes, Map<String, dynamic>? alertData, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$BillingAlertCopyWithImpl<$Res>
    implements _$BillingAlertCopyWith<$Res> {
  __$BillingAlertCopyWithImpl(this._self, this._then);

  final _BillingAlert _self;
  final $Res Function(_BillingAlert) _then;

/// Create a copy of BillingAlert
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? type = null,Object? severity = null,Object? title = null,Object? description = null,Object? detectedAt = null,Object? isActive = null,Object? resolvedAt = freezed,Object? resolvedBy = freezed,Object? resolutionNotes = freezed,Object? alertData = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_BillingAlert(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as BillingAlertType,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as BillingAlertSeverity,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,detectedAt: null == detectedAt ? _self.detectedAt : detectedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,resolvedBy: freezed == resolvedBy ? _self.resolvedBy : resolvedBy // ignore: cast_nullable_to_non_nullable
as String?,resolutionNotes: freezed == resolutionNotes ? _self.resolutionNotes : resolutionNotes // ignore: cast_nullable_to_non_nullable
as String?,alertData: freezed == alertData ? _self._alertData : alertData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on

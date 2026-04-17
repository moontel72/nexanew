// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invoice_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AdminInvoice {

 String get id; String get invoiceNumber; String get companyId; String get companyName; String get subscriptionId; String get subscriptionName; DateTime get periodStart; DateTime get periodEnd; DateTime get issueDate; DateTime get dueDate; double get subtotal; double get taxAmount; double get discountAmount; double get totalAmount; String get currency; List<AdminInvoiceItem> get items; InvoiceStatus get status; DateTime? get paymentDate; PaymentMethod? get paymentMethod; String? get paymentReference; String? get notes; Map<String, dynamic>? get metadata; DateTime? get createdAt; DateTime? get updatedAt;// Additional admin-specific fields
 String? get adminNotes; bool? get requiresFollowUp; String? get followUpReason; DateTime? get followUpDate; String? get assignedToAdminId; String? get assignedToAdminName;
/// Create a copy of AdminInvoice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminInvoiceCopyWith<AdminInvoice> get copyWith => _$AdminInvoiceCopyWithImpl<AdminInvoice>(this as AdminInvoice, _$identity);

  /// Serializes this AdminInvoice to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminInvoice&&(identical(other.id, id) || other.id == id)&&(identical(other.invoiceNumber, invoiceNumber) || other.invoiceNumber == invoiceNumber)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.subscriptionId, subscriptionId) || other.subscriptionId == subscriptionId)&&(identical(other.subscriptionName, subscriptionName) || other.subscriptionName == subscriptionName)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.issueDate, issueDate) || other.issueDate == issueDate)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.taxAmount, taxAmount) || other.taxAmount == taxAmount)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.currency, currency) || other.currency == currency)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentDate, paymentDate) || other.paymentDate == paymentDate)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.paymentReference, paymentReference) || other.paymentReference == paymentReference)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.adminNotes, adminNotes) || other.adminNotes == adminNotes)&&(identical(other.requiresFollowUp, requiresFollowUp) || other.requiresFollowUp == requiresFollowUp)&&(identical(other.followUpReason, followUpReason) || other.followUpReason == followUpReason)&&(identical(other.followUpDate, followUpDate) || other.followUpDate == followUpDate)&&(identical(other.assignedToAdminId, assignedToAdminId) || other.assignedToAdminId == assignedToAdminId)&&(identical(other.assignedToAdminName, assignedToAdminName) || other.assignedToAdminName == assignedToAdminName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,invoiceNumber,companyId,companyName,subscriptionId,subscriptionName,periodStart,periodEnd,issueDate,dueDate,subtotal,taxAmount,discountAmount,totalAmount,currency,const DeepCollectionEquality().hash(items),status,paymentDate,paymentMethod,paymentReference,notes,const DeepCollectionEquality().hash(metadata),createdAt,updatedAt,adminNotes,requiresFollowUp,followUpReason,followUpDate,assignedToAdminId,assignedToAdminName]);

@override
String toString() {
  return 'AdminInvoice(id: $id, invoiceNumber: $invoiceNumber, companyId: $companyId, companyName: $companyName, subscriptionId: $subscriptionId, subscriptionName: $subscriptionName, periodStart: $periodStart, periodEnd: $periodEnd, issueDate: $issueDate, dueDate: $dueDate, subtotal: $subtotal, taxAmount: $taxAmount, discountAmount: $discountAmount, totalAmount: $totalAmount, currency: $currency, items: $items, status: $status, paymentDate: $paymentDate, paymentMethod: $paymentMethod, paymentReference: $paymentReference, notes: $notes, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt, adminNotes: $adminNotes, requiresFollowUp: $requiresFollowUp, followUpReason: $followUpReason, followUpDate: $followUpDate, assignedToAdminId: $assignedToAdminId, assignedToAdminName: $assignedToAdminName)';
}


}

/// @nodoc
abstract mixin class $AdminInvoiceCopyWith<$Res>  {
  factory $AdminInvoiceCopyWith(AdminInvoice value, $Res Function(AdminInvoice) _then) = _$AdminInvoiceCopyWithImpl;
@useResult
$Res call({
 String id, String invoiceNumber, String companyId, String companyName, String subscriptionId, String subscriptionName, DateTime periodStart, DateTime periodEnd, DateTime issueDate, DateTime dueDate, double subtotal, double taxAmount, double discountAmount, double totalAmount, String currency, List<AdminInvoiceItem> items, InvoiceStatus status, DateTime? paymentDate, PaymentMethod? paymentMethod, String? paymentReference, String? notes, Map<String, dynamic>? metadata, DateTime? createdAt, DateTime? updatedAt, String? adminNotes, bool? requiresFollowUp, String? followUpReason, DateTime? followUpDate, String? assignedToAdminId, String? assignedToAdminName
});




}
/// @nodoc
class _$AdminInvoiceCopyWithImpl<$Res>
    implements $AdminInvoiceCopyWith<$Res> {
  _$AdminInvoiceCopyWithImpl(this._self, this._then);

  final AdminInvoice _self;
  final $Res Function(AdminInvoice) _then;

/// Create a copy of AdminInvoice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? invoiceNumber = null,Object? companyId = null,Object? companyName = null,Object? subscriptionId = null,Object? subscriptionName = null,Object? periodStart = null,Object? periodEnd = null,Object? issueDate = null,Object? dueDate = null,Object? subtotal = null,Object? taxAmount = null,Object? discountAmount = null,Object? totalAmount = null,Object? currency = null,Object? items = null,Object? status = null,Object? paymentDate = freezed,Object? paymentMethod = freezed,Object? paymentReference = freezed,Object? notes = freezed,Object? metadata = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? adminNotes = freezed,Object? requiresFollowUp = freezed,Object? followUpReason = freezed,Object? followUpDate = freezed,Object? assignedToAdminId = freezed,Object? assignedToAdminName = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,invoiceNumber: null == invoiceNumber ? _self.invoiceNumber : invoiceNumber // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,companyName: null == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String,subscriptionId: null == subscriptionId ? _self.subscriptionId : subscriptionId // ignore: cast_nullable_to_non_nullable
as String,subscriptionName: null == subscriptionName ? _self.subscriptionName : subscriptionName // ignore: cast_nullable_to_non_nullable
as String,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,issueDate: null == issueDate ? _self.issueDate : issueDate // ignore: cast_nullable_to_non_nullable
as DateTime,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,taxAmount: null == taxAmount ? _self.taxAmount : taxAmount // ignore: cast_nullable_to_non_nullable
as double,discountAmount: null == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as double,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<AdminInvoiceItem>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InvoiceStatus,paymentDate: freezed == paymentDate ? _self.paymentDate : paymentDate // ignore: cast_nullable_to_non_nullable
as DateTime?,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod?,paymentReference: freezed == paymentReference ? _self.paymentReference : paymentReference // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,adminNotes: freezed == adminNotes ? _self.adminNotes : adminNotes // ignore: cast_nullable_to_non_nullable
as String?,requiresFollowUp: freezed == requiresFollowUp ? _self.requiresFollowUp : requiresFollowUp // ignore: cast_nullable_to_non_nullable
as bool?,followUpReason: freezed == followUpReason ? _self.followUpReason : followUpReason // ignore: cast_nullable_to_non_nullable
as String?,followUpDate: freezed == followUpDate ? _self.followUpDate : followUpDate // ignore: cast_nullable_to_non_nullable
as DateTime?,assignedToAdminId: freezed == assignedToAdminId ? _self.assignedToAdminId : assignedToAdminId // ignore: cast_nullable_to_non_nullable
as String?,assignedToAdminName: freezed == assignedToAdminName ? _self.assignedToAdminName : assignedToAdminName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminInvoice].
extension AdminInvoicePatterns on AdminInvoice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminInvoice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminInvoice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminInvoice value)  $default,){
final _that = this;
switch (_that) {
case _AdminInvoice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminInvoice value)?  $default,){
final _that = this;
switch (_that) {
case _AdminInvoice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String invoiceNumber,  String companyId,  String companyName,  String subscriptionId,  String subscriptionName,  DateTime periodStart,  DateTime periodEnd,  DateTime issueDate,  DateTime dueDate,  double subtotal,  double taxAmount,  double discountAmount,  double totalAmount,  String currency,  List<AdminInvoiceItem> items,  InvoiceStatus status,  DateTime? paymentDate,  PaymentMethod? paymentMethod,  String? paymentReference,  String? notes,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt,  String? adminNotes,  bool? requiresFollowUp,  String? followUpReason,  DateTime? followUpDate,  String? assignedToAdminId,  String? assignedToAdminName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminInvoice() when $default != null:
return $default(_that.id,_that.invoiceNumber,_that.companyId,_that.companyName,_that.subscriptionId,_that.subscriptionName,_that.periodStart,_that.periodEnd,_that.issueDate,_that.dueDate,_that.subtotal,_that.taxAmount,_that.discountAmount,_that.totalAmount,_that.currency,_that.items,_that.status,_that.paymentDate,_that.paymentMethod,_that.paymentReference,_that.notes,_that.metadata,_that.createdAt,_that.updatedAt,_that.adminNotes,_that.requiresFollowUp,_that.followUpReason,_that.followUpDate,_that.assignedToAdminId,_that.assignedToAdminName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String invoiceNumber,  String companyId,  String companyName,  String subscriptionId,  String subscriptionName,  DateTime periodStart,  DateTime periodEnd,  DateTime issueDate,  DateTime dueDate,  double subtotal,  double taxAmount,  double discountAmount,  double totalAmount,  String currency,  List<AdminInvoiceItem> items,  InvoiceStatus status,  DateTime? paymentDate,  PaymentMethod? paymentMethod,  String? paymentReference,  String? notes,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt,  String? adminNotes,  bool? requiresFollowUp,  String? followUpReason,  DateTime? followUpDate,  String? assignedToAdminId,  String? assignedToAdminName)  $default,) {final _that = this;
switch (_that) {
case _AdminInvoice():
return $default(_that.id,_that.invoiceNumber,_that.companyId,_that.companyName,_that.subscriptionId,_that.subscriptionName,_that.periodStart,_that.periodEnd,_that.issueDate,_that.dueDate,_that.subtotal,_that.taxAmount,_that.discountAmount,_that.totalAmount,_that.currency,_that.items,_that.status,_that.paymentDate,_that.paymentMethod,_that.paymentReference,_that.notes,_that.metadata,_that.createdAt,_that.updatedAt,_that.adminNotes,_that.requiresFollowUp,_that.followUpReason,_that.followUpDate,_that.assignedToAdminId,_that.assignedToAdminName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String invoiceNumber,  String companyId,  String companyName,  String subscriptionId,  String subscriptionName,  DateTime periodStart,  DateTime periodEnd,  DateTime issueDate,  DateTime dueDate,  double subtotal,  double taxAmount,  double discountAmount,  double totalAmount,  String currency,  List<AdminInvoiceItem> items,  InvoiceStatus status,  DateTime? paymentDate,  PaymentMethod? paymentMethod,  String? paymentReference,  String? notes,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt,  String? adminNotes,  bool? requiresFollowUp,  String? followUpReason,  DateTime? followUpDate,  String? assignedToAdminId,  String? assignedToAdminName)?  $default,) {final _that = this;
switch (_that) {
case _AdminInvoice() when $default != null:
return $default(_that.id,_that.invoiceNumber,_that.companyId,_that.companyName,_that.subscriptionId,_that.subscriptionName,_that.periodStart,_that.periodEnd,_that.issueDate,_that.dueDate,_that.subtotal,_that.taxAmount,_that.discountAmount,_that.totalAmount,_that.currency,_that.items,_that.status,_that.paymentDate,_that.paymentMethod,_that.paymentReference,_that.notes,_that.metadata,_that.createdAt,_that.updatedAt,_that.adminNotes,_that.requiresFollowUp,_that.followUpReason,_that.followUpDate,_that.assignedToAdminId,_that.assignedToAdminName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminInvoice implements AdminInvoice {
  const _AdminInvoice({required this.id, required this.invoiceNumber, required this.companyId, required this.companyName, required this.subscriptionId, required this.subscriptionName, required this.periodStart, required this.periodEnd, required this.issueDate, required this.dueDate, required this.subtotal, required this.taxAmount, required this.discountAmount, required this.totalAmount, this.currency = 'USD', required final  List<AdminInvoiceItem> items, this.status = InvoiceStatus.pending, this.paymentDate, this.paymentMethod, this.paymentReference, this.notes, final  Map<String, dynamic>? metadata, this.createdAt, this.updatedAt, this.adminNotes, this.requiresFollowUp, this.followUpReason, this.followUpDate, this.assignedToAdminId, this.assignedToAdminName}): _items = items,_metadata = metadata;
  factory _AdminInvoice.fromJson(Map<String, dynamic> json) => _$AdminInvoiceFromJson(json);

@override final  String id;
@override final  String invoiceNumber;
@override final  String companyId;
@override final  String companyName;
@override final  String subscriptionId;
@override final  String subscriptionName;
@override final  DateTime periodStart;
@override final  DateTime periodEnd;
@override final  DateTime issueDate;
@override final  DateTime dueDate;
@override final  double subtotal;
@override final  double taxAmount;
@override final  double discountAmount;
@override final  double totalAmount;
@override@JsonKey() final  String currency;
 final  List<AdminInvoiceItem> _items;
@override List<AdminInvoiceItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  InvoiceStatus status;
@override final  DateTime? paymentDate;
@override final  PaymentMethod? paymentMethod;
@override final  String? paymentReference;
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
// Additional admin-specific fields
@override final  String? adminNotes;
@override final  bool? requiresFollowUp;
@override final  String? followUpReason;
@override final  DateTime? followUpDate;
@override final  String? assignedToAdminId;
@override final  String? assignedToAdminName;

/// Create a copy of AdminInvoice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminInvoiceCopyWith<_AdminInvoice> get copyWith => __$AdminInvoiceCopyWithImpl<_AdminInvoice>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminInvoiceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminInvoice&&(identical(other.id, id) || other.id == id)&&(identical(other.invoiceNumber, invoiceNumber) || other.invoiceNumber == invoiceNumber)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.subscriptionId, subscriptionId) || other.subscriptionId == subscriptionId)&&(identical(other.subscriptionName, subscriptionName) || other.subscriptionName == subscriptionName)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.issueDate, issueDate) || other.issueDate == issueDate)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.taxAmount, taxAmount) || other.taxAmount == taxAmount)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.currency, currency) || other.currency == currency)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentDate, paymentDate) || other.paymentDate == paymentDate)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.paymentReference, paymentReference) || other.paymentReference == paymentReference)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.adminNotes, adminNotes) || other.adminNotes == adminNotes)&&(identical(other.requiresFollowUp, requiresFollowUp) || other.requiresFollowUp == requiresFollowUp)&&(identical(other.followUpReason, followUpReason) || other.followUpReason == followUpReason)&&(identical(other.followUpDate, followUpDate) || other.followUpDate == followUpDate)&&(identical(other.assignedToAdminId, assignedToAdminId) || other.assignedToAdminId == assignedToAdminId)&&(identical(other.assignedToAdminName, assignedToAdminName) || other.assignedToAdminName == assignedToAdminName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,invoiceNumber,companyId,companyName,subscriptionId,subscriptionName,periodStart,periodEnd,issueDate,dueDate,subtotal,taxAmount,discountAmount,totalAmount,currency,const DeepCollectionEquality().hash(_items),status,paymentDate,paymentMethod,paymentReference,notes,const DeepCollectionEquality().hash(_metadata),createdAt,updatedAt,adminNotes,requiresFollowUp,followUpReason,followUpDate,assignedToAdminId,assignedToAdminName]);

@override
String toString() {
  return 'AdminInvoice(id: $id, invoiceNumber: $invoiceNumber, companyId: $companyId, companyName: $companyName, subscriptionId: $subscriptionId, subscriptionName: $subscriptionName, periodStart: $periodStart, periodEnd: $periodEnd, issueDate: $issueDate, dueDate: $dueDate, subtotal: $subtotal, taxAmount: $taxAmount, discountAmount: $discountAmount, totalAmount: $totalAmount, currency: $currency, items: $items, status: $status, paymentDate: $paymentDate, paymentMethod: $paymentMethod, paymentReference: $paymentReference, notes: $notes, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt, adminNotes: $adminNotes, requiresFollowUp: $requiresFollowUp, followUpReason: $followUpReason, followUpDate: $followUpDate, assignedToAdminId: $assignedToAdminId, assignedToAdminName: $assignedToAdminName)';
}


}

/// @nodoc
abstract mixin class _$AdminInvoiceCopyWith<$Res> implements $AdminInvoiceCopyWith<$Res> {
  factory _$AdminInvoiceCopyWith(_AdminInvoice value, $Res Function(_AdminInvoice) _then) = __$AdminInvoiceCopyWithImpl;
@override @useResult
$Res call({
 String id, String invoiceNumber, String companyId, String companyName, String subscriptionId, String subscriptionName, DateTime periodStart, DateTime periodEnd, DateTime issueDate, DateTime dueDate, double subtotal, double taxAmount, double discountAmount, double totalAmount, String currency, List<AdminInvoiceItem> items, InvoiceStatus status, DateTime? paymentDate, PaymentMethod? paymentMethod, String? paymentReference, String? notes, Map<String, dynamic>? metadata, DateTime? createdAt, DateTime? updatedAt, String? adminNotes, bool? requiresFollowUp, String? followUpReason, DateTime? followUpDate, String? assignedToAdminId, String? assignedToAdminName
});




}
/// @nodoc
class __$AdminInvoiceCopyWithImpl<$Res>
    implements _$AdminInvoiceCopyWith<$Res> {
  __$AdminInvoiceCopyWithImpl(this._self, this._then);

  final _AdminInvoice _self;
  final $Res Function(_AdminInvoice) _then;

/// Create a copy of AdminInvoice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? invoiceNumber = null,Object? companyId = null,Object? companyName = null,Object? subscriptionId = null,Object? subscriptionName = null,Object? periodStart = null,Object? periodEnd = null,Object? issueDate = null,Object? dueDate = null,Object? subtotal = null,Object? taxAmount = null,Object? discountAmount = null,Object? totalAmount = null,Object? currency = null,Object? items = null,Object? status = null,Object? paymentDate = freezed,Object? paymentMethod = freezed,Object? paymentReference = freezed,Object? notes = freezed,Object? metadata = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? adminNotes = freezed,Object? requiresFollowUp = freezed,Object? followUpReason = freezed,Object? followUpDate = freezed,Object? assignedToAdminId = freezed,Object? assignedToAdminName = freezed,}) {
  return _then(_AdminInvoice(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,invoiceNumber: null == invoiceNumber ? _self.invoiceNumber : invoiceNumber // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,companyName: null == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String,subscriptionId: null == subscriptionId ? _self.subscriptionId : subscriptionId // ignore: cast_nullable_to_non_nullable
as String,subscriptionName: null == subscriptionName ? _self.subscriptionName : subscriptionName // ignore: cast_nullable_to_non_nullable
as String,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,issueDate: null == issueDate ? _self.issueDate : issueDate // ignore: cast_nullable_to_non_nullable
as DateTime,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,taxAmount: null == taxAmount ? _self.taxAmount : taxAmount // ignore: cast_nullable_to_non_nullable
as double,discountAmount: null == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as double,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<AdminInvoiceItem>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InvoiceStatus,paymentDate: freezed == paymentDate ? _self.paymentDate : paymentDate // ignore: cast_nullable_to_non_nullable
as DateTime?,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod?,paymentReference: freezed == paymentReference ? _self.paymentReference : paymentReference // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,adminNotes: freezed == adminNotes ? _self.adminNotes : adminNotes // ignore: cast_nullable_to_non_nullable
as String?,requiresFollowUp: freezed == requiresFollowUp ? _self.requiresFollowUp : requiresFollowUp // ignore: cast_nullable_to_non_nullable
as bool?,followUpReason: freezed == followUpReason ? _self.followUpReason : followUpReason // ignore: cast_nullable_to_non_nullable
as String?,followUpDate: freezed == followUpDate ? _self.followUpDate : followUpDate // ignore: cast_nullable_to_non_nullable
as DateTime?,assignedToAdminId: freezed == assignedToAdminId ? _self.assignedToAdminId : assignedToAdminId // ignore: cast_nullable_to_non_nullable
as String?,assignedToAdminName: freezed == assignedToAdminName ? _self.assignedToAdminName : assignedToAdminName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AdminInvoiceItem {

 String get id; String get description; double get quantity; double get unitPrice; double get total; String get currency; String? get codeType; int? get codeCount; DateTime? get periodStart; DateTime? get periodEnd; Map<String, dynamic>? get metadata;// Additional admin-specific fields
 String? get planFeatureId; String? get planFeatureName; double? get usageAmount; double? get overageAmount; bool? get isOverageCharge;
/// Create a copy of AdminInvoiceItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminInvoiceItemCopyWith<AdminInvoiceItem> get copyWith => _$AdminInvoiceItemCopyWithImpl<AdminInvoiceItem>(this as AdminInvoiceItem, _$identity);

  /// Serializes this AdminInvoiceItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminInvoiceItem&&(identical(other.id, id) || other.id == id)&&(identical(other.description, description) || other.description == description)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.total, total) || other.total == total)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.codeType, codeType) || other.codeType == codeType)&&(identical(other.codeCount, codeCount) || other.codeCount == codeCount)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.planFeatureId, planFeatureId) || other.planFeatureId == planFeatureId)&&(identical(other.planFeatureName, planFeatureName) || other.planFeatureName == planFeatureName)&&(identical(other.usageAmount, usageAmount) || other.usageAmount == usageAmount)&&(identical(other.overageAmount, overageAmount) || other.overageAmount == overageAmount)&&(identical(other.isOverageCharge, isOverageCharge) || other.isOverageCharge == isOverageCharge));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,description,quantity,unitPrice,total,currency,codeType,codeCount,periodStart,periodEnd,const DeepCollectionEquality().hash(metadata),planFeatureId,planFeatureName,usageAmount,overageAmount,isOverageCharge);

@override
String toString() {
  return 'AdminInvoiceItem(id: $id, description: $description, quantity: $quantity, unitPrice: $unitPrice, total: $total, currency: $currency, codeType: $codeType, codeCount: $codeCount, periodStart: $periodStart, periodEnd: $periodEnd, metadata: $metadata, planFeatureId: $planFeatureId, planFeatureName: $planFeatureName, usageAmount: $usageAmount, overageAmount: $overageAmount, isOverageCharge: $isOverageCharge)';
}


}

/// @nodoc
abstract mixin class $AdminInvoiceItemCopyWith<$Res>  {
  factory $AdminInvoiceItemCopyWith(AdminInvoiceItem value, $Res Function(AdminInvoiceItem) _then) = _$AdminInvoiceItemCopyWithImpl;
@useResult
$Res call({
 String id, String description, double quantity, double unitPrice, double total, String currency, String? codeType, int? codeCount, DateTime? periodStart, DateTime? periodEnd, Map<String, dynamic>? metadata, String? planFeatureId, String? planFeatureName, double? usageAmount, double? overageAmount, bool? isOverageCharge
});




}
/// @nodoc
class _$AdminInvoiceItemCopyWithImpl<$Res>
    implements $AdminInvoiceItemCopyWith<$Res> {
  _$AdminInvoiceItemCopyWithImpl(this._self, this._then);

  final AdminInvoiceItem _self;
  final $Res Function(AdminInvoiceItem) _then;

/// Create a copy of AdminInvoiceItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? description = null,Object? quantity = null,Object? unitPrice = null,Object? total = null,Object? currency = null,Object? codeType = freezed,Object? codeCount = freezed,Object? periodStart = freezed,Object? periodEnd = freezed,Object? metadata = freezed,Object? planFeatureId = freezed,Object? planFeatureName = freezed,Object? usageAmount = freezed,Object? overageAmount = freezed,Object? isOverageCharge = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,codeType: freezed == codeType ? _self.codeType : codeType // ignore: cast_nullable_to_non_nullable
as String?,codeCount: freezed == codeCount ? _self.codeCount : codeCount // ignore: cast_nullable_to_non_nullable
as int?,periodStart: freezed == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime?,periodEnd: freezed == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,planFeatureId: freezed == planFeatureId ? _self.planFeatureId : planFeatureId // ignore: cast_nullable_to_non_nullable
as String?,planFeatureName: freezed == planFeatureName ? _self.planFeatureName : planFeatureName // ignore: cast_nullable_to_non_nullable
as String?,usageAmount: freezed == usageAmount ? _self.usageAmount : usageAmount // ignore: cast_nullable_to_non_nullable
as double?,overageAmount: freezed == overageAmount ? _self.overageAmount : overageAmount // ignore: cast_nullable_to_non_nullable
as double?,isOverageCharge: freezed == isOverageCharge ? _self.isOverageCharge : isOverageCharge // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminInvoiceItem].
extension AdminInvoiceItemPatterns on AdminInvoiceItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminInvoiceItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminInvoiceItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminInvoiceItem value)  $default,){
final _that = this;
switch (_that) {
case _AdminInvoiceItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminInvoiceItem value)?  $default,){
final _that = this;
switch (_that) {
case _AdminInvoiceItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String description,  double quantity,  double unitPrice,  double total,  String currency,  String? codeType,  int? codeCount,  DateTime? periodStart,  DateTime? periodEnd,  Map<String, dynamic>? metadata,  String? planFeatureId,  String? planFeatureName,  double? usageAmount,  double? overageAmount,  bool? isOverageCharge)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminInvoiceItem() when $default != null:
return $default(_that.id,_that.description,_that.quantity,_that.unitPrice,_that.total,_that.currency,_that.codeType,_that.codeCount,_that.periodStart,_that.periodEnd,_that.metadata,_that.planFeatureId,_that.planFeatureName,_that.usageAmount,_that.overageAmount,_that.isOverageCharge);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String description,  double quantity,  double unitPrice,  double total,  String currency,  String? codeType,  int? codeCount,  DateTime? periodStart,  DateTime? periodEnd,  Map<String, dynamic>? metadata,  String? planFeatureId,  String? planFeatureName,  double? usageAmount,  double? overageAmount,  bool? isOverageCharge)  $default,) {final _that = this;
switch (_that) {
case _AdminInvoiceItem():
return $default(_that.id,_that.description,_that.quantity,_that.unitPrice,_that.total,_that.currency,_that.codeType,_that.codeCount,_that.periodStart,_that.periodEnd,_that.metadata,_that.planFeatureId,_that.planFeatureName,_that.usageAmount,_that.overageAmount,_that.isOverageCharge);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String description,  double quantity,  double unitPrice,  double total,  String currency,  String? codeType,  int? codeCount,  DateTime? periodStart,  DateTime? periodEnd,  Map<String, dynamic>? metadata,  String? planFeatureId,  String? planFeatureName,  double? usageAmount,  double? overageAmount,  bool? isOverageCharge)?  $default,) {final _that = this;
switch (_that) {
case _AdminInvoiceItem() when $default != null:
return $default(_that.id,_that.description,_that.quantity,_that.unitPrice,_that.total,_that.currency,_that.codeType,_that.codeCount,_that.periodStart,_that.periodEnd,_that.metadata,_that.planFeatureId,_that.planFeatureName,_that.usageAmount,_that.overageAmount,_that.isOverageCharge);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminInvoiceItem implements AdminInvoiceItem {
  const _AdminInvoiceItem({required this.id, required this.description, required this.quantity, required this.unitPrice, required this.total, required this.currency, this.codeType, this.codeCount, this.periodStart, this.periodEnd, final  Map<String, dynamic>? metadata, this.planFeatureId, this.planFeatureName, this.usageAmount, this.overageAmount, this.isOverageCharge}): _metadata = metadata;
  factory _AdminInvoiceItem.fromJson(Map<String, dynamic> json) => _$AdminInvoiceItemFromJson(json);

@override final  String id;
@override final  String description;
@override final  double quantity;
@override final  double unitPrice;
@override final  double total;
@override final  String currency;
@override final  String? codeType;
@override final  int? codeCount;
@override final  DateTime? periodStart;
@override final  DateTime? periodEnd;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

// Additional admin-specific fields
@override final  String? planFeatureId;
@override final  String? planFeatureName;
@override final  double? usageAmount;
@override final  double? overageAmount;
@override final  bool? isOverageCharge;

/// Create a copy of AdminInvoiceItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminInvoiceItemCopyWith<_AdminInvoiceItem> get copyWith => __$AdminInvoiceItemCopyWithImpl<_AdminInvoiceItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminInvoiceItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminInvoiceItem&&(identical(other.id, id) || other.id == id)&&(identical(other.description, description) || other.description == description)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.total, total) || other.total == total)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.codeType, codeType) || other.codeType == codeType)&&(identical(other.codeCount, codeCount) || other.codeCount == codeCount)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.planFeatureId, planFeatureId) || other.planFeatureId == planFeatureId)&&(identical(other.planFeatureName, planFeatureName) || other.planFeatureName == planFeatureName)&&(identical(other.usageAmount, usageAmount) || other.usageAmount == usageAmount)&&(identical(other.overageAmount, overageAmount) || other.overageAmount == overageAmount)&&(identical(other.isOverageCharge, isOverageCharge) || other.isOverageCharge == isOverageCharge));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,description,quantity,unitPrice,total,currency,codeType,codeCount,periodStart,periodEnd,const DeepCollectionEquality().hash(_metadata),planFeatureId,planFeatureName,usageAmount,overageAmount,isOverageCharge);

@override
String toString() {
  return 'AdminInvoiceItem(id: $id, description: $description, quantity: $quantity, unitPrice: $unitPrice, total: $total, currency: $currency, codeType: $codeType, codeCount: $codeCount, periodStart: $periodStart, periodEnd: $periodEnd, metadata: $metadata, planFeatureId: $planFeatureId, planFeatureName: $planFeatureName, usageAmount: $usageAmount, overageAmount: $overageAmount, isOverageCharge: $isOverageCharge)';
}


}

/// @nodoc
abstract mixin class _$AdminInvoiceItemCopyWith<$Res> implements $AdminInvoiceItemCopyWith<$Res> {
  factory _$AdminInvoiceItemCopyWith(_AdminInvoiceItem value, $Res Function(_AdminInvoiceItem) _then) = __$AdminInvoiceItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String description, double quantity, double unitPrice, double total, String currency, String? codeType, int? codeCount, DateTime? periodStart, DateTime? periodEnd, Map<String, dynamic>? metadata, String? planFeatureId, String? planFeatureName, double? usageAmount, double? overageAmount, bool? isOverageCharge
});




}
/// @nodoc
class __$AdminInvoiceItemCopyWithImpl<$Res>
    implements _$AdminInvoiceItemCopyWith<$Res> {
  __$AdminInvoiceItemCopyWithImpl(this._self, this._then);

  final _AdminInvoiceItem _self;
  final $Res Function(_AdminInvoiceItem) _then;

/// Create a copy of AdminInvoiceItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? description = null,Object? quantity = null,Object? unitPrice = null,Object? total = null,Object? currency = null,Object? codeType = freezed,Object? codeCount = freezed,Object? periodStart = freezed,Object? periodEnd = freezed,Object? metadata = freezed,Object? planFeatureId = freezed,Object? planFeatureName = freezed,Object? usageAmount = freezed,Object? overageAmount = freezed,Object? isOverageCharge = freezed,}) {
  return _then(_AdminInvoiceItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,codeType: freezed == codeType ? _self.codeType : codeType // ignore: cast_nullable_to_non_nullable
as String?,codeCount: freezed == codeCount ? _self.codeCount : codeCount // ignore: cast_nullable_to_non_nullable
as int?,periodStart: freezed == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime?,periodEnd: freezed == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,planFeatureId: freezed == planFeatureId ? _self.planFeatureId : planFeatureId // ignore: cast_nullable_to_non_nullable
as String?,planFeatureName: freezed == planFeatureName ? _self.planFeatureName : planFeatureName // ignore: cast_nullable_to_non_nullable
as String?,usageAmount: freezed == usageAmount ? _self.usageAmount : usageAmount // ignore: cast_nullable_to_non_nullable
as double?,overageAmount: freezed == overageAmount ? _self.overageAmount : overageAmount // ignore: cast_nullable_to_non_nullable
as double?,isOverageCharge: freezed == isOverageCharge ? _self.isOverageCharge : isOverageCharge // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}


/// @nodoc
mixin _$PlatformRevenueSummary {

 double get totalRevenue; double get collectedRevenue; double get pendingRevenue; double get overdueRevenue; int get totalInvoices; int get paidInvoices; int get pendingInvoices; int get overdueInvoices; int get draftInvoices; int get cancelledInvoices; DateTime? get periodStart; DateTime? get periodEnd; Map<String, double>? get revenueByPlan; Map<String, double>? get revenueByCompanyType; List<RevenueTrendData>? get revenueTrend;
/// Create a copy of PlatformRevenueSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlatformRevenueSummaryCopyWith<PlatformRevenueSummary> get copyWith => _$PlatformRevenueSummaryCopyWithImpl<PlatformRevenueSummary>(this as PlatformRevenueSummary, _$identity);

  /// Serializes this PlatformRevenueSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlatformRevenueSummary&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.collectedRevenue, collectedRevenue) || other.collectedRevenue == collectedRevenue)&&(identical(other.pendingRevenue, pendingRevenue) || other.pendingRevenue == pendingRevenue)&&(identical(other.overdueRevenue, overdueRevenue) || other.overdueRevenue == overdueRevenue)&&(identical(other.totalInvoices, totalInvoices) || other.totalInvoices == totalInvoices)&&(identical(other.paidInvoices, paidInvoices) || other.paidInvoices == paidInvoices)&&(identical(other.pendingInvoices, pendingInvoices) || other.pendingInvoices == pendingInvoices)&&(identical(other.overdueInvoices, overdueInvoices) || other.overdueInvoices == overdueInvoices)&&(identical(other.draftInvoices, draftInvoices) || other.draftInvoices == draftInvoices)&&(identical(other.cancelledInvoices, cancelledInvoices) || other.cancelledInvoices == cancelledInvoices)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&const DeepCollectionEquality().equals(other.revenueByPlan, revenueByPlan)&&const DeepCollectionEquality().equals(other.revenueByCompanyType, revenueByCompanyType)&&const DeepCollectionEquality().equals(other.revenueTrend, revenueTrend));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalRevenue,collectedRevenue,pendingRevenue,overdueRevenue,totalInvoices,paidInvoices,pendingInvoices,overdueInvoices,draftInvoices,cancelledInvoices,periodStart,periodEnd,const DeepCollectionEquality().hash(revenueByPlan),const DeepCollectionEquality().hash(revenueByCompanyType),const DeepCollectionEquality().hash(revenueTrend));

@override
String toString() {
  return 'PlatformRevenueSummary(totalRevenue: $totalRevenue, collectedRevenue: $collectedRevenue, pendingRevenue: $pendingRevenue, overdueRevenue: $overdueRevenue, totalInvoices: $totalInvoices, paidInvoices: $paidInvoices, pendingInvoices: $pendingInvoices, overdueInvoices: $overdueInvoices, draftInvoices: $draftInvoices, cancelledInvoices: $cancelledInvoices, periodStart: $periodStart, periodEnd: $periodEnd, revenueByPlan: $revenueByPlan, revenueByCompanyType: $revenueByCompanyType, revenueTrend: $revenueTrend)';
}


}

/// @nodoc
abstract mixin class $PlatformRevenueSummaryCopyWith<$Res>  {
  factory $PlatformRevenueSummaryCopyWith(PlatformRevenueSummary value, $Res Function(PlatformRevenueSummary) _then) = _$PlatformRevenueSummaryCopyWithImpl;
@useResult
$Res call({
 double totalRevenue, double collectedRevenue, double pendingRevenue, double overdueRevenue, int totalInvoices, int paidInvoices, int pendingInvoices, int overdueInvoices, int draftInvoices, int cancelledInvoices, DateTime? periodStart, DateTime? periodEnd, Map<String, double>? revenueByPlan, Map<String, double>? revenueByCompanyType, List<RevenueTrendData>? revenueTrend
});




}
/// @nodoc
class _$PlatformRevenueSummaryCopyWithImpl<$Res>
    implements $PlatformRevenueSummaryCopyWith<$Res> {
  _$PlatformRevenueSummaryCopyWithImpl(this._self, this._then);

  final PlatformRevenueSummary _self;
  final $Res Function(PlatformRevenueSummary) _then;

/// Create a copy of PlatformRevenueSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalRevenue = null,Object? collectedRevenue = null,Object? pendingRevenue = null,Object? overdueRevenue = null,Object? totalInvoices = null,Object? paidInvoices = null,Object? pendingInvoices = null,Object? overdueInvoices = null,Object? draftInvoices = null,Object? cancelledInvoices = null,Object? periodStart = freezed,Object? periodEnd = freezed,Object? revenueByPlan = freezed,Object? revenueByCompanyType = freezed,Object? revenueTrend = freezed,}) {
  return _then(_self.copyWith(
totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,collectedRevenue: null == collectedRevenue ? _self.collectedRevenue : collectedRevenue // ignore: cast_nullable_to_non_nullable
as double,pendingRevenue: null == pendingRevenue ? _self.pendingRevenue : pendingRevenue // ignore: cast_nullable_to_non_nullable
as double,overdueRevenue: null == overdueRevenue ? _self.overdueRevenue : overdueRevenue // ignore: cast_nullable_to_non_nullable
as double,totalInvoices: null == totalInvoices ? _self.totalInvoices : totalInvoices // ignore: cast_nullable_to_non_nullable
as int,paidInvoices: null == paidInvoices ? _self.paidInvoices : paidInvoices // ignore: cast_nullable_to_non_nullable
as int,pendingInvoices: null == pendingInvoices ? _self.pendingInvoices : pendingInvoices // ignore: cast_nullable_to_non_nullable
as int,overdueInvoices: null == overdueInvoices ? _self.overdueInvoices : overdueInvoices // ignore: cast_nullable_to_non_nullable
as int,draftInvoices: null == draftInvoices ? _self.draftInvoices : draftInvoices // ignore: cast_nullable_to_non_nullable
as int,cancelledInvoices: null == cancelledInvoices ? _self.cancelledInvoices : cancelledInvoices // ignore: cast_nullable_to_non_nullable
as int,periodStart: freezed == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime?,periodEnd: freezed == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,revenueByPlan: freezed == revenueByPlan ? _self.revenueByPlan : revenueByPlan // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,revenueByCompanyType: freezed == revenueByCompanyType ? _self.revenueByCompanyType : revenueByCompanyType // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,revenueTrend: freezed == revenueTrend ? _self.revenueTrend : revenueTrend // ignore: cast_nullable_to_non_nullable
as List<RevenueTrendData>?,
  ));
}

}


/// Adds pattern-matching-related methods to [PlatformRevenueSummary].
extension PlatformRevenueSummaryPatterns on PlatformRevenueSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlatformRevenueSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlatformRevenueSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlatformRevenueSummary value)  $default,){
final _that = this;
switch (_that) {
case _PlatformRevenueSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlatformRevenueSummary value)?  $default,){
final _that = this;
switch (_that) {
case _PlatformRevenueSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double totalRevenue,  double collectedRevenue,  double pendingRevenue,  double overdueRevenue,  int totalInvoices,  int paidInvoices,  int pendingInvoices,  int overdueInvoices,  int draftInvoices,  int cancelledInvoices,  DateTime? periodStart,  DateTime? periodEnd,  Map<String, double>? revenueByPlan,  Map<String, double>? revenueByCompanyType,  List<RevenueTrendData>? revenueTrend)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlatformRevenueSummary() when $default != null:
return $default(_that.totalRevenue,_that.collectedRevenue,_that.pendingRevenue,_that.overdueRevenue,_that.totalInvoices,_that.paidInvoices,_that.pendingInvoices,_that.overdueInvoices,_that.draftInvoices,_that.cancelledInvoices,_that.periodStart,_that.periodEnd,_that.revenueByPlan,_that.revenueByCompanyType,_that.revenueTrend);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double totalRevenue,  double collectedRevenue,  double pendingRevenue,  double overdueRevenue,  int totalInvoices,  int paidInvoices,  int pendingInvoices,  int overdueInvoices,  int draftInvoices,  int cancelledInvoices,  DateTime? periodStart,  DateTime? periodEnd,  Map<String, double>? revenueByPlan,  Map<String, double>? revenueByCompanyType,  List<RevenueTrendData>? revenueTrend)  $default,) {final _that = this;
switch (_that) {
case _PlatformRevenueSummary():
return $default(_that.totalRevenue,_that.collectedRevenue,_that.pendingRevenue,_that.overdueRevenue,_that.totalInvoices,_that.paidInvoices,_that.pendingInvoices,_that.overdueInvoices,_that.draftInvoices,_that.cancelledInvoices,_that.periodStart,_that.periodEnd,_that.revenueByPlan,_that.revenueByCompanyType,_that.revenueTrend);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double totalRevenue,  double collectedRevenue,  double pendingRevenue,  double overdueRevenue,  int totalInvoices,  int paidInvoices,  int pendingInvoices,  int overdueInvoices,  int draftInvoices,  int cancelledInvoices,  DateTime? periodStart,  DateTime? periodEnd,  Map<String, double>? revenueByPlan,  Map<String, double>? revenueByCompanyType,  List<RevenueTrendData>? revenueTrend)?  $default,) {final _that = this;
switch (_that) {
case _PlatformRevenueSummary() when $default != null:
return $default(_that.totalRevenue,_that.collectedRevenue,_that.pendingRevenue,_that.overdueRevenue,_that.totalInvoices,_that.paidInvoices,_that.pendingInvoices,_that.overdueInvoices,_that.draftInvoices,_that.cancelledInvoices,_that.periodStart,_that.periodEnd,_that.revenueByPlan,_that.revenueByCompanyType,_that.revenueTrend);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlatformRevenueSummary implements PlatformRevenueSummary {
  const _PlatformRevenueSummary({this.totalRevenue = 0.0, this.collectedRevenue = 0.0, this.pendingRevenue = 0.0, this.overdueRevenue = 0.0, this.totalInvoices = 0, this.paidInvoices = 0, this.pendingInvoices = 0, this.overdueInvoices = 0, this.draftInvoices = 0, this.cancelledInvoices = 0, this.periodStart, this.periodEnd, final  Map<String, double>? revenueByPlan, final  Map<String, double>? revenueByCompanyType, final  List<RevenueTrendData>? revenueTrend}): _revenueByPlan = revenueByPlan,_revenueByCompanyType = revenueByCompanyType,_revenueTrend = revenueTrend;
  factory _PlatformRevenueSummary.fromJson(Map<String, dynamic> json) => _$PlatformRevenueSummaryFromJson(json);

@override@JsonKey() final  double totalRevenue;
@override@JsonKey() final  double collectedRevenue;
@override@JsonKey() final  double pendingRevenue;
@override@JsonKey() final  double overdueRevenue;
@override@JsonKey() final  int totalInvoices;
@override@JsonKey() final  int paidInvoices;
@override@JsonKey() final  int pendingInvoices;
@override@JsonKey() final  int overdueInvoices;
@override@JsonKey() final  int draftInvoices;
@override@JsonKey() final  int cancelledInvoices;
@override final  DateTime? periodStart;
@override final  DateTime? periodEnd;
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

 final  List<RevenueTrendData>? _revenueTrend;
@override List<RevenueTrendData>? get revenueTrend {
  final value = _revenueTrend;
  if (value == null) return null;
  if (_revenueTrend is EqualUnmodifiableListView) return _revenueTrend;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of PlatformRevenueSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlatformRevenueSummaryCopyWith<_PlatformRevenueSummary> get copyWith => __$PlatformRevenueSummaryCopyWithImpl<_PlatformRevenueSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlatformRevenueSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlatformRevenueSummary&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.collectedRevenue, collectedRevenue) || other.collectedRevenue == collectedRevenue)&&(identical(other.pendingRevenue, pendingRevenue) || other.pendingRevenue == pendingRevenue)&&(identical(other.overdueRevenue, overdueRevenue) || other.overdueRevenue == overdueRevenue)&&(identical(other.totalInvoices, totalInvoices) || other.totalInvoices == totalInvoices)&&(identical(other.paidInvoices, paidInvoices) || other.paidInvoices == paidInvoices)&&(identical(other.pendingInvoices, pendingInvoices) || other.pendingInvoices == pendingInvoices)&&(identical(other.overdueInvoices, overdueInvoices) || other.overdueInvoices == overdueInvoices)&&(identical(other.draftInvoices, draftInvoices) || other.draftInvoices == draftInvoices)&&(identical(other.cancelledInvoices, cancelledInvoices) || other.cancelledInvoices == cancelledInvoices)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&const DeepCollectionEquality().equals(other._revenueByPlan, _revenueByPlan)&&const DeepCollectionEquality().equals(other._revenueByCompanyType, _revenueByCompanyType)&&const DeepCollectionEquality().equals(other._revenueTrend, _revenueTrend));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalRevenue,collectedRevenue,pendingRevenue,overdueRevenue,totalInvoices,paidInvoices,pendingInvoices,overdueInvoices,draftInvoices,cancelledInvoices,periodStart,periodEnd,const DeepCollectionEquality().hash(_revenueByPlan),const DeepCollectionEquality().hash(_revenueByCompanyType),const DeepCollectionEquality().hash(_revenueTrend));

@override
String toString() {
  return 'PlatformRevenueSummary(totalRevenue: $totalRevenue, collectedRevenue: $collectedRevenue, pendingRevenue: $pendingRevenue, overdueRevenue: $overdueRevenue, totalInvoices: $totalInvoices, paidInvoices: $paidInvoices, pendingInvoices: $pendingInvoices, overdueInvoices: $overdueInvoices, draftInvoices: $draftInvoices, cancelledInvoices: $cancelledInvoices, periodStart: $periodStart, periodEnd: $periodEnd, revenueByPlan: $revenueByPlan, revenueByCompanyType: $revenueByCompanyType, revenueTrend: $revenueTrend)';
}


}

/// @nodoc
abstract mixin class _$PlatformRevenueSummaryCopyWith<$Res> implements $PlatformRevenueSummaryCopyWith<$Res> {
  factory _$PlatformRevenueSummaryCopyWith(_PlatformRevenueSummary value, $Res Function(_PlatformRevenueSummary) _then) = __$PlatformRevenueSummaryCopyWithImpl;
@override @useResult
$Res call({
 double totalRevenue, double collectedRevenue, double pendingRevenue, double overdueRevenue, int totalInvoices, int paidInvoices, int pendingInvoices, int overdueInvoices, int draftInvoices, int cancelledInvoices, DateTime? periodStart, DateTime? periodEnd, Map<String, double>? revenueByPlan, Map<String, double>? revenueByCompanyType, List<RevenueTrendData>? revenueTrend
});




}
/// @nodoc
class __$PlatformRevenueSummaryCopyWithImpl<$Res>
    implements _$PlatformRevenueSummaryCopyWith<$Res> {
  __$PlatformRevenueSummaryCopyWithImpl(this._self, this._then);

  final _PlatformRevenueSummary _self;
  final $Res Function(_PlatformRevenueSummary) _then;

/// Create a copy of PlatformRevenueSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalRevenue = null,Object? collectedRevenue = null,Object? pendingRevenue = null,Object? overdueRevenue = null,Object? totalInvoices = null,Object? paidInvoices = null,Object? pendingInvoices = null,Object? overdueInvoices = null,Object? draftInvoices = null,Object? cancelledInvoices = null,Object? periodStart = freezed,Object? periodEnd = freezed,Object? revenueByPlan = freezed,Object? revenueByCompanyType = freezed,Object? revenueTrend = freezed,}) {
  return _then(_PlatformRevenueSummary(
totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,collectedRevenue: null == collectedRevenue ? _self.collectedRevenue : collectedRevenue // ignore: cast_nullable_to_non_nullable
as double,pendingRevenue: null == pendingRevenue ? _self.pendingRevenue : pendingRevenue // ignore: cast_nullable_to_non_nullable
as double,overdueRevenue: null == overdueRevenue ? _self.overdueRevenue : overdueRevenue // ignore: cast_nullable_to_non_nullable
as double,totalInvoices: null == totalInvoices ? _self.totalInvoices : totalInvoices // ignore: cast_nullable_to_non_nullable
as int,paidInvoices: null == paidInvoices ? _self.paidInvoices : paidInvoices // ignore: cast_nullable_to_non_nullable
as int,pendingInvoices: null == pendingInvoices ? _self.pendingInvoices : pendingInvoices // ignore: cast_nullable_to_non_nullable
as int,overdueInvoices: null == overdueInvoices ? _self.overdueInvoices : overdueInvoices // ignore: cast_nullable_to_non_nullable
as int,draftInvoices: null == draftInvoices ? _self.draftInvoices : draftInvoices // ignore: cast_nullable_to_non_nullable
as int,cancelledInvoices: null == cancelledInvoices ? _self.cancelledInvoices : cancelledInvoices // ignore: cast_nullable_to_non_nullable
as int,periodStart: freezed == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime?,periodEnd: freezed == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,revenueByPlan: freezed == revenueByPlan ? _self._revenueByPlan : revenueByPlan // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,revenueByCompanyType: freezed == revenueByCompanyType ? _self._revenueByCompanyType : revenueByCompanyType // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,revenueTrend: freezed == revenueTrend ? _self._revenueTrend : revenueTrend // ignore: cast_nullable_to_non_nullable
as List<RevenueTrendData>?,
  ));
}


}


/// @nodoc
mixin _$RevenueTrendData {

 DateTime get date; double get revenue; int get invoiceCount; int get paidCount;
/// Create a copy of RevenueTrendData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RevenueTrendDataCopyWith<RevenueTrendData> get copyWith => _$RevenueTrendDataCopyWithImpl<RevenueTrendData>(this as RevenueTrendData, _$identity);

  /// Serializes this RevenueTrendData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RevenueTrendData&&(identical(other.date, date) || other.date == date)&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.invoiceCount, invoiceCount) || other.invoiceCount == invoiceCount)&&(identical(other.paidCount, paidCount) || other.paidCount == paidCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,revenue,invoiceCount,paidCount);

@override
String toString() {
  return 'RevenueTrendData(date: $date, revenue: $revenue, invoiceCount: $invoiceCount, paidCount: $paidCount)';
}


}

/// @nodoc
abstract mixin class $RevenueTrendDataCopyWith<$Res>  {
  factory $RevenueTrendDataCopyWith(RevenueTrendData value, $Res Function(RevenueTrendData) _then) = _$RevenueTrendDataCopyWithImpl;
@useResult
$Res call({
 DateTime date, double revenue, int invoiceCount, int paidCount
});




}
/// @nodoc
class _$RevenueTrendDataCopyWithImpl<$Res>
    implements $RevenueTrendDataCopyWith<$Res> {
  _$RevenueTrendDataCopyWithImpl(this._self, this._then);

  final RevenueTrendData _self;
  final $Res Function(RevenueTrendData) _then;

/// Create a copy of RevenueTrendData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? revenue = null,Object? invoiceCount = null,Object? paidCount = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as double,invoiceCount: null == invoiceCount ? _self.invoiceCount : invoiceCount // ignore: cast_nullable_to_non_nullable
as int,paidCount: null == paidCount ? _self.paidCount : paidCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RevenueTrendData].
extension RevenueTrendDataPatterns on RevenueTrendData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RevenueTrendData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RevenueTrendData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RevenueTrendData value)  $default,){
final _that = this;
switch (_that) {
case _RevenueTrendData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RevenueTrendData value)?  $default,){
final _that = this;
switch (_that) {
case _RevenueTrendData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  double revenue,  int invoiceCount,  int paidCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RevenueTrendData() when $default != null:
return $default(_that.date,_that.revenue,_that.invoiceCount,_that.paidCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  double revenue,  int invoiceCount,  int paidCount)  $default,) {final _that = this;
switch (_that) {
case _RevenueTrendData():
return $default(_that.date,_that.revenue,_that.invoiceCount,_that.paidCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  double revenue,  int invoiceCount,  int paidCount)?  $default,) {final _that = this;
switch (_that) {
case _RevenueTrendData() when $default != null:
return $default(_that.date,_that.revenue,_that.invoiceCount,_that.paidCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RevenueTrendData implements RevenueTrendData {
  const _RevenueTrendData({required this.date, required this.revenue, required this.invoiceCount, required this.paidCount});
  factory _RevenueTrendData.fromJson(Map<String, dynamic> json) => _$RevenueTrendDataFromJson(json);

@override final  DateTime date;
@override final  double revenue;
@override final  int invoiceCount;
@override final  int paidCount;

/// Create a copy of RevenueTrendData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RevenueTrendDataCopyWith<_RevenueTrendData> get copyWith => __$RevenueTrendDataCopyWithImpl<_RevenueTrendData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RevenueTrendDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RevenueTrendData&&(identical(other.date, date) || other.date == date)&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.invoiceCount, invoiceCount) || other.invoiceCount == invoiceCount)&&(identical(other.paidCount, paidCount) || other.paidCount == paidCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,revenue,invoiceCount,paidCount);

@override
String toString() {
  return 'RevenueTrendData(date: $date, revenue: $revenue, invoiceCount: $invoiceCount, paidCount: $paidCount)';
}


}

/// @nodoc
abstract mixin class _$RevenueTrendDataCopyWith<$Res> implements $RevenueTrendDataCopyWith<$Res> {
  factory _$RevenueTrendDataCopyWith(_RevenueTrendData value, $Res Function(_RevenueTrendData) _then) = __$RevenueTrendDataCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, double revenue, int invoiceCount, int paidCount
});




}
/// @nodoc
class __$RevenueTrendDataCopyWithImpl<$Res>
    implements _$RevenueTrendDataCopyWith<$Res> {
  __$RevenueTrendDataCopyWithImpl(this._self, this._then);

  final _RevenueTrendData _self;
  final $Res Function(_RevenueTrendData) _then;

/// Create a copy of RevenueTrendData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? revenue = null,Object? invoiceCount = null,Object? paidCount = null,}) {
  return _then(_RevenueTrendData(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as double,invoiceCount: null == invoiceCount ? _self.invoiceCount : invoiceCount // ignore: cast_nullable_to_non_nullable
as int,paidCount: null == paidCount ? _self.paidCount : paidCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$CompanyRevenueSummary {

 String get companyId; String get companyName; String get companyType; double get totalRevenue; double get paidAmount; double get pendingAmount; double get overdueAmount; int get totalInvoices; int get paidInvoices; int get pendingInvoices; int get overdueInvoices; DateTime? get lastPaymentDate; double? get averagePaymentDays; String? get currentPlan; DateTime? get subscriptionStartDate; DateTime? get subscriptionEndDate;
/// Create a copy of CompanyRevenueSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompanyRevenueSummaryCopyWith<CompanyRevenueSummary> get copyWith => _$CompanyRevenueSummaryCopyWithImpl<CompanyRevenueSummary>(this as CompanyRevenueSummary, _$identity);

  /// Serializes this CompanyRevenueSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompanyRevenueSummary&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.companyType, companyType) || other.companyType == companyType)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.paidAmount, paidAmount) || other.paidAmount == paidAmount)&&(identical(other.pendingAmount, pendingAmount) || other.pendingAmount == pendingAmount)&&(identical(other.overdueAmount, overdueAmount) || other.overdueAmount == overdueAmount)&&(identical(other.totalInvoices, totalInvoices) || other.totalInvoices == totalInvoices)&&(identical(other.paidInvoices, paidInvoices) || other.paidInvoices == paidInvoices)&&(identical(other.pendingInvoices, pendingInvoices) || other.pendingInvoices == pendingInvoices)&&(identical(other.overdueInvoices, overdueInvoices) || other.overdueInvoices == overdueInvoices)&&(identical(other.lastPaymentDate, lastPaymentDate) || other.lastPaymentDate == lastPaymentDate)&&(identical(other.averagePaymentDays, averagePaymentDays) || other.averagePaymentDays == averagePaymentDays)&&(identical(other.currentPlan, currentPlan) || other.currentPlan == currentPlan)&&(identical(other.subscriptionStartDate, subscriptionStartDate) || other.subscriptionStartDate == subscriptionStartDate)&&(identical(other.subscriptionEndDate, subscriptionEndDate) || other.subscriptionEndDate == subscriptionEndDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,companyId,companyName,companyType,totalRevenue,paidAmount,pendingAmount,overdueAmount,totalInvoices,paidInvoices,pendingInvoices,overdueInvoices,lastPaymentDate,averagePaymentDays,currentPlan,subscriptionStartDate,subscriptionEndDate);

@override
String toString() {
  return 'CompanyRevenueSummary(companyId: $companyId, companyName: $companyName, companyType: $companyType, totalRevenue: $totalRevenue, paidAmount: $paidAmount, pendingAmount: $pendingAmount, overdueAmount: $overdueAmount, totalInvoices: $totalInvoices, paidInvoices: $paidInvoices, pendingInvoices: $pendingInvoices, overdueInvoices: $overdueInvoices, lastPaymentDate: $lastPaymentDate, averagePaymentDays: $averagePaymentDays, currentPlan: $currentPlan, subscriptionStartDate: $subscriptionStartDate, subscriptionEndDate: $subscriptionEndDate)';
}


}

/// @nodoc
abstract mixin class $CompanyRevenueSummaryCopyWith<$Res>  {
  factory $CompanyRevenueSummaryCopyWith(CompanyRevenueSummary value, $Res Function(CompanyRevenueSummary) _then) = _$CompanyRevenueSummaryCopyWithImpl;
@useResult
$Res call({
 String companyId, String companyName, String companyType, double totalRevenue, double paidAmount, double pendingAmount, double overdueAmount, int totalInvoices, int paidInvoices, int pendingInvoices, int overdueInvoices, DateTime? lastPaymentDate, double? averagePaymentDays, String? currentPlan, DateTime? subscriptionStartDate, DateTime? subscriptionEndDate
});




}
/// @nodoc
class _$CompanyRevenueSummaryCopyWithImpl<$Res>
    implements $CompanyRevenueSummaryCopyWith<$Res> {
  _$CompanyRevenueSummaryCopyWithImpl(this._self, this._then);

  final CompanyRevenueSummary _self;
  final $Res Function(CompanyRevenueSummary) _then;

/// Create a copy of CompanyRevenueSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? companyId = null,Object? companyName = null,Object? companyType = null,Object? totalRevenue = null,Object? paidAmount = null,Object? pendingAmount = null,Object? overdueAmount = null,Object? totalInvoices = null,Object? paidInvoices = null,Object? pendingInvoices = null,Object? overdueInvoices = null,Object? lastPaymentDate = freezed,Object? averagePaymentDays = freezed,Object? currentPlan = freezed,Object? subscriptionStartDate = freezed,Object? subscriptionEndDate = freezed,}) {
  return _then(_self.copyWith(
companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,companyName: null == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String,companyType: null == companyType ? _self.companyType : companyType // ignore: cast_nullable_to_non_nullable
as String,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,paidAmount: null == paidAmount ? _self.paidAmount : paidAmount // ignore: cast_nullable_to_non_nullable
as double,pendingAmount: null == pendingAmount ? _self.pendingAmount : pendingAmount // ignore: cast_nullable_to_non_nullable
as double,overdueAmount: null == overdueAmount ? _self.overdueAmount : overdueAmount // ignore: cast_nullable_to_non_nullable
as double,totalInvoices: null == totalInvoices ? _self.totalInvoices : totalInvoices // ignore: cast_nullable_to_non_nullable
as int,paidInvoices: null == paidInvoices ? _self.paidInvoices : paidInvoices // ignore: cast_nullable_to_non_nullable
as int,pendingInvoices: null == pendingInvoices ? _self.pendingInvoices : pendingInvoices // ignore: cast_nullable_to_non_nullable
as int,overdueInvoices: null == overdueInvoices ? _self.overdueInvoices : overdueInvoices // ignore: cast_nullable_to_non_nullable
as int,lastPaymentDate: freezed == lastPaymentDate ? _self.lastPaymentDate : lastPaymentDate // ignore: cast_nullable_to_non_nullable
as DateTime?,averagePaymentDays: freezed == averagePaymentDays ? _self.averagePaymentDays : averagePaymentDays // ignore: cast_nullable_to_non_nullable
as double?,currentPlan: freezed == currentPlan ? _self.currentPlan : currentPlan // ignore: cast_nullable_to_non_nullable
as String?,subscriptionStartDate: freezed == subscriptionStartDate ? _self.subscriptionStartDate : subscriptionStartDate // ignore: cast_nullable_to_non_nullable
as DateTime?,subscriptionEndDate: freezed == subscriptionEndDate ? _self.subscriptionEndDate : subscriptionEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CompanyRevenueSummary].
extension CompanyRevenueSummaryPatterns on CompanyRevenueSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CompanyRevenueSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompanyRevenueSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CompanyRevenueSummary value)  $default,){
final _that = this;
switch (_that) {
case _CompanyRevenueSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CompanyRevenueSummary value)?  $default,){
final _that = this;
switch (_that) {
case _CompanyRevenueSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String companyId,  String companyName,  String companyType,  double totalRevenue,  double paidAmount,  double pendingAmount,  double overdueAmount,  int totalInvoices,  int paidInvoices,  int pendingInvoices,  int overdueInvoices,  DateTime? lastPaymentDate,  double? averagePaymentDays,  String? currentPlan,  DateTime? subscriptionStartDate,  DateTime? subscriptionEndDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CompanyRevenueSummary() when $default != null:
return $default(_that.companyId,_that.companyName,_that.companyType,_that.totalRevenue,_that.paidAmount,_that.pendingAmount,_that.overdueAmount,_that.totalInvoices,_that.paidInvoices,_that.pendingInvoices,_that.overdueInvoices,_that.lastPaymentDate,_that.averagePaymentDays,_that.currentPlan,_that.subscriptionStartDate,_that.subscriptionEndDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String companyId,  String companyName,  String companyType,  double totalRevenue,  double paidAmount,  double pendingAmount,  double overdueAmount,  int totalInvoices,  int paidInvoices,  int pendingInvoices,  int overdueInvoices,  DateTime? lastPaymentDate,  double? averagePaymentDays,  String? currentPlan,  DateTime? subscriptionStartDate,  DateTime? subscriptionEndDate)  $default,) {final _that = this;
switch (_that) {
case _CompanyRevenueSummary():
return $default(_that.companyId,_that.companyName,_that.companyType,_that.totalRevenue,_that.paidAmount,_that.pendingAmount,_that.overdueAmount,_that.totalInvoices,_that.paidInvoices,_that.pendingInvoices,_that.overdueInvoices,_that.lastPaymentDate,_that.averagePaymentDays,_that.currentPlan,_that.subscriptionStartDate,_that.subscriptionEndDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String companyId,  String companyName,  String companyType,  double totalRevenue,  double paidAmount,  double pendingAmount,  double overdueAmount,  int totalInvoices,  int paidInvoices,  int pendingInvoices,  int overdueInvoices,  DateTime? lastPaymentDate,  double? averagePaymentDays,  String? currentPlan,  DateTime? subscriptionStartDate,  DateTime? subscriptionEndDate)?  $default,) {final _that = this;
switch (_that) {
case _CompanyRevenueSummary() when $default != null:
return $default(_that.companyId,_that.companyName,_that.companyType,_that.totalRevenue,_that.paidAmount,_that.pendingAmount,_that.overdueAmount,_that.totalInvoices,_that.paidInvoices,_that.pendingInvoices,_that.overdueInvoices,_that.lastPaymentDate,_that.averagePaymentDays,_that.currentPlan,_that.subscriptionStartDate,_that.subscriptionEndDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CompanyRevenueSummary implements CompanyRevenueSummary {
  const _CompanyRevenueSummary({required this.companyId, required this.companyName, required this.companyType, required this.totalRevenue, required this.paidAmount, required this.pendingAmount, required this.overdueAmount, required this.totalInvoices, required this.paidInvoices, required this.pendingInvoices, required this.overdueInvoices, this.lastPaymentDate, this.averagePaymentDays, this.currentPlan, this.subscriptionStartDate, this.subscriptionEndDate});
  factory _CompanyRevenueSummary.fromJson(Map<String, dynamic> json) => _$CompanyRevenueSummaryFromJson(json);

@override final  String companyId;
@override final  String companyName;
@override final  String companyType;
@override final  double totalRevenue;
@override final  double paidAmount;
@override final  double pendingAmount;
@override final  double overdueAmount;
@override final  int totalInvoices;
@override final  int paidInvoices;
@override final  int pendingInvoices;
@override final  int overdueInvoices;
@override final  DateTime? lastPaymentDate;
@override final  double? averagePaymentDays;
@override final  String? currentPlan;
@override final  DateTime? subscriptionStartDate;
@override final  DateTime? subscriptionEndDate;

/// Create a copy of CompanyRevenueSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompanyRevenueSummaryCopyWith<_CompanyRevenueSummary> get copyWith => __$CompanyRevenueSummaryCopyWithImpl<_CompanyRevenueSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CompanyRevenueSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompanyRevenueSummary&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.companyType, companyType) || other.companyType == companyType)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.paidAmount, paidAmount) || other.paidAmount == paidAmount)&&(identical(other.pendingAmount, pendingAmount) || other.pendingAmount == pendingAmount)&&(identical(other.overdueAmount, overdueAmount) || other.overdueAmount == overdueAmount)&&(identical(other.totalInvoices, totalInvoices) || other.totalInvoices == totalInvoices)&&(identical(other.paidInvoices, paidInvoices) || other.paidInvoices == paidInvoices)&&(identical(other.pendingInvoices, pendingInvoices) || other.pendingInvoices == pendingInvoices)&&(identical(other.overdueInvoices, overdueInvoices) || other.overdueInvoices == overdueInvoices)&&(identical(other.lastPaymentDate, lastPaymentDate) || other.lastPaymentDate == lastPaymentDate)&&(identical(other.averagePaymentDays, averagePaymentDays) || other.averagePaymentDays == averagePaymentDays)&&(identical(other.currentPlan, currentPlan) || other.currentPlan == currentPlan)&&(identical(other.subscriptionStartDate, subscriptionStartDate) || other.subscriptionStartDate == subscriptionStartDate)&&(identical(other.subscriptionEndDate, subscriptionEndDate) || other.subscriptionEndDate == subscriptionEndDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,companyId,companyName,companyType,totalRevenue,paidAmount,pendingAmount,overdueAmount,totalInvoices,paidInvoices,pendingInvoices,overdueInvoices,lastPaymentDate,averagePaymentDays,currentPlan,subscriptionStartDate,subscriptionEndDate);

@override
String toString() {
  return 'CompanyRevenueSummary(companyId: $companyId, companyName: $companyName, companyType: $companyType, totalRevenue: $totalRevenue, paidAmount: $paidAmount, pendingAmount: $pendingAmount, overdueAmount: $overdueAmount, totalInvoices: $totalInvoices, paidInvoices: $paidInvoices, pendingInvoices: $pendingInvoices, overdueInvoices: $overdueInvoices, lastPaymentDate: $lastPaymentDate, averagePaymentDays: $averagePaymentDays, currentPlan: $currentPlan, subscriptionStartDate: $subscriptionStartDate, subscriptionEndDate: $subscriptionEndDate)';
}


}

/// @nodoc
abstract mixin class _$CompanyRevenueSummaryCopyWith<$Res> implements $CompanyRevenueSummaryCopyWith<$Res> {
  factory _$CompanyRevenueSummaryCopyWith(_CompanyRevenueSummary value, $Res Function(_CompanyRevenueSummary) _then) = __$CompanyRevenueSummaryCopyWithImpl;
@override @useResult
$Res call({
 String companyId, String companyName, String companyType, double totalRevenue, double paidAmount, double pendingAmount, double overdueAmount, int totalInvoices, int paidInvoices, int pendingInvoices, int overdueInvoices, DateTime? lastPaymentDate, double? averagePaymentDays, String? currentPlan, DateTime? subscriptionStartDate, DateTime? subscriptionEndDate
});




}
/// @nodoc
class __$CompanyRevenueSummaryCopyWithImpl<$Res>
    implements _$CompanyRevenueSummaryCopyWith<$Res> {
  __$CompanyRevenueSummaryCopyWithImpl(this._self, this._then);

  final _CompanyRevenueSummary _self;
  final $Res Function(_CompanyRevenueSummary) _then;

/// Create a copy of CompanyRevenueSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? companyId = null,Object? companyName = null,Object? companyType = null,Object? totalRevenue = null,Object? paidAmount = null,Object? pendingAmount = null,Object? overdueAmount = null,Object? totalInvoices = null,Object? paidInvoices = null,Object? pendingInvoices = null,Object? overdueInvoices = null,Object? lastPaymentDate = freezed,Object? averagePaymentDays = freezed,Object? currentPlan = freezed,Object? subscriptionStartDate = freezed,Object? subscriptionEndDate = freezed,}) {
  return _then(_CompanyRevenueSummary(
companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,companyName: null == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String,companyType: null == companyType ? _self.companyType : companyType // ignore: cast_nullable_to_non_nullable
as String,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,paidAmount: null == paidAmount ? _self.paidAmount : paidAmount // ignore: cast_nullable_to_non_nullable
as double,pendingAmount: null == pendingAmount ? _self.pendingAmount : pendingAmount // ignore: cast_nullable_to_non_nullable
as double,overdueAmount: null == overdueAmount ? _self.overdueAmount : overdueAmount // ignore: cast_nullable_to_non_nullable
as double,totalInvoices: null == totalInvoices ? _self.totalInvoices : totalInvoices // ignore: cast_nullable_to_non_nullable
as int,paidInvoices: null == paidInvoices ? _self.paidInvoices : paidInvoices // ignore: cast_nullable_to_non_nullable
as int,pendingInvoices: null == pendingInvoices ? _self.pendingInvoices : pendingInvoices // ignore: cast_nullable_to_non_nullable
as int,overdueInvoices: null == overdueInvoices ? _self.overdueInvoices : overdueInvoices // ignore: cast_nullable_to_non_nullable
as int,lastPaymentDate: freezed == lastPaymentDate ? _self.lastPaymentDate : lastPaymentDate // ignore: cast_nullable_to_non_nullable
as DateTime?,averagePaymentDays: freezed == averagePaymentDays ? _self.averagePaymentDays : averagePaymentDays // ignore: cast_nullable_to_non_nullable
as double?,currentPlan: freezed == currentPlan ? _self.currentPlan : currentPlan // ignore: cast_nullable_to_non_nullable
as String?,subscriptionStartDate: freezed == subscriptionStartDate ? _self.subscriptionStartDate : subscriptionStartDate // ignore: cast_nullable_to_non_nullable
as DateTime?,subscriptionEndDate: freezed == subscriptionEndDate ? _self.subscriptionEndDate : subscriptionEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$PaymentReconciliation {

 String get id; DateTime get reconciliationDate; DateTime get periodStart; DateTime get periodEnd; double get expectedAmount; double get actualAmount; double get discrepancyAmount; int get totalTransactions; int get matchedTransactions; int get unmatchedTransactions; ReconciliationStatus get status; String? get notes; String? get performedByAdminId; String? get performedByAdminName; List<ReconciliationItem>? get items; Map<String, dynamic>? get metadata; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of PaymentReconciliation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentReconciliationCopyWith<PaymentReconciliation> get copyWith => _$PaymentReconciliationCopyWithImpl<PaymentReconciliation>(this as PaymentReconciliation, _$identity);

  /// Serializes this PaymentReconciliation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentReconciliation&&(identical(other.id, id) || other.id == id)&&(identical(other.reconciliationDate, reconciliationDate) || other.reconciliationDate == reconciliationDate)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.expectedAmount, expectedAmount) || other.expectedAmount == expectedAmount)&&(identical(other.actualAmount, actualAmount) || other.actualAmount == actualAmount)&&(identical(other.discrepancyAmount, discrepancyAmount) || other.discrepancyAmount == discrepancyAmount)&&(identical(other.totalTransactions, totalTransactions) || other.totalTransactions == totalTransactions)&&(identical(other.matchedTransactions, matchedTransactions) || other.matchedTransactions == matchedTransactions)&&(identical(other.unmatchedTransactions, unmatchedTransactions) || other.unmatchedTransactions == unmatchedTransactions)&&(identical(other.status, status) || other.status == status)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.performedByAdminId, performedByAdminId) || other.performedByAdminId == performedByAdminId)&&(identical(other.performedByAdminName, performedByAdminName) || other.performedByAdminName == performedByAdminName)&&const DeepCollectionEquality().equals(other.items, items)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reconciliationDate,periodStart,periodEnd,expectedAmount,actualAmount,discrepancyAmount,totalTransactions,matchedTransactions,unmatchedTransactions,status,notes,performedByAdminId,performedByAdminName,const DeepCollectionEquality().hash(items),const DeepCollectionEquality().hash(metadata),createdAt,updatedAt);

@override
String toString() {
  return 'PaymentReconciliation(id: $id, reconciliationDate: $reconciliationDate, periodStart: $periodStart, periodEnd: $periodEnd, expectedAmount: $expectedAmount, actualAmount: $actualAmount, discrepancyAmount: $discrepancyAmount, totalTransactions: $totalTransactions, matchedTransactions: $matchedTransactions, unmatchedTransactions: $unmatchedTransactions, status: $status, notes: $notes, performedByAdminId: $performedByAdminId, performedByAdminName: $performedByAdminName, items: $items, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PaymentReconciliationCopyWith<$Res>  {
  factory $PaymentReconciliationCopyWith(PaymentReconciliation value, $Res Function(PaymentReconciliation) _then) = _$PaymentReconciliationCopyWithImpl;
@useResult
$Res call({
 String id, DateTime reconciliationDate, DateTime periodStart, DateTime periodEnd, double expectedAmount, double actualAmount, double discrepancyAmount, int totalTransactions, int matchedTransactions, int unmatchedTransactions, ReconciliationStatus status, String? notes, String? performedByAdminId, String? performedByAdminName, List<ReconciliationItem>? items, Map<String, dynamic>? metadata, DateTime? createdAt, DateTime? updatedAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reconciliationDate = null,Object? periodStart = null,Object? periodEnd = null,Object? expectedAmount = null,Object? actualAmount = null,Object? discrepancyAmount = null,Object? totalTransactions = null,Object? matchedTransactions = null,Object? unmatchedTransactions = null,Object? status = null,Object? notes = freezed,Object? performedByAdminId = freezed,Object? performedByAdminName = freezed,Object? items = freezed,Object? metadata = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reconciliationDate: null == reconciliationDate ? _self.reconciliationDate : reconciliationDate // ignore: cast_nullable_to_non_nullable
as DateTime,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,expectedAmount: null == expectedAmount ? _self.expectedAmount : expectedAmount // ignore: cast_nullable_to_non_nullable
as double,actualAmount: null == actualAmount ? _self.actualAmount : actualAmount // ignore: cast_nullable_to_non_nullable
as double,discrepancyAmount: null == discrepancyAmount ? _self.discrepancyAmount : discrepancyAmount // ignore: cast_nullable_to_non_nullable
as double,totalTransactions: null == totalTransactions ? _self.totalTransactions : totalTransactions // ignore: cast_nullable_to_non_nullable
as int,matchedTransactions: null == matchedTransactions ? _self.matchedTransactions : matchedTransactions // ignore: cast_nullable_to_non_nullable
as int,unmatchedTransactions: null == unmatchedTransactions ? _self.unmatchedTransactions : unmatchedTransactions // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReconciliationStatus,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,performedByAdminId: freezed == performedByAdminId ? _self.performedByAdminId : performedByAdminId // ignore: cast_nullable_to_non_nullable
as String?,performedByAdminName: freezed == performedByAdminName ? _self.performedByAdminName : performedByAdminName // ignore: cast_nullable_to_non_nullable
as String?,items: freezed == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ReconciliationItem>?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime reconciliationDate,  DateTime periodStart,  DateTime periodEnd,  double expectedAmount,  double actualAmount,  double discrepancyAmount,  int totalTransactions,  int matchedTransactions,  int unmatchedTransactions,  ReconciliationStatus status,  String? notes,  String? performedByAdminId,  String? performedByAdminName,  List<ReconciliationItem>? items,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentReconciliation() when $default != null:
return $default(_that.id,_that.reconciliationDate,_that.periodStart,_that.periodEnd,_that.expectedAmount,_that.actualAmount,_that.discrepancyAmount,_that.totalTransactions,_that.matchedTransactions,_that.unmatchedTransactions,_that.status,_that.notes,_that.performedByAdminId,_that.performedByAdminName,_that.items,_that.metadata,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime reconciliationDate,  DateTime periodStart,  DateTime periodEnd,  double expectedAmount,  double actualAmount,  double discrepancyAmount,  int totalTransactions,  int matchedTransactions,  int unmatchedTransactions,  ReconciliationStatus status,  String? notes,  String? performedByAdminId,  String? performedByAdminName,  List<ReconciliationItem>? items,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PaymentReconciliation():
return $default(_that.id,_that.reconciliationDate,_that.periodStart,_that.periodEnd,_that.expectedAmount,_that.actualAmount,_that.discrepancyAmount,_that.totalTransactions,_that.matchedTransactions,_that.unmatchedTransactions,_that.status,_that.notes,_that.performedByAdminId,_that.performedByAdminName,_that.items,_that.metadata,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime reconciliationDate,  DateTime periodStart,  DateTime periodEnd,  double expectedAmount,  double actualAmount,  double discrepancyAmount,  int totalTransactions,  int matchedTransactions,  int unmatchedTransactions,  ReconciliationStatus status,  String? notes,  String? performedByAdminId,  String? performedByAdminName,  List<ReconciliationItem>? items,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PaymentReconciliation() when $default != null:
return $default(_that.id,_that.reconciliationDate,_that.periodStart,_that.periodEnd,_that.expectedAmount,_that.actualAmount,_that.discrepancyAmount,_that.totalTransactions,_that.matchedTransactions,_that.unmatchedTransactions,_that.status,_that.notes,_that.performedByAdminId,_that.performedByAdminName,_that.items,_that.metadata,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentReconciliation implements PaymentReconciliation {
  const _PaymentReconciliation({required this.id, required this.reconciliationDate, required this.periodStart, required this.periodEnd, required this.expectedAmount, required this.actualAmount, required this.discrepancyAmount, required this.totalTransactions, required this.matchedTransactions, required this.unmatchedTransactions, required this.status, this.notes, this.performedByAdminId, this.performedByAdminName, final  List<ReconciliationItem>? items, final  Map<String, dynamic>? metadata, this.createdAt, this.updatedAt}): _items = items,_metadata = metadata;
  factory _PaymentReconciliation.fromJson(Map<String, dynamic> json) => _$PaymentReconciliationFromJson(json);

@override final  String id;
@override final  DateTime reconciliationDate;
@override final  DateTime periodStart;
@override final  DateTime periodEnd;
@override final  double expectedAmount;
@override final  double actualAmount;
@override final  double discrepancyAmount;
@override final  int totalTransactions;
@override final  int matchedTransactions;
@override final  int unmatchedTransactions;
@override final  ReconciliationStatus status;
@override final  String? notes;
@override final  String? performedByAdminId;
@override final  String? performedByAdminName;
 final  List<ReconciliationItem>? _items;
@override List<ReconciliationItem>? get items {
  final value = _items;
  if (value == null) return null;
  if (_items is EqualUnmodifiableListView) return _items;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentReconciliation&&(identical(other.id, id) || other.id == id)&&(identical(other.reconciliationDate, reconciliationDate) || other.reconciliationDate == reconciliationDate)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.expectedAmount, expectedAmount) || other.expectedAmount == expectedAmount)&&(identical(other.actualAmount, actualAmount) || other.actualAmount == actualAmount)&&(identical(other.discrepancyAmount, discrepancyAmount) || other.discrepancyAmount == discrepancyAmount)&&(identical(other.totalTransactions, totalTransactions) || other.totalTransactions == totalTransactions)&&(identical(other.matchedTransactions, matchedTransactions) || other.matchedTransactions == matchedTransactions)&&(identical(other.unmatchedTransactions, unmatchedTransactions) || other.unmatchedTransactions == unmatchedTransactions)&&(identical(other.status, status) || other.status == status)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.performedByAdminId, performedByAdminId) || other.performedByAdminId == performedByAdminId)&&(identical(other.performedByAdminName, performedByAdminName) || other.performedByAdminName == performedByAdminName)&&const DeepCollectionEquality().equals(other._items, _items)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reconciliationDate,periodStart,periodEnd,expectedAmount,actualAmount,discrepancyAmount,totalTransactions,matchedTransactions,unmatchedTransactions,status,notes,performedByAdminId,performedByAdminName,const DeepCollectionEquality().hash(_items),const DeepCollectionEquality().hash(_metadata),createdAt,updatedAt);

@override
String toString() {
  return 'PaymentReconciliation(id: $id, reconciliationDate: $reconciliationDate, periodStart: $periodStart, periodEnd: $periodEnd, expectedAmount: $expectedAmount, actualAmount: $actualAmount, discrepancyAmount: $discrepancyAmount, totalTransactions: $totalTransactions, matchedTransactions: $matchedTransactions, unmatchedTransactions: $unmatchedTransactions, status: $status, notes: $notes, performedByAdminId: $performedByAdminId, performedByAdminName: $performedByAdminName, items: $items, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PaymentReconciliationCopyWith<$Res> implements $PaymentReconciliationCopyWith<$Res> {
  factory _$PaymentReconciliationCopyWith(_PaymentReconciliation value, $Res Function(_PaymentReconciliation) _then) = __$PaymentReconciliationCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime reconciliationDate, DateTime periodStart, DateTime periodEnd, double expectedAmount, double actualAmount, double discrepancyAmount, int totalTransactions, int matchedTransactions, int unmatchedTransactions, ReconciliationStatus status, String? notes, String? performedByAdminId, String? performedByAdminName, List<ReconciliationItem>? items, Map<String, dynamic>? metadata, DateTime? createdAt, DateTime? updatedAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reconciliationDate = null,Object? periodStart = null,Object? periodEnd = null,Object? expectedAmount = null,Object? actualAmount = null,Object? discrepancyAmount = null,Object? totalTransactions = null,Object? matchedTransactions = null,Object? unmatchedTransactions = null,Object? status = null,Object? notes = freezed,Object? performedByAdminId = freezed,Object? performedByAdminName = freezed,Object? items = freezed,Object? metadata = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_PaymentReconciliation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reconciliationDate: null == reconciliationDate ? _self.reconciliationDate : reconciliationDate // ignore: cast_nullable_to_non_nullable
as DateTime,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,expectedAmount: null == expectedAmount ? _self.expectedAmount : expectedAmount // ignore: cast_nullable_to_non_nullable
as double,actualAmount: null == actualAmount ? _self.actualAmount : actualAmount // ignore: cast_nullable_to_non_nullable
as double,discrepancyAmount: null == discrepancyAmount ? _self.discrepancyAmount : discrepancyAmount // ignore: cast_nullable_to_non_nullable
as double,totalTransactions: null == totalTransactions ? _self.totalTransactions : totalTransactions // ignore: cast_nullable_to_non_nullable
as int,matchedTransactions: null == matchedTransactions ? _self.matchedTransactions : matchedTransactions // ignore: cast_nullable_to_non_nullable
as int,unmatchedTransactions: null == unmatchedTransactions ? _self.unmatchedTransactions : unmatchedTransactions // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReconciliationStatus,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,performedByAdminId: freezed == performedByAdminId ? _self.performedByAdminId : performedByAdminId // ignore: cast_nullable_to_non_nullable
as String?,performedByAdminName: freezed == performedByAdminName ? _self.performedByAdminName : performedByAdminName // ignore: cast_nullable_to_non_nullable
as String?,items: freezed == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ReconciliationItem>?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ReconciliationItem {

 String get id; String get transactionId; String get invoiceId; String get invoiceNumber; double get expectedAmount; double get actualAmount; double get discrepancy; ReconciliationItemStatus get status; String? get notes; DateTime? get matchedAt; String? get matchedByAdminId; Map<String, dynamic>? get metadata;
/// Create a copy of ReconciliationItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReconciliationItemCopyWith<ReconciliationItem> get copyWith => _$ReconciliationItemCopyWithImpl<ReconciliationItem>(this as ReconciliationItem, _$identity);

  /// Serializes this ReconciliationItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReconciliationItem&&(identical(other.id, id) || other.id == id)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.invoiceNumber, invoiceNumber) || other.invoiceNumber == invoiceNumber)&&(identical(other.expectedAmount, expectedAmount) || other.expectedAmount == expectedAmount)&&(identical(other.actualAmount, actualAmount) || other.actualAmount == actualAmount)&&(identical(other.discrepancy, discrepancy) || other.discrepancy == discrepancy)&&(identical(other.status, status) || other.status == status)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.matchedAt, matchedAt) || other.matchedAt == matchedAt)&&(identical(other.matchedByAdminId, matchedByAdminId) || other.matchedByAdminId == matchedByAdminId)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,transactionId,invoiceId,invoiceNumber,expectedAmount,actualAmount,discrepancy,status,notes,matchedAt,matchedByAdminId,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'ReconciliationItem(id: $id, transactionId: $transactionId, invoiceId: $invoiceId, invoiceNumber: $invoiceNumber, expectedAmount: $expectedAmount, actualAmount: $actualAmount, discrepancy: $discrepancy, status: $status, notes: $notes, matchedAt: $matchedAt, matchedByAdminId: $matchedByAdminId, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $ReconciliationItemCopyWith<$Res>  {
  factory $ReconciliationItemCopyWith(ReconciliationItem value, $Res Function(ReconciliationItem) _then) = _$ReconciliationItemCopyWithImpl;
@useResult
$Res call({
 String id, String transactionId, String invoiceId, String invoiceNumber, double expectedAmount, double actualAmount, double discrepancy, ReconciliationItemStatus status, String? notes, DateTime? matchedAt, String? matchedByAdminId, Map<String, dynamic>? metadata
});




}
/// @nodoc
class _$ReconciliationItemCopyWithImpl<$Res>
    implements $ReconciliationItemCopyWith<$Res> {
  _$ReconciliationItemCopyWithImpl(this._self, this._then);

  final ReconciliationItem _self;
  final $Res Function(ReconciliationItem) _then;

/// Create a copy of ReconciliationItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? transactionId = null,Object? invoiceId = null,Object? invoiceNumber = null,Object? expectedAmount = null,Object? actualAmount = null,Object? discrepancy = null,Object? status = null,Object? notes = freezed,Object? matchedAt = freezed,Object? matchedByAdminId = freezed,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,transactionId: null == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String,invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,invoiceNumber: null == invoiceNumber ? _self.invoiceNumber : invoiceNumber // ignore: cast_nullable_to_non_nullable
as String,expectedAmount: null == expectedAmount ? _self.expectedAmount : expectedAmount // ignore: cast_nullable_to_non_nullable
as double,actualAmount: null == actualAmount ? _self.actualAmount : actualAmount // ignore: cast_nullable_to_non_nullable
as double,discrepancy: null == discrepancy ? _self.discrepancy : discrepancy // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReconciliationItemStatus,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,matchedAt: freezed == matchedAt ? _self.matchedAt : matchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,matchedByAdminId: freezed == matchedByAdminId ? _self.matchedByAdminId : matchedByAdminId // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReconciliationItem].
extension ReconciliationItemPatterns on ReconciliationItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReconciliationItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReconciliationItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReconciliationItem value)  $default,){
final _that = this;
switch (_that) {
case _ReconciliationItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReconciliationItem value)?  $default,){
final _that = this;
switch (_that) {
case _ReconciliationItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String transactionId,  String invoiceId,  String invoiceNumber,  double expectedAmount,  double actualAmount,  double discrepancy,  ReconciliationItemStatus status,  String? notes,  DateTime? matchedAt,  String? matchedByAdminId,  Map<String, dynamic>? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReconciliationItem() when $default != null:
return $default(_that.id,_that.transactionId,_that.invoiceId,_that.invoiceNumber,_that.expectedAmount,_that.actualAmount,_that.discrepancy,_that.status,_that.notes,_that.matchedAt,_that.matchedByAdminId,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String transactionId,  String invoiceId,  String invoiceNumber,  double expectedAmount,  double actualAmount,  double discrepancy,  ReconciliationItemStatus status,  String? notes,  DateTime? matchedAt,  String? matchedByAdminId,  Map<String, dynamic>? metadata)  $default,) {final _that = this;
switch (_that) {
case _ReconciliationItem():
return $default(_that.id,_that.transactionId,_that.invoiceId,_that.invoiceNumber,_that.expectedAmount,_that.actualAmount,_that.discrepancy,_that.status,_that.notes,_that.matchedAt,_that.matchedByAdminId,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String transactionId,  String invoiceId,  String invoiceNumber,  double expectedAmount,  double actualAmount,  double discrepancy,  ReconciliationItemStatus status,  String? notes,  DateTime? matchedAt,  String? matchedByAdminId,  Map<String, dynamic>? metadata)?  $default,) {final _that = this;
switch (_that) {
case _ReconciliationItem() when $default != null:
return $default(_that.id,_that.transactionId,_that.invoiceId,_that.invoiceNumber,_that.expectedAmount,_that.actualAmount,_that.discrepancy,_that.status,_that.notes,_that.matchedAt,_that.matchedByAdminId,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReconciliationItem implements ReconciliationItem {
  const _ReconciliationItem({required this.id, required this.transactionId, required this.invoiceId, required this.invoiceNumber, required this.expectedAmount, required this.actualAmount, required this.discrepancy, required this.status, this.notes, this.matchedAt, this.matchedByAdminId, final  Map<String, dynamic>? metadata}): _metadata = metadata;
  factory _ReconciliationItem.fromJson(Map<String, dynamic> json) => _$ReconciliationItemFromJson(json);

@override final  String id;
@override final  String transactionId;
@override final  String invoiceId;
@override final  String invoiceNumber;
@override final  double expectedAmount;
@override final  double actualAmount;
@override final  double discrepancy;
@override final  ReconciliationItemStatus status;
@override final  String? notes;
@override final  DateTime? matchedAt;
@override final  String? matchedByAdminId;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of ReconciliationItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReconciliationItemCopyWith<_ReconciliationItem> get copyWith => __$ReconciliationItemCopyWithImpl<_ReconciliationItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReconciliationItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReconciliationItem&&(identical(other.id, id) || other.id == id)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.invoiceNumber, invoiceNumber) || other.invoiceNumber == invoiceNumber)&&(identical(other.expectedAmount, expectedAmount) || other.expectedAmount == expectedAmount)&&(identical(other.actualAmount, actualAmount) || other.actualAmount == actualAmount)&&(identical(other.discrepancy, discrepancy) || other.discrepancy == discrepancy)&&(identical(other.status, status) || other.status == status)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.matchedAt, matchedAt) || other.matchedAt == matchedAt)&&(identical(other.matchedByAdminId, matchedByAdminId) || other.matchedByAdminId == matchedByAdminId)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,transactionId,invoiceId,invoiceNumber,expectedAmount,actualAmount,discrepancy,status,notes,matchedAt,matchedByAdminId,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'ReconciliationItem(id: $id, transactionId: $transactionId, invoiceId: $invoiceId, invoiceNumber: $invoiceNumber, expectedAmount: $expectedAmount, actualAmount: $actualAmount, discrepancy: $discrepancy, status: $status, notes: $notes, matchedAt: $matchedAt, matchedByAdminId: $matchedByAdminId, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$ReconciliationItemCopyWith<$Res> implements $ReconciliationItemCopyWith<$Res> {
  factory _$ReconciliationItemCopyWith(_ReconciliationItem value, $Res Function(_ReconciliationItem) _then) = __$ReconciliationItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String transactionId, String invoiceId, String invoiceNumber, double expectedAmount, double actualAmount, double discrepancy, ReconciliationItemStatus status, String? notes, DateTime? matchedAt, String? matchedByAdminId, Map<String, dynamic>? metadata
});




}
/// @nodoc
class __$ReconciliationItemCopyWithImpl<$Res>
    implements _$ReconciliationItemCopyWith<$Res> {
  __$ReconciliationItemCopyWithImpl(this._self, this._then);

  final _ReconciliationItem _self;
  final $Res Function(_ReconciliationItem) _then;

/// Create a copy of ReconciliationItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? transactionId = null,Object? invoiceId = null,Object? invoiceNumber = null,Object? expectedAmount = null,Object? actualAmount = null,Object? discrepancy = null,Object? status = null,Object? notes = freezed,Object? matchedAt = freezed,Object? matchedByAdminId = freezed,Object? metadata = freezed,}) {
  return _then(_ReconciliationItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,transactionId: null == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String,invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,invoiceNumber: null == invoiceNumber ? _self.invoiceNumber : invoiceNumber // ignore: cast_nullable_to_non_nullable
as String,expectedAmount: null == expectedAmount ? _self.expectedAmount : expectedAmount // ignore: cast_nullable_to_non_nullable
as double,actualAmount: null == actualAmount ? _self.actualAmount : actualAmount // ignore: cast_nullable_to_non_nullable
as double,discrepancy: null == discrepancy ? _self.discrepancy : discrepancy // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReconciliationItemStatus,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,matchedAt: freezed == matchedAt ? _self.matchedAt : matchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,matchedByAdminId: freezed == matchedByAdminId ? _self.matchedByAdminId : matchedByAdminId // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on

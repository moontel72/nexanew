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
mixin _$InvoiceItem {

 String get id; String get description; double get quantity; double get unitPrice; double get total; String get currency; String? get codeType; int? get codeCount; DateTime? get periodStart; DateTime? get periodEnd; Map<String, dynamic>? get metadata;
/// Create a copy of InvoiceItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvoiceItemCopyWith<InvoiceItem> get copyWith => _$InvoiceItemCopyWithImpl<InvoiceItem>(this as InvoiceItem, _$identity);

  /// Serializes this InvoiceItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvoiceItem&&(identical(other.id, id) || other.id == id)&&(identical(other.description, description) || other.description == description)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.total, total) || other.total == total)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.codeType, codeType) || other.codeType == codeType)&&(identical(other.codeCount, codeCount) || other.codeCount == codeCount)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,description,quantity,unitPrice,total,currency,codeType,codeCount,periodStart,periodEnd,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'InvoiceItem(id: $id, description: $description, quantity: $quantity, unitPrice: $unitPrice, total: $total, currency: $currency, codeType: $codeType, codeCount: $codeCount, periodStart: $periodStart, periodEnd: $periodEnd, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $InvoiceItemCopyWith<$Res>  {
  factory $InvoiceItemCopyWith(InvoiceItem value, $Res Function(InvoiceItem) _then) = _$InvoiceItemCopyWithImpl;
@useResult
$Res call({
 String id, String description, double quantity, double unitPrice, double total, String currency, String? codeType, int? codeCount, DateTime? periodStart, DateTime? periodEnd, Map<String, dynamic>? metadata
});




}
/// @nodoc
class _$InvoiceItemCopyWithImpl<$Res>
    implements $InvoiceItemCopyWith<$Res> {
  _$InvoiceItemCopyWithImpl(this._self, this._then);

  final InvoiceItem _self;
  final $Res Function(InvoiceItem) _then;

/// Create a copy of InvoiceItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? description = null,Object? quantity = null,Object? unitPrice = null,Object? total = null,Object? currency = null,Object? codeType = freezed,Object? codeCount = freezed,Object? periodStart = freezed,Object? periodEnd = freezed,Object? metadata = freezed,}) {
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
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [InvoiceItem].
extension InvoiceItemPatterns on InvoiceItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InvoiceItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InvoiceItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InvoiceItem value)  $default,){
final _that = this;
switch (_that) {
case _InvoiceItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InvoiceItem value)?  $default,){
final _that = this;
switch (_that) {
case _InvoiceItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String description,  double quantity,  double unitPrice,  double total,  String currency,  String? codeType,  int? codeCount,  DateTime? periodStart,  DateTime? periodEnd,  Map<String, dynamic>? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InvoiceItem() when $default != null:
return $default(_that.id,_that.description,_that.quantity,_that.unitPrice,_that.total,_that.currency,_that.codeType,_that.codeCount,_that.periodStart,_that.periodEnd,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String description,  double quantity,  double unitPrice,  double total,  String currency,  String? codeType,  int? codeCount,  DateTime? periodStart,  DateTime? periodEnd,  Map<String, dynamic>? metadata)  $default,) {final _that = this;
switch (_that) {
case _InvoiceItem():
return $default(_that.id,_that.description,_that.quantity,_that.unitPrice,_that.total,_that.currency,_that.codeType,_that.codeCount,_that.periodStart,_that.periodEnd,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String description,  double quantity,  double unitPrice,  double total,  String currency,  String? codeType,  int? codeCount,  DateTime? periodStart,  DateTime? periodEnd,  Map<String, dynamic>? metadata)?  $default,) {final _that = this;
switch (_that) {
case _InvoiceItem() when $default != null:
return $default(_that.id,_that.description,_that.quantity,_that.unitPrice,_that.total,_that.currency,_that.codeType,_that.codeCount,_that.periodStart,_that.periodEnd,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InvoiceItem implements InvoiceItem {
  const _InvoiceItem({required this.id, required this.description, required this.quantity, required this.unitPrice, required this.total, required this.currency, this.codeType, this.codeCount, this.periodStart, this.periodEnd, final  Map<String, dynamic>? metadata}): _metadata = metadata;
  factory _InvoiceItem.fromJson(Map<String, dynamic> json) => _$InvoiceItemFromJson(json);

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


/// Create a copy of InvoiceItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvoiceItemCopyWith<_InvoiceItem> get copyWith => __$InvoiceItemCopyWithImpl<_InvoiceItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvoiceItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvoiceItem&&(identical(other.id, id) || other.id == id)&&(identical(other.description, description) || other.description == description)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.total, total) || other.total == total)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.codeType, codeType) || other.codeType == codeType)&&(identical(other.codeCount, codeCount) || other.codeCount == codeCount)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,description,quantity,unitPrice,total,currency,codeType,codeCount,periodStart,periodEnd,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'InvoiceItem(id: $id, description: $description, quantity: $quantity, unitPrice: $unitPrice, total: $total, currency: $currency, codeType: $codeType, codeCount: $codeCount, periodStart: $periodStart, periodEnd: $periodEnd, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$InvoiceItemCopyWith<$Res> implements $InvoiceItemCopyWith<$Res> {
  factory _$InvoiceItemCopyWith(_InvoiceItem value, $Res Function(_InvoiceItem) _then) = __$InvoiceItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String description, double quantity, double unitPrice, double total, String currency, String? codeType, int? codeCount, DateTime? periodStart, DateTime? periodEnd, Map<String, dynamic>? metadata
});




}
/// @nodoc
class __$InvoiceItemCopyWithImpl<$Res>
    implements _$InvoiceItemCopyWith<$Res> {
  __$InvoiceItemCopyWithImpl(this._self, this._then);

  final _InvoiceItem _self;
  final $Res Function(_InvoiceItem) _then;

/// Create a copy of InvoiceItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? description = null,Object? quantity = null,Object? unitPrice = null,Object? total = null,Object? currency = null,Object? codeType = freezed,Object? codeCount = freezed,Object? periodStart = freezed,Object? periodEnd = freezed,Object? metadata = freezed,}) {
  return _then(_InvoiceItem(
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
as Map<String, dynamic>?,
  ));
}


}


/// @nodoc
mixin _$Invoice {

 String get id; String get invoiceNumber; String get companyId; String? get subscriptionId; DateTime get periodStart; DateTime get periodEnd; DateTime get issueDate; DateTime get dueDate; double get subtotal; double get taxAmount; double get discountAmount; double get totalAmount; String get currency; List<InvoiceItem> get items; InvoiceStatus get status; DateTime? get paymentDate; PaymentMethod? get paymentMethod; String? get paymentReference; String? get notes; Map<String, dynamic>? get metadata; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvoiceCopyWith<Invoice> get copyWith => _$InvoiceCopyWithImpl<Invoice>(this as Invoice, _$identity);

  /// Serializes this Invoice to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Invoice&&(identical(other.id, id) || other.id == id)&&(identical(other.invoiceNumber, invoiceNumber) || other.invoiceNumber == invoiceNumber)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.subscriptionId, subscriptionId) || other.subscriptionId == subscriptionId)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.issueDate, issueDate) || other.issueDate == issueDate)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.taxAmount, taxAmount) || other.taxAmount == taxAmount)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.currency, currency) || other.currency == currency)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentDate, paymentDate) || other.paymentDate == paymentDate)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.paymentReference, paymentReference) || other.paymentReference == paymentReference)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,invoiceNumber,companyId,subscriptionId,periodStart,periodEnd,issueDate,dueDate,subtotal,taxAmount,discountAmount,totalAmount,currency,const DeepCollectionEquality().hash(items),status,paymentDate,paymentMethod,paymentReference,notes,const DeepCollectionEquality().hash(metadata),createdAt,updatedAt]);

@override
String toString() {
  return 'Invoice(id: $id, invoiceNumber: $invoiceNumber, companyId: $companyId, subscriptionId: $subscriptionId, periodStart: $periodStart, periodEnd: $periodEnd, issueDate: $issueDate, dueDate: $dueDate, subtotal: $subtotal, taxAmount: $taxAmount, discountAmount: $discountAmount, totalAmount: $totalAmount, currency: $currency, items: $items, status: $status, paymentDate: $paymentDate, paymentMethod: $paymentMethod, paymentReference: $paymentReference, notes: $notes, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $InvoiceCopyWith<$Res>  {
  factory $InvoiceCopyWith(Invoice value, $Res Function(Invoice) _then) = _$InvoiceCopyWithImpl;
@useResult
$Res call({
 String id, String invoiceNumber, String companyId, String? subscriptionId, DateTime periodStart, DateTime periodEnd, DateTime issueDate, DateTime dueDate, double subtotal, double taxAmount, double discountAmount, double totalAmount, String currency, List<InvoiceItem> items, InvoiceStatus status, DateTime? paymentDate, PaymentMethod? paymentMethod, String? paymentReference, String? notes, Map<String, dynamic>? metadata, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$InvoiceCopyWithImpl<$Res>
    implements $InvoiceCopyWith<$Res> {
  _$InvoiceCopyWithImpl(this._self, this._then);

  final Invoice _self;
  final $Res Function(Invoice) _then;

/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? invoiceNumber = null,Object? companyId = null,Object? subscriptionId = freezed,Object? periodStart = null,Object? periodEnd = null,Object? issueDate = null,Object? dueDate = null,Object? subtotal = null,Object? taxAmount = null,Object? discountAmount = null,Object? totalAmount = null,Object? currency = null,Object? items = null,Object? status = null,Object? paymentDate = freezed,Object? paymentMethod = freezed,Object? paymentReference = freezed,Object? notes = freezed,Object? metadata = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,invoiceNumber: null == invoiceNumber ? _self.invoiceNumber : invoiceNumber // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,subscriptionId: freezed == subscriptionId ? _self.subscriptionId : subscriptionId // ignore: cast_nullable_to_non_nullable
as String?,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,issueDate: null == issueDate ? _self.issueDate : issueDate // ignore: cast_nullable_to_non_nullable
as DateTime,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,taxAmount: null == taxAmount ? _self.taxAmount : taxAmount // ignore: cast_nullable_to_non_nullable
as double,discountAmount: null == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as double,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<InvoiceItem>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InvoiceStatus,paymentDate: freezed == paymentDate ? _self.paymentDate : paymentDate // ignore: cast_nullable_to_non_nullable
as DateTime?,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod?,paymentReference: freezed == paymentReference ? _self.paymentReference : paymentReference // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Invoice].
extension InvoicePatterns on Invoice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Invoice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Invoice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Invoice value)  $default,){
final _that = this;
switch (_that) {
case _Invoice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Invoice value)?  $default,){
final _that = this;
switch (_that) {
case _Invoice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String invoiceNumber,  String companyId,  String? subscriptionId,  DateTime periodStart,  DateTime periodEnd,  DateTime issueDate,  DateTime dueDate,  double subtotal,  double taxAmount,  double discountAmount,  double totalAmount,  String currency,  List<InvoiceItem> items,  InvoiceStatus status,  DateTime? paymentDate,  PaymentMethod? paymentMethod,  String? paymentReference,  String? notes,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Invoice() when $default != null:
return $default(_that.id,_that.invoiceNumber,_that.companyId,_that.subscriptionId,_that.periodStart,_that.periodEnd,_that.issueDate,_that.dueDate,_that.subtotal,_that.taxAmount,_that.discountAmount,_that.totalAmount,_that.currency,_that.items,_that.status,_that.paymentDate,_that.paymentMethod,_that.paymentReference,_that.notes,_that.metadata,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String invoiceNumber,  String companyId,  String? subscriptionId,  DateTime periodStart,  DateTime periodEnd,  DateTime issueDate,  DateTime dueDate,  double subtotal,  double taxAmount,  double discountAmount,  double totalAmount,  String currency,  List<InvoiceItem> items,  InvoiceStatus status,  DateTime? paymentDate,  PaymentMethod? paymentMethod,  String? paymentReference,  String? notes,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Invoice():
return $default(_that.id,_that.invoiceNumber,_that.companyId,_that.subscriptionId,_that.periodStart,_that.periodEnd,_that.issueDate,_that.dueDate,_that.subtotal,_that.taxAmount,_that.discountAmount,_that.totalAmount,_that.currency,_that.items,_that.status,_that.paymentDate,_that.paymentMethod,_that.paymentReference,_that.notes,_that.metadata,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String invoiceNumber,  String companyId,  String? subscriptionId,  DateTime periodStart,  DateTime periodEnd,  DateTime issueDate,  DateTime dueDate,  double subtotal,  double taxAmount,  double discountAmount,  double totalAmount,  String currency,  List<InvoiceItem> items,  InvoiceStatus status,  DateTime? paymentDate,  PaymentMethod? paymentMethod,  String? paymentReference,  String? notes,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Invoice() when $default != null:
return $default(_that.id,_that.invoiceNumber,_that.companyId,_that.subscriptionId,_that.periodStart,_that.periodEnd,_that.issueDate,_that.dueDate,_that.subtotal,_that.taxAmount,_that.discountAmount,_that.totalAmount,_that.currency,_that.items,_that.status,_that.paymentDate,_that.paymentMethod,_that.paymentReference,_that.notes,_that.metadata,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Invoice implements Invoice {
  const _Invoice({required this.id, required this.invoiceNumber, required this.companyId, this.subscriptionId, required this.periodStart, required this.periodEnd, required this.issueDate, required this.dueDate, required this.subtotal, required this.taxAmount, required this.discountAmount, required this.totalAmount, this.currency = 'USD', required final  List<InvoiceItem> items, this.status = InvoiceStatus.pending, this.paymentDate, this.paymentMethod, this.paymentReference, this.notes, final  Map<String, dynamic>? metadata, this.createdAt, this.updatedAt}): _items = items,_metadata = metadata;
  factory _Invoice.fromJson(Map<String, dynamic> json) => _$InvoiceFromJson(json);

@override final  String id;
@override final  String invoiceNumber;
@override final  String companyId;
@override final  String? subscriptionId;
@override final  DateTime periodStart;
@override final  DateTime periodEnd;
@override final  DateTime issueDate;
@override final  DateTime dueDate;
@override final  double subtotal;
@override final  double taxAmount;
@override final  double discountAmount;
@override final  double totalAmount;
@override@JsonKey() final  String currency;
 final  List<InvoiceItem> _items;
@override List<InvoiceItem> get items {
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

/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvoiceCopyWith<_Invoice> get copyWith => __$InvoiceCopyWithImpl<_Invoice>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvoiceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Invoice&&(identical(other.id, id) || other.id == id)&&(identical(other.invoiceNumber, invoiceNumber) || other.invoiceNumber == invoiceNumber)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.subscriptionId, subscriptionId) || other.subscriptionId == subscriptionId)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.issueDate, issueDate) || other.issueDate == issueDate)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.taxAmount, taxAmount) || other.taxAmount == taxAmount)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.currency, currency) || other.currency == currency)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentDate, paymentDate) || other.paymentDate == paymentDate)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.paymentReference, paymentReference) || other.paymentReference == paymentReference)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,invoiceNumber,companyId,subscriptionId,periodStart,periodEnd,issueDate,dueDate,subtotal,taxAmount,discountAmount,totalAmount,currency,const DeepCollectionEquality().hash(_items),status,paymentDate,paymentMethod,paymentReference,notes,const DeepCollectionEquality().hash(_metadata),createdAt,updatedAt]);

@override
String toString() {
  return 'Invoice(id: $id, invoiceNumber: $invoiceNumber, companyId: $companyId, subscriptionId: $subscriptionId, periodStart: $periodStart, periodEnd: $periodEnd, issueDate: $issueDate, dueDate: $dueDate, subtotal: $subtotal, taxAmount: $taxAmount, discountAmount: $discountAmount, totalAmount: $totalAmount, currency: $currency, items: $items, status: $status, paymentDate: $paymentDate, paymentMethod: $paymentMethod, paymentReference: $paymentReference, notes: $notes, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$InvoiceCopyWith<$Res> implements $InvoiceCopyWith<$Res> {
  factory _$InvoiceCopyWith(_Invoice value, $Res Function(_Invoice) _then) = __$InvoiceCopyWithImpl;
@override @useResult
$Res call({
 String id, String invoiceNumber, String companyId, String? subscriptionId, DateTime periodStart, DateTime periodEnd, DateTime issueDate, DateTime dueDate, double subtotal, double taxAmount, double discountAmount, double totalAmount, String currency, List<InvoiceItem> items, InvoiceStatus status, DateTime? paymentDate, PaymentMethod? paymentMethod, String? paymentReference, String? notes, Map<String, dynamic>? metadata, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$InvoiceCopyWithImpl<$Res>
    implements _$InvoiceCopyWith<$Res> {
  __$InvoiceCopyWithImpl(this._self, this._then);

  final _Invoice _self;
  final $Res Function(_Invoice) _then;

/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? invoiceNumber = null,Object? companyId = null,Object? subscriptionId = freezed,Object? periodStart = null,Object? periodEnd = null,Object? issueDate = null,Object? dueDate = null,Object? subtotal = null,Object? taxAmount = null,Object? discountAmount = null,Object? totalAmount = null,Object? currency = null,Object? items = null,Object? status = null,Object? paymentDate = freezed,Object? paymentMethod = freezed,Object? paymentReference = freezed,Object? notes = freezed,Object? metadata = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Invoice(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,invoiceNumber: null == invoiceNumber ? _self.invoiceNumber : invoiceNumber // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,subscriptionId: freezed == subscriptionId ? _self.subscriptionId : subscriptionId // ignore: cast_nullable_to_non_nullable
as String?,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,issueDate: null == issueDate ? _self.issueDate : issueDate // ignore: cast_nullable_to_non_nullable
as DateTime,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,taxAmount: null == taxAmount ? _self.taxAmount : taxAmount // ignore: cast_nullable_to_non_nullable
as double,discountAmount: null == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as double,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<InvoiceItem>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InvoiceStatus,paymentDate: freezed == paymentDate ? _self.paymentDate : paymentDate // ignore: cast_nullable_to_non_nullable
as DateTime?,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod?,paymentReference: freezed == paymentReference ? _self.paymentReference : paymentReference // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$BillingSummary {

 double get totalOwed; double get totalPaid; int get pendingInvoices; int get paidInvoices; int get overdueInvoices; DateTime? get nextPaymentDate; double? get nextPaymentAmount; String? get nextPaymentCurrency; Map<String, dynamic>? get usageSummary;
/// Create a copy of BillingSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillingSummaryCopyWith<BillingSummary> get copyWith => _$BillingSummaryCopyWithImpl<BillingSummary>(this as BillingSummary, _$identity);

  /// Serializes this BillingSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillingSummary&&(identical(other.totalOwed, totalOwed) || other.totalOwed == totalOwed)&&(identical(other.totalPaid, totalPaid) || other.totalPaid == totalPaid)&&(identical(other.pendingInvoices, pendingInvoices) || other.pendingInvoices == pendingInvoices)&&(identical(other.paidInvoices, paidInvoices) || other.paidInvoices == paidInvoices)&&(identical(other.overdueInvoices, overdueInvoices) || other.overdueInvoices == overdueInvoices)&&(identical(other.nextPaymentDate, nextPaymentDate) || other.nextPaymentDate == nextPaymentDate)&&(identical(other.nextPaymentAmount, nextPaymentAmount) || other.nextPaymentAmount == nextPaymentAmount)&&(identical(other.nextPaymentCurrency, nextPaymentCurrency) || other.nextPaymentCurrency == nextPaymentCurrency)&&const DeepCollectionEquality().equals(other.usageSummary, usageSummary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalOwed,totalPaid,pendingInvoices,paidInvoices,overdueInvoices,nextPaymentDate,nextPaymentAmount,nextPaymentCurrency,const DeepCollectionEquality().hash(usageSummary));

@override
String toString() {
  return 'BillingSummary(totalOwed: $totalOwed, totalPaid: $totalPaid, pendingInvoices: $pendingInvoices, paidInvoices: $paidInvoices, overdueInvoices: $overdueInvoices, nextPaymentDate: $nextPaymentDate, nextPaymentAmount: $nextPaymentAmount, nextPaymentCurrency: $nextPaymentCurrency, usageSummary: $usageSummary)';
}


}

/// @nodoc
abstract mixin class $BillingSummaryCopyWith<$Res>  {
  factory $BillingSummaryCopyWith(BillingSummary value, $Res Function(BillingSummary) _then) = _$BillingSummaryCopyWithImpl;
@useResult
$Res call({
 double totalOwed, double totalPaid, int pendingInvoices, int paidInvoices, int overdueInvoices, DateTime? nextPaymentDate, double? nextPaymentAmount, String? nextPaymentCurrency, Map<String, dynamic>? usageSummary
});




}
/// @nodoc
class _$BillingSummaryCopyWithImpl<$Res>
    implements $BillingSummaryCopyWith<$Res> {
  _$BillingSummaryCopyWithImpl(this._self, this._then);

  final BillingSummary _self;
  final $Res Function(BillingSummary) _then;

/// Create a copy of BillingSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalOwed = null,Object? totalPaid = null,Object? pendingInvoices = null,Object? paidInvoices = null,Object? overdueInvoices = null,Object? nextPaymentDate = freezed,Object? nextPaymentAmount = freezed,Object? nextPaymentCurrency = freezed,Object? usageSummary = freezed,}) {
  return _then(_self.copyWith(
totalOwed: null == totalOwed ? _self.totalOwed : totalOwed // ignore: cast_nullable_to_non_nullable
as double,totalPaid: null == totalPaid ? _self.totalPaid : totalPaid // ignore: cast_nullable_to_non_nullable
as double,pendingInvoices: null == pendingInvoices ? _self.pendingInvoices : pendingInvoices // ignore: cast_nullable_to_non_nullable
as int,paidInvoices: null == paidInvoices ? _self.paidInvoices : paidInvoices // ignore: cast_nullable_to_non_nullable
as int,overdueInvoices: null == overdueInvoices ? _self.overdueInvoices : overdueInvoices // ignore: cast_nullable_to_non_nullable
as int,nextPaymentDate: freezed == nextPaymentDate ? _self.nextPaymentDate : nextPaymentDate // ignore: cast_nullable_to_non_nullable
as DateTime?,nextPaymentAmount: freezed == nextPaymentAmount ? _self.nextPaymentAmount : nextPaymentAmount // ignore: cast_nullable_to_non_nullable
as double?,nextPaymentCurrency: freezed == nextPaymentCurrency ? _self.nextPaymentCurrency : nextPaymentCurrency // ignore: cast_nullable_to_non_nullable
as String?,usageSummary: freezed == usageSummary ? _self.usageSummary : usageSummary // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [BillingSummary].
extension BillingSummaryPatterns on BillingSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BillingSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BillingSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BillingSummary value)  $default,){
final _that = this;
switch (_that) {
case _BillingSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BillingSummary value)?  $default,){
final _that = this;
switch (_that) {
case _BillingSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double totalOwed,  double totalPaid,  int pendingInvoices,  int paidInvoices,  int overdueInvoices,  DateTime? nextPaymentDate,  double? nextPaymentAmount,  String? nextPaymentCurrency,  Map<String, dynamic>? usageSummary)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BillingSummary() when $default != null:
return $default(_that.totalOwed,_that.totalPaid,_that.pendingInvoices,_that.paidInvoices,_that.overdueInvoices,_that.nextPaymentDate,_that.nextPaymentAmount,_that.nextPaymentCurrency,_that.usageSummary);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double totalOwed,  double totalPaid,  int pendingInvoices,  int paidInvoices,  int overdueInvoices,  DateTime? nextPaymentDate,  double? nextPaymentAmount,  String? nextPaymentCurrency,  Map<String, dynamic>? usageSummary)  $default,) {final _that = this;
switch (_that) {
case _BillingSummary():
return $default(_that.totalOwed,_that.totalPaid,_that.pendingInvoices,_that.paidInvoices,_that.overdueInvoices,_that.nextPaymentDate,_that.nextPaymentAmount,_that.nextPaymentCurrency,_that.usageSummary);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double totalOwed,  double totalPaid,  int pendingInvoices,  int paidInvoices,  int overdueInvoices,  DateTime? nextPaymentDate,  double? nextPaymentAmount,  String? nextPaymentCurrency,  Map<String, dynamic>? usageSummary)?  $default,) {final _that = this;
switch (_that) {
case _BillingSummary() when $default != null:
return $default(_that.totalOwed,_that.totalPaid,_that.pendingInvoices,_that.paidInvoices,_that.overdueInvoices,_that.nextPaymentDate,_that.nextPaymentAmount,_that.nextPaymentCurrency,_that.usageSummary);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BillingSummary implements BillingSummary {
  const _BillingSummary({this.totalOwed = 0.0, this.totalPaid = 0.0, this.pendingInvoices = 0, this.paidInvoices = 0, this.overdueInvoices = 0, this.nextPaymentDate, this.nextPaymentAmount, this.nextPaymentCurrency, final  Map<String, dynamic>? usageSummary}): _usageSummary = usageSummary;
  factory _BillingSummary.fromJson(Map<String, dynamic> json) => _$BillingSummaryFromJson(json);

@override@JsonKey() final  double totalOwed;
@override@JsonKey() final  double totalPaid;
@override@JsonKey() final  int pendingInvoices;
@override@JsonKey() final  int paidInvoices;
@override@JsonKey() final  int overdueInvoices;
@override final  DateTime? nextPaymentDate;
@override final  double? nextPaymentAmount;
@override final  String? nextPaymentCurrency;
 final  Map<String, dynamic>? _usageSummary;
@override Map<String, dynamic>? get usageSummary {
  final value = _usageSummary;
  if (value == null) return null;
  if (_usageSummary is EqualUnmodifiableMapView) return _usageSummary;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of BillingSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BillingSummaryCopyWith<_BillingSummary> get copyWith => __$BillingSummaryCopyWithImpl<_BillingSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BillingSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BillingSummary&&(identical(other.totalOwed, totalOwed) || other.totalOwed == totalOwed)&&(identical(other.totalPaid, totalPaid) || other.totalPaid == totalPaid)&&(identical(other.pendingInvoices, pendingInvoices) || other.pendingInvoices == pendingInvoices)&&(identical(other.paidInvoices, paidInvoices) || other.paidInvoices == paidInvoices)&&(identical(other.overdueInvoices, overdueInvoices) || other.overdueInvoices == overdueInvoices)&&(identical(other.nextPaymentDate, nextPaymentDate) || other.nextPaymentDate == nextPaymentDate)&&(identical(other.nextPaymentAmount, nextPaymentAmount) || other.nextPaymentAmount == nextPaymentAmount)&&(identical(other.nextPaymentCurrency, nextPaymentCurrency) || other.nextPaymentCurrency == nextPaymentCurrency)&&const DeepCollectionEquality().equals(other._usageSummary, _usageSummary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalOwed,totalPaid,pendingInvoices,paidInvoices,overdueInvoices,nextPaymentDate,nextPaymentAmount,nextPaymentCurrency,const DeepCollectionEquality().hash(_usageSummary));

@override
String toString() {
  return 'BillingSummary(totalOwed: $totalOwed, totalPaid: $totalPaid, pendingInvoices: $pendingInvoices, paidInvoices: $paidInvoices, overdueInvoices: $overdueInvoices, nextPaymentDate: $nextPaymentDate, nextPaymentAmount: $nextPaymentAmount, nextPaymentCurrency: $nextPaymentCurrency, usageSummary: $usageSummary)';
}


}

/// @nodoc
abstract mixin class _$BillingSummaryCopyWith<$Res> implements $BillingSummaryCopyWith<$Res> {
  factory _$BillingSummaryCopyWith(_BillingSummary value, $Res Function(_BillingSummary) _then) = __$BillingSummaryCopyWithImpl;
@override @useResult
$Res call({
 double totalOwed, double totalPaid, int pendingInvoices, int paidInvoices, int overdueInvoices, DateTime? nextPaymentDate, double? nextPaymentAmount, String? nextPaymentCurrency, Map<String, dynamic>? usageSummary
});




}
/// @nodoc
class __$BillingSummaryCopyWithImpl<$Res>
    implements _$BillingSummaryCopyWith<$Res> {
  __$BillingSummaryCopyWithImpl(this._self, this._then);

  final _BillingSummary _self;
  final $Res Function(_BillingSummary) _then;

/// Create a copy of BillingSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalOwed = null,Object? totalPaid = null,Object? pendingInvoices = null,Object? paidInvoices = null,Object? overdueInvoices = null,Object? nextPaymentDate = freezed,Object? nextPaymentAmount = freezed,Object? nextPaymentCurrency = freezed,Object? usageSummary = freezed,}) {
  return _then(_BillingSummary(
totalOwed: null == totalOwed ? _self.totalOwed : totalOwed // ignore: cast_nullable_to_non_nullable
as double,totalPaid: null == totalPaid ? _self.totalPaid : totalPaid // ignore: cast_nullable_to_non_nullable
as double,pendingInvoices: null == pendingInvoices ? _self.pendingInvoices : pendingInvoices // ignore: cast_nullable_to_non_nullable
as int,paidInvoices: null == paidInvoices ? _self.paidInvoices : paidInvoices // ignore: cast_nullable_to_non_nullable
as int,overdueInvoices: null == overdueInvoices ? _self.overdueInvoices : overdueInvoices // ignore: cast_nullable_to_non_nullable
as int,nextPaymentDate: freezed == nextPaymentDate ? _self.nextPaymentDate : nextPaymentDate // ignore: cast_nullable_to_non_nullable
as DateTime?,nextPaymentAmount: freezed == nextPaymentAmount ? _self.nextPaymentAmount : nextPaymentAmount // ignore: cast_nullable_to_non_nullable
as double?,nextPaymentCurrency: freezed == nextPaymentCurrency ? _self.nextPaymentCurrency : nextPaymentCurrency // ignore: cast_nullable_to_non_nullable
as String?,usageSummary: freezed == usageSummary ? _self._usageSummary : usageSummary // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}


/// @nodoc
mixin _$Payment {

 String get id; String get invoiceId; double get amount; String get currency; PaymentMethod get method; DateTime get paymentDate; String? get reference; String? get transactionId; String? get notes; Map<String, dynamic>? get metadata; DateTime? get createdAt;
/// Create a copy of Payment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentCopyWith<Payment> get copyWith => _$PaymentCopyWithImpl<Payment>(this as Payment, _$identity);

  /// Serializes this Payment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Payment&&(identical(other.id, id) || other.id == id)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.method, method) || other.method == method)&&(identical(other.paymentDate, paymentDate) || other.paymentDate == paymentDate)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,invoiceId,amount,currency,method,paymentDate,reference,transactionId,notes,const DeepCollectionEquality().hash(metadata),createdAt);

@override
String toString() {
  return 'Payment(id: $id, invoiceId: $invoiceId, amount: $amount, currency: $currency, method: $method, paymentDate: $paymentDate, reference: $reference, transactionId: $transactionId, notes: $notes, metadata: $metadata, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PaymentCopyWith<$Res>  {
  factory $PaymentCopyWith(Payment value, $Res Function(Payment) _then) = _$PaymentCopyWithImpl;
@useResult
$Res call({
 String id, String invoiceId, double amount, String currency, PaymentMethod method, DateTime paymentDate, String? reference, String? transactionId, String? notes, Map<String, dynamic>? metadata, DateTime? createdAt
});




}
/// @nodoc
class _$PaymentCopyWithImpl<$Res>
    implements $PaymentCopyWith<$Res> {
  _$PaymentCopyWithImpl(this._self, this._then);

  final Payment _self;
  final $Res Function(Payment) _then;

/// Create a copy of Payment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? invoiceId = null,Object? amount = null,Object? currency = null,Object? method = null,Object? paymentDate = null,Object? reference = freezed,Object? transactionId = freezed,Object? notes = freezed,Object? metadata = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as PaymentMethod,paymentDate: null == paymentDate ? _self.paymentDate : paymentDate // ignore: cast_nullable_to_non_nullable
as DateTime,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,transactionId: freezed == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Payment].
extension PaymentPatterns on Payment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Payment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Payment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Payment value)  $default,){
final _that = this;
switch (_that) {
case _Payment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Payment value)?  $default,){
final _that = this;
switch (_that) {
case _Payment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String invoiceId,  double amount,  String currency,  PaymentMethod method,  DateTime paymentDate,  String? reference,  String? transactionId,  String? notes,  Map<String, dynamic>? metadata,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Payment() when $default != null:
return $default(_that.id,_that.invoiceId,_that.amount,_that.currency,_that.method,_that.paymentDate,_that.reference,_that.transactionId,_that.notes,_that.metadata,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String invoiceId,  double amount,  String currency,  PaymentMethod method,  DateTime paymentDate,  String? reference,  String? transactionId,  String? notes,  Map<String, dynamic>? metadata,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _Payment():
return $default(_that.id,_that.invoiceId,_that.amount,_that.currency,_that.method,_that.paymentDate,_that.reference,_that.transactionId,_that.notes,_that.metadata,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String invoiceId,  double amount,  String currency,  PaymentMethod method,  DateTime paymentDate,  String? reference,  String? transactionId,  String? notes,  Map<String, dynamic>? metadata,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Payment() when $default != null:
return $default(_that.id,_that.invoiceId,_that.amount,_that.currency,_that.method,_that.paymentDate,_that.reference,_that.transactionId,_that.notes,_that.metadata,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Payment implements Payment {
  const _Payment({required this.id, required this.invoiceId, required this.amount, required this.currency, required this.method, required this.paymentDate, this.reference, this.transactionId, this.notes, final  Map<String, dynamic>? metadata, this.createdAt}): _metadata = metadata;
  factory _Payment.fromJson(Map<String, dynamic> json) => _$PaymentFromJson(json);

@override final  String id;
@override final  String invoiceId;
@override final  double amount;
@override final  String currency;
@override final  PaymentMethod method;
@override final  DateTime paymentDate;
@override final  String? reference;
@override final  String? transactionId;
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

/// Create a copy of Payment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentCopyWith<_Payment> get copyWith => __$PaymentCopyWithImpl<_Payment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Payment&&(identical(other.id, id) || other.id == id)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.method, method) || other.method == method)&&(identical(other.paymentDate, paymentDate) || other.paymentDate == paymentDate)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,invoiceId,amount,currency,method,paymentDate,reference,transactionId,notes,const DeepCollectionEquality().hash(_metadata),createdAt);

@override
String toString() {
  return 'Payment(id: $id, invoiceId: $invoiceId, amount: $amount, currency: $currency, method: $method, paymentDate: $paymentDate, reference: $reference, transactionId: $transactionId, notes: $notes, metadata: $metadata, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PaymentCopyWith<$Res> implements $PaymentCopyWith<$Res> {
  factory _$PaymentCopyWith(_Payment value, $Res Function(_Payment) _then) = __$PaymentCopyWithImpl;
@override @useResult
$Res call({
 String id, String invoiceId, double amount, String currency, PaymentMethod method, DateTime paymentDate, String? reference, String? transactionId, String? notes, Map<String, dynamic>? metadata, DateTime? createdAt
});




}
/// @nodoc
class __$PaymentCopyWithImpl<$Res>
    implements _$PaymentCopyWith<$Res> {
  __$PaymentCopyWithImpl(this._self, this._then);

  final _Payment _self;
  final $Res Function(_Payment) _then;

/// Create a copy of Payment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? invoiceId = null,Object? amount = null,Object? currency = null,Object? method = null,Object? paymentDate = null,Object? reference = freezed,Object? transactionId = freezed,Object? notes = freezed,Object? metadata = freezed,Object? createdAt = freezed,}) {
  return _then(_Payment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as PaymentMethod,paymentDate: null == paymentDate ? _self.paymentDate : paymentDate // ignore: cast_nullable_to_non_nullable
as DateTime,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,transactionId: freezed == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$BillingFilter {

 DateTime? get startDate; DateTime? get endDate; List<InvoiceStatus>? get statuses; double? get minAmount; double? get maxAmount; String? get searchQuery; String get sortBy; bool get sortDesc; int get page; int get limit;
/// Create a copy of BillingFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillingFilterCopyWith<BillingFilter> get copyWith => _$BillingFilterCopyWithImpl<BillingFilter>(this as BillingFilter, _$identity);

  /// Serializes this BillingFilter to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillingFilter&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other.statuses, statuses)&&(identical(other.minAmount, minAmount) || other.minAmount == minAmount)&&(identical(other.maxAmount, maxAmount) || other.maxAmount == maxAmount)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.sortDesc, sortDesc) || other.sortDesc == sortDesc)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startDate,endDate,const DeepCollectionEquality().hash(statuses),minAmount,maxAmount,searchQuery,sortBy,sortDesc,page,limit);

@override
String toString() {
  return 'BillingFilter(startDate: $startDate, endDate: $endDate, statuses: $statuses, minAmount: $minAmount, maxAmount: $maxAmount, searchQuery: $searchQuery, sortBy: $sortBy, sortDesc: $sortDesc, page: $page, limit: $limit)';
}


}

/// @nodoc
abstract mixin class $BillingFilterCopyWith<$Res>  {
  factory $BillingFilterCopyWith(BillingFilter value, $Res Function(BillingFilter) _then) = _$BillingFilterCopyWithImpl;
@useResult
$Res call({
 DateTime? startDate, DateTime? endDate, List<InvoiceStatus>? statuses, double? minAmount, double? maxAmount, String? searchQuery, String sortBy, bool sortDesc, int page, int limit
});




}
/// @nodoc
class _$BillingFilterCopyWithImpl<$Res>
    implements $BillingFilterCopyWith<$Res> {
  _$BillingFilterCopyWithImpl(this._self, this._then);

  final BillingFilter _self;
  final $Res Function(BillingFilter) _then;

/// Create a copy of BillingFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? startDate = freezed,Object? endDate = freezed,Object? statuses = freezed,Object? minAmount = freezed,Object? maxAmount = freezed,Object? searchQuery = freezed,Object? sortBy = null,Object? sortDesc = null,Object? page = null,Object? limit = null,}) {
  return _then(_self.copyWith(
startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,statuses: freezed == statuses ? _self.statuses : statuses // ignore: cast_nullable_to_non_nullable
as List<InvoiceStatus>?,minAmount: freezed == minAmount ? _self.minAmount : minAmount // ignore: cast_nullable_to_non_nullable
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


/// Adds pattern-matching-related methods to [BillingFilter].
extension BillingFilterPatterns on BillingFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BillingFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BillingFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BillingFilter value)  $default,){
final _that = this;
switch (_that) {
case _BillingFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BillingFilter value)?  $default,){
final _that = this;
switch (_that) {
case _BillingFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime? startDate,  DateTime? endDate,  List<InvoiceStatus>? statuses,  double? minAmount,  double? maxAmount,  String? searchQuery,  String sortBy,  bool sortDesc,  int page,  int limit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BillingFilter() when $default != null:
return $default(_that.startDate,_that.endDate,_that.statuses,_that.minAmount,_that.maxAmount,_that.searchQuery,_that.sortBy,_that.sortDesc,_that.page,_that.limit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime? startDate,  DateTime? endDate,  List<InvoiceStatus>? statuses,  double? minAmount,  double? maxAmount,  String? searchQuery,  String sortBy,  bool sortDesc,  int page,  int limit)  $default,) {final _that = this;
switch (_that) {
case _BillingFilter():
return $default(_that.startDate,_that.endDate,_that.statuses,_that.minAmount,_that.maxAmount,_that.searchQuery,_that.sortBy,_that.sortDesc,_that.page,_that.limit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime? startDate,  DateTime? endDate,  List<InvoiceStatus>? statuses,  double? minAmount,  double? maxAmount,  String? searchQuery,  String sortBy,  bool sortDesc,  int page,  int limit)?  $default,) {final _that = this;
switch (_that) {
case _BillingFilter() when $default != null:
return $default(_that.startDate,_that.endDate,_that.statuses,_that.minAmount,_that.maxAmount,_that.searchQuery,_that.sortBy,_that.sortDesc,_that.page,_that.limit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BillingFilter implements BillingFilter {
  const _BillingFilter({this.startDate, this.endDate, final  List<InvoiceStatus>? statuses, this.minAmount, this.maxAmount, this.searchQuery, this.sortBy = 'issueDate', this.sortDesc = false, this.page = 1, this.limit = 20}): _statuses = statuses;
  factory _BillingFilter.fromJson(Map<String, dynamic> json) => _$BillingFilterFromJson(json);

@override final  DateTime? startDate;
@override final  DateTime? endDate;
 final  List<InvoiceStatus>? _statuses;
@override List<InvoiceStatus>? get statuses {
  final value = _statuses;
  if (value == null) return null;
  if (_statuses is EqualUnmodifiableListView) return _statuses;
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

/// Create a copy of BillingFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BillingFilterCopyWith<_BillingFilter> get copyWith => __$BillingFilterCopyWithImpl<_BillingFilter>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BillingFilterToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BillingFilter&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other._statuses, _statuses)&&(identical(other.minAmount, minAmount) || other.minAmount == minAmount)&&(identical(other.maxAmount, maxAmount) || other.maxAmount == maxAmount)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.sortDesc, sortDesc) || other.sortDesc == sortDesc)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startDate,endDate,const DeepCollectionEquality().hash(_statuses),minAmount,maxAmount,searchQuery,sortBy,sortDesc,page,limit);

@override
String toString() {
  return 'BillingFilter(startDate: $startDate, endDate: $endDate, statuses: $statuses, minAmount: $minAmount, maxAmount: $maxAmount, searchQuery: $searchQuery, sortBy: $sortBy, sortDesc: $sortDesc, page: $page, limit: $limit)';
}


}

/// @nodoc
abstract mixin class _$BillingFilterCopyWith<$Res> implements $BillingFilterCopyWith<$Res> {
  factory _$BillingFilterCopyWith(_BillingFilter value, $Res Function(_BillingFilter) _then) = __$BillingFilterCopyWithImpl;
@override @useResult
$Res call({
 DateTime? startDate, DateTime? endDate, List<InvoiceStatus>? statuses, double? minAmount, double? maxAmount, String? searchQuery, String sortBy, bool sortDesc, int page, int limit
});




}
/// @nodoc
class __$BillingFilterCopyWithImpl<$Res>
    implements _$BillingFilterCopyWith<$Res> {
  __$BillingFilterCopyWithImpl(this._self, this._then);

  final _BillingFilter _self;
  final $Res Function(_BillingFilter) _then;

/// Create a copy of BillingFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? startDate = freezed,Object? endDate = freezed,Object? statuses = freezed,Object? minAmount = freezed,Object? maxAmount = freezed,Object? searchQuery = freezed,Object? sortBy = null,Object? sortDesc = null,Object? page = null,Object? limit = null,}) {
  return _then(_BillingFilter(
startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,statuses: freezed == statuses ? _self._statuses : statuses // ignore: cast_nullable_to_non_nullable
as List<InvoiceStatus>?,minAmount: freezed == minAmount ? _self.minAmount : minAmount // ignore: cast_nullable_to_non_nullable
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

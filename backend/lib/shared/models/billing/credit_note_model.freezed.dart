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
mixin _$CreditNoteItem {

 String get id; String get description; double get quantity; double get unitPrice; double get total; String get currency; String? get invoiceItemId; String? get reason; Map<String, dynamic>? get metadata;
/// Create a copy of CreditNoteItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreditNoteItemCopyWith<CreditNoteItem> get copyWith => _$CreditNoteItemCopyWithImpl<CreditNoteItem>(this as CreditNoteItem, _$identity);

  /// Serializes this CreditNoteItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreditNoteItem&&(identical(other.id, id) || other.id == id)&&(identical(other.description, description) || other.description == description)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.total, total) || other.total == total)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.invoiceItemId, invoiceItemId) || other.invoiceItemId == invoiceItemId)&&(identical(other.reason, reason) || other.reason == reason)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,description,quantity,unitPrice,total,currency,invoiceItemId,reason,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'CreditNoteItem(id: $id, description: $description, quantity: $quantity, unitPrice: $unitPrice, total: $total, currency: $currency, invoiceItemId: $invoiceItemId, reason: $reason, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $CreditNoteItemCopyWith<$Res>  {
  factory $CreditNoteItemCopyWith(CreditNoteItem value, $Res Function(CreditNoteItem) _then) = _$CreditNoteItemCopyWithImpl;
@useResult
$Res call({
 String id, String description, double quantity, double unitPrice, double total, String currency, String? invoiceItemId, String? reason, Map<String, dynamic>? metadata
});




}
/// @nodoc
class _$CreditNoteItemCopyWithImpl<$Res>
    implements $CreditNoteItemCopyWith<$Res> {
  _$CreditNoteItemCopyWithImpl(this._self, this._then);

  final CreditNoteItem _self;
  final $Res Function(CreditNoteItem) _then;

/// Create a copy of CreditNoteItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? description = null,Object? quantity = null,Object? unitPrice = null,Object? total = null,Object? currency = null,Object? invoiceItemId = freezed,Object? reason = freezed,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,invoiceItemId: freezed == invoiceItemId ? _self.invoiceItemId : invoiceItemId // ignore: cast_nullable_to_non_nullable
as String?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreditNoteItem].
extension CreditNoteItemPatterns on CreditNoteItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreditNoteItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreditNoteItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreditNoteItem value)  $default,){
final _that = this;
switch (_that) {
case _CreditNoteItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreditNoteItem value)?  $default,){
final _that = this;
switch (_that) {
case _CreditNoteItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String description,  double quantity,  double unitPrice,  double total,  String currency,  String? invoiceItemId,  String? reason,  Map<String, dynamic>? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreditNoteItem() when $default != null:
return $default(_that.id,_that.description,_that.quantity,_that.unitPrice,_that.total,_that.currency,_that.invoiceItemId,_that.reason,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String description,  double quantity,  double unitPrice,  double total,  String currency,  String? invoiceItemId,  String? reason,  Map<String, dynamic>? metadata)  $default,) {final _that = this;
switch (_that) {
case _CreditNoteItem():
return $default(_that.id,_that.description,_that.quantity,_that.unitPrice,_that.total,_that.currency,_that.invoiceItemId,_that.reason,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String description,  double quantity,  double unitPrice,  double total,  String currency,  String? invoiceItemId,  String? reason,  Map<String, dynamic>? metadata)?  $default,) {final _that = this;
switch (_that) {
case _CreditNoteItem() when $default != null:
return $default(_that.id,_that.description,_that.quantity,_that.unitPrice,_that.total,_that.currency,_that.invoiceItemId,_that.reason,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreditNoteItem implements CreditNoteItem {
  const _CreditNoteItem({required this.id, required this.description, required this.quantity, required this.unitPrice, required this.total, required this.currency, this.invoiceItemId, this.reason, final  Map<String, dynamic>? metadata}): _metadata = metadata;
  factory _CreditNoteItem.fromJson(Map<String, dynamic> json) => _$CreditNoteItemFromJson(json);

@override final  String id;
@override final  String description;
@override final  double quantity;
@override final  double unitPrice;
@override final  double total;
@override final  String currency;
@override final  String? invoiceItemId;
@override final  String? reason;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of CreditNoteItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreditNoteItemCopyWith<_CreditNoteItem> get copyWith => __$CreditNoteItemCopyWithImpl<_CreditNoteItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreditNoteItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreditNoteItem&&(identical(other.id, id) || other.id == id)&&(identical(other.description, description) || other.description == description)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.total, total) || other.total == total)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.invoiceItemId, invoiceItemId) || other.invoiceItemId == invoiceItemId)&&(identical(other.reason, reason) || other.reason == reason)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,description,quantity,unitPrice,total,currency,invoiceItemId,reason,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'CreditNoteItem(id: $id, description: $description, quantity: $quantity, unitPrice: $unitPrice, total: $total, currency: $currency, invoiceItemId: $invoiceItemId, reason: $reason, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$CreditNoteItemCopyWith<$Res> implements $CreditNoteItemCopyWith<$Res> {
  factory _$CreditNoteItemCopyWith(_CreditNoteItem value, $Res Function(_CreditNoteItem) _then) = __$CreditNoteItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String description, double quantity, double unitPrice, double total, String currency, String? invoiceItemId, String? reason, Map<String, dynamic>? metadata
});




}
/// @nodoc
class __$CreditNoteItemCopyWithImpl<$Res>
    implements _$CreditNoteItemCopyWith<$Res> {
  __$CreditNoteItemCopyWithImpl(this._self, this._then);

  final _CreditNoteItem _self;
  final $Res Function(_CreditNoteItem) _then;

/// Create a copy of CreditNoteItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? description = null,Object? quantity = null,Object? unitPrice = null,Object? total = null,Object? currency = null,Object? invoiceItemId = freezed,Object? reason = freezed,Object? metadata = freezed,}) {
  return _then(_CreditNoteItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,invoiceItemId: freezed == invoiceItemId ? _self.invoiceItemId : invoiceItemId // ignore: cast_nullable_to_non_nullable
as String?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}


/// @nodoc
mixin _$CreditNote {

 String get id; String get creditNoteNumber; String get companyId; String? get invoiceId; CreditNoteType get type; String get reason; double get totalAmount; String get currency; List<CreditNoteItem> get items; CreditNoteStatus get status; DateTime? get approvalDate; String? get approvedBy; DateTime? get applicationDate; String? get appliedToInvoiceId; DateTime? get expiryDate; String? get notes; Map<String, dynamic>? get metadata; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of CreditNote
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreditNoteCopyWith<CreditNote> get copyWith => _$CreditNoteCopyWithImpl<CreditNote>(this as CreditNote, _$identity);

  /// Serializes this CreditNote to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreditNote&&(identical(other.id, id) || other.id == id)&&(identical(other.creditNoteNumber, creditNoteNumber) || other.creditNoteNumber == creditNoteNumber)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.type, type) || other.type == type)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.currency, currency) || other.currency == currency)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.status, status) || other.status == status)&&(identical(other.approvalDate, approvalDate) || other.approvalDate == approvalDate)&&(identical(other.approvedBy, approvedBy) || other.approvedBy == approvedBy)&&(identical(other.applicationDate, applicationDate) || other.applicationDate == applicationDate)&&(identical(other.appliedToInvoiceId, appliedToInvoiceId) || other.appliedToInvoiceId == appliedToInvoiceId)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,creditNoteNumber,companyId,invoiceId,type,reason,totalAmount,currency,const DeepCollectionEquality().hash(items),status,approvalDate,approvedBy,applicationDate,appliedToInvoiceId,expiryDate,notes,const DeepCollectionEquality().hash(metadata),createdAt,updatedAt]);

@override
String toString() {
  return 'CreditNote(id: $id, creditNoteNumber: $creditNoteNumber, companyId: $companyId, invoiceId: $invoiceId, type: $type, reason: $reason, totalAmount: $totalAmount, currency: $currency, items: $items, status: $status, approvalDate: $approvalDate, approvedBy: $approvedBy, applicationDate: $applicationDate, appliedToInvoiceId: $appliedToInvoiceId, expiryDate: $expiryDate, notes: $notes, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CreditNoteCopyWith<$Res>  {
  factory $CreditNoteCopyWith(CreditNote value, $Res Function(CreditNote) _then) = _$CreditNoteCopyWithImpl;
@useResult
$Res call({
 String id, String creditNoteNumber, String companyId, String? invoiceId, CreditNoteType type, String reason, double totalAmount, String currency, List<CreditNoteItem> items, CreditNoteStatus status, DateTime? approvalDate, String? approvedBy, DateTime? applicationDate, String? appliedToInvoiceId, DateTime? expiryDate, String? notes, Map<String, dynamic>? metadata, DateTime? createdAt, DateTime? updatedAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? creditNoteNumber = null,Object? companyId = null,Object? invoiceId = freezed,Object? type = null,Object? reason = null,Object? totalAmount = null,Object? currency = null,Object? items = null,Object? status = null,Object? approvalDate = freezed,Object? approvedBy = freezed,Object? applicationDate = freezed,Object? appliedToInvoiceId = freezed,Object? expiryDate = freezed,Object? notes = freezed,Object? metadata = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,creditNoteNumber: null == creditNoteNumber ? _self.creditNoteNumber : creditNoteNumber // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,invoiceId: freezed == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CreditNoteType,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<CreditNoteItem>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CreditNoteStatus,approvalDate: freezed == approvalDate ? _self.approvalDate : approvalDate // ignore: cast_nullable_to_non_nullable
as DateTime?,approvedBy: freezed == approvedBy ? _self.approvedBy : approvedBy // ignore: cast_nullable_to_non_nullable
as String?,applicationDate: freezed == applicationDate ? _self.applicationDate : applicationDate // ignore: cast_nullable_to_non_nullable
as DateTime?,appliedToInvoiceId: freezed == appliedToInvoiceId ? _self.appliedToInvoiceId : appliedToInvoiceId // ignore: cast_nullable_to_non_nullable
as String?,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String creditNoteNumber,  String companyId,  String? invoiceId,  CreditNoteType type,  String reason,  double totalAmount,  String currency,  List<CreditNoteItem> items,  CreditNoteStatus status,  DateTime? approvalDate,  String? approvedBy,  DateTime? applicationDate,  String? appliedToInvoiceId,  DateTime? expiryDate,  String? notes,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreditNote() when $default != null:
return $default(_that.id,_that.creditNoteNumber,_that.companyId,_that.invoiceId,_that.type,_that.reason,_that.totalAmount,_that.currency,_that.items,_that.status,_that.approvalDate,_that.approvedBy,_that.applicationDate,_that.appliedToInvoiceId,_that.expiryDate,_that.notes,_that.metadata,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String creditNoteNumber,  String companyId,  String? invoiceId,  CreditNoteType type,  String reason,  double totalAmount,  String currency,  List<CreditNoteItem> items,  CreditNoteStatus status,  DateTime? approvalDate,  String? approvedBy,  DateTime? applicationDate,  String? appliedToInvoiceId,  DateTime? expiryDate,  String? notes,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _CreditNote():
return $default(_that.id,_that.creditNoteNumber,_that.companyId,_that.invoiceId,_that.type,_that.reason,_that.totalAmount,_that.currency,_that.items,_that.status,_that.approvalDate,_that.approvedBy,_that.applicationDate,_that.appliedToInvoiceId,_that.expiryDate,_that.notes,_that.metadata,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String creditNoteNumber,  String companyId,  String? invoiceId,  CreditNoteType type,  String reason,  double totalAmount,  String currency,  List<CreditNoteItem> items,  CreditNoteStatus status,  DateTime? approvalDate,  String? approvedBy,  DateTime? applicationDate,  String? appliedToInvoiceId,  DateTime? expiryDate,  String? notes,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _CreditNote() when $default != null:
return $default(_that.id,_that.creditNoteNumber,_that.companyId,_that.invoiceId,_that.type,_that.reason,_that.totalAmount,_that.currency,_that.items,_that.status,_that.approvalDate,_that.approvedBy,_that.applicationDate,_that.appliedToInvoiceId,_that.expiryDate,_that.notes,_that.metadata,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreditNote implements CreditNote {
  const _CreditNote({required this.id, required this.creditNoteNumber, required this.companyId, this.invoiceId, required this.type, required this.reason, required this.totalAmount, this.currency = 'USD', required final  List<CreditNoteItem> items, this.status = CreditNoteStatus.draft, this.approvalDate, this.approvedBy, this.applicationDate, this.appliedToInvoiceId, this.expiryDate, this.notes, final  Map<String, dynamic>? metadata, this.createdAt, this.updatedAt}): _items = items,_metadata = metadata;
  factory _CreditNote.fromJson(Map<String, dynamic> json) => _$CreditNoteFromJson(json);

@override final  String id;
@override final  String creditNoteNumber;
@override final  String companyId;
@override final  String? invoiceId;
@override final  CreditNoteType type;
@override final  String reason;
@override final  double totalAmount;
@override@JsonKey() final  String currency;
 final  List<CreditNoteItem> _items;
@override List<CreditNoteItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  CreditNoteStatus status;
@override final  DateTime? approvalDate;
@override final  String? approvedBy;
@override final  DateTime? applicationDate;
@override final  String? appliedToInvoiceId;
@override final  DateTime? expiryDate;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreditNote&&(identical(other.id, id) || other.id == id)&&(identical(other.creditNoteNumber, creditNoteNumber) || other.creditNoteNumber == creditNoteNumber)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.type, type) || other.type == type)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.currency, currency) || other.currency == currency)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.status, status) || other.status == status)&&(identical(other.approvalDate, approvalDate) || other.approvalDate == approvalDate)&&(identical(other.approvedBy, approvedBy) || other.approvedBy == approvedBy)&&(identical(other.applicationDate, applicationDate) || other.applicationDate == applicationDate)&&(identical(other.appliedToInvoiceId, appliedToInvoiceId) || other.appliedToInvoiceId == appliedToInvoiceId)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,creditNoteNumber,companyId,invoiceId,type,reason,totalAmount,currency,const DeepCollectionEquality().hash(_items),status,approvalDate,approvedBy,applicationDate,appliedToInvoiceId,expiryDate,notes,const DeepCollectionEquality().hash(_metadata),createdAt,updatedAt]);

@override
String toString() {
  return 'CreditNote(id: $id, creditNoteNumber: $creditNoteNumber, companyId: $companyId, invoiceId: $invoiceId, type: $type, reason: $reason, totalAmount: $totalAmount, currency: $currency, items: $items, status: $status, approvalDate: $approvalDate, approvedBy: $approvedBy, applicationDate: $applicationDate, appliedToInvoiceId: $appliedToInvoiceId, expiryDate: $expiryDate, notes: $notes, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CreditNoteCopyWith<$Res> implements $CreditNoteCopyWith<$Res> {
  factory _$CreditNoteCopyWith(_CreditNote value, $Res Function(_CreditNote) _then) = __$CreditNoteCopyWithImpl;
@override @useResult
$Res call({
 String id, String creditNoteNumber, String companyId, String? invoiceId, CreditNoteType type, String reason, double totalAmount, String currency, List<CreditNoteItem> items, CreditNoteStatus status, DateTime? approvalDate, String? approvedBy, DateTime? applicationDate, String? appliedToInvoiceId, DateTime? expiryDate, String? notes, Map<String, dynamic>? metadata, DateTime? createdAt, DateTime? updatedAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? creditNoteNumber = null,Object? companyId = null,Object? invoiceId = freezed,Object? type = null,Object? reason = null,Object? totalAmount = null,Object? currency = null,Object? items = null,Object? status = null,Object? approvalDate = freezed,Object? approvedBy = freezed,Object? applicationDate = freezed,Object? appliedToInvoiceId = freezed,Object? expiryDate = freezed,Object? notes = freezed,Object? metadata = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_CreditNote(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,creditNoteNumber: null == creditNoteNumber ? _self.creditNoteNumber : creditNoteNumber // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,invoiceId: freezed == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CreditNoteType,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CreditNoteItem>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CreditNoteStatus,approvalDate: freezed == approvalDate ? _self.approvalDate : approvalDate // ignore: cast_nullable_to_non_nullable
as DateTime?,approvedBy: freezed == approvedBy ? _self.approvedBy : approvedBy // ignore: cast_nullable_to_non_nullable
as String?,applicationDate: freezed == applicationDate ? _self.applicationDate : applicationDate // ignore: cast_nullable_to_non_nullable
as DateTime?,appliedToInvoiceId: freezed == appliedToInvoiceId ? _self.appliedToInvoiceId : appliedToInvoiceId // ignore: cast_nullable_to_non_nullable
as String?,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$CreditNoteFilter {

 DateTime? get startDate; DateTime? get endDate; List<CreditNoteStatus>? get statuses; List<CreditNoteType>? get types; double? get minAmount; double? get maxAmount; String? get searchQuery; String get sortBy; bool get sortDesc; int get page; int get limit;
/// Create a copy of CreditNoteFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreditNoteFilterCopyWith<CreditNoteFilter> get copyWith => _$CreditNoteFilterCopyWithImpl<CreditNoteFilter>(this as CreditNoteFilter, _$identity);

  /// Serializes this CreditNoteFilter to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreditNoteFilter&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other.statuses, statuses)&&const DeepCollectionEquality().equals(other.types, types)&&(identical(other.minAmount, minAmount) || other.minAmount == minAmount)&&(identical(other.maxAmount, maxAmount) || other.maxAmount == maxAmount)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.sortDesc, sortDesc) || other.sortDesc == sortDesc)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startDate,endDate,const DeepCollectionEquality().hash(statuses),const DeepCollectionEquality().hash(types),minAmount,maxAmount,searchQuery,sortBy,sortDesc,page,limit);

@override
String toString() {
  return 'CreditNoteFilter(startDate: $startDate, endDate: $endDate, statuses: $statuses, types: $types, minAmount: $minAmount, maxAmount: $maxAmount, searchQuery: $searchQuery, sortBy: $sortBy, sortDesc: $sortDesc, page: $page, limit: $limit)';
}


}

/// @nodoc
abstract mixin class $CreditNoteFilterCopyWith<$Res>  {
  factory $CreditNoteFilterCopyWith(CreditNoteFilter value, $Res Function(CreditNoteFilter) _then) = _$CreditNoteFilterCopyWithImpl;
@useResult
$Res call({
 DateTime? startDate, DateTime? endDate, List<CreditNoteStatus>? statuses, List<CreditNoteType>? types, double? minAmount, double? maxAmount, String? searchQuery, String sortBy, bool sortDesc, int page, int limit
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
@pragma('vm:prefer-inline') @override $Res call({Object? startDate = freezed,Object? endDate = freezed,Object? statuses = freezed,Object? types = freezed,Object? minAmount = freezed,Object? maxAmount = freezed,Object? searchQuery = freezed,Object? sortBy = null,Object? sortDesc = null,Object? page = null,Object? limit = null,}) {
  return _then(_self.copyWith(
startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,statuses: freezed == statuses ? _self.statuses : statuses // ignore: cast_nullable_to_non_nullable
as List<CreditNoteStatus>?,types: freezed == types ? _self.types : types // ignore: cast_nullable_to_non_nullable
as List<CreditNoteType>?,minAmount: freezed == minAmount ? _self.minAmount : minAmount // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime? startDate,  DateTime? endDate,  List<CreditNoteStatus>? statuses,  List<CreditNoteType>? types,  double? minAmount,  double? maxAmount,  String? searchQuery,  String sortBy,  bool sortDesc,  int page,  int limit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreditNoteFilter() when $default != null:
return $default(_that.startDate,_that.endDate,_that.statuses,_that.types,_that.minAmount,_that.maxAmount,_that.searchQuery,_that.sortBy,_that.sortDesc,_that.page,_that.limit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime? startDate,  DateTime? endDate,  List<CreditNoteStatus>? statuses,  List<CreditNoteType>? types,  double? minAmount,  double? maxAmount,  String? searchQuery,  String sortBy,  bool sortDesc,  int page,  int limit)  $default,) {final _that = this;
switch (_that) {
case _CreditNoteFilter():
return $default(_that.startDate,_that.endDate,_that.statuses,_that.types,_that.minAmount,_that.maxAmount,_that.searchQuery,_that.sortBy,_that.sortDesc,_that.page,_that.limit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime? startDate,  DateTime? endDate,  List<CreditNoteStatus>? statuses,  List<CreditNoteType>? types,  double? minAmount,  double? maxAmount,  String? searchQuery,  String sortBy,  bool sortDesc,  int page,  int limit)?  $default,) {final _that = this;
switch (_that) {
case _CreditNoteFilter() when $default != null:
return $default(_that.startDate,_that.endDate,_that.statuses,_that.types,_that.minAmount,_that.maxAmount,_that.searchQuery,_that.sortBy,_that.sortDesc,_that.page,_that.limit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreditNoteFilter implements CreditNoteFilter {
  const _CreditNoteFilter({this.startDate, this.endDate, final  List<CreditNoteStatus>? statuses, final  List<CreditNoteType>? types, this.minAmount, this.maxAmount, this.searchQuery, this.sortBy = 'createdAt', this.sortDesc = false, this.page = 1, this.limit = 20}): _statuses = statuses,_types = types;
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

 final  List<CreditNoteType>? _types;
@override List<CreditNoteType>? get types {
  final value = _types;
  if (value == null) return null;
  if (_types is EqualUnmodifiableListView) return _types;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreditNoteFilter&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other._statuses, _statuses)&&const DeepCollectionEquality().equals(other._types, _types)&&(identical(other.minAmount, minAmount) || other.minAmount == minAmount)&&(identical(other.maxAmount, maxAmount) || other.maxAmount == maxAmount)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.sortDesc, sortDesc) || other.sortDesc == sortDesc)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startDate,endDate,const DeepCollectionEquality().hash(_statuses),const DeepCollectionEquality().hash(_types),minAmount,maxAmount,searchQuery,sortBy,sortDesc,page,limit);

@override
String toString() {
  return 'CreditNoteFilter(startDate: $startDate, endDate: $endDate, statuses: $statuses, types: $types, minAmount: $minAmount, maxAmount: $maxAmount, searchQuery: $searchQuery, sortBy: $sortBy, sortDesc: $sortDesc, page: $page, limit: $limit)';
}


}

/// @nodoc
abstract mixin class _$CreditNoteFilterCopyWith<$Res> implements $CreditNoteFilterCopyWith<$Res> {
  factory _$CreditNoteFilterCopyWith(_CreditNoteFilter value, $Res Function(_CreditNoteFilter) _then) = __$CreditNoteFilterCopyWithImpl;
@override @useResult
$Res call({
 DateTime? startDate, DateTime? endDate, List<CreditNoteStatus>? statuses, List<CreditNoteType>? types, double? minAmount, double? maxAmount, String? searchQuery, String sortBy, bool sortDesc, int page, int limit
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
@override @pragma('vm:prefer-inline') $Res call({Object? startDate = freezed,Object? endDate = freezed,Object? statuses = freezed,Object? types = freezed,Object? minAmount = freezed,Object? maxAmount = freezed,Object? searchQuery = freezed,Object? sortBy = null,Object? sortDesc = null,Object? page = null,Object? limit = null,}) {
  return _then(_CreditNoteFilter(
startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,statuses: freezed == statuses ? _self._statuses : statuses // ignore: cast_nullable_to_non_nullable
as List<CreditNoteStatus>?,types: freezed == types ? _self._types : types // ignore: cast_nullable_to_non_nullable
as List<CreditNoteType>?,minAmount: freezed == minAmount ? _self.minAmount : minAmount // ignore: cast_nullable_to_non_nullable
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


/// @nodoc
mixin _$CreditNoteSummary {

 double get totalIssued; double get totalApplied; double get totalAvailable; int get draftCount; int get pendingApprovalCount; int get approvedCount; int get appliedCount; int get expiredCount; Map<String, double>? get byType; Map<String, double>? get byCompany;
/// Create a copy of CreditNoteSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreditNoteSummaryCopyWith<CreditNoteSummary> get copyWith => _$CreditNoteSummaryCopyWithImpl<CreditNoteSummary>(this as CreditNoteSummary, _$identity);

  /// Serializes this CreditNoteSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreditNoteSummary&&(identical(other.totalIssued, totalIssued) || other.totalIssued == totalIssued)&&(identical(other.totalApplied, totalApplied) || other.totalApplied == totalApplied)&&(identical(other.totalAvailable, totalAvailable) || other.totalAvailable == totalAvailable)&&(identical(other.draftCount, draftCount) || other.draftCount == draftCount)&&(identical(other.pendingApprovalCount, pendingApprovalCount) || other.pendingApprovalCount == pendingApprovalCount)&&(identical(other.approvedCount, approvedCount) || other.approvedCount == approvedCount)&&(identical(other.appliedCount, appliedCount) || other.appliedCount == appliedCount)&&(identical(other.expiredCount, expiredCount) || other.expiredCount == expiredCount)&&const DeepCollectionEquality().equals(other.byType, byType)&&const DeepCollectionEquality().equals(other.byCompany, byCompany));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalIssued,totalApplied,totalAvailable,draftCount,pendingApprovalCount,approvedCount,appliedCount,expiredCount,const DeepCollectionEquality().hash(byType),const DeepCollectionEquality().hash(byCompany));

@override
String toString() {
  return 'CreditNoteSummary(totalIssued: $totalIssued, totalApplied: $totalApplied, totalAvailable: $totalAvailable, draftCount: $draftCount, pendingApprovalCount: $pendingApprovalCount, approvedCount: $approvedCount, appliedCount: $appliedCount, expiredCount: $expiredCount, byType: $byType, byCompany: $byCompany)';
}


}

/// @nodoc
abstract mixin class $CreditNoteSummaryCopyWith<$Res>  {
  factory $CreditNoteSummaryCopyWith(CreditNoteSummary value, $Res Function(CreditNoteSummary) _then) = _$CreditNoteSummaryCopyWithImpl;
@useResult
$Res call({
 double totalIssued, double totalApplied, double totalAvailable, int draftCount, int pendingApprovalCount, int approvedCount, int appliedCount, int expiredCount, Map<String, double>? byType, Map<String, double>? byCompany
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
@pragma('vm:prefer-inline') @override $Res call({Object? totalIssued = null,Object? totalApplied = null,Object? totalAvailable = null,Object? draftCount = null,Object? pendingApprovalCount = null,Object? approvedCount = null,Object? appliedCount = null,Object? expiredCount = null,Object? byType = freezed,Object? byCompany = freezed,}) {
  return _then(_self.copyWith(
totalIssued: null == totalIssued ? _self.totalIssued : totalIssued // ignore: cast_nullable_to_non_nullable
as double,totalApplied: null == totalApplied ? _self.totalApplied : totalApplied // ignore: cast_nullable_to_non_nullable
as double,totalAvailable: null == totalAvailable ? _self.totalAvailable : totalAvailable // ignore: cast_nullable_to_non_nullable
as double,draftCount: null == draftCount ? _self.draftCount : draftCount // ignore: cast_nullable_to_non_nullable
as int,pendingApprovalCount: null == pendingApprovalCount ? _self.pendingApprovalCount : pendingApprovalCount // ignore: cast_nullable_to_non_nullable
as int,approvedCount: null == approvedCount ? _self.approvedCount : approvedCount // ignore: cast_nullable_to_non_nullable
as int,appliedCount: null == appliedCount ? _self.appliedCount : appliedCount // ignore: cast_nullable_to_non_nullable
as int,expiredCount: null == expiredCount ? _self.expiredCount : expiredCount // ignore: cast_nullable_to_non_nullable
as int,byType: freezed == byType ? _self.byType : byType // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,byCompany: freezed == byCompany ? _self.byCompany : byCompany // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double totalIssued,  double totalApplied,  double totalAvailable,  int draftCount,  int pendingApprovalCount,  int approvedCount,  int appliedCount,  int expiredCount,  Map<String, double>? byType,  Map<String, double>? byCompany)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreditNoteSummary() when $default != null:
return $default(_that.totalIssued,_that.totalApplied,_that.totalAvailable,_that.draftCount,_that.pendingApprovalCount,_that.approvedCount,_that.appliedCount,_that.expiredCount,_that.byType,_that.byCompany);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double totalIssued,  double totalApplied,  double totalAvailable,  int draftCount,  int pendingApprovalCount,  int approvedCount,  int appliedCount,  int expiredCount,  Map<String, double>? byType,  Map<String, double>? byCompany)  $default,) {final _that = this;
switch (_that) {
case _CreditNoteSummary():
return $default(_that.totalIssued,_that.totalApplied,_that.totalAvailable,_that.draftCount,_that.pendingApprovalCount,_that.approvedCount,_that.appliedCount,_that.expiredCount,_that.byType,_that.byCompany);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double totalIssued,  double totalApplied,  double totalAvailable,  int draftCount,  int pendingApprovalCount,  int approvedCount,  int appliedCount,  int expiredCount,  Map<String, double>? byType,  Map<String, double>? byCompany)?  $default,) {final _that = this;
switch (_that) {
case _CreditNoteSummary() when $default != null:
return $default(_that.totalIssued,_that.totalApplied,_that.totalAvailable,_that.draftCount,_that.pendingApprovalCount,_that.approvedCount,_that.appliedCount,_that.expiredCount,_that.byType,_that.byCompany);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreditNoteSummary implements CreditNoteSummary {
  const _CreditNoteSummary({this.totalIssued = 0.0, this.totalApplied = 0.0, this.totalAvailable = 0.0, this.draftCount = 0, this.pendingApprovalCount = 0, this.approvedCount = 0, this.appliedCount = 0, this.expiredCount = 0, final  Map<String, double>? byType, final  Map<String, double>? byCompany}): _byType = byType,_byCompany = byCompany;
  factory _CreditNoteSummary.fromJson(Map<String, dynamic> json) => _$CreditNoteSummaryFromJson(json);

@override@JsonKey() final  double totalIssued;
@override@JsonKey() final  double totalApplied;
@override@JsonKey() final  double totalAvailable;
@override@JsonKey() final  int draftCount;
@override@JsonKey() final  int pendingApprovalCount;
@override@JsonKey() final  int approvedCount;
@override@JsonKey() final  int appliedCount;
@override@JsonKey() final  int expiredCount;
 final  Map<String, double>? _byType;
@override Map<String, double>? get byType {
  final value = _byType;
  if (value == null) return null;
  if (_byType is EqualUnmodifiableMapView) return _byType;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, double>? _byCompany;
@override Map<String, double>? get byCompany {
  final value = _byCompany;
  if (value == null) return null;
  if (_byCompany is EqualUnmodifiableMapView) return _byCompany;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreditNoteSummary&&(identical(other.totalIssued, totalIssued) || other.totalIssued == totalIssued)&&(identical(other.totalApplied, totalApplied) || other.totalApplied == totalApplied)&&(identical(other.totalAvailable, totalAvailable) || other.totalAvailable == totalAvailable)&&(identical(other.draftCount, draftCount) || other.draftCount == draftCount)&&(identical(other.pendingApprovalCount, pendingApprovalCount) || other.pendingApprovalCount == pendingApprovalCount)&&(identical(other.approvedCount, approvedCount) || other.approvedCount == approvedCount)&&(identical(other.appliedCount, appliedCount) || other.appliedCount == appliedCount)&&(identical(other.expiredCount, expiredCount) || other.expiredCount == expiredCount)&&const DeepCollectionEquality().equals(other._byType, _byType)&&const DeepCollectionEquality().equals(other._byCompany, _byCompany));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalIssued,totalApplied,totalAvailable,draftCount,pendingApprovalCount,approvedCount,appliedCount,expiredCount,const DeepCollectionEquality().hash(_byType),const DeepCollectionEquality().hash(_byCompany));

@override
String toString() {
  return 'CreditNoteSummary(totalIssued: $totalIssued, totalApplied: $totalApplied, totalAvailable: $totalAvailable, draftCount: $draftCount, pendingApprovalCount: $pendingApprovalCount, approvedCount: $approvedCount, appliedCount: $appliedCount, expiredCount: $expiredCount, byType: $byType, byCompany: $byCompany)';
}


}

/// @nodoc
abstract mixin class _$CreditNoteSummaryCopyWith<$Res> implements $CreditNoteSummaryCopyWith<$Res> {
  factory _$CreditNoteSummaryCopyWith(_CreditNoteSummary value, $Res Function(_CreditNoteSummary) _then) = __$CreditNoteSummaryCopyWithImpl;
@override @useResult
$Res call({
 double totalIssued, double totalApplied, double totalAvailable, int draftCount, int pendingApprovalCount, int approvedCount, int appliedCount, int expiredCount, Map<String, double>? byType, Map<String, double>? byCompany
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
@override @pragma('vm:prefer-inline') $Res call({Object? totalIssued = null,Object? totalApplied = null,Object? totalAvailable = null,Object? draftCount = null,Object? pendingApprovalCount = null,Object? approvedCount = null,Object? appliedCount = null,Object? expiredCount = null,Object? byType = freezed,Object? byCompany = freezed,}) {
  return _then(_CreditNoteSummary(
totalIssued: null == totalIssued ? _self.totalIssued : totalIssued // ignore: cast_nullable_to_non_nullable
as double,totalApplied: null == totalApplied ? _self.totalApplied : totalApplied // ignore: cast_nullable_to_non_nullable
as double,totalAvailable: null == totalAvailable ? _self.totalAvailable : totalAvailable // ignore: cast_nullable_to_non_nullable
as double,draftCount: null == draftCount ? _self.draftCount : draftCount // ignore: cast_nullable_to_non_nullable
as int,pendingApprovalCount: null == pendingApprovalCount ? _self.pendingApprovalCount : pendingApprovalCount // ignore: cast_nullable_to_non_nullable
as int,approvedCount: null == approvedCount ? _self.approvedCount : approvedCount // ignore: cast_nullable_to_non_nullable
as int,appliedCount: null == appliedCount ? _self.appliedCount : appliedCount // ignore: cast_nullable_to_non_nullable
as int,expiredCount: null == expiredCount ? _self.expiredCount : expiredCount // ignore: cast_nullable_to_non_nullable
as int,byType: freezed == byType ? _self._byType : byType // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,byCompany: freezed == byCompany ? _self._byCompany : byCompany // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,
  ));
}


}

// dart format on

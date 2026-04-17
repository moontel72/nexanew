// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invoice_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InvoiceItemDetail {

 String get id; String get invoiceId; String get description; String get itemType; double get quantity; double get unitPrice; double get totalAmount; String get currency; DateTime get periodStart; DateTime get periodEnd;// Item type specific fields
 String? get codeType; int? get codeCount; double? get codeUnitPrice; String? get planFeatureId; String? get planFeatureName; double? get usageAmount; double? get overageRate; double? get overageAmount; bool? get isOverageCharge;// Tax and discount details
 double? get taxRate; double? get taxAmount; double? get discountRate; double? get discountAmount;// Metadata
 Map<String, dynamic>? get metadata; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of InvoiceItemDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvoiceItemDetailCopyWith<InvoiceItemDetail> get copyWith => _$InvoiceItemDetailCopyWithImpl<InvoiceItemDetail>(this as InvoiceItemDetail, _$identity);

  /// Serializes this InvoiceItemDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvoiceItemDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.description, description) || other.description == description)&&(identical(other.itemType, itemType) || other.itemType == itemType)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.codeType, codeType) || other.codeType == codeType)&&(identical(other.codeCount, codeCount) || other.codeCount == codeCount)&&(identical(other.codeUnitPrice, codeUnitPrice) || other.codeUnitPrice == codeUnitPrice)&&(identical(other.planFeatureId, planFeatureId) || other.planFeatureId == planFeatureId)&&(identical(other.planFeatureName, planFeatureName) || other.planFeatureName == planFeatureName)&&(identical(other.usageAmount, usageAmount) || other.usageAmount == usageAmount)&&(identical(other.overageRate, overageRate) || other.overageRate == overageRate)&&(identical(other.overageAmount, overageAmount) || other.overageAmount == overageAmount)&&(identical(other.isOverageCharge, isOverageCharge) || other.isOverageCharge == isOverageCharge)&&(identical(other.taxRate, taxRate) || other.taxRate == taxRate)&&(identical(other.taxAmount, taxAmount) || other.taxAmount == taxAmount)&&(identical(other.discountRate, discountRate) || other.discountRate == discountRate)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,invoiceId,description,itemType,quantity,unitPrice,totalAmount,currency,periodStart,periodEnd,codeType,codeCount,codeUnitPrice,planFeatureId,planFeatureName,usageAmount,overageRate,overageAmount,isOverageCharge,taxRate,taxAmount,discountRate,discountAmount,const DeepCollectionEquality().hash(metadata),createdAt,updatedAt]);

@override
String toString() {
  return 'InvoiceItemDetail(id: $id, invoiceId: $invoiceId, description: $description, itemType: $itemType, quantity: $quantity, unitPrice: $unitPrice, totalAmount: $totalAmount, currency: $currency, periodStart: $periodStart, periodEnd: $periodEnd, codeType: $codeType, codeCount: $codeCount, codeUnitPrice: $codeUnitPrice, planFeatureId: $planFeatureId, planFeatureName: $planFeatureName, usageAmount: $usageAmount, overageRate: $overageRate, overageAmount: $overageAmount, isOverageCharge: $isOverageCharge, taxRate: $taxRate, taxAmount: $taxAmount, discountRate: $discountRate, discountAmount: $discountAmount, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $InvoiceItemDetailCopyWith<$Res>  {
  factory $InvoiceItemDetailCopyWith(InvoiceItemDetail value, $Res Function(InvoiceItemDetail) _then) = _$InvoiceItemDetailCopyWithImpl;
@useResult
$Res call({
 String id, String invoiceId, String description, String itemType, double quantity, double unitPrice, double totalAmount, String currency, DateTime periodStart, DateTime periodEnd, String? codeType, int? codeCount, double? codeUnitPrice, String? planFeatureId, String? planFeatureName, double? usageAmount, double? overageRate, double? overageAmount, bool? isOverageCharge, double? taxRate, double? taxAmount, double? discountRate, double? discountAmount, Map<String, dynamic>? metadata, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$InvoiceItemDetailCopyWithImpl<$Res>
    implements $InvoiceItemDetailCopyWith<$Res> {
  _$InvoiceItemDetailCopyWithImpl(this._self, this._then);

  final InvoiceItemDetail _self;
  final $Res Function(InvoiceItemDetail) _then;

/// Create a copy of InvoiceItemDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? invoiceId = null,Object? description = null,Object? itemType = null,Object? quantity = null,Object? unitPrice = null,Object? totalAmount = null,Object? currency = null,Object? periodStart = null,Object? periodEnd = null,Object? codeType = freezed,Object? codeCount = freezed,Object? codeUnitPrice = freezed,Object? planFeatureId = freezed,Object? planFeatureName = freezed,Object? usageAmount = freezed,Object? overageRate = freezed,Object? overageAmount = freezed,Object? isOverageCharge = freezed,Object? taxRate = freezed,Object? taxAmount = freezed,Object? discountRate = freezed,Object? discountAmount = freezed,Object? metadata = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,itemType: null == itemType ? _self.itemType : itemType // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,codeType: freezed == codeType ? _self.codeType : codeType // ignore: cast_nullable_to_non_nullable
as String?,codeCount: freezed == codeCount ? _self.codeCount : codeCount // ignore: cast_nullable_to_non_nullable
as int?,codeUnitPrice: freezed == codeUnitPrice ? _self.codeUnitPrice : codeUnitPrice // ignore: cast_nullable_to_non_nullable
as double?,planFeatureId: freezed == planFeatureId ? _self.planFeatureId : planFeatureId // ignore: cast_nullable_to_non_nullable
as String?,planFeatureName: freezed == planFeatureName ? _self.planFeatureName : planFeatureName // ignore: cast_nullable_to_non_nullable
as String?,usageAmount: freezed == usageAmount ? _self.usageAmount : usageAmount // ignore: cast_nullable_to_non_nullable
as double?,overageRate: freezed == overageRate ? _self.overageRate : overageRate // ignore: cast_nullable_to_non_nullable
as double?,overageAmount: freezed == overageAmount ? _self.overageAmount : overageAmount // ignore: cast_nullable_to_non_nullable
as double?,isOverageCharge: freezed == isOverageCharge ? _self.isOverageCharge : isOverageCharge // ignore: cast_nullable_to_non_nullable
as bool?,taxRate: freezed == taxRate ? _self.taxRate : taxRate // ignore: cast_nullable_to_non_nullable
as double?,taxAmount: freezed == taxAmount ? _self.taxAmount : taxAmount // ignore: cast_nullable_to_non_nullable
as double?,discountRate: freezed == discountRate ? _self.discountRate : discountRate // ignore: cast_nullable_to_non_nullable
as double?,discountAmount: freezed == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as double?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [InvoiceItemDetail].
extension InvoiceItemDetailPatterns on InvoiceItemDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InvoiceItemDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InvoiceItemDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InvoiceItemDetail value)  $default,){
final _that = this;
switch (_that) {
case _InvoiceItemDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InvoiceItemDetail value)?  $default,){
final _that = this;
switch (_that) {
case _InvoiceItemDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String invoiceId,  String description,  String itemType,  double quantity,  double unitPrice,  double totalAmount,  String currency,  DateTime periodStart,  DateTime periodEnd,  String? codeType,  int? codeCount,  double? codeUnitPrice,  String? planFeatureId,  String? planFeatureName,  double? usageAmount,  double? overageRate,  double? overageAmount,  bool? isOverageCharge,  double? taxRate,  double? taxAmount,  double? discountRate,  double? discountAmount,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InvoiceItemDetail() when $default != null:
return $default(_that.id,_that.invoiceId,_that.description,_that.itemType,_that.quantity,_that.unitPrice,_that.totalAmount,_that.currency,_that.periodStart,_that.periodEnd,_that.codeType,_that.codeCount,_that.codeUnitPrice,_that.planFeatureId,_that.planFeatureName,_that.usageAmount,_that.overageRate,_that.overageAmount,_that.isOverageCharge,_that.taxRate,_that.taxAmount,_that.discountRate,_that.discountAmount,_that.metadata,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String invoiceId,  String description,  String itemType,  double quantity,  double unitPrice,  double totalAmount,  String currency,  DateTime periodStart,  DateTime periodEnd,  String? codeType,  int? codeCount,  double? codeUnitPrice,  String? planFeatureId,  String? planFeatureName,  double? usageAmount,  double? overageRate,  double? overageAmount,  bool? isOverageCharge,  double? taxRate,  double? taxAmount,  double? discountRate,  double? discountAmount,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _InvoiceItemDetail():
return $default(_that.id,_that.invoiceId,_that.description,_that.itemType,_that.quantity,_that.unitPrice,_that.totalAmount,_that.currency,_that.periodStart,_that.periodEnd,_that.codeType,_that.codeCount,_that.codeUnitPrice,_that.planFeatureId,_that.planFeatureName,_that.usageAmount,_that.overageRate,_that.overageAmount,_that.isOverageCharge,_that.taxRate,_that.taxAmount,_that.discountRate,_that.discountAmount,_that.metadata,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String invoiceId,  String description,  String itemType,  double quantity,  double unitPrice,  double totalAmount,  String currency,  DateTime periodStart,  DateTime periodEnd,  String? codeType,  int? codeCount,  double? codeUnitPrice,  String? planFeatureId,  String? planFeatureName,  double? usageAmount,  double? overageRate,  double? overageAmount,  bool? isOverageCharge,  double? taxRate,  double? taxAmount,  double? discountRate,  double? discountAmount,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _InvoiceItemDetail() when $default != null:
return $default(_that.id,_that.invoiceId,_that.description,_that.itemType,_that.quantity,_that.unitPrice,_that.totalAmount,_that.currency,_that.periodStart,_that.periodEnd,_that.codeType,_that.codeCount,_that.codeUnitPrice,_that.planFeatureId,_that.planFeatureName,_that.usageAmount,_that.overageRate,_that.overageAmount,_that.isOverageCharge,_that.taxRate,_that.taxAmount,_that.discountRate,_that.discountAmount,_that.metadata,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InvoiceItemDetail implements InvoiceItemDetail {
  const _InvoiceItemDetail({required this.id, required this.invoiceId, required this.description, required this.itemType, required this.quantity, required this.unitPrice, required this.totalAmount, required this.currency, required this.periodStart, required this.periodEnd, this.codeType, this.codeCount, this.codeUnitPrice, this.planFeatureId, this.planFeatureName, this.usageAmount, this.overageRate, this.overageAmount, this.isOverageCharge, this.taxRate, this.taxAmount, this.discountRate, this.discountAmount, final  Map<String, dynamic>? metadata, this.createdAt, this.updatedAt}): _metadata = metadata;
  factory _InvoiceItemDetail.fromJson(Map<String, dynamic> json) => _$InvoiceItemDetailFromJson(json);

@override final  String id;
@override final  String invoiceId;
@override final  String description;
@override final  String itemType;
@override final  double quantity;
@override final  double unitPrice;
@override final  double totalAmount;
@override final  String currency;
@override final  DateTime periodStart;
@override final  DateTime periodEnd;
// Item type specific fields
@override final  String? codeType;
@override final  int? codeCount;
@override final  double? codeUnitPrice;
@override final  String? planFeatureId;
@override final  String? planFeatureName;
@override final  double? usageAmount;
@override final  double? overageRate;
@override final  double? overageAmount;
@override final  bool? isOverageCharge;
// Tax and discount details
@override final  double? taxRate;
@override final  double? taxAmount;
@override final  double? discountRate;
@override final  double? discountAmount;
// Metadata
 final  Map<String, dynamic>? _metadata;
// Metadata
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of InvoiceItemDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvoiceItemDetailCopyWith<_InvoiceItemDetail> get copyWith => __$InvoiceItemDetailCopyWithImpl<_InvoiceItemDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvoiceItemDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvoiceItemDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.description, description) || other.description == description)&&(identical(other.itemType, itemType) || other.itemType == itemType)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.codeType, codeType) || other.codeType == codeType)&&(identical(other.codeCount, codeCount) || other.codeCount == codeCount)&&(identical(other.codeUnitPrice, codeUnitPrice) || other.codeUnitPrice == codeUnitPrice)&&(identical(other.planFeatureId, planFeatureId) || other.planFeatureId == planFeatureId)&&(identical(other.planFeatureName, planFeatureName) || other.planFeatureName == planFeatureName)&&(identical(other.usageAmount, usageAmount) || other.usageAmount == usageAmount)&&(identical(other.overageRate, overageRate) || other.overageRate == overageRate)&&(identical(other.overageAmount, overageAmount) || other.overageAmount == overageAmount)&&(identical(other.isOverageCharge, isOverageCharge) || other.isOverageCharge == isOverageCharge)&&(identical(other.taxRate, taxRate) || other.taxRate == taxRate)&&(identical(other.taxAmount, taxAmount) || other.taxAmount == taxAmount)&&(identical(other.discountRate, discountRate) || other.discountRate == discountRate)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,invoiceId,description,itemType,quantity,unitPrice,totalAmount,currency,periodStart,periodEnd,codeType,codeCount,codeUnitPrice,planFeatureId,planFeatureName,usageAmount,overageRate,overageAmount,isOverageCharge,taxRate,taxAmount,discountRate,discountAmount,const DeepCollectionEquality().hash(_metadata),createdAt,updatedAt]);

@override
String toString() {
  return 'InvoiceItemDetail(id: $id, invoiceId: $invoiceId, description: $description, itemType: $itemType, quantity: $quantity, unitPrice: $unitPrice, totalAmount: $totalAmount, currency: $currency, periodStart: $periodStart, periodEnd: $periodEnd, codeType: $codeType, codeCount: $codeCount, codeUnitPrice: $codeUnitPrice, planFeatureId: $planFeatureId, planFeatureName: $planFeatureName, usageAmount: $usageAmount, overageRate: $overageRate, overageAmount: $overageAmount, isOverageCharge: $isOverageCharge, taxRate: $taxRate, taxAmount: $taxAmount, discountRate: $discountRate, discountAmount: $discountAmount, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$InvoiceItemDetailCopyWith<$Res> implements $InvoiceItemDetailCopyWith<$Res> {
  factory _$InvoiceItemDetailCopyWith(_InvoiceItemDetail value, $Res Function(_InvoiceItemDetail) _then) = __$InvoiceItemDetailCopyWithImpl;
@override @useResult
$Res call({
 String id, String invoiceId, String description, String itemType, double quantity, double unitPrice, double totalAmount, String currency, DateTime periodStart, DateTime periodEnd, String? codeType, int? codeCount, double? codeUnitPrice, String? planFeatureId, String? planFeatureName, double? usageAmount, double? overageRate, double? overageAmount, bool? isOverageCharge, double? taxRate, double? taxAmount, double? discountRate, double? discountAmount, Map<String, dynamic>? metadata, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$InvoiceItemDetailCopyWithImpl<$Res>
    implements _$InvoiceItemDetailCopyWith<$Res> {
  __$InvoiceItemDetailCopyWithImpl(this._self, this._then);

  final _InvoiceItemDetail _self;
  final $Res Function(_InvoiceItemDetail) _then;

/// Create a copy of InvoiceItemDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? invoiceId = null,Object? description = null,Object? itemType = null,Object? quantity = null,Object? unitPrice = null,Object? totalAmount = null,Object? currency = null,Object? periodStart = null,Object? periodEnd = null,Object? codeType = freezed,Object? codeCount = freezed,Object? codeUnitPrice = freezed,Object? planFeatureId = freezed,Object? planFeatureName = freezed,Object? usageAmount = freezed,Object? overageRate = freezed,Object? overageAmount = freezed,Object? isOverageCharge = freezed,Object? taxRate = freezed,Object? taxAmount = freezed,Object? discountRate = freezed,Object? discountAmount = freezed,Object? metadata = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_InvoiceItemDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,itemType: null == itemType ? _self.itemType : itemType // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,codeType: freezed == codeType ? _self.codeType : codeType // ignore: cast_nullable_to_non_nullable
as String?,codeCount: freezed == codeCount ? _self.codeCount : codeCount // ignore: cast_nullable_to_non_nullable
as int?,codeUnitPrice: freezed == codeUnitPrice ? _self.codeUnitPrice : codeUnitPrice // ignore: cast_nullable_to_non_nullable
as double?,planFeatureId: freezed == planFeatureId ? _self.planFeatureId : planFeatureId // ignore: cast_nullable_to_non_nullable
as String?,planFeatureName: freezed == planFeatureName ? _self.planFeatureName : planFeatureName // ignore: cast_nullable_to_non_nullable
as String?,usageAmount: freezed == usageAmount ? _self.usageAmount : usageAmount // ignore: cast_nullable_to_non_nullable
as double?,overageRate: freezed == overageRate ? _self.overageRate : overageRate // ignore: cast_nullable_to_non_nullable
as double?,overageAmount: freezed == overageAmount ? _self.overageAmount : overageAmount // ignore: cast_nullable_to_non_nullable
as double?,isOverageCharge: freezed == isOverageCharge ? _self.isOverageCharge : isOverageCharge // ignore: cast_nullable_to_non_nullable
as bool?,taxRate: freezed == taxRate ? _self.taxRate : taxRate // ignore: cast_nullable_to_non_nullable
as double?,taxAmount: freezed == taxAmount ? _self.taxAmount : taxAmount // ignore: cast_nullable_to_non_nullable
as double?,discountRate: freezed == discountRate ? _self.discountRate : discountRate // ignore: cast_nullable_to_non_nullable
as double?,discountAmount: freezed == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as double?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$InvoiceItemBreakdown {

 String get invoiceId; String get invoiceNumber; DateTime get invoiceDate; String get companyId; String get companyName; List<InvoiceItemDetail> get items; double get subtotal; double get totalTax; double get totalDiscount; double get grandTotal; String get currency;// Summary statistics
 int? get totalItems; double? get averageItemPrice; double? get highestItemPrice; double? get lowestItemPrice;// Categorization
 Map<String, double>? get amountByItemType; Map<String, int>? get countByItemType;
/// Create a copy of InvoiceItemBreakdown
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvoiceItemBreakdownCopyWith<InvoiceItemBreakdown> get copyWith => _$InvoiceItemBreakdownCopyWithImpl<InvoiceItemBreakdown>(this as InvoiceItemBreakdown, _$identity);

  /// Serializes this InvoiceItemBreakdown to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvoiceItemBreakdown&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.invoiceNumber, invoiceNumber) || other.invoiceNumber == invoiceNumber)&&(identical(other.invoiceDate, invoiceDate) || other.invoiceDate == invoiceDate)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.totalTax, totalTax) || other.totalTax == totalTax)&&(identical(other.totalDiscount, totalDiscount) || other.totalDiscount == totalDiscount)&&(identical(other.grandTotal, grandTotal) || other.grandTotal == grandTotal)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.totalItems, totalItems) || other.totalItems == totalItems)&&(identical(other.averageItemPrice, averageItemPrice) || other.averageItemPrice == averageItemPrice)&&(identical(other.highestItemPrice, highestItemPrice) || other.highestItemPrice == highestItemPrice)&&(identical(other.lowestItemPrice, lowestItemPrice) || other.lowestItemPrice == lowestItemPrice)&&const DeepCollectionEquality().equals(other.amountByItemType, amountByItemType)&&const DeepCollectionEquality().equals(other.countByItemType, countByItemType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,invoiceId,invoiceNumber,invoiceDate,companyId,companyName,const DeepCollectionEquality().hash(items),subtotal,totalTax,totalDiscount,grandTotal,currency,totalItems,averageItemPrice,highestItemPrice,lowestItemPrice,const DeepCollectionEquality().hash(amountByItemType),const DeepCollectionEquality().hash(countByItemType));

@override
String toString() {
  return 'InvoiceItemBreakdown(invoiceId: $invoiceId, invoiceNumber: $invoiceNumber, invoiceDate: $invoiceDate, companyId: $companyId, companyName: $companyName, items: $items, subtotal: $subtotal, totalTax: $totalTax, totalDiscount: $totalDiscount, grandTotal: $grandTotal, currency: $currency, totalItems: $totalItems, averageItemPrice: $averageItemPrice, highestItemPrice: $highestItemPrice, lowestItemPrice: $lowestItemPrice, amountByItemType: $amountByItemType, countByItemType: $countByItemType)';
}


}

/// @nodoc
abstract mixin class $InvoiceItemBreakdownCopyWith<$Res>  {
  factory $InvoiceItemBreakdownCopyWith(InvoiceItemBreakdown value, $Res Function(InvoiceItemBreakdown) _then) = _$InvoiceItemBreakdownCopyWithImpl;
@useResult
$Res call({
 String invoiceId, String invoiceNumber, DateTime invoiceDate, String companyId, String companyName, List<InvoiceItemDetail> items, double subtotal, double totalTax, double totalDiscount, double grandTotal, String currency, int? totalItems, double? averageItemPrice, double? highestItemPrice, double? lowestItemPrice, Map<String, double>? amountByItemType, Map<String, int>? countByItemType
});




}
/// @nodoc
class _$InvoiceItemBreakdownCopyWithImpl<$Res>
    implements $InvoiceItemBreakdownCopyWith<$Res> {
  _$InvoiceItemBreakdownCopyWithImpl(this._self, this._then);

  final InvoiceItemBreakdown _self;
  final $Res Function(InvoiceItemBreakdown) _then;

/// Create a copy of InvoiceItemBreakdown
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? invoiceId = null,Object? invoiceNumber = null,Object? invoiceDate = null,Object? companyId = null,Object? companyName = null,Object? items = null,Object? subtotal = null,Object? totalTax = null,Object? totalDiscount = null,Object? grandTotal = null,Object? currency = null,Object? totalItems = freezed,Object? averageItemPrice = freezed,Object? highestItemPrice = freezed,Object? lowestItemPrice = freezed,Object? amountByItemType = freezed,Object? countByItemType = freezed,}) {
  return _then(_self.copyWith(
invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,invoiceNumber: null == invoiceNumber ? _self.invoiceNumber : invoiceNumber // ignore: cast_nullable_to_non_nullable
as String,invoiceDate: null == invoiceDate ? _self.invoiceDate : invoiceDate // ignore: cast_nullable_to_non_nullable
as DateTime,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,companyName: null == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<InvoiceItemDetail>,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,totalTax: null == totalTax ? _self.totalTax : totalTax // ignore: cast_nullable_to_non_nullable
as double,totalDiscount: null == totalDiscount ? _self.totalDiscount : totalDiscount // ignore: cast_nullable_to_non_nullable
as double,grandTotal: null == grandTotal ? _self.grandTotal : grandTotal // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,totalItems: freezed == totalItems ? _self.totalItems : totalItems // ignore: cast_nullable_to_non_nullable
as int?,averageItemPrice: freezed == averageItemPrice ? _self.averageItemPrice : averageItemPrice // ignore: cast_nullable_to_non_nullable
as double?,highestItemPrice: freezed == highestItemPrice ? _self.highestItemPrice : highestItemPrice // ignore: cast_nullable_to_non_nullable
as double?,lowestItemPrice: freezed == lowestItemPrice ? _self.lowestItemPrice : lowestItemPrice // ignore: cast_nullable_to_non_nullable
as double?,amountByItemType: freezed == amountByItemType ? _self.amountByItemType : amountByItemType // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,countByItemType: freezed == countByItemType ? _self.countByItemType : countByItemType // ignore: cast_nullable_to_non_nullable
as Map<String, int>?,
  ));
}

}


/// Adds pattern-matching-related methods to [InvoiceItemBreakdown].
extension InvoiceItemBreakdownPatterns on InvoiceItemBreakdown {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InvoiceItemBreakdown value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InvoiceItemBreakdown() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InvoiceItemBreakdown value)  $default,){
final _that = this;
switch (_that) {
case _InvoiceItemBreakdown():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InvoiceItemBreakdown value)?  $default,){
final _that = this;
switch (_that) {
case _InvoiceItemBreakdown() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String invoiceId,  String invoiceNumber,  DateTime invoiceDate,  String companyId,  String companyName,  List<InvoiceItemDetail> items,  double subtotal,  double totalTax,  double totalDiscount,  double grandTotal,  String currency,  int? totalItems,  double? averageItemPrice,  double? highestItemPrice,  double? lowestItemPrice,  Map<String, double>? amountByItemType,  Map<String, int>? countByItemType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InvoiceItemBreakdown() when $default != null:
return $default(_that.invoiceId,_that.invoiceNumber,_that.invoiceDate,_that.companyId,_that.companyName,_that.items,_that.subtotal,_that.totalTax,_that.totalDiscount,_that.grandTotal,_that.currency,_that.totalItems,_that.averageItemPrice,_that.highestItemPrice,_that.lowestItemPrice,_that.amountByItemType,_that.countByItemType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String invoiceId,  String invoiceNumber,  DateTime invoiceDate,  String companyId,  String companyName,  List<InvoiceItemDetail> items,  double subtotal,  double totalTax,  double totalDiscount,  double grandTotal,  String currency,  int? totalItems,  double? averageItemPrice,  double? highestItemPrice,  double? lowestItemPrice,  Map<String, double>? amountByItemType,  Map<String, int>? countByItemType)  $default,) {final _that = this;
switch (_that) {
case _InvoiceItemBreakdown():
return $default(_that.invoiceId,_that.invoiceNumber,_that.invoiceDate,_that.companyId,_that.companyName,_that.items,_that.subtotal,_that.totalTax,_that.totalDiscount,_that.grandTotal,_that.currency,_that.totalItems,_that.averageItemPrice,_that.highestItemPrice,_that.lowestItemPrice,_that.amountByItemType,_that.countByItemType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String invoiceId,  String invoiceNumber,  DateTime invoiceDate,  String companyId,  String companyName,  List<InvoiceItemDetail> items,  double subtotal,  double totalTax,  double totalDiscount,  double grandTotal,  String currency,  int? totalItems,  double? averageItemPrice,  double? highestItemPrice,  double? lowestItemPrice,  Map<String, double>? amountByItemType,  Map<String, int>? countByItemType)?  $default,) {final _that = this;
switch (_that) {
case _InvoiceItemBreakdown() when $default != null:
return $default(_that.invoiceId,_that.invoiceNumber,_that.invoiceDate,_that.companyId,_that.companyName,_that.items,_that.subtotal,_that.totalTax,_that.totalDiscount,_that.grandTotal,_that.currency,_that.totalItems,_that.averageItemPrice,_that.highestItemPrice,_that.lowestItemPrice,_that.amountByItemType,_that.countByItemType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InvoiceItemBreakdown implements InvoiceItemBreakdown {
  const _InvoiceItemBreakdown({required this.invoiceId, required this.invoiceNumber, required this.invoiceDate, required this.companyId, required this.companyName, required final  List<InvoiceItemDetail> items, required this.subtotal, required this.totalTax, required this.totalDiscount, required this.grandTotal, required this.currency, this.totalItems, this.averageItemPrice, this.highestItemPrice, this.lowestItemPrice, final  Map<String, double>? amountByItemType, final  Map<String, int>? countByItemType}): _items = items,_amountByItemType = amountByItemType,_countByItemType = countByItemType;
  factory _InvoiceItemBreakdown.fromJson(Map<String, dynamic> json) => _$InvoiceItemBreakdownFromJson(json);

@override final  String invoiceId;
@override final  String invoiceNumber;
@override final  DateTime invoiceDate;
@override final  String companyId;
@override final  String companyName;
 final  List<InvoiceItemDetail> _items;
@override List<InvoiceItemDetail> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  double subtotal;
@override final  double totalTax;
@override final  double totalDiscount;
@override final  double grandTotal;
@override final  String currency;
// Summary statistics
@override final  int? totalItems;
@override final  double? averageItemPrice;
@override final  double? highestItemPrice;
@override final  double? lowestItemPrice;
// Categorization
 final  Map<String, double>? _amountByItemType;
// Categorization
@override Map<String, double>? get amountByItemType {
  final value = _amountByItemType;
  if (value == null) return null;
  if (_amountByItemType is EqualUnmodifiableMapView) return _amountByItemType;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, int>? _countByItemType;
@override Map<String, int>? get countByItemType {
  final value = _countByItemType;
  if (value == null) return null;
  if (_countByItemType is EqualUnmodifiableMapView) return _countByItemType;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of InvoiceItemBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvoiceItemBreakdownCopyWith<_InvoiceItemBreakdown> get copyWith => __$InvoiceItemBreakdownCopyWithImpl<_InvoiceItemBreakdown>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvoiceItemBreakdownToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvoiceItemBreakdown&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.invoiceNumber, invoiceNumber) || other.invoiceNumber == invoiceNumber)&&(identical(other.invoiceDate, invoiceDate) || other.invoiceDate == invoiceDate)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.totalTax, totalTax) || other.totalTax == totalTax)&&(identical(other.totalDiscount, totalDiscount) || other.totalDiscount == totalDiscount)&&(identical(other.grandTotal, grandTotal) || other.grandTotal == grandTotal)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.totalItems, totalItems) || other.totalItems == totalItems)&&(identical(other.averageItemPrice, averageItemPrice) || other.averageItemPrice == averageItemPrice)&&(identical(other.highestItemPrice, highestItemPrice) || other.highestItemPrice == highestItemPrice)&&(identical(other.lowestItemPrice, lowestItemPrice) || other.lowestItemPrice == lowestItemPrice)&&const DeepCollectionEquality().equals(other._amountByItemType, _amountByItemType)&&const DeepCollectionEquality().equals(other._countByItemType, _countByItemType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,invoiceId,invoiceNumber,invoiceDate,companyId,companyName,const DeepCollectionEquality().hash(_items),subtotal,totalTax,totalDiscount,grandTotal,currency,totalItems,averageItemPrice,highestItemPrice,lowestItemPrice,const DeepCollectionEquality().hash(_amountByItemType),const DeepCollectionEquality().hash(_countByItemType));

@override
String toString() {
  return 'InvoiceItemBreakdown(invoiceId: $invoiceId, invoiceNumber: $invoiceNumber, invoiceDate: $invoiceDate, companyId: $companyId, companyName: $companyName, items: $items, subtotal: $subtotal, totalTax: $totalTax, totalDiscount: $totalDiscount, grandTotal: $grandTotal, currency: $currency, totalItems: $totalItems, averageItemPrice: $averageItemPrice, highestItemPrice: $highestItemPrice, lowestItemPrice: $lowestItemPrice, amountByItemType: $amountByItemType, countByItemType: $countByItemType)';
}


}

/// @nodoc
abstract mixin class _$InvoiceItemBreakdownCopyWith<$Res> implements $InvoiceItemBreakdownCopyWith<$Res> {
  factory _$InvoiceItemBreakdownCopyWith(_InvoiceItemBreakdown value, $Res Function(_InvoiceItemBreakdown) _then) = __$InvoiceItemBreakdownCopyWithImpl;
@override @useResult
$Res call({
 String invoiceId, String invoiceNumber, DateTime invoiceDate, String companyId, String companyName, List<InvoiceItemDetail> items, double subtotal, double totalTax, double totalDiscount, double grandTotal, String currency, int? totalItems, double? averageItemPrice, double? highestItemPrice, double? lowestItemPrice, Map<String, double>? amountByItemType, Map<String, int>? countByItemType
});




}
/// @nodoc
class __$InvoiceItemBreakdownCopyWithImpl<$Res>
    implements _$InvoiceItemBreakdownCopyWith<$Res> {
  __$InvoiceItemBreakdownCopyWithImpl(this._self, this._then);

  final _InvoiceItemBreakdown _self;
  final $Res Function(_InvoiceItemBreakdown) _then;

/// Create a copy of InvoiceItemBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? invoiceId = null,Object? invoiceNumber = null,Object? invoiceDate = null,Object? companyId = null,Object? companyName = null,Object? items = null,Object? subtotal = null,Object? totalTax = null,Object? totalDiscount = null,Object? grandTotal = null,Object? currency = null,Object? totalItems = freezed,Object? averageItemPrice = freezed,Object? highestItemPrice = freezed,Object? lowestItemPrice = freezed,Object? amountByItemType = freezed,Object? countByItemType = freezed,}) {
  return _then(_InvoiceItemBreakdown(
invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,invoiceNumber: null == invoiceNumber ? _self.invoiceNumber : invoiceNumber // ignore: cast_nullable_to_non_nullable
as String,invoiceDate: null == invoiceDate ? _self.invoiceDate : invoiceDate // ignore: cast_nullable_to_non_nullable
as DateTime,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,companyName: null == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<InvoiceItemDetail>,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,totalTax: null == totalTax ? _self.totalTax : totalTax // ignore: cast_nullable_to_non_nullable
as double,totalDiscount: null == totalDiscount ? _self.totalDiscount : totalDiscount // ignore: cast_nullable_to_non_nullable
as double,grandTotal: null == grandTotal ? _self.grandTotal : grandTotal // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,totalItems: freezed == totalItems ? _self.totalItems : totalItems // ignore: cast_nullable_to_non_nullable
as int?,averageItemPrice: freezed == averageItemPrice ? _self.averageItemPrice : averageItemPrice // ignore: cast_nullable_to_non_nullable
as double?,highestItemPrice: freezed == highestItemPrice ? _self.highestItemPrice : highestItemPrice // ignore: cast_nullable_to_non_nullable
as double?,lowestItemPrice: freezed == lowestItemPrice ? _self.lowestItemPrice : lowestItemPrice // ignore: cast_nullable_to_non_nullable
as double?,amountByItemType: freezed == amountByItemType ? _self._amountByItemType : amountByItemType // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,countByItemType: freezed == countByItemType ? _self._countByItemType : countByItemType // ignore: cast_nullable_to_non_nullable
as Map<String, int>?,
  ));
}


}


/// @nodoc
mixin _$ItemTypeSummary {

 String get itemType; String get displayName; double get totalAmount; int get itemCount; double get averageAmount; String get currency;// Time period
 DateTime? get periodStart; DateTime? get periodEnd;// Breakdown by sub-type
 Map<String, double>? get amountBySubType; Map<String, int>? get countBySubType;// Trend data
 List<ItemTypeTrendData>? get trendData;
/// Create a copy of ItemTypeSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemTypeSummaryCopyWith<ItemTypeSummary> get copyWith => _$ItemTypeSummaryCopyWithImpl<ItemTypeSummary>(this as ItemTypeSummary, _$identity);

  /// Serializes this ItemTypeSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemTypeSummary&&(identical(other.itemType, itemType) || other.itemType == itemType)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.itemCount, itemCount) || other.itemCount == itemCount)&&(identical(other.averageAmount, averageAmount) || other.averageAmount == averageAmount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&const DeepCollectionEquality().equals(other.amountBySubType, amountBySubType)&&const DeepCollectionEquality().equals(other.countBySubType, countBySubType)&&const DeepCollectionEquality().equals(other.trendData, trendData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,itemType,displayName,totalAmount,itemCount,averageAmount,currency,periodStart,periodEnd,const DeepCollectionEquality().hash(amountBySubType),const DeepCollectionEquality().hash(countBySubType),const DeepCollectionEquality().hash(trendData));

@override
String toString() {
  return 'ItemTypeSummary(itemType: $itemType, displayName: $displayName, totalAmount: $totalAmount, itemCount: $itemCount, averageAmount: $averageAmount, currency: $currency, periodStart: $periodStart, periodEnd: $periodEnd, amountBySubType: $amountBySubType, countBySubType: $countBySubType, trendData: $trendData)';
}


}

/// @nodoc
abstract mixin class $ItemTypeSummaryCopyWith<$Res>  {
  factory $ItemTypeSummaryCopyWith(ItemTypeSummary value, $Res Function(ItemTypeSummary) _then) = _$ItemTypeSummaryCopyWithImpl;
@useResult
$Res call({
 String itemType, String displayName, double totalAmount, int itemCount, double averageAmount, String currency, DateTime? periodStart, DateTime? periodEnd, Map<String, double>? amountBySubType, Map<String, int>? countBySubType, List<ItemTypeTrendData>? trendData
});




}
/// @nodoc
class _$ItemTypeSummaryCopyWithImpl<$Res>
    implements $ItemTypeSummaryCopyWith<$Res> {
  _$ItemTypeSummaryCopyWithImpl(this._self, this._then);

  final ItemTypeSummary _self;
  final $Res Function(ItemTypeSummary) _then;

/// Create a copy of ItemTypeSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? itemType = null,Object? displayName = null,Object? totalAmount = null,Object? itemCount = null,Object? averageAmount = null,Object? currency = null,Object? periodStart = freezed,Object? periodEnd = freezed,Object? amountBySubType = freezed,Object? countBySubType = freezed,Object? trendData = freezed,}) {
  return _then(_self.copyWith(
itemType: null == itemType ? _self.itemType : itemType // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,itemCount: null == itemCount ? _self.itemCount : itemCount // ignore: cast_nullable_to_non_nullable
as int,averageAmount: null == averageAmount ? _self.averageAmount : averageAmount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,periodStart: freezed == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime?,periodEnd: freezed == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,amountBySubType: freezed == amountBySubType ? _self.amountBySubType : amountBySubType // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,countBySubType: freezed == countBySubType ? _self.countBySubType : countBySubType // ignore: cast_nullable_to_non_nullable
as Map<String, int>?,trendData: freezed == trendData ? _self.trendData : trendData // ignore: cast_nullable_to_non_nullable
as List<ItemTypeTrendData>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ItemTypeSummary].
extension ItemTypeSummaryPatterns on ItemTypeSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemTypeSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemTypeSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemTypeSummary value)  $default,){
final _that = this;
switch (_that) {
case _ItemTypeSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemTypeSummary value)?  $default,){
final _that = this;
switch (_that) {
case _ItemTypeSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String itemType,  String displayName,  double totalAmount,  int itemCount,  double averageAmount,  String currency,  DateTime? periodStart,  DateTime? periodEnd,  Map<String, double>? amountBySubType,  Map<String, int>? countBySubType,  List<ItemTypeTrendData>? trendData)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemTypeSummary() when $default != null:
return $default(_that.itemType,_that.displayName,_that.totalAmount,_that.itemCount,_that.averageAmount,_that.currency,_that.periodStart,_that.periodEnd,_that.amountBySubType,_that.countBySubType,_that.trendData);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String itemType,  String displayName,  double totalAmount,  int itemCount,  double averageAmount,  String currency,  DateTime? periodStart,  DateTime? periodEnd,  Map<String, double>? amountBySubType,  Map<String, int>? countBySubType,  List<ItemTypeTrendData>? trendData)  $default,) {final _that = this;
switch (_that) {
case _ItemTypeSummary():
return $default(_that.itemType,_that.displayName,_that.totalAmount,_that.itemCount,_that.averageAmount,_that.currency,_that.periodStart,_that.periodEnd,_that.amountBySubType,_that.countBySubType,_that.trendData);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String itemType,  String displayName,  double totalAmount,  int itemCount,  double averageAmount,  String currency,  DateTime? periodStart,  DateTime? periodEnd,  Map<String, double>? amountBySubType,  Map<String, int>? countBySubType,  List<ItemTypeTrendData>? trendData)?  $default,) {final _that = this;
switch (_that) {
case _ItemTypeSummary() when $default != null:
return $default(_that.itemType,_that.displayName,_that.totalAmount,_that.itemCount,_that.averageAmount,_that.currency,_that.periodStart,_that.periodEnd,_that.amountBySubType,_that.countBySubType,_that.trendData);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ItemTypeSummary implements ItemTypeSummary {
  const _ItemTypeSummary({required this.itemType, required this.displayName, required this.totalAmount, required this.itemCount, required this.averageAmount, required this.currency, this.periodStart, this.periodEnd, final  Map<String, double>? amountBySubType, final  Map<String, int>? countBySubType, final  List<ItemTypeTrendData>? trendData}): _amountBySubType = amountBySubType,_countBySubType = countBySubType,_trendData = trendData;
  factory _ItemTypeSummary.fromJson(Map<String, dynamic> json) => _$ItemTypeSummaryFromJson(json);

@override final  String itemType;
@override final  String displayName;
@override final  double totalAmount;
@override final  int itemCount;
@override final  double averageAmount;
@override final  String currency;
// Time period
@override final  DateTime? periodStart;
@override final  DateTime? periodEnd;
// Breakdown by sub-type
 final  Map<String, double>? _amountBySubType;
// Breakdown by sub-type
@override Map<String, double>? get amountBySubType {
  final value = _amountBySubType;
  if (value == null) return null;
  if (_amountBySubType is EqualUnmodifiableMapView) return _amountBySubType;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, int>? _countBySubType;
@override Map<String, int>? get countBySubType {
  final value = _countBySubType;
  if (value == null) return null;
  if (_countBySubType is EqualUnmodifiableMapView) return _countBySubType;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

// Trend data
 final  List<ItemTypeTrendData>? _trendData;
// Trend data
@override List<ItemTypeTrendData>? get trendData {
  final value = _trendData;
  if (value == null) return null;
  if (_trendData is EqualUnmodifiableListView) return _trendData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of ItemTypeSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemTypeSummaryCopyWith<_ItemTypeSummary> get copyWith => __$ItemTypeSummaryCopyWithImpl<_ItemTypeSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemTypeSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemTypeSummary&&(identical(other.itemType, itemType) || other.itemType == itemType)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.itemCount, itemCount) || other.itemCount == itemCount)&&(identical(other.averageAmount, averageAmount) || other.averageAmount == averageAmount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&const DeepCollectionEquality().equals(other._amountBySubType, _amountBySubType)&&const DeepCollectionEquality().equals(other._countBySubType, _countBySubType)&&const DeepCollectionEquality().equals(other._trendData, _trendData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,itemType,displayName,totalAmount,itemCount,averageAmount,currency,periodStart,periodEnd,const DeepCollectionEquality().hash(_amountBySubType),const DeepCollectionEquality().hash(_countBySubType),const DeepCollectionEquality().hash(_trendData));

@override
String toString() {
  return 'ItemTypeSummary(itemType: $itemType, displayName: $displayName, totalAmount: $totalAmount, itemCount: $itemCount, averageAmount: $averageAmount, currency: $currency, periodStart: $periodStart, periodEnd: $periodEnd, amountBySubType: $amountBySubType, countBySubType: $countBySubType, trendData: $trendData)';
}


}

/// @nodoc
abstract mixin class _$ItemTypeSummaryCopyWith<$Res> implements $ItemTypeSummaryCopyWith<$Res> {
  factory _$ItemTypeSummaryCopyWith(_ItemTypeSummary value, $Res Function(_ItemTypeSummary) _then) = __$ItemTypeSummaryCopyWithImpl;
@override @useResult
$Res call({
 String itemType, String displayName, double totalAmount, int itemCount, double averageAmount, String currency, DateTime? periodStart, DateTime? periodEnd, Map<String, double>? amountBySubType, Map<String, int>? countBySubType, List<ItemTypeTrendData>? trendData
});




}
/// @nodoc
class __$ItemTypeSummaryCopyWithImpl<$Res>
    implements _$ItemTypeSummaryCopyWith<$Res> {
  __$ItemTypeSummaryCopyWithImpl(this._self, this._then);

  final _ItemTypeSummary _self;
  final $Res Function(_ItemTypeSummary) _then;

/// Create a copy of ItemTypeSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? itemType = null,Object? displayName = null,Object? totalAmount = null,Object? itemCount = null,Object? averageAmount = null,Object? currency = null,Object? periodStart = freezed,Object? periodEnd = freezed,Object? amountBySubType = freezed,Object? countBySubType = freezed,Object? trendData = freezed,}) {
  return _then(_ItemTypeSummary(
itemType: null == itemType ? _self.itemType : itemType // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,itemCount: null == itemCount ? _self.itemCount : itemCount // ignore: cast_nullable_to_non_nullable
as int,averageAmount: null == averageAmount ? _self.averageAmount : averageAmount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,periodStart: freezed == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime?,periodEnd: freezed == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,amountBySubType: freezed == amountBySubType ? _self._amountBySubType : amountBySubType // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,countBySubType: freezed == countBySubType ? _self._countBySubType : countBySubType // ignore: cast_nullable_to_non_nullable
as Map<String, int>?,trendData: freezed == trendData ? _self._trendData : trendData // ignore: cast_nullable_to_non_nullable
as List<ItemTypeTrendData>?,
  ));
}


}


/// @nodoc
mixin _$ItemTypeTrendData {

 DateTime get date; double get amount; int get count; String get itemType;
/// Create a copy of ItemTypeTrendData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemTypeTrendDataCopyWith<ItemTypeTrendData> get copyWith => _$ItemTypeTrendDataCopyWithImpl<ItemTypeTrendData>(this as ItemTypeTrendData, _$identity);

  /// Serializes this ItemTypeTrendData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemTypeTrendData&&(identical(other.date, date) || other.date == date)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.count, count) || other.count == count)&&(identical(other.itemType, itemType) || other.itemType == itemType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,amount,count,itemType);

@override
String toString() {
  return 'ItemTypeTrendData(date: $date, amount: $amount, count: $count, itemType: $itemType)';
}


}

/// @nodoc
abstract mixin class $ItemTypeTrendDataCopyWith<$Res>  {
  factory $ItemTypeTrendDataCopyWith(ItemTypeTrendData value, $Res Function(ItemTypeTrendData) _then) = _$ItemTypeTrendDataCopyWithImpl;
@useResult
$Res call({
 DateTime date, double amount, int count, String itemType
});




}
/// @nodoc
class _$ItemTypeTrendDataCopyWithImpl<$Res>
    implements $ItemTypeTrendDataCopyWith<$Res> {
  _$ItemTypeTrendDataCopyWithImpl(this._self, this._then);

  final ItemTypeTrendData _self;
  final $Res Function(ItemTypeTrendData) _then;

/// Create a copy of ItemTypeTrendData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? amount = null,Object? count = null,Object? itemType = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,itemType: null == itemType ? _self.itemType : itemType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ItemTypeTrendData].
extension ItemTypeTrendDataPatterns on ItemTypeTrendData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemTypeTrendData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemTypeTrendData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemTypeTrendData value)  $default,){
final _that = this;
switch (_that) {
case _ItemTypeTrendData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemTypeTrendData value)?  $default,){
final _that = this;
switch (_that) {
case _ItemTypeTrendData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  double amount,  int count,  String itemType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemTypeTrendData() when $default != null:
return $default(_that.date,_that.amount,_that.count,_that.itemType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  double amount,  int count,  String itemType)  $default,) {final _that = this;
switch (_that) {
case _ItemTypeTrendData():
return $default(_that.date,_that.amount,_that.count,_that.itemType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  double amount,  int count,  String itemType)?  $default,) {final _that = this;
switch (_that) {
case _ItemTypeTrendData() when $default != null:
return $default(_that.date,_that.amount,_that.count,_that.itemType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ItemTypeTrendData implements ItemTypeTrendData {
  const _ItemTypeTrendData({required this.date, required this.amount, required this.count, required this.itemType});
  factory _ItemTypeTrendData.fromJson(Map<String, dynamic> json) => _$ItemTypeTrendDataFromJson(json);

@override final  DateTime date;
@override final  double amount;
@override final  int count;
@override final  String itemType;

/// Create a copy of ItemTypeTrendData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemTypeTrendDataCopyWith<_ItemTypeTrendData> get copyWith => __$ItemTypeTrendDataCopyWithImpl<_ItemTypeTrendData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemTypeTrendDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemTypeTrendData&&(identical(other.date, date) || other.date == date)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.count, count) || other.count == count)&&(identical(other.itemType, itemType) || other.itemType == itemType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,amount,count,itemType);

@override
String toString() {
  return 'ItemTypeTrendData(date: $date, amount: $amount, count: $count, itemType: $itemType)';
}


}

/// @nodoc
abstract mixin class _$ItemTypeTrendDataCopyWith<$Res> implements $ItemTypeTrendDataCopyWith<$Res> {
  factory _$ItemTypeTrendDataCopyWith(_ItemTypeTrendData value, $Res Function(_ItemTypeTrendData) _then) = __$ItemTypeTrendDataCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, double amount, int count, String itemType
});




}
/// @nodoc
class __$ItemTypeTrendDataCopyWithImpl<$Res>
    implements _$ItemTypeTrendDataCopyWith<$Res> {
  __$ItemTypeTrendDataCopyWithImpl(this._self, this._then);

  final _ItemTypeTrendData _self;
  final $Res Function(_ItemTypeTrendData) _then;

/// Create a copy of ItemTypeTrendData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? amount = null,Object? count = null,Object? itemType = null,}) {
  return _then(_ItemTypeTrendData(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,itemType: null == itemType ? _self.itemType : itemType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$OverageChargeDetail {

 String get id; String get companyId; String get planFeatureId; String get planFeatureName; double get includedAmount; double get usedAmount; double get overageAmount; double get overageRate; double get chargeAmount; DateTime get periodStart; DateTime get periodEnd; String get currency; String? get invoiceId; String? get invoiceNumber; bool? get isInvoiced; DateTime? get invoicedAt; Map<String, dynamic>? get usageMetadata; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of OverageChargeDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OverageChargeDetailCopyWith<OverageChargeDetail> get copyWith => _$OverageChargeDetailCopyWithImpl<OverageChargeDetail>(this as OverageChargeDetail, _$identity);

  /// Serializes this OverageChargeDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OverageChargeDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.planFeatureId, planFeatureId) || other.planFeatureId == planFeatureId)&&(identical(other.planFeatureName, planFeatureName) || other.planFeatureName == planFeatureName)&&(identical(other.includedAmount, includedAmount) || other.includedAmount == includedAmount)&&(identical(other.usedAmount, usedAmount) || other.usedAmount == usedAmount)&&(identical(other.overageAmount, overageAmount) || other.overageAmount == overageAmount)&&(identical(other.overageRate, overageRate) || other.overageRate == overageRate)&&(identical(other.chargeAmount, chargeAmount) || other.chargeAmount == chargeAmount)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.invoiceNumber, invoiceNumber) || other.invoiceNumber == invoiceNumber)&&(identical(other.isInvoiced, isInvoiced) || other.isInvoiced == isInvoiced)&&(identical(other.invoicedAt, invoicedAt) || other.invoicedAt == invoicedAt)&&const DeepCollectionEquality().equals(other.usageMetadata, usageMetadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,companyId,planFeatureId,planFeatureName,includedAmount,usedAmount,overageAmount,overageRate,chargeAmount,periodStart,periodEnd,currency,invoiceId,invoiceNumber,isInvoiced,invoicedAt,const DeepCollectionEquality().hash(usageMetadata),createdAt,updatedAt]);

@override
String toString() {
  return 'OverageChargeDetail(id: $id, companyId: $companyId, planFeatureId: $planFeatureId, planFeatureName: $planFeatureName, includedAmount: $includedAmount, usedAmount: $usedAmount, overageAmount: $overageAmount, overageRate: $overageRate, chargeAmount: $chargeAmount, periodStart: $periodStart, periodEnd: $periodEnd, currency: $currency, invoiceId: $invoiceId, invoiceNumber: $invoiceNumber, isInvoiced: $isInvoiced, invoicedAt: $invoicedAt, usageMetadata: $usageMetadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $OverageChargeDetailCopyWith<$Res>  {
  factory $OverageChargeDetailCopyWith(OverageChargeDetail value, $Res Function(OverageChargeDetail) _then) = _$OverageChargeDetailCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String planFeatureId, String planFeatureName, double includedAmount, double usedAmount, double overageAmount, double overageRate, double chargeAmount, DateTime periodStart, DateTime periodEnd, String currency, String? invoiceId, String? invoiceNumber, bool? isInvoiced, DateTime? invoicedAt, Map<String, dynamic>? usageMetadata, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$OverageChargeDetailCopyWithImpl<$Res>
    implements $OverageChargeDetailCopyWith<$Res> {
  _$OverageChargeDetailCopyWithImpl(this._self, this._then);

  final OverageChargeDetail _self;
  final $Res Function(OverageChargeDetail) _then;

/// Create a copy of OverageChargeDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? planFeatureId = null,Object? planFeatureName = null,Object? includedAmount = null,Object? usedAmount = null,Object? overageAmount = null,Object? overageRate = null,Object? chargeAmount = null,Object? periodStart = null,Object? periodEnd = null,Object? currency = null,Object? invoiceId = freezed,Object? invoiceNumber = freezed,Object? isInvoiced = freezed,Object? invoicedAt = freezed,Object? usageMetadata = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,planFeatureId: null == planFeatureId ? _self.planFeatureId : planFeatureId // ignore: cast_nullable_to_non_nullable
as String,planFeatureName: null == planFeatureName ? _self.planFeatureName : planFeatureName // ignore: cast_nullable_to_non_nullable
as String,includedAmount: null == includedAmount ? _self.includedAmount : includedAmount // ignore: cast_nullable_to_non_nullable
as double,usedAmount: null == usedAmount ? _self.usedAmount : usedAmount // ignore: cast_nullable_to_non_nullable
as double,overageAmount: null == overageAmount ? _self.overageAmount : overageAmount // ignore: cast_nullable_to_non_nullable
as double,overageRate: null == overageRate ? _self.overageRate : overageRate // ignore: cast_nullable_to_non_nullable
as double,chargeAmount: null == chargeAmount ? _self.chargeAmount : chargeAmount // ignore: cast_nullable_to_non_nullable
as double,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,invoiceId: freezed == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String?,invoiceNumber: freezed == invoiceNumber ? _self.invoiceNumber : invoiceNumber // ignore: cast_nullable_to_non_nullable
as String?,isInvoiced: freezed == isInvoiced ? _self.isInvoiced : isInvoiced // ignore: cast_nullable_to_non_nullable
as bool?,invoicedAt: freezed == invoicedAt ? _self.invoicedAt : invoicedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,usageMetadata: freezed == usageMetadata ? _self.usageMetadata : usageMetadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [OverageChargeDetail].
extension OverageChargeDetailPatterns on OverageChargeDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OverageChargeDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OverageChargeDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OverageChargeDetail value)  $default,){
final _that = this;
switch (_that) {
case _OverageChargeDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OverageChargeDetail value)?  $default,){
final _that = this;
switch (_that) {
case _OverageChargeDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String planFeatureId,  String planFeatureName,  double includedAmount,  double usedAmount,  double overageAmount,  double overageRate,  double chargeAmount,  DateTime periodStart,  DateTime periodEnd,  String currency,  String? invoiceId,  String? invoiceNumber,  bool? isInvoiced,  DateTime? invoicedAt,  Map<String, dynamic>? usageMetadata,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OverageChargeDetail() when $default != null:
return $default(_that.id,_that.companyId,_that.planFeatureId,_that.planFeatureName,_that.includedAmount,_that.usedAmount,_that.overageAmount,_that.overageRate,_that.chargeAmount,_that.periodStart,_that.periodEnd,_that.currency,_that.invoiceId,_that.invoiceNumber,_that.isInvoiced,_that.invoicedAt,_that.usageMetadata,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String planFeatureId,  String planFeatureName,  double includedAmount,  double usedAmount,  double overageAmount,  double overageRate,  double chargeAmount,  DateTime periodStart,  DateTime periodEnd,  String currency,  String? invoiceId,  String? invoiceNumber,  bool? isInvoiced,  DateTime? invoicedAt,  Map<String, dynamic>? usageMetadata,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _OverageChargeDetail():
return $default(_that.id,_that.companyId,_that.planFeatureId,_that.planFeatureName,_that.includedAmount,_that.usedAmount,_that.overageAmount,_that.overageRate,_that.chargeAmount,_that.periodStart,_that.periodEnd,_that.currency,_that.invoiceId,_that.invoiceNumber,_that.isInvoiced,_that.invoicedAt,_that.usageMetadata,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String planFeatureId,  String planFeatureName,  double includedAmount,  double usedAmount,  double overageAmount,  double overageRate,  double chargeAmount,  DateTime periodStart,  DateTime periodEnd,  String currency,  String? invoiceId,  String? invoiceNumber,  bool? isInvoiced,  DateTime? invoicedAt,  Map<String, dynamic>? usageMetadata,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _OverageChargeDetail() when $default != null:
return $default(_that.id,_that.companyId,_that.planFeatureId,_that.planFeatureName,_that.includedAmount,_that.usedAmount,_that.overageAmount,_that.overageRate,_that.chargeAmount,_that.periodStart,_that.periodEnd,_that.currency,_that.invoiceId,_that.invoiceNumber,_that.isInvoiced,_that.invoicedAt,_that.usageMetadata,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OverageChargeDetail implements OverageChargeDetail {
  const _OverageChargeDetail({required this.id, required this.companyId, required this.planFeatureId, required this.planFeatureName, required this.includedAmount, required this.usedAmount, required this.overageAmount, required this.overageRate, required this.chargeAmount, required this.periodStart, required this.periodEnd, required this.currency, this.invoiceId, this.invoiceNumber, this.isInvoiced, this.invoicedAt, final  Map<String, dynamic>? usageMetadata, this.createdAt, this.updatedAt}): _usageMetadata = usageMetadata;
  factory _OverageChargeDetail.fromJson(Map<String, dynamic> json) => _$OverageChargeDetailFromJson(json);

@override final  String id;
@override final  String companyId;
@override final  String planFeatureId;
@override final  String planFeatureName;
@override final  double includedAmount;
@override final  double usedAmount;
@override final  double overageAmount;
@override final  double overageRate;
@override final  double chargeAmount;
@override final  DateTime periodStart;
@override final  DateTime periodEnd;
@override final  String currency;
@override final  String? invoiceId;
@override final  String? invoiceNumber;
@override final  bool? isInvoiced;
@override final  DateTime? invoicedAt;
 final  Map<String, dynamic>? _usageMetadata;
@override Map<String, dynamic>? get usageMetadata {
  final value = _usageMetadata;
  if (value == null) return null;
  if (_usageMetadata is EqualUnmodifiableMapView) return _usageMetadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of OverageChargeDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OverageChargeDetailCopyWith<_OverageChargeDetail> get copyWith => __$OverageChargeDetailCopyWithImpl<_OverageChargeDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OverageChargeDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OverageChargeDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.planFeatureId, planFeatureId) || other.planFeatureId == planFeatureId)&&(identical(other.planFeatureName, planFeatureName) || other.planFeatureName == planFeatureName)&&(identical(other.includedAmount, includedAmount) || other.includedAmount == includedAmount)&&(identical(other.usedAmount, usedAmount) || other.usedAmount == usedAmount)&&(identical(other.overageAmount, overageAmount) || other.overageAmount == overageAmount)&&(identical(other.overageRate, overageRate) || other.overageRate == overageRate)&&(identical(other.chargeAmount, chargeAmount) || other.chargeAmount == chargeAmount)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.invoiceNumber, invoiceNumber) || other.invoiceNumber == invoiceNumber)&&(identical(other.isInvoiced, isInvoiced) || other.isInvoiced == isInvoiced)&&(identical(other.invoicedAt, invoicedAt) || other.invoicedAt == invoicedAt)&&const DeepCollectionEquality().equals(other._usageMetadata, _usageMetadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,companyId,planFeatureId,planFeatureName,includedAmount,usedAmount,overageAmount,overageRate,chargeAmount,periodStart,periodEnd,currency,invoiceId,invoiceNumber,isInvoiced,invoicedAt,const DeepCollectionEquality().hash(_usageMetadata),createdAt,updatedAt]);

@override
String toString() {
  return 'OverageChargeDetail(id: $id, companyId: $companyId, planFeatureId: $planFeatureId, planFeatureName: $planFeatureName, includedAmount: $includedAmount, usedAmount: $usedAmount, overageAmount: $overageAmount, overageRate: $overageRate, chargeAmount: $chargeAmount, periodStart: $periodStart, periodEnd: $periodEnd, currency: $currency, invoiceId: $invoiceId, invoiceNumber: $invoiceNumber, isInvoiced: $isInvoiced, invoicedAt: $invoicedAt, usageMetadata: $usageMetadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$OverageChargeDetailCopyWith<$Res> implements $OverageChargeDetailCopyWith<$Res> {
  factory _$OverageChargeDetailCopyWith(_OverageChargeDetail value, $Res Function(_OverageChargeDetail) _then) = __$OverageChargeDetailCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String planFeatureId, String planFeatureName, double includedAmount, double usedAmount, double overageAmount, double overageRate, double chargeAmount, DateTime periodStart, DateTime periodEnd, String currency, String? invoiceId, String? invoiceNumber, bool? isInvoiced, DateTime? invoicedAt, Map<String, dynamic>? usageMetadata, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$OverageChargeDetailCopyWithImpl<$Res>
    implements _$OverageChargeDetailCopyWith<$Res> {
  __$OverageChargeDetailCopyWithImpl(this._self, this._then);

  final _OverageChargeDetail _self;
  final $Res Function(_OverageChargeDetail) _then;

/// Create a copy of OverageChargeDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? planFeatureId = null,Object? planFeatureName = null,Object? includedAmount = null,Object? usedAmount = null,Object? overageAmount = null,Object? overageRate = null,Object? chargeAmount = null,Object? periodStart = null,Object? periodEnd = null,Object? currency = null,Object? invoiceId = freezed,Object? invoiceNumber = freezed,Object? isInvoiced = freezed,Object? invoicedAt = freezed,Object? usageMetadata = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_OverageChargeDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,planFeatureId: null == planFeatureId ? _self.planFeatureId : planFeatureId // ignore: cast_nullable_to_non_nullable
as String,planFeatureName: null == planFeatureName ? _self.planFeatureName : planFeatureName // ignore: cast_nullable_to_non_nullable
as String,includedAmount: null == includedAmount ? _self.includedAmount : includedAmount // ignore: cast_nullable_to_non_nullable
as double,usedAmount: null == usedAmount ? _self.usedAmount : usedAmount // ignore: cast_nullable_to_non_nullable
as double,overageAmount: null == overageAmount ? _self.overageAmount : overageAmount // ignore: cast_nullable_to_non_nullable
as double,overageRate: null == overageRate ? _self.overageRate : overageRate // ignore: cast_nullable_to_non_nullable
as double,chargeAmount: null == chargeAmount ? _self.chargeAmount : chargeAmount // ignore: cast_nullable_to_non_nullable
as double,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,invoiceId: freezed == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String?,invoiceNumber: freezed == invoiceNumber ? _self.invoiceNumber : invoiceNumber // ignore: cast_nullable_to_non_nullable
as String?,isInvoiced: freezed == isInvoiced ? _self.isInvoiced : isInvoiced // ignore: cast_nullable_to_non_nullable
as bool?,invoicedAt: freezed == invoicedAt ? _self.invoicedAt : invoicedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,usageMetadata: freezed == usageMetadata ? _self._usageMetadata : usageMetadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$UsageBasedCharge {

 String get id; String get companyId; String get metricName; String get metricUnit; double get includedUnits; double get usedUnits; double get overageUnits; double get unitPrice; double get totalCharge; DateTime get periodStart; DateTime get periodEnd; String get currency; String? get invoiceId; String? get invoiceNumber; bool? get isInvoiced; DateTime? get invoicedAt; Map<String, dynamic>? get usageData; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of UsageBasedCharge
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UsageBasedChargeCopyWith<UsageBasedCharge> get copyWith => _$UsageBasedChargeCopyWithImpl<UsageBasedCharge>(this as UsageBasedCharge, _$identity);

  /// Serializes this UsageBasedCharge to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UsageBasedCharge&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.metricName, metricName) || other.metricName == metricName)&&(identical(other.metricUnit, metricUnit) || other.metricUnit == metricUnit)&&(identical(other.includedUnits, includedUnits) || other.includedUnits == includedUnits)&&(identical(other.usedUnits, usedUnits) || other.usedUnits == usedUnits)&&(identical(other.overageUnits, overageUnits) || other.overageUnits == overageUnits)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.totalCharge, totalCharge) || other.totalCharge == totalCharge)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.invoiceNumber, invoiceNumber) || other.invoiceNumber == invoiceNumber)&&(identical(other.isInvoiced, isInvoiced) || other.isInvoiced == isInvoiced)&&(identical(other.invoicedAt, invoicedAt) || other.invoicedAt == invoicedAt)&&const DeepCollectionEquality().equals(other.usageData, usageData)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,companyId,metricName,metricUnit,includedUnits,usedUnits,overageUnits,unitPrice,totalCharge,periodStart,periodEnd,currency,invoiceId,invoiceNumber,isInvoiced,invoicedAt,const DeepCollectionEquality().hash(usageData),createdAt,updatedAt]);

@override
String toString() {
  return 'UsageBasedCharge(id: $id, companyId: $companyId, metricName: $metricName, metricUnit: $metricUnit, includedUnits: $includedUnits, usedUnits: $usedUnits, overageUnits: $overageUnits, unitPrice: $unitPrice, totalCharge: $totalCharge, periodStart: $periodStart, periodEnd: $periodEnd, currency: $currency, invoiceId: $invoiceId, invoiceNumber: $invoiceNumber, isInvoiced: $isInvoiced, invoicedAt: $invoicedAt, usageData: $usageData, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $UsageBasedChargeCopyWith<$Res>  {
  factory $UsageBasedChargeCopyWith(UsageBasedCharge value, $Res Function(UsageBasedCharge) _then) = _$UsageBasedChargeCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, String metricName, String metricUnit, double includedUnits, double usedUnits, double overageUnits, double unitPrice, double totalCharge, DateTime periodStart, DateTime periodEnd, String currency, String? invoiceId, String? invoiceNumber, bool? isInvoiced, DateTime? invoicedAt, Map<String, dynamic>? usageData, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$UsageBasedChargeCopyWithImpl<$Res>
    implements $UsageBasedChargeCopyWith<$Res> {
  _$UsageBasedChargeCopyWithImpl(this._self, this._then);

  final UsageBasedCharge _self;
  final $Res Function(UsageBasedCharge) _then;

/// Create a copy of UsageBasedCharge
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? metricName = null,Object? metricUnit = null,Object? includedUnits = null,Object? usedUnits = null,Object? overageUnits = null,Object? unitPrice = null,Object? totalCharge = null,Object? periodStart = null,Object? periodEnd = null,Object? currency = null,Object? invoiceId = freezed,Object? invoiceNumber = freezed,Object? isInvoiced = freezed,Object? invoicedAt = freezed,Object? usageData = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,metricName: null == metricName ? _self.metricName : metricName // ignore: cast_nullable_to_non_nullable
as String,metricUnit: null == metricUnit ? _self.metricUnit : metricUnit // ignore: cast_nullable_to_non_nullable
as String,includedUnits: null == includedUnits ? _self.includedUnits : includedUnits // ignore: cast_nullable_to_non_nullable
as double,usedUnits: null == usedUnits ? _self.usedUnits : usedUnits // ignore: cast_nullable_to_non_nullable
as double,overageUnits: null == overageUnits ? _self.overageUnits : overageUnits // ignore: cast_nullable_to_non_nullable
as double,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,totalCharge: null == totalCharge ? _self.totalCharge : totalCharge // ignore: cast_nullable_to_non_nullable
as double,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,invoiceId: freezed == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String?,invoiceNumber: freezed == invoiceNumber ? _self.invoiceNumber : invoiceNumber // ignore: cast_nullable_to_non_nullable
as String?,isInvoiced: freezed == isInvoiced ? _self.isInvoiced : isInvoiced // ignore: cast_nullable_to_non_nullable
as bool?,invoicedAt: freezed == invoicedAt ? _self.invoicedAt : invoicedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,usageData: freezed == usageData ? _self.usageData : usageData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [UsageBasedCharge].
extension UsageBasedChargePatterns on UsageBasedCharge {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UsageBasedCharge value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UsageBasedCharge() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UsageBasedCharge value)  $default,){
final _that = this;
switch (_that) {
case _UsageBasedCharge():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UsageBasedCharge value)?  $default,){
final _that = this;
switch (_that) {
case _UsageBasedCharge() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  String metricName,  String metricUnit,  double includedUnits,  double usedUnits,  double overageUnits,  double unitPrice,  double totalCharge,  DateTime periodStart,  DateTime periodEnd,  String currency,  String? invoiceId,  String? invoiceNumber,  bool? isInvoiced,  DateTime? invoicedAt,  Map<String, dynamic>? usageData,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UsageBasedCharge() when $default != null:
return $default(_that.id,_that.companyId,_that.metricName,_that.metricUnit,_that.includedUnits,_that.usedUnits,_that.overageUnits,_that.unitPrice,_that.totalCharge,_that.periodStart,_that.periodEnd,_that.currency,_that.invoiceId,_that.invoiceNumber,_that.isInvoiced,_that.invoicedAt,_that.usageData,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  String metricName,  String metricUnit,  double includedUnits,  double usedUnits,  double overageUnits,  double unitPrice,  double totalCharge,  DateTime periodStart,  DateTime periodEnd,  String currency,  String? invoiceId,  String? invoiceNumber,  bool? isInvoiced,  DateTime? invoicedAt,  Map<String, dynamic>? usageData,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _UsageBasedCharge():
return $default(_that.id,_that.companyId,_that.metricName,_that.metricUnit,_that.includedUnits,_that.usedUnits,_that.overageUnits,_that.unitPrice,_that.totalCharge,_that.periodStart,_that.periodEnd,_that.currency,_that.invoiceId,_that.invoiceNumber,_that.isInvoiced,_that.invoicedAt,_that.usageData,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  String metricName,  String metricUnit,  double includedUnits,  double usedUnits,  double overageUnits,  double unitPrice,  double totalCharge,  DateTime periodStart,  DateTime periodEnd,  String currency,  String? invoiceId,  String? invoiceNumber,  bool? isInvoiced,  DateTime? invoicedAt,  Map<String, dynamic>? usageData,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _UsageBasedCharge() when $default != null:
return $default(_that.id,_that.companyId,_that.metricName,_that.metricUnit,_that.includedUnits,_that.usedUnits,_that.overageUnits,_that.unitPrice,_that.totalCharge,_that.periodStart,_that.periodEnd,_that.currency,_that.invoiceId,_that.invoiceNumber,_that.isInvoiced,_that.invoicedAt,_that.usageData,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UsageBasedCharge implements UsageBasedCharge {
  const _UsageBasedCharge({required this.id, required this.companyId, required this.metricName, required this.metricUnit, required this.includedUnits, required this.usedUnits, required this.overageUnits, required this.unitPrice, required this.totalCharge, required this.periodStart, required this.periodEnd, required this.currency, this.invoiceId, this.invoiceNumber, this.isInvoiced, this.invoicedAt, final  Map<String, dynamic>? usageData, this.createdAt, this.updatedAt}): _usageData = usageData;
  factory _UsageBasedCharge.fromJson(Map<String, dynamic> json) => _$UsageBasedChargeFromJson(json);

@override final  String id;
@override final  String companyId;
@override final  String metricName;
@override final  String metricUnit;
@override final  double includedUnits;
@override final  double usedUnits;
@override final  double overageUnits;
@override final  double unitPrice;
@override final  double totalCharge;
@override final  DateTime periodStart;
@override final  DateTime periodEnd;
@override final  String currency;
@override final  String? invoiceId;
@override final  String? invoiceNumber;
@override final  bool? isInvoiced;
@override final  DateTime? invoicedAt;
 final  Map<String, dynamic>? _usageData;
@override Map<String, dynamic>? get usageData {
  final value = _usageData;
  if (value == null) return null;
  if (_usageData is EqualUnmodifiableMapView) return _usageData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of UsageBasedCharge
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UsageBasedChargeCopyWith<_UsageBasedCharge> get copyWith => __$UsageBasedChargeCopyWithImpl<_UsageBasedCharge>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UsageBasedChargeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UsageBasedCharge&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.metricName, metricName) || other.metricName == metricName)&&(identical(other.metricUnit, metricUnit) || other.metricUnit == metricUnit)&&(identical(other.includedUnits, includedUnits) || other.includedUnits == includedUnits)&&(identical(other.usedUnits, usedUnits) || other.usedUnits == usedUnits)&&(identical(other.overageUnits, overageUnits) || other.overageUnits == overageUnits)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.totalCharge, totalCharge) || other.totalCharge == totalCharge)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.invoiceNumber, invoiceNumber) || other.invoiceNumber == invoiceNumber)&&(identical(other.isInvoiced, isInvoiced) || other.isInvoiced == isInvoiced)&&(identical(other.invoicedAt, invoicedAt) || other.invoicedAt == invoicedAt)&&const DeepCollectionEquality().equals(other._usageData, _usageData)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,companyId,metricName,metricUnit,includedUnits,usedUnits,overageUnits,unitPrice,totalCharge,periodStart,periodEnd,currency,invoiceId,invoiceNumber,isInvoiced,invoicedAt,const DeepCollectionEquality().hash(_usageData),createdAt,updatedAt]);

@override
String toString() {
  return 'UsageBasedCharge(id: $id, companyId: $companyId, metricName: $metricName, metricUnit: $metricUnit, includedUnits: $includedUnits, usedUnits: $usedUnits, overageUnits: $overageUnits, unitPrice: $unitPrice, totalCharge: $totalCharge, periodStart: $periodStart, periodEnd: $periodEnd, currency: $currency, invoiceId: $invoiceId, invoiceNumber: $invoiceNumber, isInvoiced: $isInvoiced, invoicedAt: $invoicedAt, usageData: $usageData, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$UsageBasedChargeCopyWith<$Res> implements $UsageBasedChargeCopyWith<$Res> {
  factory _$UsageBasedChargeCopyWith(_UsageBasedCharge value, $Res Function(_UsageBasedCharge) _then) = __$UsageBasedChargeCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, String metricName, String metricUnit, double includedUnits, double usedUnits, double overageUnits, double unitPrice, double totalCharge, DateTime periodStart, DateTime periodEnd, String currency, String? invoiceId, String? invoiceNumber, bool? isInvoiced, DateTime? invoicedAt, Map<String, dynamic>? usageData, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$UsageBasedChargeCopyWithImpl<$Res>
    implements _$UsageBasedChargeCopyWith<$Res> {
  __$UsageBasedChargeCopyWithImpl(this._self, this._then);

  final _UsageBasedCharge _self;
  final $Res Function(_UsageBasedCharge) _then;

/// Create a copy of UsageBasedCharge
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? metricName = null,Object? metricUnit = null,Object? includedUnits = null,Object? usedUnits = null,Object? overageUnits = null,Object? unitPrice = null,Object? totalCharge = null,Object? periodStart = null,Object? periodEnd = null,Object? currency = null,Object? invoiceId = freezed,Object? invoiceNumber = freezed,Object? isInvoiced = freezed,Object? invoicedAt = freezed,Object? usageData = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_UsageBasedCharge(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,metricName: null == metricName ? _self.metricName : metricName // ignore: cast_nullable_to_non_nullable
as String,metricUnit: null == metricUnit ? _self.metricUnit : metricUnit // ignore: cast_nullable_to_non_nullable
as String,includedUnits: null == includedUnits ? _self.includedUnits : includedUnits // ignore: cast_nullable_to_non_nullable
as double,usedUnits: null == usedUnits ? _self.usedUnits : usedUnits // ignore: cast_nullable_to_non_nullable
as double,overageUnits: null == overageUnits ? _self.overageUnits : overageUnits // ignore: cast_nullable_to_non_nullable
as double,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,totalCharge: null == totalCharge ? _self.totalCharge : totalCharge // ignore: cast_nullable_to_non_nullable
as double,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,invoiceId: freezed == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String?,invoiceNumber: freezed == invoiceNumber ? _self.invoiceNumber : invoiceNumber // ignore: cast_nullable_to_non_nullable
as String?,isInvoiced: freezed == isInvoiced ? _self.isInvoiced : isInvoiced // ignore: cast_nullable_to_non_nullable
as bool?,invoicedAt: freezed == invoicedAt ? _self.invoicedAt : invoicedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,usageData: freezed == usageData ? _self._usageData : usageData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on

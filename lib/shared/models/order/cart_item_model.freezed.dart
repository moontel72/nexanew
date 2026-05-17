// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cart_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CartItemModel {

 String get productId; String get tenantId; String get factoryId; int get quantity; double get unitPrice; double get listPrice; double? get discountPercent; double get discountAmount; double get taxRate; double get taxAmount; double get lineTotal; String? get discountType; double? get bonusQuantity; Map<String, dynamic>? get metadata;
/// Create a copy of CartItemModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartItemModelCopyWith<CartItemModel> get copyWith => _$CartItemModelCopyWithImpl<CartItemModel>(this as CartItemModel, _$identity);

  /// Serializes this CartItemModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CartItemModel&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.factoryId, factoryId) || other.factoryId == factoryId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.listPrice, listPrice) || other.listPrice == listPrice)&&(identical(other.discountPercent, discountPercent) || other.discountPercent == discountPercent)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount)&&(identical(other.taxRate, taxRate) || other.taxRate == taxRate)&&(identical(other.taxAmount, taxAmount) || other.taxAmount == taxAmount)&&(identical(other.lineTotal, lineTotal) || other.lineTotal == lineTotal)&&(identical(other.discountType, discountType) || other.discountType == discountType)&&(identical(other.bonusQuantity, bonusQuantity) || other.bonusQuantity == bonusQuantity)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,tenantId,factoryId,quantity,unitPrice,listPrice,discountPercent,discountAmount,taxRate,taxAmount,lineTotal,discountType,bonusQuantity,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'CartItemModel(productId: $productId, tenantId: $tenantId, factoryId: $factoryId, quantity: $quantity, unitPrice: $unitPrice, listPrice: $listPrice, discountPercent: $discountPercent, discountAmount: $discountAmount, taxRate: $taxRate, taxAmount: $taxAmount, lineTotal: $lineTotal, discountType: $discountType, bonusQuantity: $bonusQuantity, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $CartItemModelCopyWith<$Res>  {
  factory $CartItemModelCopyWith(CartItemModel value, $Res Function(CartItemModel) _then) = _$CartItemModelCopyWithImpl;
@useResult
$Res call({
 String productId, String tenantId, String factoryId, int quantity, double unitPrice, double listPrice, double? discountPercent, double discountAmount, double taxRate, double taxAmount, double lineTotal, String? discountType, double? bonusQuantity, Map<String, dynamic>? metadata
});




}
/// @nodoc
class _$CartItemModelCopyWithImpl<$Res>
    implements $CartItemModelCopyWith<$Res> {
  _$CartItemModelCopyWithImpl(this._self, this._then);

  final CartItemModel _self;
  final $Res Function(CartItemModel) _then;

/// Create a copy of CartItemModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? tenantId = null,Object? factoryId = null,Object? quantity = null,Object? unitPrice = null,Object? listPrice = null,Object? discountPercent = freezed,Object? discountAmount = null,Object? taxRate = null,Object? taxAmount = null,Object? lineTotal = null,Object? discountType = freezed,Object? bonusQuantity = freezed,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,factoryId: null == factoryId ? _self.factoryId : factoryId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,listPrice: null == listPrice ? _self.listPrice : listPrice // ignore: cast_nullable_to_non_nullable
as double,discountPercent: freezed == discountPercent ? _self.discountPercent : discountPercent // ignore: cast_nullable_to_non_nullable
as double?,discountAmount: null == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as double,taxRate: null == taxRate ? _self.taxRate : taxRate // ignore: cast_nullable_to_non_nullable
as double,taxAmount: null == taxAmount ? _self.taxAmount : taxAmount // ignore: cast_nullable_to_non_nullable
as double,lineTotal: null == lineTotal ? _self.lineTotal : lineTotal // ignore: cast_nullable_to_non_nullable
as double,discountType: freezed == discountType ? _self.discountType : discountType // ignore: cast_nullable_to_non_nullable
as String?,bonusQuantity: freezed == bonusQuantity ? _self.bonusQuantity : bonusQuantity // ignore: cast_nullable_to_non_nullable
as double?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [CartItemModel].
extension CartItemModelPatterns on CartItemModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CartItemModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CartItemModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CartItemModel value)  $default,){
final _that = this;
switch (_that) {
case _CartItemModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CartItemModel value)?  $default,){
final _that = this;
switch (_that) {
case _CartItemModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String productId,  String tenantId,  String factoryId,  int quantity,  double unitPrice,  double listPrice,  double? discountPercent,  double discountAmount,  double taxRate,  double taxAmount,  double lineTotal,  String? discountType,  double? bonusQuantity,  Map<String, dynamic>? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CartItemModel() when $default != null:
return $default(_that.productId,_that.tenantId,_that.factoryId,_that.quantity,_that.unitPrice,_that.listPrice,_that.discountPercent,_that.discountAmount,_that.taxRate,_that.taxAmount,_that.lineTotal,_that.discountType,_that.bonusQuantity,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String productId,  String tenantId,  String factoryId,  int quantity,  double unitPrice,  double listPrice,  double? discountPercent,  double discountAmount,  double taxRate,  double taxAmount,  double lineTotal,  String? discountType,  double? bonusQuantity,  Map<String, dynamic>? metadata)  $default,) {final _that = this;
switch (_that) {
case _CartItemModel():
return $default(_that.productId,_that.tenantId,_that.factoryId,_that.quantity,_that.unitPrice,_that.listPrice,_that.discountPercent,_that.discountAmount,_that.taxRate,_that.taxAmount,_that.lineTotal,_that.discountType,_that.bonusQuantity,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String productId,  String tenantId,  String factoryId,  int quantity,  double unitPrice,  double listPrice,  double? discountPercent,  double discountAmount,  double taxRate,  double taxAmount,  double lineTotal,  String? discountType,  double? bonusQuantity,  Map<String, dynamic>? metadata)?  $default,) {final _that = this;
switch (_that) {
case _CartItemModel() when $default != null:
return $default(_that.productId,_that.tenantId,_that.factoryId,_that.quantity,_that.unitPrice,_that.listPrice,_that.discountPercent,_that.discountAmount,_that.taxRate,_that.taxAmount,_that.lineTotal,_that.discountType,_that.bonusQuantity,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CartItemModel implements CartItemModel {
  const _CartItemModel({required this.productId, required this.tenantId, required this.factoryId, this.quantity = 1, this.unitPrice = 0.0, this.listPrice = 0.0, this.discountPercent, this.discountAmount = 0.0, this.taxRate = 0.0, this.taxAmount = 0.0, this.lineTotal = 0.0, this.discountType, this.bonusQuantity, final  Map<String, dynamic>? metadata}): _metadata = metadata;
  factory _CartItemModel.fromJson(Map<String, dynamic> json) => _$CartItemModelFromJson(json);

@override final  String productId;
@override final  String tenantId;
@override final  String factoryId;
@override@JsonKey() final  int quantity;
@override@JsonKey() final  double unitPrice;
@override@JsonKey() final  double listPrice;
@override final  double? discountPercent;
@override@JsonKey() final  double discountAmount;
@override@JsonKey() final  double taxRate;
@override@JsonKey() final  double taxAmount;
@override@JsonKey() final  double lineTotal;
@override final  String? discountType;
@override final  double? bonusQuantity;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of CartItemModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CartItemModelCopyWith<_CartItemModel> get copyWith => __$CartItemModelCopyWithImpl<_CartItemModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CartItemModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CartItemModel&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.factoryId, factoryId) || other.factoryId == factoryId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.listPrice, listPrice) || other.listPrice == listPrice)&&(identical(other.discountPercent, discountPercent) || other.discountPercent == discountPercent)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount)&&(identical(other.taxRate, taxRate) || other.taxRate == taxRate)&&(identical(other.taxAmount, taxAmount) || other.taxAmount == taxAmount)&&(identical(other.lineTotal, lineTotal) || other.lineTotal == lineTotal)&&(identical(other.discountType, discountType) || other.discountType == discountType)&&(identical(other.bonusQuantity, bonusQuantity) || other.bonusQuantity == bonusQuantity)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,tenantId,factoryId,quantity,unitPrice,listPrice,discountPercent,discountAmount,taxRate,taxAmount,lineTotal,discountType,bonusQuantity,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'CartItemModel(productId: $productId, tenantId: $tenantId, factoryId: $factoryId, quantity: $quantity, unitPrice: $unitPrice, listPrice: $listPrice, discountPercent: $discountPercent, discountAmount: $discountAmount, taxRate: $taxRate, taxAmount: $taxAmount, lineTotal: $lineTotal, discountType: $discountType, bonusQuantity: $bonusQuantity, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$CartItemModelCopyWith<$Res> implements $CartItemModelCopyWith<$Res> {
  factory _$CartItemModelCopyWith(_CartItemModel value, $Res Function(_CartItemModel) _then) = __$CartItemModelCopyWithImpl;
@override @useResult
$Res call({
 String productId, String tenantId, String factoryId, int quantity, double unitPrice, double listPrice, double? discountPercent, double discountAmount, double taxRate, double taxAmount, double lineTotal, String? discountType, double? bonusQuantity, Map<String, dynamic>? metadata
});




}
/// @nodoc
class __$CartItemModelCopyWithImpl<$Res>
    implements _$CartItemModelCopyWith<$Res> {
  __$CartItemModelCopyWithImpl(this._self, this._then);

  final _CartItemModel _self;
  final $Res Function(_CartItemModel) _then;

/// Create a copy of CartItemModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? tenantId = null,Object? factoryId = null,Object? quantity = null,Object? unitPrice = null,Object? listPrice = null,Object? discountPercent = freezed,Object? discountAmount = null,Object? taxRate = null,Object? taxAmount = null,Object? lineTotal = null,Object? discountType = freezed,Object? bonusQuantity = freezed,Object? metadata = freezed,}) {
  return _then(_CartItemModel(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,factoryId: null == factoryId ? _self.factoryId : factoryId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,listPrice: null == listPrice ? _self.listPrice : listPrice // ignore: cast_nullable_to_non_nullable
as double,discountPercent: freezed == discountPercent ? _self.discountPercent : discountPercent // ignore: cast_nullable_to_non_nullable
as double?,discountAmount: null == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as double,taxRate: null == taxRate ? _self.taxRate : taxRate // ignore: cast_nullable_to_non_nullable
as double,taxAmount: null == taxAmount ? _self.taxAmount : taxAmount // ignore: cast_nullable_to_non_nullable
as double,lineTotal: null == lineTotal ? _self.lineTotal : lineTotal // ignore: cast_nullable_to_non_nullable
as double,discountType: freezed == discountType ? _self.discountType : discountType // ignore: cast_nullable_to_non_nullable
as String?,bonusQuantity: freezed == bonusQuantity ? _self.bonusQuantity : bonusQuantity // ignore: cast_nullable_to_non_nullable
as double?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on

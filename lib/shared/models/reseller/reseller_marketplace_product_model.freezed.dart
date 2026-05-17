// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reseller_marketplace_product_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ResellerMarketplaceProductModel {

 String get id; String get tenantId; String get factoryId; String get name; String get sku; String get category; String get productType; String get status;@JsonKey(fromJson: _safeParseDoubleNN) double get price; String get currency; List<VolumeDiscountTier>? get volumeDiscounts;@JsonKey(fromJson: _safeParseDouble) double? get promoDiscount; Map<String, dynamic>? get metadata; String? get factoryName; String? get factoryCity; String? get factoryLogo; String? get factoryStatus;@JsonKey(fromJson: _safeParseDouble) double? get cartonPrice;@JsonKey(fromJson: _safeParseDouble) double? get wholesalePrice; int? get moq; int? get bonusQuantity; int? get bonusThreshold;
/// Create a copy of ResellerMarketplaceProductModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResellerMarketplaceProductModelCopyWith<ResellerMarketplaceProductModel> get copyWith => _$ResellerMarketplaceProductModelCopyWithImpl<ResellerMarketplaceProductModel>(this as ResellerMarketplaceProductModel, _$identity);

  /// Serializes this ResellerMarketplaceProductModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResellerMarketplaceProductModel&&(identical(other.id, id) || other.id == id)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.factoryId, factoryId) || other.factoryId == factoryId)&&(identical(other.name, name) || other.name == name)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.category, category) || other.category == category)&&(identical(other.productType, productType) || other.productType == productType)&&(identical(other.status, status) || other.status == status)&&(identical(other.price, price) || other.price == price)&&(identical(other.currency, currency) || other.currency == currency)&&const DeepCollectionEquality().equals(other.volumeDiscounts, volumeDiscounts)&&(identical(other.promoDiscount, promoDiscount) || other.promoDiscount == promoDiscount)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.factoryName, factoryName) || other.factoryName == factoryName)&&(identical(other.factoryCity, factoryCity) || other.factoryCity == factoryCity)&&(identical(other.factoryLogo, factoryLogo) || other.factoryLogo == factoryLogo)&&(identical(other.factoryStatus, factoryStatus) || other.factoryStatus == factoryStatus)&&(identical(other.cartonPrice, cartonPrice) || other.cartonPrice == cartonPrice)&&(identical(other.wholesalePrice, wholesalePrice) || other.wholesalePrice == wholesalePrice)&&(identical(other.moq, moq) || other.moq == moq)&&(identical(other.bonusQuantity, bonusQuantity) || other.bonusQuantity == bonusQuantity)&&(identical(other.bonusThreshold, bonusThreshold) || other.bonusThreshold == bonusThreshold));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,tenantId,factoryId,name,sku,category,productType,status,price,currency,const DeepCollectionEquality().hash(volumeDiscounts),promoDiscount,const DeepCollectionEquality().hash(metadata),factoryName,factoryCity,factoryLogo,factoryStatus,cartonPrice,wholesalePrice,moq,bonusQuantity,bonusThreshold]);

@override
String toString() {
  return 'ResellerMarketplaceProductModel(id: $id, tenantId: $tenantId, factoryId: $factoryId, name: $name, sku: $sku, category: $category, productType: $productType, status: $status, price: $price, currency: $currency, volumeDiscounts: $volumeDiscounts, promoDiscount: $promoDiscount, metadata: $metadata, factoryName: $factoryName, factoryCity: $factoryCity, factoryLogo: $factoryLogo, factoryStatus: $factoryStatus, cartonPrice: $cartonPrice, wholesalePrice: $wholesalePrice, moq: $moq, bonusQuantity: $bonusQuantity, bonusThreshold: $bonusThreshold)';
}


}

/// @nodoc
abstract mixin class $ResellerMarketplaceProductModelCopyWith<$Res>  {
  factory $ResellerMarketplaceProductModelCopyWith(ResellerMarketplaceProductModel value, $Res Function(ResellerMarketplaceProductModel) _then) = _$ResellerMarketplaceProductModelCopyWithImpl;
@useResult
$Res call({
 String id, String tenantId, String factoryId, String name, String sku, String category, String productType, String status,@JsonKey(fromJson: _safeParseDoubleNN) double price, String currency, List<VolumeDiscountTier>? volumeDiscounts,@JsonKey(fromJson: _safeParseDouble) double? promoDiscount, Map<String, dynamic>? metadata, String? factoryName, String? factoryCity, String? factoryLogo, String? factoryStatus,@JsonKey(fromJson: _safeParseDouble) double? cartonPrice,@JsonKey(fromJson: _safeParseDouble) double? wholesalePrice, int? moq, int? bonusQuantity, int? bonusThreshold
});




}
/// @nodoc
class _$ResellerMarketplaceProductModelCopyWithImpl<$Res>
    implements $ResellerMarketplaceProductModelCopyWith<$Res> {
  _$ResellerMarketplaceProductModelCopyWithImpl(this._self, this._then);

  final ResellerMarketplaceProductModel _self;
  final $Res Function(ResellerMarketplaceProductModel) _then;

/// Create a copy of ResellerMarketplaceProductModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tenantId = null,Object? factoryId = null,Object? name = null,Object? sku = null,Object? category = null,Object? productType = null,Object? status = null,Object? price = null,Object? currency = null,Object? volumeDiscounts = freezed,Object? promoDiscount = freezed,Object? metadata = freezed,Object? factoryName = freezed,Object? factoryCity = freezed,Object? factoryLogo = freezed,Object? factoryStatus = freezed,Object? cartonPrice = freezed,Object? wholesalePrice = freezed,Object? moq = freezed,Object? bonusQuantity = freezed,Object? bonusThreshold = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,factoryId: null == factoryId ? _self.factoryId : factoryId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sku: null == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,productType: null == productType ? _self.productType : productType // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,volumeDiscounts: freezed == volumeDiscounts ? _self.volumeDiscounts : volumeDiscounts // ignore: cast_nullable_to_non_nullable
as List<VolumeDiscountTier>?,promoDiscount: freezed == promoDiscount ? _self.promoDiscount : promoDiscount // ignore: cast_nullable_to_non_nullable
as double?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,factoryName: freezed == factoryName ? _self.factoryName : factoryName // ignore: cast_nullable_to_non_nullable
as String?,factoryCity: freezed == factoryCity ? _self.factoryCity : factoryCity // ignore: cast_nullable_to_non_nullable
as String?,factoryLogo: freezed == factoryLogo ? _self.factoryLogo : factoryLogo // ignore: cast_nullable_to_non_nullable
as String?,factoryStatus: freezed == factoryStatus ? _self.factoryStatus : factoryStatus // ignore: cast_nullable_to_non_nullable
as String?,cartonPrice: freezed == cartonPrice ? _self.cartonPrice : cartonPrice // ignore: cast_nullable_to_non_nullable
as double?,wholesalePrice: freezed == wholesalePrice ? _self.wholesalePrice : wholesalePrice // ignore: cast_nullable_to_non_nullable
as double?,moq: freezed == moq ? _self.moq : moq // ignore: cast_nullable_to_non_nullable
as int?,bonusQuantity: freezed == bonusQuantity ? _self.bonusQuantity : bonusQuantity // ignore: cast_nullable_to_non_nullable
as int?,bonusThreshold: freezed == bonusThreshold ? _self.bonusThreshold : bonusThreshold // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ResellerMarketplaceProductModel].
extension ResellerMarketplaceProductModelPatterns on ResellerMarketplaceProductModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResellerMarketplaceProductModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResellerMarketplaceProductModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResellerMarketplaceProductModel value)  $default,){
final _that = this;
switch (_that) {
case _ResellerMarketplaceProductModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResellerMarketplaceProductModel value)?  $default,){
final _that = this;
switch (_that) {
case _ResellerMarketplaceProductModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String tenantId,  String factoryId,  String name,  String sku,  String category,  String productType,  String status, @JsonKey(fromJson: _safeParseDoubleNN)  double price,  String currency,  List<VolumeDiscountTier>? volumeDiscounts, @JsonKey(fromJson: _safeParseDouble)  double? promoDiscount,  Map<String, dynamic>? metadata,  String? factoryName,  String? factoryCity,  String? factoryLogo,  String? factoryStatus, @JsonKey(fromJson: _safeParseDouble)  double? cartonPrice, @JsonKey(fromJson: _safeParseDouble)  double? wholesalePrice,  int? moq,  int? bonusQuantity,  int? bonusThreshold)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResellerMarketplaceProductModel() when $default != null:
return $default(_that.id,_that.tenantId,_that.factoryId,_that.name,_that.sku,_that.category,_that.productType,_that.status,_that.price,_that.currency,_that.volumeDiscounts,_that.promoDiscount,_that.metadata,_that.factoryName,_that.factoryCity,_that.factoryLogo,_that.factoryStatus,_that.cartonPrice,_that.wholesalePrice,_that.moq,_that.bonusQuantity,_that.bonusThreshold);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String tenantId,  String factoryId,  String name,  String sku,  String category,  String productType,  String status, @JsonKey(fromJson: _safeParseDoubleNN)  double price,  String currency,  List<VolumeDiscountTier>? volumeDiscounts, @JsonKey(fromJson: _safeParseDouble)  double? promoDiscount,  Map<String, dynamic>? metadata,  String? factoryName,  String? factoryCity,  String? factoryLogo,  String? factoryStatus, @JsonKey(fromJson: _safeParseDouble)  double? cartonPrice, @JsonKey(fromJson: _safeParseDouble)  double? wholesalePrice,  int? moq,  int? bonusQuantity,  int? bonusThreshold)  $default,) {final _that = this;
switch (_that) {
case _ResellerMarketplaceProductModel():
return $default(_that.id,_that.tenantId,_that.factoryId,_that.name,_that.sku,_that.category,_that.productType,_that.status,_that.price,_that.currency,_that.volumeDiscounts,_that.promoDiscount,_that.metadata,_that.factoryName,_that.factoryCity,_that.factoryLogo,_that.factoryStatus,_that.cartonPrice,_that.wholesalePrice,_that.moq,_that.bonusQuantity,_that.bonusThreshold);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String tenantId,  String factoryId,  String name,  String sku,  String category,  String productType,  String status, @JsonKey(fromJson: _safeParseDoubleNN)  double price,  String currency,  List<VolumeDiscountTier>? volumeDiscounts, @JsonKey(fromJson: _safeParseDouble)  double? promoDiscount,  Map<String, dynamic>? metadata,  String? factoryName,  String? factoryCity,  String? factoryLogo,  String? factoryStatus, @JsonKey(fromJson: _safeParseDouble)  double? cartonPrice, @JsonKey(fromJson: _safeParseDouble)  double? wholesalePrice,  int? moq,  int? bonusQuantity,  int? bonusThreshold)?  $default,) {final _that = this;
switch (_that) {
case _ResellerMarketplaceProductModel() when $default != null:
return $default(_that.id,_that.tenantId,_that.factoryId,_that.name,_that.sku,_that.category,_that.productType,_that.status,_that.price,_that.currency,_that.volumeDiscounts,_that.promoDiscount,_that.metadata,_that.factoryName,_that.factoryCity,_that.factoryLogo,_that.factoryStatus,_that.cartonPrice,_that.wholesalePrice,_that.moq,_that.bonusQuantity,_that.bonusThreshold);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ResellerMarketplaceProductModel implements ResellerMarketplaceProductModel {
  const _ResellerMarketplaceProductModel({required this.id, required this.tenantId, required this.factoryId, required this.name, this.sku = '', this.category = '', this.productType = '', this.status = 'active', @JsonKey(fromJson: _safeParseDoubleNN) this.price = 0.0, this.currency = 'PKR', final  List<VolumeDiscountTier>? volumeDiscounts, @JsonKey(fromJson: _safeParseDouble) this.promoDiscount, final  Map<String, dynamic>? metadata, this.factoryName, this.factoryCity, this.factoryLogo, this.factoryStatus, @JsonKey(fromJson: _safeParseDouble) this.cartonPrice, @JsonKey(fromJson: _safeParseDouble) this.wholesalePrice, this.moq, this.bonusQuantity, this.bonusThreshold}): _volumeDiscounts = volumeDiscounts,_metadata = metadata;
  factory _ResellerMarketplaceProductModel.fromJson(Map<String, dynamic> json) => _$ResellerMarketplaceProductModelFromJson(json);

@override final  String id;
@override final  String tenantId;
@override final  String factoryId;
@override final  String name;
@override@JsonKey() final  String sku;
@override@JsonKey() final  String category;
@override@JsonKey() final  String productType;
@override@JsonKey() final  String status;
@override@JsonKey(fromJson: _safeParseDoubleNN) final  double price;
@override@JsonKey() final  String currency;
 final  List<VolumeDiscountTier>? _volumeDiscounts;
@override List<VolumeDiscountTier>? get volumeDiscounts {
  final value = _volumeDiscounts;
  if (value == null) return null;
  if (_volumeDiscounts is EqualUnmodifiableListView) return _volumeDiscounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(fromJson: _safeParseDouble) final  double? promoDiscount;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? factoryName;
@override final  String? factoryCity;
@override final  String? factoryLogo;
@override final  String? factoryStatus;
@override@JsonKey(fromJson: _safeParseDouble) final  double? cartonPrice;
@override@JsonKey(fromJson: _safeParseDouble) final  double? wholesalePrice;
@override final  int? moq;
@override final  int? bonusQuantity;
@override final  int? bonusThreshold;

/// Create a copy of ResellerMarketplaceProductModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResellerMarketplaceProductModelCopyWith<_ResellerMarketplaceProductModel> get copyWith => __$ResellerMarketplaceProductModelCopyWithImpl<_ResellerMarketplaceProductModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ResellerMarketplaceProductModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResellerMarketplaceProductModel&&(identical(other.id, id) || other.id == id)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.factoryId, factoryId) || other.factoryId == factoryId)&&(identical(other.name, name) || other.name == name)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.category, category) || other.category == category)&&(identical(other.productType, productType) || other.productType == productType)&&(identical(other.status, status) || other.status == status)&&(identical(other.price, price) || other.price == price)&&(identical(other.currency, currency) || other.currency == currency)&&const DeepCollectionEquality().equals(other._volumeDiscounts, _volumeDiscounts)&&(identical(other.promoDiscount, promoDiscount) || other.promoDiscount == promoDiscount)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.factoryName, factoryName) || other.factoryName == factoryName)&&(identical(other.factoryCity, factoryCity) || other.factoryCity == factoryCity)&&(identical(other.factoryLogo, factoryLogo) || other.factoryLogo == factoryLogo)&&(identical(other.factoryStatus, factoryStatus) || other.factoryStatus == factoryStatus)&&(identical(other.cartonPrice, cartonPrice) || other.cartonPrice == cartonPrice)&&(identical(other.wholesalePrice, wholesalePrice) || other.wholesalePrice == wholesalePrice)&&(identical(other.moq, moq) || other.moq == moq)&&(identical(other.bonusQuantity, bonusQuantity) || other.bonusQuantity == bonusQuantity)&&(identical(other.bonusThreshold, bonusThreshold) || other.bonusThreshold == bonusThreshold));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,tenantId,factoryId,name,sku,category,productType,status,price,currency,const DeepCollectionEquality().hash(_volumeDiscounts),promoDiscount,const DeepCollectionEquality().hash(_metadata),factoryName,factoryCity,factoryLogo,factoryStatus,cartonPrice,wholesalePrice,moq,bonusQuantity,bonusThreshold]);

@override
String toString() {
  return 'ResellerMarketplaceProductModel(id: $id, tenantId: $tenantId, factoryId: $factoryId, name: $name, sku: $sku, category: $category, productType: $productType, status: $status, price: $price, currency: $currency, volumeDiscounts: $volumeDiscounts, promoDiscount: $promoDiscount, metadata: $metadata, factoryName: $factoryName, factoryCity: $factoryCity, factoryLogo: $factoryLogo, factoryStatus: $factoryStatus, cartonPrice: $cartonPrice, wholesalePrice: $wholesalePrice, moq: $moq, bonusQuantity: $bonusQuantity, bonusThreshold: $bonusThreshold)';
}


}

/// @nodoc
abstract mixin class _$ResellerMarketplaceProductModelCopyWith<$Res> implements $ResellerMarketplaceProductModelCopyWith<$Res> {
  factory _$ResellerMarketplaceProductModelCopyWith(_ResellerMarketplaceProductModel value, $Res Function(_ResellerMarketplaceProductModel) _then) = __$ResellerMarketplaceProductModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String tenantId, String factoryId, String name, String sku, String category, String productType, String status,@JsonKey(fromJson: _safeParseDoubleNN) double price, String currency, List<VolumeDiscountTier>? volumeDiscounts,@JsonKey(fromJson: _safeParseDouble) double? promoDiscount, Map<String, dynamic>? metadata, String? factoryName, String? factoryCity, String? factoryLogo, String? factoryStatus,@JsonKey(fromJson: _safeParseDouble) double? cartonPrice,@JsonKey(fromJson: _safeParseDouble) double? wholesalePrice, int? moq, int? bonusQuantity, int? bonusThreshold
});




}
/// @nodoc
class __$ResellerMarketplaceProductModelCopyWithImpl<$Res>
    implements _$ResellerMarketplaceProductModelCopyWith<$Res> {
  __$ResellerMarketplaceProductModelCopyWithImpl(this._self, this._then);

  final _ResellerMarketplaceProductModel _self;
  final $Res Function(_ResellerMarketplaceProductModel) _then;

/// Create a copy of ResellerMarketplaceProductModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tenantId = null,Object? factoryId = null,Object? name = null,Object? sku = null,Object? category = null,Object? productType = null,Object? status = null,Object? price = null,Object? currency = null,Object? volumeDiscounts = freezed,Object? promoDiscount = freezed,Object? metadata = freezed,Object? factoryName = freezed,Object? factoryCity = freezed,Object? factoryLogo = freezed,Object? factoryStatus = freezed,Object? cartonPrice = freezed,Object? wholesalePrice = freezed,Object? moq = freezed,Object? bonusQuantity = freezed,Object? bonusThreshold = freezed,}) {
  return _then(_ResellerMarketplaceProductModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,factoryId: null == factoryId ? _self.factoryId : factoryId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sku: null == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,productType: null == productType ? _self.productType : productType // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,volumeDiscounts: freezed == volumeDiscounts ? _self._volumeDiscounts : volumeDiscounts // ignore: cast_nullable_to_non_nullable
as List<VolumeDiscountTier>?,promoDiscount: freezed == promoDiscount ? _self.promoDiscount : promoDiscount // ignore: cast_nullable_to_non_nullable
as double?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,factoryName: freezed == factoryName ? _self.factoryName : factoryName // ignore: cast_nullable_to_non_nullable
as String?,factoryCity: freezed == factoryCity ? _self.factoryCity : factoryCity // ignore: cast_nullable_to_non_nullable
as String?,factoryLogo: freezed == factoryLogo ? _self.factoryLogo : factoryLogo // ignore: cast_nullable_to_non_nullable
as String?,factoryStatus: freezed == factoryStatus ? _self.factoryStatus : factoryStatus // ignore: cast_nullable_to_non_nullable
as String?,cartonPrice: freezed == cartonPrice ? _self.cartonPrice : cartonPrice // ignore: cast_nullable_to_non_nullable
as double?,wholesalePrice: freezed == wholesalePrice ? _self.wholesalePrice : wholesalePrice // ignore: cast_nullable_to_non_nullable
as double?,moq: freezed == moq ? _self.moq : moq // ignore: cast_nullable_to_non_nullable
as int?,bonusQuantity: freezed == bonusQuantity ? _self.bonusQuantity : bonusQuantity // ignore: cast_nullable_to_non_nullable
as int?,bonusThreshold: freezed == bonusThreshold ? _self.bonusThreshold : bonusThreshold // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on

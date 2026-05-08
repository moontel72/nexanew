// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bundle_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BundleModel {

@HiveField(0) String get id;@HiveField(1) String get bundleCode;@HiveField(2) String get orderReference;@HiveField(3) int get totalCartons;@HiveField(4) int get totalPackets;@HiveField(5) String? get locationStore;@HiveField(6) String? get locationShelf;@HiveField(7) String get status;@HiveField(8) DateTime? get packedAt;@HiveField(9) String? get notes;@HiveField(10)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime get createdAt;@HiveField(11) List<BundleItemModel> get items;
/// Create a copy of BundleModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BundleModelCopyWith<BundleModel> get copyWith => _$BundleModelCopyWithImpl<BundleModel>(this as BundleModel, _$identity);

  /// Serializes this BundleModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BundleModel&&(identical(other.id, id) || other.id == id)&&(identical(other.bundleCode, bundleCode) || other.bundleCode == bundleCode)&&(identical(other.orderReference, orderReference) || other.orderReference == orderReference)&&(identical(other.totalCartons, totalCartons) || other.totalCartons == totalCartons)&&(identical(other.totalPackets, totalPackets) || other.totalPackets == totalPackets)&&(identical(other.locationStore, locationStore) || other.locationStore == locationStore)&&(identical(other.locationShelf, locationShelf) || other.locationShelf == locationShelf)&&(identical(other.status, status) || other.status == status)&&(identical(other.packedAt, packedAt) || other.packedAt == packedAt)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,bundleCode,orderReference,totalCartons,totalPackets,locationStore,locationShelf,status,packedAt,notes,createdAt,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'BundleModel(id: $id, bundleCode: $bundleCode, orderReference: $orderReference, totalCartons: $totalCartons, totalPackets: $totalPackets, locationStore: $locationStore, locationShelf: $locationShelf, status: $status, packedAt: $packedAt, notes: $notes, createdAt: $createdAt, items: $items)';
}


}

/// @nodoc
abstract mixin class $BundleModelCopyWith<$Res>  {
  factory $BundleModelCopyWith(BundleModel value, $Res Function(BundleModel) _then) = _$BundleModelCopyWithImpl;
@useResult
$Res call({
@HiveField(0) String id,@HiveField(1) String bundleCode,@HiveField(2) String orderReference,@HiveField(3) int totalCartons,@HiveField(4) int totalPackets,@HiveField(5) String? locationStore,@HiveField(6) String? locationShelf,@HiveField(7) String status,@HiveField(8) DateTime? packedAt,@HiveField(9) String? notes,@HiveField(10)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime createdAt,@HiveField(11) List<BundleItemModel> items
});




}
/// @nodoc
class _$BundleModelCopyWithImpl<$Res>
    implements $BundleModelCopyWith<$Res> {
  _$BundleModelCopyWithImpl(this._self, this._then);

  final BundleModel _self;
  final $Res Function(BundleModel) _then;

/// Create a copy of BundleModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? bundleCode = null,Object? orderReference = null,Object? totalCartons = null,Object? totalPackets = null,Object? locationStore = freezed,Object? locationShelf = freezed,Object? status = null,Object? packedAt = freezed,Object? notes = freezed,Object? createdAt = null,Object? items = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,bundleCode: null == bundleCode ? _self.bundleCode : bundleCode // ignore: cast_nullable_to_non_nullable
as String,orderReference: null == orderReference ? _self.orderReference : orderReference // ignore: cast_nullable_to_non_nullable
as String,totalCartons: null == totalCartons ? _self.totalCartons : totalCartons // ignore: cast_nullable_to_non_nullable
as int,totalPackets: null == totalPackets ? _self.totalPackets : totalPackets // ignore: cast_nullable_to_non_nullable
as int,locationStore: freezed == locationStore ? _self.locationStore : locationStore // ignore: cast_nullable_to_non_nullable
as String?,locationShelf: freezed == locationShelf ? _self.locationShelf : locationShelf // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,packedAt: freezed == packedAt ? _self.packedAt : packedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<BundleItemModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [BundleModel].
extension BundleModelPatterns on BundleModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BundleModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BundleModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BundleModel value)  $default,){
final _that = this;
switch (_that) {
case _BundleModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BundleModel value)?  $default,){
final _that = this;
switch (_that) {
case _BundleModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@HiveField(0)  String id, @HiveField(1)  String bundleCode, @HiveField(2)  String orderReference, @HiveField(3)  int totalCartons, @HiveField(4)  int totalPackets, @HiveField(5)  String? locationStore, @HiveField(6)  String? locationShelf, @HiveField(7)  String status, @HiveField(8)  DateTime? packedAt, @HiveField(9)  String? notes, @HiveField(10)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime createdAt, @HiveField(11)  List<BundleItemModel> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BundleModel() when $default != null:
return $default(_that.id,_that.bundleCode,_that.orderReference,_that.totalCartons,_that.totalPackets,_that.locationStore,_that.locationShelf,_that.status,_that.packedAt,_that.notes,_that.createdAt,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@HiveField(0)  String id, @HiveField(1)  String bundleCode, @HiveField(2)  String orderReference, @HiveField(3)  int totalCartons, @HiveField(4)  int totalPackets, @HiveField(5)  String? locationStore, @HiveField(6)  String? locationShelf, @HiveField(7)  String status, @HiveField(8)  DateTime? packedAt, @HiveField(9)  String? notes, @HiveField(10)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime createdAt, @HiveField(11)  List<BundleItemModel> items)  $default,) {final _that = this;
switch (_that) {
case _BundleModel():
return $default(_that.id,_that.bundleCode,_that.orderReference,_that.totalCartons,_that.totalPackets,_that.locationStore,_that.locationShelf,_that.status,_that.packedAt,_that.notes,_that.createdAt,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@HiveField(0)  String id, @HiveField(1)  String bundleCode, @HiveField(2)  String orderReference, @HiveField(3)  int totalCartons, @HiveField(4)  int totalPackets, @HiveField(5)  String? locationStore, @HiveField(6)  String? locationShelf, @HiveField(7)  String status, @HiveField(8)  DateTime? packedAt, @HiveField(9)  String? notes, @HiveField(10)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime createdAt, @HiveField(11)  List<BundleItemModel> items)?  $default,) {final _that = this;
switch (_that) {
case _BundleModel() when $default != null:
return $default(_that.id,_that.bundleCode,_that.orderReference,_that.totalCartons,_that.totalPackets,_that.locationStore,_that.locationShelf,_that.status,_that.packedAt,_that.notes,_that.createdAt,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BundleModel implements BundleModel {
  const _BundleModel({@HiveField(0) required this.id, @HiveField(1) required this.bundleCode, @HiveField(2) this.orderReference = '', @HiveField(3) this.totalCartons = 0, @HiveField(4) this.totalPackets = 0, @HiveField(5) this.locationStore, @HiveField(6) this.locationShelf, @HiveField(7) this.status = 'draft', @HiveField(8) this.packedAt, @HiveField(9) this.notes, @HiveField(10)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) required this.createdAt, @HiveField(11) final  List<BundleItemModel> items = const []}): _items = items;
  factory _BundleModel.fromJson(Map<String, dynamic> json) => _$BundleModelFromJson(json);

@override@HiveField(0) final  String id;
@override@HiveField(1) final  String bundleCode;
@override@JsonKey()@HiveField(2) final  String orderReference;
@override@JsonKey()@HiveField(3) final  int totalCartons;
@override@JsonKey()@HiveField(4) final  int totalPackets;
@override@HiveField(5) final  String? locationStore;
@override@HiveField(6) final  String? locationShelf;
@override@JsonKey()@HiveField(7) final  String status;
@override@HiveField(8) final  DateTime? packedAt;
@override@HiveField(9) final  String? notes;
@override@HiveField(10)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) final  DateTime createdAt;
 final  List<BundleItemModel> _items;
@override@JsonKey()@HiveField(11) List<BundleItemModel> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of BundleModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BundleModelCopyWith<_BundleModel> get copyWith => __$BundleModelCopyWithImpl<_BundleModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BundleModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BundleModel&&(identical(other.id, id) || other.id == id)&&(identical(other.bundleCode, bundleCode) || other.bundleCode == bundleCode)&&(identical(other.orderReference, orderReference) || other.orderReference == orderReference)&&(identical(other.totalCartons, totalCartons) || other.totalCartons == totalCartons)&&(identical(other.totalPackets, totalPackets) || other.totalPackets == totalPackets)&&(identical(other.locationStore, locationStore) || other.locationStore == locationStore)&&(identical(other.locationShelf, locationShelf) || other.locationShelf == locationShelf)&&(identical(other.status, status) || other.status == status)&&(identical(other.packedAt, packedAt) || other.packedAt == packedAt)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,bundleCode,orderReference,totalCartons,totalPackets,locationStore,locationShelf,status,packedAt,notes,createdAt,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'BundleModel(id: $id, bundleCode: $bundleCode, orderReference: $orderReference, totalCartons: $totalCartons, totalPackets: $totalPackets, locationStore: $locationStore, locationShelf: $locationShelf, status: $status, packedAt: $packedAt, notes: $notes, createdAt: $createdAt, items: $items)';
}


}

/// @nodoc
abstract mixin class _$BundleModelCopyWith<$Res> implements $BundleModelCopyWith<$Res> {
  factory _$BundleModelCopyWith(_BundleModel value, $Res Function(_BundleModel) _then) = __$BundleModelCopyWithImpl;
@override @useResult
$Res call({
@HiveField(0) String id,@HiveField(1) String bundleCode,@HiveField(2) String orderReference,@HiveField(3) int totalCartons,@HiveField(4) int totalPackets,@HiveField(5) String? locationStore,@HiveField(6) String? locationShelf,@HiveField(7) String status,@HiveField(8) DateTime? packedAt,@HiveField(9) String? notes,@HiveField(10)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime createdAt,@HiveField(11) List<BundleItemModel> items
});




}
/// @nodoc
class __$BundleModelCopyWithImpl<$Res>
    implements _$BundleModelCopyWith<$Res> {
  __$BundleModelCopyWithImpl(this._self, this._then);

  final _BundleModel _self;
  final $Res Function(_BundleModel) _then;

/// Create a copy of BundleModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? bundleCode = null,Object? orderReference = null,Object? totalCartons = null,Object? totalPackets = null,Object? locationStore = freezed,Object? locationShelf = freezed,Object? status = null,Object? packedAt = freezed,Object? notes = freezed,Object? createdAt = null,Object? items = null,}) {
  return _then(_BundleModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,bundleCode: null == bundleCode ? _self.bundleCode : bundleCode // ignore: cast_nullable_to_non_nullable
as String,orderReference: null == orderReference ? _self.orderReference : orderReference // ignore: cast_nullable_to_non_nullable
as String,totalCartons: null == totalCartons ? _self.totalCartons : totalCartons // ignore: cast_nullable_to_non_nullable
as int,totalPackets: null == totalPackets ? _self.totalPackets : totalPackets // ignore: cast_nullable_to_non_nullable
as int,locationStore: freezed == locationStore ? _self.locationStore : locationStore // ignore: cast_nullable_to_non_nullable
as String?,locationShelf: freezed == locationShelf ? _self.locationShelf : locationShelf // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,packedAt: freezed == packedAt ? _self.packedAt : packedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<BundleItemModel>,
  ));
}


}


/// @nodoc
mixin _$BundleItemModel {

@HiveField(0) String get id;@HiveField(1) String get type;// 'carton' or 'packet'
@HiveField(2) String? get cartonCodeId;@HiveField(3) String? get packetCodeId;
/// Create a copy of BundleItemModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BundleItemModelCopyWith<BundleItemModel> get copyWith => _$BundleItemModelCopyWithImpl<BundleItemModel>(this as BundleItemModel, _$identity);

  /// Serializes this BundleItemModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BundleItemModel&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.cartonCodeId, cartonCodeId) || other.cartonCodeId == cartonCodeId)&&(identical(other.packetCodeId, packetCodeId) || other.packetCodeId == packetCodeId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,cartonCodeId,packetCodeId);

@override
String toString() {
  return 'BundleItemModel(id: $id, type: $type, cartonCodeId: $cartonCodeId, packetCodeId: $packetCodeId)';
}


}

/// @nodoc
abstract mixin class $BundleItemModelCopyWith<$Res>  {
  factory $BundleItemModelCopyWith(BundleItemModel value, $Res Function(BundleItemModel) _then) = _$BundleItemModelCopyWithImpl;
@useResult
$Res call({
@HiveField(0) String id,@HiveField(1) String type,@HiveField(2) String? cartonCodeId,@HiveField(3) String? packetCodeId
});




}
/// @nodoc
class _$BundleItemModelCopyWithImpl<$Res>
    implements $BundleItemModelCopyWith<$Res> {
  _$BundleItemModelCopyWithImpl(this._self, this._then);

  final BundleItemModel _self;
  final $Res Function(BundleItemModel) _then;

/// Create a copy of BundleItemModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? cartonCodeId = freezed,Object? packetCodeId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,cartonCodeId: freezed == cartonCodeId ? _self.cartonCodeId : cartonCodeId // ignore: cast_nullable_to_non_nullable
as String?,packetCodeId: freezed == packetCodeId ? _self.packetCodeId : packetCodeId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BundleItemModel].
extension BundleItemModelPatterns on BundleItemModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BundleItemModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BundleItemModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BundleItemModel value)  $default,){
final _that = this;
switch (_that) {
case _BundleItemModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BundleItemModel value)?  $default,){
final _that = this;
switch (_that) {
case _BundleItemModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@HiveField(0)  String id, @HiveField(1)  String type, @HiveField(2)  String? cartonCodeId, @HiveField(3)  String? packetCodeId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BundleItemModel() when $default != null:
return $default(_that.id,_that.type,_that.cartonCodeId,_that.packetCodeId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@HiveField(0)  String id, @HiveField(1)  String type, @HiveField(2)  String? cartonCodeId, @HiveField(3)  String? packetCodeId)  $default,) {final _that = this;
switch (_that) {
case _BundleItemModel():
return $default(_that.id,_that.type,_that.cartonCodeId,_that.packetCodeId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@HiveField(0)  String id, @HiveField(1)  String type, @HiveField(2)  String? cartonCodeId, @HiveField(3)  String? packetCodeId)?  $default,) {final _that = this;
switch (_that) {
case _BundleItemModel() when $default != null:
return $default(_that.id,_that.type,_that.cartonCodeId,_that.packetCodeId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BundleItemModel implements BundleItemModel {
  const _BundleItemModel({@HiveField(0) required this.id, @HiveField(1) this.type = '', @HiveField(2) this.cartonCodeId, @HiveField(3) this.packetCodeId});
  factory _BundleItemModel.fromJson(Map<String, dynamic> json) => _$BundleItemModelFromJson(json);

@override@HiveField(0) final  String id;
@override@JsonKey()@HiveField(1) final  String type;
// 'carton' or 'packet'
@override@HiveField(2) final  String? cartonCodeId;
@override@HiveField(3) final  String? packetCodeId;

/// Create a copy of BundleItemModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BundleItemModelCopyWith<_BundleItemModel> get copyWith => __$BundleItemModelCopyWithImpl<_BundleItemModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BundleItemModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BundleItemModel&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.cartonCodeId, cartonCodeId) || other.cartonCodeId == cartonCodeId)&&(identical(other.packetCodeId, packetCodeId) || other.packetCodeId == packetCodeId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,cartonCodeId,packetCodeId);

@override
String toString() {
  return 'BundleItemModel(id: $id, type: $type, cartonCodeId: $cartonCodeId, packetCodeId: $packetCodeId)';
}


}

/// @nodoc
abstract mixin class _$BundleItemModelCopyWith<$Res> implements $BundleItemModelCopyWith<$Res> {
  factory _$BundleItemModelCopyWith(_BundleItemModel value, $Res Function(_BundleItemModel) _then) = __$BundleItemModelCopyWithImpl;
@override @useResult
$Res call({
@HiveField(0) String id,@HiveField(1) String type,@HiveField(2) String? cartonCodeId,@HiveField(3) String? packetCodeId
});




}
/// @nodoc
class __$BundleItemModelCopyWithImpl<$Res>
    implements _$BundleItemModelCopyWith<$Res> {
  __$BundleItemModelCopyWithImpl(this._self, this._then);

  final _BundleItemModel _self;
  final $Res Function(_BundleItemModel) _then;

/// Create a copy of BundleItemModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? cartonCodeId = freezed,Object? packetCodeId = freezed,}) {
  return _then(_BundleItemModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,cartonCodeId: freezed == cartonCodeId ? _self.cartonCodeId : cartonCodeId // ignore: cast_nullable_to_non_nullable
as String?,packetCodeId: freezed == packetCodeId ? _self.packetCodeId : packetCodeId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

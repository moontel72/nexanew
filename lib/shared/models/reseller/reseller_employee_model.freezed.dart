// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reseller_employee_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ResellerEmployeeModel {

 String get id; String get resellerId; String get shopId; String get name; ResellerEmployeeRole get role; bool get isActive; DateTime? get createdAt; DateTime? get updatedAt; Map<String, dynamic>? get metadata;
/// Create a copy of ResellerEmployeeModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResellerEmployeeModelCopyWith<ResellerEmployeeModel> get copyWith => _$ResellerEmployeeModelCopyWithImpl<ResellerEmployeeModel>(this as ResellerEmployeeModel, _$identity);

  /// Serializes this ResellerEmployeeModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResellerEmployeeModel&&(identical(other.id, id) || other.id == id)&&(identical(other.resellerId, resellerId) || other.resellerId == resellerId)&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.name, name) || other.name == name)&&(identical(other.role, role) || other.role == role)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,resellerId,shopId,name,role,isActive,createdAt,updatedAt,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'ResellerEmployeeModel(id: $id, resellerId: $resellerId, shopId: $shopId, name: $name, role: $role, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $ResellerEmployeeModelCopyWith<$Res>  {
  factory $ResellerEmployeeModelCopyWith(ResellerEmployeeModel value, $Res Function(ResellerEmployeeModel) _then) = _$ResellerEmployeeModelCopyWithImpl;
@useResult
$Res call({
 String id, String resellerId, String shopId, String name, ResellerEmployeeRole role, bool isActive, DateTime? createdAt, DateTime? updatedAt, Map<String, dynamic>? metadata
});




}
/// @nodoc
class _$ResellerEmployeeModelCopyWithImpl<$Res>
    implements $ResellerEmployeeModelCopyWith<$Res> {
  _$ResellerEmployeeModelCopyWithImpl(this._self, this._then);

  final ResellerEmployeeModel _self;
  final $Res Function(ResellerEmployeeModel) _then;

/// Create a copy of ResellerEmployeeModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? resellerId = null,Object? shopId = null,Object? name = null,Object? role = null,Object? isActive = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,resellerId: null == resellerId ? _self.resellerId : resellerId // ignore: cast_nullable_to_non_nullable
as String,shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as ResellerEmployeeRole,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ResellerEmployeeModel].
extension ResellerEmployeeModelPatterns on ResellerEmployeeModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResellerEmployeeModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResellerEmployeeModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResellerEmployeeModel value)  $default,){
final _that = this;
switch (_that) {
case _ResellerEmployeeModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResellerEmployeeModel value)?  $default,){
final _that = this;
switch (_that) {
case _ResellerEmployeeModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String resellerId,  String shopId,  String name,  ResellerEmployeeRole role,  bool isActive,  DateTime? createdAt,  DateTime? updatedAt,  Map<String, dynamic>? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResellerEmployeeModel() when $default != null:
return $default(_that.id,_that.resellerId,_that.shopId,_that.name,_that.role,_that.isActive,_that.createdAt,_that.updatedAt,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String resellerId,  String shopId,  String name,  ResellerEmployeeRole role,  bool isActive,  DateTime? createdAt,  DateTime? updatedAt,  Map<String, dynamic>? metadata)  $default,) {final _that = this;
switch (_that) {
case _ResellerEmployeeModel():
return $default(_that.id,_that.resellerId,_that.shopId,_that.name,_that.role,_that.isActive,_that.createdAt,_that.updatedAt,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String resellerId,  String shopId,  String name,  ResellerEmployeeRole role,  bool isActive,  DateTime? createdAt,  DateTime? updatedAt,  Map<String, dynamic>? metadata)?  $default,) {final _that = this;
switch (_that) {
case _ResellerEmployeeModel() when $default != null:
return $default(_that.id,_that.resellerId,_that.shopId,_that.name,_that.role,_that.isActive,_that.createdAt,_that.updatedAt,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ResellerEmployeeModel implements ResellerEmployeeModel {
  const _ResellerEmployeeModel({required this.id, required this.resellerId, required this.shopId, required this.name, required this.role, this.isActive = true, this.createdAt, this.updatedAt, final  Map<String, dynamic>? metadata}): _metadata = metadata;
  factory _ResellerEmployeeModel.fromJson(Map<String, dynamic> json) => _$ResellerEmployeeModelFromJson(json);

@override final  String id;
@override final  String resellerId;
@override final  String shopId;
@override final  String name;
@override final  ResellerEmployeeRole role;
@override@JsonKey() final  bool isActive;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of ResellerEmployeeModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResellerEmployeeModelCopyWith<_ResellerEmployeeModel> get copyWith => __$ResellerEmployeeModelCopyWithImpl<_ResellerEmployeeModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ResellerEmployeeModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResellerEmployeeModel&&(identical(other.id, id) || other.id == id)&&(identical(other.resellerId, resellerId) || other.resellerId == resellerId)&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.name, name) || other.name == name)&&(identical(other.role, role) || other.role == role)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,resellerId,shopId,name,role,isActive,createdAt,updatedAt,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'ResellerEmployeeModel(id: $id, resellerId: $resellerId, shopId: $shopId, name: $name, role: $role, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$ResellerEmployeeModelCopyWith<$Res> implements $ResellerEmployeeModelCopyWith<$Res> {
  factory _$ResellerEmployeeModelCopyWith(_ResellerEmployeeModel value, $Res Function(_ResellerEmployeeModel) _then) = __$ResellerEmployeeModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String resellerId, String shopId, String name, ResellerEmployeeRole role, bool isActive, DateTime? createdAt, DateTime? updatedAt, Map<String, dynamic>? metadata
});




}
/// @nodoc
class __$ResellerEmployeeModelCopyWithImpl<$Res>
    implements _$ResellerEmployeeModelCopyWith<$Res> {
  __$ResellerEmployeeModelCopyWithImpl(this._self, this._then);

  final _ResellerEmployeeModel _self;
  final $Res Function(_ResellerEmployeeModel) _then;

/// Create a copy of ResellerEmployeeModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? resellerId = null,Object? shopId = null,Object? name = null,Object? role = null,Object? isActive = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? metadata = freezed,}) {
  return _then(_ResellerEmployeeModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,resellerId: null == resellerId ? _self.resellerId : resellerId // ignore: cast_nullable_to_non_nullable
as String,shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as ResellerEmployeeRole,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on

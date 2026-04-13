// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plan_feature_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlanFeature {

/// Unique identifier for the feature
@JsonKey(name: 'id') String get id;/// Name of the feature
@JsonKey(name: 'name') String get name;/// Description of the feature
@JsonKey(name: 'description') String get description;/// Type of feature (Core, Advanced, Enterprise, Custom)
@JsonKey(name: 'type') FeatureType get type;/// Whether this feature is included in the plan
@JsonKey(name: 'is_included') bool get isIncluded;/// Icon name for the feature (from Material Icons)
@JsonKey(name: 'icon') String get icon;/// Sort order for display
@JsonKey(name: 'sort_order') int get sortOrder;/// Whether this feature is a highlight feature
@JsonKey(name: 'is_highlight') bool get isHighlight;/// Additional metadata for the feature
@JsonKey(name: 'metadata') Map<String, dynamic> get metadata;/// Date when the feature was created
@JsonKey(name: 'created_at') DateTime get createdAt;/// Date when the feature was last updated
@JsonKey(name: 'updated_at') DateTime get updatedAt;
/// Create a copy of PlanFeature
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlanFeatureCopyWith<PlanFeature> get copyWith => _$PlanFeatureCopyWithImpl<PlanFeature>(this as PlanFeature, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlanFeature&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&(identical(other.isIncluded, isIncluded) || other.isIncluded == isIncluded)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.isHighlight, isHighlight) || other.isHighlight == isHighlight)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,description,type,isIncluded,icon,sortOrder,isHighlight,const DeepCollectionEquality().hash(metadata),createdAt,updatedAt);

@override
String toString() {
  return 'PlanFeature(id: $id, name: $name, description: $description, type: $type, isIncluded: $isIncluded, icon: $icon, sortOrder: $sortOrder, isHighlight: $isHighlight, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PlanFeatureCopyWith<$Res>  {
  factory $PlanFeatureCopyWith(PlanFeature value, $Res Function(PlanFeature) _then) = _$PlanFeatureCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id') String id,@JsonKey(name: 'name') String name,@JsonKey(name: 'description') String description,@JsonKey(name: 'type') FeatureType type,@JsonKey(name: 'is_included') bool isIncluded,@JsonKey(name: 'icon') String icon,@JsonKey(name: 'sort_order') int sortOrder,@JsonKey(name: 'is_highlight') bool isHighlight,@JsonKey(name: 'metadata') Map<String, dynamic> metadata,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class _$PlanFeatureCopyWithImpl<$Res>
    implements $PlanFeatureCopyWith<$Res> {
  _$PlanFeatureCopyWithImpl(this._self, this._then);

  final PlanFeature _self;
  final $Res Function(PlanFeature) _then;

/// Create a copy of PlanFeature
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? type = null,Object? isIncluded = null,Object? icon = null,Object? sortOrder = null,Object? isHighlight = null,Object? metadata = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FeatureType,isIncluded: null == isIncluded ? _self.isIncluded : isIncluded // ignore: cast_nullable_to_non_nullable
as bool,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,isHighlight: null == isHighlight ? _self.isHighlight : isHighlight // ignore: cast_nullable_to_non_nullable
as bool,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PlanFeature].
extension PlanFeaturePatterns on PlanFeature {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlanFeature value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlanFeature() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlanFeature value)  $default,){
final _that = this;
switch (_that) {
case _PlanFeature():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlanFeature value)?  $default,){
final _that = this;
switch (_that) {
case _PlanFeature() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'name')  String name, @JsonKey(name: 'description')  String description, @JsonKey(name: 'type')  FeatureType type, @JsonKey(name: 'is_included')  bool isIncluded, @JsonKey(name: 'icon')  String icon, @JsonKey(name: 'sort_order')  int sortOrder, @JsonKey(name: 'is_highlight')  bool isHighlight, @JsonKey(name: 'metadata')  Map<String, dynamic> metadata, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlanFeature() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.type,_that.isIncluded,_that.icon,_that.sortOrder,_that.isHighlight,_that.metadata,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'name')  String name, @JsonKey(name: 'description')  String description, @JsonKey(name: 'type')  FeatureType type, @JsonKey(name: 'is_included')  bool isIncluded, @JsonKey(name: 'icon')  String icon, @JsonKey(name: 'sort_order')  int sortOrder, @JsonKey(name: 'is_highlight')  bool isHighlight, @JsonKey(name: 'metadata')  Map<String, dynamic> metadata, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PlanFeature():
return $default(_that.id,_that.name,_that.description,_that.type,_that.isIncluded,_that.icon,_that.sortOrder,_that.isHighlight,_that.metadata,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'name')  String name, @JsonKey(name: 'description')  String description, @JsonKey(name: 'type')  FeatureType type, @JsonKey(name: 'is_included')  bool isIncluded, @JsonKey(name: 'icon')  String icon, @JsonKey(name: 'sort_order')  int sortOrder, @JsonKey(name: 'is_highlight')  bool isHighlight, @JsonKey(name: 'metadata')  Map<String, dynamic> metadata, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PlanFeature() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.type,_that.isIncluded,_that.icon,_that.sortOrder,_that.isHighlight,_that.metadata,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _PlanFeature extends PlanFeature {
  const _PlanFeature({@JsonKey(name: 'id') required this.id, @JsonKey(name: 'name') required this.name, @JsonKey(name: 'description') required this.description, @JsonKey(name: 'type') required this.type, @JsonKey(name: 'is_included') this.isIncluded = true, @JsonKey(name: 'icon') this.icon = 'check_circle', @JsonKey(name: 'sort_order') this.sortOrder = 0, @JsonKey(name: 'is_highlight') this.isHighlight = false, @JsonKey(name: 'metadata') final  Map<String, dynamic> metadata = const {}, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt}): _metadata = metadata,super._();
  

/// Unique identifier for the feature
@override@JsonKey(name: 'id') final  String id;
/// Name of the feature
@override@JsonKey(name: 'name') final  String name;
/// Description of the feature
@override@JsonKey(name: 'description') final  String description;
/// Type of feature (Core, Advanced, Enterprise, Custom)
@override@JsonKey(name: 'type') final  FeatureType type;
/// Whether this feature is included in the plan
@override@JsonKey(name: 'is_included') final  bool isIncluded;
/// Icon name for the feature (from Material Icons)
@override@JsonKey(name: 'icon') final  String icon;
/// Sort order for display
@override@JsonKey(name: 'sort_order') final  int sortOrder;
/// Whether this feature is a highlight feature
@override@JsonKey(name: 'is_highlight') final  bool isHighlight;
/// Additional metadata for the feature
 final  Map<String, dynamic> _metadata;
/// Additional metadata for the feature
@override@JsonKey(name: 'metadata') Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}

/// Date when the feature was created
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
/// Date when the feature was last updated
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;

/// Create a copy of PlanFeature
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlanFeatureCopyWith<_PlanFeature> get copyWith => __$PlanFeatureCopyWithImpl<_PlanFeature>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlanFeature&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&(identical(other.isIncluded, isIncluded) || other.isIncluded == isIncluded)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.isHighlight, isHighlight) || other.isHighlight == isHighlight)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,description,type,isIncluded,icon,sortOrder,isHighlight,const DeepCollectionEquality().hash(_metadata),createdAt,updatedAt);

@override
String toString() {
  return 'PlanFeature(id: $id, name: $name, description: $description, type: $type, isIncluded: $isIncluded, icon: $icon, sortOrder: $sortOrder, isHighlight: $isHighlight, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PlanFeatureCopyWith<$Res> implements $PlanFeatureCopyWith<$Res> {
  factory _$PlanFeatureCopyWith(_PlanFeature value, $Res Function(_PlanFeature) _then) = __$PlanFeatureCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id') String id,@JsonKey(name: 'name') String name,@JsonKey(name: 'description') String description,@JsonKey(name: 'type') FeatureType type,@JsonKey(name: 'is_included') bool isIncluded,@JsonKey(name: 'icon') String icon,@JsonKey(name: 'sort_order') int sortOrder,@JsonKey(name: 'is_highlight') bool isHighlight,@JsonKey(name: 'metadata') Map<String, dynamic> metadata,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class __$PlanFeatureCopyWithImpl<$Res>
    implements _$PlanFeatureCopyWith<$Res> {
  __$PlanFeatureCopyWithImpl(this._self, this._then);

  final _PlanFeature _self;
  final $Res Function(_PlanFeature) _then;

/// Create a copy of PlanFeature
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? type = null,Object? isIncluded = null,Object? icon = null,Object? sortOrder = null,Object? isHighlight = null,Object? metadata = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_PlanFeature(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FeatureType,isIncluded: null == isIncluded ? _self.isIncluded : isIncluded // ignore: cast_nullable_to_non_nullable
as bool,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,isHighlight: null == isHighlight ? _self.isHighlight : isHighlight // ignore: cast_nullable_to_non_nullable
as bool,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on

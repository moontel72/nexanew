// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bundle_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BundleEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BundleEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BundleEvent()';
}


}

/// @nodoc
class $BundleEventCopyWith<$Res>  {
$BundleEventCopyWith(BundleEvent _, $Res Function(BundleEvent) __);
}


/// Adds pattern-matching-related methods to [BundleEvent].
extension BundleEventPatterns on BundleEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LoadBundles value)?  load,TResult Function( CreateBundle value)?  create,TResult Function( ShowBundle value)?  show,TResult Function( UpdateBundle value)?  update,TResult Function( DeleteBundle value)?  delete,TResult Function( ScanBundle value)?  scan,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LoadBundles() when load != null:
return load(_that);case CreateBundle() when create != null:
return create(_that);case ShowBundle() when show != null:
return show(_that);case UpdateBundle() when update != null:
return update(_that);case DeleteBundle() when delete != null:
return delete(_that);case ScanBundle() when scan != null:
return scan(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LoadBundles value)  load,required TResult Function( CreateBundle value)  create,required TResult Function( ShowBundle value)  show,required TResult Function( UpdateBundle value)  update,required TResult Function( DeleteBundle value)  delete,required TResult Function( ScanBundle value)  scan,}){
final _that = this;
switch (_that) {
case LoadBundles():
return load(_that);case CreateBundle():
return create(_that);case ShowBundle():
return show(_that);case UpdateBundle():
return update(_that);case DeleteBundle():
return delete(_that);case ScanBundle():
return scan(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LoadBundles value)?  load,TResult? Function( CreateBundle value)?  create,TResult? Function( ShowBundle value)?  show,TResult? Function( UpdateBundle value)?  update,TResult? Function( DeleteBundle value)?  delete,TResult? Function( ScanBundle value)?  scan,}){
final _that = this;
switch (_that) {
case LoadBundles() when load != null:
return load(_that);case CreateBundle() when create != null:
return create(_that);case ShowBundle() when show != null:
return show(_that);case UpdateBundle() when update != null:
return update(_that);case DeleteBundle() when delete != null:
return delete(_that);case ScanBundle() when scan != null:
return scan(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  load,TResult Function( String orderReference,  List<String>? cartonCodeIds,  List<String>? packetCodeIds,  String? locationStore,  String? locationShelf,  String? notes)?  create,TResult Function( String bundleId)?  show,TResult Function( String bundleId,  String? status,  String? locationStore,  String? locationShelf,  String? notes)?  update,TResult Function( String bundleId)?  delete,TResult Function( String bundleId)?  scan,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LoadBundles() when load != null:
return load();case CreateBundle() when create != null:
return create(_that.orderReference,_that.cartonCodeIds,_that.packetCodeIds,_that.locationStore,_that.locationShelf,_that.notes);case ShowBundle() when show != null:
return show(_that.bundleId);case UpdateBundle() when update != null:
return update(_that.bundleId,_that.status,_that.locationStore,_that.locationShelf,_that.notes);case DeleteBundle() when delete != null:
return delete(_that.bundleId);case ScanBundle() when scan != null:
return scan(_that.bundleId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  load,required TResult Function( String orderReference,  List<String>? cartonCodeIds,  List<String>? packetCodeIds,  String? locationStore,  String? locationShelf,  String? notes)  create,required TResult Function( String bundleId)  show,required TResult Function( String bundleId,  String? status,  String? locationStore,  String? locationShelf,  String? notes)  update,required TResult Function( String bundleId)  delete,required TResult Function( String bundleId)  scan,}) {final _that = this;
switch (_that) {
case LoadBundles():
return load();case CreateBundle():
return create(_that.orderReference,_that.cartonCodeIds,_that.packetCodeIds,_that.locationStore,_that.locationShelf,_that.notes);case ShowBundle():
return show(_that.bundleId);case UpdateBundle():
return update(_that.bundleId,_that.status,_that.locationStore,_that.locationShelf,_that.notes);case DeleteBundle():
return delete(_that.bundleId);case ScanBundle():
return scan(_that.bundleId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  load,TResult? Function( String orderReference,  List<String>? cartonCodeIds,  List<String>? packetCodeIds,  String? locationStore,  String? locationShelf,  String? notes)?  create,TResult? Function( String bundleId)?  show,TResult? Function( String bundleId,  String? status,  String? locationStore,  String? locationShelf,  String? notes)?  update,TResult? Function( String bundleId)?  delete,TResult? Function( String bundleId)?  scan,}) {final _that = this;
switch (_that) {
case LoadBundles() when load != null:
return load();case CreateBundle() when create != null:
return create(_that.orderReference,_that.cartonCodeIds,_that.packetCodeIds,_that.locationStore,_that.locationShelf,_that.notes);case ShowBundle() when show != null:
return show(_that.bundleId);case UpdateBundle() when update != null:
return update(_that.bundleId,_that.status,_that.locationStore,_that.locationShelf,_that.notes);case DeleteBundle() when delete != null:
return delete(_that.bundleId);case ScanBundle() when scan != null:
return scan(_that.bundleId);case _:
  return null;

}
}

}

/// @nodoc


class LoadBundles implements BundleEvent {
  const LoadBundles();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoadBundles);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BundleEvent.load()';
}


}




/// @nodoc


class CreateBundle implements BundleEvent {
  const CreateBundle({required this.orderReference, final  List<String>? cartonCodeIds, final  List<String>? packetCodeIds, this.locationStore, this.locationShelf, this.notes}): _cartonCodeIds = cartonCodeIds,_packetCodeIds = packetCodeIds;
  

 final  String orderReference;
 final  List<String>? _cartonCodeIds;
 List<String>? get cartonCodeIds {
  final value = _cartonCodeIds;
  if (value == null) return null;
  if (_cartonCodeIds is EqualUnmodifiableListView) return _cartonCodeIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _packetCodeIds;
 List<String>? get packetCodeIds {
  final value = _packetCodeIds;
  if (value == null) return null;
  if (_packetCodeIds is EqualUnmodifiableListView) return _packetCodeIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  String? locationStore;
 final  String? locationShelf;
 final  String? notes;

/// Create a copy of BundleEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateBundleCopyWith<CreateBundle> get copyWith => _$CreateBundleCopyWithImpl<CreateBundle>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateBundle&&(identical(other.orderReference, orderReference) || other.orderReference == orderReference)&&const DeepCollectionEquality().equals(other._cartonCodeIds, _cartonCodeIds)&&const DeepCollectionEquality().equals(other._packetCodeIds, _packetCodeIds)&&(identical(other.locationStore, locationStore) || other.locationStore == locationStore)&&(identical(other.locationShelf, locationShelf) || other.locationShelf == locationShelf)&&(identical(other.notes, notes) || other.notes == notes));
}


@override
int get hashCode => Object.hash(runtimeType,orderReference,const DeepCollectionEquality().hash(_cartonCodeIds),const DeepCollectionEquality().hash(_packetCodeIds),locationStore,locationShelf,notes);

@override
String toString() {
  return 'BundleEvent.create(orderReference: $orderReference, cartonCodeIds: $cartonCodeIds, packetCodeIds: $packetCodeIds, locationStore: $locationStore, locationShelf: $locationShelf, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $CreateBundleCopyWith<$Res> implements $BundleEventCopyWith<$Res> {
  factory $CreateBundleCopyWith(CreateBundle value, $Res Function(CreateBundle) _then) = _$CreateBundleCopyWithImpl;
@useResult
$Res call({
 String orderReference, List<String>? cartonCodeIds, List<String>? packetCodeIds, String? locationStore, String? locationShelf, String? notes
});




}
/// @nodoc
class _$CreateBundleCopyWithImpl<$Res>
    implements $CreateBundleCopyWith<$Res> {
  _$CreateBundleCopyWithImpl(this._self, this._then);

  final CreateBundle _self;
  final $Res Function(CreateBundle) _then;

/// Create a copy of BundleEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? orderReference = null,Object? cartonCodeIds = freezed,Object? packetCodeIds = freezed,Object? locationStore = freezed,Object? locationShelf = freezed,Object? notes = freezed,}) {
  return _then(CreateBundle(
orderReference: null == orderReference ? _self.orderReference : orderReference // ignore: cast_nullable_to_non_nullable
as String,cartonCodeIds: freezed == cartonCodeIds ? _self._cartonCodeIds : cartonCodeIds // ignore: cast_nullable_to_non_nullable
as List<String>?,packetCodeIds: freezed == packetCodeIds ? _self._packetCodeIds : packetCodeIds // ignore: cast_nullable_to_non_nullable
as List<String>?,locationStore: freezed == locationStore ? _self.locationStore : locationStore // ignore: cast_nullable_to_non_nullable
as String?,locationShelf: freezed == locationShelf ? _self.locationShelf : locationShelf // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class ShowBundle implements BundleEvent {
  const ShowBundle(this.bundleId);
  

 final  String bundleId;

/// Create a copy of BundleEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShowBundleCopyWith<ShowBundle> get copyWith => _$ShowBundleCopyWithImpl<ShowBundle>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShowBundle&&(identical(other.bundleId, bundleId) || other.bundleId == bundleId));
}


@override
int get hashCode => Object.hash(runtimeType,bundleId);

@override
String toString() {
  return 'BundleEvent.show(bundleId: $bundleId)';
}


}

/// @nodoc
abstract mixin class $ShowBundleCopyWith<$Res> implements $BundleEventCopyWith<$Res> {
  factory $ShowBundleCopyWith(ShowBundle value, $Res Function(ShowBundle) _then) = _$ShowBundleCopyWithImpl;
@useResult
$Res call({
 String bundleId
});




}
/// @nodoc
class _$ShowBundleCopyWithImpl<$Res>
    implements $ShowBundleCopyWith<$Res> {
  _$ShowBundleCopyWithImpl(this._self, this._then);

  final ShowBundle _self;
  final $Res Function(ShowBundle) _then;

/// Create a copy of BundleEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? bundleId = null,}) {
  return _then(ShowBundle(
null == bundleId ? _self.bundleId : bundleId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class UpdateBundle implements BundleEvent {
  const UpdateBundle({required this.bundleId, this.status, this.locationStore, this.locationShelf, this.notes});
  

 final  String bundleId;
 final  String? status;
 final  String? locationStore;
 final  String? locationShelf;
 final  String? notes;

/// Create a copy of BundleEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateBundleCopyWith<UpdateBundle> get copyWith => _$UpdateBundleCopyWithImpl<UpdateBundle>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateBundle&&(identical(other.bundleId, bundleId) || other.bundleId == bundleId)&&(identical(other.status, status) || other.status == status)&&(identical(other.locationStore, locationStore) || other.locationStore == locationStore)&&(identical(other.locationShelf, locationShelf) || other.locationShelf == locationShelf)&&(identical(other.notes, notes) || other.notes == notes));
}


@override
int get hashCode => Object.hash(runtimeType,bundleId,status,locationStore,locationShelf,notes);

@override
String toString() {
  return 'BundleEvent.update(bundleId: $bundleId, status: $status, locationStore: $locationStore, locationShelf: $locationShelf, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $UpdateBundleCopyWith<$Res> implements $BundleEventCopyWith<$Res> {
  factory $UpdateBundleCopyWith(UpdateBundle value, $Res Function(UpdateBundle) _then) = _$UpdateBundleCopyWithImpl;
@useResult
$Res call({
 String bundleId, String? status, String? locationStore, String? locationShelf, String? notes
});




}
/// @nodoc
class _$UpdateBundleCopyWithImpl<$Res>
    implements $UpdateBundleCopyWith<$Res> {
  _$UpdateBundleCopyWithImpl(this._self, this._then);

  final UpdateBundle _self;
  final $Res Function(UpdateBundle) _then;

/// Create a copy of BundleEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? bundleId = null,Object? status = freezed,Object? locationStore = freezed,Object? locationShelf = freezed,Object? notes = freezed,}) {
  return _then(UpdateBundle(
bundleId: null == bundleId ? _self.bundleId : bundleId // ignore: cast_nullable_to_non_nullable
as String,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,locationStore: freezed == locationStore ? _self.locationStore : locationStore // ignore: cast_nullable_to_non_nullable
as String?,locationShelf: freezed == locationShelf ? _self.locationShelf : locationShelf // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class DeleteBundle implements BundleEvent {
  const DeleteBundle(this.bundleId);
  

 final  String bundleId;

/// Create a copy of BundleEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeleteBundleCopyWith<DeleteBundle> get copyWith => _$DeleteBundleCopyWithImpl<DeleteBundle>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeleteBundle&&(identical(other.bundleId, bundleId) || other.bundleId == bundleId));
}


@override
int get hashCode => Object.hash(runtimeType,bundleId);

@override
String toString() {
  return 'BundleEvent.delete(bundleId: $bundleId)';
}


}

/// @nodoc
abstract mixin class $DeleteBundleCopyWith<$Res> implements $BundleEventCopyWith<$Res> {
  factory $DeleteBundleCopyWith(DeleteBundle value, $Res Function(DeleteBundle) _then) = _$DeleteBundleCopyWithImpl;
@useResult
$Res call({
 String bundleId
});




}
/// @nodoc
class _$DeleteBundleCopyWithImpl<$Res>
    implements $DeleteBundleCopyWith<$Res> {
  _$DeleteBundleCopyWithImpl(this._self, this._then);

  final DeleteBundle _self;
  final $Res Function(DeleteBundle) _then;

/// Create a copy of BundleEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? bundleId = null,}) {
  return _then(DeleteBundle(
null == bundleId ? _self.bundleId : bundleId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ScanBundle implements BundleEvent {
  const ScanBundle(this.bundleId);
  

 final  String bundleId;

/// Create a copy of BundleEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScanBundleCopyWith<ScanBundle> get copyWith => _$ScanBundleCopyWithImpl<ScanBundle>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScanBundle&&(identical(other.bundleId, bundleId) || other.bundleId == bundleId));
}


@override
int get hashCode => Object.hash(runtimeType,bundleId);

@override
String toString() {
  return 'BundleEvent.scan(bundleId: $bundleId)';
}


}

/// @nodoc
abstract mixin class $ScanBundleCopyWith<$Res> implements $BundleEventCopyWith<$Res> {
  factory $ScanBundleCopyWith(ScanBundle value, $Res Function(ScanBundle) _then) = _$ScanBundleCopyWithImpl;
@useResult
$Res call({
 String bundleId
});




}
/// @nodoc
class _$ScanBundleCopyWithImpl<$Res>
    implements $ScanBundleCopyWith<$Res> {
  _$ScanBundleCopyWithImpl(this._self, this._then);

  final ScanBundle _self;
  final $Res Function(ScanBundle) _then;

/// Create a copy of BundleEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? bundleId = null,}) {
  return _then(ScanBundle(
null == bundleId ? _self.bundleId : bundleId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$BundleState {

 BundleStatus get status; List<BundleModel> get bundles; BundleModel? get selectedBundle; String? get errorMessage; int get totalCount; String? get scanResult;
/// Create a copy of BundleState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BundleStateCopyWith<BundleState> get copyWith => _$BundleStateCopyWithImpl<BundleState>(this as BundleState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BundleState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.bundles, bundles)&&(identical(other.selectedBundle, selectedBundle) || other.selectedBundle == selectedBundle)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.scanResult, scanResult) || other.scanResult == scanResult));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(bundles),selectedBundle,errorMessage,totalCount,scanResult);

@override
String toString() {
  return 'BundleState(status: $status, bundles: $bundles, selectedBundle: $selectedBundle, errorMessage: $errorMessage, totalCount: $totalCount, scanResult: $scanResult)';
}


}

/// @nodoc
abstract mixin class $BundleStateCopyWith<$Res>  {
  factory $BundleStateCopyWith(BundleState value, $Res Function(BundleState) _then) = _$BundleStateCopyWithImpl;
@useResult
$Res call({
 BundleStatus status, List<BundleModel> bundles, BundleModel? selectedBundle, String? errorMessage, int totalCount, String? scanResult
});


$BundleModelCopyWith<$Res>? get selectedBundle;

}
/// @nodoc
class _$BundleStateCopyWithImpl<$Res>
    implements $BundleStateCopyWith<$Res> {
  _$BundleStateCopyWithImpl(this._self, this._then);

  final BundleState _self;
  final $Res Function(BundleState) _then;

/// Create a copy of BundleState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? bundles = null,Object? selectedBundle = freezed,Object? errorMessage = freezed,Object? totalCount = null,Object? scanResult = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BundleStatus,bundles: null == bundles ? _self.bundles : bundles // ignore: cast_nullable_to_non_nullable
as List<BundleModel>,selectedBundle: freezed == selectedBundle ? _self.selectedBundle : selectedBundle // ignore: cast_nullable_to_non_nullable
as BundleModel?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,scanResult: freezed == scanResult ? _self.scanResult : scanResult // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of BundleState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BundleModelCopyWith<$Res>? get selectedBundle {
    if (_self.selectedBundle == null) {
    return null;
  }

  return $BundleModelCopyWith<$Res>(_self.selectedBundle!, (value) {
    return _then(_self.copyWith(selectedBundle: value));
  });
}
}


/// Adds pattern-matching-related methods to [BundleState].
extension BundleStatePatterns on BundleState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BundleState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BundleState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BundleState value)  $default,){
final _that = this;
switch (_that) {
case _BundleState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BundleState value)?  $default,){
final _that = this;
switch (_that) {
case _BundleState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( BundleStatus status,  List<BundleModel> bundles,  BundleModel? selectedBundle,  String? errorMessage,  int totalCount,  String? scanResult)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BundleState() when $default != null:
return $default(_that.status,_that.bundles,_that.selectedBundle,_that.errorMessage,_that.totalCount,_that.scanResult);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( BundleStatus status,  List<BundleModel> bundles,  BundleModel? selectedBundle,  String? errorMessage,  int totalCount,  String? scanResult)  $default,) {final _that = this;
switch (_that) {
case _BundleState():
return $default(_that.status,_that.bundles,_that.selectedBundle,_that.errorMessage,_that.totalCount,_that.scanResult);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( BundleStatus status,  List<BundleModel> bundles,  BundleModel? selectedBundle,  String? errorMessage,  int totalCount,  String? scanResult)?  $default,) {final _that = this;
switch (_that) {
case _BundleState() when $default != null:
return $default(_that.status,_that.bundles,_that.selectedBundle,_that.errorMessage,_that.totalCount,_that.scanResult);case _:
  return null;

}
}

}

/// @nodoc


class _BundleState implements BundleState {
  const _BundleState({this.status = BundleStatus.initial, final  List<BundleModel> bundles = const [], this.selectedBundle, this.errorMessage, this.totalCount = 0, this.scanResult}): _bundles = bundles;
  

@override@JsonKey() final  BundleStatus status;
 final  List<BundleModel> _bundles;
@override@JsonKey() List<BundleModel> get bundles {
  if (_bundles is EqualUnmodifiableListView) return _bundles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bundles);
}

@override final  BundleModel? selectedBundle;
@override final  String? errorMessage;
@override@JsonKey() final  int totalCount;
@override final  String? scanResult;

/// Create a copy of BundleState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BundleStateCopyWith<_BundleState> get copyWith => __$BundleStateCopyWithImpl<_BundleState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BundleState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._bundles, _bundles)&&(identical(other.selectedBundle, selectedBundle) || other.selectedBundle == selectedBundle)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.scanResult, scanResult) || other.scanResult == scanResult));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_bundles),selectedBundle,errorMessage,totalCount,scanResult);

@override
String toString() {
  return 'BundleState(status: $status, bundles: $bundles, selectedBundle: $selectedBundle, errorMessage: $errorMessage, totalCount: $totalCount, scanResult: $scanResult)';
}


}

/// @nodoc
abstract mixin class _$BundleStateCopyWith<$Res> implements $BundleStateCopyWith<$Res> {
  factory _$BundleStateCopyWith(_BundleState value, $Res Function(_BundleState) _then) = __$BundleStateCopyWithImpl;
@override @useResult
$Res call({
 BundleStatus status, List<BundleModel> bundles, BundleModel? selectedBundle, String? errorMessage, int totalCount, String? scanResult
});


@override $BundleModelCopyWith<$Res>? get selectedBundle;

}
/// @nodoc
class __$BundleStateCopyWithImpl<$Res>
    implements _$BundleStateCopyWith<$Res> {
  __$BundleStateCopyWithImpl(this._self, this._then);

  final _BundleState _self;
  final $Res Function(_BundleState) _then;

/// Create a copy of BundleState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? bundles = null,Object? selectedBundle = freezed,Object? errorMessage = freezed,Object? totalCount = null,Object? scanResult = freezed,}) {
  return _then(_BundleState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BundleStatus,bundles: null == bundles ? _self._bundles : bundles // ignore: cast_nullable_to_non_nullable
as List<BundleModel>,selectedBundle: freezed == selectedBundle ? _self.selectedBundle : selectedBundle // ignore: cast_nullable_to_non_nullable
as BundleModel?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,scanResult: freezed == scanResult ? _self.scanResult : scanResult // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of BundleState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BundleModelCopyWith<$Res>? get selectedBundle {
    if (_self.selectedBundle == null) {
    return null;
  }

  return $BundleModelCopyWith<$Res>(_self.selectedBundle!, (value) {
    return _then(_self.copyWith(selectedBundle: value));
  });
}
}

// dart format on

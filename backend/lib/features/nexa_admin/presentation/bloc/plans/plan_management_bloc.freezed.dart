// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plan_management_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlanManagementEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlanManagementEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PlanManagementEvent()';
}


}

/// @nodoc
class $PlanManagementEventCopyWith<$Res>  {
$PlanManagementEventCopyWith(PlanManagementEvent _, $Res Function(PlanManagementEvent) __);
}


/// Adds pattern-matching-related methods to [PlanManagementEvent].
extension PlanManagementEventPatterns on PlanManagementEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _LoadPlans value)?  loadPlans,TResult Function( _LoadPlan value)?  loadPlan,TResult Function( _CreatePlan value)?  createPlan,TResult Function( _UpdatePlan value)?  updatePlan,TResult Function( _UpdatePlanStatus value)?  updatePlanStatus,TResult Function( _DeletePlan value)?  deletePlan,TResult Function( _DuplicatePlan value)?  duplicatePlan,TResult Function( _LoadPlanStatistics value)?  loadPlanStatistics,TResult Function( _LoadPlanFeatures value)?  loadPlanFeatures,TResult Function( _ExportPlans value)?  exportPlans,TResult Function( _ClearError value)?  clearError,TResult Function( _Reset value)?  reset,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoadPlans() when loadPlans != null:
return loadPlans(_that);case _LoadPlan() when loadPlan != null:
return loadPlan(_that);case _CreatePlan() when createPlan != null:
return createPlan(_that);case _UpdatePlan() when updatePlan != null:
return updatePlan(_that);case _UpdatePlanStatus() when updatePlanStatus != null:
return updatePlanStatus(_that);case _DeletePlan() when deletePlan != null:
return deletePlan(_that);case _DuplicatePlan() when duplicatePlan != null:
return duplicatePlan(_that);case _LoadPlanStatistics() when loadPlanStatistics != null:
return loadPlanStatistics(_that);case _LoadPlanFeatures() when loadPlanFeatures != null:
return loadPlanFeatures(_that);case _ExportPlans() when exportPlans != null:
return exportPlans(_that);case _ClearError() when clearError != null:
return clearError(_that);case _Reset() when reset != null:
return reset(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _LoadPlans value)  loadPlans,required TResult Function( _LoadPlan value)  loadPlan,required TResult Function( _CreatePlan value)  createPlan,required TResult Function( _UpdatePlan value)  updatePlan,required TResult Function( _UpdatePlanStatus value)  updatePlanStatus,required TResult Function( _DeletePlan value)  deletePlan,required TResult Function( _DuplicatePlan value)  duplicatePlan,required TResult Function( _LoadPlanStatistics value)  loadPlanStatistics,required TResult Function( _LoadPlanFeatures value)  loadPlanFeatures,required TResult Function( _ExportPlans value)  exportPlans,required TResult Function( _ClearError value)  clearError,required TResult Function( _Reset value)  reset,}){
final _that = this;
switch (_that) {
case _LoadPlans():
return loadPlans(_that);case _LoadPlan():
return loadPlan(_that);case _CreatePlan():
return createPlan(_that);case _UpdatePlan():
return updatePlan(_that);case _UpdatePlanStatus():
return updatePlanStatus(_that);case _DeletePlan():
return deletePlan(_that);case _DuplicatePlan():
return duplicatePlan(_that);case _LoadPlanStatistics():
return loadPlanStatistics(_that);case _LoadPlanFeatures():
return loadPlanFeatures(_that);case _ExportPlans():
return exportPlans(_that);case _ClearError():
return clearError(_that);case _Reset():
return reset(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _LoadPlans value)?  loadPlans,TResult? Function( _LoadPlan value)?  loadPlan,TResult? Function( _CreatePlan value)?  createPlan,TResult? Function( _UpdatePlan value)?  updatePlan,TResult? Function( _UpdatePlanStatus value)?  updatePlanStatus,TResult? Function( _DeletePlan value)?  deletePlan,TResult? Function( _DuplicatePlan value)?  duplicatePlan,TResult? Function( _LoadPlanStatistics value)?  loadPlanStatistics,TResult? Function( _LoadPlanFeatures value)?  loadPlanFeatures,TResult? Function( _ExportPlans value)?  exportPlans,TResult? Function( _ClearError value)?  clearError,TResult? Function( _Reset value)?  reset,}){
final _that = this;
switch (_that) {
case _LoadPlans() when loadPlans != null:
return loadPlans(_that);case _LoadPlan() when loadPlan != null:
return loadPlan(_that);case _CreatePlan() when createPlan != null:
return createPlan(_that);case _UpdatePlan() when updatePlan != null:
return updatePlan(_that);case _UpdatePlanStatus() when updatePlanStatus != null:
return updatePlanStatus(_that);case _DeletePlan() when deletePlan != null:
return deletePlan(_that);case _DuplicatePlan() when duplicatePlan != null:
return duplicatePlan(_that);case _LoadPlanStatistics() when loadPlanStatistics != null:
return loadPlanStatistics(_that);case _LoadPlanFeatures() when loadPlanFeatures != null:
return loadPlanFeatures(_that);case _ExportPlans() when exportPlans != null:
return exportPlans(_that);case _ClearError() when clearError != null:
return clearError(_that);case _Reset() when reset != null:
return reset(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String search,  String? type,  String? status,  String sortBy,  String sortOrder,  int page,  int perPage)?  loadPlans,TResult Function( String id)?  loadPlan,TResult Function( String name,  String type,  String? description,  double price,  String billingCycle,  String currency,  String status,  bool? isFeatured,  bool? isPopular,  int? sortOrder,  Map<String, dynamic> limits,  List<PlanFeatureInput>? features,  Map<String, dynamic>? metadata)?  createPlan,TResult Function( String id,  String? name,  String? type,  String? description,  double? price,  String? billingCycle,  String? currency,  String? status,  bool? isFeatured,  bool? isPopular,  int? sortOrder,  Map<String, dynamic>? limits,  List<PlanFeatureInput>? features,  Map<String, dynamic>? metadata)?  updatePlan,TResult Function( String planId,  PlanStatus status)?  updatePlanStatus,TResult Function( String id)?  deletePlan,TResult Function( String id)?  duplicatePlan,TResult Function()?  loadPlanStatistics,TResult Function()?  loadPlanFeatures,TResult Function( String? search,  String? type,  String? status)?  exportPlans,TResult Function()?  clearError,TResult Function()?  reset,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoadPlans() when loadPlans != null:
return loadPlans(_that.search,_that.type,_that.status,_that.sortBy,_that.sortOrder,_that.page,_that.perPage);case _LoadPlan() when loadPlan != null:
return loadPlan(_that.id);case _CreatePlan() when createPlan != null:
return createPlan(_that.name,_that.type,_that.description,_that.price,_that.billingCycle,_that.currency,_that.status,_that.isFeatured,_that.isPopular,_that.sortOrder,_that.limits,_that.features,_that.metadata);case _UpdatePlan() when updatePlan != null:
return updatePlan(_that.id,_that.name,_that.type,_that.description,_that.price,_that.billingCycle,_that.currency,_that.status,_that.isFeatured,_that.isPopular,_that.sortOrder,_that.limits,_that.features,_that.metadata);case _UpdatePlanStatus() when updatePlanStatus != null:
return updatePlanStatus(_that.planId,_that.status);case _DeletePlan() when deletePlan != null:
return deletePlan(_that.id);case _DuplicatePlan() when duplicatePlan != null:
return duplicatePlan(_that.id);case _LoadPlanStatistics() when loadPlanStatistics != null:
return loadPlanStatistics();case _LoadPlanFeatures() when loadPlanFeatures != null:
return loadPlanFeatures();case _ExportPlans() when exportPlans != null:
return exportPlans(_that.search,_that.type,_that.status);case _ClearError() when clearError != null:
return clearError();case _Reset() when reset != null:
return reset();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String search,  String? type,  String? status,  String sortBy,  String sortOrder,  int page,  int perPage)  loadPlans,required TResult Function( String id)  loadPlan,required TResult Function( String name,  String type,  String? description,  double price,  String billingCycle,  String currency,  String status,  bool? isFeatured,  bool? isPopular,  int? sortOrder,  Map<String, dynamic> limits,  List<PlanFeatureInput>? features,  Map<String, dynamic>? metadata)  createPlan,required TResult Function( String id,  String? name,  String? type,  String? description,  double? price,  String? billingCycle,  String? currency,  String? status,  bool? isFeatured,  bool? isPopular,  int? sortOrder,  Map<String, dynamic>? limits,  List<PlanFeatureInput>? features,  Map<String, dynamic>? metadata)  updatePlan,required TResult Function( String planId,  PlanStatus status)  updatePlanStatus,required TResult Function( String id)  deletePlan,required TResult Function( String id)  duplicatePlan,required TResult Function()  loadPlanStatistics,required TResult Function()  loadPlanFeatures,required TResult Function( String? search,  String? type,  String? status)  exportPlans,required TResult Function()  clearError,required TResult Function()  reset,}) {final _that = this;
switch (_that) {
case _LoadPlans():
return loadPlans(_that.search,_that.type,_that.status,_that.sortBy,_that.sortOrder,_that.page,_that.perPage);case _LoadPlan():
return loadPlan(_that.id);case _CreatePlan():
return createPlan(_that.name,_that.type,_that.description,_that.price,_that.billingCycle,_that.currency,_that.status,_that.isFeatured,_that.isPopular,_that.sortOrder,_that.limits,_that.features,_that.metadata);case _UpdatePlan():
return updatePlan(_that.id,_that.name,_that.type,_that.description,_that.price,_that.billingCycle,_that.currency,_that.status,_that.isFeatured,_that.isPopular,_that.sortOrder,_that.limits,_that.features,_that.metadata);case _UpdatePlanStatus():
return updatePlanStatus(_that.planId,_that.status);case _DeletePlan():
return deletePlan(_that.id);case _DuplicatePlan():
return duplicatePlan(_that.id);case _LoadPlanStatistics():
return loadPlanStatistics();case _LoadPlanFeatures():
return loadPlanFeatures();case _ExportPlans():
return exportPlans(_that.search,_that.type,_that.status);case _ClearError():
return clearError();case _Reset():
return reset();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String search,  String? type,  String? status,  String sortBy,  String sortOrder,  int page,  int perPage)?  loadPlans,TResult? Function( String id)?  loadPlan,TResult? Function( String name,  String type,  String? description,  double price,  String billingCycle,  String currency,  String status,  bool? isFeatured,  bool? isPopular,  int? sortOrder,  Map<String, dynamic> limits,  List<PlanFeatureInput>? features,  Map<String, dynamic>? metadata)?  createPlan,TResult? Function( String id,  String? name,  String? type,  String? description,  double? price,  String? billingCycle,  String? currency,  String? status,  bool? isFeatured,  bool? isPopular,  int? sortOrder,  Map<String, dynamic>? limits,  List<PlanFeatureInput>? features,  Map<String, dynamic>? metadata)?  updatePlan,TResult? Function( String planId,  PlanStatus status)?  updatePlanStatus,TResult? Function( String id)?  deletePlan,TResult? Function( String id)?  duplicatePlan,TResult? Function()?  loadPlanStatistics,TResult? Function()?  loadPlanFeatures,TResult? Function( String? search,  String? type,  String? status)?  exportPlans,TResult? Function()?  clearError,TResult? Function()?  reset,}) {final _that = this;
switch (_that) {
case _LoadPlans() when loadPlans != null:
return loadPlans(_that.search,_that.type,_that.status,_that.sortBy,_that.sortOrder,_that.page,_that.perPage);case _LoadPlan() when loadPlan != null:
return loadPlan(_that.id);case _CreatePlan() when createPlan != null:
return createPlan(_that.name,_that.type,_that.description,_that.price,_that.billingCycle,_that.currency,_that.status,_that.isFeatured,_that.isPopular,_that.sortOrder,_that.limits,_that.features,_that.metadata);case _UpdatePlan() when updatePlan != null:
return updatePlan(_that.id,_that.name,_that.type,_that.description,_that.price,_that.billingCycle,_that.currency,_that.status,_that.isFeatured,_that.isPopular,_that.sortOrder,_that.limits,_that.features,_that.metadata);case _UpdatePlanStatus() when updatePlanStatus != null:
return updatePlanStatus(_that.planId,_that.status);case _DeletePlan() when deletePlan != null:
return deletePlan(_that.id);case _DuplicatePlan() when duplicatePlan != null:
return duplicatePlan(_that.id);case _LoadPlanStatistics() when loadPlanStatistics != null:
return loadPlanStatistics();case _LoadPlanFeatures() when loadPlanFeatures != null:
return loadPlanFeatures();case _ExportPlans() when exportPlans != null:
return exportPlans(_that.search,_that.type,_that.status);case _ClearError() when clearError != null:
return clearError();case _Reset() when reset != null:
return reset();case _:
  return null;

}
}

}

/// @nodoc


class _LoadPlans implements PlanManagementEvent {
  const _LoadPlans({this.search = '', this.type, this.status, this.sortBy = 'created_at', this.sortOrder = 'desc', this.page = 1, this.perPage = 20});
  

@JsonKey() final  String search;
 final  String? type;
 final  String? status;
@JsonKey() final  String sortBy;
@JsonKey() final  String sortOrder;
@JsonKey() final  int page;
@JsonKey() final  int perPage;

/// Create a copy of PlanManagementEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadPlansCopyWith<_LoadPlans> get copyWith => __$LoadPlansCopyWithImpl<_LoadPlans>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoadPlans&&(identical(other.search, search) || other.search == search)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.page, page) || other.page == page)&&(identical(other.perPage, perPage) || other.perPage == perPage));
}


@override
int get hashCode => Object.hash(runtimeType,search,type,status,sortBy,sortOrder,page,perPage);

@override
String toString() {
  return 'PlanManagementEvent.loadPlans(search: $search, type: $type, status: $status, sortBy: $sortBy, sortOrder: $sortOrder, page: $page, perPage: $perPage)';
}


}

/// @nodoc
abstract mixin class _$LoadPlansCopyWith<$Res> implements $PlanManagementEventCopyWith<$Res> {
  factory _$LoadPlansCopyWith(_LoadPlans value, $Res Function(_LoadPlans) _then) = __$LoadPlansCopyWithImpl;
@useResult
$Res call({
 String search, String? type, String? status, String sortBy, String sortOrder, int page, int perPage
});




}
/// @nodoc
class __$LoadPlansCopyWithImpl<$Res>
    implements _$LoadPlansCopyWith<$Res> {
  __$LoadPlansCopyWithImpl(this._self, this._then);

  final _LoadPlans _self;
  final $Res Function(_LoadPlans) _then;

/// Create a copy of PlanManagementEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? search = null,Object? type = freezed,Object? status = freezed,Object? sortBy = null,Object? sortOrder = null,Object? page = null,Object? perPage = null,}) {
  return _then(_LoadPlans(
search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as String,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,perPage: null == perPage ? _self.perPage : perPage // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _LoadPlan implements PlanManagementEvent {
  const _LoadPlan(this.id);
  

 final  String id;

/// Create a copy of PlanManagementEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadPlanCopyWith<_LoadPlan> get copyWith => __$LoadPlanCopyWithImpl<_LoadPlan>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoadPlan&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,id);

@override
String toString() {
  return 'PlanManagementEvent.loadPlan(id: $id)';
}


}

/// @nodoc
abstract mixin class _$LoadPlanCopyWith<$Res> implements $PlanManagementEventCopyWith<$Res> {
  factory _$LoadPlanCopyWith(_LoadPlan value, $Res Function(_LoadPlan) _then) = __$LoadPlanCopyWithImpl;
@useResult
$Res call({
 String id
});




}
/// @nodoc
class __$LoadPlanCopyWithImpl<$Res>
    implements _$LoadPlanCopyWith<$Res> {
  __$LoadPlanCopyWithImpl(this._self, this._then);

  final _LoadPlan _self;
  final $Res Function(_LoadPlan) _then;

/// Create a copy of PlanManagementEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,}) {
  return _then(_LoadPlan(
null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _CreatePlan implements PlanManagementEvent {
  const _CreatePlan({required this.name, required this.type, this.description, required this.price, required this.billingCycle, required this.currency, required this.status, this.isFeatured, this.isPopular, this.sortOrder, required final  Map<String, dynamic> limits, final  List<PlanFeatureInput>? features, final  Map<String, dynamic>? metadata}): _limits = limits,_features = features,_metadata = metadata;
  

 final  String name;
 final  String type;
 final  String? description;
 final  double price;
 final  String billingCycle;
 final  String currency;
 final  String status;
 final  bool? isFeatured;
 final  bool? isPopular;
 final  int? sortOrder;
 final  Map<String, dynamic> _limits;
 Map<String, dynamic> get limits {
  if (_limits is EqualUnmodifiableMapView) return _limits;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_limits);
}

 final  List<PlanFeatureInput>? _features;
 List<PlanFeatureInput>? get features {
  final value = _features;
  if (value == null) return null;
  if (_features is EqualUnmodifiableListView) return _features;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  Map<String, dynamic>? _metadata;
 Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of PlanManagementEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreatePlanCopyWith<_CreatePlan> get copyWith => __$CreatePlanCopyWithImpl<_CreatePlan>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreatePlan&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.billingCycle, billingCycle) || other.billingCycle == billingCycle)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.isFeatured, isFeatured) || other.isFeatured == isFeatured)&&(identical(other.isPopular, isPopular) || other.isPopular == isPopular)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&const DeepCollectionEquality().equals(other._limits, _limits)&&const DeepCollectionEquality().equals(other._features, _features)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}


@override
int get hashCode => Object.hash(runtimeType,name,type,description,price,billingCycle,currency,status,isFeatured,isPopular,sortOrder,const DeepCollectionEquality().hash(_limits),const DeepCollectionEquality().hash(_features),const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'PlanManagementEvent.createPlan(name: $name, type: $type, description: $description, price: $price, billingCycle: $billingCycle, currency: $currency, status: $status, isFeatured: $isFeatured, isPopular: $isPopular, sortOrder: $sortOrder, limits: $limits, features: $features, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$CreatePlanCopyWith<$Res> implements $PlanManagementEventCopyWith<$Res> {
  factory _$CreatePlanCopyWith(_CreatePlan value, $Res Function(_CreatePlan) _then) = __$CreatePlanCopyWithImpl;
@useResult
$Res call({
 String name, String type, String? description, double price, String billingCycle, String currency, String status, bool? isFeatured, bool? isPopular, int? sortOrder, Map<String, dynamic> limits, List<PlanFeatureInput>? features, Map<String, dynamic>? metadata
});




}
/// @nodoc
class __$CreatePlanCopyWithImpl<$Res>
    implements _$CreatePlanCopyWith<$Res> {
  __$CreatePlanCopyWithImpl(this._self, this._then);

  final _CreatePlan _self;
  final $Res Function(_CreatePlan) _then;

/// Create a copy of PlanManagementEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? name = null,Object? type = null,Object? description = freezed,Object? price = null,Object? billingCycle = null,Object? currency = null,Object? status = null,Object? isFeatured = freezed,Object? isPopular = freezed,Object? sortOrder = freezed,Object? limits = null,Object? features = freezed,Object? metadata = freezed,}) {
  return _then(_CreatePlan(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,billingCycle: null == billingCycle ? _self.billingCycle : billingCycle // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,isFeatured: freezed == isFeatured ? _self.isFeatured : isFeatured // ignore: cast_nullable_to_non_nullable
as bool?,isPopular: freezed == isPopular ? _self.isPopular : isPopular // ignore: cast_nullable_to_non_nullable
as bool?,sortOrder: freezed == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int?,limits: null == limits ? _self._limits : limits // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,features: freezed == features ? _self._features : features // ignore: cast_nullable_to_non_nullable
as List<PlanFeatureInput>?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

/// @nodoc


class _UpdatePlan implements PlanManagementEvent {
  const _UpdatePlan({required this.id, this.name, this.type, this.description, this.price, this.billingCycle, this.currency, this.status, this.isFeatured, this.isPopular, this.sortOrder, final  Map<String, dynamic>? limits, final  List<PlanFeatureInput>? features, final  Map<String, dynamic>? metadata}): _limits = limits,_features = features,_metadata = metadata;
  

 final  String id;
 final  String? name;
 final  String? type;
 final  String? description;
 final  double? price;
 final  String? billingCycle;
 final  String? currency;
 final  String? status;
 final  bool? isFeatured;
 final  bool? isPopular;
 final  int? sortOrder;
 final  Map<String, dynamic>? _limits;
 Map<String, dynamic>? get limits {
  final value = _limits;
  if (value == null) return null;
  if (_limits is EqualUnmodifiableMapView) return _limits;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<PlanFeatureInput>? _features;
 List<PlanFeatureInput>? get features {
  final value = _features;
  if (value == null) return null;
  if (_features is EqualUnmodifiableListView) return _features;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  Map<String, dynamic>? _metadata;
 Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of PlanManagementEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdatePlanCopyWith<_UpdatePlan> get copyWith => __$UpdatePlanCopyWithImpl<_UpdatePlan>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdatePlan&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.billingCycle, billingCycle) || other.billingCycle == billingCycle)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.isFeatured, isFeatured) || other.isFeatured == isFeatured)&&(identical(other.isPopular, isPopular) || other.isPopular == isPopular)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&const DeepCollectionEquality().equals(other._limits, _limits)&&const DeepCollectionEquality().equals(other._features, _features)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,type,description,price,billingCycle,currency,status,isFeatured,isPopular,sortOrder,const DeepCollectionEquality().hash(_limits),const DeepCollectionEquality().hash(_features),const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'PlanManagementEvent.updatePlan(id: $id, name: $name, type: $type, description: $description, price: $price, billingCycle: $billingCycle, currency: $currency, status: $status, isFeatured: $isFeatured, isPopular: $isPopular, sortOrder: $sortOrder, limits: $limits, features: $features, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$UpdatePlanCopyWith<$Res> implements $PlanManagementEventCopyWith<$Res> {
  factory _$UpdatePlanCopyWith(_UpdatePlan value, $Res Function(_UpdatePlan) _then) = __$UpdatePlanCopyWithImpl;
@useResult
$Res call({
 String id, String? name, String? type, String? description, double? price, String? billingCycle, String? currency, String? status, bool? isFeatured, bool? isPopular, int? sortOrder, Map<String, dynamic>? limits, List<PlanFeatureInput>? features, Map<String, dynamic>? metadata
});




}
/// @nodoc
class __$UpdatePlanCopyWithImpl<$Res>
    implements _$UpdatePlanCopyWith<$Res> {
  __$UpdatePlanCopyWithImpl(this._self, this._then);

  final _UpdatePlan _self;
  final $Res Function(_UpdatePlan) _then;

/// Create a copy of PlanManagementEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = freezed,Object? type = freezed,Object? description = freezed,Object? price = freezed,Object? billingCycle = freezed,Object? currency = freezed,Object? status = freezed,Object? isFeatured = freezed,Object? isPopular = freezed,Object? sortOrder = freezed,Object? limits = freezed,Object? features = freezed,Object? metadata = freezed,}) {
  return _then(_UpdatePlan(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double?,billingCycle: freezed == billingCycle ? _self.billingCycle : billingCycle // ignore: cast_nullable_to_non_nullable
as String?,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,isFeatured: freezed == isFeatured ? _self.isFeatured : isFeatured // ignore: cast_nullable_to_non_nullable
as bool?,isPopular: freezed == isPopular ? _self.isPopular : isPopular // ignore: cast_nullable_to_non_nullable
as bool?,sortOrder: freezed == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int?,limits: freezed == limits ? _self._limits : limits // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,features: freezed == features ? _self._features : features // ignore: cast_nullable_to_non_nullable
as List<PlanFeatureInput>?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

/// @nodoc


class _UpdatePlanStatus implements PlanManagementEvent {
  const _UpdatePlanStatus({required this.planId, required this.status});
  

 final  String planId;
 final  PlanStatus status;

/// Create a copy of PlanManagementEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdatePlanStatusCopyWith<_UpdatePlanStatus> get copyWith => __$UpdatePlanStatusCopyWithImpl<_UpdatePlanStatus>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdatePlanStatus&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,planId,status);

@override
String toString() {
  return 'PlanManagementEvent.updatePlanStatus(planId: $planId, status: $status)';
}


}

/// @nodoc
abstract mixin class _$UpdatePlanStatusCopyWith<$Res> implements $PlanManagementEventCopyWith<$Res> {
  factory _$UpdatePlanStatusCopyWith(_UpdatePlanStatus value, $Res Function(_UpdatePlanStatus) _then) = __$UpdatePlanStatusCopyWithImpl;
@useResult
$Res call({
 String planId, PlanStatus status
});




}
/// @nodoc
class __$UpdatePlanStatusCopyWithImpl<$Res>
    implements _$UpdatePlanStatusCopyWith<$Res> {
  __$UpdatePlanStatusCopyWithImpl(this._self, this._then);

  final _UpdatePlanStatus _self;
  final $Res Function(_UpdatePlanStatus) _then;

/// Create a copy of PlanManagementEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? planId = null,Object? status = null,}) {
  return _then(_UpdatePlanStatus(
planId: null == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PlanStatus,
  ));
}


}

/// @nodoc


class _DeletePlan implements PlanManagementEvent {
  const _DeletePlan(this.id);
  

 final  String id;

/// Create a copy of PlanManagementEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeletePlanCopyWith<_DeletePlan> get copyWith => __$DeletePlanCopyWithImpl<_DeletePlan>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeletePlan&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,id);

@override
String toString() {
  return 'PlanManagementEvent.deletePlan(id: $id)';
}


}

/// @nodoc
abstract mixin class _$DeletePlanCopyWith<$Res> implements $PlanManagementEventCopyWith<$Res> {
  factory _$DeletePlanCopyWith(_DeletePlan value, $Res Function(_DeletePlan) _then) = __$DeletePlanCopyWithImpl;
@useResult
$Res call({
 String id
});




}
/// @nodoc
class __$DeletePlanCopyWithImpl<$Res>
    implements _$DeletePlanCopyWith<$Res> {
  __$DeletePlanCopyWithImpl(this._self, this._then);

  final _DeletePlan _self;
  final $Res Function(_DeletePlan) _then;

/// Create a copy of PlanManagementEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,}) {
  return _then(_DeletePlan(
null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _DuplicatePlan implements PlanManagementEvent {
  const _DuplicatePlan(this.id);
  

 final  String id;

/// Create a copy of PlanManagementEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DuplicatePlanCopyWith<_DuplicatePlan> get copyWith => __$DuplicatePlanCopyWithImpl<_DuplicatePlan>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DuplicatePlan&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,id);

@override
String toString() {
  return 'PlanManagementEvent.duplicatePlan(id: $id)';
}


}

/// @nodoc
abstract mixin class _$DuplicatePlanCopyWith<$Res> implements $PlanManagementEventCopyWith<$Res> {
  factory _$DuplicatePlanCopyWith(_DuplicatePlan value, $Res Function(_DuplicatePlan) _then) = __$DuplicatePlanCopyWithImpl;
@useResult
$Res call({
 String id
});




}
/// @nodoc
class __$DuplicatePlanCopyWithImpl<$Res>
    implements _$DuplicatePlanCopyWith<$Res> {
  __$DuplicatePlanCopyWithImpl(this._self, this._then);

  final _DuplicatePlan _self;
  final $Res Function(_DuplicatePlan) _then;

/// Create a copy of PlanManagementEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,}) {
  return _then(_DuplicatePlan(
null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _LoadPlanStatistics implements PlanManagementEvent {
  const _LoadPlanStatistics();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoadPlanStatistics);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PlanManagementEvent.loadPlanStatistics()';
}


}




/// @nodoc


class _LoadPlanFeatures implements PlanManagementEvent {
  const _LoadPlanFeatures();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoadPlanFeatures);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PlanManagementEvent.loadPlanFeatures()';
}


}




/// @nodoc


class _ExportPlans implements PlanManagementEvent {
  const _ExportPlans({this.search, this.type, this.status});
  

 final  String? search;
 final  String? type;
 final  String? status;

/// Create a copy of PlanManagementEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExportPlansCopyWith<_ExportPlans> get copyWith => __$ExportPlansCopyWithImpl<_ExportPlans>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExportPlans&&(identical(other.search, search) || other.search == search)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,search,type,status);

@override
String toString() {
  return 'PlanManagementEvent.exportPlans(search: $search, type: $type, status: $status)';
}


}

/// @nodoc
abstract mixin class _$ExportPlansCopyWith<$Res> implements $PlanManagementEventCopyWith<$Res> {
  factory _$ExportPlansCopyWith(_ExportPlans value, $Res Function(_ExportPlans) _then) = __$ExportPlansCopyWithImpl;
@useResult
$Res call({
 String? search, String? type, String? status
});




}
/// @nodoc
class __$ExportPlansCopyWithImpl<$Res>
    implements _$ExportPlansCopyWith<$Res> {
  __$ExportPlansCopyWithImpl(this._self, this._then);

  final _ExportPlans _self;
  final $Res Function(_ExportPlans) _then;

/// Create a copy of PlanManagementEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? search = freezed,Object? type = freezed,Object? status = freezed,}) {
  return _then(_ExportPlans(
search: freezed == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _ClearError implements PlanManagementEvent {
  const _ClearError();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClearError);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PlanManagementEvent.clearError()';
}


}




/// @nodoc


class _Reset implements PlanManagementEvent {
  const _Reset();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Reset);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PlanManagementEvent.reset()';
}


}




/// @nodoc
mixin _$PlanManagementState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlanManagementState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PlanManagementState()';
}


}

/// @nodoc
class $PlanManagementStateCopyWith<$Res>  {
$PlanManagementStateCopyWith(PlanManagementState _, $Res Function(PlanManagementState) __);
}


/// Adds pattern-matching-related methods to [PlanManagementState].
extension PlanManagementStatePatterns on PlanManagementState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _Loaded value)?  loaded,TResult Function( _PlanDetailLoaded value)?  planDetailLoaded,TResult Function( _PlanCreated value)?  planCreated,TResult Function( _PlanUpdated value)?  planUpdated,TResult Function( _PlanDeleted value)?  planDeleted,TResult Function( _PlanDuplicated value)?  planDuplicated,TResult Function( _PlanStatusUpdated value)?  planStatusUpdated,TResult Function( _Exporting value)?  exporting,TResult Function( _Exported value)?  exported,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Loaded() when loaded != null:
return loaded(_that);case _PlanDetailLoaded() when planDetailLoaded != null:
return planDetailLoaded(_that);case _PlanCreated() when planCreated != null:
return planCreated(_that);case _PlanUpdated() when planUpdated != null:
return planUpdated(_that);case _PlanDeleted() when planDeleted != null:
return planDeleted(_that);case _PlanDuplicated() when planDuplicated != null:
return planDuplicated(_that);case _PlanStatusUpdated() when planStatusUpdated != null:
return planStatusUpdated(_that);case _Exporting() when exporting != null:
return exporting(_that);case _Exported() when exported != null:
return exported(_that);case _Error() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _Loaded value)  loaded,required TResult Function( _PlanDetailLoaded value)  planDetailLoaded,required TResult Function( _PlanCreated value)  planCreated,required TResult Function( _PlanUpdated value)  planUpdated,required TResult Function( _PlanDeleted value)  planDeleted,required TResult Function( _PlanDuplicated value)  planDuplicated,required TResult Function( _PlanStatusUpdated value)  planStatusUpdated,required TResult Function( _Exporting value)  exporting,required TResult Function( _Exported value)  exported,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _Loaded():
return loaded(_that);case _PlanDetailLoaded():
return planDetailLoaded(_that);case _PlanCreated():
return planCreated(_that);case _PlanUpdated():
return planUpdated(_that);case _PlanDeleted():
return planDeleted(_that);case _PlanDuplicated():
return planDuplicated(_that);case _PlanStatusUpdated():
return planStatusUpdated(_that);case _Exporting():
return exporting(_that);case _Exported():
return exported(_that);case _Error():
return error(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _Loaded value)?  loaded,TResult? Function( _PlanDetailLoaded value)?  planDetailLoaded,TResult? Function( _PlanCreated value)?  planCreated,TResult? Function( _PlanUpdated value)?  planUpdated,TResult? Function( _PlanDeleted value)?  planDeleted,TResult? Function( _PlanDuplicated value)?  planDuplicated,TResult? Function( _PlanStatusUpdated value)?  planStatusUpdated,TResult? Function( _Exporting value)?  exporting,TResult? Function( _Exported value)?  exported,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Loaded() when loaded != null:
return loaded(_that);case _PlanDetailLoaded() when planDetailLoaded != null:
return planDetailLoaded(_that);case _PlanCreated() when planCreated != null:
return planCreated(_that);case _PlanUpdated() when planUpdated != null:
return planUpdated(_that);case _PlanDeleted() when planDeleted != null:
return planDeleted(_that);case _PlanDuplicated() when planDuplicated != null:
return planDuplicated(_that);case _PlanStatusUpdated() when planStatusUpdated != null:
return planStatusUpdated(_that);case _Exporting() when exporting != null:
return exporting(_that);case _Exported() when exported != null:
return exported(_that);case _Error() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<Plan> plans,  int total,  int page,  int perPage,  int totalPages,  String search,  String? type,  String? status,  String sortBy,  String sortOrder,  PlanStatistics? statistics,  Map<String, List<PlanFeature>> availableFeatures)?  loaded,TResult Function( Plan plan,  Map<String, List<PlanFeature>> availableFeatures)?  planDetailLoaded,TResult Function( Plan plan,  String message)?  planCreated,TResult Function( Plan plan,  String message)?  planUpdated,TResult Function( String planId,  String message)?  planDeleted,TResult Function( Plan plan,  String message)?  planDuplicated,TResult Function( String planId,  PlanStatus newStatus,  String message)?  planStatusUpdated,TResult Function()?  exporting,TResult Function( String filePath,  String message)?  exported,TResult Function( String message,  bool isNetworkError,  bool isServerError,  bool isValidationError,  StackTrace? stackTrace)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Loaded() when loaded != null:
return loaded(_that.plans,_that.total,_that.page,_that.perPage,_that.totalPages,_that.search,_that.type,_that.status,_that.sortBy,_that.sortOrder,_that.statistics,_that.availableFeatures);case _PlanDetailLoaded() when planDetailLoaded != null:
return planDetailLoaded(_that.plan,_that.availableFeatures);case _PlanCreated() when planCreated != null:
return planCreated(_that.plan,_that.message);case _PlanUpdated() when planUpdated != null:
return planUpdated(_that.plan,_that.message);case _PlanDeleted() when planDeleted != null:
return planDeleted(_that.planId,_that.message);case _PlanDuplicated() when planDuplicated != null:
return planDuplicated(_that.plan,_that.message);case _PlanStatusUpdated() when planStatusUpdated != null:
return planStatusUpdated(_that.planId,_that.newStatus,_that.message);case _Exporting() when exporting != null:
return exporting();case _Exported() when exported != null:
return exported(_that.filePath,_that.message);case _Error() when error != null:
return error(_that.message,_that.isNetworkError,_that.isServerError,_that.isValidationError,_that.stackTrace);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<Plan> plans,  int total,  int page,  int perPage,  int totalPages,  String search,  String? type,  String? status,  String sortBy,  String sortOrder,  PlanStatistics? statistics,  Map<String, List<PlanFeature>> availableFeatures)  loaded,required TResult Function( Plan plan,  Map<String, List<PlanFeature>> availableFeatures)  planDetailLoaded,required TResult Function( Plan plan,  String message)  planCreated,required TResult Function( Plan plan,  String message)  planUpdated,required TResult Function( String planId,  String message)  planDeleted,required TResult Function( Plan plan,  String message)  planDuplicated,required TResult Function( String planId,  PlanStatus newStatus,  String message)  planStatusUpdated,required TResult Function()  exporting,required TResult Function( String filePath,  String message)  exported,required TResult Function( String message,  bool isNetworkError,  bool isServerError,  bool isValidationError,  StackTrace? stackTrace)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _Loaded():
return loaded(_that.plans,_that.total,_that.page,_that.perPage,_that.totalPages,_that.search,_that.type,_that.status,_that.sortBy,_that.sortOrder,_that.statistics,_that.availableFeatures);case _PlanDetailLoaded():
return planDetailLoaded(_that.plan,_that.availableFeatures);case _PlanCreated():
return planCreated(_that.plan,_that.message);case _PlanUpdated():
return planUpdated(_that.plan,_that.message);case _PlanDeleted():
return planDeleted(_that.planId,_that.message);case _PlanDuplicated():
return planDuplicated(_that.plan,_that.message);case _PlanStatusUpdated():
return planStatusUpdated(_that.planId,_that.newStatus,_that.message);case _Exporting():
return exporting();case _Exported():
return exported(_that.filePath,_that.message);case _Error():
return error(_that.message,_that.isNetworkError,_that.isServerError,_that.isValidationError,_that.stackTrace);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<Plan> plans,  int total,  int page,  int perPage,  int totalPages,  String search,  String? type,  String? status,  String sortBy,  String sortOrder,  PlanStatistics? statistics,  Map<String, List<PlanFeature>> availableFeatures)?  loaded,TResult? Function( Plan plan,  Map<String, List<PlanFeature>> availableFeatures)?  planDetailLoaded,TResult? Function( Plan plan,  String message)?  planCreated,TResult? Function( Plan plan,  String message)?  planUpdated,TResult? Function( String planId,  String message)?  planDeleted,TResult? Function( Plan plan,  String message)?  planDuplicated,TResult? Function( String planId,  PlanStatus newStatus,  String message)?  planStatusUpdated,TResult? Function()?  exporting,TResult? Function( String filePath,  String message)?  exported,TResult? Function( String message,  bool isNetworkError,  bool isServerError,  bool isValidationError,  StackTrace? stackTrace)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Loaded() when loaded != null:
return loaded(_that.plans,_that.total,_that.page,_that.perPage,_that.totalPages,_that.search,_that.type,_that.status,_that.sortBy,_that.sortOrder,_that.statistics,_that.availableFeatures);case _PlanDetailLoaded() when planDetailLoaded != null:
return planDetailLoaded(_that.plan,_that.availableFeatures);case _PlanCreated() when planCreated != null:
return planCreated(_that.plan,_that.message);case _PlanUpdated() when planUpdated != null:
return planUpdated(_that.plan,_that.message);case _PlanDeleted() when planDeleted != null:
return planDeleted(_that.planId,_that.message);case _PlanDuplicated() when planDuplicated != null:
return planDuplicated(_that.plan,_that.message);case _PlanStatusUpdated() when planStatusUpdated != null:
return planStatusUpdated(_that.planId,_that.newStatus,_that.message);case _Exporting() when exporting != null:
return exporting();case _Exported() when exported != null:
return exported(_that.filePath,_that.message);case _Error() when error != null:
return error(_that.message,_that.isNetworkError,_that.isServerError,_that.isValidationError,_that.stackTrace);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements PlanManagementState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PlanManagementState.initial()';
}


}




/// @nodoc


class _Loading implements PlanManagementState {
  const _Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PlanManagementState.loading()';
}


}




/// @nodoc


class _Loaded implements PlanManagementState {
  const _Loaded({required final  List<Plan> plans, required this.total, required this.page, required this.perPage, required this.totalPages, required this.search, this.type, this.status, required this.sortBy, required this.sortOrder, required this.statistics, required final  Map<String, List<PlanFeature>> availableFeatures}): _plans = plans,_availableFeatures = availableFeatures;
  

 final  List<Plan> _plans;
 List<Plan> get plans {
  if (_plans is EqualUnmodifiableListView) return _plans;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_plans);
}

 final  int total;
 final  int page;
 final  int perPage;
 final  int totalPages;
 final  String search;
 final  String? type;
 final  String? status;
 final  String sortBy;
 final  String sortOrder;
 final  PlanStatistics? statistics;
 final  Map<String, List<PlanFeature>> _availableFeatures;
 Map<String, List<PlanFeature>> get availableFeatures {
  if (_availableFeatures is EqualUnmodifiableMapView) return _availableFeatures;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_availableFeatures);
}


/// Create a copy of PlanManagementState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadedCopyWith<_Loaded> get copyWith => __$LoadedCopyWithImpl<_Loaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loaded&&const DeepCollectionEquality().equals(other._plans, _plans)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.perPage, perPage) || other.perPage == perPage)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.search, search) || other.search == search)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.statistics, statistics) || other.statistics == statistics)&&const DeepCollectionEquality().equals(other._availableFeatures, _availableFeatures));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_plans),total,page,perPage,totalPages,search,type,status,sortBy,sortOrder,statistics,const DeepCollectionEquality().hash(_availableFeatures));

@override
String toString() {
  return 'PlanManagementState.loaded(plans: $plans, total: $total, page: $page, perPage: $perPage, totalPages: $totalPages, search: $search, type: $type, status: $status, sortBy: $sortBy, sortOrder: $sortOrder, statistics: $statistics, availableFeatures: $availableFeatures)';
}


}

/// @nodoc
abstract mixin class _$LoadedCopyWith<$Res> implements $PlanManagementStateCopyWith<$Res> {
  factory _$LoadedCopyWith(_Loaded value, $Res Function(_Loaded) _then) = __$LoadedCopyWithImpl;
@useResult
$Res call({
 List<Plan> plans, int total, int page, int perPage, int totalPages, String search, String? type, String? status, String sortBy, String sortOrder, PlanStatistics? statistics, Map<String, List<PlanFeature>> availableFeatures
});




}
/// @nodoc
class __$LoadedCopyWithImpl<$Res>
    implements _$LoadedCopyWith<$Res> {
  __$LoadedCopyWithImpl(this._self, this._then);

  final _Loaded _self;
  final $Res Function(_Loaded) _then;

/// Create a copy of PlanManagementState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? plans = null,Object? total = null,Object? page = null,Object? perPage = null,Object? totalPages = null,Object? search = null,Object? type = freezed,Object? status = freezed,Object? sortBy = null,Object? sortOrder = null,Object? statistics = freezed,Object? availableFeatures = null,}) {
  return _then(_Loaded(
plans: null == plans ? _self._plans : plans // ignore: cast_nullable_to_non_nullable
as List<Plan>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,perPage: null == perPage ? _self.perPage : perPage // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as String,statistics: freezed == statistics ? _self.statistics : statistics // ignore: cast_nullable_to_non_nullable
as PlanStatistics?,availableFeatures: null == availableFeatures ? _self._availableFeatures : availableFeatures // ignore: cast_nullable_to_non_nullable
as Map<String, List<PlanFeature>>,
  ));
}


}

/// @nodoc


class _PlanDetailLoaded implements PlanManagementState {
  const _PlanDetailLoaded({required this.plan, required final  Map<String, List<PlanFeature>> availableFeatures}): _availableFeatures = availableFeatures;
  

 final  Plan plan;
 final  Map<String, List<PlanFeature>> _availableFeatures;
 Map<String, List<PlanFeature>> get availableFeatures {
  if (_availableFeatures is EqualUnmodifiableMapView) return _availableFeatures;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_availableFeatures);
}


/// Create a copy of PlanManagementState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlanDetailLoadedCopyWith<_PlanDetailLoaded> get copyWith => __$PlanDetailLoadedCopyWithImpl<_PlanDetailLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlanDetailLoaded&&(identical(other.plan, plan) || other.plan == plan)&&const DeepCollectionEquality().equals(other._availableFeatures, _availableFeatures));
}


@override
int get hashCode => Object.hash(runtimeType,plan,const DeepCollectionEquality().hash(_availableFeatures));

@override
String toString() {
  return 'PlanManagementState.planDetailLoaded(plan: $plan, availableFeatures: $availableFeatures)';
}


}

/// @nodoc
abstract mixin class _$PlanDetailLoadedCopyWith<$Res> implements $PlanManagementStateCopyWith<$Res> {
  factory _$PlanDetailLoadedCopyWith(_PlanDetailLoaded value, $Res Function(_PlanDetailLoaded) _then) = __$PlanDetailLoadedCopyWithImpl;
@useResult
$Res call({
 Plan plan, Map<String, List<PlanFeature>> availableFeatures
});


$PlanCopyWith<$Res> get plan;

}
/// @nodoc
class __$PlanDetailLoadedCopyWithImpl<$Res>
    implements _$PlanDetailLoadedCopyWith<$Res> {
  __$PlanDetailLoadedCopyWithImpl(this._self, this._then);

  final _PlanDetailLoaded _self;
  final $Res Function(_PlanDetailLoaded) _then;

/// Create a copy of PlanManagementState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? plan = null,Object? availableFeatures = null,}) {
  return _then(_PlanDetailLoaded(
plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as Plan,availableFeatures: null == availableFeatures ? _self._availableFeatures : availableFeatures // ignore: cast_nullable_to_non_nullable
as Map<String, List<PlanFeature>>,
  ));
}

/// Create a copy of PlanManagementState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlanCopyWith<$Res> get plan {
  
  return $PlanCopyWith<$Res>(_self.plan, (value) {
    return _then(_self.copyWith(plan: value));
  });
}
}

/// @nodoc


class _PlanCreated implements PlanManagementState {
  const _PlanCreated({required this.plan, required this.message});
  

 final  Plan plan;
 final  String message;

/// Create a copy of PlanManagementState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlanCreatedCopyWith<_PlanCreated> get copyWith => __$PlanCreatedCopyWithImpl<_PlanCreated>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlanCreated&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,plan,message);

@override
String toString() {
  return 'PlanManagementState.planCreated(plan: $plan, message: $message)';
}


}

/// @nodoc
abstract mixin class _$PlanCreatedCopyWith<$Res> implements $PlanManagementStateCopyWith<$Res> {
  factory _$PlanCreatedCopyWith(_PlanCreated value, $Res Function(_PlanCreated) _then) = __$PlanCreatedCopyWithImpl;
@useResult
$Res call({
 Plan plan, String message
});


$PlanCopyWith<$Res> get plan;

}
/// @nodoc
class __$PlanCreatedCopyWithImpl<$Res>
    implements _$PlanCreatedCopyWith<$Res> {
  __$PlanCreatedCopyWithImpl(this._self, this._then);

  final _PlanCreated _self;
  final $Res Function(_PlanCreated) _then;

/// Create a copy of PlanManagementState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? plan = null,Object? message = null,}) {
  return _then(_PlanCreated(
plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as Plan,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of PlanManagementState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlanCopyWith<$Res> get plan {
  
  return $PlanCopyWith<$Res>(_self.plan, (value) {
    return _then(_self.copyWith(plan: value));
  });
}
}

/// @nodoc


class _PlanUpdated implements PlanManagementState {
  const _PlanUpdated({required this.plan, required this.message});
  

 final  Plan plan;
 final  String message;

/// Create a copy of PlanManagementState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlanUpdatedCopyWith<_PlanUpdated> get copyWith => __$PlanUpdatedCopyWithImpl<_PlanUpdated>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlanUpdated&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,plan,message);

@override
String toString() {
  return 'PlanManagementState.planUpdated(plan: $plan, message: $message)';
}


}

/// @nodoc
abstract mixin class _$PlanUpdatedCopyWith<$Res> implements $PlanManagementStateCopyWith<$Res> {
  factory _$PlanUpdatedCopyWith(_PlanUpdated value, $Res Function(_PlanUpdated) _then) = __$PlanUpdatedCopyWithImpl;
@useResult
$Res call({
 Plan plan, String message
});


$PlanCopyWith<$Res> get plan;

}
/// @nodoc
class __$PlanUpdatedCopyWithImpl<$Res>
    implements _$PlanUpdatedCopyWith<$Res> {
  __$PlanUpdatedCopyWithImpl(this._self, this._then);

  final _PlanUpdated _self;
  final $Res Function(_PlanUpdated) _then;

/// Create a copy of PlanManagementState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? plan = null,Object? message = null,}) {
  return _then(_PlanUpdated(
plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as Plan,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of PlanManagementState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlanCopyWith<$Res> get plan {
  
  return $PlanCopyWith<$Res>(_self.plan, (value) {
    return _then(_self.copyWith(plan: value));
  });
}
}

/// @nodoc


class _PlanDeleted implements PlanManagementState {
  const _PlanDeleted({required this.planId, required this.message});
  

 final  String planId;
 final  String message;

/// Create a copy of PlanManagementState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlanDeletedCopyWith<_PlanDeleted> get copyWith => __$PlanDeletedCopyWithImpl<_PlanDeleted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlanDeleted&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,planId,message);

@override
String toString() {
  return 'PlanManagementState.planDeleted(planId: $planId, message: $message)';
}


}

/// @nodoc
abstract mixin class _$PlanDeletedCopyWith<$Res> implements $PlanManagementStateCopyWith<$Res> {
  factory _$PlanDeletedCopyWith(_PlanDeleted value, $Res Function(_PlanDeleted) _then) = __$PlanDeletedCopyWithImpl;
@useResult
$Res call({
 String planId, String message
});




}
/// @nodoc
class __$PlanDeletedCopyWithImpl<$Res>
    implements _$PlanDeletedCopyWith<$Res> {
  __$PlanDeletedCopyWithImpl(this._self, this._then);

  final _PlanDeleted _self;
  final $Res Function(_PlanDeleted) _then;

/// Create a copy of PlanManagementState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? planId = null,Object? message = null,}) {
  return _then(_PlanDeleted(
planId: null == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _PlanDuplicated implements PlanManagementState {
  const _PlanDuplicated({required this.plan, required this.message});
  

 final  Plan plan;
 final  String message;

/// Create a copy of PlanManagementState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlanDuplicatedCopyWith<_PlanDuplicated> get copyWith => __$PlanDuplicatedCopyWithImpl<_PlanDuplicated>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlanDuplicated&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,plan,message);

@override
String toString() {
  return 'PlanManagementState.planDuplicated(plan: $plan, message: $message)';
}


}

/// @nodoc
abstract mixin class _$PlanDuplicatedCopyWith<$Res> implements $PlanManagementStateCopyWith<$Res> {
  factory _$PlanDuplicatedCopyWith(_PlanDuplicated value, $Res Function(_PlanDuplicated) _then) = __$PlanDuplicatedCopyWithImpl;
@useResult
$Res call({
 Plan plan, String message
});


$PlanCopyWith<$Res> get plan;

}
/// @nodoc
class __$PlanDuplicatedCopyWithImpl<$Res>
    implements _$PlanDuplicatedCopyWith<$Res> {
  __$PlanDuplicatedCopyWithImpl(this._self, this._then);

  final _PlanDuplicated _self;
  final $Res Function(_PlanDuplicated) _then;

/// Create a copy of PlanManagementState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? plan = null,Object? message = null,}) {
  return _then(_PlanDuplicated(
plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as Plan,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of PlanManagementState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlanCopyWith<$Res> get plan {
  
  return $PlanCopyWith<$Res>(_self.plan, (value) {
    return _then(_self.copyWith(plan: value));
  });
}
}

/// @nodoc


class _PlanStatusUpdated implements PlanManagementState {
  const _PlanStatusUpdated({required this.planId, required this.newStatus, required this.message});
  

 final  String planId;
 final  PlanStatus newStatus;
 final  String message;

/// Create a copy of PlanManagementState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlanStatusUpdatedCopyWith<_PlanStatusUpdated> get copyWith => __$PlanStatusUpdatedCopyWithImpl<_PlanStatusUpdated>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlanStatusUpdated&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.newStatus, newStatus) || other.newStatus == newStatus)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,planId,newStatus,message);

@override
String toString() {
  return 'PlanManagementState.planStatusUpdated(planId: $planId, newStatus: $newStatus, message: $message)';
}


}

/// @nodoc
abstract mixin class _$PlanStatusUpdatedCopyWith<$Res> implements $PlanManagementStateCopyWith<$Res> {
  factory _$PlanStatusUpdatedCopyWith(_PlanStatusUpdated value, $Res Function(_PlanStatusUpdated) _then) = __$PlanStatusUpdatedCopyWithImpl;
@useResult
$Res call({
 String planId, PlanStatus newStatus, String message
});




}
/// @nodoc
class __$PlanStatusUpdatedCopyWithImpl<$Res>
    implements _$PlanStatusUpdatedCopyWith<$Res> {
  __$PlanStatusUpdatedCopyWithImpl(this._self, this._then);

  final _PlanStatusUpdated _self;
  final $Res Function(_PlanStatusUpdated) _then;

/// Create a copy of PlanManagementState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? planId = null,Object? newStatus = null,Object? message = null,}) {
  return _then(_PlanStatusUpdated(
planId: null == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String,newStatus: null == newStatus ? _self.newStatus : newStatus // ignore: cast_nullable_to_non_nullable
as PlanStatus,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _Exporting implements PlanManagementState {
  const _Exporting();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Exporting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PlanManagementState.exporting()';
}


}




/// @nodoc


class _Exported implements PlanManagementState {
  const _Exported({required this.filePath, required this.message});
  

 final  String filePath;
 final  String message;

/// Create a copy of PlanManagementState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExportedCopyWith<_Exported> get copyWith => __$ExportedCopyWithImpl<_Exported>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Exported&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,filePath,message);

@override
String toString() {
  return 'PlanManagementState.exported(filePath: $filePath, message: $message)';
}


}

/// @nodoc
abstract mixin class _$ExportedCopyWith<$Res> implements $PlanManagementStateCopyWith<$Res> {
  factory _$ExportedCopyWith(_Exported value, $Res Function(_Exported) _then) = __$ExportedCopyWithImpl;
@useResult
$Res call({
 String filePath, String message
});




}
/// @nodoc
class __$ExportedCopyWithImpl<$Res>
    implements _$ExportedCopyWith<$Res> {
  __$ExportedCopyWithImpl(this._self, this._then);

  final _Exported _self;
  final $Res Function(_Exported) _then;

/// Create a copy of PlanManagementState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? filePath = null,Object? message = null,}) {
  return _then(_Exported(
filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _Error implements PlanManagementState {
  const _Error({required this.message, this.isNetworkError = false, this.isServerError = false, this.isValidationError = false, this.stackTrace});
  

 final  String message;
@JsonKey() final  bool isNetworkError;
@JsonKey() final  bool isServerError;
@JsonKey() final  bool isValidationError;
 final  StackTrace? stackTrace;

/// Create a copy of PlanManagementState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error&&(identical(other.message, message) || other.message == message)&&(identical(other.isNetworkError, isNetworkError) || other.isNetworkError == isNetworkError)&&(identical(other.isServerError, isServerError) || other.isServerError == isServerError)&&(identical(other.isValidationError, isValidationError) || other.isValidationError == isValidationError)&&(identical(other.stackTrace, stackTrace) || other.stackTrace == stackTrace));
}


@override
int get hashCode => Object.hash(runtimeType,message,isNetworkError,isServerError,isValidationError,stackTrace);

@override
String toString() {
  return 'PlanManagementState.error(message: $message, isNetworkError: $isNetworkError, isServerError: $isServerError, isValidationError: $isValidationError, stackTrace: $stackTrace)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $PlanManagementStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) = __$ErrorCopyWithImpl;
@useResult
$Res call({
 String message, bool isNetworkError, bool isServerError, bool isValidationError, StackTrace? stackTrace
});




}
/// @nodoc
class __$ErrorCopyWithImpl<$Res>
    implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

/// Create a copy of PlanManagementState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,Object? isNetworkError = null,Object? isServerError = null,Object? isValidationError = null,Object? stackTrace = freezed,}) {
  return _then(_Error(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,isNetworkError: null == isNetworkError ? _self.isNetworkError : isNetworkError // ignore: cast_nullable_to_non_nullable
as bool,isServerError: null == isServerError ? _self.isServerError : isServerError // ignore: cast_nullable_to_non_nullable
as bool,isValidationError: null == isValidationError ? _self.isValidationError : isValidationError // ignore: cast_nullable_to_non_nullable
as bool,stackTrace: freezed == stackTrace ? _self.stackTrace : stackTrace // ignore: cast_nullable_to_non_nullable
as StackTrace?,
  ));
}


}

// dart format on

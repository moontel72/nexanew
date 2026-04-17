// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plan_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Plan {

/// Unique identifier for the plan
@JsonKey(name: 'id') String get id;/// Name of the plan (e.g., "Free Plan", "Basic Plan")
@JsonKey(name: 'name') String get name;/// Type of the plan (Free, Basic, Standard, Premium, Custom)
@JsonKey(name: 'type') PlanType get type;/// Description of the plan
@JsonKey(name: 'description') String get description;/// Monthly price of the plan
@JsonKey(name: 'monthly_price') double get monthlyPrice;/// Yearly price of the plan
@JsonKey(name: 'yearly_price') double get yearlyPrice;/// Currency of the price (e.g., 'USD', 'EUR')
 String get currency;/// Billing cycle (e.g., 'monthly', 'yearly')
@JsonKey(name: 'billing_cycle') String get billingCycle;/// Current status of the plan
 PlanStatus get status;/// Whether the plan is featured
@JsonKey(name: 'is_featured') bool get isFeatured;/// Whether the plan is marked as popular
@JsonKey(name: 'is_popular') bool get isPopular;/// Order in which the plan is displayed
@JsonKey(name: 'sort_order') int get sortOrder;/// List of features included in the plan
 List<PlanFeature> get features;/// Plan limits (e.g., max users, max codes)
 Map<String, dynamic> get limits;/// Metadata for the plan
 Map<String, dynamic>? get metadata;/// User limits for this plan
@JsonKey(name: 'user_limits') UserLimits get userLimits;/// Storage limit in GB
@JsonKey(name: 'storage_gb') int get storageGb;/// Daily API call limit
@JsonKey(name: 'daily_api_calls') int get dailyApiCalls;/// Whether the plan is recommended
@JsonKey(name: 'is_recommended') bool get isRecommended;/// Number of companies using this plan
@JsonKey(name: 'company_count') int get companyCount;/// Date when the plan was created
@JsonKey(name: 'created_at') DateTime get createdAt;/// Date when the plan was last updated
@JsonKey(name: 'updated_at') DateTime get updatedAt;/// Date when the plan was archived (if applicable)
@JsonKey(name: 'archived_at') DateTime? get archivedAt;
/// Create a copy of Plan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlanCopyWith<Plan> get copyWith => _$PlanCopyWithImpl<Plan>(this as Plan, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Plan&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.description, description) || other.description == description)&&(identical(other.monthlyPrice, monthlyPrice) || other.monthlyPrice == monthlyPrice)&&(identical(other.yearlyPrice, yearlyPrice) || other.yearlyPrice == yearlyPrice)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.billingCycle, billingCycle) || other.billingCycle == billingCycle)&&(identical(other.status, status) || other.status == status)&&(identical(other.isFeatured, isFeatured) || other.isFeatured == isFeatured)&&(identical(other.isPopular, isPopular) || other.isPopular == isPopular)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&const DeepCollectionEquality().equals(other.features, features)&&const DeepCollectionEquality().equals(other.limits, limits)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.userLimits, userLimits) || other.userLimits == userLimits)&&(identical(other.storageGb, storageGb) || other.storageGb == storageGb)&&(identical(other.dailyApiCalls, dailyApiCalls) || other.dailyApiCalls == dailyApiCalls)&&(identical(other.isRecommended, isRecommended) || other.isRecommended == isRecommended)&&(identical(other.companyCount, companyCount) || other.companyCount == companyCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,name,type,description,monthlyPrice,yearlyPrice,currency,billingCycle,status,isFeatured,isPopular,sortOrder,const DeepCollectionEquality().hash(features),const DeepCollectionEquality().hash(limits),const DeepCollectionEquality().hash(metadata),userLimits,storageGb,dailyApiCalls,isRecommended,companyCount,createdAt,updatedAt,archivedAt]);

@override
String toString() {
  return 'Plan(id: $id, name: $name, type: $type, description: $description, monthlyPrice: $monthlyPrice, yearlyPrice: $yearlyPrice, currency: $currency, billingCycle: $billingCycle, status: $status, isFeatured: $isFeatured, isPopular: $isPopular, sortOrder: $sortOrder, features: $features, limits: $limits, metadata: $metadata, userLimits: $userLimits, storageGb: $storageGb, dailyApiCalls: $dailyApiCalls, isRecommended: $isRecommended, companyCount: $companyCount, createdAt: $createdAt, updatedAt: $updatedAt, archivedAt: $archivedAt)';
}


}

/// @nodoc
abstract mixin class $PlanCopyWith<$Res>  {
  factory $PlanCopyWith(Plan value, $Res Function(Plan) _then) = _$PlanCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id') String id,@JsonKey(name: 'name') String name,@JsonKey(name: 'type') PlanType type,@JsonKey(name: 'description') String description,@JsonKey(name: 'monthly_price') double monthlyPrice,@JsonKey(name: 'yearly_price') double yearlyPrice, String currency,@JsonKey(name: 'billing_cycle') String billingCycle, PlanStatus status,@JsonKey(name: 'is_featured') bool isFeatured,@JsonKey(name: 'is_popular') bool isPopular,@JsonKey(name: 'sort_order') int sortOrder, List<PlanFeature> features, Map<String, dynamic> limits, Map<String, dynamic>? metadata,@JsonKey(name: 'user_limits') UserLimits userLimits,@JsonKey(name: 'storage_gb') int storageGb,@JsonKey(name: 'daily_api_calls') int dailyApiCalls,@JsonKey(name: 'is_recommended') bool isRecommended,@JsonKey(name: 'company_count') int companyCount,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'archived_at') DateTime? archivedAt
});


$UserLimitsCopyWith<$Res> get userLimits;

}
/// @nodoc
class _$PlanCopyWithImpl<$Res>
    implements $PlanCopyWith<$Res> {
  _$PlanCopyWithImpl(this._self, this._then);

  final Plan _self;
  final $Res Function(Plan) _then;

/// Create a copy of Plan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? description = null,Object? monthlyPrice = null,Object? yearlyPrice = null,Object? currency = null,Object? billingCycle = null,Object? status = null,Object? isFeatured = null,Object? isPopular = null,Object? sortOrder = null,Object? features = null,Object? limits = null,Object? metadata = freezed,Object? userLimits = null,Object? storageGb = null,Object? dailyApiCalls = null,Object? isRecommended = null,Object? companyCount = null,Object? createdAt = null,Object? updatedAt = null,Object? archivedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PlanType,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,monthlyPrice: null == monthlyPrice ? _self.monthlyPrice : monthlyPrice // ignore: cast_nullable_to_non_nullable
as double,yearlyPrice: null == yearlyPrice ? _self.yearlyPrice : yearlyPrice // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,billingCycle: null == billingCycle ? _self.billingCycle : billingCycle // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PlanStatus,isFeatured: null == isFeatured ? _self.isFeatured : isFeatured // ignore: cast_nullable_to_non_nullable
as bool,isPopular: null == isPopular ? _self.isPopular : isPopular // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,features: null == features ? _self.features : features // ignore: cast_nullable_to_non_nullable
as List<PlanFeature>,limits: null == limits ? _self.limits : limits // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,userLimits: null == userLimits ? _self.userLimits : userLimits // ignore: cast_nullable_to_non_nullable
as UserLimits,storageGb: null == storageGb ? _self.storageGb : storageGb // ignore: cast_nullable_to_non_nullable
as int,dailyApiCalls: null == dailyApiCalls ? _self.dailyApiCalls : dailyApiCalls // ignore: cast_nullable_to_non_nullable
as int,isRecommended: null == isRecommended ? _self.isRecommended : isRecommended // ignore: cast_nullable_to_non_nullable
as bool,companyCount: null == companyCount ? _self.companyCount : companyCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of Plan
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserLimitsCopyWith<$Res> get userLimits {
  
  return $UserLimitsCopyWith<$Res>(_self.userLimits, (value) {
    return _then(_self.copyWith(userLimits: value));
  });
}
}


/// Adds pattern-matching-related methods to [Plan].
extension PlanPatterns on Plan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Plan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Plan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Plan value)  $default,){
final _that = this;
switch (_that) {
case _Plan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Plan value)?  $default,){
final _that = this;
switch (_that) {
case _Plan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'name')  String name, @JsonKey(name: 'type')  PlanType type, @JsonKey(name: 'description')  String description, @JsonKey(name: 'monthly_price')  double monthlyPrice, @JsonKey(name: 'yearly_price')  double yearlyPrice,  String currency, @JsonKey(name: 'billing_cycle')  String billingCycle,  PlanStatus status, @JsonKey(name: 'is_featured')  bool isFeatured, @JsonKey(name: 'is_popular')  bool isPopular, @JsonKey(name: 'sort_order')  int sortOrder,  List<PlanFeature> features,  Map<String, dynamic> limits,  Map<String, dynamic>? metadata, @JsonKey(name: 'user_limits')  UserLimits userLimits, @JsonKey(name: 'storage_gb')  int storageGb, @JsonKey(name: 'daily_api_calls')  int dailyApiCalls, @JsonKey(name: 'is_recommended')  bool isRecommended, @JsonKey(name: 'company_count')  int companyCount, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'archived_at')  DateTime? archivedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Plan() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.description,_that.monthlyPrice,_that.yearlyPrice,_that.currency,_that.billingCycle,_that.status,_that.isFeatured,_that.isPopular,_that.sortOrder,_that.features,_that.limits,_that.metadata,_that.userLimits,_that.storageGb,_that.dailyApiCalls,_that.isRecommended,_that.companyCount,_that.createdAt,_that.updatedAt,_that.archivedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'name')  String name, @JsonKey(name: 'type')  PlanType type, @JsonKey(name: 'description')  String description, @JsonKey(name: 'monthly_price')  double monthlyPrice, @JsonKey(name: 'yearly_price')  double yearlyPrice,  String currency, @JsonKey(name: 'billing_cycle')  String billingCycle,  PlanStatus status, @JsonKey(name: 'is_featured')  bool isFeatured, @JsonKey(name: 'is_popular')  bool isPopular, @JsonKey(name: 'sort_order')  int sortOrder,  List<PlanFeature> features,  Map<String, dynamic> limits,  Map<String, dynamic>? metadata, @JsonKey(name: 'user_limits')  UserLimits userLimits, @JsonKey(name: 'storage_gb')  int storageGb, @JsonKey(name: 'daily_api_calls')  int dailyApiCalls, @JsonKey(name: 'is_recommended')  bool isRecommended, @JsonKey(name: 'company_count')  int companyCount, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'archived_at')  DateTime? archivedAt)  $default,) {final _that = this;
switch (_that) {
case _Plan():
return $default(_that.id,_that.name,_that.type,_that.description,_that.monthlyPrice,_that.yearlyPrice,_that.currency,_that.billingCycle,_that.status,_that.isFeatured,_that.isPopular,_that.sortOrder,_that.features,_that.limits,_that.metadata,_that.userLimits,_that.storageGb,_that.dailyApiCalls,_that.isRecommended,_that.companyCount,_that.createdAt,_that.updatedAt,_that.archivedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'name')  String name, @JsonKey(name: 'type')  PlanType type, @JsonKey(name: 'description')  String description, @JsonKey(name: 'monthly_price')  double monthlyPrice, @JsonKey(name: 'yearly_price')  double yearlyPrice,  String currency, @JsonKey(name: 'billing_cycle')  String billingCycle,  PlanStatus status, @JsonKey(name: 'is_featured')  bool isFeatured, @JsonKey(name: 'is_popular')  bool isPopular, @JsonKey(name: 'sort_order')  int sortOrder,  List<PlanFeature> features,  Map<String, dynamic> limits,  Map<String, dynamic>? metadata, @JsonKey(name: 'user_limits')  UserLimits userLimits, @JsonKey(name: 'storage_gb')  int storageGb, @JsonKey(name: 'daily_api_calls')  int dailyApiCalls, @JsonKey(name: 'is_recommended')  bool isRecommended, @JsonKey(name: 'company_count')  int companyCount, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'archived_at')  DateTime? archivedAt)?  $default,) {final _that = this;
switch (_that) {
case _Plan() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.description,_that.monthlyPrice,_that.yearlyPrice,_that.currency,_that.billingCycle,_that.status,_that.isFeatured,_that.isPopular,_that.sortOrder,_that.features,_that.limits,_that.metadata,_that.userLimits,_that.storageGb,_that.dailyApiCalls,_that.isRecommended,_that.companyCount,_that.createdAt,_that.updatedAt,_that.archivedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Plan extends Plan {
  const _Plan({@JsonKey(name: 'id') required this.id, @JsonKey(name: 'name') required this.name, @JsonKey(name: 'type') required this.type, @JsonKey(name: 'description') required this.description, @JsonKey(name: 'monthly_price') required this.monthlyPrice, @JsonKey(name: 'yearly_price') required this.yearlyPrice, this.currency = 'USD', @JsonKey(name: 'billing_cycle') required this.billingCycle, required this.status, @JsonKey(name: 'is_featured') this.isFeatured = false, @JsonKey(name: 'is_popular') this.isPopular = false, @JsonKey(name: 'sort_order') this.sortOrder = 0, required final  List<PlanFeature> features, final  Map<String, dynamic> limits = const {}, final  Map<String, dynamic>? metadata, @JsonKey(name: 'user_limits') required this.userLimits, @JsonKey(name: 'storage_gb') this.storageGb = 1, @JsonKey(name: 'daily_api_calls') this.dailyApiCalls = 0, @JsonKey(name: 'is_recommended') this.isRecommended = false, @JsonKey(name: 'company_count') this.companyCount = 0, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, @JsonKey(name: 'archived_at') this.archivedAt}): _features = features,_limits = limits,_metadata = metadata,super._();
  

/// Unique identifier for the plan
@override@JsonKey(name: 'id') final  String id;
/// Name of the plan (e.g., "Free Plan", "Basic Plan")
@override@JsonKey(name: 'name') final  String name;
/// Type of the plan (Free, Basic, Standard, Premium, Custom)
@override@JsonKey(name: 'type') final  PlanType type;
/// Description of the plan
@override@JsonKey(name: 'description') final  String description;
/// Monthly price of the plan
@override@JsonKey(name: 'monthly_price') final  double monthlyPrice;
/// Yearly price of the plan
@override@JsonKey(name: 'yearly_price') final  double yearlyPrice;
/// Currency of the price (e.g., 'USD', 'EUR')
@override@JsonKey() final  String currency;
/// Billing cycle (e.g., 'monthly', 'yearly')
@override@JsonKey(name: 'billing_cycle') final  String billingCycle;
/// Current status of the plan
@override final  PlanStatus status;
/// Whether the plan is featured
@override@JsonKey(name: 'is_featured') final  bool isFeatured;
/// Whether the plan is marked as popular
@override@JsonKey(name: 'is_popular') final  bool isPopular;
/// Order in which the plan is displayed
@override@JsonKey(name: 'sort_order') final  int sortOrder;
/// List of features included in the plan
 final  List<PlanFeature> _features;
/// List of features included in the plan
@override List<PlanFeature> get features {
  if (_features is EqualUnmodifiableListView) return _features;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_features);
}

/// Plan limits (e.g., max users, max codes)
 final  Map<String, dynamic> _limits;
/// Plan limits (e.g., max users, max codes)
@override@JsonKey() Map<String, dynamic> get limits {
  if (_limits is EqualUnmodifiableMapView) return _limits;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_limits);
}

/// Metadata for the plan
 final  Map<String, dynamic>? _metadata;
/// Metadata for the plan
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// User limits for this plan
@override@JsonKey(name: 'user_limits') final  UserLimits userLimits;
/// Storage limit in GB
@override@JsonKey(name: 'storage_gb') final  int storageGb;
/// Daily API call limit
@override@JsonKey(name: 'daily_api_calls') final  int dailyApiCalls;
/// Whether the plan is recommended
@override@JsonKey(name: 'is_recommended') final  bool isRecommended;
/// Number of companies using this plan
@override@JsonKey(name: 'company_count') final  int companyCount;
/// Date when the plan was created
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
/// Date when the plan was last updated
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;
/// Date when the plan was archived (if applicable)
@override@JsonKey(name: 'archived_at') final  DateTime? archivedAt;

/// Create a copy of Plan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlanCopyWith<_Plan> get copyWith => __$PlanCopyWithImpl<_Plan>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Plan&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.description, description) || other.description == description)&&(identical(other.monthlyPrice, monthlyPrice) || other.monthlyPrice == monthlyPrice)&&(identical(other.yearlyPrice, yearlyPrice) || other.yearlyPrice == yearlyPrice)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.billingCycle, billingCycle) || other.billingCycle == billingCycle)&&(identical(other.status, status) || other.status == status)&&(identical(other.isFeatured, isFeatured) || other.isFeatured == isFeatured)&&(identical(other.isPopular, isPopular) || other.isPopular == isPopular)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&const DeepCollectionEquality().equals(other._features, _features)&&const DeepCollectionEquality().equals(other._limits, _limits)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.userLimits, userLimits) || other.userLimits == userLimits)&&(identical(other.storageGb, storageGb) || other.storageGb == storageGb)&&(identical(other.dailyApiCalls, dailyApiCalls) || other.dailyApiCalls == dailyApiCalls)&&(identical(other.isRecommended, isRecommended) || other.isRecommended == isRecommended)&&(identical(other.companyCount, companyCount) || other.companyCount == companyCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,name,type,description,monthlyPrice,yearlyPrice,currency,billingCycle,status,isFeatured,isPopular,sortOrder,const DeepCollectionEquality().hash(_features),const DeepCollectionEquality().hash(_limits),const DeepCollectionEquality().hash(_metadata),userLimits,storageGb,dailyApiCalls,isRecommended,companyCount,createdAt,updatedAt,archivedAt]);

@override
String toString() {
  return 'Plan(id: $id, name: $name, type: $type, description: $description, monthlyPrice: $monthlyPrice, yearlyPrice: $yearlyPrice, currency: $currency, billingCycle: $billingCycle, status: $status, isFeatured: $isFeatured, isPopular: $isPopular, sortOrder: $sortOrder, features: $features, limits: $limits, metadata: $metadata, userLimits: $userLimits, storageGb: $storageGb, dailyApiCalls: $dailyApiCalls, isRecommended: $isRecommended, companyCount: $companyCount, createdAt: $createdAt, updatedAt: $updatedAt, archivedAt: $archivedAt)';
}


}

/// @nodoc
abstract mixin class _$PlanCopyWith<$Res> implements $PlanCopyWith<$Res> {
  factory _$PlanCopyWith(_Plan value, $Res Function(_Plan) _then) = __$PlanCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id') String id,@JsonKey(name: 'name') String name,@JsonKey(name: 'type') PlanType type,@JsonKey(name: 'description') String description,@JsonKey(name: 'monthly_price') double monthlyPrice,@JsonKey(name: 'yearly_price') double yearlyPrice, String currency,@JsonKey(name: 'billing_cycle') String billingCycle, PlanStatus status,@JsonKey(name: 'is_featured') bool isFeatured,@JsonKey(name: 'is_popular') bool isPopular,@JsonKey(name: 'sort_order') int sortOrder, List<PlanFeature> features, Map<String, dynamic> limits, Map<String, dynamic>? metadata,@JsonKey(name: 'user_limits') UserLimits userLimits,@JsonKey(name: 'storage_gb') int storageGb,@JsonKey(name: 'daily_api_calls') int dailyApiCalls,@JsonKey(name: 'is_recommended') bool isRecommended,@JsonKey(name: 'company_count') int companyCount,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'archived_at') DateTime? archivedAt
});


@override $UserLimitsCopyWith<$Res> get userLimits;

}
/// @nodoc
class __$PlanCopyWithImpl<$Res>
    implements _$PlanCopyWith<$Res> {
  __$PlanCopyWithImpl(this._self, this._then);

  final _Plan _self;
  final $Res Function(_Plan) _then;

/// Create a copy of Plan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? description = null,Object? monthlyPrice = null,Object? yearlyPrice = null,Object? currency = null,Object? billingCycle = null,Object? status = null,Object? isFeatured = null,Object? isPopular = null,Object? sortOrder = null,Object? features = null,Object? limits = null,Object? metadata = freezed,Object? userLimits = null,Object? storageGb = null,Object? dailyApiCalls = null,Object? isRecommended = null,Object? companyCount = null,Object? createdAt = null,Object? updatedAt = null,Object? archivedAt = freezed,}) {
  return _then(_Plan(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PlanType,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,monthlyPrice: null == monthlyPrice ? _self.monthlyPrice : monthlyPrice // ignore: cast_nullable_to_non_nullable
as double,yearlyPrice: null == yearlyPrice ? _self.yearlyPrice : yearlyPrice // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,billingCycle: null == billingCycle ? _self.billingCycle : billingCycle // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PlanStatus,isFeatured: null == isFeatured ? _self.isFeatured : isFeatured // ignore: cast_nullable_to_non_nullable
as bool,isPopular: null == isPopular ? _self.isPopular : isPopular // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,features: null == features ? _self._features : features // ignore: cast_nullable_to_non_nullable
as List<PlanFeature>,limits: null == limits ? _self._limits : limits // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,userLimits: null == userLimits ? _self.userLimits : userLimits // ignore: cast_nullable_to_non_nullable
as UserLimits,storageGb: null == storageGb ? _self.storageGb : storageGb // ignore: cast_nullable_to_non_nullable
as int,dailyApiCalls: null == dailyApiCalls ? _self.dailyApiCalls : dailyApiCalls // ignore: cast_nullable_to_non_nullable
as int,isRecommended: null == isRecommended ? _self.isRecommended : isRecommended // ignore: cast_nullable_to_non_nullable
as bool,companyCount: null == companyCount ? _self.companyCount : companyCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of Plan
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserLimitsCopyWith<$Res> get userLimits {
  
  return $UserLimitsCopyWith<$Res>(_self.userLimits, (value) {
    return _then(_self.copyWith(userLimits: value));
  });
}
}

/// @nodoc
mixin _$PlanLimits {

/// Monthly unit code limit
@JsonKey(name: 'monthly_unit_codes') int get monthlyUnitCodes;/// Monthly packet code limit
@JsonKey(name: 'monthly_packet_codes') int get monthlyPacketCodes;/// Monthly carton code limit
@JsonKey(name: 'monthly_carton_codes') int get monthlyCartonCodes;/// Monthly bundle code limit
@JsonKey(name: 'monthly_bundle_codes') int get monthlyBundleCodes;/// Whether limits are custom (for custom plans)
@JsonKey(name: 'is_custom') bool get isCustom;
/// Create a copy of PlanLimits
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlanLimitsCopyWith<PlanLimits> get copyWith => _$PlanLimitsCopyWithImpl<PlanLimits>(this as PlanLimits, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlanLimits&&(identical(other.monthlyUnitCodes, monthlyUnitCodes) || other.monthlyUnitCodes == monthlyUnitCodes)&&(identical(other.monthlyPacketCodes, monthlyPacketCodes) || other.monthlyPacketCodes == monthlyPacketCodes)&&(identical(other.monthlyCartonCodes, monthlyCartonCodes) || other.monthlyCartonCodes == monthlyCartonCodes)&&(identical(other.monthlyBundleCodes, monthlyBundleCodes) || other.monthlyBundleCodes == monthlyBundleCodes)&&(identical(other.isCustom, isCustom) || other.isCustom == isCustom));
}


@override
int get hashCode => Object.hash(runtimeType,monthlyUnitCodes,monthlyPacketCodes,monthlyCartonCodes,monthlyBundleCodes,isCustom);

@override
String toString() {
  return 'PlanLimits(monthlyUnitCodes: $monthlyUnitCodes, monthlyPacketCodes: $monthlyPacketCodes, monthlyCartonCodes: $monthlyCartonCodes, monthlyBundleCodes: $monthlyBundleCodes, isCustom: $isCustom)';
}


}

/// @nodoc
abstract mixin class $PlanLimitsCopyWith<$Res>  {
  factory $PlanLimitsCopyWith(PlanLimits value, $Res Function(PlanLimits) _then) = _$PlanLimitsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'monthly_unit_codes') int monthlyUnitCodes,@JsonKey(name: 'monthly_packet_codes') int monthlyPacketCodes,@JsonKey(name: 'monthly_carton_codes') int monthlyCartonCodes,@JsonKey(name: 'monthly_bundle_codes') int monthlyBundleCodes,@JsonKey(name: 'is_custom') bool isCustom
});




}
/// @nodoc
class _$PlanLimitsCopyWithImpl<$Res>
    implements $PlanLimitsCopyWith<$Res> {
  _$PlanLimitsCopyWithImpl(this._self, this._then);

  final PlanLimits _self;
  final $Res Function(PlanLimits) _then;

/// Create a copy of PlanLimits
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? monthlyUnitCodes = null,Object? monthlyPacketCodes = null,Object? monthlyCartonCodes = null,Object? monthlyBundleCodes = null,Object? isCustom = null,}) {
  return _then(_self.copyWith(
monthlyUnitCodes: null == monthlyUnitCodes ? _self.monthlyUnitCodes : monthlyUnitCodes // ignore: cast_nullable_to_non_nullable
as int,monthlyPacketCodes: null == monthlyPacketCodes ? _self.monthlyPacketCodes : monthlyPacketCodes // ignore: cast_nullable_to_non_nullable
as int,monthlyCartonCodes: null == monthlyCartonCodes ? _self.monthlyCartonCodes : monthlyCartonCodes // ignore: cast_nullable_to_non_nullable
as int,monthlyBundleCodes: null == monthlyBundleCodes ? _self.monthlyBundleCodes : monthlyBundleCodes // ignore: cast_nullable_to_non_nullable
as int,isCustom: null == isCustom ? _self.isCustom : isCustom // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PlanLimits].
extension PlanLimitsPatterns on PlanLimits {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlanLimits value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlanLimits() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlanLimits value)  $default,){
final _that = this;
switch (_that) {
case _PlanLimits():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlanLimits value)?  $default,){
final _that = this;
switch (_that) {
case _PlanLimits() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'monthly_unit_codes')  int monthlyUnitCodes, @JsonKey(name: 'monthly_packet_codes')  int monthlyPacketCodes, @JsonKey(name: 'monthly_carton_codes')  int monthlyCartonCodes, @JsonKey(name: 'monthly_bundle_codes')  int monthlyBundleCodes, @JsonKey(name: 'is_custom')  bool isCustom)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlanLimits() when $default != null:
return $default(_that.monthlyUnitCodes,_that.monthlyPacketCodes,_that.monthlyCartonCodes,_that.monthlyBundleCodes,_that.isCustom);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'monthly_unit_codes')  int monthlyUnitCodes, @JsonKey(name: 'monthly_packet_codes')  int monthlyPacketCodes, @JsonKey(name: 'monthly_carton_codes')  int monthlyCartonCodes, @JsonKey(name: 'monthly_bundle_codes')  int monthlyBundleCodes, @JsonKey(name: 'is_custom')  bool isCustom)  $default,) {final _that = this;
switch (_that) {
case _PlanLimits():
return $default(_that.monthlyUnitCodes,_that.monthlyPacketCodes,_that.monthlyCartonCodes,_that.monthlyBundleCodes,_that.isCustom);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'monthly_unit_codes')  int monthlyUnitCodes, @JsonKey(name: 'monthly_packet_codes')  int monthlyPacketCodes, @JsonKey(name: 'monthly_carton_codes')  int monthlyCartonCodes, @JsonKey(name: 'monthly_bundle_codes')  int monthlyBundleCodes, @JsonKey(name: 'is_custom')  bool isCustom)?  $default,) {final _that = this;
switch (_that) {
case _PlanLimits() when $default != null:
return $default(_that.monthlyUnitCodes,_that.monthlyPacketCodes,_that.monthlyCartonCodes,_that.monthlyBundleCodes,_that.isCustom);case _:
  return null;

}
}

}

/// @nodoc


class _PlanLimits extends PlanLimits {
  const _PlanLimits({@JsonKey(name: 'monthly_unit_codes') required this.monthlyUnitCodes, @JsonKey(name: 'monthly_packet_codes') required this.monthlyPacketCodes, @JsonKey(name: 'monthly_carton_codes') required this.monthlyCartonCodes, @JsonKey(name: 'monthly_bundle_codes') required this.monthlyBundleCodes, @JsonKey(name: 'is_custom') this.isCustom = false}): super._();
  

/// Monthly unit code limit
@override@JsonKey(name: 'monthly_unit_codes') final  int monthlyUnitCodes;
/// Monthly packet code limit
@override@JsonKey(name: 'monthly_packet_codes') final  int monthlyPacketCodes;
/// Monthly carton code limit
@override@JsonKey(name: 'monthly_carton_codes') final  int monthlyCartonCodes;
/// Monthly bundle code limit
@override@JsonKey(name: 'monthly_bundle_codes') final  int monthlyBundleCodes;
/// Whether limits are custom (for custom plans)
@override@JsonKey(name: 'is_custom') final  bool isCustom;

/// Create a copy of PlanLimits
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlanLimitsCopyWith<_PlanLimits> get copyWith => __$PlanLimitsCopyWithImpl<_PlanLimits>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlanLimits&&(identical(other.monthlyUnitCodes, monthlyUnitCodes) || other.monthlyUnitCodes == monthlyUnitCodes)&&(identical(other.monthlyPacketCodes, monthlyPacketCodes) || other.monthlyPacketCodes == monthlyPacketCodes)&&(identical(other.monthlyCartonCodes, monthlyCartonCodes) || other.monthlyCartonCodes == monthlyCartonCodes)&&(identical(other.monthlyBundleCodes, monthlyBundleCodes) || other.monthlyBundleCodes == monthlyBundleCodes)&&(identical(other.isCustom, isCustom) || other.isCustom == isCustom));
}


@override
int get hashCode => Object.hash(runtimeType,monthlyUnitCodes,monthlyPacketCodes,monthlyCartonCodes,monthlyBundleCodes,isCustom);

@override
String toString() {
  return 'PlanLimits(monthlyUnitCodes: $monthlyUnitCodes, monthlyPacketCodes: $monthlyPacketCodes, monthlyCartonCodes: $monthlyCartonCodes, monthlyBundleCodes: $monthlyBundleCodes, isCustom: $isCustom)';
}


}

/// @nodoc
abstract mixin class _$PlanLimitsCopyWith<$Res> implements $PlanLimitsCopyWith<$Res> {
  factory _$PlanLimitsCopyWith(_PlanLimits value, $Res Function(_PlanLimits) _then) = __$PlanLimitsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'monthly_unit_codes') int monthlyUnitCodes,@JsonKey(name: 'monthly_packet_codes') int monthlyPacketCodes,@JsonKey(name: 'monthly_carton_codes') int monthlyCartonCodes,@JsonKey(name: 'monthly_bundle_codes') int monthlyBundleCodes,@JsonKey(name: 'is_custom') bool isCustom
});




}
/// @nodoc
class __$PlanLimitsCopyWithImpl<$Res>
    implements _$PlanLimitsCopyWith<$Res> {
  __$PlanLimitsCopyWithImpl(this._self, this._then);

  final _PlanLimits _self;
  final $Res Function(_PlanLimits) _then;

/// Create a copy of PlanLimits
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? monthlyUnitCodes = null,Object? monthlyPacketCodes = null,Object? monthlyCartonCodes = null,Object? monthlyBundleCodes = null,Object? isCustom = null,}) {
  return _then(_PlanLimits(
monthlyUnitCodes: null == monthlyUnitCodes ? _self.monthlyUnitCodes : monthlyUnitCodes // ignore: cast_nullable_to_non_nullable
as int,monthlyPacketCodes: null == monthlyPacketCodes ? _self.monthlyPacketCodes : monthlyPacketCodes // ignore: cast_nullable_to_non_nullable
as int,monthlyCartonCodes: null == monthlyCartonCodes ? _self.monthlyCartonCodes : monthlyCartonCodes // ignore: cast_nullable_to_non_nullable
as int,monthlyBundleCodes: null == monthlyBundleCodes ? _self.monthlyBundleCodes : monthlyBundleCodes // ignore: cast_nullable_to_non_nullable
as int,isCustom: null == isCustom ? _self.isCustom : isCustom // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$UserLimits {

/// Maximum number of store keepers
@JsonKey(name: 'store_keepers') int get storeKeepers;/// Maximum number of drivers
@JsonKey(name: 'drivers') int get drivers;/// Maximum number of admin users
@JsonKey(name: 'admin_users') int get adminUsers;/// Maximum number of active products
@JsonKey(name: 'active_products') int get activeProducts;/// Whether user limits are custom (for custom plans)
@JsonKey(name: 'is_custom') bool get isCustom;
/// Create a copy of UserLimits
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserLimitsCopyWith<UserLimits> get copyWith => _$UserLimitsCopyWithImpl<UserLimits>(this as UserLimits, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserLimits&&(identical(other.storeKeepers, storeKeepers) || other.storeKeepers == storeKeepers)&&(identical(other.drivers, drivers) || other.drivers == drivers)&&(identical(other.adminUsers, adminUsers) || other.adminUsers == adminUsers)&&(identical(other.activeProducts, activeProducts) || other.activeProducts == activeProducts)&&(identical(other.isCustom, isCustom) || other.isCustom == isCustom));
}


@override
int get hashCode => Object.hash(runtimeType,storeKeepers,drivers,adminUsers,activeProducts,isCustom);

@override
String toString() {
  return 'UserLimits(storeKeepers: $storeKeepers, drivers: $drivers, adminUsers: $adminUsers, activeProducts: $activeProducts, isCustom: $isCustom)';
}


}

/// @nodoc
abstract mixin class $UserLimitsCopyWith<$Res>  {
  factory $UserLimitsCopyWith(UserLimits value, $Res Function(UserLimits) _then) = _$UserLimitsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'store_keepers') int storeKeepers,@JsonKey(name: 'drivers') int drivers,@JsonKey(name: 'admin_users') int adminUsers,@JsonKey(name: 'active_products') int activeProducts,@JsonKey(name: 'is_custom') bool isCustom
});




}
/// @nodoc
class _$UserLimitsCopyWithImpl<$Res>
    implements $UserLimitsCopyWith<$Res> {
  _$UserLimitsCopyWithImpl(this._self, this._then);

  final UserLimits _self;
  final $Res Function(UserLimits) _then;

/// Create a copy of UserLimits
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? storeKeepers = null,Object? drivers = null,Object? adminUsers = null,Object? activeProducts = null,Object? isCustom = null,}) {
  return _then(_self.copyWith(
storeKeepers: null == storeKeepers ? _self.storeKeepers : storeKeepers // ignore: cast_nullable_to_non_nullable
as int,drivers: null == drivers ? _self.drivers : drivers // ignore: cast_nullable_to_non_nullable
as int,adminUsers: null == adminUsers ? _self.adminUsers : adminUsers // ignore: cast_nullable_to_non_nullable
as int,activeProducts: null == activeProducts ? _self.activeProducts : activeProducts // ignore: cast_nullable_to_non_nullable
as int,isCustom: null == isCustom ? _self.isCustom : isCustom // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [UserLimits].
extension UserLimitsPatterns on UserLimits {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserLimits value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserLimits() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserLimits value)  $default,){
final _that = this;
switch (_that) {
case _UserLimits():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserLimits value)?  $default,){
final _that = this;
switch (_that) {
case _UserLimits() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'store_keepers')  int storeKeepers, @JsonKey(name: 'drivers')  int drivers, @JsonKey(name: 'admin_users')  int adminUsers, @JsonKey(name: 'active_products')  int activeProducts, @JsonKey(name: 'is_custom')  bool isCustom)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserLimits() when $default != null:
return $default(_that.storeKeepers,_that.drivers,_that.adminUsers,_that.activeProducts,_that.isCustom);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'store_keepers')  int storeKeepers, @JsonKey(name: 'drivers')  int drivers, @JsonKey(name: 'admin_users')  int adminUsers, @JsonKey(name: 'active_products')  int activeProducts, @JsonKey(name: 'is_custom')  bool isCustom)  $default,) {final _that = this;
switch (_that) {
case _UserLimits():
return $default(_that.storeKeepers,_that.drivers,_that.adminUsers,_that.activeProducts,_that.isCustom);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'store_keepers')  int storeKeepers, @JsonKey(name: 'drivers')  int drivers, @JsonKey(name: 'admin_users')  int adminUsers, @JsonKey(name: 'active_products')  int activeProducts, @JsonKey(name: 'is_custom')  bool isCustom)?  $default,) {final _that = this;
switch (_that) {
case _UserLimits() when $default != null:
return $default(_that.storeKeepers,_that.drivers,_that.adminUsers,_that.activeProducts,_that.isCustom);case _:
  return null;

}
}

}

/// @nodoc


class _UserLimits extends UserLimits {
  const _UserLimits({@JsonKey(name: 'store_keepers') required this.storeKeepers, @JsonKey(name: 'drivers') required this.drivers, @JsonKey(name: 'admin_users') required this.adminUsers, @JsonKey(name: 'active_products') required this.activeProducts, @JsonKey(name: 'is_custom') this.isCustom = false}): super._();
  

/// Maximum number of store keepers
@override@JsonKey(name: 'store_keepers') final  int storeKeepers;
/// Maximum number of drivers
@override@JsonKey(name: 'drivers') final  int drivers;
/// Maximum number of admin users
@override@JsonKey(name: 'admin_users') final  int adminUsers;
/// Maximum number of active products
@override@JsonKey(name: 'active_products') final  int activeProducts;
/// Whether user limits are custom (for custom plans)
@override@JsonKey(name: 'is_custom') final  bool isCustom;

/// Create a copy of UserLimits
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserLimitsCopyWith<_UserLimits> get copyWith => __$UserLimitsCopyWithImpl<_UserLimits>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserLimits&&(identical(other.storeKeepers, storeKeepers) || other.storeKeepers == storeKeepers)&&(identical(other.drivers, drivers) || other.drivers == drivers)&&(identical(other.adminUsers, adminUsers) || other.adminUsers == adminUsers)&&(identical(other.activeProducts, activeProducts) || other.activeProducts == activeProducts)&&(identical(other.isCustom, isCustom) || other.isCustom == isCustom));
}


@override
int get hashCode => Object.hash(runtimeType,storeKeepers,drivers,adminUsers,activeProducts,isCustom);

@override
String toString() {
  return 'UserLimits(storeKeepers: $storeKeepers, drivers: $drivers, adminUsers: $adminUsers, activeProducts: $activeProducts, isCustom: $isCustom)';
}


}

/// @nodoc
abstract mixin class _$UserLimitsCopyWith<$Res> implements $UserLimitsCopyWith<$Res> {
  factory _$UserLimitsCopyWith(_UserLimits value, $Res Function(_UserLimits) _then) = __$UserLimitsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'store_keepers') int storeKeepers,@JsonKey(name: 'drivers') int drivers,@JsonKey(name: 'admin_users') int adminUsers,@JsonKey(name: 'active_products') int activeProducts,@JsonKey(name: 'is_custom') bool isCustom
});




}
/// @nodoc
class __$UserLimitsCopyWithImpl<$Res>
    implements _$UserLimitsCopyWith<$Res> {
  __$UserLimitsCopyWithImpl(this._self, this._then);

  final _UserLimits _self;
  final $Res Function(_UserLimits) _then;

/// Create a copy of UserLimits
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? storeKeepers = null,Object? drivers = null,Object? adminUsers = null,Object? activeProducts = null,Object? isCustom = null,}) {
  return _then(_UserLimits(
storeKeepers: null == storeKeepers ? _self.storeKeepers : storeKeepers // ignore: cast_nullable_to_non_nullable
as int,drivers: null == drivers ? _self.drivers : drivers // ignore: cast_nullable_to_non_nullable
as int,adminUsers: null == adminUsers ? _self.adminUsers : adminUsers // ignore: cast_nullable_to_non_nullable
as int,activeProducts: null == activeProducts ? _self.activeProducts : activeProducts // ignore: cast_nullable_to_non_nullable
as int,isCustom: null == isCustom ? _self.isCustom : isCustom // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

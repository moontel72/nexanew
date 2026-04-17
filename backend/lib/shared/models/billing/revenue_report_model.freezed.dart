// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'revenue_report_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RevenueDataPoint {

 DateTime get date; double get amount; String get currency; RevenueType get type; String? get companyId; String? get planId; String? get region; Map<String, dynamic>? get metadata;
/// Create a copy of RevenueDataPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RevenueDataPointCopyWith<RevenueDataPoint> get copyWith => _$RevenueDataPointCopyWithImpl<RevenueDataPoint>(this as RevenueDataPoint, _$identity);

  /// Serializes this RevenueDataPoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RevenueDataPoint&&(identical(other.date, date) || other.date == date)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.type, type) || other.type == type)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.region, region) || other.region == region)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,amount,currency,type,companyId,planId,region,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'RevenueDataPoint(date: $date, amount: $amount, currency: $currency, type: $type, companyId: $companyId, planId: $planId, region: $region, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $RevenueDataPointCopyWith<$Res>  {
  factory $RevenueDataPointCopyWith(RevenueDataPoint value, $Res Function(RevenueDataPoint) _then) = _$RevenueDataPointCopyWithImpl;
@useResult
$Res call({
 DateTime date, double amount, String currency, RevenueType type, String? companyId, String? planId, String? region, Map<String, dynamic>? metadata
});




}
/// @nodoc
class _$RevenueDataPointCopyWithImpl<$Res>
    implements $RevenueDataPointCopyWith<$Res> {
  _$RevenueDataPointCopyWithImpl(this._self, this._then);

  final RevenueDataPoint _self;
  final $Res Function(RevenueDataPoint) _then;

/// Create a copy of RevenueDataPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? amount = null,Object? currency = null,Object? type = null,Object? companyId = freezed,Object? planId = freezed,Object? region = freezed,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as RevenueType,companyId: freezed == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String?,planId: freezed == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String?,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [RevenueDataPoint].
extension RevenueDataPointPatterns on RevenueDataPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RevenueDataPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RevenueDataPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RevenueDataPoint value)  $default,){
final _that = this;
switch (_that) {
case _RevenueDataPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RevenueDataPoint value)?  $default,){
final _that = this;
switch (_that) {
case _RevenueDataPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  double amount,  String currency,  RevenueType type,  String? companyId,  String? planId,  String? region,  Map<String, dynamic>? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RevenueDataPoint() when $default != null:
return $default(_that.date,_that.amount,_that.currency,_that.type,_that.companyId,_that.planId,_that.region,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  double amount,  String currency,  RevenueType type,  String? companyId,  String? planId,  String? region,  Map<String, dynamic>? metadata)  $default,) {final _that = this;
switch (_that) {
case _RevenueDataPoint():
return $default(_that.date,_that.amount,_that.currency,_that.type,_that.companyId,_that.planId,_that.region,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  double amount,  String currency,  RevenueType type,  String? companyId,  String? planId,  String? region,  Map<String, dynamic>? metadata)?  $default,) {final _that = this;
switch (_that) {
case _RevenueDataPoint() when $default != null:
return $default(_that.date,_that.amount,_that.currency,_that.type,_that.companyId,_that.planId,_that.region,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RevenueDataPoint implements RevenueDataPoint {
  const _RevenueDataPoint({required this.date, required this.amount, required this.currency, required this.type, this.companyId, this.planId, this.region, final  Map<String, dynamic>? metadata}): _metadata = metadata;
  factory _RevenueDataPoint.fromJson(Map<String, dynamic> json) => _$RevenueDataPointFromJson(json);

@override final  DateTime date;
@override final  double amount;
@override final  String currency;
@override final  RevenueType type;
@override final  String? companyId;
@override final  String? planId;
@override final  String? region;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of RevenueDataPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RevenueDataPointCopyWith<_RevenueDataPoint> get copyWith => __$RevenueDataPointCopyWithImpl<_RevenueDataPoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RevenueDataPointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RevenueDataPoint&&(identical(other.date, date) || other.date == date)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.type, type) || other.type == type)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.region, region) || other.region == region)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,amount,currency,type,companyId,planId,region,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'RevenueDataPoint(date: $date, amount: $amount, currency: $currency, type: $type, companyId: $companyId, planId: $planId, region: $region, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$RevenueDataPointCopyWith<$Res> implements $RevenueDataPointCopyWith<$Res> {
  factory _$RevenueDataPointCopyWith(_RevenueDataPoint value, $Res Function(_RevenueDataPoint) _then) = __$RevenueDataPointCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, double amount, String currency, RevenueType type, String? companyId, String? planId, String? region, Map<String, dynamic>? metadata
});




}
/// @nodoc
class __$RevenueDataPointCopyWithImpl<$Res>
    implements _$RevenueDataPointCopyWith<$Res> {
  __$RevenueDataPointCopyWithImpl(this._self, this._then);

  final _RevenueDataPoint _self;
  final $Res Function(_RevenueDataPoint) _then;

/// Create a copy of RevenueDataPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? amount = null,Object? currency = null,Object? type = null,Object? companyId = freezed,Object? planId = freezed,Object? region = freezed,Object? metadata = freezed,}) {
  return _then(_RevenueDataPoint(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as RevenueType,companyId: freezed == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String?,planId: freezed == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String?,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}


/// @nodoc
mixin _$RevenueBreakdown {

 double get totalRevenue; String get currency; double get subscriptionRevenue; double get usageRevenue; double get commissionRevenue; double get oneTimeRevenue; double get refundAmount; double get creditNoteAmount; double get netRevenue; Map<String, double>? get revenueByCompany; Map<String, double>? get revenueByPlan; Map<String, double>? get revenueByRegion; Map<String, double>? get revenueByType; List<RevenueDataPoint>? get dataPoints;
/// Create a copy of RevenueBreakdown
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RevenueBreakdownCopyWith<RevenueBreakdown> get copyWith => _$RevenueBreakdownCopyWithImpl<RevenueBreakdown>(this as RevenueBreakdown, _$identity);

  /// Serializes this RevenueBreakdown to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RevenueBreakdown&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.subscriptionRevenue, subscriptionRevenue) || other.subscriptionRevenue == subscriptionRevenue)&&(identical(other.usageRevenue, usageRevenue) || other.usageRevenue == usageRevenue)&&(identical(other.commissionRevenue, commissionRevenue) || other.commissionRevenue == commissionRevenue)&&(identical(other.oneTimeRevenue, oneTimeRevenue) || other.oneTimeRevenue == oneTimeRevenue)&&(identical(other.refundAmount, refundAmount) || other.refundAmount == refundAmount)&&(identical(other.creditNoteAmount, creditNoteAmount) || other.creditNoteAmount == creditNoteAmount)&&(identical(other.netRevenue, netRevenue) || other.netRevenue == netRevenue)&&const DeepCollectionEquality().equals(other.revenueByCompany, revenueByCompany)&&const DeepCollectionEquality().equals(other.revenueByPlan, revenueByPlan)&&const DeepCollectionEquality().equals(other.revenueByRegion, revenueByRegion)&&const DeepCollectionEquality().equals(other.revenueByType, revenueByType)&&const DeepCollectionEquality().equals(other.dataPoints, dataPoints));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalRevenue,currency,subscriptionRevenue,usageRevenue,commissionRevenue,oneTimeRevenue,refundAmount,creditNoteAmount,netRevenue,const DeepCollectionEquality().hash(revenueByCompany),const DeepCollectionEquality().hash(revenueByPlan),const DeepCollectionEquality().hash(revenueByRegion),const DeepCollectionEquality().hash(revenueByType),const DeepCollectionEquality().hash(dataPoints));

@override
String toString() {
  return 'RevenueBreakdown(totalRevenue: $totalRevenue, currency: $currency, subscriptionRevenue: $subscriptionRevenue, usageRevenue: $usageRevenue, commissionRevenue: $commissionRevenue, oneTimeRevenue: $oneTimeRevenue, refundAmount: $refundAmount, creditNoteAmount: $creditNoteAmount, netRevenue: $netRevenue, revenueByCompany: $revenueByCompany, revenueByPlan: $revenueByPlan, revenueByRegion: $revenueByRegion, revenueByType: $revenueByType, dataPoints: $dataPoints)';
}


}

/// @nodoc
abstract mixin class $RevenueBreakdownCopyWith<$Res>  {
  factory $RevenueBreakdownCopyWith(RevenueBreakdown value, $Res Function(RevenueBreakdown) _then) = _$RevenueBreakdownCopyWithImpl;
@useResult
$Res call({
 double totalRevenue, String currency, double subscriptionRevenue, double usageRevenue, double commissionRevenue, double oneTimeRevenue, double refundAmount, double creditNoteAmount, double netRevenue, Map<String, double>? revenueByCompany, Map<String, double>? revenueByPlan, Map<String, double>? revenueByRegion, Map<String, double>? revenueByType, List<RevenueDataPoint>? dataPoints
});




}
/// @nodoc
class _$RevenueBreakdownCopyWithImpl<$Res>
    implements $RevenueBreakdownCopyWith<$Res> {
  _$RevenueBreakdownCopyWithImpl(this._self, this._then);

  final RevenueBreakdown _self;
  final $Res Function(RevenueBreakdown) _then;

/// Create a copy of RevenueBreakdown
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalRevenue = null,Object? currency = null,Object? subscriptionRevenue = null,Object? usageRevenue = null,Object? commissionRevenue = null,Object? oneTimeRevenue = null,Object? refundAmount = null,Object? creditNoteAmount = null,Object? netRevenue = null,Object? revenueByCompany = freezed,Object? revenueByPlan = freezed,Object? revenueByRegion = freezed,Object? revenueByType = freezed,Object? dataPoints = freezed,}) {
  return _then(_self.copyWith(
totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,subscriptionRevenue: null == subscriptionRevenue ? _self.subscriptionRevenue : subscriptionRevenue // ignore: cast_nullable_to_non_nullable
as double,usageRevenue: null == usageRevenue ? _self.usageRevenue : usageRevenue // ignore: cast_nullable_to_non_nullable
as double,commissionRevenue: null == commissionRevenue ? _self.commissionRevenue : commissionRevenue // ignore: cast_nullable_to_non_nullable
as double,oneTimeRevenue: null == oneTimeRevenue ? _self.oneTimeRevenue : oneTimeRevenue // ignore: cast_nullable_to_non_nullable
as double,refundAmount: null == refundAmount ? _self.refundAmount : refundAmount // ignore: cast_nullable_to_non_nullable
as double,creditNoteAmount: null == creditNoteAmount ? _self.creditNoteAmount : creditNoteAmount // ignore: cast_nullable_to_non_nullable
as double,netRevenue: null == netRevenue ? _self.netRevenue : netRevenue // ignore: cast_nullable_to_non_nullable
as double,revenueByCompany: freezed == revenueByCompany ? _self.revenueByCompany : revenueByCompany // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,revenueByPlan: freezed == revenueByPlan ? _self.revenueByPlan : revenueByPlan // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,revenueByRegion: freezed == revenueByRegion ? _self.revenueByRegion : revenueByRegion // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,revenueByType: freezed == revenueByType ? _self.revenueByType : revenueByType // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,dataPoints: freezed == dataPoints ? _self.dataPoints : dataPoints // ignore: cast_nullable_to_non_nullable
as List<RevenueDataPoint>?,
  ));
}

}


/// Adds pattern-matching-related methods to [RevenueBreakdown].
extension RevenueBreakdownPatterns on RevenueBreakdown {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RevenueBreakdown value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RevenueBreakdown() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RevenueBreakdown value)  $default,){
final _that = this;
switch (_that) {
case _RevenueBreakdown():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RevenueBreakdown value)?  $default,){
final _that = this;
switch (_that) {
case _RevenueBreakdown() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double totalRevenue,  String currency,  double subscriptionRevenue,  double usageRevenue,  double commissionRevenue,  double oneTimeRevenue,  double refundAmount,  double creditNoteAmount,  double netRevenue,  Map<String, double>? revenueByCompany,  Map<String, double>? revenueByPlan,  Map<String, double>? revenueByRegion,  Map<String, double>? revenueByType,  List<RevenueDataPoint>? dataPoints)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RevenueBreakdown() when $default != null:
return $default(_that.totalRevenue,_that.currency,_that.subscriptionRevenue,_that.usageRevenue,_that.commissionRevenue,_that.oneTimeRevenue,_that.refundAmount,_that.creditNoteAmount,_that.netRevenue,_that.revenueByCompany,_that.revenueByPlan,_that.revenueByRegion,_that.revenueByType,_that.dataPoints);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double totalRevenue,  String currency,  double subscriptionRevenue,  double usageRevenue,  double commissionRevenue,  double oneTimeRevenue,  double refundAmount,  double creditNoteAmount,  double netRevenue,  Map<String, double>? revenueByCompany,  Map<String, double>? revenueByPlan,  Map<String, double>? revenueByRegion,  Map<String, double>? revenueByType,  List<RevenueDataPoint>? dataPoints)  $default,) {final _that = this;
switch (_that) {
case _RevenueBreakdown():
return $default(_that.totalRevenue,_that.currency,_that.subscriptionRevenue,_that.usageRevenue,_that.commissionRevenue,_that.oneTimeRevenue,_that.refundAmount,_that.creditNoteAmount,_that.netRevenue,_that.revenueByCompany,_that.revenueByPlan,_that.revenueByRegion,_that.revenueByType,_that.dataPoints);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double totalRevenue,  String currency,  double subscriptionRevenue,  double usageRevenue,  double commissionRevenue,  double oneTimeRevenue,  double refundAmount,  double creditNoteAmount,  double netRevenue,  Map<String, double>? revenueByCompany,  Map<String, double>? revenueByPlan,  Map<String, double>? revenueByRegion,  Map<String, double>? revenueByType,  List<RevenueDataPoint>? dataPoints)?  $default,) {final _that = this;
switch (_that) {
case _RevenueBreakdown() when $default != null:
return $default(_that.totalRevenue,_that.currency,_that.subscriptionRevenue,_that.usageRevenue,_that.commissionRevenue,_that.oneTimeRevenue,_that.refundAmount,_that.creditNoteAmount,_that.netRevenue,_that.revenueByCompany,_that.revenueByPlan,_that.revenueByRegion,_that.revenueByType,_that.dataPoints);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RevenueBreakdown implements RevenueBreakdown {
  const _RevenueBreakdown({this.totalRevenue = 0.0, this.currency = 'USD', this.subscriptionRevenue = 0.0, this.usageRevenue = 0.0, this.commissionRevenue = 0.0, this.oneTimeRevenue = 0.0, this.refundAmount = 0.0, this.creditNoteAmount = 0.0, this.netRevenue = 0.0, final  Map<String, double>? revenueByCompany, final  Map<String, double>? revenueByPlan, final  Map<String, double>? revenueByRegion, final  Map<String, double>? revenueByType, final  List<RevenueDataPoint>? dataPoints}): _revenueByCompany = revenueByCompany,_revenueByPlan = revenueByPlan,_revenueByRegion = revenueByRegion,_revenueByType = revenueByType,_dataPoints = dataPoints;
  factory _RevenueBreakdown.fromJson(Map<String, dynamic> json) => _$RevenueBreakdownFromJson(json);

@override@JsonKey() final  double totalRevenue;
@override@JsonKey() final  String currency;
@override@JsonKey() final  double subscriptionRevenue;
@override@JsonKey() final  double usageRevenue;
@override@JsonKey() final  double commissionRevenue;
@override@JsonKey() final  double oneTimeRevenue;
@override@JsonKey() final  double refundAmount;
@override@JsonKey() final  double creditNoteAmount;
@override@JsonKey() final  double netRevenue;
 final  Map<String, double>? _revenueByCompany;
@override Map<String, double>? get revenueByCompany {
  final value = _revenueByCompany;
  if (value == null) return null;
  if (_revenueByCompany is EqualUnmodifiableMapView) return _revenueByCompany;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, double>? _revenueByPlan;
@override Map<String, double>? get revenueByPlan {
  final value = _revenueByPlan;
  if (value == null) return null;
  if (_revenueByPlan is EqualUnmodifiableMapView) return _revenueByPlan;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, double>? _revenueByRegion;
@override Map<String, double>? get revenueByRegion {
  final value = _revenueByRegion;
  if (value == null) return null;
  if (_revenueByRegion is EqualUnmodifiableMapView) return _revenueByRegion;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, double>? _revenueByType;
@override Map<String, double>? get revenueByType {
  final value = _revenueByType;
  if (value == null) return null;
  if (_revenueByType is EqualUnmodifiableMapView) return _revenueByType;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<RevenueDataPoint>? _dataPoints;
@override List<RevenueDataPoint>? get dataPoints {
  final value = _dataPoints;
  if (value == null) return null;
  if (_dataPoints is EqualUnmodifiableListView) return _dataPoints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of RevenueBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RevenueBreakdownCopyWith<_RevenueBreakdown> get copyWith => __$RevenueBreakdownCopyWithImpl<_RevenueBreakdown>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RevenueBreakdownToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RevenueBreakdown&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.subscriptionRevenue, subscriptionRevenue) || other.subscriptionRevenue == subscriptionRevenue)&&(identical(other.usageRevenue, usageRevenue) || other.usageRevenue == usageRevenue)&&(identical(other.commissionRevenue, commissionRevenue) || other.commissionRevenue == commissionRevenue)&&(identical(other.oneTimeRevenue, oneTimeRevenue) || other.oneTimeRevenue == oneTimeRevenue)&&(identical(other.refundAmount, refundAmount) || other.refundAmount == refundAmount)&&(identical(other.creditNoteAmount, creditNoteAmount) || other.creditNoteAmount == creditNoteAmount)&&(identical(other.netRevenue, netRevenue) || other.netRevenue == netRevenue)&&const DeepCollectionEquality().equals(other._revenueByCompany, _revenueByCompany)&&const DeepCollectionEquality().equals(other._revenueByPlan, _revenueByPlan)&&const DeepCollectionEquality().equals(other._revenueByRegion, _revenueByRegion)&&const DeepCollectionEquality().equals(other._revenueByType, _revenueByType)&&const DeepCollectionEquality().equals(other._dataPoints, _dataPoints));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalRevenue,currency,subscriptionRevenue,usageRevenue,commissionRevenue,oneTimeRevenue,refundAmount,creditNoteAmount,netRevenue,const DeepCollectionEquality().hash(_revenueByCompany),const DeepCollectionEquality().hash(_revenueByPlan),const DeepCollectionEquality().hash(_revenueByRegion),const DeepCollectionEquality().hash(_revenueByType),const DeepCollectionEquality().hash(_dataPoints));

@override
String toString() {
  return 'RevenueBreakdown(totalRevenue: $totalRevenue, currency: $currency, subscriptionRevenue: $subscriptionRevenue, usageRevenue: $usageRevenue, commissionRevenue: $commissionRevenue, oneTimeRevenue: $oneTimeRevenue, refundAmount: $refundAmount, creditNoteAmount: $creditNoteAmount, netRevenue: $netRevenue, revenueByCompany: $revenueByCompany, revenueByPlan: $revenueByPlan, revenueByRegion: $revenueByRegion, revenueByType: $revenueByType, dataPoints: $dataPoints)';
}


}

/// @nodoc
abstract mixin class _$RevenueBreakdownCopyWith<$Res> implements $RevenueBreakdownCopyWith<$Res> {
  factory _$RevenueBreakdownCopyWith(_RevenueBreakdown value, $Res Function(_RevenueBreakdown) _then) = __$RevenueBreakdownCopyWithImpl;
@override @useResult
$Res call({
 double totalRevenue, String currency, double subscriptionRevenue, double usageRevenue, double commissionRevenue, double oneTimeRevenue, double refundAmount, double creditNoteAmount, double netRevenue, Map<String, double>? revenueByCompany, Map<String, double>? revenueByPlan, Map<String, double>? revenueByRegion, Map<String, double>? revenueByType, List<RevenueDataPoint>? dataPoints
});




}
/// @nodoc
class __$RevenueBreakdownCopyWithImpl<$Res>
    implements _$RevenueBreakdownCopyWith<$Res> {
  __$RevenueBreakdownCopyWithImpl(this._self, this._then);

  final _RevenueBreakdown _self;
  final $Res Function(_RevenueBreakdown) _then;

/// Create a copy of RevenueBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalRevenue = null,Object? currency = null,Object? subscriptionRevenue = null,Object? usageRevenue = null,Object? commissionRevenue = null,Object? oneTimeRevenue = null,Object? refundAmount = null,Object? creditNoteAmount = null,Object? netRevenue = null,Object? revenueByCompany = freezed,Object? revenueByPlan = freezed,Object? revenueByRegion = freezed,Object? revenueByType = freezed,Object? dataPoints = freezed,}) {
  return _then(_RevenueBreakdown(
totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,subscriptionRevenue: null == subscriptionRevenue ? _self.subscriptionRevenue : subscriptionRevenue // ignore: cast_nullable_to_non_nullable
as double,usageRevenue: null == usageRevenue ? _self.usageRevenue : usageRevenue // ignore: cast_nullable_to_non_nullable
as double,commissionRevenue: null == commissionRevenue ? _self.commissionRevenue : commissionRevenue // ignore: cast_nullable_to_non_nullable
as double,oneTimeRevenue: null == oneTimeRevenue ? _self.oneTimeRevenue : oneTimeRevenue // ignore: cast_nullable_to_non_nullable
as double,refundAmount: null == refundAmount ? _self.refundAmount : refundAmount // ignore: cast_nullable_to_non_nullable
as double,creditNoteAmount: null == creditNoteAmount ? _self.creditNoteAmount : creditNoteAmount // ignore: cast_nullable_to_non_nullable
as double,netRevenue: null == netRevenue ? _self.netRevenue : netRevenue // ignore: cast_nullable_to_non_nullable
as double,revenueByCompany: freezed == revenueByCompany ? _self._revenueByCompany : revenueByCompany // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,revenueByPlan: freezed == revenueByPlan ? _self._revenueByPlan : revenueByPlan // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,revenueByRegion: freezed == revenueByRegion ? _self._revenueByRegion : revenueByRegion // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,revenueByType: freezed == revenueByType ? _self._revenueByType : revenueByType // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,dataPoints: freezed == dataPoints ? _self._dataPoints : dataPoints // ignore: cast_nullable_to_non_nullable
as List<RevenueDataPoint>?,
  ));
}


}


/// @nodoc
mixin _$FinancialReport {

 String get id; String get reportName; ReportPeriod get period; DateTime get periodStart; DateTime get periodEnd; DateTime get generatedAt; RevenueBreakdown get revenue; double get totalExpenses; double get grossProfit; double get operatingProfit; double get netProfit; double get taxAmount; double get taxRate; int get totalInvoices; int get paidInvoices; int get overdueInvoices; int get newCustomers; int get churnedCustomers; double get customerLifetimeValue; double get monthlyRecurringRevenue; double get annualRecurringRevenue; double get churnRate; double get growthRate; Map<String, dynamic>? get metrics; Map<String, dynamic>? get comparisons; String? get notes; Map<String, dynamic>? get metadata; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of FinancialReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FinancialReportCopyWith<FinancialReport> get copyWith => _$FinancialReportCopyWithImpl<FinancialReport>(this as FinancialReport, _$identity);

  /// Serializes this FinancialReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FinancialReport&&(identical(other.id, id) || other.id == id)&&(identical(other.reportName, reportName) || other.reportName == reportName)&&(identical(other.period, period) || other.period == period)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.totalExpenses, totalExpenses) || other.totalExpenses == totalExpenses)&&(identical(other.grossProfit, grossProfit) || other.grossProfit == grossProfit)&&(identical(other.operatingProfit, operatingProfit) || other.operatingProfit == operatingProfit)&&(identical(other.netProfit, netProfit) || other.netProfit == netProfit)&&(identical(other.taxAmount, taxAmount) || other.taxAmount == taxAmount)&&(identical(other.taxRate, taxRate) || other.taxRate == taxRate)&&(identical(other.totalInvoices, totalInvoices) || other.totalInvoices == totalInvoices)&&(identical(other.paidInvoices, paidInvoices) || other.paidInvoices == paidInvoices)&&(identical(other.overdueInvoices, overdueInvoices) || other.overdueInvoices == overdueInvoices)&&(identical(other.newCustomers, newCustomers) || other.newCustomers == newCustomers)&&(identical(other.churnedCustomers, churnedCustomers) || other.churnedCustomers == churnedCustomers)&&(identical(other.customerLifetimeValue, customerLifetimeValue) || other.customerLifetimeValue == customerLifetimeValue)&&(identical(other.monthlyRecurringRevenue, monthlyRecurringRevenue) || other.monthlyRecurringRevenue == monthlyRecurringRevenue)&&(identical(other.annualRecurringRevenue, annualRecurringRevenue) || other.annualRecurringRevenue == annualRecurringRevenue)&&(identical(other.churnRate, churnRate) || other.churnRate == churnRate)&&(identical(other.growthRate, growthRate) || other.growthRate == growthRate)&&const DeepCollectionEquality().equals(other.metrics, metrics)&&const DeepCollectionEquality().equals(other.comparisons, comparisons)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,reportName,period,periodStart,periodEnd,generatedAt,revenue,totalExpenses,grossProfit,operatingProfit,netProfit,taxAmount,taxRate,totalInvoices,paidInvoices,overdueInvoices,newCustomers,churnedCustomers,customerLifetimeValue,monthlyRecurringRevenue,annualRecurringRevenue,churnRate,growthRate,const DeepCollectionEquality().hash(metrics),const DeepCollectionEquality().hash(comparisons),notes,const DeepCollectionEquality().hash(metadata),createdAt,updatedAt]);

@override
String toString() {
  return 'FinancialReport(id: $id, reportName: $reportName, period: $period, periodStart: $periodStart, periodEnd: $periodEnd, generatedAt: $generatedAt, revenue: $revenue, totalExpenses: $totalExpenses, grossProfit: $grossProfit, operatingProfit: $operatingProfit, netProfit: $netProfit, taxAmount: $taxAmount, taxRate: $taxRate, totalInvoices: $totalInvoices, paidInvoices: $paidInvoices, overdueInvoices: $overdueInvoices, newCustomers: $newCustomers, churnedCustomers: $churnedCustomers, customerLifetimeValue: $customerLifetimeValue, monthlyRecurringRevenue: $monthlyRecurringRevenue, annualRecurringRevenue: $annualRecurringRevenue, churnRate: $churnRate, growthRate: $growthRate, metrics: $metrics, comparisons: $comparisons, notes: $notes, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $FinancialReportCopyWith<$Res>  {
  factory $FinancialReportCopyWith(FinancialReport value, $Res Function(FinancialReport) _then) = _$FinancialReportCopyWithImpl;
@useResult
$Res call({
 String id, String reportName, ReportPeriod period, DateTime periodStart, DateTime periodEnd, DateTime generatedAt, RevenueBreakdown revenue, double totalExpenses, double grossProfit, double operatingProfit, double netProfit, double taxAmount, double taxRate, int totalInvoices, int paidInvoices, int overdueInvoices, int newCustomers, int churnedCustomers, double customerLifetimeValue, double monthlyRecurringRevenue, double annualRecurringRevenue, double churnRate, double growthRate, Map<String, dynamic>? metrics, Map<String, dynamic>? comparisons, String? notes, Map<String, dynamic>? metadata, DateTime? createdAt, DateTime? updatedAt
});


$RevenueBreakdownCopyWith<$Res> get revenue;

}
/// @nodoc
class _$FinancialReportCopyWithImpl<$Res>
    implements $FinancialReportCopyWith<$Res> {
  _$FinancialReportCopyWithImpl(this._self, this._then);

  final FinancialReport _self;
  final $Res Function(FinancialReport) _then;

/// Create a copy of FinancialReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reportName = null,Object? period = null,Object? periodStart = null,Object? periodEnd = null,Object? generatedAt = null,Object? revenue = null,Object? totalExpenses = null,Object? grossProfit = null,Object? operatingProfit = null,Object? netProfit = null,Object? taxAmount = null,Object? taxRate = null,Object? totalInvoices = null,Object? paidInvoices = null,Object? overdueInvoices = null,Object? newCustomers = null,Object? churnedCustomers = null,Object? customerLifetimeValue = null,Object? monthlyRecurringRevenue = null,Object? annualRecurringRevenue = null,Object? churnRate = null,Object? growthRate = null,Object? metrics = freezed,Object? comparisons = freezed,Object? notes = freezed,Object? metadata = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reportName: null == reportName ? _self.reportName : reportName // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as ReportPeriod,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as RevenueBreakdown,totalExpenses: null == totalExpenses ? _self.totalExpenses : totalExpenses // ignore: cast_nullable_to_non_nullable
as double,grossProfit: null == grossProfit ? _self.grossProfit : grossProfit // ignore: cast_nullable_to_non_nullable
as double,operatingProfit: null == operatingProfit ? _self.operatingProfit : operatingProfit // ignore: cast_nullable_to_non_nullable
as double,netProfit: null == netProfit ? _self.netProfit : netProfit // ignore: cast_nullable_to_non_nullable
as double,taxAmount: null == taxAmount ? _self.taxAmount : taxAmount // ignore: cast_nullable_to_non_nullable
as double,taxRate: null == taxRate ? _self.taxRate : taxRate // ignore: cast_nullable_to_non_nullable
as double,totalInvoices: null == totalInvoices ? _self.totalInvoices : totalInvoices // ignore: cast_nullable_to_non_nullable
as int,paidInvoices: null == paidInvoices ? _self.paidInvoices : paidInvoices // ignore: cast_nullable_to_non_nullable
as int,overdueInvoices: null == overdueInvoices ? _self.overdueInvoices : overdueInvoices // ignore: cast_nullable_to_non_nullable
as int,newCustomers: null == newCustomers ? _self.newCustomers : newCustomers // ignore: cast_nullable_to_non_nullable
as int,churnedCustomers: null == churnedCustomers ? _self.churnedCustomers : churnedCustomers // ignore: cast_nullable_to_non_nullable
as int,customerLifetimeValue: null == customerLifetimeValue ? _self.customerLifetimeValue : customerLifetimeValue // ignore: cast_nullable_to_non_nullable
as double,monthlyRecurringRevenue: null == monthlyRecurringRevenue ? _self.monthlyRecurringRevenue : monthlyRecurringRevenue // ignore: cast_nullable_to_non_nullable
as double,annualRecurringRevenue: null == annualRecurringRevenue ? _self.annualRecurringRevenue : annualRecurringRevenue // ignore: cast_nullable_to_non_nullable
as double,churnRate: null == churnRate ? _self.churnRate : churnRate // ignore: cast_nullable_to_non_nullable
as double,growthRate: null == growthRate ? _self.growthRate : growthRate // ignore: cast_nullable_to_non_nullable
as double,metrics: freezed == metrics ? _self.metrics : metrics // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,comparisons: freezed == comparisons ? _self.comparisons : comparisons // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of FinancialReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RevenueBreakdownCopyWith<$Res> get revenue {
  
  return $RevenueBreakdownCopyWith<$Res>(_self.revenue, (value) {
    return _then(_self.copyWith(revenue: value));
  });
}
}


/// Adds pattern-matching-related methods to [FinancialReport].
extension FinancialReportPatterns on FinancialReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FinancialReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FinancialReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FinancialReport value)  $default,){
final _that = this;
switch (_that) {
case _FinancialReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FinancialReport value)?  $default,){
final _that = this;
switch (_that) {
case _FinancialReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String reportName,  ReportPeriod period,  DateTime periodStart,  DateTime periodEnd,  DateTime generatedAt,  RevenueBreakdown revenue,  double totalExpenses,  double grossProfit,  double operatingProfit,  double netProfit,  double taxAmount,  double taxRate,  int totalInvoices,  int paidInvoices,  int overdueInvoices,  int newCustomers,  int churnedCustomers,  double customerLifetimeValue,  double monthlyRecurringRevenue,  double annualRecurringRevenue,  double churnRate,  double growthRate,  Map<String, dynamic>? metrics,  Map<String, dynamic>? comparisons,  String? notes,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FinancialReport() when $default != null:
return $default(_that.id,_that.reportName,_that.period,_that.periodStart,_that.periodEnd,_that.generatedAt,_that.revenue,_that.totalExpenses,_that.grossProfit,_that.operatingProfit,_that.netProfit,_that.taxAmount,_that.taxRate,_that.totalInvoices,_that.paidInvoices,_that.overdueInvoices,_that.newCustomers,_that.churnedCustomers,_that.customerLifetimeValue,_that.monthlyRecurringRevenue,_that.annualRecurringRevenue,_that.churnRate,_that.growthRate,_that.metrics,_that.comparisons,_that.notes,_that.metadata,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String reportName,  ReportPeriod period,  DateTime periodStart,  DateTime periodEnd,  DateTime generatedAt,  RevenueBreakdown revenue,  double totalExpenses,  double grossProfit,  double operatingProfit,  double netProfit,  double taxAmount,  double taxRate,  int totalInvoices,  int paidInvoices,  int overdueInvoices,  int newCustomers,  int churnedCustomers,  double customerLifetimeValue,  double monthlyRecurringRevenue,  double annualRecurringRevenue,  double churnRate,  double growthRate,  Map<String, dynamic>? metrics,  Map<String, dynamic>? comparisons,  String? notes,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _FinancialReport():
return $default(_that.id,_that.reportName,_that.period,_that.periodStart,_that.periodEnd,_that.generatedAt,_that.revenue,_that.totalExpenses,_that.grossProfit,_that.operatingProfit,_that.netProfit,_that.taxAmount,_that.taxRate,_that.totalInvoices,_that.paidInvoices,_that.overdueInvoices,_that.newCustomers,_that.churnedCustomers,_that.customerLifetimeValue,_that.monthlyRecurringRevenue,_that.annualRecurringRevenue,_that.churnRate,_that.growthRate,_that.metrics,_that.comparisons,_that.notes,_that.metadata,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String reportName,  ReportPeriod period,  DateTime periodStart,  DateTime periodEnd,  DateTime generatedAt,  RevenueBreakdown revenue,  double totalExpenses,  double grossProfit,  double operatingProfit,  double netProfit,  double taxAmount,  double taxRate,  int totalInvoices,  int paidInvoices,  int overdueInvoices,  int newCustomers,  int churnedCustomers,  double customerLifetimeValue,  double monthlyRecurringRevenue,  double annualRecurringRevenue,  double churnRate,  double growthRate,  Map<String, dynamic>? metrics,  Map<String, dynamic>? comparisons,  String? notes,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _FinancialReport() when $default != null:
return $default(_that.id,_that.reportName,_that.period,_that.periodStart,_that.periodEnd,_that.generatedAt,_that.revenue,_that.totalExpenses,_that.grossProfit,_that.operatingProfit,_that.netProfit,_that.taxAmount,_that.taxRate,_that.totalInvoices,_that.paidInvoices,_that.overdueInvoices,_that.newCustomers,_that.churnedCustomers,_that.customerLifetimeValue,_that.monthlyRecurringRevenue,_that.annualRecurringRevenue,_that.churnRate,_that.growthRate,_that.metrics,_that.comparisons,_that.notes,_that.metadata,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FinancialReport implements FinancialReport {
  const _FinancialReport({required this.id, required this.reportName, required this.period, required this.periodStart, required this.periodEnd, required this.generatedAt, required this.revenue, this.totalExpenses = 0.0, this.grossProfit = 0.0, this.operatingProfit = 0.0, this.netProfit = 0.0, this.taxAmount = 0.0, this.taxRate = 0.0, this.totalInvoices = 0, this.paidInvoices = 0, this.overdueInvoices = 0, this.newCustomers = 0, this.churnedCustomers = 0, this.customerLifetimeValue = 0.0, this.monthlyRecurringRevenue = 0.0, this.annualRecurringRevenue = 0.0, this.churnRate = 0.0, this.growthRate = 0.0, final  Map<String, dynamic>? metrics, final  Map<String, dynamic>? comparisons, this.notes, final  Map<String, dynamic>? metadata, this.createdAt, this.updatedAt}): _metrics = metrics,_comparisons = comparisons,_metadata = metadata;
  factory _FinancialReport.fromJson(Map<String, dynamic> json) => _$FinancialReportFromJson(json);

@override final  String id;
@override final  String reportName;
@override final  ReportPeriod period;
@override final  DateTime periodStart;
@override final  DateTime periodEnd;
@override final  DateTime generatedAt;
@override final  RevenueBreakdown revenue;
@override@JsonKey() final  double totalExpenses;
@override@JsonKey() final  double grossProfit;
@override@JsonKey() final  double operatingProfit;
@override@JsonKey() final  double netProfit;
@override@JsonKey() final  double taxAmount;
@override@JsonKey() final  double taxRate;
@override@JsonKey() final  int totalInvoices;
@override@JsonKey() final  int paidInvoices;
@override@JsonKey() final  int overdueInvoices;
@override@JsonKey() final  int newCustomers;
@override@JsonKey() final  int churnedCustomers;
@override@JsonKey() final  double customerLifetimeValue;
@override@JsonKey() final  double monthlyRecurringRevenue;
@override@JsonKey() final  double annualRecurringRevenue;
@override@JsonKey() final  double churnRate;
@override@JsonKey() final  double growthRate;
 final  Map<String, dynamic>? _metrics;
@override Map<String, dynamic>? get metrics {
  final value = _metrics;
  if (value == null) return null;
  if (_metrics is EqualUnmodifiableMapView) return _metrics;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _comparisons;
@override Map<String, dynamic>? get comparisons {
  final value = _comparisons;
  if (value == null) return null;
  if (_comparisons is EqualUnmodifiableMapView) return _comparisons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

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

/// Create a copy of FinancialReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FinancialReportCopyWith<_FinancialReport> get copyWith => __$FinancialReportCopyWithImpl<_FinancialReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FinancialReportToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FinancialReport&&(identical(other.id, id) || other.id == id)&&(identical(other.reportName, reportName) || other.reportName == reportName)&&(identical(other.period, period) || other.period == period)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.totalExpenses, totalExpenses) || other.totalExpenses == totalExpenses)&&(identical(other.grossProfit, grossProfit) || other.grossProfit == grossProfit)&&(identical(other.operatingProfit, operatingProfit) || other.operatingProfit == operatingProfit)&&(identical(other.netProfit, netProfit) || other.netProfit == netProfit)&&(identical(other.taxAmount, taxAmount) || other.taxAmount == taxAmount)&&(identical(other.taxRate, taxRate) || other.taxRate == taxRate)&&(identical(other.totalInvoices, totalInvoices) || other.totalInvoices == totalInvoices)&&(identical(other.paidInvoices, paidInvoices) || other.paidInvoices == paidInvoices)&&(identical(other.overdueInvoices, overdueInvoices) || other.overdueInvoices == overdueInvoices)&&(identical(other.newCustomers, newCustomers) || other.newCustomers == newCustomers)&&(identical(other.churnedCustomers, churnedCustomers) || other.churnedCustomers == churnedCustomers)&&(identical(other.customerLifetimeValue, customerLifetimeValue) || other.customerLifetimeValue == customerLifetimeValue)&&(identical(other.monthlyRecurringRevenue, monthlyRecurringRevenue) || other.monthlyRecurringRevenue == monthlyRecurringRevenue)&&(identical(other.annualRecurringRevenue, annualRecurringRevenue) || other.annualRecurringRevenue == annualRecurringRevenue)&&(identical(other.churnRate, churnRate) || other.churnRate == churnRate)&&(identical(other.growthRate, growthRate) || other.growthRate == growthRate)&&const DeepCollectionEquality().equals(other._metrics, _metrics)&&const DeepCollectionEquality().equals(other._comparisons, _comparisons)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,reportName,period,periodStart,periodEnd,generatedAt,revenue,totalExpenses,grossProfit,operatingProfit,netProfit,taxAmount,taxRate,totalInvoices,paidInvoices,overdueInvoices,newCustomers,churnedCustomers,customerLifetimeValue,monthlyRecurringRevenue,annualRecurringRevenue,churnRate,growthRate,const DeepCollectionEquality().hash(_metrics),const DeepCollectionEquality().hash(_comparisons),notes,const DeepCollectionEquality().hash(_metadata),createdAt,updatedAt]);

@override
String toString() {
  return 'FinancialReport(id: $id, reportName: $reportName, period: $period, periodStart: $periodStart, periodEnd: $periodEnd, generatedAt: $generatedAt, revenue: $revenue, totalExpenses: $totalExpenses, grossProfit: $grossProfit, operatingProfit: $operatingProfit, netProfit: $netProfit, taxAmount: $taxAmount, taxRate: $taxRate, totalInvoices: $totalInvoices, paidInvoices: $paidInvoices, overdueInvoices: $overdueInvoices, newCustomers: $newCustomers, churnedCustomers: $churnedCustomers, customerLifetimeValue: $customerLifetimeValue, monthlyRecurringRevenue: $monthlyRecurringRevenue, annualRecurringRevenue: $annualRecurringRevenue, churnRate: $churnRate, growthRate: $growthRate, metrics: $metrics, comparisons: $comparisons, notes: $notes, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$FinancialReportCopyWith<$Res> implements $FinancialReportCopyWith<$Res> {
  factory _$FinancialReportCopyWith(_FinancialReport value, $Res Function(_FinancialReport) _then) = __$FinancialReportCopyWithImpl;
@override @useResult
$Res call({
 String id, String reportName, ReportPeriod period, DateTime periodStart, DateTime periodEnd, DateTime generatedAt, RevenueBreakdown revenue, double totalExpenses, double grossProfit, double operatingProfit, double netProfit, double taxAmount, double taxRate, int totalInvoices, int paidInvoices, int overdueInvoices, int newCustomers, int churnedCustomers, double customerLifetimeValue, double monthlyRecurringRevenue, double annualRecurringRevenue, double churnRate, double growthRate, Map<String, dynamic>? metrics, Map<String, dynamic>? comparisons, String? notes, Map<String, dynamic>? metadata, DateTime? createdAt, DateTime? updatedAt
});


@override $RevenueBreakdownCopyWith<$Res> get revenue;

}
/// @nodoc
class __$FinancialReportCopyWithImpl<$Res>
    implements _$FinancialReportCopyWith<$Res> {
  __$FinancialReportCopyWithImpl(this._self, this._then);

  final _FinancialReport _self;
  final $Res Function(_FinancialReport) _then;

/// Create a copy of FinancialReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reportName = null,Object? period = null,Object? periodStart = null,Object? periodEnd = null,Object? generatedAt = null,Object? revenue = null,Object? totalExpenses = null,Object? grossProfit = null,Object? operatingProfit = null,Object? netProfit = null,Object? taxAmount = null,Object? taxRate = null,Object? totalInvoices = null,Object? paidInvoices = null,Object? overdueInvoices = null,Object? newCustomers = null,Object? churnedCustomers = null,Object? customerLifetimeValue = null,Object? monthlyRecurringRevenue = null,Object? annualRecurringRevenue = null,Object? churnRate = null,Object? growthRate = null,Object? metrics = freezed,Object? comparisons = freezed,Object? notes = freezed,Object? metadata = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_FinancialReport(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reportName: null == reportName ? _self.reportName : reportName // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as ReportPeriod,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as RevenueBreakdown,totalExpenses: null == totalExpenses ? _self.totalExpenses : totalExpenses // ignore: cast_nullable_to_non_nullable
as double,grossProfit: null == grossProfit ? _self.grossProfit : grossProfit // ignore: cast_nullable_to_non_nullable
as double,operatingProfit: null == operatingProfit ? _self.operatingProfit : operatingProfit // ignore: cast_nullable_to_non_nullable
as double,netProfit: null == netProfit ? _self.netProfit : netProfit // ignore: cast_nullable_to_non_nullable
as double,taxAmount: null == taxAmount ? _self.taxAmount : taxAmount // ignore: cast_nullable_to_non_nullable
as double,taxRate: null == taxRate ? _self.taxRate : taxRate // ignore: cast_nullable_to_non_nullable
as double,totalInvoices: null == totalInvoices ? _self.totalInvoices : totalInvoices // ignore: cast_nullable_to_non_nullable
as int,paidInvoices: null == paidInvoices ? _self.paidInvoices : paidInvoices // ignore: cast_nullable_to_non_nullable
as int,overdueInvoices: null == overdueInvoices ? _self.overdueInvoices : overdueInvoices // ignore: cast_nullable_to_non_nullable
as int,newCustomers: null == newCustomers ? _self.newCustomers : newCustomers // ignore: cast_nullable_to_non_nullable
as int,churnedCustomers: null == churnedCustomers ? _self.churnedCustomers : churnedCustomers // ignore: cast_nullable_to_non_nullable
as int,customerLifetimeValue: null == customerLifetimeValue ? _self.customerLifetimeValue : customerLifetimeValue // ignore: cast_nullable_to_non_nullable
as double,monthlyRecurringRevenue: null == monthlyRecurringRevenue ? _self.monthlyRecurringRevenue : monthlyRecurringRevenue // ignore: cast_nullable_to_non_nullable
as double,annualRecurringRevenue: null == annualRecurringRevenue ? _self.annualRecurringRevenue : annualRecurringRevenue // ignore: cast_nullable_to_non_nullable
as double,churnRate: null == churnRate ? _self.churnRate : churnRate // ignore: cast_nullable_to_non_nullable
as double,growthRate: null == growthRate ? _self.growthRate : growthRate // ignore: cast_nullable_to_non_nullable
as double,metrics: freezed == metrics ? _self._metrics : metrics // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,comparisons: freezed == comparisons ? _self._comparisons : comparisons // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of FinancialReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RevenueBreakdownCopyWith<$Res> get revenue {
  
  return $RevenueBreakdownCopyWith<$Res>(_self.revenue, (value) {
    return _then(_self.copyWith(revenue: value));
  });
}
}


/// @nodoc
mixin _$RevenueForecast {

 DateTime get forecastDate; DateTime get periodStart; DateTime get periodEnd; double get forecastedRevenue; String get currency; double get lowerBound; double get upperBound; double get confidenceLevel; Map<String, double>? get forecastByType; Map<String, double>? get forecastByCompany; List<RevenueDataPoint>? get historicalData; List<RevenueDataPoint>? get forecastData; String? get methodology; Map<String, dynamic>? get assumptions; Map<String, dynamic>? get metadata; DateTime? get createdAt;
/// Create a copy of RevenueForecast
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RevenueForecastCopyWith<RevenueForecast> get copyWith => _$RevenueForecastCopyWithImpl<RevenueForecast>(this as RevenueForecast, _$identity);

  /// Serializes this RevenueForecast to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RevenueForecast&&(identical(other.forecastDate, forecastDate) || other.forecastDate == forecastDate)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.forecastedRevenue, forecastedRevenue) || other.forecastedRevenue == forecastedRevenue)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.lowerBound, lowerBound) || other.lowerBound == lowerBound)&&(identical(other.upperBound, upperBound) || other.upperBound == upperBound)&&(identical(other.confidenceLevel, confidenceLevel) || other.confidenceLevel == confidenceLevel)&&const DeepCollectionEquality().equals(other.forecastByType, forecastByType)&&const DeepCollectionEquality().equals(other.forecastByCompany, forecastByCompany)&&const DeepCollectionEquality().equals(other.historicalData, historicalData)&&const DeepCollectionEquality().equals(other.forecastData, forecastData)&&(identical(other.methodology, methodology) || other.methodology == methodology)&&const DeepCollectionEquality().equals(other.assumptions, assumptions)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,forecastDate,periodStart,periodEnd,forecastedRevenue,currency,lowerBound,upperBound,confidenceLevel,const DeepCollectionEquality().hash(forecastByType),const DeepCollectionEquality().hash(forecastByCompany),const DeepCollectionEquality().hash(historicalData),const DeepCollectionEquality().hash(forecastData),methodology,const DeepCollectionEquality().hash(assumptions),const DeepCollectionEquality().hash(metadata),createdAt);

@override
String toString() {
  return 'RevenueForecast(forecastDate: $forecastDate, periodStart: $periodStart, periodEnd: $periodEnd, forecastedRevenue: $forecastedRevenue, currency: $currency, lowerBound: $lowerBound, upperBound: $upperBound, confidenceLevel: $confidenceLevel, forecastByType: $forecastByType, forecastByCompany: $forecastByCompany, historicalData: $historicalData, forecastData: $forecastData, methodology: $methodology, assumptions: $assumptions, metadata: $metadata, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $RevenueForecastCopyWith<$Res>  {
  factory $RevenueForecastCopyWith(RevenueForecast value, $Res Function(RevenueForecast) _then) = _$RevenueForecastCopyWithImpl;
@useResult
$Res call({
 DateTime forecastDate, DateTime periodStart, DateTime periodEnd, double forecastedRevenue, String currency, double lowerBound, double upperBound, double confidenceLevel, Map<String, double>? forecastByType, Map<String, double>? forecastByCompany, List<RevenueDataPoint>? historicalData, List<RevenueDataPoint>? forecastData, String? methodology, Map<String, dynamic>? assumptions, Map<String, dynamic>? metadata, DateTime? createdAt
});




}
/// @nodoc
class _$RevenueForecastCopyWithImpl<$Res>
    implements $RevenueForecastCopyWith<$Res> {
  _$RevenueForecastCopyWithImpl(this._self, this._then);

  final RevenueForecast _self;
  final $Res Function(RevenueForecast) _then;

/// Create a copy of RevenueForecast
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? forecastDate = null,Object? periodStart = null,Object? periodEnd = null,Object? forecastedRevenue = null,Object? currency = null,Object? lowerBound = null,Object? upperBound = null,Object? confidenceLevel = null,Object? forecastByType = freezed,Object? forecastByCompany = freezed,Object? historicalData = freezed,Object? forecastData = freezed,Object? methodology = freezed,Object? assumptions = freezed,Object? metadata = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
forecastDate: null == forecastDate ? _self.forecastDate : forecastDate // ignore: cast_nullable_to_non_nullable
as DateTime,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,forecastedRevenue: null == forecastedRevenue ? _self.forecastedRevenue : forecastedRevenue // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,lowerBound: null == lowerBound ? _self.lowerBound : lowerBound // ignore: cast_nullable_to_non_nullable
as double,upperBound: null == upperBound ? _self.upperBound : upperBound // ignore: cast_nullable_to_non_nullable
as double,confidenceLevel: null == confidenceLevel ? _self.confidenceLevel : confidenceLevel // ignore: cast_nullable_to_non_nullable
as double,forecastByType: freezed == forecastByType ? _self.forecastByType : forecastByType // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,forecastByCompany: freezed == forecastByCompany ? _self.forecastByCompany : forecastByCompany // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,historicalData: freezed == historicalData ? _self.historicalData : historicalData // ignore: cast_nullable_to_non_nullable
as List<RevenueDataPoint>?,forecastData: freezed == forecastData ? _self.forecastData : forecastData // ignore: cast_nullable_to_non_nullable
as List<RevenueDataPoint>?,methodology: freezed == methodology ? _self.methodology : methodology // ignore: cast_nullable_to_non_nullable
as String?,assumptions: freezed == assumptions ? _self.assumptions : assumptions // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RevenueForecast].
extension RevenueForecastPatterns on RevenueForecast {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RevenueForecast value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RevenueForecast() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RevenueForecast value)  $default,){
final _that = this;
switch (_that) {
case _RevenueForecast():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RevenueForecast value)?  $default,){
final _that = this;
switch (_that) {
case _RevenueForecast() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime forecastDate,  DateTime periodStart,  DateTime periodEnd,  double forecastedRevenue,  String currency,  double lowerBound,  double upperBound,  double confidenceLevel,  Map<String, double>? forecastByType,  Map<String, double>? forecastByCompany,  List<RevenueDataPoint>? historicalData,  List<RevenueDataPoint>? forecastData,  String? methodology,  Map<String, dynamic>? assumptions,  Map<String, dynamic>? metadata,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RevenueForecast() when $default != null:
return $default(_that.forecastDate,_that.periodStart,_that.periodEnd,_that.forecastedRevenue,_that.currency,_that.lowerBound,_that.upperBound,_that.confidenceLevel,_that.forecastByType,_that.forecastByCompany,_that.historicalData,_that.forecastData,_that.methodology,_that.assumptions,_that.metadata,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime forecastDate,  DateTime periodStart,  DateTime periodEnd,  double forecastedRevenue,  String currency,  double lowerBound,  double upperBound,  double confidenceLevel,  Map<String, double>? forecastByType,  Map<String, double>? forecastByCompany,  List<RevenueDataPoint>? historicalData,  List<RevenueDataPoint>? forecastData,  String? methodology,  Map<String, dynamic>? assumptions,  Map<String, dynamic>? metadata,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _RevenueForecast():
return $default(_that.forecastDate,_that.periodStart,_that.periodEnd,_that.forecastedRevenue,_that.currency,_that.lowerBound,_that.upperBound,_that.confidenceLevel,_that.forecastByType,_that.forecastByCompany,_that.historicalData,_that.forecastData,_that.methodology,_that.assumptions,_that.metadata,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime forecastDate,  DateTime periodStart,  DateTime periodEnd,  double forecastedRevenue,  String currency,  double lowerBound,  double upperBound,  double confidenceLevel,  Map<String, double>? forecastByType,  Map<String, double>? forecastByCompany,  List<RevenueDataPoint>? historicalData,  List<RevenueDataPoint>? forecastData,  String? methodology,  Map<String, dynamic>? assumptions,  Map<String, dynamic>? metadata,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _RevenueForecast() when $default != null:
return $default(_that.forecastDate,_that.periodStart,_that.periodEnd,_that.forecastedRevenue,_that.currency,_that.lowerBound,_that.upperBound,_that.confidenceLevel,_that.forecastByType,_that.forecastByCompany,_that.historicalData,_that.forecastData,_that.methodology,_that.assumptions,_that.metadata,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RevenueForecast implements RevenueForecast {
  const _RevenueForecast({required this.forecastDate, required this.periodStart, required this.periodEnd, this.forecastedRevenue = 0.0, this.currency = 'USD', this.lowerBound = 0.0, this.upperBound = 0.0, this.confidenceLevel = 0.0, final  Map<String, double>? forecastByType, final  Map<String, double>? forecastByCompany, final  List<RevenueDataPoint>? historicalData, final  List<RevenueDataPoint>? forecastData, this.methodology, final  Map<String, dynamic>? assumptions, final  Map<String, dynamic>? metadata, this.createdAt}): _forecastByType = forecastByType,_forecastByCompany = forecastByCompany,_historicalData = historicalData,_forecastData = forecastData,_assumptions = assumptions,_metadata = metadata;
  factory _RevenueForecast.fromJson(Map<String, dynamic> json) => _$RevenueForecastFromJson(json);

@override final  DateTime forecastDate;
@override final  DateTime periodStart;
@override final  DateTime periodEnd;
@override@JsonKey() final  double forecastedRevenue;
@override@JsonKey() final  String currency;
@override@JsonKey() final  double lowerBound;
@override@JsonKey() final  double upperBound;
@override@JsonKey() final  double confidenceLevel;
 final  Map<String, double>? _forecastByType;
@override Map<String, double>? get forecastByType {
  final value = _forecastByType;
  if (value == null) return null;
  if (_forecastByType is EqualUnmodifiableMapView) return _forecastByType;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, double>? _forecastByCompany;
@override Map<String, double>? get forecastByCompany {
  final value = _forecastByCompany;
  if (value == null) return null;
  if (_forecastByCompany is EqualUnmodifiableMapView) return _forecastByCompany;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<RevenueDataPoint>? _historicalData;
@override List<RevenueDataPoint>? get historicalData {
  final value = _historicalData;
  if (value == null) return null;
  if (_historicalData is EqualUnmodifiableListView) return _historicalData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<RevenueDataPoint>? _forecastData;
@override List<RevenueDataPoint>? get forecastData {
  final value = _forecastData;
  if (value == null) return null;
  if (_forecastData is EqualUnmodifiableListView) return _forecastData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? methodology;
 final  Map<String, dynamic>? _assumptions;
@override Map<String, dynamic>? get assumptions {
  final value = _assumptions;
  if (value == null) return null;
  if (_assumptions is EqualUnmodifiableMapView) return _assumptions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  DateTime? createdAt;

/// Create a copy of RevenueForecast
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RevenueForecastCopyWith<_RevenueForecast> get copyWith => __$RevenueForecastCopyWithImpl<_RevenueForecast>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RevenueForecastToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RevenueForecast&&(identical(other.forecastDate, forecastDate) || other.forecastDate == forecastDate)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.forecastedRevenue, forecastedRevenue) || other.forecastedRevenue == forecastedRevenue)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.lowerBound, lowerBound) || other.lowerBound == lowerBound)&&(identical(other.upperBound, upperBound) || other.upperBound == upperBound)&&(identical(other.confidenceLevel, confidenceLevel) || other.confidenceLevel == confidenceLevel)&&const DeepCollectionEquality().equals(other._forecastByType, _forecastByType)&&const DeepCollectionEquality().equals(other._forecastByCompany, _forecastByCompany)&&const DeepCollectionEquality().equals(other._historicalData, _historicalData)&&const DeepCollectionEquality().equals(other._forecastData, _forecastData)&&(identical(other.methodology, methodology) || other.methodology == methodology)&&const DeepCollectionEquality().equals(other._assumptions, _assumptions)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,forecastDate,periodStart,periodEnd,forecastedRevenue,currency,lowerBound,upperBound,confidenceLevel,const DeepCollectionEquality().hash(_forecastByType),const DeepCollectionEquality().hash(_forecastByCompany),const DeepCollectionEquality().hash(_historicalData),const DeepCollectionEquality().hash(_forecastData),methodology,const DeepCollectionEquality().hash(_assumptions),const DeepCollectionEquality().hash(_metadata),createdAt);

@override
String toString() {
  return 'RevenueForecast(forecastDate: $forecastDate, periodStart: $periodStart, periodEnd: $periodEnd, forecastedRevenue: $forecastedRevenue, currency: $currency, lowerBound: $lowerBound, upperBound: $upperBound, confidenceLevel: $confidenceLevel, forecastByType: $forecastByType, forecastByCompany: $forecastByCompany, historicalData: $historicalData, forecastData: $forecastData, methodology: $methodology, assumptions: $assumptions, metadata: $metadata, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$RevenueForecastCopyWith<$Res> implements $RevenueForecastCopyWith<$Res> {
  factory _$RevenueForecastCopyWith(_RevenueForecast value, $Res Function(_RevenueForecast) _then) = __$RevenueForecastCopyWithImpl;
@override @useResult
$Res call({
 DateTime forecastDate, DateTime periodStart, DateTime periodEnd, double forecastedRevenue, String currency, double lowerBound, double upperBound, double confidenceLevel, Map<String, double>? forecastByType, Map<String, double>? forecastByCompany, List<RevenueDataPoint>? historicalData, List<RevenueDataPoint>? forecastData, String? methodology, Map<String, dynamic>? assumptions, Map<String, dynamic>? metadata, DateTime? createdAt
});




}
/// @nodoc
class __$RevenueForecastCopyWithImpl<$Res>
    implements _$RevenueForecastCopyWith<$Res> {
  __$RevenueForecastCopyWithImpl(this._self, this._then);

  final _RevenueForecast _self;
  final $Res Function(_RevenueForecast) _then;

/// Create a copy of RevenueForecast
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? forecastDate = null,Object? periodStart = null,Object? periodEnd = null,Object? forecastedRevenue = null,Object? currency = null,Object? lowerBound = null,Object? upperBound = null,Object? confidenceLevel = null,Object? forecastByType = freezed,Object? forecastByCompany = freezed,Object? historicalData = freezed,Object? forecastData = freezed,Object? methodology = freezed,Object? assumptions = freezed,Object? metadata = freezed,Object? createdAt = freezed,}) {
  return _then(_RevenueForecast(
forecastDate: null == forecastDate ? _self.forecastDate : forecastDate // ignore: cast_nullable_to_non_nullable
as DateTime,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,forecastedRevenue: null == forecastedRevenue ? _self.forecastedRevenue : forecastedRevenue // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,lowerBound: null == lowerBound ? _self.lowerBound : lowerBound // ignore: cast_nullable_to_non_nullable
as double,upperBound: null == upperBound ? _self.upperBound : upperBound // ignore: cast_nullable_to_non_nullable
as double,confidenceLevel: null == confidenceLevel ? _self.confidenceLevel : confidenceLevel // ignore: cast_nullable_to_non_nullable
as double,forecastByType: freezed == forecastByType ? _self._forecastByType : forecastByType // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,forecastByCompany: freezed == forecastByCompany ? _self._forecastByCompany : forecastByCompany // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,historicalData: freezed == historicalData ? _self._historicalData : historicalData // ignore: cast_nullable_to_non_nullable
as List<RevenueDataPoint>?,forecastData: freezed == forecastData ? _self._forecastData : forecastData // ignore: cast_nullable_to_non_nullable
as List<RevenueDataPoint>?,methodology: freezed == methodology ? _self.methodology : methodology // ignore: cast_nullable_to_non_nullable
as String?,assumptions: freezed == assumptions ? _self._assumptions : assumptions // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$TaxSummary {

 DateTime get periodStart; DateTime get periodEnd; double get taxableRevenue; double get taxCollected; String get currency; double get taxRate; Map<String, double>? get taxByJurisdiction; Map<String, double>? get taxByCompany; Map<String, double>? get taxByRevenueType; List<TaxTransaction>? get transactions; String? get notes; Map<String, dynamic>? get metadata; DateTime? get generatedAt;
/// Create a copy of TaxSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaxSummaryCopyWith<TaxSummary> get copyWith => _$TaxSummaryCopyWithImpl<TaxSummary>(this as TaxSummary, _$identity);

  /// Serializes this TaxSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaxSummary&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.taxableRevenue, taxableRevenue) || other.taxableRevenue == taxableRevenue)&&(identical(other.taxCollected, taxCollected) || other.taxCollected == taxCollected)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.taxRate, taxRate) || other.taxRate == taxRate)&&const DeepCollectionEquality().equals(other.taxByJurisdiction, taxByJurisdiction)&&const DeepCollectionEquality().equals(other.taxByCompany, taxByCompany)&&const DeepCollectionEquality().equals(other.taxByRevenueType, taxByRevenueType)&&const DeepCollectionEquality().equals(other.transactions, transactions)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,periodStart,periodEnd,taxableRevenue,taxCollected,currency,taxRate,const DeepCollectionEquality().hash(taxByJurisdiction),const DeepCollectionEquality().hash(taxByCompany),const DeepCollectionEquality().hash(taxByRevenueType),const DeepCollectionEquality().hash(transactions),notes,const DeepCollectionEquality().hash(metadata),generatedAt);

@override
String toString() {
  return 'TaxSummary(periodStart: $periodStart, periodEnd: $periodEnd, taxableRevenue: $taxableRevenue, taxCollected: $taxCollected, currency: $currency, taxRate: $taxRate, taxByJurisdiction: $taxByJurisdiction, taxByCompany: $taxByCompany, taxByRevenueType: $taxByRevenueType, transactions: $transactions, notes: $notes, metadata: $metadata, generatedAt: $generatedAt)';
}


}

/// @nodoc
abstract mixin class $TaxSummaryCopyWith<$Res>  {
  factory $TaxSummaryCopyWith(TaxSummary value, $Res Function(TaxSummary) _then) = _$TaxSummaryCopyWithImpl;
@useResult
$Res call({
 DateTime periodStart, DateTime periodEnd, double taxableRevenue, double taxCollected, String currency, double taxRate, Map<String, double>? taxByJurisdiction, Map<String, double>? taxByCompany, Map<String, double>? taxByRevenueType, List<TaxTransaction>? transactions, String? notes, Map<String, dynamic>? metadata, DateTime? generatedAt
});




}
/// @nodoc
class _$TaxSummaryCopyWithImpl<$Res>
    implements $TaxSummaryCopyWith<$Res> {
  _$TaxSummaryCopyWithImpl(this._self, this._then);

  final TaxSummary _self;
  final $Res Function(TaxSummary) _then;

/// Create a copy of TaxSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? periodStart = null,Object? periodEnd = null,Object? taxableRevenue = null,Object? taxCollected = null,Object? currency = null,Object? taxRate = null,Object? taxByJurisdiction = freezed,Object? taxByCompany = freezed,Object? taxByRevenueType = freezed,Object? transactions = freezed,Object? notes = freezed,Object? metadata = freezed,Object? generatedAt = freezed,}) {
  return _then(_self.copyWith(
periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,taxableRevenue: null == taxableRevenue ? _self.taxableRevenue : taxableRevenue // ignore: cast_nullable_to_non_nullable
as double,taxCollected: null == taxCollected ? _self.taxCollected : taxCollected // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,taxRate: null == taxRate ? _self.taxRate : taxRate // ignore: cast_nullable_to_non_nullable
as double,taxByJurisdiction: freezed == taxByJurisdiction ? _self.taxByJurisdiction : taxByJurisdiction // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,taxByCompany: freezed == taxByCompany ? _self.taxByCompany : taxByCompany // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,taxByRevenueType: freezed == taxByRevenueType ? _self.taxByRevenueType : taxByRevenueType // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,transactions: freezed == transactions ? _self.transactions : transactions // ignore: cast_nullable_to_non_nullable
as List<TaxTransaction>?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,generatedAt: freezed == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [TaxSummary].
extension TaxSummaryPatterns on TaxSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaxSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaxSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaxSummary value)  $default,){
final _that = this;
switch (_that) {
case _TaxSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaxSummary value)?  $default,){
final _that = this;
switch (_that) {
case _TaxSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime periodStart,  DateTime periodEnd,  double taxableRevenue,  double taxCollected,  String currency,  double taxRate,  Map<String, double>? taxByJurisdiction,  Map<String, double>? taxByCompany,  Map<String, double>? taxByRevenueType,  List<TaxTransaction>? transactions,  String? notes,  Map<String, dynamic>? metadata,  DateTime? generatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaxSummary() when $default != null:
return $default(_that.periodStart,_that.periodEnd,_that.taxableRevenue,_that.taxCollected,_that.currency,_that.taxRate,_that.taxByJurisdiction,_that.taxByCompany,_that.taxByRevenueType,_that.transactions,_that.notes,_that.metadata,_that.generatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime periodStart,  DateTime periodEnd,  double taxableRevenue,  double taxCollected,  String currency,  double taxRate,  Map<String, double>? taxByJurisdiction,  Map<String, double>? taxByCompany,  Map<String, double>? taxByRevenueType,  List<TaxTransaction>? transactions,  String? notes,  Map<String, dynamic>? metadata,  DateTime? generatedAt)  $default,) {final _that = this;
switch (_that) {
case _TaxSummary():
return $default(_that.periodStart,_that.periodEnd,_that.taxableRevenue,_that.taxCollected,_that.currency,_that.taxRate,_that.taxByJurisdiction,_that.taxByCompany,_that.taxByRevenueType,_that.transactions,_that.notes,_that.metadata,_that.generatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime periodStart,  DateTime periodEnd,  double taxableRevenue,  double taxCollected,  String currency,  double taxRate,  Map<String, double>? taxByJurisdiction,  Map<String, double>? taxByCompany,  Map<String, double>? taxByRevenueType,  List<TaxTransaction>? transactions,  String? notes,  Map<String, dynamic>? metadata,  DateTime? generatedAt)?  $default,) {final _that = this;
switch (_that) {
case _TaxSummary() when $default != null:
return $default(_that.periodStart,_that.periodEnd,_that.taxableRevenue,_that.taxCollected,_that.currency,_that.taxRate,_that.taxByJurisdiction,_that.taxByCompany,_that.taxByRevenueType,_that.transactions,_that.notes,_that.metadata,_that.generatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TaxSummary implements TaxSummary {
  const _TaxSummary({required this.periodStart, required this.periodEnd, this.taxableRevenue = 0.0, this.taxCollected = 0.0, this.currency = 'USD', this.taxRate = 0.0, final  Map<String, double>? taxByJurisdiction, final  Map<String, double>? taxByCompany, final  Map<String, double>? taxByRevenueType, final  List<TaxTransaction>? transactions, this.notes, final  Map<String, dynamic>? metadata, this.generatedAt}): _taxByJurisdiction = taxByJurisdiction,_taxByCompany = taxByCompany,_taxByRevenueType = taxByRevenueType,_transactions = transactions,_metadata = metadata;
  factory _TaxSummary.fromJson(Map<String, dynamic> json) => _$TaxSummaryFromJson(json);

@override final  DateTime periodStart;
@override final  DateTime periodEnd;
@override@JsonKey() final  double taxableRevenue;
@override@JsonKey() final  double taxCollected;
@override@JsonKey() final  String currency;
@override@JsonKey() final  double taxRate;
 final  Map<String, double>? _taxByJurisdiction;
@override Map<String, double>? get taxByJurisdiction {
  final value = _taxByJurisdiction;
  if (value == null) return null;
  if (_taxByJurisdiction is EqualUnmodifiableMapView) return _taxByJurisdiction;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, double>? _taxByCompany;
@override Map<String, double>? get taxByCompany {
  final value = _taxByCompany;
  if (value == null) return null;
  if (_taxByCompany is EqualUnmodifiableMapView) return _taxByCompany;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, double>? _taxByRevenueType;
@override Map<String, double>? get taxByRevenueType {
  final value = _taxByRevenueType;
  if (value == null) return null;
  if (_taxByRevenueType is EqualUnmodifiableMapView) return _taxByRevenueType;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<TaxTransaction>? _transactions;
@override List<TaxTransaction>? get transactions {
  final value = _transactions;
  if (value == null) return null;
  if (_transactions is EqualUnmodifiableListView) return _transactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? notes;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  DateTime? generatedAt;

/// Create a copy of TaxSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaxSummaryCopyWith<_TaxSummary> get copyWith => __$TaxSummaryCopyWithImpl<_TaxSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaxSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaxSummary&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.taxableRevenue, taxableRevenue) || other.taxableRevenue == taxableRevenue)&&(identical(other.taxCollected, taxCollected) || other.taxCollected == taxCollected)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.taxRate, taxRate) || other.taxRate == taxRate)&&const DeepCollectionEquality().equals(other._taxByJurisdiction, _taxByJurisdiction)&&const DeepCollectionEquality().equals(other._taxByCompany, _taxByCompany)&&const DeepCollectionEquality().equals(other._taxByRevenueType, _taxByRevenueType)&&const DeepCollectionEquality().equals(other._transactions, _transactions)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,periodStart,periodEnd,taxableRevenue,taxCollected,currency,taxRate,const DeepCollectionEquality().hash(_taxByJurisdiction),const DeepCollectionEquality().hash(_taxByCompany),const DeepCollectionEquality().hash(_taxByRevenueType),const DeepCollectionEquality().hash(_transactions),notes,const DeepCollectionEquality().hash(_metadata),generatedAt);

@override
String toString() {
  return 'TaxSummary(periodStart: $periodStart, periodEnd: $periodEnd, taxableRevenue: $taxableRevenue, taxCollected: $taxCollected, currency: $currency, taxRate: $taxRate, taxByJurisdiction: $taxByJurisdiction, taxByCompany: $taxByCompany, taxByRevenueType: $taxByRevenueType, transactions: $transactions, notes: $notes, metadata: $metadata, generatedAt: $generatedAt)';
}


}

/// @nodoc
abstract mixin class _$TaxSummaryCopyWith<$Res> implements $TaxSummaryCopyWith<$Res> {
  factory _$TaxSummaryCopyWith(_TaxSummary value, $Res Function(_TaxSummary) _then) = __$TaxSummaryCopyWithImpl;
@override @useResult
$Res call({
 DateTime periodStart, DateTime periodEnd, double taxableRevenue, double taxCollected, String currency, double taxRate, Map<String, double>? taxByJurisdiction, Map<String, double>? taxByCompany, Map<String, double>? taxByRevenueType, List<TaxTransaction>? transactions, String? notes, Map<String, dynamic>? metadata, DateTime? generatedAt
});




}
/// @nodoc
class __$TaxSummaryCopyWithImpl<$Res>
    implements _$TaxSummaryCopyWith<$Res> {
  __$TaxSummaryCopyWithImpl(this._self, this._then);

  final _TaxSummary _self;
  final $Res Function(_TaxSummary) _then;

/// Create a copy of TaxSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? periodStart = null,Object? periodEnd = null,Object? taxableRevenue = null,Object? taxCollected = null,Object? currency = null,Object? taxRate = null,Object? taxByJurisdiction = freezed,Object? taxByCompany = freezed,Object? taxByRevenueType = freezed,Object? transactions = freezed,Object? notes = freezed,Object? metadata = freezed,Object? generatedAt = freezed,}) {
  return _then(_TaxSummary(
periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,taxableRevenue: null == taxableRevenue ? _self.taxableRevenue : taxableRevenue // ignore: cast_nullable_to_non_nullable
as double,taxCollected: null == taxCollected ? _self.taxCollected : taxCollected // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,taxRate: null == taxRate ? _self.taxRate : taxRate // ignore: cast_nullable_to_non_nullable
as double,taxByJurisdiction: freezed == taxByJurisdiction ? _self._taxByJurisdiction : taxByJurisdiction // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,taxByCompany: freezed == taxByCompany ? _self._taxByCompany : taxByCompany // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,taxByRevenueType: freezed == taxByRevenueType ? _self._taxByRevenueType : taxByRevenueType // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,transactions: freezed == transactions ? _self._transactions : transactions // ignore: cast_nullable_to_non_nullable
as List<TaxTransaction>?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,generatedAt: freezed == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$TaxTransaction {

 String get id; DateTime get transactionDate; double get amount; double get taxAmount; String get currency; double get taxRate; String? get companyId; String? get invoiceId; RevenueType? get revenueType; String? get jurisdiction; String? get taxCode; String? get description; Map<String, dynamic>? get metadata; DateTime? get createdAt;
/// Create a copy of TaxTransaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaxTransactionCopyWith<TaxTransaction> get copyWith => _$TaxTransactionCopyWithImpl<TaxTransaction>(this as TaxTransaction, _$identity);

  /// Serializes this TaxTransaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaxTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.transactionDate, transactionDate) || other.transactionDate == transactionDate)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.taxAmount, taxAmount) || other.taxAmount == taxAmount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.taxRate, taxRate) || other.taxRate == taxRate)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.revenueType, revenueType) || other.revenueType == revenueType)&&(identical(other.jurisdiction, jurisdiction) || other.jurisdiction == jurisdiction)&&(identical(other.taxCode, taxCode) || other.taxCode == taxCode)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,transactionDate,amount,taxAmount,currency,taxRate,companyId,invoiceId,revenueType,jurisdiction,taxCode,description,const DeepCollectionEquality().hash(metadata),createdAt);

@override
String toString() {
  return 'TaxTransaction(id: $id, transactionDate: $transactionDate, amount: $amount, taxAmount: $taxAmount, currency: $currency, taxRate: $taxRate, companyId: $companyId, invoiceId: $invoiceId, revenueType: $revenueType, jurisdiction: $jurisdiction, taxCode: $taxCode, description: $description, metadata: $metadata, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $TaxTransactionCopyWith<$Res>  {
  factory $TaxTransactionCopyWith(TaxTransaction value, $Res Function(TaxTransaction) _then) = _$TaxTransactionCopyWithImpl;
@useResult
$Res call({
 String id, DateTime transactionDate, double amount, double taxAmount, String currency, double taxRate, String? companyId, String? invoiceId, RevenueType? revenueType, String? jurisdiction, String? taxCode, String? description, Map<String, dynamic>? metadata, DateTime? createdAt
});




}
/// @nodoc
class _$TaxTransactionCopyWithImpl<$Res>
    implements $TaxTransactionCopyWith<$Res> {
  _$TaxTransactionCopyWithImpl(this._self, this._then);

  final TaxTransaction _self;
  final $Res Function(TaxTransaction) _then;

/// Create a copy of TaxTransaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? transactionDate = null,Object? amount = null,Object? taxAmount = null,Object? currency = null,Object? taxRate = null,Object? companyId = freezed,Object? invoiceId = freezed,Object? revenueType = freezed,Object? jurisdiction = freezed,Object? taxCode = freezed,Object? description = freezed,Object? metadata = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,transactionDate: null == transactionDate ? _self.transactionDate : transactionDate // ignore: cast_nullable_to_non_nullable
as DateTime,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,taxAmount: null == taxAmount ? _self.taxAmount : taxAmount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,taxRate: null == taxRate ? _self.taxRate : taxRate // ignore: cast_nullable_to_non_nullable
as double,companyId: freezed == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String?,invoiceId: freezed == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String?,revenueType: freezed == revenueType ? _self.revenueType : revenueType // ignore: cast_nullable_to_non_nullable
as RevenueType?,jurisdiction: freezed == jurisdiction ? _self.jurisdiction : jurisdiction // ignore: cast_nullable_to_non_nullable
as String?,taxCode: freezed == taxCode ? _self.taxCode : taxCode // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [TaxTransaction].
extension TaxTransactionPatterns on TaxTransaction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaxTransaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaxTransaction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaxTransaction value)  $default,){
final _that = this;
switch (_that) {
case _TaxTransaction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaxTransaction value)?  $default,){
final _that = this;
switch (_that) {
case _TaxTransaction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime transactionDate,  double amount,  double taxAmount,  String currency,  double taxRate,  String? companyId,  String? invoiceId,  RevenueType? revenueType,  String? jurisdiction,  String? taxCode,  String? description,  Map<String, dynamic>? metadata,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaxTransaction() when $default != null:
return $default(_that.id,_that.transactionDate,_that.amount,_that.taxAmount,_that.currency,_that.taxRate,_that.companyId,_that.invoiceId,_that.revenueType,_that.jurisdiction,_that.taxCode,_that.description,_that.metadata,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime transactionDate,  double amount,  double taxAmount,  String currency,  double taxRate,  String? companyId,  String? invoiceId,  RevenueType? revenueType,  String? jurisdiction,  String? taxCode,  String? description,  Map<String, dynamic>? metadata,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _TaxTransaction():
return $default(_that.id,_that.transactionDate,_that.amount,_that.taxAmount,_that.currency,_that.taxRate,_that.companyId,_that.invoiceId,_that.revenueType,_that.jurisdiction,_that.taxCode,_that.description,_that.metadata,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime transactionDate,  double amount,  double taxAmount,  String currency,  double taxRate,  String? companyId,  String? invoiceId,  RevenueType? revenueType,  String? jurisdiction,  String? taxCode,  String? description,  Map<String, dynamic>? metadata,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _TaxTransaction() when $default != null:
return $default(_that.id,_that.transactionDate,_that.amount,_that.taxAmount,_that.currency,_that.taxRate,_that.companyId,_that.invoiceId,_that.revenueType,_that.jurisdiction,_that.taxCode,_that.description,_that.metadata,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TaxTransaction implements TaxTransaction {
  const _TaxTransaction({required this.id, required this.transactionDate, required this.amount, required this.taxAmount, required this.currency, required this.taxRate, this.companyId, this.invoiceId, this.revenueType, this.jurisdiction, this.taxCode, this.description, final  Map<String, dynamic>? metadata, this.createdAt}): _metadata = metadata;
  factory _TaxTransaction.fromJson(Map<String, dynamic> json) => _$TaxTransactionFromJson(json);

@override final  String id;
@override final  DateTime transactionDate;
@override final  double amount;
@override final  double taxAmount;
@override final  String currency;
@override final  double taxRate;
@override final  String? companyId;
@override final  String? invoiceId;
@override final  RevenueType? revenueType;
@override final  String? jurisdiction;
@override final  String? taxCode;
@override final  String? description;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  DateTime? createdAt;

/// Create a copy of TaxTransaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaxTransactionCopyWith<_TaxTransaction> get copyWith => __$TaxTransactionCopyWithImpl<_TaxTransaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaxTransactionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaxTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.transactionDate, transactionDate) || other.transactionDate == transactionDate)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.taxAmount, taxAmount) || other.taxAmount == taxAmount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.taxRate, taxRate) || other.taxRate == taxRate)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.revenueType, revenueType) || other.revenueType == revenueType)&&(identical(other.jurisdiction, jurisdiction) || other.jurisdiction == jurisdiction)&&(identical(other.taxCode, taxCode) || other.taxCode == taxCode)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,transactionDate,amount,taxAmount,currency,taxRate,companyId,invoiceId,revenueType,jurisdiction,taxCode,description,const DeepCollectionEquality().hash(_metadata),createdAt);

@override
String toString() {
  return 'TaxTransaction(id: $id, transactionDate: $transactionDate, amount: $amount, taxAmount: $taxAmount, currency: $currency, taxRate: $taxRate, companyId: $companyId, invoiceId: $invoiceId, revenueType: $revenueType, jurisdiction: $jurisdiction, taxCode: $taxCode, description: $description, metadata: $metadata, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$TaxTransactionCopyWith<$Res> implements $TaxTransactionCopyWith<$Res> {
  factory _$TaxTransactionCopyWith(_TaxTransaction value, $Res Function(_TaxTransaction) _then) = __$TaxTransactionCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime transactionDate, double amount, double taxAmount, String currency, double taxRate, String? companyId, String? invoiceId, RevenueType? revenueType, String? jurisdiction, String? taxCode, String? description, Map<String, dynamic>? metadata, DateTime? createdAt
});




}
/// @nodoc
class __$TaxTransactionCopyWithImpl<$Res>
    implements _$TaxTransactionCopyWith<$Res> {
  __$TaxTransactionCopyWithImpl(this._self, this._then);

  final _TaxTransaction _self;
  final $Res Function(_TaxTransaction) _then;

/// Create a copy of TaxTransaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? transactionDate = null,Object? amount = null,Object? taxAmount = null,Object? currency = null,Object? taxRate = null,Object? companyId = freezed,Object? invoiceId = freezed,Object? revenueType = freezed,Object? jurisdiction = freezed,Object? taxCode = freezed,Object? description = freezed,Object? metadata = freezed,Object? createdAt = freezed,}) {
  return _then(_TaxTransaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,transactionDate: null == transactionDate ? _self.transactionDate : transactionDate // ignore: cast_nullable_to_non_nullable
as DateTime,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,taxAmount: null == taxAmount ? _self.taxAmount : taxAmount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,taxRate: null == taxRate ? _self.taxRate : taxRate // ignore: cast_nullable_to_non_nullable
as double,companyId: freezed == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String?,invoiceId: freezed == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String?,revenueType: freezed == revenueType ? _self.revenueType : revenueType // ignore: cast_nullable_to_non_nullable
as RevenueType?,jurisdiction: freezed == jurisdiction ? _self.jurisdiction : jurisdiction // ignore: cast_nullable_to_non_nullable
as String?,taxCode: freezed == taxCode ? _self.taxCode : taxCode // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ReportFilter {

 DateTime? get startDate; DateTime? get endDate; List<RevenueType>? get revenueTypes; List<String>? get companyIds; List<String>? get planIds; List<String>? get regions; ReportPeriod? get period; String get sortBy; bool get sortDesc; int get page; int get limit;
/// Create a copy of ReportFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportFilterCopyWith<ReportFilter> get copyWith => _$ReportFilterCopyWithImpl<ReportFilter>(this as ReportFilter, _$identity);

  /// Serializes this ReportFilter to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportFilter&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other.revenueTypes, revenueTypes)&&const DeepCollectionEquality().equals(other.companyIds, companyIds)&&const DeepCollectionEquality().equals(other.planIds, planIds)&&const DeepCollectionEquality().equals(other.regions, regions)&&(identical(other.period, period) || other.period == period)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.sortDesc, sortDesc) || other.sortDesc == sortDesc)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startDate,endDate,const DeepCollectionEquality().hash(revenueTypes),const DeepCollectionEquality().hash(companyIds),const DeepCollectionEquality().hash(planIds),const DeepCollectionEquality().hash(regions),period,sortBy,sortDesc,page,limit);

@override
String toString() {
  return 'ReportFilter(startDate: $startDate, endDate: $endDate, revenueTypes: $revenueTypes, companyIds: $companyIds, planIds: $planIds, regions: $regions, period: $period, sortBy: $sortBy, sortDesc: $sortDesc, page: $page, limit: $limit)';
}


}

/// @nodoc
abstract mixin class $ReportFilterCopyWith<$Res>  {
  factory $ReportFilterCopyWith(ReportFilter value, $Res Function(ReportFilter) _then) = _$ReportFilterCopyWithImpl;
@useResult
$Res call({
 DateTime? startDate, DateTime? endDate, List<RevenueType>? revenueTypes, List<String>? companyIds, List<String>? planIds, List<String>? regions, ReportPeriod? period, String sortBy, bool sortDesc, int page, int limit
});




}
/// @nodoc
class _$ReportFilterCopyWithImpl<$Res>
    implements $ReportFilterCopyWith<$Res> {
  _$ReportFilterCopyWithImpl(this._self, this._then);

  final ReportFilter _self;
  final $Res Function(ReportFilter) _then;

/// Create a copy of ReportFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? startDate = freezed,Object? endDate = freezed,Object? revenueTypes = freezed,Object? companyIds = freezed,Object? planIds = freezed,Object? regions = freezed,Object? period = freezed,Object? sortBy = null,Object? sortDesc = null,Object? page = null,Object? limit = null,}) {
  return _then(_self.copyWith(
startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,revenueTypes: freezed == revenueTypes ? _self.revenueTypes : revenueTypes // ignore: cast_nullable_to_non_nullable
as List<RevenueType>?,companyIds: freezed == companyIds ? _self.companyIds : companyIds // ignore: cast_nullable_to_non_nullable
as List<String>?,planIds: freezed == planIds ? _self.planIds : planIds // ignore: cast_nullable_to_non_nullable
as List<String>?,regions: freezed == regions ? _self.regions : regions // ignore: cast_nullable_to_non_nullable
as List<String>?,period: freezed == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as ReportPeriod?,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as String,sortDesc: null == sortDesc ? _self.sortDesc : sortDesc // ignore: cast_nullable_to_non_nullable
as bool,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportFilter].
extension ReportFilterPatterns on ReportFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportFilter value)  $default,){
final _that = this;
switch (_that) {
case _ReportFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportFilter value)?  $default,){
final _that = this;
switch (_that) {
case _ReportFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime? startDate,  DateTime? endDate,  List<RevenueType>? revenueTypes,  List<String>? companyIds,  List<String>? planIds,  List<String>? regions,  ReportPeriod? period,  String sortBy,  bool sortDesc,  int page,  int limit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportFilter() when $default != null:
return $default(_that.startDate,_that.endDate,_that.revenueTypes,_that.companyIds,_that.planIds,_that.regions,_that.period,_that.sortBy,_that.sortDesc,_that.page,_that.limit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime? startDate,  DateTime? endDate,  List<RevenueType>? revenueTypes,  List<String>? companyIds,  List<String>? planIds,  List<String>? regions,  ReportPeriod? period,  String sortBy,  bool sortDesc,  int page,  int limit)  $default,) {final _that = this;
switch (_that) {
case _ReportFilter():
return $default(_that.startDate,_that.endDate,_that.revenueTypes,_that.companyIds,_that.planIds,_that.regions,_that.period,_that.sortBy,_that.sortDesc,_that.page,_that.limit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime? startDate,  DateTime? endDate,  List<RevenueType>? revenueTypes,  List<String>? companyIds,  List<String>? planIds,  List<String>? regions,  ReportPeriod? period,  String sortBy,  bool sortDesc,  int page,  int limit)?  $default,) {final _that = this;
switch (_that) {
case _ReportFilter() when $default != null:
return $default(_that.startDate,_that.endDate,_that.revenueTypes,_that.companyIds,_that.planIds,_that.regions,_that.period,_that.sortBy,_that.sortDesc,_that.page,_that.limit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReportFilter implements ReportFilter {
  const _ReportFilter({this.startDate, this.endDate, final  List<RevenueType>? revenueTypes, final  List<String>? companyIds, final  List<String>? planIds, final  List<String>? regions, this.period, this.sortBy = 'generatedAt', this.sortDesc = false, this.page = 1, this.limit = 20}): _revenueTypes = revenueTypes,_companyIds = companyIds,_planIds = planIds,_regions = regions;
  factory _ReportFilter.fromJson(Map<String, dynamic> json) => _$ReportFilterFromJson(json);

@override final  DateTime? startDate;
@override final  DateTime? endDate;
 final  List<RevenueType>? _revenueTypes;
@override List<RevenueType>? get revenueTypes {
  final value = _revenueTypes;
  if (value == null) return null;
  if (_revenueTypes is EqualUnmodifiableListView) return _revenueTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _companyIds;
@override List<String>? get companyIds {
  final value = _companyIds;
  if (value == null) return null;
  if (_companyIds is EqualUnmodifiableListView) return _companyIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _planIds;
@override List<String>? get planIds {
  final value = _planIds;
  if (value == null) return null;
  if (_planIds is EqualUnmodifiableListView) return _planIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _regions;
@override List<String>? get regions {
  final value = _regions;
  if (value == null) return null;
  if (_regions is EqualUnmodifiableListView) return _regions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  ReportPeriod? period;
@override@JsonKey() final  String sortBy;
@override@JsonKey() final  bool sortDesc;
@override@JsonKey() final  int page;
@override@JsonKey() final  int limit;

/// Create a copy of ReportFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportFilterCopyWith<_ReportFilter> get copyWith => __$ReportFilterCopyWithImpl<_ReportFilter>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportFilterToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportFilter&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other._revenueTypes, _revenueTypes)&&const DeepCollectionEquality().equals(other._companyIds, _companyIds)&&const DeepCollectionEquality().equals(other._planIds, _planIds)&&const DeepCollectionEquality().equals(other._regions, _regions)&&(identical(other.period, period) || other.period == period)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.sortDesc, sortDesc) || other.sortDesc == sortDesc)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startDate,endDate,const DeepCollectionEquality().hash(_revenueTypes),const DeepCollectionEquality().hash(_companyIds),const DeepCollectionEquality().hash(_planIds),const DeepCollectionEquality().hash(_regions),period,sortBy,sortDesc,page,limit);

@override
String toString() {
  return 'ReportFilter(startDate: $startDate, endDate: $endDate, revenueTypes: $revenueTypes, companyIds: $companyIds, planIds: $planIds, regions: $regions, period: $period, sortBy: $sortBy, sortDesc: $sortDesc, page: $page, limit: $limit)';
}


}

/// @nodoc
abstract mixin class _$ReportFilterCopyWith<$Res> implements $ReportFilterCopyWith<$Res> {
  factory _$ReportFilterCopyWith(_ReportFilter value, $Res Function(_ReportFilter) _then) = __$ReportFilterCopyWithImpl;
@override @useResult
$Res call({
 DateTime? startDate, DateTime? endDate, List<RevenueType>? revenueTypes, List<String>? companyIds, List<String>? planIds, List<String>? regions, ReportPeriod? period, String sortBy, bool sortDesc, int page, int limit
});




}
/// @nodoc
class __$ReportFilterCopyWithImpl<$Res>
    implements _$ReportFilterCopyWith<$Res> {
  __$ReportFilterCopyWithImpl(this._self, this._then);

  final _ReportFilter _self;
  final $Res Function(_ReportFilter) _then;

/// Create a copy of ReportFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? startDate = freezed,Object? endDate = freezed,Object? revenueTypes = freezed,Object? companyIds = freezed,Object? planIds = freezed,Object? regions = freezed,Object? period = freezed,Object? sortBy = null,Object? sortDesc = null,Object? page = null,Object? limit = null,}) {
  return _then(_ReportFilter(
startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,revenueTypes: freezed == revenueTypes ? _self._revenueTypes : revenueTypes // ignore: cast_nullable_to_non_nullable
as List<RevenueType>?,companyIds: freezed == companyIds ? _self._companyIds : companyIds // ignore: cast_nullable_to_non_nullable
as List<String>?,planIds: freezed == planIds ? _self._planIds : planIds // ignore: cast_nullable_to_non_nullable
as List<String>?,regions: freezed == regions ? _self._regions : regions // ignore: cast_nullable_to_non_nullable
as List<String>?,period: freezed == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as ReportPeriod?,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as String,sortDesc: null == sortDesc ? _self.sortDesc : sortDesc // ignore: cast_nullable_to_non_nullable
as bool,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ExportRequest {

 String get format; ReportFilter get filter; List<String>? get columns; bool get includeCharts; String? get fileName; Map<String, dynamic>? get options;
/// Create a copy of ExportRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExportRequestCopyWith<ExportRequest> get copyWith => _$ExportRequestCopyWithImpl<ExportRequest>(this as ExportRequest, _$identity);

  /// Serializes this ExportRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExportRequest&&(identical(other.format, format) || other.format == format)&&(identical(other.filter, filter) || other.filter == filter)&&const DeepCollectionEquality().equals(other.columns, columns)&&(identical(other.includeCharts, includeCharts) || other.includeCharts == includeCharts)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&const DeepCollectionEquality().equals(other.options, options));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,format,filter,const DeepCollectionEquality().hash(columns),includeCharts,fileName,const DeepCollectionEquality().hash(options));

@override
String toString() {
  return 'ExportRequest(format: $format, filter: $filter, columns: $columns, includeCharts: $includeCharts, fileName: $fileName, options: $options)';
}


}

/// @nodoc
abstract mixin class $ExportRequestCopyWith<$Res>  {
  factory $ExportRequestCopyWith(ExportRequest value, $Res Function(ExportRequest) _then) = _$ExportRequestCopyWithImpl;
@useResult
$Res call({
 String format, ReportFilter filter, List<String>? columns, bool includeCharts, String? fileName, Map<String, dynamic>? options
});


$ReportFilterCopyWith<$Res> get filter;

}
/// @nodoc
class _$ExportRequestCopyWithImpl<$Res>
    implements $ExportRequestCopyWith<$Res> {
  _$ExportRequestCopyWithImpl(this._self, this._then);

  final ExportRequest _self;
  final $Res Function(ExportRequest) _then;

/// Create a copy of ExportRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? format = null,Object? filter = null,Object? columns = freezed,Object? includeCharts = null,Object? fileName = freezed,Object? options = freezed,}) {
  return _then(_self.copyWith(
format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as ReportFilter,columns: freezed == columns ? _self.columns : columns // ignore: cast_nullable_to_non_nullable
as List<String>?,includeCharts: null == includeCharts ? _self.includeCharts : includeCharts // ignore: cast_nullable_to_non_nullable
as bool,fileName: freezed == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String?,options: freezed == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}
/// Create a copy of ExportRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReportFilterCopyWith<$Res> get filter {
  
  return $ReportFilterCopyWith<$Res>(_self.filter, (value) {
    return _then(_self.copyWith(filter: value));
  });
}
}


/// Adds pattern-matching-related methods to [ExportRequest].
extension ExportRequestPatterns on ExportRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExportRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExportRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExportRequest value)  $default,){
final _that = this;
switch (_that) {
case _ExportRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExportRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ExportRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String format,  ReportFilter filter,  List<String>? columns,  bool includeCharts,  String? fileName,  Map<String, dynamic>? options)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExportRequest() when $default != null:
return $default(_that.format,_that.filter,_that.columns,_that.includeCharts,_that.fileName,_that.options);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String format,  ReportFilter filter,  List<String>? columns,  bool includeCharts,  String? fileName,  Map<String, dynamic>? options)  $default,) {final _that = this;
switch (_that) {
case _ExportRequest():
return $default(_that.format,_that.filter,_that.columns,_that.includeCharts,_that.fileName,_that.options);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String format,  ReportFilter filter,  List<String>? columns,  bool includeCharts,  String? fileName,  Map<String, dynamic>? options)?  $default,) {final _that = this;
switch (_that) {
case _ExportRequest() when $default != null:
return $default(_that.format,_that.filter,_that.columns,_that.includeCharts,_that.fileName,_that.options);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExportRequest implements ExportRequest {
  const _ExportRequest({required this.format, required this.filter, final  List<String>? columns, this.includeCharts = false, this.fileName, final  Map<String, dynamic>? options}): _columns = columns,_options = options;
  factory _ExportRequest.fromJson(Map<String, dynamic> json) => _$ExportRequestFromJson(json);

@override final  String format;
@override final  ReportFilter filter;
 final  List<String>? _columns;
@override List<String>? get columns {
  final value = _columns;
  if (value == null) return null;
  if (_columns is EqualUnmodifiableListView) return _columns;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey() final  bool includeCharts;
@override final  String? fileName;
 final  Map<String, dynamic>? _options;
@override Map<String, dynamic>? get options {
  final value = _options;
  if (value == null) return null;
  if (_options is EqualUnmodifiableMapView) return _options;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of ExportRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExportRequestCopyWith<_ExportRequest> get copyWith => __$ExportRequestCopyWithImpl<_ExportRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExportRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExportRequest&&(identical(other.format, format) || other.format == format)&&(identical(other.filter, filter) || other.filter == filter)&&const DeepCollectionEquality().equals(other._columns, _columns)&&(identical(other.includeCharts, includeCharts) || other.includeCharts == includeCharts)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&const DeepCollectionEquality().equals(other._options, _options));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,format,filter,const DeepCollectionEquality().hash(_columns),includeCharts,fileName,const DeepCollectionEquality().hash(_options));

@override
String toString() {
  return 'ExportRequest(format: $format, filter: $filter, columns: $columns, includeCharts: $includeCharts, fileName: $fileName, options: $options)';
}


}

/// @nodoc
abstract mixin class _$ExportRequestCopyWith<$Res> implements $ExportRequestCopyWith<$Res> {
  factory _$ExportRequestCopyWith(_ExportRequest value, $Res Function(_ExportRequest) _then) = __$ExportRequestCopyWithImpl;
@override @useResult
$Res call({
 String format, ReportFilter filter, List<String>? columns, bool includeCharts, String? fileName, Map<String, dynamic>? options
});


@override $ReportFilterCopyWith<$Res> get filter;

}
/// @nodoc
class __$ExportRequestCopyWithImpl<$Res>
    implements _$ExportRequestCopyWith<$Res> {
  __$ExportRequestCopyWithImpl(this._self, this._then);

  final _ExportRequest _self;
  final $Res Function(_ExportRequest) _then;

/// Create a copy of ExportRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? format = null,Object? filter = null,Object? columns = freezed,Object? includeCharts = null,Object? fileName = freezed,Object? options = freezed,}) {
  return _then(_ExportRequest(
format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as ReportFilter,columns: freezed == columns ? _self._columns : columns // ignore: cast_nullable_to_non_nullable
as List<String>?,includeCharts: null == includeCharts ? _self.includeCharts : includeCharts // ignore: cast_nullable_to_non_nullable
as bool,fileName: freezed == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String?,options: freezed == options ? _self._options : options // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

/// Create a copy of ExportRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReportFilterCopyWith<$Res> get filter {
  
  return $ReportFilterCopyWith<$Res>(_self.filter, (value) {
    return _then(_self.copyWith(filter: value));
  });
}
}

// dart format on

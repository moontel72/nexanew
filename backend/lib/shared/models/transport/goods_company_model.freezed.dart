// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'goods_company_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GoodsCompanyModel {

 String get id; String get userId; String get companyName; String get ownerName; String get phone; String get email; String get cnic; String get address; GoodsCompanyPlanType get planType; GoodsCompanyStatus get status; VerificationStatus get verificationStatus; double get commissionMin; double get commissionMax; bool get autoCommissionEnabled; bool get liveTrackingEnabled; bool get biddingEnabled; bool get autoBiddingEnabled; bool get escrowEnabled; bool get whatsappIntegration; bool get whiteLabelEnabled; int get apiCallsToday; int get apiCallsLimit; int get totalTrucks; int get totalFactories; int get totalTrips; double get totalRevenue; double get rating; int get ratingCount; String? get logoUrl; String? get website; String? get taxNumber; String? get bankAccountNumber; String? get bankName; String? get verificationNotes; DateTime? get subscriptionStartDate; DateTime? get subscriptionEndDate; DateTime? get lastPaymentDate; DateTime get createdAt; DateTime? get updatedAt;
/// Create a copy of GoodsCompanyModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoodsCompanyModelCopyWith<GoodsCompanyModel> get copyWith => _$GoodsCompanyModelCopyWithImpl<GoodsCompanyModel>(this as GoodsCompanyModel, _$identity);

  /// Serializes this GoodsCompanyModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoodsCompanyModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.cnic, cnic) || other.cnic == cnic)&&(identical(other.address, address) || other.address == address)&&(identical(other.planType, planType) || other.planType == planType)&&(identical(other.status, status) || other.status == status)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.commissionMin, commissionMin) || other.commissionMin == commissionMin)&&(identical(other.commissionMax, commissionMax) || other.commissionMax == commissionMax)&&(identical(other.autoCommissionEnabled, autoCommissionEnabled) || other.autoCommissionEnabled == autoCommissionEnabled)&&(identical(other.liveTrackingEnabled, liveTrackingEnabled) || other.liveTrackingEnabled == liveTrackingEnabled)&&(identical(other.biddingEnabled, biddingEnabled) || other.biddingEnabled == biddingEnabled)&&(identical(other.autoBiddingEnabled, autoBiddingEnabled) || other.autoBiddingEnabled == autoBiddingEnabled)&&(identical(other.escrowEnabled, escrowEnabled) || other.escrowEnabled == escrowEnabled)&&(identical(other.whatsappIntegration, whatsappIntegration) || other.whatsappIntegration == whatsappIntegration)&&(identical(other.whiteLabelEnabled, whiteLabelEnabled) || other.whiteLabelEnabled == whiteLabelEnabled)&&(identical(other.apiCallsToday, apiCallsToday) || other.apiCallsToday == apiCallsToday)&&(identical(other.apiCallsLimit, apiCallsLimit) || other.apiCallsLimit == apiCallsLimit)&&(identical(other.totalTrucks, totalTrucks) || other.totalTrucks == totalTrucks)&&(identical(other.totalFactories, totalFactories) || other.totalFactories == totalFactories)&&(identical(other.totalTrips, totalTrips) || other.totalTrips == totalTrips)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.ratingCount, ratingCount) || other.ratingCount == ratingCount)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.website, website) || other.website == website)&&(identical(other.taxNumber, taxNumber) || other.taxNumber == taxNumber)&&(identical(other.bankAccountNumber, bankAccountNumber) || other.bankAccountNumber == bankAccountNumber)&&(identical(other.bankName, bankName) || other.bankName == bankName)&&(identical(other.verificationNotes, verificationNotes) || other.verificationNotes == verificationNotes)&&(identical(other.subscriptionStartDate, subscriptionStartDate) || other.subscriptionStartDate == subscriptionStartDate)&&(identical(other.subscriptionEndDate, subscriptionEndDate) || other.subscriptionEndDate == subscriptionEndDate)&&(identical(other.lastPaymentDate, lastPaymentDate) || other.lastPaymentDate == lastPaymentDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,companyName,ownerName,phone,email,cnic,address,planType,status,verificationStatus,commissionMin,commissionMax,autoCommissionEnabled,liveTrackingEnabled,biddingEnabled,autoBiddingEnabled,escrowEnabled,whatsappIntegration,whiteLabelEnabled,apiCallsToday,apiCallsLimit,totalTrucks,totalFactories,totalTrips,totalRevenue,rating,ratingCount,logoUrl,website,taxNumber,bankAccountNumber,bankName,verificationNotes,subscriptionStartDate,subscriptionEndDate,lastPaymentDate,createdAt,updatedAt]);

@override
String toString() {
  return 'GoodsCompanyModel(id: $id, userId: $userId, companyName: $companyName, ownerName: $ownerName, phone: $phone, email: $email, cnic: $cnic, address: $address, planType: $planType, status: $status, verificationStatus: $verificationStatus, commissionMin: $commissionMin, commissionMax: $commissionMax, autoCommissionEnabled: $autoCommissionEnabled, liveTrackingEnabled: $liveTrackingEnabled, biddingEnabled: $biddingEnabled, autoBiddingEnabled: $autoBiddingEnabled, escrowEnabled: $escrowEnabled, whatsappIntegration: $whatsappIntegration, whiteLabelEnabled: $whiteLabelEnabled, apiCallsToday: $apiCallsToday, apiCallsLimit: $apiCallsLimit, totalTrucks: $totalTrucks, totalFactories: $totalFactories, totalTrips: $totalTrips, totalRevenue: $totalRevenue, rating: $rating, ratingCount: $ratingCount, logoUrl: $logoUrl, website: $website, taxNumber: $taxNumber, bankAccountNumber: $bankAccountNumber, bankName: $bankName, verificationNotes: $verificationNotes, subscriptionStartDate: $subscriptionStartDate, subscriptionEndDate: $subscriptionEndDate, lastPaymentDate: $lastPaymentDate, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $GoodsCompanyModelCopyWith<$Res>  {
  factory $GoodsCompanyModelCopyWith(GoodsCompanyModel value, $Res Function(GoodsCompanyModel) _then) = _$GoodsCompanyModelCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String companyName, String ownerName, String phone, String email, String cnic, String address, GoodsCompanyPlanType planType, GoodsCompanyStatus status, VerificationStatus verificationStatus, double commissionMin, double commissionMax, bool autoCommissionEnabled, bool liveTrackingEnabled, bool biddingEnabled, bool autoBiddingEnabled, bool escrowEnabled, bool whatsappIntegration, bool whiteLabelEnabled, int apiCallsToday, int apiCallsLimit, int totalTrucks, int totalFactories, int totalTrips, double totalRevenue, double rating, int ratingCount, String? logoUrl, String? website, String? taxNumber, String? bankAccountNumber, String? bankName, String? verificationNotes, DateTime? subscriptionStartDate, DateTime? subscriptionEndDate, DateTime? lastPaymentDate, DateTime createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$GoodsCompanyModelCopyWithImpl<$Res>
    implements $GoodsCompanyModelCopyWith<$Res> {
  _$GoodsCompanyModelCopyWithImpl(this._self, this._then);

  final GoodsCompanyModel _self;
  final $Res Function(GoodsCompanyModel) _then;

/// Create a copy of GoodsCompanyModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? companyName = null,Object? ownerName = null,Object? phone = null,Object? email = null,Object? cnic = null,Object? address = null,Object? planType = null,Object? status = null,Object? verificationStatus = null,Object? commissionMin = null,Object? commissionMax = null,Object? autoCommissionEnabled = null,Object? liveTrackingEnabled = null,Object? biddingEnabled = null,Object? autoBiddingEnabled = null,Object? escrowEnabled = null,Object? whatsappIntegration = null,Object? whiteLabelEnabled = null,Object? apiCallsToday = null,Object? apiCallsLimit = null,Object? totalTrucks = null,Object? totalFactories = null,Object? totalTrips = null,Object? totalRevenue = null,Object? rating = null,Object? ratingCount = null,Object? logoUrl = freezed,Object? website = freezed,Object? taxNumber = freezed,Object? bankAccountNumber = freezed,Object? bankName = freezed,Object? verificationNotes = freezed,Object? subscriptionStartDate = freezed,Object? subscriptionEndDate = freezed,Object? lastPaymentDate = freezed,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,companyName: null == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,cnic: null == cnic ? _self.cnic : cnic // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,planType: null == planType ? _self.planType : planType // ignore: cast_nullable_to_non_nullable
as GoodsCompanyPlanType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GoodsCompanyStatus,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as VerificationStatus,commissionMin: null == commissionMin ? _self.commissionMin : commissionMin // ignore: cast_nullable_to_non_nullable
as double,commissionMax: null == commissionMax ? _self.commissionMax : commissionMax // ignore: cast_nullable_to_non_nullable
as double,autoCommissionEnabled: null == autoCommissionEnabled ? _self.autoCommissionEnabled : autoCommissionEnabled // ignore: cast_nullable_to_non_nullable
as bool,liveTrackingEnabled: null == liveTrackingEnabled ? _self.liveTrackingEnabled : liveTrackingEnabled // ignore: cast_nullable_to_non_nullable
as bool,biddingEnabled: null == biddingEnabled ? _self.biddingEnabled : biddingEnabled // ignore: cast_nullable_to_non_nullable
as bool,autoBiddingEnabled: null == autoBiddingEnabled ? _self.autoBiddingEnabled : autoBiddingEnabled // ignore: cast_nullable_to_non_nullable
as bool,escrowEnabled: null == escrowEnabled ? _self.escrowEnabled : escrowEnabled // ignore: cast_nullable_to_non_nullable
as bool,whatsappIntegration: null == whatsappIntegration ? _self.whatsappIntegration : whatsappIntegration // ignore: cast_nullable_to_non_nullable
as bool,whiteLabelEnabled: null == whiteLabelEnabled ? _self.whiteLabelEnabled : whiteLabelEnabled // ignore: cast_nullable_to_non_nullable
as bool,apiCallsToday: null == apiCallsToday ? _self.apiCallsToday : apiCallsToday // ignore: cast_nullable_to_non_nullable
as int,apiCallsLimit: null == apiCallsLimit ? _self.apiCallsLimit : apiCallsLimit // ignore: cast_nullable_to_non_nullable
as int,totalTrucks: null == totalTrucks ? _self.totalTrucks : totalTrucks // ignore: cast_nullable_to_non_nullable
as int,totalFactories: null == totalFactories ? _self.totalFactories : totalFactories // ignore: cast_nullable_to_non_nullable
as int,totalTrips: null == totalTrips ? _self.totalTrips : totalTrips // ignore: cast_nullable_to_non_nullable
as int,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,ratingCount: null == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,taxNumber: freezed == taxNumber ? _self.taxNumber : taxNumber // ignore: cast_nullable_to_non_nullable
as String?,bankAccountNumber: freezed == bankAccountNumber ? _self.bankAccountNumber : bankAccountNumber // ignore: cast_nullable_to_non_nullable
as String?,bankName: freezed == bankName ? _self.bankName : bankName // ignore: cast_nullable_to_non_nullable
as String?,verificationNotes: freezed == verificationNotes ? _self.verificationNotes : verificationNotes // ignore: cast_nullable_to_non_nullable
as String?,subscriptionStartDate: freezed == subscriptionStartDate ? _self.subscriptionStartDate : subscriptionStartDate // ignore: cast_nullable_to_non_nullable
as DateTime?,subscriptionEndDate: freezed == subscriptionEndDate ? _self.subscriptionEndDate : subscriptionEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,lastPaymentDate: freezed == lastPaymentDate ? _self.lastPaymentDate : lastPaymentDate // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [GoodsCompanyModel].
extension GoodsCompanyModelPatterns on GoodsCompanyModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoodsCompanyModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoodsCompanyModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoodsCompanyModel value)  $default,){
final _that = this;
switch (_that) {
case _GoodsCompanyModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoodsCompanyModel value)?  $default,){
final _that = this;
switch (_that) {
case _GoodsCompanyModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String companyName,  String ownerName,  String phone,  String email,  String cnic,  String address,  GoodsCompanyPlanType planType,  GoodsCompanyStatus status,  VerificationStatus verificationStatus,  double commissionMin,  double commissionMax,  bool autoCommissionEnabled,  bool liveTrackingEnabled,  bool biddingEnabled,  bool autoBiddingEnabled,  bool escrowEnabled,  bool whatsappIntegration,  bool whiteLabelEnabled,  int apiCallsToday,  int apiCallsLimit,  int totalTrucks,  int totalFactories,  int totalTrips,  double totalRevenue,  double rating,  int ratingCount,  String? logoUrl,  String? website,  String? taxNumber,  String? bankAccountNumber,  String? bankName,  String? verificationNotes,  DateTime? subscriptionStartDate,  DateTime? subscriptionEndDate,  DateTime? lastPaymentDate,  DateTime createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoodsCompanyModel() when $default != null:
return $default(_that.id,_that.userId,_that.companyName,_that.ownerName,_that.phone,_that.email,_that.cnic,_that.address,_that.planType,_that.status,_that.verificationStatus,_that.commissionMin,_that.commissionMax,_that.autoCommissionEnabled,_that.liveTrackingEnabled,_that.biddingEnabled,_that.autoBiddingEnabled,_that.escrowEnabled,_that.whatsappIntegration,_that.whiteLabelEnabled,_that.apiCallsToday,_that.apiCallsLimit,_that.totalTrucks,_that.totalFactories,_that.totalTrips,_that.totalRevenue,_that.rating,_that.ratingCount,_that.logoUrl,_that.website,_that.taxNumber,_that.bankAccountNumber,_that.bankName,_that.verificationNotes,_that.subscriptionStartDate,_that.subscriptionEndDate,_that.lastPaymentDate,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String companyName,  String ownerName,  String phone,  String email,  String cnic,  String address,  GoodsCompanyPlanType planType,  GoodsCompanyStatus status,  VerificationStatus verificationStatus,  double commissionMin,  double commissionMax,  bool autoCommissionEnabled,  bool liveTrackingEnabled,  bool biddingEnabled,  bool autoBiddingEnabled,  bool escrowEnabled,  bool whatsappIntegration,  bool whiteLabelEnabled,  int apiCallsToday,  int apiCallsLimit,  int totalTrucks,  int totalFactories,  int totalTrips,  double totalRevenue,  double rating,  int ratingCount,  String? logoUrl,  String? website,  String? taxNumber,  String? bankAccountNumber,  String? bankName,  String? verificationNotes,  DateTime? subscriptionStartDate,  DateTime? subscriptionEndDate,  DateTime? lastPaymentDate,  DateTime createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _GoodsCompanyModel():
return $default(_that.id,_that.userId,_that.companyName,_that.ownerName,_that.phone,_that.email,_that.cnic,_that.address,_that.planType,_that.status,_that.verificationStatus,_that.commissionMin,_that.commissionMax,_that.autoCommissionEnabled,_that.liveTrackingEnabled,_that.biddingEnabled,_that.autoBiddingEnabled,_that.escrowEnabled,_that.whatsappIntegration,_that.whiteLabelEnabled,_that.apiCallsToday,_that.apiCallsLimit,_that.totalTrucks,_that.totalFactories,_that.totalTrips,_that.totalRevenue,_that.rating,_that.ratingCount,_that.logoUrl,_that.website,_that.taxNumber,_that.bankAccountNumber,_that.bankName,_that.verificationNotes,_that.subscriptionStartDate,_that.subscriptionEndDate,_that.lastPaymentDate,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String companyName,  String ownerName,  String phone,  String email,  String cnic,  String address,  GoodsCompanyPlanType planType,  GoodsCompanyStatus status,  VerificationStatus verificationStatus,  double commissionMin,  double commissionMax,  bool autoCommissionEnabled,  bool liveTrackingEnabled,  bool biddingEnabled,  bool autoBiddingEnabled,  bool escrowEnabled,  bool whatsappIntegration,  bool whiteLabelEnabled,  int apiCallsToday,  int apiCallsLimit,  int totalTrucks,  int totalFactories,  int totalTrips,  double totalRevenue,  double rating,  int ratingCount,  String? logoUrl,  String? website,  String? taxNumber,  String? bankAccountNumber,  String? bankName,  String? verificationNotes,  DateTime? subscriptionStartDate,  DateTime? subscriptionEndDate,  DateTime? lastPaymentDate,  DateTime createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _GoodsCompanyModel() when $default != null:
return $default(_that.id,_that.userId,_that.companyName,_that.ownerName,_that.phone,_that.email,_that.cnic,_that.address,_that.planType,_that.status,_that.verificationStatus,_that.commissionMin,_that.commissionMax,_that.autoCommissionEnabled,_that.liveTrackingEnabled,_that.biddingEnabled,_that.autoBiddingEnabled,_that.escrowEnabled,_that.whatsappIntegration,_that.whiteLabelEnabled,_that.apiCallsToday,_that.apiCallsLimit,_that.totalTrucks,_that.totalFactories,_that.totalTrips,_that.totalRevenue,_that.rating,_that.ratingCount,_that.logoUrl,_that.website,_that.taxNumber,_that.bankAccountNumber,_that.bankName,_that.verificationNotes,_that.subscriptionStartDate,_that.subscriptionEndDate,_that.lastPaymentDate,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GoodsCompanyModel extends GoodsCompanyModel {
  const _GoodsCompanyModel({required this.id, required this.userId, required this.companyName, required this.ownerName, required this.phone, required this.email, required this.cnic, required this.address, required this.planType, this.status = GoodsCompanyStatus.pending, this.verificationStatus = VerificationStatus.pending, this.commissionMin = 0.0, this.commissionMax = 15.0, this.autoCommissionEnabled = false, this.liveTrackingEnabled = true, this.biddingEnabled = true, this.autoBiddingEnabled = false, this.escrowEnabled = false, this.whatsappIntegration = false, this.whiteLabelEnabled = false, this.apiCallsToday = 0, this.apiCallsLimit = 1000, this.totalTrucks = 0, this.totalFactories = 0, this.totalTrips = 0, this.totalRevenue = 0.0, this.rating = 0.0, this.ratingCount = 0, this.logoUrl, this.website, this.taxNumber, this.bankAccountNumber, this.bankName, this.verificationNotes, this.subscriptionStartDate, this.subscriptionEndDate, this.lastPaymentDate, required this.createdAt, this.updatedAt}): super._();
  factory _GoodsCompanyModel.fromJson(Map<String, dynamic> json) => _$GoodsCompanyModelFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String companyName;
@override final  String ownerName;
@override final  String phone;
@override final  String email;
@override final  String cnic;
@override final  String address;
@override final  GoodsCompanyPlanType planType;
@override@JsonKey() final  GoodsCompanyStatus status;
@override@JsonKey() final  VerificationStatus verificationStatus;
@override@JsonKey() final  double commissionMin;
@override@JsonKey() final  double commissionMax;
@override@JsonKey() final  bool autoCommissionEnabled;
@override@JsonKey() final  bool liveTrackingEnabled;
@override@JsonKey() final  bool biddingEnabled;
@override@JsonKey() final  bool autoBiddingEnabled;
@override@JsonKey() final  bool escrowEnabled;
@override@JsonKey() final  bool whatsappIntegration;
@override@JsonKey() final  bool whiteLabelEnabled;
@override@JsonKey() final  int apiCallsToday;
@override@JsonKey() final  int apiCallsLimit;
@override@JsonKey() final  int totalTrucks;
@override@JsonKey() final  int totalFactories;
@override@JsonKey() final  int totalTrips;
@override@JsonKey() final  double totalRevenue;
@override@JsonKey() final  double rating;
@override@JsonKey() final  int ratingCount;
@override final  String? logoUrl;
@override final  String? website;
@override final  String? taxNumber;
@override final  String? bankAccountNumber;
@override final  String? bankName;
@override final  String? verificationNotes;
@override final  DateTime? subscriptionStartDate;
@override final  DateTime? subscriptionEndDate;
@override final  DateTime? lastPaymentDate;
@override final  DateTime createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of GoodsCompanyModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoodsCompanyModelCopyWith<_GoodsCompanyModel> get copyWith => __$GoodsCompanyModelCopyWithImpl<_GoodsCompanyModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GoodsCompanyModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoodsCompanyModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.cnic, cnic) || other.cnic == cnic)&&(identical(other.address, address) || other.address == address)&&(identical(other.planType, planType) || other.planType == planType)&&(identical(other.status, status) || other.status == status)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.commissionMin, commissionMin) || other.commissionMin == commissionMin)&&(identical(other.commissionMax, commissionMax) || other.commissionMax == commissionMax)&&(identical(other.autoCommissionEnabled, autoCommissionEnabled) || other.autoCommissionEnabled == autoCommissionEnabled)&&(identical(other.liveTrackingEnabled, liveTrackingEnabled) || other.liveTrackingEnabled == liveTrackingEnabled)&&(identical(other.biddingEnabled, biddingEnabled) || other.biddingEnabled == biddingEnabled)&&(identical(other.autoBiddingEnabled, autoBiddingEnabled) || other.autoBiddingEnabled == autoBiddingEnabled)&&(identical(other.escrowEnabled, escrowEnabled) || other.escrowEnabled == escrowEnabled)&&(identical(other.whatsappIntegration, whatsappIntegration) || other.whatsappIntegration == whatsappIntegration)&&(identical(other.whiteLabelEnabled, whiteLabelEnabled) || other.whiteLabelEnabled == whiteLabelEnabled)&&(identical(other.apiCallsToday, apiCallsToday) || other.apiCallsToday == apiCallsToday)&&(identical(other.apiCallsLimit, apiCallsLimit) || other.apiCallsLimit == apiCallsLimit)&&(identical(other.totalTrucks, totalTrucks) || other.totalTrucks == totalTrucks)&&(identical(other.totalFactories, totalFactories) || other.totalFactories == totalFactories)&&(identical(other.totalTrips, totalTrips) || other.totalTrips == totalTrips)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.ratingCount, ratingCount) || other.ratingCount == ratingCount)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.website, website) || other.website == website)&&(identical(other.taxNumber, taxNumber) || other.taxNumber == taxNumber)&&(identical(other.bankAccountNumber, bankAccountNumber) || other.bankAccountNumber == bankAccountNumber)&&(identical(other.bankName, bankName) || other.bankName == bankName)&&(identical(other.verificationNotes, verificationNotes) || other.verificationNotes == verificationNotes)&&(identical(other.subscriptionStartDate, subscriptionStartDate) || other.subscriptionStartDate == subscriptionStartDate)&&(identical(other.subscriptionEndDate, subscriptionEndDate) || other.subscriptionEndDate == subscriptionEndDate)&&(identical(other.lastPaymentDate, lastPaymentDate) || other.lastPaymentDate == lastPaymentDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,companyName,ownerName,phone,email,cnic,address,planType,status,verificationStatus,commissionMin,commissionMax,autoCommissionEnabled,liveTrackingEnabled,biddingEnabled,autoBiddingEnabled,escrowEnabled,whatsappIntegration,whiteLabelEnabled,apiCallsToday,apiCallsLimit,totalTrucks,totalFactories,totalTrips,totalRevenue,rating,ratingCount,logoUrl,website,taxNumber,bankAccountNumber,bankName,verificationNotes,subscriptionStartDate,subscriptionEndDate,lastPaymentDate,createdAt,updatedAt]);

@override
String toString() {
  return 'GoodsCompanyModel(id: $id, userId: $userId, companyName: $companyName, ownerName: $ownerName, phone: $phone, email: $email, cnic: $cnic, address: $address, planType: $planType, status: $status, verificationStatus: $verificationStatus, commissionMin: $commissionMin, commissionMax: $commissionMax, autoCommissionEnabled: $autoCommissionEnabled, liveTrackingEnabled: $liveTrackingEnabled, biddingEnabled: $biddingEnabled, autoBiddingEnabled: $autoBiddingEnabled, escrowEnabled: $escrowEnabled, whatsappIntegration: $whatsappIntegration, whiteLabelEnabled: $whiteLabelEnabled, apiCallsToday: $apiCallsToday, apiCallsLimit: $apiCallsLimit, totalTrucks: $totalTrucks, totalFactories: $totalFactories, totalTrips: $totalTrips, totalRevenue: $totalRevenue, rating: $rating, ratingCount: $ratingCount, logoUrl: $logoUrl, website: $website, taxNumber: $taxNumber, bankAccountNumber: $bankAccountNumber, bankName: $bankName, verificationNotes: $verificationNotes, subscriptionStartDate: $subscriptionStartDate, subscriptionEndDate: $subscriptionEndDate, lastPaymentDate: $lastPaymentDate, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$GoodsCompanyModelCopyWith<$Res> implements $GoodsCompanyModelCopyWith<$Res> {
  factory _$GoodsCompanyModelCopyWith(_GoodsCompanyModel value, $Res Function(_GoodsCompanyModel) _then) = __$GoodsCompanyModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String companyName, String ownerName, String phone, String email, String cnic, String address, GoodsCompanyPlanType planType, GoodsCompanyStatus status, VerificationStatus verificationStatus, double commissionMin, double commissionMax, bool autoCommissionEnabled, bool liveTrackingEnabled, bool biddingEnabled, bool autoBiddingEnabled, bool escrowEnabled, bool whatsappIntegration, bool whiteLabelEnabled, int apiCallsToday, int apiCallsLimit, int totalTrucks, int totalFactories, int totalTrips, double totalRevenue, double rating, int ratingCount, String? logoUrl, String? website, String? taxNumber, String? bankAccountNumber, String? bankName, String? verificationNotes, DateTime? subscriptionStartDate, DateTime? subscriptionEndDate, DateTime? lastPaymentDate, DateTime createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$GoodsCompanyModelCopyWithImpl<$Res>
    implements _$GoodsCompanyModelCopyWith<$Res> {
  __$GoodsCompanyModelCopyWithImpl(this._self, this._then);

  final _GoodsCompanyModel _self;
  final $Res Function(_GoodsCompanyModel) _then;

/// Create a copy of GoodsCompanyModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? companyName = null,Object? ownerName = null,Object? phone = null,Object? email = null,Object? cnic = null,Object? address = null,Object? planType = null,Object? status = null,Object? verificationStatus = null,Object? commissionMin = null,Object? commissionMax = null,Object? autoCommissionEnabled = null,Object? liveTrackingEnabled = null,Object? biddingEnabled = null,Object? autoBiddingEnabled = null,Object? escrowEnabled = null,Object? whatsappIntegration = null,Object? whiteLabelEnabled = null,Object? apiCallsToday = null,Object? apiCallsLimit = null,Object? totalTrucks = null,Object? totalFactories = null,Object? totalTrips = null,Object? totalRevenue = null,Object? rating = null,Object? ratingCount = null,Object? logoUrl = freezed,Object? website = freezed,Object? taxNumber = freezed,Object? bankAccountNumber = freezed,Object? bankName = freezed,Object? verificationNotes = freezed,Object? subscriptionStartDate = freezed,Object? subscriptionEndDate = freezed,Object? lastPaymentDate = freezed,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_GoodsCompanyModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,companyName: null == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,cnic: null == cnic ? _self.cnic : cnic // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,planType: null == planType ? _self.planType : planType // ignore: cast_nullable_to_non_nullable
as GoodsCompanyPlanType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GoodsCompanyStatus,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as VerificationStatus,commissionMin: null == commissionMin ? _self.commissionMin : commissionMin // ignore: cast_nullable_to_non_nullable
as double,commissionMax: null == commissionMax ? _self.commissionMax : commissionMax // ignore: cast_nullable_to_non_nullable
as double,autoCommissionEnabled: null == autoCommissionEnabled ? _self.autoCommissionEnabled : autoCommissionEnabled // ignore: cast_nullable_to_non_nullable
as bool,liveTrackingEnabled: null == liveTrackingEnabled ? _self.liveTrackingEnabled : liveTrackingEnabled // ignore: cast_nullable_to_non_nullable
as bool,biddingEnabled: null == biddingEnabled ? _self.biddingEnabled : biddingEnabled // ignore: cast_nullable_to_non_nullable
as bool,autoBiddingEnabled: null == autoBiddingEnabled ? _self.autoBiddingEnabled : autoBiddingEnabled // ignore: cast_nullable_to_non_nullable
as bool,escrowEnabled: null == escrowEnabled ? _self.escrowEnabled : escrowEnabled // ignore: cast_nullable_to_non_nullable
as bool,whatsappIntegration: null == whatsappIntegration ? _self.whatsappIntegration : whatsappIntegration // ignore: cast_nullable_to_non_nullable
as bool,whiteLabelEnabled: null == whiteLabelEnabled ? _self.whiteLabelEnabled : whiteLabelEnabled // ignore: cast_nullable_to_non_nullable
as bool,apiCallsToday: null == apiCallsToday ? _self.apiCallsToday : apiCallsToday // ignore: cast_nullable_to_non_nullable
as int,apiCallsLimit: null == apiCallsLimit ? _self.apiCallsLimit : apiCallsLimit // ignore: cast_nullable_to_non_nullable
as int,totalTrucks: null == totalTrucks ? _self.totalTrucks : totalTrucks // ignore: cast_nullable_to_non_nullable
as int,totalFactories: null == totalFactories ? _self.totalFactories : totalFactories // ignore: cast_nullable_to_non_nullable
as int,totalTrips: null == totalTrips ? _self.totalTrips : totalTrips // ignore: cast_nullable_to_non_nullable
as int,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,ratingCount: null == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,taxNumber: freezed == taxNumber ? _self.taxNumber : taxNumber // ignore: cast_nullable_to_non_nullable
as String?,bankAccountNumber: freezed == bankAccountNumber ? _self.bankAccountNumber : bankAccountNumber // ignore: cast_nullable_to_non_nullable
as String?,bankName: freezed == bankName ? _self.bankName : bankName // ignore: cast_nullable_to_non_nullable
as String?,verificationNotes: freezed == verificationNotes ? _self.verificationNotes : verificationNotes // ignore: cast_nullable_to_non_nullable
as String?,subscriptionStartDate: freezed == subscriptionStartDate ? _self.subscriptionStartDate : subscriptionStartDate // ignore: cast_nullable_to_non_nullable
as DateTime?,subscriptionEndDate: freezed == subscriptionEndDate ? _self.subscriptionEndDate : subscriptionEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,lastPaymentDate: freezed == lastPaymentDate ? _self.lastPaymentDate : lastPaymentDate // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$GoodsCompanySubscription {

 String get id; String get companyId; GoodsCompanyPlanType get planType; DateTime get startDate; DateTime get endDate; double get amount; String get paymentMethod; String get paymentReference; bool get isAutoRenew; bool get isPaid; String? get invoiceUrl; DateTime? get paidAt; DateTime? get cancelledAt; String? get cancellationReason; DateTime get createdAt;
/// Create a copy of GoodsCompanySubscription
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoodsCompanySubscriptionCopyWith<GoodsCompanySubscription> get copyWith => _$GoodsCompanySubscriptionCopyWithImpl<GoodsCompanySubscription>(this as GoodsCompanySubscription, _$identity);

  /// Serializes this GoodsCompanySubscription to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoodsCompanySubscription&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.planType, planType) || other.planType == planType)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.paymentReference, paymentReference) || other.paymentReference == paymentReference)&&(identical(other.isAutoRenew, isAutoRenew) || other.isAutoRenew == isAutoRenew)&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid)&&(identical(other.invoiceUrl, invoiceUrl) || other.invoiceUrl == invoiceUrl)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.cancellationReason, cancellationReason) || other.cancellationReason == cancellationReason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,companyId,planType,startDate,endDate,amount,paymentMethod,paymentReference,isAutoRenew,isPaid,invoiceUrl,paidAt,cancelledAt,cancellationReason,createdAt);

@override
String toString() {
  return 'GoodsCompanySubscription(id: $id, companyId: $companyId, planType: $planType, startDate: $startDate, endDate: $endDate, amount: $amount, paymentMethod: $paymentMethod, paymentReference: $paymentReference, isAutoRenew: $isAutoRenew, isPaid: $isPaid, invoiceUrl: $invoiceUrl, paidAt: $paidAt, cancelledAt: $cancelledAt, cancellationReason: $cancellationReason, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $GoodsCompanySubscriptionCopyWith<$Res>  {
  factory $GoodsCompanySubscriptionCopyWith(GoodsCompanySubscription value, $Res Function(GoodsCompanySubscription) _then) = _$GoodsCompanySubscriptionCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, GoodsCompanyPlanType planType, DateTime startDate, DateTime endDate, double amount, String paymentMethod, String paymentReference, bool isAutoRenew, bool isPaid, String? invoiceUrl, DateTime? paidAt, DateTime? cancelledAt, String? cancellationReason, DateTime createdAt
});




}
/// @nodoc
class _$GoodsCompanySubscriptionCopyWithImpl<$Res>
    implements $GoodsCompanySubscriptionCopyWith<$Res> {
  _$GoodsCompanySubscriptionCopyWithImpl(this._self, this._then);

  final GoodsCompanySubscription _self;
  final $Res Function(GoodsCompanySubscription) _then;

/// Create a copy of GoodsCompanySubscription
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? planType = null,Object? startDate = null,Object? endDate = null,Object? amount = null,Object? paymentMethod = null,Object? paymentReference = null,Object? isAutoRenew = null,Object? isPaid = null,Object? invoiceUrl = freezed,Object? paidAt = freezed,Object? cancelledAt = freezed,Object? cancellationReason = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,planType: null == planType ? _self.planType : planType // ignore: cast_nullable_to_non_nullable
as GoodsCompanyPlanType,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String,paymentReference: null == paymentReference ? _self.paymentReference : paymentReference // ignore: cast_nullable_to_non_nullable
as String,isAutoRenew: null == isAutoRenew ? _self.isAutoRenew : isAutoRenew // ignore: cast_nullable_to_non_nullable
as bool,isPaid: null == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool,invoiceUrl: freezed == invoiceUrl ? _self.invoiceUrl : invoiceUrl // ignore: cast_nullable_to_non_nullable
as String?,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancellationReason: freezed == cancellationReason ? _self.cancellationReason : cancellationReason // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [GoodsCompanySubscription].
extension GoodsCompanySubscriptionPatterns on GoodsCompanySubscription {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoodsCompanySubscription value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoodsCompanySubscription() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoodsCompanySubscription value)  $default,){
final _that = this;
switch (_that) {
case _GoodsCompanySubscription():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoodsCompanySubscription value)?  $default,){
final _that = this;
switch (_that) {
case _GoodsCompanySubscription() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  GoodsCompanyPlanType planType,  DateTime startDate,  DateTime endDate,  double amount,  String paymentMethod,  String paymentReference,  bool isAutoRenew,  bool isPaid,  String? invoiceUrl,  DateTime? paidAt,  DateTime? cancelledAt,  String? cancellationReason,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoodsCompanySubscription() when $default != null:
return $default(_that.id,_that.companyId,_that.planType,_that.startDate,_that.endDate,_that.amount,_that.paymentMethod,_that.paymentReference,_that.isAutoRenew,_that.isPaid,_that.invoiceUrl,_that.paidAt,_that.cancelledAt,_that.cancellationReason,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  GoodsCompanyPlanType planType,  DateTime startDate,  DateTime endDate,  double amount,  String paymentMethod,  String paymentReference,  bool isAutoRenew,  bool isPaid,  String? invoiceUrl,  DateTime? paidAt,  DateTime? cancelledAt,  String? cancellationReason,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _GoodsCompanySubscription():
return $default(_that.id,_that.companyId,_that.planType,_that.startDate,_that.endDate,_that.amount,_that.paymentMethod,_that.paymentReference,_that.isAutoRenew,_that.isPaid,_that.invoiceUrl,_that.paidAt,_that.cancelledAt,_that.cancellationReason,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  GoodsCompanyPlanType planType,  DateTime startDate,  DateTime endDate,  double amount,  String paymentMethod,  String paymentReference,  bool isAutoRenew,  bool isPaid,  String? invoiceUrl,  DateTime? paidAt,  DateTime? cancelledAt,  String? cancellationReason,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _GoodsCompanySubscription() when $default != null:
return $default(_that.id,_that.companyId,_that.planType,_that.startDate,_that.endDate,_that.amount,_that.paymentMethod,_that.paymentReference,_that.isAutoRenew,_that.isPaid,_that.invoiceUrl,_that.paidAt,_that.cancelledAt,_that.cancellationReason,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GoodsCompanySubscription extends GoodsCompanySubscription {
  const _GoodsCompanySubscription({required this.id, required this.companyId, required this.planType, required this.startDate, required this.endDate, required this.amount, required this.paymentMethod, required this.paymentReference, this.isAutoRenew = false, this.isPaid = false, this.invoiceUrl, this.paidAt, this.cancelledAt, this.cancellationReason, required this.createdAt}): super._();
  factory _GoodsCompanySubscription.fromJson(Map<String, dynamic> json) => _$GoodsCompanySubscriptionFromJson(json);

@override final  String id;
@override final  String companyId;
@override final  GoodsCompanyPlanType planType;
@override final  DateTime startDate;
@override final  DateTime endDate;
@override final  double amount;
@override final  String paymentMethod;
@override final  String paymentReference;
@override@JsonKey() final  bool isAutoRenew;
@override@JsonKey() final  bool isPaid;
@override final  String? invoiceUrl;
@override final  DateTime? paidAt;
@override final  DateTime? cancelledAt;
@override final  String? cancellationReason;
@override final  DateTime createdAt;

/// Create a copy of GoodsCompanySubscription
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoodsCompanySubscriptionCopyWith<_GoodsCompanySubscription> get copyWith => __$GoodsCompanySubscriptionCopyWithImpl<_GoodsCompanySubscription>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GoodsCompanySubscriptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoodsCompanySubscription&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.planType, planType) || other.planType == planType)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.paymentReference, paymentReference) || other.paymentReference == paymentReference)&&(identical(other.isAutoRenew, isAutoRenew) || other.isAutoRenew == isAutoRenew)&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid)&&(identical(other.invoiceUrl, invoiceUrl) || other.invoiceUrl == invoiceUrl)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.cancellationReason, cancellationReason) || other.cancellationReason == cancellationReason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,companyId,planType,startDate,endDate,amount,paymentMethod,paymentReference,isAutoRenew,isPaid,invoiceUrl,paidAt,cancelledAt,cancellationReason,createdAt);

@override
String toString() {
  return 'GoodsCompanySubscription(id: $id, companyId: $companyId, planType: $planType, startDate: $startDate, endDate: $endDate, amount: $amount, paymentMethod: $paymentMethod, paymentReference: $paymentReference, isAutoRenew: $isAutoRenew, isPaid: $isPaid, invoiceUrl: $invoiceUrl, paidAt: $paidAt, cancelledAt: $cancelledAt, cancellationReason: $cancellationReason, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$GoodsCompanySubscriptionCopyWith<$Res> implements $GoodsCompanySubscriptionCopyWith<$Res> {
  factory _$GoodsCompanySubscriptionCopyWith(_GoodsCompanySubscription value, $Res Function(_GoodsCompanySubscription) _then) = __$GoodsCompanySubscriptionCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, GoodsCompanyPlanType planType, DateTime startDate, DateTime endDate, double amount, String paymentMethod, String paymentReference, bool isAutoRenew, bool isPaid, String? invoiceUrl, DateTime? paidAt, DateTime? cancelledAt, String? cancellationReason, DateTime createdAt
});




}
/// @nodoc
class __$GoodsCompanySubscriptionCopyWithImpl<$Res>
    implements _$GoodsCompanySubscriptionCopyWith<$Res> {
  __$GoodsCompanySubscriptionCopyWithImpl(this._self, this._then);

  final _GoodsCompanySubscription _self;
  final $Res Function(_GoodsCompanySubscription) _then;

/// Create a copy of GoodsCompanySubscription
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? planType = null,Object? startDate = null,Object? endDate = null,Object? amount = null,Object? paymentMethod = null,Object? paymentReference = null,Object? isAutoRenew = null,Object? isPaid = null,Object? invoiceUrl = freezed,Object? paidAt = freezed,Object? cancelledAt = freezed,Object? cancellationReason = freezed,Object? createdAt = null,}) {
  return _then(_GoodsCompanySubscription(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,planType: null == planType ? _self.planType : planType // ignore: cast_nullable_to_non_nullable
as GoodsCompanyPlanType,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String,paymentReference: null == paymentReference ? _self.paymentReference : paymentReference // ignore: cast_nullable_to_non_nullable
as String,isAutoRenew: null == isAutoRenew ? _self.isAutoRenew : isAutoRenew // ignore: cast_nullable_to_non_nullable
as bool,isPaid: null == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool,invoiceUrl: freezed == invoiceUrl ? _self.invoiceUrl : invoiceUrl // ignore: cast_nullable_to_non_nullable
as String?,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancellationReason: freezed == cancellationReason ? _self.cancellationReason : cancellationReason // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$CommissionStructureModel {

 String get id; String get companyId; double get minPercentage; double get maxPercentage; bool get isDynamic; Map<String, double>? get dynamicRates;// tripAmount -> percentage
 bool get includeTax; bool get includeInsurance; String? get notes; DateTime get effectiveFrom; DateTime? get effectiveTo; DateTime get createdAt;
/// Create a copy of CommissionStructureModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommissionStructureModelCopyWith<CommissionStructureModel> get copyWith => _$CommissionStructureModelCopyWithImpl<CommissionStructureModel>(this as CommissionStructureModel, _$identity);

  /// Serializes this CommissionStructureModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommissionStructureModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.minPercentage, minPercentage) || other.minPercentage == minPercentage)&&(identical(other.maxPercentage, maxPercentage) || other.maxPercentage == maxPercentage)&&(identical(other.isDynamic, isDynamic) || other.isDynamic == isDynamic)&&const DeepCollectionEquality().equals(other.dynamicRates, dynamicRates)&&(identical(other.includeTax, includeTax) || other.includeTax == includeTax)&&(identical(other.includeInsurance, includeInsurance) || other.includeInsurance == includeInsurance)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.effectiveFrom, effectiveFrom) || other.effectiveFrom == effectiveFrom)&&(identical(other.effectiveTo, effectiveTo) || other.effectiveTo == effectiveTo)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,companyId,minPercentage,maxPercentage,isDynamic,const DeepCollectionEquality().hash(dynamicRates),includeTax,includeInsurance,notes,effectiveFrom,effectiveTo,createdAt);

@override
String toString() {
  return 'CommissionStructureModel(id: $id, companyId: $companyId, minPercentage: $minPercentage, maxPercentage: $maxPercentage, isDynamic: $isDynamic, dynamicRates: $dynamicRates, includeTax: $includeTax, includeInsurance: $includeInsurance, notes: $notes, effectiveFrom: $effectiveFrom, effectiveTo: $effectiveTo, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $CommissionStructureModelCopyWith<$Res>  {
  factory $CommissionStructureModelCopyWith(CommissionStructureModel value, $Res Function(CommissionStructureModel) _then) = _$CommissionStructureModelCopyWithImpl;
@useResult
$Res call({
 String id, String companyId, double minPercentage, double maxPercentage, bool isDynamic, Map<String, double>? dynamicRates, bool includeTax, bool includeInsurance, String? notes, DateTime effectiveFrom, DateTime? effectiveTo, DateTime createdAt
});




}
/// @nodoc
class _$CommissionStructureModelCopyWithImpl<$Res>
    implements $CommissionStructureModelCopyWith<$Res> {
  _$CommissionStructureModelCopyWithImpl(this._self, this._then);

  final CommissionStructureModel _self;
  final $Res Function(CommissionStructureModel) _then;

/// Create a copy of CommissionStructureModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? minPercentage = null,Object? maxPercentage = null,Object? isDynamic = null,Object? dynamicRates = freezed,Object? includeTax = null,Object? includeInsurance = null,Object? notes = freezed,Object? effectiveFrom = null,Object? effectiveTo = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,minPercentage: null == minPercentage ? _self.minPercentage : minPercentage // ignore: cast_nullable_to_non_nullable
as double,maxPercentage: null == maxPercentage ? _self.maxPercentage : maxPercentage // ignore: cast_nullable_to_non_nullable
as double,isDynamic: null == isDynamic ? _self.isDynamic : isDynamic // ignore: cast_nullable_to_non_nullable
as bool,dynamicRates: freezed == dynamicRates ? _self.dynamicRates : dynamicRates // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,includeTax: null == includeTax ? _self.includeTax : includeTax // ignore: cast_nullable_to_non_nullable
as bool,includeInsurance: null == includeInsurance ? _self.includeInsurance : includeInsurance // ignore: cast_nullable_to_non_nullable
as bool,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,effectiveFrom: null == effectiveFrom ? _self.effectiveFrom : effectiveFrom // ignore: cast_nullable_to_non_nullable
as DateTime,effectiveTo: freezed == effectiveTo ? _self.effectiveTo : effectiveTo // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CommissionStructureModel].
extension CommissionStructureModelPatterns on CommissionStructureModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommissionStructureModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommissionStructureModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommissionStructureModel value)  $default,){
final _that = this;
switch (_that) {
case _CommissionStructureModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommissionStructureModel value)?  $default,){
final _that = this;
switch (_that) {
case _CommissionStructureModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String companyId,  double minPercentage,  double maxPercentage,  bool isDynamic,  Map<String, double>? dynamicRates,  bool includeTax,  bool includeInsurance,  String? notes,  DateTime effectiveFrom,  DateTime? effectiveTo,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommissionStructureModel() when $default != null:
return $default(_that.id,_that.companyId,_that.minPercentage,_that.maxPercentage,_that.isDynamic,_that.dynamicRates,_that.includeTax,_that.includeInsurance,_that.notes,_that.effectiveFrom,_that.effectiveTo,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String companyId,  double minPercentage,  double maxPercentage,  bool isDynamic,  Map<String, double>? dynamicRates,  bool includeTax,  bool includeInsurance,  String? notes,  DateTime effectiveFrom,  DateTime? effectiveTo,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _CommissionStructureModel():
return $default(_that.id,_that.companyId,_that.minPercentage,_that.maxPercentage,_that.isDynamic,_that.dynamicRates,_that.includeTax,_that.includeInsurance,_that.notes,_that.effectiveFrom,_that.effectiveTo,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String companyId,  double minPercentage,  double maxPercentage,  bool isDynamic,  Map<String, double>? dynamicRates,  bool includeTax,  bool includeInsurance,  String? notes,  DateTime effectiveFrom,  DateTime? effectiveTo,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _CommissionStructureModel() when $default != null:
return $default(_that.id,_that.companyId,_that.minPercentage,_that.maxPercentage,_that.isDynamic,_that.dynamicRates,_that.includeTax,_that.includeInsurance,_that.notes,_that.effectiveFrom,_that.effectiveTo,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CommissionStructureModel extends CommissionStructureModel {
  const _CommissionStructureModel({required this.id, required this.companyId, required this.minPercentage, required this.maxPercentage, this.isDynamic = true, final  Map<String, double>? dynamicRates, this.includeTax = false, this.includeInsurance = false, this.notes, required this.effectiveFrom, this.effectiveTo, required this.createdAt}): _dynamicRates = dynamicRates,super._();
  factory _CommissionStructureModel.fromJson(Map<String, dynamic> json) => _$CommissionStructureModelFromJson(json);

@override final  String id;
@override final  String companyId;
@override final  double minPercentage;
@override final  double maxPercentage;
@override@JsonKey() final  bool isDynamic;
 final  Map<String, double>? _dynamicRates;
@override Map<String, double>? get dynamicRates {
  final value = _dynamicRates;
  if (value == null) return null;
  if (_dynamicRates is EqualUnmodifiableMapView) return _dynamicRates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

// tripAmount -> percentage
@override@JsonKey() final  bool includeTax;
@override@JsonKey() final  bool includeInsurance;
@override final  String? notes;
@override final  DateTime effectiveFrom;
@override final  DateTime? effectiveTo;
@override final  DateTime createdAt;

/// Create a copy of CommissionStructureModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommissionStructureModelCopyWith<_CommissionStructureModel> get copyWith => __$CommissionStructureModelCopyWithImpl<_CommissionStructureModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CommissionStructureModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommissionStructureModel&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.minPercentage, minPercentage) || other.minPercentage == minPercentage)&&(identical(other.maxPercentage, maxPercentage) || other.maxPercentage == maxPercentage)&&(identical(other.isDynamic, isDynamic) || other.isDynamic == isDynamic)&&const DeepCollectionEquality().equals(other._dynamicRates, _dynamicRates)&&(identical(other.includeTax, includeTax) || other.includeTax == includeTax)&&(identical(other.includeInsurance, includeInsurance) || other.includeInsurance == includeInsurance)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.effectiveFrom, effectiveFrom) || other.effectiveFrom == effectiveFrom)&&(identical(other.effectiveTo, effectiveTo) || other.effectiveTo == effectiveTo)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,companyId,minPercentage,maxPercentage,isDynamic,const DeepCollectionEquality().hash(_dynamicRates),includeTax,includeInsurance,notes,effectiveFrom,effectiveTo,createdAt);

@override
String toString() {
  return 'CommissionStructureModel(id: $id, companyId: $companyId, minPercentage: $minPercentage, maxPercentage: $maxPercentage, isDynamic: $isDynamic, dynamicRates: $dynamicRates, includeTax: $includeTax, includeInsurance: $includeInsurance, notes: $notes, effectiveFrom: $effectiveFrom, effectiveTo: $effectiveTo, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$CommissionStructureModelCopyWith<$Res> implements $CommissionStructureModelCopyWith<$Res> {
  factory _$CommissionStructureModelCopyWith(_CommissionStructureModel value, $Res Function(_CommissionStructureModel) _then) = __$CommissionStructureModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String companyId, double minPercentage, double maxPercentage, bool isDynamic, Map<String, double>? dynamicRates, bool includeTax, bool includeInsurance, String? notes, DateTime effectiveFrom, DateTime? effectiveTo, DateTime createdAt
});




}
/// @nodoc
class __$CommissionStructureModelCopyWithImpl<$Res>
    implements _$CommissionStructureModelCopyWith<$Res> {
  __$CommissionStructureModelCopyWithImpl(this._self, this._then);

  final _CommissionStructureModel _self;
  final $Res Function(_CommissionStructureModel) _then;

/// Create a copy of CommissionStructureModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? minPercentage = null,Object? maxPercentage = null,Object? isDynamic = null,Object? dynamicRates = freezed,Object? includeTax = null,Object? includeInsurance = null,Object? notes = freezed,Object? effectiveFrom = null,Object? effectiveTo = freezed,Object? createdAt = null,}) {
  return _then(_CommissionStructureModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,minPercentage: null == minPercentage ? _self.minPercentage : minPercentage // ignore: cast_nullable_to_non_nullable
as double,maxPercentage: null == maxPercentage ? _self.maxPercentage : maxPercentage // ignore: cast_nullable_to_non_nullable
as double,isDynamic: null == isDynamic ? _self.isDynamic : isDynamic // ignore: cast_nullable_to_non_nullable
as bool,dynamicRates: freezed == dynamicRates ? _self._dynamicRates : dynamicRates // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,includeTax: null == includeTax ? _self.includeTax : includeTax // ignore: cast_nullable_to_non_nullable
as bool,includeInsurance: null == includeInsurance ? _self.includeInsurance : includeInsurance // ignore: cast_nullable_to_non_nullable
as bool,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,effectiveFrom: null == effectiveFrom ? _self.effectiveFrom : effectiveFrom // ignore: cast_nullable_to_non_nullable
as DateTime,effectiveTo: freezed == effectiveTo ? _self.effectiveTo : effectiveTo // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$GoodsCompanySettings {

 String get companyId; bool get emailNotifications; bool get smsNotifications; bool get pushNotifications; bool get bidNotifications; bool get tripNotifications; bool get paymentNotifications; bool get autoAcceptBids; double get autoAcceptMaxAmount; bool get requireDriverVerification; bool get requireTruckVerification; bool get showLiveTracking; bool get shareLocationWithFactories; String get language; String get country; String get timezone; DateTime? get updatedAt;
/// Create a copy of GoodsCompanySettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoodsCompanySettingsCopyWith<GoodsCompanySettings> get copyWith => _$GoodsCompanySettingsCopyWithImpl<GoodsCompanySettings>(this as GoodsCompanySettings, _$identity);

  /// Serializes this GoodsCompanySettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoodsCompanySettings&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.emailNotifications, emailNotifications) || other.emailNotifications == emailNotifications)&&(identical(other.smsNotifications, smsNotifications) || other.smsNotifications == smsNotifications)&&(identical(other.pushNotifications, pushNotifications) || other.pushNotifications == pushNotifications)&&(identical(other.bidNotifications, bidNotifications) || other.bidNotifications == bidNotifications)&&(identical(other.tripNotifications, tripNotifications) || other.tripNotifications == tripNotifications)&&(identical(other.paymentNotifications, paymentNotifications) || other.paymentNotifications == paymentNotifications)&&(identical(other.autoAcceptBids, autoAcceptBids) || other.autoAcceptBids == autoAcceptBids)&&(identical(other.autoAcceptMaxAmount, autoAcceptMaxAmount) || other.autoAcceptMaxAmount == autoAcceptMaxAmount)&&(identical(other.requireDriverVerification, requireDriverVerification) || other.requireDriverVerification == requireDriverVerification)&&(identical(other.requireTruckVerification, requireTruckVerification) || other.requireTruckVerification == requireTruckVerification)&&(identical(other.showLiveTracking, showLiveTracking) || other.showLiveTracking == showLiveTracking)&&(identical(other.shareLocationWithFactories, shareLocationWithFactories) || other.shareLocationWithFactories == shareLocationWithFactories)&&(identical(other.language, language) || other.language == language)&&(identical(other.country, country) || other.country == country)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,companyId,emailNotifications,smsNotifications,pushNotifications,bidNotifications,tripNotifications,paymentNotifications,autoAcceptBids,autoAcceptMaxAmount,requireDriverVerification,requireTruckVerification,showLiveTracking,shareLocationWithFactories,language,country,timezone,updatedAt);

@override
String toString() {
  return 'GoodsCompanySettings(companyId: $companyId, emailNotifications: $emailNotifications, smsNotifications: $smsNotifications, pushNotifications: $pushNotifications, bidNotifications: $bidNotifications, tripNotifications: $tripNotifications, paymentNotifications: $paymentNotifications, autoAcceptBids: $autoAcceptBids, autoAcceptMaxAmount: $autoAcceptMaxAmount, requireDriverVerification: $requireDriverVerification, requireTruckVerification: $requireTruckVerification, showLiveTracking: $showLiveTracking, shareLocationWithFactories: $shareLocationWithFactories, language: $language, country: $country, timezone: $timezone, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $GoodsCompanySettingsCopyWith<$Res>  {
  factory $GoodsCompanySettingsCopyWith(GoodsCompanySettings value, $Res Function(GoodsCompanySettings) _then) = _$GoodsCompanySettingsCopyWithImpl;
@useResult
$Res call({
 String companyId, bool emailNotifications, bool smsNotifications, bool pushNotifications, bool bidNotifications, bool tripNotifications, bool paymentNotifications, bool autoAcceptBids, double autoAcceptMaxAmount, bool requireDriverVerification, bool requireTruckVerification, bool showLiveTracking, bool shareLocationWithFactories, String language, String country, String timezone, DateTime? updatedAt
});




}
/// @nodoc
class _$GoodsCompanySettingsCopyWithImpl<$Res>
    implements $GoodsCompanySettingsCopyWith<$Res> {
  _$GoodsCompanySettingsCopyWithImpl(this._self, this._then);

  final GoodsCompanySettings _self;
  final $Res Function(GoodsCompanySettings) _then;

/// Create a copy of GoodsCompanySettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? companyId = null,Object? emailNotifications = null,Object? smsNotifications = null,Object? pushNotifications = null,Object? bidNotifications = null,Object? tripNotifications = null,Object? paymentNotifications = null,Object? autoAcceptBids = null,Object? autoAcceptMaxAmount = null,Object? requireDriverVerification = null,Object? requireTruckVerification = null,Object? showLiveTracking = null,Object? shareLocationWithFactories = null,Object? language = null,Object? country = null,Object? timezone = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,emailNotifications: null == emailNotifications ? _self.emailNotifications : emailNotifications // ignore: cast_nullable_to_non_nullable
as bool,smsNotifications: null == smsNotifications ? _self.smsNotifications : smsNotifications // ignore: cast_nullable_to_non_nullable
as bool,pushNotifications: null == pushNotifications ? _self.pushNotifications : pushNotifications // ignore: cast_nullable_to_non_nullable
as bool,bidNotifications: null == bidNotifications ? _self.bidNotifications : bidNotifications // ignore: cast_nullable_to_non_nullable
as bool,tripNotifications: null == tripNotifications ? _self.tripNotifications : tripNotifications // ignore: cast_nullable_to_non_nullable
as bool,paymentNotifications: null == paymentNotifications ? _self.paymentNotifications : paymentNotifications // ignore: cast_nullable_to_non_nullable
as bool,autoAcceptBids: null == autoAcceptBids ? _self.autoAcceptBids : autoAcceptBids // ignore: cast_nullable_to_non_nullable
as bool,autoAcceptMaxAmount: null == autoAcceptMaxAmount ? _self.autoAcceptMaxAmount : autoAcceptMaxAmount // ignore: cast_nullable_to_non_nullable
as double,requireDriverVerification: null == requireDriverVerification ? _self.requireDriverVerification : requireDriverVerification // ignore: cast_nullable_to_non_nullable
as bool,requireTruckVerification: null == requireTruckVerification ? _self.requireTruckVerification : requireTruckVerification // ignore: cast_nullable_to_non_nullable
as bool,showLiveTracking: null == showLiveTracking ? _self.showLiveTracking : showLiveTracking // ignore: cast_nullable_to_non_nullable
as bool,shareLocationWithFactories: null == shareLocationWithFactories ? _self.shareLocationWithFactories : shareLocationWithFactories // ignore: cast_nullable_to_non_nullable
as bool,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [GoodsCompanySettings].
extension GoodsCompanySettingsPatterns on GoodsCompanySettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoodsCompanySettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoodsCompanySettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoodsCompanySettings value)  $default,){
final _that = this;
switch (_that) {
case _GoodsCompanySettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoodsCompanySettings value)?  $default,){
final _that = this;
switch (_that) {
case _GoodsCompanySettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String companyId,  bool emailNotifications,  bool smsNotifications,  bool pushNotifications,  bool bidNotifications,  bool tripNotifications,  bool paymentNotifications,  bool autoAcceptBids,  double autoAcceptMaxAmount,  bool requireDriverVerification,  bool requireTruckVerification,  bool showLiveTracking,  bool shareLocationWithFactories,  String language,  String country,  String timezone,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoodsCompanySettings() when $default != null:
return $default(_that.companyId,_that.emailNotifications,_that.smsNotifications,_that.pushNotifications,_that.bidNotifications,_that.tripNotifications,_that.paymentNotifications,_that.autoAcceptBids,_that.autoAcceptMaxAmount,_that.requireDriverVerification,_that.requireTruckVerification,_that.showLiveTracking,_that.shareLocationWithFactories,_that.language,_that.country,_that.timezone,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String companyId,  bool emailNotifications,  bool smsNotifications,  bool pushNotifications,  bool bidNotifications,  bool tripNotifications,  bool paymentNotifications,  bool autoAcceptBids,  double autoAcceptMaxAmount,  bool requireDriverVerification,  bool requireTruckVerification,  bool showLiveTracking,  bool shareLocationWithFactories,  String language,  String country,  String timezone,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _GoodsCompanySettings():
return $default(_that.companyId,_that.emailNotifications,_that.smsNotifications,_that.pushNotifications,_that.bidNotifications,_that.tripNotifications,_that.paymentNotifications,_that.autoAcceptBids,_that.autoAcceptMaxAmount,_that.requireDriverVerification,_that.requireTruckVerification,_that.showLiveTracking,_that.shareLocationWithFactories,_that.language,_that.country,_that.timezone,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String companyId,  bool emailNotifications,  bool smsNotifications,  bool pushNotifications,  bool bidNotifications,  bool tripNotifications,  bool paymentNotifications,  bool autoAcceptBids,  double autoAcceptMaxAmount,  bool requireDriverVerification,  bool requireTruckVerification,  bool showLiveTracking,  bool shareLocationWithFactories,  String language,  String country,  String timezone,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _GoodsCompanySettings() when $default != null:
return $default(_that.companyId,_that.emailNotifications,_that.smsNotifications,_that.pushNotifications,_that.bidNotifications,_that.tripNotifications,_that.paymentNotifications,_that.autoAcceptBids,_that.autoAcceptMaxAmount,_that.requireDriverVerification,_that.requireTruckVerification,_that.showLiveTracking,_that.shareLocationWithFactories,_that.language,_that.country,_that.timezone,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GoodsCompanySettings implements GoodsCompanySettings {
  const _GoodsCompanySettings({required this.companyId, this.emailNotifications = true, this.smsNotifications = true, this.pushNotifications = true, this.bidNotifications = true, this.tripNotifications = true, this.paymentNotifications = true, this.autoAcceptBids = false, this.autoAcceptMaxAmount = 50000.0, this.requireDriverVerification = false, this.requireTruckVerification = false, this.showLiveTracking = true, this.shareLocationWithFactories = false, this.language = 'en', this.country = 'PK', this.timezone = 'UTC', this.updatedAt});
  factory _GoodsCompanySettings.fromJson(Map<String, dynamic> json) => _$GoodsCompanySettingsFromJson(json);

@override final  String companyId;
@override@JsonKey() final  bool emailNotifications;
@override@JsonKey() final  bool smsNotifications;
@override@JsonKey() final  bool pushNotifications;
@override@JsonKey() final  bool bidNotifications;
@override@JsonKey() final  bool tripNotifications;
@override@JsonKey() final  bool paymentNotifications;
@override@JsonKey() final  bool autoAcceptBids;
@override@JsonKey() final  double autoAcceptMaxAmount;
@override@JsonKey() final  bool requireDriverVerification;
@override@JsonKey() final  bool requireTruckVerification;
@override@JsonKey() final  bool showLiveTracking;
@override@JsonKey() final  bool shareLocationWithFactories;
@override@JsonKey() final  String language;
@override@JsonKey() final  String country;
@override@JsonKey() final  String timezone;
@override final  DateTime? updatedAt;

/// Create a copy of GoodsCompanySettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoodsCompanySettingsCopyWith<_GoodsCompanySettings> get copyWith => __$GoodsCompanySettingsCopyWithImpl<_GoodsCompanySettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GoodsCompanySettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoodsCompanySettings&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.emailNotifications, emailNotifications) || other.emailNotifications == emailNotifications)&&(identical(other.smsNotifications, smsNotifications) || other.smsNotifications == smsNotifications)&&(identical(other.pushNotifications, pushNotifications) || other.pushNotifications == pushNotifications)&&(identical(other.bidNotifications, bidNotifications) || other.bidNotifications == bidNotifications)&&(identical(other.tripNotifications, tripNotifications) || other.tripNotifications == tripNotifications)&&(identical(other.paymentNotifications, paymentNotifications) || other.paymentNotifications == paymentNotifications)&&(identical(other.autoAcceptBids, autoAcceptBids) || other.autoAcceptBids == autoAcceptBids)&&(identical(other.autoAcceptMaxAmount, autoAcceptMaxAmount) || other.autoAcceptMaxAmount == autoAcceptMaxAmount)&&(identical(other.requireDriverVerification, requireDriverVerification) || other.requireDriverVerification == requireDriverVerification)&&(identical(other.requireTruckVerification, requireTruckVerification) || other.requireTruckVerification == requireTruckVerification)&&(identical(other.showLiveTracking, showLiveTracking) || other.showLiveTracking == showLiveTracking)&&(identical(other.shareLocationWithFactories, shareLocationWithFactories) || other.shareLocationWithFactories == shareLocationWithFactories)&&(identical(other.language, language) || other.language == language)&&(identical(other.country, country) || other.country == country)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,companyId,emailNotifications,smsNotifications,pushNotifications,bidNotifications,tripNotifications,paymentNotifications,autoAcceptBids,autoAcceptMaxAmount,requireDriverVerification,requireTruckVerification,showLiveTracking,shareLocationWithFactories,language,country,timezone,updatedAt);

@override
String toString() {
  return 'GoodsCompanySettings(companyId: $companyId, emailNotifications: $emailNotifications, smsNotifications: $smsNotifications, pushNotifications: $pushNotifications, bidNotifications: $bidNotifications, tripNotifications: $tripNotifications, paymentNotifications: $paymentNotifications, autoAcceptBids: $autoAcceptBids, autoAcceptMaxAmount: $autoAcceptMaxAmount, requireDriverVerification: $requireDriverVerification, requireTruckVerification: $requireTruckVerification, showLiveTracking: $showLiveTracking, shareLocationWithFactories: $shareLocationWithFactories, language: $language, country: $country, timezone: $timezone, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$GoodsCompanySettingsCopyWith<$Res> implements $GoodsCompanySettingsCopyWith<$Res> {
  factory _$GoodsCompanySettingsCopyWith(_GoodsCompanySettings value, $Res Function(_GoodsCompanySettings) _then) = __$GoodsCompanySettingsCopyWithImpl;
@override @useResult
$Res call({
 String companyId, bool emailNotifications, bool smsNotifications, bool pushNotifications, bool bidNotifications, bool tripNotifications, bool paymentNotifications, bool autoAcceptBids, double autoAcceptMaxAmount, bool requireDriverVerification, bool requireTruckVerification, bool showLiveTracking, bool shareLocationWithFactories, String language, String country, String timezone, DateTime? updatedAt
});




}
/// @nodoc
class __$GoodsCompanySettingsCopyWithImpl<$Res>
    implements _$GoodsCompanySettingsCopyWith<$Res> {
  __$GoodsCompanySettingsCopyWithImpl(this._self, this._then);

  final _GoodsCompanySettings _self;
  final $Res Function(_GoodsCompanySettings) _then;

/// Create a copy of GoodsCompanySettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? companyId = null,Object? emailNotifications = null,Object? smsNotifications = null,Object? pushNotifications = null,Object? bidNotifications = null,Object? tripNotifications = null,Object? paymentNotifications = null,Object? autoAcceptBids = null,Object? autoAcceptMaxAmount = null,Object? requireDriverVerification = null,Object? requireTruckVerification = null,Object? showLiveTracking = null,Object? shareLocationWithFactories = null,Object? language = null,Object? country = null,Object? timezone = null,Object? updatedAt = freezed,}) {
  return _then(_GoodsCompanySettings(
companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,emailNotifications: null == emailNotifications ? _self.emailNotifications : emailNotifications // ignore: cast_nullable_to_non_nullable
as bool,smsNotifications: null == smsNotifications ? _self.smsNotifications : smsNotifications // ignore: cast_nullable_to_non_nullable
as bool,pushNotifications: null == pushNotifications ? _self.pushNotifications : pushNotifications // ignore: cast_nullable_to_non_nullable
as bool,bidNotifications: null == bidNotifications ? _self.bidNotifications : bidNotifications // ignore: cast_nullable_to_non_nullable
as bool,tripNotifications: null == tripNotifications ? _self.tripNotifications : tripNotifications // ignore: cast_nullable_to_non_nullable
as bool,paymentNotifications: null == paymentNotifications ? _self.paymentNotifications : paymentNotifications // ignore: cast_nullable_to_non_nullable
as bool,autoAcceptBids: null == autoAcceptBids ? _self.autoAcceptBids : autoAcceptBids // ignore: cast_nullable_to_non_nullable
as bool,autoAcceptMaxAmount: null == autoAcceptMaxAmount ? _self.autoAcceptMaxAmount : autoAcceptMaxAmount // ignore: cast_nullable_to_non_nullable
as double,requireDriverVerification: null == requireDriverVerification ? _self.requireDriverVerification : requireDriverVerification // ignore: cast_nullable_to_non_nullable
as bool,requireTruckVerification: null == requireTruckVerification ? _self.requireTruckVerification : requireTruckVerification // ignore: cast_nullable_to_non_nullable
as bool,showLiveTracking: null == showLiveTracking ? _self.showLiveTracking : showLiveTracking // ignore: cast_nullable_to_non_nullable
as bool,shareLocationWithFactories: null == shareLocationWithFactories ? _self.shareLocationWithFactories : shareLocationWithFactories // ignore: cast_nullable_to_non_nullable
as bool,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'company_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Company {

/// Unique identifier for the company
@JsonKey(name: 'id') String get id;/// Official company name
@JsonKey(name: 'name') String get name;/// Trading name (if different from official name)
@JsonKey(name: 'trading_name') String? get tradingName;/// Company registration number
@JsonKey(name: 'registration_number') String get registrationNumber;/// Tax ID/VAT number
@JsonKey(name: 'tax_id') String? get taxId;/// Type of company
@JsonKey(name: 'type') CompanyType get type;/// Industry type
@JsonKey(name: 'industry') IndustryType get industry;/// Country where company is registered
@JsonKey(name: 'country') String get country;/// City where company is located
@JsonKey(name: 'city') String get city;/// Full address of the company
@JsonKey(name: 'address') String get address;/// Postal/ZIP code
@JsonKey(name: 'postal_code') String? get postalCode;/// Primary phone number
@JsonKey(name: 'phone') String get phone;/// Primary email address
@JsonKey(name: 'email') String get email;/// Company website
@JsonKey(name: 'website') String? get website;/// Status of the company
@JsonKey(name: 'status') CompanyStatus get status;/// Verification status
@JsonKey(name: 'verification_status') VerificationStatus get verificationStatus;/// Contact person information
@JsonKey(name: 'contact_person') ContactPerson get contactPerson;/// Subscription plan assigned to the company
@JsonKey(name: 'subscription_plan') Plan? get subscriptionPlan;/// Subscription ID (if subscribed)
@JsonKey(name: 'subscription_id') String? get subscriptionId;/// Billing cycle (monthly/yearly)
@JsonKey(name: 'billing_cycle') BillingCycle get billingCycle;/// Date when subscription started
@JsonKey(name: 'subscription_start_date') DateTime? get subscriptionStartDate;/// Date when subscription ends/renews
@JsonKey(name: 'subscription_end_date') DateTime? get subscriptionEndDate;/// Whether the company is on trial
@JsonKey(name: 'is_trial') bool get isTrial;/// Trial end date (if applicable)
@JsonKey(name: 'trial_end_date') DateTime? get trialEndDate;/// Number of employees in the company
@JsonKey(name: 'employee_count') int get employeeCount;/// Annual revenue (optional)
@JsonKey(name: 'annual_revenue') double? get annualRevenue;/// Currency for revenue
@JsonKey(name: 'revenue_currency') String get revenueCurrency;/// Notes about the company
@JsonKey(name: 'notes') String? get notes;/// Tags for categorization
@JsonKey(name: 'tags') List<String> get tags;/// Documents submitted for verification
@JsonKey(name: 'documents') List<CompanyDocument> get documents;/// Settings specific to this company
@JsonKey(name: 'settings') CompanySettings get settings;/// Usage statistics
@JsonKey(name: 'usage_stats') CompanyUsageStats get usageStats;/// Date when the company was registered
@JsonKey(name: 'registered_at') DateTime get registeredAt;/// Date when the company was last updated
@JsonKey(name: 'updated_at') DateTime get updatedAt;/// Date when the company was verified
@JsonKey(name: 'verified_at') DateTime? get verifiedAt;/// Date when the company was suspended
@JsonKey(name: 'suspended_at') DateTime? get suspendedAt;/// Reason for suspension
@JsonKey(name: 'suspension_reason') String? get suspensionReason;
/// Create a copy of Company
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompanyCopyWith<Company> get copyWith => _$CompanyCopyWithImpl<Company>(this as Company, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Company&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.tradingName, tradingName) || other.tradingName == tradingName)&&(identical(other.registrationNumber, registrationNumber) || other.registrationNumber == registrationNumber)&&(identical(other.taxId, taxId) || other.taxId == taxId)&&(identical(other.type, type) || other.type == type)&&(identical(other.industry, industry) || other.industry == industry)&&(identical(other.country, country) || other.country == country)&&(identical(other.city, city) || other.city == city)&&(identical(other.address, address) || other.address == address)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.website, website) || other.website == website)&&(identical(other.status, status) || other.status == status)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.contactPerson, contactPerson) || other.contactPerson == contactPerson)&&(identical(other.subscriptionPlan, subscriptionPlan) || other.subscriptionPlan == subscriptionPlan)&&(identical(other.subscriptionId, subscriptionId) || other.subscriptionId == subscriptionId)&&(identical(other.billingCycle, billingCycle) || other.billingCycle == billingCycle)&&(identical(other.subscriptionStartDate, subscriptionStartDate) || other.subscriptionStartDate == subscriptionStartDate)&&(identical(other.subscriptionEndDate, subscriptionEndDate) || other.subscriptionEndDate == subscriptionEndDate)&&(identical(other.isTrial, isTrial) || other.isTrial == isTrial)&&(identical(other.trialEndDate, trialEndDate) || other.trialEndDate == trialEndDate)&&(identical(other.employeeCount, employeeCount) || other.employeeCount == employeeCount)&&(identical(other.annualRevenue, annualRevenue) || other.annualRevenue == annualRevenue)&&(identical(other.revenueCurrency, revenueCurrency) || other.revenueCurrency == revenueCurrency)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other.tags, tags)&&const DeepCollectionEquality().equals(other.documents, documents)&&(identical(other.settings, settings) || other.settings == settings)&&(identical(other.usageStats, usageStats) || other.usageStats == usageStats)&&(identical(other.registeredAt, registeredAt) || other.registeredAt == registeredAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.suspendedAt, suspendedAt) || other.suspendedAt == suspendedAt)&&(identical(other.suspensionReason, suspensionReason) || other.suspensionReason == suspensionReason));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,name,tradingName,registrationNumber,taxId,type,industry,country,city,address,postalCode,phone,email,website,status,verificationStatus,contactPerson,subscriptionPlan,subscriptionId,billingCycle,subscriptionStartDate,subscriptionEndDate,isTrial,trialEndDate,employeeCount,annualRevenue,revenueCurrency,notes,const DeepCollectionEquality().hash(tags),const DeepCollectionEquality().hash(documents),settings,usageStats,registeredAt,updatedAt,verifiedAt,suspendedAt,suspensionReason]);

@override
String toString() {
  return 'Company(id: $id, name: $name, tradingName: $tradingName, registrationNumber: $registrationNumber, taxId: $taxId, type: $type, industry: $industry, country: $country, city: $city, address: $address, postalCode: $postalCode, phone: $phone, email: $email, website: $website, status: $status, verificationStatus: $verificationStatus, contactPerson: $contactPerson, subscriptionPlan: $subscriptionPlan, subscriptionId: $subscriptionId, billingCycle: $billingCycle, subscriptionStartDate: $subscriptionStartDate, subscriptionEndDate: $subscriptionEndDate, isTrial: $isTrial, trialEndDate: $trialEndDate, employeeCount: $employeeCount, annualRevenue: $annualRevenue, revenueCurrency: $revenueCurrency, notes: $notes, tags: $tags, documents: $documents, settings: $settings, usageStats: $usageStats, registeredAt: $registeredAt, updatedAt: $updatedAt, verifiedAt: $verifiedAt, suspendedAt: $suspendedAt, suspensionReason: $suspensionReason)';
}


}

/// @nodoc
abstract mixin class $CompanyCopyWith<$Res>  {
  factory $CompanyCopyWith(Company value, $Res Function(Company) _then) = _$CompanyCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id') String id,@JsonKey(name: 'name') String name,@JsonKey(name: 'trading_name') String? tradingName,@JsonKey(name: 'registration_number') String registrationNumber,@JsonKey(name: 'tax_id') String? taxId,@JsonKey(name: 'type') CompanyType type,@JsonKey(name: 'industry') IndustryType industry,@JsonKey(name: 'country') String country,@JsonKey(name: 'city') String city,@JsonKey(name: 'address') String address,@JsonKey(name: 'postal_code') String? postalCode,@JsonKey(name: 'phone') String phone,@JsonKey(name: 'email') String email,@JsonKey(name: 'website') String? website,@JsonKey(name: 'status') CompanyStatus status,@JsonKey(name: 'verification_status') VerificationStatus verificationStatus,@JsonKey(name: 'contact_person') ContactPerson contactPerson,@JsonKey(name: 'subscription_plan') Plan? subscriptionPlan,@JsonKey(name: 'subscription_id') String? subscriptionId,@JsonKey(name: 'billing_cycle') BillingCycle billingCycle,@JsonKey(name: 'subscription_start_date') DateTime? subscriptionStartDate,@JsonKey(name: 'subscription_end_date') DateTime? subscriptionEndDate,@JsonKey(name: 'is_trial') bool isTrial,@JsonKey(name: 'trial_end_date') DateTime? trialEndDate,@JsonKey(name: 'employee_count') int employeeCount,@JsonKey(name: 'annual_revenue') double? annualRevenue,@JsonKey(name: 'revenue_currency') String revenueCurrency,@JsonKey(name: 'notes') String? notes,@JsonKey(name: 'tags') List<String> tags,@JsonKey(name: 'documents') List<CompanyDocument> documents,@JsonKey(name: 'settings') CompanySettings settings,@JsonKey(name: 'usage_stats') CompanyUsageStats usageStats,@JsonKey(name: 'registered_at') DateTime registeredAt,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'verified_at') DateTime? verifiedAt,@JsonKey(name: 'suspended_at') DateTime? suspendedAt,@JsonKey(name: 'suspension_reason') String? suspensionReason
});


$ContactPersonCopyWith<$Res> get contactPerson;$PlanCopyWith<$Res>? get subscriptionPlan;$CompanySettingsCopyWith<$Res> get settings;$CompanyUsageStatsCopyWith<$Res> get usageStats;

}
/// @nodoc
class _$CompanyCopyWithImpl<$Res>
    implements $CompanyCopyWith<$Res> {
  _$CompanyCopyWithImpl(this._self, this._then);

  final Company _self;
  final $Res Function(Company) _then;

/// Create a copy of Company
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? tradingName = freezed,Object? registrationNumber = null,Object? taxId = freezed,Object? type = null,Object? industry = null,Object? country = null,Object? city = null,Object? address = null,Object? postalCode = freezed,Object? phone = null,Object? email = null,Object? website = freezed,Object? status = null,Object? verificationStatus = null,Object? contactPerson = null,Object? subscriptionPlan = freezed,Object? subscriptionId = freezed,Object? billingCycle = null,Object? subscriptionStartDate = freezed,Object? subscriptionEndDate = freezed,Object? isTrial = null,Object? trialEndDate = freezed,Object? employeeCount = null,Object? annualRevenue = freezed,Object? revenueCurrency = null,Object? notes = freezed,Object? tags = null,Object? documents = null,Object? settings = null,Object? usageStats = null,Object? registeredAt = null,Object? updatedAt = null,Object? verifiedAt = freezed,Object? suspendedAt = freezed,Object? suspensionReason = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,tradingName: freezed == tradingName ? _self.tradingName : tradingName // ignore: cast_nullable_to_non_nullable
as String?,registrationNumber: null == registrationNumber ? _self.registrationNumber : registrationNumber // ignore: cast_nullable_to_non_nullable
as String,taxId: freezed == taxId ? _self.taxId : taxId // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CompanyType,industry: null == industry ? _self.industry : industry // ignore: cast_nullable_to_non_nullable
as IndustryType,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,postalCode: freezed == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String?,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CompanyStatus,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as VerificationStatus,contactPerson: null == contactPerson ? _self.contactPerson : contactPerson // ignore: cast_nullable_to_non_nullable
as ContactPerson,subscriptionPlan: freezed == subscriptionPlan ? _self.subscriptionPlan : subscriptionPlan // ignore: cast_nullable_to_non_nullable
as Plan?,subscriptionId: freezed == subscriptionId ? _self.subscriptionId : subscriptionId // ignore: cast_nullable_to_non_nullable
as String?,billingCycle: null == billingCycle ? _self.billingCycle : billingCycle // ignore: cast_nullable_to_non_nullable
as BillingCycle,subscriptionStartDate: freezed == subscriptionStartDate ? _self.subscriptionStartDate : subscriptionStartDate // ignore: cast_nullable_to_non_nullable
as DateTime?,subscriptionEndDate: freezed == subscriptionEndDate ? _self.subscriptionEndDate : subscriptionEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,isTrial: null == isTrial ? _self.isTrial : isTrial // ignore: cast_nullable_to_non_nullable
as bool,trialEndDate: freezed == trialEndDate ? _self.trialEndDate : trialEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,employeeCount: null == employeeCount ? _self.employeeCount : employeeCount // ignore: cast_nullable_to_non_nullable
as int,annualRevenue: freezed == annualRevenue ? _self.annualRevenue : annualRevenue // ignore: cast_nullable_to_non_nullable
as double?,revenueCurrency: null == revenueCurrency ? _self.revenueCurrency : revenueCurrency // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,documents: null == documents ? _self.documents : documents // ignore: cast_nullable_to_non_nullable
as List<CompanyDocument>,settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as CompanySettings,usageStats: null == usageStats ? _self.usageStats : usageStats // ignore: cast_nullable_to_non_nullable
as CompanyUsageStats,registeredAt: null == registeredAt ? _self.registeredAt : registeredAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,verifiedAt: freezed == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,suspendedAt: freezed == suspendedAt ? _self.suspendedAt : suspendedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,suspensionReason: freezed == suspensionReason ? _self.suspensionReason : suspensionReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Company
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactPersonCopyWith<$Res> get contactPerson {
  
  return $ContactPersonCopyWith<$Res>(_self.contactPerson, (value) {
    return _then(_self.copyWith(contactPerson: value));
  });
}/// Create a copy of Company
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlanCopyWith<$Res>? get subscriptionPlan {
    if (_self.subscriptionPlan == null) {
    return null;
  }

  return $PlanCopyWith<$Res>(_self.subscriptionPlan!, (value) {
    return _then(_self.copyWith(subscriptionPlan: value));
  });
}/// Create a copy of Company
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompanySettingsCopyWith<$Res> get settings {
  
  return $CompanySettingsCopyWith<$Res>(_self.settings, (value) {
    return _then(_self.copyWith(settings: value));
  });
}/// Create a copy of Company
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompanyUsageStatsCopyWith<$Res> get usageStats {
  
  return $CompanyUsageStatsCopyWith<$Res>(_self.usageStats, (value) {
    return _then(_self.copyWith(usageStats: value));
  });
}
}


/// Adds pattern-matching-related methods to [Company].
extension CompanyPatterns on Company {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Company value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Company() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Company value)  $default,){
final _that = this;
switch (_that) {
case _Company():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Company value)?  $default,){
final _that = this;
switch (_that) {
case _Company() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'name')  String name, @JsonKey(name: 'trading_name')  String? tradingName, @JsonKey(name: 'registration_number')  String registrationNumber, @JsonKey(name: 'tax_id')  String? taxId, @JsonKey(name: 'type')  CompanyType type, @JsonKey(name: 'industry')  IndustryType industry, @JsonKey(name: 'country')  String country, @JsonKey(name: 'city')  String city, @JsonKey(name: 'address')  String address, @JsonKey(name: 'postal_code')  String? postalCode, @JsonKey(name: 'phone')  String phone, @JsonKey(name: 'email')  String email, @JsonKey(name: 'website')  String? website, @JsonKey(name: 'status')  CompanyStatus status, @JsonKey(name: 'verification_status')  VerificationStatus verificationStatus, @JsonKey(name: 'contact_person')  ContactPerson contactPerson, @JsonKey(name: 'subscription_plan')  Plan? subscriptionPlan, @JsonKey(name: 'subscription_id')  String? subscriptionId, @JsonKey(name: 'billing_cycle')  BillingCycle billingCycle, @JsonKey(name: 'subscription_start_date')  DateTime? subscriptionStartDate, @JsonKey(name: 'subscription_end_date')  DateTime? subscriptionEndDate, @JsonKey(name: 'is_trial')  bool isTrial, @JsonKey(name: 'trial_end_date')  DateTime? trialEndDate, @JsonKey(name: 'employee_count')  int employeeCount, @JsonKey(name: 'annual_revenue')  double? annualRevenue, @JsonKey(name: 'revenue_currency')  String revenueCurrency, @JsonKey(name: 'notes')  String? notes, @JsonKey(name: 'tags')  List<String> tags, @JsonKey(name: 'documents')  List<CompanyDocument> documents, @JsonKey(name: 'settings')  CompanySettings settings, @JsonKey(name: 'usage_stats')  CompanyUsageStats usageStats, @JsonKey(name: 'registered_at')  DateTime registeredAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'verified_at')  DateTime? verifiedAt, @JsonKey(name: 'suspended_at')  DateTime? suspendedAt, @JsonKey(name: 'suspension_reason')  String? suspensionReason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Company() when $default != null:
return $default(_that.id,_that.name,_that.tradingName,_that.registrationNumber,_that.taxId,_that.type,_that.industry,_that.country,_that.city,_that.address,_that.postalCode,_that.phone,_that.email,_that.website,_that.status,_that.verificationStatus,_that.contactPerson,_that.subscriptionPlan,_that.subscriptionId,_that.billingCycle,_that.subscriptionStartDate,_that.subscriptionEndDate,_that.isTrial,_that.trialEndDate,_that.employeeCount,_that.annualRevenue,_that.revenueCurrency,_that.notes,_that.tags,_that.documents,_that.settings,_that.usageStats,_that.registeredAt,_that.updatedAt,_that.verifiedAt,_that.suspendedAt,_that.suspensionReason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'name')  String name, @JsonKey(name: 'trading_name')  String? tradingName, @JsonKey(name: 'registration_number')  String registrationNumber, @JsonKey(name: 'tax_id')  String? taxId, @JsonKey(name: 'type')  CompanyType type, @JsonKey(name: 'industry')  IndustryType industry, @JsonKey(name: 'country')  String country, @JsonKey(name: 'city')  String city, @JsonKey(name: 'address')  String address, @JsonKey(name: 'postal_code')  String? postalCode, @JsonKey(name: 'phone')  String phone, @JsonKey(name: 'email')  String email, @JsonKey(name: 'website')  String? website, @JsonKey(name: 'status')  CompanyStatus status, @JsonKey(name: 'verification_status')  VerificationStatus verificationStatus, @JsonKey(name: 'contact_person')  ContactPerson contactPerson, @JsonKey(name: 'subscription_plan')  Plan? subscriptionPlan, @JsonKey(name: 'subscription_id')  String? subscriptionId, @JsonKey(name: 'billing_cycle')  BillingCycle billingCycle, @JsonKey(name: 'subscription_start_date')  DateTime? subscriptionStartDate, @JsonKey(name: 'subscription_end_date')  DateTime? subscriptionEndDate, @JsonKey(name: 'is_trial')  bool isTrial, @JsonKey(name: 'trial_end_date')  DateTime? trialEndDate, @JsonKey(name: 'employee_count')  int employeeCount, @JsonKey(name: 'annual_revenue')  double? annualRevenue, @JsonKey(name: 'revenue_currency')  String revenueCurrency, @JsonKey(name: 'notes')  String? notes, @JsonKey(name: 'tags')  List<String> tags, @JsonKey(name: 'documents')  List<CompanyDocument> documents, @JsonKey(name: 'settings')  CompanySettings settings, @JsonKey(name: 'usage_stats')  CompanyUsageStats usageStats, @JsonKey(name: 'registered_at')  DateTime registeredAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'verified_at')  DateTime? verifiedAt, @JsonKey(name: 'suspended_at')  DateTime? suspendedAt, @JsonKey(name: 'suspension_reason')  String? suspensionReason)  $default,) {final _that = this;
switch (_that) {
case _Company():
return $default(_that.id,_that.name,_that.tradingName,_that.registrationNumber,_that.taxId,_that.type,_that.industry,_that.country,_that.city,_that.address,_that.postalCode,_that.phone,_that.email,_that.website,_that.status,_that.verificationStatus,_that.contactPerson,_that.subscriptionPlan,_that.subscriptionId,_that.billingCycle,_that.subscriptionStartDate,_that.subscriptionEndDate,_that.isTrial,_that.trialEndDate,_that.employeeCount,_that.annualRevenue,_that.revenueCurrency,_that.notes,_that.tags,_that.documents,_that.settings,_that.usageStats,_that.registeredAt,_that.updatedAt,_that.verifiedAt,_that.suspendedAt,_that.suspensionReason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'name')  String name, @JsonKey(name: 'trading_name')  String? tradingName, @JsonKey(name: 'registration_number')  String registrationNumber, @JsonKey(name: 'tax_id')  String? taxId, @JsonKey(name: 'type')  CompanyType type, @JsonKey(name: 'industry')  IndustryType industry, @JsonKey(name: 'country')  String country, @JsonKey(name: 'city')  String city, @JsonKey(name: 'address')  String address, @JsonKey(name: 'postal_code')  String? postalCode, @JsonKey(name: 'phone')  String phone, @JsonKey(name: 'email')  String email, @JsonKey(name: 'website')  String? website, @JsonKey(name: 'status')  CompanyStatus status, @JsonKey(name: 'verification_status')  VerificationStatus verificationStatus, @JsonKey(name: 'contact_person')  ContactPerson contactPerson, @JsonKey(name: 'subscription_plan')  Plan? subscriptionPlan, @JsonKey(name: 'subscription_id')  String? subscriptionId, @JsonKey(name: 'billing_cycle')  BillingCycle billingCycle, @JsonKey(name: 'subscription_start_date')  DateTime? subscriptionStartDate, @JsonKey(name: 'subscription_end_date')  DateTime? subscriptionEndDate, @JsonKey(name: 'is_trial')  bool isTrial, @JsonKey(name: 'trial_end_date')  DateTime? trialEndDate, @JsonKey(name: 'employee_count')  int employeeCount, @JsonKey(name: 'annual_revenue')  double? annualRevenue, @JsonKey(name: 'revenue_currency')  String revenueCurrency, @JsonKey(name: 'notes')  String? notes, @JsonKey(name: 'tags')  List<String> tags, @JsonKey(name: 'documents')  List<CompanyDocument> documents, @JsonKey(name: 'settings')  CompanySettings settings, @JsonKey(name: 'usage_stats')  CompanyUsageStats usageStats, @JsonKey(name: 'registered_at')  DateTime registeredAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'verified_at')  DateTime? verifiedAt, @JsonKey(name: 'suspended_at')  DateTime? suspendedAt, @JsonKey(name: 'suspension_reason')  String? suspensionReason)?  $default,) {final _that = this;
switch (_that) {
case _Company() when $default != null:
return $default(_that.id,_that.name,_that.tradingName,_that.registrationNumber,_that.taxId,_that.type,_that.industry,_that.country,_that.city,_that.address,_that.postalCode,_that.phone,_that.email,_that.website,_that.status,_that.verificationStatus,_that.contactPerson,_that.subscriptionPlan,_that.subscriptionId,_that.billingCycle,_that.subscriptionStartDate,_that.subscriptionEndDate,_that.isTrial,_that.trialEndDate,_that.employeeCount,_that.annualRevenue,_that.revenueCurrency,_that.notes,_that.tags,_that.documents,_that.settings,_that.usageStats,_that.registeredAt,_that.updatedAt,_that.verifiedAt,_that.suspendedAt,_that.suspensionReason);case _:
  return null;

}
}

}

/// @nodoc


class _Company extends Company {
  const _Company({@JsonKey(name: 'id') required this.id, @JsonKey(name: 'name') required this.name, @JsonKey(name: 'trading_name') this.tradingName, @JsonKey(name: 'registration_number') required this.registrationNumber, @JsonKey(name: 'tax_id') this.taxId, @JsonKey(name: 'type') required this.type, @JsonKey(name: 'industry') required this.industry, @JsonKey(name: 'country') required this.country, @JsonKey(name: 'city') required this.city, @JsonKey(name: 'address') required this.address, @JsonKey(name: 'postal_code') this.postalCode, @JsonKey(name: 'phone') required this.phone, @JsonKey(name: 'email') required this.email, @JsonKey(name: 'website') this.website, @JsonKey(name: 'status') this.status = CompanyStatus.pending, @JsonKey(name: 'verification_status') this.verificationStatus = VerificationStatus.notSubmitted, @JsonKey(name: 'contact_person') required this.contactPerson, @JsonKey(name: 'subscription_plan') this.subscriptionPlan, @JsonKey(name: 'subscription_id') this.subscriptionId, @JsonKey(name: 'billing_cycle') this.billingCycle = BillingCycle.monthly, @JsonKey(name: 'subscription_start_date') this.subscriptionStartDate, @JsonKey(name: 'subscription_end_date') this.subscriptionEndDate, @JsonKey(name: 'is_trial') this.isTrial = false, @JsonKey(name: 'trial_end_date') this.trialEndDate, @JsonKey(name: 'employee_count') this.employeeCount = 0, @JsonKey(name: 'annual_revenue') this.annualRevenue, @JsonKey(name: 'revenue_currency') this.revenueCurrency = 'USD', @JsonKey(name: 'notes') this.notes, @JsonKey(name: 'tags') final  List<String> tags = const [], @JsonKey(name: 'documents') final  List<CompanyDocument> documents = const [], @JsonKey(name: 'settings') this.settings = const CompanySettings(), @JsonKey(name: 'usage_stats') this.usageStats = const CompanyUsageStats(), @JsonKey(name: 'registered_at') required this.registeredAt, @JsonKey(name: 'updated_at') required this.updatedAt, @JsonKey(name: 'verified_at') this.verifiedAt, @JsonKey(name: 'suspended_at') this.suspendedAt, @JsonKey(name: 'suspension_reason') this.suspensionReason}): _tags = tags,_documents = documents,super._();
  

/// Unique identifier for the company
@override@JsonKey(name: 'id') final  String id;
/// Official company name
@override@JsonKey(name: 'name') final  String name;
/// Trading name (if different from official name)
@override@JsonKey(name: 'trading_name') final  String? tradingName;
/// Company registration number
@override@JsonKey(name: 'registration_number') final  String registrationNumber;
/// Tax ID/VAT number
@override@JsonKey(name: 'tax_id') final  String? taxId;
/// Type of company
@override@JsonKey(name: 'type') final  CompanyType type;
/// Industry type
@override@JsonKey(name: 'industry') final  IndustryType industry;
/// Country where company is registered
@override@JsonKey(name: 'country') final  String country;
/// City where company is located
@override@JsonKey(name: 'city') final  String city;
/// Full address of the company
@override@JsonKey(name: 'address') final  String address;
/// Postal/ZIP code
@override@JsonKey(name: 'postal_code') final  String? postalCode;
/// Primary phone number
@override@JsonKey(name: 'phone') final  String phone;
/// Primary email address
@override@JsonKey(name: 'email') final  String email;
/// Company website
@override@JsonKey(name: 'website') final  String? website;
/// Status of the company
@override@JsonKey(name: 'status') final  CompanyStatus status;
/// Verification status
@override@JsonKey(name: 'verification_status') final  VerificationStatus verificationStatus;
/// Contact person information
@override@JsonKey(name: 'contact_person') final  ContactPerson contactPerson;
/// Subscription plan assigned to the company
@override@JsonKey(name: 'subscription_plan') final  Plan? subscriptionPlan;
/// Subscription ID (if subscribed)
@override@JsonKey(name: 'subscription_id') final  String? subscriptionId;
/// Billing cycle (monthly/yearly)
@override@JsonKey(name: 'billing_cycle') final  BillingCycle billingCycle;
/// Date when subscription started
@override@JsonKey(name: 'subscription_start_date') final  DateTime? subscriptionStartDate;
/// Date when subscription ends/renews
@override@JsonKey(name: 'subscription_end_date') final  DateTime? subscriptionEndDate;
/// Whether the company is on trial
@override@JsonKey(name: 'is_trial') final  bool isTrial;
/// Trial end date (if applicable)
@override@JsonKey(name: 'trial_end_date') final  DateTime? trialEndDate;
/// Number of employees in the company
@override@JsonKey(name: 'employee_count') final  int employeeCount;
/// Annual revenue (optional)
@override@JsonKey(name: 'annual_revenue') final  double? annualRevenue;
/// Currency for revenue
@override@JsonKey(name: 'revenue_currency') final  String revenueCurrency;
/// Notes about the company
@override@JsonKey(name: 'notes') final  String? notes;
/// Tags for categorization
 final  List<String> _tags;
/// Tags for categorization
@override@JsonKey(name: 'tags') List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

/// Documents submitted for verification
 final  List<CompanyDocument> _documents;
/// Documents submitted for verification
@override@JsonKey(name: 'documents') List<CompanyDocument> get documents {
  if (_documents is EqualUnmodifiableListView) return _documents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_documents);
}

/// Settings specific to this company
@override@JsonKey(name: 'settings') final  CompanySettings settings;
/// Usage statistics
@override@JsonKey(name: 'usage_stats') final  CompanyUsageStats usageStats;
/// Date when the company was registered
@override@JsonKey(name: 'registered_at') final  DateTime registeredAt;
/// Date when the company was last updated
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;
/// Date when the company was verified
@override@JsonKey(name: 'verified_at') final  DateTime? verifiedAt;
/// Date when the company was suspended
@override@JsonKey(name: 'suspended_at') final  DateTime? suspendedAt;
/// Reason for suspension
@override@JsonKey(name: 'suspension_reason') final  String? suspensionReason;

/// Create a copy of Company
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompanyCopyWith<_Company> get copyWith => __$CompanyCopyWithImpl<_Company>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Company&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.tradingName, tradingName) || other.tradingName == tradingName)&&(identical(other.registrationNumber, registrationNumber) || other.registrationNumber == registrationNumber)&&(identical(other.taxId, taxId) || other.taxId == taxId)&&(identical(other.type, type) || other.type == type)&&(identical(other.industry, industry) || other.industry == industry)&&(identical(other.country, country) || other.country == country)&&(identical(other.city, city) || other.city == city)&&(identical(other.address, address) || other.address == address)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.website, website) || other.website == website)&&(identical(other.status, status) || other.status == status)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.contactPerson, contactPerson) || other.contactPerson == contactPerson)&&(identical(other.subscriptionPlan, subscriptionPlan) || other.subscriptionPlan == subscriptionPlan)&&(identical(other.subscriptionId, subscriptionId) || other.subscriptionId == subscriptionId)&&(identical(other.billingCycle, billingCycle) || other.billingCycle == billingCycle)&&(identical(other.subscriptionStartDate, subscriptionStartDate) || other.subscriptionStartDate == subscriptionStartDate)&&(identical(other.subscriptionEndDate, subscriptionEndDate) || other.subscriptionEndDate == subscriptionEndDate)&&(identical(other.isTrial, isTrial) || other.isTrial == isTrial)&&(identical(other.trialEndDate, trialEndDate) || other.trialEndDate == trialEndDate)&&(identical(other.employeeCount, employeeCount) || other.employeeCount == employeeCount)&&(identical(other.annualRevenue, annualRevenue) || other.annualRevenue == annualRevenue)&&(identical(other.revenueCurrency, revenueCurrency) || other.revenueCurrency == revenueCurrency)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other._tags, _tags)&&const DeepCollectionEquality().equals(other._documents, _documents)&&(identical(other.settings, settings) || other.settings == settings)&&(identical(other.usageStats, usageStats) || other.usageStats == usageStats)&&(identical(other.registeredAt, registeredAt) || other.registeredAt == registeredAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.suspendedAt, suspendedAt) || other.suspendedAt == suspendedAt)&&(identical(other.suspensionReason, suspensionReason) || other.suspensionReason == suspensionReason));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,name,tradingName,registrationNumber,taxId,type,industry,country,city,address,postalCode,phone,email,website,status,verificationStatus,contactPerson,subscriptionPlan,subscriptionId,billingCycle,subscriptionStartDate,subscriptionEndDate,isTrial,trialEndDate,employeeCount,annualRevenue,revenueCurrency,notes,const DeepCollectionEquality().hash(_tags),const DeepCollectionEquality().hash(_documents),settings,usageStats,registeredAt,updatedAt,verifiedAt,suspendedAt,suspensionReason]);

@override
String toString() {
  return 'Company(id: $id, name: $name, tradingName: $tradingName, registrationNumber: $registrationNumber, taxId: $taxId, type: $type, industry: $industry, country: $country, city: $city, address: $address, postalCode: $postalCode, phone: $phone, email: $email, website: $website, status: $status, verificationStatus: $verificationStatus, contactPerson: $contactPerson, subscriptionPlan: $subscriptionPlan, subscriptionId: $subscriptionId, billingCycle: $billingCycle, subscriptionStartDate: $subscriptionStartDate, subscriptionEndDate: $subscriptionEndDate, isTrial: $isTrial, trialEndDate: $trialEndDate, employeeCount: $employeeCount, annualRevenue: $annualRevenue, revenueCurrency: $revenueCurrency, notes: $notes, tags: $tags, documents: $documents, settings: $settings, usageStats: $usageStats, registeredAt: $registeredAt, updatedAt: $updatedAt, verifiedAt: $verifiedAt, suspendedAt: $suspendedAt, suspensionReason: $suspensionReason)';
}


}

/// @nodoc
abstract mixin class _$CompanyCopyWith<$Res> implements $CompanyCopyWith<$Res> {
  factory _$CompanyCopyWith(_Company value, $Res Function(_Company) _then) = __$CompanyCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id') String id,@JsonKey(name: 'name') String name,@JsonKey(name: 'trading_name') String? tradingName,@JsonKey(name: 'registration_number') String registrationNumber,@JsonKey(name: 'tax_id') String? taxId,@JsonKey(name: 'type') CompanyType type,@JsonKey(name: 'industry') IndustryType industry,@JsonKey(name: 'country') String country,@JsonKey(name: 'city') String city,@JsonKey(name: 'address') String address,@JsonKey(name: 'postal_code') String? postalCode,@JsonKey(name: 'phone') String phone,@JsonKey(name: 'email') String email,@JsonKey(name: 'website') String? website,@JsonKey(name: 'status') CompanyStatus status,@JsonKey(name: 'verification_status') VerificationStatus verificationStatus,@JsonKey(name: 'contact_person') ContactPerson contactPerson,@JsonKey(name: 'subscription_plan') Plan? subscriptionPlan,@JsonKey(name: 'subscription_id') String? subscriptionId,@JsonKey(name: 'billing_cycle') BillingCycle billingCycle,@JsonKey(name: 'subscription_start_date') DateTime? subscriptionStartDate,@JsonKey(name: 'subscription_end_date') DateTime? subscriptionEndDate,@JsonKey(name: 'is_trial') bool isTrial,@JsonKey(name: 'trial_end_date') DateTime? trialEndDate,@JsonKey(name: 'employee_count') int employeeCount,@JsonKey(name: 'annual_revenue') double? annualRevenue,@JsonKey(name: 'revenue_currency') String revenueCurrency,@JsonKey(name: 'notes') String? notes,@JsonKey(name: 'tags') List<String> tags,@JsonKey(name: 'documents') List<CompanyDocument> documents,@JsonKey(name: 'settings') CompanySettings settings,@JsonKey(name: 'usage_stats') CompanyUsageStats usageStats,@JsonKey(name: 'registered_at') DateTime registeredAt,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'verified_at') DateTime? verifiedAt,@JsonKey(name: 'suspended_at') DateTime? suspendedAt,@JsonKey(name: 'suspension_reason') String? suspensionReason
});


@override $ContactPersonCopyWith<$Res> get contactPerson;@override $PlanCopyWith<$Res>? get subscriptionPlan;@override $CompanySettingsCopyWith<$Res> get settings;@override $CompanyUsageStatsCopyWith<$Res> get usageStats;

}
/// @nodoc
class __$CompanyCopyWithImpl<$Res>
    implements _$CompanyCopyWith<$Res> {
  __$CompanyCopyWithImpl(this._self, this._then);

  final _Company _self;
  final $Res Function(_Company) _then;

/// Create a copy of Company
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? tradingName = freezed,Object? registrationNumber = null,Object? taxId = freezed,Object? type = null,Object? industry = null,Object? country = null,Object? city = null,Object? address = null,Object? postalCode = freezed,Object? phone = null,Object? email = null,Object? website = freezed,Object? status = null,Object? verificationStatus = null,Object? contactPerson = null,Object? subscriptionPlan = freezed,Object? subscriptionId = freezed,Object? billingCycle = null,Object? subscriptionStartDate = freezed,Object? subscriptionEndDate = freezed,Object? isTrial = null,Object? trialEndDate = freezed,Object? employeeCount = null,Object? annualRevenue = freezed,Object? revenueCurrency = null,Object? notes = freezed,Object? tags = null,Object? documents = null,Object? settings = null,Object? usageStats = null,Object? registeredAt = null,Object? updatedAt = null,Object? verifiedAt = freezed,Object? suspendedAt = freezed,Object? suspensionReason = freezed,}) {
  return _then(_Company(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,tradingName: freezed == tradingName ? _self.tradingName : tradingName // ignore: cast_nullable_to_non_nullable
as String?,registrationNumber: null == registrationNumber ? _self.registrationNumber : registrationNumber // ignore: cast_nullable_to_non_nullable
as String,taxId: freezed == taxId ? _self.taxId : taxId // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CompanyType,industry: null == industry ? _self.industry : industry // ignore: cast_nullable_to_non_nullable
as IndustryType,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,postalCode: freezed == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String?,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CompanyStatus,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as VerificationStatus,contactPerson: null == contactPerson ? _self.contactPerson : contactPerson // ignore: cast_nullable_to_non_nullable
as ContactPerson,subscriptionPlan: freezed == subscriptionPlan ? _self.subscriptionPlan : subscriptionPlan // ignore: cast_nullable_to_non_nullable
as Plan?,subscriptionId: freezed == subscriptionId ? _self.subscriptionId : subscriptionId // ignore: cast_nullable_to_non_nullable
as String?,billingCycle: null == billingCycle ? _self.billingCycle : billingCycle // ignore: cast_nullable_to_non_nullable
as BillingCycle,subscriptionStartDate: freezed == subscriptionStartDate ? _self.subscriptionStartDate : subscriptionStartDate // ignore: cast_nullable_to_non_nullable
as DateTime?,subscriptionEndDate: freezed == subscriptionEndDate ? _self.subscriptionEndDate : subscriptionEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,isTrial: null == isTrial ? _self.isTrial : isTrial // ignore: cast_nullable_to_non_nullable
as bool,trialEndDate: freezed == trialEndDate ? _self.trialEndDate : trialEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,employeeCount: null == employeeCount ? _self.employeeCount : employeeCount // ignore: cast_nullable_to_non_nullable
as int,annualRevenue: freezed == annualRevenue ? _self.annualRevenue : annualRevenue // ignore: cast_nullable_to_non_nullable
as double?,revenueCurrency: null == revenueCurrency ? _self.revenueCurrency : revenueCurrency // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,documents: null == documents ? _self._documents : documents // ignore: cast_nullable_to_non_nullable
as List<CompanyDocument>,settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as CompanySettings,usageStats: null == usageStats ? _self.usageStats : usageStats // ignore: cast_nullable_to_non_nullable
as CompanyUsageStats,registeredAt: null == registeredAt ? _self.registeredAt : registeredAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,verifiedAt: freezed == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,suspendedAt: freezed == suspendedAt ? _self.suspendedAt : suspendedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,suspensionReason: freezed == suspensionReason ? _self.suspensionReason : suspensionReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Company
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactPersonCopyWith<$Res> get contactPerson {
  
  return $ContactPersonCopyWith<$Res>(_self.contactPerson, (value) {
    return _then(_self.copyWith(contactPerson: value));
  });
}/// Create a copy of Company
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlanCopyWith<$Res>? get subscriptionPlan {
    if (_self.subscriptionPlan == null) {
    return null;
  }

  return $PlanCopyWith<$Res>(_self.subscriptionPlan!, (value) {
    return _then(_self.copyWith(subscriptionPlan: value));
  });
}/// Create a copy of Company
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompanySettingsCopyWith<$Res> get settings {
  
  return $CompanySettingsCopyWith<$Res>(_self.settings, (value) {
    return _then(_self.copyWith(settings: value));
  });
}/// Create a copy of Company
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompanyUsageStatsCopyWith<$Res> get usageStats {
  
  return $CompanyUsageStatsCopyWith<$Res>(_self.usageStats, (value) {
    return _then(_self.copyWith(usageStats: value));
  });
}
}

/// @nodoc
mixin _$ContactPerson {

/// Full name of the contact person
@JsonKey(name: 'full_name') String get fullName;/// Position/title of the contact person
@JsonKey(name: 'position') String get position;/// Email address of the contact person
@JsonKey(name: 'email') String get email;/// Phone number of the contact person
@JsonKey(name: 'phone') String get phone;/// Whether this is the primary contact
@JsonKey(name: 'is_primary') bool get isPrimary;/// Additional contact information
@JsonKey(name: 'additional_info') String? get additionalInfo;
/// Create a copy of ContactPerson
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContactPersonCopyWith<ContactPerson> get copyWith => _$ContactPersonCopyWithImpl<ContactPerson>(this as ContactPerson, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContactPerson&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.position, position) || other.position == position)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.additionalInfo, additionalInfo) || other.additionalInfo == additionalInfo));
}


@override
int get hashCode => Object.hash(runtimeType,fullName,position,email,phone,isPrimary,additionalInfo);

@override
String toString() {
  return 'ContactPerson(fullName: $fullName, position: $position, email: $email, phone: $phone, isPrimary: $isPrimary, additionalInfo: $additionalInfo)';
}


}

/// @nodoc
abstract mixin class $ContactPersonCopyWith<$Res>  {
  factory $ContactPersonCopyWith(ContactPerson value, $Res Function(ContactPerson) _then) = _$ContactPersonCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'full_name') String fullName,@JsonKey(name: 'position') String position,@JsonKey(name: 'email') String email,@JsonKey(name: 'phone') String phone,@JsonKey(name: 'is_primary') bool isPrimary,@JsonKey(name: 'additional_info') String? additionalInfo
});




}
/// @nodoc
class _$ContactPersonCopyWithImpl<$Res>
    implements $ContactPersonCopyWith<$Res> {
  _$ContactPersonCopyWithImpl(this._self, this._then);

  final ContactPerson _self;
  final $Res Function(ContactPerson) _then;

/// Create a copy of ContactPerson
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fullName = null,Object? position = null,Object? email = null,Object? phone = null,Object? isPrimary = null,Object? additionalInfo = freezed,}) {
  return _then(_self.copyWith(
fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,additionalInfo: freezed == additionalInfo ? _self.additionalInfo : additionalInfo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ContactPerson].
extension ContactPersonPatterns on ContactPerson {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContactPerson value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContactPerson() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContactPerson value)  $default,){
final _that = this;
switch (_that) {
case _ContactPerson():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContactPerson value)?  $default,){
final _that = this;
switch (_that) {
case _ContactPerson() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'position')  String position, @JsonKey(name: 'email')  String email, @JsonKey(name: 'phone')  String phone, @JsonKey(name: 'is_primary')  bool isPrimary, @JsonKey(name: 'additional_info')  String? additionalInfo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContactPerson() when $default != null:
return $default(_that.fullName,_that.position,_that.email,_that.phone,_that.isPrimary,_that.additionalInfo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'position')  String position, @JsonKey(name: 'email')  String email, @JsonKey(name: 'phone')  String phone, @JsonKey(name: 'is_primary')  bool isPrimary, @JsonKey(name: 'additional_info')  String? additionalInfo)  $default,) {final _that = this;
switch (_that) {
case _ContactPerson():
return $default(_that.fullName,_that.position,_that.email,_that.phone,_that.isPrimary,_that.additionalInfo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'position')  String position, @JsonKey(name: 'email')  String email, @JsonKey(name: 'phone')  String phone, @JsonKey(name: 'is_primary')  bool isPrimary, @JsonKey(name: 'additional_info')  String? additionalInfo)?  $default,) {final _that = this;
switch (_that) {
case _ContactPerson() when $default != null:
return $default(_that.fullName,_that.position,_that.email,_that.phone,_that.isPrimary,_that.additionalInfo);case _:
  return null;

}
}

}

/// @nodoc


class _ContactPerson extends ContactPerson {
  const _ContactPerson({@JsonKey(name: 'full_name') required this.fullName, @JsonKey(name: 'position') required this.position, @JsonKey(name: 'email') required this.email, @JsonKey(name: 'phone') required this.phone, @JsonKey(name: 'is_primary') this.isPrimary = true, @JsonKey(name: 'additional_info') this.additionalInfo}): super._();
  

/// Full name of the contact person
@override@JsonKey(name: 'full_name') final  String fullName;
/// Position/title of the contact person
@override@JsonKey(name: 'position') final  String position;
/// Email address of the contact person
@override@JsonKey(name: 'email') final  String email;
/// Phone number of the contact person
@override@JsonKey(name: 'phone') final  String phone;
/// Whether this is the primary contact
@override@JsonKey(name: 'is_primary') final  bool isPrimary;
/// Additional contact information
@override@JsonKey(name: 'additional_info') final  String? additionalInfo;

/// Create a copy of ContactPerson
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContactPersonCopyWith<_ContactPerson> get copyWith => __$ContactPersonCopyWithImpl<_ContactPerson>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContactPerson&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.position, position) || other.position == position)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.additionalInfo, additionalInfo) || other.additionalInfo == additionalInfo));
}


@override
int get hashCode => Object.hash(runtimeType,fullName,position,email,phone,isPrimary,additionalInfo);

@override
String toString() {
  return 'ContactPerson(fullName: $fullName, position: $position, email: $email, phone: $phone, isPrimary: $isPrimary, additionalInfo: $additionalInfo)';
}


}

/// @nodoc
abstract mixin class _$ContactPersonCopyWith<$Res> implements $ContactPersonCopyWith<$Res> {
  factory _$ContactPersonCopyWith(_ContactPerson value, $Res Function(_ContactPerson) _then) = __$ContactPersonCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'full_name') String fullName,@JsonKey(name: 'position') String position,@JsonKey(name: 'email') String email,@JsonKey(name: 'phone') String phone,@JsonKey(name: 'is_primary') bool isPrimary,@JsonKey(name: 'additional_info') String? additionalInfo
});




}
/// @nodoc
class __$ContactPersonCopyWithImpl<$Res>
    implements _$ContactPersonCopyWith<$Res> {
  __$ContactPersonCopyWithImpl(this._self, this._then);

  final _ContactPerson _self;
  final $Res Function(_ContactPerson) _then;

/// Create a copy of ContactPerson
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fullName = null,Object? position = null,Object? email = null,Object? phone = null,Object? isPrimary = null,Object? additionalInfo = freezed,}) {
  return _then(_ContactPerson(
fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,additionalInfo: freezed == additionalInfo ? _self.additionalInfo : additionalInfo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$CompanyDocument {

/// Unique identifier for the document
@JsonKey(name: 'id') String get id;/// Type of document
@JsonKey(name: 'type') DocumentType get type;/// Name of the document
@JsonKey(name: 'name') String get name;/// Description of the document
@JsonKey(name: 'description') String? get description;/// File URL/path
@JsonKey(name: 'file_url') String get fileUrl;/// File size in bytes
@JsonKey(name: 'file_size') int? get fileSize;/// File MIME type
@JsonKey(name: 'mime_type') String? get mimeType;/// Status of the document verification
@JsonKey(name: 'status') DocumentStatus get status;/// Rejection reason (if rejected)
@JsonKey(name: 'rejection_reason') String? get rejectionReason;/// Verified by (admin user ID)
@JsonKey(name: 'verified_by') String? get verifiedBy;/// Date when document was uploaded
@JsonKey(name: 'uploaded_at') DateTime get uploadedAt;/// Date when document was verified
@JsonKey(name: 'verified_at') DateTime? get verifiedAt;/// Expiry date of the document (if applicable)
@JsonKey(name: 'expiry_date') DateTime? get expiryDate;
/// Create a copy of CompanyDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompanyDocumentCopyWith<CompanyDocument> get copyWith => _$CompanyDocumentCopyWithImpl<CompanyDocument>(this as CompanyDocument, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompanyDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.status, status) || other.status == status)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.verifiedBy, verifiedBy) || other.verifiedBy == verifiedBy)&&(identical(other.uploadedAt, uploadedAt) || other.uploadedAt == uploadedAt)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate));
}


@override
int get hashCode => Object.hash(runtimeType,id,type,name,description,fileUrl,fileSize,mimeType,status,rejectionReason,verifiedBy,uploadedAt,verifiedAt,expiryDate);

@override
String toString() {
  return 'CompanyDocument(id: $id, type: $type, name: $name, description: $description, fileUrl: $fileUrl, fileSize: $fileSize, mimeType: $mimeType, status: $status, rejectionReason: $rejectionReason, verifiedBy: $verifiedBy, uploadedAt: $uploadedAt, verifiedAt: $verifiedAt, expiryDate: $expiryDate)';
}


}

/// @nodoc
abstract mixin class $CompanyDocumentCopyWith<$Res>  {
  factory $CompanyDocumentCopyWith(CompanyDocument value, $Res Function(CompanyDocument) _then) = _$CompanyDocumentCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id') String id,@JsonKey(name: 'type') DocumentType type,@JsonKey(name: 'name') String name,@JsonKey(name: 'description') String? description,@JsonKey(name: 'file_url') String fileUrl,@JsonKey(name: 'file_size') int? fileSize,@JsonKey(name: 'mime_type') String? mimeType,@JsonKey(name: 'status') DocumentStatus status,@JsonKey(name: 'rejection_reason') String? rejectionReason,@JsonKey(name: 'verified_by') String? verifiedBy,@JsonKey(name: 'uploaded_at') DateTime uploadedAt,@JsonKey(name: 'verified_at') DateTime? verifiedAt,@JsonKey(name: 'expiry_date') DateTime? expiryDate
});




}
/// @nodoc
class _$CompanyDocumentCopyWithImpl<$Res>
    implements $CompanyDocumentCopyWith<$Res> {
  _$CompanyDocumentCopyWithImpl(this._self, this._then);

  final CompanyDocument _self;
  final $Res Function(CompanyDocument) _then;

/// Create a copy of CompanyDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? name = null,Object? description = freezed,Object? fileUrl = null,Object? fileSize = freezed,Object? mimeType = freezed,Object? status = null,Object? rejectionReason = freezed,Object? verifiedBy = freezed,Object? uploadedAt = null,Object? verifiedAt = freezed,Object? expiryDate = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DocumentType,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,fileUrl: null == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String,fileSize: freezed == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int?,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DocumentStatus,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,verifiedBy: freezed == verifiedBy ? _self.verifiedBy : verifiedBy // ignore: cast_nullable_to_non_nullable
as String?,uploadedAt: null == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as DateTime,verifiedAt: freezed == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CompanyDocument].
extension CompanyDocumentPatterns on CompanyDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CompanyDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompanyDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CompanyDocument value)  $default,){
final _that = this;
switch (_that) {
case _CompanyDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CompanyDocument value)?  $default,){
final _that = this;
switch (_that) {
case _CompanyDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'type')  DocumentType type, @JsonKey(name: 'name')  String name, @JsonKey(name: 'description')  String? description, @JsonKey(name: 'file_url')  String fileUrl, @JsonKey(name: 'file_size')  int? fileSize, @JsonKey(name: 'mime_type')  String? mimeType, @JsonKey(name: 'status')  DocumentStatus status, @JsonKey(name: 'rejection_reason')  String? rejectionReason, @JsonKey(name: 'verified_by')  String? verifiedBy, @JsonKey(name: 'uploaded_at')  DateTime uploadedAt, @JsonKey(name: 'verified_at')  DateTime? verifiedAt, @JsonKey(name: 'expiry_date')  DateTime? expiryDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CompanyDocument() when $default != null:
return $default(_that.id,_that.type,_that.name,_that.description,_that.fileUrl,_that.fileSize,_that.mimeType,_that.status,_that.rejectionReason,_that.verifiedBy,_that.uploadedAt,_that.verifiedAt,_that.expiryDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'type')  DocumentType type, @JsonKey(name: 'name')  String name, @JsonKey(name: 'description')  String? description, @JsonKey(name: 'file_url')  String fileUrl, @JsonKey(name: 'file_size')  int? fileSize, @JsonKey(name: 'mime_type')  String? mimeType, @JsonKey(name: 'status')  DocumentStatus status, @JsonKey(name: 'rejection_reason')  String? rejectionReason, @JsonKey(name: 'verified_by')  String? verifiedBy, @JsonKey(name: 'uploaded_at')  DateTime uploadedAt, @JsonKey(name: 'verified_at')  DateTime? verifiedAt, @JsonKey(name: 'expiry_date')  DateTime? expiryDate)  $default,) {final _that = this;
switch (_that) {
case _CompanyDocument():
return $default(_that.id,_that.type,_that.name,_that.description,_that.fileUrl,_that.fileSize,_that.mimeType,_that.status,_that.rejectionReason,_that.verifiedBy,_that.uploadedAt,_that.verifiedAt,_that.expiryDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'type')  DocumentType type, @JsonKey(name: 'name')  String name, @JsonKey(name: 'description')  String? description, @JsonKey(name: 'file_url')  String fileUrl, @JsonKey(name: 'file_size')  int? fileSize, @JsonKey(name: 'mime_type')  String? mimeType, @JsonKey(name: 'status')  DocumentStatus status, @JsonKey(name: 'rejection_reason')  String? rejectionReason, @JsonKey(name: 'verified_by')  String? verifiedBy, @JsonKey(name: 'uploaded_at')  DateTime uploadedAt, @JsonKey(name: 'verified_at')  DateTime? verifiedAt, @JsonKey(name: 'expiry_date')  DateTime? expiryDate)?  $default,) {final _that = this;
switch (_that) {
case _CompanyDocument() when $default != null:
return $default(_that.id,_that.type,_that.name,_that.description,_that.fileUrl,_that.fileSize,_that.mimeType,_that.status,_that.rejectionReason,_that.verifiedBy,_that.uploadedAt,_that.verifiedAt,_that.expiryDate);case _:
  return null;

}
}

}

/// @nodoc


class _CompanyDocument extends CompanyDocument {
  const _CompanyDocument({@JsonKey(name: 'id') required this.id, @JsonKey(name: 'type') required this.type, @JsonKey(name: 'name') required this.name, @JsonKey(name: 'description') this.description, @JsonKey(name: 'file_url') required this.fileUrl, @JsonKey(name: 'file_size') this.fileSize, @JsonKey(name: 'mime_type') this.mimeType, @JsonKey(name: 'status') this.status = DocumentStatus.pending, @JsonKey(name: 'rejection_reason') this.rejectionReason, @JsonKey(name: 'verified_by') this.verifiedBy, @JsonKey(name: 'uploaded_at') required this.uploadedAt, @JsonKey(name: 'verified_at') this.verifiedAt, @JsonKey(name: 'expiry_date') this.expiryDate}): super._();
  

/// Unique identifier for the document
@override@JsonKey(name: 'id') final  String id;
/// Type of document
@override@JsonKey(name: 'type') final  DocumentType type;
/// Name of the document
@override@JsonKey(name: 'name') final  String name;
/// Description of the document
@override@JsonKey(name: 'description') final  String? description;
/// File URL/path
@override@JsonKey(name: 'file_url') final  String fileUrl;
/// File size in bytes
@override@JsonKey(name: 'file_size') final  int? fileSize;
/// File MIME type
@override@JsonKey(name: 'mime_type') final  String? mimeType;
/// Status of the document verification
@override@JsonKey(name: 'status') final  DocumentStatus status;
/// Rejection reason (if rejected)
@override@JsonKey(name: 'rejection_reason') final  String? rejectionReason;
/// Verified by (admin user ID)
@override@JsonKey(name: 'verified_by') final  String? verifiedBy;
/// Date when document was uploaded
@override@JsonKey(name: 'uploaded_at') final  DateTime uploadedAt;
/// Date when document was verified
@override@JsonKey(name: 'verified_at') final  DateTime? verifiedAt;
/// Expiry date of the document (if applicable)
@override@JsonKey(name: 'expiry_date') final  DateTime? expiryDate;

/// Create a copy of CompanyDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompanyDocumentCopyWith<_CompanyDocument> get copyWith => __$CompanyDocumentCopyWithImpl<_CompanyDocument>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompanyDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.status, status) || other.status == status)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.verifiedBy, verifiedBy) || other.verifiedBy == verifiedBy)&&(identical(other.uploadedAt, uploadedAt) || other.uploadedAt == uploadedAt)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate));
}


@override
int get hashCode => Object.hash(runtimeType,id,type,name,description,fileUrl,fileSize,mimeType,status,rejectionReason,verifiedBy,uploadedAt,verifiedAt,expiryDate);

@override
String toString() {
  return 'CompanyDocument(id: $id, type: $type, name: $name, description: $description, fileUrl: $fileUrl, fileSize: $fileSize, mimeType: $mimeType, status: $status, rejectionReason: $rejectionReason, verifiedBy: $verifiedBy, uploadedAt: $uploadedAt, verifiedAt: $verifiedAt, expiryDate: $expiryDate)';
}


}

/// @nodoc
abstract mixin class _$CompanyDocumentCopyWith<$Res> implements $CompanyDocumentCopyWith<$Res> {
  factory _$CompanyDocumentCopyWith(_CompanyDocument value, $Res Function(_CompanyDocument) _then) = __$CompanyDocumentCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id') String id,@JsonKey(name: 'type') DocumentType type,@JsonKey(name: 'name') String name,@JsonKey(name: 'description') String? description,@JsonKey(name: 'file_url') String fileUrl,@JsonKey(name: 'file_size') int? fileSize,@JsonKey(name: 'mime_type') String? mimeType,@JsonKey(name: 'status') DocumentStatus status,@JsonKey(name: 'rejection_reason') String? rejectionReason,@JsonKey(name: 'verified_by') String? verifiedBy,@JsonKey(name: 'uploaded_at') DateTime uploadedAt,@JsonKey(name: 'verified_at') DateTime? verifiedAt,@JsonKey(name: 'expiry_date') DateTime? expiryDate
});




}
/// @nodoc
class __$CompanyDocumentCopyWithImpl<$Res>
    implements _$CompanyDocumentCopyWith<$Res> {
  __$CompanyDocumentCopyWithImpl(this._self, this._then);

  final _CompanyDocument _self;
  final $Res Function(_CompanyDocument) _then;

/// Create a copy of CompanyDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? name = null,Object? description = freezed,Object? fileUrl = null,Object? fileSize = freezed,Object? mimeType = freezed,Object? status = null,Object? rejectionReason = freezed,Object? verifiedBy = freezed,Object? uploadedAt = null,Object? verifiedAt = freezed,Object? expiryDate = freezed,}) {
  return _then(_CompanyDocument(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DocumentType,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,fileUrl: null == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String,fileSize: freezed == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int?,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DocumentStatus,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,verifiedBy: freezed == verifiedBy ? _self.verifiedBy : verifiedBy // ignore: cast_nullable_to_non_nullable
as String?,uploadedAt: null == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as DateTime,verifiedAt: freezed == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$CompanySettings {

/// Whether email notifications are enabled
@JsonKey(name: 'email_notifications') bool get emailNotifications;/// Whether SMS notifications are enabled
@JsonKey(name: 'sms_notifications') bool get smsNotifications;/// Whether auto-renewal is enabled
@JsonKey(name: 'auto_renewal') bool get autoRenewal;/// Invoice payment terms (in days)
@JsonKey(name: 'payment_terms') int get paymentTerms;/// Preferred language
@JsonKey(name: 'preferred_language') String get preferredLanguage;/// Timezone
@JsonKey(name: 'timezone') String get timezone;/// Currency for billing
@JsonKey(name: 'billing_currency') String get billingCurrency;/// Tax rate percentage
@JsonKey(name: 'tax_rate') double get taxRate;/// Whether VAT is applicable
@JsonKey(name: 'vat_applicable') bool get vatApplicable;/// VAT number
@JsonKey(name: 'vat_number') String? get vatNumber;/// Custom settings
@JsonKey(name: 'custom_settings') Map<String, dynamic> get customSettings;
/// Create a copy of CompanySettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompanySettingsCopyWith<CompanySettings> get copyWith => _$CompanySettingsCopyWithImpl<CompanySettings>(this as CompanySettings, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompanySettings&&(identical(other.emailNotifications, emailNotifications) || other.emailNotifications == emailNotifications)&&(identical(other.smsNotifications, smsNotifications) || other.smsNotifications == smsNotifications)&&(identical(other.autoRenewal, autoRenewal) || other.autoRenewal == autoRenewal)&&(identical(other.paymentTerms, paymentTerms) || other.paymentTerms == paymentTerms)&&(identical(other.preferredLanguage, preferredLanguage) || other.preferredLanguage == preferredLanguage)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.billingCurrency, billingCurrency) || other.billingCurrency == billingCurrency)&&(identical(other.taxRate, taxRate) || other.taxRate == taxRate)&&(identical(other.vatApplicable, vatApplicable) || other.vatApplicable == vatApplicable)&&(identical(other.vatNumber, vatNumber) || other.vatNumber == vatNumber)&&const DeepCollectionEquality().equals(other.customSettings, customSettings));
}


@override
int get hashCode => Object.hash(runtimeType,emailNotifications,smsNotifications,autoRenewal,paymentTerms,preferredLanguage,timezone,billingCurrency,taxRate,vatApplicable,vatNumber,const DeepCollectionEquality().hash(customSettings));

@override
String toString() {
  return 'CompanySettings(emailNotifications: $emailNotifications, smsNotifications: $smsNotifications, autoRenewal: $autoRenewal, paymentTerms: $paymentTerms, preferredLanguage: $preferredLanguage, timezone: $timezone, billingCurrency: $billingCurrency, taxRate: $taxRate, vatApplicable: $vatApplicable, vatNumber: $vatNumber, customSettings: $customSettings)';
}


}

/// @nodoc
abstract mixin class $CompanySettingsCopyWith<$Res>  {
  factory $CompanySettingsCopyWith(CompanySettings value, $Res Function(CompanySettings) _then) = _$CompanySettingsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'email_notifications') bool emailNotifications,@JsonKey(name: 'sms_notifications') bool smsNotifications,@JsonKey(name: 'auto_renewal') bool autoRenewal,@JsonKey(name: 'payment_terms') int paymentTerms,@JsonKey(name: 'preferred_language') String preferredLanguage,@JsonKey(name: 'timezone') String timezone,@JsonKey(name: 'billing_currency') String billingCurrency,@JsonKey(name: 'tax_rate') double taxRate,@JsonKey(name: 'vat_applicable') bool vatApplicable,@JsonKey(name: 'vat_number') String? vatNumber,@JsonKey(name: 'custom_settings') Map<String, dynamic> customSettings
});




}
/// @nodoc
class _$CompanySettingsCopyWithImpl<$Res>
    implements $CompanySettingsCopyWith<$Res> {
  _$CompanySettingsCopyWithImpl(this._self, this._then);

  final CompanySettings _self;
  final $Res Function(CompanySettings) _then;

/// Create a copy of CompanySettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? emailNotifications = null,Object? smsNotifications = null,Object? autoRenewal = null,Object? paymentTerms = null,Object? preferredLanguage = null,Object? timezone = null,Object? billingCurrency = null,Object? taxRate = null,Object? vatApplicable = null,Object? vatNumber = freezed,Object? customSettings = null,}) {
  return _then(_self.copyWith(
emailNotifications: null == emailNotifications ? _self.emailNotifications : emailNotifications // ignore: cast_nullable_to_non_nullable
as bool,smsNotifications: null == smsNotifications ? _self.smsNotifications : smsNotifications // ignore: cast_nullable_to_non_nullable
as bool,autoRenewal: null == autoRenewal ? _self.autoRenewal : autoRenewal // ignore: cast_nullable_to_non_nullable
as bool,paymentTerms: null == paymentTerms ? _self.paymentTerms : paymentTerms // ignore: cast_nullable_to_non_nullable
as int,preferredLanguage: null == preferredLanguage ? _self.preferredLanguage : preferredLanguage // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,billingCurrency: null == billingCurrency ? _self.billingCurrency : billingCurrency // ignore: cast_nullable_to_non_nullable
as String,taxRate: null == taxRate ? _self.taxRate : taxRate // ignore: cast_nullable_to_non_nullable
as double,vatApplicable: null == vatApplicable ? _self.vatApplicable : vatApplicable // ignore: cast_nullable_to_non_nullable
as bool,vatNumber: freezed == vatNumber ? _self.vatNumber : vatNumber // ignore: cast_nullable_to_non_nullable
as String?,customSettings: null == customSettings ? _self.customSettings : customSettings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [CompanySettings].
extension CompanySettingsPatterns on CompanySettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CompanySettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompanySettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CompanySettings value)  $default,){
final _that = this;
switch (_that) {
case _CompanySettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CompanySettings value)?  $default,){
final _that = this;
switch (_that) {
case _CompanySettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'email_notifications')  bool emailNotifications, @JsonKey(name: 'sms_notifications')  bool smsNotifications, @JsonKey(name: 'auto_renewal')  bool autoRenewal, @JsonKey(name: 'payment_terms')  int paymentTerms, @JsonKey(name: 'preferred_language')  String preferredLanguage, @JsonKey(name: 'timezone')  String timezone, @JsonKey(name: 'billing_currency')  String billingCurrency, @JsonKey(name: 'tax_rate')  double taxRate, @JsonKey(name: 'vat_applicable')  bool vatApplicable, @JsonKey(name: 'vat_number')  String? vatNumber, @JsonKey(name: 'custom_settings')  Map<String, dynamic> customSettings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CompanySettings() when $default != null:
return $default(_that.emailNotifications,_that.smsNotifications,_that.autoRenewal,_that.paymentTerms,_that.preferredLanguage,_that.timezone,_that.billingCurrency,_that.taxRate,_that.vatApplicable,_that.vatNumber,_that.customSettings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'email_notifications')  bool emailNotifications, @JsonKey(name: 'sms_notifications')  bool smsNotifications, @JsonKey(name: 'auto_renewal')  bool autoRenewal, @JsonKey(name: 'payment_terms')  int paymentTerms, @JsonKey(name: 'preferred_language')  String preferredLanguage, @JsonKey(name: 'timezone')  String timezone, @JsonKey(name: 'billing_currency')  String billingCurrency, @JsonKey(name: 'tax_rate')  double taxRate, @JsonKey(name: 'vat_applicable')  bool vatApplicable, @JsonKey(name: 'vat_number')  String? vatNumber, @JsonKey(name: 'custom_settings')  Map<String, dynamic> customSettings)  $default,) {final _that = this;
switch (_that) {
case _CompanySettings():
return $default(_that.emailNotifications,_that.smsNotifications,_that.autoRenewal,_that.paymentTerms,_that.preferredLanguage,_that.timezone,_that.billingCurrency,_that.taxRate,_that.vatApplicable,_that.vatNumber,_that.customSettings);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'email_notifications')  bool emailNotifications, @JsonKey(name: 'sms_notifications')  bool smsNotifications, @JsonKey(name: 'auto_renewal')  bool autoRenewal, @JsonKey(name: 'payment_terms')  int paymentTerms, @JsonKey(name: 'preferred_language')  String preferredLanguage, @JsonKey(name: 'timezone')  String timezone, @JsonKey(name: 'billing_currency')  String billingCurrency, @JsonKey(name: 'tax_rate')  double taxRate, @JsonKey(name: 'vat_applicable')  bool vatApplicable, @JsonKey(name: 'vat_number')  String? vatNumber, @JsonKey(name: 'custom_settings')  Map<String, dynamic> customSettings)?  $default,) {final _that = this;
switch (_that) {
case _CompanySettings() when $default != null:
return $default(_that.emailNotifications,_that.smsNotifications,_that.autoRenewal,_that.paymentTerms,_that.preferredLanguage,_that.timezone,_that.billingCurrency,_that.taxRate,_that.vatApplicable,_that.vatNumber,_that.customSettings);case _:
  return null;

}
}

}

/// @nodoc


class _CompanySettings extends CompanySettings {
  const _CompanySettings({@JsonKey(name: 'email_notifications') this.emailNotifications = true, @JsonKey(name: 'sms_notifications') this.smsNotifications = false, @JsonKey(name: 'auto_renewal') this.autoRenewal = true, @JsonKey(name: 'payment_terms') this.paymentTerms = 15, @JsonKey(name: 'preferred_language') this.preferredLanguage = 'en', @JsonKey(name: 'timezone') this.timezone = 'UTC', @JsonKey(name: 'billing_currency') this.billingCurrency = 'USD', @JsonKey(name: 'tax_rate') this.taxRate = 0.0, @JsonKey(name: 'vat_applicable') this.vatApplicable = false, @JsonKey(name: 'vat_number') this.vatNumber, @JsonKey(name: 'custom_settings') final  Map<String, dynamic> customSettings = const {}}): _customSettings = customSettings,super._();
  

/// Whether email notifications are enabled
@override@JsonKey(name: 'email_notifications') final  bool emailNotifications;
/// Whether SMS notifications are enabled
@override@JsonKey(name: 'sms_notifications') final  bool smsNotifications;
/// Whether auto-renewal is enabled
@override@JsonKey(name: 'auto_renewal') final  bool autoRenewal;
/// Invoice payment terms (in days)
@override@JsonKey(name: 'payment_terms') final  int paymentTerms;
/// Preferred language
@override@JsonKey(name: 'preferred_language') final  String preferredLanguage;
/// Timezone
@override@JsonKey(name: 'timezone') final  String timezone;
/// Currency for billing
@override@JsonKey(name: 'billing_currency') final  String billingCurrency;
/// Tax rate percentage
@override@JsonKey(name: 'tax_rate') final  double taxRate;
/// Whether VAT is applicable
@override@JsonKey(name: 'vat_applicable') final  bool vatApplicable;
/// VAT number
@override@JsonKey(name: 'vat_number') final  String? vatNumber;
/// Custom settings
 final  Map<String, dynamic> _customSettings;
/// Custom settings
@override@JsonKey(name: 'custom_settings') Map<String, dynamic> get customSettings {
  if (_customSettings is EqualUnmodifiableMapView) return _customSettings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_customSettings);
}


/// Create a copy of CompanySettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompanySettingsCopyWith<_CompanySettings> get copyWith => __$CompanySettingsCopyWithImpl<_CompanySettings>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompanySettings&&(identical(other.emailNotifications, emailNotifications) || other.emailNotifications == emailNotifications)&&(identical(other.smsNotifications, smsNotifications) || other.smsNotifications == smsNotifications)&&(identical(other.autoRenewal, autoRenewal) || other.autoRenewal == autoRenewal)&&(identical(other.paymentTerms, paymentTerms) || other.paymentTerms == paymentTerms)&&(identical(other.preferredLanguage, preferredLanguage) || other.preferredLanguage == preferredLanguage)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.billingCurrency, billingCurrency) || other.billingCurrency == billingCurrency)&&(identical(other.taxRate, taxRate) || other.taxRate == taxRate)&&(identical(other.vatApplicable, vatApplicable) || other.vatApplicable == vatApplicable)&&(identical(other.vatNumber, vatNumber) || other.vatNumber == vatNumber)&&const DeepCollectionEquality().equals(other._customSettings, _customSettings));
}


@override
int get hashCode => Object.hash(runtimeType,emailNotifications,smsNotifications,autoRenewal,paymentTerms,preferredLanguage,timezone,billingCurrency,taxRate,vatApplicable,vatNumber,const DeepCollectionEquality().hash(_customSettings));

@override
String toString() {
  return 'CompanySettings(emailNotifications: $emailNotifications, smsNotifications: $smsNotifications, autoRenewal: $autoRenewal, paymentTerms: $paymentTerms, preferredLanguage: $preferredLanguage, timezone: $timezone, billingCurrency: $billingCurrency, taxRate: $taxRate, vatApplicable: $vatApplicable, vatNumber: $vatNumber, customSettings: $customSettings)';
}


}

/// @nodoc
abstract mixin class _$CompanySettingsCopyWith<$Res> implements $CompanySettingsCopyWith<$Res> {
  factory _$CompanySettingsCopyWith(_CompanySettings value, $Res Function(_CompanySettings) _then) = __$CompanySettingsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'email_notifications') bool emailNotifications,@JsonKey(name: 'sms_notifications') bool smsNotifications,@JsonKey(name: 'auto_renewal') bool autoRenewal,@JsonKey(name: 'payment_terms') int paymentTerms,@JsonKey(name: 'preferred_language') String preferredLanguage,@JsonKey(name: 'timezone') String timezone,@JsonKey(name: 'billing_currency') String billingCurrency,@JsonKey(name: 'tax_rate') double taxRate,@JsonKey(name: 'vat_applicable') bool vatApplicable,@JsonKey(name: 'vat_number') String? vatNumber,@JsonKey(name: 'custom_settings') Map<String, dynamic> customSettings
});




}
/// @nodoc
class __$CompanySettingsCopyWithImpl<$Res>
    implements _$CompanySettingsCopyWith<$Res> {
  __$CompanySettingsCopyWithImpl(this._self, this._then);

  final _CompanySettings _self;
  final $Res Function(_CompanySettings) _then;

/// Create a copy of CompanySettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? emailNotifications = null,Object? smsNotifications = null,Object? autoRenewal = null,Object? paymentTerms = null,Object? preferredLanguage = null,Object? timezone = null,Object? billingCurrency = null,Object? taxRate = null,Object? vatApplicable = null,Object? vatNumber = freezed,Object? customSettings = null,}) {
  return _then(_CompanySettings(
emailNotifications: null == emailNotifications ? _self.emailNotifications : emailNotifications // ignore: cast_nullable_to_non_nullable
as bool,smsNotifications: null == smsNotifications ? _self.smsNotifications : smsNotifications // ignore: cast_nullable_to_non_nullable
as bool,autoRenewal: null == autoRenewal ? _self.autoRenewal : autoRenewal // ignore: cast_nullable_to_non_nullable
as bool,paymentTerms: null == paymentTerms ? _self.paymentTerms : paymentTerms // ignore: cast_nullable_to_non_nullable
as int,preferredLanguage: null == preferredLanguage ? _self.preferredLanguage : preferredLanguage // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,billingCurrency: null == billingCurrency ? _self.billingCurrency : billingCurrency // ignore: cast_nullable_to_non_nullable
as String,taxRate: null == taxRate ? _self.taxRate : taxRate // ignore: cast_nullable_to_non_nullable
as double,vatApplicable: null == vatApplicable ? _self.vatApplicable : vatApplicable // ignore: cast_nullable_to_non_nullable
as bool,vatNumber: freezed == vatNumber ? _self.vatNumber : vatNumber // ignore: cast_nullable_to_non_nullable
as String?,customSettings: null == customSettings ? _self._customSettings : customSettings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

/// @nodoc
mixin _$CompanyUsageStats {

/// Current month's unit code usage
@JsonKey(name: 'current_month_unit_codes') int get currentMonthUnitCodes;/// Current month's packet code usage
@JsonKey(name: 'current_month_packet_codes') int get currentMonthPacketCodes;/// Current month's carton code usage
@JsonKey(name: 'current_month_carton_codes') int get currentMonthCartonCodes;/// Current month's bundle code usage
@JsonKey(name: 'current_month_bundle_codes') int get currentMonthBundleCodes;/// Total unit codes generated
@JsonKey(name: 'total_unit_codes') int get totalUnitCodes;/// Total packet codes generated
@JsonKey(name: 'total_packet_codes') int get totalPacketCodes;/// Total carton codes generated
@JsonKey(name: 'total_carton_codes') int get totalCartonCodes;/// Total bundle codes generated
@JsonKey(name: 'total_bundle_codes') int get totalBundleCodes;/// Current store keepers count
@JsonKey(name: 'current_store_keepers') int get currentStoreKeepers;/// Current drivers count
@JsonKey(name: 'current_drivers') int get currentDrivers;/// Current admin users count
@JsonKey(name: 'current_admin_users') int get currentAdminUsers;/// Current active products count
@JsonKey(name: 'current_active_products') int get currentActiveProducts;/// Storage used in MB
@JsonKey(name: 'storage_used_mb') int get storageUsedMb;/// API calls made today
@JsonKey(name: 'api_calls_today') int get apiCallsToday;/// Last activity timestamp
@JsonKey(name: 'last_activity_at') DateTime? get lastActivityAt;/// Monthly usage history
@JsonKey(name: 'monthly_history') List<MonthlyUsage> get monthlyHistory;
/// Create a copy of CompanyUsageStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompanyUsageStatsCopyWith<CompanyUsageStats> get copyWith => _$CompanyUsageStatsCopyWithImpl<CompanyUsageStats>(this as CompanyUsageStats, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompanyUsageStats&&(identical(other.currentMonthUnitCodes, currentMonthUnitCodes) || other.currentMonthUnitCodes == currentMonthUnitCodes)&&(identical(other.currentMonthPacketCodes, currentMonthPacketCodes) || other.currentMonthPacketCodes == currentMonthPacketCodes)&&(identical(other.currentMonthCartonCodes, currentMonthCartonCodes) || other.currentMonthCartonCodes == currentMonthCartonCodes)&&(identical(other.currentMonthBundleCodes, currentMonthBundleCodes) || other.currentMonthBundleCodes == currentMonthBundleCodes)&&(identical(other.totalUnitCodes, totalUnitCodes) || other.totalUnitCodes == totalUnitCodes)&&(identical(other.totalPacketCodes, totalPacketCodes) || other.totalPacketCodes == totalPacketCodes)&&(identical(other.totalCartonCodes, totalCartonCodes) || other.totalCartonCodes == totalCartonCodes)&&(identical(other.totalBundleCodes, totalBundleCodes) || other.totalBundleCodes == totalBundleCodes)&&(identical(other.currentStoreKeepers, currentStoreKeepers) || other.currentStoreKeepers == currentStoreKeepers)&&(identical(other.currentDrivers, currentDrivers) || other.currentDrivers == currentDrivers)&&(identical(other.currentAdminUsers, currentAdminUsers) || other.currentAdminUsers == currentAdminUsers)&&(identical(other.currentActiveProducts, currentActiveProducts) || other.currentActiveProducts == currentActiveProducts)&&(identical(other.storageUsedMb, storageUsedMb) || other.storageUsedMb == storageUsedMb)&&(identical(other.apiCallsToday, apiCallsToday) || other.apiCallsToday == apiCallsToday)&&(identical(other.lastActivityAt, lastActivityAt) || other.lastActivityAt == lastActivityAt)&&const DeepCollectionEquality().equals(other.monthlyHistory, monthlyHistory));
}


@override
int get hashCode => Object.hash(runtimeType,currentMonthUnitCodes,currentMonthPacketCodes,currentMonthCartonCodes,currentMonthBundleCodes,totalUnitCodes,totalPacketCodes,totalCartonCodes,totalBundleCodes,currentStoreKeepers,currentDrivers,currentAdminUsers,currentActiveProducts,storageUsedMb,apiCallsToday,lastActivityAt,const DeepCollectionEquality().hash(monthlyHistory));

@override
String toString() {
  return 'CompanyUsageStats(currentMonthUnitCodes: $currentMonthUnitCodes, currentMonthPacketCodes: $currentMonthPacketCodes, currentMonthCartonCodes: $currentMonthCartonCodes, currentMonthBundleCodes: $currentMonthBundleCodes, totalUnitCodes: $totalUnitCodes, totalPacketCodes: $totalPacketCodes, totalCartonCodes: $totalCartonCodes, totalBundleCodes: $totalBundleCodes, currentStoreKeepers: $currentStoreKeepers, currentDrivers: $currentDrivers, currentAdminUsers: $currentAdminUsers, currentActiveProducts: $currentActiveProducts, storageUsedMb: $storageUsedMb, apiCallsToday: $apiCallsToday, lastActivityAt: $lastActivityAt, monthlyHistory: $monthlyHistory)';
}


}

/// @nodoc
abstract mixin class $CompanyUsageStatsCopyWith<$Res>  {
  factory $CompanyUsageStatsCopyWith(CompanyUsageStats value, $Res Function(CompanyUsageStats) _then) = _$CompanyUsageStatsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'current_month_unit_codes') int currentMonthUnitCodes,@JsonKey(name: 'current_month_packet_codes') int currentMonthPacketCodes,@JsonKey(name: 'current_month_carton_codes') int currentMonthCartonCodes,@JsonKey(name: 'current_month_bundle_codes') int currentMonthBundleCodes,@JsonKey(name: 'total_unit_codes') int totalUnitCodes,@JsonKey(name: 'total_packet_codes') int totalPacketCodes,@JsonKey(name: 'total_carton_codes') int totalCartonCodes,@JsonKey(name: 'total_bundle_codes') int totalBundleCodes,@JsonKey(name: 'current_store_keepers') int currentStoreKeepers,@JsonKey(name: 'current_drivers') int currentDrivers,@JsonKey(name: 'current_admin_users') int currentAdminUsers,@JsonKey(name: 'current_active_products') int currentActiveProducts,@JsonKey(name: 'storage_used_mb') int storageUsedMb,@JsonKey(name: 'api_calls_today') int apiCallsToday,@JsonKey(name: 'last_activity_at') DateTime? lastActivityAt,@JsonKey(name: 'monthly_history') List<MonthlyUsage> monthlyHistory
});




}
/// @nodoc
class _$CompanyUsageStatsCopyWithImpl<$Res>
    implements $CompanyUsageStatsCopyWith<$Res> {
  _$CompanyUsageStatsCopyWithImpl(this._self, this._then);

  final CompanyUsageStats _self;
  final $Res Function(CompanyUsageStats) _then;

/// Create a copy of CompanyUsageStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentMonthUnitCodes = null,Object? currentMonthPacketCodes = null,Object? currentMonthCartonCodes = null,Object? currentMonthBundleCodes = null,Object? totalUnitCodes = null,Object? totalPacketCodes = null,Object? totalCartonCodes = null,Object? totalBundleCodes = null,Object? currentStoreKeepers = null,Object? currentDrivers = null,Object? currentAdminUsers = null,Object? currentActiveProducts = null,Object? storageUsedMb = null,Object? apiCallsToday = null,Object? lastActivityAt = freezed,Object? monthlyHistory = null,}) {
  return _then(_self.copyWith(
currentMonthUnitCodes: null == currentMonthUnitCodes ? _self.currentMonthUnitCodes : currentMonthUnitCodes // ignore: cast_nullable_to_non_nullable
as int,currentMonthPacketCodes: null == currentMonthPacketCodes ? _self.currentMonthPacketCodes : currentMonthPacketCodes // ignore: cast_nullable_to_non_nullable
as int,currentMonthCartonCodes: null == currentMonthCartonCodes ? _self.currentMonthCartonCodes : currentMonthCartonCodes // ignore: cast_nullable_to_non_nullable
as int,currentMonthBundleCodes: null == currentMonthBundleCodes ? _self.currentMonthBundleCodes : currentMonthBundleCodes // ignore: cast_nullable_to_non_nullable
as int,totalUnitCodes: null == totalUnitCodes ? _self.totalUnitCodes : totalUnitCodes // ignore: cast_nullable_to_non_nullable
as int,totalPacketCodes: null == totalPacketCodes ? _self.totalPacketCodes : totalPacketCodes // ignore: cast_nullable_to_non_nullable
as int,totalCartonCodes: null == totalCartonCodes ? _self.totalCartonCodes : totalCartonCodes // ignore: cast_nullable_to_non_nullable
as int,totalBundleCodes: null == totalBundleCodes ? _self.totalBundleCodes : totalBundleCodes // ignore: cast_nullable_to_non_nullable
as int,currentStoreKeepers: null == currentStoreKeepers ? _self.currentStoreKeepers : currentStoreKeepers // ignore: cast_nullable_to_non_nullable
as int,currentDrivers: null == currentDrivers ? _self.currentDrivers : currentDrivers // ignore: cast_nullable_to_non_nullable
as int,currentAdminUsers: null == currentAdminUsers ? _self.currentAdminUsers : currentAdminUsers // ignore: cast_nullable_to_non_nullable
as int,currentActiveProducts: null == currentActiveProducts ? _self.currentActiveProducts : currentActiveProducts // ignore: cast_nullable_to_non_nullable
as int,storageUsedMb: null == storageUsedMb ? _self.storageUsedMb : storageUsedMb // ignore: cast_nullable_to_non_nullable
as int,apiCallsToday: null == apiCallsToday ? _self.apiCallsToday : apiCallsToday // ignore: cast_nullable_to_non_nullable
as int,lastActivityAt: freezed == lastActivityAt ? _self.lastActivityAt : lastActivityAt // ignore: cast_nullable_to_non_nullable
as DateTime?,monthlyHistory: null == monthlyHistory ? _self.monthlyHistory : monthlyHistory // ignore: cast_nullable_to_non_nullable
as List<MonthlyUsage>,
  ));
}

}


/// Adds pattern-matching-related methods to [CompanyUsageStats].
extension CompanyUsageStatsPatterns on CompanyUsageStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CompanyUsageStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompanyUsageStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CompanyUsageStats value)  $default,){
final _that = this;
switch (_that) {
case _CompanyUsageStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CompanyUsageStats value)?  $default,){
final _that = this;
switch (_that) {
case _CompanyUsageStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'current_month_unit_codes')  int currentMonthUnitCodes, @JsonKey(name: 'current_month_packet_codes')  int currentMonthPacketCodes, @JsonKey(name: 'current_month_carton_codes')  int currentMonthCartonCodes, @JsonKey(name: 'current_month_bundle_codes')  int currentMonthBundleCodes, @JsonKey(name: 'total_unit_codes')  int totalUnitCodes, @JsonKey(name: 'total_packet_codes')  int totalPacketCodes, @JsonKey(name: 'total_carton_codes')  int totalCartonCodes, @JsonKey(name: 'total_bundle_codes')  int totalBundleCodes, @JsonKey(name: 'current_store_keepers')  int currentStoreKeepers, @JsonKey(name: 'current_drivers')  int currentDrivers, @JsonKey(name: 'current_admin_users')  int currentAdminUsers, @JsonKey(name: 'current_active_products')  int currentActiveProducts, @JsonKey(name: 'storage_used_mb')  int storageUsedMb, @JsonKey(name: 'api_calls_today')  int apiCallsToday, @JsonKey(name: 'last_activity_at')  DateTime? lastActivityAt, @JsonKey(name: 'monthly_history')  List<MonthlyUsage> monthlyHistory)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CompanyUsageStats() when $default != null:
return $default(_that.currentMonthUnitCodes,_that.currentMonthPacketCodes,_that.currentMonthCartonCodes,_that.currentMonthBundleCodes,_that.totalUnitCodes,_that.totalPacketCodes,_that.totalCartonCodes,_that.totalBundleCodes,_that.currentStoreKeepers,_that.currentDrivers,_that.currentAdminUsers,_that.currentActiveProducts,_that.storageUsedMb,_that.apiCallsToday,_that.lastActivityAt,_that.monthlyHistory);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'current_month_unit_codes')  int currentMonthUnitCodes, @JsonKey(name: 'current_month_packet_codes')  int currentMonthPacketCodes, @JsonKey(name: 'current_month_carton_codes')  int currentMonthCartonCodes, @JsonKey(name: 'current_month_bundle_codes')  int currentMonthBundleCodes, @JsonKey(name: 'total_unit_codes')  int totalUnitCodes, @JsonKey(name: 'total_packet_codes')  int totalPacketCodes, @JsonKey(name: 'total_carton_codes')  int totalCartonCodes, @JsonKey(name: 'total_bundle_codes')  int totalBundleCodes, @JsonKey(name: 'current_store_keepers')  int currentStoreKeepers, @JsonKey(name: 'current_drivers')  int currentDrivers, @JsonKey(name: 'current_admin_users')  int currentAdminUsers, @JsonKey(name: 'current_active_products')  int currentActiveProducts, @JsonKey(name: 'storage_used_mb')  int storageUsedMb, @JsonKey(name: 'api_calls_today')  int apiCallsToday, @JsonKey(name: 'last_activity_at')  DateTime? lastActivityAt, @JsonKey(name: 'monthly_history')  List<MonthlyUsage> monthlyHistory)  $default,) {final _that = this;
switch (_that) {
case _CompanyUsageStats():
return $default(_that.currentMonthUnitCodes,_that.currentMonthPacketCodes,_that.currentMonthCartonCodes,_that.currentMonthBundleCodes,_that.totalUnitCodes,_that.totalPacketCodes,_that.totalCartonCodes,_that.totalBundleCodes,_that.currentStoreKeepers,_that.currentDrivers,_that.currentAdminUsers,_that.currentActiveProducts,_that.storageUsedMb,_that.apiCallsToday,_that.lastActivityAt,_that.monthlyHistory);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'current_month_unit_codes')  int currentMonthUnitCodes, @JsonKey(name: 'current_month_packet_codes')  int currentMonthPacketCodes, @JsonKey(name: 'current_month_carton_codes')  int currentMonthCartonCodes, @JsonKey(name: 'current_month_bundle_codes')  int currentMonthBundleCodes, @JsonKey(name: 'total_unit_codes')  int totalUnitCodes, @JsonKey(name: 'total_packet_codes')  int totalPacketCodes, @JsonKey(name: 'total_carton_codes')  int totalCartonCodes, @JsonKey(name: 'total_bundle_codes')  int totalBundleCodes, @JsonKey(name: 'current_store_keepers')  int currentStoreKeepers, @JsonKey(name: 'current_drivers')  int currentDrivers, @JsonKey(name: 'current_admin_users')  int currentAdminUsers, @JsonKey(name: 'current_active_products')  int currentActiveProducts, @JsonKey(name: 'storage_used_mb')  int storageUsedMb, @JsonKey(name: 'api_calls_today')  int apiCallsToday, @JsonKey(name: 'last_activity_at')  DateTime? lastActivityAt, @JsonKey(name: 'monthly_history')  List<MonthlyUsage> monthlyHistory)?  $default,) {final _that = this;
switch (_that) {
case _CompanyUsageStats() when $default != null:
return $default(_that.currentMonthUnitCodes,_that.currentMonthPacketCodes,_that.currentMonthCartonCodes,_that.currentMonthBundleCodes,_that.totalUnitCodes,_that.totalPacketCodes,_that.totalCartonCodes,_that.totalBundleCodes,_that.currentStoreKeepers,_that.currentDrivers,_that.currentAdminUsers,_that.currentActiveProducts,_that.storageUsedMb,_that.apiCallsToday,_that.lastActivityAt,_that.monthlyHistory);case _:
  return null;

}
}

}

/// @nodoc


class _CompanyUsageStats extends CompanyUsageStats {
  const _CompanyUsageStats({@JsonKey(name: 'current_month_unit_codes') this.currentMonthUnitCodes = 0, @JsonKey(name: 'current_month_packet_codes') this.currentMonthPacketCodes = 0, @JsonKey(name: 'current_month_carton_codes') this.currentMonthCartonCodes = 0, @JsonKey(name: 'current_month_bundle_codes') this.currentMonthBundleCodes = 0, @JsonKey(name: 'total_unit_codes') this.totalUnitCodes = 0, @JsonKey(name: 'total_packet_codes') this.totalPacketCodes = 0, @JsonKey(name: 'total_carton_codes') this.totalCartonCodes = 0, @JsonKey(name: 'total_bundle_codes') this.totalBundleCodes = 0, @JsonKey(name: 'current_store_keepers') this.currentStoreKeepers = 0, @JsonKey(name: 'current_drivers') this.currentDrivers = 0, @JsonKey(name: 'current_admin_users') this.currentAdminUsers = 0, @JsonKey(name: 'current_active_products') this.currentActiveProducts = 0, @JsonKey(name: 'storage_used_mb') this.storageUsedMb = 0, @JsonKey(name: 'api_calls_today') this.apiCallsToday = 0, @JsonKey(name: 'last_activity_at') this.lastActivityAt, @JsonKey(name: 'monthly_history') final  List<MonthlyUsage> monthlyHistory = const []}): _monthlyHistory = monthlyHistory,super._();
  

/// Current month's unit code usage
@override@JsonKey(name: 'current_month_unit_codes') final  int currentMonthUnitCodes;
/// Current month's packet code usage
@override@JsonKey(name: 'current_month_packet_codes') final  int currentMonthPacketCodes;
/// Current month's carton code usage
@override@JsonKey(name: 'current_month_carton_codes') final  int currentMonthCartonCodes;
/// Current month's bundle code usage
@override@JsonKey(name: 'current_month_bundle_codes') final  int currentMonthBundleCodes;
/// Total unit codes generated
@override@JsonKey(name: 'total_unit_codes') final  int totalUnitCodes;
/// Total packet codes generated
@override@JsonKey(name: 'total_packet_codes') final  int totalPacketCodes;
/// Total carton codes generated
@override@JsonKey(name: 'total_carton_codes') final  int totalCartonCodes;
/// Total bundle codes generated
@override@JsonKey(name: 'total_bundle_codes') final  int totalBundleCodes;
/// Current store keepers count
@override@JsonKey(name: 'current_store_keepers') final  int currentStoreKeepers;
/// Current drivers count
@override@JsonKey(name: 'current_drivers') final  int currentDrivers;
/// Current admin users count
@override@JsonKey(name: 'current_admin_users') final  int currentAdminUsers;
/// Current active products count
@override@JsonKey(name: 'current_active_products') final  int currentActiveProducts;
/// Storage used in MB
@override@JsonKey(name: 'storage_used_mb') final  int storageUsedMb;
/// API calls made today
@override@JsonKey(name: 'api_calls_today') final  int apiCallsToday;
/// Last activity timestamp
@override@JsonKey(name: 'last_activity_at') final  DateTime? lastActivityAt;
/// Monthly usage history
 final  List<MonthlyUsage> _monthlyHistory;
/// Monthly usage history
@override@JsonKey(name: 'monthly_history') List<MonthlyUsage> get monthlyHistory {
  if (_monthlyHistory is EqualUnmodifiableListView) return _monthlyHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_monthlyHistory);
}


/// Create a copy of CompanyUsageStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompanyUsageStatsCopyWith<_CompanyUsageStats> get copyWith => __$CompanyUsageStatsCopyWithImpl<_CompanyUsageStats>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompanyUsageStats&&(identical(other.currentMonthUnitCodes, currentMonthUnitCodes) || other.currentMonthUnitCodes == currentMonthUnitCodes)&&(identical(other.currentMonthPacketCodes, currentMonthPacketCodes) || other.currentMonthPacketCodes == currentMonthPacketCodes)&&(identical(other.currentMonthCartonCodes, currentMonthCartonCodes) || other.currentMonthCartonCodes == currentMonthCartonCodes)&&(identical(other.currentMonthBundleCodes, currentMonthBundleCodes) || other.currentMonthBundleCodes == currentMonthBundleCodes)&&(identical(other.totalUnitCodes, totalUnitCodes) || other.totalUnitCodes == totalUnitCodes)&&(identical(other.totalPacketCodes, totalPacketCodes) || other.totalPacketCodes == totalPacketCodes)&&(identical(other.totalCartonCodes, totalCartonCodes) || other.totalCartonCodes == totalCartonCodes)&&(identical(other.totalBundleCodes, totalBundleCodes) || other.totalBundleCodes == totalBundleCodes)&&(identical(other.currentStoreKeepers, currentStoreKeepers) || other.currentStoreKeepers == currentStoreKeepers)&&(identical(other.currentDrivers, currentDrivers) || other.currentDrivers == currentDrivers)&&(identical(other.currentAdminUsers, currentAdminUsers) || other.currentAdminUsers == currentAdminUsers)&&(identical(other.currentActiveProducts, currentActiveProducts) || other.currentActiveProducts == currentActiveProducts)&&(identical(other.storageUsedMb, storageUsedMb) || other.storageUsedMb == storageUsedMb)&&(identical(other.apiCallsToday, apiCallsToday) || other.apiCallsToday == apiCallsToday)&&(identical(other.lastActivityAt, lastActivityAt) || other.lastActivityAt == lastActivityAt)&&const DeepCollectionEquality().equals(other._monthlyHistory, _monthlyHistory));
}


@override
int get hashCode => Object.hash(runtimeType,currentMonthUnitCodes,currentMonthPacketCodes,currentMonthCartonCodes,currentMonthBundleCodes,totalUnitCodes,totalPacketCodes,totalCartonCodes,totalBundleCodes,currentStoreKeepers,currentDrivers,currentAdminUsers,currentActiveProducts,storageUsedMb,apiCallsToday,lastActivityAt,const DeepCollectionEquality().hash(_monthlyHistory));

@override
String toString() {
  return 'CompanyUsageStats(currentMonthUnitCodes: $currentMonthUnitCodes, currentMonthPacketCodes: $currentMonthPacketCodes, currentMonthCartonCodes: $currentMonthCartonCodes, currentMonthBundleCodes: $currentMonthBundleCodes, totalUnitCodes: $totalUnitCodes, totalPacketCodes: $totalPacketCodes, totalCartonCodes: $totalCartonCodes, totalBundleCodes: $totalBundleCodes, currentStoreKeepers: $currentStoreKeepers, currentDrivers: $currentDrivers, currentAdminUsers: $currentAdminUsers, currentActiveProducts: $currentActiveProducts, storageUsedMb: $storageUsedMb, apiCallsToday: $apiCallsToday, lastActivityAt: $lastActivityAt, monthlyHistory: $monthlyHistory)';
}


}

/// @nodoc
abstract mixin class _$CompanyUsageStatsCopyWith<$Res> implements $CompanyUsageStatsCopyWith<$Res> {
  factory _$CompanyUsageStatsCopyWith(_CompanyUsageStats value, $Res Function(_CompanyUsageStats) _then) = __$CompanyUsageStatsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'current_month_unit_codes') int currentMonthUnitCodes,@JsonKey(name: 'current_month_packet_codes') int currentMonthPacketCodes,@JsonKey(name: 'current_month_carton_codes') int currentMonthCartonCodes,@JsonKey(name: 'current_month_bundle_codes') int currentMonthBundleCodes,@JsonKey(name: 'total_unit_codes') int totalUnitCodes,@JsonKey(name: 'total_packet_codes') int totalPacketCodes,@JsonKey(name: 'total_carton_codes') int totalCartonCodes,@JsonKey(name: 'total_bundle_codes') int totalBundleCodes,@JsonKey(name: 'current_store_keepers') int currentStoreKeepers,@JsonKey(name: 'current_drivers') int currentDrivers,@JsonKey(name: 'current_admin_users') int currentAdminUsers,@JsonKey(name: 'current_active_products') int currentActiveProducts,@JsonKey(name: 'storage_used_mb') int storageUsedMb,@JsonKey(name: 'api_calls_today') int apiCallsToday,@JsonKey(name: 'last_activity_at') DateTime? lastActivityAt,@JsonKey(name: 'monthly_history') List<MonthlyUsage> monthlyHistory
});




}
/// @nodoc
class __$CompanyUsageStatsCopyWithImpl<$Res>
    implements _$CompanyUsageStatsCopyWith<$Res> {
  __$CompanyUsageStatsCopyWithImpl(this._self, this._then);

  final _CompanyUsageStats _self;
  final $Res Function(_CompanyUsageStats) _then;

/// Create a copy of CompanyUsageStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentMonthUnitCodes = null,Object? currentMonthPacketCodes = null,Object? currentMonthCartonCodes = null,Object? currentMonthBundleCodes = null,Object? totalUnitCodes = null,Object? totalPacketCodes = null,Object? totalCartonCodes = null,Object? totalBundleCodes = null,Object? currentStoreKeepers = null,Object? currentDrivers = null,Object? currentAdminUsers = null,Object? currentActiveProducts = null,Object? storageUsedMb = null,Object? apiCallsToday = null,Object? lastActivityAt = freezed,Object? monthlyHistory = null,}) {
  return _then(_CompanyUsageStats(
currentMonthUnitCodes: null == currentMonthUnitCodes ? _self.currentMonthUnitCodes : currentMonthUnitCodes // ignore: cast_nullable_to_non_nullable
as int,currentMonthPacketCodes: null == currentMonthPacketCodes ? _self.currentMonthPacketCodes : currentMonthPacketCodes // ignore: cast_nullable_to_non_nullable
as int,currentMonthCartonCodes: null == currentMonthCartonCodes ? _self.currentMonthCartonCodes : currentMonthCartonCodes // ignore: cast_nullable_to_non_nullable
as int,currentMonthBundleCodes: null == currentMonthBundleCodes ? _self.currentMonthBundleCodes : currentMonthBundleCodes // ignore: cast_nullable_to_non_nullable
as int,totalUnitCodes: null == totalUnitCodes ? _self.totalUnitCodes : totalUnitCodes // ignore: cast_nullable_to_non_nullable
as int,totalPacketCodes: null == totalPacketCodes ? _self.totalPacketCodes : totalPacketCodes // ignore: cast_nullable_to_non_nullable
as int,totalCartonCodes: null == totalCartonCodes ? _self.totalCartonCodes : totalCartonCodes // ignore: cast_nullable_to_non_nullable
as int,totalBundleCodes: null == totalBundleCodes ? _self.totalBundleCodes : totalBundleCodes // ignore: cast_nullable_to_non_nullable
as int,currentStoreKeepers: null == currentStoreKeepers ? _self.currentStoreKeepers : currentStoreKeepers // ignore: cast_nullable_to_non_nullable
as int,currentDrivers: null == currentDrivers ? _self.currentDrivers : currentDrivers // ignore: cast_nullable_to_non_nullable
as int,currentAdminUsers: null == currentAdminUsers ? _self.currentAdminUsers : currentAdminUsers // ignore: cast_nullable_to_non_nullable
as int,currentActiveProducts: null == currentActiveProducts ? _self.currentActiveProducts : currentActiveProducts // ignore: cast_nullable_to_non_nullable
as int,storageUsedMb: null == storageUsedMb ? _self.storageUsedMb : storageUsedMb // ignore: cast_nullable_to_non_nullable
as int,apiCallsToday: null == apiCallsToday ? _self.apiCallsToday : apiCallsToday // ignore: cast_nullable_to_non_nullable
as int,lastActivityAt: freezed == lastActivityAt ? _self.lastActivityAt : lastActivityAt // ignore: cast_nullable_to_non_nullable
as DateTime?,monthlyHistory: null == monthlyHistory ? _self._monthlyHistory : monthlyHistory // ignore: cast_nullable_to_non_nullable
as List<MonthlyUsage>,
  ));
}


}

/// @nodoc
mixin _$MonthlyUsage {

/// Year and month (format: YYYY-MM)
@JsonKey(name: 'month') String get month;/// Unit codes used in this month
@JsonKey(name: 'unit_codes') int get unitCodes;/// Packet codes used in this month
@JsonKey(name: 'packet_codes') int get packetCodes;/// Carton codes used in this month
@JsonKey(name: 'carton_codes') int get cartonCodes;/// Bundle codes used in this month
@JsonKey(name: 'bundle_codes') int get bundleCodes;/// Storage used in MB
@JsonKey(name: 'storage_used_mb') int get storageUsedMb;/// API calls made
@JsonKey(name: 'api_calls') int get apiCalls;
/// Create a copy of MonthlyUsage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthlyUsageCopyWith<MonthlyUsage> get copyWith => _$MonthlyUsageCopyWithImpl<MonthlyUsage>(this as MonthlyUsage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthlyUsage&&(identical(other.month, month) || other.month == month)&&(identical(other.unitCodes, unitCodes) || other.unitCodes == unitCodes)&&(identical(other.packetCodes, packetCodes) || other.packetCodes == packetCodes)&&(identical(other.cartonCodes, cartonCodes) || other.cartonCodes == cartonCodes)&&(identical(other.bundleCodes, bundleCodes) || other.bundleCodes == bundleCodes)&&(identical(other.storageUsedMb, storageUsedMb) || other.storageUsedMb == storageUsedMb)&&(identical(other.apiCalls, apiCalls) || other.apiCalls == apiCalls));
}


@override
int get hashCode => Object.hash(runtimeType,month,unitCodes,packetCodes,cartonCodes,bundleCodes,storageUsedMb,apiCalls);

@override
String toString() {
  return 'MonthlyUsage(month: $month, unitCodes: $unitCodes, packetCodes: $packetCodes, cartonCodes: $cartonCodes, bundleCodes: $bundleCodes, storageUsedMb: $storageUsedMb, apiCalls: $apiCalls)';
}


}

/// @nodoc
abstract mixin class $MonthlyUsageCopyWith<$Res>  {
  factory $MonthlyUsageCopyWith(MonthlyUsage value, $Res Function(MonthlyUsage) _then) = _$MonthlyUsageCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'month') String month,@JsonKey(name: 'unit_codes') int unitCodes,@JsonKey(name: 'packet_codes') int packetCodes,@JsonKey(name: 'carton_codes') int cartonCodes,@JsonKey(name: 'bundle_codes') int bundleCodes,@JsonKey(name: 'storage_used_mb') int storageUsedMb,@JsonKey(name: 'api_calls') int apiCalls
});




}
/// @nodoc
class _$MonthlyUsageCopyWithImpl<$Res>
    implements $MonthlyUsageCopyWith<$Res> {
  _$MonthlyUsageCopyWithImpl(this._self, this._then);

  final MonthlyUsage _self;
  final $Res Function(MonthlyUsage) _then;

/// Create a copy of MonthlyUsage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? month = null,Object? unitCodes = null,Object? packetCodes = null,Object? cartonCodes = null,Object? bundleCodes = null,Object? storageUsedMb = null,Object? apiCalls = null,}) {
  return _then(_self.copyWith(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as String,unitCodes: null == unitCodes ? _self.unitCodes : unitCodes // ignore: cast_nullable_to_non_nullable
as int,packetCodes: null == packetCodes ? _self.packetCodes : packetCodes // ignore: cast_nullable_to_non_nullable
as int,cartonCodes: null == cartonCodes ? _self.cartonCodes : cartonCodes // ignore: cast_nullable_to_non_nullable
as int,bundleCodes: null == bundleCodes ? _self.bundleCodes : bundleCodes // ignore: cast_nullable_to_non_nullable
as int,storageUsedMb: null == storageUsedMb ? _self.storageUsedMb : storageUsedMb // ignore: cast_nullable_to_non_nullable
as int,apiCalls: null == apiCalls ? _self.apiCalls : apiCalls // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MonthlyUsage].
extension MonthlyUsagePatterns on MonthlyUsage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MonthlyUsage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MonthlyUsage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MonthlyUsage value)  $default,){
final _that = this;
switch (_that) {
case _MonthlyUsage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MonthlyUsage value)?  $default,){
final _that = this;
switch (_that) {
case _MonthlyUsage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'month')  String month, @JsonKey(name: 'unit_codes')  int unitCodes, @JsonKey(name: 'packet_codes')  int packetCodes, @JsonKey(name: 'carton_codes')  int cartonCodes, @JsonKey(name: 'bundle_codes')  int bundleCodes, @JsonKey(name: 'storage_used_mb')  int storageUsedMb, @JsonKey(name: 'api_calls')  int apiCalls)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MonthlyUsage() when $default != null:
return $default(_that.month,_that.unitCodes,_that.packetCodes,_that.cartonCodes,_that.bundleCodes,_that.storageUsedMb,_that.apiCalls);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'month')  String month, @JsonKey(name: 'unit_codes')  int unitCodes, @JsonKey(name: 'packet_codes')  int packetCodes, @JsonKey(name: 'carton_codes')  int cartonCodes, @JsonKey(name: 'bundle_codes')  int bundleCodes, @JsonKey(name: 'storage_used_mb')  int storageUsedMb, @JsonKey(name: 'api_calls')  int apiCalls)  $default,) {final _that = this;
switch (_that) {
case _MonthlyUsage():
return $default(_that.month,_that.unitCodes,_that.packetCodes,_that.cartonCodes,_that.bundleCodes,_that.storageUsedMb,_that.apiCalls);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'month')  String month, @JsonKey(name: 'unit_codes')  int unitCodes, @JsonKey(name: 'packet_codes')  int packetCodes, @JsonKey(name: 'carton_codes')  int cartonCodes, @JsonKey(name: 'bundle_codes')  int bundleCodes, @JsonKey(name: 'storage_used_mb')  int storageUsedMb, @JsonKey(name: 'api_calls')  int apiCalls)?  $default,) {final _that = this;
switch (_that) {
case _MonthlyUsage() when $default != null:
return $default(_that.month,_that.unitCodes,_that.packetCodes,_that.cartonCodes,_that.bundleCodes,_that.storageUsedMb,_that.apiCalls);case _:
  return null;

}
}

}

/// @nodoc


class _MonthlyUsage extends MonthlyUsage {
  const _MonthlyUsage({@JsonKey(name: 'month') required this.month, @JsonKey(name: 'unit_codes') this.unitCodes = 0, @JsonKey(name: 'packet_codes') this.packetCodes = 0, @JsonKey(name: 'carton_codes') this.cartonCodes = 0, @JsonKey(name: 'bundle_codes') this.bundleCodes = 0, @JsonKey(name: 'storage_used_mb') this.storageUsedMb = 0, @JsonKey(name: 'api_calls') this.apiCalls = 0}): super._();
  

/// Year and month (format: YYYY-MM)
@override@JsonKey(name: 'month') final  String month;
/// Unit codes used in this month
@override@JsonKey(name: 'unit_codes') final  int unitCodes;
/// Packet codes used in this month
@override@JsonKey(name: 'packet_codes') final  int packetCodes;
/// Carton codes used in this month
@override@JsonKey(name: 'carton_codes') final  int cartonCodes;
/// Bundle codes used in this month
@override@JsonKey(name: 'bundle_codes') final  int bundleCodes;
/// Storage used in MB
@override@JsonKey(name: 'storage_used_mb') final  int storageUsedMb;
/// API calls made
@override@JsonKey(name: 'api_calls') final  int apiCalls;

/// Create a copy of MonthlyUsage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthlyUsageCopyWith<_MonthlyUsage> get copyWith => __$MonthlyUsageCopyWithImpl<_MonthlyUsage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthlyUsage&&(identical(other.month, month) || other.month == month)&&(identical(other.unitCodes, unitCodes) || other.unitCodes == unitCodes)&&(identical(other.packetCodes, packetCodes) || other.packetCodes == packetCodes)&&(identical(other.cartonCodes, cartonCodes) || other.cartonCodes == cartonCodes)&&(identical(other.bundleCodes, bundleCodes) || other.bundleCodes == bundleCodes)&&(identical(other.storageUsedMb, storageUsedMb) || other.storageUsedMb == storageUsedMb)&&(identical(other.apiCalls, apiCalls) || other.apiCalls == apiCalls));
}


@override
int get hashCode => Object.hash(runtimeType,month,unitCodes,packetCodes,cartonCodes,bundleCodes,storageUsedMb,apiCalls);

@override
String toString() {
  return 'MonthlyUsage(month: $month, unitCodes: $unitCodes, packetCodes: $packetCodes, cartonCodes: $cartonCodes, bundleCodes: $bundleCodes, storageUsedMb: $storageUsedMb, apiCalls: $apiCalls)';
}


}

/// @nodoc
abstract mixin class _$MonthlyUsageCopyWith<$Res> implements $MonthlyUsageCopyWith<$Res> {
  factory _$MonthlyUsageCopyWith(_MonthlyUsage value, $Res Function(_MonthlyUsage) _then) = __$MonthlyUsageCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'month') String month,@JsonKey(name: 'unit_codes') int unitCodes,@JsonKey(name: 'packet_codes') int packetCodes,@JsonKey(name: 'carton_codes') int cartonCodes,@JsonKey(name: 'bundle_codes') int bundleCodes,@JsonKey(name: 'storage_used_mb') int storageUsedMb,@JsonKey(name: 'api_calls') int apiCalls
});




}
/// @nodoc
class __$MonthlyUsageCopyWithImpl<$Res>
    implements _$MonthlyUsageCopyWith<$Res> {
  __$MonthlyUsageCopyWithImpl(this._self, this._then);

  final _MonthlyUsage _self;
  final $Res Function(_MonthlyUsage) _then;

/// Create a copy of MonthlyUsage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? month = null,Object? unitCodes = null,Object? packetCodes = null,Object? cartonCodes = null,Object? bundleCodes = null,Object? storageUsedMb = null,Object? apiCalls = null,}) {
  return _then(_MonthlyUsage(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as String,unitCodes: null == unitCodes ? _self.unitCodes : unitCodes // ignore: cast_nullable_to_non_nullable
as int,packetCodes: null == packetCodes ? _self.packetCodes : packetCodes // ignore: cast_nullable_to_non_nullable
as int,cartonCodes: null == cartonCodes ? _self.cartonCodes : cartonCodes // ignore: cast_nullable_to_non_nullable
as int,bundleCodes: null == bundleCodes ? _self.bundleCodes : bundleCodes // ignore: cast_nullable_to_non_nullable
as int,storageUsedMb: null == storageUsedMb ? _self.storageUsedMb : storageUsedMb // ignore: cast_nullable_to_non_nullable
as int,apiCalls: null == apiCalls ? _self.apiCalls : apiCalls // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on

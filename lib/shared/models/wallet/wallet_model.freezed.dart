// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WalletModel {

/// Unique identifier
 String get id;/// User ID (foreign key to users table)
 String get userId;/// Type of user (determines minimum balance requirements)
 UserType get userType;/// Current wallet balance
 double get balance;/// Minimum required balance (₹100 for drivers, ₹500 for others)
 double get minimumBalance;/// Last transaction timestamp
 DateTime get lastUpdated;/// Whether wallet is active
 bool get isActive;/// Wallet currency (default: PKR)
 String get currency;/// Daily transaction limit
 double get dailyLimit;/// Monthly transaction limit
 double get monthlyLimit;/// Total transactions count
 int get transactionCount;/// Total amount transacted
 double get totalTransacted;/// Wallet creation timestamp
 DateTime get createdAt;/// Wallet last activity timestamp
 DateTime? get lastActivityAt;/// Additional metadata
 Map<String, dynamic>? get metadata;
/// Create a copy of WalletModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WalletModelCopyWith<WalletModel> get copyWith => _$WalletModelCopyWithImpl<WalletModel>(this as WalletModel, _$identity);

  /// Serializes this WalletModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WalletModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userType, userType) || other.userType == userType)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.minimumBalance, minimumBalance) || other.minimumBalance == minimumBalance)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.dailyLimit, dailyLimit) || other.dailyLimit == dailyLimit)&&(identical(other.monthlyLimit, monthlyLimit) || other.monthlyLimit == monthlyLimit)&&(identical(other.transactionCount, transactionCount) || other.transactionCount == transactionCount)&&(identical(other.totalTransacted, totalTransacted) || other.totalTransacted == totalTransacted)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastActivityAt, lastActivityAt) || other.lastActivityAt == lastActivityAt)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,userType,balance,minimumBalance,lastUpdated,isActive,currency,dailyLimit,monthlyLimit,transactionCount,totalTransacted,createdAt,lastActivityAt,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'WalletModel(id: $id, userId: $userId, userType: $userType, balance: $balance, minimumBalance: $minimumBalance, lastUpdated: $lastUpdated, isActive: $isActive, currency: $currency, dailyLimit: $dailyLimit, monthlyLimit: $monthlyLimit, transactionCount: $transactionCount, totalTransacted: $totalTransacted, createdAt: $createdAt, lastActivityAt: $lastActivityAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $WalletModelCopyWith<$Res>  {
  factory $WalletModelCopyWith(WalletModel value, $Res Function(WalletModel) _then) = _$WalletModelCopyWithImpl;
@useResult
$Res call({
 String id, String userId, UserType userType, double balance, double minimumBalance, DateTime lastUpdated, bool isActive, String currency, double dailyLimit, double monthlyLimit, int transactionCount, double totalTransacted, DateTime createdAt, DateTime? lastActivityAt, Map<String, dynamic>? metadata
});




}
/// @nodoc
class _$WalletModelCopyWithImpl<$Res>
    implements $WalletModelCopyWith<$Res> {
  _$WalletModelCopyWithImpl(this._self, this._then);

  final WalletModel _self;
  final $Res Function(WalletModel) _then;

/// Create a copy of WalletModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? userType = null,Object? balance = null,Object? minimumBalance = null,Object? lastUpdated = null,Object? isActive = null,Object? currency = null,Object? dailyLimit = null,Object? monthlyLimit = null,Object? transactionCount = null,Object? totalTransacted = null,Object? createdAt = null,Object? lastActivityAt = freezed,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userType: null == userType ? _self.userType : userType // ignore: cast_nullable_to_non_nullable
as UserType,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,minimumBalance: null == minimumBalance ? _self.minimumBalance : minimumBalance // ignore: cast_nullable_to_non_nullable
as double,lastUpdated: null == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,dailyLimit: null == dailyLimit ? _self.dailyLimit : dailyLimit // ignore: cast_nullable_to_non_nullable
as double,monthlyLimit: null == monthlyLimit ? _self.monthlyLimit : monthlyLimit // ignore: cast_nullable_to_non_nullable
as double,transactionCount: null == transactionCount ? _self.transactionCount : transactionCount // ignore: cast_nullable_to_non_nullable
as int,totalTransacted: null == totalTransacted ? _self.totalTransacted : totalTransacted // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastActivityAt: freezed == lastActivityAt ? _self.lastActivityAt : lastActivityAt // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [WalletModel].
extension WalletModelPatterns on WalletModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WalletModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WalletModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WalletModel value)  $default,){
final _that = this;
switch (_that) {
case _WalletModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WalletModel value)?  $default,){
final _that = this;
switch (_that) {
case _WalletModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  UserType userType,  double balance,  double minimumBalance,  DateTime lastUpdated,  bool isActive,  String currency,  double dailyLimit,  double monthlyLimit,  int transactionCount,  double totalTransacted,  DateTime createdAt,  DateTime? lastActivityAt,  Map<String, dynamic>? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WalletModel() when $default != null:
return $default(_that.id,_that.userId,_that.userType,_that.balance,_that.minimumBalance,_that.lastUpdated,_that.isActive,_that.currency,_that.dailyLimit,_that.monthlyLimit,_that.transactionCount,_that.totalTransacted,_that.createdAt,_that.lastActivityAt,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  UserType userType,  double balance,  double minimumBalance,  DateTime lastUpdated,  bool isActive,  String currency,  double dailyLimit,  double monthlyLimit,  int transactionCount,  double totalTransacted,  DateTime createdAt,  DateTime? lastActivityAt,  Map<String, dynamic>? metadata)  $default,) {final _that = this;
switch (_that) {
case _WalletModel():
return $default(_that.id,_that.userId,_that.userType,_that.balance,_that.minimumBalance,_that.lastUpdated,_that.isActive,_that.currency,_that.dailyLimit,_that.monthlyLimit,_that.transactionCount,_that.totalTransacted,_that.createdAt,_that.lastActivityAt,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  UserType userType,  double balance,  double minimumBalance,  DateTime lastUpdated,  bool isActive,  String currency,  double dailyLimit,  double monthlyLimit,  int transactionCount,  double totalTransacted,  DateTime createdAt,  DateTime? lastActivityAt,  Map<String, dynamic>? metadata)?  $default,) {final _that = this;
switch (_that) {
case _WalletModel() when $default != null:
return $default(_that.id,_that.userId,_that.userType,_that.balance,_that.minimumBalance,_that.lastUpdated,_that.isActive,_that.currency,_that.dailyLimit,_that.monthlyLimit,_that.transactionCount,_that.totalTransacted,_that.createdAt,_that.lastActivityAt,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WalletModel extends WalletModel {
  const _WalletModel({required this.id, required this.userId, required this.userType, this.balance = 0.0, required this.minimumBalance, required this.lastUpdated, this.isActive = true, this.currency = 'PKR', this.dailyLimit = 100000.0, this.monthlyLimit = 1000000.0, this.transactionCount = 0, this.totalTransacted = 0.0, required this.createdAt, this.lastActivityAt, final  Map<String, dynamic>? metadata}): _metadata = metadata,super._();
  factory _WalletModel.fromJson(Map<String, dynamic> json) => _$WalletModelFromJson(json);

/// Unique identifier
@override final  String id;
/// User ID (foreign key to users table)
@override final  String userId;
/// Type of user (determines minimum balance requirements)
@override final  UserType userType;
/// Current wallet balance
@override@JsonKey() final  double balance;
/// Minimum required balance (₹100 for drivers, ₹500 for others)
@override final  double minimumBalance;
/// Last transaction timestamp
@override final  DateTime lastUpdated;
/// Whether wallet is active
@override@JsonKey() final  bool isActive;
/// Wallet currency (default: PKR)
@override@JsonKey() final  String currency;
/// Daily transaction limit
@override@JsonKey() final  double dailyLimit;
/// Monthly transaction limit
@override@JsonKey() final  double monthlyLimit;
/// Total transactions count
@override@JsonKey() final  int transactionCount;
/// Total amount transacted
@override@JsonKey() final  double totalTransacted;
/// Wallet creation timestamp
@override final  DateTime createdAt;
/// Wallet last activity timestamp
@override final  DateTime? lastActivityAt;
/// Additional metadata
 final  Map<String, dynamic>? _metadata;
/// Additional metadata
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of WalletModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WalletModelCopyWith<_WalletModel> get copyWith => __$WalletModelCopyWithImpl<_WalletModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WalletModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WalletModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userType, userType) || other.userType == userType)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.minimumBalance, minimumBalance) || other.minimumBalance == minimumBalance)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.dailyLimit, dailyLimit) || other.dailyLimit == dailyLimit)&&(identical(other.monthlyLimit, monthlyLimit) || other.monthlyLimit == monthlyLimit)&&(identical(other.transactionCount, transactionCount) || other.transactionCount == transactionCount)&&(identical(other.totalTransacted, totalTransacted) || other.totalTransacted == totalTransacted)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastActivityAt, lastActivityAt) || other.lastActivityAt == lastActivityAt)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,userType,balance,minimumBalance,lastUpdated,isActive,currency,dailyLimit,monthlyLimit,transactionCount,totalTransacted,createdAt,lastActivityAt,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'WalletModel(id: $id, userId: $userId, userType: $userType, balance: $balance, minimumBalance: $minimumBalance, lastUpdated: $lastUpdated, isActive: $isActive, currency: $currency, dailyLimit: $dailyLimit, monthlyLimit: $monthlyLimit, transactionCount: $transactionCount, totalTransacted: $totalTransacted, createdAt: $createdAt, lastActivityAt: $lastActivityAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$WalletModelCopyWith<$Res> implements $WalletModelCopyWith<$Res> {
  factory _$WalletModelCopyWith(_WalletModel value, $Res Function(_WalletModel) _then) = __$WalletModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, UserType userType, double balance, double minimumBalance, DateTime lastUpdated, bool isActive, String currency, double dailyLimit, double monthlyLimit, int transactionCount, double totalTransacted, DateTime createdAt, DateTime? lastActivityAt, Map<String, dynamic>? metadata
});




}
/// @nodoc
class __$WalletModelCopyWithImpl<$Res>
    implements _$WalletModelCopyWith<$Res> {
  __$WalletModelCopyWithImpl(this._self, this._then);

  final _WalletModel _self;
  final $Res Function(_WalletModel) _then;

/// Create a copy of WalletModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? userType = null,Object? balance = null,Object? minimumBalance = null,Object? lastUpdated = null,Object? isActive = null,Object? currency = null,Object? dailyLimit = null,Object? monthlyLimit = null,Object? transactionCount = null,Object? totalTransacted = null,Object? createdAt = null,Object? lastActivityAt = freezed,Object? metadata = freezed,}) {
  return _then(_WalletModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userType: null == userType ? _self.userType : userType // ignore: cast_nullable_to_non_nullable
as UserType,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,minimumBalance: null == minimumBalance ? _self.minimumBalance : minimumBalance // ignore: cast_nullable_to_non_nullable
as double,lastUpdated: null == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,dailyLimit: null == dailyLimit ? _self.dailyLimit : dailyLimit // ignore: cast_nullable_to_non_nullable
as double,monthlyLimit: null == monthlyLimit ? _self.monthlyLimit : monthlyLimit // ignore: cast_nullable_to_non_nullable
as double,transactionCount: null == transactionCount ? _self.transactionCount : transactionCount // ignore: cast_nullable_to_non_nullable
as int,totalTransacted: null == totalTransacted ? _self.totalTransacted : totalTransacted // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastActivityAt: freezed == lastActivityAt ? _self.lastActivityAt : lastActivityAt // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}


/// @nodoc
mixin _$WalletTransactionModel {

/// Unique identifier
 String get id;/// Wallet ID (foreign key)
 String get walletId;/// Transaction type
 TransactionType get type;/// Transaction amount (positive for credit, negative for debit)
 double get amount;/// Transaction status
 TransactionStatus get status;/// Description of transaction
 String get description;/// Reference ID (trip ID, load ID, bid ID, subscription ID, etc.)
 String? get referenceId;/// From user ID (if applicable)
 String? get fromUserId;/// To user ID (if applicable)
 String? get toUserId;/// Commission percentage (if type is commission)
 double? get commissionPercentage;/// Commission amount (if type is commission)
 double? get commissionAmount;/// Connection fee details (if type is connectionFee)
 String? get connectionDetails;/// Fraud penalty reason (if type is penalty)
 String? get penaltyReason;/// Trip details (if type is tripPayment)
 String? get tripDetails;/// Subscription details (if type is subscriptionPayment)
 String? get subscriptionDetails;/// Additional metadata
 Map<String, dynamic>? get metadata;/// Transaction creation timestamp
 DateTime get createdAt;/// Transaction completion timestamp
 DateTime? get completedAt;/// Transaction failure/cancellation reason
 String? get failureReason;/// Receipt/Proof URL
 String? get receiptUrl;/// Bank/Wallet reference number
 String? get referenceNumber;
/// Create a copy of WalletTransactionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WalletTransactionModelCopyWith<WalletTransactionModel> get copyWith => _$WalletTransactionModelCopyWithImpl<WalletTransactionModel>(this as WalletTransactionModel, _$identity);

  /// Serializes this WalletTransactionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WalletTransactionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.status, status) || other.status == status)&&(identical(other.description, description) || other.description == description)&&(identical(other.referenceId, referenceId) || other.referenceId == referenceId)&&(identical(other.fromUserId, fromUserId) || other.fromUserId == fromUserId)&&(identical(other.toUserId, toUserId) || other.toUserId == toUserId)&&(identical(other.commissionPercentage, commissionPercentage) || other.commissionPercentage == commissionPercentage)&&(identical(other.commissionAmount, commissionAmount) || other.commissionAmount == commissionAmount)&&(identical(other.connectionDetails, connectionDetails) || other.connectionDetails == connectionDetails)&&(identical(other.penaltyReason, penaltyReason) || other.penaltyReason == penaltyReason)&&(identical(other.tripDetails, tripDetails) || other.tripDetails == tripDetails)&&(identical(other.subscriptionDetails, subscriptionDetails) || other.subscriptionDetails == subscriptionDetails)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.failureReason, failureReason) || other.failureReason == failureReason)&&(identical(other.receiptUrl, receiptUrl) || other.receiptUrl == receiptUrl)&&(identical(other.referenceNumber, referenceNumber) || other.referenceNumber == referenceNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,walletId,type,amount,status,description,referenceId,fromUserId,toUserId,commissionPercentage,commissionAmount,connectionDetails,penaltyReason,tripDetails,subscriptionDetails,const DeepCollectionEquality().hash(metadata),createdAt,completedAt,failureReason,receiptUrl,referenceNumber]);

@override
String toString() {
  return 'WalletTransactionModel(id: $id, walletId: $walletId, type: $type, amount: $amount, status: $status, description: $description, referenceId: $referenceId, fromUserId: $fromUserId, toUserId: $toUserId, commissionPercentage: $commissionPercentage, commissionAmount: $commissionAmount, connectionDetails: $connectionDetails, penaltyReason: $penaltyReason, tripDetails: $tripDetails, subscriptionDetails: $subscriptionDetails, metadata: $metadata, createdAt: $createdAt, completedAt: $completedAt, failureReason: $failureReason, receiptUrl: $receiptUrl, referenceNumber: $referenceNumber)';
}


}

/// @nodoc
abstract mixin class $WalletTransactionModelCopyWith<$Res>  {
  factory $WalletTransactionModelCopyWith(WalletTransactionModel value, $Res Function(WalletTransactionModel) _then) = _$WalletTransactionModelCopyWithImpl;
@useResult
$Res call({
 String id, String walletId, TransactionType type, double amount, TransactionStatus status, String description, String? referenceId, String? fromUserId, String? toUserId, double? commissionPercentage, double? commissionAmount, String? connectionDetails, String? penaltyReason, String? tripDetails, String? subscriptionDetails, Map<String, dynamic>? metadata, DateTime createdAt, DateTime? completedAt, String? failureReason, String? receiptUrl, String? referenceNumber
});




}
/// @nodoc
class _$WalletTransactionModelCopyWithImpl<$Res>
    implements $WalletTransactionModelCopyWith<$Res> {
  _$WalletTransactionModelCopyWithImpl(this._self, this._then);

  final WalletTransactionModel _self;
  final $Res Function(WalletTransactionModel) _then;

/// Create a copy of WalletTransactionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? walletId = null,Object? type = null,Object? amount = null,Object? status = null,Object? description = null,Object? referenceId = freezed,Object? fromUserId = freezed,Object? toUserId = freezed,Object? commissionPercentage = freezed,Object? commissionAmount = freezed,Object? connectionDetails = freezed,Object? penaltyReason = freezed,Object? tripDetails = freezed,Object? subscriptionDetails = freezed,Object? metadata = freezed,Object? createdAt = null,Object? completedAt = freezed,Object? failureReason = freezed,Object? receiptUrl = freezed,Object? referenceNumber = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,walletId: null == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TransactionStatus,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,referenceId: freezed == referenceId ? _self.referenceId : referenceId // ignore: cast_nullable_to_non_nullable
as String?,fromUserId: freezed == fromUserId ? _self.fromUserId : fromUserId // ignore: cast_nullable_to_non_nullable
as String?,toUserId: freezed == toUserId ? _self.toUserId : toUserId // ignore: cast_nullable_to_non_nullable
as String?,commissionPercentage: freezed == commissionPercentage ? _self.commissionPercentage : commissionPercentage // ignore: cast_nullable_to_non_nullable
as double?,commissionAmount: freezed == commissionAmount ? _self.commissionAmount : commissionAmount // ignore: cast_nullable_to_non_nullable
as double?,connectionDetails: freezed == connectionDetails ? _self.connectionDetails : connectionDetails // ignore: cast_nullable_to_non_nullable
as String?,penaltyReason: freezed == penaltyReason ? _self.penaltyReason : penaltyReason // ignore: cast_nullable_to_non_nullable
as String?,tripDetails: freezed == tripDetails ? _self.tripDetails : tripDetails // ignore: cast_nullable_to_non_nullable
as String?,subscriptionDetails: freezed == subscriptionDetails ? _self.subscriptionDetails : subscriptionDetails // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,failureReason: freezed == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String?,receiptUrl: freezed == receiptUrl ? _self.receiptUrl : receiptUrl // ignore: cast_nullable_to_non_nullable
as String?,referenceNumber: freezed == referenceNumber ? _self.referenceNumber : referenceNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WalletTransactionModel].
extension WalletTransactionModelPatterns on WalletTransactionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WalletTransactionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WalletTransactionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WalletTransactionModel value)  $default,){
final _that = this;
switch (_that) {
case _WalletTransactionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WalletTransactionModel value)?  $default,){
final _that = this;
switch (_that) {
case _WalletTransactionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String walletId,  TransactionType type,  double amount,  TransactionStatus status,  String description,  String? referenceId,  String? fromUserId,  String? toUserId,  double? commissionPercentage,  double? commissionAmount,  String? connectionDetails,  String? penaltyReason,  String? tripDetails,  String? subscriptionDetails,  Map<String, dynamic>? metadata,  DateTime createdAt,  DateTime? completedAt,  String? failureReason,  String? receiptUrl,  String? referenceNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WalletTransactionModel() when $default != null:
return $default(_that.id,_that.walletId,_that.type,_that.amount,_that.status,_that.description,_that.referenceId,_that.fromUserId,_that.toUserId,_that.commissionPercentage,_that.commissionAmount,_that.connectionDetails,_that.penaltyReason,_that.tripDetails,_that.subscriptionDetails,_that.metadata,_that.createdAt,_that.completedAt,_that.failureReason,_that.receiptUrl,_that.referenceNumber);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String walletId,  TransactionType type,  double amount,  TransactionStatus status,  String description,  String? referenceId,  String? fromUserId,  String? toUserId,  double? commissionPercentage,  double? commissionAmount,  String? connectionDetails,  String? penaltyReason,  String? tripDetails,  String? subscriptionDetails,  Map<String, dynamic>? metadata,  DateTime createdAt,  DateTime? completedAt,  String? failureReason,  String? receiptUrl,  String? referenceNumber)  $default,) {final _that = this;
switch (_that) {
case _WalletTransactionModel():
return $default(_that.id,_that.walletId,_that.type,_that.amount,_that.status,_that.description,_that.referenceId,_that.fromUserId,_that.toUserId,_that.commissionPercentage,_that.commissionAmount,_that.connectionDetails,_that.penaltyReason,_that.tripDetails,_that.subscriptionDetails,_that.metadata,_that.createdAt,_that.completedAt,_that.failureReason,_that.receiptUrl,_that.referenceNumber);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String walletId,  TransactionType type,  double amount,  TransactionStatus status,  String description,  String? referenceId,  String? fromUserId,  String? toUserId,  double? commissionPercentage,  double? commissionAmount,  String? connectionDetails,  String? penaltyReason,  String? tripDetails,  String? subscriptionDetails,  Map<String, dynamic>? metadata,  DateTime createdAt,  DateTime? completedAt,  String? failureReason,  String? receiptUrl,  String? referenceNumber)?  $default,) {final _that = this;
switch (_that) {
case _WalletTransactionModel() when $default != null:
return $default(_that.id,_that.walletId,_that.type,_that.amount,_that.status,_that.description,_that.referenceId,_that.fromUserId,_that.toUserId,_that.commissionPercentage,_that.commissionAmount,_that.connectionDetails,_that.penaltyReason,_that.tripDetails,_that.subscriptionDetails,_that.metadata,_that.createdAt,_that.completedAt,_that.failureReason,_that.receiptUrl,_that.referenceNumber);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WalletTransactionModel extends WalletTransactionModel {
  const _WalletTransactionModel({required this.id, required this.walletId, required this.type, required this.amount, this.status = TransactionStatus.pending, required this.description, this.referenceId, this.fromUserId, this.toUserId, this.commissionPercentage, this.commissionAmount, this.connectionDetails, this.penaltyReason, this.tripDetails, this.subscriptionDetails, final  Map<String, dynamic>? metadata, required this.createdAt, this.completedAt, this.failureReason, this.receiptUrl, this.referenceNumber}): _metadata = metadata,super._();
  factory _WalletTransactionModel.fromJson(Map<String, dynamic> json) => _$WalletTransactionModelFromJson(json);

/// Unique identifier
@override final  String id;
/// Wallet ID (foreign key)
@override final  String walletId;
/// Transaction type
@override final  TransactionType type;
/// Transaction amount (positive for credit, negative for debit)
@override final  double amount;
/// Transaction status
@override@JsonKey() final  TransactionStatus status;
/// Description of transaction
@override final  String description;
/// Reference ID (trip ID, load ID, bid ID, subscription ID, etc.)
@override final  String? referenceId;
/// From user ID (if applicable)
@override final  String? fromUserId;
/// To user ID (if applicable)
@override final  String? toUserId;
/// Commission percentage (if type is commission)
@override final  double? commissionPercentage;
/// Commission amount (if type is commission)
@override final  double? commissionAmount;
/// Connection fee details (if type is connectionFee)
@override final  String? connectionDetails;
/// Fraud penalty reason (if type is penalty)
@override final  String? penaltyReason;
/// Trip details (if type is tripPayment)
@override final  String? tripDetails;
/// Subscription details (if type is subscriptionPayment)
@override final  String? subscriptionDetails;
/// Additional metadata
 final  Map<String, dynamic>? _metadata;
/// Additional metadata
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// Transaction creation timestamp
@override final  DateTime createdAt;
/// Transaction completion timestamp
@override final  DateTime? completedAt;
/// Transaction failure/cancellation reason
@override final  String? failureReason;
/// Receipt/Proof URL
@override final  String? receiptUrl;
/// Bank/Wallet reference number
@override final  String? referenceNumber;

/// Create a copy of WalletTransactionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WalletTransactionModelCopyWith<_WalletTransactionModel> get copyWith => __$WalletTransactionModelCopyWithImpl<_WalletTransactionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WalletTransactionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WalletTransactionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.status, status) || other.status == status)&&(identical(other.description, description) || other.description == description)&&(identical(other.referenceId, referenceId) || other.referenceId == referenceId)&&(identical(other.fromUserId, fromUserId) || other.fromUserId == fromUserId)&&(identical(other.toUserId, toUserId) || other.toUserId == toUserId)&&(identical(other.commissionPercentage, commissionPercentage) || other.commissionPercentage == commissionPercentage)&&(identical(other.commissionAmount, commissionAmount) || other.commissionAmount == commissionAmount)&&(identical(other.connectionDetails, connectionDetails) || other.connectionDetails == connectionDetails)&&(identical(other.penaltyReason, penaltyReason) || other.penaltyReason == penaltyReason)&&(identical(other.tripDetails, tripDetails) || other.tripDetails == tripDetails)&&(identical(other.subscriptionDetails, subscriptionDetails) || other.subscriptionDetails == subscriptionDetails)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.failureReason, failureReason) || other.failureReason == failureReason)&&(identical(other.receiptUrl, receiptUrl) || other.receiptUrl == receiptUrl)&&(identical(other.referenceNumber, referenceNumber) || other.referenceNumber == referenceNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,walletId,type,amount,status,description,referenceId,fromUserId,toUserId,commissionPercentage,commissionAmount,connectionDetails,penaltyReason,tripDetails,subscriptionDetails,const DeepCollectionEquality().hash(_metadata),createdAt,completedAt,failureReason,receiptUrl,referenceNumber]);

@override
String toString() {
  return 'WalletTransactionModel(id: $id, walletId: $walletId, type: $type, amount: $amount, status: $status, description: $description, referenceId: $referenceId, fromUserId: $fromUserId, toUserId: $toUserId, commissionPercentage: $commissionPercentage, commissionAmount: $commissionAmount, connectionDetails: $connectionDetails, penaltyReason: $penaltyReason, tripDetails: $tripDetails, subscriptionDetails: $subscriptionDetails, metadata: $metadata, createdAt: $createdAt, completedAt: $completedAt, failureReason: $failureReason, receiptUrl: $receiptUrl, referenceNumber: $referenceNumber)';
}


}

/// @nodoc
abstract mixin class _$WalletTransactionModelCopyWith<$Res> implements $WalletTransactionModelCopyWith<$Res> {
  factory _$WalletTransactionModelCopyWith(_WalletTransactionModel value, $Res Function(_WalletTransactionModel) _then) = __$WalletTransactionModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String walletId, TransactionType type, double amount, TransactionStatus status, String description, String? referenceId, String? fromUserId, String? toUserId, double? commissionPercentage, double? commissionAmount, String? connectionDetails, String? penaltyReason, String? tripDetails, String? subscriptionDetails, Map<String, dynamic>? metadata, DateTime createdAt, DateTime? completedAt, String? failureReason, String? receiptUrl, String? referenceNumber
});




}
/// @nodoc
class __$WalletTransactionModelCopyWithImpl<$Res>
    implements _$WalletTransactionModelCopyWith<$Res> {
  __$WalletTransactionModelCopyWithImpl(this._self, this._then);

  final _WalletTransactionModel _self;
  final $Res Function(_WalletTransactionModel) _then;

/// Create a copy of WalletTransactionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? walletId = null,Object? type = null,Object? amount = null,Object? status = null,Object? description = null,Object? referenceId = freezed,Object? fromUserId = freezed,Object? toUserId = freezed,Object? commissionPercentage = freezed,Object? commissionAmount = freezed,Object? connectionDetails = freezed,Object? penaltyReason = freezed,Object? tripDetails = freezed,Object? subscriptionDetails = freezed,Object? metadata = freezed,Object? createdAt = null,Object? completedAt = freezed,Object? failureReason = freezed,Object? receiptUrl = freezed,Object? referenceNumber = freezed,}) {
  return _then(_WalletTransactionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,walletId: null == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TransactionStatus,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,referenceId: freezed == referenceId ? _self.referenceId : referenceId // ignore: cast_nullable_to_non_nullable
as String?,fromUserId: freezed == fromUserId ? _self.fromUserId : fromUserId // ignore: cast_nullable_to_non_nullable
as String?,toUserId: freezed == toUserId ? _self.toUserId : toUserId // ignore: cast_nullable_to_non_nullable
as String?,commissionPercentage: freezed == commissionPercentage ? _self.commissionPercentage : commissionPercentage // ignore: cast_nullable_to_non_nullable
as double?,commissionAmount: freezed == commissionAmount ? _self.commissionAmount : commissionAmount // ignore: cast_nullable_to_non_nullable
as double?,connectionDetails: freezed == connectionDetails ? _self.connectionDetails : connectionDetails // ignore: cast_nullable_to_non_nullable
as String?,penaltyReason: freezed == penaltyReason ? _self.penaltyReason : penaltyReason // ignore: cast_nullable_to_non_nullable
as String?,tripDetails: freezed == tripDetails ? _self.tripDetails : tripDetails // ignore: cast_nullable_to_non_nullable
as String?,subscriptionDetails: freezed == subscriptionDetails ? _self.subscriptionDetails : subscriptionDetails // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,failureReason: freezed == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String?,receiptUrl: freezed == receiptUrl ? _self.receiptUrl : receiptUrl // ignore: cast_nullable_to_non_nullable
as String?,referenceNumber: freezed == referenceNumber ? _self.referenceNumber : referenceNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$WalletBalanceModel {

 double get balance; double get minimumBalance; bool get canMakeContact; UserType get userType; String get currency; DateTime? get lastUpdated;
/// Create a copy of WalletBalanceModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WalletBalanceModelCopyWith<WalletBalanceModel> get copyWith => _$WalletBalanceModelCopyWithImpl<WalletBalanceModel>(this as WalletBalanceModel, _$identity);

  /// Serializes this WalletBalanceModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WalletBalanceModel&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.minimumBalance, minimumBalance) || other.minimumBalance == minimumBalance)&&(identical(other.canMakeContact, canMakeContact) || other.canMakeContact == canMakeContact)&&(identical(other.userType, userType) || other.userType == userType)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,balance,minimumBalance,canMakeContact,userType,currency,lastUpdated);

@override
String toString() {
  return 'WalletBalanceModel(balance: $balance, minimumBalance: $minimumBalance, canMakeContact: $canMakeContact, userType: $userType, currency: $currency, lastUpdated: $lastUpdated)';
}


}

/// @nodoc
abstract mixin class $WalletBalanceModelCopyWith<$Res>  {
  factory $WalletBalanceModelCopyWith(WalletBalanceModel value, $Res Function(WalletBalanceModel) _then) = _$WalletBalanceModelCopyWithImpl;
@useResult
$Res call({
 double balance, double minimumBalance, bool canMakeContact, UserType userType, String currency, DateTime? lastUpdated
});




}
/// @nodoc
class _$WalletBalanceModelCopyWithImpl<$Res>
    implements $WalletBalanceModelCopyWith<$Res> {
  _$WalletBalanceModelCopyWithImpl(this._self, this._then);

  final WalletBalanceModel _self;
  final $Res Function(WalletBalanceModel) _then;

/// Create a copy of WalletBalanceModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? balance = null,Object? minimumBalance = null,Object? canMakeContact = null,Object? userType = null,Object? currency = null,Object? lastUpdated = freezed,}) {
  return _then(_self.copyWith(
balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,minimumBalance: null == minimumBalance ? _self.minimumBalance : minimumBalance // ignore: cast_nullable_to_non_nullable
as double,canMakeContact: null == canMakeContact ? _self.canMakeContact : canMakeContact // ignore: cast_nullable_to_non_nullable
as bool,userType: null == userType ? _self.userType : userType // ignore: cast_nullable_to_non_nullable
as UserType,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,lastUpdated: freezed == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [WalletBalanceModel].
extension WalletBalanceModelPatterns on WalletBalanceModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WalletBalanceModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WalletBalanceModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WalletBalanceModel value)  $default,){
final _that = this;
switch (_that) {
case _WalletBalanceModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WalletBalanceModel value)?  $default,){
final _that = this;
switch (_that) {
case _WalletBalanceModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double balance,  double minimumBalance,  bool canMakeContact,  UserType userType,  String currency,  DateTime? lastUpdated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WalletBalanceModel() when $default != null:
return $default(_that.balance,_that.minimumBalance,_that.canMakeContact,_that.userType,_that.currency,_that.lastUpdated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double balance,  double minimumBalance,  bool canMakeContact,  UserType userType,  String currency,  DateTime? lastUpdated)  $default,) {final _that = this;
switch (_that) {
case _WalletBalanceModel():
return $default(_that.balance,_that.minimumBalance,_that.canMakeContact,_that.userType,_that.currency,_that.lastUpdated);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double balance,  double minimumBalance,  bool canMakeContact,  UserType userType,  String currency,  DateTime? lastUpdated)?  $default,) {final _that = this;
switch (_that) {
case _WalletBalanceModel() when $default != null:
return $default(_that.balance,_that.minimumBalance,_that.canMakeContact,_that.userType,_that.currency,_that.lastUpdated);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WalletBalanceModel implements WalletBalanceModel {
  const _WalletBalanceModel({required this.balance, required this.minimumBalance, required this.canMakeContact, required this.userType, required this.currency, this.lastUpdated});
  factory _WalletBalanceModel.fromJson(Map<String, dynamic> json) => _$WalletBalanceModelFromJson(json);

@override final  double balance;
@override final  double minimumBalance;
@override final  bool canMakeContact;
@override final  UserType userType;
@override final  String currency;
@override final  DateTime? lastUpdated;

/// Create a copy of WalletBalanceModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WalletBalanceModelCopyWith<_WalletBalanceModel> get copyWith => __$WalletBalanceModelCopyWithImpl<_WalletBalanceModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WalletBalanceModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WalletBalanceModel&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.minimumBalance, minimumBalance) || other.minimumBalance == minimumBalance)&&(identical(other.canMakeContact, canMakeContact) || other.canMakeContact == canMakeContact)&&(identical(other.userType, userType) || other.userType == userType)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,balance,minimumBalance,canMakeContact,userType,currency,lastUpdated);

@override
String toString() {
  return 'WalletBalanceModel(balance: $balance, minimumBalance: $minimumBalance, canMakeContact: $canMakeContact, userType: $userType, currency: $currency, lastUpdated: $lastUpdated)';
}


}

/// @nodoc
abstract mixin class _$WalletBalanceModelCopyWith<$Res> implements $WalletBalanceModelCopyWith<$Res> {
  factory _$WalletBalanceModelCopyWith(_WalletBalanceModel value, $Res Function(_WalletBalanceModel) _then) = __$WalletBalanceModelCopyWithImpl;
@override @useResult
$Res call({
 double balance, double minimumBalance, bool canMakeContact, UserType userType, String currency, DateTime? lastUpdated
});




}
/// @nodoc
class __$WalletBalanceModelCopyWithImpl<$Res>
    implements _$WalletBalanceModelCopyWith<$Res> {
  __$WalletBalanceModelCopyWithImpl(this._self, this._then);

  final _WalletBalanceModel _self;
  final $Res Function(_WalletBalanceModel) _then;

/// Create a copy of WalletBalanceModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? balance = null,Object? minimumBalance = null,Object? canMakeContact = null,Object? userType = null,Object? currency = null,Object? lastUpdated = freezed,}) {
  return _then(_WalletBalanceModel(
balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,minimumBalance: null == minimumBalance ? _self.minimumBalance : minimumBalance // ignore: cast_nullable_to_non_nullable
as double,canMakeContact: null == canMakeContact ? _self.canMakeContact : canMakeContact // ignore: cast_nullable_to_non_nullable
as bool,userType: null == userType ? _self.userType : userType // ignore: cast_nullable_to_non_nullable
as UserType,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,lastUpdated: freezed == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$WalletTopUpModel {

/// Unique identifier
 String get id;/// User ID
 String get userId;/// Amount to top up
 double get amount;/// Payment method
 String get paymentMethod;/// Payment gateway reference
 String? get gatewayReference;/// Payment status
 TransactionStatus get status;/// Additional metadata
 Map<String, dynamic>? get metadata;/// Request creation timestamp
 DateTime get createdAt;/// Request completion timestamp
 DateTime? get completedAt;/// Failure reason (if any)
 String? get failureReason;
/// Create a copy of WalletTopUpModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WalletTopUpModelCopyWith<WalletTopUpModel> get copyWith => _$WalletTopUpModelCopyWithImpl<WalletTopUpModel>(this as WalletTopUpModel, _$identity);

  /// Serializes this WalletTopUpModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WalletTopUpModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.gatewayReference, gatewayReference) || other.gatewayReference == gatewayReference)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.failureReason, failureReason) || other.failureReason == failureReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,amount,paymentMethod,gatewayReference,status,const DeepCollectionEquality().hash(metadata),createdAt,completedAt,failureReason);

@override
String toString() {
  return 'WalletTopUpModel(id: $id, userId: $userId, amount: $amount, paymentMethod: $paymentMethod, gatewayReference: $gatewayReference, status: $status, metadata: $metadata, createdAt: $createdAt, completedAt: $completedAt, failureReason: $failureReason)';
}


}

/// @nodoc
abstract mixin class $WalletTopUpModelCopyWith<$Res>  {
  factory $WalletTopUpModelCopyWith(WalletTopUpModel value, $Res Function(WalletTopUpModel) _then) = _$WalletTopUpModelCopyWithImpl;
@useResult
$Res call({
 String id, String userId, double amount, String paymentMethod, String? gatewayReference, TransactionStatus status, Map<String, dynamic>? metadata, DateTime createdAt, DateTime? completedAt, String? failureReason
});




}
/// @nodoc
class _$WalletTopUpModelCopyWithImpl<$Res>
    implements $WalletTopUpModelCopyWith<$Res> {
  _$WalletTopUpModelCopyWithImpl(this._self, this._then);

  final WalletTopUpModel _self;
  final $Res Function(WalletTopUpModel) _then;

/// Create a copy of WalletTopUpModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? amount = null,Object? paymentMethod = null,Object? gatewayReference = freezed,Object? status = null,Object? metadata = freezed,Object? createdAt = null,Object? completedAt = freezed,Object? failureReason = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String,gatewayReference: freezed == gatewayReference ? _self.gatewayReference : gatewayReference // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TransactionStatus,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,failureReason: freezed == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WalletTopUpModel].
extension WalletTopUpModelPatterns on WalletTopUpModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WalletTopUpModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WalletTopUpModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WalletTopUpModel value)  $default,){
final _that = this;
switch (_that) {
case _WalletTopUpModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WalletTopUpModel value)?  $default,){
final _that = this;
switch (_that) {
case _WalletTopUpModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  double amount,  String paymentMethod,  String? gatewayReference,  TransactionStatus status,  Map<String, dynamic>? metadata,  DateTime createdAt,  DateTime? completedAt,  String? failureReason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WalletTopUpModel() when $default != null:
return $default(_that.id,_that.userId,_that.amount,_that.paymentMethod,_that.gatewayReference,_that.status,_that.metadata,_that.createdAt,_that.completedAt,_that.failureReason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  double amount,  String paymentMethod,  String? gatewayReference,  TransactionStatus status,  Map<String, dynamic>? metadata,  DateTime createdAt,  DateTime? completedAt,  String? failureReason)  $default,) {final _that = this;
switch (_that) {
case _WalletTopUpModel():
return $default(_that.id,_that.userId,_that.amount,_that.paymentMethod,_that.gatewayReference,_that.status,_that.metadata,_that.createdAt,_that.completedAt,_that.failureReason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  double amount,  String paymentMethod,  String? gatewayReference,  TransactionStatus status,  Map<String, dynamic>? metadata,  DateTime createdAt,  DateTime? completedAt,  String? failureReason)?  $default,) {final _that = this;
switch (_that) {
case _WalletTopUpModel() when $default != null:
return $default(_that.id,_that.userId,_that.amount,_that.paymentMethod,_that.gatewayReference,_that.status,_that.metadata,_that.createdAt,_that.completedAt,_that.failureReason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WalletTopUpModel implements WalletTopUpModel {
  const _WalletTopUpModel({required this.id, required this.userId, required this.amount, required this.paymentMethod, this.gatewayReference, this.status = TransactionStatus.pending, final  Map<String, dynamic>? metadata, required this.createdAt, this.completedAt, this.failureReason}): _metadata = metadata;
  factory _WalletTopUpModel.fromJson(Map<String, dynamic> json) => _$WalletTopUpModelFromJson(json);

/// Unique identifier
@override final  String id;
/// User ID
@override final  String userId;
/// Amount to top up
@override final  double amount;
/// Payment method
@override final  String paymentMethod;
/// Payment gateway reference
@override final  String? gatewayReference;
/// Payment status
@override@JsonKey() final  TransactionStatus status;
/// Additional metadata
 final  Map<String, dynamic>? _metadata;
/// Additional metadata
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// Request creation timestamp
@override final  DateTime createdAt;
/// Request completion timestamp
@override final  DateTime? completedAt;
/// Failure reason (if any)
@override final  String? failureReason;

/// Create a copy of WalletTopUpModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WalletTopUpModelCopyWith<_WalletTopUpModel> get copyWith => __$WalletTopUpModelCopyWithImpl<_WalletTopUpModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WalletTopUpModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WalletTopUpModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.gatewayReference, gatewayReference) || other.gatewayReference == gatewayReference)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.failureReason, failureReason) || other.failureReason == failureReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,amount,paymentMethod,gatewayReference,status,const DeepCollectionEquality().hash(_metadata),createdAt,completedAt,failureReason);

@override
String toString() {
  return 'WalletTopUpModel(id: $id, userId: $userId, amount: $amount, paymentMethod: $paymentMethod, gatewayReference: $gatewayReference, status: $status, metadata: $metadata, createdAt: $createdAt, completedAt: $completedAt, failureReason: $failureReason)';
}


}

/// @nodoc
abstract mixin class _$WalletTopUpModelCopyWith<$Res> implements $WalletTopUpModelCopyWith<$Res> {
  factory _$WalletTopUpModelCopyWith(_WalletTopUpModel value, $Res Function(_WalletTopUpModel) _then) = __$WalletTopUpModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, double amount, String paymentMethod, String? gatewayReference, TransactionStatus status, Map<String, dynamic>? metadata, DateTime createdAt, DateTime? completedAt, String? failureReason
});




}
/// @nodoc
class __$WalletTopUpModelCopyWithImpl<$Res>
    implements _$WalletTopUpModelCopyWith<$Res> {
  __$WalletTopUpModelCopyWithImpl(this._self, this._then);

  final _WalletTopUpModel _self;
  final $Res Function(_WalletTopUpModel) _then;

/// Create a copy of WalletTopUpModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? amount = null,Object? paymentMethod = null,Object? gatewayReference = freezed,Object? status = null,Object? metadata = freezed,Object? createdAt = null,Object? completedAt = freezed,Object? failureReason = freezed,}) {
  return _then(_WalletTopUpModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String,gatewayReference: freezed == gatewayReference ? _self.gatewayReference : gatewayReference // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TransactionStatus,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,failureReason: freezed == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$WalletWithdrawalModel {

/// Unique identifier
 String get id;/// User ID
 String get userId;/// Amount to withdraw
 double get amount;/// Bank account details
 Map<String, dynamic> get bankDetails;/// Withdrawal status
 TransactionStatus get status;/// Additional metadata
 Map<String, dynamic>? get metadata;/// Request creation timestamp
 DateTime get createdAt;/// Request completion timestamp
 DateTime? get completedAt;/// Failure reason (if any)
 String? get failureReason;/// Transaction ID (if processed)
 String? get transactionId;
/// Create a copy of WalletWithdrawalModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WalletWithdrawalModelCopyWith<WalletWithdrawalModel> get copyWith => _$WalletWithdrawalModelCopyWithImpl<WalletWithdrawalModel>(this as WalletWithdrawalModel, _$identity);

  /// Serializes this WalletWithdrawalModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WalletWithdrawalModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.amount, amount) || other.amount == amount)&&const DeepCollectionEquality().equals(other.bankDetails, bankDetails)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.failureReason, failureReason) || other.failureReason == failureReason)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,amount,const DeepCollectionEquality().hash(bankDetails),status,const DeepCollectionEquality().hash(metadata),createdAt,completedAt,failureReason,transactionId);

@override
String toString() {
  return 'WalletWithdrawalModel(id: $id, userId: $userId, amount: $amount, bankDetails: $bankDetails, status: $status, metadata: $metadata, createdAt: $createdAt, completedAt: $completedAt, failureReason: $failureReason, transactionId: $transactionId)';
}


}

/// @nodoc
abstract mixin class $WalletWithdrawalModelCopyWith<$Res>  {
  factory $WalletWithdrawalModelCopyWith(WalletWithdrawalModel value, $Res Function(WalletWithdrawalModel) _then) = _$WalletWithdrawalModelCopyWithImpl;
@useResult
$Res call({
 String id, String userId, double amount, Map<String, dynamic> bankDetails, TransactionStatus status, Map<String, dynamic>? metadata, DateTime createdAt, DateTime? completedAt, String? failureReason, String? transactionId
});




}
/// @nodoc
class _$WalletWithdrawalModelCopyWithImpl<$Res>
    implements $WalletWithdrawalModelCopyWith<$Res> {
  _$WalletWithdrawalModelCopyWithImpl(this._self, this._then);

  final WalletWithdrawalModel _self;
  final $Res Function(WalletWithdrawalModel) _then;

/// Create a copy of WalletWithdrawalModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? amount = null,Object? bankDetails = null,Object? status = null,Object? metadata = freezed,Object? createdAt = null,Object? completedAt = freezed,Object? failureReason = freezed,Object? transactionId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,bankDetails: null == bankDetails ? _self.bankDetails : bankDetails // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TransactionStatus,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,failureReason: freezed == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String?,transactionId: freezed == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WalletWithdrawalModel].
extension WalletWithdrawalModelPatterns on WalletWithdrawalModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WalletWithdrawalModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WalletWithdrawalModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WalletWithdrawalModel value)  $default,){
final _that = this;
switch (_that) {
case _WalletWithdrawalModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WalletWithdrawalModel value)?  $default,){
final _that = this;
switch (_that) {
case _WalletWithdrawalModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  double amount,  Map<String, dynamic> bankDetails,  TransactionStatus status,  Map<String, dynamic>? metadata,  DateTime createdAt,  DateTime? completedAt,  String? failureReason,  String? transactionId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WalletWithdrawalModel() when $default != null:
return $default(_that.id,_that.userId,_that.amount,_that.bankDetails,_that.status,_that.metadata,_that.createdAt,_that.completedAt,_that.failureReason,_that.transactionId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  double amount,  Map<String, dynamic> bankDetails,  TransactionStatus status,  Map<String, dynamic>? metadata,  DateTime createdAt,  DateTime? completedAt,  String? failureReason,  String? transactionId)  $default,) {final _that = this;
switch (_that) {
case _WalletWithdrawalModel():
return $default(_that.id,_that.userId,_that.amount,_that.bankDetails,_that.status,_that.metadata,_that.createdAt,_that.completedAt,_that.failureReason,_that.transactionId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  double amount,  Map<String, dynamic> bankDetails,  TransactionStatus status,  Map<String, dynamic>? metadata,  DateTime createdAt,  DateTime? completedAt,  String? failureReason,  String? transactionId)?  $default,) {final _that = this;
switch (_that) {
case _WalletWithdrawalModel() when $default != null:
return $default(_that.id,_that.userId,_that.amount,_that.bankDetails,_that.status,_that.metadata,_that.createdAt,_that.completedAt,_that.failureReason,_that.transactionId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WalletWithdrawalModel implements WalletWithdrawalModel {
  const _WalletWithdrawalModel({required this.id, required this.userId, required this.amount, required final  Map<String, dynamic> bankDetails, this.status = TransactionStatus.pending, final  Map<String, dynamic>? metadata, required this.createdAt, this.completedAt, this.failureReason, this.transactionId}): _bankDetails = bankDetails,_metadata = metadata;
  factory _WalletWithdrawalModel.fromJson(Map<String, dynamic> json) => _$WalletWithdrawalModelFromJson(json);

/// Unique identifier
@override final  String id;
/// User ID
@override final  String userId;
/// Amount to withdraw
@override final  double amount;
/// Bank account details
 final  Map<String, dynamic> _bankDetails;
/// Bank account details
@override Map<String, dynamic> get bankDetails {
  if (_bankDetails is EqualUnmodifiableMapView) return _bankDetails;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_bankDetails);
}

/// Withdrawal status
@override@JsonKey() final  TransactionStatus status;
/// Additional metadata
 final  Map<String, dynamic>? _metadata;
/// Additional metadata
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// Request creation timestamp
@override final  DateTime createdAt;
/// Request completion timestamp
@override final  DateTime? completedAt;
/// Failure reason (if any)
@override final  String? failureReason;
/// Transaction ID (if processed)
@override final  String? transactionId;

/// Create a copy of WalletWithdrawalModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WalletWithdrawalModelCopyWith<_WalletWithdrawalModel> get copyWith => __$WalletWithdrawalModelCopyWithImpl<_WalletWithdrawalModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WalletWithdrawalModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WalletWithdrawalModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.amount, amount) || other.amount == amount)&&const DeepCollectionEquality().equals(other._bankDetails, _bankDetails)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.failureReason, failureReason) || other.failureReason == failureReason)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,amount,const DeepCollectionEquality().hash(_bankDetails),status,const DeepCollectionEquality().hash(_metadata),createdAt,completedAt,failureReason,transactionId);

@override
String toString() {
  return 'WalletWithdrawalModel(id: $id, userId: $userId, amount: $amount, bankDetails: $bankDetails, status: $status, metadata: $metadata, createdAt: $createdAt, completedAt: $completedAt, failureReason: $failureReason, transactionId: $transactionId)';
}


}

/// @nodoc
abstract mixin class _$WalletWithdrawalModelCopyWith<$Res> implements $WalletWithdrawalModelCopyWith<$Res> {
  factory _$WalletWithdrawalModelCopyWith(_WalletWithdrawalModel value, $Res Function(_WalletWithdrawalModel) _then) = __$WalletWithdrawalModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, double amount, Map<String, dynamic> bankDetails, TransactionStatus status, Map<String, dynamic>? metadata, DateTime createdAt, DateTime? completedAt, String? failureReason, String? transactionId
});




}
/// @nodoc
class __$WalletWithdrawalModelCopyWithImpl<$Res>
    implements _$WalletWithdrawalModelCopyWith<$Res> {
  __$WalletWithdrawalModelCopyWithImpl(this._self, this._then);

  final _WalletWithdrawalModel _self;
  final $Res Function(_WalletWithdrawalModel) _then;

/// Create a copy of WalletWithdrawalModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? amount = null,Object? bankDetails = null,Object? status = null,Object? metadata = freezed,Object? createdAt = null,Object? completedAt = freezed,Object? failureReason = freezed,Object? transactionId = freezed,}) {
  return _then(_WalletWithdrawalModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,bankDetails: null == bankDetails ? _self._bankDetails : bankDetails // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TransactionStatus,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,failureReason: freezed == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String?,transactionId: freezed == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

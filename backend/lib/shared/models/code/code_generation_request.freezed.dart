// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'code_generation_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BaseCodeGenerationRequest {

/// Factory ID that owns these codes
 String get factoryId;/// Subscription plan ID for billing
 String get subscriptionPlanId;/// Number of codes to generate
 int get count;/// Code prefix (e.g., "A", "YY", "YBZ", "TSFG")
 String get prefix;/// Starting sequence number
 int get startSequence;/// Should include international standard codes?
 bool get includeInternationalCodes;/// Should generate QR codes?
 bool get generateQrCodes;/// Should generate barcodes?
 bool get generateBarcodes;/// Batch name/description
 String? get batchName;/// Batch notes
 String? get batchNotes;/// Metadata for additional information (JSON string)
 String? get metadata;
/// Create a copy of BaseCodeGenerationRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BaseCodeGenerationRequestCopyWith<BaseCodeGenerationRequest> get copyWith => _$BaseCodeGenerationRequestCopyWithImpl<BaseCodeGenerationRequest>(this as BaseCodeGenerationRequest, _$identity);

  /// Serializes this BaseCodeGenerationRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BaseCodeGenerationRequest&&(identical(other.factoryId, factoryId) || other.factoryId == factoryId)&&(identical(other.subscriptionPlanId, subscriptionPlanId) || other.subscriptionPlanId == subscriptionPlanId)&&(identical(other.count, count) || other.count == count)&&(identical(other.prefix, prefix) || other.prefix == prefix)&&(identical(other.startSequence, startSequence) || other.startSequence == startSequence)&&(identical(other.includeInternationalCodes, includeInternationalCodes) || other.includeInternationalCodes == includeInternationalCodes)&&(identical(other.generateQrCodes, generateQrCodes) || other.generateQrCodes == generateQrCodes)&&(identical(other.generateBarcodes, generateBarcodes) || other.generateBarcodes == generateBarcodes)&&(identical(other.batchName, batchName) || other.batchName == batchName)&&(identical(other.batchNotes, batchNotes) || other.batchNotes == batchNotes)&&(identical(other.metadata, metadata) || other.metadata == metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,factoryId,subscriptionPlanId,count,prefix,startSequence,includeInternationalCodes,generateQrCodes,generateBarcodes,batchName,batchNotes,metadata);

@override
String toString() {
  return 'BaseCodeGenerationRequest(factoryId: $factoryId, subscriptionPlanId: $subscriptionPlanId, count: $count, prefix: $prefix, startSequence: $startSequence, includeInternationalCodes: $includeInternationalCodes, generateQrCodes: $generateQrCodes, generateBarcodes: $generateBarcodes, batchName: $batchName, batchNotes: $batchNotes, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $BaseCodeGenerationRequestCopyWith<$Res>  {
  factory $BaseCodeGenerationRequestCopyWith(BaseCodeGenerationRequest value, $Res Function(BaseCodeGenerationRequest) _then) = _$BaseCodeGenerationRequestCopyWithImpl;
@useResult
$Res call({
 String factoryId, String subscriptionPlanId, int count, String prefix, int startSequence, bool includeInternationalCodes, bool generateQrCodes, bool generateBarcodes, String? batchName, String? batchNotes, String? metadata
});




}
/// @nodoc
class _$BaseCodeGenerationRequestCopyWithImpl<$Res>
    implements $BaseCodeGenerationRequestCopyWith<$Res> {
  _$BaseCodeGenerationRequestCopyWithImpl(this._self, this._then);

  final BaseCodeGenerationRequest _self;
  final $Res Function(BaseCodeGenerationRequest) _then;

/// Create a copy of BaseCodeGenerationRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? factoryId = null,Object? subscriptionPlanId = null,Object? count = null,Object? prefix = null,Object? startSequence = null,Object? includeInternationalCodes = null,Object? generateQrCodes = null,Object? generateBarcodes = null,Object? batchName = freezed,Object? batchNotes = freezed,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
factoryId: null == factoryId ? _self.factoryId : factoryId // ignore: cast_nullable_to_non_nullable
as String,subscriptionPlanId: null == subscriptionPlanId ? _self.subscriptionPlanId : subscriptionPlanId // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,prefix: null == prefix ? _self.prefix : prefix // ignore: cast_nullable_to_non_nullable
as String,startSequence: null == startSequence ? _self.startSequence : startSequence // ignore: cast_nullable_to_non_nullable
as int,includeInternationalCodes: null == includeInternationalCodes ? _self.includeInternationalCodes : includeInternationalCodes // ignore: cast_nullable_to_non_nullable
as bool,generateQrCodes: null == generateQrCodes ? _self.generateQrCodes : generateQrCodes // ignore: cast_nullable_to_non_nullable
as bool,generateBarcodes: null == generateBarcodes ? _self.generateBarcodes : generateBarcodes // ignore: cast_nullable_to_non_nullable
as bool,batchName: freezed == batchName ? _self.batchName : batchName // ignore: cast_nullable_to_non_nullable
as String?,batchNotes: freezed == batchNotes ? _self.batchNotes : batchNotes // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BaseCodeGenerationRequest].
extension BaseCodeGenerationRequestPatterns on BaseCodeGenerationRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BaseCodeGenerationRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BaseCodeGenerationRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BaseCodeGenerationRequest value)  $default,){
final _that = this;
switch (_that) {
case _BaseCodeGenerationRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BaseCodeGenerationRequest value)?  $default,){
final _that = this;
switch (_that) {
case _BaseCodeGenerationRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String factoryId,  String subscriptionPlanId,  int count,  String prefix,  int startSequence,  bool includeInternationalCodes,  bool generateQrCodes,  bool generateBarcodes,  String? batchName,  String? batchNotes,  String? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BaseCodeGenerationRequest() when $default != null:
return $default(_that.factoryId,_that.subscriptionPlanId,_that.count,_that.prefix,_that.startSequence,_that.includeInternationalCodes,_that.generateQrCodes,_that.generateBarcodes,_that.batchName,_that.batchNotes,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String factoryId,  String subscriptionPlanId,  int count,  String prefix,  int startSequence,  bool includeInternationalCodes,  bool generateQrCodes,  bool generateBarcodes,  String? batchName,  String? batchNotes,  String? metadata)  $default,) {final _that = this;
switch (_that) {
case _BaseCodeGenerationRequest():
return $default(_that.factoryId,_that.subscriptionPlanId,_that.count,_that.prefix,_that.startSequence,_that.includeInternationalCodes,_that.generateQrCodes,_that.generateBarcodes,_that.batchName,_that.batchNotes,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String factoryId,  String subscriptionPlanId,  int count,  String prefix,  int startSequence,  bool includeInternationalCodes,  bool generateQrCodes,  bool generateBarcodes,  String? batchName,  String? batchNotes,  String? metadata)?  $default,) {final _that = this;
switch (_that) {
case _BaseCodeGenerationRequest() when $default != null:
return $default(_that.factoryId,_that.subscriptionPlanId,_that.count,_that.prefix,_that.startSequence,_that.includeInternationalCodes,_that.generateQrCodes,_that.generateBarcodes,_that.batchName,_that.batchNotes,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BaseCodeGenerationRequest implements BaseCodeGenerationRequest {
  const _BaseCodeGenerationRequest({required this.factoryId, required this.subscriptionPlanId, required this.count, required this.prefix, this.startSequence = 1, this.includeInternationalCodes = true, this.generateQrCodes = true, this.generateBarcodes = true, this.batchName, this.batchNotes, this.metadata});
  factory _BaseCodeGenerationRequest.fromJson(Map<String, dynamic> json) => _$BaseCodeGenerationRequestFromJson(json);

/// Factory ID that owns these codes
@override final  String factoryId;
/// Subscription plan ID for billing
@override final  String subscriptionPlanId;
/// Number of codes to generate
@override final  int count;
/// Code prefix (e.g., "A", "YY", "YBZ", "TSFG")
@override final  String prefix;
/// Starting sequence number
@override@JsonKey() final  int startSequence;
/// Should include international standard codes?
@override@JsonKey() final  bool includeInternationalCodes;
/// Should generate QR codes?
@override@JsonKey() final  bool generateQrCodes;
/// Should generate barcodes?
@override@JsonKey() final  bool generateBarcodes;
/// Batch name/description
@override final  String? batchName;
/// Batch notes
@override final  String? batchNotes;
/// Metadata for additional information (JSON string)
@override final  String? metadata;

/// Create a copy of BaseCodeGenerationRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BaseCodeGenerationRequestCopyWith<_BaseCodeGenerationRequest> get copyWith => __$BaseCodeGenerationRequestCopyWithImpl<_BaseCodeGenerationRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BaseCodeGenerationRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BaseCodeGenerationRequest&&(identical(other.factoryId, factoryId) || other.factoryId == factoryId)&&(identical(other.subscriptionPlanId, subscriptionPlanId) || other.subscriptionPlanId == subscriptionPlanId)&&(identical(other.count, count) || other.count == count)&&(identical(other.prefix, prefix) || other.prefix == prefix)&&(identical(other.startSequence, startSequence) || other.startSequence == startSequence)&&(identical(other.includeInternationalCodes, includeInternationalCodes) || other.includeInternationalCodes == includeInternationalCodes)&&(identical(other.generateQrCodes, generateQrCodes) || other.generateQrCodes == generateQrCodes)&&(identical(other.generateBarcodes, generateBarcodes) || other.generateBarcodes == generateBarcodes)&&(identical(other.batchName, batchName) || other.batchName == batchName)&&(identical(other.batchNotes, batchNotes) || other.batchNotes == batchNotes)&&(identical(other.metadata, metadata) || other.metadata == metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,factoryId,subscriptionPlanId,count,prefix,startSequence,includeInternationalCodes,generateQrCodes,generateBarcodes,batchName,batchNotes,metadata);

@override
String toString() {
  return 'BaseCodeGenerationRequest(factoryId: $factoryId, subscriptionPlanId: $subscriptionPlanId, count: $count, prefix: $prefix, startSequence: $startSequence, includeInternationalCodes: $includeInternationalCodes, generateQrCodes: $generateQrCodes, generateBarcodes: $generateBarcodes, batchName: $batchName, batchNotes: $batchNotes, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$BaseCodeGenerationRequestCopyWith<$Res> implements $BaseCodeGenerationRequestCopyWith<$Res> {
  factory _$BaseCodeGenerationRequestCopyWith(_BaseCodeGenerationRequest value, $Res Function(_BaseCodeGenerationRequest) _then) = __$BaseCodeGenerationRequestCopyWithImpl;
@override @useResult
$Res call({
 String factoryId, String subscriptionPlanId, int count, String prefix, int startSequence, bool includeInternationalCodes, bool generateQrCodes, bool generateBarcodes, String? batchName, String? batchNotes, String? metadata
});




}
/// @nodoc
class __$BaseCodeGenerationRequestCopyWithImpl<$Res>
    implements _$BaseCodeGenerationRequestCopyWith<$Res> {
  __$BaseCodeGenerationRequestCopyWithImpl(this._self, this._then);

  final _BaseCodeGenerationRequest _self;
  final $Res Function(_BaseCodeGenerationRequest) _then;

/// Create a copy of BaseCodeGenerationRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? factoryId = null,Object? subscriptionPlanId = null,Object? count = null,Object? prefix = null,Object? startSequence = null,Object? includeInternationalCodes = null,Object? generateQrCodes = null,Object? generateBarcodes = null,Object? batchName = freezed,Object? batchNotes = freezed,Object? metadata = freezed,}) {
  return _then(_BaseCodeGenerationRequest(
factoryId: null == factoryId ? _self.factoryId : factoryId // ignore: cast_nullable_to_non_nullable
as String,subscriptionPlanId: null == subscriptionPlanId ? _self.subscriptionPlanId : subscriptionPlanId // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,prefix: null == prefix ? _self.prefix : prefix // ignore: cast_nullable_to_non_nullable
as String,startSequence: null == startSequence ? _self.startSequence : startSequence // ignore: cast_nullable_to_non_nullable
as int,includeInternationalCodes: null == includeInternationalCodes ? _self.includeInternationalCodes : includeInternationalCodes // ignore: cast_nullable_to_non_nullable
as bool,generateQrCodes: null == generateQrCodes ? _self.generateQrCodes : generateQrCodes // ignore: cast_nullable_to_non_nullable
as bool,generateBarcodes: null == generateBarcodes ? _self.generateBarcodes : generateBarcodes // ignore: cast_nullable_to_non_nullable
as bool,batchName: freezed == batchName ? _self.batchName : batchName // ignore: cast_nullable_to_non_nullable
as String?,batchNotes: freezed == batchNotes ? _self.batchNotes : batchNotes // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$BundleCodeGenerationRequest {

/// Base request parameters
 String get factoryId; String get subscriptionPlanId; int get count; String get prefix; int get startSequence; bool get includeInternationalCodes; bool get generateQrCodes; bool get generateBarcodes; String? get batchName; String? get batchNotes; String? get metadata;/// Bundle-specific parameters
/// Number of cartons per bundle
 int get cartonsPerBundle;/// Bundle weight in kilograms (optional)
 double? get bundleWeight;/// Bundle dimensions (length x width x height in cm)
 String? get bundleDimensions;/// Storage location
 String? get storageLocation;/// Shipping method
 String? get shippingMethod;/// Expected delivery date
 DateTime? get expectedDeliveryDate;/// Bundle category
 String? get category;/// Handling instructions
 String? get handlingInstructions;/// Customs declaration number
 String? get customsDeclarationNumber;/// Insurance value
 double? get insuranceValue;/// Priority (1=High, 2=Medium, 3=Low)
 int get priority;
/// Create a copy of BundleCodeGenerationRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BundleCodeGenerationRequestCopyWith<BundleCodeGenerationRequest> get copyWith => _$BundleCodeGenerationRequestCopyWithImpl<BundleCodeGenerationRequest>(this as BundleCodeGenerationRequest, _$identity);

  /// Serializes this BundleCodeGenerationRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BundleCodeGenerationRequest&&(identical(other.factoryId, factoryId) || other.factoryId == factoryId)&&(identical(other.subscriptionPlanId, subscriptionPlanId) || other.subscriptionPlanId == subscriptionPlanId)&&(identical(other.count, count) || other.count == count)&&(identical(other.prefix, prefix) || other.prefix == prefix)&&(identical(other.startSequence, startSequence) || other.startSequence == startSequence)&&(identical(other.includeInternationalCodes, includeInternationalCodes) || other.includeInternationalCodes == includeInternationalCodes)&&(identical(other.generateQrCodes, generateQrCodes) || other.generateQrCodes == generateQrCodes)&&(identical(other.generateBarcodes, generateBarcodes) || other.generateBarcodes == generateBarcodes)&&(identical(other.batchName, batchName) || other.batchName == batchName)&&(identical(other.batchNotes, batchNotes) || other.batchNotes == batchNotes)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.cartonsPerBundle, cartonsPerBundle) || other.cartonsPerBundle == cartonsPerBundle)&&(identical(other.bundleWeight, bundleWeight) || other.bundleWeight == bundleWeight)&&(identical(other.bundleDimensions, bundleDimensions) || other.bundleDimensions == bundleDimensions)&&(identical(other.storageLocation, storageLocation) || other.storageLocation == storageLocation)&&(identical(other.shippingMethod, shippingMethod) || other.shippingMethod == shippingMethod)&&(identical(other.expectedDeliveryDate, expectedDeliveryDate) || other.expectedDeliveryDate == expectedDeliveryDate)&&(identical(other.category, category) || other.category == category)&&(identical(other.handlingInstructions, handlingInstructions) || other.handlingInstructions == handlingInstructions)&&(identical(other.customsDeclarationNumber, customsDeclarationNumber) || other.customsDeclarationNumber == customsDeclarationNumber)&&(identical(other.insuranceValue, insuranceValue) || other.insuranceValue == insuranceValue)&&(identical(other.priority, priority) || other.priority == priority));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,factoryId,subscriptionPlanId,count,prefix,startSequence,includeInternationalCodes,generateQrCodes,generateBarcodes,batchName,batchNotes,metadata,cartonsPerBundle,bundleWeight,bundleDimensions,storageLocation,shippingMethod,expectedDeliveryDate,category,handlingInstructions,customsDeclarationNumber,insuranceValue,priority]);

@override
String toString() {
  return 'BundleCodeGenerationRequest(factoryId: $factoryId, subscriptionPlanId: $subscriptionPlanId, count: $count, prefix: $prefix, startSequence: $startSequence, includeInternationalCodes: $includeInternationalCodes, generateQrCodes: $generateQrCodes, generateBarcodes: $generateBarcodes, batchName: $batchName, batchNotes: $batchNotes, metadata: $metadata, cartonsPerBundle: $cartonsPerBundle, bundleWeight: $bundleWeight, bundleDimensions: $bundleDimensions, storageLocation: $storageLocation, shippingMethod: $shippingMethod, expectedDeliveryDate: $expectedDeliveryDate, category: $category, handlingInstructions: $handlingInstructions, customsDeclarationNumber: $customsDeclarationNumber, insuranceValue: $insuranceValue, priority: $priority)';
}


}

/// @nodoc
abstract mixin class $BundleCodeGenerationRequestCopyWith<$Res>  {
  factory $BundleCodeGenerationRequestCopyWith(BundleCodeGenerationRequest value, $Res Function(BundleCodeGenerationRequest) _then) = _$BundleCodeGenerationRequestCopyWithImpl;
@useResult
$Res call({
 String factoryId, String subscriptionPlanId, int count, String prefix, int startSequence, bool includeInternationalCodes, bool generateQrCodes, bool generateBarcodes, String? batchName, String? batchNotes, String? metadata, int cartonsPerBundle, double? bundleWeight, String? bundleDimensions, String? storageLocation, String? shippingMethod, DateTime? expectedDeliveryDate, String? category, String? handlingInstructions, String? customsDeclarationNumber, double? insuranceValue, int priority
});




}
/// @nodoc
class _$BundleCodeGenerationRequestCopyWithImpl<$Res>
    implements $BundleCodeGenerationRequestCopyWith<$Res> {
  _$BundleCodeGenerationRequestCopyWithImpl(this._self, this._then);

  final BundleCodeGenerationRequest _self;
  final $Res Function(BundleCodeGenerationRequest) _then;

/// Create a copy of BundleCodeGenerationRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? factoryId = null,Object? subscriptionPlanId = null,Object? count = null,Object? prefix = null,Object? startSequence = null,Object? includeInternationalCodes = null,Object? generateQrCodes = null,Object? generateBarcodes = null,Object? batchName = freezed,Object? batchNotes = freezed,Object? metadata = freezed,Object? cartonsPerBundle = null,Object? bundleWeight = freezed,Object? bundleDimensions = freezed,Object? storageLocation = freezed,Object? shippingMethod = freezed,Object? expectedDeliveryDate = freezed,Object? category = freezed,Object? handlingInstructions = freezed,Object? customsDeclarationNumber = freezed,Object? insuranceValue = freezed,Object? priority = null,}) {
  return _then(_self.copyWith(
factoryId: null == factoryId ? _self.factoryId : factoryId // ignore: cast_nullable_to_non_nullable
as String,subscriptionPlanId: null == subscriptionPlanId ? _self.subscriptionPlanId : subscriptionPlanId // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,prefix: null == prefix ? _self.prefix : prefix // ignore: cast_nullable_to_non_nullable
as String,startSequence: null == startSequence ? _self.startSequence : startSequence // ignore: cast_nullable_to_non_nullable
as int,includeInternationalCodes: null == includeInternationalCodes ? _self.includeInternationalCodes : includeInternationalCodes // ignore: cast_nullable_to_non_nullable
as bool,generateQrCodes: null == generateQrCodes ? _self.generateQrCodes : generateQrCodes // ignore: cast_nullable_to_non_nullable
as bool,generateBarcodes: null == generateBarcodes ? _self.generateBarcodes : generateBarcodes // ignore: cast_nullable_to_non_nullable
as bool,batchName: freezed == batchName ? _self.batchName : batchName // ignore: cast_nullable_to_non_nullable
as String?,batchNotes: freezed == batchNotes ? _self.batchNotes : batchNotes // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as String?,cartonsPerBundle: null == cartonsPerBundle ? _self.cartonsPerBundle : cartonsPerBundle // ignore: cast_nullable_to_non_nullable
as int,bundleWeight: freezed == bundleWeight ? _self.bundleWeight : bundleWeight // ignore: cast_nullable_to_non_nullable
as double?,bundleDimensions: freezed == bundleDimensions ? _self.bundleDimensions : bundleDimensions // ignore: cast_nullable_to_non_nullable
as String?,storageLocation: freezed == storageLocation ? _self.storageLocation : storageLocation // ignore: cast_nullable_to_non_nullable
as String?,shippingMethod: freezed == shippingMethod ? _self.shippingMethod : shippingMethod // ignore: cast_nullable_to_non_nullable
as String?,expectedDeliveryDate: freezed == expectedDeliveryDate ? _self.expectedDeliveryDate : expectedDeliveryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,handlingInstructions: freezed == handlingInstructions ? _self.handlingInstructions : handlingInstructions // ignore: cast_nullable_to_non_nullable
as String?,customsDeclarationNumber: freezed == customsDeclarationNumber ? _self.customsDeclarationNumber : customsDeclarationNumber // ignore: cast_nullable_to_non_nullable
as String?,insuranceValue: freezed == insuranceValue ? _self.insuranceValue : insuranceValue // ignore: cast_nullable_to_non_nullable
as double?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [BundleCodeGenerationRequest].
extension BundleCodeGenerationRequestPatterns on BundleCodeGenerationRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BundleCodeGenerationRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BundleCodeGenerationRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BundleCodeGenerationRequest value)  $default,){
final _that = this;
switch (_that) {
case _BundleCodeGenerationRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BundleCodeGenerationRequest value)?  $default,){
final _that = this;
switch (_that) {
case _BundleCodeGenerationRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String factoryId,  String subscriptionPlanId,  int count,  String prefix,  int startSequence,  bool includeInternationalCodes,  bool generateQrCodes,  bool generateBarcodes,  String? batchName,  String? batchNotes,  String? metadata,  int cartonsPerBundle,  double? bundleWeight,  String? bundleDimensions,  String? storageLocation,  String? shippingMethod,  DateTime? expectedDeliveryDate,  String? category,  String? handlingInstructions,  String? customsDeclarationNumber,  double? insuranceValue,  int priority)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BundleCodeGenerationRequest() when $default != null:
return $default(_that.factoryId,_that.subscriptionPlanId,_that.count,_that.prefix,_that.startSequence,_that.includeInternationalCodes,_that.generateQrCodes,_that.generateBarcodes,_that.batchName,_that.batchNotes,_that.metadata,_that.cartonsPerBundle,_that.bundleWeight,_that.bundleDimensions,_that.storageLocation,_that.shippingMethod,_that.expectedDeliveryDate,_that.category,_that.handlingInstructions,_that.customsDeclarationNumber,_that.insuranceValue,_that.priority);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String factoryId,  String subscriptionPlanId,  int count,  String prefix,  int startSequence,  bool includeInternationalCodes,  bool generateQrCodes,  bool generateBarcodes,  String? batchName,  String? batchNotes,  String? metadata,  int cartonsPerBundle,  double? bundleWeight,  String? bundleDimensions,  String? storageLocation,  String? shippingMethod,  DateTime? expectedDeliveryDate,  String? category,  String? handlingInstructions,  String? customsDeclarationNumber,  double? insuranceValue,  int priority)  $default,) {final _that = this;
switch (_that) {
case _BundleCodeGenerationRequest():
return $default(_that.factoryId,_that.subscriptionPlanId,_that.count,_that.prefix,_that.startSequence,_that.includeInternationalCodes,_that.generateQrCodes,_that.generateBarcodes,_that.batchName,_that.batchNotes,_that.metadata,_that.cartonsPerBundle,_that.bundleWeight,_that.bundleDimensions,_that.storageLocation,_that.shippingMethod,_that.expectedDeliveryDate,_that.category,_that.handlingInstructions,_that.customsDeclarationNumber,_that.insuranceValue,_that.priority);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String factoryId,  String subscriptionPlanId,  int count,  String prefix,  int startSequence,  bool includeInternationalCodes,  bool generateQrCodes,  bool generateBarcodes,  String? batchName,  String? batchNotes,  String? metadata,  int cartonsPerBundle,  double? bundleWeight,  String? bundleDimensions,  String? storageLocation,  String? shippingMethod,  DateTime? expectedDeliveryDate,  String? category,  String? handlingInstructions,  String? customsDeclarationNumber,  double? insuranceValue,  int priority)?  $default,) {final _that = this;
switch (_that) {
case _BundleCodeGenerationRequest() when $default != null:
return $default(_that.factoryId,_that.subscriptionPlanId,_that.count,_that.prefix,_that.startSequence,_that.includeInternationalCodes,_that.generateQrCodes,_that.generateBarcodes,_that.batchName,_that.batchNotes,_that.metadata,_that.cartonsPerBundle,_that.bundleWeight,_that.bundleDimensions,_that.storageLocation,_that.shippingMethod,_that.expectedDeliveryDate,_that.category,_that.handlingInstructions,_that.customsDeclarationNumber,_that.insuranceValue,_that.priority);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BundleCodeGenerationRequest implements BundleCodeGenerationRequest {
  const _BundleCodeGenerationRequest({required this.factoryId, required this.subscriptionPlanId, required this.count, required this.prefix, this.startSequence = 1, this.includeInternationalCodes = true, this.generateQrCodes = true, this.generateBarcodes = true, this.batchName, this.batchNotes, this.metadata, required this.cartonsPerBundle, this.bundleWeight, this.bundleDimensions, this.storageLocation, this.shippingMethod, this.expectedDeliveryDate, this.category, this.handlingInstructions, this.customsDeclarationNumber, this.insuranceValue, this.priority = 2});
  factory _BundleCodeGenerationRequest.fromJson(Map<String, dynamic> json) => _$BundleCodeGenerationRequestFromJson(json);

/// Base request parameters
@override final  String factoryId;
@override final  String subscriptionPlanId;
@override final  int count;
@override final  String prefix;
@override@JsonKey() final  int startSequence;
@override@JsonKey() final  bool includeInternationalCodes;
@override@JsonKey() final  bool generateQrCodes;
@override@JsonKey() final  bool generateBarcodes;
@override final  String? batchName;
@override final  String? batchNotes;
@override final  String? metadata;
/// Bundle-specific parameters
/// Number of cartons per bundle
@override final  int cartonsPerBundle;
/// Bundle weight in kilograms (optional)
@override final  double? bundleWeight;
/// Bundle dimensions (length x width x height in cm)
@override final  String? bundleDimensions;
/// Storage location
@override final  String? storageLocation;
/// Shipping method
@override final  String? shippingMethod;
/// Expected delivery date
@override final  DateTime? expectedDeliveryDate;
/// Bundle category
@override final  String? category;
/// Handling instructions
@override final  String? handlingInstructions;
/// Customs declaration number
@override final  String? customsDeclarationNumber;
/// Insurance value
@override final  double? insuranceValue;
/// Priority (1=High, 2=Medium, 3=Low)
@override@JsonKey() final  int priority;

/// Create a copy of BundleCodeGenerationRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BundleCodeGenerationRequestCopyWith<_BundleCodeGenerationRequest> get copyWith => __$BundleCodeGenerationRequestCopyWithImpl<_BundleCodeGenerationRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BundleCodeGenerationRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BundleCodeGenerationRequest&&(identical(other.factoryId, factoryId) || other.factoryId == factoryId)&&(identical(other.subscriptionPlanId, subscriptionPlanId) || other.subscriptionPlanId == subscriptionPlanId)&&(identical(other.count, count) || other.count == count)&&(identical(other.prefix, prefix) || other.prefix == prefix)&&(identical(other.startSequence, startSequence) || other.startSequence == startSequence)&&(identical(other.includeInternationalCodes, includeInternationalCodes) || other.includeInternationalCodes == includeInternationalCodes)&&(identical(other.generateQrCodes, generateQrCodes) || other.generateQrCodes == generateQrCodes)&&(identical(other.generateBarcodes, generateBarcodes) || other.generateBarcodes == generateBarcodes)&&(identical(other.batchName, batchName) || other.batchName == batchName)&&(identical(other.batchNotes, batchNotes) || other.batchNotes == batchNotes)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.cartonsPerBundle, cartonsPerBundle) || other.cartonsPerBundle == cartonsPerBundle)&&(identical(other.bundleWeight, bundleWeight) || other.bundleWeight == bundleWeight)&&(identical(other.bundleDimensions, bundleDimensions) || other.bundleDimensions == bundleDimensions)&&(identical(other.storageLocation, storageLocation) || other.storageLocation == storageLocation)&&(identical(other.shippingMethod, shippingMethod) || other.shippingMethod == shippingMethod)&&(identical(other.expectedDeliveryDate, expectedDeliveryDate) || other.expectedDeliveryDate == expectedDeliveryDate)&&(identical(other.category, category) || other.category == category)&&(identical(other.handlingInstructions, handlingInstructions) || other.handlingInstructions == handlingInstructions)&&(identical(other.customsDeclarationNumber, customsDeclarationNumber) || other.customsDeclarationNumber == customsDeclarationNumber)&&(identical(other.insuranceValue, insuranceValue) || other.insuranceValue == insuranceValue)&&(identical(other.priority, priority) || other.priority == priority));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,factoryId,subscriptionPlanId,count,prefix,startSequence,includeInternationalCodes,generateQrCodes,generateBarcodes,batchName,batchNotes,metadata,cartonsPerBundle,bundleWeight,bundleDimensions,storageLocation,shippingMethod,expectedDeliveryDate,category,handlingInstructions,customsDeclarationNumber,insuranceValue,priority]);

@override
String toString() {
  return 'BundleCodeGenerationRequest(factoryId: $factoryId, subscriptionPlanId: $subscriptionPlanId, count: $count, prefix: $prefix, startSequence: $startSequence, includeInternationalCodes: $includeInternationalCodes, generateQrCodes: $generateQrCodes, generateBarcodes: $generateBarcodes, batchName: $batchName, batchNotes: $batchNotes, metadata: $metadata, cartonsPerBundle: $cartonsPerBundle, bundleWeight: $bundleWeight, bundleDimensions: $bundleDimensions, storageLocation: $storageLocation, shippingMethod: $shippingMethod, expectedDeliveryDate: $expectedDeliveryDate, category: $category, handlingInstructions: $handlingInstructions, customsDeclarationNumber: $customsDeclarationNumber, insuranceValue: $insuranceValue, priority: $priority)';
}


}

/// @nodoc
abstract mixin class _$BundleCodeGenerationRequestCopyWith<$Res> implements $BundleCodeGenerationRequestCopyWith<$Res> {
  factory _$BundleCodeGenerationRequestCopyWith(_BundleCodeGenerationRequest value, $Res Function(_BundleCodeGenerationRequest) _then) = __$BundleCodeGenerationRequestCopyWithImpl;
@override @useResult
$Res call({
 String factoryId, String subscriptionPlanId, int count, String prefix, int startSequence, bool includeInternationalCodes, bool generateQrCodes, bool generateBarcodes, String? batchName, String? batchNotes, String? metadata, int cartonsPerBundle, double? bundleWeight, String? bundleDimensions, String? storageLocation, String? shippingMethod, DateTime? expectedDeliveryDate, String? category, String? handlingInstructions, String? customsDeclarationNumber, double? insuranceValue, int priority
});




}
/// @nodoc
class __$BundleCodeGenerationRequestCopyWithImpl<$Res>
    implements _$BundleCodeGenerationRequestCopyWith<$Res> {
  __$BundleCodeGenerationRequestCopyWithImpl(this._self, this._then);

  final _BundleCodeGenerationRequest _self;
  final $Res Function(_BundleCodeGenerationRequest) _then;

/// Create a copy of BundleCodeGenerationRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? factoryId = null,Object? subscriptionPlanId = null,Object? count = null,Object? prefix = null,Object? startSequence = null,Object? includeInternationalCodes = null,Object? generateQrCodes = null,Object? generateBarcodes = null,Object? batchName = freezed,Object? batchNotes = freezed,Object? metadata = freezed,Object? cartonsPerBundle = null,Object? bundleWeight = freezed,Object? bundleDimensions = freezed,Object? storageLocation = freezed,Object? shippingMethod = freezed,Object? expectedDeliveryDate = freezed,Object? category = freezed,Object? handlingInstructions = freezed,Object? customsDeclarationNumber = freezed,Object? insuranceValue = freezed,Object? priority = null,}) {
  return _then(_BundleCodeGenerationRequest(
factoryId: null == factoryId ? _self.factoryId : factoryId // ignore: cast_nullable_to_non_nullable
as String,subscriptionPlanId: null == subscriptionPlanId ? _self.subscriptionPlanId : subscriptionPlanId // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,prefix: null == prefix ? _self.prefix : prefix // ignore: cast_nullable_to_non_nullable
as String,startSequence: null == startSequence ? _self.startSequence : startSequence // ignore: cast_nullable_to_non_nullable
as int,includeInternationalCodes: null == includeInternationalCodes ? _self.includeInternationalCodes : includeInternationalCodes // ignore: cast_nullable_to_non_nullable
as bool,generateQrCodes: null == generateQrCodes ? _self.generateQrCodes : generateQrCodes // ignore: cast_nullable_to_non_nullable
as bool,generateBarcodes: null == generateBarcodes ? _self.generateBarcodes : generateBarcodes // ignore: cast_nullable_to_non_nullable
as bool,batchName: freezed == batchName ? _self.batchName : batchName // ignore: cast_nullable_to_non_nullable
as String?,batchNotes: freezed == batchNotes ? _self.batchNotes : batchNotes // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as String?,cartonsPerBundle: null == cartonsPerBundle ? _self.cartonsPerBundle : cartonsPerBundle // ignore: cast_nullable_to_non_nullable
as int,bundleWeight: freezed == bundleWeight ? _self.bundleWeight : bundleWeight // ignore: cast_nullable_to_non_nullable
as double?,bundleDimensions: freezed == bundleDimensions ? _self.bundleDimensions : bundleDimensions // ignore: cast_nullable_to_non_nullable
as String?,storageLocation: freezed == storageLocation ? _self.storageLocation : storageLocation // ignore: cast_nullable_to_non_nullable
as String?,shippingMethod: freezed == shippingMethod ? _self.shippingMethod : shippingMethod // ignore: cast_nullable_to_non_nullable
as String?,expectedDeliveryDate: freezed == expectedDeliveryDate ? _self.expectedDeliveryDate : expectedDeliveryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,handlingInstructions: freezed == handlingInstructions ? _self.handlingInstructions : handlingInstructions // ignore: cast_nullable_to_non_nullable
as String?,customsDeclarationNumber: freezed == customsDeclarationNumber ? _self.customsDeclarationNumber : customsDeclarationNumber // ignore: cast_nullable_to_non_nullable
as String?,insuranceValue: freezed == insuranceValue ? _self.insuranceValue : insuranceValue // ignore: cast_nullable_to_non_nullable
as double?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$CartonCodeGenerationRequest {

/// Base request parameters
 String get factoryId; String get subscriptionPlanId; int get count; String get prefix; int get startSequence; bool get includeInternationalCodes; bool get generateQrCodes; bool get generateBarcodes; String? get batchName; String? get batchNotes; String? get metadata;/// Carton-specific parameters
/// Bundle code that will contain these cartons
 String get bundleCode;/// Number of packets per carton
 int get packetsPerCarton;/// Carton weight in kilograms (optional)
 double? get cartonWeight;/// Carton dimensions (length x width x height in cm)
 String? get cartonDimensions;/// Carton type (e.g., "Corrugated", "Cardboard", "Plastic")
 String? get cartonType;/// Carton grade/quality
 String? get grade;/// Maximum weight capacity
 double? get maxWeightCapacity;/// Temperature requirements
 String? get temperatureRequirements;/// Handling instructions
 String? get handlingInstructions;/// Should generate separate carton barcode?
 bool get generateCartonBarcode;/// Should generate separate carton QR code?
 bool get generateCartonQrCode;
/// Create a copy of CartonCodeGenerationRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartonCodeGenerationRequestCopyWith<CartonCodeGenerationRequest> get copyWith => _$CartonCodeGenerationRequestCopyWithImpl<CartonCodeGenerationRequest>(this as CartonCodeGenerationRequest, _$identity);

  /// Serializes this CartonCodeGenerationRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CartonCodeGenerationRequest&&(identical(other.factoryId, factoryId) || other.factoryId == factoryId)&&(identical(other.subscriptionPlanId, subscriptionPlanId) || other.subscriptionPlanId == subscriptionPlanId)&&(identical(other.count, count) || other.count == count)&&(identical(other.prefix, prefix) || other.prefix == prefix)&&(identical(other.startSequence, startSequence) || other.startSequence == startSequence)&&(identical(other.includeInternationalCodes, includeInternationalCodes) || other.includeInternationalCodes == includeInternationalCodes)&&(identical(other.generateQrCodes, generateQrCodes) || other.generateQrCodes == generateQrCodes)&&(identical(other.generateBarcodes, generateBarcodes) || other.generateBarcodes == generateBarcodes)&&(identical(other.batchName, batchName) || other.batchName == batchName)&&(identical(other.batchNotes, batchNotes) || other.batchNotes == batchNotes)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.bundleCode, bundleCode) || other.bundleCode == bundleCode)&&(identical(other.packetsPerCarton, packetsPerCarton) || other.packetsPerCarton == packetsPerCarton)&&(identical(other.cartonWeight, cartonWeight) || other.cartonWeight == cartonWeight)&&(identical(other.cartonDimensions, cartonDimensions) || other.cartonDimensions == cartonDimensions)&&(identical(other.cartonType, cartonType) || other.cartonType == cartonType)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.maxWeightCapacity, maxWeightCapacity) || other.maxWeightCapacity == maxWeightCapacity)&&(identical(other.temperatureRequirements, temperatureRequirements) || other.temperatureRequirements == temperatureRequirements)&&(identical(other.handlingInstructions, handlingInstructions) || other.handlingInstructions == handlingInstructions)&&(identical(other.generateCartonBarcode, generateCartonBarcode) || other.generateCartonBarcode == generateCartonBarcode)&&(identical(other.generateCartonQrCode, generateCartonQrCode) || other.generateCartonQrCode == generateCartonQrCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,factoryId,subscriptionPlanId,count,prefix,startSequence,includeInternationalCodes,generateQrCodes,generateBarcodes,batchName,batchNotes,metadata,bundleCode,packetsPerCarton,cartonWeight,cartonDimensions,cartonType,grade,maxWeightCapacity,temperatureRequirements,handlingInstructions,generateCartonBarcode,generateCartonQrCode]);

@override
String toString() {
  return 'CartonCodeGenerationRequest(factoryId: $factoryId, subscriptionPlanId: $subscriptionPlanId, count: $count, prefix: $prefix, startSequence: $startSequence, includeInternationalCodes: $includeInternationalCodes, generateQrCodes: $generateQrCodes, generateBarcodes: $generateBarcodes, batchName: $batchName, batchNotes: $batchNotes, metadata: $metadata, bundleCode: $bundleCode, packetsPerCarton: $packetsPerCarton, cartonWeight: $cartonWeight, cartonDimensions: $cartonDimensions, cartonType: $cartonType, grade: $grade, maxWeightCapacity: $maxWeightCapacity, temperatureRequirements: $temperatureRequirements, handlingInstructions: $handlingInstructions, generateCartonBarcode: $generateCartonBarcode, generateCartonQrCode: $generateCartonQrCode)';
}


}

/// @nodoc
abstract mixin class $CartonCodeGenerationRequestCopyWith<$Res>  {
  factory $CartonCodeGenerationRequestCopyWith(CartonCodeGenerationRequest value, $Res Function(CartonCodeGenerationRequest) _then) = _$CartonCodeGenerationRequestCopyWithImpl;
@useResult
$Res call({
 String factoryId, String subscriptionPlanId, int count, String prefix, int startSequence, bool includeInternationalCodes, bool generateQrCodes, bool generateBarcodes, String? batchName, String? batchNotes, String? metadata, String bundleCode, int packetsPerCarton, double? cartonWeight, String? cartonDimensions, String? cartonType, String? grade, double? maxWeightCapacity, String? temperatureRequirements, String? handlingInstructions, bool generateCartonBarcode, bool generateCartonQrCode
});




}
/// @nodoc
class _$CartonCodeGenerationRequestCopyWithImpl<$Res>
    implements $CartonCodeGenerationRequestCopyWith<$Res> {
  _$CartonCodeGenerationRequestCopyWithImpl(this._self, this._then);

  final CartonCodeGenerationRequest _self;
  final $Res Function(CartonCodeGenerationRequest) _then;

/// Create a copy of CartonCodeGenerationRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? factoryId = null,Object? subscriptionPlanId = null,Object? count = null,Object? prefix = null,Object? startSequence = null,Object? includeInternationalCodes = null,Object? generateQrCodes = null,Object? generateBarcodes = null,Object? batchName = freezed,Object? batchNotes = freezed,Object? metadata = freezed,Object? bundleCode = null,Object? packetsPerCarton = null,Object? cartonWeight = freezed,Object? cartonDimensions = freezed,Object? cartonType = freezed,Object? grade = freezed,Object? maxWeightCapacity = freezed,Object? temperatureRequirements = freezed,Object? handlingInstructions = freezed,Object? generateCartonBarcode = null,Object? generateCartonQrCode = null,}) {
  return _then(_self.copyWith(
factoryId: null == factoryId ? _self.factoryId : factoryId // ignore: cast_nullable_to_non_nullable
as String,subscriptionPlanId: null == subscriptionPlanId ? _self.subscriptionPlanId : subscriptionPlanId // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,prefix: null == prefix ? _self.prefix : prefix // ignore: cast_nullable_to_non_nullable
as String,startSequence: null == startSequence ? _self.startSequence : startSequence // ignore: cast_nullable_to_non_nullable
as int,includeInternationalCodes: null == includeInternationalCodes ? _self.includeInternationalCodes : includeInternationalCodes // ignore: cast_nullable_to_non_nullable
as bool,generateQrCodes: null == generateQrCodes ? _self.generateQrCodes : generateQrCodes // ignore: cast_nullable_to_non_nullable
as bool,generateBarcodes: null == generateBarcodes ? _self.generateBarcodes : generateBarcodes // ignore: cast_nullable_to_non_nullable
as bool,batchName: freezed == batchName ? _self.batchName : batchName // ignore: cast_nullable_to_non_nullable
as String?,batchNotes: freezed == batchNotes ? _self.batchNotes : batchNotes // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as String?,bundleCode: null == bundleCode ? _self.bundleCode : bundleCode // ignore: cast_nullable_to_non_nullable
as String,packetsPerCarton: null == packetsPerCarton ? _self.packetsPerCarton : packetsPerCarton // ignore: cast_nullable_to_non_nullable
as int,cartonWeight: freezed == cartonWeight ? _self.cartonWeight : cartonWeight // ignore: cast_nullable_to_non_nullable
as double?,cartonDimensions: freezed == cartonDimensions ? _self.cartonDimensions : cartonDimensions // ignore: cast_nullable_to_non_nullable
as String?,cartonType: freezed == cartonType ? _self.cartonType : cartonType // ignore: cast_nullable_to_non_nullable
as String?,grade: freezed == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as String?,maxWeightCapacity: freezed == maxWeightCapacity ? _self.maxWeightCapacity : maxWeightCapacity // ignore: cast_nullable_to_non_nullable
as double?,temperatureRequirements: freezed == temperatureRequirements ? _self.temperatureRequirements : temperatureRequirements // ignore: cast_nullable_to_non_nullable
as String?,handlingInstructions: freezed == handlingInstructions ? _self.handlingInstructions : handlingInstructions // ignore: cast_nullable_to_non_nullable
as String?,generateCartonBarcode: null == generateCartonBarcode ? _self.generateCartonBarcode : generateCartonBarcode // ignore: cast_nullable_to_non_nullable
as bool,generateCartonQrCode: null == generateCartonQrCode ? _self.generateCartonQrCode : generateCartonQrCode // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CartonCodeGenerationRequest].
extension CartonCodeGenerationRequestPatterns on CartonCodeGenerationRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CartonCodeGenerationRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CartonCodeGenerationRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CartonCodeGenerationRequest value)  $default,){
final _that = this;
switch (_that) {
case _CartonCodeGenerationRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CartonCodeGenerationRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CartonCodeGenerationRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String factoryId,  String subscriptionPlanId,  int count,  String prefix,  int startSequence,  bool includeInternationalCodes,  bool generateQrCodes,  bool generateBarcodes,  String? batchName,  String? batchNotes,  String? metadata,  String bundleCode,  int packetsPerCarton,  double? cartonWeight,  String? cartonDimensions,  String? cartonType,  String? grade,  double? maxWeightCapacity,  String? temperatureRequirements,  String? handlingInstructions,  bool generateCartonBarcode,  bool generateCartonQrCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CartonCodeGenerationRequest() when $default != null:
return $default(_that.factoryId,_that.subscriptionPlanId,_that.count,_that.prefix,_that.startSequence,_that.includeInternationalCodes,_that.generateQrCodes,_that.generateBarcodes,_that.batchName,_that.batchNotes,_that.metadata,_that.bundleCode,_that.packetsPerCarton,_that.cartonWeight,_that.cartonDimensions,_that.cartonType,_that.grade,_that.maxWeightCapacity,_that.temperatureRequirements,_that.handlingInstructions,_that.generateCartonBarcode,_that.generateCartonQrCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String factoryId,  String subscriptionPlanId,  int count,  String prefix,  int startSequence,  bool includeInternationalCodes,  bool generateQrCodes,  bool generateBarcodes,  String? batchName,  String? batchNotes,  String? metadata,  String bundleCode,  int packetsPerCarton,  double? cartonWeight,  String? cartonDimensions,  String? cartonType,  String? grade,  double? maxWeightCapacity,  String? temperatureRequirements,  String? handlingInstructions,  bool generateCartonBarcode,  bool generateCartonQrCode)  $default,) {final _that = this;
switch (_that) {
case _CartonCodeGenerationRequest():
return $default(_that.factoryId,_that.subscriptionPlanId,_that.count,_that.prefix,_that.startSequence,_that.includeInternationalCodes,_that.generateQrCodes,_that.generateBarcodes,_that.batchName,_that.batchNotes,_that.metadata,_that.bundleCode,_that.packetsPerCarton,_that.cartonWeight,_that.cartonDimensions,_that.cartonType,_that.grade,_that.maxWeightCapacity,_that.temperatureRequirements,_that.handlingInstructions,_that.generateCartonBarcode,_that.generateCartonQrCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String factoryId,  String subscriptionPlanId,  int count,  String prefix,  int startSequence,  bool includeInternationalCodes,  bool generateQrCodes,  bool generateBarcodes,  String? batchName,  String? batchNotes,  String? metadata,  String bundleCode,  int packetsPerCarton,  double? cartonWeight,  String? cartonDimensions,  String? cartonType,  String? grade,  double? maxWeightCapacity,  String? temperatureRequirements,  String? handlingInstructions,  bool generateCartonBarcode,  bool generateCartonQrCode)?  $default,) {final _that = this;
switch (_that) {
case _CartonCodeGenerationRequest() when $default != null:
return $default(_that.factoryId,_that.subscriptionPlanId,_that.count,_that.prefix,_that.startSequence,_that.includeInternationalCodes,_that.generateQrCodes,_that.generateBarcodes,_that.batchName,_that.batchNotes,_that.metadata,_that.bundleCode,_that.packetsPerCarton,_that.cartonWeight,_that.cartonDimensions,_that.cartonType,_that.grade,_that.maxWeightCapacity,_that.temperatureRequirements,_that.handlingInstructions,_that.generateCartonBarcode,_that.generateCartonQrCode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CartonCodeGenerationRequest implements CartonCodeGenerationRequest {
  const _CartonCodeGenerationRequest({required this.factoryId, required this.subscriptionPlanId, required this.count, required this.prefix, this.startSequence = 1, this.includeInternationalCodes = true, this.generateQrCodes = true, this.generateBarcodes = true, this.batchName, this.batchNotes, this.metadata, required this.bundleCode, required this.packetsPerCarton, this.cartonWeight, this.cartonDimensions, this.cartonType, this.grade, this.maxWeightCapacity, this.temperatureRequirements, this.handlingInstructions, this.generateCartonBarcode = true, this.generateCartonQrCode = true});
  factory _CartonCodeGenerationRequest.fromJson(Map<String, dynamic> json) => _$CartonCodeGenerationRequestFromJson(json);

/// Base request parameters
@override final  String factoryId;
@override final  String subscriptionPlanId;
@override final  int count;
@override final  String prefix;
@override@JsonKey() final  int startSequence;
@override@JsonKey() final  bool includeInternationalCodes;
@override@JsonKey() final  bool generateQrCodes;
@override@JsonKey() final  bool generateBarcodes;
@override final  String? batchName;
@override final  String? batchNotes;
@override final  String? metadata;
/// Carton-specific parameters
/// Bundle code that will contain these cartons
@override final  String bundleCode;
/// Number of packets per carton
@override final  int packetsPerCarton;
/// Carton weight in kilograms (optional)
@override final  double? cartonWeight;
/// Carton dimensions (length x width x height in cm)
@override final  String? cartonDimensions;
/// Carton type (e.g., "Corrugated", "Cardboard", "Plastic")
@override final  String? cartonType;
/// Carton grade/quality
@override final  String? grade;
/// Maximum weight capacity
@override final  double? maxWeightCapacity;
/// Temperature requirements
@override final  String? temperatureRequirements;
/// Handling instructions
@override final  String? handlingInstructions;
/// Should generate separate carton barcode?
@override@JsonKey() final  bool generateCartonBarcode;
/// Should generate separate carton QR code?
@override@JsonKey() final  bool generateCartonQrCode;

/// Create a copy of CartonCodeGenerationRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CartonCodeGenerationRequestCopyWith<_CartonCodeGenerationRequest> get copyWith => __$CartonCodeGenerationRequestCopyWithImpl<_CartonCodeGenerationRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CartonCodeGenerationRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CartonCodeGenerationRequest&&(identical(other.factoryId, factoryId) || other.factoryId == factoryId)&&(identical(other.subscriptionPlanId, subscriptionPlanId) || other.subscriptionPlanId == subscriptionPlanId)&&(identical(other.count, count) || other.count == count)&&(identical(other.prefix, prefix) || other.prefix == prefix)&&(identical(other.startSequence, startSequence) || other.startSequence == startSequence)&&(identical(other.includeInternationalCodes, includeInternationalCodes) || other.includeInternationalCodes == includeInternationalCodes)&&(identical(other.generateQrCodes, generateQrCodes) || other.generateQrCodes == generateQrCodes)&&(identical(other.generateBarcodes, generateBarcodes) || other.generateBarcodes == generateBarcodes)&&(identical(other.batchName, batchName) || other.batchName == batchName)&&(identical(other.batchNotes, batchNotes) || other.batchNotes == batchNotes)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.bundleCode, bundleCode) || other.bundleCode == bundleCode)&&(identical(other.packetsPerCarton, packetsPerCarton) || other.packetsPerCarton == packetsPerCarton)&&(identical(other.cartonWeight, cartonWeight) || other.cartonWeight == cartonWeight)&&(identical(other.cartonDimensions, cartonDimensions) || other.cartonDimensions == cartonDimensions)&&(identical(other.cartonType, cartonType) || other.cartonType == cartonType)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.maxWeightCapacity, maxWeightCapacity) || other.maxWeightCapacity == maxWeightCapacity)&&(identical(other.temperatureRequirements, temperatureRequirements) || other.temperatureRequirements == temperatureRequirements)&&(identical(other.handlingInstructions, handlingInstructions) || other.handlingInstructions == handlingInstructions)&&(identical(other.generateCartonBarcode, generateCartonBarcode) || other.generateCartonBarcode == generateCartonBarcode)&&(identical(other.generateCartonQrCode, generateCartonQrCode) || other.generateCartonQrCode == generateCartonQrCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,factoryId,subscriptionPlanId,count,prefix,startSequence,includeInternationalCodes,generateQrCodes,generateBarcodes,batchName,batchNotes,metadata,bundleCode,packetsPerCarton,cartonWeight,cartonDimensions,cartonType,grade,maxWeightCapacity,temperatureRequirements,handlingInstructions,generateCartonBarcode,generateCartonQrCode]);

@override
String toString() {
  return 'CartonCodeGenerationRequest(factoryId: $factoryId, subscriptionPlanId: $subscriptionPlanId, count: $count, prefix: $prefix, startSequence: $startSequence, includeInternationalCodes: $includeInternationalCodes, generateQrCodes: $generateQrCodes, generateBarcodes: $generateBarcodes, batchName: $batchName, batchNotes: $batchNotes, metadata: $metadata, bundleCode: $bundleCode, packetsPerCarton: $packetsPerCarton, cartonWeight: $cartonWeight, cartonDimensions: $cartonDimensions, cartonType: $cartonType, grade: $grade, maxWeightCapacity: $maxWeightCapacity, temperatureRequirements: $temperatureRequirements, handlingInstructions: $handlingInstructions, generateCartonBarcode: $generateCartonBarcode, generateCartonQrCode: $generateCartonQrCode)';
}


}

/// @nodoc
abstract mixin class _$CartonCodeGenerationRequestCopyWith<$Res> implements $CartonCodeGenerationRequestCopyWith<$Res> {
  factory _$CartonCodeGenerationRequestCopyWith(_CartonCodeGenerationRequest value, $Res Function(_CartonCodeGenerationRequest) _then) = __$CartonCodeGenerationRequestCopyWithImpl;
@override @useResult
$Res call({
 String factoryId, String subscriptionPlanId, int count, String prefix, int startSequence, bool includeInternationalCodes, bool generateQrCodes, bool generateBarcodes, String? batchName, String? batchNotes, String? metadata, String bundleCode, int packetsPerCarton, double? cartonWeight, String? cartonDimensions, String? cartonType, String? grade, double? maxWeightCapacity, String? temperatureRequirements, String? handlingInstructions, bool generateCartonBarcode, bool generateCartonQrCode
});




}
/// @nodoc
class __$CartonCodeGenerationRequestCopyWithImpl<$Res>
    implements _$CartonCodeGenerationRequestCopyWith<$Res> {
  __$CartonCodeGenerationRequestCopyWithImpl(this._self, this._then);

  final _CartonCodeGenerationRequest _self;
  final $Res Function(_CartonCodeGenerationRequest) _then;

/// Create a copy of CartonCodeGenerationRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? factoryId = null,Object? subscriptionPlanId = null,Object? count = null,Object? prefix = null,Object? startSequence = null,Object? includeInternationalCodes = null,Object? generateQrCodes = null,Object? generateBarcodes = null,Object? batchName = freezed,Object? batchNotes = freezed,Object? metadata = freezed,Object? bundleCode = null,Object? packetsPerCarton = null,Object? cartonWeight = freezed,Object? cartonDimensions = freezed,Object? cartonType = freezed,Object? grade = freezed,Object? maxWeightCapacity = freezed,Object? temperatureRequirements = freezed,Object? handlingInstructions = freezed,Object? generateCartonBarcode = null,Object? generateCartonQrCode = null,}) {
  return _then(_CartonCodeGenerationRequest(
factoryId: null == factoryId ? _self.factoryId : factoryId // ignore: cast_nullable_to_non_nullable
as String,subscriptionPlanId: null == subscriptionPlanId ? _self.subscriptionPlanId : subscriptionPlanId // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,prefix: null == prefix ? _self.prefix : prefix // ignore: cast_nullable_to_non_nullable
as String,startSequence: null == startSequence ? _self.startSequence : startSequence // ignore: cast_nullable_to_non_nullable
as int,includeInternationalCodes: null == includeInternationalCodes ? _self.includeInternationalCodes : includeInternationalCodes // ignore: cast_nullable_to_non_nullable
as bool,generateQrCodes: null == generateQrCodes ? _self.generateQrCodes : generateQrCodes // ignore: cast_nullable_to_non_nullable
as bool,generateBarcodes: null == generateBarcodes ? _self.generateBarcodes : generateBarcodes // ignore: cast_nullable_to_non_nullable
as bool,batchName: freezed == batchName ? _self.batchName : batchName // ignore: cast_nullable_to_non_nullable
as String?,batchNotes: freezed == batchNotes ? _self.batchNotes : batchNotes // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as String?,bundleCode: null == bundleCode ? _self.bundleCode : bundleCode // ignore: cast_nullable_to_non_nullable
as String,packetsPerCarton: null == packetsPerCarton ? _self.packetsPerCarton : packetsPerCarton // ignore: cast_nullable_to_non_nullable
as int,cartonWeight: freezed == cartonWeight ? _self.cartonWeight : cartonWeight // ignore: cast_nullable_to_non_nullable
as double?,cartonDimensions: freezed == cartonDimensions ? _self.cartonDimensions : cartonDimensions // ignore: cast_nullable_to_non_nullable
as String?,cartonType: freezed == cartonType ? _self.cartonType : cartonType // ignore: cast_nullable_to_non_nullable
as String?,grade: freezed == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as String?,maxWeightCapacity: freezed == maxWeightCapacity ? _self.maxWeightCapacity : maxWeightCapacity // ignore: cast_nullable_to_non_nullable
as double?,temperatureRequirements: freezed == temperatureRequirements ? _self.temperatureRequirements : temperatureRequirements // ignore: cast_nullable_to_non_nullable
as String?,handlingInstructions: freezed == handlingInstructions ? _self.handlingInstructions : handlingInstructions // ignore: cast_nullable_to_non_nullable
as String?,generateCartonBarcode: null == generateCartonBarcode ? _self.generateCartonBarcode : generateCartonBarcode // ignore: cast_nullable_to_non_nullable
as bool,generateCartonQrCode: null == generateCartonQrCode ? _self.generateCartonQrCode : generateCartonQrCode // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$PacketCodeGenerationRequest {

/// Base request parameters
 String get factoryId; String get subscriptionPlanId; int get count; String get prefix; int get startSequence; bool get includeInternationalCodes; bool get generateQrCodes; bool get generateBarcodes; String? get batchName; String? get batchNotes; String? get metadata;/// Packet-specific parameters
/// Carton code that will contain these packets
 String get cartonCode;/// Number of units per packet
 int get unitsPerPacket;/// Packet weight in grams (optional)
 double? get packetWeight;/// Packet dimensions (length x width x height in cm)
 String? get packetDimensions;/// Packet type (e.g., "Blister", "Box", "Pouch", "Bottle")
 String? get packetType;/// Packet material (e.g., "Plastic", "Paper", "Aluminum")
 String? get material;/// Sealing method (e.g., "Heat Seal", "Adhesive", "Clip")
 String? get sealingMethod;/// Should include tamper evidence?
 bool get includeTamperEvidence;/// Should include child safety features?
 bool get includeChildSafety;/// Should include instructions?
 bool get includeInstructions;/// Packet color
 String? get color;/// Printing details
 String? get printingDetails;/// Should generate separate packet barcode?
 bool get generatePacketBarcode;/// Should generate separate packet QR code?
 bool get generatePacketQrCode;
/// Create a copy of PacketCodeGenerationRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PacketCodeGenerationRequestCopyWith<PacketCodeGenerationRequest> get copyWith => _$PacketCodeGenerationRequestCopyWithImpl<PacketCodeGenerationRequest>(this as PacketCodeGenerationRequest, _$identity);

  /// Serializes this PacketCodeGenerationRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PacketCodeGenerationRequest&&(identical(other.factoryId, factoryId) || other.factoryId == factoryId)&&(identical(other.subscriptionPlanId, subscriptionPlanId) || other.subscriptionPlanId == subscriptionPlanId)&&(identical(other.count, count) || other.count == count)&&(identical(other.prefix, prefix) || other.prefix == prefix)&&(identical(other.startSequence, startSequence) || other.startSequence == startSequence)&&(identical(other.includeInternationalCodes, includeInternationalCodes) || other.includeInternationalCodes == includeInternationalCodes)&&(identical(other.generateQrCodes, generateQrCodes) || other.generateQrCodes == generateQrCodes)&&(identical(other.generateBarcodes, generateBarcodes) || other.generateBarcodes == generateBarcodes)&&(identical(other.batchName, batchName) || other.batchName == batchName)&&(identical(other.batchNotes, batchNotes) || other.batchNotes == batchNotes)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.cartonCode, cartonCode) || other.cartonCode == cartonCode)&&(identical(other.unitsPerPacket, unitsPerPacket) || other.unitsPerPacket == unitsPerPacket)&&(identical(other.packetWeight, packetWeight) || other.packetWeight == packetWeight)&&(identical(other.packetDimensions, packetDimensions) || other.packetDimensions == packetDimensions)&&(identical(other.packetType, packetType) || other.packetType == packetType)&&(identical(other.material, material) || other.material == material)&&(identical(other.sealingMethod, sealingMethod) || other.sealingMethod == sealingMethod)&&(identical(other.includeTamperEvidence, includeTamperEvidence) || other.includeTamperEvidence == includeTamperEvidence)&&(identical(other.includeChildSafety, includeChildSafety) || other.includeChildSafety == includeChildSafety)&&(identical(other.includeInstructions, includeInstructions) || other.includeInstructions == includeInstructions)&&(identical(other.color, color) || other.color == color)&&(identical(other.printingDetails, printingDetails) || other.printingDetails == printingDetails)&&(identical(other.generatePacketBarcode, generatePacketBarcode) || other.generatePacketBarcode == generatePacketBarcode)&&(identical(other.generatePacketQrCode, generatePacketQrCode) || other.generatePacketQrCode == generatePacketQrCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,factoryId,subscriptionPlanId,count,prefix,startSequence,includeInternationalCodes,generateQrCodes,generateBarcodes,batchName,batchNotes,metadata,cartonCode,unitsPerPacket,packetWeight,packetDimensions,packetType,material,sealingMethod,includeTamperEvidence,includeChildSafety,includeInstructions,color,printingDetails,generatePacketBarcode,generatePacketQrCode]);

@override
String toString() {
  return 'PacketCodeGenerationRequest(factoryId: $factoryId, subscriptionPlanId: $subscriptionPlanId, count: $count, prefix: $prefix, startSequence: $startSequence, includeInternationalCodes: $includeInternationalCodes, generateQrCodes: $generateQrCodes, generateBarcodes: $generateBarcodes, batchName: $batchName, batchNotes: $batchNotes, metadata: $metadata, cartonCode: $cartonCode, unitsPerPacket: $unitsPerPacket, packetWeight: $packetWeight, packetDimensions: $packetDimensions, packetType: $packetType, material: $material, sealingMethod: $sealingMethod, includeTamperEvidence: $includeTamperEvidence, includeChildSafety: $includeChildSafety, includeInstructions: $includeInstructions, color: $color, printingDetails: $printingDetails, generatePacketBarcode: $generatePacketBarcode, generatePacketQrCode: $generatePacketQrCode)';
}


}

/// @nodoc
abstract mixin class $PacketCodeGenerationRequestCopyWith<$Res>  {
  factory $PacketCodeGenerationRequestCopyWith(PacketCodeGenerationRequest value, $Res Function(PacketCodeGenerationRequest) _then) = _$PacketCodeGenerationRequestCopyWithImpl;
@useResult
$Res call({
 String factoryId, String subscriptionPlanId, int count, String prefix, int startSequence, bool includeInternationalCodes, bool generateQrCodes, bool generateBarcodes, String? batchName, String? batchNotes, String? metadata, String cartonCode, int unitsPerPacket, double? packetWeight, String? packetDimensions, String? packetType, String? material, String? sealingMethod, bool includeTamperEvidence, bool includeChildSafety, bool includeInstructions, String? color, String? printingDetails, bool generatePacketBarcode, bool generatePacketQrCode
});




}
/// @nodoc
class _$PacketCodeGenerationRequestCopyWithImpl<$Res>
    implements $PacketCodeGenerationRequestCopyWith<$Res> {
  _$PacketCodeGenerationRequestCopyWithImpl(this._self, this._then);

  final PacketCodeGenerationRequest _self;
  final $Res Function(PacketCodeGenerationRequest) _then;

/// Create a copy of PacketCodeGenerationRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? factoryId = null,Object? subscriptionPlanId = null,Object? count = null,Object? prefix = null,Object? startSequence = null,Object? includeInternationalCodes = null,Object? generateQrCodes = null,Object? generateBarcodes = null,Object? batchName = freezed,Object? batchNotes = freezed,Object? metadata = freezed,Object? cartonCode = null,Object? unitsPerPacket = null,Object? packetWeight = freezed,Object? packetDimensions = freezed,Object? packetType = freezed,Object? material = freezed,Object? sealingMethod = freezed,Object? includeTamperEvidence = null,Object? includeChildSafety = null,Object? includeInstructions = null,Object? color = freezed,Object? printingDetails = freezed,Object? generatePacketBarcode = null,Object? generatePacketQrCode = null,}) {
  return _then(_self.copyWith(
factoryId: null == factoryId ? _self.factoryId : factoryId // ignore: cast_nullable_to_non_nullable
as String,subscriptionPlanId: null == subscriptionPlanId ? _self.subscriptionPlanId : subscriptionPlanId // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,prefix: null == prefix ? _self.prefix : prefix // ignore: cast_nullable_to_non_nullable
as String,startSequence: null == startSequence ? _self.startSequence : startSequence // ignore: cast_nullable_to_non_nullable
as int,includeInternationalCodes: null == includeInternationalCodes ? _self.includeInternationalCodes : includeInternationalCodes // ignore: cast_nullable_to_non_nullable
as bool,generateQrCodes: null == generateQrCodes ? _self.generateQrCodes : generateQrCodes // ignore: cast_nullable_to_non_nullable
as bool,generateBarcodes: null == generateBarcodes ? _self.generateBarcodes : generateBarcodes // ignore: cast_nullable_to_non_nullable
as bool,batchName: freezed == batchName ? _self.batchName : batchName // ignore: cast_nullable_to_non_nullable
as String?,batchNotes: freezed == batchNotes ? _self.batchNotes : batchNotes // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as String?,cartonCode: null == cartonCode ? _self.cartonCode : cartonCode // ignore: cast_nullable_to_non_nullable
as String,unitsPerPacket: null == unitsPerPacket ? _self.unitsPerPacket : unitsPerPacket // ignore: cast_nullable_to_non_nullable
as int,packetWeight: freezed == packetWeight ? _self.packetWeight : packetWeight // ignore: cast_nullable_to_non_nullable
as double?,packetDimensions: freezed == packetDimensions ? _self.packetDimensions : packetDimensions // ignore: cast_nullable_to_non_nullable
as String?,packetType: freezed == packetType ? _self.packetType : packetType // ignore: cast_nullable_to_non_nullable
as String?,material: freezed == material ? _self.material : material // ignore: cast_nullable_to_non_nullable
as String?,sealingMethod: freezed == sealingMethod ? _self.sealingMethod : sealingMethod // ignore: cast_nullable_to_non_nullable
as String?,includeTamperEvidence: null == includeTamperEvidence ? _self.includeTamperEvidence : includeTamperEvidence // ignore: cast_nullable_to_non_nullable
as bool,includeChildSafety: null == includeChildSafety ? _self.includeChildSafety : includeChildSafety // ignore: cast_nullable_to_non_nullable
as bool,includeInstructions: null == includeInstructions ? _self.includeInstructions : includeInstructions // ignore: cast_nullable_to_non_nullable
as bool,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,printingDetails: freezed == printingDetails ? _self.printingDetails : printingDetails // ignore: cast_nullable_to_non_nullable
as String?,generatePacketBarcode: null == generatePacketBarcode ? _self.generatePacketBarcode : generatePacketBarcode // ignore: cast_nullable_to_non_nullable
as bool,generatePacketQrCode: null == generatePacketQrCode ? _self.generatePacketQrCode : generatePacketQrCode // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PacketCodeGenerationRequest].
extension PacketCodeGenerationRequestPatterns on PacketCodeGenerationRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PacketCodeGenerationRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PacketCodeGenerationRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PacketCodeGenerationRequest value)  $default,){
final _that = this;
switch (_that) {
case _PacketCodeGenerationRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PacketCodeGenerationRequest value)?  $default,){
final _that = this;
switch (_that) {
case _PacketCodeGenerationRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String factoryId,  String subscriptionPlanId,  int count,  String prefix,  int startSequence,  bool includeInternationalCodes,  bool generateQrCodes,  bool generateBarcodes,  String? batchName,  String? batchNotes,  String? metadata,  String cartonCode,  int unitsPerPacket,  double? packetWeight,  String? packetDimensions,  String? packetType,  String? material,  String? sealingMethod,  bool includeTamperEvidence,  bool includeChildSafety,  bool includeInstructions,  String? color,  String? printingDetails,  bool generatePacketBarcode,  bool generatePacketQrCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PacketCodeGenerationRequest() when $default != null:
return $default(_that.factoryId,_that.subscriptionPlanId,_that.count,_that.prefix,_that.startSequence,_that.includeInternationalCodes,_that.generateQrCodes,_that.generateBarcodes,_that.batchName,_that.batchNotes,_that.metadata,_that.cartonCode,_that.unitsPerPacket,_that.packetWeight,_that.packetDimensions,_that.packetType,_that.material,_that.sealingMethod,_that.includeTamperEvidence,_that.includeChildSafety,_that.includeInstructions,_that.color,_that.printingDetails,_that.generatePacketBarcode,_that.generatePacketQrCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String factoryId,  String subscriptionPlanId,  int count,  String prefix,  int startSequence,  bool includeInternationalCodes,  bool generateQrCodes,  bool generateBarcodes,  String? batchName,  String? batchNotes,  String? metadata,  String cartonCode,  int unitsPerPacket,  double? packetWeight,  String? packetDimensions,  String? packetType,  String? material,  String? sealingMethod,  bool includeTamperEvidence,  bool includeChildSafety,  bool includeInstructions,  String? color,  String? printingDetails,  bool generatePacketBarcode,  bool generatePacketQrCode)  $default,) {final _that = this;
switch (_that) {
case _PacketCodeGenerationRequest():
return $default(_that.factoryId,_that.subscriptionPlanId,_that.count,_that.prefix,_that.startSequence,_that.includeInternationalCodes,_that.generateQrCodes,_that.generateBarcodes,_that.batchName,_that.batchNotes,_that.metadata,_that.cartonCode,_that.unitsPerPacket,_that.packetWeight,_that.packetDimensions,_that.packetType,_that.material,_that.sealingMethod,_that.includeTamperEvidence,_that.includeChildSafety,_that.includeInstructions,_that.color,_that.printingDetails,_that.generatePacketBarcode,_that.generatePacketQrCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String factoryId,  String subscriptionPlanId,  int count,  String prefix,  int startSequence,  bool includeInternationalCodes,  bool generateQrCodes,  bool generateBarcodes,  String? batchName,  String? batchNotes,  String? metadata,  String cartonCode,  int unitsPerPacket,  double? packetWeight,  String? packetDimensions,  String? packetType,  String? material,  String? sealingMethod,  bool includeTamperEvidence,  bool includeChildSafety,  bool includeInstructions,  String? color,  String? printingDetails,  bool generatePacketBarcode,  bool generatePacketQrCode)?  $default,) {final _that = this;
switch (_that) {
case _PacketCodeGenerationRequest() when $default != null:
return $default(_that.factoryId,_that.subscriptionPlanId,_that.count,_that.prefix,_that.startSequence,_that.includeInternationalCodes,_that.generateQrCodes,_that.generateBarcodes,_that.batchName,_that.batchNotes,_that.metadata,_that.cartonCode,_that.unitsPerPacket,_that.packetWeight,_that.packetDimensions,_that.packetType,_that.material,_that.sealingMethod,_that.includeTamperEvidence,_that.includeChildSafety,_that.includeInstructions,_that.color,_that.printingDetails,_that.generatePacketBarcode,_that.generatePacketQrCode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PacketCodeGenerationRequest implements PacketCodeGenerationRequest {
  const _PacketCodeGenerationRequest({required this.factoryId, required this.subscriptionPlanId, required this.count, required this.prefix, this.startSequence = 1, this.includeInternationalCodes = true, this.generateQrCodes = true, this.generateBarcodes = true, this.batchName, this.batchNotes, this.metadata, required this.cartonCode, required this.unitsPerPacket, this.packetWeight, this.packetDimensions, this.packetType, this.material, this.sealingMethod, this.includeTamperEvidence = false, this.includeChildSafety = false, this.includeInstructions = true, this.color, this.printingDetails, this.generatePacketBarcode = true, this.generatePacketQrCode = true});
  factory _PacketCodeGenerationRequest.fromJson(Map<String, dynamic> json) => _$PacketCodeGenerationRequestFromJson(json);

/// Base request parameters
@override final  String factoryId;
@override final  String subscriptionPlanId;
@override final  int count;
@override final  String prefix;
@override@JsonKey() final  int startSequence;
@override@JsonKey() final  bool includeInternationalCodes;
@override@JsonKey() final  bool generateQrCodes;
@override@JsonKey() final  bool generateBarcodes;
@override final  String? batchName;
@override final  String? batchNotes;
@override final  String? metadata;
/// Packet-specific parameters
/// Carton code that will contain these packets
@override final  String cartonCode;
/// Number of units per packet
@override final  int unitsPerPacket;
/// Packet weight in grams (optional)
@override final  double? packetWeight;
/// Packet dimensions (length x width x height in cm)
@override final  String? packetDimensions;
/// Packet type (e.g., "Blister", "Box", "Pouch", "Bottle")
@override final  String? packetType;
/// Packet material (e.g., "Plastic", "Paper", "Aluminum")
@override final  String? material;
/// Sealing method (e.g., "Heat Seal", "Adhesive", "Clip")
@override final  String? sealingMethod;
/// Should include tamper evidence?
@override@JsonKey() final  bool includeTamperEvidence;
/// Should include child safety features?
@override@JsonKey() final  bool includeChildSafety;
/// Should include instructions?
@override@JsonKey() final  bool includeInstructions;
/// Packet color
@override final  String? color;
/// Printing details
@override final  String? printingDetails;
/// Should generate separate packet barcode?
@override@JsonKey() final  bool generatePacketBarcode;
/// Should generate separate packet QR code?
@override@JsonKey() final  bool generatePacketQrCode;

/// Create a copy of PacketCodeGenerationRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PacketCodeGenerationRequestCopyWith<_PacketCodeGenerationRequest> get copyWith => __$PacketCodeGenerationRequestCopyWithImpl<_PacketCodeGenerationRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PacketCodeGenerationRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PacketCodeGenerationRequest&&(identical(other.factoryId, factoryId) || other.factoryId == factoryId)&&(identical(other.subscriptionPlanId, subscriptionPlanId) || other.subscriptionPlanId == subscriptionPlanId)&&(identical(other.count, count) || other.count == count)&&(identical(other.prefix, prefix) || other.prefix == prefix)&&(identical(other.startSequence, startSequence) || other.startSequence == startSequence)&&(identical(other.includeInternationalCodes, includeInternationalCodes) || other.includeInternationalCodes == includeInternationalCodes)&&(identical(other.generateQrCodes, generateQrCodes) || other.generateQrCodes == generateQrCodes)&&(identical(other.generateBarcodes, generateBarcodes) || other.generateBarcodes == generateBarcodes)&&(identical(other.batchName, batchName) || other.batchName == batchName)&&(identical(other.batchNotes, batchNotes) || other.batchNotes == batchNotes)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.cartonCode, cartonCode) || other.cartonCode == cartonCode)&&(identical(other.unitsPerPacket, unitsPerPacket) || other.unitsPerPacket == unitsPerPacket)&&(identical(other.packetWeight, packetWeight) || other.packetWeight == packetWeight)&&(identical(other.packetDimensions, packetDimensions) || other.packetDimensions == packetDimensions)&&(identical(other.packetType, packetType) || other.packetType == packetType)&&(identical(other.material, material) || other.material == material)&&(identical(other.sealingMethod, sealingMethod) || other.sealingMethod == sealingMethod)&&(identical(other.includeTamperEvidence, includeTamperEvidence) || other.includeTamperEvidence == includeTamperEvidence)&&(identical(other.includeChildSafety, includeChildSafety) || other.includeChildSafety == includeChildSafety)&&(identical(other.includeInstructions, includeInstructions) || other.includeInstructions == includeInstructions)&&(identical(other.color, color) || other.color == color)&&(identical(other.printingDetails, printingDetails) || other.printingDetails == printingDetails)&&(identical(other.generatePacketBarcode, generatePacketBarcode) || other.generatePacketBarcode == generatePacketBarcode)&&(identical(other.generatePacketQrCode, generatePacketQrCode) || other.generatePacketQrCode == generatePacketQrCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,factoryId,subscriptionPlanId,count,prefix,startSequence,includeInternationalCodes,generateQrCodes,generateBarcodes,batchName,batchNotes,metadata,cartonCode,unitsPerPacket,packetWeight,packetDimensions,packetType,material,sealingMethod,includeTamperEvidence,includeChildSafety,includeInstructions,color,printingDetails,generatePacketBarcode,generatePacketQrCode]);

@override
String toString() {
  return 'PacketCodeGenerationRequest(factoryId: $factoryId, subscriptionPlanId: $subscriptionPlanId, count: $count, prefix: $prefix, startSequence: $startSequence, includeInternationalCodes: $includeInternationalCodes, generateQrCodes: $generateQrCodes, generateBarcodes: $generateBarcodes, batchName: $batchName, batchNotes: $batchNotes, metadata: $metadata, cartonCode: $cartonCode, unitsPerPacket: $unitsPerPacket, packetWeight: $packetWeight, packetDimensions: $packetDimensions, packetType: $packetType, material: $material, sealingMethod: $sealingMethod, includeTamperEvidence: $includeTamperEvidence, includeChildSafety: $includeChildSafety, includeInstructions: $includeInstructions, color: $color, printingDetails: $printingDetails, generatePacketBarcode: $generatePacketBarcode, generatePacketQrCode: $generatePacketQrCode)';
}


}

/// @nodoc
abstract mixin class _$PacketCodeGenerationRequestCopyWith<$Res> implements $PacketCodeGenerationRequestCopyWith<$Res> {
  factory _$PacketCodeGenerationRequestCopyWith(_PacketCodeGenerationRequest value, $Res Function(_PacketCodeGenerationRequest) _then) = __$PacketCodeGenerationRequestCopyWithImpl;
@override @useResult
$Res call({
 String factoryId, String subscriptionPlanId, int count, String prefix, int startSequence, bool includeInternationalCodes, bool generateQrCodes, bool generateBarcodes, String? batchName, String? batchNotes, String? metadata, String cartonCode, int unitsPerPacket, double? packetWeight, String? packetDimensions, String? packetType, String? material, String? sealingMethod, bool includeTamperEvidence, bool includeChildSafety, bool includeInstructions, String? color, String? printingDetails, bool generatePacketBarcode, bool generatePacketQrCode
});




}
/// @nodoc
class __$PacketCodeGenerationRequestCopyWithImpl<$Res>
    implements _$PacketCodeGenerationRequestCopyWith<$Res> {
  __$PacketCodeGenerationRequestCopyWithImpl(this._self, this._then);

  final _PacketCodeGenerationRequest _self;
  final $Res Function(_PacketCodeGenerationRequest) _then;

/// Create a copy of PacketCodeGenerationRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? factoryId = null,Object? subscriptionPlanId = null,Object? count = null,Object? prefix = null,Object? startSequence = null,Object? includeInternationalCodes = null,Object? generateQrCodes = null,Object? generateBarcodes = null,Object? batchName = freezed,Object? batchNotes = freezed,Object? metadata = freezed,Object? cartonCode = null,Object? unitsPerPacket = null,Object? packetWeight = freezed,Object? packetDimensions = freezed,Object? packetType = freezed,Object? material = freezed,Object? sealingMethod = freezed,Object? includeTamperEvidence = null,Object? includeChildSafety = null,Object? includeInstructions = null,Object? color = freezed,Object? printingDetails = freezed,Object? generatePacketBarcode = null,Object? generatePacketQrCode = null,}) {
  return _then(_PacketCodeGenerationRequest(
factoryId: null == factoryId ? _self.factoryId : factoryId // ignore: cast_nullable_to_non_nullable
as String,subscriptionPlanId: null == subscriptionPlanId ? _self.subscriptionPlanId : subscriptionPlanId // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,prefix: null == prefix ? _self.prefix : prefix // ignore: cast_nullable_to_non_nullable
as String,startSequence: null == startSequence ? _self.startSequence : startSequence // ignore: cast_nullable_to_non_nullable
as int,includeInternationalCodes: null == includeInternationalCodes ? _self.includeInternationalCodes : includeInternationalCodes // ignore: cast_nullable_to_non_nullable
as bool,generateQrCodes: null == generateQrCodes ? _self.generateQrCodes : generateQrCodes // ignore: cast_nullable_to_non_nullable
as bool,generateBarcodes: null == generateBarcodes ? _self.generateBarcodes : generateBarcodes // ignore: cast_nullable_to_non_nullable
as bool,batchName: freezed == batchName ? _self.batchName : batchName // ignore: cast_nullable_to_non_nullable
as String?,batchNotes: freezed == batchNotes ? _self.batchNotes : batchNotes // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as String?,cartonCode: null == cartonCode ? _self.cartonCode : cartonCode // ignore: cast_nullable_to_non_nullable
as String,unitsPerPacket: null == unitsPerPacket ? _self.unitsPerPacket : unitsPerPacket // ignore: cast_nullable_to_non_nullable
as int,packetWeight: freezed == packetWeight ? _self.packetWeight : packetWeight // ignore: cast_nullable_to_non_nullable
as double?,packetDimensions: freezed == packetDimensions ? _self.packetDimensions : packetDimensions // ignore: cast_nullable_to_non_nullable
as String?,packetType: freezed == packetType ? _self.packetType : packetType // ignore: cast_nullable_to_non_nullable
as String?,material: freezed == material ? _self.material : material // ignore: cast_nullable_to_non_nullable
as String?,sealingMethod: freezed == sealingMethod ? _self.sealingMethod : sealingMethod // ignore: cast_nullable_to_non_nullable
as String?,includeTamperEvidence: null == includeTamperEvidence ? _self.includeTamperEvidence : includeTamperEvidence // ignore: cast_nullable_to_non_nullable
as bool,includeChildSafety: null == includeChildSafety ? _self.includeChildSafety : includeChildSafety // ignore: cast_nullable_to_non_nullable
as bool,includeInstructions: null == includeInstructions ? _self.includeInstructions : includeInstructions // ignore: cast_nullable_to_non_nullable
as bool,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,printingDetails: freezed == printingDetails ? _self.printingDetails : printingDetails // ignore: cast_nullable_to_non_nullable
as String?,generatePacketBarcode: null == generatePacketBarcode ? _self.generatePacketBarcode : generatePacketBarcode // ignore: cast_nullable_to_non_nullable
as bool,generatePacketQrCode: null == generatePacketQrCode ? _self.generatePacketQrCode : generatePacketQrCode // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$UnitCodeGenerationRequest {

/// Base request parameters
 String get factoryId; String get subscriptionPlanId; int get count; String get prefix; int get startSequence; bool get includeInternationalCodes;// Usually false for units
 bool get generateQrCodes; bool get generateBarcodes; String? get batchName; String? get batchNotes; String? get metadata;/// Unit-specific parameters
/// Packet code that will contain these units
 String get packetCode;/// Authentication code algorithm
 String get authenticationAlgorithm;/// Authentication code length
 int get authenticationCodeLength;/// Should include master authentication codes?
 bool get includeMasterCodes;/// Number of units per master code
 int get unitsPerMasterCode;/// Unit model/variant
 String? get model;/// Unit color
 String? get color;/// Unit size
 String? get size;/// Unit weight in grams
 double? get unitWeight;/// Unit dimensions (length x width x height in cm)
 String? get unitDimensions;/// Unit condition
 String get condition;/// Unit grade/quality
 String? get grade;/// Should include warranty card?
 bool get includeWarrantyCard;/// Should include user manual?
 bool get includeUserManual;/// Should include accessories?
 bool get includeAccessories;/// Accessories list (JSON string)
 String? get accessoriesList;/// Special features (JSON string)
 String? get specialFeatures;/// Safety certifications (JSON string)
 String? get safetyCertifications;/// Compliance standards (JSON string)
 String? get complianceStandards;
/// Create a copy of UnitCodeGenerationRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnitCodeGenerationRequestCopyWith<UnitCodeGenerationRequest> get copyWith => _$UnitCodeGenerationRequestCopyWithImpl<UnitCodeGenerationRequest>(this as UnitCodeGenerationRequest, _$identity);

  /// Serializes this UnitCodeGenerationRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnitCodeGenerationRequest&&(identical(other.factoryId, factoryId) || other.factoryId == factoryId)&&(identical(other.subscriptionPlanId, subscriptionPlanId) || other.subscriptionPlanId == subscriptionPlanId)&&(identical(other.count, count) || other.count == count)&&(identical(other.prefix, prefix) || other.prefix == prefix)&&(identical(other.startSequence, startSequence) || other.startSequence == startSequence)&&(identical(other.includeInternationalCodes, includeInternationalCodes) || other.includeInternationalCodes == includeInternationalCodes)&&(identical(other.generateQrCodes, generateQrCodes) || other.generateQrCodes == generateQrCodes)&&(identical(other.generateBarcodes, generateBarcodes) || other.generateBarcodes == generateBarcodes)&&(identical(other.batchName, batchName) || other.batchName == batchName)&&(identical(other.batchNotes, batchNotes) || other.batchNotes == batchNotes)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.packetCode, packetCode) || other.packetCode == packetCode)&&(identical(other.authenticationAlgorithm, authenticationAlgorithm) || other.authenticationAlgorithm == authenticationAlgorithm)&&(identical(other.authenticationCodeLength, authenticationCodeLength) || other.authenticationCodeLength == authenticationCodeLength)&&(identical(other.includeMasterCodes, includeMasterCodes) || other.includeMasterCodes == includeMasterCodes)&&(identical(other.unitsPerMasterCode, unitsPerMasterCode) || other.unitsPerMasterCode == unitsPerMasterCode)&&(identical(other.model, model) || other.model == model)&&(identical(other.color, color) || other.color == color)&&(identical(other.size, size) || other.size == size)&&(identical(other.unitWeight, unitWeight) || other.unitWeight == unitWeight)&&(identical(other.unitDimensions, unitDimensions) || other.unitDimensions == unitDimensions)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.includeWarrantyCard, includeWarrantyCard) || other.includeWarrantyCard == includeWarrantyCard)&&(identical(other.includeUserManual, includeUserManual) || other.includeUserManual == includeUserManual)&&(identical(other.includeAccessories, includeAccessories) || other.includeAccessories == includeAccessories)&&(identical(other.accessoriesList, accessoriesList) || other.accessoriesList == accessoriesList)&&(identical(other.specialFeatures, specialFeatures) || other.specialFeatures == specialFeatures)&&(identical(other.safetyCertifications, safetyCertifications) || other.safetyCertifications == safetyCertifications)&&(identical(other.complianceStandards, complianceStandards) || other.complianceStandards == complianceStandards));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,factoryId,subscriptionPlanId,count,prefix,startSequence,includeInternationalCodes,generateQrCodes,generateBarcodes,batchName,batchNotes,metadata,packetCode,authenticationAlgorithm,authenticationCodeLength,includeMasterCodes,unitsPerMasterCode,model,color,size,unitWeight,unitDimensions,condition,grade,includeWarrantyCard,includeUserManual,includeAccessories,accessoriesList,specialFeatures,safetyCertifications,complianceStandards]);

@override
String toString() {
  return 'UnitCodeGenerationRequest(factoryId: $factoryId, subscriptionPlanId: $subscriptionPlanId, count: $count, prefix: $prefix, startSequence: $startSequence, includeInternationalCodes: $includeInternationalCodes, generateQrCodes: $generateQrCodes, generateBarcodes: $generateBarcodes, batchName: $batchName, batchNotes: $batchNotes, metadata: $metadata, packetCode: $packetCode, authenticationAlgorithm: $authenticationAlgorithm, authenticationCodeLength: $authenticationCodeLength, includeMasterCodes: $includeMasterCodes, unitsPerMasterCode: $unitsPerMasterCode, model: $model, color: $color, size: $size, unitWeight: $unitWeight, unitDimensions: $unitDimensions, condition: $condition, grade: $grade, includeWarrantyCard: $includeWarrantyCard, includeUserManual: $includeUserManual, includeAccessories: $includeAccessories, accessoriesList: $accessoriesList, specialFeatures: $specialFeatures, safetyCertifications: $safetyCertifications, complianceStandards: $complianceStandards)';
}


}

/// @nodoc
abstract mixin class $UnitCodeGenerationRequestCopyWith<$Res>  {
  factory $UnitCodeGenerationRequestCopyWith(UnitCodeGenerationRequest value, $Res Function(UnitCodeGenerationRequest) _then) = _$UnitCodeGenerationRequestCopyWithImpl;
@useResult
$Res call({
 String factoryId, String subscriptionPlanId, int count, String prefix, int startSequence, bool includeInternationalCodes, bool generateQrCodes, bool generateBarcodes, String? batchName, String? batchNotes, String? metadata, String packetCode, String authenticationAlgorithm, int authenticationCodeLength, bool includeMasterCodes, int unitsPerMasterCode, String? model, String? color, String? size, double? unitWeight, String? unitDimensions, String condition, String? grade, bool includeWarrantyCard, bool includeUserManual, bool includeAccessories, String? accessoriesList, String? specialFeatures, String? safetyCertifications, String? complianceStandards
});




}
/// @nodoc
class _$UnitCodeGenerationRequestCopyWithImpl<$Res>
    implements $UnitCodeGenerationRequestCopyWith<$Res> {
  _$UnitCodeGenerationRequestCopyWithImpl(this._self, this._then);

  final UnitCodeGenerationRequest _self;
  final $Res Function(UnitCodeGenerationRequest) _then;

/// Create a copy of UnitCodeGenerationRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? factoryId = null,Object? subscriptionPlanId = null,Object? count = null,Object? prefix = null,Object? startSequence = null,Object? includeInternationalCodes = null,Object? generateQrCodes = null,Object? generateBarcodes = null,Object? batchName = freezed,Object? batchNotes = freezed,Object? metadata = freezed,Object? packetCode = null,Object? authenticationAlgorithm = null,Object? authenticationCodeLength = null,Object? includeMasterCodes = null,Object? unitsPerMasterCode = null,Object? model = freezed,Object? color = freezed,Object? size = freezed,Object? unitWeight = freezed,Object? unitDimensions = freezed,Object? condition = null,Object? grade = freezed,Object? includeWarrantyCard = null,Object? includeUserManual = null,Object? includeAccessories = null,Object? accessoriesList = freezed,Object? specialFeatures = freezed,Object? safetyCertifications = freezed,Object? complianceStandards = freezed,}) {
  return _then(_self.copyWith(
factoryId: null == factoryId ? _self.factoryId : factoryId // ignore: cast_nullable_to_non_nullable
as String,subscriptionPlanId: null == subscriptionPlanId ? _self.subscriptionPlanId : subscriptionPlanId // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,prefix: null == prefix ? _self.prefix : prefix // ignore: cast_nullable_to_non_nullable
as String,startSequence: null == startSequence ? _self.startSequence : startSequence // ignore: cast_nullable_to_non_nullable
as int,includeInternationalCodes: null == includeInternationalCodes ? _self.includeInternationalCodes : includeInternationalCodes // ignore: cast_nullable_to_non_nullable
as bool,generateQrCodes: null == generateQrCodes ? _self.generateQrCodes : generateQrCodes // ignore: cast_nullable_to_non_nullable
as bool,generateBarcodes: null == generateBarcodes ? _self.generateBarcodes : generateBarcodes // ignore: cast_nullable_to_non_nullable
as bool,batchName: freezed == batchName ? _self.batchName : batchName // ignore: cast_nullable_to_non_nullable
as String?,batchNotes: freezed == batchNotes ? _self.batchNotes : batchNotes // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as String?,packetCode: null == packetCode ? _self.packetCode : packetCode // ignore: cast_nullable_to_non_nullable
as String,authenticationAlgorithm: null == authenticationAlgorithm ? _self.authenticationAlgorithm : authenticationAlgorithm // ignore: cast_nullable_to_non_nullable
as String,authenticationCodeLength: null == authenticationCodeLength ? _self.authenticationCodeLength : authenticationCodeLength // ignore: cast_nullable_to_non_nullable
as int,includeMasterCodes: null == includeMasterCodes ? _self.includeMasterCodes : includeMasterCodes // ignore: cast_nullable_to_non_nullable
as bool,unitsPerMasterCode: null == unitsPerMasterCode ? _self.unitsPerMasterCode : unitsPerMasterCode // ignore: cast_nullable_to_non_nullable
as int,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String?,unitWeight: freezed == unitWeight ? _self.unitWeight : unitWeight // ignore: cast_nullable_to_non_nullable
as double?,unitDimensions: freezed == unitDimensions ? _self.unitDimensions : unitDimensions // ignore: cast_nullable_to_non_nullable
as String?,condition: null == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as String,grade: freezed == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as String?,includeWarrantyCard: null == includeWarrantyCard ? _self.includeWarrantyCard : includeWarrantyCard // ignore: cast_nullable_to_non_nullable
as bool,includeUserManual: null == includeUserManual ? _self.includeUserManual : includeUserManual // ignore: cast_nullable_to_non_nullable
as bool,includeAccessories: null == includeAccessories ? _self.includeAccessories : includeAccessories // ignore: cast_nullable_to_non_nullable
as bool,accessoriesList: freezed == accessoriesList ? _self.accessoriesList : accessoriesList // ignore: cast_nullable_to_non_nullable
as String?,specialFeatures: freezed == specialFeatures ? _self.specialFeatures : specialFeatures // ignore: cast_nullable_to_non_nullable
as String?,safetyCertifications: freezed == safetyCertifications ? _self.safetyCertifications : safetyCertifications // ignore: cast_nullable_to_non_nullable
as String?,complianceStandards: freezed == complianceStandards ? _self.complianceStandards : complianceStandards // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UnitCodeGenerationRequest].
extension UnitCodeGenerationRequestPatterns on UnitCodeGenerationRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UnitCodeGenerationRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UnitCodeGenerationRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UnitCodeGenerationRequest value)  $default,){
final _that = this;
switch (_that) {
case _UnitCodeGenerationRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UnitCodeGenerationRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UnitCodeGenerationRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String factoryId,  String subscriptionPlanId,  int count,  String prefix,  int startSequence,  bool includeInternationalCodes,  bool generateQrCodes,  bool generateBarcodes,  String? batchName,  String? batchNotes,  String? metadata,  String packetCode,  String authenticationAlgorithm,  int authenticationCodeLength,  bool includeMasterCodes,  int unitsPerMasterCode,  String? model,  String? color,  String? size,  double? unitWeight,  String? unitDimensions,  String condition,  String? grade,  bool includeWarrantyCard,  bool includeUserManual,  bool includeAccessories,  String? accessoriesList,  String? specialFeatures,  String? safetyCertifications,  String? complianceStandards)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UnitCodeGenerationRequest() when $default != null:
return $default(_that.factoryId,_that.subscriptionPlanId,_that.count,_that.prefix,_that.startSequence,_that.includeInternationalCodes,_that.generateQrCodes,_that.generateBarcodes,_that.batchName,_that.batchNotes,_that.metadata,_that.packetCode,_that.authenticationAlgorithm,_that.authenticationCodeLength,_that.includeMasterCodes,_that.unitsPerMasterCode,_that.model,_that.color,_that.size,_that.unitWeight,_that.unitDimensions,_that.condition,_that.grade,_that.includeWarrantyCard,_that.includeUserManual,_that.includeAccessories,_that.accessoriesList,_that.specialFeatures,_that.safetyCertifications,_that.complianceStandards);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String factoryId,  String subscriptionPlanId,  int count,  String prefix,  int startSequence,  bool includeInternationalCodes,  bool generateQrCodes,  bool generateBarcodes,  String? batchName,  String? batchNotes,  String? metadata,  String packetCode,  String authenticationAlgorithm,  int authenticationCodeLength,  bool includeMasterCodes,  int unitsPerMasterCode,  String? model,  String? color,  String? size,  double? unitWeight,  String? unitDimensions,  String condition,  String? grade,  bool includeWarrantyCard,  bool includeUserManual,  bool includeAccessories,  String? accessoriesList,  String? specialFeatures,  String? safetyCertifications,  String? complianceStandards)  $default,) {final _that = this;
switch (_that) {
case _UnitCodeGenerationRequest():
return $default(_that.factoryId,_that.subscriptionPlanId,_that.count,_that.prefix,_that.startSequence,_that.includeInternationalCodes,_that.generateQrCodes,_that.generateBarcodes,_that.batchName,_that.batchNotes,_that.metadata,_that.packetCode,_that.authenticationAlgorithm,_that.authenticationCodeLength,_that.includeMasterCodes,_that.unitsPerMasterCode,_that.model,_that.color,_that.size,_that.unitWeight,_that.unitDimensions,_that.condition,_that.grade,_that.includeWarrantyCard,_that.includeUserManual,_that.includeAccessories,_that.accessoriesList,_that.specialFeatures,_that.safetyCertifications,_that.complianceStandards);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String factoryId,  String subscriptionPlanId,  int count,  String prefix,  int startSequence,  bool includeInternationalCodes,  bool generateQrCodes,  bool generateBarcodes,  String? batchName,  String? batchNotes,  String? metadata,  String packetCode,  String authenticationAlgorithm,  int authenticationCodeLength,  bool includeMasterCodes,  int unitsPerMasterCode,  String? model,  String? color,  String? size,  double? unitWeight,  String? unitDimensions,  String condition,  String? grade,  bool includeWarrantyCard,  bool includeUserManual,  bool includeAccessories,  String? accessoriesList,  String? specialFeatures,  String? safetyCertifications,  String? complianceStandards)?  $default,) {final _that = this;
switch (_that) {
case _UnitCodeGenerationRequest() when $default != null:
return $default(_that.factoryId,_that.subscriptionPlanId,_that.count,_that.prefix,_that.startSequence,_that.includeInternationalCodes,_that.generateQrCodes,_that.generateBarcodes,_that.batchName,_that.batchNotes,_that.metadata,_that.packetCode,_that.authenticationAlgorithm,_that.authenticationCodeLength,_that.includeMasterCodes,_that.unitsPerMasterCode,_that.model,_that.color,_that.size,_that.unitWeight,_that.unitDimensions,_that.condition,_that.grade,_that.includeWarrantyCard,_that.includeUserManual,_that.includeAccessories,_that.accessoriesList,_that.specialFeatures,_that.safetyCertifications,_that.complianceStandards);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UnitCodeGenerationRequest implements UnitCodeGenerationRequest {
  const _UnitCodeGenerationRequest({required this.factoryId, required this.subscriptionPlanId, required this.count, required this.prefix, this.startSequence = 1, this.includeInternationalCodes = false, this.generateQrCodes = true, this.generateBarcodes = true, this.batchName, this.batchNotes, this.metadata, required this.packetCode, this.authenticationAlgorithm = 'secure_random', this.authenticationCodeLength = 16, this.includeMasterCodes = true, this.unitsPerMasterCode = 100, this.model, this.color, this.size, this.unitWeight, this.unitDimensions, this.condition = 'New', this.grade, this.includeWarrantyCard = true, this.includeUserManual = true, this.includeAccessories = false, this.accessoriesList, this.specialFeatures, this.safetyCertifications, this.complianceStandards});
  factory _UnitCodeGenerationRequest.fromJson(Map<String, dynamic> json) => _$UnitCodeGenerationRequestFromJson(json);

/// Base request parameters
@override final  String factoryId;
@override final  String subscriptionPlanId;
@override final  int count;
@override final  String prefix;
@override@JsonKey() final  int startSequence;
@override@JsonKey() final  bool includeInternationalCodes;
// Usually false for units
@override@JsonKey() final  bool generateQrCodes;
@override@JsonKey() final  bool generateBarcodes;
@override final  String? batchName;
@override final  String? batchNotes;
@override final  String? metadata;
/// Unit-specific parameters
/// Packet code that will contain these units
@override final  String packetCode;
/// Authentication code algorithm
@override@JsonKey() final  String authenticationAlgorithm;
/// Authentication code length
@override@JsonKey() final  int authenticationCodeLength;
/// Should include master authentication codes?
@override@JsonKey() final  bool includeMasterCodes;
/// Number of units per master code
@override@JsonKey() final  int unitsPerMasterCode;
/// Unit model/variant
@override final  String? model;
/// Unit color
@override final  String? color;
/// Unit size
@override final  String? size;
/// Unit weight in grams
@override final  double? unitWeight;
/// Unit dimensions (length x width x height in cm)
@override final  String? unitDimensions;
/// Unit condition
@override@JsonKey() final  String condition;
/// Unit grade/quality
@override final  String? grade;
/// Should include warranty card?
@override@JsonKey() final  bool includeWarrantyCard;
/// Should include user manual?
@override@JsonKey() final  bool includeUserManual;
/// Should include accessories?
@override@JsonKey() final  bool includeAccessories;
/// Accessories list (JSON string)
@override final  String? accessoriesList;
/// Special features (JSON string)
@override final  String? specialFeatures;
/// Safety certifications (JSON string)
@override final  String? safetyCertifications;
/// Compliance standards (JSON string)
@override final  String? complianceStandards;

/// Create a copy of UnitCodeGenerationRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnitCodeGenerationRequestCopyWith<_UnitCodeGenerationRequest> get copyWith => __$UnitCodeGenerationRequestCopyWithImpl<_UnitCodeGenerationRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UnitCodeGenerationRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnitCodeGenerationRequest&&(identical(other.factoryId, factoryId) || other.factoryId == factoryId)&&(identical(other.subscriptionPlanId, subscriptionPlanId) || other.subscriptionPlanId == subscriptionPlanId)&&(identical(other.count, count) || other.count == count)&&(identical(other.prefix, prefix) || other.prefix == prefix)&&(identical(other.startSequence, startSequence) || other.startSequence == startSequence)&&(identical(other.includeInternationalCodes, includeInternationalCodes) || other.includeInternationalCodes == includeInternationalCodes)&&(identical(other.generateQrCodes, generateQrCodes) || other.generateQrCodes == generateQrCodes)&&(identical(other.generateBarcodes, generateBarcodes) || other.generateBarcodes == generateBarcodes)&&(identical(other.batchName, batchName) || other.batchName == batchName)&&(identical(other.batchNotes, batchNotes) || other.batchNotes == batchNotes)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.packetCode, packetCode) || other.packetCode == packetCode)&&(identical(other.authenticationAlgorithm, authenticationAlgorithm) || other.authenticationAlgorithm == authenticationAlgorithm)&&(identical(other.authenticationCodeLength, authenticationCodeLength) || other.authenticationCodeLength == authenticationCodeLength)&&(identical(other.includeMasterCodes, includeMasterCodes) || other.includeMasterCodes == includeMasterCodes)&&(identical(other.unitsPerMasterCode, unitsPerMasterCode) || other.unitsPerMasterCode == unitsPerMasterCode)&&(identical(other.model, model) || other.model == model)&&(identical(other.color, color) || other.color == color)&&(identical(other.size, size) || other.size == size)&&(identical(other.unitWeight, unitWeight) || other.unitWeight == unitWeight)&&(identical(other.unitDimensions, unitDimensions) || other.unitDimensions == unitDimensions)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.includeWarrantyCard, includeWarrantyCard) || other.includeWarrantyCard == includeWarrantyCard)&&(identical(other.includeUserManual, includeUserManual) || other.includeUserManual == includeUserManual)&&(identical(other.includeAccessories, includeAccessories) || other.includeAccessories == includeAccessories)&&(identical(other.accessoriesList, accessoriesList) || other.accessoriesList == accessoriesList)&&(identical(other.specialFeatures, specialFeatures) || other.specialFeatures == specialFeatures)&&(identical(other.safetyCertifications, safetyCertifications) || other.safetyCertifications == safetyCertifications)&&(identical(other.complianceStandards, complianceStandards) || other.complianceStandards == complianceStandards));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,factoryId,subscriptionPlanId,count,prefix,startSequence,includeInternationalCodes,generateQrCodes,generateBarcodes,batchName,batchNotes,metadata,packetCode,authenticationAlgorithm,authenticationCodeLength,includeMasterCodes,unitsPerMasterCode,model,color,size,unitWeight,unitDimensions,condition,grade,includeWarrantyCard,includeUserManual,includeAccessories,accessoriesList,specialFeatures,safetyCertifications,complianceStandards]);

@override
String toString() {
  return 'UnitCodeGenerationRequest(factoryId: $factoryId, subscriptionPlanId: $subscriptionPlanId, count: $count, prefix: $prefix, startSequence: $startSequence, includeInternationalCodes: $includeInternationalCodes, generateQrCodes: $generateQrCodes, generateBarcodes: $generateBarcodes, batchName: $batchName, batchNotes: $batchNotes, metadata: $metadata, packetCode: $packetCode, authenticationAlgorithm: $authenticationAlgorithm, authenticationCodeLength: $authenticationCodeLength, includeMasterCodes: $includeMasterCodes, unitsPerMasterCode: $unitsPerMasterCode, model: $model, color: $color, size: $size, unitWeight: $unitWeight, unitDimensions: $unitDimensions, condition: $condition, grade: $grade, includeWarrantyCard: $includeWarrantyCard, includeUserManual: $includeUserManual, includeAccessories: $includeAccessories, accessoriesList: $accessoriesList, specialFeatures: $specialFeatures, safetyCertifications: $safetyCertifications, complianceStandards: $complianceStandards)';
}


}

/// @nodoc
abstract mixin class _$UnitCodeGenerationRequestCopyWith<$Res> implements $UnitCodeGenerationRequestCopyWith<$Res> {
  factory _$UnitCodeGenerationRequestCopyWith(_UnitCodeGenerationRequest value, $Res Function(_UnitCodeGenerationRequest) _then) = __$UnitCodeGenerationRequestCopyWithImpl;
@override @useResult
$Res call({
 String factoryId, String subscriptionPlanId, int count, String prefix, int startSequence, bool includeInternationalCodes, bool generateQrCodes, bool generateBarcodes, String? batchName, String? batchNotes, String? metadata, String packetCode, String authenticationAlgorithm, int authenticationCodeLength, bool includeMasterCodes, int unitsPerMasterCode, String? model, String? color, String? size, double? unitWeight, String? unitDimensions, String condition, String? grade, bool includeWarrantyCard, bool includeUserManual, bool includeAccessories, String? accessoriesList, String? specialFeatures, String? safetyCertifications, String? complianceStandards
});




}
/// @nodoc
class __$UnitCodeGenerationRequestCopyWithImpl<$Res>
    implements _$UnitCodeGenerationRequestCopyWith<$Res> {
  __$UnitCodeGenerationRequestCopyWithImpl(this._self, this._then);

  final _UnitCodeGenerationRequest _self;
  final $Res Function(_UnitCodeGenerationRequest) _then;

/// Create a copy of UnitCodeGenerationRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? factoryId = null,Object? subscriptionPlanId = null,Object? count = null,Object? prefix = null,Object? startSequence = null,Object? includeInternationalCodes = null,Object? generateQrCodes = null,Object? generateBarcodes = null,Object? batchName = freezed,Object? batchNotes = freezed,Object? metadata = freezed,Object? packetCode = null,Object? authenticationAlgorithm = null,Object? authenticationCodeLength = null,Object? includeMasterCodes = null,Object? unitsPerMasterCode = null,Object? model = freezed,Object? color = freezed,Object? size = freezed,Object? unitWeight = freezed,Object? unitDimensions = freezed,Object? condition = null,Object? grade = freezed,Object? includeWarrantyCard = null,Object? includeUserManual = null,Object? includeAccessories = null,Object? accessoriesList = freezed,Object? specialFeatures = freezed,Object? safetyCertifications = freezed,Object? complianceStandards = freezed,}) {
  return _then(_UnitCodeGenerationRequest(
factoryId: null == factoryId ? _self.factoryId : factoryId // ignore: cast_nullable_to_non_nullable
as String,subscriptionPlanId: null == subscriptionPlanId ? _self.subscriptionPlanId : subscriptionPlanId // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,prefix: null == prefix ? _self.prefix : prefix // ignore: cast_nullable_to_non_nullable
as String,startSequence: null == startSequence ? _self.startSequence : startSequence // ignore: cast_nullable_to_non_nullable
as int,includeInternationalCodes: null == includeInternationalCodes ? _self.includeInternationalCodes : includeInternationalCodes // ignore: cast_nullable_to_non_nullable
as bool,generateQrCodes: null == generateQrCodes ? _self.generateQrCodes : generateQrCodes // ignore: cast_nullable_to_non_nullable
as bool,generateBarcodes: null == generateBarcodes ? _self.generateBarcodes : generateBarcodes // ignore: cast_nullable_to_non_nullable
as bool,batchName: freezed == batchName ? _self.batchName : batchName // ignore: cast_nullable_to_non_nullable
as String?,batchNotes: freezed == batchNotes ? _self.batchNotes : batchNotes // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as String?,packetCode: null == packetCode ? _self.packetCode : packetCode // ignore: cast_nullable_to_non_nullable
as String,authenticationAlgorithm: null == authenticationAlgorithm ? _self.authenticationAlgorithm : authenticationAlgorithm // ignore: cast_nullable_to_non_nullable
as String,authenticationCodeLength: null == authenticationCodeLength ? _self.authenticationCodeLength : authenticationCodeLength // ignore: cast_nullable_to_non_nullable
as int,includeMasterCodes: null == includeMasterCodes ? _self.includeMasterCodes : includeMasterCodes // ignore: cast_nullable_to_non_nullable
as bool,unitsPerMasterCode: null == unitsPerMasterCode ? _self.unitsPerMasterCode : unitsPerMasterCode // ignore: cast_nullable_to_non_nullable
as int,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String?,unitWeight: freezed == unitWeight ? _self.unitWeight : unitWeight // ignore: cast_nullable_to_non_nullable
as double?,unitDimensions: freezed == unitDimensions ? _self.unitDimensions : unitDimensions // ignore: cast_nullable_to_non_nullable
as String?,condition: null == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as String,grade: freezed == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as String?,includeWarrantyCard: null == includeWarrantyCard ? _self.includeWarrantyCard : includeWarrantyCard // ignore: cast_nullable_to_non_nullable
as bool,includeUserManual: null == includeUserManual ? _self.includeUserManual : includeUserManual // ignore: cast_nullable_to_non_nullable
as bool,includeAccessories: null == includeAccessories ? _self.includeAccessories : includeAccessories // ignore: cast_nullable_to_non_nullable
as bool,accessoriesList: freezed == accessoriesList ? _self.accessoriesList : accessoriesList // ignore: cast_nullable_to_non_nullable
as String?,specialFeatures: freezed == specialFeatures ? _self.specialFeatures : specialFeatures // ignore: cast_nullable_to_non_nullable
as String?,safetyCertifications: freezed == safetyCertifications ? _self.safetyCertifications : safetyCertifications // ignore: cast_nullable_to_non_nullable
as String?,complianceStandards: freezed == complianceStandards ? _self.complianceStandards : complianceStandards // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$BatchCodeGenerationRequest {

/// Factory ID
 String get factoryId;/// Subscription plan ID
 String get subscriptionPlanId;/// Batch name
 String get batchName;/// Batch description
 String? get batchDescription;/// Bundle generation request (optional)
 BundleCodeGenerationRequest? get bundleRequest;/// Carton generation request (optional)
 CartonCodeGenerationRequest? get cartonRequest;/// Packet generation request (optional)
 PacketCodeGenerationRequest? get packetRequest;/// Unit generation request (optional)
 UnitCodeGenerationRequest? get unitRequest;/// Should generate hierarchical codes?
/// If true, will generate codes in hierarchy: Bundle -> Carton -> Packet -> Unit
 bool get generateHierarchical;/// Hierarchical configuration
/// Only used if generateHierarchical is true
 HierarchicalConfig? get hierarchicalConfig;
/// Create a copy of BatchCodeGenerationRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BatchCodeGenerationRequestCopyWith<BatchCodeGenerationRequest> get copyWith => _$BatchCodeGenerationRequestCopyWithImpl<BatchCodeGenerationRequest>(this as BatchCodeGenerationRequest, _$identity);

  /// Serializes this BatchCodeGenerationRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BatchCodeGenerationRequest&&(identical(other.factoryId, factoryId) || other.factoryId == factoryId)&&(identical(other.subscriptionPlanId, subscriptionPlanId) || other.subscriptionPlanId == subscriptionPlanId)&&(identical(other.batchName, batchName) || other.batchName == batchName)&&(identical(other.batchDescription, batchDescription) || other.batchDescription == batchDescription)&&(identical(other.bundleRequest, bundleRequest) || other.bundleRequest == bundleRequest)&&(identical(other.cartonRequest, cartonRequest) || other.cartonRequest == cartonRequest)&&(identical(other.packetRequest, packetRequest) || other.packetRequest == packetRequest)&&(identical(other.unitRequest, unitRequest) || other.unitRequest == unitRequest)&&(identical(other.generateHierarchical, generateHierarchical) || other.generateHierarchical == generateHierarchical)&&(identical(other.hierarchicalConfig, hierarchicalConfig) || other.hierarchicalConfig == hierarchicalConfig));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,factoryId,subscriptionPlanId,batchName,batchDescription,bundleRequest,cartonRequest,packetRequest,unitRequest,generateHierarchical,hierarchicalConfig);

@override
String toString() {
  return 'BatchCodeGenerationRequest(factoryId: $factoryId, subscriptionPlanId: $subscriptionPlanId, batchName: $batchName, batchDescription: $batchDescription, bundleRequest: $bundleRequest, cartonRequest: $cartonRequest, packetRequest: $packetRequest, unitRequest: $unitRequest, generateHierarchical: $generateHierarchical, hierarchicalConfig: $hierarchicalConfig)';
}


}

/// @nodoc
abstract mixin class $BatchCodeGenerationRequestCopyWith<$Res>  {
  factory $BatchCodeGenerationRequestCopyWith(BatchCodeGenerationRequest value, $Res Function(BatchCodeGenerationRequest) _then) = _$BatchCodeGenerationRequestCopyWithImpl;
@useResult
$Res call({
 String factoryId, String subscriptionPlanId, String batchName, String? batchDescription, BundleCodeGenerationRequest? bundleRequest, CartonCodeGenerationRequest? cartonRequest, PacketCodeGenerationRequest? packetRequest, UnitCodeGenerationRequest? unitRequest, bool generateHierarchical, HierarchicalConfig? hierarchicalConfig
});


$BundleCodeGenerationRequestCopyWith<$Res>? get bundleRequest;$CartonCodeGenerationRequestCopyWith<$Res>? get cartonRequest;$PacketCodeGenerationRequestCopyWith<$Res>? get packetRequest;$UnitCodeGenerationRequestCopyWith<$Res>? get unitRequest;$HierarchicalConfigCopyWith<$Res>? get hierarchicalConfig;

}
/// @nodoc
class _$BatchCodeGenerationRequestCopyWithImpl<$Res>
    implements $BatchCodeGenerationRequestCopyWith<$Res> {
  _$BatchCodeGenerationRequestCopyWithImpl(this._self, this._then);

  final BatchCodeGenerationRequest _self;
  final $Res Function(BatchCodeGenerationRequest) _then;

/// Create a copy of BatchCodeGenerationRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? factoryId = null,Object? subscriptionPlanId = null,Object? batchName = null,Object? batchDescription = freezed,Object? bundleRequest = freezed,Object? cartonRequest = freezed,Object? packetRequest = freezed,Object? unitRequest = freezed,Object? generateHierarchical = null,Object? hierarchicalConfig = freezed,}) {
  return _then(_self.copyWith(
factoryId: null == factoryId ? _self.factoryId : factoryId // ignore: cast_nullable_to_non_nullable
as String,subscriptionPlanId: null == subscriptionPlanId ? _self.subscriptionPlanId : subscriptionPlanId // ignore: cast_nullable_to_non_nullable
as String,batchName: null == batchName ? _self.batchName : batchName // ignore: cast_nullable_to_non_nullable
as String,batchDescription: freezed == batchDescription ? _self.batchDescription : batchDescription // ignore: cast_nullable_to_non_nullable
as String?,bundleRequest: freezed == bundleRequest ? _self.bundleRequest : bundleRequest // ignore: cast_nullable_to_non_nullable
as BundleCodeGenerationRequest?,cartonRequest: freezed == cartonRequest ? _self.cartonRequest : cartonRequest // ignore: cast_nullable_to_non_nullable
as CartonCodeGenerationRequest?,packetRequest: freezed == packetRequest ? _self.packetRequest : packetRequest // ignore: cast_nullable_to_non_nullable
as PacketCodeGenerationRequest?,unitRequest: freezed == unitRequest ? _self.unitRequest : unitRequest // ignore: cast_nullable_to_non_nullable
as UnitCodeGenerationRequest?,generateHierarchical: null == generateHierarchical ? _self.generateHierarchical : generateHierarchical // ignore: cast_nullable_to_non_nullable
as bool,hierarchicalConfig: freezed == hierarchicalConfig ? _self.hierarchicalConfig : hierarchicalConfig // ignore: cast_nullable_to_non_nullable
as HierarchicalConfig?,
  ));
}
/// Create a copy of BatchCodeGenerationRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BundleCodeGenerationRequestCopyWith<$Res>? get bundleRequest {
    if (_self.bundleRequest == null) {
    return null;
  }

  return $BundleCodeGenerationRequestCopyWith<$Res>(_self.bundleRequest!, (value) {
    return _then(_self.copyWith(bundleRequest: value));
  });
}/// Create a copy of BatchCodeGenerationRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CartonCodeGenerationRequestCopyWith<$Res>? get cartonRequest {
    if (_self.cartonRequest == null) {
    return null;
  }

  return $CartonCodeGenerationRequestCopyWith<$Res>(_self.cartonRequest!, (value) {
    return _then(_self.copyWith(cartonRequest: value));
  });
}/// Create a copy of BatchCodeGenerationRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PacketCodeGenerationRequestCopyWith<$Res>? get packetRequest {
    if (_self.packetRequest == null) {
    return null;
  }

  return $PacketCodeGenerationRequestCopyWith<$Res>(_self.packetRequest!, (value) {
    return _then(_self.copyWith(packetRequest: value));
  });
}/// Create a copy of BatchCodeGenerationRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UnitCodeGenerationRequestCopyWith<$Res>? get unitRequest {
    if (_self.unitRequest == null) {
    return null;
  }

  return $UnitCodeGenerationRequestCopyWith<$Res>(_self.unitRequest!, (value) {
    return _then(_self.copyWith(unitRequest: value));
  });
}/// Create a copy of BatchCodeGenerationRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HierarchicalConfigCopyWith<$Res>? get hierarchicalConfig {
    if (_self.hierarchicalConfig == null) {
    return null;
  }

  return $HierarchicalConfigCopyWith<$Res>(_self.hierarchicalConfig!, (value) {
    return _then(_self.copyWith(hierarchicalConfig: value));
  });
}
}


/// Adds pattern-matching-related methods to [BatchCodeGenerationRequest].
extension BatchCodeGenerationRequestPatterns on BatchCodeGenerationRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BatchCodeGenerationRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BatchCodeGenerationRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BatchCodeGenerationRequest value)  $default,){
final _that = this;
switch (_that) {
case _BatchCodeGenerationRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BatchCodeGenerationRequest value)?  $default,){
final _that = this;
switch (_that) {
case _BatchCodeGenerationRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String factoryId,  String subscriptionPlanId,  String batchName,  String? batchDescription,  BundleCodeGenerationRequest? bundleRequest,  CartonCodeGenerationRequest? cartonRequest,  PacketCodeGenerationRequest? packetRequest,  UnitCodeGenerationRequest? unitRequest,  bool generateHierarchical,  HierarchicalConfig? hierarchicalConfig)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BatchCodeGenerationRequest() when $default != null:
return $default(_that.factoryId,_that.subscriptionPlanId,_that.batchName,_that.batchDescription,_that.bundleRequest,_that.cartonRequest,_that.packetRequest,_that.unitRequest,_that.generateHierarchical,_that.hierarchicalConfig);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String factoryId,  String subscriptionPlanId,  String batchName,  String? batchDescription,  BundleCodeGenerationRequest? bundleRequest,  CartonCodeGenerationRequest? cartonRequest,  PacketCodeGenerationRequest? packetRequest,  UnitCodeGenerationRequest? unitRequest,  bool generateHierarchical,  HierarchicalConfig? hierarchicalConfig)  $default,) {final _that = this;
switch (_that) {
case _BatchCodeGenerationRequest():
return $default(_that.factoryId,_that.subscriptionPlanId,_that.batchName,_that.batchDescription,_that.bundleRequest,_that.cartonRequest,_that.packetRequest,_that.unitRequest,_that.generateHierarchical,_that.hierarchicalConfig);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String factoryId,  String subscriptionPlanId,  String batchName,  String? batchDescription,  BundleCodeGenerationRequest? bundleRequest,  CartonCodeGenerationRequest? cartonRequest,  PacketCodeGenerationRequest? packetRequest,  UnitCodeGenerationRequest? unitRequest,  bool generateHierarchical,  HierarchicalConfig? hierarchicalConfig)?  $default,) {final _that = this;
switch (_that) {
case _BatchCodeGenerationRequest() when $default != null:
return $default(_that.factoryId,_that.subscriptionPlanId,_that.batchName,_that.batchDescription,_that.bundleRequest,_that.cartonRequest,_that.packetRequest,_that.unitRequest,_that.generateHierarchical,_that.hierarchicalConfig);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BatchCodeGenerationRequest implements BatchCodeGenerationRequest {
  const _BatchCodeGenerationRequest({required this.factoryId, required this.subscriptionPlanId, required this.batchName, this.batchDescription, this.bundleRequest, this.cartonRequest, this.packetRequest, this.unitRequest, this.generateHierarchical = false, this.hierarchicalConfig});
  factory _BatchCodeGenerationRequest.fromJson(Map<String, dynamic> json) => _$BatchCodeGenerationRequestFromJson(json);

/// Factory ID
@override final  String factoryId;
/// Subscription plan ID
@override final  String subscriptionPlanId;
/// Batch name
@override final  String batchName;
/// Batch description
@override final  String? batchDescription;
/// Bundle generation request (optional)
@override final  BundleCodeGenerationRequest? bundleRequest;
/// Carton generation request (optional)
@override final  CartonCodeGenerationRequest? cartonRequest;
/// Packet generation request (optional)
@override final  PacketCodeGenerationRequest? packetRequest;
/// Unit generation request (optional)
@override final  UnitCodeGenerationRequest? unitRequest;
/// Should generate hierarchical codes?
/// If true, will generate codes in hierarchy: Bundle -> Carton -> Packet -> Unit
@override@JsonKey() final  bool generateHierarchical;
/// Hierarchical configuration
/// Only used if generateHierarchical is true
@override final  HierarchicalConfig? hierarchicalConfig;

/// Create a copy of BatchCodeGenerationRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BatchCodeGenerationRequestCopyWith<_BatchCodeGenerationRequest> get copyWith => __$BatchCodeGenerationRequestCopyWithImpl<_BatchCodeGenerationRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BatchCodeGenerationRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BatchCodeGenerationRequest&&(identical(other.factoryId, factoryId) || other.factoryId == factoryId)&&(identical(other.subscriptionPlanId, subscriptionPlanId) || other.subscriptionPlanId == subscriptionPlanId)&&(identical(other.batchName, batchName) || other.batchName == batchName)&&(identical(other.batchDescription, batchDescription) || other.batchDescription == batchDescription)&&(identical(other.bundleRequest, bundleRequest) || other.bundleRequest == bundleRequest)&&(identical(other.cartonRequest, cartonRequest) || other.cartonRequest == cartonRequest)&&(identical(other.packetRequest, packetRequest) || other.packetRequest == packetRequest)&&(identical(other.unitRequest, unitRequest) || other.unitRequest == unitRequest)&&(identical(other.generateHierarchical, generateHierarchical) || other.generateHierarchical == generateHierarchical)&&(identical(other.hierarchicalConfig, hierarchicalConfig) || other.hierarchicalConfig == hierarchicalConfig));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,factoryId,subscriptionPlanId,batchName,batchDescription,bundleRequest,cartonRequest,packetRequest,unitRequest,generateHierarchical,hierarchicalConfig);

@override
String toString() {
  return 'BatchCodeGenerationRequest(factoryId: $factoryId, subscriptionPlanId: $subscriptionPlanId, batchName: $batchName, batchDescription: $batchDescription, bundleRequest: $bundleRequest, cartonRequest: $cartonRequest, packetRequest: $packetRequest, unitRequest: $unitRequest, generateHierarchical: $generateHierarchical, hierarchicalConfig: $hierarchicalConfig)';
}


}

/// @nodoc
abstract mixin class _$BatchCodeGenerationRequestCopyWith<$Res> implements $BatchCodeGenerationRequestCopyWith<$Res> {
  factory _$BatchCodeGenerationRequestCopyWith(_BatchCodeGenerationRequest value, $Res Function(_BatchCodeGenerationRequest) _then) = __$BatchCodeGenerationRequestCopyWithImpl;
@override @useResult
$Res call({
 String factoryId, String subscriptionPlanId, String batchName, String? batchDescription, BundleCodeGenerationRequest? bundleRequest, CartonCodeGenerationRequest? cartonRequest, PacketCodeGenerationRequest? packetRequest, UnitCodeGenerationRequest? unitRequest, bool generateHierarchical, HierarchicalConfig? hierarchicalConfig
});


@override $BundleCodeGenerationRequestCopyWith<$Res>? get bundleRequest;@override $CartonCodeGenerationRequestCopyWith<$Res>? get cartonRequest;@override $PacketCodeGenerationRequestCopyWith<$Res>? get packetRequest;@override $UnitCodeGenerationRequestCopyWith<$Res>? get unitRequest;@override $HierarchicalConfigCopyWith<$Res>? get hierarchicalConfig;

}
/// @nodoc
class __$BatchCodeGenerationRequestCopyWithImpl<$Res>
    implements _$BatchCodeGenerationRequestCopyWith<$Res> {
  __$BatchCodeGenerationRequestCopyWithImpl(this._self, this._then);

  final _BatchCodeGenerationRequest _self;
  final $Res Function(_BatchCodeGenerationRequest) _then;

/// Create a copy of BatchCodeGenerationRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? factoryId = null,Object? subscriptionPlanId = null,Object? batchName = null,Object? batchDescription = freezed,Object? bundleRequest = freezed,Object? cartonRequest = freezed,Object? packetRequest = freezed,Object? unitRequest = freezed,Object? generateHierarchical = null,Object? hierarchicalConfig = freezed,}) {
  return _then(_BatchCodeGenerationRequest(
factoryId: null == factoryId ? _self.factoryId : factoryId // ignore: cast_nullable_to_non_nullable
as String,subscriptionPlanId: null == subscriptionPlanId ? _self.subscriptionPlanId : subscriptionPlanId // ignore: cast_nullable_to_non_nullable
as String,batchName: null == batchName ? _self.batchName : batchName // ignore: cast_nullable_to_non_nullable
as String,batchDescription: freezed == batchDescription ? _self.batchDescription : batchDescription // ignore: cast_nullable_to_non_nullable
as String?,bundleRequest: freezed == bundleRequest ? _self.bundleRequest : bundleRequest // ignore: cast_nullable_to_non_nullable
as BundleCodeGenerationRequest?,cartonRequest: freezed == cartonRequest ? _self.cartonRequest : cartonRequest // ignore: cast_nullable_to_non_nullable
as CartonCodeGenerationRequest?,packetRequest: freezed == packetRequest ? _self.packetRequest : packetRequest // ignore: cast_nullable_to_non_nullable
as PacketCodeGenerationRequest?,unitRequest: freezed == unitRequest ? _self.unitRequest : unitRequest // ignore: cast_nullable_to_non_nullable
as UnitCodeGenerationRequest?,generateHierarchical: null == generateHierarchical ? _self.generateHierarchical : generateHierarchical // ignore: cast_nullable_to_non_nullable
as bool,hierarchicalConfig: freezed == hierarchicalConfig ? _self.hierarchicalConfig : hierarchicalConfig // ignore: cast_nullable_to_non_nullable
as HierarchicalConfig?,
  ));
}

/// Create a copy of BatchCodeGenerationRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BundleCodeGenerationRequestCopyWith<$Res>? get bundleRequest {
    if (_self.bundleRequest == null) {
    return null;
  }

  return $BundleCodeGenerationRequestCopyWith<$Res>(_self.bundleRequest!, (value) {
    return _then(_self.copyWith(bundleRequest: value));
  });
}/// Create a copy of BatchCodeGenerationRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CartonCodeGenerationRequestCopyWith<$Res>? get cartonRequest {
    if (_self.cartonRequest == null) {
    return null;
  }

  return $CartonCodeGenerationRequestCopyWith<$Res>(_self.cartonRequest!, (value) {
    return _then(_self.copyWith(cartonRequest: value));
  });
}/// Create a copy of BatchCodeGenerationRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PacketCodeGenerationRequestCopyWith<$Res>? get packetRequest {
    if (_self.packetRequest == null) {
    return null;
  }

  return $PacketCodeGenerationRequestCopyWith<$Res>(_self.packetRequest!, (value) {
    return _then(_self.copyWith(packetRequest: value));
  });
}/// Create a copy of BatchCodeGenerationRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UnitCodeGenerationRequestCopyWith<$Res>? get unitRequest {
    if (_self.unitRequest == null) {
    return null;
  }

  return $UnitCodeGenerationRequestCopyWith<$Res>(_self.unitRequest!, (value) {
    return _then(_self.copyWith(unitRequest: value));
  });
}/// Create a copy of BatchCodeGenerationRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HierarchicalConfigCopyWith<$Res>? get hierarchicalConfig {
    if (_self.hierarchicalConfig == null) {
    return null;
  }

  return $HierarchicalConfigCopyWith<$Res>(_self.hierarchicalConfig!, (value) {
    return _then(_self.copyWith(hierarchicalConfig: value));
  });
}
}


/// @nodoc
mixin _$HierarchicalConfig {

/// Number of bundles to generate
 int get bundleCount;/// Number of cartons per bundle
 int get cartonsPerBundle;/// Number of packets per carton
 int get packetsPerCarton;/// Number of units per packet
 int get unitsPerPacket;/// Bundle prefix
 String get bundlePrefix;/// Carton prefix
 String get cartonPrefix;/// Packet prefix
 String get packetPrefix;/// Unit prefix
 String get unitPrefix;/// Bundle-specific parameters
 String? get bundleCategory; double? get bundleWeight; String? get bundleDimensions;/// Carton-specific parameters
 String? get cartonType; double? get cartonWeight; String? get cartonDimensions;/// Packet-specific parameters
 String? get packetType; String? get packetMaterial; double? get packetWeight; String? get packetDimensions;/// Unit-specific parameters
 String? get unitModel; String? get unitColor; String? get unitSize; double? get unitWeight; String? get unitDimensions;
/// Create a copy of HierarchicalConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HierarchicalConfigCopyWith<HierarchicalConfig> get copyWith => _$HierarchicalConfigCopyWithImpl<HierarchicalConfig>(this as HierarchicalConfig, _$identity);

  /// Serializes this HierarchicalConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HierarchicalConfig&&(identical(other.bundleCount, bundleCount) || other.bundleCount == bundleCount)&&(identical(other.cartonsPerBundle, cartonsPerBundle) || other.cartonsPerBundle == cartonsPerBundle)&&(identical(other.packetsPerCarton, packetsPerCarton) || other.packetsPerCarton == packetsPerCarton)&&(identical(other.unitsPerPacket, unitsPerPacket) || other.unitsPerPacket == unitsPerPacket)&&(identical(other.bundlePrefix, bundlePrefix) || other.bundlePrefix == bundlePrefix)&&(identical(other.cartonPrefix, cartonPrefix) || other.cartonPrefix == cartonPrefix)&&(identical(other.packetPrefix, packetPrefix) || other.packetPrefix == packetPrefix)&&(identical(other.unitPrefix, unitPrefix) || other.unitPrefix == unitPrefix)&&(identical(other.bundleCategory, bundleCategory) || other.bundleCategory == bundleCategory)&&(identical(other.bundleWeight, bundleWeight) || other.bundleWeight == bundleWeight)&&(identical(other.bundleDimensions, bundleDimensions) || other.bundleDimensions == bundleDimensions)&&(identical(other.cartonType, cartonType) || other.cartonType == cartonType)&&(identical(other.cartonWeight, cartonWeight) || other.cartonWeight == cartonWeight)&&(identical(other.cartonDimensions, cartonDimensions) || other.cartonDimensions == cartonDimensions)&&(identical(other.packetType, packetType) || other.packetType == packetType)&&(identical(other.packetMaterial, packetMaterial) || other.packetMaterial == packetMaterial)&&(identical(other.packetWeight, packetWeight) || other.packetWeight == packetWeight)&&(identical(other.packetDimensions, packetDimensions) || other.packetDimensions == packetDimensions)&&(identical(other.unitModel, unitModel) || other.unitModel == unitModel)&&(identical(other.unitColor, unitColor) || other.unitColor == unitColor)&&(identical(other.unitSize, unitSize) || other.unitSize == unitSize)&&(identical(other.unitWeight, unitWeight) || other.unitWeight == unitWeight)&&(identical(other.unitDimensions, unitDimensions) || other.unitDimensions == unitDimensions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,bundleCount,cartonsPerBundle,packetsPerCarton,unitsPerPacket,bundlePrefix,cartonPrefix,packetPrefix,unitPrefix,bundleCategory,bundleWeight,bundleDimensions,cartonType,cartonWeight,cartonDimensions,packetType,packetMaterial,packetWeight,packetDimensions,unitModel,unitColor,unitSize,unitWeight,unitDimensions]);

@override
String toString() {
  return 'HierarchicalConfig(bundleCount: $bundleCount, cartonsPerBundle: $cartonsPerBundle, packetsPerCarton: $packetsPerCarton, unitsPerPacket: $unitsPerPacket, bundlePrefix: $bundlePrefix, cartonPrefix: $cartonPrefix, packetPrefix: $packetPrefix, unitPrefix: $unitPrefix, bundleCategory: $bundleCategory, bundleWeight: $bundleWeight, bundleDimensions: $bundleDimensions, cartonType: $cartonType, cartonWeight: $cartonWeight, cartonDimensions: $cartonDimensions, packetType: $packetType, packetMaterial: $packetMaterial, packetWeight: $packetWeight, packetDimensions: $packetDimensions, unitModel: $unitModel, unitColor: $unitColor, unitSize: $unitSize, unitWeight: $unitWeight, unitDimensions: $unitDimensions)';
}


}

/// @nodoc
abstract mixin class $HierarchicalConfigCopyWith<$Res>  {
  factory $HierarchicalConfigCopyWith(HierarchicalConfig value, $Res Function(HierarchicalConfig) _then) = _$HierarchicalConfigCopyWithImpl;
@useResult
$Res call({
 int bundleCount, int cartonsPerBundle, int packetsPerCarton, int unitsPerPacket, String bundlePrefix, String cartonPrefix, String packetPrefix, String unitPrefix, String? bundleCategory, double? bundleWeight, String? bundleDimensions, String? cartonType, double? cartonWeight, String? cartonDimensions, String? packetType, String? packetMaterial, double? packetWeight, String? packetDimensions, String? unitModel, String? unitColor, String? unitSize, double? unitWeight, String? unitDimensions
});




}
/// @nodoc
class _$HierarchicalConfigCopyWithImpl<$Res>
    implements $HierarchicalConfigCopyWith<$Res> {
  _$HierarchicalConfigCopyWithImpl(this._self, this._then);

  final HierarchicalConfig _self;
  final $Res Function(HierarchicalConfig) _then;

/// Create a copy of HierarchicalConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bundleCount = null,Object? cartonsPerBundle = null,Object? packetsPerCarton = null,Object? unitsPerPacket = null,Object? bundlePrefix = null,Object? cartonPrefix = null,Object? packetPrefix = null,Object? unitPrefix = null,Object? bundleCategory = freezed,Object? bundleWeight = freezed,Object? bundleDimensions = freezed,Object? cartonType = freezed,Object? cartonWeight = freezed,Object? cartonDimensions = freezed,Object? packetType = freezed,Object? packetMaterial = freezed,Object? packetWeight = freezed,Object? packetDimensions = freezed,Object? unitModel = freezed,Object? unitColor = freezed,Object? unitSize = freezed,Object? unitWeight = freezed,Object? unitDimensions = freezed,}) {
  return _then(_self.copyWith(
bundleCount: null == bundleCount ? _self.bundleCount : bundleCount // ignore: cast_nullable_to_non_nullable
as int,cartonsPerBundle: null == cartonsPerBundle ? _self.cartonsPerBundle : cartonsPerBundle // ignore: cast_nullable_to_non_nullable
as int,packetsPerCarton: null == packetsPerCarton ? _self.packetsPerCarton : packetsPerCarton // ignore: cast_nullable_to_non_nullable
as int,unitsPerPacket: null == unitsPerPacket ? _self.unitsPerPacket : unitsPerPacket // ignore: cast_nullable_to_non_nullable
as int,bundlePrefix: null == bundlePrefix ? _self.bundlePrefix : bundlePrefix // ignore: cast_nullable_to_non_nullable
as String,cartonPrefix: null == cartonPrefix ? _self.cartonPrefix : cartonPrefix // ignore: cast_nullable_to_non_nullable
as String,packetPrefix: null == packetPrefix ? _self.packetPrefix : packetPrefix // ignore: cast_nullable_to_non_nullable
as String,unitPrefix: null == unitPrefix ? _self.unitPrefix : unitPrefix // ignore: cast_nullable_to_non_nullable
as String,bundleCategory: freezed == bundleCategory ? _self.bundleCategory : bundleCategory // ignore: cast_nullable_to_non_nullable
as String?,bundleWeight: freezed == bundleWeight ? _self.bundleWeight : bundleWeight // ignore: cast_nullable_to_non_nullable
as double?,bundleDimensions: freezed == bundleDimensions ? _self.bundleDimensions : bundleDimensions // ignore: cast_nullable_to_non_nullable
as String?,cartonType: freezed == cartonType ? _self.cartonType : cartonType // ignore: cast_nullable_to_non_nullable
as String?,cartonWeight: freezed == cartonWeight ? _self.cartonWeight : cartonWeight // ignore: cast_nullable_to_non_nullable
as double?,cartonDimensions: freezed == cartonDimensions ? _self.cartonDimensions : cartonDimensions // ignore: cast_nullable_to_non_nullable
as String?,packetType: freezed == packetType ? _self.packetType : packetType // ignore: cast_nullable_to_non_nullable
as String?,packetMaterial: freezed == packetMaterial ? _self.packetMaterial : packetMaterial // ignore: cast_nullable_to_non_nullable
as String?,packetWeight: freezed == packetWeight ? _self.packetWeight : packetWeight // ignore: cast_nullable_to_non_nullable
as double?,packetDimensions: freezed == packetDimensions ? _self.packetDimensions : packetDimensions // ignore: cast_nullable_to_non_nullable
as String?,unitModel: freezed == unitModel ? _self.unitModel : unitModel // ignore: cast_nullable_to_non_nullable
as String?,unitColor: freezed == unitColor ? _self.unitColor : unitColor // ignore: cast_nullable_to_non_nullable
as String?,unitSize: freezed == unitSize ? _self.unitSize : unitSize // ignore: cast_nullable_to_non_nullable
as String?,unitWeight: freezed == unitWeight ? _self.unitWeight : unitWeight // ignore: cast_nullable_to_non_nullable
as double?,unitDimensions: freezed == unitDimensions ? _self.unitDimensions : unitDimensions // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [HierarchicalConfig].
extension HierarchicalConfigPatterns on HierarchicalConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HierarchicalConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HierarchicalConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HierarchicalConfig value)  $default,){
final _that = this;
switch (_that) {
case _HierarchicalConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HierarchicalConfig value)?  $default,){
final _that = this;
switch (_that) {
case _HierarchicalConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int bundleCount,  int cartonsPerBundle,  int packetsPerCarton,  int unitsPerPacket,  String bundlePrefix,  String cartonPrefix,  String packetPrefix,  String unitPrefix,  String? bundleCategory,  double? bundleWeight,  String? bundleDimensions,  String? cartonType,  double? cartonWeight,  String? cartonDimensions,  String? packetType,  String? packetMaterial,  double? packetWeight,  String? packetDimensions,  String? unitModel,  String? unitColor,  String? unitSize,  double? unitWeight,  String? unitDimensions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HierarchicalConfig() when $default != null:
return $default(_that.bundleCount,_that.cartonsPerBundle,_that.packetsPerCarton,_that.unitsPerPacket,_that.bundlePrefix,_that.cartonPrefix,_that.packetPrefix,_that.unitPrefix,_that.bundleCategory,_that.bundleWeight,_that.bundleDimensions,_that.cartonType,_that.cartonWeight,_that.cartonDimensions,_that.packetType,_that.packetMaterial,_that.packetWeight,_that.packetDimensions,_that.unitModel,_that.unitColor,_that.unitSize,_that.unitWeight,_that.unitDimensions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int bundleCount,  int cartonsPerBundle,  int packetsPerCarton,  int unitsPerPacket,  String bundlePrefix,  String cartonPrefix,  String packetPrefix,  String unitPrefix,  String? bundleCategory,  double? bundleWeight,  String? bundleDimensions,  String? cartonType,  double? cartonWeight,  String? cartonDimensions,  String? packetType,  String? packetMaterial,  double? packetWeight,  String? packetDimensions,  String? unitModel,  String? unitColor,  String? unitSize,  double? unitWeight,  String? unitDimensions)  $default,) {final _that = this;
switch (_that) {
case _HierarchicalConfig():
return $default(_that.bundleCount,_that.cartonsPerBundle,_that.packetsPerCarton,_that.unitsPerPacket,_that.bundlePrefix,_that.cartonPrefix,_that.packetPrefix,_that.unitPrefix,_that.bundleCategory,_that.bundleWeight,_that.bundleDimensions,_that.cartonType,_that.cartonWeight,_that.cartonDimensions,_that.packetType,_that.packetMaterial,_that.packetWeight,_that.packetDimensions,_that.unitModel,_that.unitColor,_that.unitSize,_that.unitWeight,_that.unitDimensions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int bundleCount,  int cartonsPerBundle,  int packetsPerCarton,  int unitsPerPacket,  String bundlePrefix,  String cartonPrefix,  String packetPrefix,  String unitPrefix,  String? bundleCategory,  double? bundleWeight,  String? bundleDimensions,  String? cartonType,  double? cartonWeight,  String? cartonDimensions,  String? packetType,  String? packetMaterial,  double? packetWeight,  String? packetDimensions,  String? unitModel,  String? unitColor,  String? unitSize,  double? unitWeight,  String? unitDimensions)?  $default,) {final _that = this;
switch (_that) {
case _HierarchicalConfig() when $default != null:
return $default(_that.bundleCount,_that.cartonsPerBundle,_that.packetsPerCarton,_that.unitsPerPacket,_that.bundlePrefix,_that.cartonPrefix,_that.packetPrefix,_that.unitPrefix,_that.bundleCategory,_that.bundleWeight,_that.bundleDimensions,_that.cartonType,_that.cartonWeight,_that.cartonDimensions,_that.packetType,_that.packetMaterial,_that.packetWeight,_that.packetDimensions,_that.unitModel,_that.unitColor,_that.unitSize,_that.unitWeight,_that.unitDimensions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HierarchicalConfig implements HierarchicalConfig {
  const _HierarchicalConfig({required this.bundleCount, required this.cartonsPerBundle, required this.packetsPerCarton, required this.unitsPerPacket, required this.bundlePrefix, required this.cartonPrefix, required this.packetPrefix, required this.unitPrefix, this.bundleCategory, this.bundleWeight, this.bundleDimensions, this.cartonType, this.cartonWeight, this.cartonDimensions, this.packetType, this.packetMaterial, this.packetWeight, this.packetDimensions, this.unitModel, this.unitColor, this.unitSize, this.unitWeight, this.unitDimensions});
  factory _HierarchicalConfig.fromJson(Map<String, dynamic> json) => _$HierarchicalConfigFromJson(json);

/// Number of bundles to generate
@override final  int bundleCount;
/// Number of cartons per bundle
@override final  int cartonsPerBundle;
/// Number of packets per carton
@override final  int packetsPerCarton;
/// Number of units per packet
@override final  int unitsPerPacket;
/// Bundle prefix
@override final  String bundlePrefix;
/// Carton prefix
@override final  String cartonPrefix;
/// Packet prefix
@override final  String packetPrefix;
/// Unit prefix
@override final  String unitPrefix;
/// Bundle-specific parameters
@override final  String? bundleCategory;
@override final  double? bundleWeight;
@override final  String? bundleDimensions;
/// Carton-specific parameters
@override final  String? cartonType;
@override final  double? cartonWeight;
@override final  String? cartonDimensions;
/// Packet-specific parameters
@override final  String? packetType;
@override final  String? packetMaterial;
@override final  double? packetWeight;
@override final  String? packetDimensions;
/// Unit-specific parameters
@override final  String? unitModel;
@override final  String? unitColor;
@override final  String? unitSize;
@override final  double? unitWeight;
@override final  String? unitDimensions;

/// Create a copy of HierarchicalConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HierarchicalConfigCopyWith<_HierarchicalConfig> get copyWith => __$HierarchicalConfigCopyWithImpl<_HierarchicalConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HierarchicalConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HierarchicalConfig&&(identical(other.bundleCount, bundleCount) || other.bundleCount == bundleCount)&&(identical(other.cartonsPerBundle, cartonsPerBundle) || other.cartonsPerBundle == cartonsPerBundle)&&(identical(other.packetsPerCarton, packetsPerCarton) || other.packetsPerCarton == packetsPerCarton)&&(identical(other.unitsPerPacket, unitsPerPacket) || other.unitsPerPacket == unitsPerPacket)&&(identical(other.bundlePrefix, bundlePrefix) || other.bundlePrefix == bundlePrefix)&&(identical(other.cartonPrefix, cartonPrefix) || other.cartonPrefix == cartonPrefix)&&(identical(other.packetPrefix, packetPrefix) || other.packetPrefix == packetPrefix)&&(identical(other.unitPrefix, unitPrefix) || other.unitPrefix == unitPrefix)&&(identical(other.bundleCategory, bundleCategory) || other.bundleCategory == bundleCategory)&&(identical(other.bundleWeight, bundleWeight) || other.bundleWeight == bundleWeight)&&(identical(other.bundleDimensions, bundleDimensions) || other.bundleDimensions == bundleDimensions)&&(identical(other.cartonType, cartonType) || other.cartonType == cartonType)&&(identical(other.cartonWeight, cartonWeight) || other.cartonWeight == cartonWeight)&&(identical(other.cartonDimensions, cartonDimensions) || other.cartonDimensions == cartonDimensions)&&(identical(other.packetType, packetType) || other.packetType == packetType)&&(identical(other.packetMaterial, packetMaterial) || other.packetMaterial == packetMaterial)&&(identical(other.packetWeight, packetWeight) || other.packetWeight == packetWeight)&&(identical(other.packetDimensions, packetDimensions) || other.packetDimensions == packetDimensions)&&(identical(other.unitModel, unitModel) || other.unitModel == unitModel)&&(identical(other.unitColor, unitColor) || other.unitColor == unitColor)&&(identical(other.unitSize, unitSize) || other.unitSize == unitSize)&&(identical(other.unitWeight, unitWeight) || other.unitWeight == unitWeight)&&(identical(other.unitDimensions, unitDimensions) || other.unitDimensions == unitDimensions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,bundleCount,cartonsPerBundle,packetsPerCarton,unitsPerPacket,bundlePrefix,cartonPrefix,packetPrefix,unitPrefix,bundleCategory,bundleWeight,bundleDimensions,cartonType,cartonWeight,cartonDimensions,packetType,packetMaterial,packetWeight,packetDimensions,unitModel,unitColor,unitSize,unitWeight,unitDimensions]);

@override
String toString() {
  return 'HierarchicalConfig(bundleCount: $bundleCount, cartonsPerBundle: $cartonsPerBundle, packetsPerCarton: $packetsPerCarton, unitsPerPacket: $unitsPerPacket, bundlePrefix: $bundlePrefix, cartonPrefix: $cartonPrefix, packetPrefix: $packetPrefix, unitPrefix: $unitPrefix, bundleCategory: $bundleCategory, bundleWeight: $bundleWeight, bundleDimensions: $bundleDimensions, cartonType: $cartonType, cartonWeight: $cartonWeight, cartonDimensions: $cartonDimensions, packetType: $packetType, packetMaterial: $packetMaterial, packetWeight: $packetWeight, packetDimensions: $packetDimensions, unitModel: $unitModel, unitColor: $unitColor, unitSize: $unitSize, unitWeight: $unitWeight, unitDimensions: $unitDimensions)';
}


}

/// @nodoc
abstract mixin class _$HierarchicalConfigCopyWith<$Res> implements $HierarchicalConfigCopyWith<$Res> {
  factory _$HierarchicalConfigCopyWith(_HierarchicalConfig value, $Res Function(_HierarchicalConfig) _then) = __$HierarchicalConfigCopyWithImpl;
@override @useResult
$Res call({
 int bundleCount, int cartonsPerBundle, int packetsPerCarton, int unitsPerPacket, String bundlePrefix, String cartonPrefix, String packetPrefix, String unitPrefix, String? bundleCategory, double? bundleWeight, String? bundleDimensions, String? cartonType, double? cartonWeight, String? cartonDimensions, String? packetType, String? packetMaterial, double? packetWeight, String? packetDimensions, String? unitModel, String? unitColor, String? unitSize, double? unitWeight, String? unitDimensions
});




}
/// @nodoc
class __$HierarchicalConfigCopyWithImpl<$Res>
    implements _$HierarchicalConfigCopyWith<$Res> {
  __$HierarchicalConfigCopyWithImpl(this._self, this._then);

  final _HierarchicalConfig _self;
  final $Res Function(_HierarchicalConfig) _then;

/// Create a copy of HierarchicalConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bundleCount = null,Object? cartonsPerBundle = null,Object? packetsPerCarton = null,Object? unitsPerPacket = null,Object? bundlePrefix = null,Object? cartonPrefix = null,Object? packetPrefix = null,Object? unitPrefix = null,Object? bundleCategory = freezed,Object? bundleWeight = freezed,Object? bundleDimensions = freezed,Object? cartonType = freezed,Object? cartonWeight = freezed,Object? cartonDimensions = freezed,Object? packetType = freezed,Object? packetMaterial = freezed,Object? packetWeight = freezed,Object? packetDimensions = freezed,Object? unitModel = freezed,Object? unitColor = freezed,Object? unitSize = freezed,Object? unitWeight = freezed,Object? unitDimensions = freezed,}) {
  return _then(_HierarchicalConfig(
bundleCount: null == bundleCount ? _self.bundleCount : bundleCount // ignore: cast_nullable_to_non_nullable
as int,cartonsPerBundle: null == cartonsPerBundle ? _self.cartonsPerBundle : cartonsPerBundle // ignore: cast_nullable_to_non_nullable
as int,packetsPerCarton: null == packetsPerCarton ? _self.packetsPerCarton : packetsPerCarton // ignore: cast_nullable_to_non_nullable
as int,unitsPerPacket: null == unitsPerPacket ? _self.unitsPerPacket : unitsPerPacket // ignore: cast_nullable_to_non_nullable
as int,bundlePrefix: null == bundlePrefix ? _self.bundlePrefix : bundlePrefix // ignore: cast_nullable_to_non_nullable
as String,cartonPrefix: null == cartonPrefix ? _self.cartonPrefix : cartonPrefix // ignore: cast_nullable_to_non_nullable
as String,packetPrefix: null == packetPrefix ? _self.packetPrefix : packetPrefix // ignore: cast_nullable_to_non_nullable
as String,unitPrefix: null == unitPrefix ? _self.unitPrefix : unitPrefix // ignore: cast_nullable_to_non_nullable
as String,bundleCategory: freezed == bundleCategory ? _self.bundleCategory : bundleCategory // ignore: cast_nullable_to_non_nullable
as String?,bundleWeight: freezed == bundleWeight ? _self.bundleWeight : bundleWeight // ignore: cast_nullable_to_non_nullable
as double?,bundleDimensions: freezed == bundleDimensions ? _self.bundleDimensions : bundleDimensions // ignore: cast_nullable_to_non_nullable
as String?,cartonType: freezed == cartonType ? _self.cartonType : cartonType // ignore: cast_nullable_to_non_nullable
as String?,cartonWeight: freezed == cartonWeight ? _self.cartonWeight : cartonWeight // ignore: cast_nullable_to_non_nullable
as double?,cartonDimensions: freezed == cartonDimensions ? _self.cartonDimensions : cartonDimensions // ignore: cast_nullable_to_non_nullable
as String?,packetType: freezed == packetType ? _self.packetType : packetType // ignore: cast_nullable_to_non_nullable
as String?,packetMaterial: freezed == packetMaterial ? _self.packetMaterial : packetMaterial // ignore: cast_nullable_to_non_nullable
as String?,packetWeight: freezed == packetWeight ? _self.packetWeight : packetWeight // ignore: cast_nullable_to_non_nullable
as double?,packetDimensions: freezed == packetDimensions ? _self.packetDimensions : packetDimensions // ignore: cast_nullable_to_non_nullable
as String?,unitModel: freezed == unitModel ? _self.unitModel : unitModel // ignore: cast_nullable_to_non_nullable
as String?,unitColor: freezed == unitColor ? _self.unitColor : unitColor // ignore: cast_nullable_to_non_nullable
as String?,unitSize: freezed == unitSize ? _self.unitSize : unitSize // ignore: cast_nullable_to_non_nullable
as String?,unitWeight: freezed == unitWeight ? _self.unitWeight : unitWeight // ignore: cast_nullable_to_non_nullable
as double?,unitDimensions: freezed == unitDimensions ? _self.unitDimensions : unitDimensions // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CodeGenerationResponse {

/// Generation success status
 bool get success;/// Generated batch ID
 String get batchId;/// Number of codes generated
 int get codesGenerated;/// Total codes in subscription after this generation
 int get totalCodesAfterGeneration;/// Remaining codes in subscription
 int get remainingCodes;/// Generated codes (first 100 for preview)
 List<String>? get generatedCodesPreview;/// Download URL for full code list
 String? get downloadUrl;/// QR codes download URL
 String? get qrCodesDownloadUrl;/// Barcodes download URL
 String? get barcodesDownloadUrl;/// Generation timestamp
 DateTime get generatedAt;/// Estimated billing amount
 double? get estimatedBillingAmount;/// Error message if generation failed
 String? get error;
/// Create a copy of CodeGenerationResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CodeGenerationResponseCopyWith<CodeGenerationResponse> get copyWith => _$CodeGenerationResponseCopyWithImpl<CodeGenerationResponse>(this as CodeGenerationResponse, _$identity);

  /// Serializes this CodeGenerationResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CodeGenerationResponse&&(identical(other.success, success) || other.success == success)&&(identical(other.batchId, batchId) || other.batchId == batchId)&&(identical(other.codesGenerated, codesGenerated) || other.codesGenerated == codesGenerated)&&(identical(other.totalCodesAfterGeneration, totalCodesAfterGeneration) || other.totalCodesAfterGeneration == totalCodesAfterGeneration)&&(identical(other.remainingCodes, remainingCodes) || other.remainingCodes == remainingCodes)&&const DeepCollectionEquality().equals(other.generatedCodesPreview, generatedCodesPreview)&&(identical(other.downloadUrl, downloadUrl) || other.downloadUrl == downloadUrl)&&(identical(other.qrCodesDownloadUrl, qrCodesDownloadUrl) || other.qrCodesDownloadUrl == qrCodesDownloadUrl)&&(identical(other.barcodesDownloadUrl, barcodesDownloadUrl) || other.barcodesDownloadUrl == barcodesDownloadUrl)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.estimatedBillingAmount, estimatedBillingAmount) || other.estimatedBillingAmount == estimatedBillingAmount)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,batchId,codesGenerated,totalCodesAfterGeneration,remainingCodes,const DeepCollectionEquality().hash(generatedCodesPreview),downloadUrl,qrCodesDownloadUrl,barcodesDownloadUrl,generatedAt,estimatedBillingAmount,error);

@override
String toString() {
  return 'CodeGenerationResponse(success: $success, batchId: $batchId, codesGenerated: $codesGenerated, totalCodesAfterGeneration: $totalCodesAfterGeneration, remainingCodes: $remainingCodes, generatedCodesPreview: $generatedCodesPreview, downloadUrl: $downloadUrl, qrCodesDownloadUrl: $qrCodesDownloadUrl, barcodesDownloadUrl: $barcodesDownloadUrl, generatedAt: $generatedAt, estimatedBillingAmount: $estimatedBillingAmount, error: $error)';
}


}

/// @nodoc
abstract mixin class $CodeGenerationResponseCopyWith<$Res>  {
  factory $CodeGenerationResponseCopyWith(CodeGenerationResponse value, $Res Function(CodeGenerationResponse) _then) = _$CodeGenerationResponseCopyWithImpl;
@useResult
$Res call({
 bool success, String batchId, int codesGenerated, int totalCodesAfterGeneration, int remainingCodes, List<String>? generatedCodesPreview, String? downloadUrl, String? qrCodesDownloadUrl, String? barcodesDownloadUrl, DateTime generatedAt, double? estimatedBillingAmount, String? error
});




}
/// @nodoc
class _$CodeGenerationResponseCopyWithImpl<$Res>
    implements $CodeGenerationResponseCopyWith<$Res> {
  _$CodeGenerationResponseCopyWithImpl(this._self, this._then);

  final CodeGenerationResponse _self;
  final $Res Function(CodeGenerationResponse) _then;

/// Create a copy of CodeGenerationResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? success = null,Object? batchId = null,Object? codesGenerated = null,Object? totalCodesAfterGeneration = null,Object? remainingCodes = null,Object? generatedCodesPreview = freezed,Object? downloadUrl = freezed,Object? qrCodesDownloadUrl = freezed,Object? barcodesDownloadUrl = freezed,Object? generatedAt = null,Object? estimatedBillingAmount = freezed,Object? error = freezed,}) {
  return _then(_self.copyWith(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,batchId: null == batchId ? _self.batchId : batchId // ignore: cast_nullable_to_non_nullable
as String,codesGenerated: null == codesGenerated ? _self.codesGenerated : codesGenerated // ignore: cast_nullable_to_non_nullable
as int,totalCodesAfterGeneration: null == totalCodesAfterGeneration ? _self.totalCodesAfterGeneration : totalCodesAfterGeneration // ignore: cast_nullable_to_non_nullable
as int,remainingCodes: null == remainingCodes ? _self.remainingCodes : remainingCodes // ignore: cast_nullable_to_non_nullable
as int,generatedCodesPreview: freezed == generatedCodesPreview ? _self.generatedCodesPreview : generatedCodesPreview // ignore: cast_nullable_to_non_nullable
as List<String>?,downloadUrl: freezed == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String?,qrCodesDownloadUrl: freezed == qrCodesDownloadUrl ? _self.qrCodesDownloadUrl : qrCodesDownloadUrl // ignore: cast_nullable_to_non_nullable
as String?,barcodesDownloadUrl: freezed == barcodesDownloadUrl ? _self.barcodesDownloadUrl : barcodesDownloadUrl // ignore: cast_nullable_to_non_nullable
as String?,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,estimatedBillingAmount: freezed == estimatedBillingAmount ? _self.estimatedBillingAmount : estimatedBillingAmount // ignore: cast_nullable_to_non_nullable
as double?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CodeGenerationResponse].
extension CodeGenerationResponsePatterns on CodeGenerationResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CodeGenerationResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CodeGenerationResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CodeGenerationResponse value)  $default,){
final _that = this;
switch (_that) {
case _CodeGenerationResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CodeGenerationResponse value)?  $default,){
final _that = this;
switch (_that) {
case _CodeGenerationResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool success,  String batchId,  int codesGenerated,  int totalCodesAfterGeneration,  int remainingCodes,  List<String>? generatedCodesPreview,  String? downloadUrl,  String? qrCodesDownloadUrl,  String? barcodesDownloadUrl,  DateTime generatedAt,  double? estimatedBillingAmount,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CodeGenerationResponse() when $default != null:
return $default(_that.success,_that.batchId,_that.codesGenerated,_that.totalCodesAfterGeneration,_that.remainingCodes,_that.generatedCodesPreview,_that.downloadUrl,_that.qrCodesDownloadUrl,_that.barcodesDownloadUrl,_that.generatedAt,_that.estimatedBillingAmount,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool success,  String batchId,  int codesGenerated,  int totalCodesAfterGeneration,  int remainingCodes,  List<String>? generatedCodesPreview,  String? downloadUrl,  String? qrCodesDownloadUrl,  String? barcodesDownloadUrl,  DateTime generatedAt,  double? estimatedBillingAmount,  String? error)  $default,) {final _that = this;
switch (_that) {
case _CodeGenerationResponse():
return $default(_that.success,_that.batchId,_that.codesGenerated,_that.totalCodesAfterGeneration,_that.remainingCodes,_that.generatedCodesPreview,_that.downloadUrl,_that.qrCodesDownloadUrl,_that.barcodesDownloadUrl,_that.generatedAt,_that.estimatedBillingAmount,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool success,  String batchId,  int codesGenerated,  int totalCodesAfterGeneration,  int remainingCodes,  List<String>? generatedCodesPreview,  String? downloadUrl,  String? qrCodesDownloadUrl,  String? barcodesDownloadUrl,  DateTime generatedAt,  double? estimatedBillingAmount,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _CodeGenerationResponse() when $default != null:
return $default(_that.success,_that.batchId,_that.codesGenerated,_that.totalCodesAfterGeneration,_that.remainingCodes,_that.generatedCodesPreview,_that.downloadUrl,_that.qrCodesDownloadUrl,_that.barcodesDownloadUrl,_that.generatedAt,_that.estimatedBillingAmount,_that.error);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CodeGenerationResponse implements CodeGenerationResponse {
  const _CodeGenerationResponse({required this.success, required this.batchId, required this.codesGenerated, required this.totalCodesAfterGeneration, required this.remainingCodes, final  List<String>? generatedCodesPreview, this.downloadUrl, this.qrCodesDownloadUrl, this.barcodesDownloadUrl, required this.generatedAt, this.estimatedBillingAmount, this.error}): _generatedCodesPreview = generatedCodesPreview;
  factory _CodeGenerationResponse.fromJson(Map<String, dynamic> json) => _$CodeGenerationResponseFromJson(json);

/// Generation success status
@override final  bool success;
/// Generated batch ID
@override final  String batchId;
/// Number of codes generated
@override final  int codesGenerated;
/// Total codes in subscription after this generation
@override final  int totalCodesAfterGeneration;
/// Remaining codes in subscription
@override final  int remainingCodes;
/// Generated codes (first 100 for preview)
 final  List<String>? _generatedCodesPreview;
/// Generated codes (first 100 for preview)
@override List<String>? get generatedCodesPreview {
  final value = _generatedCodesPreview;
  if (value == null) return null;
  if (_generatedCodesPreview is EqualUnmodifiableListView) return _generatedCodesPreview;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// Download URL for full code list
@override final  String? downloadUrl;
/// QR codes download URL
@override final  String? qrCodesDownloadUrl;
/// Barcodes download URL
@override final  String? barcodesDownloadUrl;
/// Generation timestamp
@override final  DateTime generatedAt;
/// Estimated billing amount
@override final  double? estimatedBillingAmount;
/// Error message if generation failed
@override final  String? error;

/// Create a copy of CodeGenerationResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CodeGenerationResponseCopyWith<_CodeGenerationResponse> get copyWith => __$CodeGenerationResponseCopyWithImpl<_CodeGenerationResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CodeGenerationResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CodeGenerationResponse&&(identical(other.success, success) || other.success == success)&&(identical(other.batchId, batchId) || other.batchId == batchId)&&(identical(other.codesGenerated, codesGenerated) || other.codesGenerated == codesGenerated)&&(identical(other.totalCodesAfterGeneration, totalCodesAfterGeneration) || other.totalCodesAfterGeneration == totalCodesAfterGeneration)&&(identical(other.remainingCodes, remainingCodes) || other.remainingCodes == remainingCodes)&&const DeepCollectionEquality().equals(other._generatedCodesPreview, _generatedCodesPreview)&&(identical(other.downloadUrl, downloadUrl) || other.downloadUrl == downloadUrl)&&(identical(other.qrCodesDownloadUrl, qrCodesDownloadUrl) || other.qrCodesDownloadUrl == qrCodesDownloadUrl)&&(identical(other.barcodesDownloadUrl, barcodesDownloadUrl) || other.barcodesDownloadUrl == barcodesDownloadUrl)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.estimatedBillingAmount, estimatedBillingAmount) || other.estimatedBillingAmount == estimatedBillingAmount)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,batchId,codesGenerated,totalCodesAfterGeneration,remainingCodes,const DeepCollectionEquality().hash(_generatedCodesPreview),downloadUrl,qrCodesDownloadUrl,barcodesDownloadUrl,generatedAt,estimatedBillingAmount,error);

@override
String toString() {
  return 'CodeGenerationResponse(success: $success, batchId: $batchId, codesGenerated: $codesGenerated, totalCodesAfterGeneration: $totalCodesAfterGeneration, remainingCodes: $remainingCodes, generatedCodesPreview: $generatedCodesPreview, downloadUrl: $downloadUrl, qrCodesDownloadUrl: $qrCodesDownloadUrl, barcodesDownloadUrl: $barcodesDownloadUrl, generatedAt: $generatedAt, estimatedBillingAmount: $estimatedBillingAmount, error: $error)';
}


}

/// @nodoc
abstract mixin class _$CodeGenerationResponseCopyWith<$Res> implements $CodeGenerationResponseCopyWith<$Res> {
  factory _$CodeGenerationResponseCopyWith(_CodeGenerationResponse value, $Res Function(_CodeGenerationResponse) _then) = __$CodeGenerationResponseCopyWithImpl;
@override @useResult
$Res call({
 bool success, String batchId, int codesGenerated, int totalCodesAfterGeneration, int remainingCodes, List<String>? generatedCodesPreview, String? downloadUrl, String? qrCodesDownloadUrl, String? barcodesDownloadUrl, DateTime generatedAt, double? estimatedBillingAmount, String? error
});




}
/// @nodoc
class __$CodeGenerationResponseCopyWithImpl<$Res>
    implements _$CodeGenerationResponseCopyWith<$Res> {
  __$CodeGenerationResponseCopyWithImpl(this._self, this._then);

  final _CodeGenerationResponse _self;
  final $Res Function(_CodeGenerationResponse) _then;

/// Create a copy of CodeGenerationResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? success = null,Object? batchId = null,Object? codesGenerated = null,Object? totalCodesAfterGeneration = null,Object? remainingCodes = null,Object? generatedCodesPreview = freezed,Object? downloadUrl = freezed,Object? qrCodesDownloadUrl = freezed,Object? barcodesDownloadUrl = freezed,Object? generatedAt = null,Object? estimatedBillingAmount = freezed,Object? error = freezed,}) {
  return _then(_CodeGenerationResponse(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,batchId: null == batchId ? _self.batchId : batchId // ignore: cast_nullable_to_non_nullable
as String,codesGenerated: null == codesGenerated ? _self.codesGenerated : codesGenerated // ignore: cast_nullable_to_non_nullable
as int,totalCodesAfterGeneration: null == totalCodesAfterGeneration ? _self.totalCodesAfterGeneration : totalCodesAfterGeneration // ignore: cast_nullable_to_non_nullable
as int,remainingCodes: null == remainingCodes ? _self.remainingCodes : remainingCodes // ignore: cast_nullable_to_non_nullable
as int,generatedCodesPreview: freezed == generatedCodesPreview ? _self._generatedCodesPreview : generatedCodesPreview // ignore: cast_nullable_to_non_nullable
as List<String>?,downloadUrl: freezed == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String?,qrCodesDownloadUrl: freezed == qrCodesDownloadUrl ? _self.qrCodesDownloadUrl : qrCodesDownloadUrl // ignore: cast_nullable_to_non_nullable
as String?,barcodesDownloadUrl: freezed == barcodesDownloadUrl ? _self.barcodesDownloadUrl : barcodesDownloadUrl // ignore: cast_nullable_to_non_nullable
as String?,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,estimatedBillingAmount: freezed == estimatedBillingAmount ? _self.estimatedBillingAmount : estimatedBillingAmount // ignore: cast_nullable_to_non_nullable
as double?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CodeGenerationValidation {

/// Is request valid?
 bool get isValid;/// Validation errors
 List<String>? get errors;/// Validation warnings
 List<String>? get warnings;/// Estimated code count
 int? get estimatedCodeCount;/// Estimated processing time in seconds
 double? get estimatedProcessingTime;/// Estimated storage required in KB
 double? get estimatedStorageRequired;/// Will exceed subscription limits?
 bool? get willExceedLimits;/// Current subscription usage
 SubscriptionUsage? get currentUsage;/// Proposed subscription usage after generation
 SubscriptionUsage? get proposedUsage;
/// Create a copy of CodeGenerationValidation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CodeGenerationValidationCopyWith<CodeGenerationValidation> get copyWith => _$CodeGenerationValidationCopyWithImpl<CodeGenerationValidation>(this as CodeGenerationValidation, _$identity);

  /// Serializes this CodeGenerationValidation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CodeGenerationValidation&&(identical(other.isValid, isValid) || other.isValid == isValid)&&const DeepCollectionEquality().equals(other.errors, errors)&&const DeepCollectionEquality().equals(other.warnings, warnings)&&(identical(other.estimatedCodeCount, estimatedCodeCount) || other.estimatedCodeCount == estimatedCodeCount)&&(identical(other.estimatedProcessingTime, estimatedProcessingTime) || other.estimatedProcessingTime == estimatedProcessingTime)&&(identical(other.estimatedStorageRequired, estimatedStorageRequired) || other.estimatedStorageRequired == estimatedStorageRequired)&&(identical(other.willExceedLimits, willExceedLimits) || other.willExceedLimits == willExceedLimits)&&(identical(other.currentUsage, currentUsage) || other.currentUsage == currentUsage)&&(identical(other.proposedUsage, proposedUsage) || other.proposedUsage == proposedUsage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isValid,const DeepCollectionEquality().hash(errors),const DeepCollectionEquality().hash(warnings),estimatedCodeCount,estimatedProcessingTime,estimatedStorageRequired,willExceedLimits,currentUsage,proposedUsage);

@override
String toString() {
  return 'CodeGenerationValidation(isValid: $isValid, errors: $errors, warnings: $warnings, estimatedCodeCount: $estimatedCodeCount, estimatedProcessingTime: $estimatedProcessingTime, estimatedStorageRequired: $estimatedStorageRequired, willExceedLimits: $willExceedLimits, currentUsage: $currentUsage, proposedUsage: $proposedUsage)';
}


}

/// @nodoc
abstract mixin class $CodeGenerationValidationCopyWith<$Res>  {
  factory $CodeGenerationValidationCopyWith(CodeGenerationValidation value, $Res Function(CodeGenerationValidation) _then) = _$CodeGenerationValidationCopyWithImpl;
@useResult
$Res call({
 bool isValid, List<String>? errors, List<String>? warnings, int? estimatedCodeCount, double? estimatedProcessingTime, double? estimatedStorageRequired, bool? willExceedLimits, SubscriptionUsage? currentUsage, SubscriptionUsage? proposedUsage
});


$SubscriptionUsageCopyWith<$Res>? get currentUsage;$SubscriptionUsageCopyWith<$Res>? get proposedUsage;

}
/// @nodoc
class _$CodeGenerationValidationCopyWithImpl<$Res>
    implements $CodeGenerationValidationCopyWith<$Res> {
  _$CodeGenerationValidationCopyWithImpl(this._self, this._then);

  final CodeGenerationValidation _self;
  final $Res Function(CodeGenerationValidation) _then;

/// Create a copy of CodeGenerationValidation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isValid = null,Object? errors = freezed,Object? warnings = freezed,Object? estimatedCodeCount = freezed,Object? estimatedProcessingTime = freezed,Object? estimatedStorageRequired = freezed,Object? willExceedLimits = freezed,Object? currentUsage = freezed,Object? proposedUsage = freezed,}) {
  return _then(_self.copyWith(
isValid: null == isValid ? _self.isValid : isValid // ignore: cast_nullable_to_non_nullable
as bool,errors: freezed == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as List<String>?,warnings: freezed == warnings ? _self.warnings : warnings // ignore: cast_nullable_to_non_nullable
as List<String>?,estimatedCodeCount: freezed == estimatedCodeCount ? _self.estimatedCodeCount : estimatedCodeCount // ignore: cast_nullable_to_non_nullable
as int?,estimatedProcessingTime: freezed == estimatedProcessingTime ? _self.estimatedProcessingTime : estimatedProcessingTime // ignore: cast_nullable_to_non_nullable
as double?,estimatedStorageRequired: freezed == estimatedStorageRequired ? _self.estimatedStorageRequired : estimatedStorageRequired // ignore: cast_nullable_to_non_nullable
as double?,willExceedLimits: freezed == willExceedLimits ? _self.willExceedLimits : willExceedLimits // ignore: cast_nullable_to_non_nullable
as bool?,currentUsage: freezed == currentUsage ? _self.currentUsage : currentUsage // ignore: cast_nullable_to_non_nullable
as SubscriptionUsage?,proposedUsage: freezed == proposedUsage ? _self.proposedUsage : proposedUsage // ignore: cast_nullable_to_non_nullable
as SubscriptionUsage?,
  ));
}
/// Create a copy of CodeGenerationValidation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubscriptionUsageCopyWith<$Res>? get currentUsage {
    if (_self.currentUsage == null) {
    return null;
  }

  return $SubscriptionUsageCopyWith<$Res>(_self.currentUsage!, (value) {
    return _then(_self.copyWith(currentUsage: value));
  });
}/// Create a copy of CodeGenerationValidation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubscriptionUsageCopyWith<$Res>? get proposedUsage {
    if (_self.proposedUsage == null) {
    return null;
  }

  return $SubscriptionUsageCopyWith<$Res>(_self.proposedUsage!, (value) {
    return _then(_self.copyWith(proposedUsage: value));
  });
}
}


/// Adds pattern-matching-related methods to [CodeGenerationValidation].
extension CodeGenerationValidationPatterns on CodeGenerationValidation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CodeGenerationValidation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CodeGenerationValidation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CodeGenerationValidation value)  $default,){
final _that = this;
switch (_that) {
case _CodeGenerationValidation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CodeGenerationValidation value)?  $default,){
final _that = this;
switch (_that) {
case _CodeGenerationValidation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isValid,  List<String>? errors,  List<String>? warnings,  int? estimatedCodeCount,  double? estimatedProcessingTime,  double? estimatedStorageRequired,  bool? willExceedLimits,  SubscriptionUsage? currentUsage,  SubscriptionUsage? proposedUsage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CodeGenerationValidation() when $default != null:
return $default(_that.isValid,_that.errors,_that.warnings,_that.estimatedCodeCount,_that.estimatedProcessingTime,_that.estimatedStorageRequired,_that.willExceedLimits,_that.currentUsage,_that.proposedUsage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isValid,  List<String>? errors,  List<String>? warnings,  int? estimatedCodeCount,  double? estimatedProcessingTime,  double? estimatedStorageRequired,  bool? willExceedLimits,  SubscriptionUsage? currentUsage,  SubscriptionUsage? proposedUsage)  $default,) {final _that = this;
switch (_that) {
case _CodeGenerationValidation():
return $default(_that.isValid,_that.errors,_that.warnings,_that.estimatedCodeCount,_that.estimatedProcessingTime,_that.estimatedStorageRequired,_that.willExceedLimits,_that.currentUsage,_that.proposedUsage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isValid,  List<String>? errors,  List<String>? warnings,  int? estimatedCodeCount,  double? estimatedProcessingTime,  double? estimatedStorageRequired,  bool? willExceedLimits,  SubscriptionUsage? currentUsage,  SubscriptionUsage? proposedUsage)?  $default,) {final _that = this;
switch (_that) {
case _CodeGenerationValidation() when $default != null:
return $default(_that.isValid,_that.errors,_that.warnings,_that.estimatedCodeCount,_that.estimatedProcessingTime,_that.estimatedStorageRequired,_that.willExceedLimits,_that.currentUsage,_that.proposedUsage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CodeGenerationValidation implements CodeGenerationValidation {
  const _CodeGenerationValidation({required this.isValid, final  List<String>? errors, final  List<String>? warnings, this.estimatedCodeCount, this.estimatedProcessingTime, this.estimatedStorageRequired, this.willExceedLimits, this.currentUsage, this.proposedUsage}): _errors = errors,_warnings = warnings;
  factory _CodeGenerationValidation.fromJson(Map<String, dynamic> json) => _$CodeGenerationValidationFromJson(json);

/// Is request valid?
@override final  bool isValid;
/// Validation errors
 final  List<String>? _errors;
/// Validation errors
@override List<String>? get errors {
  final value = _errors;
  if (value == null) return null;
  if (_errors is EqualUnmodifiableListView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// Validation warnings
 final  List<String>? _warnings;
/// Validation warnings
@override List<String>? get warnings {
  final value = _warnings;
  if (value == null) return null;
  if (_warnings is EqualUnmodifiableListView) return _warnings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// Estimated code count
@override final  int? estimatedCodeCount;
/// Estimated processing time in seconds
@override final  double? estimatedProcessingTime;
/// Estimated storage required in KB
@override final  double? estimatedStorageRequired;
/// Will exceed subscription limits?
@override final  bool? willExceedLimits;
/// Current subscription usage
@override final  SubscriptionUsage? currentUsage;
/// Proposed subscription usage after generation
@override final  SubscriptionUsage? proposedUsage;

/// Create a copy of CodeGenerationValidation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CodeGenerationValidationCopyWith<_CodeGenerationValidation> get copyWith => __$CodeGenerationValidationCopyWithImpl<_CodeGenerationValidation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CodeGenerationValidationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CodeGenerationValidation&&(identical(other.isValid, isValid) || other.isValid == isValid)&&const DeepCollectionEquality().equals(other._errors, _errors)&&const DeepCollectionEquality().equals(other._warnings, _warnings)&&(identical(other.estimatedCodeCount, estimatedCodeCount) || other.estimatedCodeCount == estimatedCodeCount)&&(identical(other.estimatedProcessingTime, estimatedProcessingTime) || other.estimatedProcessingTime == estimatedProcessingTime)&&(identical(other.estimatedStorageRequired, estimatedStorageRequired) || other.estimatedStorageRequired == estimatedStorageRequired)&&(identical(other.willExceedLimits, willExceedLimits) || other.willExceedLimits == willExceedLimits)&&(identical(other.currentUsage, currentUsage) || other.currentUsage == currentUsage)&&(identical(other.proposedUsage, proposedUsage) || other.proposedUsage == proposedUsage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isValid,const DeepCollectionEquality().hash(_errors),const DeepCollectionEquality().hash(_warnings),estimatedCodeCount,estimatedProcessingTime,estimatedStorageRequired,willExceedLimits,currentUsage,proposedUsage);

@override
String toString() {
  return 'CodeGenerationValidation(isValid: $isValid, errors: $errors, warnings: $warnings, estimatedCodeCount: $estimatedCodeCount, estimatedProcessingTime: $estimatedProcessingTime, estimatedStorageRequired: $estimatedStorageRequired, willExceedLimits: $willExceedLimits, currentUsage: $currentUsage, proposedUsage: $proposedUsage)';
}


}

/// @nodoc
abstract mixin class _$CodeGenerationValidationCopyWith<$Res> implements $CodeGenerationValidationCopyWith<$Res> {
  factory _$CodeGenerationValidationCopyWith(_CodeGenerationValidation value, $Res Function(_CodeGenerationValidation) _then) = __$CodeGenerationValidationCopyWithImpl;
@override @useResult
$Res call({
 bool isValid, List<String>? errors, List<String>? warnings, int? estimatedCodeCount, double? estimatedProcessingTime, double? estimatedStorageRequired, bool? willExceedLimits, SubscriptionUsage? currentUsage, SubscriptionUsage? proposedUsage
});


@override $SubscriptionUsageCopyWith<$Res>? get currentUsage;@override $SubscriptionUsageCopyWith<$Res>? get proposedUsage;

}
/// @nodoc
class __$CodeGenerationValidationCopyWithImpl<$Res>
    implements _$CodeGenerationValidationCopyWith<$Res> {
  __$CodeGenerationValidationCopyWithImpl(this._self, this._then);

  final _CodeGenerationValidation _self;
  final $Res Function(_CodeGenerationValidation) _then;

/// Create a copy of CodeGenerationValidation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isValid = null,Object? errors = freezed,Object? warnings = freezed,Object? estimatedCodeCount = freezed,Object? estimatedProcessingTime = freezed,Object? estimatedStorageRequired = freezed,Object? willExceedLimits = freezed,Object? currentUsage = freezed,Object? proposedUsage = freezed,}) {
  return _then(_CodeGenerationValidation(
isValid: null == isValid ? _self.isValid : isValid // ignore: cast_nullable_to_non_nullable
as bool,errors: freezed == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as List<String>?,warnings: freezed == warnings ? _self._warnings : warnings // ignore: cast_nullable_to_non_nullable
as List<String>?,estimatedCodeCount: freezed == estimatedCodeCount ? _self.estimatedCodeCount : estimatedCodeCount // ignore: cast_nullable_to_non_nullable
as int?,estimatedProcessingTime: freezed == estimatedProcessingTime ? _self.estimatedProcessingTime : estimatedProcessingTime // ignore: cast_nullable_to_non_nullable
as double?,estimatedStorageRequired: freezed == estimatedStorageRequired ? _self.estimatedStorageRequired : estimatedStorageRequired // ignore: cast_nullable_to_non_nullable
as double?,willExceedLimits: freezed == willExceedLimits ? _self.willExceedLimits : willExceedLimits // ignore: cast_nullable_to_non_nullable
as bool?,currentUsage: freezed == currentUsage ? _self.currentUsage : currentUsage // ignore: cast_nullable_to_non_nullable
as SubscriptionUsage?,proposedUsage: freezed == proposedUsage ? _self.proposedUsage : proposedUsage // ignore: cast_nullable_to_non_nullable
as SubscriptionUsage?,
  ));
}

/// Create a copy of CodeGenerationValidation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubscriptionUsageCopyWith<$Res>? get currentUsage {
    if (_self.currentUsage == null) {
    return null;
  }

  return $SubscriptionUsageCopyWith<$Res>(_self.currentUsage!, (value) {
    return _then(_self.copyWith(currentUsage: value));
  });
}/// Create a copy of CodeGenerationValidation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubscriptionUsageCopyWith<$Res>? get proposedUsage {
    if (_self.proposedUsage == null) {
    return null;
  }

  return $SubscriptionUsageCopyWith<$Res>(_self.proposedUsage!, (value) {
    return _then(_self.copyWith(proposedUsage: value));
  });
}
}


/// @nodoc
mixin _$SubscriptionUsage {

/// Subscription plan ID
 String get planId;/// Plan name
 String get planName;/// Total codes allowed
 int get totalCodesAllowed;/// Codes used so far
 int get codesUsed;/// Codes remaining
 int get codesRemaining;/// Monthly limit
 int? get monthlyLimit;/// Monthly usage
 int? get monthlyUsage;/// Monthly remaining
 int? get monthlyRemaining;/// Reset date for monthly limits
 DateTime? get monthlyResetDate;/// Yearly limit
 int? get yearlyLimit;/// Yearly usage
 int? get yearlyUsage;/// Yearly remaining
 int? get yearlyRemaining;/// Reset date for yearly limits
 DateTime? get yearlyResetDate;/// Is subscription active?
 bool get isActive;/// Expiry date
 DateTime? get expiryDate;/// Days until expiry
 int? get daysUntilExpiry;
/// Create a copy of SubscriptionUsage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionUsageCopyWith<SubscriptionUsage> get copyWith => _$SubscriptionUsageCopyWithImpl<SubscriptionUsage>(this as SubscriptionUsage, _$identity);

  /// Serializes this SubscriptionUsage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionUsage&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.planName, planName) || other.planName == planName)&&(identical(other.totalCodesAllowed, totalCodesAllowed) || other.totalCodesAllowed == totalCodesAllowed)&&(identical(other.codesUsed, codesUsed) || other.codesUsed == codesUsed)&&(identical(other.codesRemaining, codesRemaining) || other.codesRemaining == codesRemaining)&&(identical(other.monthlyLimit, monthlyLimit) || other.monthlyLimit == monthlyLimit)&&(identical(other.monthlyUsage, monthlyUsage) || other.monthlyUsage == monthlyUsage)&&(identical(other.monthlyRemaining, monthlyRemaining) || other.monthlyRemaining == monthlyRemaining)&&(identical(other.monthlyResetDate, monthlyResetDate) || other.monthlyResetDate == monthlyResetDate)&&(identical(other.yearlyLimit, yearlyLimit) || other.yearlyLimit == yearlyLimit)&&(identical(other.yearlyUsage, yearlyUsage) || other.yearlyUsage == yearlyUsage)&&(identical(other.yearlyRemaining, yearlyRemaining) || other.yearlyRemaining == yearlyRemaining)&&(identical(other.yearlyResetDate, yearlyResetDate) || other.yearlyResetDate == yearlyResetDate)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.daysUntilExpiry, daysUntilExpiry) || other.daysUntilExpiry == daysUntilExpiry));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,planId,planName,totalCodesAllowed,codesUsed,codesRemaining,monthlyLimit,monthlyUsage,monthlyRemaining,monthlyResetDate,yearlyLimit,yearlyUsage,yearlyRemaining,yearlyResetDate,isActive,expiryDate,daysUntilExpiry);

@override
String toString() {
  return 'SubscriptionUsage(planId: $planId, planName: $planName, totalCodesAllowed: $totalCodesAllowed, codesUsed: $codesUsed, codesRemaining: $codesRemaining, monthlyLimit: $monthlyLimit, monthlyUsage: $monthlyUsage, monthlyRemaining: $monthlyRemaining, monthlyResetDate: $monthlyResetDate, yearlyLimit: $yearlyLimit, yearlyUsage: $yearlyUsage, yearlyRemaining: $yearlyRemaining, yearlyResetDate: $yearlyResetDate, isActive: $isActive, expiryDate: $expiryDate, daysUntilExpiry: $daysUntilExpiry)';
}


}

/// @nodoc
abstract mixin class $SubscriptionUsageCopyWith<$Res>  {
  factory $SubscriptionUsageCopyWith(SubscriptionUsage value, $Res Function(SubscriptionUsage) _then) = _$SubscriptionUsageCopyWithImpl;
@useResult
$Res call({
 String planId, String planName, int totalCodesAllowed, int codesUsed, int codesRemaining, int? monthlyLimit, int? monthlyUsage, int? monthlyRemaining, DateTime? monthlyResetDate, int? yearlyLimit, int? yearlyUsage, int? yearlyRemaining, DateTime? yearlyResetDate, bool isActive, DateTime? expiryDate, int? daysUntilExpiry
});




}
/// @nodoc
class _$SubscriptionUsageCopyWithImpl<$Res>
    implements $SubscriptionUsageCopyWith<$Res> {
  _$SubscriptionUsageCopyWithImpl(this._self, this._then);

  final SubscriptionUsage _self;
  final $Res Function(SubscriptionUsage) _then;

/// Create a copy of SubscriptionUsage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? planId = null,Object? planName = null,Object? totalCodesAllowed = null,Object? codesUsed = null,Object? codesRemaining = null,Object? monthlyLimit = freezed,Object? monthlyUsage = freezed,Object? monthlyRemaining = freezed,Object? monthlyResetDate = freezed,Object? yearlyLimit = freezed,Object? yearlyUsage = freezed,Object? yearlyRemaining = freezed,Object? yearlyResetDate = freezed,Object? isActive = null,Object? expiryDate = freezed,Object? daysUntilExpiry = freezed,}) {
  return _then(_self.copyWith(
planId: null == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String,planName: null == planName ? _self.planName : planName // ignore: cast_nullable_to_non_nullable
as String,totalCodesAllowed: null == totalCodesAllowed ? _self.totalCodesAllowed : totalCodesAllowed // ignore: cast_nullable_to_non_nullable
as int,codesUsed: null == codesUsed ? _self.codesUsed : codesUsed // ignore: cast_nullable_to_non_nullable
as int,codesRemaining: null == codesRemaining ? _self.codesRemaining : codesRemaining // ignore: cast_nullable_to_non_nullable
as int,monthlyLimit: freezed == monthlyLimit ? _self.monthlyLimit : monthlyLimit // ignore: cast_nullable_to_non_nullable
as int?,monthlyUsage: freezed == monthlyUsage ? _self.monthlyUsage : monthlyUsage // ignore: cast_nullable_to_non_nullable
as int?,monthlyRemaining: freezed == monthlyRemaining ? _self.monthlyRemaining : monthlyRemaining // ignore: cast_nullable_to_non_nullable
as int?,monthlyResetDate: freezed == monthlyResetDate ? _self.monthlyResetDate : monthlyResetDate // ignore: cast_nullable_to_non_nullable
as DateTime?,yearlyLimit: freezed == yearlyLimit ? _self.yearlyLimit : yearlyLimit // ignore: cast_nullable_to_non_nullable
as int?,yearlyUsage: freezed == yearlyUsage ? _self.yearlyUsage : yearlyUsage // ignore: cast_nullable_to_non_nullable
as int?,yearlyRemaining: freezed == yearlyRemaining ? _self.yearlyRemaining : yearlyRemaining // ignore: cast_nullable_to_non_nullable
as int?,yearlyResetDate: freezed == yearlyResetDate ? _self.yearlyResetDate : yearlyResetDate // ignore: cast_nullable_to_non_nullable
as DateTime?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,daysUntilExpiry: freezed == daysUntilExpiry ? _self.daysUntilExpiry : daysUntilExpiry // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [SubscriptionUsage].
extension SubscriptionUsagePatterns on SubscriptionUsage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionUsage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionUsage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionUsage value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionUsage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionUsage value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionUsage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String planId,  String planName,  int totalCodesAllowed,  int codesUsed,  int codesRemaining,  int? monthlyLimit,  int? monthlyUsage,  int? monthlyRemaining,  DateTime? monthlyResetDate,  int? yearlyLimit,  int? yearlyUsage,  int? yearlyRemaining,  DateTime? yearlyResetDate,  bool isActive,  DateTime? expiryDate,  int? daysUntilExpiry)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionUsage() when $default != null:
return $default(_that.planId,_that.planName,_that.totalCodesAllowed,_that.codesUsed,_that.codesRemaining,_that.monthlyLimit,_that.monthlyUsage,_that.monthlyRemaining,_that.monthlyResetDate,_that.yearlyLimit,_that.yearlyUsage,_that.yearlyRemaining,_that.yearlyResetDate,_that.isActive,_that.expiryDate,_that.daysUntilExpiry);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String planId,  String planName,  int totalCodesAllowed,  int codesUsed,  int codesRemaining,  int? monthlyLimit,  int? monthlyUsage,  int? monthlyRemaining,  DateTime? monthlyResetDate,  int? yearlyLimit,  int? yearlyUsage,  int? yearlyRemaining,  DateTime? yearlyResetDate,  bool isActive,  DateTime? expiryDate,  int? daysUntilExpiry)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionUsage():
return $default(_that.planId,_that.planName,_that.totalCodesAllowed,_that.codesUsed,_that.codesRemaining,_that.monthlyLimit,_that.monthlyUsage,_that.monthlyRemaining,_that.monthlyResetDate,_that.yearlyLimit,_that.yearlyUsage,_that.yearlyRemaining,_that.yearlyResetDate,_that.isActive,_that.expiryDate,_that.daysUntilExpiry);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String planId,  String planName,  int totalCodesAllowed,  int codesUsed,  int codesRemaining,  int? monthlyLimit,  int? monthlyUsage,  int? monthlyRemaining,  DateTime? monthlyResetDate,  int? yearlyLimit,  int? yearlyUsage,  int? yearlyRemaining,  DateTime? yearlyResetDate,  bool isActive,  DateTime? expiryDate,  int? daysUntilExpiry)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionUsage() when $default != null:
return $default(_that.planId,_that.planName,_that.totalCodesAllowed,_that.codesUsed,_that.codesRemaining,_that.monthlyLimit,_that.monthlyUsage,_that.monthlyRemaining,_that.monthlyResetDate,_that.yearlyLimit,_that.yearlyUsage,_that.yearlyRemaining,_that.yearlyResetDate,_that.isActive,_that.expiryDate,_that.daysUntilExpiry);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubscriptionUsage implements SubscriptionUsage {
  const _SubscriptionUsage({required this.planId, required this.planName, required this.totalCodesAllowed, required this.codesUsed, required this.codesRemaining, this.monthlyLimit, this.monthlyUsage, this.monthlyRemaining, this.monthlyResetDate, this.yearlyLimit, this.yearlyUsage, this.yearlyRemaining, this.yearlyResetDate, required this.isActive, this.expiryDate, this.daysUntilExpiry});
  factory _SubscriptionUsage.fromJson(Map<String, dynamic> json) => _$SubscriptionUsageFromJson(json);

/// Subscription plan ID
@override final  String planId;
/// Plan name
@override final  String planName;
/// Total codes allowed
@override final  int totalCodesAllowed;
/// Codes used so far
@override final  int codesUsed;
/// Codes remaining
@override final  int codesRemaining;
/// Monthly limit
@override final  int? monthlyLimit;
/// Monthly usage
@override final  int? monthlyUsage;
/// Monthly remaining
@override final  int? monthlyRemaining;
/// Reset date for monthly limits
@override final  DateTime? monthlyResetDate;
/// Yearly limit
@override final  int? yearlyLimit;
/// Yearly usage
@override final  int? yearlyUsage;
/// Yearly remaining
@override final  int? yearlyRemaining;
/// Reset date for yearly limits
@override final  DateTime? yearlyResetDate;
/// Is subscription active?
@override final  bool isActive;
/// Expiry date
@override final  DateTime? expiryDate;
/// Days until expiry
@override final  int? daysUntilExpiry;

/// Create a copy of SubscriptionUsage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionUsageCopyWith<_SubscriptionUsage> get copyWith => __$SubscriptionUsageCopyWithImpl<_SubscriptionUsage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubscriptionUsageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionUsage&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.planName, planName) || other.planName == planName)&&(identical(other.totalCodesAllowed, totalCodesAllowed) || other.totalCodesAllowed == totalCodesAllowed)&&(identical(other.codesUsed, codesUsed) || other.codesUsed == codesUsed)&&(identical(other.codesRemaining, codesRemaining) || other.codesRemaining == codesRemaining)&&(identical(other.monthlyLimit, monthlyLimit) || other.monthlyLimit == monthlyLimit)&&(identical(other.monthlyUsage, monthlyUsage) || other.monthlyUsage == monthlyUsage)&&(identical(other.monthlyRemaining, monthlyRemaining) || other.monthlyRemaining == monthlyRemaining)&&(identical(other.monthlyResetDate, monthlyResetDate) || other.monthlyResetDate == monthlyResetDate)&&(identical(other.yearlyLimit, yearlyLimit) || other.yearlyLimit == yearlyLimit)&&(identical(other.yearlyUsage, yearlyUsage) || other.yearlyUsage == yearlyUsage)&&(identical(other.yearlyRemaining, yearlyRemaining) || other.yearlyRemaining == yearlyRemaining)&&(identical(other.yearlyResetDate, yearlyResetDate) || other.yearlyResetDate == yearlyResetDate)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.daysUntilExpiry, daysUntilExpiry) || other.daysUntilExpiry == daysUntilExpiry));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,planId,planName,totalCodesAllowed,codesUsed,codesRemaining,monthlyLimit,monthlyUsage,monthlyRemaining,monthlyResetDate,yearlyLimit,yearlyUsage,yearlyRemaining,yearlyResetDate,isActive,expiryDate,daysUntilExpiry);

@override
String toString() {
  return 'SubscriptionUsage(planId: $planId, planName: $planName, totalCodesAllowed: $totalCodesAllowed, codesUsed: $codesUsed, codesRemaining: $codesRemaining, monthlyLimit: $monthlyLimit, monthlyUsage: $monthlyUsage, monthlyRemaining: $monthlyRemaining, monthlyResetDate: $monthlyResetDate, yearlyLimit: $yearlyLimit, yearlyUsage: $yearlyUsage, yearlyRemaining: $yearlyRemaining, yearlyResetDate: $yearlyResetDate, isActive: $isActive, expiryDate: $expiryDate, daysUntilExpiry: $daysUntilExpiry)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionUsageCopyWith<$Res> implements $SubscriptionUsageCopyWith<$Res> {
  factory _$SubscriptionUsageCopyWith(_SubscriptionUsage value, $Res Function(_SubscriptionUsage) _then) = __$SubscriptionUsageCopyWithImpl;
@override @useResult
$Res call({
 String planId, String planName, int totalCodesAllowed, int codesUsed, int codesRemaining, int? monthlyLimit, int? monthlyUsage, int? monthlyRemaining, DateTime? monthlyResetDate, int? yearlyLimit, int? yearlyUsage, int? yearlyRemaining, DateTime? yearlyResetDate, bool isActive, DateTime? expiryDate, int? daysUntilExpiry
});




}
/// @nodoc
class __$SubscriptionUsageCopyWithImpl<$Res>
    implements _$SubscriptionUsageCopyWith<$Res> {
  __$SubscriptionUsageCopyWithImpl(this._self, this._then);

  final _SubscriptionUsage _self;
  final $Res Function(_SubscriptionUsage) _then;

/// Create a copy of SubscriptionUsage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? planId = null,Object? planName = null,Object? totalCodesAllowed = null,Object? codesUsed = null,Object? codesRemaining = null,Object? monthlyLimit = freezed,Object? monthlyUsage = freezed,Object? monthlyRemaining = freezed,Object? monthlyResetDate = freezed,Object? yearlyLimit = freezed,Object? yearlyUsage = freezed,Object? yearlyRemaining = freezed,Object? yearlyResetDate = freezed,Object? isActive = null,Object? expiryDate = freezed,Object? daysUntilExpiry = freezed,}) {
  return _then(_SubscriptionUsage(
planId: null == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String,planName: null == planName ? _self.planName : planName // ignore: cast_nullable_to_non_nullable
as String,totalCodesAllowed: null == totalCodesAllowed ? _self.totalCodesAllowed : totalCodesAllowed // ignore: cast_nullable_to_non_nullable
as int,codesUsed: null == codesUsed ? _self.codesUsed : codesUsed // ignore: cast_nullable_to_non_nullable
as int,codesRemaining: null == codesRemaining ? _self.codesRemaining : codesRemaining // ignore: cast_nullable_to_non_nullable
as int,monthlyLimit: freezed == monthlyLimit ? _self.monthlyLimit : monthlyLimit // ignore: cast_nullable_to_non_nullable
as int?,monthlyUsage: freezed == monthlyUsage ? _self.monthlyUsage : monthlyUsage // ignore: cast_nullable_to_non_nullable
as int?,monthlyRemaining: freezed == monthlyRemaining ? _self.monthlyRemaining : monthlyRemaining // ignore: cast_nullable_to_non_nullable
as int?,monthlyResetDate: freezed == monthlyResetDate ? _self.monthlyResetDate : monthlyResetDate // ignore: cast_nullable_to_non_nullable
as DateTime?,yearlyLimit: freezed == yearlyLimit ? _self.yearlyLimit : yearlyLimit // ignore: cast_nullable_to_non_nullable
as int?,yearlyUsage: freezed == yearlyUsage ? _self.yearlyUsage : yearlyUsage // ignore: cast_nullable_to_non_nullable
as int?,yearlyRemaining: freezed == yearlyRemaining ? _self.yearlyRemaining : yearlyRemaining // ignore: cast_nullable_to_non_nullable
as int?,yearlyResetDate: freezed == yearlyResetDate ? _self.yearlyResetDate : yearlyResetDate // ignore: cast_nullable_to_non_nullable
as DateTime?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,daysUntilExpiry: freezed == daysUntilExpiry ? _self.daysUntilExpiry : daysUntilExpiry // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on

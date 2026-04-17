// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bundle_code_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BundleCodeModel {

/// Base code properties
@HiveField(0) String get id;@HiveField(1) String get code;@HiveField(2) CodeType get type;@HiveField(3) CodeStatus get status;@HiveField(4) String get factoryId;@HiveField(5) String get subscriptionPlanId;@HiveField(6) String get storeKeeperCode;@HiveField(7) String get internationalCode;@HiveField(8) String get batchId;@HiveField(9)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime get generatedAt;@HiveField(10) DateTime? get linkedAt;@HiveField(11) DateTime? get publishedAt;@HiveField(12) DateTime? get deactivatedAt;@HiveField(13) String? get productId;@HiveField(14) String? get productBatchNumber;@HiveField(15) DateTime? get manufacturingDate;@HiveField(16) DateTime? get expiryDate;@HiveField(17) int? get warrantyMonths;@HiveField(18) String? get qrCodeData;@HiveField(19) String? get barcodeData;@HiveField(20) String? get metadata;@HiveField(21) int get version;@HiveField(22)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime get createdAt;@HiveField(23)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime get updatedAt;@HiveField(24) bool get isDeleted;/// Bundle-specific properties
/// Number of cartons in this bundle
@HiveField(25) int get cartonCount;/// List of carton codes contained in this bundle
@HiveField(26) List<String> get cartonCodes;/// Bundle weight in kilograms
@HiveField(27) double? get weight;/// Bundle dimensions (length x width x height in cm)
@HiveField(28) String? get dimensions;/// Storage location in warehouse
@HiveField(29) String? get storageLocation;/// Shipping method for this bundle
@HiveField(30) String? get shippingMethod;/// Expected delivery date
@HiveField(31) DateTime? get expectedDeliveryDate;/// Actual delivery date
@HiveField(32) DateTime? get actualDeliveryDate;/// Bundle sequence number (e.g., 1, 2, 3...)
@HiveField(33) int get sequenceNumber;/// Total units in this bundle (calculated: cartonCount * packetsPerCarton * unitsPerPacket)
@HiveField(34) int get totalUnits;/// Bundle category (e.g., "Electronics", "Food", "Medical")
@HiveField(35) String? get category;/// Special handling instructions
@HiveField(36) String? get handlingInstructions;/// Customs declaration number (for international shipping)
@HiveField(37) String? get customsDeclarationNumber;/// Insurance value of the bundle
@HiveField(38) double? get insuranceValue;/// Bundle priority (1=High, 2=Medium, 3=Low)
@HiveField(39) int get priority;
/// Create a copy of BundleCodeModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BundleCodeModelCopyWith<BundleCodeModel> get copyWith => _$BundleCodeModelCopyWithImpl<BundleCodeModel>(this as BundleCodeModel, _$identity);

  /// Serializes this BundleCodeModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BundleCodeModel&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.factoryId, factoryId) || other.factoryId == factoryId)&&(identical(other.subscriptionPlanId, subscriptionPlanId) || other.subscriptionPlanId == subscriptionPlanId)&&(identical(other.storeKeeperCode, storeKeeperCode) || other.storeKeeperCode == storeKeeperCode)&&(identical(other.internationalCode, internationalCode) || other.internationalCode == internationalCode)&&(identical(other.batchId, batchId) || other.batchId == batchId)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.linkedAt, linkedAt) || other.linkedAt == linkedAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.deactivatedAt, deactivatedAt) || other.deactivatedAt == deactivatedAt)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productBatchNumber, productBatchNumber) || other.productBatchNumber == productBatchNumber)&&(identical(other.manufacturingDate, manufacturingDate) || other.manufacturingDate == manufacturingDate)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.warrantyMonths, warrantyMonths) || other.warrantyMonths == warrantyMonths)&&(identical(other.qrCodeData, qrCodeData) || other.qrCodeData == qrCodeData)&&(identical(other.barcodeData, barcodeData) || other.barcodeData == barcodeData)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.version, version) || other.version == version)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.cartonCount, cartonCount) || other.cartonCount == cartonCount)&&const DeepCollectionEquality().equals(other.cartonCodes, cartonCodes)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.dimensions, dimensions) || other.dimensions == dimensions)&&(identical(other.storageLocation, storageLocation) || other.storageLocation == storageLocation)&&(identical(other.shippingMethod, shippingMethod) || other.shippingMethod == shippingMethod)&&(identical(other.expectedDeliveryDate, expectedDeliveryDate) || other.expectedDeliveryDate == expectedDeliveryDate)&&(identical(other.actualDeliveryDate, actualDeliveryDate) || other.actualDeliveryDate == actualDeliveryDate)&&(identical(other.sequenceNumber, sequenceNumber) || other.sequenceNumber == sequenceNumber)&&(identical(other.totalUnits, totalUnits) || other.totalUnits == totalUnits)&&(identical(other.category, category) || other.category == category)&&(identical(other.handlingInstructions, handlingInstructions) || other.handlingInstructions == handlingInstructions)&&(identical(other.customsDeclarationNumber, customsDeclarationNumber) || other.customsDeclarationNumber == customsDeclarationNumber)&&(identical(other.insuranceValue, insuranceValue) || other.insuranceValue == insuranceValue)&&(identical(other.priority, priority) || other.priority == priority));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,code,type,status,factoryId,subscriptionPlanId,storeKeeperCode,internationalCode,batchId,generatedAt,linkedAt,publishedAt,deactivatedAt,productId,productBatchNumber,manufacturingDate,expiryDate,warrantyMonths,qrCodeData,barcodeData,metadata,version,createdAt,updatedAt,isDeleted,cartonCount,const DeepCollectionEquality().hash(cartonCodes),weight,dimensions,storageLocation,shippingMethod,expectedDeliveryDate,actualDeliveryDate,sequenceNumber,totalUnits,category,handlingInstructions,customsDeclarationNumber,insuranceValue,priority]);

@override
String toString() {
  return 'BundleCodeModel(id: $id, code: $code, type: $type, status: $status, factoryId: $factoryId, subscriptionPlanId: $subscriptionPlanId, storeKeeperCode: $storeKeeperCode, internationalCode: $internationalCode, batchId: $batchId, generatedAt: $generatedAt, linkedAt: $linkedAt, publishedAt: $publishedAt, deactivatedAt: $deactivatedAt, productId: $productId, productBatchNumber: $productBatchNumber, manufacturingDate: $manufacturingDate, expiryDate: $expiryDate, warrantyMonths: $warrantyMonths, qrCodeData: $qrCodeData, barcodeData: $barcodeData, metadata: $metadata, version: $version, createdAt: $createdAt, updatedAt: $updatedAt, isDeleted: $isDeleted, cartonCount: $cartonCount, cartonCodes: $cartonCodes, weight: $weight, dimensions: $dimensions, storageLocation: $storageLocation, shippingMethod: $shippingMethod, expectedDeliveryDate: $expectedDeliveryDate, actualDeliveryDate: $actualDeliveryDate, sequenceNumber: $sequenceNumber, totalUnits: $totalUnits, category: $category, handlingInstructions: $handlingInstructions, customsDeclarationNumber: $customsDeclarationNumber, insuranceValue: $insuranceValue, priority: $priority)';
}


}

/// @nodoc
abstract mixin class $BundleCodeModelCopyWith<$Res>  {
  factory $BundleCodeModelCopyWith(BundleCodeModel value, $Res Function(BundleCodeModel) _then) = _$BundleCodeModelCopyWithImpl;
@useResult
$Res call({
@HiveField(0) String id,@HiveField(1) String code,@HiveField(2) CodeType type,@HiveField(3) CodeStatus status,@HiveField(4) String factoryId,@HiveField(5) String subscriptionPlanId,@HiveField(6) String storeKeeperCode,@HiveField(7) String internationalCode,@HiveField(8) String batchId,@HiveField(9)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime generatedAt,@HiveField(10) DateTime? linkedAt,@HiveField(11) DateTime? publishedAt,@HiveField(12) DateTime? deactivatedAt,@HiveField(13) String? productId,@HiveField(14) String? productBatchNumber,@HiveField(15) DateTime? manufacturingDate,@HiveField(16) DateTime? expiryDate,@HiveField(17) int? warrantyMonths,@HiveField(18) String? qrCodeData,@HiveField(19) String? barcodeData,@HiveField(20) String? metadata,@HiveField(21) int version,@HiveField(22)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime createdAt,@HiveField(23)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime updatedAt,@HiveField(24) bool isDeleted,@HiveField(25) int cartonCount,@HiveField(26) List<String> cartonCodes,@HiveField(27) double? weight,@HiveField(28) String? dimensions,@HiveField(29) String? storageLocation,@HiveField(30) String? shippingMethod,@HiveField(31) DateTime? expectedDeliveryDate,@HiveField(32) DateTime? actualDeliveryDate,@HiveField(33) int sequenceNumber,@HiveField(34) int totalUnits,@HiveField(35) String? category,@HiveField(36) String? handlingInstructions,@HiveField(37) String? customsDeclarationNumber,@HiveField(38) double? insuranceValue,@HiveField(39) int priority
});




}
/// @nodoc
class _$BundleCodeModelCopyWithImpl<$Res>
    implements $BundleCodeModelCopyWith<$Res> {
  _$BundleCodeModelCopyWithImpl(this._self, this._then);

  final BundleCodeModel _self;
  final $Res Function(BundleCodeModel) _then;

/// Create a copy of BundleCodeModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? type = null,Object? status = null,Object? factoryId = null,Object? subscriptionPlanId = null,Object? storeKeeperCode = null,Object? internationalCode = null,Object? batchId = null,Object? generatedAt = null,Object? linkedAt = freezed,Object? publishedAt = freezed,Object? deactivatedAt = freezed,Object? productId = freezed,Object? productBatchNumber = freezed,Object? manufacturingDate = freezed,Object? expiryDate = freezed,Object? warrantyMonths = freezed,Object? qrCodeData = freezed,Object? barcodeData = freezed,Object? metadata = freezed,Object? version = null,Object? createdAt = null,Object? updatedAt = null,Object? isDeleted = null,Object? cartonCount = null,Object? cartonCodes = null,Object? weight = freezed,Object? dimensions = freezed,Object? storageLocation = freezed,Object? shippingMethod = freezed,Object? expectedDeliveryDate = freezed,Object? actualDeliveryDate = freezed,Object? sequenceNumber = null,Object? totalUnits = null,Object? category = freezed,Object? handlingInstructions = freezed,Object? customsDeclarationNumber = freezed,Object? insuranceValue = freezed,Object? priority = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CodeType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CodeStatus,factoryId: null == factoryId ? _self.factoryId : factoryId // ignore: cast_nullable_to_non_nullable
as String,subscriptionPlanId: null == subscriptionPlanId ? _self.subscriptionPlanId : subscriptionPlanId // ignore: cast_nullable_to_non_nullable
as String,storeKeeperCode: null == storeKeeperCode ? _self.storeKeeperCode : storeKeeperCode // ignore: cast_nullable_to_non_nullable
as String,internationalCode: null == internationalCode ? _self.internationalCode : internationalCode // ignore: cast_nullable_to_non_nullable
as String,batchId: null == batchId ? _self.batchId : batchId // ignore: cast_nullable_to_non_nullable
as String,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,linkedAt: freezed == linkedAt ? _self.linkedAt : linkedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deactivatedAt: freezed == deactivatedAt ? _self.deactivatedAt : deactivatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,productBatchNumber: freezed == productBatchNumber ? _self.productBatchNumber : productBatchNumber // ignore: cast_nullable_to_non_nullable
as String?,manufacturingDate: freezed == manufacturingDate ? _self.manufacturingDate : manufacturingDate // ignore: cast_nullable_to_non_nullable
as DateTime?,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,warrantyMonths: freezed == warrantyMonths ? _self.warrantyMonths : warrantyMonths // ignore: cast_nullable_to_non_nullable
as int?,qrCodeData: freezed == qrCodeData ? _self.qrCodeData : qrCodeData // ignore: cast_nullable_to_non_nullable
as String?,barcodeData: freezed == barcodeData ? _self.barcodeData : barcodeData // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as String?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,cartonCount: null == cartonCount ? _self.cartonCount : cartonCount // ignore: cast_nullable_to_non_nullable
as int,cartonCodes: null == cartonCodes ? _self.cartonCodes : cartonCodes // ignore: cast_nullable_to_non_nullable
as List<String>,weight: freezed == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double?,dimensions: freezed == dimensions ? _self.dimensions : dimensions // ignore: cast_nullable_to_non_nullable
as String?,storageLocation: freezed == storageLocation ? _self.storageLocation : storageLocation // ignore: cast_nullable_to_non_nullable
as String?,shippingMethod: freezed == shippingMethod ? _self.shippingMethod : shippingMethod // ignore: cast_nullable_to_non_nullable
as String?,expectedDeliveryDate: freezed == expectedDeliveryDate ? _self.expectedDeliveryDate : expectedDeliveryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,actualDeliveryDate: freezed == actualDeliveryDate ? _self.actualDeliveryDate : actualDeliveryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,sequenceNumber: null == sequenceNumber ? _self.sequenceNumber : sequenceNumber // ignore: cast_nullable_to_non_nullable
as int,totalUnits: null == totalUnits ? _self.totalUnits : totalUnits // ignore: cast_nullable_to_non_nullable
as int,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,handlingInstructions: freezed == handlingInstructions ? _self.handlingInstructions : handlingInstructions // ignore: cast_nullable_to_non_nullable
as String?,customsDeclarationNumber: freezed == customsDeclarationNumber ? _self.customsDeclarationNumber : customsDeclarationNumber // ignore: cast_nullable_to_non_nullable
as String?,insuranceValue: freezed == insuranceValue ? _self.insuranceValue : insuranceValue // ignore: cast_nullable_to_non_nullable
as double?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [BundleCodeModel].
extension BundleCodeModelPatterns on BundleCodeModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BundleCodeModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BundleCodeModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BundleCodeModel value)  $default,){
final _that = this;
switch (_that) {
case _BundleCodeModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BundleCodeModel value)?  $default,){
final _that = this;
switch (_that) {
case _BundleCodeModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@HiveField(0)  String id, @HiveField(1)  String code, @HiveField(2)  CodeType type, @HiveField(3)  CodeStatus status, @HiveField(4)  String factoryId, @HiveField(5)  String subscriptionPlanId, @HiveField(6)  String storeKeeperCode, @HiveField(7)  String internationalCode, @HiveField(8)  String batchId, @HiveField(9)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime generatedAt, @HiveField(10)  DateTime? linkedAt, @HiveField(11)  DateTime? publishedAt, @HiveField(12)  DateTime? deactivatedAt, @HiveField(13)  String? productId, @HiveField(14)  String? productBatchNumber, @HiveField(15)  DateTime? manufacturingDate, @HiveField(16)  DateTime? expiryDate, @HiveField(17)  int? warrantyMonths, @HiveField(18)  String? qrCodeData, @HiveField(19)  String? barcodeData, @HiveField(20)  String? metadata, @HiveField(21)  int version, @HiveField(22)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime createdAt, @HiveField(23)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime updatedAt, @HiveField(24)  bool isDeleted, @HiveField(25)  int cartonCount, @HiveField(26)  List<String> cartonCodes, @HiveField(27)  double? weight, @HiveField(28)  String? dimensions, @HiveField(29)  String? storageLocation, @HiveField(30)  String? shippingMethod, @HiveField(31)  DateTime? expectedDeliveryDate, @HiveField(32)  DateTime? actualDeliveryDate, @HiveField(33)  int sequenceNumber, @HiveField(34)  int totalUnits, @HiveField(35)  String? category, @HiveField(36)  String? handlingInstructions, @HiveField(37)  String? customsDeclarationNumber, @HiveField(38)  double? insuranceValue, @HiveField(39)  int priority)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BundleCodeModel() when $default != null:
return $default(_that.id,_that.code,_that.type,_that.status,_that.factoryId,_that.subscriptionPlanId,_that.storeKeeperCode,_that.internationalCode,_that.batchId,_that.generatedAt,_that.linkedAt,_that.publishedAt,_that.deactivatedAt,_that.productId,_that.productBatchNumber,_that.manufacturingDate,_that.expiryDate,_that.warrantyMonths,_that.qrCodeData,_that.barcodeData,_that.metadata,_that.version,_that.createdAt,_that.updatedAt,_that.isDeleted,_that.cartonCount,_that.cartonCodes,_that.weight,_that.dimensions,_that.storageLocation,_that.shippingMethod,_that.expectedDeliveryDate,_that.actualDeliveryDate,_that.sequenceNumber,_that.totalUnits,_that.category,_that.handlingInstructions,_that.customsDeclarationNumber,_that.insuranceValue,_that.priority);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@HiveField(0)  String id, @HiveField(1)  String code, @HiveField(2)  CodeType type, @HiveField(3)  CodeStatus status, @HiveField(4)  String factoryId, @HiveField(5)  String subscriptionPlanId, @HiveField(6)  String storeKeeperCode, @HiveField(7)  String internationalCode, @HiveField(8)  String batchId, @HiveField(9)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime generatedAt, @HiveField(10)  DateTime? linkedAt, @HiveField(11)  DateTime? publishedAt, @HiveField(12)  DateTime? deactivatedAt, @HiveField(13)  String? productId, @HiveField(14)  String? productBatchNumber, @HiveField(15)  DateTime? manufacturingDate, @HiveField(16)  DateTime? expiryDate, @HiveField(17)  int? warrantyMonths, @HiveField(18)  String? qrCodeData, @HiveField(19)  String? barcodeData, @HiveField(20)  String? metadata, @HiveField(21)  int version, @HiveField(22)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime createdAt, @HiveField(23)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime updatedAt, @HiveField(24)  bool isDeleted, @HiveField(25)  int cartonCount, @HiveField(26)  List<String> cartonCodes, @HiveField(27)  double? weight, @HiveField(28)  String? dimensions, @HiveField(29)  String? storageLocation, @HiveField(30)  String? shippingMethod, @HiveField(31)  DateTime? expectedDeliveryDate, @HiveField(32)  DateTime? actualDeliveryDate, @HiveField(33)  int sequenceNumber, @HiveField(34)  int totalUnits, @HiveField(35)  String? category, @HiveField(36)  String? handlingInstructions, @HiveField(37)  String? customsDeclarationNumber, @HiveField(38)  double? insuranceValue, @HiveField(39)  int priority)  $default,) {final _that = this;
switch (_that) {
case _BundleCodeModel():
return $default(_that.id,_that.code,_that.type,_that.status,_that.factoryId,_that.subscriptionPlanId,_that.storeKeeperCode,_that.internationalCode,_that.batchId,_that.generatedAt,_that.linkedAt,_that.publishedAt,_that.deactivatedAt,_that.productId,_that.productBatchNumber,_that.manufacturingDate,_that.expiryDate,_that.warrantyMonths,_that.qrCodeData,_that.barcodeData,_that.metadata,_that.version,_that.createdAt,_that.updatedAt,_that.isDeleted,_that.cartonCount,_that.cartonCodes,_that.weight,_that.dimensions,_that.storageLocation,_that.shippingMethod,_that.expectedDeliveryDate,_that.actualDeliveryDate,_that.sequenceNumber,_that.totalUnits,_that.category,_that.handlingInstructions,_that.customsDeclarationNumber,_that.insuranceValue,_that.priority);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@HiveField(0)  String id, @HiveField(1)  String code, @HiveField(2)  CodeType type, @HiveField(3)  CodeStatus status, @HiveField(4)  String factoryId, @HiveField(5)  String subscriptionPlanId, @HiveField(6)  String storeKeeperCode, @HiveField(7)  String internationalCode, @HiveField(8)  String batchId, @HiveField(9)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime generatedAt, @HiveField(10)  DateTime? linkedAt, @HiveField(11)  DateTime? publishedAt, @HiveField(12)  DateTime? deactivatedAt, @HiveField(13)  String? productId, @HiveField(14)  String? productBatchNumber, @HiveField(15)  DateTime? manufacturingDate, @HiveField(16)  DateTime? expiryDate, @HiveField(17)  int? warrantyMonths, @HiveField(18)  String? qrCodeData, @HiveField(19)  String? barcodeData, @HiveField(20)  String? metadata, @HiveField(21)  int version, @HiveField(22)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime createdAt, @HiveField(23)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime updatedAt, @HiveField(24)  bool isDeleted, @HiveField(25)  int cartonCount, @HiveField(26)  List<String> cartonCodes, @HiveField(27)  double? weight, @HiveField(28)  String? dimensions, @HiveField(29)  String? storageLocation, @HiveField(30)  String? shippingMethod, @HiveField(31)  DateTime? expectedDeliveryDate, @HiveField(32)  DateTime? actualDeliveryDate, @HiveField(33)  int sequenceNumber, @HiveField(34)  int totalUnits, @HiveField(35)  String? category, @HiveField(36)  String? handlingInstructions, @HiveField(37)  String? customsDeclarationNumber, @HiveField(38)  double? insuranceValue, @HiveField(39)  int priority)?  $default,) {final _that = this;
switch (_that) {
case _BundleCodeModel() when $default != null:
return $default(_that.id,_that.code,_that.type,_that.status,_that.factoryId,_that.subscriptionPlanId,_that.storeKeeperCode,_that.internationalCode,_that.batchId,_that.generatedAt,_that.linkedAt,_that.publishedAt,_that.deactivatedAt,_that.productId,_that.productBatchNumber,_that.manufacturingDate,_that.expiryDate,_that.warrantyMonths,_that.qrCodeData,_that.barcodeData,_that.metadata,_that.version,_that.createdAt,_that.updatedAt,_that.isDeleted,_that.cartonCount,_that.cartonCodes,_that.weight,_that.dimensions,_that.storageLocation,_that.shippingMethod,_that.expectedDeliveryDate,_that.actualDeliveryDate,_that.sequenceNumber,_that.totalUnits,_that.category,_that.handlingInstructions,_that.customsDeclarationNumber,_that.insuranceValue,_that.priority);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BundleCodeModel extends BundleCodeModel {
  const _BundleCodeModel({@HiveField(0) required this.id, @HiveField(1) required this.code, @HiveField(2) this.type = CodeType.bundle, @HiveField(3) this.status = CodeStatus.generated, @HiveField(4) this.factoryId = '', @HiveField(5) this.subscriptionPlanId = '', @HiveField(6) this.storeKeeperCode = '', @HiveField(7) this.internationalCode = '', @HiveField(8) this.batchId = '', @HiveField(9)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) required this.generatedAt, @HiveField(10) this.linkedAt, @HiveField(11) this.publishedAt, @HiveField(12) this.deactivatedAt, @HiveField(13) this.productId, @HiveField(14) this.productBatchNumber, @HiveField(15) this.manufacturingDate, @HiveField(16) this.expiryDate, @HiveField(17) this.warrantyMonths, @HiveField(18) this.qrCodeData, @HiveField(19) this.barcodeData, @HiveField(20) this.metadata, @HiveField(21) this.version = 1, @HiveField(22)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) required this.createdAt, @HiveField(23)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) required this.updatedAt, @HiveField(24) this.isDeleted = false, @HiveField(25) this.cartonCount = 0, @HiveField(26) final  List<String> cartonCodes = const <String>[], @HiveField(27) this.weight, @HiveField(28) this.dimensions, @HiveField(29) this.storageLocation, @HiveField(30) this.shippingMethod, @HiveField(31) this.expectedDeliveryDate, @HiveField(32) this.actualDeliveryDate, @HiveField(33) this.sequenceNumber = 0, @HiveField(34) this.totalUnits = 0, @HiveField(35) this.category, @HiveField(36) this.handlingInstructions, @HiveField(37) this.customsDeclarationNumber, @HiveField(38) this.insuranceValue, @HiveField(39) this.priority = 2}): _cartonCodes = cartonCodes,super._();
  factory _BundleCodeModel.fromJson(Map<String, dynamic> json) => _$BundleCodeModelFromJson(json);

/// Base code properties
@override@HiveField(0) final  String id;
@override@HiveField(1) final  String code;
@override@JsonKey()@HiveField(2) final  CodeType type;
@override@JsonKey()@HiveField(3) final  CodeStatus status;
@override@JsonKey()@HiveField(4) final  String factoryId;
@override@JsonKey()@HiveField(5) final  String subscriptionPlanId;
@override@JsonKey()@HiveField(6) final  String storeKeeperCode;
@override@JsonKey()@HiveField(7) final  String internationalCode;
@override@JsonKey()@HiveField(8) final  String batchId;
@override@HiveField(9)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) final  DateTime generatedAt;
@override@HiveField(10) final  DateTime? linkedAt;
@override@HiveField(11) final  DateTime? publishedAt;
@override@HiveField(12) final  DateTime? deactivatedAt;
@override@HiveField(13) final  String? productId;
@override@HiveField(14) final  String? productBatchNumber;
@override@HiveField(15) final  DateTime? manufacturingDate;
@override@HiveField(16) final  DateTime? expiryDate;
@override@HiveField(17) final  int? warrantyMonths;
@override@HiveField(18) final  String? qrCodeData;
@override@HiveField(19) final  String? barcodeData;
@override@HiveField(20) final  String? metadata;
@override@JsonKey()@HiveField(21) final  int version;
@override@HiveField(22)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) final  DateTime createdAt;
@override@HiveField(23)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) final  DateTime updatedAt;
@override@JsonKey()@HiveField(24) final  bool isDeleted;
/// Bundle-specific properties
/// Number of cartons in this bundle
@override@JsonKey()@HiveField(25) final  int cartonCount;
/// List of carton codes contained in this bundle
 final  List<String> _cartonCodes;
/// List of carton codes contained in this bundle
@override@JsonKey()@HiveField(26) List<String> get cartonCodes {
  if (_cartonCodes is EqualUnmodifiableListView) return _cartonCodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cartonCodes);
}

/// Bundle weight in kilograms
@override@HiveField(27) final  double? weight;
/// Bundle dimensions (length x width x height in cm)
@override@HiveField(28) final  String? dimensions;
/// Storage location in warehouse
@override@HiveField(29) final  String? storageLocation;
/// Shipping method for this bundle
@override@HiveField(30) final  String? shippingMethod;
/// Expected delivery date
@override@HiveField(31) final  DateTime? expectedDeliveryDate;
/// Actual delivery date
@override@HiveField(32) final  DateTime? actualDeliveryDate;
/// Bundle sequence number (e.g., 1, 2, 3...)
@override@JsonKey()@HiveField(33) final  int sequenceNumber;
/// Total units in this bundle (calculated: cartonCount * packetsPerCarton * unitsPerPacket)
@override@JsonKey()@HiveField(34) final  int totalUnits;
/// Bundle category (e.g., "Electronics", "Food", "Medical")
@override@HiveField(35) final  String? category;
/// Special handling instructions
@override@HiveField(36) final  String? handlingInstructions;
/// Customs declaration number (for international shipping)
@override@HiveField(37) final  String? customsDeclarationNumber;
/// Insurance value of the bundle
@override@HiveField(38) final  double? insuranceValue;
/// Bundle priority (1=High, 2=Medium, 3=Low)
@override@JsonKey()@HiveField(39) final  int priority;

/// Create a copy of BundleCodeModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BundleCodeModelCopyWith<_BundleCodeModel> get copyWith => __$BundleCodeModelCopyWithImpl<_BundleCodeModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BundleCodeModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BundleCodeModel&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.factoryId, factoryId) || other.factoryId == factoryId)&&(identical(other.subscriptionPlanId, subscriptionPlanId) || other.subscriptionPlanId == subscriptionPlanId)&&(identical(other.storeKeeperCode, storeKeeperCode) || other.storeKeeperCode == storeKeeperCode)&&(identical(other.internationalCode, internationalCode) || other.internationalCode == internationalCode)&&(identical(other.batchId, batchId) || other.batchId == batchId)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.linkedAt, linkedAt) || other.linkedAt == linkedAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.deactivatedAt, deactivatedAt) || other.deactivatedAt == deactivatedAt)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productBatchNumber, productBatchNumber) || other.productBatchNumber == productBatchNumber)&&(identical(other.manufacturingDate, manufacturingDate) || other.manufacturingDate == manufacturingDate)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.warrantyMonths, warrantyMonths) || other.warrantyMonths == warrantyMonths)&&(identical(other.qrCodeData, qrCodeData) || other.qrCodeData == qrCodeData)&&(identical(other.barcodeData, barcodeData) || other.barcodeData == barcodeData)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.version, version) || other.version == version)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.cartonCount, cartonCount) || other.cartonCount == cartonCount)&&const DeepCollectionEquality().equals(other._cartonCodes, _cartonCodes)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.dimensions, dimensions) || other.dimensions == dimensions)&&(identical(other.storageLocation, storageLocation) || other.storageLocation == storageLocation)&&(identical(other.shippingMethod, shippingMethod) || other.shippingMethod == shippingMethod)&&(identical(other.expectedDeliveryDate, expectedDeliveryDate) || other.expectedDeliveryDate == expectedDeliveryDate)&&(identical(other.actualDeliveryDate, actualDeliveryDate) || other.actualDeliveryDate == actualDeliveryDate)&&(identical(other.sequenceNumber, sequenceNumber) || other.sequenceNumber == sequenceNumber)&&(identical(other.totalUnits, totalUnits) || other.totalUnits == totalUnits)&&(identical(other.category, category) || other.category == category)&&(identical(other.handlingInstructions, handlingInstructions) || other.handlingInstructions == handlingInstructions)&&(identical(other.customsDeclarationNumber, customsDeclarationNumber) || other.customsDeclarationNumber == customsDeclarationNumber)&&(identical(other.insuranceValue, insuranceValue) || other.insuranceValue == insuranceValue)&&(identical(other.priority, priority) || other.priority == priority));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,code,type,status,factoryId,subscriptionPlanId,storeKeeperCode,internationalCode,batchId,generatedAt,linkedAt,publishedAt,deactivatedAt,productId,productBatchNumber,manufacturingDate,expiryDate,warrantyMonths,qrCodeData,barcodeData,metadata,version,createdAt,updatedAt,isDeleted,cartonCount,const DeepCollectionEquality().hash(_cartonCodes),weight,dimensions,storageLocation,shippingMethod,expectedDeliveryDate,actualDeliveryDate,sequenceNumber,totalUnits,category,handlingInstructions,customsDeclarationNumber,insuranceValue,priority]);

@override
String toString() {
  return 'BundleCodeModel(id: $id, code: $code, type: $type, status: $status, factoryId: $factoryId, subscriptionPlanId: $subscriptionPlanId, storeKeeperCode: $storeKeeperCode, internationalCode: $internationalCode, batchId: $batchId, generatedAt: $generatedAt, linkedAt: $linkedAt, publishedAt: $publishedAt, deactivatedAt: $deactivatedAt, productId: $productId, productBatchNumber: $productBatchNumber, manufacturingDate: $manufacturingDate, expiryDate: $expiryDate, warrantyMonths: $warrantyMonths, qrCodeData: $qrCodeData, barcodeData: $barcodeData, metadata: $metadata, version: $version, createdAt: $createdAt, updatedAt: $updatedAt, isDeleted: $isDeleted, cartonCount: $cartonCount, cartonCodes: $cartonCodes, weight: $weight, dimensions: $dimensions, storageLocation: $storageLocation, shippingMethod: $shippingMethod, expectedDeliveryDate: $expectedDeliveryDate, actualDeliveryDate: $actualDeliveryDate, sequenceNumber: $sequenceNumber, totalUnits: $totalUnits, category: $category, handlingInstructions: $handlingInstructions, customsDeclarationNumber: $customsDeclarationNumber, insuranceValue: $insuranceValue, priority: $priority)';
}


}

/// @nodoc
abstract mixin class _$BundleCodeModelCopyWith<$Res> implements $BundleCodeModelCopyWith<$Res> {
  factory _$BundleCodeModelCopyWith(_BundleCodeModel value, $Res Function(_BundleCodeModel) _then) = __$BundleCodeModelCopyWithImpl;
@override @useResult
$Res call({
@HiveField(0) String id,@HiveField(1) String code,@HiveField(2) CodeType type,@HiveField(3) CodeStatus status,@HiveField(4) String factoryId,@HiveField(5) String subscriptionPlanId,@HiveField(6) String storeKeeperCode,@HiveField(7) String internationalCode,@HiveField(8) String batchId,@HiveField(9)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime generatedAt,@HiveField(10) DateTime? linkedAt,@HiveField(11) DateTime? publishedAt,@HiveField(12) DateTime? deactivatedAt,@HiveField(13) String? productId,@HiveField(14) String? productBatchNumber,@HiveField(15) DateTime? manufacturingDate,@HiveField(16) DateTime? expiryDate,@HiveField(17) int? warrantyMonths,@HiveField(18) String? qrCodeData,@HiveField(19) String? barcodeData,@HiveField(20) String? metadata,@HiveField(21) int version,@HiveField(22)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime createdAt,@HiveField(23)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime updatedAt,@HiveField(24) bool isDeleted,@HiveField(25) int cartonCount,@HiveField(26) List<String> cartonCodes,@HiveField(27) double? weight,@HiveField(28) String? dimensions,@HiveField(29) String? storageLocation,@HiveField(30) String? shippingMethod,@HiveField(31) DateTime? expectedDeliveryDate,@HiveField(32) DateTime? actualDeliveryDate,@HiveField(33) int sequenceNumber,@HiveField(34) int totalUnits,@HiveField(35) String? category,@HiveField(36) String? handlingInstructions,@HiveField(37) String? customsDeclarationNumber,@HiveField(38) double? insuranceValue,@HiveField(39) int priority
});




}
/// @nodoc
class __$BundleCodeModelCopyWithImpl<$Res>
    implements _$BundleCodeModelCopyWith<$Res> {
  __$BundleCodeModelCopyWithImpl(this._self, this._then);

  final _BundleCodeModel _self;
  final $Res Function(_BundleCodeModel) _then;

/// Create a copy of BundleCodeModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? type = null,Object? status = null,Object? factoryId = null,Object? subscriptionPlanId = null,Object? storeKeeperCode = null,Object? internationalCode = null,Object? batchId = null,Object? generatedAt = null,Object? linkedAt = freezed,Object? publishedAt = freezed,Object? deactivatedAt = freezed,Object? productId = freezed,Object? productBatchNumber = freezed,Object? manufacturingDate = freezed,Object? expiryDate = freezed,Object? warrantyMonths = freezed,Object? qrCodeData = freezed,Object? barcodeData = freezed,Object? metadata = freezed,Object? version = null,Object? createdAt = null,Object? updatedAt = null,Object? isDeleted = null,Object? cartonCount = null,Object? cartonCodes = null,Object? weight = freezed,Object? dimensions = freezed,Object? storageLocation = freezed,Object? shippingMethod = freezed,Object? expectedDeliveryDate = freezed,Object? actualDeliveryDate = freezed,Object? sequenceNumber = null,Object? totalUnits = null,Object? category = freezed,Object? handlingInstructions = freezed,Object? customsDeclarationNumber = freezed,Object? insuranceValue = freezed,Object? priority = null,}) {
  return _then(_BundleCodeModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CodeType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CodeStatus,factoryId: null == factoryId ? _self.factoryId : factoryId // ignore: cast_nullable_to_non_nullable
as String,subscriptionPlanId: null == subscriptionPlanId ? _self.subscriptionPlanId : subscriptionPlanId // ignore: cast_nullable_to_non_nullable
as String,storeKeeperCode: null == storeKeeperCode ? _self.storeKeeperCode : storeKeeperCode // ignore: cast_nullable_to_non_nullable
as String,internationalCode: null == internationalCode ? _self.internationalCode : internationalCode // ignore: cast_nullable_to_non_nullable
as String,batchId: null == batchId ? _self.batchId : batchId // ignore: cast_nullable_to_non_nullable
as String,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,linkedAt: freezed == linkedAt ? _self.linkedAt : linkedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deactivatedAt: freezed == deactivatedAt ? _self.deactivatedAt : deactivatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,productBatchNumber: freezed == productBatchNumber ? _self.productBatchNumber : productBatchNumber // ignore: cast_nullable_to_non_nullable
as String?,manufacturingDate: freezed == manufacturingDate ? _self.manufacturingDate : manufacturingDate // ignore: cast_nullable_to_non_nullable
as DateTime?,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,warrantyMonths: freezed == warrantyMonths ? _self.warrantyMonths : warrantyMonths // ignore: cast_nullable_to_non_nullable
as int?,qrCodeData: freezed == qrCodeData ? _self.qrCodeData : qrCodeData // ignore: cast_nullable_to_non_nullable
as String?,barcodeData: freezed == barcodeData ? _self.barcodeData : barcodeData // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as String?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,cartonCount: null == cartonCount ? _self.cartonCount : cartonCount // ignore: cast_nullable_to_non_nullable
as int,cartonCodes: null == cartonCodes ? _self._cartonCodes : cartonCodes // ignore: cast_nullable_to_non_nullable
as List<String>,weight: freezed == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double?,dimensions: freezed == dimensions ? _self.dimensions : dimensions // ignore: cast_nullable_to_non_nullable
as String?,storageLocation: freezed == storageLocation ? _self.storageLocation : storageLocation // ignore: cast_nullable_to_non_nullable
as String?,shippingMethod: freezed == shippingMethod ? _self.shippingMethod : shippingMethod // ignore: cast_nullable_to_non_nullable
as String?,expectedDeliveryDate: freezed == expectedDeliveryDate ? _self.expectedDeliveryDate : expectedDeliveryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,actualDeliveryDate: freezed == actualDeliveryDate ? _self.actualDeliveryDate : actualDeliveryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,sequenceNumber: null == sequenceNumber ? _self.sequenceNumber : sequenceNumber // ignore: cast_nullable_to_non_nullable
as int,totalUnits: null == totalUnits ? _self.totalUnits : totalUnits // ignore: cast_nullable_to_non_nullable
as int,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,handlingInstructions: freezed == handlingInstructions ? _self.handlingInstructions : handlingInstructions // ignore: cast_nullable_to_non_nullable
as String?,customsDeclarationNumber: freezed == customsDeclarationNumber ? _self.customsDeclarationNumber : customsDeclarationNumber // ignore: cast_nullable_to_non_nullable
as String?,insuranceValue: freezed == insuranceValue ? _self.insuranceValue : insuranceValue // ignore: cast_nullable_to_non_nullable
as double?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on

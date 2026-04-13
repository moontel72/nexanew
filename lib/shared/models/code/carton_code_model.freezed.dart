// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'carton_code_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CartonCodeModel {

/// Base code properties
@HiveField(0) String get id;@HiveField(1) String get code;@HiveField(2) CodeType get type;@HiveField(3) CodeStatus get status;@HiveField(4) String get factoryId;@HiveField(5) String get subscriptionPlanId;@HiveField(6) String get storeKeeperCode;@HiveField(7) String get internationalCode;@HiveField(8) String get batchId;@HiveField(9)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime get generatedAt;@HiveField(10) DateTime? get linkedAt;@HiveField(11) DateTime? get publishedAt;@HiveField(12) DateTime? get deactivatedAt;@HiveField(13) String? get productId;@HiveField(14) String? get productBatchNumber;@HiveField(15) DateTime? get manufacturingDate;@HiveField(16) DateTime? get expiryDate;@HiveField(17) int? get warrantyMonths;@HiveField(18) String? get qrCodeData;@HiveField(19) String? get barcodeData;@HiveField(20) String? get metadata;@HiveField(21) int get version;@HiveField(22)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime get createdAt;@HiveField(23)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime get updatedAt;@HiveField(24) bool get isDeleted;/// Carton-specific properties
/// Bundle code that contains this carton
@HiveField(25) String get bundleCode;/// Number of packets in this carton
@HiveField(26) int get packetCount;/// List of packet codes contained in this carton
@HiveField(27) List<String> get packetCodes;/// Carton weight in kilograms
@HiveField(28) double? get weight;/// Carton dimensions (length x width x height in cm)
@HiveField(29) String? get dimensions;/// Carton sequence number within bundle (e.g., 1, 2, 3...)
@HiveField(30) int get sequenceNumber;/// Total units in this carton (calculated: packetCount * unitsPerPacket)
@HiveField(31) int get totalUnits;/// Carton type (e.g., "Corrugated", "Cardboard", "Plastic")
@HiveField(32) String? get cartonType;/// Carton grade/quality
@HiveField(33) String? get grade;/// Maximum weight capacity of carton
@HiveField(34) double? get maxWeightCapacity;/// Is carton sealed?
@HiveField(35) bool get isSealed;/// Sealing date
@HiveField(36) DateTime? get sealedAt;/// Sealed by (user ID)
@HiveField(37) String? get sealedBy;/// Storage temperature requirements
@HiveField(38) String? get temperatureRequirements;/// Handling instructions specific to carton
@HiveField(39) String? get handlingInstructions;/// Carton barcode (separate from product barcode)
@HiveField(40) String? get cartonBarcode;/// Carton QR code (separate from product QR code)
@HiveField(41) String? get cartonQrCode;/// Carton condition (e.g., "New", "Good", "Damaged")
@HiveField(42) String get condition;/// Last inspection date
@HiveField(43) DateTime? get lastInspectionDate;/// Inspection notes
@HiveField(44) String? get inspectionNotes;
/// Create a copy of CartonCodeModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartonCodeModelCopyWith<CartonCodeModel> get copyWith => _$CartonCodeModelCopyWithImpl<CartonCodeModel>(this as CartonCodeModel, _$identity);

  /// Serializes this CartonCodeModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CartonCodeModel&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.factoryId, factoryId) || other.factoryId == factoryId)&&(identical(other.subscriptionPlanId, subscriptionPlanId) || other.subscriptionPlanId == subscriptionPlanId)&&(identical(other.storeKeeperCode, storeKeeperCode) || other.storeKeeperCode == storeKeeperCode)&&(identical(other.internationalCode, internationalCode) || other.internationalCode == internationalCode)&&(identical(other.batchId, batchId) || other.batchId == batchId)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.linkedAt, linkedAt) || other.linkedAt == linkedAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.deactivatedAt, deactivatedAt) || other.deactivatedAt == deactivatedAt)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productBatchNumber, productBatchNumber) || other.productBatchNumber == productBatchNumber)&&(identical(other.manufacturingDate, manufacturingDate) || other.manufacturingDate == manufacturingDate)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.warrantyMonths, warrantyMonths) || other.warrantyMonths == warrantyMonths)&&(identical(other.qrCodeData, qrCodeData) || other.qrCodeData == qrCodeData)&&(identical(other.barcodeData, barcodeData) || other.barcodeData == barcodeData)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.version, version) || other.version == version)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.bundleCode, bundleCode) || other.bundleCode == bundleCode)&&(identical(other.packetCount, packetCount) || other.packetCount == packetCount)&&const DeepCollectionEquality().equals(other.packetCodes, packetCodes)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.dimensions, dimensions) || other.dimensions == dimensions)&&(identical(other.sequenceNumber, sequenceNumber) || other.sequenceNumber == sequenceNumber)&&(identical(other.totalUnits, totalUnits) || other.totalUnits == totalUnits)&&(identical(other.cartonType, cartonType) || other.cartonType == cartonType)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.maxWeightCapacity, maxWeightCapacity) || other.maxWeightCapacity == maxWeightCapacity)&&(identical(other.isSealed, isSealed) || other.isSealed == isSealed)&&(identical(other.sealedAt, sealedAt) || other.sealedAt == sealedAt)&&(identical(other.sealedBy, sealedBy) || other.sealedBy == sealedBy)&&(identical(other.temperatureRequirements, temperatureRequirements) || other.temperatureRequirements == temperatureRequirements)&&(identical(other.handlingInstructions, handlingInstructions) || other.handlingInstructions == handlingInstructions)&&(identical(other.cartonBarcode, cartonBarcode) || other.cartonBarcode == cartonBarcode)&&(identical(other.cartonQrCode, cartonQrCode) || other.cartonQrCode == cartonQrCode)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.lastInspectionDate, lastInspectionDate) || other.lastInspectionDate == lastInspectionDate)&&(identical(other.inspectionNotes, inspectionNotes) || other.inspectionNotes == inspectionNotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,code,type,status,factoryId,subscriptionPlanId,storeKeeperCode,internationalCode,batchId,generatedAt,linkedAt,publishedAt,deactivatedAt,productId,productBatchNumber,manufacturingDate,expiryDate,warrantyMonths,qrCodeData,barcodeData,metadata,version,createdAt,updatedAt,isDeleted,bundleCode,packetCount,const DeepCollectionEquality().hash(packetCodes),weight,dimensions,sequenceNumber,totalUnits,cartonType,grade,maxWeightCapacity,isSealed,sealedAt,sealedBy,temperatureRequirements,handlingInstructions,cartonBarcode,cartonQrCode,condition,lastInspectionDate,inspectionNotes]);

@override
String toString() {
  return 'CartonCodeModel(id: $id, code: $code, type: $type, status: $status, factoryId: $factoryId, subscriptionPlanId: $subscriptionPlanId, storeKeeperCode: $storeKeeperCode, internationalCode: $internationalCode, batchId: $batchId, generatedAt: $generatedAt, linkedAt: $linkedAt, publishedAt: $publishedAt, deactivatedAt: $deactivatedAt, productId: $productId, productBatchNumber: $productBatchNumber, manufacturingDate: $manufacturingDate, expiryDate: $expiryDate, warrantyMonths: $warrantyMonths, qrCodeData: $qrCodeData, barcodeData: $barcodeData, metadata: $metadata, version: $version, createdAt: $createdAt, updatedAt: $updatedAt, isDeleted: $isDeleted, bundleCode: $bundleCode, packetCount: $packetCount, packetCodes: $packetCodes, weight: $weight, dimensions: $dimensions, sequenceNumber: $sequenceNumber, totalUnits: $totalUnits, cartonType: $cartonType, grade: $grade, maxWeightCapacity: $maxWeightCapacity, isSealed: $isSealed, sealedAt: $sealedAt, sealedBy: $sealedBy, temperatureRequirements: $temperatureRequirements, handlingInstructions: $handlingInstructions, cartonBarcode: $cartonBarcode, cartonQrCode: $cartonQrCode, condition: $condition, lastInspectionDate: $lastInspectionDate, inspectionNotes: $inspectionNotes)';
}


}

/// @nodoc
abstract mixin class $CartonCodeModelCopyWith<$Res>  {
  factory $CartonCodeModelCopyWith(CartonCodeModel value, $Res Function(CartonCodeModel) _then) = _$CartonCodeModelCopyWithImpl;
@useResult
$Res call({
@HiveField(0) String id,@HiveField(1) String code,@HiveField(2) CodeType type,@HiveField(3) CodeStatus status,@HiveField(4) String factoryId,@HiveField(5) String subscriptionPlanId,@HiveField(6) String storeKeeperCode,@HiveField(7) String internationalCode,@HiveField(8) String batchId,@HiveField(9)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime generatedAt,@HiveField(10) DateTime? linkedAt,@HiveField(11) DateTime? publishedAt,@HiveField(12) DateTime? deactivatedAt,@HiveField(13) String? productId,@HiveField(14) String? productBatchNumber,@HiveField(15) DateTime? manufacturingDate,@HiveField(16) DateTime? expiryDate,@HiveField(17) int? warrantyMonths,@HiveField(18) String? qrCodeData,@HiveField(19) String? barcodeData,@HiveField(20) String? metadata,@HiveField(21) int version,@HiveField(22)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime createdAt,@HiveField(23)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime updatedAt,@HiveField(24) bool isDeleted,@HiveField(25) String bundleCode,@HiveField(26) int packetCount,@HiveField(27) List<String> packetCodes,@HiveField(28) double? weight,@HiveField(29) String? dimensions,@HiveField(30) int sequenceNumber,@HiveField(31) int totalUnits,@HiveField(32) String? cartonType,@HiveField(33) String? grade,@HiveField(34) double? maxWeightCapacity,@HiveField(35) bool isSealed,@HiveField(36) DateTime? sealedAt,@HiveField(37) String? sealedBy,@HiveField(38) String? temperatureRequirements,@HiveField(39) String? handlingInstructions,@HiveField(40) String? cartonBarcode,@HiveField(41) String? cartonQrCode,@HiveField(42) String condition,@HiveField(43) DateTime? lastInspectionDate,@HiveField(44) String? inspectionNotes
});




}
/// @nodoc
class _$CartonCodeModelCopyWithImpl<$Res>
    implements $CartonCodeModelCopyWith<$Res> {
  _$CartonCodeModelCopyWithImpl(this._self, this._then);

  final CartonCodeModel _self;
  final $Res Function(CartonCodeModel) _then;

/// Create a copy of CartonCodeModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? type = null,Object? status = null,Object? factoryId = null,Object? subscriptionPlanId = null,Object? storeKeeperCode = null,Object? internationalCode = null,Object? batchId = null,Object? generatedAt = null,Object? linkedAt = freezed,Object? publishedAt = freezed,Object? deactivatedAt = freezed,Object? productId = freezed,Object? productBatchNumber = freezed,Object? manufacturingDate = freezed,Object? expiryDate = freezed,Object? warrantyMonths = freezed,Object? qrCodeData = freezed,Object? barcodeData = freezed,Object? metadata = freezed,Object? version = null,Object? createdAt = null,Object? updatedAt = null,Object? isDeleted = null,Object? bundleCode = null,Object? packetCount = null,Object? packetCodes = null,Object? weight = freezed,Object? dimensions = freezed,Object? sequenceNumber = null,Object? totalUnits = null,Object? cartonType = freezed,Object? grade = freezed,Object? maxWeightCapacity = freezed,Object? isSealed = null,Object? sealedAt = freezed,Object? sealedBy = freezed,Object? temperatureRequirements = freezed,Object? handlingInstructions = freezed,Object? cartonBarcode = freezed,Object? cartonQrCode = freezed,Object? condition = null,Object? lastInspectionDate = freezed,Object? inspectionNotes = freezed,}) {
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
as bool,bundleCode: null == bundleCode ? _self.bundleCode : bundleCode // ignore: cast_nullable_to_non_nullable
as String,packetCount: null == packetCount ? _self.packetCount : packetCount // ignore: cast_nullable_to_non_nullable
as int,packetCodes: null == packetCodes ? _self.packetCodes : packetCodes // ignore: cast_nullable_to_non_nullable
as List<String>,weight: freezed == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double?,dimensions: freezed == dimensions ? _self.dimensions : dimensions // ignore: cast_nullable_to_non_nullable
as String?,sequenceNumber: null == sequenceNumber ? _self.sequenceNumber : sequenceNumber // ignore: cast_nullable_to_non_nullable
as int,totalUnits: null == totalUnits ? _self.totalUnits : totalUnits // ignore: cast_nullable_to_non_nullable
as int,cartonType: freezed == cartonType ? _self.cartonType : cartonType // ignore: cast_nullable_to_non_nullable
as String?,grade: freezed == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as String?,maxWeightCapacity: freezed == maxWeightCapacity ? _self.maxWeightCapacity : maxWeightCapacity // ignore: cast_nullable_to_non_nullable
as double?,isSealed: null == isSealed ? _self.isSealed : isSealed // ignore: cast_nullable_to_non_nullable
as bool,sealedAt: freezed == sealedAt ? _self.sealedAt : sealedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,sealedBy: freezed == sealedBy ? _self.sealedBy : sealedBy // ignore: cast_nullable_to_non_nullable
as String?,temperatureRequirements: freezed == temperatureRequirements ? _self.temperatureRequirements : temperatureRequirements // ignore: cast_nullable_to_non_nullable
as String?,handlingInstructions: freezed == handlingInstructions ? _self.handlingInstructions : handlingInstructions // ignore: cast_nullable_to_non_nullable
as String?,cartonBarcode: freezed == cartonBarcode ? _self.cartonBarcode : cartonBarcode // ignore: cast_nullable_to_non_nullable
as String?,cartonQrCode: freezed == cartonQrCode ? _self.cartonQrCode : cartonQrCode // ignore: cast_nullable_to_non_nullable
as String?,condition: null == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as String,lastInspectionDate: freezed == lastInspectionDate ? _self.lastInspectionDate : lastInspectionDate // ignore: cast_nullable_to_non_nullable
as DateTime?,inspectionNotes: freezed == inspectionNotes ? _self.inspectionNotes : inspectionNotes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CartonCodeModel].
extension CartonCodeModelPatterns on CartonCodeModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CartonCodeModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CartonCodeModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CartonCodeModel value)  $default,){
final _that = this;
switch (_that) {
case _CartonCodeModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CartonCodeModel value)?  $default,){
final _that = this;
switch (_that) {
case _CartonCodeModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@HiveField(0)  String id, @HiveField(1)  String code, @HiveField(2)  CodeType type, @HiveField(3)  CodeStatus status, @HiveField(4)  String factoryId, @HiveField(5)  String subscriptionPlanId, @HiveField(6)  String storeKeeperCode, @HiveField(7)  String internationalCode, @HiveField(8)  String batchId, @HiveField(9)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime generatedAt, @HiveField(10)  DateTime? linkedAt, @HiveField(11)  DateTime? publishedAt, @HiveField(12)  DateTime? deactivatedAt, @HiveField(13)  String? productId, @HiveField(14)  String? productBatchNumber, @HiveField(15)  DateTime? manufacturingDate, @HiveField(16)  DateTime? expiryDate, @HiveField(17)  int? warrantyMonths, @HiveField(18)  String? qrCodeData, @HiveField(19)  String? barcodeData, @HiveField(20)  String? metadata, @HiveField(21)  int version, @HiveField(22)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime createdAt, @HiveField(23)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime updatedAt, @HiveField(24)  bool isDeleted, @HiveField(25)  String bundleCode, @HiveField(26)  int packetCount, @HiveField(27)  List<String> packetCodes, @HiveField(28)  double? weight, @HiveField(29)  String? dimensions, @HiveField(30)  int sequenceNumber, @HiveField(31)  int totalUnits, @HiveField(32)  String? cartonType, @HiveField(33)  String? grade, @HiveField(34)  double? maxWeightCapacity, @HiveField(35)  bool isSealed, @HiveField(36)  DateTime? sealedAt, @HiveField(37)  String? sealedBy, @HiveField(38)  String? temperatureRequirements, @HiveField(39)  String? handlingInstructions, @HiveField(40)  String? cartonBarcode, @HiveField(41)  String? cartonQrCode, @HiveField(42)  String condition, @HiveField(43)  DateTime? lastInspectionDate, @HiveField(44)  String? inspectionNotes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CartonCodeModel() when $default != null:
return $default(_that.id,_that.code,_that.type,_that.status,_that.factoryId,_that.subscriptionPlanId,_that.storeKeeperCode,_that.internationalCode,_that.batchId,_that.generatedAt,_that.linkedAt,_that.publishedAt,_that.deactivatedAt,_that.productId,_that.productBatchNumber,_that.manufacturingDate,_that.expiryDate,_that.warrantyMonths,_that.qrCodeData,_that.barcodeData,_that.metadata,_that.version,_that.createdAt,_that.updatedAt,_that.isDeleted,_that.bundleCode,_that.packetCount,_that.packetCodes,_that.weight,_that.dimensions,_that.sequenceNumber,_that.totalUnits,_that.cartonType,_that.grade,_that.maxWeightCapacity,_that.isSealed,_that.sealedAt,_that.sealedBy,_that.temperatureRequirements,_that.handlingInstructions,_that.cartonBarcode,_that.cartonQrCode,_that.condition,_that.lastInspectionDate,_that.inspectionNotes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@HiveField(0)  String id, @HiveField(1)  String code, @HiveField(2)  CodeType type, @HiveField(3)  CodeStatus status, @HiveField(4)  String factoryId, @HiveField(5)  String subscriptionPlanId, @HiveField(6)  String storeKeeperCode, @HiveField(7)  String internationalCode, @HiveField(8)  String batchId, @HiveField(9)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime generatedAt, @HiveField(10)  DateTime? linkedAt, @HiveField(11)  DateTime? publishedAt, @HiveField(12)  DateTime? deactivatedAt, @HiveField(13)  String? productId, @HiveField(14)  String? productBatchNumber, @HiveField(15)  DateTime? manufacturingDate, @HiveField(16)  DateTime? expiryDate, @HiveField(17)  int? warrantyMonths, @HiveField(18)  String? qrCodeData, @HiveField(19)  String? barcodeData, @HiveField(20)  String? metadata, @HiveField(21)  int version, @HiveField(22)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime createdAt, @HiveField(23)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime updatedAt, @HiveField(24)  bool isDeleted, @HiveField(25)  String bundleCode, @HiveField(26)  int packetCount, @HiveField(27)  List<String> packetCodes, @HiveField(28)  double? weight, @HiveField(29)  String? dimensions, @HiveField(30)  int sequenceNumber, @HiveField(31)  int totalUnits, @HiveField(32)  String? cartonType, @HiveField(33)  String? grade, @HiveField(34)  double? maxWeightCapacity, @HiveField(35)  bool isSealed, @HiveField(36)  DateTime? sealedAt, @HiveField(37)  String? sealedBy, @HiveField(38)  String? temperatureRequirements, @HiveField(39)  String? handlingInstructions, @HiveField(40)  String? cartonBarcode, @HiveField(41)  String? cartonQrCode, @HiveField(42)  String condition, @HiveField(43)  DateTime? lastInspectionDate, @HiveField(44)  String? inspectionNotes)  $default,) {final _that = this;
switch (_that) {
case _CartonCodeModel():
return $default(_that.id,_that.code,_that.type,_that.status,_that.factoryId,_that.subscriptionPlanId,_that.storeKeeperCode,_that.internationalCode,_that.batchId,_that.generatedAt,_that.linkedAt,_that.publishedAt,_that.deactivatedAt,_that.productId,_that.productBatchNumber,_that.manufacturingDate,_that.expiryDate,_that.warrantyMonths,_that.qrCodeData,_that.barcodeData,_that.metadata,_that.version,_that.createdAt,_that.updatedAt,_that.isDeleted,_that.bundleCode,_that.packetCount,_that.packetCodes,_that.weight,_that.dimensions,_that.sequenceNumber,_that.totalUnits,_that.cartonType,_that.grade,_that.maxWeightCapacity,_that.isSealed,_that.sealedAt,_that.sealedBy,_that.temperatureRequirements,_that.handlingInstructions,_that.cartonBarcode,_that.cartonQrCode,_that.condition,_that.lastInspectionDate,_that.inspectionNotes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@HiveField(0)  String id, @HiveField(1)  String code, @HiveField(2)  CodeType type, @HiveField(3)  CodeStatus status, @HiveField(4)  String factoryId, @HiveField(5)  String subscriptionPlanId, @HiveField(6)  String storeKeeperCode, @HiveField(7)  String internationalCode, @HiveField(8)  String batchId, @HiveField(9)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime generatedAt, @HiveField(10)  DateTime? linkedAt, @HiveField(11)  DateTime? publishedAt, @HiveField(12)  DateTime? deactivatedAt, @HiveField(13)  String? productId, @HiveField(14)  String? productBatchNumber, @HiveField(15)  DateTime? manufacturingDate, @HiveField(16)  DateTime? expiryDate, @HiveField(17)  int? warrantyMonths, @HiveField(18)  String? qrCodeData, @HiveField(19)  String? barcodeData, @HiveField(20)  String? metadata, @HiveField(21)  int version, @HiveField(22)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime createdAt, @HiveField(23)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime updatedAt, @HiveField(24)  bool isDeleted, @HiveField(25)  String bundleCode, @HiveField(26)  int packetCount, @HiveField(27)  List<String> packetCodes, @HiveField(28)  double? weight, @HiveField(29)  String? dimensions, @HiveField(30)  int sequenceNumber, @HiveField(31)  int totalUnits, @HiveField(32)  String? cartonType, @HiveField(33)  String? grade, @HiveField(34)  double? maxWeightCapacity, @HiveField(35)  bool isSealed, @HiveField(36)  DateTime? sealedAt, @HiveField(37)  String? sealedBy, @HiveField(38)  String? temperatureRequirements, @HiveField(39)  String? handlingInstructions, @HiveField(40)  String? cartonBarcode, @HiveField(41)  String? cartonQrCode, @HiveField(42)  String condition, @HiveField(43)  DateTime? lastInspectionDate, @HiveField(44)  String? inspectionNotes)?  $default,) {final _that = this;
switch (_that) {
case _CartonCodeModel() when $default != null:
return $default(_that.id,_that.code,_that.type,_that.status,_that.factoryId,_that.subscriptionPlanId,_that.storeKeeperCode,_that.internationalCode,_that.batchId,_that.generatedAt,_that.linkedAt,_that.publishedAt,_that.deactivatedAt,_that.productId,_that.productBatchNumber,_that.manufacturingDate,_that.expiryDate,_that.warrantyMonths,_that.qrCodeData,_that.barcodeData,_that.metadata,_that.version,_that.createdAt,_that.updatedAt,_that.isDeleted,_that.bundleCode,_that.packetCount,_that.packetCodes,_that.weight,_that.dimensions,_that.sequenceNumber,_that.totalUnits,_that.cartonType,_that.grade,_that.maxWeightCapacity,_that.isSealed,_that.sealedAt,_that.sealedBy,_that.temperatureRequirements,_that.handlingInstructions,_that.cartonBarcode,_that.cartonQrCode,_that.condition,_that.lastInspectionDate,_that.inspectionNotes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CartonCodeModel extends CartonCodeModel {
  const _CartonCodeModel({@HiveField(0) required this.id, @HiveField(1) required this.code, @HiveField(2) this.type = CodeType.carton, @HiveField(3) this.status = CodeStatus.generated, @HiveField(4) this.factoryId = '', @HiveField(5) this.subscriptionPlanId = '', @HiveField(6) this.storeKeeperCode = '', @HiveField(7) this.internationalCode = '', @HiveField(8) this.batchId = '', @HiveField(9)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) required this.generatedAt, @HiveField(10) this.linkedAt, @HiveField(11) this.publishedAt, @HiveField(12) this.deactivatedAt, @HiveField(13) this.productId, @HiveField(14) this.productBatchNumber, @HiveField(15) this.manufacturingDate, @HiveField(16) this.expiryDate, @HiveField(17) this.warrantyMonths, @HiveField(18) this.qrCodeData, @HiveField(19) this.barcodeData, @HiveField(20) this.metadata, @HiveField(21) this.version = 1, @HiveField(22)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) required this.createdAt, @HiveField(23)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) required this.updatedAt, @HiveField(24) this.isDeleted = false, @HiveField(25) this.bundleCode = '', @HiveField(26) this.packetCount = 0, @HiveField(27) final  List<String> packetCodes = const <String>[], @HiveField(28) this.weight, @HiveField(29) this.dimensions, @HiveField(30) this.sequenceNumber = 0, @HiveField(31) this.totalUnits = 0, @HiveField(32) this.cartonType, @HiveField(33) this.grade, @HiveField(34) this.maxWeightCapacity, @HiveField(35) this.isSealed = false, @HiveField(36) this.sealedAt, @HiveField(37) this.sealedBy, @HiveField(38) this.temperatureRequirements, @HiveField(39) this.handlingInstructions, @HiveField(40) this.cartonBarcode, @HiveField(41) this.cartonQrCode, @HiveField(42) this.condition = 'New', @HiveField(43) this.lastInspectionDate, @HiveField(44) this.inspectionNotes}): _packetCodes = packetCodes,super._();
  factory _CartonCodeModel.fromJson(Map<String, dynamic> json) => _$CartonCodeModelFromJson(json);

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
/// Carton-specific properties
/// Bundle code that contains this carton
@override@JsonKey()@HiveField(25) final  String bundleCode;
/// Number of packets in this carton
@override@JsonKey()@HiveField(26) final  int packetCount;
/// List of packet codes contained in this carton
 final  List<String> _packetCodes;
/// List of packet codes contained in this carton
@override@JsonKey()@HiveField(27) List<String> get packetCodes {
  if (_packetCodes is EqualUnmodifiableListView) return _packetCodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_packetCodes);
}

/// Carton weight in kilograms
@override@HiveField(28) final  double? weight;
/// Carton dimensions (length x width x height in cm)
@override@HiveField(29) final  String? dimensions;
/// Carton sequence number within bundle (e.g., 1, 2, 3...)
@override@JsonKey()@HiveField(30) final  int sequenceNumber;
/// Total units in this carton (calculated: packetCount * unitsPerPacket)
@override@JsonKey()@HiveField(31) final  int totalUnits;
/// Carton type (e.g., "Corrugated", "Cardboard", "Plastic")
@override@HiveField(32) final  String? cartonType;
/// Carton grade/quality
@override@HiveField(33) final  String? grade;
/// Maximum weight capacity of carton
@override@HiveField(34) final  double? maxWeightCapacity;
/// Is carton sealed?
@override@JsonKey()@HiveField(35) final  bool isSealed;
/// Sealing date
@override@HiveField(36) final  DateTime? sealedAt;
/// Sealed by (user ID)
@override@HiveField(37) final  String? sealedBy;
/// Storage temperature requirements
@override@HiveField(38) final  String? temperatureRequirements;
/// Handling instructions specific to carton
@override@HiveField(39) final  String? handlingInstructions;
/// Carton barcode (separate from product barcode)
@override@HiveField(40) final  String? cartonBarcode;
/// Carton QR code (separate from product QR code)
@override@HiveField(41) final  String? cartonQrCode;
/// Carton condition (e.g., "New", "Good", "Damaged")
@override@JsonKey()@HiveField(42) final  String condition;
/// Last inspection date
@override@HiveField(43) final  DateTime? lastInspectionDate;
/// Inspection notes
@override@HiveField(44) final  String? inspectionNotes;

/// Create a copy of CartonCodeModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CartonCodeModelCopyWith<_CartonCodeModel> get copyWith => __$CartonCodeModelCopyWithImpl<_CartonCodeModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CartonCodeModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CartonCodeModel&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.factoryId, factoryId) || other.factoryId == factoryId)&&(identical(other.subscriptionPlanId, subscriptionPlanId) || other.subscriptionPlanId == subscriptionPlanId)&&(identical(other.storeKeeperCode, storeKeeperCode) || other.storeKeeperCode == storeKeeperCode)&&(identical(other.internationalCode, internationalCode) || other.internationalCode == internationalCode)&&(identical(other.batchId, batchId) || other.batchId == batchId)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.linkedAt, linkedAt) || other.linkedAt == linkedAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.deactivatedAt, deactivatedAt) || other.deactivatedAt == deactivatedAt)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productBatchNumber, productBatchNumber) || other.productBatchNumber == productBatchNumber)&&(identical(other.manufacturingDate, manufacturingDate) || other.manufacturingDate == manufacturingDate)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.warrantyMonths, warrantyMonths) || other.warrantyMonths == warrantyMonths)&&(identical(other.qrCodeData, qrCodeData) || other.qrCodeData == qrCodeData)&&(identical(other.barcodeData, barcodeData) || other.barcodeData == barcodeData)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.version, version) || other.version == version)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.bundleCode, bundleCode) || other.bundleCode == bundleCode)&&(identical(other.packetCount, packetCount) || other.packetCount == packetCount)&&const DeepCollectionEquality().equals(other._packetCodes, _packetCodes)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.dimensions, dimensions) || other.dimensions == dimensions)&&(identical(other.sequenceNumber, sequenceNumber) || other.sequenceNumber == sequenceNumber)&&(identical(other.totalUnits, totalUnits) || other.totalUnits == totalUnits)&&(identical(other.cartonType, cartonType) || other.cartonType == cartonType)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.maxWeightCapacity, maxWeightCapacity) || other.maxWeightCapacity == maxWeightCapacity)&&(identical(other.isSealed, isSealed) || other.isSealed == isSealed)&&(identical(other.sealedAt, sealedAt) || other.sealedAt == sealedAt)&&(identical(other.sealedBy, sealedBy) || other.sealedBy == sealedBy)&&(identical(other.temperatureRequirements, temperatureRequirements) || other.temperatureRequirements == temperatureRequirements)&&(identical(other.handlingInstructions, handlingInstructions) || other.handlingInstructions == handlingInstructions)&&(identical(other.cartonBarcode, cartonBarcode) || other.cartonBarcode == cartonBarcode)&&(identical(other.cartonQrCode, cartonQrCode) || other.cartonQrCode == cartonQrCode)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.lastInspectionDate, lastInspectionDate) || other.lastInspectionDate == lastInspectionDate)&&(identical(other.inspectionNotes, inspectionNotes) || other.inspectionNotes == inspectionNotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,code,type,status,factoryId,subscriptionPlanId,storeKeeperCode,internationalCode,batchId,generatedAt,linkedAt,publishedAt,deactivatedAt,productId,productBatchNumber,manufacturingDate,expiryDate,warrantyMonths,qrCodeData,barcodeData,metadata,version,createdAt,updatedAt,isDeleted,bundleCode,packetCount,const DeepCollectionEquality().hash(_packetCodes),weight,dimensions,sequenceNumber,totalUnits,cartonType,grade,maxWeightCapacity,isSealed,sealedAt,sealedBy,temperatureRequirements,handlingInstructions,cartonBarcode,cartonQrCode,condition,lastInspectionDate,inspectionNotes]);

@override
String toString() {
  return 'CartonCodeModel(id: $id, code: $code, type: $type, status: $status, factoryId: $factoryId, subscriptionPlanId: $subscriptionPlanId, storeKeeperCode: $storeKeeperCode, internationalCode: $internationalCode, batchId: $batchId, generatedAt: $generatedAt, linkedAt: $linkedAt, publishedAt: $publishedAt, deactivatedAt: $deactivatedAt, productId: $productId, productBatchNumber: $productBatchNumber, manufacturingDate: $manufacturingDate, expiryDate: $expiryDate, warrantyMonths: $warrantyMonths, qrCodeData: $qrCodeData, barcodeData: $barcodeData, metadata: $metadata, version: $version, createdAt: $createdAt, updatedAt: $updatedAt, isDeleted: $isDeleted, bundleCode: $bundleCode, packetCount: $packetCount, packetCodes: $packetCodes, weight: $weight, dimensions: $dimensions, sequenceNumber: $sequenceNumber, totalUnits: $totalUnits, cartonType: $cartonType, grade: $grade, maxWeightCapacity: $maxWeightCapacity, isSealed: $isSealed, sealedAt: $sealedAt, sealedBy: $sealedBy, temperatureRequirements: $temperatureRequirements, handlingInstructions: $handlingInstructions, cartonBarcode: $cartonBarcode, cartonQrCode: $cartonQrCode, condition: $condition, lastInspectionDate: $lastInspectionDate, inspectionNotes: $inspectionNotes)';
}


}

/// @nodoc
abstract mixin class _$CartonCodeModelCopyWith<$Res> implements $CartonCodeModelCopyWith<$Res> {
  factory _$CartonCodeModelCopyWith(_CartonCodeModel value, $Res Function(_CartonCodeModel) _then) = __$CartonCodeModelCopyWithImpl;
@override @useResult
$Res call({
@HiveField(0) String id,@HiveField(1) String code,@HiveField(2) CodeType type,@HiveField(3) CodeStatus status,@HiveField(4) String factoryId,@HiveField(5) String subscriptionPlanId,@HiveField(6) String storeKeeperCode,@HiveField(7) String internationalCode,@HiveField(8) String batchId,@HiveField(9)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime generatedAt,@HiveField(10) DateTime? linkedAt,@HiveField(11) DateTime? publishedAt,@HiveField(12) DateTime? deactivatedAt,@HiveField(13) String? productId,@HiveField(14) String? productBatchNumber,@HiveField(15) DateTime? manufacturingDate,@HiveField(16) DateTime? expiryDate,@HiveField(17) int? warrantyMonths,@HiveField(18) String? qrCodeData,@HiveField(19) String? barcodeData,@HiveField(20) String? metadata,@HiveField(21) int version,@HiveField(22)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime createdAt,@HiveField(23)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime updatedAt,@HiveField(24) bool isDeleted,@HiveField(25) String bundleCode,@HiveField(26) int packetCount,@HiveField(27) List<String> packetCodes,@HiveField(28) double? weight,@HiveField(29) String? dimensions,@HiveField(30) int sequenceNumber,@HiveField(31) int totalUnits,@HiveField(32) String? cartonType,@HiveField(33) String? grade,@HiveField(34) double? maxWeightCapacity,@HiveField(35) bool isSealed,@HiveField(36) DateTime? sealedAt,@HiveField(37) String? sealedBy,@HiveField(38) String? temperatureRequirements,@HiveField(39) String? handlingInstructions,@HiveField(40) String? cartonBarcode,@HiveField(41) String? cartonQrCode,@HiveField(42) String condition,@HiveField(43) DateTime? lastInspectionDate,@HiveField(44) String? inspectionNotes
});




}
/// @nodoc
class __$CartonCodeModelCopyWithImpl<$Res>
    implements _$CartonCodeModelCopyWith<$Res> {
  __$CartonCodeModelCopyWithImpl(this._self, this._then);

  final _CartonCodeModel _self;
  final $Res Function(_CartonCodeModel) _then;

/// Create a copy of CartonCodeModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? type = null,Object? status = null,Object? factoryId = null,Object? subscriptionPlanId = null,Object? storeKeeperCode = null,Object? internationalCode = null,Object? batchId = null,Object? generatedAt = null,Object? linkedAt = freezed,Object? publishedAt = freezed,Object? deactivatedAt = freezed,Object? productId = freezed,Object? productBatchNumber = freezed,Object? manufacturingDate = freezed,Object? expiryDate = freezed,Object? warrantyMonths = freezed,Object? qrCodeData = freezed,Object? barcodeData = freezed,Object? metadata = freezed,Object? version = null,Object? createdAt = null,Object? updatedAt = null,Object? isDeleted = null,Object? bundleCode = null,Object? packetCount = null,Object? packetCodes = null,Object? weight = freezed,Object? dimensions = freezed,Object? sequenceNumber = null,Object? totalUnits = null,Object? cartonType = freezed,Object? grade = freezed,Object? maxWeightCapacity = freezed,Object? isSealed = null,Object? sealedAt = freezed,Object? sealedBy = freezed,Object? temperatureRequirements = freezed,Object? handlingInstructions = freezed,Object? cartonBarcode = freezed,Object? cartonQrCode = freezed,Object? condition = null,Object? lastInspectionDate = freezed,Object? inspectionNotes = freezed,}) {
  return _then(_CartonCodeModel(
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
as bool,bundleCode: null == bundleCode ? _self.bundleCode : bundleCode // ignore: cast_nullable_to_non_nullable
as String,packetCount: null == packetCount ? _self.packetCount : packetCount // ignore: cast_nullable_to_non_nullable
as int,packetCodes: null == packetCodes ? _self._packetCodes : packetCodes // ignore: cast_nullable_to_non_nullable
as List<String>,weight: freezed == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double?,dimensions: freezed == dimensions ? _self.dimensions : dimensions // ignore: cast_nullable_to_non_nullable
as String?,sequenceNumber: null == sequenceNumber ? _self.sequenceNumber : sequenceNumber // ignore: cast_nullable_to_non_nullable
as int,totalUnits: null == totalUnits ? _self.totalUnits : totalUnits // ignore: cast_nullable_to_non_nullable
as int,cartonType: freezed == cartonType ? _self.cartonType : cartonType // ignore: cast_nullable_to_non_nullable
as String?,grade: freezed == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as String?,maxWeightCapacity: freezed == maxWeightCapacity ? _self.maxWeightCapacity : maxWeightCapacity // ignore: cast_nullable_to_non_nullable
as double?,isSealed: null == isSealed ? _self.isSealed : isSealed // ignore: cast_nullable_to_non_nullable
as bool,sealedAt: freezed == sealedAt ? _self.sealedAt : sealedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,sealedBy: freezed == sealedBy ? _self.sealedBy : sealedBy // ignore: cast_nullable_to_non_nullable
as String?,temperatureRequirements: freezed == temperatureRequirements ? _self.temperatureRequirements : temperatureRequirements // ignore: cast_nullable_to_non_nullable
as String?,handlingInstructions: freezed == handlingInstructions ? _self.handlingInstructions : handlingInstructions // ignore: cast_nullable_to_non_nullable
as String?,cartonBarcode: freezed == cartonBarcode ? _self.cartonBarcode : cartonBarcode // ignore: cast_nullable_to_non_nullable
as String?,cartonQrCode: freezed == cartonQrCode ? _self.cartonQrCode : cartonQrCode // ignore: cast_nullable_to_non_nullable
as String?,condition: null == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as String,lastInspectionDate: freezed == lastInspectionDate ? _self.lastInspectionDate : lastInspectionDate // ignore: cast_nullable_to_non_nullable
as DateTime?,inspectionNotes: freezed == inspectionNotes ? _self.inspectionNotes : inspectionNotes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

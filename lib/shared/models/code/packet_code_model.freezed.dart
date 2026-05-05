// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'packet_code_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PacketCodeModel {

/// Base code properties
@HiveField(0) String get id;@HiveField(1) String get code;@HiveField(2) CodeType get type;@HiveField(3) CodeStatus get status;@HiveField(4) String get factoryId;@HiveField(5) String get subscriptionPlanId;@HiveField(6) String get storeKeeperCode;@HiveField(7) String get internationalCode;@HiveField(8) String get batchId;@HiveField(9)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime get generatedAt;@HiveField(10) DateTime? get linkedAt;@HiveField(11) DateTime? get publishedAt;@HiveField(12) DateTime? get deactivatedAt;@HiveField(13) String? get productId;@HiveField(14) String? get productBatchNumber;@HiveField(15) DateTime? get manufacturingDate;@HiveField(16) DateTime? get expiryDate;@HiveField(17) int? get warrantyMonths;@HiveField(18) String? get qrCodeData;@HiveField(19) String? get barcodeData;@HiveField(20) String? get metadata;@HiveField(21) int get version;@HiveField(22)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime get createdAt;@HiveField(23)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime get updatedAt;@HiveField(24) bool get isDeleted;/// Packet-specific properties
/// Carton code that contains this packet
@HiveField(25) String get cartonCode;/// Number of units in this packet
@HiveField(26) int get unitCount;/// List of unit codes contained in this packet
@HiveField(27) List<String> get unitCodes;/// Packet weight in grams
@HiveField(28) double? get weight;/// Packet dimensions (length x width x height in cm)
@HiveField(29) String? get dimensions;/// Packet sequence number within carton (e.g., 1, 2, 3...)
@HiveField(30) int get sequenceNumber;/// Packet type (e.g., "Blister", "Box", "Pouch", "Bottle")
@HiveField(31) String? get packetType;/// Packet material (e.g., "Plastic", "Paper", "Aluminum")
@HiveField(32) String? get material;/// Is packet sealed?
@HiveField(33) bool get isSealed;/// Sealing date
@HiveField(34) DateTime? get sealedAt;/// Sealed by (user ID)
@HiveField(35) String? get sealedBy;/// Sealing method (e.g., "Heat Seal", "Adhesive", "Clip")
@HiveField(36) String? get sealingMethod;/// Packet barcode (separate from product barcode)
@HiveField(37) String? get packetBarcode;/// Packet QR code (separate from product QR code)
@HiveField(38) String? get packetQrCode;/// Packet condition (e.g., "Intact", "Damaged", "Torn")
@HiveField(39) String get condition;/// Tamper evidence seal present?
@HiveField(40) bool get hasTamperEvidence;/// Child safety features present?
@HiveField(41) bool get hasChildSafety;/// Instructions for use included?
@HiveField(42) bool get hasInstructions;/// Batch number specific to this packet
@HiveField(43) String? get packetBatchNumber;/// Serial number specific to this packet
@HiveField(44) String? get serialNumber;/// Packet color (for identification)
@HiveField(45) String? get color;/// Packet printing details
@HiveField(46) String? get printingDetails;/// Quality control passed?
@HiveField(47) bool get qcPassed;/// QC passed date
@HiveField(48) DateTime? get qcPassedDate;/// QC passed by (user ID)
@HiveField(49) String? get qcPassedBy;/// QC notes
@HiveField(50) String? get qcNotes;/// Packet code format type (itf14, gs1_128, code128_industrial, qr, datamatrix, code128_label)
@HiveField(51) String get codeFormat;
/// Create a copy of PacketCodeModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PacketCodeModelCopyWith<PacketCodeModel> get copyWith => _$PacketCodeModelCopyWithImpl<PacketCodeModel>(this as PacketCodeModel, _$identity);

  /// Serializes this PacketCodeModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PacketCodeModel&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.factoryId, factoryId) || other.factoryId == factoryId)&&(identical(other.subscriptionPlanId, subscriptionPlanId) || other.subscriptionPlanId == subscriptionPlanId)&&(identical(other.storeKeeperCode, storeKeeperCode) || other.storeKeeperCode == storeKeeperCode)&&(identical(other.internationalCode, internationalCode) || other.internationalCode == internationalCode)&&(identical(other.batchId, batchId) || other.batchId == batchId)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.linkedAt, linkedAt) || other.linkedAt == linkedAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.deactivatedAt, deactivatedAt) || other.deactivatedAt == deactivatedAt)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productBatchNumber, productBatchNumber) || other.productBatchNumber == productBatchNumber)&&(identical(other.manufacturingDate, manufacturingDate) || other.manufacturingDate == manufacturingDate)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.warrantyMonths, warrantyMonths) || other.warrantyMonths == warrantyMonths)&&(identical(other.qrCodeData, qrCodeData) || other.qrCodeData == qrCodeData)&&(identical(other.barcodeData, barcodeData) || other.barcodeData == barcodeData)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.version, version) || other.version == version)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.cartonCode, cartonCode) || other.cartonCode == cartonCode)&&(identical(other.unitCount, unitCount) || other.unitCount == unitCount)&&const DeepCollectionEquality().equals(other.unitCodes, unitCodes)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.dimensions, dimensions) || other.dimensions == dimensions)&&(identical(other.sequenceNumber, sequenceNumber) || other.sequenceNumber == sequenceNumber)&&(identical(other.packetType, packetType) || other.packetType == packetType)&&(identical(other.material, material) || other.material == material)&&(identical(other.isSealed, isSealed) || other.isSealed == isSealed)&&(identical(other.sealedAt, sealedAt) || other.sealedAt == sealedAt)&&(identical(other.sealedBy, sealedBy) || other.sealedBy == sealedBy)&&(identical(other.sealingMethod, sealingMethod) || other.sealingMethod == sealingMethod)&&(identical(other.packetBarcode, packetBarcode) || other.packetBarcode == packetBarcode)&&(identical(other.packetQrCode, packetQrCode) || other.packetQrCode == packetQrCode)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.hasTamperEvidence, hasTamperEvidence) || other.hasTamperEvidence == hasTamperEvidence)&&(identical(other.hasChildSafety, hasChildSafety) || other.hasChildSafety == hasChildSafety)&&(identical(other.hasInstructions, hasInstructions) || other.hasInstructions == hasInstructions)&&(identical(other.packetBatchNumber, packetBatchNumber) || other.packetBatchNumber == packetBatchNumber)&&(identical(other.serialNumber, serialNumber) || other.serialNumber == serialNumber)&&(identical(other.color, color) || other.color == color)&&(identical(other.printingDetails, printingDetails) || other.printingDetails == printingDetails)&&(identical(other.qcPassed, qcPassed) || other.qcPassed == qcPassed)&&(identical(other.qcPassedDate, qcPassedDate) || other.qcPassedDate == qcPassedDate)&&(identical(other.qcPassedBy, qcPassedBy) || other.qcPassedBy == qcPassedBy)&&(identical(other.qcNotes, qcNotes) || other.qcNotes == qcNotes)&&(identical(other.codeFormat, codeFormat) || other.codeFormat == codeFormat));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,code,type,status,factoryId,subscriptionPlanId,storeKeeperCode,internationalCode,batchId,generatedAt,linkedAt,publishedAt,deactivatedAt,productId,productBatchNumber,manufacturingDate,expiryDate,warrantyMonths,qrCodeData,barcodeData,metadata,version,createdAt,updatedAt,isDeleted,cartonCode,unitCount,const DeepCollectionEquality().hash(unitCodes),weight,dimensions,sequenceNumber,packetType,material,isSealed,sealedAt,sealedBy,sealingMethod,packetBarcode,packetQrCode,condition,hasTamperEvidence,hasChildSafety,hasInstructions,packetBatchNumber,serialNumber,color,printingDetails,qcPassed,qcPassedDate,qcPassedBy,qcNotes,codeFormat]);

@override
String toString() {
  return 'PacketCodeModel(id: $id, code: $code, type: $type, status: $status, factoryId: $factoryId, subscriptionPlanId: $subscriptionPlanId, storeKeeperCode: $storeKeeperCode, internationalCode: $internationalCode, batchId: $batchId, generatedAt: $generatedAt, linkedAt: $linkedAt, publishedAt: $publishedAt, deactivatedAt: $deactivatedAt, productId: $productId, productBatchNumber: $productBatchNumber, manufacturingDate: $manufacturingDate, expiryDate: $expiryDate, warrantyMonths: $warrantyMonths, qrCodeData: $qrCodeData, barcodeData: $barcodeData, metadata: $metadata, version: $version, createdAt: $createdAt, updatedAt: $updatedAt, isDeleted: $isDeleted, cartonCode: $cartonCode, unitCount: $unitCount, unitCodes: $unitCodes, weight: $weight, dimensions: $dimensions, sequenceNumber: $sequenceNumber, packetType: $packetType, material: $material, isSealed: $isSealed, sealedAt: $sealedAt, sealedBy: $sealedBy, sealingMethod: $sealingMethod, packetBarcode: $packetBarcode, packetQrCode: $packetQrCode, condition: $condition, hasTamperEvidence: $hasTamperEvidence, hasChildSafety: $hasChildSafety, hasInstructions: $hasInstructions, packetBatchNumber: $packetBatchNumber, serialNumber: $serialNumber, color: $color, printingDetails: $printingDetails, qcPassed: $qcPassed, qcPassedDate: $qcPassedDate, qcPassedBy: $qcPassedBy, qcNotes: $qcNotes, codeFormat: $codeFormat)';
}


}

/// @nodoc
abstract mixin class $PacketCodeModelCopyWith<$Res>  {
  factory $PacketCodeModelCopyWith(PacketCodeModel value, $Res Function(PacketCodeModel) _then) = _$PacketCodeModelCopyWithImpl;
@useResult
$Res call({
@HiveField(0) String id,@HiveField(1) String code,@HiveField(2) CodeType type,@HiveField(3) CodeStatus status,@HiveField(4) String factoryId,@HiveField(5) String subscriptionPlanId,@HiveField(6) String storeKeeperCode,@HiveField(7) String internationalCode,@HiveField(8) String batchId,@HiveField(9)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime generatedAt,@HiveField(10) DateTime? linkedAt,@HiveField(11) DateTime? publishedAt,@HiveField(12) DateTime? deactivatedAt,@HiveField(13) String? productId,@HiveField(14) String? productBatchNumber,@HiveField(15) DateTime? manufacturingDate,@HiveField(16) DateTime? expiryDate,@HiveField(17) int? warrantyMonths,@HiveField(18) String? qrCodeData,@HiveField(19) String? barcodeData,@HiveField(20) String? metadata,@HiveField(21) int version,@HiveField(22)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime createdAt,@HiveField(23)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime updatedAt,@HiveField(24) bool isDeleted,@HiveField(25) String cartonCode,@HiveField(26) int unitCount,@HiveField(27) List<String> unitCodes,@HiveField(28) double? weight,@HiveField(29) String? dimensions,@HiveField(30) int sequenceNumber,@HiveField(31) String? packetType,@HiveField(32) String? material,@HiveField(33) bool isSealed,@HiveField(34) DateTime? sealedAt,@HiveField(35) String? sealedBy,@HiveField(36) String? sealingMethod,@HiveField(37) String? packetBarcode,@HiveField(38) String? packetQrCode,@HiveField(39) String condition,@HiveField(40) bool hasTamperEvidence,@HiveField(41) bool hasChildSafety,@HiveField(42) bool hasInstructions,@HiveField(43) String? packetBatchNumber,@HiveField(44) String? serialNumber,@HiveField(45) String? color,@HiveField(46) String? printingDetails,@HiveField(47) bool qcPassed,@HiveField(48) DateTime? qcPassedDate,@HiveField(49) String? qcPassedBy,@HiveField(50) String? qcNotes,@HiveField(51) String codeFormat
});




}
/// @nodoc
class _$PacketCodeModelCopyWithImpl<$Res>
    implements $PacketCodeModelCopyWith<$Res> {
  _$PacketCodeModelCopyWithImpl(this._self, this._then);

  final PacketCodeModel _self;
  final $Res Function(PacketCodeModel) _then;

/// Create a copy of PacketCodeModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? type = null,Object? status = null,Object? factoryId = null,Object? subscriptionPlanId = null,Object? storeKeeperCode = null,Object? internationalCode = null,Object? batchId = null,Object? generatedAt = null,Object? linkedAt = freezed,Object? publishedAt = freezed,Object? deactivatedAt = freezed,Object? productId = freezed,Object? productBatchNumber = freezed,Object? manufacturingDate = freezed,Object? expiryDate = freezed,Object? warrantyMonths = freezed,Object? qrCodeData = freezed,Object? barcodeData = freezed,Object? metadata = freezed,Object? version = null,Object? createdAt = null,Object? updatedAt = null,Object? isDeleted = null,Object? cartonCode = null,Object? unitCount = null,Object? unitCodes = null,Object? weight = freezed,Object? dimensions = freezed,Object? sequenceNumber = null,Object? packetType = freezed,Object? material = freezed,Object? isSealed = null,Object? sealedAt = freezed,Object? sealedBy = freezed,Object? sealingMethod = freezed,Object? packetBarcode = freezed,Object? packetQrCode = freezed,Object? condition = null,Object? hasTamperEvidence = null,Object? hasChildSafety = null,Object? hasInstructions = null,Object? packetBatchNumber = freezed,Object? serialNumber = freezed,Object? color = freezed,Object? printingDetails = freezed,Object? qcPassed = null,Object? qcPassedDate = freezed,Object? qcPassedBy = freezed,Object? qcNotes = freezed,Object? codeFormat = null,}) {
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
as bool,cartonCode: null == cartonCode ? _self.cartonCode : cartonCode // ignore: cast_nullable_to_non_nullable
as String,unitCount: null == unitCount ? _self.unitCount : unitCount // ignore: cast_nullable_to_non_nullable
as int,unitCodes: null == unitCodes ? _self.unitCodes : unitCodes // ignore: cast_nullable_to_non_nullable
as List<String>,weight: freezed == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double?,dimensions: freezed == dimensions ? _self.dimensions : dimensions // ignore: cast_nullable_to_non_nullable
as String?,sequenceNumber: null == sequenceNumber ? _self.sequenceNumber : sequenceNumber // ignore: cast_nullable_to_non_nullable
as int,packetType: freezed == packetType ? _self.packetType : packetType // ignore: cast_nullable_to_non_nullable
as String?,material: freezed == material ? _self.material : material // ignore: cast_nullable_to_non_nullable
as String?,isSealed: null == isSealed ? _self.isSealed : isSealed // ignore: cast_nullable_to_non_nullable
as bool,sealedAt: freezed == sealedAt ? _self.sealedAt : sealedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,sealedBy: freezed == sealedBy ? _self.sealedBy : sealedBy // ignore: cast_nullable_to_non_nullable
as String?,sealingMethod: freezed == sealingMethod ? _self.sealingMethod : sealingMethod // ignore: cast_nullable_to_non_nullable
as String?,packetBarcode: freezed == packetBarcode ? _self.packetBarcode : packetBarcode // ignore: cast_nullable_to_non_nullable
as String?,packetQrCode: freezed == packetQrCode ? _self.packetQrCode : packetQrCode // ignore: cast_nullable_to_non_nullable
as String?,condition: null == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as String,hasTamperEvidence: null == hasTamperEvidence ? _self.hasTamperEvidence : hasTamperEvidence // ignore: cast_nullable_to_non_nullable
as bool,hasChildSafety: null == hasChildSafety ? _self.hasChildSafety : hasChildSafety // ignore: cast_nullable_to_non_nullable
as bool,hasInstructions: null == hasInstructions ? _self.hasInstructions : hasInstructions // ignore: cast_nullable_to_non_nullable
as bool,packetBatchNumber: freezed == packetBatchNumber ? _self.packetBatchNumber : packetBatchNumber // ignore: cast_nullable_to_non_nullable
as String?,serialNumber: freezed == serialNumber ? _self.serialNumber : serialNumber // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,printingDetails: freezed == printingDetails ? _self.printingDetails : printingDetails // ignore: cast_nullable_to_non_nullable
as String?,qcPassed: null == qcPassed ? _self.qcPassed : qcPassed // ignore: cast_nullable_to_non_nullable
as bool,qcPassedDate: freezed == qcPassedDate ? _self.qcPassedDate : qcPassedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,qcPassedBy: freezed == qcPassedBy ? _self.qcPassedBy : qcPassedBy // ignore: cast_nullable_to_non_nullable
as String?,qcNotes: freezed == qcNotes ? _self.qcNotes : qcNotes // ignore: cast_nullable_to_non_nullable
as String?,codeFormat: null == codeFormat ? _self.codeFormat : codeFormat // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PacketCodeModel].
extension PacketCodeModelPatterns on PacketCodeModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PacketCodeModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PacketCodeModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PacketCodeModel value)  $default,){
final _that = this;
switch (_that) {
case _PacketCodeModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PacketCodeModel value)?  $default,){
final _that = this;
switch (_that) {
case _PacketCodeModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@HiveField(0)  String id, @HiveField(1)  String code, @HiveField(2)  CodeType type, @HiveField(3)  CodeStatus status, @HiveField(4)  String factoryId, @HiveField(5)  String subscriptionPlanId, @HiveField(6)  String storeKeeperCode, @HiveField(7)  String internationalCode, @HiveField(8)  String batchId, @HiveField(9)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime generatedAt, @HiveField(10)  DateTime? linkedAt, @HiveField(11)  DateTime? publishedAt, @HiveField(12)  DateTime? deactivatedAt, @HiveField(13)  String? productId, @HiveField(14)  String? productBatchNumber, @HiveField(15)  DateTime? manufacturingDate, @HiveField(16)  DateTime? expiryDate, @HiveField(17)  int? warrantyMonths, @HiveField(18)  String? qrCodeData, @HiveField(19)  String? barcodeData, @HiveField(20)  String? metadata, @HiveField(21)  int version, @HiveField(22)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime createdAt, @HiveField(23)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime updatedAt, @HiveField(24)  bool isDeleted, @HiveField(25)  String cartonCode, @HiveField(26)  int unitCount, @HiveField(27)  List<String> unitCodes, @HiveField(28)  double? weight, @HiveField(29)  String? dimensions, @HiveField(30)  int sequenceNumber, @HiveField(31)  String? packetType, @HiveField(32)  String? material, @HiveField(33)  bool isSealed, @HiveField(34)  DateTime? sealedAt, @HiveField(35)  String? sealedBy, @HiveField(36)  String? sealingMethod, @HiveField(37)  String? packetBarcode, @HiveField(38)  String? packetQrCode, @HiveField(39)  String condition, @HiveField(40)  bool hasTamperEvidence, @HiveField(41)  bool hasChildSafety, @HiveField(42)  bool hasInstructions, @HiveField(43)  String? packetBatchNumber, @HiveField(44)  String? serialNumber, @HiveField(45)  String? color, @HiveField(46)  String? printingDetails, @HiveField(47)  bool qcPassed, @HiveField(48)  DateTime? qcPassedDate, @HiveField(49)  String? qcPassedBy, @HiveField(50)  String? qcNotes, @HiveField(51)  String codeFormat)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PacketCodeModel() when $default != null:
return $default(_that.id,_that.code,_that.type,_that.status,_that.factoryId,_that.subscriptionPlanId,_that.storeKeeperCode,_that.internationalCode,_that.batchId,_that.generatedAt,_that.linkedAt,_that.publishedAt,_that.deactivatedAt,_that.productId,_that.productBatchNumber,_that.manufacturingDate,_that.expiryDate,_that.warrantyMonths,_that.qrCodeData,_that.barcodeData,_that.metadata,_that.version,_that.createdAt,_that.updatedAt,_that.isDeleted,_that.cartonCode,_that.unitCount,_that.unitCodes,_that.weight,_that.dimensions,_that.sequenceNumber,_that.packetType,_that.material,_that.isSealed,_that.sealedAt,_that.sealedBy,_that.sealingMethod,_that.packetBarcode,_that.packetQrCode,_that.condition,_that.hasTamperEvidence,_that.hasChildSafety,_that.hasInstructions,_that.packetBatchNumber,_that.serialNumber,_that.color,_that.printingDetails,_that.qcPassed,_that.qcPassedDate,_that.qcPassedBy,_that.qcNotes,_that.codeFormat);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@HiveField(0)  String id, @HiveField(1)  String code, @HiveField(2)  CodeType type, @HiveField(3)  CodeStatus status, @HiveField(4)  String factoryId, @HiveField(5)  String subscriptionPlanId, @HiveField(6)  String storeKeeperCode, @HiveField(7)  String internationalCode, @HiveField(8)  String batchId, @HiveField(9)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime generatedAt, @HiveField(10)  DateTime? linkedAt, @HiveField(11)  DateTime? publishedAt, @HiveField(12)  DateTime? deactivatedAt, @HiveField(13)  String? productId, @HiveField(14)  String? productBatchNumber, @HiveField(15)  DateTime? manufacturingDate, @HiveField(16)  DateTime? expiryDate, @HiveField(17)  int? warrantyMonths, @HiveField(18)  String? qrCodeData, @HiveField(19)  String? barcodeData, @HiveField(20)  String? metadata, @HiveField(21)  int version, @HiveField(22)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime createdAt, @HiveField(23)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime updatedAt, @HiveField(24)  bool isDeleted, @HiveField(25)  String cartonCode, @HiveField(26)  int unitCount, @HiveField(27)  List<String> unitCodes, @HiveField(28)  double? weight, @HiveField(29)  String? dimensions, @HiveField(30)  int sequenceNumber, @HiveField(31)  String? packetType, @HiveField(32)  String? material, @HiveField(33)  bool isSealed, @HiveField(34)  DateTime? sealedAt, @HiveField(35)  String? sealedBy, @HiveField(36)  String? sealingMethod, @HiveField(37)  String? packetBarcode, @HiveField(38)  String? packetQrCode, @HiveField(39)  String condition, @HiveField(40)  bool hasTamperEvidence, @HiveField(41)  bool hasChildSafety, @HiveField(42)  bool hasInstructions, @HiveField(43)  String? packetBatchNumber, @HiveField(44)  String? serialNumber, @HiveField(45)  String? color, @HiveField(46)  String? printingDetails, @HiveField(47)  bool qcPassed, @HiveField(48)  DateTime? qcPassedDate, @HiveField(49)  String? qcPassedBy, @HiveField(50)  String? qcNotes, @HiveField(51)  String codeFormat)  $default,) {final _that = this;
switch (_that) {
case _PacketCodeModel():
return $default(_that.id,_that.code,_that.type,_that.status,_that.factoryId,_that.subscriptionPlanId,_that.storeKeeperCode,_that.internationalCode,_that.batchId,_that.generatedAt,_that.linkedAt,_that.publishedAt,_that.deactivatedAt,_that.productId,_that.productBatchNumber,_that.manufacturingDate,_that.expiryDate,_that.warrantyMonths,_that.qrCodeData,_that.barcodeData,_that.metadata,_that.version,_that.createdAt,_that.updatedAt,_that.isDeleted,_that.cartonCode,_that.unitCount,_that.unitCodes,_that.weight,_that.dimensions,_that.sequenceNumber,_that.packetType,_that.material,_that.isSealed,_that.sealedAt,_that.sealedBy,_that.sealingMethod,_that.packetBarcode,_that.packetQrCode,_that.condition,_that.hasTamperEvidence,_that.hasChildSafety,_that.hasInstructions,_that.packetBatchNumber,_that.serialNumber,_that.color,_that.printingDetails,_that.qcPassed,_that.qcPassedDate,_that.qcPassedBy,_that.qcNotes,_that.codeFormat);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@HiveField(0)  String id, @HiveField(1)  String code, @HiveField(2)  CodeType type, @HiveField(3)  CodeStatus status, @HiveField(4)  String factoryId, @HiveField(5)  String subscriptionPlanId, @HiveField(6)  String storeKeeperCode, @HiveField(7)  String internationalCode, @HiveField(8)  String batchId, @HiveField(9)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime generatedAt, @HiveField(10)  DateTime? linkedAt, @HiveField(11)  DateTime? publishedAt, @HiveField(12)  DateTime? deactivatedAt, @HiveField(13)  String? productId, @HiveField(14)  String? productBatchNumber, @HiveField(15)  DateTime? manufacturingDate, @HiveField(16)  DateTime? expiryDate, @HiveField(17)  int? warrantyMonths, @HiveField(18)  String? qrCodeData, @HiveField(19)  String? barcodeData, @HiveField(20)  String? metadata, @HiveField(21)  int version, @HiveField(22)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime createdAt, @HiveField(23)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime updatedAt, @HiveField(24)  bool isDeleted, @HiveField(25)  String cartonCode, @HiveField(26)  int unitCount, @HiveField(27)  List<String> unitCodes, @HiveField(28)  double? weight, @HiveField(29)  String? dimensions, @HiveField(30)  int sequenceNumber, @HiveField(31)  String? packetType, @HiveField(32)  String? material, @HiveField(33)  bool isSealed, @HiveField(34)  DateTime? sealedAt, @HiveField(35)  String? sealedBy, @HiveField(36)  String? sealingMethod, @HiveField(37)  String? packetBarcode, @HiveField(38)  String? packetQrCode, @HiveField(39)  String condition, @HiveField(40)  bool hasTamperEvidence, @HiveField(41)  bool hasChildSafety, @HiveField(42)  bool hasInstructions, @HiveField(43)  String? packetBatchNumber, @HiveField(44)  String? serialNumber, @HiveField(45)  String? color, @HiveField(46)  String? printingDetails, @HiveField(47)  bool qcPassed, @HiveField(48)  DateTime? qcPassedDate, @HiveField(49)  String? qcPassedBy, @HiveField(50)  String? qcNotes, @HiveField(51)  String codeFormat)?  $default,) {final _that = this;
switch (_that) {
case _PacketCodeModel() when $default != null:
return $default(_that.id,_that.code,_that.type,_that.status,_that.factoryId,_that.subscriptionPlanId,_that.storeKeeperCode,_that.internationalCode,_that.batchId,_that.generatedAt,_that.linkedAt,_that.publishedAt,_that.deactivatedAt,_that.productId,_that.productBatchNumber,_that.manufacturingDate,_that.expiryDate,_that.warrantyMonths,_that.qrCodeData,_that.barcodeData,_that.metadata,_that.version,_that.createdAt,_that.updatedAt,_that.isDeleted,_that.cartonCode,_that.unitCount,_that.unitCodes,_that.weight,_that.dimensions,_that.sequenceNumber,_that.packetType,_that.material,_that.isSealed,_that.sealedAt,_that.sealedBy,_that.sealingMethod,_that.packetBarcode,_that.packetQrCode,_that.condition,_that.hasTamperEvidence,_that.hasChildSafety,_that.hasInstructions,_that.packetBatchNumber,_that.serialNumber,_that.color,_that.printingDetails,_that.qcPassed,_that.qcPassedDate,_that.qcPassedBy,_that.qcNotes,_that.codeFormat);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PacketCodeModel extends PacketCodeModel {
  const _PacketCodeModel({@HiveField(0) required this.id, @HiveField(1) required this.code, @HiveField(2) this.type = CodeType.packet, @HiveField(3) this.status = CodeStatus.generated, @HiveField(4) this.factoryId = '', @HiveField(5) this.subscriptionPlanId = '', @HiveField(6) this.storeKeeperCode = '', @HiveField(7) this.internationalCode = '', @HiveField(8) this.batchId = '', @HiveField(9)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) required this.generatedAt, @HiveField(10) this.linkedAt, @HiveField(11) this.publishedAt, @HiveField(12) this.deactivatedAt, @HiveField(13) this.productId, @HiveField(14) this.productBatchNumber, @HiveField(15) this.manufacturingDate, @HiveField(16) this.expiryDate, @HiveField(17) this.warrantyMonths, @HiveField(18) this.qrCodeData, @HiveField(19) this.barcodeData, @HiveField(20) this.metadata, @HiveField(21) this.version = 1, @HiveField(22)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) required this.createdAt, @HiveField(23)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) required this.updatedAt, @HiveField(24) this.isDeleted = false, @HiveField(25) this.cartonCode = '', @HiveField(26) this.unitCount = 0, @HiveField(27) final  List<String> unitCodes = const <String>[], @HiveField(28) this.weight, @HiveField(29) this.dimensions, @HiveField(30) this.sequenceNumber = 0, @HiveField(31) this.packetType, @HiveField(32) this.material, @HiveField(33) this.isSealed = false, @HiveField(34) this.sealedAt, @HiveField(35) this.sealedBy, @HiveField(36) this.sealingMethod, @HiveField(37) this.packetBarcode, @HiveField(38) this.packetQrCode, @HiveField(39) this.condition = 'Intact', @HiveField(40) this.hasTamperEvidence = false, @HiveField(41) this.hasChildSafety = false, @HiveField(42) this.hasInstructions = false, @HiveField(43) this.packetBatchNumber, @HiveField(44) this.serialNumber, @HiveField(45) this.color, @HiveField(46) this.printingDetails, @HiveField(47) this.qcPassed = false, @HiveField(48) this.qcPassedDate, @HiveField(49) this.qcPassedBy, @HiveField(50) this.qcNotes, @HiveField(51) this.codeFormat = 'qr'}): _unitCodes = unitCodes,super._();
  factory _PacketCodeModel.fromJson(Map<String, dynamic> json) => _$PacketCodeModelFromJson(json);

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
/// Packet-specific properties
/// Carton code that contains this packet
@override@JsonKey()@HiveField(25) final  String cartonCode;
/// Number of units in this packet
@override@JsonKey()@HiveField(26) final  int unitCount;
/// List of unit codes contained in this packet
 final  List<String> _unitCodes;
/// List of unit codes contained in this packet
@override@JsonKey()@HiveField(27) List<String> get unitCodes {
  if (_unitCodes is EqualUnmodifiableListView) return _unitCodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_unitCodes);
}

/// Packet weight in grams
@override@HiveField(28) final  double? weight;
/// Packet dimensions (length x width x height in cm)
@override@HiveField(29) final  String? dimensions;
/// Packet sequence number within carton (e.g., 1, 2, 3...)
@override@JsonKey()@HiveField(30) final  int sequenceNumber;
/// Packet type (e.g., "Blister", "Box", "Pouch", "Bottle")
@override@HiveField(31) final  String? packetType;
/// Packet material (e.g., "Plastic", "Paper", "Aluminum")
@override@HiveField(32) final  String? material;
/// Is packet sealed?
@override@JsonKey()@HiveField(33) final  bool isSealed;
/// Sealing date
@override@HiveField(34) final  DateTime? sealedAt;
/// Sealed by (user ID)
@override@HiveField(35) final  String? sealedBy;
/// Sealing method (e.g., "Heat Seal", "Adhesive", "Clip")
@override@HiveField(36) final  String? sealingMethod;
/// Packet barcode (separate from product barcode)
@override@HiveField(37) final  String? packetBarcode;
/// Packet QR code (separate from product QR code)
@override@HiveField(38) final  String? packetQrCode;
/// Packet condition (e.g., "Intact", "Damaged", "Torn")
@override@JsonKey()@HiveField(39) final  String condition;
/// Tamper evidence seal present?
@override@JsonKey()@HiveField(40) final  bool hasTamperEvidence;
/// Child safety features present?
@override@JsonKey()@HiveField(41) final  bool hasChildSafety;
/// Instructions for use included?
@override@JsonKey()@HiveField(42) final  bool hasInstructions;
/// Batch number specific to this packet
@override@HiveField(43) final  String? packetBatchNumber;
/// Serial number specific to this packet
@override@HiveField(44) final  String? serialNumber;
/// Packet color (for identification)
@override@HiveField(45) final  String? color;
/// Packet printing details
@override@HiveField(46) final  String? printingDetails;
/// Quality control passed?
@override@JsonKey()@HiveField(47) final  bool qcPassed;
/// QC passed date
@override@HiveField(48) final  DateTime? qcPassedDate;
/// QC passed by (user ID)
@override@HiveField(49) final  String? qcPassedBy;
/// QC notes
@override@HiveField(50) final  String? qcNotes;
/// Packet code format type (itf14, gs1_128, code128_industrial, qr, datamatrix, code128_label)
@override@JsonKey()@HiveField(51) final  String codeFormat;

/// Create a copy of PacketCodeModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PacketCodeModelCopyWith<_PacketCodeModel> get copyWith => __$PacketCodeModelCopyWithImpl<_PacketCodeModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PacketCodeModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PacketCodeModel&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.factoryId, factoryId) || other.factoryId == factoryId)&&(identical(other.subscriptionPlanId, subscriptionPlanId) || other.subscriptionPlanId == subscriptionPlanId)&&(identical(other.storeKeeperCode, storeKeeperCode) || other.storeKeeperCode == storeKeeperCode)&&(identical(other.internationalCode, internationalCode) || other.internationalCode == internationalCode)&&(identical(other.batchId, batchId) || other.batchId == batchId)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.linkedAt, linkedAt) || other.linkedAt == linkedAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.deactivatedAt, deactivatedAt) || other.deactivatedAt == deactivatedAt)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productBatchNumber, productBatchNumber) || other.productBatchNumber == productBatchNumber)&&(identical(other.manufacturingDate, manufacturingDate) || other.manufacturingDate == manufacturingDate)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.warrantyMonths, warrantyMonths) || other.warrantyMonths == warrantyMonths)&&(identical(other.qrCodeData, qrCodeData) || other.qrCodeData == qrCodeData)&&(identical(other.barcodeData, barcodeData) || other.barcodeData == barcodeData)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.version, version) || other.version == version)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.cartonCode, cartonCode) || other.cartonCode == cartonCode)&&(identical(other.unitCount, unitCount) || other.unitCount == unitCount)&&const DeepCollectionEquality().equals(other._unitCodes, _unitCodes)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.dimensions, dimensions) || other.dimensions == dimensions)&&(identical(other.sequenceNumber, sequenceNumber) || other.sequenceNumber == sequenceNumber)&&(identical(other.packetType, packetType) || other.packetType == packetType)&&(identical(other.material, material) || other.material == material)&&(identical(other.isSealed, isSealed) || other.isSealed == isSealed)&&(identical(other.sealedAt, sealedAt) || other.sealedAt == sealedAt)&&(identical(other.sealedBy, sealedBy) || other.sealedBy == sealedBy)&&(identical(other.sealingMethod, sealingMethod) || other.sealingMethod == sealingMethod)&&(identical(other.packetBarcode, packetBarcode) || other.packetBarcode == packetBarcode)&&(identical(other.packetQrCode, packetQrCode) || other.packetQrCode == packetQrCode)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.hasTamperEvidence, hasTamperEvidence) || other.hasTamperEvidence == hasTamperEvidence)&&(identical(other.hasChildSafety, hasChildSafety) || other.hasChildSafety == hasChildSafety)&&(identical(other.hasInstructions, hasInstructions) || other.hasInstructions == hasInstructions)&&(identical(other.packetBatchNumber, packetBatchNumber) || other.packetBatchNumber == packetBatchNumber)&&(identical(other.serialNumber, serialNumber) || other.serialNumber == serialNumber)&&(identical(other.color, color) || other.color == color)&&(identical(other.printingDetails, printingDetails) || other.printingDetails == printingDetails)&&(identical(other.qcPassed, qcPassed) || other.qcPassed == qcPassed)&&(identical(other.qcPassedDate, qcPassedDate) || other.qcPassedDate == qcPassedDate)&&(identical(other.qcPassedBy, qcPassedBy) || other.qcPassedBy == qcPassedBy)&&(identical(other.qcNotes, qcNotes) || other.qcNotes == qcNotes)&&(identical(other.codeFormat, codeFormat) || other.codeFormat == codeFormat));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,code,type,status,factoryId,subscriptionPlanId,storeKeeperCode,internationalCode,batchId,generatedAt,linkedAt,publishedAt,deactivatedAt,productId,productBatchNumber,manufacturingDate,expiryDate,warrantyMonths,qrCodeData,barcodeData,metadata,version,createdAt,updatedAt,isDeleted,cartonCode,unitCount,const DeepCollectionEquality().hash(_unitCodes),weight,dimensions,sequenceNumber,packetType,material,isSealed,sealedAt,sealedBy,sealingMethod,packetBarcode,packetQrCode,condition,hasTamperEvidence,hasChildSafety,hasInstructions,packetBatchNumber,serialNumber,color,printingDetails,qcPassed,qcPassedDate,qcPassedBy,qcNotes,codeFormat]);

@override
String toString() {
  return 'PacketCodeModel(id: $id, code: $code, type: $type, status: $status, factoryId: $factoryId, subscriptionPlanId: $subscriptionPlanId, storeKeeperCode: $storeKeeperCode, internationalCode: $internationalCode, batchId: $batchId, generatedAt: $generatedAt, linkedAt: $linkedAt, publishedAt: $publishedAt, deactivatedAt: $deactivatedAt, productId: $productId, productBatchNumber: $productBatchNumber, manufacturingDate: $manufacturingDate, expiryDate: $expiryDate, warrantyMonths: $warrantyMonths, qrCodeData: $qrCodeData, barcodeData: $barcodeData, metadata: $metadata, version: $version, createdAt: $createdAt, updatedAt: $updatedAt, isDeleted: $isDeleted, cartonCode: $cartonCode, unitCount: $unitCount, unitCodes: $unitCodes, weight: $weight, dimensions: $dimensions, sequenceNumber: $sequenceNumber, packetType: $packetType, material: $material, isSealed: $isSealed, sealedAt: $sealedAt, sealedBy: $sealedBy, sealingMethod: $sealingMethod, packetBarcode: $packetBarcode, packetQrCode: $packetQrCode, condition: $condition, hasTamperEvidence: $hasTamperEvidence, hasChildSafety: $hasChildSafety, hasInstructions: $hasInstructions, packetBatchNumber: $packetBatchNumber, serialNumber: $serialNumber, color: $color, printingDetails: $printingDetails, qcPassed: $qcPassed, qcPassedDate: $qcPassedDate, qcPassedBy: $qcPassedBy, qcNotes: $qcNotes, codeFormat: $codeFormat)';
}


}

/// @nodoc
abstract mixin class _$PacketCodeModelCopyWith<$Res> implements $PacketCodeModelCopyWith<$Res> {
  factory _$PacketCodeModelCopyWith(_PacketCodeModel value, $Res Function(_PacketCodeModel) _then) = __$PacketCodeModelCopyWithImpl;
@override @useResult
$Res call({
@HiveField(0) String id,@HiveField(1) String code,@HiveField(2) CodeType type,@HiveField(3) CodeStatus status,@HiveField(4) String factoryId,@HiveField(5) String subscriptionPlanId,@HiveField(6) String storeKeeperCode,@HiveField(7) String internationalCode,@HiveField(8) String batchId,@HiveField(9)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime generatedAt,@HiveField(10) DateTime? linkedAt,@HiveField(11) DateTime? publishedAt,@HiveField(12) DateTime? deactivatedAt,@HiveField(13) String? productId,@HiveField(14) String? productBatchNumber,@HiveField(15) DateTime? manufacturingDate,@HiveField(16) DateTime? expiryDate,@HiveField(17) int? warrantyMonths,@HiveField(18) String? qrCodeData,@HiveField(19) String? barcodeData,@HiveField(20) String? metadata,@HiveField(21) int version,@HiveField(22)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime createdAt,@HiveField(23)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime updatedAt,@HiveField(24) bool isDeleted,@HiveField(25) String cartonCode,@HiveField(26) int unitCount,@HiveField(27) List<String> unitCodes,@HiveField(28) double? weight,@HiveField(29) String? dimensions,@HiveField(30) int sequenceNumber,@HiveField(31) String? packetType,@HiveField(32) String? material,@HiveField(33) bool isSealed,@HiveField(34) DateTime? sealedAt,@HiveField(35) String? sealedBy,@HiveField(36) String? sealingMethod,@HiveField(37) String? packetBarcode,@HiveField(38) String? packetQrCode,@HiveField(39) String condition,@HiveField(40) bool hasTamperEvidence,@HiveField(41) bool hasChildSafety,@HiveField(42) bool hasInstructions,@HiveField(43) String? packetBatchNumber,@HiveField(44) String? serialNumber,@HiveField(45) String? color,@HiveField(46) String? printingDetails,@HiveField(47) bool qcPassed,@HiveField(48) DateTime? qcPassedDate,@HiveField(49) String? qcPassedBy,@HiveField(50) String? qcNotes,@HiveField(51) String codeFormat
});




}
/// @nodoc
class __$PacketCodeModelCopyWithImpl<$Res>
    implements _$PacketCodeModelCopyWith<$Res> {
  __$PacketCodeModelCopyWithImpl(this._self, this._then);

  final _PacketCodeModel _self;
  final $Res Function(_PacketCodeModel) _then;

/// Create a copy of PacketCodeModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? type = null,Object? status = null,Object? factoryId = null,Object? subscriptionPlanId = null,Object? storeKeeperCode = null,Object? internationalCode = null,Object? batchId = null,Object? generatedAt = null,Object? linkedAt = freezed,Object? publishedAt = freezed,Object? deactivatedAt = freezed,Object? productId = freezed,Object? productBatchNumber = freezed,Object? manufacturingDate = freezed,Object? expiryDate = freezed,Object? warrantyMonths = freezed,Object? qrCodeData = freezed,Object? barcodeData = freezed,Object? metadata = freezed,Object? version = null,Object? createdAt = null,Object? updatedAt = null,Object? isDeleted = null,Object? cartonCode = null,Object? unitCount = null,Object? unitCodes = null,Object? weight = freezed,Object? dimensions = freezed,Object? sequenceNumber = null,Object? packetType = freezed,Object? material = freezed,Object? isSealed = null,Object? sealedAt = freezed,Object? sealedBy = freezed,Object? sealingMethod = freezed,Object? packetBarcode = freezed,Object? packetQrCode = freezed,Object? condition = null,Object? hasTamperEvidence = null,Object? hasChildSafety = null,Object? hasInstructions = null,Object? packetBatchNumber = freezed,Object? serialNumber = freezed,Object? color = freezed,Object? printingDetails = freezed,Object? qcPassed = null,Object? qcPassedDate = freezed,Object? qcPassedBy = freezed,Object? qcNotes = freezed,Object? codeFormat = null,}) {
  return _then(_PacketCodeModel(
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
as bool,cartonCode: null == cartonCode ? _self.cartonCode : cartonCode // ignore: cast_nullable_to_non_nullable
as String,unitCount: null == unitCount ? _self.unitCount : unitCount // ignore: cast_nullable_to_non_nullable
as int,unitCodes: null == unitCodes ? _self._unitCodes : unitCodes // ignore: cast_nullable_to_non_nullable
as List<String>,weight: freezed == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double?,dimensions: freezed == dimensions ? _self.dimensions : dimensions // ignore: cast_nullable_to_non_nullable
as String?,sequenceNumber: null == sequenceNumber ? _self.sequenceNumber : sequenceNumber // ignore: cast_nullable_to_non_nullable
as int,packetType: freezed == packetType ? _self.packetType : packetType // ignore: cast_nullable_to_non_nullable
as String?,material: freezed == material ? _self.material : material // ignore: cast_nullable_to_non_nullable
as String?,isSealed: null == isSealed ? _self.isSealed : isSealed // ignore: cast_nullable_to_non_nullable
as bool,sealedAt: freezed == sealedAt ? _self.sealedAt : sealedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,sealedBy: freezed == sealedBy ? _self.sealedBy : sealedBy // ignore: cast_nullable_to_non_nullable
as String?,sealingMethod: freezed == sealingMethod ? _self.sealingMethod : sealingMethod // ignore: cast_nullable_to_non_nullable
as String?,packetBarcode: freezed == packetBarcode ? _self.packetBarcode : packetBarcode // ignore: cast_nullable_to_non_nullable
as String?,packetQrCode: freezed == packetQrCode ? _self.packetQrCode : packetQrCode // ignore: cast_nullable_to_non_nullable
as String?,condition: null == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as String,hasTamperEvidence: null == hasTamperEvidence ? _self.hasTamperEvidence : hasTamperEvidence // ignore: cast_nullable_to_non_nullable
as bool,hasChildSafety: null == hasChildSafety ? _self.hasChildSafety : hasChildSafety // ignore: cast_nullable_to_non_nullable
as bool,hasInstructions: null == hasInstructions ? _self.hasInstructions : hasInstructions // ignore: cast_nullable_to_non_nullable
as bool,packetBatchNumber: freezed == packetBatchNumber ? _self.packetBatchNumber : packetBatchNumber // ignore: cast_nullable_to_non_nullable
as String?,serialNumber: freezed == serialNumber ? _self.serialNumber : serialNumber // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,printingDetails: freezed == printingDetails ? _self.printingDetails : printingDetails // ignore: cast_nullable_to_non_nullable
as String?,qcPassed: null == qcPassed ? _self.qcPassed : qcPassed // ignore: cast_nullable_to_non_nullable
as bool,qcPassedDate: freezed == qcPassedDate ? _self.qcPassedDate : qcPassedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,qcPassedBy: freezed == qcPassedBy ? _self.qcPassedBy : qcPassedBy // ignore: cast_nullable_to_non_nullable
as String?,qcNotes: freezed == qcNotes ? _self.qcNotes : qcNotes // ignore: cast_nullable_to_non_nullable
as String?,codeFormat: null == codeFormat ? _self.codeFormat : codeFormat // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

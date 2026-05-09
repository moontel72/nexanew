// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'unit_code_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UnitCodeModel {

/// Base code properties
@HiveField(0) String get id;@HiveField(1) String get code;@HiveField(2) CodeType get type;@HiveField(3) CodeStatus get status;@HiveField(4) String get factoryId;@HiveField(5) String get subscriptionPlanId;@HiveField(6) String get storeKeeperCode;@HiveField(7) String? get internationalCode;// Optional for unit codes
@HiveField(8) String get batchId;@HiveField(9)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime get generatedAt;@HiveField(10) DateTime? get linkedAt;@HiveField(11) DateTime? get publishedAt;@HiveField(12) DateTime? get deactivatedAt;@HiveField(13) String? get productId;@HiveField(14) String? get productBatchNumber;@HiveField(15) DateTime? get manufacturingDate;@HiveField(16) DateTime? get expiryDate;@HiveField(17) int? get warrantyMonths;@HiveField(18) String? get qrCodeData;@HiveField(19) String? get barcodeData;@HiveField(20) String? get metadata;@HiveField(21) int get version;@HiveField(22)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime get createdAt;@HiveField(23)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime get updatedAt;@HiveField(24) bool get isDeleted;/// Unit-specific properties
/// Packet code that contains this unit
@HiveField(25) String get packetCode;/// Unit sequence number within packet (e.g., 1, 2, 3...)
@HiveField(26) int get sequenceNumber;/// Authentication code (system-generated for verification)
@HiveField(27) String get authenticationCode;/// Is this a master authentication code?
@HiveField(28) bool get isMasterCode;/// Master code ID (if this is a sub-code)
@HiveField(29) String? get masterCodeId;/// Verification count (how many times this code has been verified)
@HiveField(30) int get verificationCount;/// First verification date
@HiveField(31) DateTime? get firstVerifiedAt;/// Last verification date
@HiveField(32) DateTime? get lastVerifiedAt;/// Verification location (GPS coordinates or address)
@HiveField(33) String? get verificationLocation;/// Verified by (user ID or device ID)
@HiveField(34) String? get verifiedBy;/// Is code reported as fake/counterfeit?
@HiveField(35) bool get isReportedFake;/// Fake report date
@HiveField(36) DateTime? get fakeReportedAt;/// Fake reported by (user ID)
@HiveField(37) String? get fakeReportedBy;/// Fake report reason
@HiveField(38) String? get fakeReportReason;/// Is code blocked?
@HiveField(39) bool get isBlocked;/// Blocked date
@HiveField(40) DateTime? get blockedAt;/// Blocked by (user ID)
@HiveField(41) String? get blockedBy;/// Block reason
@HiveField(42) String? get blockReason;/// Unit serial number (unique per unit)
@HiveField(43) String get serialNumber;/// Unit model/variant
@HiveField(44) String? get model;/// Unit color
@HiveField(45) String? get color;/// Unit size
@HiveField(46) String? get size;/// Unit weight in grams
@HiveField(47) double? get weight;/// Unit dimensions (length x width x height in cm)
@HiveField(48) String? get dimensions;/// Unit condition (e.g., "New", "Used", "Refurbished")
@HiveField(49) String get condition;/// Unit grade/quality
@HiveField(50) String? get grade;/// Has warranty card?
@HiveField(51) bool get hasWarrantyCard;/// Has user manual?
@HiveField(52) bool get hasUserManual;/// Has accessories?
@HiveField(53) bool get hasAccessories;/// Accessories list (JSON string)
@HiveField(54) String? get accessoriesList;/// Special features (JSON string)
@HiveField(55) String? get specialFeatures;/// Safety certifications (JSON string)
@HiveField(56) String? get safetyCertifications;/// Compliance standards (JSON string)
@HiveField(57) String? get complianceStandards;/// Last maintenance date
@HiveField(58) DateTime? get lastMaintenanceDate;/// Maintenance notes
@HiveField(59) String? get maintenanceNotes;/// Is unit activated?
@HiveField(60) bool get isActivated;/// Activation date
@HiveField(61) DateTime? get activatedAt;/// Activated by (user ID)
@HiveField(62) String? get activatedBy;/// Activation location
@HiveField(63) String? get activationLocation;/// Unit code format type (itf14, gs1_128, code128_industrial, qr, datamatrix, code128_label)
@HiveField(64) String get codeFormat;
/// Create a copy of UnitCodeModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnitCodeModelCopyWith<UnitCodeModel> get copyWith => _$UnitCodeModelCopyWithImpl<UnitCodeModel>(this as UnitCodeModel, _$identity);

  /// Serializes this UnitCodeModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnitCodeModel&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.factoryId, factoryId) || other.factoryId == factoryId)&&(identical(other.subscriptionPlanId, subscriptionPlanId) || other.subscriptionPlanId == subscriptionPlanId)&&(identical(other.storeKeeperCode, storeKeeperCode) || other.storeKeeperCode == storeKeeperCode)&&(identical(other.internationalCode, internationalCode) || other.internationalCode == internationalCode)&&(identical(other.batchId, batchId) || other.batchId == batchId)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.linkedAt, linkedAt) || other.linkedAt == linkedAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.deactivatedAt, deactivatedAt) || other.deactivatedAt == deactivatedAt)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productBatchNumber, productBatchNumber) || other.productBatchNumber == productBatchNumber)&&(identical(other.manufacturingDate, manufacturingDate) || other.manufacturingDate == manufacturingDate)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.warrantyMonths, warrantyMonths) || other.warrantyMonths == warrantyMonths)&&(identical(other.qrCodeData, qrCodeData) || other.qrCodeData == qrCodeData)&&(identical(other.barcodeData, barcodeData) || other.barcodeData == barcodeData)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.version, version) || other.version == version)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.packetCode, packetCode) || other.packetCode == packetCode)&&(identical(other.sequenceNumber, sequenceNumber) || other.sequenceNumber == sequenceNumber)&&(identical(other.authenticationCode, authenticationCode) || other.authenticationCode == authenticationCode)&&(identical(other.isMasterCode, isMasterCode) || other.isMasterCode == isMasterCode)&&(identical(other.masterCodeId, masterCodeId) || other.masterCodeId == masterCodeId)&&(identical(other.verificationCount, verificationCount) || other.verificationCount == verificationCount)&&(identical(other.firstVerifiedAt, firstVerifiedAt) || other.firstVerifiedAt == firstVerifiedAt)&&(identical(other.lastVerifiedAt, lastVerifiedAt) || other.lastVerifiedAt == lastVerifiedAt)&&(identical(other.verificationLocation, verificationLocation) || other.verificationLocation == verificationLocation)&&(identical(other.verifiedBy, verifiedBy) || other.verifiedBy == verifiedBy)&&(identical(other.isReportedFake, isReportedFake) || other.isReportedFake == isReportedFake)&&(identical(other.fakeReportedAt, fakeReportedAt) || other.fakeReportedAt == fakeReportedAt)&&(identical(other.fakeReportedBy, fakeReportedBy) || other.fakeReportedBy == fakeReportedBy)&&(identical(other.fakeReportReason, fakeReportReason) || other.fakeReportReason == fakeReportReason)&&(identical(other.isBlocked, isBlocked) || other.isBlocked == isBlocked)&&(identical(other.blockedAt, blockedAt) || other.blockedAt == blockedAt)&&(identical(other.blockedBy, blockedBy) || other.blockedBy == blockedBy)&&(identical(other.blockReason, blockReason) || other.blockReason == blockReason)&&(identical(other.serialNumber, serialNumber) || other.serialNumber == serialNumber)&&(identical(other.model, model) || other.model == model)&&(identical(other.color, color) || other.color == color)&&(identical(other.size, size) || other.size == size)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.dimensions, dimensions) || other.dimensions == dimensions)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.hasWarrantyCard, hasWarrantyCard) || other.hasWarrantyCard == hasWarrantyCard)&&(identical(other.hasUserManual, hasUserManual) || other.hasUserManual == hasUserManual)&&(identical(other.hasAccessories, hasAccessories) || other.hasAccessories == hasAccessories)&&(identical(other.accessoriesList, accessoriesList) || other.accessoriesList == accessoriesList)&&(identical(other.specialFeatures, specialFeatures) || other.specialFeatures == specialFeatures)&&(identical(other.safetyCertifications, safetyCertifications) || other.safetyCertifications == safetyCertifications)&&(identical(other.complianceStandards, complianceStandards) || other.complianceStandards == complianceStandards)&&(identical(other.lastMaintenanceDate, lastMaintenanceDate) || other.lastMaintenanceDate == lastMaintenanceDate)&&(identical(other.maintenanceNotes, maintenanceNotes) || other.maintenanceNotes == maintenanceNotes)&&(identical(other.isActivated, isActivated) || other.isActivated == isActivated)&&(identical(other.activatedAt, activatedAt) || other.activatedAt == activatedAt)&&(identical(other.activatedBy, activatedBy) || other.activatedBy == activatedBy)&&(identical(other.activationLocation, activationLocation) || other.activationLocation == activationLocation)&&(identical(other.codeFormat, codeFormat) || other.codeFormat == codeFormat));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,code,type,status,factoryId,subscriptionPlanId,storeKeeperCode,internationalCode,batchId,generatedAt,linkedAt,publishedAt,deactivatedAt,productId,productBatchNumber,manufacturingDate,expiryDate,warrantyMonths,qrCodeData,barcodeData,metadata,version,createdAt,updatedAt,isDeleted,packetCode,sequenceNumber,authenticationCode,isMasterCode,masterCodeId,verificationCount,firstVerifiedAt,lastVerifiedAt,verificationLocation,verifiedBy,isReportedFake,fakeReportedAt,fakeReportedBy,fakeReportReason,isBlocked,blockedAt,blockedBy,blockReason,serialNumber,model,color,size,weight,dimensions,condition,grade,hasWarrantyCard,hasUserManual,hasAccessories,accessoriesList,specialFeatures,safetyCertifications,complianceStandards,lastMaintenanceDate,maintenanceNotes,isActivated,activatedAt,activatedBy,activationLocation,codeFormat]);

@override
String toString() {
  return 'UnitCodeModel(id: $id, code: $code, type: $type, status: $status, factoryId: $factoryId, subscriptionPlanId: $subscriptionPlanId, storeKeeperCode: $storeKeeperCode, internationalCode: $internationalCode, batchId: $batchId, generatedAt: $generatedAt, linkedAt: $linkedAt, publishedAt: $publishedAt, deactivatedAt: $deactivatedAt, productId: $productId, productBatchNumber: $productBatchNumber, manufacturingDate: $manufacturingDate, expiryDate: $expiryDate, warrantyMonths: $warrantyMonths, qrCodeData: $qrCodeData, barcodeData: $barcodeData, metadata: $metadata, version: $version, createdAt: $createdAt, updatedAt: $updatedAt, isDeleted: $isDeleted, packetCode: $packetCode, sequenceNumber: $sequenceNumber, authenticationCode: $authenticationCode, isMasterCode: $isMasterCode, masterCodeId: $masterCodeId, verificationCount: $verificationCount, firstVerifiedAt: $firstVerifiedAt, lastVerifiedAt: $lastVerifiedAt, verificationLocation: $verificationLocation, verifiedBy: $verifiedBy, isReportedFake: $isReportedFake, fakeReportedAt: $fakeReportedAt, fakeReportedBy: $fakeReportedBy, fakeReportReason: $fakeReportReason, isBlocked: $isBlocked, blockedAt: $blockedAt, blockedBy: $blockedBy, blockReason: $blockReason, serialNumber: $serialNumber, model: $model, color: $color, size: $size, weight: $weight, dimensions: $dimensions, condition: $condition, grade: $grade, hasWarrantyCard: $hasWarrantyCard, hasUserManual: $hasUserManual, hasAccessories: $hasAccessories, accessoriesList: $accessoriesList, specialFeatures: $specialFeatures, safetyCertifications: $safetyCertifications, complianceStandards: $complianceStandards, lastMaintenanceDate: $lastMaintenanceDate, maintenanceNotes: $maintenanceNotes, isActivated: $isActivated, activatedAt: $activatedAt, activatedBy: $activatedBy, activationLocation: $activationLocation, codeFormat: $codeFormat)';
}


}

/// @nodoc
abstract mixin class $UnitCodeModelCopyWith<$Res>  {
  factory $UnitCodeModelCopyWith(UnitCodeModel value, $Res Function(UnitCodeModel) _then) = _$UnitCodeModelCopyWithImpl;
@useResult
$Res call({
@HiveField(0) String id,@HiveField(1) String code,@HiveField(2) CodeType type,@HiveField(3) CodeStatus status,@HiveField(4) String factoryId,@HiveField(5) String subscriptionPlanId,@HiveField(6) String storeKeeperCode,@HiveField(7) String? internationalCode,@HiveField(8) String batchId,@HiveField(9)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime generatedAt,@HiveField(10) DateTime? linkedAt,@HiveField(11) DateTime? publishedAt,@HiveField(12) DateTime? deactivatedAt,@HiveField(13) String? productId,@HiveField(14) String? productBatchNumber,@HiveField(15) DateTime? manufacturingDate,@HiveField(16) DateTime? expiryDate,@HiveField(17) int? warrantyMonths,@HiveField(18) String? qrCodeData,@HiveField(19) String? barcodeData,@HiveField(20) String? metadata,@HiveField(21) int version,@HiveField(22)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime createdAt,@HiveField(23)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime updatedAt,@HiveField(24) bool isDeleted,@HiveField(25) String packetCode,@HiveField(26) int sequenceNumber,@HiveField(27) String authenticationCode,@HiveField(28) bool isMasterCode,@HiveField(29) String? masterCodeId,@HiveField(30) int verificationCount,@HiveField(31) DateTime? firstVerifiedAt,@HiveField(32) DateTime? lastVerifiedAt,@HiveField(33) String? verificationLocation,@HiveField(34) String? verifiedBy,@HiveField(35) bool isReportedFake,@HiveField(36) DateTime? fakeReportedAt,@HiveField(37) String? fakeReportedBy,@HiveField(38) String? fakeReportReason,@HiveField(39) bool isBlocked,@HiveField(40) DateTime? blockedAt,@HiveField(41) String? blockedBy,@HiveField(42) String? blockReason,@HiveField(43) String serialNumber,@HiveField(44) String? model,@HiveField(45) String? color,@HiveField(46) String? size,@HiveField(47) double? weight,@HiveField(48) String? dimensions,@HiveField(49) String condition,@HiveField(50) String? grade,@HiveField(51) bool hasWarrantyCard,@HiveField(52) bool hasUserManual,@HiveField(53) bool hasAccessories,@HiveField(54) String? accessoriesList,@HiveField(55) String? specialFeatures,@HiveField(56) String? safetyCertifications,@HiveField(57) String? complianceStandards,@HiveField(58) DateTime? lastMaintenanceDate,@HiveField(59) String? maintenanceNotes,@HiveField(60) bool isActivated,@HiveField(61) DateTime? activatedAt,@HiveField(62) String? activatedBy,@HiveField(63) String? activationLocation,@HiveField(64) String codeFormat
});




}
/// @nodoc
class _$UnitCodeModelCopyWithImpl<$Res>
    implements $UnitCodeModelCopyWith<$Res> {
  _$UnitCodeModelCopyWithImpl(this._self, this._then);

  final UnitCodeModel _self;
  final $Res Function(UnitCodeModel) _then;

/// Create a copy of UnitCodeModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? type = null,Object? status = null,Object? factoryId = null,Object? subscriptionPlanId = null,Object? storeKeeperCode = null,Object? internationalCode = freezed,Object? batchId = null,Object? generatedAt = null,Object? linkedAt = freezed,Object? publishedAt = freezed,Object? deactivatedAt = freezed,Object? productId = freezed,Object? productBatchNumber = freezed,Object? manufacturingDate = freezed,Object? expiryDate = freezed,Object? warrantyMonths = freezed,Object? qrCodeData = freezed,Object? barcodeData = freezed,Object? metadata = freezed,Object? version = null,Object? createdAt = null,Object? updatedAt = null,Object? isDeleted = null,Object? packetCode = null,Object? sequenceNumber = null,Object? authenticationCode = null,Object? isMasterCode = null,Object? masterCodeId = freezed,Object? verificationCount = null,Object? firstVerifiedAt = freezed,Object? lastVerifiedAt = freezed,Object? verificationLocation = freezed,Object? verifiedBy = freezed,Object? isReportedFake = null,Object? fakeReportedAt = freezed,Object? fakeReportedBy = freezed,Object? fakeReportReason = freezed,Object? isBlocked = null,Object? blockedAt = freezed,Object? blockedBy = freezed,Object? blockReason = freezed,Object? serialNumber = null,Object? model = freezed,Object? color = freezed,Object? size = freezed,Object? weight = freezed,Object? dimensions = freezed,Object? condition = null,Object? grade = freezed,Object? hasWarrantyCard = null,Object? hasUserManual = null,Object? hasAccessories = null,Object? accessoriesList = freezed,Object? specialFeatures = freezed,Object? safetyCertifications = freezed,Object? complianceStandards = freezed,Object? lastMaintenanceDate = freezed,Object? maintenanceNotes = freezed,Object? isActivated = null,Object? activatedAt = freezed,Object? activatedBy = freezed,Object? activationLocation = freezed,Object? codeFormat = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CodeType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CodeStatus,factoryId: null == factoryId ? _self.factoryId : factoryId // ignore: cast_nullable_to_non_nullable
as String,subscriptionPlanId: null == subscriptionPlanId ? _self.subscriptionPlanId : subscriptionPlanId // ignore: cast_nullable_to_non_nullable
as String,storeKeeperCode: null == storeKeeperCode ? _self.storeKeeperCode : storeKeeperCode // ignore: cast_nullable_to_non_nullable
as String,internationalCode: freezed == internationalCode ? _self.internationalCode : internationalCode // ignore: cast_nullable_to_non_nullable
as String?,batchId: null == batchId ? _self.batchId : batchId // ignore: cast_nullable_to_non_nullable
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
as bool,packetCode: null == packetCode ? _self.packetCode : packetCode // ignore: cast_nullable_to_non_nullable
as String,sequenceNumber: null == sequenceNumber ? _self.sequenceNumber : sequenceNumber // ignore: cast_nullable_to_non_nullable
as int,authenticationCode: null == authenticationCode ? _self.authenticationCode : authenticationCode // ignore: cast_nullable_to_non_nullable
as String,isMasterCode: null == isMasterCode ? _self.isMasterCode : isMasterCode // ignore: cast_nullable_to_non_nullable
as bool,masterCodeId: freezed == masterCodeId ? _self.masterCodeId : masterCodeId // ignore: cast_nullable_to_non_nullable
as String?,verificationCount: null == verificationCount ? _self.verificationCount : verificationCount // ignore: cast_nullable_to_non_nullable
as int,firstVerifiedAt: freezed == firstVerifiedAt ? _self.firstVerifiedAt : firstVerifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastVerifiedAt: freezed == lastVerifiedAt ? _self.lastVerifiedAt : lastVerifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,verificationLocation: freezed == verificationLocation ? _self.verificationLocation : verificationLocation // ignore: cast_nullable_to_non_nullable
as String?,verifiedBy: freezed == verifiedBy ? _self.verifiedBy : verifiedBy // ignore: cast_nullable_to_non_nullable
as String?,isReportedFake: null == isReportedFake ? _self.isReportedFake : isReportedFake // ignore: cast_nullable_to_non_nullable
as bool,fakeReportedAt: freezed == fakeReportedAt ? _self.fakeReportedAt : fakeReportedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,fakeReportedBy: freezed == fakeReportedBy ? _self.fakeReportedBy : fakeReportedBy // ignore: cast_nullable_to_non_nullable
as String?,fakeReportReason: freezed == fakeReportReason ? _self.fakeReportReason : fakeReportReason // ignore: cast_nullable_to_non_nullable
as String?,isBlocked: null == isBlocked ? _self.isBlocked : isBlocked // ignore: cast_nullable_to_non_nullable
as bool,blockedAt: freezed == blockedAt ? _self.blockedAt : blockedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,blockedBy: freezed == blockedBy ? _self.blockedBy : blockedBy // ignore: cast_nullable_to_non_nullable
as String?,blockReason: freezed == blockReason ? _self.blockReason : blockReason // ignore: cast_nullable_to_non_nullable
as String?,serialNumber: null == serialNumber ? _self.serialNumber : serialNumber // ignore: cast_nullable_to_non_nullable
as String,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String?,weight: freezed == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double?,dimensions: freezed == dimensions ? _self.dimensions : dimensions // ignore: cast_nullable_to_non_nullable
as String?,condition: null == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as String,grade: freezed == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as String?,hasWarrantyCard: null == hasWarrantyCard ? _self.hasWarrantyCard : hasWarrantyCard // ignore: cast_nullable_to_non_nullable
as bool,hasUserManual: null == hasUserManual ? _self.hasUserManual : hasUserManual // ignore: cast_nullable_to_non_nullable
as bool,hasAccessories: null == hasAccessories ? _self.hasAccessories : hasAccessories // ignore: cast_nullable_to_non_nullable
as bool,accessoriesList: freezed == accessoriesList ? _self.accessoriesList : accessoriesList // ignore: cast_nullable_to_non_nullable
as String?,specialFeatures: freezed == specialFeatures ? _self.specialFeatures : specialFeatures // ignore: cast_nullable_to_non_nullable
as String?,safetyCertifications: freezed == safetyCertifications ? _self.safetyCertifications : safetyCertifications // ignore: cast_nullable_to_non_nullable
as String?,complianceStandards: freezed == complianceStandards ? _self.complianceStandards : complianceStandards // ignore: cast_nullable_to_non_nullable
as String?,lastMaintenanceDate: freezed == lastMaintenanceDate ? _self.lastMaintenanceDate : lastMaintenanceDate // ignore: cast_nullable_to_non_nullable
as DateTime?,maintenanceNotes: freezed == maintenanceNotes ? _self.maintenanceNotes : maintenanceNotes // ignore: cast_nullable_to_non_nullable
as String?,isActivated: null == isActivated ? _self.isActivated : isActivated // ignore: cast_nullable_to_non_nullable
as bool,activatedAt: freezed == activatedAt ? _self.activatedAt : activatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,activatedBy: freezed == activatedBy ? _self.activatedBy : activatedBy // ignore: cast_nullable_to_non_nullable
as String?,activationLocation: freezed == activationLocation ? _self.activationLocation : activationLocation // ignore: cast_nullable_to_non_nullable
as String?,codeFormat: null == codeFormat ? _self.codeFormat : codeFormat // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UnitCodeModel].
extension UnitCodeModelPatterns on UnitCodeModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UnitCodeModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UnitCodeModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UnitCodeModel value)  $default,){
final _that = this;
switch (_that) {
case _UnitCodeModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UnitCodeModel value)?  $default,){
final _that = this;
switch (_that) {
case _UnitCodeModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@HiveField(0)  String id, @HiveField(1)  String code, @HiveField(2)  CodeType type, @HiveField(3)  CodeStatus status, @HiveField(4)  String factoryId, @HiveField(5)  String subscriptionPlanId, @HiveField(6)  String storeKeeperCode, @HiveField(7)  String? internationalCode, @HiveField(8)  String batchId, @HiveField(9)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime generatedAt, @HiveField(10)  DateTime? linkedAt, @HiveField(11)  DateTime? publishedAt, @HiveField(12)  DateTime? deactivatedAt, @HiveField(13)  String? productId, @HiveField(14)  String? productBatchNumber, @HiveField(15)  DateTime? manufacturingDate, @HiveField(16)  DateTime? expiryDate, @HiveField(17)  int? warrantyMonths, @HiveField(18)  String? qrCodeData, @HiveField(19)  String? barcodeData, @HiveField(20)  String? metadata, @HiveField(21)  int version, @HiveField(22)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime createdAt, @HiveField(23)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime updatedAt, @HiveField(24)  bool isDeleted, @HiveField(25)  String packetCode, @HiveField(26)  int sequenceNumber, @HiveField(27)  String authenticationCode, @HiveField(28)  bool isMasterCode, @HiveField(29)  String? masterCodeId, @HiveField(30)  int verificationCount, @HiveField(31)  DateTime? firstVerifiedAt, @HiveField(32)  DateTime? lastVerifiedAt, @HiveField(33)  String? verificationLocation, @HiveField(34)  String? verifiedBy, @HiveField(35)  bool isReportedFake, @HiveField(36)  DateTime? fakeReportedAt, @HiveField(37)  String? fakeReportedBy, @HiveField(38)  String? fakeReportReason, @HiveField(39)  bool isBlocked, @HiveField(40)  DateTime? blockedAt, @HiveField(41)  String? blockedBy, @HiveField(42)  String? blockReason, @HiveField(43)  String serialNumber, @HiveField(44)  String? model, @HiveField(45)  String? color, @HiveField(46)  String? size, @HiveField(47)  double? weight, @HiveField(48)  String? dimensions, @HiveField(49)  String condition, @HiveField(50)  String? grade, @HiveField(51)  bool hasWarrantyCard, @HiveField(52)  bool hasUserManual, @HiveField(53)  bool hasAccessories, @HiveField(54)  String? accessoriesList, @HiveField(55)  String? specialFeatures, @HiveField(56)  String? safetyCertifications, @HiveField(57)  String? complianceStandards, @HiveField(58)  DateTime? lastMaintenanceDate, @HiveField(59)  String? maintenanceNotes, @HiveField(60)  bool isActivated, @HiveField(61)  DateTime? activatedAt, @HiveField(62)  String? activatedBy, @HiveField(63)  String? activationLocation, @HiveField(64)  String codeFormat)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UnitCodeModel() when $default != null:
return $default(_that.id,_that.code,_that.type,_that.status,_that.factoryId,_that.subscriptionPlanId,_that.storeKeeperCode,_that.internationalCode,_that.batchId,_that.generatedAt,_that.linkedAt,_that.publishedAt,_that.deactivatedAt,_that.productId,_that.productBatchNumber,_that.manufacturingDate,_that.expiryDate,_that.warrantyMonths,_that.qrCodeData,_that.barcodeData,_that.metadata,_that.version,_that.createdAt,_that.updatedAt,_that.isDeleted,_that.packetCode,_that.sequenceNumber,_that.authenticationCode,_that.isMasterCode,_that.masterCodeId,_that.verificationCount,_that.firstVerifiedAt,_that.lastVerifiedAt,_that.verificationLocation,_that.verifiedBy,_that.isReportedFake,_that.fakeReportedAt,_that.fakeReportedBy,_that.fakeReportReason,_that.isBlocked,_that.blockedAt,_that.blockedBy,_that.blockReason,_that.serialNumber,_that.model,_that.color,_that.size,_that.weight,_that.dimensions,_that.condition,_that.grade,_that.hasWarrantyCard,_that.hasUserManual,_that.hasAccessories,_that.accessoriesList,_that.specialFeatures,_that.safetyCertifications,_that.complianceStandards,_that.lastMaintenanceDate,_that.maintenanceNotes,_that.isActivated,_that.activatedAt,_that.activatedBy,_that.activationLocation,_that.codeFormat);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@HiveField(0)  String id, @HiveField(1)  String code, @HiveField(2)  CodeType type, @HiveField(3)  CodeStatus status, @HiveField(4)  String factoryId, @HiveField(5)  String subscriptionPlanId, @HiveField(6)  String storeKeeperCode, @HiveField(7)  String? internationalCode, @HiveField(8)  String batchId, @HiveField(9)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime generatedAt, @HiveField(10)  DateTime? linkedAt, @HiveField(11)  DateTime? publishedAt, @HiveField(12)  DateTime? deactivatedAt, @HiveField(13)  String? productId, @HiveField(14)  String? productBatchNumber, @HiveField(15)  DateTime? manufacturingDate, @HiveField(16)  DateTime? expiryDate, @HiveField(17)  int? warrantyMonths, @HiveField(18)  String? qrCodeData, @HiveField(19)  String? barcodeData, @HiveField(20)  String? metadata, @HiveField(21)  int version, @HiveField(22)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime createdAt, @HiveField(23)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime updatedAt, @HiveField(24)  bool isDeleted, @HiveField(25)  String packetCode, @HiveField(26)  int sequenceNumber, @HiveField(27)  String authenticationCode, @HiveField(28)  bool isMasterCode, @HiveField(29)  String? masterCodeId, @HiveField(30)  int verificationCount, @HiveField(31)  DateTime? firstVerifiedAt, @HiveField(32)  DateTime? lastVerifiedAt, @HiveField(33)  String? verificationLocation, @HiveField(34)  String? verifiedBy, @HiveField(35)  bool isReportedFake, @HiveField(36)  DateTime? fakeReportedAt, @HiveField(37)  String? fakeReportedBy, @HiveField(38)  String? fakeReportReason, @HiveField(39)  bool isBlocked, @HiveField(40)  DateTime? blockedAt, @HiveField(41)  String? blockedBy, @HiveField(42)  String? blockReason, @HiveField(43)  String serialNumber, @HiveField(44)  String? model, @HiveField(45)  String? color, @HiveField(46)  String? size, @HiveField(47)  double? weight, @HiveField(48)  String? dimensions, @HiveField(49)  String condition, @HiveField(50)  String? grade, @HiveField(51)  bool hasWarrantyCard, @HiveField(52)  bool hasUserManual, @HiveField(53)  bool hasAccessories, @HiveField(54)  String? accessoriesList, @HiveField(55)  String? specialFeatures, @HiveField(56)  String? safetyCertifications, @HiveField(57)  String? complianceStandards, @HiveField(58)  DateTime? lastMaintenanceDate, @HiveField(59)  String? maintenanceNotes, @HiveField(60)  bool isActivated, @HiveField(61)  DateTime? activatedAt, @HiveField(62)  String? activatedBy, @HiveField(63)  String? activationLocation, @HiveField(64)  String codeFormat)  $default,) {final _that = this;
switch (_that) {
case _UnitCodeModel():
return $default(_that.id,_that.code,_that.type,_that.status,_that.factoryId,_that.subscriptionPlanId,_that.storeKeeperCode,_that.internationalCode,_that.batchId,_that.generatedAt,_that.linkedAt,_that.publishedAt,_that.deactivatedAt,_that.productId,_that.productBatchNumber,_that.manufacturingDate,_that.expiryDate,_that.warrantyMonths,_that.qrCodeData,_that.barcodeData,_that.metadata,_that.version,_that.createdAt,_that.updatedAt,_that.isDeleted,_that.packetCode,_that.sequenceNumber,_that.authenticationCode,_that.isMasterCode,_that.masterCodeId,_that.verificationCount,_that.firstVerifiedAt,_that.lastVerifiedAt,_that.verificationLocation,_that.verifiedBy,_that.isReportedFake,_that.fakeReportedAt,_that.fakeReportedBy,_that.fakeReportReason,_that.isBlocked,_that.blockedAt,_that.blockedBy,_that.blockReason,_that.serialNumber,_that.model,_that.color,_that.size,_that.weight,_that.dimensions,_that.condition,_that.grade,_that.hasWarrantyCard,_that.hasUserManual,_that.hasAccessories,_that.accessoriesList,_that.specialFeatures,_that.safetyCertifications,_that.complianceStandards,_that.lastMaintenanceDate,_that.maintenanceNotes,_that.isActivated,_that.activatedAt,_that.activatedBy,_that.activationLocation,_that.codeFormat);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@HiveField(0)  String id, @HiveField(1)  String code, @HiveField(2)  CodeType type, @HiveField(3)  CodeStatus status, @HiveField(4)  String factoryId, @HiveField(5)  String subscriptionPlanId, @HiveField(6)  String storeKeeperCode, @HiveField(7)  String? internationalCode, @HiveField(8)  String batchId, @HiveField(9)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime generatedAt, @HiveField(10)  DateTime? linkedAt, @HiveField(11)  DateTime? publishedAt, @HiveField(12)  DateTime? deactivatedAt, @HiveField(13)  String? productId, @HiveField(14)  String? productBatchNumber, @HiveField(15)  DateTime? manufacturingDate, @HiveField(16)  DateTime? expiryDate, @HiveField(17)  int? warrantyMonths, @HiveField(18)  String? qrCodeData, @HiveField(19)  String? barcodeData, @HiveField(20)  String? metadata, @HiveField(21)  int version, @HiveField(22)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime createdAt, @HiveField(23)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)  DateTime updatedAt, @HiveField(24)  bool isDeleted, @HiveField(25)  String packetCode, @HiveField(26)  int sequenceNumber, @HiveField(27)  String authenticationCode, @HiveField(28)  bool isMasterCode, @HiveField(29)  String? masterCodeId, @HiveField(30)  int verificationCount, @HiveField(31)  DateTime? firstVerifiedAt, @HiveField(32)  DateTime? lastVerifiedAt, @HiveField(33)  String? verificationLocation, @HiveField(34)  String? verifiedBy, @HiveField(35)  bool isReportedFake, @HiveField(36)  DateTime? fakeReportedAt, @HiveField(37)  String? fakeReportedBy, @HiveField(38)  String? fakeReportReason, @HiveField(39)  bool isBlocked, @HiveField(40)  DateTime? blockedAt, @HiveField(41)  String? blockedBy, @HiveField(42)  String? blockReason, @HiveField(43)  String serialNumber, @HiveField(44)  String? model, @HiveField(45)  String? color, @HiveField(46)  String? size, @HiveField(47)  double? weight, @HiveField(48)  String? dimensions, @HiveField(49)  String condition, @HiveField(50)  String? grade, @HiveField(51)  bool hasWarrantyCard, @HiveField(52)  bool hasUserManual, @HiveField(53)  bool hasAccessories, @HiveField(54)  String? accessoriesList, @HiveField(55)  String? specialFeatures, @HiveField(56)  String? safetyCertifications, @HiveField(57)  String? complianceStandards, @HiveField(58)  DateTime? lastMaintenanceDate, @HiveField(59)  String? maintenanceNotes, @HiveField(60)  bool isActivated, @HiveField(61)  DateTime? activatedAt, @HiveField(62)  String? activatedBy, @HiveField(63)  String? activationLocation, @HiveField(64)  String codeFormat)?  $default,) {final _that = this;
switch (_that) {
case _UnitCodeModel() when $default != null:
return $default(_that.id,_that.code,_that.type,_that.status,_that.factoryId,_that.subscriptionPlanId,_that.storeKeeperCode,_that.internationalCode,_that.batchId,_that.generatedAt,_that.linkedAt,_that.publishedAt,_that.deactivatedAt,_that.productId,_that.productBatchNumber,_that.manufacturingDate,_that.expiryDate,_that.warrantyMonths,_that.qrCodeData,_that.barcodeData,_that.metadata,_that.version,_that.createdAt,_that.updatedAt,_that.isDeleted,_that.packetCode,_that.sequenceNumber,_that.authenticationCode,_that.isMasterCode,_that.masterCodeId,_that.verificationCount,_that.firstVerifiedAt,_that.lastVerifiedAt,_that.verificationLocation,_that.verifiedBy,_that.isReportedFake,_that.fakeReportedAt,_that.fakeReportedBy,_that.fakeReportReason,_that.isBlocked,_that.blockedAt,_that.blockedBy,_that.blockReason,_that.serialNumber,_that.model,_that.color,_that.size,_that.weight,_that.dimensions,_that.condition,_that.grade,_that.hasWarrantyCard,_that.hasUserManual,_that.hasAccessories,_that.accessoriesList,_that.specialFeatures,_that.safetyCertifications,_that.complianceStandards,_that.lastMaintenanceDate,_that.maintenanceNotes,_that.isActivated,_that.activatedAt,_that.activatedBy,_that.activationLocation,_that.codeFormat);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UnitCodeModel extends UnitCodeModel {
  const _UnitCodeModel({@HiveField(0) required this.id, @HiveField(1) required this.code, @HiveField(2) this.type = CodeType.unit, @HiveField(3) this.status = CodeStatus.generated, @HiveField(4) this.factoryId = '', @HiveField(5) this.subscriptionPlanId = '', @HiveField(6) this.storeKeeperCode = '', @HiveField(7) this.internationalCode, @HiveField(8) this.batchId = '', @HiveField(9)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) required this.generatedAt, @HiveField(10) this.linkedAt, @HiveField(11) this.publishedAt, @HiveField(12) this.deactivatedAt, @HiveField(13) this.productId, @HiveField(14) this.productBatchNumber, @HiveField(15) this.manufacturingDate, @HiveField(16) this.expiryDate, @HiveField(17) this.warrantyMonths, @HiveField(18) this.qrCodeData, @HiveField(19) this.barcodeData, @HiveField(20) this.metadata, @HiveField(21) this.version = 1, @HiveField(22)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) required this.createdAt, @HiveField(23)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) required this.updatedAt, @HiveField(24) this.isDeleted = false, @HiveField(25) this.packetCode = '', @HiveField(26) this.sequenceNumber = 0, @HiveField(27) this.authenticationCode = '', @HiveField(28) this.isMasterCode = false, @HiveField(29) this.masterCodeId, @HiveField(30) this.verificationCount = 0, @HiveField(31) this.firstVerifiedAt, @HiveField(32) this.lastVerifiedAt, @HiveField(33) this.verificationLocation, @HiveField(34) this.verifiedBy, @HiveField(35) this.isReportedFake = false, @HiveField(36) this.fakeReportedAt, @HiveField(37) this.fakeReportedBy, @HiveField(38) this.fakeReportReason, @HiveField(39) this.isBlocked = false, @HiveField(40) this.blockedAt, @HiveField(41) this.blockedBy, @HiveField(42) this.blockReason, @HiveField(43) this.serialNumber = '', @HiveField(44) this.model, @HiveField(45) this.color, @HiveField(46) this.size, @HiveField(47) this.weight, @HiveField(48) this.dimensions, @HiveField(49) this.condition = 'New', @HiveField(50) this.grade, @HiveField(51) this.hasWarrantyCard = false, @HiveField(52) this.hasUserManual = false, @HiveField(53) this.hasAccessories = false, @HiveField(54) this.accessoriesList, @HiveField(55) this.specialFeatures, @HiveField(56) this.safetyCertifications, @HiveField(57) this.complianceStandards, @HiveField(58) this.lastMaintenanceDate, @HiveField(59) this.maintenanceNotes, @HiveField(60) this.isActivated = false, @HiveField(61) this.activatedAt, @HiveField(62) this.activatedBy, @HiveField(63) this.activationLocation, @HiveField(64) this.codeFormat = 'qr'}): super._();
  factory _UnitCodeModel.fromJson(Map<String, dynamic> json) => _$UnitCodeModelFromJson(json);

/// Base code properties
@override@HiveField(0) final  String id;
@override@HiveField(1) final  String code;
@override@JsonKey()@HiveField(2) final  CodeType type;
@override@JsonKey()@HiveField(3) final  CodeStatus status;
@override@JsonKey()@HiveField(4) final  String factoryId;
@override@JsonKey()@HiveField(5) final  String subscriptionPlanId;
@override@JsonKey()@HiveField(6) final  String storeKeeperCode;
@override@HiveField(7) final  String? internationalCode;
// Optional for unit codes
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
/// Unit-specific properties
/// Packet code that contains this unit
@override@JsonKey()@HiveField(25) final  String packetCode;
/// Unit sequence number within packet (e.g., 1, 2, 3...)
@override@JsonKey()@HiveField(26) final  int sequenceNumber;
/// Authentication code (system-generated for verification)
@override@JsonKey()@HiveField(27) final  String authenticationCode;
/// Is this a master authentication code?
@override@JsonKey()@HiveField(28) final  bool isMasterCode;
/// Master code ID (if this is a sub-code)
@override@HiveField(29) final  String? masterCodeId;
/// Verification count (how many times this code has been verified)
@override@JsonKey()@HiveField(30) final  int verificationCount;
/// First verification date
@override@HiveField(31) final  DateTime? firstVerifiedAt;
/// Last verification date
@override@HiveField(32) final  DateTime? lastVerifiedAt;
/// Verification location (GPS coordinates or address)
@override@HiveField(33) final  String? verificationLocation;
/// Verified by (user ID or device ID)
@override@HiveField(34) final  String? verifiedBy;
/// Is code reported as fake/counterfeit?
@override@JsonKey()@HiveField(35) final  bool isReportedFake;
/// Fake report date
@override@HiveField(36) final  DateTime? fakeReportedAt;
/// Fake reported by (user ID)
@override@HiveField(37) final  String? fakeReportedBy;
/// Fake report reason
@override@HiveField(38) final  String? fakeReportReason;
/// Is code blocked?
@override@JsonKey()@HiveField(39) final  bool isBlocked;
/// Blocked date
@override@HiveField(40) final  DateTime? blockedAt;
/// Blocked by (user ID)
@override@HiveField(41) final  String? blockedBy;
/// Block reason
@override@HiveField(42) final  String? blockReason;
/// Unit serial number (unique per unit)
@override@JsonKey()@HiveField(43) final  String serialNumber;
/// Unit model/variant
@override@HiveField(44) final  String? model;
/// Unit color
@override@HiveField(45) final  String? color;
/// Unit size
@override@HiveField(46) final  String? size;
/// Unit weight in grams
@override@HiveField(47) final  double? weight;
/// Unit dimensions (length x width x height in cm)
@override@HiveField(48) final  String? dimensions;
/// Unit condition (e.g., "New", "Used", "Refurbished")
@override@JsonKey()@HiveField(49) final  String condition;
/// Unit grade/quality
@override@HiveField(50) final  String? grade;
/// Has warranty card?
@override@JsonKey()@HiveField(51) final  bool hasWarrantyCard;
/// Has user manual?
@override@JsonKey()@HiveField(52) final  bool hasUserManual;
/// Has accessories?
@override@JsonKey()@HiveField(53) final  bool hasAccessories;
/// Accessories list (JSON string)
@override@HiveField(54) final  String? accessoriesList;
/// Special features (JSON string)
@override@HiveField(55) final  String? specialFeatures;
/// Safety certifications (JSON string)
@override@HiveField(56) final  String? safetyCertifications;
/// Compliance standards (JSON string)
@override@HiveField(57) final  String? complianceStandards;
/// Last maintenance date
@override@HiveField(58) final  DateTime? lastMaintenanceDate;
/// Maintenance notes
@override@HiveField(59) final  String? maintenanceNotes;
/// Is unit activated?
@override@JsonKey()@HiveField(60) final  bool isActivated;
/// Activation date
@override@HiveField(61) final  DateTime? activatedAt;
/// Activated by (user ID)
@override@HiveField(62) final  String? activatedBy;
/// Activation location
@override@HiveField(63) final  String? activationLocation;
/// Unit code format type (itf14, gs1_128, code128_industrial, qr, datamatrix, code128_label)
@override@JsonKey()@HiveField(64) final  String codeFormat;

/// Create a copy of UnitCodeModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnitCodeModelCopyWith<_UnitCodeModel> get copyWith => __$UnitCodeModelCopyWithImpl<_UnitCodeModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UnitCodeModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnitCodeModel&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.factoryId, factoryId) || other.factoryId == factoryId)&&(identical(other.subscriptionPlanId, subscriptionPlanId) || other.subscriptionPlanId == subscriptionPlanId)&&(identical(other.storeKeeperCode, storeKeeperCode) || other.storeKeeperCode == storeKeeperCode)&&(identical(other.internationalCode, internationalCode) || other.internationalCode == internationalCode)&&(identical(other.batchId, batchId) || other.batchId == batchId)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.linkedAt, linkedAt) || other.linkedAt == linkedAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.deactivatedAt, deactivatedAt) || other.deactivatedAt == deactivatedAt)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productBatchNumber, productBatchNumber) || other.productBatchNumber == productBatchNumber)&&(identical(other.manufacturingDate, manufacturingDate) || other.manufacturingDate == manufacturingDate)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.warrantyMonths, warrantyMonths) || other.warrantyMonths == warrantyMonths)&&(identical(other.qrCodeData, qrCodeData) || other.qrCodeData == qrCodeData)&&(identical(other.barcodeData, barcodeData) || other.barcodeData == barcodeData)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.version, version) || other.version == version)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.packetCode, packetCode) || other.packetCode == packetCode)&&(identical(other.sequenceNumber, sequenceNumber) || other.sequenceNumber == sequenceNumber)&&(identical(other.authenticationCode, authenticationCode) || other.authenticationCode == authenticationCode)&&(identical(other.isMasterCode, isMasterCode) || other.isMasterCode == isMasterCode)&&(identical(other.masterCodeId, masterCodeId) || other.masterCodeId == masterCodeId)&&(identical(other.verificationCount, verificationCount) || other.verificationCount == verificationCount)&&(identical(other.firstVerifiedAt, firstVerifiedAt) || other.firstVerifiedAt == firstVerifiedAt)&&(identical(other.lastVerifiedAt, lastVerifiedAt) || other.lastVerifiedAt == lastVerifiedAt)&&(identical(other.verificationLocation, verificationLocation) || other.verificationLocation == verificationLocation)&&(identical(other.verifiedBy, verifiedBy) || other.verifiedBy == verifiedBy)&&(identical(other.isReportedFake, isReportedFake) || other.isReportedFake == isReportedFake)&&(identical(other.fakeReportedAt, fakeReportedAt) || other.fakeReportedAt == fakeReportedAt)&&(identical(other.fakeReportedBy, fakeReportedBy) || other.fakeReportedBy == fakeReportedBy)&&(identical(other.fakeReportReason, fakeReportReason) || other.fakeReportReason == fakeReportReason)&&(identical(other.isBlocked, isBlocked) || other.isBlocked == isBlocked)&&(identical(other.blockedAt, blockedAt) || other.blockedAt == blockedAt)&&(identical(other.blockedBy, blockedBy) || other.blockedBy == blockedBy)&&(identical(other.blockReason, blockReason) || other.blockReason == blockReason)&&(identical(other.serialNumber, serialNumber) || other.serialNumber == serialNumber)&&(identical(other.model, model) || other.model == model)&&(identical(other.color, color) || other.color == color)&&(identical(other.size, size) || other.size == size)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.dimensions, dimensions) || other.dimensions == dimensions)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.hasWarrantyCard, hasWarrantyCard) || other.hasWarrantyCard == hasWarrantyCard)&&(identical(other.hasUserManual, hasUserManual) || other.hasUserManual == hasUserManual)&&(identical(other.hasAccessories, hasAccessories) || other.hasAccessories == hasAccessories)&&(identical(other.accessoriesList, accessoriesList) || other.accessoriesList == accessoriesList)&&(identical(other.specialFeatures, specialFeatures) || other.specialFeatures == specialFeatures)&&(identical(other.safetyCertifications, safetyCertifications) || other.safetyCertifications == safetyCertifications)&&(identical(other.complianceStandards, complianceStandards) || other.complianceStandards == complianceStandards)&&(identical(other.lastMaintenanceDate, lastMaintenanceDate) || other.lastMaintenanceDate == lastMaintenanceDate)&&(identical(other.maintenanceNotes, maintenanceNotes) || other.maintenanceNotes == maintenanceNotes)&&(identical(other.isActivated, isActivated) || other.isActivated == isActivated)&&(identical(other.activatedAt, activatedAt) || other.activatedAt == activatedAt)&&(identical(other.activatedBy, activatedBy) || other.activatedBy == activatedBy)&&(identical(other.activationLocation, activationLocation) || other.activationLocation == activationLocation)&&(identical(other.codeFormat, codeFormat) || other.codeFormat == codeFormat));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,code,type,status,factoryId,subscriptionPlanId,storeKeeperCode,internationalCode,batchId,generatedAt,linkedAt,publishedAt,deactivatedAt,productId,productBatchNumber,manufacturingDate,expiryDate,warrantyMonths,qrCodeData,barcodeData,metadata,version,createdAt,updatedAt,isDeleted,packetCode,sequenceNumber,authenticationCode,isMasterCode,masterCodeId,verificationCount,firstVerifiedAt,lastVerifiedAt,verificationLocation,verifiedBy,isReportedFake,fakeReportedAt,fakeReportedBy,fakeReportReason,isBlocked,blockedAt,blockedBy,blockReason,serialNumber,model,color,size,weight,dimensions,condition,grade,hasWarrantyCard,hasUserManual,hasAccessories,accessoriesList,specialFeatures,safetyCertifications,complianceStandards,lastMaintenanceDate,maintenanceNotes,isActivated,activatedAt,activatedBy,activationLocation,codeFormat]);

@override
String toString() {
  return 'UnitCodeModel(id: $id, code: $code, type: $type, status: $status, factoryId: $factoryId, subscriptionPlanId: $subscriptionPlanId, storeKeeperCode: $storeKeeperCode, internationalCode: $internationalCode, batchId: $batchId, generatedAt: $generatedAt, linkedAt: $linkedAt, publishedAt: $publishedAt, deactivatedAt: $deactivatedAt, productId: $productId, productBatchNumber: $productBatchNumber, manufacturingDate: $manufacturingDate, expiryDate: $expiryDate, warrantyMonths: $warrantyMonths, qrCodeData: $qrCodeData, barcodeData: $barcodeData, metadata: $metadata, version: $version, createdAt: $createdAt, updatedAt: $updatedAt, isDeleted: $isDeleted, packetCode: $packetCode, sequenceNumber: $sequenceNumber, authenticationCode: $authenticationCode, isMasterCode: $isMasterCode, masterCodeId: $masterCodeId, verificationCount: $verificationCount, firstVerifiedAt: $firstVerifiedAt, lastVerifiedAt: $lastVerifiedAt, verificationLocation: $verificationLocation, verifiedBy: $verifiedBy, isReportedFake: $isReportedFake, fakeReportedAt: $fakeReportedAt, fakeReportedBy: $fakeReportedBy, fakeReportReason: $fakeReportReason, isBlocked: $isBlocked, blockedAt: $blockedAt, blockedBy: $blockedBy, blockReason: $blockReason, serialNumber: $serialNumber, model: $model, color: $color, size: $size, weight: $weight, dimensions: $dimensions, condition: $condition, grade: $grade, hasWarrantyCard: $hasWarrantyCard, hasUserManual: $hasUserManual, hasAccessories: $hasAccessories, accessoriesList: $accessoriesList, specialFeatures: $specialFeatures, safetyCertifications: $safetyCertifications, complianceStandards: $complianceStandards, lastMaintenanceDate: $lastMaintenanceDate, maintenanceNotes: $maintenanceNotes, isActivated: $isActivated, activatedAt: $activatedAt, activatedBy: $activatedBy, activationLocation: $activationLocation, codeFormat: $codeFormat)';
}


}

/// @nodoc
abstract mixin class _$UnitCodeModelCopyWith<$Res> implements $UnitCodeModelCopyWith<$Res> {
  factory _$UnitCodeModelCopyWith(_UnitCodeModel value, $Res Function(_UnitCodeModel) _then) = __$UnitCodeModelCopyWithImpl;
@override @useResult
$Res call({
@HiveField(0) String id,@HiveField(1) String code,@HiveField(2) CodeType type,@HiveField(3) CodeStatus status,@HiveField(4) String factoryId,@HiveField(5) String subscriptionPlanId,@HiveField(6) String storeKeeperCode,@HiveField(7) String? internationalCode,@HiveField(8) String batchId,@HiveField(9)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime generatedAt,@HiveField(10) DateTime? linkedAt,@HiveField(11) DateTime? publishedAt,@HiveField(12) DateTime? deactivatedAt,@HiveField(13) String? productId,@HiveField(14) String? productBatchNumber,@HiveField(15) DateTime? manufacturingDate,@HiveField(16) DateTime? expiryDate,@HiveField(17) int? warrantyMonths,@HiveField(18) String? qrCodeData,@HiveField(19) String? barcodeData,@HiveField(20) String? metadata,@HiveField(21) int version,@HiveField(22)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime createdAt,@HiveField(23)@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime updatedAt,@HiveField(24) bool isDeleted,@HiveField(25) String packetCode,@HiveField(26) int sequenceNumber,@HiveField(27) String authenticationCode,@HiveField(28) bool isMasterCode,@HiveField(29) String? masterCodeId,@HiveField(30) int verificationCount,@HiveField(31) DateTime? firstVerifiedAt,@HiveField(32) DateTime? lastVerifiedAt,@HiveField(33) String? verificationLocation,@HiveField(34) String? verifiedBy,@HiveField(35) bool isReportedFake,@HiveField(36) DateTime? fakeReportedAt,@HiveField(37) String? fakeReportedBy,@HiveField(38) String? fakeReportReason,@HiveField(39) bool isBlocked,@HiveField(40) DateTime? blockedAt,@HiveField(41) String? blockedBy,@HiveField(42) String? blockReason,@HiveField(43) String serialNumber,@HiveField(44) String? model,@HiveField(45) String? color,@HiveField(46) String? size,@HiveField(47) double? weight,@HiveField(48) String? dimensions,@HiveField(49) String condition,@HiveField(50) String? grade,@HiveField(51) bool hasWarrantyCard,@HiveField(52) bool hasUserManual,@HiveField(53) bool hasAccessories,@HiveField(54) String? accessoriesList,@HiveField(55) String? specialFeatures,@HiveField(56) String? safetyCertifications,@HiveField(57) String? complianceStandards,@HiveField(58) DateTime? lastMaintenanceDate,@HiveField(59) String? maintenanceNotes,@HiveField(60) bool isActivated,@HiveField(61) DateTime? activatedAt,@HiveField(62) String? activatedBy,@HiveField(63) String? activationLocation,@HiveField(64) String codeFormat
});




}
/// @nodoc
class __$UnitCodeModelCopyWithImpl<$Res>
    implements _$UnitCodeModelCopyWith<$Res> {
  __$UnitCodeModelCopyWithImpl(this._self, this._then);

  final _UnitCodeModel _self;
  final $Res Function(_UnitCodeModel) _then;

/// Create a copy of UnitCodeModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? type = null,Object? status = null,Object? factoryId = null,Object? subscriptionPlanId = null,Object? storeKeeperCode = null,Object? internationalCode = freezed,Object? batchId = null,Object? generatedAt = null,Object? linkedAt = freezed,Object? publishedAt = freezed,Object? deactivatedAt = freezed,Object? productId = freezed,Object? productBatchNumber = freezed,Object? manufacturingDate = freezed,Object? expiryDate = freezed,Object? warrantyMonths = freezed,Object? qrCodeData = freezed,Object? barcodeData = freezed,Object? metadata = freezed,Object? version = null,Object? createdAt = null,Object? updatedAt = null,Object? isDeleted = null,Object? packetCode = null,Object? sequenceNumber = null,Object? authenticationCode = null,Object? isMasterCode = null,Object? masterCodeId = freezed,Object? verificationCount = null,Object? firstVerifiedAt = freezed,Object? lastVerifiedAt = freezed,Object? verificationLocation = freezed,Object? verifiedBy = freezed,Object? isReportedFake = null,Object? fakeReportedAt = freezed,Object? fakeReportedBy = freezed,Object? fakeReportReason = freezed,Object? isBlocked = null,Object? blockedAt = freezed,Object? blockedBy = freezed,Object? blockReason = freezed,Object? serialNumber = null,Object? model = freezed,Object? color = freezed,Object? size = freezed,Object? weight = freezed,Object? dimensions = freezed,Object? condition = null,Object? grade = freezed,Object? hasWarrantyCard = null,Object? hasUserManual = null,Object? hasAccessories = null,Object? accessoriesList = freezed,Object? specialFeatures = freezed,Object? safetyCertifications = freezed,Object? complianceStandards = freezed,Object? lastMaintenanceDate = freezed,Object? maintenanceNotes = freezed,Object? isActivated = null,Object? activatedAt = freezed,Object? activatedBy = freezed,Object? activationLocation = freezed,Object? codeFormat = null,}) {
  return _then(_UnitCodeModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CodeType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CodeStatus,factoryId: null == factoryId ? _self.factoryId : factoryId // ignore: cast_nullable_to_non_nullable
as String,subscriptionPlanId: null == subscriptionPlanId ? _self.subscriptionPlanId : subscriptionPlanId // ignore: cast_nullable_to_non_nullable
as String,storeKeeperCode: null == storeKeeperCode ? _self.storeKeeperCode : storeKeeperCode // ignore: cast_nullable_to_non_nullable
as String,internationalCode: freezed == internationalCode ? _self.internationalCode : internationalCode // ignore: cast_nullable_to_non_nullable
as String?,batchId: null == batchId ? _self.batchId : batchId // ignore: cast_nullable_to_non_nullable
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
as bool,packetCode: null == packetCode ? _self.packetCode : packetCode // ignore: cast_nullable_to_non_nullable
as String,sequenceNumber: null == sequenceNumber ? _self.sequenceNumber : sequenceNumber // ignore: cast_nullable_to_non_nullable
as int,authenticationCode: null == authenticationCode ? _self.authenticationCode : authenticationCode // ignore: cast_nullable_to_non_nullable
as String,isMasterCode: null == isMasterCode ? _self.isMasterCode : isMasterCode // ignore: cast_nullable_to_non_nullable
as bool,masterCodeId: freezed == masterCodeId ? _self.masterCodeId : masterCodeId // ignore: cast_nullable_to_non_nullable
as String?,verificationCount: null == verificationCount ? _self.verificationCount : verificationCount // ignore: cast_nullable_to_non_nullable
as int,firstVerifiedAt: freezed == firstVerifiedAt ? _self.firstVerifiedAt : firstVerifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastVerifiedAt: freezed == lastVerifiedAt ? _self.lastVerifiedAt : lastVerifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,verificationLocation: freezed == verificationLocation ? _self.verificationLocation : verificationLocation // ignore: cast_nullable_to_non_nullable
as String?,verifiedBy: freezed == verifiedBy ? _self.verifiedBy : verifiedBy // ignore: cast_nullable_to_non_nullable
as String?,isReportedFake: null == isReportedFake ? _self.isReportedFake : isReportedFake // ignore: cast_nullable_to_non_nullable
as bool,fakeReportedAt: freezed == fakeReportedAt ? _self.fakeReportedAt : fakeReportedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,fakeReportedBy: freezed == fakeReportedBy ? _self.fakeReportedBy : fakeReportedBy // ignore: cast_nullable_to_non_nullable
as String?,fakeReportReason: freezed == fakeReportReason ? _self.fakeReportReason : fakeReportReason // ignore: cast_nullable_to_non_nullable
as String?,isBlocked: null == isBlocked ? _self.isBlocked : isBlocked // ignore: cast_nullable_to_non_nullable
as bool,blockedAt: freezed == blockedAt ? _self.blockedAt : blockedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,blockedBy: freezed == blockedBy ? _self.blockedBy : blockedBy // ignore: cast_nullable_to_non_nullable
as String?,blockReason: freezed == blockReason ? _self.blockReason : blockReason // ignore: cast_nullable_to_non_nullable
as String?,serialNumber: null == serialNumber ? _self.serialNumber : serialNumber // ignore: cast_nullable_to_non_nullable
as String,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String?,weight: freezed == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double?,dimensions: freezed == dimensions ? _self.dimensions : dimensions // ignore: cast_nullable_to_non_nullable
as String?,condition: null == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as String,grade: freezed == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as String?,hasWarrantyCard: null == hasWarrantyCard ? _self.hasWarrantyCard : hasWarrantyCard // ignore: cast_nullable_to_non_nullable
as bool,hasUserManual: null == hasUserManual ? _self.hasUserManual : hasUserManual // ignore: cast_nullable_to_non_nullable
as bool,hasAccessories: null == hasAccessories ? _self.hasAccessories : hasAccessories // ignore: cast_nullable_to_non_nullable
as bool,accessoriesList: freezed == accessoriesList ? _self.accessoriesList : accessoriesList // ignore: cast_nullable_to_non_nullable
as String?,specialFeatures: freezed == specialFeatures ? _self.specialFeatures : specialFeatures // ignore: cast_nullable_to_non_nullable
as String?,safetyCertifications: freezed == safetyCertifications ? _self.safetyCertifications : safetyCertifications // ignore: cast_nullable_to_non_nullable
as String?,complianceStandards: freezed == complianceStandards ? _self.complianceStandards : complianceStandards // ignore: cast_nullable_to_non_nullable
as String?,lastMaintenanceDate: freezed == lastMaintenanceDate ? _self.lastMaintenanceDate : lastMaintenanceDate // ignore: cast_nullable_to_non_nullable
as DateTime?,maintenanceNotes: freezed == maintenanceNotes ? _self.maintenanceNotes : maintenanceNotes // ignore: cast_nullable_to_non_nullable
as String?,isActivated: null == isActivated ? _self.isActivated : isActivated // ignore: cast_nullable_to_non_nullable
as bool,activatedAt: freezed == activatedAt ? _self.activatedAt : activatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,activatedBy: freezed == activatedBy ? _self.activatedBy : activatedBy // ignore: cast_nullable_to_non_nullable
as String?,activationLocation: freezed == activationLocation ? _self.activationLocation : activationLocation // ignore: cast_nullable_to_non_nullable
as String?,codeFormat: null == codeFormat ? _self.codeFormat : codeFormat // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

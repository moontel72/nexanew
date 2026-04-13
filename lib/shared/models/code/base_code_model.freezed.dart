// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'base_code_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BaseCodeModel {

/// Unique identifier for the code
@HiveField(0) String get id;/// The actual code value (e.g., "A-01", "YY-001", "YBZ-0001", "TSFG-00001")
@HiveField(1) String get code;/// Code type (bundle, carton, packet, unit)
@HiveField(2) CodeType get type;/// Current status of the code
@HiveField(3) CodeStatus get status;/// Factory ID that owns this code
@HiveField(4) String get factoryId;/// Subscription plan ID under which this code was generated
@HiveField(5) String get subscriptionPlanId;/// Store keeper code (internal tracking code)
@HiveField(6) String get storeKeeperCode;/// International standard code (GS1, etc.) - optional for unit codes
@HiveField(7) String? get internationalCode;/// Batch ID - all codes generated together in one batch have same batchId
@HiveField(8) String get batchId;/// Date and time when the code was generated
@HiveField(9) DateTime get generatedAt;/// Date and time when the code was linked to a product
@HiveField(10) DateTime? get linkedAt;/// Date and time when the code was published
@HiveField(11) DateTime? get publishedAt;/// Date and time when the code was deactivated
@HiveField(12) DateTime? get deactivatedAt;/// Product ID this code is linked to (null if not linked)
@HiveField(13) String? get productId;/// Product batch number (if applicable)
@HiveField(14) String? get productBatchNumber;/// Manufacturing date (for food/medical products)
@HiveField(15) DateTime? get manufacturingDate;/// Expiry date (for food/medical products)
@HiveField(16) DateTime? get expiryDate;/// Warranty period in months (for other products)
@HiveField(17) int? get warrantyMonths;/// QR code data (encoded string)
@HiveField(18) String? get qrCodeData;/// Barcode data (encoded string)
@HiveField(19) String? get barcodeData;/// Metadata for additional information (JSON string)
@HiveField(20) String? get metadata;/// Version for optimistic concurrency control
@HiveField(21) int get version;/// Created timestamp
@HiveField(22) DateTime get createdAt;/// Updated timestamp
@HiveField(23) DateTime get updatedAt;/// Soft delete flag
@HiveField(24) bool get isDeleted;
/// Create a copy of BaseCodeModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BaseCodeModelCopyWith<BaseCodeModel> get copyWith => _$BaseCodeModelCopyWithImpl<BaseCodeModel>(this as BaseCodeModel, _$identity);

  /// Serializes this BaseCodeModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BaseCodeModel&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.factoryId, factoryId) || other.factoryId == factoryId)&&(identical(other.subscriptionPlanId, subscriptionPlanId) || other.subscriptionPlanId == subscriptionPlanId)&&(identical(other.storeKeeperCode, storeKeeperCode) || other.storeKeeperCode == storeKeeperCode)&&(identical(other.internationalCode, internationalCode) || other.internationalCode == internationalCode)&&(identical(other.batchId, batchId) || other.batchId == batchId)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.linkedAt, linkedAt) || other.linkedAt == linkedAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.deactivatedAt, deactivatedAt) || other.deactivatedAt == deactivatedAt)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productBatchNumber, productBatchNumber) || other.productBatchNumber == productBatchNumber)&&(identical(other.manufacturingDate, manufacturingDate) || other.manufacturingDate == manufacturingDate)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.warrantyMonths, warrantyMonths) || other.warrantyMonths == warrantyMonths)&&(identical(other.qrCodeData, qrCodeData) || other.qrCodeData == qrCodeData)&&(identical(other.barcodeData, barcodeData) || other.barcodeData == barcodeData)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.version, version) || other.version == version)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,code,type,status,factoryId,subscriptionPlanId,storeKeeperCode,internationalCode,batchId,generatedAt,linkedAt,publishedAt,deactivatedAt,productId,productBatchNumber,manufacturingDate,expiryDate,warrantyMonths,qrCodeData,barcodeData,metadata,version,createdAt,updatedAt,isDeleted]);

@override
String toString() {
  return 'BaseCodeModel(id: $id, code: $code, type: $type, status: $status, factoryId: $factoryId, subscriptionPlanId: $subscriptionPlanId, storeKeeperCode: $storeKeeperCode, internationalCode: $internationalCode, batchId: $batchId, generatedAt: $generatedAt, linkedAt: $linkedAt, publishedAt: $publishedAt, deactivatedAt: $deactivatedAt, productId: $productId, productBatchNumber: $productBatchNumber, manufacturingDate: $manufacturingDate, expiryDate: $expiryDate, warrantyMonths: $warrantyMonths, qrCodeData: $qrCodeData, barcodeData: $barcodeData, metadata: $metadata, version: $version, createdAt: $createdAt, updatedAt: $updatedAt, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class $BaseCodeModelCopyWith<$Res>  {
  factory $BaseCodeModelCopyWith(BaseCodeModel value, $Res Function(BaseCodeModel) _then) = _$BaseCodeModelCopyWithImpl;
@useResult
$Res call({
@HiveField(0) String id,@HiveField(1) String code,@HiveField(2) CodeType type,@HiveField(3) CodeStatus status,@HiveField(4) String factoryId,@HiveField(5) String subscriptionPlanId,@HiveField(6) String storeKeeperCode,@HiveField(7) String? internationalCode,@HiveField(8) String batchId,@HiveField(9) DateTime generatedAt,@HiveField(10) DateTime? linkedAt,@HiveField(11) DateTime? publishedAt,@HiveField(12) DateTime? deactivatedAt,@HiveField(13) String? productId,@HiveField(14) String? productBatchNumber,@HiveField(15) DateTime? manufacturingDate,@HiveField(16) DateTime? expiryDate,@HiveField(17) int? warrantyMonths,@HiveField(18) String? qrCodeData,@HiveField(19) String? barcodeData,@HiveField(20) String? metadata,@HiveField(21) int version,@HiveField(22) DateTime createdAt,@HiveField(23) DateTime updatedAt,@HiveField(24) bool isDeleted
});




}
/// @nodoc
class _$BaseCodeModelCopyWithImpl<$Res>
    implements $BaseCodeModelCopyWith<$Res> {
  _$BaseCodeModelCopyWithImpl(this._self, this._then);

  final BaseCodeModel _self;
  final $Res Function(BaseCodeModel) _then;

/// Create a copy of BaseCodeModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? type = null,Object? status = null,Object? factoryId = null,Object? subscriptionPlanId = null,Object? storeKeeperCode = null,Object? internationalCode = freezed,Object? batchId = null,Object? generatedAt = null,Object? linkedAt = freezed,Object? publishedAt = freezed,Object? deactivatedAt = freezed,Object? productId = freezed,Object? productBatchNumber = freezed,Object? manufacturingDate = freezed,Object? expiryDate = freezed,Object? warrantyMonths = freezed,Object? qrCodeData = freezed,Object? barcodeData = freezed,Object? metadata = freezed,Object? version = null,Object? createdAt = null,Object? updatedAt = null,Object? isDeleted = null,}) {
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
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [BaseCodeModel].
extension BaseCodeModelPatterns on BaseCodeModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BaseCodeModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BaseCodeModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BaseCodeModel value)  $default,){
final _that = this;
switch (_that) {
case _BaseCodeModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BaseCodeModel value)?  $default,){
final _that = this;
switch (_that) {
case _BaseCodeModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@HiveField(0)  String id, @HiveField(1)  String code, @HiveField(2)  CodeType type, @HiveField(3)  CodeStatus status, @HiveField(4)  String factoryId, @HiveField(5)  String subscriptionPlanId, @HiveField(6)  String storeKeeperCode, @HiveField(7)  String? internationalCode, @HiveField(8)  String batchId, @HiveField(9)  DateTime generatedAt, @HiveField(10)  DateTime? linkedAt, @HiveField(11)  DateTime? publishedAt, @HiveField(12)  DateTime? deactivatedAt, @HiveField(13)  String? productId, @HiveField(14)  String? productBatchNumber, @HiveField(15)  DateTime? manufacturingDate, @HiveField(16)  DateTime? expiryDate, @HiveField(17)  int? warrantyMonths, @HiveField(18)  String? qrCodeData, @HiveField(19)  String? barcodeData, @HiveField(20)  String? metadata, @HiveField(21)  int version, @HiveField(22)  DateTime createdAt, @HiveField(23)  DateTime updatedAt, @HiveField(24)  bool isDeleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BaseCodeModel() when $default != null:
return $default(_that.id,_that.code,_that.type,_that.status,_that.factoryId,_that.subscriptionPlanId,_that.storeKeeperCode,_that.internationalCode,_that.batchId,_that.generatedAt,_that.linkedAt,_that.publishedAt,_that.deactivatedAt,_that.productId,_that.productBatchNumber,_that.manufacturingDate,_that.expiryDate,_that.warrantyMonths,_that.qrCodeData,_that.barcodeData,_that.metadata,_that.version,_that.createdAt,_that.updatedAt,_that.isDeleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@HiveField(0)  String id, @HiveField(1)  String code, @HiveField(2)  CodeType type, @HiveField(3)  CodeStatus status, @HiveField(4)  String factoryId, @HiveField(5)  String subscriptionPlanId, @HiveField(6)  String storeKeeperCode, @HiveField(7)  String? internationalCode, @HiveField(8)  String batchId, @HiveField(9)  DateTime generatedAt, @HiveField(10)  DateTime? linkedAt, @HiveField(11)  DateTime? publishedAt, @HiveField(12)  DateTime? deactivatedAt, @HiveField(13)  String? productId, @HiveField(14)  String? productBatchNumber, @HiveField(15)  DateTime? manufacturingDate, @HiveField(16)  DateTime? expiryDate, @HiveField(17)  int? warrantyMonths, @HiveField(18)  String? qrCodeData, @HiveField(19)  String? barcodeData, @HiveField(20)  String? metadata, @HiveField(21)  int version, @HiveField(22)  DateTime createdAt, @HiveField(23)  DateTime updatedAt, @HiveField(24)  bool isDeleted)  $default,) {final _that = this;
switch (_that) {
case _BaseCodeModel():
return $default(_that.id,_that.code,_that.type,_that.status,_that.factoryId,_that.subscriptionPlanId,_that.storeKeeperCode,_that.internationalCode,_that.batchId,_that.generatedAt,_that.linkedAt,_that.publishedAt,_that.deactivatedAt,_that.productId,_that.productBatchNumber,_that.manufacturingDate,_that.expiryDate,_that.warrantyMonths,_that.qrCodeData,_that.barcodeData,_that.metadata,_that.version,_that.createdAt,_that.updatedAt,_that.isDeleted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@HiveField(0)  String id, @HiveField(1)  String code, @HiveField(2)  CodeType type, @HiveField(3)  CodeStatus status, @HiveField(4)  String factoryId, @HiveField(5)  String subscriptionPlanId, @HiveField(6)  String storeKeeperCode, @HiveField(7)  String? internationalCode, @HiveField(8)  String batchId, @HiveField(9)  DateTime generatedAt, @HiveField(10)  DateTime? linkedAt, @HiveField(11)  DateTime? publishedAt, @HiveField(12)  DateTime? deactivatedAt, @HiveField(13)  String? productId, @HiveField(14)  String? productBatchNumber, @HiveField(15)  DateTime? manufacturingDate, @HiveField(16)  DateTime? expiryDate, @HiveField(17)  int? warrantyMonths, @HiveField(18)  String? qrCodeData, @HiveField(19)  String? barcodeData, @HiveField(20)  String? metadata, @HiveField(21)  int version, @HiveField(22)  DateTime createdAt, @HiveField(23)  DateTime updatedAt, @HiveField(24)  bool isDeleted)?  $default,) {final _that = this;
switch (_that) {
case _BaseCodeModel() when $default != null:
return $default(_that.id,_that.code,_that.type,_that.status,_that.factoryId,_that.subscriptionPlanId,_that.storeKeeperCode,_that.internationalCode,_that.batchId,_that.generatedAt,_that.linkedAt,_that.publishedAt,_that.deactivatedAt,_that.productId,_that.productBatchNumber,_that.manufacturingDate,_that.expiryDate,_that.warrantyMonths,_that.qrCodeData,_that.barcodeData,_that.metadata,_that.version,_that.createdAt,_that.updatedAt,_that.isDeleted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BaseCodeModel extends BaseCodeModel {
  const _BaseCodeModel({@HiveField(0) required this.id, @HiveField(1) required this.code, @HiveField(2) required this.type, @HiveField(3) this.status = CodeStatus.generated, @HiveField(4) required this.factoryId, @HiveField(5) required this.subscriptionPlanId, @HiveField(6) required this.storeKeeperCode, @HiveField(7) this.internationalCode, @HiveField(8) required this.batchId, @HiveField(9) required this.generatedAt, @HiveField(10) this.linkedAt, @HiveField(11) this.publishedAt, @HiveField(12) this.deactivatedAt, @HiveField(13) this.productId, @HiveField(14) this.productBatchNumber, @HiveField(15) this.manufacturingDate, @HiveField(16) this.expiryDate, @HiveField(17) this.warrantyMonths, @HiveField(18) this.qrCodeData, @HiveField(19) this.barcodeData, @HiveField(20) this.metadata, @HiveField(21) this.version = 1, @HiveField(22) required this.createdAt, @HiveField(23) required this.updatedAt, @HiveField(24) this.isDeleted = false}): super._();
  factory _BaseCodeModel.fromJson(Map<String, dynamic> json) => _$BaseCodeModelFromJson(json);

/// Unique identifier for the code
@override@HiveField(0) final  String id;
/// The actual code value (e.g., "A-01", "YY-001", "YBZ-0001", "TSFG-00001")
@override@HiveField(1) final  String code;
/// Code type (bundle, carton, packet, unit)
@override@HiveField(2) final  CodeType type;
/// Current status of the code
@override@JsonKey()@HiveField(3) final  CodeStatus status;
/// Factory ID that owns this code
@override@HiveField(4) final  String factoryId;
/// Subscription plan ID under which this code was generated
@override@HiveField(5) final  String subscriptionPlanId;
/// Store keeper code (internal tracking code)
@override@HiveField(6) final  String storeKeeperCode;
/// International standard code (GS1, etc.) - optional for unit codes
@override@HiveField(7) final  String? internationalCode;
/// Batch ID - all codes generated together in one batch have same batchId
@override@HiveField(8) final  String batchId;
/// Date and time when the code was generated
@override@HiveField(9) final  DateTime generatedAt;
/// Date and time when the code was linked to a product
@override@HiveField(10) final  DateTime? linkedAt;
/// Date and time when the code was published
@override@HiveField(11) final  DateTime? publishedAt;
/// Date and time when the code was deactivated
@override@HiveField(12) final  DateTime? deactivatedAt;
/// Product ID this code is linked to (null if not linked)
@override@HiveField(13) final  String? productId;
/// Product batch number (if applicable)
@override@HiveField(14) final  String? productBatchNumber;
/// Manufacturing date (for food/medical products)
@override@HiveField(15) final  DateTime? manufacturingDate;
/// Expiry date (for food/medical products)
@override@HiveField(16) final  DateTime? expiryDate;
/// Warranty period in months (for other products)
@override@HiveField(17) final  int? warrantyMonths;
/// QR code data (encoded string)
@override@HiveField(18) final  String? qrCodeData;
/// Barcode data (encoded string)
@override@HiveField(19) final  String? barcodeData;
/// Metadata for additional information (JSON string)
@override@HiveField(20) final  String? metadata;
/// Version for optimistic concurrency control
@override@JsonKey()@HiveField(21) final  int version;
/// Created timestamp
@override@HiveField(22) final  DateTime createdAt;
/// Updated timestamp
@override@HiveField(23) final  DateTime updatedAt;
/// Soft delete flag
@override@JsonKey()@HiveField(24) final  bool isDeleted;

/// Create a copy of BaseCodeModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BaseCodeModelCopyWith<_BaseCodeModel> get copyWith => __$BaseCodeModelCopyWithImpl<_BaseCodeModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BaseCodeModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BaseCodeModel&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.factoryId, factoryId) || other.factoryId == factoryId)&&(identical(other.subscriptionPlanId, subscriptionPlanId) || other.subscriptionPlanId == subscriptionPlanId)&&(identical(other.storeKeeperCode, storeKeeperCode) || other.storeKeeperCode == storeKeeperCode)&&(identical(other.internationalCode, internationalCode) || other.internationalCode == internationalCode)&&(identical(other.batchId, batchId) || other.batchId == batchId)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.linkedAt, linkedAt) || other.linkedAt == linkedAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.deactivatedAt, deactivatedAt) || other.deactivatedAt == deactivatedAt)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productBatchNumber, productBatchNumber) || other.productBatchNumber == productBatchNumber)&&(identical(other.manufacturingDate, manufacturingDate) || other.manufacturingDate == manufacturingDate)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.warrantyMonths, warrantyMonths) || other.warrantyMonths == warrantyMonths)&&(identical(other.qrCodeData, qrCodeData) || other.qrCodeData == qrCodeData)&&(identical(other.barcodeData, barcodeData) || other.barcodeData == barcodeData)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.version, version) || other.version == version)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,code,type,status,factoryId,subscriptionPlanId,storeKeeperCode,internationalCode,batchId,generatedAt,linkedAt,publishedAt,deactivatedAt,productId,productBatchNumber,manufacturingDate,expiryDate,warrantyMonths,qrCodeData,barcodeData,metadata,version,createdAt,updatedAt,isDeleted]);

@override
String toString() {
  return 'BaseCodeModel(id: $id, code: $code, type: $type, status: $status, factoryId: $factoryId, subscriptionPlanId: $subscriptionPlanId, storeKeeperCode: $storeKeeperCode, internationalCode: $internationalCode, batchId: $batchId, generatedAt: $generatedAt, linkedAt: $linkedAt, publishedAt: $publishedAt, deactivatedAt: $deactivatedAt, productId: $productId, productBatchNumber: $productBatchNumber, manufacturingDate: $manufacturingDate, expiryDate: $expiryDate, warrantyMonths: $warrantyMonths, qrCodeData: $qrCodeData, barcodeData: $barcodeData, metadata: $metadata, version: $version, createdAt: $createdAt, updatedAt: $updatedAt, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class _$BaseCodeModelCopyWith<$Res> implements $BaseCodeModelCopyWith<$Res> {
  factory _$BaseCodeModelCopyWith(_BaseCodeModel value, $Res Function(_BaseCodeModel) _then) = __$BaseCodeModelCopyWithImpl;
@override @useResult
$Res call({
@HiveField(0) String id,@HiveField(1) String code,@HiveField(2) CodeType type,@HiveField(3) CodeStatus status,@HiveField(4) String factoryId,@HiveField(5) String subscriptionPlanId,@HiveField(6) String storeKeeperCode,@HiveField(7) String? internationalCode,@HiveField(8) String batchId,@HiveField(9) DateTime generatedAt,@HiveField(10) DateTime? linkedAt,@HiveField(11) DateTime? publishedAt,@HiveField(12) DateTime? deactivatedAt,@HiveField(13) String? productId,@HiveField(14) String? productBatchNumber,@HiveField(15) DateTime? manufacturingDate,@HiveField(16) DateTime? expiryDate,@HiveField(17) int? warrantyMonths,@HiveField(18) String? qrCodeData,@HiveField(19) String? barcodeData,@HiveField(20) String? metadata,@HiveField(21) int version,@HiveField(22) DateTime createdAt,@HiveField(23) DateTime updatedAt,@HiveField(24) bool isDeleted
});




}
/// @nodoc
class __$BaseCodeModelCopyWithImpl<$Res>
    implements _$BaseCodeModelCopyWith<$Res> {
  __$BaseCodeModelCopyWithImpl(this._self, this._then);

  final _BaseCodeModel _self;
  final $Res Function(_BaseCodeModel) _then;

/// Create a copy of BaseCodeModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? type = null,Object? status = null,Object? factoryId = null,Object? subscriptionPlanId = null,Object? storeKeeperCode = null,Object? internationalCode = freezed,Object? batchId = null,Object? generatedAt = null,Object? linkedAt = freezed,Object? publishedAt = freezed,Object? deactivatedAt = freezed,Object? productId = freezed,Object? productBatchNumber = freezed,Object? manufacturingDate = freezed,Object? expiryDate = freezed,Object? warrantyMonths = freezed,Object? qrCodeData = freezed,Object? barcodeData = freezed,Object? metadata = freezed,Object? version = null,Object? createdAt = null,Object? updatedAt = null,Object? isDeleted = null,}) {
  return _then(_BaseCodeModel(
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
as bool,
  ));
}


}

// dart format on

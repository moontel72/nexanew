// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'carton_codes_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CartonCodesEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CartonCodesEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CartonCodesEvent()';
}


}

/// @nodoc
class $CartonCodesEventCopyWith<$Res>  {
$CartonCodesEventCopyWith(CartonCodesEvent _, $Res Function(CartonCodesEvent) __);
}


/// Adds pattern-matching-related methods to [CartonCodesEvent].
extension CartonCodesEventPatterns on CartonCodesEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LoadCartonCodes value)?  load,TResult Function( GenerateCartonCodes value)?  generate,TResult Function( DeleteCartonCode value)?  delete,TResult Function( DeleteCartonCodeBatch value)?  deleteBatch,TResult Function( LinkCartonCodeToProduct value)?  linkToProduct,TResult Function( PublishCartonCode value)?  publish,TResult Function( PushCartonBatch value)?  pushBatch,TResult Function( DeleteCartonBatchByGroup value)?  deleteBatchByGroup,TResult Function( ExportCartonBatch value)?  exportBatch,TResult Function( DeactivateCartonCode value)?  deactivate,TResult Function( SearchCartonCodes value)?  search,TResult Function( FilterCartonCodes value)?  filter,TResult Function( FilterCartonCodesByFormat value)?  filterByFormat,TResult Function( ExportCartonCodes value)?  export,TResult Function( SelectCartonCode value)?  select,TResult Function( ClearSelection value)?  clearSelection,TResult Function( RefreshCartonCodes value)?  refresh,TResult Function( SealCarton value)?  seal,TResult Function( UpdateCartonInspection value)?  updateInspection,TResult Function( UpdateCartonProperties value)?  updateProperties,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LoadCartonCodes() when load != null:
return load(_that);case GenerateCartonCodes() when generate != null:
return generate(_that);case DeleteCartonCode() when delete != null:
return delete(_that);case DeleteCartonCodeBatch() when deleteBatch != null:
return deleteBatch(_that);case LinkCartonCodeToProduct() when linkToProduct != null:
return linkToProduct(_that);case PublishCartonCode() when publish != null:
return publish(_that);case PushCartonBatch() when pushBatch != null:
return pushBatch(_that);case DeleteCartonBatchByGroup() when deleteBatchByGroup != null:
return deleteBatchByGroup(_that);case ExportCartonBatch() when exportBatch != null:
return exportBatch(_that);case DeactivateCartonCode() when deactivate != null:
return deactivate(_that);case SearchCartonCodes() when search != null:
return search(_that);case FilterCartonCodes() when filter != null:
return filter(_that);case FilterCartonCodesByFormat() when filterByFormat != null:
return filterByFormat(_that);case ExportCartonCodes() when export != null:
return export(_that);case SelectCartonCode() when select != null:
return select(_that);case ClearSelection() when clearSelection != null:
return clearSelection(_that);case RefreshCartonCodes() when refresh != null:
return refresh(_that);case SealCarton() when seal != null:
return seal(_that);case UpdateCartonInspection() when updateInspection != null:
return updateInspection(_that);case UpdateCartonProperties() when updateProperties != null:
return updateProperties(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LoadCartonCodes value)  load,required TResult Function( GenerateCartonCodes value)  generate,required TResult Function( DeleteCartonCode value)  delete,required TResult Function( DeleteCartonCodeBatch value)  deleteBatch,required TResult Function( LinkCartonCodeToProduct value)  linkToProduct,required TResult Function( PublishCartonCode value)  publish,required TResult Function( PushCartonBatch value)  pushBatch,required TResult Function( DeleteCartonBatchByGroup value)  deleteBatchByGroup,required TResult Function( ExportCartonBatch value)  exportBatch,required TResult Function( DeactivateCartonCode value)  deactivate,required TResult Function( SearchCartonCodes value)  search,required TResult Function( FilterCartonCodes value)  filter,required TResult Function( FilterCartonCodesByFormat value)  filterByFormat,required TResult Function( ExportCartonCodes value)  export,required TResult Function( SelectCartonCode value)  select,required TResult Function( ClearSelection value)  clearSelection,required TResult Function( RefreshCartonCodes value)  refresh,required TResult Function( SealCarton value)  seal,required TResult Function( UpdateCartonInspection value)  updateInspection,required TResult Function( UpdateCartonProperties value)  updateProperties,}){
final _that = this;
switch (_that) {
case LoadCartonCodes():
return load(_that);case GenerateCartonCodes():
return generate(_that);case DeleteCartonCode():
return delete(_that);case DeleteCartonCodeBatch():
return deleteBatch(_that);case LinkCartonCodeToProduct():
return linkToProduct(_that);case PublishCartonCode():
return publish(_that);case PushCartonBatch():
return pushBatch(_that);case DeleteCartonBatchByGroup():
return deleteBatchByGroup(_that);case ExportCartonBatch():
return exportBatch(_that);case DeactivateCartonCode():
return deactivate(_that);case SearchCartonCodes():
return search(_that);case FilterCartonCodes():
return filter(_that);case FilterCartonCodesByFormat():
return filterByFormat(_that);case ExportCartonCodes():
return export(_that);case SelectCartonCode():
return select(_that);case ClearSelection():
return clearSelection(_that);case RefreshCartonCodes():
return refresh(_that);case SealCarton():
return seal(_that);case UpdateCartonInspection():
return updateInspection(_that);case UpdateCartonProperties():
return updateProperties(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LoadCartonCodes value)?  load,TResult? Function( GenerateCartonCodes value)?  generate,TResult? Function( DeleteCartonCode value)?  delete,TResult? Function( DeleteCartonCodeBatch value)?  deleteBatch,TResult? Function( LinkCartonCodeToProduct value)?  linkToProduct,TResult? Function( PublishCartonCode value)?  publish,TResult? Function( PushCartonBatch value)?  pushBatch,TResult? Function( DeleteCartonBatchByGroup value)?  deleteBatchByGroup,TResult? Function( ExportCartonBatch value)?  exportBatch,TResult? Function( DeactivateCartonCode value)?  deactivate,TResult? Function( SearchCartonCodes value)?  search,TResult? Function( FilterCartonCodes value)?  filter,TResult? Function( FilterCartonCodesByFormat value)?  filterByFormat,TResult? Function( ExportCartonCodes value)?  export,TResult? Function( SelectCartonCode value)?  select,TResult? Function( ClearSelection value)?  clearSelection,TResult? Function( RefreshCartonCodes value)?  refresh,TResult? Function( SealCarton value)?  seal,TResult? Function( UpdateCartonInspection value)?  updateInspection,TResult? Function( UpdateCartonProperties value)?  updateProperties,}){
final _that = this;
switch (_that) {
case LoadCartonCodes() when load != null:
return load(_that);case GenerateCartonCodes() when generate != null:
return generate(_that);case DeleteCartonCode() when delete != null:
return delete(_that);case DeleteCartonCodeBatch() when deleteBatch != null:
return deleteBatch(_that);case LinkCartonCodeToProduct() when linkToProduct != null:
return linkToProduct(_that);case PublishCartonCode() when publish != null:
return publish(_that);case PushCartonBatch() when pushBatch != null:
return pushBatch(_that);case DeleteCartonBatchByGroup() when deleteBatchByGroup != null:
return deleteBatchByGroup(_that);case ExportCartonBatch() when exportBatch != null:
return exportBatch(_that);case DeactivateCartonCode() when deactivate != null:
return deactivate(_that);case SearchCartonCodes() when search != null:
return search(_that);case FilterCartonCodes() when filter != null:
return filter(_that);case FilterCartonCodesByFormat() when filterByFormat != null:
return filterByFormat(_that);case ExportCartonCodes() when export != null:
return export(_that);case SelectCartonCode() when select != null:
return select(_that);case ClearSelection() when clearSelection != null:
return clearSelection(_that);case RefreshCartonCodes() when refresh != null:
return refresh(_that);case SealCarton() when seal != null:
return seal(_that);case UpdateCartonInspection() when updateInspection != null:
return updateInspection(_that);case UpdateCartonProperties() when updateProperties != null:
return updateProperties(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String? codeFormat)?  load,TResult Function( CartonCodeGenerationRequest request)?  generate,TResult Function( String cartonCodeId)?  delete,TResult Function( List<String> cartonCodeIds)?  deleteBatch,TResult Function( String cartonCodeId,  String productId,  String productBatchNumber,  DateTime? manufacturingDate,  DateTime? expiryDate,  int? warrantyMonths)?  linkToProduct,TResult Function( String cartonCodeId)?  publish,TResult Function( String batchId,  String codeFormat,  int count)?  pushBatch,TResult Function( String batchId,  String codeFormat)?  deleteBatchByGroup,TResult Function( String batchId,  String codeFormat,  String format)?  exportBatch,TResult Function( String cartonCodeId,  String reason)?  deactivate,TResult Function( String query)?  search,TResult Function( CodeStatus? status,  String? bundleCode,  DateTime? startDate,  DateTime? endDate,  String? cartonType,  String? condition)?  filter,TResult Function( String? codeFormat)?  filterByFormat,TResult Function( List<String> cartonCodeIds,  String format)?  export,TResult Function( String cartonCodeId,  bool isSelected)?  select,TResult Function()?  clearSelection,TResult Function()?  refresh,TResult Function( String cartonCodeId,  String sealedBy)?  seal,TResult Function( String cartonCodeId,  String condition,  String inspectionNotes)?  updateInspection,TResult Function( String cartonCodeId,  double? weight,  String? dimensions,  String? temperatureRequirements,  String? handlingInstructions)?  updateProperties,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LoadCartonCodes() when load != null:
return load(_that.codeFormat);case GenerateCartonCodes() when generate != null:
return generate(_that.request);case DeleteCartonCode() when delete != null:
return delete(_that.cartonCodeId);case DeleteCartonCodeBatch() when deleteBatch != null:
return deleteBatch(_that.cartonCodeIds);case LinkCartonCodeToProduct() when linkToProduct != null:
return linkToProduct(_that.cartonCodeId,_that.productId,_that.productBatchNumber,_that.manufacturingDate,_that.expiryDate,_that.warrantyMonths);case PublishCartonCode() when publish != null:
return publish(_that.cartonCodeId);case PushCartonBatch() when pushBatch != null:
return pushBatch(_that.batchId,_that.codeFormat,_that.count);case DeleteCartonBatchByGroup() when deleteBatchByGroup != null:
return deleteBatchByGroup(_that.batchId,_that.codeFormat);case ExportCartonBatch() when exportBatch != null:
return exportBatch(_that.batchId,_that.codeFormat,_that.format);case DeactivateCartonCode() when deactivate != null:
return deactivate(_that.cartonCodeId,_that.reason);case SearchCartonCodes() when search != null:
return search(_that.query);case FilterCartonCodes() when filter != null:
return filter(_that.status,_that.bundleCode,_that.startDate,_that.endDate,_that.cartonType,_that.condition);case FilterCartonCodesByFormat() when filterByFormat != null:
return filterByFormat(_that.codeFormat);case ExportCartonCodes() when export != null:
return export(_that.cartonCodeIds,_that.format);case SelectCartonCode() when select != null:
return select(_that.cartonCodeId,_that.isSelected);case ClearSelection() when clearSelection != null:
return clearSelection();case RefreshCartonCodes() when refresh != null:
return refresh();case SealCarton() when seal != null:
return seal(_that.cartonCodeId,_that.sealedBy);case UpdateCartonInspection() when updateInspection != null:
return updateInspection(_that.cartonCodeId,_that.condition,_that.inspectionNotes);case UpdateCartonProperties() when updateProperties != null:
return updateProperties(_that.cartonCodeId,_that.weight,_that.dimensions,_that.temperatureRequirements,_that.handlingInstructions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String? codeFormat)  load,required TResult Function( CartonCodeGenerationRequest request)  generate,required TResult Function( String cartonCodeId)  delete,required TResult Function( List<String> cartonCodeIds)  deleteBatch,required TResult Function( String cartonCodeId,  String productId,  String productBatchNumber,  DateTime? manufacturingDate,  DateTime? expiryDate,  int? warrantyMonths)  linkToProduct,required TResult Function( String cartonCodeId)  publish,required TResult Function( String batchId,  String codeFormat,  int count)  pushBatch,required TResult Function( String batchId,  String codeFormat)  deleteBatchByGroup,required TResult Function( String batchId,  String codeFormat,  String format)  exportBatch,required TResult Function( String cartonCodeId,  String reason)  deactivate,required TResult Function( String query)  search,required TResult Function( CodeStatus? status,  String? bundleCode,  DateTime? startDate,  DateTime? endDate,  String? cartonType,  String? condition)  filter,required TResult Function( String? codeFormat)  filterByFormat,required TResult Function( List<String> cartonCodeIds,  String format)  export,required TResult Function( String cartonCodeId,  bool isSelected)  select,required TResult Function()  clearSelection,required TResult Function()  refresh,required TResult Function( String cartonCodeId,  String sealedBy)  seal,required TResult Function( String cartonCodeId,  String condition,  String inspectionNotes)  updateInspection,required TResult Function( String cartonCodeId,  double? weight,  String? dimensions,  String? temperatureRequirements,  String? handlingInstructions)  updateProperties,}) {final _that = this;
switch (_that) {
case LoadCartonCodes():
return load(_that.codeFormat);case GenerateCartonCodes():
return generate(_that.request);case DeleteCartonCode():
return delete(_that.cartonCodeId);case DeleteCartonCodeBatch():
return deleteBatch(_that.cartonCodeIds);case LinkCartonCodeToProduct():
return linkToProduct(_that.cartonCodeId,_that.productId,_that.productBatchNumber,_that.manufacturingDate,_that.expiryDate,_that.warrantyMonths);case PublishCartonCode():
return publish(_that.cartonCodeId);case PushCartonBatch():
return pushBatch(_that.batchId,_that.codeFormat,_that.count);case DeleteCartonBatchByGroup():
return deleteBatchByGroup(_that.batchId,_that.codeFormat);case ExportCartonBatch():
return exportBatch(_that.batchId,_that.codeFormat,_that.format);case DeactivateCartonCode():
return deactivate(_that.cartonCodeId,_that.reason);case SearchCartonCodes():
return search(_that.query);case FilterCartonCodes():
return filter(_that.status,_that.bundleCode,_that.startDate,_that.endDate,_that.cartonType,_that.condition);case FilterCartonCodesByFormat():
return filterByFormat(_that.codeFormat);case ExportCartonCodes():
return export(_that.cartonCodeIds,_that.format);case SelectCartonCode():
return select(_that.cartonCodeId,_that.isSelected);case ClearSelection():
return clearSelection();case RefreshCartonCodes():
return refresh();case SealCarton():
return seal(_that.cartonCodeId,_that.sealedBy);case UpdateCartonInspection():
return updateInspection(_that.cartonCodeId,_that.condition,_that.inspectionNotes);case UpdateCartonProperties():
return updateProperties(_that.cartonCodeId,_that.weight,_that.dimensions,_that.temperatureRequirements,_that.handlingInstructions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String? codeFormat)?  load,TResult? Function( CartonCodeGenerationRequest request)?  generate,TResult? Function( String cartonCodeId)?  delete,TResult? Function( List<String> cartonCodeIds)?  deleteBatch,TResult? Function( String cartonCodeId,  String productId,  String productBatchNumber,  DateTime? manufacturingDate,  DateTime? expiryDate,  int? warrantyMonths)?  linkToProduct,TResult? Function( String cartonCodeId)?  publish,TResult? Function( String batchId,  String codeFormat,  int count)?  pushBatch,TResult? Function( String batchId,  String codeFormat)?  deleteBatchByGroup,TResult? Function( String batchId,  String codeFormat,  String format)?  exportBatch,TResult? Function( String cartonCodeId,  String reason)?  deactivate,TResult? Function( String query)?  search,TResult? Function( CodeStatus? status,  String? bundleCode,  DateTime? startDate,  DateTime? endDate,  String? cartonType,  String? condition)?  filter,TResult? Function( String? codeFormat)?  filterByFormat,TResult? Function( List<String> cartonCodeIds,  String format)?  export,TResult? Function( String cartonCodeId,  bool isSelected)?  select,TResult? Function()?  clearSelection,TResult? Function()?  refresh,TResult? Function( String cartonCodeId,  String sealedBy)?  seal,TResult? Function( String cartonCodeId,  String condition,  String inspectionNotes)?  updateInspection,TResult? Function( String cartonCodeId,  double? weight,  String? dimensions,  String? temperatureRequirements,  String? handlingInstructions)?  updateProperties,}) {final _that = this;
switch (_that) {
case LoadCartonCodes() when load != null:
return load(_that.codeFormat);case GenerateCartonCodes() when generate != null:
return generate(_that.request);case DeleteCartonCode() when delete != null:
return delete(_that.cartonCodeId);case DeleteCartonCodeBatch() when deleteBatch != null:
return deleteBatch(_that.cartonCodeIds);case LinkCartonCodeToProduct() when linkToProduct != null:
return linkToProduct(_that.cartonCodeId,_that.productId,_that.productBatchNumber,_that.manufacturingDate,_that.expiryDate,_that.warrantyMonths);case PublishCartonCode() when publish != null:
return publish(_that.cartonCodeId);case PushCartonBatch() when pushBatch != null:
return pushBatch(_that.batchId,_that.codeFormat,_that.count);case DeleteCartonBatchByGroup() when deleteBatchByGroup != null:
return deleteBatchByGroup(_that.batchId,_that.codeFormat);case ExportCartonBatch() when exportBatch != null:
return exportBatch(_that.batchId,_that.codeFormat,_that.format);case DeactivateCartonCode() when deactivate != null:
return deactivate(_that.cartonCodeId,_that.reason);case SearchCartonCodes() when search != null:
return search(_that.query);case FilterCartonCodes() when filter != null:
return filter(_that.status,_that.bundleCode,_that.startDate,_that.endDate,_that.cartonType,_that.condition);case FilterCartonCodesByFormat() when filterByFormat != null:
return filterByFormat(_that.codeFormat);case ExportCartonCodes() when export != null:
return export(_that.cartonCodeIds,_that.format);case SelectCartonCode() when select != null:
return select(_that.cartonCodeId,_that.isSelected);case ClearSelection() when clearSelection != null:
return clearSelection();case RefreshCartonCodes() when refresh != null:
return refresh();case SealCarton() when seal != null:
return seal(_that.cartonCodeId,_that.sealedBy);case UpdateCartonInspection() when updateInspection != null:
return updateInspection(_that.cartonCodeId,_that.condition,_that.inspectionNotes);case UpdateCartonProperties() when updateProperties != null:
return updateProperties(_that.cartonCodeId,_that.weight,_that.dimensions,_that.temperatureRequirements,_that.handlingInstructions);case _:
  return null;

}
}

}

/// @nodoc


class LoadCartonCodes implements CartonCodesEvent {
  const LoadCartonCodes({this.codeFormat});
  

 final  String? codeFormat;

/// Create a copy of CartonCodesEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoadCartonCodesCopyWith<LoadCartonCodes> get copyWith => _$LoadCartonCodesCopyWithImpl<LoadCartonCodes>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoadCartonCodes&&(identical(other.codeFormat, codeFormat) || other.codeFormat == codeFormat));
}


@override
int get hashCode => Object.hash(runtimeType,codeFormat);

@override
String toString() {
  return 'CartonCodesEvent.load(codeFormat: $codeFormat)';
}


}

/// @nodoc
abstract mixin class $LoadCartonCodesCopyWith<$Res> implements $CartonCodesEventCopyWith<$Res> {
  factory $LoadCartonCodesCopyWith(LoadCartonCodes value, $Res Function(LoadCartonCodes) _then) = _$LoadCartonCodesCopyWithImpl;
@useResult
$Res call({
 String? codeFormat
});




}
/// @nodoc
class _$LoadCartonCodesCopyWithImpl<$Res>
    implements $LoadCartonCodesCopyWith<$Res> {
  _$LoadCartonCodesCopyWithImpl(this._self, this._then);

  final LoadCartonCodes _self;
  final $Res Function(LoadCartonCodes) _then;

/// Create a copy of CartonCodesEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? codeFormat = freezed,}) {
  return _then(LoadCartonCodes(
codeFormat: freezed == codeFormat ? _self.codeFormat : codeFormat // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class GenerateCartonCodes implements CartonCodesEvent {
  const GenerateCartonCodes(this.request);
  

 final  CartonCodeGenerationRequest request;

/// Create a copy of CartonCodesEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GenerateCartonCodesCopyWith<GenerateCartonCodes> get copyWith => _$GenerateCartonCodesCopyWithImpl<GenerateCartonCodes>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GenerateCartonCodes&&(identical(other.request, request) || other.request == request));
}


@override
int get hashCode => Object.hash(runtimeType,request);

@override
String toString() {
  return 'CartonCodesEvent.generate(request: $request)';
}


}

/// @nodoc
abstract mixin class $GenerateCartonCodesCopyWith<$Res> implements $CartonCodesEventCopyWith<$Res> {
  factory $GenerateCartonCodesCopyWith(GenerateCartonCodes value, $Res Function(GenerateCartonCodes) _then) = _$GenerateCartonCodesCopyWithImpl;
@useResult
$Res call({
 CartonCodeGenerationRequest request
});


$CartonCodeGenerationRequestCopyWith<$Res> get request;

}
/// @nodoc
class _$GenerateCartonCodesCopyWithImpl<$Res>
    implements $GenerateCartonCodesCopyWith<$Res> {
  _$GenerateCartonCodesCopyWithImpl(this._self, this._then);

  final GenerateCartonCodes _self;
  final $Res Function(GenerateCartonCodes) _then;

/// Create a copy of CartonCodesEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? request = null,}) {
  return _then(GenerateCartonCodes(
null == request ? _self.request : request // ignore: cast_nullable_to_non_nullable
as CartonCodeGenerationRequest,
  ));
}

/// Create a copy of CartonCodesEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CartonCodeGenerationRequestCopyWith<$Res> get request {
  
  return $CartonCodeGenerationRequestCopyWith<$Res>(_self.request, (value) {
    return _then(_self.copyWith(request: value));
  });
}
}

/// @nodoc


class DeleteCartonCode implements CartonCodesEvent {
  const DeleteCartonCode(this.cartonCodeId);
  

 final  String cartonCodeId;

/// Create a copy of CartonCodesEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeleteCartonCodeCopyWith<DeleteCartonCode> get copyWith => _$DeleteCartonCodeCopyWithImpl<DeleteCartonCode>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeleteCartonCode&&(identical(other.cartonCodeId, cartonCodeId) || other.cartonCodeId == cartonCodeId));
}


@override
int get hashCode => Object.hash(runtimeType,cartonCodeId);

@override
String toString() {
  return 'CartonCodesEvent.delete(cartonCodeId: $cartonCodeId)';
}


}

/// @nodoc
abstract mixin class $DeleteCartonCodeCopyWith<$Res> implements $CartonCodesEventCopyWith<$Res> {
  factory $DeleteCartonCodeCopyWith(DeleteCartonCode value, $Res Function(DeleteCartonCode) _then) = _$DeleteCartonCodeCopyWithImpl;
@useResult
$Res call({
 String cartonCodeId
});




}
/// @nodoc
class _$DeleteCartonCodeCopyWithImpl<$Res>
    implements $DeleteCartonCodeCopyWith<$Res> {
  _$DeleteCartonCodeCopyWithImpl(this._self, this._then);

  final DeleteCartonCode _self;
  final $Res Function(DeleteCartonCode) _then;

/// Create a copy of CartonCodesEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? cartonCodeId = null,}) {
  return _then(DeleteCartonCode(
null == cartonCodeId ? _self.cartonCodeId : cartonCodeId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class DeleteCartonCodeBatch implements CartonCodesEvent {
  const DeleteCartonCodeBatch(final  List<String> cartonCodeIds): _cartonCodeIds = cartonCodeIds;
  

 final  List<String> _cartonCodeIds;
 List<String> get cartonCodeIds {
  if (_cartonCodeIds is EqualUnmodifiableListView) return _cartonCodeIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cartonCodeIds);
}


/// Create a copy of CartonCodesEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeleteCartonCodeBatchCopyWith<DeleteCartonCodeBatch> get copyWith => _$DeleteCartonCodeBatchCopyWithImpl<DeleteCartonCodeBatch>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeleteCartonCodeBatch&&const DeepCollectionEquality().equals(other._cartonCodeIds, _cartonCodeIds));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_cartonCodeIds));

@override
String toString() {
  return 'CartonCodesEvent.deleteBatch(cartonCodeIds: $cartonCodeIds)';
}


}

/// @nodoc
abstract mixin class $DeleteCartonCodeBatchCopyWith<$Res> implements $CartonCodesEventCopyWith<$Res> {
  factory $DeleteCartonCodeBatchCopyWith(DeleteCartonCodeBatch value, $Res Function(DeleteCartonCodeBatch) _then) = _$DeleteCartonCodeBatchCopyWithImpl;
@useResult
$Res call({
 List<String> cartonCodeIds
});




}
/// @nodoc
class _$DeleteCartonCodeBatchCopyWithImpl<$Res>
    implements $DeleteCartonCodeBatchCopyWith<$Res> {
  _$DeleteCartonCodeBatchCopyWithImpl(this._self, this._then);

  final DeleteCartonCodeBatch _self;
  final $Res Function(DeleteCartonCodeBatch) _then;

/// Create a copy of CartonCodesEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? cartonCodeIds = null,}) {
  return _then(DeleteCartonCodeBatch(
null == cartonCodeIds ? _self._cartonCodeIds : cartonCodeIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class LinkCartonCodeToProduct implements CartonCodesEvent {
  const LinkCartonCodeToProduct({required this.cartonCodeId, required this.productId, required this.productBatchNumber, this.manufacturingDate, this.expiryDate, this.warrantyMonths});
  

 final  String cartonCodeId;
 final  String productId;
 final  String productBatchNumber;
 final  DateTime? manufacturingDate;
 final  DateTime? expiryDate;
 final  int? warrantyMonths;

/// Create a copy of CartonCodesEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LinkCartonCodeToProductCopyWith<LinkCartonCodeToProduct> get copyWith => _$LinkCartonCodeToProductCopyWithImpl<LinkCartonCodeToProduct>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LinkCartonCodeToProduct&&(identical(other.cartonCodeId, cartonCodeId) || other.cartonCodeId == cartonCodeId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productBatchNumber, productBatchNumber) || other.productBatchNumber == productBatchNumber)&&(identical(other.manufacturingDate, manufacturingDate) || other.manufacturingDate == manufacturingDate)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.warrantyMonths, warrantyMonths) || other.warrantyMonths == warrantyMonths));
}


@override
int get hashCode => Object.hash(runtimeType,cartonCodeId,productId,productBatchNumber,manufacturingDate,expiryDate,warrantyMonths);

@override
String toString() {
  return 'CartonCodesEvent.linkToProduct(cartonCodeId: $cartonCodeId, productId: $productId, productBatchNumber: $productBatchNumber, manufacturingDate: $manufacturingDate, expiryDate: $expiryDate, warrantyMonths: $warrantyMonths)';
}


}

/// @nodoc
abstract mixin class $LinkCartonCodeToProductCopyWith<$Res> implements $CartonCodesEventCopyWith<$Res> {
  factory $LinkCartonCodeToProductCopyWith(LinkCartonCodeToProduct value, $Res Function(LinkCartonCodeToProduct) _then) = _$LinkCartonCodeToProductCopyWithImpl;
@useResult
$Res call({
 String cartonCodeId, String productId, String productBatchNumber, DateTime? manufacturingDate, DateTime? expiryDate, int? warrantyMonths
});




}
/// @nodoc
class _$LinkCartonCodeToProductCopyWithImpl<$Res>
    implements $LinkCartonCodeToProductCopyWith<$Res> {
  _$LinkCartonCodeToProductCopyWithImpl(this._self, this._then);

  final LinkCartonCodeToProduct _self;
  final $Res Function(LinkCartonCodeToProduct) _then;

/// Create a copy of CartonCodesEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? cartonCodeId = null,Object? productId = null,Object? productBatchNumber = null,Object? manufacturingDate = freezed,Object? expiryDate = freezed,Object? warrantyMonths = freezed,}) {
  return _then(LinkCartonCodeToProduct(
cartonCodeId: null == cartonCodeId ? _self.cartonCodeId : cartonCodeId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,productBatchNumber: null == productBatchNumber ? _self.productBatchNumber : productBatchNumber // ignore: cast_nullable_to_non_nullable
as String,manufacturingDate: freezed == manufacturingDate ? _self.manufacturingDate : manufacturingDate // ignore: cast_nullable_to_non_nullable
as DateTime?,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,warrantyMonths: freezed == warrantyMonths ? _self.warrantyMonths : warrantyMonths // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc


class PublishCartonCode implements CartonCodesEvent {
  const PublishCartonCode(this.cartonCodeId);
  

 final  String cartonCodeId;

/// Create a copy of CartonCodesEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PublishCartonCodeCopyWith<PublishCartonCode> get copyWith => _$PublishCartonCodeCopyWithImpl<PublishCartonCode>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PublishCartonCode&&(identical(other.cartonCodeId, cartonCodeId) || other.cartonCodeId == cartonCodeId));
}


@override
int get hashCode => Object.hash(runtimeType,cartonCodeId);

@override
String toString() {
  return 'CartonCodesEvent.publish(cartonCodeId: $cartonCodeId)';
}


}

/// @nodoc
abstract mixin class $PublishCartonCodeCopyWith<$Res> implements $CartonCodesEventCopyWith<$Res> {
  factory $PublishCartonCodeCopyWith(PublishCartonCode value, $Res Function(PublishCartonCode) _then) = _$PublishCartonCodeCopyWithImpl;
@useResult
$Res call({
 String cartonCodeId
});




}
/// @nodoc
class _$PublishCartonCodeCopyWithImpl<$Res>
    implements $PublishCartonCodeCopyWith<$Res> {
  _$PublishCartonCodeCopyWithImpl(this._self, this._then);

  final PublishCartonCode _self;
  final $Res Function(PublishCartonCode) _then;

/// Create a copy of CartonCodesEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? cartonCodeId = null,}) {
  return _then(PublishCartonCode(
null == cartonCodeId ? _self.cartonCodeId : cartonCodeId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class PushCartonBatch implements CartonCodesEvent {
  const PushCartonBatch({required this.batchId, required this.codeFormat, required this.count});
  

 final  String batchId;
 final  String codeFormat;
 final  int count;

/// Create a copy of CartonCodesEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PushCartonBatchCopyWith<PushCartonBatch> get copyWith => _$PushCartonBatchCopyWithImpl<PushCartonBatch>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PushCartonBatch&&(identical(other.batchId, batchId) || other.batchId == batchId)&&(identical(other.codeFormat, codeFormat) || other.codeFormat == codeFormat)&&(identical(other.count, count) || other.count == count));
}


@override
int get hashCode => Object.hash(runtimeType,batchId,codeFormat,count);

@override
String toString() {
  return 'CartonCodesEvent.pushBatch(batchId: $batchId, codeFormat: $codeFormat, count: $count)';
}


}

/// @nodoc
abstract mixin class $PushCartonBatchCopyWith<$Res> implements $CartonCodesEventCopyWith<$Res> {
  factory $PushCartonBatchCopyWith(PushCartonBatch value, $Res Function(PushCartonBatch) _then) = _$PushCartonBatchCopyWithImpl;
@useResult
$Res call({
 String batchId, String codeFormat, int count
});




}
/// @nodoc
class _$PushCartonBatchCopyWithImpl<$Res>
    implements $PushCartonBatchCopyWith<$Res> {
  _$PushCartonBatchCopyWithImpl(this._self, this._then);

  final PushCartonBatch _self;
  final $Res Function(PushCartonBatch) _then;

/// Create a copy of CartonCodesEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? batchId = null,Object? codeFormat = null,Object? count = null,}) {
  return _then(PushCartonBatch(
batchId: null == batchId ? _self.batchId : batchId // ignore: cast_nullable_to_non_nullable
as String,codeFormat: null == codeFormat ? _self.codeFormat : codeFormat // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class DeleteCartonBatchByGroup implements CartonCodesEvent {
  const DeleteCartonBatchByGroup({required this.batchId, required this.codeFormat});
  

 final  String batchId;
 final  String codeFormat;

/// Create a copy of CartonCodesEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeleteCartonBatchByGroupCopyWith<DeleteCartonBatchByGroup> get copyWith => _$DeleteCartonBatchByGroupCopyWithImpl<DeleteCartonBatchByGroup>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeleteCartonBatchByGroup&&(identical(other.batchId, batchId) || other.batchId == batchId)&&(identical(other.codeFormat, codeFormat) || other.codeFormat == codeFormat));
}


@override
int get hashCode => Object.hash(runtimeType,batchId,codeFormat);

@override
String toString() {
  return 'CartonCodesEvent.deleteBatchByGroup(batchId: $batchId, codeFormat: $codeFormat)';
}


}

/// @nodoc
abstract mixin class $DeleteCartonBatchByGroupCopyWith<$Res> implements $CartonCodesEventCopyWith<$Res> {
  factory $DeleteCartonBatchByGroupCopyWith(DeleteCartonBatchByGroup value, $Res Function(DeleteCartonBatchByGroup) _then) = _$DeleteCartonBatchByGroupCopyWithImpl;
@useResult
$Res call({
 String batchId, String codeFormat
});




}
/// @nodoc
class _$DeleteCartonBatchByGroupCopyWithImpl<$Res>
    implements $DeleteCartonBatchByGroupCopyWith<$Res> {
  _$DeleteCartonBatchByGroupCopyWithImpl(this._self, this._then);

  final DeleteCartonBatchByGroup _self;
  final $Res Function(DeleteCartonBatchByGroup) _then;

/// Create a copy of CartonCodesEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? batchId = null,Object? codeFormat = null,}) {
  return _then(DeleteCartonBatchByGroup(
batchId: null == batchId ? _self.batchId : batchId // ignore: cast_nullable_to_non_nullable
as String,codeFormat: null == codeFormat ? _self.codeFormat : codeFormat // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ExportCartonBatch implements CartonCodesEvent {
  const ExportCartonBatch(this.batchId, this.codeFormat, this.format);
  

 final  String batchId;
 final  String codeFormat;
 final  String format;

/// Create a copy of CartonCodesEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExportCartonBatchCopyWith<ExportCartonBatch> get copyWith => _$ExportCartonBatchCopyWithImpl<ExportCartonBatch>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExportCartonBatch&&(identical(other.batchId, batchId) || other.batchId == batchId)&&(identical(other.codeFormat, codeFormat) || other.codeFormat == codeFormat)&&(identical(other.format, format) || other.format == format));
}


@override
int get hashCode => Object.hash(runtimeType,batchId,codeFormat,format);

@override
String toString() {
  return 'CartonCodesEvent.exportBatch(batchId: $batchId, codeFormat: $codeFormat, format: $format)';
}


}

/// @nodoc
abstract mixin class $ExportCartonBatchCopyWith<$Res> implements $CartonCodesEventCopyWith<$Res> {
  factory $ExportCartonBatchCopyWith(ExportCartonBatch value, $Res Function(ExportCartonBatch) _then) = _$ExportCartonBatchCopyWithImpl;
@useResult
$Res call({
 String batchId, String codeFormat, String format
});




}
/// @nodoc
class _$ExportCartonBatchCopyWithImpl<$Res>
    implements $ExportCartonBatchCopyWith<$Res> {
  _$ExportCartonBatchCopyWithImpl(this._self, this._then);

  final ExportCartonBatch _self;
  final $Res Function(ExportCartonBatch) _then;

/// Create a copy of CartonCodesEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? batchId = null,Object? codeFormat = null,Object? format = null,}) {
  return _then(ExportCartonBatch(
null == batchId ? _self.batchId : batchId // ignore: cast_nullable_to_non_nullable
as String,null == codeFormat ? _self.codeFormat : codeFormat // ignore: cast_nullable_to_non_nullable
as String,null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class DeactivateCartonCode implements CartonCodesEvent {
  const DeactivateCartonCode(this.cartonCodeId, this.reason);
  

 final  String cartonCodeId;
 final  String reason;

/// Create a copy of CartonCodesEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeactivateCartonCodeCopyWith<DeactivateCartonCode> get copyWith => _$DeactivateCartonCodeCopyWithImpl<DeactivateCartonCode>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeactivateCartonCode&&(identical(other.cartonCodeId, cartonCodeId) || other.cartonCodeId == cartonCodeId)&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode => Object.hash(runtimeType,cartonCodeId,reason);

@override
String toString() {
  return 'CartonCodesEvent.deactivate(cartonCodeId: $cartonCodeId, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $DeactivateCartonCodeCopyWith<$Res> implements $CartonCodesEventCopyWith<$Res> {
  factory $DeactivateCartonCodeCopyWith(DeactivateCartonCode value, $Res Function(DeactivateCartonCode) _then) = _$DeactivateCartonCodeCopyWithImpl;
@useResult
$Res call({
 String cartonCodeId, String reason
});




}
/// @nodoc
class _$DeactivateCartonCodeCopyWithImpl<$Res>
    implements $DeactivateCartonCodeCopyWith<$Res> {
  _$DeactivateCartonCodeCopyWithImpl(this._self, this._then);

  final DeactivateCartonCode _self;
  final $Res Function(DeactivateCartonCode) _then;

/// Create a copy of CartonCodesEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? cartonCodeId = null,Object? reason = null,}) {
  return _then(DeactivateCartonCode(
null == cartonCodeId ? _self.cartonCodeId : cartonCodeId // ignore: cast_nullable_to_non_nullable
as String,null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SearchCartonCodes implements CartonCodesEvent {
  const SearchCartonCodes(this.query);
  

 final  String query;

/// Create a copy of CartonCodesEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchCartonCodesCopyWith<SearchCartonCodes> get copyWith => _$SearchCartonCodesCopyWithImpl<SearchCartonCodes>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchCartonCodes&&(identical(other.query, query) || other.query == query));
}


@override
int get hashCode => Object.hash(runtimeType,query);

@override
String toString() {
  return 'CartonCodesEvent.search(query: $query)';
}


}

/// @nodoc
abstract mixin class $SearchCartonCodesCopyWith<$Res> implements $CartonCodesEventCopyWith<$Res> {
  factory $SearchCartonCodesCopyWith(SearchCartonCodes value, $Res Function(SearchCartonCodes) _then) = _$SearchCartonCodesCopyWithImpl;
@useResult
$Res call({
 String query
});




}
/// @nodoc
class _$SearchCartonCodesCopyWithImpl<$Res>
    implements $SearchCartonCodesCopyWith<$Res> {
  _$SearchCartonCodesCopyWithImpl(this._self, this._then);

  final SearchCartonCodes _self;
  final $Res Function(SearchCartonCodes) _then;

/// Create a copy of CartonCodesEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? query = null,}) {
  return _then(SearchCartonCodes(
null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class FilterCartonCodes implements CartonCodesEvent {
  const FilterCartonCodes({this.status, this.bundleCode, this.startDate, this.endDate, this.cartonType, this.condition});
  

 final  CodeStatus? status;
 final  String? bundleCode;
 final  DateTime? startDate;
 final  DateTime? endDate;
 final  String? cartonType;
 final  String? condition;

/// Create a copy of CartonCodesEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FilterCartonCodesCopyWith<FilterCartonCodes> get copyWith => _$FilterCartonCodesCopyWithImpl<FilterCartonCodes>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FilterCartonCodes&&(identical(other.status, status) || other.status == status)&&(identical(other.bundleCode, bundleCode) || other.bundleCode == bundleCode)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.cartonType, cartonType) || other.cartonType == cartonType)&&(identical(other.condition, condition) || other.condition == condition));
}


@override
int get hashCode => Object.hash(runtimeType,status,bundleCode,startDate,endDate,cartonType,condition);

@override
String toString() {
  return 'CartonCodesEvent.filter(status: $status, bundleCode: $bundleCode, startDate: $startDate, endDate: $endDate, cartonType: $cartonType, condition: $condition)';
}


}

/// @nodoc
abstract mixin class $FilterCartonCodesCopyWith<$Res> implements $CartonCodesEventCopyWith<$Res> {
  factory $FilterCartonCodesCopyWith(FilterCartonCodes value, $Res Function(FilterCartonCodes) _then) = _$FilterCartonCodesCopyWithImpl;
@useResult
$Res call({
 CodeStatus? status, String? bundleCode, DateTime? startDate, DateTime? endDate, String? cartonType, String? condition
});




}
/// @nodoc
class _$FilterCartonCodesCopyWithImpl<$Res>
    implements $FilterCartonCodesCopyWith<$Res> {
  _$FilterCartonCodesCopyWithImpl(this._self, this._then);

  final FilterCartonCodes _self;
  final $Res Function(FilterCartonCodes) _then;

/// Create a copy of CartonCodesEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? status = freezed,Object? bundleCode = freezed,Object? startDate = freezed,Object? endDate = freezed,Object? cartonType = freezed,Object? condition = freezed,}) {
  return _then(FilterCartonCodes(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CodeStatus?,bundleCode: freezed == bundleCode ? _self.bundleCode : bundleCode // ignore: cast_nullable_to_non_nullable
as String?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,cartonType: freezed == cartonType ? _self.cartonType : cartonType // ignore: cast_nullable_to_non_nullable
as String?,condition: freezed == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class FilterCartonCodesByFormat implements CartonCodesEvent {
  const FilterCartonCodesByFormat(this.codeFormat);
  

 final  String? codeFormat;

/// Create a copy of CartonCodesEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FilterCartonCodesByFormatCopyWith<FilterCartonCodesByFormat> get copyWith => _$FilterCartonCodesByFormatCopyWithImpl<FilterCartonCodesByFormat>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FilterCartonCodesByFormat&&(identical(other.codeFormat, codeFormat) || other.codeFormat == codeFormat));
}


@override
int get hashCode => Object.hash(runtimeType,codeFormat);

@override
String toString() {
  return 'CartonCodesEvent.filterByFormat(codeFormat: $codeFormat)';
}


}

/// @nodoc
abstract mixin class $FilterCartonCodesByFormatCopyWith<$Res> implements $CartonCodesEventCopyWith<$Res> {
  factory $FilterCartonCodesByFormatCopyWith(FilterCartonCodesByFormat value, $Res Function(FilterCartonCodesByFormat) _then) = _$FilterCartonCodesByFormatCopyWithImpl;
@useResult
$Res call({
 String? codeFormat
});




}
/// @nodoc
class _$FilterCartonCodesByFormatCopyWithImpl<$Res>
    implements $FilterCartonCodesByFormatCopyWith<$Res> {
  _$FilterCartonCodesByFormatCopyWithImpl(this._self, this._then);

  final FilterCartonCodesByFormat _self;
  final $Res Function(FilterCartonCodesByFormat) _then;

/// Create a copy of CartonCodesEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? codeFormat = freezed,}) {
  return _then(FilterCartonCodesByFormat(
freezed == codeFormat ? _self.codeFormat : codeFormat // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class ExportCartonCodes implements CartonCodesEvent {
  const ExportCartonCodes(final  List<String> cartonCodeIds, this.format): _cartonCodeIds = cartonCodeIds;
  

 final  List<String> _cartonCodeIds;
 List<String> get cartonCodeIds {
  if (_cartonCodeIds is EqualUnmodifiableListView) return _cartonCodeIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cartonCodeIds);
}

 final  String format;

/// Create a copy of CartonCodesEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExportCartonCodesCopyWith<ExportCartonCodes> get copyWith => _$ExportCartonCodesCopyWithImpl<ExportCartonCodes>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExportCartonCodes&&const DeepCollectionEquality().equals(other._cartonCodeIds, _cartonCodeIds)&&(identical(other.format, format) || other.format == format));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_cartonCodeIds),format);

@override
String toString() {
  return 'CartonCodesEvent.export(cartonCodeIds: $cartonCodeIds, format: $format)';
}


}

/// @nodoc
abstract mixin class $ExportCartonCodesCopyWith<$Res> implements $CartonCodesEventCopyWith<$Res> {
  factory $ExportCartonCodesCopyWith(ExportCartonCodes value, $Res Function(ExportCartonCodes) _then) = _$ExportCartonCodesCopyWithImpl;
@useResult
$Res call({
 List<String> cartonCodeIds, String format
});




}
/// @nodoc
class _$ExportCartonCodesCopyWithImpl<$Res>
    implements $ExportCartonCodesCopyWith<$Res> {
  _$ExportCartonCodesCopyWithImpl(this._self, this._then);

  final ExportCartonCodes _self;
  final $Res Function(ExportCartonCodes) _then;

/// Create a copy of CartonCodesEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? cartonCodeIds = null,Object? format = null,}) {
  return _then(ExportCartonCodes(
null == cartonCodeIds ? _self._cartonCodeIds : cartonCodeIds // ignore: cast_nullable_to_non_nullable
as List<String>,null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SelectCartonCode implements CartonCodesEvent {
  const SelectCartonCode(this.cartonCodeId, this.isSelected);
  

 final  String cartonCodeId;
 final  bool isSelected;

/// Create a copy of CartonCodesEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SelectCartonCodeCopyWith<SelectCartonCode> get copyWith => _$SelectCartonCodeCopyWithImpl<SelectCartonCode>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SelectCartonCode&&(identical(other.cartonCodeId, cartonCodeId) || other.cartonCodeId == cartonCodeId)&&(identical(other.isSelected, isSelected) || other.isSelected == isSelected));
}


@override
int get hashCode => Object.hash(runtimeType,cartonCodeId,isSelected);

@override
String toString() {
  return 'CartonCodesEvent.select(cartonCodeId: $cartonCodeId, isSelected: $isSelected)';
}


}

/// @nodoc
abstract mixin class $SelectCartonCodeCopyWith<$Res> implements $CartonCodesEventCopyWith<$Res> {
  factory $SelectCartonCodeCopyWith(SelectCartonCode value, $Res Function(SelectCartonCode) _then) = _$SelectCartonCodeCopyWithImpl;
@useResult
$Res call({
 String cartonCodeId, bool isSelected
});




}
/// @nodoc
class _$SelectCartonCodeCopyWithImpl<$Res>
    implements $SelectCartonCodeCopyWith<$Res> {
  _$SelectCartonCodeCopyWithImpl(this._self, this._then);

  final SelectCartonCode _self;
  final $Res Function(SelectCartonCode) _then;

/// Create a copy of CartonCodesEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? cartonCodeId = null,Object? isSelected = null,}) {
  return _then(SelectCartonCode(
null == cartonCodeId ? _self.cartonCodeId : cartonCodeId // ignore: cast_nullable_to_non_nullable
as String,null == isSelected ? _self.isSelected : isSelected // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class ClearSelection implements CartonCodesEvent {
  const ClearSelection();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClearSelection);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CartonCodesEvent.clearSelection()';
}


}




/// @nodoc


class RefreshCartonCodes implements CartonCodesEvent {
  const RefreshCartonCodes();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RefreshCartonCodes);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CartonCodesEvent.refresh()';
}


}




/// @nodoc


class SealCarton implements CartonCodesEvent {
  const SealCarton(this.cartonCodeId, this.sealedBy);
  

 final  String cartonCodeId;
 final  String sealedBy;

/// Create a copy of CartonCodesEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SealCartonCopyWith<SealCarton> get copyWith => _$SealCartonCopyWithImpl<SealCarton>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SealCarton&&(identical(other.cartonCodeId, cartonCodeId) || other.cartonCodeId == cartonCodeId)&&(identical(other.sealedBy, sealedBy) || other.sealedBy == sealedBy));
}


@override
int get hashCode => Object.hash(runtimeType,cartonCodeId,sealedBy);

@override
String toString() {
  return 'CartonCodesEvent.seal(cartonCodeId: $cartonCodeId, sealedBy: $sealedBy)';
}


}

/// @nodoc
abstract mixin class $SealCartonCopyWith<$Res> implements $CartonCodesEventCopyWith<$Res> {
  factory $SealCartonCopyWith(SealCarton value, $Res Function(SealCarton) _then) = _$SealCartonCopyWithImpl;
@useResult
$Res call({
 String cartonCodeId, String sealedBy
});




}
/// @nodoc
class _$SealCartonCopyWithImpl<$Res>
    implements $SealCartonCopyWith<$Res> {
  _$SealCartonCopyWithImpl(this._self, this._then);

  final SealCarton _self;
  final $Res Function(SealCarton) _then;

/// Create a copy of CartonCodesEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? cartonCodeId = null,Object? sealedBy = null,}) {
  return _then(SealCarton(
null == cartonCodeId ? _self.cartonCodeId : cartonCodeId // ignore: cast_nullable_to_non_nullable
as String,null == sealedBy ? _self.sealedBy : sealedBy // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class UpdateCartonInspection implements CartonCodesEvent {
  const UpdateCartonInspection(this.cartonCodeId, this.condition, this.inspectionNotes);
  

 final  String cartonCodeId;
 final  String condition;
 final  String inspectionNotes;

/// Create a copy of CartonCodesEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateCartonInspectionCopyWith<UpdateCartonInspection> get copyWith => _$UpdateCartonInspectionCopyWithImpl<UpdateCartonInspection>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateCartonInspection&&(identical(other.cartonCodeId, cartonCodeId) || other.cartonCodeId == cartonCodeId)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.inspectionNotes, inspectionNotes) || other.inspectionNotes == inspectionNotes));
}


@override
int get hashCode => Object.hash(runtimeType,cartonCodeId,condition,inspectionNotes);

@override
String toString() {
  return 'CartonCodesEvent.updateInspection(cartonCodeId: $cartonCodeId, condition: $condition, inspectionNotes: $inspectionNotes)';
}


}

/// @nodoc
abstract mixin class $UpdateCartonInspectionCopyWith<$Res> implements $CartonCodesEventCopyWith<$Res> {
  factory $UpdateCartonInspectionCopyWith(UpdateCartonInspection value, $Res Function(UpdateCartonInspection) _then) = _$UpdateCartonInspectionCopyWithImpl;
@useResult
$Res call({
 String cartonCodeId, String condition, String inspectionNotes
});




}
/// @nodoc
class _$UpdateCartonInspectionCopyWithImpl<$Res>
    implements $UpdateCartonInspectionCopyWith<$Res> {
  _$UpdateCartonInspectionCopyWithImpl(this._self, this._then);

  final UpdateCartonInspection _self;
  final $Res Function(UpdateCartonInspection) _then;

/// Create a copy of CartonCodesEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? cartonCodeId = null,Object? condition = null,Object? inspectionNotes = null,}) {
  return _then(UpdateCartonInspection(
null == cartonCodeId ? _self.cartonCodeId : cartonCodeId // ignore: cast_nullable_to_non_nullable
as String,null == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as String,null == inspectionNotes ? _self.inspectionNotes : inspectionNotes // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class UpdateCartonProperties implements CartonCodesEvent {
  const UpdateCartonProperties({required this.cartonCodeId, this.weight, this.dimensions, this.temperatureRequirements, this.handlingInstructions});
  

 final  String cartonCodeId;
 final  double? weight;
 final  String? dimensions;
 final  String? temperatureRequirements;
 final  String? handlingInstructions;

/// Create a copy of CartonCodesEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateCartonPropertiesCopyWith<UpdateCartonProperties> get copyWith => _$UpdateCartonPropertiesCopyWithImpl<UpdateCartonProperties>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateCartonProperties&&(identical(other.cartonCodeId, cartonCodeId) || other.cartonCodeId == cartonCodeId)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.dimensions, dimensions) || other.dimensions == dimensions)&&(identical(other.temperatureRequirements, temperatureRequirements) || other.temperatureRequirements == temperatureRequirements)&&(identical(other.handlingInstructions, handlingInstructions) || other.handlingInstructions == handlingInstructions));
}


@override
int get hashCode => Object.hash(runtimeType,cartonCodeId,weight,dimensions,temperatureRequirements,handlingInstructions);

@override
String toString() {
  return 'CartonCodesEvent.updateProperties(cartonCodeId: $cartonCodeId, weight: $weight, dimensions: $dimensions, temperatureRequirements: $temperatureRequirements, handlingInstructions: $handlingInstructions)';
}


}

/// @nodoc
abstract mixin class $UpdateCartonPropertiesCopyWith<$Res> implements $CartonCodesEventCopyWith<$Res> {
  factory $UpdateCartonPropertiesCopyWith(UpdateCartonProperties value, $Res Function(UpdateCartonProperties) _then) = _$UpdateCartonPropertiesCopyWithImpl;
@useResult
$Res call({
 String cartonCodeId, double? weight, String? dimensions, String? temperatureRequirements, String? handlingInstructions
});




}
/// @nodoc
class _$UpdateCartonPropertiesCopyWithImpl<$Res>
    implements $UpdateCartonPropertiesCopyWith<$Res> {
  _$UpdateCartonPropertiesCopyWithImpl(this._self, this._then);

  final UpdateCartonProperties _self;
  final $Res Function(UpdateCartonProperties) _then;

/// Create a copy of CartonCodesEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? cartonCodeId = null,Object? weight = freezed,Object? dimensions = freezed,Object? temperatureRequirements = freezed,Object? handlingInstructions = freezed,}) {
  return _then(UpdateCartonProperties(
cartonCodeId: null == cartonCodeId ? _self.cartonCodeId : cartonCodeId // ignore: cast_nullable_to_non_nullable
as String,weight: freezed == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double?,dimensions: freezed == dimensions ? _self.dimensions : dimensions // ignore: cast_nullable_to_non_nullable
as String?,temperatureRequirements: freezed == temperatureRequirements ? _self.temperatureRequirements : temperatureRequirements // ignore: cast_nullable_to_non_nullable
as String?,handlingInstructions: freezed == handlingInstructions ? _self.handlingInstructions : handlingInstructions // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$CartonCodesState {

 CartonCodesStatus get status; List<CartonCodeModel> get cartonCodes; List<CartonCodeModel> get filteredCartonCodes; Set<String> get selectedCartonCodeIds; String get searchQuery; CodeStatus? get filterStatus; String? get filterBundleCode; DateTime? get filterStartDate; DateTime? get filterEndDate; String? get filterCartonType; String? get filterCondition; String get filterCodeFormat; String? get errorMessage; bool get hasReachedMax; int get currentPage; int get totalCount; bool get isLoadingMore; int get generatedCount; DateTime? get lastGeneratedAt; String? get exportPath; bool get isExporting;
/// Create a copy of CartonCodesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartonCodesStateCopyWith<CartonCodesState> get copyWith => _$CartonCodesStateCopyWithImpl<CartonCodesState>(this as CartonCodesState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CartonCodesState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.cartonCodes, cartonCodes)&&const DeepCollectionEquality().equals(other.filteredCartonCodes, filteredCartonCodes)&&const DeepCollectionEquality().equals(other.selectedCartonCodeIds, selectedCartonCodeIds)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.filterStatus, filterStatus) || other.filterStatus == filterStatus)&&(identical(other.filterBundleCode, filterBundleCode) || other.filterBundleCode == filterBundleCode)&&(identical(other.filterStartDate, filterStartDate) || other.filterStartDate == filterStartDate)&&(identical(other.filterEndDate, filterEndDate) || other.filterEndDate == filterEndDate)&&(identical(other.filterCartonType, filterCartonType) || other.filterCartonType == filterCartonType)&&(identical(other.filterCondition, filterCondition) || other.filterCondition == filterCondition)&&(identical(other.filterCodeFormat, filterCodeFormat) || other.filterCodeFormat == filterCodeFormat)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.hasReachedMax, hasReachedMax) || other.hasReachedMax == hasReachedMax)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.generatedCount, generatedCount) || other.generatedCount == generatedCount)&&(identical(other.lastGeneratedAt, lastGeneratedAt) || other.lastGeneratedAt == lastGeneratedAt)&&(identical(other.exportPath, exportPath) || other.exportPath == exportPath)&&(identical(other.isExporting, isExporting) || other.isExporting == isExporting));
}


@override
int get hashCode => Object.hashAll([runtimeType,status,const DeepCollectionEquality().hash(cartonCodes),const DeepCollectionEquality().hash(filteredCartonCodes),const DeepCollectionEquality().hash(selectedCartonCodeIds),searchQuery,filterStatus,filterBundleCode,filterStartDate,filterEndDate,filterCartonType,filterCondition,filterCodeFormat,errorMessage,hasReachedMax,currentPage,totalCount,isLoadingMore,generatedCount,lastGeneratedAt,exportPath,isExporting]);

@override
String toString() {
  return 'CartonCodesState(status: $status, cartonCodes: $cartonCodes, filteredCartonCodes: $filteredCartonCodes, selectedCartonCodeIds: $selectedCartonCodeIds, searchQuery: $searchQuery, filterStatus: $filterStatus, filterBundleCode: $filterBundleCode, filterStartDate: $filterStartDate, filterEndDate: $filterEndDate, filterCartonType: $filterCartonType, filterCondition: $filterCondition, filterCodeFormat: $filterCodeFormat, errorMessage: $errorMessage, hasReachedMax: $hasReachedMax, currentPage: $currentPage, totalCount: $totalCount, isLoadingMore: $isLoadingMore, generatedCount: $generatedCount, lastGeneratedAt: $lastGeneratedAt, exportPath: $exportPath, isExporting: $isExporting)';
}


}

/// @nodoc
abstract mixin class $CartonCodesStateCopyWith<$Res>  {
  factory $CartonCodesStateCopyWith(CartonCodesState value, $Res Function(CartonCodesState) _then) = _$CartonCodesStateCopyWithImpl;
@useResult
$Res call({
 CartonCodesStatus status, List<CartonCodeModel> cartonCodes, List<CartonCodeModel> filteredCartonCodes, Set<String> selectedCartonCodeIds, String searchQuery, CodeStatus? filterStatus, String? filterBundleCode, DateTime? filterStartDate, DateTime? filterEndDate, String? filterCartonType, String? filterCondition, String filterCodeFormat, String? errorMessage, bool hasReachedMax, int currentPage, int totalCount, bool isLoadingMore, int generatedCount, DateTime? lastGeneratedAt, String? exportPath, bool isExporting
});




}
/// @nodoc
class _$CartonCodesStateCopyWithImpl<$Res>
    implements $CartonCodesStateCopyWith<$Res> {
  _$CartonCodesStateCopyWithImpl(this._self, this._then);

  final CartonCodesState _self;
  final $Res Function(CartonCodesState) _then;

/// Create a copy of CartonCodesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? cartonCodes = null,Object? filteredCartonCodes = null,Object? selectedCartonCodeIds = null,Object? searchQuery = null,Object? filterStatus = freezed,Object? filterBundleCode = freezed,Object? filterStartDate = freezed,Object? filterEndDate = freezed,Object? filterCartonType = freezed,Object? filterCondition = freezed,Object? filterCodeFormat = null,Object? errorMessage = freezed,Object? hasReachedMax = null,Object? currentPage = null,Object? totalCount = null,Object? isLoadingMore = null,Object? generatedCount = null,Object? lastGeneratedAt = freezed,Object? exportPath = freezed,Object? isExporting = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CartonCodesStatus,cartonCodes: null == cartonCodes ? _self.cartonCodes : cartonCodes // ignore: cast_nullable_to_non_nullable
as List<CartonCodeModel>,filteredCartonCodes: null == filteredCartonCodes ? _self.filteredCartonCodes : filteredCartonCodes // ignore: cast_nullable_to_non_nullable
as List<CartonCodeModel>,selectedCartonCodeIds: null == selectedCartonCodeIds ? _self.selectedCartonCodeIds : selectedCartonCodeIds // ignore: cast_nullable_to_non_nullable
as Set<String>,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,filterStatus: freezed == filterStatus ? _self.filterStatus : filterStatus // ignore: cast_nullable_to_non_nullable
as CodeStatus?,filterBundleCode: freezed == filterBundleCode ? _self.filterBundleCode : filterBundleCode // ignore: cast_nullable_to_non_nullable
as String?,filterStartDate: freezed == filterStartDate ? _self.filterStartDate : filterStartDate // ignore: cast_nullable_to_non_nullable
as DateTime?,filterEndDate: freezed == filterEndDate ? _self.filterEndDate : filterEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,filterCartonType: freezed == filterCartonType ? _self.filterCartonType : filterCartonType // ignore: cast_nullable_to_non_nullable
as String?,filterCondition: freezed == filterCondition ? _self.filterCondition : filterCondition // ignore: cast_nullable_to_non_nullable
as String?,filterCodeFormat: null == filterCodeFormat ? _self.filterCodeFormat : filterCodeFormat // ignore: cast_nullable_to_non_nullable
as String,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,hasReachedMax: null == hasReachedMax ? _self.hasReachedMax : hasReachedMax // ignore: cast_nullable_to_non_nullable
as bool,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,generatedCount: null == generatedCount ? _self.generatedCount : generatedCount // ignore: cast_nullable_to_non_nullable
as int,lastGeneratedAt: freezed == lastGeneratedAt ? _self.lastGeneratedAt : lastGeneratedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,exportPath: freezed == exportPath ? _self.exportPath : exportPath // ignore: cast_nullable_to_non_nullable
as String?,isExporting: null == isExporting ? _self.isExporting : isExporting // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CartonCodesState].
extension CartonCodesStatePatterns on CartonCodesState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CartonCodesState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CartonCodesState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CartonCodesState value)  $default,){
final _that = this;
switch (_that) {
case _CartonCodesState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CartonCodesState value)?  $default,){
final _that = this;
switch (_that) {
case _CartonCodesState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CartonCodesStatus status,  List<CartonCodeModel> cartonCodes,  List<CartonCodeModel> filteredCartonCodes,  Set<String> selectedCartonCodeIds,  String searchQuery,  CodeStatus? filterStatus,  String? filterBundleCode,  DateTime? filterStartDate,  DateTime? filterEndDate,  String? filterCartonType,  String? filterCondition,  String filterCodeFormat,  String? errorMessage,  bool hasReachedMax,  int currentPage,  int totalCount,  bool isLoadingMore,  int generatedCount,  DateTime? lastGeneratedAt,  String? exportPath,  bool isExporting)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CartonCodesState() when $default != null:
return $default(_that.status,_that.cartonCodes,_that.filteredCartonCodes,_that.selectedCartonCodeIds,_that.searchQuery,_that.filterStatus,_that.filterBundleCode,_that.filterStartDate,_that.filterEndDate,_that.filterCartonType,_that.filterCondition,_that.filterCodeFormat,_that.errorMessage,_that.hasReachedMax,_that.currentPage,_that.totalCount,_that.isLoadingMore,_that.generatedCount,_that.lastGeneratedAt,_that.exportPath,_that.isExporting);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CartonCodesStatus status,  List<CartonCodeModel> cartonCodes,  List<CartonCodeModel> filteredCartonCodes,  Set<String> selectedCartonCodeIds,  String searchQuery,  CodeStatus? filterStatus,  String? filterBundleCode,  DateTime? filterStartDate,  DateTime? filterEndDate,  String? filterCartonType,  String? filterCondition,  String filterCodeFormat,  String? errorMessage,  bool hasReachedMax,  int currentPage,  int totalCount,  bool isLoadingMore,  int generatedCount,  DateTime? lastGeneratedAt,  String? exportPath,  bool isExporting)  $default,) {final _that = this;
switch (_that) {
case _CartonCodesState():
return $default(_that.status,_that.cartonCodes,_that.filteredCartonCodes,_that.selectedCartonCodeIds,_that.searchQuery,_that.filterStatus,_that.filterBundleCode,_that.filterStartDate,_that.filterEndDate,_that.filterCartonType,_that.filterCondition,_that.filterCodeFormat,_that.errorMessage,_that.hasReachedMax,_that.currentPage,_that.totalCount,_that.isLoadingMore,_that.generatedCount,_that.lastGeneratedAt,_that.exportPath,_that.isExporting);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CartonCodesStatus status,  List<CartonCodeModel> cartonCodes,  List<CartonCodeModel> filteredCartonCodes,  Set<String> selectedCartonCodeIds,  String searchQuery,  CodeStatus? filterStatus,  String? filterBundleCode,  DateTime? filterStartDate,  DateTime? filterEndDate,  String? filterCartonType,  String? filterCondition,  String filterCodeFormat,  String? errorMessage,  bool hasReachedMax,  int currentPage,  int totalCount,  bool isLoadingMore,  int generatedCount,  DateTime? lastGeneratedAt,  String? exportPath,  bool isExporting)?  $default,) {final _that = this;
switch (_that) {
case _CartonCodesState() when $default != null:
return $default(_that.status,_that.cartonCodes,_that.filteredCartonCodes,_that.selectedCartonCodeIds,_that.searchQuery,_that.filterStatus,_that.filterBundleCode,_that.filterStartDate,_that.filterEndDate,_that.filterCartonType,_that.filterCondition,_that.filterCodeFormat,_that.errorMessage,_that.hasReachedMax,_that.currentPage,_that.totalCount,_that.isLoadingMore,_that.generatedCount,_that.lastGeneratedAt,_that.exportPath,_that.isExporting);case _:
  return null;

}
}

}

/// @nodoc


class _CartonCodesState extends CartonCodesState {
  const _CartonCodesState({this.status = CartonCodesStatus.initial, final  List<CartonCodeModel> cartonCodes = const [], final  List<CartonCodeModel> filteredCartonCodes = const [], final  Set<String> selectedCartonCodeIds = const {}, this.searchQuery = '', this.filterStatus, this.filterBundleCode, this.filterStartDate, this.filterEndDate, this.filterCartonType, this.filterCondition, this.filterCodeFormat = 'qr', this.errorMessage, this.hasReachedMax = false, this.currentPage = 1, this.totalCount = 0, this.isLoadingMore = false, this.generatedCount = 0, this.lastGeneratedAt, this.exportPath, this.isExporting = false}): _cartonCodes = cartonCodes,_filteredCartonCodes = filteredCartonCodes,_selectedCartonCodeIds = selectedCartonCodeIds,super._();
  

@override@JsonKey() final  CartonCodesStatus status;
 final  List<CartonCodeModel> _cartonCodes;
@override@JsonKey() List<CartonCodeModel> get cartonCodes {
  if (_cartonCodes is EqualUnmodifiableListView) return _cartonCodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cartonCodes);
}

 final  List<CartonCodeModel> _filteredCartonCodes;
@override@JsonKey() List<CartonCodeModel> get filteredCartonCodes {
  if (_filteredCartonCodes is EqualUnmodifiableListView) return _filteredCartonCodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_filteredCartonCodes);
}

 final  Set<String> _selectedCartonCodeIds;
@override@JsonKey() Set<String> get selectedCartonCodeIds {
  if (_selectedCartonCodeIds is EqualUnmodifiableSetView) return _selectedCartonCodeIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_selectedCartonCodeIds);
}

@override@JsonKey() final  String searchQuery;
@override final  CodeStatus? filterStatus;
@override final  String? filterBundleCode;
@override final  DateTime? filterStartDate;
@override final  DateTime? filterEndDate;
@override final  String? filterCartonType;
@override final  String? filterCondition;
@override@JsonKey() final  String filterCodeFormat;
@override final  String? errorMessage;
@override@JsonKey() final  bool hasReachedMax;
@override@JsonKey() final  int currentPage;
@override@JsonKey() final  int totalCount;
@override@JsonKey() final  bool isLoadingMore;
@override@JsonKey() final  int generatedCount;
@override final  DateTime? lastGeneratedAt;
@override final  String? exportPath;
@override@JsonKey() final  bool isExporting;

/// Create a copy of CartonCodesState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CartonCodesStateCopyWith<_CartonCodesState> get copyWith => __$CartonCodesStateCopyWithImpl<_CartonCodesState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CartonCodesState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._cartonCodes, _cartonCodes)&&const DeepCollectionEquality().equals(other._filteredCartonCodes, _filteredCartonCodes)&&const DeepCollectionEquality().equals(other._selectedCartonCodeIds, _selectedCartonCodeIds)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.filterStatus, filterStatus) || other.filterStatus == filterStatus)&&(identical(other.filterBundleCode, filterBundleCode) || other.filterBundleCode == filterBundleCode)&&(identical(other.filterStartDate, filterStartDate) || other.filterStartDate == filterStartDate)&&(identical(other.filterEndDate, filterEndDate) || other.filterEndDate == filterEndDate)&&(identical(other.filterCartonType, filterCartonType) || other.filterCartonType == filterCartonType)&&(identical(other.filterCondition, filterCondition) || other.filterCondition == filterCondition)&&(identical(other.filterCodeFormat, filterCodeFormat) || other.filterCodeFormat == filterCodeFormat)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.hasReachedMax, hasReachedMax) || other.hasReachedMax == hasReachedMax)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.generatedCount, generatedCount) || other.generatedCount == generatedCount)&&(identical(other.lastGeneratedAt, lastGeneratedAt) || other.lastGeneratedAt == lastGeneratedAt)&&(identical(other.exportPath, exportPath) || other.exportPath == exportPath)&&(identical(other.isExporting, isExporting) || other.isExporting == isExporting));
}


@override
int get hashCode => Object.hashAll([runtimeType,status,const DeepCollectionEquality().hash(_cartonCodes),const DeepCollectionEquality().hash(_filteredCartonCodes),const DeepCollectionEquality().hash(_selectedCartonCodeIds),searchQuery,filterStatus,filterBundleCode,filterStartDate,filterEndDate,filterCartonType,filterCondition,filterCodeFormat,errorMessage,hasReachedMax,currentPage,totalCount,isLoadingMore,generatedCount,lastGeneratedAt,exportPath,isExporting]);

@override
String toString() {
  return 'CartonCodesState(status: $status, cartonCodes: $cartonCodes, filteredCartonCodes: $filteredCartonCodes, selectedCartonCodeIds: $selectedCartonCodeIds, searchQuery: $searchQuery, filterStatus: $filterStatus, filterBundleCode: $filterBundleCode, filterStartDate: $filterStartDate, filterEndDate: $filterEndDate, filterCartonType: $filterCartonType, filterCondition: $filterCondition, filterCodeFormat: $filterCodeFormat, errorMessage: $errorMessage, hasReachedMax: $hasReachedMax, currentPage: $currentPage, totalCount: $totalCount, isLoadingMore: $isLoadingMore, generatedCount: $generatedCount, lastGeneratedAt: $lastGeneratedAt, exportPath: $exportPath, isExporting: $isExporting)';
}


}

/// @nodoc
abstract mixin class _$CartonCodesStateCopyWith<$Res> implements $CartonCodesStateCopyWith<$Res> {
  factory _$CartonCodesStateCopyWith(_CartonCodesState value, $Res Function(_CartonCodesState) _then) = __$CartonCodesStateCopyWithImpl;
@override @useResult
$Res call({
 CartonCodesStatus status, List<CartonCodeModel> cartonCodes, List<CartonCodeModel> filteredCartonCodes, Set<String> selectedCartonCodeIds, String searchQuery, CodeStatus? filterStatus, String? filterBundleCode, DateTime? filterStartDate, DateTime? filterEndDate, String? filterCartonType, String? filterCondition, String filterCodeFormat, String? errorMessage, bool hasReachedMax, int currentPage, int totalCount, bool isLoadingMore, int generatedCount, DateTime? lastGeneratedAt, String? exportPath, bool isExporting
});




}
/// @nodoc
class __$CartonCodesStateCopyWithImpl<$Res>
    implements _$CartonCodesStateCopyWith<$Res> {
  __$CartonCodesStateCopyWithImpl(this._self, this._then);

  final _CartonCodesState _self;
  final $Res Function(_CartonCodesState) _then;

/// Create a copy of CartonCodesState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? cartonCodes = null,Object? filteredCartonCodes = null,Object? selectedCartonCodeIds = null,Object? searchQuery = null,Object? filterStatus = freezed,Object? filterBundleCode = freezed,Object? filterStartDate = freezed,Object? filterEndDate = freezed,Object? filterCartonType = freezed,Object? filterCondition = freezed,Object? filterCodeFormat = null,Object? errorMessage = freezed,Object? hasReachedMax = null,Object? currentPage = null,Object? totalCount = null,Object? isLoadingMore = null,Object? generatedCount = null,Object? lastGeneratedAt = freezed,Object? exportPath = freezed,Object? isExporting = null,}) {
  return _then(_CartonCodesState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CartonCodesStatus,cartonCodes: null == cartonCodes ? _self._cartonCodes : cartonCodes // ignore: cast_nullable_to_non_nullable
as List<CartonCodeModel>,filteredCartonCodes: null == filteredCartonCodes ? _self._filteredCartonCodes : filteredCartonCodes // ignore: cast_nullable_to_non_nullable
as List<CartonCodeModel>,selectedCartonCodeIds: null == selectedCartonCodeIds ? _self._selectedCartonCodeIds : selectedCartonCodeIds // ignore: cast_nullable_to_non_nullable
as Set<String>,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,filterStatus: freezed == filterStatus ? _self.filterStatus : filterStatus // ignore: cast_nullable_to_non_nullable
as CodeStatus?,filterBundleCode: freezed == filterBundleCode ? _self.filterBundleCode : filterBundleCode // ignore: cast_nullable_to_non_nullable
as String?,filterStartDate: freezed == filterStartDate ? _self.filterStartDate : filterStartDate // ignore: cast_nullable_to_non_nullable
as DateTime?,filterEndDate: freezed == filterEndDate ? _self.filterEndDate : filterEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,filterCartonType: freezed == filterCartonType ? _self.filterCartonType : filterCartonType // ignore: cast_nullable_to_non_nullable
as String?,filterCondition: freezed == filterCondition ? _self.filterCondition : filterCondition // ignore: cast_nullable_to_non_nullable
as String?,filterCodeFormat: null == filterCodeFormat ? _self.filterCodeFormat : filterCodeFormat // ignore: cast_nullable_to_non_nullable
as String,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,hasReachedMax: null == hasReachedMax ? _self.hasReachedMax : hasReachedMax // ignore: cast_nullable_to_non_nullable
as bool,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,generatedCount: null == generatedCount ? _self.generatedCount : generatedCount // ignore: cast_nullable_to_non_nullable
as int,lastGeneratedAt: freezed == lastGeneratedAt ? _self.lastGeneratedAt : lastGeneratedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,exportPath: freezed == exportPath ? _self.exportPath : exportPath // ignore: cast_nullable_to_non_nullable
as String?,isExporting: null == isExporting ? _self.isExporting : isExporting // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

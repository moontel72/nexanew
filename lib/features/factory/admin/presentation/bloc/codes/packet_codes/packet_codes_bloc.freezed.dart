// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'packet_codes_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PacketCodesEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PacketCodesEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PacketCodesEvent()';
}


}

/// @nodoc
class $PacketCodesEventCopyWith<$Res>  {
$PacketCodesEventCopyWith(PacketCodesEvent _, $Res Function(PacketCodesEvent) __);
}


/// Adds pattern-matching-related methods to [PacketCodesEvent].
extension PacketCodesEventPatterns on PacketCodesEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LoadPacketCodes value)?  load,TResult Function( GeneratePacketCodes value)?  generate,TResult Function( DeletePacketCode value)?  delete,TResult Function( DeletePacketCodeBatch value)?  deleteBatch,TResult Function( LinkPacketCodeToProduct value)?  linkToProduct,TResult Function( PublishPacketCode value)?  publish,TResult Function( DeactivatePacketCode value)?  deactivate,TResult Function( SearchPacketCodes value)?  search,TResult Function( FilterPacketCodes value)?  filter,TResult Function( ExportPacketCodes value)?  export,TResult Function( SelectPacketCode value)?  select,TResult Function( ClearSelection value)?  clearSelection,TResult Function( RefreshPacketCodes value)?  refresh,TResult Function( SealPacket value)?  seal,TResult Function( UpdatePacketInspection value)?  updateInspection,TResult Function( UpdatePacketProperties value)?  updateProperties,TResult Function( AddTamperEvidence value)?  addTamperEvidence,TResult Function( AddChildSafetyFeatures value)?  addChildSafetyFeatures,TResult Function( AddInstructions value)?  addInstructions,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LoadPacketCodes() when load != null:
return load(_that);case GeneratePacketCodes() when generate != null:
return generate(_that);case DeletePacketCode() when delete != null:
return delete(_that);case DeletePacketCodeBatch() when deleteBatch != null:
return deleteBatch(_that);case LinkPacketCodeToProduct() when linkToProduct != null:
return linkToProduct(_that);case PublishPacketCode() when publish != null:
return publish(_that);case DeactivatePacketCode() when deactivate != null:
return deactivate(_that);case SearchPacketCodes() when search != null:
return search(_that);case FilterPacketCodes() when filter != null:
return filter(_that);case ExportPacketCodes() when export != null:
return export(_that);case SelectPacketCode() when select != null:
return select(_that);case ClearSelection() when clearSelection != null:
return clearSelection(_that);case RefreshPacketCodes() when refresh != null:
return refresh(_that);case SealPacket() when seal != null:
return seal(_that);case UpdatePacketInspection() when updateInspection != null:
return updateInspection(_that);case UpdatePacketProperties() when updateProperties != null:
return updateProperties(_that);case AddTamperEvidence() when addTamperEvidence != null:
return addTamperEvidence(_that);case AddChildSafetyFeatures() when addChildSafetyFeatures != null:
return addChildSafetyFeatures(_that);case AddInstructions() when addInstructions != null:
return addInstructions(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LoadPacketCodes value)  load,required TResult Function( GeneratePacketCodes value)  generate,required TResult Function( DeletePacketCode value)  delete,required TResult Function( DeletePacketCodeBatch value)  deleteBatch,required TResult Function( LinkPacketCodeToProduct value)  linkToProduct,required TResult Function( PublishPacketCode value)  publish,required TResult Function( DeactivatePacketCode value)  deactivate,required TResult Function( SearchPacketCodes value)  search,required TResult Function( FilterPacketCodes value)  filter,required TResult Function( ExportPacketCodes value)  export,required TResult Function( SelectPacketCode value)  select,required TResult Function( ClearSelection value)  clearSelection,required TResult Function( RefreshPacketCodes value)  refresh,required TResult Function( SealPacket value)  seal,required TResult Function( UpdatePacketInspection value)  updateInspection,required TResult Function( UpdatePacketProperties value)  updateProperties,required TResult Function( AddTamperEvidence value)  addTamperEvidence,required TResult Function( AddChildSafetyFeatures value)  addChildSafetyFeatures,required TResult Function( AddInstructions value)  addInstructions,}){
final _that = this;
switch (_that) {
case LoadPacketCodes():
return load(_that);case GeneratePacketCodes():
return generate(_that);case DeletePacketCode():
return delete(_that);case DeletePacketCodeBatch():
return deleteBatch(_that);case LinkPacketCodeToProduct():
return linkToProduct(_that);case PublishPacketCode():
return publish(_that);case DeactivatePacketCode():
return deactivate(_that);case SearchPacketCodes():
return search(_that);case FilterPacketCodes():
return filter(_that);case ExportPacketCodes():
return export(_that);case SelectPacketCode():
return select(_that);case ClearSelection():
return clearSelection(_that);case RefreshPacketCodes():
return refresh(_that);case SealPacket():
return seal(_that);case UpdatePacketInspection():
return updateInspection(_that);case UpdatePacketProperties():
return updateProperties(_that);case AddTamperEvidence():
return addTamperEvidence(_that);case AddChildSafetyFeatures():
return addChildSafetyFeatures(_that);case AddInstructions():
return addInstructions(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LoadPacketCodes value)?  load,TResult? Function( GeneratePacketCodes value)?  generate,TResult? Function( DeletePacketCode value)?  delete,TResult? Function( DeletePacketCodeBatch value)?  deleteBatch,TResult? Function( LinkPacketCodeToProduct value)?  linkToProduct,TResult? Function( PublishPacketCode value)?  publish,TResult? Function( DeactivatePacketCode value)?  deactivate,TResult? Function( SearchPacketCodes value)?  search,TResult? Function( FilterPacketCodes value)?  filter,TResult? Function( ExportPacketCodes value)?  export,TResult? Function( SelectPacketCode value)?  select,TResult? Function( ClearSelection value)?  clearSelection,TResult? Function( RefreshPacketCodes value)?  refresh,TResult? Function( SealPacket value)?  seal,TResult? Function( UpdatePacketInspection value)?  updateInspection,TResult? Function( UpdatePacketProperties value)?  updateProperties,TResult? Function( AddTamperEvidence value)?  addTamperEvidence,TResult? Function( AddChildSafetyFeatures value)?  addChildSafetyFeatures,TResult? Function( AddInstructions value)?  addInstructions,}){
final _that = this;
switch (_that) {
case LoadPacketCodes() when load != null:
return load(_that);case GeneratePacketCodes() when generate != null:
return generate(_that);case DeletePacketCode() when delete != null:
return delete(_that);case DeletePacketCodeBatch() when deleteBatch != null:
return deleteBatch(_that);case LinkPacketCodeToProduct() when linkToProduct != null:
return linkToProduct(_that);case PublishPacketCode() when publish != null:
return publish(_that);case DeactivatePacketCode() when deactivate != null:
return deactivate(_that);case SearchPacketCodes() when search != null:
return search(_that);case FilterPacketCodes() when filter != null:
return filter(_that);case ExportPacketCodes() when export != null:
return export(_that);case SelectPacketCode() when select != null:
return select(_that);case ClearSelection() when clearSelection != null:
return clearSelection(_that);case RefreshPacketCodes() when refresh != null:
return refresh(_that);case SealPacket() when seal != null:
return seal(_that);case UpdatePacketInspection() when updateInspection != null:
return updateInspection(_that);case UpdatePacketProperties() when updateProperties != null:
return updateProperties(_that);case AddTamperEvidence() when addTamperEvidence != null:
return addTamperEvidence(_that);case AddChildSafetyFeatures() when addChildSafetyFeatures != null:
return addChildSafetyFeatures(_that);case AddInstructions() when addInstructions != null:
return addInstructions(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  load,TResult Function( PacketCodeGenerationRequest request)?  generate,TResult Function( String packetCodeId)?  delete,TResult Function( List<String> packetCodeIds)?  deleteBatch,TResult Function( String packetCodeId,  String productId,  String productBatchNumber,  DateTime? manufacturingDate,  DateTime? expiryDate,  int? warrantyMonths)?  linkToProduct,TResult Function( String packetCodeId)?  publish,TResult Function( String packetCodeId,  String reason)?  deactivate,TResult Function( String query)?  search,TResult Function( CodeStatus? status,  String? cartonCode,  DateTime? startDate,  DateTime? endDate,  String? packetType,  String? condition)?  filter,TResult Function( List<String> packetCodeIds,  String format)?  export,TResult Function( String packetCodeId,  bool isSelected)?  select,TResult Function()?  clearSelection,TResult Function()?  refresh,TResult Function( String packetCodeId,  String sealedBy,  String? sealingMethod)?  seal,TResult Function( String packetCodeId,  String condition,  String inspectionNotes,  bool hasTamperEvidence,  bool hasChildSafety)?  updateInspection,TResult Function( String packetCodeId,  double? weight,  String? dimensions,  String? packetType,  String? material,  String? sealingMethod)?  updateProperties,TResult Function( String packetCodeId)?  addTamperEvidence,TResult Function( String packetCodeId)?  addChildSafetyFeatures,TResult Function( String packetCodeId)?  addInstructions,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LoadPacketCodes() when load != null:
return load();case GeneratePacketCodes() when generate != null:
return generate(_that.request);case DeletePacketCode() when delete != null:
return delete(_that.packetCodeId);case DeletePacketCodeBatch() when deleteBatch != null:
return deleteBatch(_that.packetCodeIds);case LinkPacketCodeToProduct() when linkToProduct != null:
return linkToProduct(_that.packetCodeId,_that.productId,_that.productBatchNumber,_that.manufacturingDate,_that.expiryDate,_that.warrantyMonths);case PublishPacketCode() when publish != null:
return publish(_that.packetCodeId);case DeactivatePacketCode() when deactivate != null:
return deactivate(_that.packetCodeId,_that.reason);case SearchPacketCodes() when search != null:
return search(_that.query);case FilterPacketCodes() when filter != null:
return filter(_that.status,_that.cartonCode,_that.startDate,_that.endDate,_that.packetType,_that.condition);case ExportPacketCodes() when export != null:
return export(_that.packetCodeIds,_that.format);case SelectPacketCode() when select != null:
return select(_that.packetCodeId,_that.isSelected);case ClearSelection() when clearSelection != null:
return clearSelection();case RefreshPacketCodes() when refresh != null:
return refresh();case SealPacket() when seal != null:
return seal(_that.packetCodeId,_that.sealedBy,_that.sealingMethod);case UpdatePacketInspection() when updateInspection != null:
return updateInspection(_that.packetCodeId,_that.condition,_that.inspectionNotes,_that.hasTamperEvidence,_that.hasChildSafety);case UpdatePacketProperties() when updateProperties != null:
return updateProperties(_that.packetCodeId,_that.weight,_that.dimensions,_that.packetType,_that.material,_that.sealingMethod);case AddTamperEvidence() when addTamperEvidence != null:
return addTamperEvidence(_that.packetCodeId);case AddChildSafetyFeatures() when addChildSafetyFeatures != null:
return addChildSafetyFeatures(_that.packetCodeId);case AddInstructions() when addInstructions != null:
return addInstructions(_that.packetCodeId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  load,required TResult Function( PacketCodeGenerationRequest request)  generate,required TResult Function( String packetCodeId)  delete,required TResult Function( List<String> packetCodeIds)  deleteBatch,required TResult Function( String packetCodeId,  String productId,  String productBatchNumber,  DateTime? manufacturingDate,  DateTime? expiryDate,  int? warrantyMonths)  linkToProduct,required TResult Function( String packetCodeId)  publish,required TResult Function( String packetCodeId,  String reason)  deactivate,required TResult Function( String query)  search,required TResult Function( CodeStatus? status,  String? cartonCode,  DateTime? startDate,  DateTime? endDate,  String? packetType,  String? condition)  filter,required TResult Function( List<String> packetCodeIds,  String format)  export,required TResult Function( String packetCodeId,  bool isSelected)  select,required TResult Function()  clearSelection,required TResult Function()  refresh,required TResult Function( String packetCodeId,  String sealedBy,  String? sealingMethod)  seal,required TResult Function( String packetCodeId,  String condition,  String inspectionNotes,  bool hasTamperEvidence,  bool hasChildSafety)  updateInspection,required TResult Function( String packetCodeId,  double? weight,  String? dimensions,  String? packetType,  String? material,  String? sealingMethod)  updateProperties,required TResult Function( String packetCodeId)  addTamperEvidence,required TResult Function( String packetCodeId)  addChildSafetyFeatures,required TResult Function( String packetCodeId)  addInstructions,}) {final _that = this;
switch (_that) {
case LoadPacketCodes():
return load();case GeneratePacketCodes():
return generate(_that.request);case DeletePacketCode():
return delete(_that.packetCodeId);case DeletePacketCodeBatch():
return deleteBatch(_that.packetCodeIds);case LinkPacketCodeToProduct():
return linkToProduct(_that.packetCodeId,_that.productId,_that.productBatchNumber,_that.manufacturingDate,_that.expiryDate,_that.warrantyMonths);case PublishPacketCode():
return publish(_that.packetCodeId);case DeactivatePacketCode():
return deactivate(_that.packetCodeId,_that.reason);case SearchPacketCodes():
return search(_that.query);case FilterPacketCodes():
return filter(_that.status,_that.cartonCode,_that.startDate,_that.endDate,_that.packetType,_that.condition);case ExportPacketCodes():
return export(_that.packetCodeIds,_that.format);case SelectPacketCode():
return select(_that.packetCodeId,_that.isSelected);case ClearSelection():
return clearSelection();case RefreshPacketCodes():
return refresh();case SealPacket():
return seal(_that.packetCodeId,_that.sealedBy,_that.sealingMethod);case UpdatePacketInspection():
return updateInspection(_that.packetCodeId,_that.condition,_that.inspectionNotes,_that.hasTamperEvidence,_that.hasChildSafety);case UpdatePacketProperties():
return updateProperties(_that.packetCodeId,_that.weight,_that.dimensions,_that.packetType,_that.material,_that.sealingMethod);case AddTamperEvidence():
return addTamperEvidence(_that.packetCodeId);case AddChildSafetyFeatures():
return addChildSafetyFeatures(_that.packetCodeId);case AddInstructions():
return addInstructions(_that.packetCodeId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  load,TResult? Function( PacketCodeGenerationRequest request)?  generate,TResult? Function( String packetCodeId)?  delete,TResult? Function( List<String> packetCodeIds)?  deleteBatch,TResult? Function( String packetCodeId,  String productId,  String productBatchNumber,  DateTime? manufacturingDate,  DateTime? expiryDate,  int? warrantyMonths)?  linkToProduct,TResult? Function( String packetCodeId)?  publish,TResult? Function( String packetCodeId,  String reason)?  deactivate,TResult? Function( String query)?  search,TResult? Function( CodeStatus? status,  String? cartonCode,  DateTime? startDate,  DateTime? endDate,  String? packetType,  String? condition)?  filter,TResult? Function( List<String> packetCodeIds,  String format)?  export,TResult? Function( String packetCodeId,  bool isSelected)?  select,TResult? Function()?  clearSelection,TResult? Function()?  refresh,TResult? Function( String packetCodeId,  String sealedBy,  String? sealingMethod)?  seal,TResult? Function( String packetCodeId,  String condition,  String inspectionNotes,  bool hasTamperEvidence,  bool hasChildSafety)?  updateInspection,TResult? Function( String packetCodeId,  double? weight,  String? dimensions,  String? packetType,  String? material,  String? sealingMethod)?  updateProperties,TResult? Function( String packetCodeId)?  addTamperEvidence,TResult? Function( String packetCodeId)?  addChildSafetyFeatures,TResult? Function( String packetCodeId)?  addInstructions,}) {final _that = this;
switch (_that) {
case LoadPacketCodes() when load != null:
return load();case GeneratePacketCodes() when generate != null:
return generate(_that.request);case DeletePacketCode() when delete != null:
return delete(_that.packetCodeId);case DeletePacketCodeBatch() when deleteBatch != null:
return deleteBatch(_that.packetCodeIds);case LinkPacketCodeToProduct() when linkToProduct != null:
return linkToProduct(_that.packetCodeId,_that.productId,_that.productBatchNumber,_that.manufacturingDate,_that.expiryDate,_that.warrantyMonths);case PublishPacketCode() when publish != null:
return publish(_that.packetCodeId);case DeactivatePacketCode() when deactivate != null:
return deactivate(_that.packetCodeId,_that.reason);case SearchPacketCodes() when search != null:
return search(_that.query);case FilterPacketCodes() when filter != null:
return filter(_that.status,_that.cartonCode,_that.startDate,_that.endDate,_that.packetType,_that.condition);case ExportPacketCodes() when export != null:
return export(_that.packetCodeIds,_that.format);case SelectPacketCode() when select != null:
return select(_that.packetCodeId,_that.isSelected);case ClearSelection() when clearSelection != null:
return clearSelection();case RefreshPacketCodes() when refresh != null:
return refresh();case SealPacket() when seal != null:
return seal(_that.packetCodeId,_that.sealedBy,_that.sealingMethod);case UpdatePacketInspection() when updateInspection != null:
return updateInspection(_that.packetCodeId,_that.condition,_that.inspectionNotes,_that.hasTamperEvidence,_that.hasChildSafety);case UpdatePacketProperties() when updateProperties != null:
return updateProperties(_that.packetCodeId,_that.weight,_that.dimensions,_that.packetType,_that.material,_that.sealingMethod);case AddTamperEvidence() when addTamperEvidence != null:
return addTamperEvidence(_that.packetCodeId);case AddChildSafetyFeatures() when addChildSafetyFeatures != null:
return addChildSafetyFeatures(_that.packetCodeId);case AddInstructions() when addInstructions != null:
return addInstructions(_that.packetCodeId);case _:
  return null;

}
}

}

/// @nodoc


class LoadPacketCodes implements PacketCodesEvent {
  const LoadPacketCodes();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoadPacketCodes);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PacketCodesEvent.load()';
}


}




/// @nodoc


class GeneratePacketCodes implements PacketCodesEvent {
  const GeneratePacketCodes(this.request);
  

 final  PacketCodeGenerationRequest request;

/// Create a copy of PacketCodesEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GeneratePacketCodesCopyWith<GeneratePacketCodes> get copyWith => _$GeneratePacketCodesCopyWithImpl<GeneratePacketCodes>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GeneratePacketCodes&&(identical(other.request, request) || other.request == request));
}


@override
int get hashCode => Object.hash(runtimeType,request);

@override
String toString() {
  return 'PacketCodesEvent.generate(request: $request)';
}


}

/// @nodoc
abstract mixin class $GeneratePacketCodesCopyWith<$Res> implements $PacketCodesEventCopyWith<$Res> {
  factory $GeneratePacketCodesCopyWith(GeneratePacketCodes value, $Res Function(GeneratePacketCodes) _then) = _$GeneratePacketCodesCopyWithImpl;
@useResult
$Res call({
 PacketCodeGenerationRequest request
});


$PacketCodeGenerationRequestCopyWith<$Res> get request;

}
/// @nodoc
class _$GeneratePacketCodesCopyWithImpl<$Res>
    implements $GeneratePacketCodesCopyWith<$Res> {
  _$GeneratePacketCodesCopyWithImpl(this._self, this._then);

  final GeneratePacketCodes _self;
  final $Res Function(GeneratePacketCodes) _then;

/// Create a copy of PacketCodesEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? request = null,}) {
  return _then(GeneratePacketCodes(
null == request ? _self.request : request // ignore: cast_nullable_to_non_nullable
as PacketCodeGenerationRequest,
  ));
}

/// Create a copy of PacketCodesEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PacketCodeGenerationRequestCopyWith<$Res> get request {
  
  return $PacketCodeGenerationRequestCopyWith<$Res>(_self.request, (value) {
    return _then(_self.copyWith(request: value));
  });
}
}

/// @nodoc


class DeletePacketCode implements PacketCodesEvent {
  const DeletePacketCode(this.packetCodeId);
  

 final  String packetCodeId;

/// Create a copy of PacketCodesEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeletePacketCodeCopyWith<DeletePacketCode> get copyWith => _$DeletePacketCodeCopyWithImpl<DeletePacketCode>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeletePacketCode&&(identical(other.packetCodeId, packetCodeId) || other.packetCodeId == packetCodeId));
}


@override
int get hashCode => Object.hash(runtimeType,packetCodeId);

@override
String toString() {
  return 'PacketCodesEvent.delete(packetCodeId: $packetCodeId)';
}


}

/// @nodoc
abstract mixin class $DeletePacketCodeCopyWith<$Res> implements $PacketCodesEventCopyWith<$Res> {
  factory $DeletePacketCodeCopyWith(DeletePacketCode value, $Res Function(DeletePacketCode) _then) = _$DeletePacketCodeCopyWithImpl;
@useResult
$Res call({
 String packetCodeId
});




}
/// @nodoc
class _$DeletePacketCodeCopyWithImpl<$Res>
    implements $DeletePacketCodeCopyWith<$Res> {
  _$DeletePacketCodeCopyWithImpl(this._self, this._then);

  final DeletePacketCode _self;
  final $Res Function(DeletePacketCode) _then;

/// Create a copy of PacketCodesEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? packetCodeId = null,}) {
  return _then(DeletePacketCode(
null == packetCodeId ? _self.packetCodeId : packetCodeId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class DeletePacketCodeBatch implements PacketCodesEvent {
  const DeletePacketCodeBatch(final  List<String> packetCodeIds): _packetCodeIds = packetCodeIds;
  

 final  List<String> _packetCodeIds;
 List<String> get packetCodeIds {
  if (_packetCodeIds is EqualUnmodifiableListView) return _packetCodeIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_packetCodeIds);
}


/// Create a copy of PacketCodesEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeletePacketCodeBatchCopyWith<DeletePacketCodeBatch> get copyWith => _$DeletePacketCodeBatchCopyWithImpl<DeletePacketCodeBatch>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeletePacketCodeBatch&&const DeepCollectionEquality().equals(other._packetCodeIds, _packetCodeIds));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_packetCodeIds));

@override
String toString() {
  return 'PacketCodesEvent.deleteBatch(packetCodeIds: $packetCodeIds)';
}


}

/// @nodoc
abstract mixin class $DeletePacketCodeBatchCopyWith<$Res> implements $PacketCodesEventCopyWith<$Res> {
  factory $DeletePacketCodeBatchCopyWith(DeletePacketCodeBatch value, $Res Function(DeletePacketCodeBatch) _then) = _$DeletePacketCodeBatchCopyWithImpl;
@useResult
$Res call({
 List<String> packetCodeIds
});




}
/// @nodoc
class _$DeletePacketCodeBatchCopyWithImpl<$Res>
    implements $DeletePacketCodeBatchCopyWith<$Res> {
  _$DeletePacketCodeBatchCopyWithImpl(this._self, this._then);

  final DeletePacketCodeBatch _self;
  final $Res Function(DeletePacketCodeBatch) _then;

/// Create a copy of PacketCodesEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? packetCodeIds = null,}) {
  return _then(DeletePacketCodeBatch(
null == packetCodeIds ? _self._packetCodeIds : packetCodeIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class LinkPacketCodeToProduct implements PacketCodesEvent {
  const LinkPacketCodeToProduct({required this.packetCodeId, required this.productId, required this.productBatchNumber, this.manufacturingDate, this.expiryDate, this.warrantyMonths});
  

 final  String packetCodeId;
 final  String productId;
 final  String productBatchNumber;
 final  DateTime? manufacturingDate;
 final  DateTime? expiryDate;
 final  int? warrantyMonths;

/// Create a copy of PacketCodesEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LinkPacketCodeToProductCopyWith<LinkPacketCodeToProduct> get copyWith => _$LinkPacketCodeToProductCopyWithImpl<LinkPacketCodeToProduct>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LinkPacketCodeToProduct&&(identical(other.packetCodeId, packetCodeId) || other.packetCodeId == packetCodeId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productBatchNumber, productBatchNumber) || other.productBatchNumber == productBatchNumber)&&(identical(other.manufacturingDate, manufacturingDate) || other.manufacturingDate == manufacturingDate)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.warrantyMonths, warrantyMonths) || other.warrantyMonths == warrantyMonths));
}


@override
int get hashCode => Object.hash(runtimeType,packetCodeId,productId,productBatchNumber,manufacturingDate,expiryDate,warrantyMonths);

@override
String toString() {
  return 'PacketCodesEvent.linkToProduct(packetCodeId: $packetCodeId, productId: $productId, productBatchNumber: $productBatchNumber, manufacturingDate: $manufacturingDate, expiryDate: $expiryDate, warrantyMonths: $warrantyMonths)';
}


}

/// @nodoc
abstract mixin class $LinkPacketCodeToProductCopyWith<$Res> implements $PacketCodesEventCopyWith<$Res> {
  factory $LinkPacketCodeToProductCopyWith(LinkPacketCodeToProduct value, $Res Function(LinkPacketCodeToProduct) _then) = _$LinkPacketCodeToProductCopyWithImpl;
@useResult
$Res call({
 String packetCodeId, String productId, String productBatchNumber, DateTime? manufacturingDate, DateTime? expiryDate, int? warrantyMonths
});




}
/// @nodoc
class _$LinkPacketCodeToProductCopyWithImpl<$Res>
    implements $LinkPacketCodeToProductCopyWith<$Res> {
  _$LinkPacketCodeToProductCopyWithImpl(this._self, this._then);

  final LinkPacketCodeToProduct _self;
  final $Res Function(LinkPacketCodeToProduct) _then;

/// Create a copy of PacketCodesEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? packetCodeId = null,Object? productId = null,Object? productBatchNumber = null,Object? manufacturingDate = freezed,Object? expiryDate = freezed,Object? warrantyMonths = freezed,}) {
  return _then(LinkPacketCodeToProduct(
packetCodeId: null == packetCodeId ? _self.packetCodeId : packetCodeId // ignore: cast_nullable_to_non_nullable
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


class PublishPacketCode implements PacketCodesEvent {
  const PublishPacketCode(this.packetCodeId);
  

 final  String packetCodeId;

/// Create a copy of PacketCodesEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PublishPacketCodeCopyWith<PublishPacketCode> get copyWith => _$PublishPacketCodeCopyWithImpl<PublishPacketCode>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PublishPacketCode&&(identical(other.packetCodeId, packetCodeId) || other.packetCodeId == packetCodeId));
}


@override
int get hashCode => Object.hash(runtimeType,packetCodeId);

@override
String toString() {
  return 'PacketCodesEvent.publish(packetCodeId: $packetCodeId)';
}


}

/// @nodoc
abstract mixin class $PublishPacketCodeCopyWith<$Res> implements $PacketCodesEventCopyWith<$Res> {
  factory $PublishPacketCodeCopyWith(PublishPacketCode value, $Res Function(PublishPacketCode) _then) = _$PublishPacketCodeCopyWithImpl;
@useResult
$Res call({
 String packetCodeId
});




}
/// @nodoc
class _$PublishPacketCodeCopyWithImpl<$Res>
    implements $PublishPacketCodeCopyWith<$Res> {
  _$PublishPacketCodeCopyWithImpl(this._self, this._then);

  final PublishPacketCode _self;
  final $Res Function(PublishPacketCode) _then;

/// Create a copy of PacketCodesEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? packetCodeId = null,}) {
  return _then(PublishPacketCode(
null == packetCodeId ? _self.packetCodeId : packetCodeId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class DeactivatePacketCode implements PacketCodesEvent {
  const DeactivatePacketCode(this.packetCodeId, this.reason);
  

 final  String packetCodeId;
 final  String reason;

/// Create a copy of PacketCodesEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeactivatePacketCodeCopyWith<DeactivatePacketCode> get copyWith => _$DeactivatePacketCodeCopyWithImpl<DeactivatePacketCode>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeactivatePacketCode&&(identical(other.packetCodeId, packetCodeId) || other.packetCodeId == packetCodeId)&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode => Object.hash(runtimeType,packetCodeId,reason);

@override
String toString() {
  return 'PacketCodesEvent.deactivate(packetCodeId: $packetCodeId, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $DeactivatePacketCodeCopyWith<$Res> implements $PacketCodesEventCopyWith<$Res> {
  factory $DeactivatePacketCodeCopyWith(DeactivatePacketCode value, $Res Function(DeactivatePacketCode) _then) = _$DeactivatePacketCodeCopyWithImpl;
@useResult
$Res call({
 String packetCodeId, String reason
});




}
/// @nodoc
class _$DeactivatePacketCodeCopyWithImpl<$Res>
    implements $DeactivatePacketCodeCopyWith<$Res> {
  _$DeactivatePacketCodeCopyWithImpl(this._self, this._then);

  final DeactivatePacketCode _self;
  final $Res Function(DeactivatePacketCode) _then;

/// Create a copy of PacketCodesEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? packetCodeId = null,Object? reason = null,}) {
  return _then(DeactivatePacketCode(
null == packetCodeId ? _self.packetCodeId : packetCodeId // ignore: cast_nullable_to_non_nullable
as String,null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SearchPacketCodes implements PacketCodesEvent {
  const SearchPacketCodes(this.query);
  

 final  String query;

/// Create a copy of PacketCodesEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchPacketCodesCopyWith<SearchPacketCodes> get copyWith => _$SearchPacketCodesCopyWithImpl<SearchPacketCodes>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchPacketCodes&&(identical(other.query, query) || other.query == query));
}


@override
int get hashCode => Object.hash(runtimeType,query);

@override
String toString() {
  return 'PacketCodesEvent.search(query: $query)';
}


}

/// @nodoc
abstract mixin class $SearchPacketCodesCopyWith<$Res> implements $PacketCodesEventCopyWith<$Res> {
  factory $SearchPacketCodesCopyWith(SearchPacketCodes value, $Res Function(SearchPacketCodes) _then) = _$SearchPacketCodesCopyWithImpl;
@useResult
$Res call({
 String query
});




}
/// @nodoc
class _$SearchPacketCodesCopyWithImpl<$Res>
    implements $SearchPacketCodesCopyWith<$Res> {
  _$SearchPacketCodesCopyWithImpl(this._self, this._then);

  final SearchPacketCodes _self;
  final $Res Function(SearchPacketCodes) _then;

/// Create a copy of PacketCodesEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? query = null,}) {
  return _then(SearchPacketCodes(
null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class FilterPacketCodes implements PacketCodesEvent {
  const FilterPacketCodes({this.status, this.cartonCode, this.startDate, this.endDate, this.packetType, this.condition});
  

 final  CodeStatus? status;
 final  String? cartonCode;
 final  DateTime? startDate;
 final  DateTime? endDate;
 final  String? packetType;
 final  String? condition;

/// Create a copy of PacketCodesEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FilterPacketCodesCopyWith<FilterPacketCodes> get copyWith => _$FilterPacketCodesCopyWithImpl<FilterPacketCodes>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FilterPacketCodes&&(identical(other.status, status) || other.status == status)&&(identical(other.cartonCode, cartonCode) || other.cartonCode == cartonCode)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.packetType, packetType) || other.packetType == packetType)&&(identical(other.condition, condition) || other.condition == condition));
}


@override
int get hashCode => Object.hash(runtimeType,status,cartonCode,startDate,endDate,packetType,condition);

@override
String toString() {
  return 'PacketCodesEvent.filter(status: $status, cartonCode: $cartonCode, startDate: $startDate, endDate: $endDate, packetType: $packetType, condition: $condition)';
}


}

/// @nodoc
abstract mixin class $FilterPacketCodesCopyWith<$Res> implements $PacketCodesEventCopyWith<$Res> {
  factory $FilterPacketCodesCopyWith(FilterPacketCodes value, $Res Function(FilterPacketCodes) _then) = _$FilterPacketCodesCopyWithImpl;
@useResult
$Res call({
 CodeStatus? status, String? cartonCode, DateTime? startDate, DateTime? endDate, String? packetType, String? condition
});




}
/// @nodoc
class _$FilterPacketCodesCopyWithImpl<$Res>
    implements $FilterPacketCodesCopyWith<$Res> {
  _$FilterPacketCodesCopyWithImpl(this._self, this._then);

  final FilterPacketCodes _self;
  final $Res Function(FilterPacketCodes) _then;

/// Create a copy of PacketCodesEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? status = freezed,Object? cartonCode = freezed,Object? startDate = freezed,Object? endDate = freezed,Object? packetType = freezed,Object? condition = freezed,}) {
  return _then(FilterPacketCodes(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CodeStatus?,cartonCode: freezed == cartonCode ? _self.cartonCode : cartonCode // ignore: cast_nullable_to_non_nullable
as String?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,packetType: freezed == packetType ? _self.packetType : packetType // ignore: cast_nullable_to_non_nullable
as String?,condition: freezed == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class ExportPacketCodes implements PacketCodesEvent {
  const ExportPacketCodes(final  List<String> packetCodeIds, this.format): _packetCodeIds = packetCodeIds;
  

 final  List<String> _packetCodeIds;
 List<String> get packetCodeIds {
  if (_packetCodeIds is EqualUnmodifiableListView) return _packetCodeIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_packetCodeIds);
}

 final  String format;

/// Create a copy of PacketCodesEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExportPacketCodesCopyWith<ExportPacketCodes> get copyWith => _$ExportPacketCodesCopyWithImpl<ExportPacketCodes>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExportPacketCodes&&const DeepCollectionEquality().equals(other._packetCodeIds, _packetCodeIds)&&(identical(other.format, format) || other.format == format));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_packetCodeIds),format);

@override
String toString() {
  return 'PacketCodesEvent.export(packetCodeIds: $packetCodeIds, format: $format)';
}


}

/// @nodoc
abstract mixin class $ExportPacketCodesCopyWith<$Res> implements $PacketCodesEventCopyWith<$Res> {
  factory $ExportPacketCodesCopyWith(ExportPacketCodes value, $Res Function(ExportPacketCodes) _then) = _$ExportPacketCodesCopyWithImpl;
@useResult
$Res call({
 List<String> packetCodeIds, String format
});




}
/// @nodoc
class _$ExportPacketCodesCopyWithImpl<$Res>
    implements $ExportPacketCodesCopyWith<$Res> {
  _$ExportPacketCodesCopyWithImpl(this._self, this._then);

  final ExportPacketCodes _self;
  final $Res Function(ExportPacketCodes) _then;

/// Create a copy of PacketCodesEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? packetCodeIds = null,Object? format = null,}) {
  return _then(ExportPacketCodes(
null == packetCodeIds ? _self._packetCodeIds : packetCodeIds // ignore: cast_nullable_to_non_nullable
as List<String>,null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SelectPacketCode implements PacketCodesEvent {
  const SelectPacketCode(this.packetCodeId, this.isSelected);
  

 final  String packetCodeId;
 final  bool isSelected;

/// Create a copy of PacketCodesEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SelectPacketCodeCopyWith<SelectPacketCode> get copyWith => _$SelectPacketCodeCopyWithImpl<SelectPacketCode>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SelectPacketCode&&(identical(other.packetCodeId, packetCodeId) || other.packetCodeId == packetCodeId)&&(identical(other.isSelected, isSelected) || other.isSelected == isSelected));
}


@override
int get hashCode => Object.hash(runtimeType,packetCodeId,isSelected);

@override
String toString() {
  return 'PacketCodesEvent.select(packetCodeId: $packetCodeId, isSelected: $isSelected)';
}


}

/// @nodoc
abstract mixin class $SelectPacketCodeCopyWith<$Res> implements $PacketCodesEventCopyWith<$Res> {
  factory $SelectPacketCodeCopyWith(SelectPacketCode value, $Res Function(SelectPacketCode) _then) = _$SelectPacketCodeCopyWithImpl;
@useResult
$Res call({
 String packetCodeId, bool isSelected
});




}
/// @nodoc
class _$SelectPacketCodeCopyWithImpl<$Res>
    implements $SelectPacketCodeCopyWith<$Res> {
  _$SelectPacketCodeCopyWithImpl(this._self, this._then);

  final SelectPacketCode _self;
  final $Res Function(SelectPacketCode) _then;

/// Create a copy of PacketCodesEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? packetCodeId = null,Object? isSelected = null,}) {
  return _then(SelectPacketCode(
null == packetCodeId ? _self.packetCodeId : packetCodeId // ignore: cast_nullable_to_non_nullable
as String,null == isSelected ? _self.isSelected : isSelected // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class ClearSelection implements PacketCodesEvent {
  const ClearSelection();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClearSelection);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PacketCodesEvent.clearSelection()';
}


}




/// @nodoc


class RefreshPacketCodes implements PacketCodesEvent {
  const RefreshPacketCodes();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RefreshPacketCodes);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PacketCodesEvent.refresh()';
}


}




/// @nodoc


class SealPacket implements PacketCodesEvent {
  const SealPacket(this.packetCodeId, this.sealedBy, {this.sealingMethod});
  

 final  String packetCodeId;
 final  String sealedBy;
 final  String? sealingMethod;

/// Create a copy of PacketCodesEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SealPacketCopyWith<SealPacket> get copyWith => _$SealPacketCopyWithImpl<SealPacket>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SealPacket&&(identical(other.packetCodeId, packetCodeId) || other.packetCodeId == packetCodeId)&&(identical(other.sealedBy, sealedBy) || other.sealedBy == sealedBy)&&(identical(other.sealingMethod, sealingMethod) || other.sealingMethod == sealingMethod));
}


@override
int get hashCode => Object.hash(runtimeType,packetCodeId,sealedBy,sealingMethod);

@override
String toString() {
  return 'PacketCodesEvent.seal(packetCodeId: $packetCodeId, sealedBy: $sealedBy, sealingMethod: $sealingMethod)';
}


}

/// @nodoc
abstract mixin class $SealPacketCopyWith<$Res> implements $PacketCodesEventCopyWith<$Res> {
  factory $SealPacketCopyWith(SealPacket value, $Res Function(SealPacket) _then) = _$SealPacketCopyWithImpl;
@useResult
$Res call({
 String packetCodeId, String sealedBy, String? sealingMethod
});




}
/// @nodoc
class _$SealPacketCopyWithImpl<$Res>
    implements $SealPacketCopyWith<$Res> {
  _$SealPacketCopyWithImpl(this._self, this._then);

  final SealPacket _self;
  final $Res Function(SealPacket) _then;

/// Create a copy of PacketCodesEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? packetCodeId = null,Object? sealedBy = null,Object? sealingMethod = freezed,}) {
  return _then(SealPacket(
null == packetCodeId ? _self.packetCodeId : packetCodeId // ignore: cast_nullable_to_non_nullable
as String,null == sealedBy ? _self.sealedBy : sealedBy // ignore: cast_nullable_to_non_nullable
as String,sealingMethod: freezed == sealingMethod ? _self.sealingMethod : sealingMethod // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class UpdatePacketInspection implements PacketCodesEvent {
  const UpdatePacketInspection(this.packetCodeId, this.condition, this.inspectionNotes, this.hasTamperEvidence, this.hasChildSafety);
  

 final  String packetCodeId;
 final  String condition;
 final  String inspectionNotes;
 final  bool hasTamperEvidence;
 final  bool hasChildSafety;

/// Create a copy of PacketCodesEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdatePacketInspectionCopyWith<UpdatePacketInspection> get copyWith => _$UpdatePacketInspectionCopyWithImpl<UpdatePacketInspection>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdatePacketInspection&&(identical(other.packetCodeId, packetCodeId) || other.packetCodeId == packetCodeId)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.inspectionNotes, inspectionNotes) || other.inspectionNotes == inspectionNotes)&&(identical(other.hasTamperEvidence, hasTamperEvidence) || other.hasTamperEvidence == hasTamperEvidence)&&(identical(other.hasChildSafety, hasChildSafety) || other.hasChildSafety == hasChildSafety));
}


@override
int get hashCode => Object.hash(runtimeType,packetCodeId,condition,inspectionNotes,hasTamperEvidence,hasChildSafety);

@override
String toString() {
  return 'PacketCodesEvent.updateInspection(packetCodeId: $packetCodeId, condition: $condition, inspectionNotes: $inspectionNotes, hasTamperEvidence: $hasTamperEvidence, hasChildSafety: $hasChildSafety)';
}


}

/// @nodoc
abstract mixin class $UpdatePacketInspectionCopyWith<$Res> implements $PacketCodesEventCopyWith<$Res> {
  factory $UpdatePacketInspectionCopyWith(UpdatePacketInspection value, $Res Function(UpdatePacketInspection) _then) = _$UpdatePacketInspectionCopyWithImpl;
@useResult
$Res call({
 String packetCodeId, String condition, String inspectionNotes, bool hasTamperEvidence, bool hasChildSafety
});




}
/// @nodoc
class _$UpdatePacketInspectionCopyWithImpl<$Res>
    implements $UpdatePacketInspectionCopyWith<$Res> {
  _$UpdatePacketInspectionCopyWithImpl(this._self, this._then);

  final UpdatePacketInspection _self;
  final $Res Function(UpdatePacketInspection) _then;

/// Create a copy of PacketCodesEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? packetCodeId = null,Object? condition = null,Object? inspectionNotes = null,Object? hasTamperEvidence = null,Object? hasChildSafety = null,}) {
  return _then(UpdatePacketInspection(
null == packetCodeId ? _self.packetCodeId : packetCodeId // ignore: cast_nullable_to_non_nullable
as String,null == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as String,null == inspectionNotes ? _self.inspectionNotes : inspectionNotes // ignore: cast_nullable_to_non_nullable
as String,null == hasTamperEvidence ? _self.hasTamperEvidence : hasTamperEvidence // ignore: cast_nullable_to_non_nullable
as bool,null == hasChildSafety ? _self.hasChildSafety : hasChildSafety // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class UpdatePacketProperties implements PacketCodesEvent {
  const UpdatePacketProperties({required this.packetCodeId, this.weight, this.dimensions, this.packetType, this.material, this.sealingMethod});
  

 final  String packetCodeId;
 final  double? weight;
 final  String? dimensions;
 final  String? packetType;
 final  String? material;
 final  String? sealingMethod;

/// Create a copy of PacketCodesEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdatePacketPropertiesCopyWith<UpdatePacketProperties> get copyWith => _$UpdatePacketPropertiesCopyWithImpl<UpdatePacketProperties>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdatePacketProperties&&(identical(other.packetCodeId, packetCodeId) || other.packetCodeId == packetCodeId)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.dimensions, dimensions) || other.dimensions == dimensions)&&(identical(other.packetType, packetType) || other.packetType == packetType)&&(identical(other.material, material) || other.material == material)&&(identical(other.sealingMethod, sealingMethod) || other.sealingMethod == sealingMethod));
}


@override
int get hashCode => Object.hash(runtimeType,packetCodeId,weight,dimensions,packetType,material,sealingMethod);

@override
String toString() {
  return 'PacketCodesEvent.updateProperties(packetCodeId: $packetCodeId, weight: $weight, dimensions: $dimensions, packetType: $packetType, material: $material, sealingMethod: $sealingMethod)';
}


}

/// @nodoc
abstract mixin class $UpdatePacketPropertiesCopyWith<$Res> implements $PacketCodesEventCopyWith<$Res> {
  factory $UpdatePacketPropertiesCopyWith(UpdatePacketProperties value, $Res Function(UpdatePacketProperties) _then) = _$UpdatePacketPropertiesCopyWithImpl;
@useResult
$Res call({
 String packetCodeId, double? weight, String? dimensions, String? packetType, String? material, String? sealingMethod
});




}
/// @nodoc
class _$UpdatePacketPropertiesCopyWithImpl<$Res>
    implements $UpdatePacketPropertiesCopyWith<$Res> {
  _$UpdatePacketPropertiesCopyWithImpl(this._self, this._then);

  final UpdatePacketProperties _self;
  final $Res Function(UpdatePacketProperties) _then;

/// Create a copy of PacketCodesEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? packetCodeId = null,Object? weight = freezed,Object? dimensions = freezed,Object? packetType = freezed,Object? material = freezed,Object? sealingMethod = freezed,}) {
  return _then(UpdatePacketProperties(
packetCodeId: null == packetCodeId ? _self.packetCodeId : packetCodeId // ignore: cast_nullable_to_non_nullable
as String,weight: freezed == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double?,dimensions: freezed == dimensions ? _self.dimensions : dimensions // ignore: cast_nullable_to_non_nullable
as String?,packetType: freezed == packetType ? _self.packetType : packetType // ignore: cast_nullable_to_non_nullable
as String?,material: freezed == material ? _self.material : material // ignore: cast_nullable_to_non_nullable
as String?,sealingMethod: freezed == sealingMethod ? _self.sealingMethod : sealingMethod // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class AddTamperEvidence implements PacketCodesEvent {
  const AddTamperEvidence(this.packetCodeId);
  

 final  String packetCodeId;

/// Create a copy of PacketCodesEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddTamperEvidenceCopyWith<AddTamperEvidence> get copyWith => _$AddTamperEvidenceCopyWithImpl<AddTamperEvidence>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddTamperEvidence&&(identical(other.packetCodeId, packetCodeId) || other.packetCodeId == packetCodeId));
}


@override
int get hashCode => Object.hash(runtimeType,packetCodeId);

@override
String toString() {
  return 'PacketCodesEvent.addTamperEvidence(packetCodeId: $packetCodeId)';
}


}

/// @nodoc
abstract mixin class $AddTamperEvidenceCopyWith<$Res> implements $PacketCodesEventCopyWith<$Res> {
  factory $AddTamperEvidenceCopyWith(AddTamperEvidence value, $Res Function(AddTamperEvidence) _then) = _$AddTamperEvidenceCopyWithImpl;
@useResult
$Res call({
 String packetCodeId
});




}
/// @nodoc
class _$AddTamperEvidenceCopyWithImpl<$Res>
    implements $AddTamperEvidenceCopyWith<$Res> {
  _$AddTamperEvidenceCopyWithImpl(this._self, this._then);

  final AddTamperEvidence _self;
  final $Res Function(AddTamperEvidence) _then;

/// Create a copy of PacketCodesEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? packetCodeId = null,}) {
  return _then(AddTamperEvidence(
null == packetCodeId ? _self.packetCodeId : packetCodeId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class AddChildSafetyFeatures implements PacketCodesEvent {
  const AddChildSafetyFeatures(this.packetCodeId);
  

 final  String packetCodeId;

/// Create a copy of PacketCodesEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddChildSafetyFeaturesCopyWith<AddChildSafetyFeatures> get copyWith => _$AddChildSafetyFeaturesCopyWithImpl<AddChildSafetyFeatures>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddChildSafetyFeatures&&(identical(other.packetCodeId, packetCodeId) || other.packetCodeId == packetCodeId));
}


@override
int get hashCode => Object.hash(runtimeType,packetCodeId);

@override
String toString() {
  return 'PacketCodesEvent.addChildSafetyFeatures(packetCodeId: $packetCodeId)';
}


}

/// @nodoc
abstract mixin class $AddChildSafetyFeaturesCopyWith<$Res> implements $PacketCodesEventCopyWith<$Res> {
  factory $AddChildSafetyFeaturesCopyWith(AddChildSafetyFeatures value, $Res Function(AddChildSafetyFeatures) _then) = _$AddChildSafetyFeaturesCopyWithImpl;
@useResult
$Res call({
 String packetCodeId
});




}
/// @nodoc
class _$AddChildSafetyFeaturesCopyWithImpl<$Res>
    implements $AddChildSafetyFeaturesCopyWith<$Res> {
  _$AddChildSafetyFeaturesCopyWithImpl(this._self, this._then);

  final AddChildSafetyFeatures _self;
  final $Res Function(AddChildSafetyFeatures) _then;

/// Create a copy of PacketCodesEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? packetCodeId = null,}) {
  return _then(AddChildSafetyFeatures(
null == packetCodeId ? _self.packetCodeId : packetCodeId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class AddInstructions implements PacketCodesEvent {
  const AddInstructions(this.packetCodeId);
  

 final  String packetCodeId;

/// Create a copy of PacketCodesEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddInstructionsCopyWith<AddInstructions> get copyWith => _$AddInstructionsCopyWithImpl<AddInstructions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddInstructions&&(identical(other.packetCodeId, packetCodeId) || other.packetCodeId == packetCodeId));
}


@override
int get hashCode => Object.hash(runtimeType,packetCodeId);

@override
String toString() {
  return 'PacketCodesEvent.addInstructions(packetCodeId: $packetCodeId)';
}


}

/// @nodoc
abstract mixin class $AddInstructionsCopyWith<$Res> implements $PacketCodesEventCopyWith<$Res> {
  factory $AddInstructionsCopyWith(AddInstructions value, $Res Function(AddInstructions) _then) = _$AddInstructionsCopyWithImpl;
@useResult
$Res call({
 String packetCodeId
});




}
/// @nodoc
class _$AddInstructionsCopyWithImpl<$Res>
    implements $AddInstructionsCopyWith<$Res> {
  _$AddInstructionsCopyWithImpl(this._self, this._then);

  final AddInstructions _self;
  final $Res Function(AddInstructions) _then;

/// Create a copy of PacketCodesEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? packetCodeId = null,}) {
  return _then(AddInstructions(
null == packetCodeId ? _self.packetCodeId : packetCodeId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$PacketCodesState {

 PacketCodesStatus get status; List<PacketCodeModel> get packetCodes; List<PacketCodeModel> get filteredPacketCodes; Set<String> get selectedPacketCodeIds; String get searchQuery; CodeStatus? get filterStatus; String? get filterCartonCode; DateTime? get filterStartDate; DateTime? get filterEndDate; String? get filterPacketType; String? get filterCondition; String? get errorMessage; bool get hasReachedMax; int get currentPage; int get totalCount; bool get isLoadingMore; int get generatedCount; DateTime? get lastGeneratedAt; String? get exportPath; bool get isExporting;
/// Create a copy of PacketCodesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PacketCodesStateCopyWith<PacketCodesState> get copyWith => _$PacketCodesStateCopyWithImpl<PacketCodesState>(this as PacketCodesState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PacketCodesState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.packetCodes, packetCodes)&&const DeepCollectionEquality().equals(other.filteredPacketCodes, filteredPacketCodes)&&const DeepCollectionEquality().equals(other.selectedPacketCodeIds, selectedPacketCodeIds)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.filterStatus, filterStatus) || other.filterStatus == filterStatus)&&(identical(other.filterCartonCode, filterCartonCode) || other.filterCartonCode == filterCartonCode)&&(identical(other.filterStartDate, filterStartDate) || other.filterStartDate == filterStartDate)&&(identical(other.filterEndDate, filterEndDate) || other.filterEndDate == filterEndDate)&&(identical(other.filterPacketType, filterPacketType) || other.filterPacketType == filterPacketType)&&(identical(other.filterCondition, filterCondition) || other.filterCondition == filterCondition)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.hasReachedMax, hasReachedMax) || other.hasReachedMax == hasReachedMax)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.generatedCount, generatedCount) || other.generatedCount == generatedCount)&&(identical(other.lastGeneratedAt, lastGeneratedAt) || other.lastGeneratedAt == lastGeneratedAt)&&(identical(other.exportPath, exportPath) || other.exportPath == exportPath)&&(identical(other.isExporting, isExporting) || other.isExporting == isExporting));
}


@override
int get hashCode => Object.hashAll([runtimeType,status,const DeepCollectionEquality().hash(packetCodes),const DeepCollectionEquality().hash(filteredPacketCodes),const DeepCollectionEquality().hash(selectedPacketCodeIds),searchQuery,filterStatus,filterCartonCode,filterStartDate,filterEndDate,filterPacketType,filterCondition,errorMessage,hasReachedMax,currentPage,totalCount,isLoadingMore,generatedCount,lastGeneratedAt,exportPath,isExporting]);

@override
String toString() {
  return 'PacketCodesState(status: $status, packetCodes: $packetCodes, filteredPacketCodes: $filteredPacketCodes, selectedPacketCodeIds: $selectedPacketCodeIds, searchQuery: $searchQuery, filterStatus: $filterStatus, filterCartonCode: $filterCartonCode, filterStartDate: $filterStartDate, filterEndDate: $filterEndDate, filterPacketType: $filterPacketType, filterCondition: $filterCondition, errorMessage: $errorMessage, hasReachedMax: $hasReachedMax, currentPage: $currentPage, totalCount: $totalCount, isLoadingMore: $isLoadingMore, generatedCount: $generatedCount, lastGeneratedAt: $lastGeneratedAt, exportPath: $exportPath, isExporting: $isExporting)';
}


}

/// @nodoc
abstract mixin class $PacketCodesStateCopyWith<$Res>  {
  factory $PacketCodesStateCopyWith(PacketCodesState value, $Res Function(PacketCodesState) _then) = _$PacketCodesStateCopyWithImpl;
@useResult
$Res call({
 PacketCodesStatus status, List<PacketCodeModel> packetCodes, List<PacketCodeModel> filteredPacketCodes, Set<String> selectedPacketCodeIds, String searchQuery, CodeStatus? filterStatus, String? filterCartonCode, DateTime? filterStartDate, DateTime? filterEndDate, String? filterPacketType, String? filterCondition, String? errorMessage, bool hasReachedMax, int currentPage, int totalCount, bool isLoadingMore, int generatedCount, DateTime? lastGeneratedAt, String? exportPath, bool isExporting
});




}
/// @nodoc
class _$PacketCodesStateCopyWithImpl<$Res>
    implements $PacketCodesStateCopyWith<$Res> {
  _$PacketCodesStateCopyWithImpl(this._self, this._then);

  final PacketCodesState _self;
  final $Res Function(PacketCodesState) _then;

/// Create a copy of PacketCodesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? packetCodes = null,Object? filteredPacketCodes = null,Object? selectedPacketCodeIds = null,Object? searchQuery = null,Object? filterStatus = freezed,Object? filterCartonCode = freezed,Object? filterStartDate = freezed,Object? filterEndDate = freezed,Object? filterPacketType = freezed,Object? filterCondition = freezed,Object? errorMessage = freezed,Object? hasReachedMax = null,Object? currentPage = null,Object? totalCount = null,Object? isLoadingMore = null,Object? generatedCount = null,Object? lastGeneratedAt = freezed,Object? exportPath = freezed,Object? isExporting = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PacketCodesStatus,packetCodes: null == packetCodes ? _self.packetCodes : packetCodes // ignore: cast_nullable_to_non_nullable
as List<PacketCodeModel>,filteredPacketCodes: null == filteredPacketCodes ? _self.filteredPacketCodes : filteredPacketCodes // ignore: cast_nullable_to_non_nullable
as List<PacketCodeModel>,selectedPacketCodeIds: null == selectedPacketCodeIds ? _self.selectedPacketCodeIds : selectedPacketCodeIds // ignore: cast_nullable_to_non_nullable
as Set<String>,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,filterStatus: freezed == filterStatus ? _self.filterStatus : filterStatus // ignore: cast_nullable_to_non_nullable
as CodeStatus?,filterCartonCode: freezed == filterCartonCode ? _self.filterCartonCode : filterCartonCode // ignore: cast_nullable_to_non_nullable
as String?,filterStartDate: freezed == filterStartDate ? _self.filterStartDate : filterStartDate // ignore: cast_nullable_to_non_nullable
as DateTime?,filterEndDate: freezed == filterEndDate ? _self.filterEndDate : filterEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,filterPacketType: freezed == filterPacketType ? _self.filterPacketType : filterPacketType // ignore: cast_nullable_to_non_nullable
as String?,filterCondition: freezed == filterCondition ? _self.filterCondition : filterCondition // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
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


/// Adds pattern-matching-related methods to [PacketCodesState].
extension PacketCodesStatePatterns on PacketCodesState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PacketCodesState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PacketCodesState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PacketCodesState value)  $default,){
final _that = this;
switch (_that) {
case _PacketCodesState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PacketCodesState value)?  $default,){
final _that = this;
switch (_that) {
case _PacketCodesState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PacketCodesStatus status,  List<PacketCodeModel> packetCodes,  List<PacketCodeModel> filteredPacketCodes,  Set<String> selectedPacketCodeIds,  String searchQuery,  CodeStatus? filterStatus,  String? filterCartonCode,  DateTime? filterStartDate,  DateTime? filterEndDate,  String? filterPacketType,  String? filterCondition,  String? errorMessage,  bool hasReachedMax,  int currentPage,  int totalCount,  bool isLoadingMore,  int generatedCount,  DateTime? lastGeneratedAt,  String? exportPath,  bool isExporting)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PacketCodesState() when $default != null:
return $default(_that.status,_that.packetCodes,_that.filteredPacketCodes,_that.selectedPacketCodeIds,_that.searchQuery,_that.filterStatus,_that.filterCartonCode,_that.filterStartDate,_that.filterEndDate,_that.filterPacketType,_that.filterCondition,_that.errorMessage,_that.hasReachedMax,_that.currentPage,_that.totalCount,_that.isLoadingMore,_that.generatedCount,_that.lastGeneratedAt,_that.exportPath,_that.isExporting);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PacketCodesStatus status,  List<PacketCodeModel> packetCodes,  List<PacketCodeModel> filteredPacketCodes,  Set<String> selectedPacketCodeIds,  String searchQuery,  CodeStatus? filterStatus,  String? filterCartonCode,  DateTime? filterStartDate,  DateTime? filterEndDate,  String? filterPacketType,  String? filterCondition,  String? errorMessage,  bool hasReachedMax,  int currentPage,  int totalCount,  bool isLoadingMore,  int generatedCount,  DateTime? lastGeneratedAt,  String? exportPath,  bool isExporting)  $default,) {final _that = this;
switch (_that) {
case _PacketCodesState():
return $default(_that.status,_that.packetCodes,_that.filteredPacketCodes,_that.selectedPacketCodeIds,_that.searchQuery,_that.filterStatus,_that.filterCartonCode,_that.filterStartDate,_that.filterEndDate,_that.filterPacketType,_that.filterCondition,_that.errorMessage,_that.hasReachedMax,_that.currentPage,_that.totalCount,_that.isLoadingMore,_that.generatedCount,_that.lastGeneratedAt,_that.exportPath,_that.isExporting);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PacketCodesStatus status,  List<PacketCodeModel> packetCodes,  List<PacketCodeModel> filteredPacketCodes,  Set<String> selectedPacketCodeIds,  String searchQuery,  CodeStatus? filterStatus,  String? filterCartonCode,  DateTime? filterStartDate,  DateTime? filterEndDate,  String? filterPacketType,  String? filterCondition,  String? errorMessage,  bool hasReachedMax,  int currentPage,  int totalCount,  bool isLoadingMore,  int generatedCount,  DateTime? lastGeneratedAt,  String? exportPath,  bool isExporting)?  $default,) {final _that = this;
switch (_that) {
case _PacketCodesState() when $default != null:
return $default(_that.status,_that.packetCodes,_that.filteredPacketCodes,_that.selectedPacketCodeIds,_that.searchQuery,_that.filterStatus,_that.filterCartonCode,_that.filterStartDate,_that.filterEndDate,_that.filterPacketType,_that.filterCondition,_that.errorMessage,_that.hasReachedMax,_that.currentPage,_that.totalCount,_that.isLoadingMore,_that.generatedCount,_that.lastGeneratedAt,_that.exportPath,_that.isExporting);case _:
  return null;

}
}

}

/// @nodoc


class _PacketCodesState extends PacketCodesState {
  const _PacketCodesState({this.status = PacketCodesStatus.initial, final  List<PacketCodeModel> packetCodes = const [], final  List<PacketCodeModel> filteredPacketCodes = const [], final  Set<String> selectedPacketCodeIds = const {}, this.searchQuery = '', this.filterStatus, this.filterCartonCode, this.filterStartDate, this.filterEndDate, this.filterPacketType, this.filterCondition, this.errorMessage, this.hasReachedMax = false, this.currentPage = 1, this.totalCount = 0, this.isLoadingMore = false, this.generatedCount = 0, this.lastGeneratedAt, this.exportPath, this.isExporting = false}): _packetCodes = packetCodes,_filteredPacketCodes = filteredPacketCodes,_selectedPacketCodeIds = selectedPacketCodeIds,super._();
  

@override@JsonKey() final  PacketCodesStatus status;
 final  List<PacketCodeModel> _packetCodes;
@override@JsonKey() List<PacketCodeModel> get packetCodes {
  if (_packetCodes is EqualUnmodifiableListView) return _packetCodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_packetCodes);
}

 final  List<PacketCodeModel> _filteredPacketCodes;
@override@JsonKey() List<PacketCodeModel> get filteredPacketCodes {
  if (_filteredPacketCodes is EqualUnmodifiableListView) return _filteredPacketCodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_filteredPacketCodes);
}

 final  Set<String> _selectedPacketCodeIds;
@override@JsonKey() Set<String> get selectedPacketCodeIds {
  if (_selectedPacketCodeIds is EqualUnmodifiableSetView) return _selectedPacketCodeIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_selectedPacketCodeIds);
}

@override@JsonKey() final  String searchQuery;
@override final  CodeStatus? filterStatus;
@override final  String? filterCartonCode;
@override final  DateTime? filterStartDate;
@override final  DateTime? filterEndDate;
@override final  String? filterPacketType;
@override final  String? filterCondition;
@override final  String? errorMessage;
@override@JsonKey() final  bool hasReachedMax;
@override@JsonKey() final  int currentPage;
@override@JsonKey() final  int totalCount;
@override@JsonKey() final  bool isLoadingMore;
@override@JsonKey() final  int generatedCount;
@override final  DateTime? lastGeneratedAt;
@override final  String? exportPath;
@override@JsonKey() final  bool isExporting;

/// Create a copy of PacketCodesState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PacketCodesStateCopyWith<_PacketCodesState> get copyWith => __$PacketCodesStateCopyWithImpl<_PacketCodesState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PacketCodesState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._packetCodes, _packetCodes)&&const DeepCollectionEquality().equals(other._filteredPacketCodes, _filteredPacketCodes)&&const DeepCollectionEquality().equals(other._selectedPacketCodeIds, _selectedPacketCodeIds)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.filterStatus, filterStatus) || other.filterStatus == filterStatus)&&(identical(other.filterCartonCode, filterCartonCode) || other.filterCartonCode == filterCartonCode)&&(identical(other.filterStartDate, filterStartDate) || other.filterStartDate == filterStartDate)&&(identical(other.filterEndDate, filterEndDate) || other.filterEndDate == filterEndDate)&&(identical(other.filterPacketType, filterPacketType) || other.filterPacketType == filterPacketType)&&(identical(other.filterCondition, filterCondition) || other.filterCondition == filterCondition)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.hasReachedMax, hasReachedMax) || other.hasReachedMax == hasReachedMax)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.generatedCount, generatedCount) || other.generatedCount == generatedCount)&&(identical(other.lastGeneratedAt, lastGeneratedAt) || other.lastGeneratedAt == lastGeneratedAt)&&(identical(other.exportPath, exportPath) || other.exportPath == exportPath)&&(identical(other.isExporting, isExporting) || other.isExporting == isExporting));
}


@override
int get hashCode => Object.hashAll([runtimeType,status,const DeepCollectionEquality().hash(_packetCodes),const DeepCollectionEquality().hash(_filteredPacketCodes),const DeepCollectionEquality().hash(_selectedPacketCodeIds),searchQuery,filterStatus,filterCartonCode,filterStartDate,filterEndDate,filterPacketType,filterCondition,errorMessage,hasReachedMax,currentPage,totalCount,isLoadingMore,generatedCount,lastGeneratedAt,exportPath,isExporting]);

@override
String toString() {
  return 'PacketCodesState(status: $status, packetCodes: $packetCodes, filteredPacketCodes: $filteredPacketCodes, selectedPacketCodeIds: $selectedPacketCodeIds, searchQuery: $searchQuery, filterStatus: $filterStatus, filterCartonCode: $filterCartonCode, filterStartDate: $filterStartDate, filterEndDate: $filterEndDate, filterPacketType: $filterPacketType, filterCondition: $filterCondition, errorMessage: $errorMessage, hasReachedMax: $hasReachedMax, currentPage: $currentPage, totalCount: $totalCount, isLoadingMore: $isLoadingMore, generatedCount: $generatedCount, lastGeneratedAt: $lastGeneratedAt, exportPath: $exportPath, isExporting: $isExporting)';
}


}

/// @nodoc
abstract mixin class _$PacketCodesStateCopyWith<$Res> implements $PacketCodesStateCopyWith<$Res> {
  factory _$PacketCodesStateCopyWith(_PacketCodesState value, $Res Function(_PacketCodesState) _then) = __$PacketCodesStateCopyWithImpl;
@override @useResult
$Res call({
 PacketCodesStatus status, List<PacketCodeModel> packetCodes, List<PacketCodeModel> filteredPacketCodes, Set<String> selectedPacketCodeIds, String searchQuery, CodeStatus? filterStatus, String? filterCartonCode, DateTime? filterStartDate, DateTime? filterEndDate, String? filterPacketType, String? filterCondition, String? errorMessage, bool hasReachedMax, int currentPage, int totalCount, bool isLoadingMore, int generatedCount, DateTime? lastGeneratedAt, String? exportPath, bool isExporting
});




}
/// @nodoc
class __$PacketCodesStateCopyWithImpl<$Res>
    implements _$PacketCodesStateCopyWith<$Res> {
  __$PacketCodesStateCopyWithImpl(this._self, this._then);

  final _PacketCodesState _self;
  final $Res Function(_PacketCodesState) _then;

/// Create a copy of PacketCodesState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? packetCodes = null,Object? filteredPacketCodes = null,Object? selectedPacketCodeIds = null,Object? searchQuery = null,Object? filterStatus = freezed,Object? filterCartonCode = freezed,Object? filterStartDate = freezed,Object? filterEndDate = freezed,Object? filterPacketType = freezed,Object? filterCondition = freezed,Object? errorMessage = freezed,Object? hasReachedMax = null,Object? currentPage = null,Object? totalCount = null,Object? isLoadingMore = null,Object? generatedCount = null,Object? lastGeneratedAt = freezed,Object? exportPath = freezed,Object? isExporting = null,}) {
  return _then(_PacketCodesState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PacketCodesStatus,packetCodes: null == packetCodes ? _self._packetCodes : packetCodes // ignore: cast_nullable_to_non_nullable
as List<PacketCodeModel>,filteredPacketCodes: null == filteredPacketCodes ? _self._filteredPacketCodes : filteredPacketCodes // ignore: cast_nullable_to_non_nullable
as List<PacketCodeModel>,selectedPacketCodeIds: null == selectedPacketCodeIds ? _self._selectedPacketCodeIds : selectedPacketCodeIds // ignore: cast_nullable_to_non_nullable
as Set<String>,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,filterStatus: freezed == filterStatus ? _self.filterStatus : filterStatus // ignore: cast_nullable_to_non_nullable
as CodeStatus?,filterCartonCode: freezed == filterCartonCode ? _self.filterCartonCode : filterCartonCode // ignore: cast_nullable_to_non_nullable
as String?,filterStartDate: freezed == filterStartDate ? _self.filterStartDate : filterStartDate // ignore: cast_nullable_to_non_nullable
as DateTime?,filterEndDate: freezed == filterEndDate ? _self.filterEndDate : filterEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,filterPacketType: freezed == filterPacketType ? _self.filterPacketType : filterPacketType // ignore: cast_nullable_to_non_nullable
as String?,filterCondition: freezed == filterCondition ? _self.filterCondition : filterCondition // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
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

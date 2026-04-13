// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invoice_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$InvoiceEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvoiceEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'InvoiceEvent()';
}


}

/// @nodoc
class $InvoiceEventCopyWith<$Res>  {
$InvoiceEventCopyWith(InvoiceEvent _, $Res Function(InvoiceEvent) __);
}


/// Adds pattern-matching-related methods to [InvoiceEvent].
extension InvoiceEventPatterns on InvoiceEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LoadInvoiceDetail value)?  loadInvoiceDetail,TResult Function( LoadInvoicePayments value)?  loadInvoicePayments,TResult Function( ValidateInvoice value)?  validateInvoice,TResult Function( CalculateInvoiceTotals value)?  calculateInvoiceTotals,TResult Function( SearchInvoices value)?  searchInvoices,TResult Function( FilterInvoices value)?  filterInvoices,TResult Function( SortInvoices value)?  sortInvoices,TResult Function( ExportInvoiceDetail value)?  exportInvoiceDetail,TResult Function( SendInvoiceReminder value)?  sendInvoiceReminder,TResult Function( ApplyDiscount value)?  applyDiscount,TResult Function( AddInvoiceNote value)?  addInvoiceNote,TResult Function( GetInvoiceStatistics value)?  getInvoiceStatistics,TResult Function( GetInvoiceTrends value)?  getInvoiceTrends,TResult Function( ResetInvoiceState value)?  resetInvoiceState,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LoadInvoiceDetail() when loadInvoiceDetail != null:
return loadInvoiceDetail(_that);case LoadInvoicePayments() when loadInvoicePayments != null:
return loadInvoicePayments(_that);case ValidateInvoice() when validateInvoice != null:
return validateInvoice(_that);case CalculateInvoiceTotals() when calculateInvoiceTotals != null:
return calculateInvoiceTotals(_that);case SearchInvoices() when searchInvoices != null:
return searchInvoices(_that);case FilterInvoices() when filterInvoices != null:
return filterInvoices(_that);case SortInvoices() when sortInvoices != null:
return sortInvoices(_that);case ExportInvoiceDetail() when exportInvoiceDetail != null:
return exportInvoiceDetail(_that);case SendInvoiceReminder() when sendInvoiceReminder != null:
return sendInvoiceReminder(_that);case ApplyDiscount() when applyDiscount != null:
return applyDiscount(_that);case AddInvoiceNote() when addInvoiceNote != null:
return addInvoiceNote(_that);case GetInvoiceStatistics() when getInvoiceStatistics != null:
return getInvoiceStatistics(_that);case GetInvoiceTrends() when getInvoiceTrends != null:
return getInvoiceTrends(_that);case ResetInvoiceState() when resetInvoiceState != null:
return resetInvoiceState(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LoadInvoiceDetail value)  loadInvoiceDetail,required TResult Function( LoadInvoicePayments value)  loadInvoicePayments,required TResult Function( ValidateInvoice value)  validateInvoice,required TResult Function( CalculateInvoiceTotals value)  calculateInvoiceTotals,required TResult Function( SearchInvoices value)  searchInvoices,required TResult Function( FilterInvoices value)  filterInvoices,required TResult Function( SortInvoices value)  sortInvoices,required TResult Function( ExportInvoiceDetail value)  exportInvoiceDetail,required TResult Function( SendInvoiceReminder value)  sendInvoiceReminder,required TResult Function( ApplyDiscount value)  applyDiscount,required TResult Function( AddInvoiceNote value)  addInvoiceNote,required TResult Function( GetInvoiceStatistics value)  getInvoiceStatistics,required TResult Function( GetInvoiceTrends value)  getInvoiceTrends,required TResult Function( ResetInvoiceState value)  resetInvoiceState,}){
final _that = this;
switch (_that) {
case LoadInvoiceDetail():
return loadInvoiceDetail(_that);case LoadInvoicePayments():
return loadInvoicePayments(_that);case ValidateInvoice():
return validateInvoice(_that);case CalculateInvoiceTotals():
return calculateInvoiceTotals(_that);case SearchInvoices():
return searchInvoices(_that);case FilterInvoices():
return filterInvoices(_that);case SortInvoices():
return sortInvoices(_that);case ExportInvoiceDetail():
return exportInvoiceDetail(_that);case SendInvoiceReminder():
return sendInvoiceReminder(_that);case ApplyDiscount():
return applyDiscount(_that);case AddInvoiceNote():
return addInvoiceNote(_that);case GetInvoiceStatistics():
return getInvoiceStatistics(_that);case GetInvoiceTrends():
return getInvoiceTrends(_that);case ResetInvoiceState():
return resetInvoiceState(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LoadInvoiceDetail value)?  loadInvoiceDetail,TResult? Function( LoadInvoicePayments value)?  loadInvoicePayments,TResult? Function( ValidateInvoice value)?  validateInvoice,TResult? Function( CalculateInvoiceTotals value)?  calculateInvoiceTotals,TResult? Function( SearchInvoices value)?  searchInvoices,TResult? Function( FilterInvoices value)?  filterInvoices,TResult? Function( SortInvoices value)?  sortInvoices,TResult? Function( ExportInvoiceDetail value)?  exportInvoiceDetail,TResult? Function( SendInvoiceReminder value)?  sendInvoiceReminder,TResult? Function( ApplyDiscount value)?  applyDiscount,TResult? Function( AddInvoiceNote value)?  addInvoiceNote,TResult? Function( GetInvoiceStatistics value)?  getInvoiceStatistics,TResult? Function( GetInvoiceTrends value)?  getInvoiceTrends,TResult? Function( ResetInvoiceState value)?  resetInvoiceState,}){
final _that = this;
switch (_that) {
case LoadInvoiceDetail() when loadInvoiceDetail != null:
return loadInvoiceDetail(_that);case LoadInvoicePayments() when loadInvoicePayments != null:
return loadInvoicePayments(_that);case ValidateInvoice() when validateInvoice != null:
return validateInvoice(_that);case CalculateInvoiceTotals() when calculateInvoiceTotals != null:
return calculateInvoiceTotals(_that);case SearchInvoices() when searchInvoices != null:
return searchInvoices(_that);case FilterInvoices() when filterInvoices != null:
return filterInvoices(_that);case SortInvoices() when sortInvoices != null:
return sortInvoices(_that);case ExportInvoiceDetail() when exportInvoiceDetail != null:
return exportInvoiceDetail(_that);case SendInvoiceReminder() when sendInvoiceReminder != null:
return sendInvoiceReminder(_that);case ApplyDiscount() when applyDiscount != null:
return applyDiscount(_that);case AddInvoiceNote() when addInvoiceNote != null:
return addInvoiceNote(_that);case GetInvoiceStatistics() when getInvoiceStatistics != null:
return getInvoiceStatistics(_that);case GetInvoiceTrends() when getInvoiceTrends != null:
return getInvoiceTrends(_that);case ResetInvoiceState() when resetInvoiceState != null:
return resetInvoiceState(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String invoiceId)?  loadInvoiceDetail,TResult Function( String invoiceId)?  loadInvoicePayments,TResult Function( String invoiceId)?  validateInvoice,TResult Function( List<shared.InvoiceItem> items,  double? discountPercentage)?  calculateInvoiceTotals,TResult Function( String query,  int page,  int limit)?  searchInvoices,TResult Function( DateTime? startDate,  DateTime? endDate,  List<shared.InvoiceStatus>? statuses,  int page,  int limit)?  filterInvoices,TResult Function( String sortBy,  bool sortDesc,  DateTime? startDate,  DateTime? endDate,  List<shared.InvoiceStatus>? statuses,  int page,  int limit)?  sortInvoices,TResult Function( String invoiceId,  String format)?  exportInvoiceDetail,TResult Function( String invoiceId,  String reminderType)?  sendInvoiceReminder,TResult Function( String invoiceId,  double discountPercentage)?  applyDiscount,TResult Function( String invoiceId,  String note,  bool isAdminNote)?  addInvoiceNote,TResult Function( DateTime? startDate,  DateTime? endDate)?  getInvoiceStatistics,TResult Function( DateTime? startDate,  DateTime? endDate)?  getInvoiceTrends,TResult Function()?  resetInvoiceState,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LoadInvoiceDetail() when loadInvoiceDetail != null:
return loadInvoiceDetail(_that.invoiceId);case LoadInvoicePayments() when loadInvoicePayments != null:
return loadInvoicePayments(_that.invoiceId);case ValidateInvoice() when validateInvoice != null:
return validateInvoice(_that.invoiceId);case CalculateInvoiceTotals() when calculateInvoiceTotals != null:
return calculateInvoiceTotals(_that.items,_that.discountPercentage);case SearchInvoices() when searchInvoices != null:
return searchInvoices(_that.query,_that.page,_that.limit);case FilterInvoices() when filterInvoices != null:
return filterInvoices(_that.startDate,_that.endDate,_that.statuses,_that.page,_that.limit);case SortInvoices() when sortInvoices != null:
return sortInvoices(_that.sortBy,_that.sortDesc,_that.startDate,_that.endDate,_that.statuses,_that.page,_that.limit);case ExportInvoiceDetail() when exportInvoiceDetail != null:
return exportInvoiceDetail(_that.invoiceId,_that.format);case SendInvoiceReminder() when sendInvoiceReminder != null:
return sendInvoiceReminder(_that.invoiceId,_that.reminderType);case ApplyDiscount() when applyDiscount != null:
return applyDiscount(_that.invoiceId,_that.discountPercentage);case AddInvoiceNote() when addInvoiceNote != null:
return addInvoiceNote(_that.invoiceId,_that.note,_that.isAdminNote);case GetInvoiceStatistics() when getInvoiceStatistics != null:
return getInvoiceStatistics(_that.startDate,_that.endDate);case GetInvoiceTrends() when getInvoiceTrends != null:
return getInvoiceTrends(_that.startDate,_that.endDate);case ResetInvoiceState() when resetInvoiceState != null:
return resetInvoiceState();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String invoiceId)  loadInvoiceDetail,required TResult Function( String invoiceId)  loadInvoicePayments,required TResult Function( String invoiceId)  validateInvoice,required TResult Function( List<shared.InvoiceItem> items,  double? discountPercentage)  calculateInvoiceTotals,required TResult Function( String query,  int page,  int limit)  searchInvoices,required TResult Function( DateTime? startDate,  DateTime? endDate,  List<shared.InvoiceStatus>? statuses,  int page,  int limit)  filterInvoices,required TResult Function( String sortBy,  bool sortDesc,  DateTime? startDate,  DateTime? endDate,  List<shared.InvoiceStatus>? statuses,  int page,  int limit)  sortInvoices,required TResult Function( String invoiceId,  String format)  exportInvoiceDetail,required TResult Function( String invoiceId,  String reminderType)  sendInvoiceReminder,required TResult Function( String invoiceId,  double discountPercentage)  applyDiscount,required TResult Function( String invoiceId,  String note,  bool isAdminNote)  addInvoiceNote,required TResult Function( DateTime? startDate,  DateTime? endDate)  getInvoiceStatistics,required TResult Function( DateTime? startDate,  DateTime? endDate)  getInvoiceTrends,required TResult Function()  resetInvoiceState,}) {final _that = this;
switch (_that) {
case LoadInvoiceDetail():
return loadInvoiceDetail(_that.invoiceId);case LoadInvoicePayments():
return loadInvoicePayments(_that.invoiceId);case ValidateInvoice():
return validateInvoice(_that.invoiceId);case CalculateInvoiceTotals():
return calculateInvoiceTotals(_that.items,_that.discountPercentage);case SearchInvoices():
return searchInvoices(_that.query,_that.page,_that.limit);case FilterInvoices():
return filterInvoices(_that.startDate,_that.endDate,_that.statuses,_that.page,_that.limit);case SortInvoices():
return sortInvoices(_that.sortBy,_that.sortDesc,_that.startDate,_that.endDate,_that.statuses,_that.page,_that.limit);case ExportInvoiceDetail():
return exportInvoiceDetail(_that.invoiceId,_that.format);case SendInvoiceReminder():
return sendInvoiceReminder(_that.invoiceId,_that.reminderType);case ApplyDiscount():
return applyDiscount(_that.invoiceId,_that.discountPercentage);case AddInvoiceNote():
return addInvoiceNote(_that.invoiceId,_that.note,_that.isAdminNote);case GetInvoiceStatistics():
return getInvoiceStatistics(_that.startDate,_that.endDate);case GetInvoiceTrends():
return getInvoiceTrends(_that.startDate,_that.endDate);case ResetInvoiceState():
return resetInvoiceState();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String invoiceId)?  loadInvoiceDetail,TResult? Function( String invoiceId)?  loadInvoicePayments,TResult? Function( String invoiceId)?  validateInvoice,TResult? Function( List<shared.InvoiceItem> items,  double? discountPercentage)?  calculateInvoiceTotals,TResult? Function( String query,  int page,  int limit)?  searchInvoices,TResult? Function( DateTime? startDate,  DateTime? endDate,  List<shared.InvoiceStatus>? statuses,  int page,  int limit)?  filterInvoices,TResult? Function( String sortBy,  bool sortDesc,  DateTime? startDate,  DateTime? endDate,  List<shared.InvoiceStatus>? statuses,  int page,  int limit)?  sortInvoices,TResult? Function( String invoiceId,  String format)?  exportInvoiceDetail,TResult? Function( String invoiceId,  String reminderType)?  sendInvoiceReminder,TResult? Function( String invoiceId,  double discountPercentage)?  applyDiscount,TResult? Function( String invoiceId,  String note,  bool isAdminNote)?  addInvoiceNote,TResult? Function( DateTime? startDate,  DateTime? endDate)?  getInvoiceStatistics,TResult? Function( DateTime? startDate,  DateTime? endDate)?  getInvoiceTrends,TResult? Function()?  resetInvoiceState,}) {final _that = this;
switch (_that) {
case LoadInvoiceDetail() when loadInvoiceDetail != null:
return loadInvoiceDetail(_that.invoiceId);case LoadInvoicePayments() when loadInvoicePayments != null:
return loadInvoicePayments(_that.invoiceId);case ValidateInvoice() when validateInvoice != null:
return validateInvoice(_that.invoiceId);case CalculateInvoiceTotals() when calculateInvoiceTotals != null:
return calculateInvoiceTotals(_that.items,_that.discountPercentage);case SearchInvoices() when searchInvoices != null:
return searchInvoices(_that.query,_that.page,_that.limit);case FilterInvoices() when filterInvoices != null:
return filterInvoices(_that.startDate,_that.endDate,_that.statuses,_that.page,_that.limit);case SortInvoices() when sortInvoices != null:
return sortInvoices(_that.sortBy,_that.sortDesc,_that.startDate,_that.endDate,_that.statuses,_that.page,_that.limit);case ExportInvoiceDetail() when exportInvoiceDetail != null:
return exportInvoiceDetail(_that.invoiceId,_that.format);case SendInvoiceReminder() when sendInvoiceReminder != null:
return sendInvoiceReminder(_that.invoiceId,_that.reminderType);case ApplyDiscount() when applyDiscount != null:
return applyDiscount(_that.invoiceId,_that.discountPercentage);case AddInvoiceNote() when addInvoiceNote != null:
return addInvoiceNote(_that.invoiceId,_that.note,_that.isAdminNote);case GetInvoiceStatistics() when getInvoiceStatistics != null:
return getInvoiceStatistics(_that.startDate,_that.endDate);case GetInvoiceTrends() when getInvoiceTrends != null:
return getInvoiceTrends(_that.startDate,_that.endDate);case ResetInvoiceState() when resetInvoiceState != null:
return resetInvoiceState();case _:
  return null;

}
}

}

/// @nodoc


class LoadInvoiceDetail implements InvoiceEvent {
  const LoadInvoiceDetail({required this.invoiceId});
  

 final  String invoiceId;

/// Create a copy of InvoiceEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoadInvoiceDetailCopyWith<LoadInvoiceDetail> get copyWith => _$LoadInvoiceDetailCopyWithImpl<LoadInvoiceDetail>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoadInvoiceDetail&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId));
}


@override
int get hashCode => Object.hash(runtimeType,invoiceId);

@override
String toString() {
  return 'InvoiceEvent.loadInvoiceDetail(invoiceId: $invoiceId)';
}


}

/// @nodoc
abstract mixin class $LoadInvoiceDetailCopyWith<$Res> implements $InvoiceEventCopyWith<$Res> {
  factory $LoadInvoiceDetailCopyWith(LoadInvoiceDetail value, $Res Function(LoadInvoiceDetail) _then) = _$LoadInvoiceDetailCopyWithImpl;
@useResult
$Res call({
 String invoiceId
});




}
/// @nodoc
class _$LoadInvoiceDetailCopyWithImpl<$Res>
    implements $LoadInvoiceDetailCopyWith<$Res> {
  _$LoadInvoiceDetailCopyWithImpl(this._self, this._then);

  final LoadInvoiceDetail _self;
  final $Res Function(LoadInvoiceDetail) _then;

/// Create a copy of InvoiceEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? invoiceId = null,}) {
  return _then(LoadInvoiceDetail(
invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class LoadInvoicePayments implements InvoiceEvent {
  const LoadInvoicePayments({required this.invoiceId});
  

 final  String invoiceId;

/// Create a copy of InvoiceEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoadInvoicePaymentsCopyWith<LoadInvoicePayments> get copyWith => _$LoadInvoicePaymentsCopyWithImpl<LoadInvoicePayments>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoadInvoicePayments&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId));
}


@override
int get hashCode => Object.hash(runtimeType,invoiceId);

@override
String toString() {
  return 'InvoiceEvent.loadInvoicePayments(invoiceId: $invoiceId)';
}


}

/// @nodoc
abstract mixin class $LoadInvoicePaymentsCopyWith<$Res> implements $InvoiceEventCopyWith<$Res> {
  factory $LoadInvoicePaymentsCopyWith(LoadInvoicePayments value, $Res Function(LoadInvoicePayments) _then) = _$LoadInvoicePaymentsCopyWithImpl;
@useResult
$Res call({
 String invoiceId
});




}
/// @nodoc
class _$LoadInvoicePaymentsCopyWithImpl<$Res>
    implements $LoadInvoicePaymentsCopyWith<$Res> {
  _$LoadInvoicePaymentsCopyWithImpl(this._self, this._then);

  final LoadInvoicePayments _self;
  final $Res Function(LoadInvoicePayments) _then;

/// Create a copy of InvoiceEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? invoiceId = null,}) {
  return _then(LoadInvoicePayments(
invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ValidateInvoice implements InvoiceEvent {
  const ValidateInvoice({required this.invoiceId});
  

 final  String invoiceId;

/// Create a copy of InvoiceEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ValidateInvoiceCopyWith<ValidateInvoice> get copyWith => _$ValidateInvoiceCopyWithImpl<ValidateInvoice>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ValidateInvoice&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId));
}


@override
int get hashCode => Object.hash(runtimeType,invoiceId);

@override
String toString() {
  return 'InvoiceEvent.validateInvoice(invoiceId: $invoiceId)';
}


}

/// @nodoc
abstract mixin class $ValidateInvoiceCopyWith<$Res> implements $InvoiceEventCopyWith<$Res> {
  factory $ValidateInvoiceCopyWith(ValidateInvoice value, $Res Function(ValidateInvoice) _then) = _$ValidateInvoiceCopyWithImpl;
@useResult
$Res call({
 String invoiceId
});




}
/// @nodoc
class _$ValidateInvoiceCopyWithImpl<$Res>
    implements $ValidateInvoiceCopyWith<$Res> {
  _$ValidateInvoiceCopyWithImpl(this._self, this._then);

  final ValidateInvoice _self;
  final $Res Function(ValidateInvoice) _then;

/// Create a copy of InvoiceEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? invoiceId = null,}) {
  return _then(ValidateInvoice(
invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class CalculateInvoiceTotals implements InvoiceEvent {
  const CalculateInvoiceTotals({required final  List<shared.InvoiceItem> items, this.discountPercentage}): _items = items;
  

 final  List<shared.InvoiceItem> _items;
 List<shared.InvoiceItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

 final  double? discountPercentage;

/// Create a copy of InvoiceEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalculateInvoiceTotalsCopyWith<CalculateInvoiceTotals> get copyWith => _$CalculateInvoiceTotalsCopyWithImpl<CalculateInvoiceTotals>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalculateInvoiceTotals&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.discountPercentage, discountPercentage) || other.discountPercentage == discountPercentage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),discountPercentage);

@override
String toString() {
  return 'InvoiceEvent.calculateInvoiceTotals(items: $items, discountPercentage: $discountPercentage)';
}


}

/// @nodoc
abstract mixin class $CalculateInvoiceTotalsCopyWith<$Res> implements $InvoiceEventCopyWith<$Res> {
  factory $CalculateInvoiceTotalsCopyWith(CalculateInvoiceTotals value, $Res Function(CalculateInvoiceTotals) _then) = _$CalculateInvoiceTotalsCopyWithImpl;
@useResult
$Res call({
 List<shared.InvoiceItem> items, double? discountPercentage
});




}
/// @nodoc
class _$CalculateInvoiceTotalsCopyWithImpl<$Res>
    implements $CalculateInvoiceTotalsCopyWith<$Res> {
  _$CalculateInvoiceTotalsCopyWithImpl(this._self, this._then);

  final CalculateInvoiceTotals _self;
  final $Res Function(CalculateInvoiceTotals) _then;

/// Create a copy of InvoiceEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? items = null,Object? discountPercentage = freezed,}) {
  return _then(CalculateInvoiceTotals(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<shared.InvoiceItem>,discountPercentage: freezed == discountPercentage ? _self.discountPercentage : discountPercentage // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

/// @nodoc


class SearchInvoices implements InvoiceEvent {
  const SearchInvoices({required this.query, this.page = 1, this.limit = 20});
  

 final  String query;
@JsonKey() final  int page;
@JsonKey() final  int limit;

/// Create a copy of InvoiceEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchInvoicesCopyWith<SearchInvoices> get copyWith => _$SearchInvoicesCopyWithImpl<SearchInvoices>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchInvoices&&(identical(other.query, query) || other.query == query)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit));
}


@override
int get hashCode => Object.hash(runtimeType,query,page,limit);

@override
String toString() {
  return 'InvoiceEvent.searchInvoices(query: $query, page: $page, limit: $limit)';
}


}

/// @nodoc
abstract mixin class $SearchInvoicesCopyWith<$Res> implements $InvoiceEventCopyWith<$Res> {
  factory $SearchInvoicesCopyWith(SearchInvoices value, $Res Function(SearchInvoices) _then) = _$SearchInvoicesCopyWithImpl;
@useResult
$Res call({
 String query, int page, int limit
});




}
/// @nodoc
class _$SearchInvoicesCopyWithImpl<$Res>
    implements $SearchInvoicesCopyWith<$Res> {
  _$SearchInvoicesCopyWithImpl(this._self, this._then);

  final SearchInvoices _self;
  final $Res Function(SearchInvoices) _then;

/// Create a copy of InvoiceEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? query = null,Object? page = null,Object? limit = null,}) {
  return _then(SearchInvoices(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class FilterInvoices implements InvoiceEvent {
  const FilterInvoices({this.startDate, this.endDate, final  List<shared.InvoiceStatus>? statuses, this.page = 1, this.limit = 20}): _statuses = statuses;
  

 final  DateTime? startDate;
 final  DateTime? endDate;
 final  List<shared.InvoiceStatus>? _statuses;
 List<shared.InvoiceStatus>? get statuses {
  final value = _statuses;
  if (value == null) return null;
  if (_statuses is EqualUnmodifiableListView) return _statuses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@JsonKey() final  int page;
@JsonKey() final  int limit;

/// Create a copy of InvoiceEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FilterInvoicesCopyWith<FilterInvoices> get copyWith => _$FilterInvoicesCopyWithImpl<FilterInvoices>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FilterInvoices&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other._statuses, _statuses)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit));
}


@override
int get hashCode => Object.hash(runtimeType,startDate,endDate,const DeepCollectionEquality().hash(_statuses),page,limit);

@override
String toString() {
  return 'InvoiceEvent.filterInvoices(startDate: $startDate, endDate: $endDate, statuses: $statuses, page: $page, limit: $limit)';
}


}

/// @nodoc
abstract mixin class $FilterInvoicesCopyWith<$Res> implements $InvoiceEventCopyWith<$Res> {
  factory $FilterInvoicesCopyWith(FilterInvoices value, $Res Function(FilterInvoices) _then) = _$FilterInvoicesCopyWithImpl;
@useResult
$Res call({
 DateTime? startDate, DateTime? endDate, List<shared.InvoiceStatus>? statuses, int page, int limit
});




}
/// @nodoc
class _$FilterInvoicesCopyWithImpl<$Res>
    implements $FilterInvoicesCopyWith<$Res> {
  _$FilterInvoicesCopyWithImpl(this._self, this._then);

  final FilterInvoices _self;
  final $Res Function(FilterInvoices) _then;

/// Create a copy of InvoiceEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? startDate = freezed,Object? endDate = freezed,Object? statuses = freezed,Object? page = null,Object? limit = null,}) {
  return _then(FilterInvoices(
startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,statuses: freezed == statuses ? _self._statuses : statuses // ignore: cast_nullable_to_non_nullable
as List<shared.InvoiceStatus>?,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class SortInvoices implements InvoiceEvent {
  const SortInvoices({required this.sortBy, this.sortDesc = true, this.startDate, this.endDate, final  List<shared.InvoiceStatus>? statuses, this.page = 1, this.limit = 20}): _statuses = statuses;
  

 final  String sortBy;
@JsonKey() final  bool sortDesc;
 final  DateTime? startDate;
 final  DateTime? endDate;
 final  List<shared.InvoiceStatus>? _statuses;
 List<shared.InvoiceStatus>? get statuses {
  final value = _statuses;
  if (value == null) return null;
  if (_statuses is EqualUnmodifiableListView) return _statuses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@JsonKey() final  int page;
@JsonKey() final  int limit;

/// Create a copy of InvoiceEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SortInvoicesCopyWith<SortInvoices> get copyWith => _$SortInvoicesCopyWithImpl<SortInvoices>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SortInvoices&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.sortDesc, sortDesc) || other.sortDesc == sortDesc)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other._statuses, _statuses)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit));
}


@override
int get hashCode => Object.hash(runtimeType,sortBy,sortDesc,startDate,endDate,const DeepCollectionEquality().hash(_statuses),page,limit);

@override
String toString() {
  return 'InvoiceEvent.sortInvoices(sortBy: $sortBy, sortDesc: $sortDesc, startDate: $startDate, endDate: $endDate, statuses: $statuses, page: $page, limit: $limit)';
}


}

/// @nodoc
abstract mixin class $SortInvoicesCopyWith<$Res> implements $InvoiceEventCopyWith<$Res> {
  factory $SortInvoicesCopyWith(SortInvoices value, $Res Function(SortInvoices) _then) = _$SortInvoicesCopyWithImpl;
@useResult
$Res call({
 String sortBy, bool sortDesc, DateTime? startDate, DateTime? endDate, List<shared.InvoiceStatus>? statuses, int page, int limit
});




}
/// @nodoc
class _$SortInvoicesCopyWithImpl<$Res>
    implements $SortInvoicesCopyWith<$Res> {
  _$SortInvoicesCopyWithImpl(this._self, this._then);

  final SortInvoices _self;
  final $Res Function(SortInvoices) _then;

/// Create a copy of InvoiceEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? sortBy = null,Object? sortDesc = null,Object? startDate = freezed,Object? endDate = freezed,Object? statuses = freezed,Object? page = null,Object? limit = null,}) {
  return _then(SortInvoices(
sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as String,sortDesc: null == sortDesc ? _self.sortDesc : sortDesc // ignore: cast_nullable_to_non_nullable
as bool,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,statuses: freezed == statuses ? _self._statuses : statuses // ignore: cast_nullable_to_non_nullable
as List<shared.InvoiceStatus>?,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class ExportInvoiceDetail implements InvoiceEvent {
  const ExportInvoiceDetail({required this.invoiceId, this.format = 'pdf'});
  

 final  String invoiceId;
@JsonKey() final  String format;

/// Create a copy of InvoiceEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExportInvoiceDetailCopyWith<ExportInvoiceDetail> get copyWith => _$ExportInvoiceDetailCopyWithImpl<ExportInvoiceDetail>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExportInvoiceDetail&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.format, format) || other.format == format));
}


@override
int get hashCode => Object.hash(runtimeType,invoiceId,format);

@override
String toString() {
  return 'InvoiceEvent.exportInvoiceDetail(invoiceId: $invoiceId, format: $format)';
}


}

/// @nodoc
abstract mixin class $ExportInvoiceDetailCopyWith<$Res> implements $InvoiceEventCopyWith<$Res> {
  factory $ExportInvoiceDetailCopyWith(ExportInvoiceDetail value, $Res Function(ExportInvoiceDetail) _then) = _$ExportInvoiceDetailCopyWithImpl;
@useResult
$Res call({
 String invoiceId, String format
});




}
/// @nodoc
class _$ExportInvoiceDetailCopyWithImpl<$Res>
    implements $ExportInvoiceDetailCopyWith<$Res> {
  _$ExportInvoiceDetailCopyWithImpl(this._self, this._then);

  final ExportInvoiceDetail _self;
  final $Res Function(ExportInvoiceDetail) _then;

/// Create a copy of InvoiceEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? invoiceId = null,Object? format = null,}) {
  return _then(ExportInvoiceDetail(
invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SendInvoiceReminder implements InvoiceEvent {
  const SendInvoiceReminder({required this.invoiceId, this.reminderType = 'payment_due'});
  

 final  String invoiceId;
@JsonKey() final  String reminderType;

/// Create a copy of InvoiceEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SendInvoiceReminderCopyWith<SendInvoiceReminder> get copyWith => _$SendInvoiceReminderCopyWithImpl<SendInvoiceReminder>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SendInvoiceReminder&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.reminderType, reminderType) || other.reminderType == reminderType));
}


@override
int get hashCode => Object.hash(runtimeType,invoiceId,reminderType);

@override
String toString() {
  return 'InvoiceEvent.sendInvoiceReminder(invoiceId: $invoiceId, reminderType: $reminderType)';
}


}

/// @nodoc
abstract mixin class $SendInvoiceReminderCopyWith<$Res> implements $InvoiceEventCopyWith<$Res> {
  factory $SendInvoiceReminderCopyWith(SendInvoiceReminder value, $Res Function(SendInvoiceReminder) _then) = _$SendInvoiceReminderCopyWithImpl;
@useResult
$Res call({
 String invoiceId, String reminderType
});




}
/// @nodoc
class _$SendInvoiceReminderCopyWithImpl<$Res>
    implements $SendInvoiceReminderCopyWith<$Res> {
  _$SendInvoiceReminderCopyWithImpl(this._self, this._then);

  final SendInvoiceReminder _self;
  final $Res Function(SendInvoiceReminder) _then;

/// Create a copy of InvoiceEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? invoiceId = null,Object? reminderType = null,}) {
  return _then(SendInvoiceReminder(
invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,reminderType: null == reminderType ? _self.reminderType : reminderType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ApplyDiscount implements InvoiceEvent {
  const ApplyDiscount({required this.invoiceId, required this.discountPercentage});
  

 final  String invoiceId;
 final  double discountPercentage;

/// Create a copy of InvoiceEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApplyDiscountCopyWith<ApplyDiscount> get copyWith => _$ApplyDiscountCopyWithImpl<ApplyDiscount>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApplyDiscount&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.discountPercentage, discountPercentage) || other.discountPercentage == discountPercentage));
}


@override
int get hashCode => Object.hash(runtimeType,invoiceId,discountPercentage);

@override
String toString() {
  return 'InvoiceEvent.applyDiscount(invoiceId: $invoiceId, discountPercentage: $discountPercentage)';
}


}

/// @nodoc
abstract mixin class $ApplyDiscountCopyWith<$Res> implements $InvoiceEventCopyWith<$Res> {
  factory $ApplyDiscountCopyWith(ApplyDiscount value, $Res Function(ApplyDiscount) _then) = _$ApplyDiscountCopyWithImpl;
@useResult
$Res call({
 String invoiceId, double discountPercentage
});




}
/// @nodoc
class _$ApplyDiscountCopyWithImpl<$Res>
    implements $ApplyDiscountCopyWith<$Res> {
  _$ApplyDiscountCopyWithImpl(this._self, this._then);

  final ApplyDiscount _self;
  final $Res Function(ApplyDiscount) _then;

/// Create a copy of InvoiceEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? invoiceId = null,Object? discountPercentage = null,}) {
  return _then(ApplyDiscount(
invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,discountPercentage: null == discountPercentage ? _self.discountPercentage : discountPercentage // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc


class AddInvoiceNote implements InvoiceEvent {
  const AddInvoiceNote({required this.invoiceId, required this.note, this.isAdminNote = false});
  

 final  String invoiceId;
 final  String note;
@JsonKey() final  bool isAdminNote;

/// Create a copy of InvoiceEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddInvoiceNoteCopyWith<AddInvoiceNote> get copyWith => _$AddInvoiceNoteCopyWithImpl<AddInvoiceNote>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddInvoiceNote&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.note, note) || other.note == note)&&(identical(other.isAdminNote, isAdminNote) || other.isAdminNote == isAdminNote));
}


@override
int get hashCode => Object.hash(runtimeType,invoiceId,note,isAdminNote);

@override
String toString() {
  return 'InvoiceEvent.addInvoiceNote(invoiceId: $invoiceId, note: $note, isAdminNote: $isAdminNote)';
}


}

/// @nodoc
abstract mixin class $AddInvoiceNoteCopyWith<$Res> implements $InvoiceEventCopyWith<$Res> {
  factory $AddInvoiceNoteCopyWith(AddInvoiceNote value, $Res Function(AddInvoiceNote) _then) = _$AddInvoiceNoteCopyWithImpl;
@useResult
$Res call({
 String invoiceId, String note, bool isAdminNote
});




}
/// @nodoc
class _$AddInvoiceNoteCopyWithImpl<$Res>
    implements $AddInvoiceNoteCopyWith<$Res> {
  _$AddInvoiceNoteCopyWithImpl(this._self, this._then);

  final AddInvoiceNote _self;
  final $Res Function(AddInvoiceNote) _then;

/// Create a copy of InvoiceEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? invoiceId = null,Object? note = null,Object? isAdminNote = null,}) {
  return _then(AddInvoiceNote(
invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,isAdminNote: null == isAdminNote ? _self.isAdminNote : isAdminNote // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class GetInvoiceStatistics implements InvoiceEvent {
  const GetInvoiceStatistics({this.startDate, this.endDate});
  

 final  DateTime? startDate;
 final  DateTime? endDate;

/// Create a copy of InvoiceEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetInvoiceStatisticsCopyWith<GetInvoiceStatistics> get copyWith => _$GetInvoiceStatisticsCopyWithImpl<GetInvoiceStatistics>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetInvoiceStatistics&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}


@override
int get hashCode => Object.hash(runtimeType,startDate,endDate);

@override
String toString() {
  return 'InvoiceEvent.getInvoiceStatistics(startDate: $startDate, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class $GetInvoiceStatisticsCopyWith<$Res> implements $InvoiceEventCopyWith<$Res> {
  factory $GetInvoiceStatisticsCopyWith(GetInvoiceStatistics value, $Res Function(GetInvoiceStatistics) _then) = _$GetInvoiceStatisticsCopyWithImpl;
@useResult
$Res call({
 DateTime? startDate, DateTime? endDate
});




}
/// @nodoc
class _$GetInvoiceStatisticsCopyWithImpl<$Res>
    implements $GetInvoiceStatisticsCopyWith<$Res> {
  _$GetInvoiceStatisticsCopyWithImpl(this._self, this._then);

  final GetInvoiceStatistics _self;
  final $Res Function(GetInvoiceStatistics) _then;

/// Create a copy of InvoiceEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? startDate = freezed,Object? endDate = freezed,}) {
  return _then(GetInvoiceStatistics(
startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc


class GetInvoiceTrends implements InvoiceEvent {
  const GetInvoiceTrends({this.startDate, this.endDate});
  

 final  DateTime? startDate;
 final  DateTime? endDate;

/// Create a copy of InvoiceEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetInvoiceTrendsCopyWith<GetInvoiceTrends> get copyWith => _$GetInvoiceTrendsCopyWithImpl<GetInvoiceTrends>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetInvoiceTrends&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}


@override
int get hashCode => Object.hash(runtimeType,startDate,endDate);

@override
String toString() {
  return 'InvoiceEvent.getInvoiceTrends(startDate: $startDate, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class $GetInvoiceTrendsCopyWith<$Res> implements $InvoiceEventCopyWith<$Res> {
  factory $GetInvoiceTrendsCopyWith(GetInvoiceTrends value, $Res Function(GetInvoiceTrends) _then) = _$GetInvoiceTrendsCopyWithImpl;
@useResult
$Res call({
 DateTime? startDate, DateTime? endDate
});




}
/// @nodoc
class _$GetInvoiceTrendsCopyWithImpl<$Res>
    implements $GetInvoiceTrendsCopyWith<$Res> {
  _$GetInvoiceTrendsCopyWithImpl(this._self, this._then);

  final GetInvoiceTrends _self;
  final $Res Function(GetInvoiceTrends) _then;

/// Create a copy of InvoiceEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? startDate = freezed,Object? endDate = freezed,}) {
  return _then(GetInvoiceTrends(
startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc


class ResetInvoiceState implements InvoiceEvent {
  const ResetInvoiceState();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResetInvoiceState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'InvoiceEvent.resetInvoiceState()';
}


}




// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'billing_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BillingEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillingEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BillingEvent()';
}


}

/// @nodoc
class $BillingEventCopyWith<$Res>  {
$BillingEventCopyWith(BillingEvent _, $Res Function(BillingEvent) __);
}


/// Adds pattern-matching-related methods to [BillingEvent].
extension BillingEventPatterns on BillingEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LoadBillingSummary value)?  loadBillingSummary,TResult Function( LoadInvoices value)?  loadInvoices,TResult Function( LoadInvoice value)?  loadInvoice,TResult Function( LoadPaymentHistory value)?  loadPaymentHistory,TResult Function( MakePayment value)?  makePayment,TResult Function( DownloadInvoice value)?  downloadInvoice,TResult Function( SendInvoiceEmail value)?  sendInvoiceEmail,TResult Function( RefreshBilling value)?  refresh,TResult Function( ClearBillingError value)?  clearError,TResult Function( ResetBilling value)?  reset,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LoadBillingSummary() when loadBillingSummary != null:
return loadBillingSummary(_that);case LoadInvoices() when loadInvoices != null:
return loadInvoices(_that);case LoadInvoice() when loadInvoice != null:
return loadInvoice(_that);case LoadPaymentHistory() when loadPaymentHistory != null:
return loadPaymentHistory(_that);case MakePayment() when makePayment != null:
return makePayment(_that);case DownloadInvoice() when downloadInvoice != null:
return downloadInvoice(_that);case SendInvoiceEmail() when sendInvoiceEmail != null:
return sendInvoiceEmail(_that);case RefreshBilling() when refresh != null:
return refresh(_that);case ClearBillingError() when clearError != null:
return clearError(_that);case ResetBilling() when reset != null:
return reset(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LoadBillingSummary value)  loadBillingSummary,required TResult Function( LoadInvoices value)  loadInvoices,required TResult Function( LoadInvoice value)  loadInvoice,required TResult Function( LoadPaymentHistory value)  loadPaymentHistory,required TResult Function( MakePayment value)  makePayment,required TResult Function( DownloadInvoice value)  downloadInvoice,required TResult Function( SendInvoiceEmail value)  sendInvoiceEmail,required TResult Function( RefreshBilling value)  refresh,required TResult Function( ClearBillingError value)  clearError,required TResult Function( ResetBilling value)  reset,}){
final _that = this;
switch (_that) {
case LoadBillingSummary():
return loadBillingSummary(_that);case LoadInvoices():
return loadInvoices(_that);case LoadInvoice():
return loadInvoice(_that);case LoadPaymentHistory():
return loadPaymentHistory(_that);case MakePayment():
return makePayment(_that);case DownloadInvoice():
return downloadInvoice(_that);case SendInvoiceEmail():
return sendInvoiceEmail(_that);case RefreshBilling():
return refresh(_that);case ClearBillingError():
return clearError(_that);case ResetBilling():
return reset(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LoadBillingSummary value)?  loadBillingSummary,TResult? Function( LoadInvoices value)?  loadInvoices,TResult? Function( LoadInvoice value)?  loadInvoice,TResult? Function( LoadPaymentHistory value)?  loadPaymentHistory,TResult? Function( MakePayment value)?  makePayment,TResult? Function( DownloadInvoice value)?  downloadInvoice,TResult? Function( SendInvoiceEmail value)?  sendInvoiceEmail,TResult? Function( RefreshBilling value)?  refresh,TResult? Function( ClearBillingError value)?  clearError,TResult? Function( ResetBilling value)?  reset,}){
final _that = this;
switch (_that) {
case LoadBillingSummary() when loadBillingSummary != null:
return loadBillingSummary(_that);case LoadInvoices() when loadInvoices != null:
return loadInvoices(_that);case LoadInvoice() when loadInvoice != null:
return loadInvoice(_that);case LoadPaymentHistory() when loadPaymentHistory != null:
return loadPaymentHistory(_that);case MakePayment() when makePayment != null:
return makePayment(_that);case DownloadInvoice() when downloadInvoice != null:
return downloadInvoice(_that);case SendInvoiceEmail() when sendInvoiceEmail != null:
return sendInvoiceEmail(_that);case RefreshBilling() when refresh != null:
return refresh(_that);case ClearBillingError() when clearError != null:
return clearError(_that);case ResetBilling() when reset != null:
return reset(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loadBillingSummary,TResult Function( BillingFilter? filter)?  loadInvoices,TResult Function( String invoiceId)?  loadInvoice,TResult Function( BillingFilter? filter)?  loadPaymentHistory,TResult Function( String invoiceId,  double amount,  PaymentMethod paymentMethod,  String? reference,  String? notes)?  makePayment,TResult Function( String invoiceId)?  downloadInvoice,TResult Function( String invoiceId,  String? email)?  sendInvoiceEmail,TResult Function()?  refresh,TResult Function()?  clearError,TResult Function()?  reset,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LoadBillingSummary() when loadBillingSummary != null:
return loadBillingSummary();case LoadInvoices() when loadInvoices != null:
return loadInvoices(_that.filter);case LoadInvoice() when loadInvoice != null:
return loadInvoice(_that.invoiceId);case LoadPaymentHistory() when loadPaymentHistory != null:
return loadPaymentHistory(_that.filter);case MakePayment() when makePayment != null:
return makePayment(_that.invoiceId,_that.amount,_that.paymentMethod,_that.reference,_that.notes);case DownloadInvoice() when downloadInvoice != null:
return downloadInvoice(_that.invoiceId);case SendInvoiceEmail() when sendInvoiceEmail != null:
return sendInvoiceEmail(_that.invoiceId,_that.email);case RefreshBilling() when refresh != null:
return refresh();case ClearBillingError() when clearError != null:
return clearError();case ResetBilling() when reset != null:
return reset();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loadBillingSummary,required TResult Function( BillingFilter? filter)  loadInvoices,required TResult Function( String invoiceId)  loadInvoice,required TResult Function( BillingFilter? filter)  loadPaymentHistory,required TResult Function( String invoiceId,  double amount,  PaymentMethod paymentMethod,  String? reference,  String? notes)  makePayment,required TResult Function( String invoiceId)  downloadInvoice,required TResult Function( String invoiceId,  String? email)  sendInvoiceEmail,required TResult Function()  refresh,required TResult Function()  clearError,required TResult Function()  reset,}) {final _that = this;
switch (_that) {
case LoadBillingSummary():
return loadBillingSummary();case LoadInvoices():
return loadInvoices(_that.filter);case LoadInvoice():
return loadInvoice(_that.invoiceId);case LoadPaymentHistory():
return loadPaymentHistory(_that.filter);case MakePayment():
return makePayment(_that.invoiceId,_that.amount,_that.paymentMethod,_that.reference,_that.notes);case DownloadInvoice():
return downloadInvoice(_that.invoiceId);case SendInvoiceEmail():
return sendInvoiceEmail(_that.invoiceId,_that.email);case RefreshBilling():
return refresh();case ClearBillingError():
return clearError();case ResetBilling():
return reset();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loadBillingSummary,TResult? Function( BillingFilter? filter)?  loadInvoices,TResult? Function( String invoiceId)?  loadInvoice,TResult? Function( BillingFilter? filter)?  loadPaymentHistory,TResult? Function( String invoiceId,  double amount,  PaymentMethod paymentMethod,  String? reference,  String? notes)?  makePayment,TResult? Function( String invoiceId)?  downloadInvoice,TResult? Function( String invoiceId,  String? email)?  sendInvoiceEmail,TResult? Function()?  refresh,TResult? Function()?  clearError,TResult? Function()?  reset,}) {final _that = this;
switch (_that) {
case LoadBillingSummary() when loadBillingSummary != null:
return loadBillingSummary();case LoadInvoices() when loadInvoices != null:
return loadInvoices(_that.filter);case LoadInvoice() when loadInvoice != null:
return loadInvoice(_that.invoiceId);case LoadPaymentHistory() when loadPaymentHistory != null:
return loadPaymentHistory(_that.filter);case MakePayment() when makePayment != null:
return makePayment(_that.invoiceId,_that.amount,_that.paymentMethod,_that.reference,_that.notes);case DownloadInvoice() when downloadInvoice != null:
return downloadInvoice(_that.invoiceId);case SendInvoiceEmail() when sendInvoiceEmail != null:
return sendInvoiceEmail(_that.invoiceId,_that.email);case RefreshBilling() when refresh != null:
return refresh();case ClearBillingError() when clearError != null:
return clearError();case ResetBilling() when reset != null:
return reset();case _:
  return null;

}
}

}

/// @nodoc


class LoadBillingSummary implements BillingEvent {
  const LoadBillingSummary();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoadBillingSummary);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BillingEvent.loadBillingSummary()';
}


}




/// @nodoc


class LoadInvoices implements BillingEvent {
  const LoadInvoices({this.filter});
  

 final  BillingFilter? filter;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoadInvoicesCopyWith<LoadInvoices> get copyWith => _$LoadInvoicesCopyWithImpl<LoadInvoices>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoadInvoices&&(identical(other.filter, filter) || other.filter == filter));
}


@override
int get hashCode => Object.hash(runtimeType,filter);

@override
String toString() {
  return 'BillingEvent.loadInvoices(filter: $filter)';
}


}

/// @nodoc
abstract mixin class $LoadInvoicesCopyWith<$Res> implements $BillingEventCopyWith<$Res> {
  factory $LoadInvoicesCopyWith(LoadInvoices value, $Res Function(LoadInvoices) _then) = _$LoadInvoicesCopyWithImpl;
@useResult
$Res call({
 BillingFilter? filter
});


$BillingFilterCopyWith<$Res>? get filter;

}
/// @nodoc
class _$LoadInvoicesCopyWithImpl<$Res>
    implements $LoadInvoicesCopyWith<$Res> {
  _$LoadInvoicesCopyWithImpl(this._self, this._then);

  final LoadInvoices _self;
  final $Res Function(LoadInvoices) _then;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? filter = freezed,}) {
  return _then(LoadInvoices(
filter: freezed == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as BillingFilter?,
  ));
}

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BillingFilterCopyWith<$Res>? get filter {
    if (_self.filter == null) {
    return null;
  }

  return $BillingFilterCopyWith<$Res>(_self.filter!, (value) {
    return _then(_self.copyWith(filter: value));
  });
}
}

/// @nodoc


class LoadInvoice implements BillingEvent {
  const LoadInvoice({required this.invoiceId});
  

 final  String invoiceId;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoadInvoiceCopyWith<LoadInvoice> get copyWith => _$LoadInvoiceCopyWithImpl<LoadInvoice>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoadInvoice&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId));
}


@override
int get hashCode => Object.hash(runtimeType,invoiceId);

@override
String toString() {
  return 'BillingEvent.loadInvoice(invoiceId: $invoiceId)';
}


}

/// @nodoc
abstract mixin class $LoadInvoiceCopyWith<$Res> implements $BillingEventCopyWith<$Res> {
  factory $LoadInvoiceCopyWith(LoadInvoice value, $Res Function(LoadInvoice) _then) = _$LoadInvoiceCopyWithImpl;
@useResult
$Res call({
 String invoiceId
});




}
/// @nodoc
class _$LoadInvoiceCopyWithImpl<$Res>
    implements $LoadInvoiceCopyWith<$Res> {
  _$LoadInvoiceCopyWithImpl(this._self, this._then);

  final LoadInvoice _self;
  final $Res Function(LoadInvoice) _then;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? invoiceId = null,}) {
  return _then(LoadInvoice(
invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class LoadPaymentHistory implements BillingEvent {
  const LoadPaymentHistory({this.filter});
  

 final  BillingFilter? filter;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoadPaymentHistoryCopyWith<LoadPaymentHistory> get copyWith => _$LoadPaymentHistoryCopyWithImpl<LoadPaymentHistory>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoadPaymentHistory&&(identical(other.filter, filter) || other.filter == filter));
}


@override
int get hashCode => Object.hash(runtimeType,filter);

@override
String toString() {
  return 'BillingEvent.loadPaymentHistory(filter: $filter)';
}


}

/// @nodoc
abstract mixin class $LoadPaymentHistoryCopyWith<$Res> implements $BillingEventCopyWith<$Res> {
  factory $LoadPaymentHistoryCopyWith(LoadPaymentHistory value, $Res Function(LoadPaymentHistory) _then) = _$LoadPaymentHistoryCopyWithImpl;
@useResult
$Res call({
 BillingFilter? filter
});


$BillingFilterCopyWith<$Res>? get filter;

}
/// @nodoc
class _$LoadPaymentHistoryCopyWithImpl<$Res>
    implements $LoadPaymentHistoryCopyWith<$Res> {
  _$LoadPaymentHistoryCopyWithImpl(this._self, this._then);

  final LoadPaymentHistory _self;
  final $Res Function(LoadPaymentHistory) _then;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? filter = freezed,}) {
  return _then(LoadPaymentHistory(
filter: freezed == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as BillingFilter?,
  ));
}

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BillingFilterCopyWith<$Res>? get filter {
    if (_self.filter == null) {
    return null;
  }

  return $BillingFilterCopyWith<$Res>(_self.filter!, (value) {
    return _then(_self.copyWith(filter: value));
  });
}
}

/// @nodoc


class MakePayment implements BillingEvent {
  const MakePayment({required this.invoiceId, required this.amount, required this.paymentMethod, this.reference, this.notes});
  

 final  String invoiceId;
 final  double amount;
 final  PaymentMethod paymentMethod;
 final  String? reference;
 final  String? notes;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MakePaymentCopyWith<MakePayment> get copyWith => _$MakePaymentCopyWithImpl<MakePayment>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MakePayment&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.notes, notes) || other.notes == notes));
}


@override
int get hashCode => Object.hash(runtimeType,invoiceId,amount,paymentMethod,reference,notes);

@override
String toString() {
  return 'BillingEvent.makePayment(invoiceId: $invoiceId, amount: $amount, paymentMethod: $paymentMethod, reference: $reference, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $MakePaymentCopyWith<$Res> implements $BillingEventCopyWith<$Res> {
  factory $MakePaymentCopyWith(MakePayment value, $Res Function(MakePayment) _then) = _$MakePaymentCopyWithImpl;
@useResult
$Res call({
 String invoiceId, double amount, PaymentMethod paymentMethod, String? reference, String? notes
});




}
/// @nodoc
class _$MakePaymentCopyWithImpl<$Res>
    implements $MakePaymentCopyWith<$Res> {
  _$MakePaymentCopyWithImpl(this._self, this._then);

  final MakePayment _self;
  final $Res Function(MakePayment) _then;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? invoiceId = null,Object? amount = null,Object? paymentMethod = null,Object? reference = freezed,Object? notes = freezed,}) {
  return _then(MakePayment(
invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class DownloadInvoice implements BillingEvent {
  const DownloadInvoice({required this.invoiceId});
  

 final  String invoiceId;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DownloadInvoiceCopyWith<DownloadInvoice> get copyWith => _$DownloadInvoiceCopyWithImpl<DownloadInvoice>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadInvoice&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId));
}


@override
int get hashCode => Object.hash(runtimeType,invoiceId);

@override
String toString() {
  return 'BillingEvent.downloadInvoice(invoiceId: $invoiceId)';
}


}

/// @nodoc
abstract mixin class $DownloadInvoiceCopyWith<$Res> implements $BillingEventCopyWith<$Res> {
  factory $DownloadInvoiceCopyWith(DownloadInvoice value, $Res Function(DownloadInvoice) _then) = _$DownloadInvoiceCopyWithImpl;
@useResult
$Res call({
 String invoiceId
});




}
/// @nodoc
class _$DownloadInvoiceCopyWithImpl<$Res>
    implements $DownloadInvoiceCopyWith<$Res> {
  _$DownloadInvoiceCopyWithImpl(this._self, this._then);

  final DownloadInvoice _self;
  final $Res Function(DownloadInvoice) _then;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? invoiceId = null,}) {
  return _then(DownloadInvoice(
invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SendInvoiceEmail implements BillingEvent {
  const SendInvoiceEmail({required this.invoiceId, this.email});
  

 final  String invoiceId;
 final  String? email;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SendInvoiceEmailCopyWith<SendInvoiceEmail> get copyWith => _$SendInvoiceEmailCopyWithImpl<SendInvoiceEmail>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SendInvoiceEmail&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.email, email) || other.email == email));
}


@override
int get hashCode => Object.hash(runtimeType,invoiceId,email);

@override
String toString() {
  return 'BillingEvent.sendInvoiceEmail(invoiceId: $invoiceId, email: $email)';
}


}

/// @nodoc
abstract mixin class $SendInvoiceEmailCopyWith<$Res> implements $BillingEventCopyWith<$Res> {
  factory $SendInvoiceEmailCopyWith(SendInvoiceEmail value, $Res Function(SendInvoiceEmail) _then) = _$SendInvoiceEmailCopyWithImpl;
@useResult
$Res call({
 String invoiceId, String? email
});




}
/// @nodoc
class _$SendInvoiceEmailCopyWithImpl<$Res>
    implements $SendInvoiceEmailCopyWith<$Res> {
  _$SendInvoiceEmailCopyWithImpl(this._self, this._then);

  final SendInvoiceEmail _self;
  final $Res Function(SendInvoiceEmail) _then;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? invoiceId = null,Object? email = freezed,}) {
  return _then(SendInvoiceEmail(
invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class RefreshBilling implements BillingEvent {
  const RefreshBilling();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RefreshBilling);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BillingEvent.refresh()';
}


}




/// @nodoc


class ClearBillingError implements BillingEvent {
  const ClearBillingError();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClearBillingError);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BillingEvent.clearError()';
}


}




/// @nodoc


class ResetBilling implements BillingEvent {
  const ResetBilling();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResetBilling);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BillingEvent.reset()';
}


}




/// @nodoc
mixin _$BillingState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillingState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BillingState()';
}


}

/// @nodoc
class $BillingStateCopyWith<$Res>  {
$BillingStateCopyWith(BillingState _, $Res Function(BillingState) __);
}


/// Adds pattern-matching-related methods to [BillingState].
extension BillingStatePatterns on BillingState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( BillingInitial value)?  initial,TResult Function( BillingLoading value)?  loading,TResult Function( BillingSummaryLoaded value)?  summaryLoaded,TResult Function( BillingInvoicesLoaded value)?  invoicesLoaded,TResult Function( BillingInvoiceDetailLoaded value)?  invoiceDetailLoaded,TResult Function( BillingPaymentHistoryLoaded value)?  paymentHistoryLoaded,TResult Function( BillingPaymentProcessing value)?  paymentProcessing,TResult Function( BillingPaymentSuccess value)?  paymentSuccess,TResult Function( BillingInvoiceDownloading value)?  invoiceDownloading,TResult Function( BillingInvoiceDownloadSuccess value)?  invoiceDownloadSuccess,TResult Function( BillingInvoiceEmailSending value)?  invoiceEmailSending,TResult Function( BillingInvoiceEmailSent value)?  invoiceEmailSent,TResult Function( BillingError value)?  error,TResult Function( BillingEmpty value)?  empty,required TResult orElse(),}){
final _that = this;
switch (_that) {
case BillingInitial() when initial != null:
return initial(_that);case BillingLoading() when loading != null:
return loading(_that);case BillingSummaryLoaded() when summaryLoaded != null:
return summaryLoaded(_that);case BillingInvoicesLoaded() when invoicesLoaded != null:
return invoicesLoaded(_that);case BillingInvoiceDetailLoaded() when invoiceDetailLoaded != null:
return invoiceDetailLoaded(_that);case BillingPaymentHistoryLoaded() when paymentHistoryLoaded != null:
return paymentHistoryLoaded(_that);case BillingPaymentProcessing() when paymentProcessing != null:
return paymentProcessing(_that);case BillingPaymentSuccess() when paymentSuccess != null:
return paymentSuccess(_that);case BillingInvoiceDownloading() when invoiceDownloading != null:
return invoiceDownloading(_that);case BillingInvoiceDownloadSuccess() when invoiceDownloadSuccess != null:
return invoiceDownloadSuccess(_that);case BillingInvoiceEmailSending() when invoiceEmailSending != null:
return invoiceEmailSending(_that);case BillingInvoiceEmailSent() when invoiceEmailSent != null:
return invoiceEmailSent(_that);case BillingError() when error != null:
return error(_that);case BillingEmpty() when empty != null:
return empty(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( BillingInitial value)  initial,required TResult Function( BillingLoading value)  loading,required TResult Function( BillingSummaryLoaded value)  summaryLoaded,required TResult Function( BillingInvoicesLoaded value)  invoicesLoaded,required TResult Function( BillingInvoiceDetailLoaded value)  invoiceDetailLoaded,required TResult Function( BillingPaymentHistoryLoaded value)  paymentHistoryLoaded,required TResult Function( BillingPaymentProcessing value)  paymentProcessing,required TResult Function( BillingPaymentSuccess value)  paymentSuccess,required TResult Function( BillingInvoiceDownloading value)  invoiceDownloading,required TResult Function( BillingInvoiceDownloadSuccess value)  invoiceDownloadSuccess,required TResult Function( BillingInvoiceEmailSending value)  invoiceEmailSending,required TResult Function( BillingInvoiceEmailSent value)  invoiceEmailSent,required TResult Function( BillingError value)  error,required TResult Function( BillingEmpty value)  empty,}){
final _that = this;
switch (_that) {
case BillingInitial():
return initial(_that);case BillingLoading():
return loading(_that);case BillingSummaryLoaded():
return summaryLoaded(_that);case BillingInvoicesLoaded():
return invoicesLoaded(_that);case BillingInvoiceDetailLoaded():
return invoiceDetailLoaded(_that);case BillingPaymentHistoryLoaded():
return paymentHistoryLoaded(_that);case BillingPaymentProcessing():
return paymentProcessing(_that);case BillingPaymentSuccess():
return paymentSuccess(_that);case BillingInvoiceDownloading():
return invoiceDownloading(_that);case BillingInvoiceDownloadSuccess():
return invoiceDownloadSuccess(_that);case BillingInvoiceEmailSending():
return invoiceEmailSending(_that);case BillingInvoiceEmailSent():
return invoiceEmailSent(_that);case BillingError():
return error(_that);case BillingEmpty():
return empty(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( BillingInitial value)?  initial,TResult? Function( BillingLoading value)?  loading,TResult? Function( BillingSummaryLoaded value)?  summaryLoaded,TResult? Function( BillingInvoicesLoaded value)?  invoicesLoaded,TResult? Function( BillingInvoiceDetailLoaded value)?  invoiceDetailLoaded,TResult? Function( BillingPaymentHistoryLoaded value)?  paymentHistoryLoaded,TResult? Function( BillingPaymentProcessing value)?  paymentProcessing,TResult? Function( BillingPaymentSuccess value)?  paymentSuccess,TResult? Function( BillingInvoiceDownloading value)?  invoiceDownloading,TResult? Function( BillingInvoiceDownloadSuccess value)?  invoiceDownloadSuccess,TResult? Function( BillingInvoiceEmailSending value)?  invoiceEmailSending,TResult? Function( BillingInvoiceEmailSent value)?  invoiceEmailSent,TResult? Function( BillingError value)?  error,TResult? Function( BillingEmpty value)?  empty,}){
final _that = this;
switch (_that) {
case BillingInitial() when initial != null:
return initial(_that);case BillingLoading() when loading != null:
return loading(_that);case BillingSummaryLoaded() when summaryLoaded != null:
return summaryLoaded(_that);case BillingInvoicesLoaded() when invoicesLoaded != null:
return invoicesLoaded(_that);case BillingInvoiceDetailLoaded() when invoiceDetailLoaded != null:
return invoiceDetailLoaded(_that);case BillingPaymentHistoryLoaded() when paymentHistoryLoaded != null:
return paymentHistoryLoaded(_that);case BillingPaymentProcessing() when paymentProcessing != null:
return paymentProcessing(_that);case BillingPaymentSuccess() when paymentSuccess != null:
return paymentSuccess(_that);case BillingInvoiceDownloading() when invoiceDownloading != null:
return invoiceDownloading(_that);case BillingInvoiceDownloadSuccess() when invoiceDownloadSuccess != null:
return invoiceDownloadSuccess(_that);case BillingInvoiceEmailSending() when invoiceEmailSending != null:
return invoiceEmailSending(_that);case BillingInvoiceEmailSent() when invoiceEmailSent != null:
return invoiceEmailSent(_that);case BillingError() when error != null:
return error(_that);case BillingEmpty() when empty != null:
return empty(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( BillingSummary summary,  List<Invoice> recentInvoices,  bool hasMoreInvoices)?  summaryLoaded,TResult Function( List<Invoice> invoices,  BillingFilter filter,  bool hasMore,  int totalCount)?  invoicesLoaded,TResult Function( Invoice invoice,  List<Payment>? payments)?  invoiceDetailLoaded,TResult Function( List<Payment> payments,  BillingFilter filter,  bool hasMore,  int totalCount)?  paymentHistoryLoaded,TResult Function( String invoiceId)?  paymentProcessing,TResult Function( Payment payment,  Invoice updatedInvoice)?  paymentSuccess,TResult Function( String invoiceId)?  invoiceDownloading,TResult Function( String invoiceId,  String filePath)?  invoiceDownloadSuccess,TResult Function( String invoiceId)?  invoiceEmailSending,TResult Function( String invoiceId)?  invoiceEmailSent,TResult Function( String message,  bool isNetworkError,  bool isPaymentError,  bool isInvoiceLocked,  BillingEvent? retryEvent)?  error,TResult Function( String message)?  empty,required TResult orElse(),}) {final _that = this;
switch (_that) {
case BillingInitial() when initial != null:
return initial();case BillingLoading() when loading != null:
return loading();case BillingSummaryLoaded() when summaryLoaded != null:
return summaryLoaded(_that.summary,_that.recentInvoices,_that.hasMoreInvoices);case BillingInvoicesLoaded() when invoicesLoaded != null:
return invoicesLoaded(_that.invoices,_that.filter,_that.hasMore,_that.totalCount);case BillingInvoiceDetailLoaded() when invoiceDetailLoaded != null:
return invoiceDetailLoaded(_that.invoice,_that.payments);case BillingPaymentHistoryLoaded() when paymentHistoryLoaded != null:
return paymentHistoryLoaded(_that.payments,_that.filter,_that.hasMore,_that.totalCount);case BillingPaymentProcessing() when paymentProcessing != null:
return paymentProcessing(_that.invoiceId);case BillingPaymentSuccess() when paymentSuccess != null:
return paymentSuccess(_that.payment,_that.updatedInvoice);case BillingInvoiceDownloading() when invoiceDownloading != null:
return invoiceDownloading(_that.invoiceId);case BillingInvoiceDownloadSuccess() when invoiceDownloadSuccess != null:
return invoiceDownloadSuccess(_that.invoiceId,_that.filePath);case BillingInvoiceEmailSending() when invoiceEmailSending != null:
return invoiceEmailSending(_that.invoiceId);case BillingInvoiceEmailSent() when invoiceEmailSent != null:
return invoiceEmailSent(_that.invoiceId);case BillingError() when error != null:
return error(_that.message,_that.isNetworkError,_that.isPaymentError,_that.isInvoiceLocked,_that.retryEvent);case BillingEmpty() when empty != null:
return empty(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( BillingSummary summary,  List<Invoice> recentInvoices,  bool hasMoreInvoices)  summaryLoaded,required TResult Function( List<Invoice> invoices,  BillingFilter filter,  bool hasMore,  int totalCount)  invoicesLoaded,required TResult Function( Invoice invoice,  List<Payment>? payments)  invoiceDetailLoaded,required TResult Function( List<Payment> payments,  BillingFilter filter,  bool hasMore,  int totalCount)  paymentHistoryLoaded,required TResult Function( String invoiceId)  paymentProcessing,required TResult Function( Payment payment,  Invoice updatedInvoice)  paymentSuccess,required TResult Function( String invoiceId)  invoiceDownloading,required TResult Function( String invoiceId,  String filePath)  invoiceDownloadSuccess,required TResult Function( String invoiceId)  invoiceEmailSending,required TResult Function( String invoiceId)  invoiceEmailSent,required TResult Function( String message,  bool isNetworkError,  bool isPaymentError,  bool isInvoiceLocked,  BillingEvent? retryEvent)  error,required TResult Function( String message)  empty,}) {final _that = this;
switch (_that) {
case BillingInitial():
return initial();case BillingLoading():
return loading();case BillingSummaryLoaded():
return summaryLoaded(_that.summary,_that.recentInvoices,_that.hasMoreInvoices);case BillingInvoicesLoaded():
return invoicesLoaded(_that.invoices,_that.filter,_that.hasMore,_that.totalCount);case BillingInvoiceDetailLoaded():
return invoiceDetailLoaded(_that.invoice,_that.payments);case BillingPaymentHistoryLoaded():
return paymentHistoryLoaded(_that.payments,_that.filter,_that.hasMore,_that.totalCount);case BillingPaymentProcessing():
return paymentProcessing(_that.invoiceId);case BillingPaymentSuccess():
return paymentSuccess(_that.payment,_that.updatedInvoice);case BillingInvoiceDownloading():
return invoiceDownloading(_that.invoiceId);case BillingInvoiceDownloadSuccess():
return invoiceDownloadSuccess(_that.invoiceId,_that.filePath);case BillingInvoiceEmailSending():
return invoiceEmailSending(_that.invoiceId);case BillingInvoiceEmailSent():
return invoiceEmailSent(_that.invoiceId);case BillingError():
return error(_that.message,_that.isNetworkError,_that.isPaymentError,_that.isInvoiceLocked,_that.retryEvent);case BillingEmpty():
return empty(_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( BillingSummary summary,  List<Invoice> recentInvoices,  bool hasMoreInvoices)?  summaryLoaded,TResult? Function( List<Invoice> invoices,  BillingFilter filter,  bool hasMore,  int totalCount)?  invoicesLoaded,TResult? Function( Invoice invoice,  List<Payment>? payments)?  invoiceDetailLoaded,TResult? Function( List<Payment> payments,  BillingFilter filter,  bool hasMore,  int totalCount)?  paymentHistoryLoaded,TResult? Function( String invoiceId)?  paymentProcessing,TResult? Function( Payment payment,  Invoice updatedInvoice)?  paymentSuccess,TResult? Function( String invoiceId)?  invoiceDownloading,TResult? Function( String invoiceId,  String filePath)?  invoiceDownloadSuccess,TResult? Function( String invoiceId)?  invoiceEmailSending,TResult? Function( String invoiceId)?  invoiceEmailSent,TResult? Function( String message,  bool isNetworkError,  bool isPaymentError,  bool isInvoiceLocked,  BillingEvent? retryEvent)?  error,TResult? Function( String message)?  empty,}) {final _that = this;
switch (_that) {
case BillingInitial() when initial != null:
return initial();case BillingLoading() when loading != null:
return loading();case BillingSummaryLoaded() when summaryLoaded != null:
return summaryLoaded(_that.summary,_that.recentInvoices,_that.hasMoreInvoices);case BillingInvoicesLoaded() when invoicesLoaded != null:
return invoicesLoaded(_that.invoices,_that.filter,_that.hasMore,_that.totalCount);case BillingInvoiceDetailLoaded() when invoiceDetailLoaded != null:
return invoiceDetailLoaded(_that.invoice,_that.payments);case BillingPaymentHistoryLoaded() when paymentHistoryLoaded != null:
return paymentHistoryLoaded(_that.payments,_that.filter,_that.hasMore,_that.totalCount);case BillingPaymentProcessing() when paymentProcessing != null:
return paymentProcessing(_that.invoiceId);case BillingPaymentSuccess() when paymentSuccess != null:
return paymentSuccess(_that.payment,_that.updatedInvoice);case BillingInvoiceDownloading() when invoiceDownloading != null:
return invoiceDownloading(_that.invoiceId);case BillingInvoiceDownloadSuccess() when invoiceDownloadSuccess != null:
return invoiceDownloadSuccess(_that.invoiceId,_that.filePath);case BillingInvoiceEmailSending() when invoiceEmailSending != null:
return invoiceEmailSending(_that.invoiceId);case BillingInvoiceEmailSent() when invoiceEmailSent != null:
return invoiceEmailSent(_that.invoiceId);case BillingError() when error != null:
return error(_that.message,_that.isNetworkError,_that.isPaymentError,_that.isInvoiceLocked,_that.retryEvent);case BillingEmpty() when empty != null:
return empty(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class BillingInitial implements BillingState {
  const BillingInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillingInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BillingState.initial()';
}


}




/// @nodoc


class BillingLoading implements BillingState {
  const BillingLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillingLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BillingState.loading()';
}


}




/// @nodoc


class BillingSummaryLoaded implements BillingState {
  const BillingSummaryLoaded({required this.summary, required final  List<Invoice> recentInvoices, this.hasMoreInvoices = false}): _recentInvoices = recentInvoices;
  

 final  BillingSummary summary;
 final  List<Invoice> _recentInvoices;
 List<Invoice> get recentInvoices {
  if (_recentInvoices is EqualUnmodifiableListView) return _recentInvoices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentInvoices);
}

@JsonKey() final  bool hasMoreInvoices;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillingSummaryLoadedCopyWith<BillingSummaryLoaded> get copyWith => _$BillingSummaryLoadedCopyWithImpl<BillingSummaryLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillingSummaryLoaded&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other._recentInvoices, _recentInvoices)&&(identical(other.hasMoreInvoices, hasMoreInvoices) || other.hasMoreInvoices == hasMoreInvoices));
}


@override
int get hashCode => Object.hash(runtimeType,summary,const DeepCollectionEquality().hash(_recentInvoices),hasMoreInvoices);

@override
String toString() {
  return 'BillingState.summaryLoaded(summary: $summary, recentInvoices: $recentInvoices, hasMoreInvoices: $hasMoreInvoices)';
}


}

/// @nodoc
abstract mixin class $BillingSummaryLoadedCopyWith<$Res> implements $BillingStateCopyWith<$Res> {
  factory $BillingSummaryLoadedCopyWith(BillingSummaryLoaded value, $Res Function(BillingSummaryLoaded) _then) = _$BillingSummaryLoadedCopyWithImpl;
@useResult
$Res call({
 BillingSummary summary, List<Invoice> recentInvoices, bool hasMoreInvoices
});


$BillingSummaryCopyWith<$Res> get summary;

}
/// @nodoc
class _$BillingSummaryLoadedCopyWithImpl<$Res>
    implements $BillingSummaryLoadedCopyWith<$Res> {
  _$BillingSummaryLoadedCopyWithImpl(this._self, this._then);

  final BillingSummaryLoaded _self;
  final $Res Function(BillingSummaryLoaded) _then;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? summary = null,Object? recentInvoices = null,Object? hasMoreInvoices = null,}) {
  return _then(BillingSummaryLoaded(
summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as BillingSummary,recentInvoices: null == recentInvoices ? _self._recentInvoices : recentInvoices // ignore: cast_nullable_to_non_nullable
as List<Invoice>,hasMoreInvoices: null == hasMoreInvoices ? _self.hasMoreInvoices : hasMoreInvoices // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BillingSummaryCopyWith<$Res> get summary {
  
  return $BillingSummaryCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}

/// @nodoc


class BillingInvoicesLoaded implements BillingState {
  const BillingInvoicesLoaded({required final  List<Invoice> invoices, required this.filter, this.hasMore = false, this.totalCount = 0}): _invoices = invoices;
  

 final  List<Invoice> _invoices;
 List<Invoice> get invoices {
  if (_invoices is EqualUnmodifiableListView) return _invoices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_invoices);
}

 final  BillingFilter filter;
@JsonKey() final  bool hasMore;
@JsonKey() final  int totalCount;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillingInvoicesLoadedCopyWith<BillingInvoicesLoaded> get copyWith => _$BillingInvoicesLoadedCopyWithImpl<BillingInvoicesLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillingInvoicesLoaded&&const DeepCollectionEquality().equals(other._invoices, _invoices)&&(identical(other.filter, filter) || other.filter == filter)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_invoices),filter,hasMore,totalCount);

@override
String toString() {
  return 'BillingState.invoicesLoaded(invoices: $invoices, filter: $filter, hasMore: $hasMore, totalCount: $totalCount)';
}


}

/// @nodoc
abstract mixin class $BillingInvoicesLoadedCopyWith<$Res> implements $BillingStateCopyWith<$Res> {
  factory $BillingInvoicesLoadedCopyWith(BillingInvoicesLoaded value, $Res Function(BillingInvoicesLoaded) _then) = _$BillingInvoicesLoadedCopyWithImpl;
@useResult
$Res call({
 List<Invoice> invoices, BillingFilter filter, bool hasMore, int totalCount
});


$BillingFilterCopyWith<$Res> get filter;

}
/// @nodoc
class _$BillingInvoicesLoadedCopyWithImpl<$Res>
    implements $BillingInvoicesLoadedCopyWith<$Res> {
  _$BillingInvoicesLoadedCopyWithImpl(this._self, this._then);

  final BillingInvoicesLoaded _self;
  final $Res Function(BillingInvoicesLoaded) _then;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? invoices = null,Object? filter = null,Object? hasMore = null,Object? totalCount = null,}) {
  return _then(BillingInvoicesLoaded(
invoices: null == invoices ? _self._invoices : invoices // ignore: cast_nullable_to_non_nullable
as List<Invoice>,filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as BillingFilter,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BillingFilterCopyWith<$Res> get filter {
  
  return $BillingFilterCopyWith<$Res>(_self.filter, (value) {
    return _then(_self.copyWith(filter: value));
  });
}
}

/// @nodoc


class BillingInvoiceDetailLoaded implements BillingState {
  const BillingInvoiceDetailLoaded({required this.invoice, final  List<Payment>? payments}): _payments = payments;
  

 final  Invoice invoice;
 final  List<Payment>? _payments;
 List<Payment>? get payments {
  final value = _payments;
  if (value == null) return null;
  if (_payments is EqualUnmodifiableListView) return _payments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillingInvoiceDetailLoadedCopyWith<BillingInvoiceDetailLoaded> get copyWith => _$BillingInvoiceDetailLoadedCopyWithImpl<BillingInvoiceDetailLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillingInvoiceDetailLoaded&&(identical(other.invoice, invoice) || other.invoice == invoice)&&const DeepCollectionEquality().equals(other._payments, _payments));
}


@override
int get hashCode => Object.hash(runtimeType,invoice,const DeepCollectionEquality().hash(_payments));

@override
String toString() {
  return 'BillingState.invoiceDetailLoaded(invoice: $invoice, payments: $payments)';
}


}

/// @nodoc
abstract mixin class $BillingInvoiceDetailLoadedCopyWith<$Res> implements $BillingStateCopyWith<$Res> {
  factory $BillingInvoiceDetailLoadedCopyWith(BillingInvoiceDetailLoaded value, $Res Function(BillingInvoiceDetailLoaded) _then) = _$BillingInvoiceDetailLoadedCopyWithImpl;
@useResult
$Res call({
 Invoice invoice, List<Payment>? payments
});


$InvoiceCopyWith<$Res> get invoice;

}
/// @nodoc
class _$BillingInvoiceDetailLoadedCopyWithImpl<$Res>
    implements $BillingInvoiceDetailLoadedCopyWith<$Res> {
  _$BillingInvoiceDetailLoadedCopyWithImpl(this._self, this._then);

  final BillingInvoiceDetailLoaded _self;
  final $Res Function(BillingInvoiceDetailLoaded) _then;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? invoice = null,Object? payments = freezed,}) {
  return _then(BillingInvoiceDetailLoaded(
invoice: null == invoice ? _self.invoice : invoice // ignore: cast_nullable_to_non_nullable
as Invoice,payments: freezed == payments ? _self._payments : payments // ignore: cast_nullable_to_non_nullable
as List<Payment>?,
  ));
}

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InvoiceCopyWith<$Res> get invoice {
  
  return $InvoiceCopyWith<$Res>(_self.invoice, (value) {
    return _then(_self.copyWith(invoice: value));
  });
}
}

/// @nodoc


class BillingPaymentHistoryLoaded implements BillingState {
  const BillingPaymentHistoryLoaded({required final  List<Payment> payments, required this.filter, this.hasMore = false, this.totalCount = 0}): _payments = payments;
  

 final  List<Payment> _payments;
 List<Payment> get payments {
  if (_payments is EqualUnmodifiableListView) return _payments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_payments);
}

 final  BillingFilter filter;
@JsonKey() final  bool hasMore;
@JsonKey() final  int totalCount;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillingPaymentHistoryLoadedCopyWith<BillingPaymentHistoryLoaded> get copyWith => _$BillingPaymentHistoryLoadedCopyWithImpl<BillingPaymentHistoryLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillingPaymentHistoryLoaded&&const DeepCollectionEquality().equals(other._payments, _payments)&&(identical(other.filter, filter) || other.filter == filter)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_payments),filter,hasMore,totalCount);

@override
String toString() {
  return 'BillingState.paymentHistoryLoaded(payments: $payments, filter: $filter, hasMore: $hasMore, totalCount: $totalCount)';
}


}

/// @nodoc
abstract mixin class $BillingPaymentHistoryLoadedCopyWith<$Res> implements $BillingStateCopyWith<$Res> {
  factory $BillingPaymentHistoryLoadedCopyWith(BillingPaymentHistoryLoaded value, $Res Function(BillingPaymentHistoryLoaded) _then) = _$BillingPaymentHistoryLoadedCopyWithImpl;
@useResult
$Res call({
 List<Payment> payments, BillingFilter filter, bool hasMore, int totalCount
});


$BillingFilterCopyWith<$Res> get filter;

}
/// @nodoc
class _$BillingPaymentHistoryLoadedCopyWithImpl<$Res>
    implements $BillingPaymentHistoryLoadedCopyWith<$Res> {
  _$BillingPaymentHistoryLoadedCopyWithImpl(this._self, this._then);

  final BillingPaymentHistoryLoaded _self;
  final $Res Function(BillingPaymentHistoryLoaded) _then;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? payments = null,Object? filter = null,Object? hasMore = null,Object? totalCount = null,}) {
  return _then(BillingPaymentHistoryLoaded(
payments: null == payments ? _self._payments : payments // ignore: cast_nullable_to_non_nullable
as List<Payment>,filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as BillingFilter,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BillingFilterCopyWith<$Res> get filter {
  
  return $BillingFilterCopyWith<$Res>(_self.filter, (value) {
    return _then(_self.copyWith(filter: value));
  });
}
}

/// @nodoc


class BillingPaymentProcessing implements BillingState {
  const BillingPaymentProcessing({required this.invoiceId});
  

 final  String invoiceId;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillingPaymentProcessingCopyWith<BillingPaymentProcessing> get copyWith => _$BillingPaymentProcessingCopyWithImpl<BillingPaymentProcessing>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillingPaymentProcessing&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId));
}


@override
int get hashCode => Object.hash(runtimeType,invoiceId);

@override
String toString() {
  return 'BillingState.paymentProcessing(invoiceId: $invoiceId)';
}


}

/// @nodoc
abstract mixin class $BillingPaymentProcessingCopyWith<$Res> implements $BillingStateCopyWith<$Res> {
  factory $BillingPaymentProcessingCopyWith(BillingPaymentProcessing value, $Res Function(BillingPaymentProcessing) _then) = _$BillingPaymentProcessingCopyWithImpl;
@useResult
$Res call({
 String invoiceId
});




}
/// @nodoc
class _$BillingPaymentProcessingCopyWithImpl<$Res>
    implements $BillingPaymentProcessingCopyWith<$Res> {
  _$BillingPaymentProcessingCopyWithImpl(this._self, this._then);

  final BillingPaymentProcessing _self;
  final $Res Function(BillingPaymentProcessing) _then;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? invoiceId = null,}) {
  return _then(BillingPaymentProcessing(
invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class BillingPaymentSuccess implements BillingState {
  const BillingPaymentSuccess({required this.payment, required this.updatedInvoice});
  

 final  Payment payment;
 final  Invoice updatedInvoice;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillingPaymentSuccessCopyWith<BillingPaymentSuccess> get copyWith => _$BillingPaymentSuccessCopyWithImpl<BillingPaymentSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillingPaymentSuccess&&(identical(other.payment, payment) || other.payment == payment)&&(identical(other.updatedInvoice, updatedInvoice) || other.updatedInvoice == updatedInvoice));
}


@override
int get hashCode => Object.hash(runtimeType,payment,updatedInvoice);

@override
String toString() {
  return 'BillingState.paymentSuccess(payment: $payment, updatedInvoice: $updatedInvoice)';
}


}

/// @nodoc
abstract mixin class $BillingPaymentSuccessCopyWith<$Res> implements $BillingStateCopyWith<$Res> {
  factory $BillingPaymentSuccessCopyWith(BillingPaymentSuccess value, $Res Function(BillingPaymentSuccess) _then) = _$BillingPaymentSuccessCopyWithImpl;
@useResult
$Res call({
 Payment payment, Invoice updatedInvoice
});


$PaymentCopyWith<$Res> get payment;$InvoiceCopyWith<$Res> get updatedInvoice;

}
/// @nodoc
class _$BillingPaymentSuccessCopyWithImpl<$Res>
    implements $BillingPaymentSuccessCopyWith<$Res> {
  _$BillingPaymentSuccessCopyWithImpl(this._self, this._then);

  final BillingPaymentSuccess _self;
  final $Res Function(BillingPaymentSuccess) _then;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? payment = null,Object? updatedInvoice = null,}) {
  return _then(BillingPaymentSuccess(
payment: null == payment ? _self.payment : payment // ignore: cast_nullable_to_non_nullable
as Payment,updatedInvoice: null == updatedInvoice ? _self.updatedInvoice : updatedInvoice // ignore: cast_nullable_to_non_nullable
as Invoice,
  ));
}

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaymentCopyWith<$Res> get payment {
  
  return $PaymentCopyWith<$Res>(_self.payment, (value) {
    return _then(_self.copyWith(payment: value));
  });
}/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InvoiceCopyWith<$Res> get updatedInvoice {
  
  return $InvoiceCopyWith<$Res>(_self.updatedInvoice, (value) {
    return _then(_self.copyWith(updatedInvoice: value));
  });
}
}

/// @nodoc


class BillingInvoiceDownloading implements BillingState {
  const BillingInvoiceDownloading({required this.invoiceId});
  

 final  String invoiceId;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillingInvoiceDownloadingCopyWith<BillingInvoiceDownloading> get copyWith => _$BillingInvoiceDownloadingCopyWithImpl<BillingInvoiceDownloading>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillingInvoiceDownloading&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId));
}


@override
int get hashCode => Object.hash(runtimeType,invoiceId);

@override
String toString() {
  return 'BillingState.invoiceDownloading(invoiceId: $invoiceId)';
}


}

/// @nodoc
abstract mixin class $BillingInvoiceDownloadingCopyWith<$Res> implements $BillingStateCopyWith<$Res> {
  factory $BillingInvoiceDownloadingCopyWith(BillingInvoiceDownloading value, $Res Function(BillingInvoiceDownloading) _then) = _$BillingInvoiceDownloadingCopyWithImpl;
@useResult
$Res call({
 String invoiceId
});




}
/// @nodoc
class _$BillingInvoiceDownloadingCopyWithImpl<$Res>
    implements $BillingInvoiceDownloadingCopyWith<$Res> {
  _$BillingInvoiceDownloadingCopyWithImpl(this._self, this._then);

  final BillingInvoiceDownloading _self;
  final $Res Function(BillingInvoiceDownloading) _then;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? invoiceId = null,}) {
  return _then(BillingInvoiceDownloading(
invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class BillingInvoiceDownloadSuccess implements BillingState {
  const BillingInvoiceDownloadSuccess({required this.invoiceId, required this.filePath});
  

 final  String invoiceId;
 final  String filePath;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillingInvoiceDownloadSuccessCopyWith<BillingInvoiceDownloadSuccess> get copyWith => _$BillingInvoiceDownloadSuccessCopyWithImpl<BillingInvoiceDownloadSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillingInvoiceDownloadSuccess&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.filePath, filePath) || other.filePath == filePath));
}


@override
int get hashCode => Object.hash(runtimeType,invoiceId,filePath);

@override
String toString() {
  return 'BillingState.invoiceDownloadSuccess(invoiceId: $invoiceId, filePath: $filePath)';
}


}

/// @nodoc
abstract mixin class $BillingInvoiceDownloadSuccessCopyWith<$Res> implements $BillingStateCopyWith<$Res> {
  factory $BillingInvoiceDownloadSuccessCopyWith(BillingInvoiceDownloadSuccess value, $Res Function(BillingInvoiceDownloadSuccess) _then) = _$BillingInvoiceDownloadSuccessCopyWithImpl;
@useResult
$Res call({
 String invoiceId, String filePath
});




}
/// @nodoc
class _$BillingInvoiceDownloadSuccessCopyWithImpl<$Res>
    implements $BillingInvoiceDownloadSuccessCopyWith<$Res> {
  _$BillingInvoiceDownloadSuccessCopyWithImpl(this._self, this._then);

  final BillingInvoiceDownloadSuccess _self;
  final $Res Function(BillingInvoiceDownloadSuccess) _then;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? invoiceId = null,Object? filePath = null,}) {
  return _then(BillingInvoiceDownloadSuccess(
invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class BillingInvoiceEmailSending implements BillingState {
  const BillingInvoiceEmailSending({required this.invoiceId});
  

 final  String invoiceId;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillingInvoiceEmailSendingCopyWith<BillingInvoiceEmailSending> get copyWith => _$BillingInvoiceEmailSendingCopyWithImpl<BillingInvoiceEmailSending>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillingInvoiceEmailSending&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId));
}


@override
int get hashCode => Object.hash(runtimeType,invoiceId);

@override
String toString() {
  return 'BillingState.invoiceEmailSending(invoiceId: $invoiceId)';
}


}

/// @nodoc
abstract mixin class $BillingInvoiceEmailSendingCopyWith<$Res> implements $BillingStateCopyWith<$Res> {
  factory $BillingInvoiceEmailSendingCopyWith(BillingInvoiceEmailSending value, $Res Function(BillingInvoiceEmailSending) _then) = _$BillingInvoiceEmailSendingCopyWithImpl;
@useResult
$Res call({
 String invoiceId
});




}
/// @nodoc
class _$BillingInvoiceEmailSendingCopyWithImpl<$Res>
    implements $BillingInvoiceEmailSendingCopyWith<$Res> {
  _$BillingInvoiceEmailSendingCopyWithImpl(this._self, this._then);

  final BillingInvoiceEmailSending _self;
  final $Res Function(BillingInvoiceEmailSending) _then;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? invoiceId = null,}) {
  return _then(BillingInvoiceEmailSending(
invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class BillingInvoiceEmailSent implements BillingState {
  const BillingInvoiceEmailSent({required this.invoiceId});
  

 final  String invoiceId;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillingInvoiceEmailSentCopyWith<BillingInvoiceEmailSent> get copyWith => _$BillingInvoiceEmailSentCopyWithImpl<BillingInvoiceEmailSent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillingInvoiceEmailSent&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId));
}


@override
int get hashCode => Object.hash(runtimeType,invoiceId);

@override
String toString() {
  return 'BillingState.invoiceEmailSent(invoiceId: $invoiceId)';
}


}

/// @nodoc
abstract mixin class $BillingInvoiceEmailSentCopyWith<$Res> implements $BillingStateCopyWith<$Res> {
  factory $BillingInvoiceEmailSentCopyWith(BillingInvoiceEmailSent value, $Res Function(BillingInvoiceEmailSent) _then) = _$BillingInvoiceEmailSentCopyWithImpl;
@useResult
$Res call({
 String invoiceId
});




}
/// @nodoc
class _$BillingInvoiceEmailSentCopyWithImpl<$Res>
    implements $BillingInvoiceEmailSentCopyWith<$Res> {
  _$BillingInvoiceEmailSentCopyWithImpl(this._self, this._then);

  final BillingInvoiceEmailSent _self;
  final $Res Function(BillingInvoiceEmailSent) _then;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? invoiceId = null,}) {
  return _then(BillingInvoiceEmailSent(
invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class BillingError implements BillingState {
  const BillingError({required this.message, this.isNetworkError = false, this.isPaymentError = false, this.isInvoiceLocked = false, this.retryEvent});
  

 final  String message;
@JsonKey() final  bool isNetworkError;
@JsonKey() final  bool isPaymentError;
@JsonKey() final  bool isInvoiceLocked;
 final  BillingEvent? retryEvent;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillingErrorCopyWith<BillingError> get copyWith => _$BillingErrorCopyWithImpl<BillingError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillingError&&(identical(other.message, message) || other.message == message)&&(identical(other.isNetworkError, isNetworkError) || other.isNetworkError == isNetworkError)&&(identical(other.isPaymentError, isPaymentError) || other.isPaymentError == isPaymentError)&&(identical(other.isInvoiceLocked, isInvoiceLocked) || other.isInvoiceLocked == isInvoiceLocked)&&(identical(other.retryEvent, retryEvent) || other.retryEvent == retryEvent));
}


@override
int get hashCode => Object.hash(runtimeType,message,isNetworkError,isPaymentError,isInvoiceLocked,retryEvent);

@override
String toString() {
  return 'BillingState.error(message: $message, isNetworkError: $isNetworkError, isPaymentError: $isPaymentError, isInvoiceLocked: $isInvoiceLocked, retryEvent: $retryEvent)';
}


}

/// @nodoc
abstract mixin class $BillingErrorCopyWith<$Res> implements $BillingStateCopyWith<$Res> {
  factory $BillingErrorCopyWith(BillingError value, $Res Function(BillingError) _then) = _$BillingErrorCopyWithImpl;
@useResult
$Res call({
 String message, bool isNetworkError, bool isPaymentError, bool isInvoiceLocked, BillingEvent? retryEvent
});


$BillingEventCopyWith<$Res>? get retryEvent;

}
/// @nodoc
class _$BillingErrorCopyWithImpl<$Res>
    implements $BillingErrorCopyWith<$Res> {
  _$BillingErrorCopyWithImpl(this._self, this._then);

  final BillingError _self;
  final $Res Function(BillingError) _then;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,Object? isNetworkError = null,Object? isPaymentError = null,Object? isInvoiceLocked = null,Object? retryEvent = freezed,}) {
  return _then(BillingError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,isNetworkError: null == isNetworkError ? _self.isNetworkError : isNetworkError // ignore: cast_nullable_to_non_nullable
as bool,isPaymentError: null == isPaymentError ? _self.isPaymentError : isPaymentError // ignore: cast_nullable_to_non_nullable
as bool,isInvoiceLocked: null == isInvoiceLocked ? _self.isInvoiceLocked : isInvoiceLocked // ignore: cast_nullable_to_non_nullable
as bool,retryEvent: freezed == retryEvent ? _self.retryEvent : retryEvent // ignore: cast_nullable_to_non_nullable
as BillingEvent?,
  ));
}

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BillingEventCopyWith<$Res>? get retryEvent {
    if (_self.retryEvent == null) {
    return null;
  }

  return $BillingEventCopyWith<$Res>(_self.retryEvent!, (value) {
    return _then(_self.copyWith(retryEvent: value));
  });
}
}

/// @nodoc


class BillingEmpty implements BillingState {
  const BillingEmpty({required this.message});
  

 final  String message;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillingEmptyCopyWith<BillingEmpty> get copyWith => _$BillingEmptyCopyWithImpl<BillingEmpty>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillingEmpty&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'BillingState.empty(message: $message)';
}


}

/// @nodoc
abstract mixin class $BillingEmptyCopyWith<$Res> implements $BillingStateCopyWith<$Res> {
  factory $BillingEmptyCopyWith(BillingEmpty value, $Res Function(BillingEmpty) _then) = _$BillingEmptyCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$BillingEmptyCopyWithImpl<$Res>
    implements $BillingEmptyCopyWith<$Res> {
  _$BillingEmptyCopyWithImpl(this._self, this._then);

  final BillingEmpty _self;
  final $Res Function(BillingEmpty) _then;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(BillingEmpty(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

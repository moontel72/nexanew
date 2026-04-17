// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'company_management_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CompanyManagementEvent implements DiagnosticableTreeMixin {




@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CompanyManagementEvent'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompanyManagementEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CompanyManagementEvent()';
}


}

/// @nodoc
class $CompanyManagementEventCopyWith<$Res>  {
$CompanyManagementEventCopyWith(CompanyManagementEvent _, $Res Function(CompanyManagementEvent) __);
}


/// Adds pattern-matching-related methods to [CompanyManagementEvent].
extension CompanyManagementEventPatterns on CompanyManagementEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _LoadCompanies value)?  loadCompanies,TResult Function( _LoadCompany value)?  loadCompany,TResult Function( _CreateCompany value)?  createCompany,TResult Function( _UpdateCompany value)?  updateCompany,TResult Function( _DeleteCompany value)?  deleteCompany,TResult Function( _UpdateCompanyStatus value)?  updateCompanyStatus,TResult Function( _UpdateVerificationStatus value)?  updateVerificationStatus,TResult Function( _AssignPlan value)?  assignPlan,TResult Function( _UploadDocument value)?  uploadDocument,TResult Function( _DeleteDocument value)?  deleteDocument,TResult Function( _LoadCompanyStatistics value)?  loadCompanyStatistics,TResult Function( _ExportCompanies value)?  exportCompanies,TResult Function( _SendWelcomeEmail value)?  sendWelcomeEmail,TResult Function( _ResetCompanyPassword value)?  resetCompanyPassword,TResult Function( _ClearError value)?  clearError,TResult Function( _Reset value)?  reset,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoadCompanies() when loadCompanies != null:
return loadCompanies(_that);case _LoadCompany() when loadCompany != null:
return loadCompany(_that);case _CreateCompany() when createCompany != null:
return createCompany(_that);case _UpdateCompany() when updateCompany != null:
return updateCompany(_that);case _DeleteCompany() when deleteCompany != null:
return deleteCompany(_that);case _UpdateCompanyStatus() when updateCompanyStatus != null:
return updateCompanyStatus(_that);case _UpdateVerificationStatus() when updateVerificationStatus != null:
return updateVerificationStatus(_that);case _AssignPlan() when assignPlan != null:
return assignPlan(_that);case _UploadDocument() when uploadDocument != null:
return uploadDocument(_that);case _DeleteDocument() when deleteDocument != null:
return deleteDocument(_that);case _LoadCompanyStatistics() when loadCompanyStatistics != null:
return loadCompanyStatistics(_that);case _ExportCompanies() when exportCompanies != null:
return exportCompanies(_that);case _SendWelcomeEmail() when sendWelcomeEmail != null:
return sendWelcomeEmail(_that);case _ResetCompanyPassword() when resetCompanyPassword != null:
return resetCompanyPassword(_that);case _ClearError() when clearError != null:
return clearError(_that);case _Reset() when reset != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _LoadCompanies value)  loadCompanies,required TResult Function( _LoadCompany value)  loadCompany,required TResult Function( _CreateCompany value)  createCompany,required TResult Function( _UpdateCompany value)  updateCompany,required TResult Function( _DeleteCompany value)  deleteCompany,required TResult Function( _UpdateCompanyStatus value)  updateCompanyStatus,required TResult Function( _UpdateVerificationStatus value)  updateVerificationStatus,required TResult Function( _AssignPlan value)  assignPlan,required TResult Function( _UploadDocument value)  uploadDocument,required TResult Function( _DeleteDocument value)  deleteDocument,required TResult Function( _LoadCompanyStatistics value)  loadCompanyStatistics,required TResult Function( _ExportCompanies value)  exportCompanies,required TResult Function( _SendWelcomeEmail value)  sendWelcomeEmail,required TResult Function( _ResetCompanyPassword value)  resetCompanyPassword,required TResult Function( _ClearError value)  clearError,required TResult Function( _Reset value)  reset,}){
final _that = this;
switch (_that) {
case _LoadCompanies():
return loadCompanies(_that);case _LoadCompany():
return loadCompany(_that);case _CreateCompany():
return createCompany(_that);case _UpdateCompany():
return updateCompany(_that);case _DeleteCompany():
return deleteCompany(_that);case _UpdateCompanyStatus():
return updateCompanyStatus(_that);case _UpdateVerificationStatus():
return updateVerificationStatus(_that);case _AssignPlan():
return assignPlan(_that);case _UploadDocument():
return uploadDocument(_that);case _DeleteDocument():
return deleteDocument(_that);case _LoadCompanyStatistics():
return loadCompanyStatistics(_that);case _ExportCompanies():
return exportCompanies(_that);case _SendWelcomeEmail():
return sendWelcomeEmail(_that);case _ResetCompanyPassword():
return resetCompanyPassword(_that);case _ClearError():
return clearError(_that);case _Reset():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _LoadCompanies value)?  loadCompanies,TResult? Function( _LoadCompany value)?  loadCompany,TResult? Function( _CreateCompany value)?  createCompany,TResult? Function( _UpdateCompany value)?  updateCompany,TResult? Function( _DeleteCompany value)?  deleteCompany,TResult? Function( _UpdateCompanyStatus value)?  updateCompanyStatus,TResult? Function( _UpdateVerificationStatus value)?  updateVerificationStatus,TResult? Function( _AssignPlan value)?  assignPlan,TResult? Function( _UploadDocument value)?  uploadDocument,TResult? Function( _DeleteDocument value)?  deleteDocument,TResult? Function( _LoadCompanyStatistics value)?  loadCompanyStatistics,TResult? Function( _ExportCompanies value)?  exportCompanies,TResult? Function( _SendWelcomeEmail value)?  sendWelcomeEmail,TResult? Function( _ResetCompanyPassword value)?  resetCompanyPassword,TResult? Function( _ClearError value)?  clearError,TResult? Function( _Reset value)?  reset,}){
final _that = this;
switch (_that) {
case _LoadCompanies() when loadCompanies != null:
return loadCompanies(_that);case _LoadCompany() when loadCompany != null:
return loadCompany(_that);case _CreateCompany() when createCompany != null:
return createCompany(_that);case _UpdateCompany() when updateCompany != null:
return updateCompany(_that);case _DeleteCompany() when deleteCompany != null:
return deleteCompany(_that);case _UpdateCompanyStatus() when updateCompanyStatus != null:
return updateCompanyStatus(_that);case _UpdateVerificationStatus() when updateVerificationStatus != null:
return updateVerificationStatus(_that);case _AssignPlan() when assignPlan != null:
return assignPlan(_that);case _UploadDocument() when uploadDocument != null:
return uploadDocument(_that);case _DeleteDocument() when deleteDocument != null:
return deleteDocument(_that);case _LoadCompanyStatistics() when loadCompanyStatistics != null:
return loadCompanyStatistics(_that);case _ExportCompanies() when exportCompanies != null:
return exportCompanies(_that);case _SendWelcomeEmail() when sendWelcomeEmail != null:
return sendWelcomeEmail(_that);case _ResetCompanyPassword() when resetCompanyPassword != null:
return resetCompanyPassword(_that);case _ClearError() when clearError != null:
return clearError(_that);case _Reset() when reset != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String search,  String? status,  String? verificationStatus,  String? country,  String? planType,  String sortBy,  String sortOrder,  int page,  int perPage)?  loadCompanies,TResult Function( String id)?  loadCompany,TResult Function( String name,  String businessRegistrationNumber,  String? taxId,  String companyType,  String industryType,  String email,  String? phone,  String? website,  String country,  String city,  String? address,  String? postalCode,  String contactPersonName,  String contactPersonEmail,  String contactPersonPhone,  String? contactPersonPosition,  String? timezone,  String? language,  String? currency,  String? planId,  String? billingCycle,  List<CompanyDocumentInput>? documents,  String? adminNotes)?  createCompany,TResult Function( String id,  String? name,  String? businessRegistrationNumber,  String? taxId,  String? companyType,  String? industryType,  String? email,  String? phone,  String? website,  String? country,  String? city,  String? address,  String? postalCode,  String? contactPersonName,  String? contactPersonEmail,  String? contactPersonPhone,  String? contactPersonPosition,  String? status,  String? verificationStatus,  String? verificationNotes,  String? timezone,  String? language,  String? currency,  String? planId,  String? billingCycle,  String? adminNotes)?  updateCompany,TResult Function( String id)?  deleteCompany,TResult Function( String id,  String status,  String? reason)?  updateCompanyStatus,TResult Function( String id,  String verificationStatus,  String? verificationNotes)?  updateVerificationStatus,TResult Function( String companyId,  String planId,  String? billingCycle,  bool? autoRenew,  DateTime? startsAt,  DateTime? endsAt)?  assignPlan,TResult Function( String companyId,  String documentType,  String documentName,  String filePath)?  uploadDocument,TResult Function( String companyId,  String documentId)?  deleteDocument,TResult Function()?  loadCompanyStatistics,TResult Function( String? search,  String? status,  String? verificationStatus,  String? country,  String? planType)?  exportCompanies,TResult Function( String companyId)?  sendWelcomeEmail,TResult Function( String companyId)?  resetCompanyPassword,TResult Function()?  clearError,TResult Function()?  reset,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoadCompanies() when loadCompanies != null:
return loadCompanies(_that.search,_that.status,_that.verificationStatus,_that.country,_that.planType,_that.sortBy,_that.sortOrder,_that.page,_that.perPage);case _LoadCompany() when loadCompany != null:
return loadCompany(_that.id);case _CreateCompany() when createCompany != null:
return createCompany(_that.name,_that.businessRegistrationNumber,_that.taxId,_that.companyType,_that.industryType,_that.email,_that.phone,_that.website,_that.country,_that.city,_that.address,_that.postalCode,_that.contactPersonName,_that.contactPersonEmail,_that.contactPersonPhone,_that.contactPersonPosition,_that.timezone,_that.language,_that.currency,_that.planId,_that.billingCycle,_that.documents,_that.adminNotes);case _UpdateCompany() when updateCompany != null:
return updateCompany(_that.id,_that.name,_that.businessRegistrationNumber,_that.taxId,_that.companyType,_that.industryType,_that.email,_that.phone,_that.website,_that.country,_that.city,_that.address,_that.postalCode,_that.contactPersonName,_that.contactPersonEmail,_that.contactPersonPhone,_that.contactPersonPosition,_that.status,_that.verificationStatus,_that.verificationNotes,_that.timezone,_that.language,_that.currency,_that.planId,_that.billingCycle,_that.adminNotes);case _DeleteCompany() when deleteCompany != null:
return deleteCompany(_that.id);case _UpdateCompanyStatus() when updateCompanyStatus != null:
return updateCompanyStatus(_that.id,_that.status,_that.reason);case _UpdateVerificationStatus() when updateVerificationStatus != null:
return updateVerificationStatus(_that.id,_that.verificationStatus,_that.verificationNotes);case _AssignPlan() when assignPlan != null:
return assignPlan(_that.companyId,_that.planId,_that.billingCycle,_that.autoRenew,_that.startsAt,_that.endsAt);case _UploadDocument() when uploadDocument != null:
return uploadDocument(_that.companyId,_that.documentType,_that.documentName,_that.filePath);case _DeleteDocument() when deleteDocument != null:
return deleteDocument(_that.companyId,_that.documentId);case _LoadCompanyStatistics() when loadCompanyStatistics != null:
return loadCompanyStatistics();case _ExportCompanies() when exportCompanies != null:
return exportCompanies(_that.search,_that.status,_that.verificationStatus,_that.country,_that.planType);case _SendWelcomeEmail() when sendWelcomeEmail != null:
return sendWelcomeEmail(_that.companyId);case _ResetCompanyPassword() when resetCompanyPassword != null:
return resetCompanyPassword(_that.companyId);case _ClearError() when clearError != null:
return clearError();case _Reset() when reset != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String search,  String? status,  String? verificationStatus,  String? country,  String? planType,  String sortBy,  String sortOrder,  int page,  int perPage)  loadCompanies,required TResult Function( String id)  loadCompany,required TResult Function( String name,  String businessRegistrationNumber,  String? taxId,  String companyType,  String industryType,  String email,  String? phone,  String? website,  String country,  String city,  String? address,  String? postalCode,  String contactPersonName,  String contactPersonEmail,  String contactPersonPhone,  String? contactPersonPosition,  String? timezone,  String? language,  String? currency,  String? planId,  String? billingCycle,  List<CompanyDocumentInput>? documents,  String? adminNotes)  createCompany,required TResult Function( String id,  String? name,  String? businessRegistrationNumber,  String? taxId,  String? companyType,  String? industryType,  String? email,  String? phone,  String? website,  String? country,  String? city,  String? address,  String? postalCode,  String? contactPersonName,  String? contactPersonEmail,  String? contactPersonPhone,  String? contactPersonPosition,  String? status,  String? verificationStatus,  String? verificationNotes,  String? timezone,  String? language,  String? currency,  String? planId,  String? billingCycle,  String? adminNotes)  updateCompany,required TResult Function( String id)  deleteCompany,required TResult Function( String id,  String status,  String? reason)  updateCompanyStatus,required TResult Function( String id,  String verificationStatus,  String? verificationNotes)  updateVerificationStatus,required TResult Function( String companyId,  String planId,  String? billingCycle,  bool? autoRenew,  DateTime? startsAt,  DateTime? endsAt)  assignPlan,required TResult Function( String companyId,  String documentType,  String documentName,  String filePath)  uploadDocument,required TResult Function( String companyId,  String documentId)  deleteDocument,required TResult Function()  loadCompanyStatistics,required TResult Function( String? search,  String? status,  String? verificationStatus,  String? country,  String? planType)  exportCompanies,required TResult Function( String companyId)  sendWelcomeEmail,required TResult Function( String companyId)  resetCompanyPassword,required TResult Function()  clearError,required TResult Function()  reset,}) {final _that = this;
switch (_that) {
case _LoadCompanies():
return loadCompanies(_that.search,_that.status,_that.verificationStatus,_that.country,_that.planType,_that.sortBy,_that.sortOrder,_that.page,_that.perPage);case _LoadCompany():
return loadCompany(_that.id);case _CreateCompany():
return createCompany(_that.name,_that.businessRegistrationNumber,_that.taxId,_that.companyType,_that.industryType,_that.email,_that.phone,_that.website,_that.country,_that.city,_that.address,_that.postalCode,_that.contactPersonName,_that.contactPersonEmail,_that.contactPersonPhone,_that.contactPersonPosition,_that.timezone,_that.language,_that.currency,_that.planId,_that.billingCycle,_that.documents,_that.adminNotes);case _UpdateCompany():
return updateCompany(_that.id,_that.name,_that.businessRegistrationNumber,_that.taxId,_that.companyType,_that.industryType,_that.email,_that.phone,_that.website,_that.country,_that.city,_that.address,_that.postalCode,_that.contactPersonName,_that.contactPersonEmail,_that.contactPersonPhone,_that.contactPersonPosition,_that.status,_that.verificationStatus,_that.verificationNotes,_that.timezone,_that.language,_that.currency,_that.planId,_that.billingCycle,_that.adminNotes);case _DeleteCompany():
return deleteCompany(_that.id);case _UpdateCompanyStatus():
return updateCompanyStatus(_that.id,_that.status,_that.reason);case _UpdateVerificationStatus():
return updateVerificationStatus(_that.id,_that.verificationStatus,_that.verificationNotes);case _AssignPlan():
return assignPlan(_that.companyId,_that.planId,_that.billingCycle,_that.autoRenew,_that.startsAt,_that.endsAt);case _UploadDocument():
return uploadDocument(_that.companyId,_that.documentType,_that.documentName,_that.filePath);case _DeleteDocument():
return deleteDocument(_that.companyId,_that.documentId);case _LoadCompanyStatistics():
return loadCompanyStatistics();case _ExportCompanies():
return exportCompanies(_that.search,_that.status,_that.verificationStatus,_that.country,_that.planType);case _SendWelcomeEmail():
return sendWelcomeEmail(_that.companyId);case _ResetCompanyPassword():
return resetCompanyPassword(_that.companyId);case _ClearError():
return clearError();case _Reset():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String search,  String? status,  String? verificationStatus,  String? country,  String? planType,  String sortBy,  String sortOrder,  int page,  int perPage)?  loadCompanies,TResult? Function( String id)?  loadCompany,TResult? Function( String name,  String businessRegistrationNumber,  String? taxId,  String companyType,  String industryType,  String email,  String? phone,  String? website,  String country,  String city,  String? address,  String? postalCode,  String contactPersonName,  String contactPersonEmail,  String contactPersonPhone,  String? contactPersonPosition,  String? timezone,  String? language,  String? currency,  String? planId,  String? billingCycle,  List<CompanyDocumentInput>? documents,  String? adminNotes)?  createCompany,TResult? Function( String id,  String? name,  String? businessRegistrationNumber,  String? taxId,  String? companyType,  String? industryType,  String? email,  String? phone,  String? website,  String? country,  String? city,  String? address,  String? postalCode,  String? contactPersonName,  String? contactPersonEmail,  String? contactPersonPhone,  String? contactPersonPosition,  String? status,  String? verificationStatus,  String? verificationNotes,  String? timezone,  String? language,  String? currency,  String? planId,  String? billingCycle,  String? adminNotes)?  updateCompany,TResult? Function( String id)?  deleteCompany,TResult? Function( String id,  String status,  String? reason)?  updateCompanyStatus,TResult? Function( String id,  String verificationStatus,  String? verificationNotes)?  updateVerificationStatus,TResult? Function( String companyId,  String planId,  String? billingCycle,  bool? autoRenew,  DateTime? startsAt,  DateTime? endsAt)?  assignPlan,TResult? Function( String companyId,  String documentType,  String documentName,  String filePath)?  uploadDocument,TResult? Function( String companyId,  String documentId)?  deleteDocument,TResult? Function()?  loadCompanyStatistics,TResult? Function( String? search,  String? status,  String? verificationStatus,  String? country,  String? planType)?  exportCompanies,TResult? Function( String companyId)?  sendWelcomeEmail,TResult? Function( String companyId)?  resetCompanyPassword,TResult? Function()?  clearError,TResult? Function()?  reset,}) {final _that = this;
switch (_that) {
case _LoadCompanies() when loadCompanies != null:
return loadCompanies(_that.search,_that.status,_that.verificationStatus,_that.country,_that.planType,_that.sortBy,_that.sortOrder,_that.page,_that.perPage);case _LoadCompany() when loadCompany != null:
return loadCompany(_that.id);case _CreateCompany() when createCompany != null:
return createCompany(_that.name,_that.businessRegistrationNumber,_that.taxId,_that.companyType,_that.industryType,_that.email,_that.phone,_that.website,_that.country,_that.city,_that.address,_that.postalCode,_that.contactPersonName,_that.contactPersonEmail,_that.contactPersonPhone,_that.contactPersonPosition,_that.timezone,_that.language,_that.currency,_that.planId,_that.billingCycle,_that.documents,_that.adminNotes);case _UpdateCompany() when updateCompany != null:
return updateCompany(_that.id,_that.name,_that.businessRegistrationNumber,_that.taxId,_that.companyType,_that.industryType,_that.email,_that.phone,_that.website,_that.country,_that.city,_that.address,_that.postalCode,_that.contactPersonName,_that.contactPersonEmail,_that.contactPersonPhone,_that.contactPersonPosition,_that.status,_that.verificationStatus,_that.verificationNotes,_that.timezone,_that.language,_that.currency,_that.planId,_that.billingCycle,_that.adminNotes);case _DeleteCompany() when deleteCompany != null:
return deleteCompany(_that.id);case _UpdateCompanyStatus() when updateCompanyStatus != null:
return updateCompanyStatus(_that.id,_that.status,_that.reason);case _UpdateVerificationStatus() when updateVerificationStatus != null:
return updateVerificationStatus(_that.id,_that.verificationStatus,_that.verificationNotes);case _AssignPlan() when assignPlan != null:
return assignPlan(_that.companyId,_that.planId,_that.billingCycle,_that.autoRenew,_that.startsAt,_that.endsAt);case _UploadDocument() when uploadDocument != null:
return uploadDocument(_that.companyId,_that.documentType,_that.documentName,_that.filePath);case _DeleteDocument() when deleteDocument != null:
return deleteDocument(_that.companyId,_that.documentId);case _LoadCompanyStatistics() when loadCompanyStatistics != null:
return loadCompanyStatistics();case _ExportCompanies() when exportCompanies != null:
return exportCompanies(_that.search,_that.status,_that.verificationStatus,_that.country,_that.planType);case _SendWelcomeEmail() when sendWelcomeEmail != null:
return sendWelcomeEmail(_that.companyId);case _ResetCompanyPassword() when resetCompanyPassword != null:
return resetCompanyPassword(_that.companyId);case _ClearError() when clearError != null:
return clearError();case _Reset() when reset != null:
return reset();case _:
  return null;

}
}

}

/// @nodoc


class _LoadCompanies with DiagnosticableTreeMixin implements CompanyManagementEvent {
  const _LoadCompanies({this.search = '', this.status, this.verificationStatus, this.country, this.planType, this.sortBy = 'created_at', this.sortOrder = 'desc', this.page = 1, this.perPage = 20});
  

@JsonKey() final  String search;
 final  String? status;
 final  String? verificationStatus;
 final  String? country;
 final  String? planType;
@JsonKey() final  String sortBy;
@JsonKey() final  String sortOrder;
@JsonKey() final  int page;
@JsonKey() final  int perPage;

/// Create a copy of CompanyManagementEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadCompaniesCopyWith<_LoadCompanies> get copyWith => __$LoadCompaniesCopyWithImpl<_LoadCompanies>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CompanyManagementEvent.loadCompanies'))
    ..add(DiagnosticsProperty('search', search))..add(DiagnosticsProperty('status', status))..add(DiagnosticsProperty('verificationStatus', verificationStatus))..add(DiagnosticsProperty('country', country))..add(DiagnosticsProperty('planType', planType))..add(DiagnosticsProperty('sortBy', sortBy))..add(DiagnosticsProperty('sortOrder', sortOrder))..add(DiagnosticsProperty('page', page))..add(DiagnosticsProperty('perPage', perPage));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoadCompanies&&(identical(other.search, search) || other.search == search)&&(identical(other.status, status) || other.status == status)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.country, country) || other.country == country)&&(identical(other.planType, planType) || other.planType == planType)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.page, page) || other.page == page)&&(identical(other.perPage, perPage) || other.perPage == perPage));
}


@override
int get hashCode => Object.hash(runtimeType,search,status,verificationStatus,country,planType,sortBy,sortOrder,page,perPage);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CompanyManagementEvent.loadCompanies(search: $search, status: $status, verificationStatus: $verificationStatus, country: $country, planType: $planType, sortBy: $sortBy, sortOrder: $sortOrder, page: $page, perPage: $perPage)';
}


}

/// @nodoc
abstract mixin class _$LoadCompaniesCopyWith<$Res> implements $CompanyManagementEventCopyWith<$Res> {
  factory _$LoadCompaniesCopyWith(_LoadCompanies value, $Res Function(_LoadCompanies) _then) = __$LoadCompaniesCopyWithImpl;
@useResult
$Res call({
 String search, String? status, String? verificationStatus, String? country, String? planType, String sortBy, String sortOrder, int page, int perPage
});




}
/// @nodoc
class __$LoadCompaniesCopyWithImpl<$Res>
    implements _$LoadCompaniesCopyWith<$Res> {
  __$LoadCompaniesCopyWithImpl(this._self, this._then);

  final _LoadCompanies _self;
  final $Res Function(_LoadCompanies) _then;

/// Create a copy of CompanyManagementEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? search = null,Object? status = freezed,Object? verificationStatus = freezed,Object? country = freezed,Object? planType = freezed,Object? sortBy = null,Object? sortOrder = null,Object? page = null,Object? perPage = null,}) {
  return _then(_LoadCompanies(
search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,verificationStatus: freezed == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,planType: freezed == planType ? _self.planType : planType // ignore: cast_nullable_to_non_nullable
as String?,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as String,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,perPage: null == perPage ? _self.perPage : perPage // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _LoadCompany with DiagnosticableTreeMixin implements CompanyManagementEvent {
  const _LoadCompany(this.id);
  

 final  String id;

/// Create a copy of CompanyManagementEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadCompanyCopyWith<_LoadCompany> get copyWith => __$LoadCompanyCopyWithImpl<_LoadCompany>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CompanyManagementEvent.loadCompany'))
    ..add(DiagnosticsProperty('id', id));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoadCompany&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,id);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CompanyManagementEvent.loadCompany(id: $id)';
}


}

/// @nodoc
abstract mixin class _$LoadCompanyCopyWith<$Res> implements $CompanyManagementEventCopyWith<$Res> {
  factory _$LoadCompanyCopyWith(_LoadCompany value, $Res Function(_LoadCompany) _then) = __$LoadCompanyCopyWithImpl;
@useResult
$Res call({
 String id
});




}
/// @nodoc
class __$LoadCompanyCopyWithImpl<$Res>
    implements _$LoadCompanyCopyWith<$Res> {
  __$LoadCompanyCopyWithImpl(this._self, this._then);

  final _LoadCompany _self;
  final $Res Function(_LoadCompany) _then;

/// Create a copy of CompanyManagementEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,}) {
  return _then(_LoadCompany(
null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _CreateCompany with DiagnosticableTreeMixin implements CompanyManagementEvent {
  const _CreateCompany({required this.name, required this.businessRegistrationNumber, this.taxId, required this.companyType, required this.industryType, required this.email, this.phone, this.website, required this.country, required this.city, this.address, this.postalCode, required this.contactPersonName, required this.contactPersonEmail, required this.contactPersonPhone, this.contactPersonPosition, this.timezone, this.language, this.currency, this.planId, this.billingCycle, final  List<CompanyDocumentInput>? documents, this.adminNotes}): _documents = documents;
  

 final  String name;
 final  String businessRegistrationNumber;
 final  String? taxId;
 final  String companyType;
 final  String industryType;
 final  String email;
 final  String? phone;
 final  String? website;
 final  String country;
 final  String city;
 final  String? address;
 final  String? postalCode;
 final  String contactPersonName;
 final  String contactPersonEmail;
 final  String contactPersonPhone;
 final  String? contactPersonPosition;
 final  String? timezone;
 final  String? language;
 final  String? currency;
 final  String? planId;
 final  String? billingCycle;
 final  List<CompanyDocumentInput>? _documents;
 List<CompanyDocumentInput>? get documents {
  final value = _documents;
  if (value == null) return null;
  if (_documents is EqualUnmodifiableListView) return _documents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  String? adminNotes;

/// Create a copy of CompanyManagementEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateCompanyCopyWith<_CreateCompany> get copyWith => __$CreateCompanyCopyWithImpl<_CreateCompany>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CompanyManagementEvent.createCompany'))
    ..add(DiagnosticsProperty('name', name))..add(DiagnosticsProperty('businessRegistrationNumber', businessRegistrationNumber))..add(DiagnosticsProperty('taxId', taxId))..add(DiagnosticsProperty('companyType', companyType))..add(DiagnosticsProperty('industryType', industryType))..add(DiagnosticsProperty('email', email))..add(DiagnosticsProperty('phone', phone))..add(DiagnosticsProperty('website', website))..add(DiagnosticsProperty('country', country))..add(DiagnosticsProperty('city', city))..add(DiagnosticsProperty('address', address))..add(DiagnosticsProperty('postalCode', postalCode))..add(DiagnosticsProperty('contactPersonName', contactPersonName))..add(DiagnosticsProperty('contactPersonEmail', contactPersonEmail))..add(DiagnosticsProperty('contactPersonPhone', contactPersonPhone))..add(DiagnosticsProperty('contactPersonPosition', contactPersonPosition))..add(DiagnosticsProperty('timezone', timezone))..add(DiagnosticsProperty('language', language))..add(DiagnosticsProperty('currency', currency))..add(DiagnosticsProperty('planId', planId))..add(DiagnosticsProperty('billingCycle', billingCycle))..add(DiagnosticsProperty('documents', documents))..add(DiagnosticsProperty('adminNotes', adminNotes));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateCompany&&(identical(other.name, name) || other.name == name)&&(identical(other.businessRegistrationNumber, businessRegistrationNumber) || other.businessRegistrationNumber == businessRegistrationNumber)&&(identical(other.taxId, taxId) || other.taxId == taxId)&&(identical(other.companyType, companyType) || other.companyType == companyType)&&(identical(other.industryType, industryType) || other.industryType == industryType)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.website, website) || other.website == website)&&(identical(other.country, country) || other.country == country)&&(identical(other.city, city) || other.city == city)&&(identical(other.address, address) || other.address == address)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.contactPersonName, contactPersonName) || other.contactPersonName == contactPersonName)&&(identical(other.contactPersonEmail, contactPersonEmail) || other.contactPersonEmail == contactPersonEmail)&&(identical(other.contactPersonPhone, contactPersonPhone) || other.contactPersonPhone == contactPersonPhone)&&(identical(other.contactPersonPosition, contactPersonPosition) || other.contactPersonPosition == contactPersonPosition)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.language, language) || other.language == language)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.billingCycle, billingCycle) || other.billingCycle == billingCycle)&&const DeepCollectionEquality().equals(other._documents, _documents)&&(identical(other.adminNotes, adminNotes) || other.adminNotes == adminNotes));
}


@override
int get hashCode => Object.hashAll([runtimeType,name,businessRegistrationNumber,taxId,companyType,industryType,email,phone,website,country,city,address,postalCode,contactPersonName,contactPersonEmail,contactPersonPhone,contactPersonPosition,timezone,language,currency,planId,billingCycle,const DeepCollectionEquality().hash(_documents),adminNotes]);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CompanyManagementEvent.createCompany(name: $name, businessRegistrationNumber: $businessRegistrationNumber, taxId: $taxId, companyType: $companyType, industryType: $industryType, email: $email, phone: $phone, website: $website, country: $country, city: $city, address: $address, postalCode: $postalCode, contactPersonName: $contactPersonName, contactPersonEmail: $contactPersonEmail, contactPersonPhone: $contactPersonPhone, contactPersonPosition: $contactPersonPosition, timezone: $timezone, language: $language, currency: $currency, planId: $planId, billingCycle: $billingCycle, documents: $documents, adminNotes: $adminNotes)';
}


}

/// @nodoc
abstract mixin class _$CreateCompanyCopyWith<$Res> implements $CompanyManagementEventCopyWith<$Res> {
  factory _$CreateCompanyCopyWith(_CreateCompany value, $Res Function(_CreateCompany) _then) = __$CreateCompanyCopyWithImpl;
@useResult
$Res call({
 String name, String businessRegistrationNumber, String? taxId, String companyType, String industryType, String email, String? phone, String? website, String country, String city, String? address, String? postalCode, String contactPersonName, String contactPersonEmail, String contactPersonPhone, String? contactPersonPosition, String? timezone, String? language, String? currency, String? planId, String? billingCycle, List<CompanyDocumentInput>? documents, String? adminNotes
});




}
/// @nodoc
class __$CreateCompanyCopyWithImpl<$Res>
    implements _$CreateCompanyCopyWith<$Res> {
  __$CreateCompanyCopyWithImpl(this._self, this._then);

  final _CreateCompany _self;
  final $Res Function(_CreateCompany) _then;

/// Create a copy of CompanyManagementEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? name = null,Object? businessRegistrationNumber = null,Object? taxId = freezed,Object? companyType = null,Object? industryType = null,Object? email = null,Object? phone = freezed,Object? website = freezed,Object? country = null,Object? city = null,Object? address = freezed,Object? postalCode = freezed,Object? contactPersonName = null,Object? contactPersonEmail = null,Object? contactPersonPhone = null,Object? contactPersonPosition = freezed,Object? timezone = freezed,Object? language = freezed,Object? currency = freezed,Object? planId = freezed,Object? billingCycle = freezed,Object? documents = freezed,Object? adminNotes = freezed,}) {
  return _then(_CreateCompany(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,businessRegistrationNumber: null == businessRegistrationNumber ? _self.businessRegistrationNumber : businessRegistrationNumber // ignore: cast_nullable_to_non_nullable
as String,taxId: freezed == taxId ? _self.taxId : taxId // ignore: cast_nullable_to_non_nullable
as String?,companyType: null == companyType ? _self.companyType : companyType // ignore: cast_nullable_to_non_nullable
as String,industryType: null == industryType ? _self.industryType : industryType // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,postalCode: freezed == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String?,contactPersonName: null == contactPersonName ? _self.contactPersonName : contactPersonName // ignore: cast_nullable_to_non_nullable
as String,contactPersonEmail: null == contactPersonEmail ? _self.contactPersonEmail : contactPersonEmail // ignore: cast_nullable_to_non_nullable
as String,contactPersonPhone: null == contactPersonPhone ? _self.contactPersonPhone : contactPersonPhone // ignore: cast_nullable_to_non_nullable
as String,contactPersonPosition: freezed == contactPersonPosition ? _self.contactPersonPosition : contactPersonPosition // ignore: cast_nullable_to_non_nullable
as String?,timezone: freezed == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String?,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,planId: freezed == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String?,billingCycle: freezed == billingCycle ? _self.billingCycle : billingCycle // ignore: cast_nullable_to_non_nullable
as String?,documents: freezed == documents ? _self._documents : documents // ignore: cast_nullable_to_non_nullable
as List<CompanyDocumentInput>?,adminNotes: freezed == adminNotes ? _self.adminNotes : adminNotes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _UpdateCompany with DiagnosticableTreeMixin implements CompanyManagementEvent {
  const _UpdateCompany({required this.id, this.name, this.businessRegistrationNumber, this.taxId, this.companyType, this.industryType, this.email, this.phone, this.website, this.country, this.city, this.address, this.postalCode, this.contactPersonName, this.contactPersonEmail, this.contactPersonPhone, this.contactPersonPosition, this.status, this.verificationStatus, this.verificationNotes, this.timezone, this.language, this.currency, this.planId, this.billingCycle, this.adminNotes});
  

 final  String id;
 final  String? name;
 final  String? businessRegistrationNumber;
 final  String? taxId;
 final  String? companyType;
 final  String? industryType;
 final  String? email;
 final  String? phone;
 final  String? website;
 final  String? country;
 final  String? city;
 final  String? address;
 final  String? postalCode;
 final  String? contactPersonName;
 final  String? contactPersonEmail;
 final  String? contactPersonPhone;
 final  String? contactPersonPosition;
 final  String? status;
 final  String? verificationStatus;
 final  String? verificationNotes;
 final  String? timezone;
 final  String? language;
 final  String? currency;
 final  String? planId;
 final  String? billingCycle;
 final  String? adminNotes;

/// Create a copy of CompanyManagementEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateCompanyCopyWith<_UpdateCompany> get copyWith => __$UpdateCompanyCopyWithImpl<_UpdateCompany>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CompanyManagementEvent.updateCompany'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('name', name))..add(DiagnosticsProperty('businessRegistrationNumber', businessRegistrationNumber))..add(DiagnosticsProperty('taxId', taxId))..add(DiagnosticsProperty('companyType', companyType))..add(DiagnosticsProperty('industryType', industryType))..add(DiagnosticsProperty('email', email))..add(DiagnosticsProperty('phone', phone))..add(DiagnosticsProperty('website', website))..add(DiagnosticsProperty('country', country))..add(DiagnosticsProperty('city', city))..add(DiagnosticsProperty('address', address))..add(DiagnosticsProperty('postalCode', postalCode))..add(DiagnosticsProperty('contactPersonName', contactPersonName))..add(DiagnosticsProperty('contactPersonEmail', contactPersonEmail))..add(DiagnosticsProperty('contactPersonPhone', contactPersonPhone))..add(DiagnosticsProperty('contactPersonPosition', contactPersonPosition))..add(DiagnosticsProperty('status', status))..add(DiagnosticsProperty('verificationStatus', verificationStatus))..add(DiagnosticsProperty('verificationNotes', verificationNotes))..add(DiagnosticsProperty('timezone', timezone))..add(DiagnosticsProperty('language', language))..add(DiagnosticsProperty('currency', currency))..add(DiagnosticsProperty('planId', planId))..add(DiagnosticsProperty('billingCycle', billingCycle))..add(DiagnosticsProperty('adminNotes', adminNotes));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateCompany&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.businessRegistrationNumber, businessRegistrationNumber) || other.businessRegistrationNumber == businessRegistrationNumber)&&(identical(other.taxId, taxId) || other.taxId == taxId)&&(identical(other.companyType, companyType) || other.companyType == companyType)&&(identical(other.industryType, industryType) || other.industryType == industryType)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.website, website) || other.website == website)&&(identical(other.country, country) || other.country == country)&&(identical(other.city, city) || other.city == city)&&(identical(other.address, address) || other.address == address)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.contactPersonName, contactPersonName) || other.contactPersonName == contactPersonName)&&(identical(other.contactPersonEmail, contactPersonEmail) || other.contactPersonEmail == contactPersonEmail)&&(identical(other.contactPersonPhone, contactPersonPhone) || other.contactPersonPhone == contactPersonPhone)&&(identical(other.contactPersonPosition, contactPersonPosition) || other.contactPersonPosition == contactPersonPosition)&&(identical(other.status, status) || other.status == status)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.verificationNotes, verificationNotes) || other.verificationNotes == verificationNotes)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.language, language) || other.language == language)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.billingCycle, billingCycle) || other.billingCycle == billingCycle)&&(identical(other.adminNotes, adminNotes) || other.adminNotes == adminNotes));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,name,businessRegistrationNumber,taxId,companyType,industryType,email,phone,website,country,city,address,postalCode,contactPersonName,contactPersonEmail,contactPersonPhone,contactPersonPosition,status,verificationStatus,verificationNotes,timezone,language,currency,planId,billingCycle,adminNotes]);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CompanyManagementEvent.updateCompany(id: $id, name: $name, businessRegistrationNumber: $businessRegistrationNumber, taxId: $taxId, companyType: $companyType, industryType: $industryType, email: $email, phone: $phone, website: $website, country: $country, city: $city, address: $address, postalCode: $postalCode, contactPersonName: $contactPersonName, contactPersonEmail: $contactPersonEmail, contactPersonPhone: $contactPersonPhone, contactPersonPosition: $contactPersonPosition, status: $status, verificationStatus: $verificationStatus, verificationNotes: $verificationNotes, timezone: $timezone, language: $language, currency: $currency, planId: $planId, billingCycle: $billingCycle, adminNotes: $adminNotes)';
}


}

/// @nodoc
abstract mixin class _$UpdateCompanyCopyWith<$Res> implements $CompanyManagementEventCopyWith<$Res> {
  factory _$UpdateCompanyCopyWith(_UpdateCompany value, $Res Function(_UpdateCompany) _then) = __$UpdateCompanyCopyWithImpl;
@useResult
$Res call({
 String id, String? name, String? businessRegistrationNumber, String? taxId, String? companyType, String? industryType, String? email, String? phone, String? website, String? country, String? city, String? address, String? postalCode, String? contactPersonName, String? contactPersonEmail, String? contactPersonPhone, String? contactPersonPosition, String? status, String? verificationStatus, String? verificationNotes, String? timezone, String? language, String? currency, String? planId, String? billingCycle, String? adminNotes
});




}
/// @nodoc
class __$UpdateCompanyCopyWithImpl<$Res>
    implements _$UpdateCompanyCopyWith<$Res> {
  __$UpdateCompanyCopyWithImpl(this._self, this._then);

  final _UpdateCompany _self;
  final $Res Function(_UpdateCompany) _then;

/// Create a copy of CompanyManagementEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = freezed,Object? businessRegistrationNumber = freezed,Object? taxId = freezed,Object? companyType = freezed,Object? industryType = freezed,Object? email = freezed,Object? phone = freezed,Object? website = freezed,Object? country = freezed,Object? city = freezed,Object? address = freezed,Object? postalCode = freezed,Object? contactPersonName = freezed,Object? contactPersonEmail = freezed,Object? contactPersonPhone = freezed,Object? contactPersonPosition = freezed,Object? status = freezed,Object? verificationStatus = freezed,Object? verificationNotes = freezed,Object? timezone = freezed,Object? language = freezed,Object? currency = freezed,Object? planId = freezed,Object? billingCycle = freezed,Object? adminNotes = freezed,}) {
  return _then(_UpdateCompany(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,businessRegistrationNumber: freezed == businessRegistrationNumber ? _self.businessRegistrationNumber : businessRegistrationNumber // ignore: cast_nullable_to_non_nullable
as String?,taxId: freezed == taxId ? _self.taxId : taxId // ignore: cast_nullable_to_non_nullable
as String?,companyType: freezed == companyType ? _self.companyType : companyType // ignore: cast_nullable_to_non_nullable
as String?,industryType: freezed == industryType ? _self.industryType : industryType // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,postalCode: freezed == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String?,contactPersonName: freezed == contactPersonName ? _self.contactPersonName : contactPersonName // ignore: cast_nullable_to_non_nullable
as String?,contactPersonEmail: freezed == contactPersonEmail ? _self.contactPersonEmail : contactPersonEmail // ignore: cast_nullable_to_non_nullable
as String?,contactPersonPhone: freezed == contactPersonPhone ? _self.contactPersonPhone : contactPersonPhone // ignore: cast_nullable_to_non_nullable
as String?,contactPersonPosition: freezed == contactPersonPosition ? _self.contactPersonPosition : contactPersonPosition // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,verificationStatus: freezed == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String?,verificationNotes: freezed == verificationNotes ? _self.verificationNotes : verificationNotes // ignore: cast_nullable_to_non_nullable
as String?,timezone: freezed == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String?,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,planId: freezed == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String?,billingCycle: freezed == billingCycle ? _self.billingCycle : billingCycle // ignore: cast_nullable_to_non_nullable
as String?,adminNotes: freezed == adminNotes ? _self.adminNotes : adminNotes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _DeleteCompany with DiagnosticableTreeMixin implements CompanyManagementEvent {
  const _DeleteCompany(this.id);
  

 final  String id;

/// Create a copy of CompanyManagementEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeleteCompanyCopyWith<_DeleteCompany> get copyWith => __$DeleteCompanyCopyWithImpl<_DeleteCompany>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CompanyManagementEvent.deleteCompany'))
    ..add(DiagnosticsProperty('id', id));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeleteCompany&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,id);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CompanyManagementEvent.deleteCompany(id: $id)';
}


}

/// @nodoc
abstract mixin class _$DeleteCompanyCopyWith<$Res> implements $CompanyManagementEventCopyWith<$Res> {
  factory _$DeleteCompanyCopyWith(_DeleteCompany value, $Res Function(_DeleteCompany) _then) = __$DeleteCompanyCopyWithImpl;
@useResult
$Res call({
 String id
});




}
/// @nodoc
class __$DeleteCompanyCopyWithImpl<$Res>
    implements _$DeleteCompanyCopyWith<$Res> {
  __$DeleteCompanyCopyWithImpl(this._self, this._then);

  final _DeleteCompany _self;
  final $Res Function(_DeleteCompany) _then;

/// Create a copy of CompanyManagementEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,}) {
  return _then(_DeleteCompany(
null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _UpdateCompanyStatus with DiagnosticableTreeMixin implements CompanyManagementEvent {
  const _UpdateCompanyStatus({required this.id, required this.status, this.reason});
  

 final  String id;
 final  String status;
 final  String? reason;

/// Create a copy of CompanyManagementEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateCompanyStatusCopyWith<_UpdateCompanyStatus> get copyWith => __$UpdateCompanyStatusCopyWithImpl<_UpdateCompanyStatus>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CompanyManagementEvent.updateCompanyStatus'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('status', status))..add(DiagnosticsProperty('reason', reason));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateCompanyStatus&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode => Object.hash(runtimeType,id,status,reason);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CompanyManagementEvent.updateCompanyStatus(id: $id, status: $status, reason: $reason)';
}


}

/// @nodoc
abstract mixin class _$UpdateCompanyStatusCopyWith<$Res> implements $CompanyManagementEventCopyWith<$Res> {
  factory _$UpdateCompanyStatusCopyWith(_UpdateCompanyStatus value, $Res Function(_UpdateCompanyStatus) _then) = __$UpdateCompanyStatusCopyWithImpl;
@useResult
$Res call({
 String id, String status, String? reason
});




}
/// @nodoc
class __$UpdateCompanyStatusCopyWithImpl<$Res>
    implements _$UpdateCompanyStatusCopyWith<$Res> {
  __$UpdateCompanyStatusCopyWithImpl(this._self, this._then);

  final _UpdateCompanyStatus _self;
  final $Res Function(_UpdateCompanyStatus) _then;

/// Create a copy of CompanyManagementEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,Object? reason = freezed,}) {
  return _then(_UpdateCompanyStatus(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _UpdateVerificationStatus with DiagnosticableTreeMixin implements CompanyManagementEvent {
  const _UpdateVerificationStatus({required this.id, required this.verificationStatus, this.verificationNotes});
  

 final  String id;
 final  String verificationStatus;
 final  String? verificationNotes;

/// Create a copy of CompanyManagementEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateVerificationStatusCopyWith<_UpdateVerificationStatus> get copyWith => __$UpdateVerificationStatusCopyWithImpl<_UpdateVerificationStatus>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CompanyManagementEvent.updateVerificationStatus'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('verificationStatus', verificationStatus))..add(DiagnosticsProperty('verificationNotes', verificationNotes));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateVerificationStatus&&(identical(other.id, id) || other.id == id)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.verificationNotes, verificationNotes) || other.verificationNotes == verificationNotes));
}


@override
int get hashCode => Object.hash(runtimeType,id,verificationStatus,verificationNotes);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CompanyManagementEvent.updateVerificationStatus(id: $id, verificationStatus: $verificationStatus, verificationNotes: $verificationNotes)';
}


}

/// @nodoc
abstract mixin class _$UpdateVerificationStatusCopyWith<$Res> implements $CompanyManagementEventCopyWith<$Res> {
  factory _$UpdateVerificationStatusCopyWith(_UpdateVerificationStatus value, $Res Function(_UpdateVerificationStatus) _then) = __$UpdateVerificationStatusCopyWithImpl;
@useResult
$Res call({
 String id, String verificationStatus, String? verificationNotes
});




}
/// @nodoc
class __$UpdateVerificationStatusCopyWithImpl<$Res>
    implements _$UpdateVerificationStatusCopyWith<$Res> {
  __$UpdateVerificationStatusCopyWithImpl(this._self, this._then);

  final _UpdateVerificationStatus _self;
  final $Res Function(_UpdateVerificationStatus) _then;

/// Create a copy of CompanyManagementEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,Object? verificationStatus = null,Object? verificationNotes = freezed,}) {
  return _then(_UpdateVerificationStatus(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String,verificationNotes: freezed == verificationNotes ? _self.verificationNotes : verificationNotes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _AssignPlan with DiagnosticableTreeMixin implements CompanyManagementEvent {
  const _AssignPlan({required this.companyId, required this.planId, this.billingCycle, this.autoRenew, this.startsAt, this.endsAt});
  

 final  String companyId;
 final  String planId;
 final  String? billingCycle;
 final  bool? autoRenew;
 final  DateTime? startsAt;
 final  DateTime? endsAt;

/// Create a copy of CompanyManagementEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssignPlanCopyWith<_AssignPlan> get copyWith => __$AssignPlanCopyWithImpl<_AssignPlan>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CompanyManagementEvent.assignPlan'))
    ..add(DiagnosticsProperty('companyId', companyId))..add(DiagnosticsProperty('planId', planId))..add(DiagnosticsProperty('billingCycle', billingCycle))..add(DiagnosticsProperty('autoRenew', autoRenew))..add(DiagnosticsProperty('startsAt', startsAt))..add(DiagnosticsProperty('endsAt', endsAt));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssignPlan&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.billingCycle, billingCycle) || other.billingCycle == billingCycle)&&(identical(other.autoRenew, autoRenew) || other.autoRenew == autoRenew)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.endsAt, endsAt) || other.endsAt == endsAt));
}


@override
int get hashCode => Object.hash(runtimeType,companyId,planId,billingCycle,autoRenew,startsAt,endsAt);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CompanyManagementEvent.assignPlan(companyId: $companyId, planId: $planId, billingCycle: $billingCycle, autoRenew: $autoRenew, startsAt: $startsAt, endsAt: $endsAt)';
}


}

/// @nodoc
abstract mixin class _$AssignPlanCopyWith<$Res> implements $CompanyManagementEventCopyWith<$Res> {
  factory _$AssignPlanCopyWith(_AssignPlan value, $Res Function(_AssignPlan) _then) = __$AssignPlanCopyWithImpl;
@useResult
$Res call({
 String companyId, String planId, String? billingCycle, bool? autoRenew, DateTime? startsAt, DateTime? endsAt
});




}
/// @nodoc
class __$AssignPlanCopyWithImpl<$Res>
    implements _$AssignPlanCopyWith<$Res> {
  __$AssignPlanCopyWithImpl(this._self, this._then);

  final _AssignPlan _self;
  final $Res Function(_AssignPlan) _then;

/// Create a copy of CompanyManagementEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? companyId = null,Object? planId = null,Object? billingCycle = freezed,Object? autoRenew = freezed,Object? startsAt = freezed,Object? endsAt = freezed,}) {
  return _then(_AssignPlan(
companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,planId: null == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String,billingCycle: freezed == billingCycle ? _self.billingCycle : billingCycle // ignore: cast_nullable_to_non_nullable
as String?,autoRenew: freezed == autoRenew ? _self.autoRenew : autoRenew // ignore: cast_nullable_to_non_nullable
as bool?,startsAt: freezed == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endsAt: freezed == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc


class _UploadDocument with DiagnosticableTreeMixin implements CompanyManagementEvent {
  const _UploadDocument({required this.companyId, required this.documentType, required this.documentName, required this.filePath});
  

 final  String companyId;
 final  String documentType;
 final  String documentName;
 final  String filePath;

/// Create a copy of CompanyManagementEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UploadDocumentCopyWith<_UploadDocument> get copyWith => __$UploadDocumentCopyWithImpl<_UploadDocument>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CompanyManagementEvent.uploadDocument'))
    ..add(DiagnosticsProperty('companyId', companyId))..add(DiagnosticsProperty('documentType', documentType))..add(DiagnosticsProperty('documentName', documentName))..add(DiagnosticsProperty('filePath', filePath));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UploadDocument&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.documentType, documentType) || other.documentType == documentType)&&(identical(other.documentName, documentName) || other.documentName == documentName)&&(identical(other.filePath, filePath) || other.filePath == filePath));
}


@override
int get hashCode => Object.hash(runtimeType,companyId,documentType,documentName,filePath);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CompanyManagementEvent.uploadDocument(companyId: $companyId, documentType: $documentType, documentName: $documentName, filePath: $filePath)';
}


}

/// @nodoc
abstract mixin class _$UploadDocumentCopyWith<$Res> implements $CompanyManagementEventCopyWith<$Res> {
  factory _$UploadDocumentCopyWith(_UploadDocument value, $Res Function(_UploadDocument) _then) = __$UploadDocumentCopyWithImpl;
@useResult
$Res call({
 String companyId, String documentType, String documentName, String filePath
});




}
/// @nodoc
class __$UploadDocumentCopyWithImpl<$Res>
    implements _$UploadDocumentCopyWith<$Res> {
  __$UploadDocumentCopyWithImpl(this._self, this._then);

  final _UploadDocument _self;
  final $Res Function(_UploadDocument) _then;

/// Create a copy of CompanyManagementEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? companyId = null,Object? documentType = null,Object? documentName = null,Object? filePath = null,}) {
  return _then(_UploadDocument(
companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,documentType: null == documentType ? _self.documentType : documentType // ignore: cast_nullable_to_non_nullable
as String,documentName: null == documentName ? _self.documentName : documentName // ignore: cast_nullable_to_non_nullable
as String,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _DeleteDocument with DiagnosticableTreeMixin implements CompanyManagementEvent {
  const _DeleteDocument({required this.companyId, required this.documentId});
  

 final  String companyId;
 final  String documentId;

/// Create a copy of CompanyManagementEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeleteDocumentCopyWith<_DeleteDocument> get copyWith => __$DeleteDocumentCopyWithImpl<_DeleteDocument>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CompanyManagementEvent.deleteDocument'))
    ..add(DiagnosticsProperty('companyId', companyId))..add(DiagnosticsProperty('documentId', documentId));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeleteDocument&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.documentId, documentId) || other.documentId == documentId));
}


@override
int get hashCode => Object.hash(runtimeType,companyId,documentId);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CompanyManagementEvent.deleteDocument(companyId: $companyId, documentId: $documentId)';
}


}

/// @nodoc
abstract mixin class _$DeleteDocumentCopyWith<$Res> implements $CompanyManagementEventCopyWith<$Res> {
  factory _$DeleteDocumentCopyWith(_DeleteDocument value, $Res Function(_DeleteDocument) _then) = __$DeleteDocumentCopyWithImpl;
@useResult
$Res call({
 String companyId, String documentId
});




}
/// @nodoc
class __$DeleteDocumentCopyWithImpl<$Res>
    implements _$DeleteDocumentCopyWith<$Res> {
  __$DeleteDocumentCopyWithImpl(this._self, this._then);

  final _DeleteDocument _self;
  final $Res Function(_DeleteDocument) _then;

/// Create a copy of CompanyManagementEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? companyId = null,Object? documentId = null,}) {
  return _then(_DeleteDocument(
companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _LoadCompanyStatistics with DiagnosticableTreeMixin implements CompanyManagementEvent {
  const _LoadCompanyStatistics();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CompanyManagementEvent.loadCompanyStatistics'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoadCompanyStatistics);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CompanyManagementEvent.loadCompanyStatistics()';
}


}




/// @nodoc


class _ExportCompanies with DiagnosticableTreeMixin implements CompanyManagementEvent {
  const _ExportCompanies({this.search, this.status, this.verificationStatus, this.country, this.planType});
  

 final  String? search;
 final  String? status;
 final  String? verificationStatus;
 final  String? country;
 final  String? planType;

/// Create a copy of CompanyManagementEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExportCompaniesCopyWith<_ExportCompanies> get copyWith => __$ExportCompaniesCopyWithImpl<_ExportCompanies>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CompanyManagementEvent.exportCompanies'))
    ..add(DiagnosticsProperty('search', search))..add(DiagnosticsProperty('status', status))..add(DiagnosticsProperty('verificationStatus', verificationStatus))..add(DiagnosticsProperty('country', country))..add(DiagnosticsProperty('planType', planType));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExportCompanies&&(identical(other.search, search) || other.search == search)&&(identical(other.status, status) || other.status == status)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.country, country) || other.country == country)&&(identical(other.planType, planType) || other.planType == planType));
}


@override
int get hashCode => Object.hash(runtimeType,search,status,verificationStatus,country,planType);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CompanyManagementEvent.exportCompanies(search: $search, status: $status, verificationStatus: $verificationStatus, country: $country, planType: $planType)';
}


}

/// @nodoc
abstract mixin class _$ExportCompaniesCopyWith<$Res> implements $CompanyManagementEventCopyWith<$Res> {
  factory _$ExportCompaniesCopyWith(_ExportCompanies value, $Res Function(_ExportCompanies) _then) = __$ExportCompaniesCopyWithImpl;
@useResult
$Res call({
 String? search, String? status, String? verificationStatus, String? country, String? planType
});




}
/// @nodoc
class __$ExportCompaniesCopyWithImpl<$Res>
    implements _$ExportCompaniesCopyWith<$Res> {
  __$ExportCompaniesCopyWithImpl(this._self, this._then);

  final _ExportCompanies _self;
  final $Res Function(_ExportCompanies) _then;

/// Create a copy of CompanyManagementEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? search = freezed,Object? status = freezed,Object? verificationStatus = freezed,Object? country = freezed,Object? planType = freezed,}) {
  return _then(_ExportCompanies(
search: freezed == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,verificationStatus: freezed == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,planType: freezed == planType ? _self.planType : planType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _SendWelcomeEmail with DiagnosticableTreeMixin implements CompanyManagementEvent {
  const _SendWelcomeEmail(this.companyId);
  

 final  String companyId;

/// Create a copy of CompanyManagementEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SendWelcomeEmailCopyWith<_SendWelcomeEmail> get copyWith => __$SendWelcomeEmailCopyWithImpl<_SendWelcomeEmail>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CompanyManagementEvent.sendWelcomeEmail'))
    ..add(DiagnosticsProperty('companyId', companyId));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SendWelcomeEmail&&(identical(other.companyId, companyId) || other.companyId == companyId));
}


@override
int get hashCode => Object.hash(runtimeType,companyId);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CompanyManagementEvent.sendWelcomeEmail(companyId: $companyId)';
}


}

/// @nodoc
abstract mixin class _$SendWelcomeEmailCopyWith<$Res> implements $CompanyManagementEventCopyWith<$Res> {
  factory _$SendWelcomeEmailCopyWith(_SendWelcomeEmail value, $Res Function(_SendWelcomeEmail) _then) = __$SendWelcomeEmailCopyWithImpl;
@useResult
$Res call({
 String companyId
});




}
/// @nodoc
class __$SendWelcomeEmailCopyWithImpl<$Res>
    implements _$SendWelcomeEmailCopyWith<$Res> {
  __$SendWelcomeEmailCopyWithImpl(this._self, this._then);

  final _SendWelcomeEmail _self;
  final $Res Function(_SendWelcomeEmail) _then;

/// Create a copy of CompanyManagementEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? companyId = null,}) {
  return _then(_SendWelcomeEmail(
null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _ResetCompanyPassword with DiagnosticableTreeMixin implements CompanyManagementEvent {
  const _ResetCompanyPassword(this.companyId);
  

 final  String companyId;

/// Create a copy of CompanyManagementEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResetCompanyPasswordCopyWith<_ResetCompanyPassword> get copyWith => __$ResetCompanyPasswordCopyWithImpl<_ResetCompanyPassword>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CompanyManagementEvent.resetCompanyPassword'))
    ..add(DiagnosticsProperty('companyId', companyId));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResetCompanyPassword&&(identical(other.companyId, companyId) || other.companyId == companyId));
}


@override
int get hashCode => Object.hash(runtimeType,companyId);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CompanyManagementEvent.resetCompanyPassword(companyId: $companyId)';
}


}

/// @nodoc
abstract mixin class _$ResetCompanyPasswordCopyWith<$Res> implements $CompanyManagementEventCopyWith<$Res> {
  factory _$ResetCompanyPasswordCopyWith(_ResetCompanyPassword value, $Res Function(_ResetCompanyPassword) _then) = __$ResetCompanyPasswordCopyWithImpl;
@useResult
$Res call({
 String companyId
});




}
/// @nodoc
class __$ResetCompanyPasswordCopyWithImpl<$Res>
    implements _$ResetCompanyPasswordCopyWith<$Res> {
  __$ResetCompanyPasswordCopyWithImpl(this._self, this._then);

  final _ResetCompanyPassword _self;
  final $Res Function(_ResetCompanyPassword) _then;

/// Create a copy of CompanyManagementEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? companyId = null,}) {
  return _then(_ResetCompanyPassword(
null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _ClearError with DiagnosticableTreeMixin implements CompanyManagementEvent {
  const _ClearError();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CompanyManagementEvent.clearError'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClearError);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CompanyManagementEvent.clearError()';
}


}




/// @nodoc


class _Reset with DiagnosticableTreeMixin implements CompanyManagementEvent {
  const _Reset();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CompanyManagementEvent.reset'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Reset);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CompanyManagementEvent.reset()';
}


}




/// @nodoc
mixin _$CompanyManagementState implements DiagnosticableTreeMixin {




@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CompanyManagementState'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompanyManagementState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CompanyManagementState()';
}


}

/// @nodoc
class $CompanyManagementStateCopyWith<$Res>  {
$CompanyManagementStateCopyWith(CompanyManagementState _, $Res Function(CompanyManagementState) __);
}


/// Adds pattern-matching-related methods to [CompanyManagementState].
extension CompanyManagementStatePatterns on CompanyManagementState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _Loaded value)?  loaded,TResult Function( _CompanyDetailLoaded value)?  companyDetailLoaded,TResult Function( _CompanyCreated value)?  companyCreated,TResult Function( _CompanyUpdated value)?  companyUpdated,TResult Function( _CompanyDeleted value)?  companyDeleted,TResult Function( _CompanyStatusUpdated value)?  companyStatusUpdated,TResult Function( _VerificationStatusUpdated value)?  verificationStatusUpdated,TResult Function( _PlanAssigned value)?  planAssigned,TResult Function( _DocumentUploaded value)?  documentUploaded,TResult Function( _DocumentDeleted value)?  documentDeleted,TResult Function( _Exporting value)?  exporting,TResult Function( _Exported value)?  exported,TResult Function( _WelcomeEmailSent value)?  welcomeEmailSent,TResult Function( _PasswordReset value)?  passwordReset,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Loaded() when loaded != null:
return loaded(_that);case _CompanyDetailLoaded() when companyDetailLoaded != null:
return companyDetailLoaded(_that);case _CompanyCreated() when companyCreated != null:
return companyCreated(_that);case _CompanyUpdated() when companyUpdated != null:
return companyUpdated(_that);case _CompanyDeleted() when companyDeleted != null:
return companyDeleted(_that);case _CompanyStatusUpdated() when companyStatusUpdated != null:
return companyStatusUpdated(_that);case _VerificationStatusUpdated() when verificationStatusUpdated != null:
return verificationStatusUpdated(_that);case _PlanAssigned() when planAssigned != null:
return planAssigned(_that);case _DocumentUploaded() when documentUploaded != null:
return documentUploaded(_that);case _DocumentDeleted() when documentDeleted != null:
return documentDeleted(_that);case _Exporting() when exporting != null:
return exporting(_that);case _Exported() when exported != null:
return exported(_that);case _WelcomeEmailSent() when welcomeEmailSent != null:
return welcomeEmailSent(_that);case _PasswordReset() when passwordReset != null:
return passwordReset(_that);case _Error() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _Loaded value)  loaded,required TResult Function( _CompanyDetailLoaded value)  companyDetailLoaded,required TResult Function( _CompanyCreated value)  companyCreated,required TResult Function( _CompanyUpdated value)  companyUpdated,required TResult Function( _CompanyDeleted value)  companyDeleted,required TResult Function( _CompanyStatusUpdated value)  companyStatusUpdated,required TResult Function( _VerificationStatusUpdated value)  verificationStatusUpdated,required TResult Function( _PlanAssigned value)  planAssigned,required TResult Function( _DocumentUploaded value)  documentUploaded,required TResult Function( _DocumentDeleted value)  documentDeleted,required TResult Function( _Exporting value)  exporting,required TResult Function( _Exported value)  exported,required TResult Function( _WelcomeEmailSent value)  welcomeEmailSent,required TResult Function( _PasswordReset value)  passwordReset,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _Loaded():
return loaded(_that);case _CompanyDetailLoaded():
return companyDetailLoaded(_that);case _CompanyCreated():
return companyCreated(_that);case _CompanyUpdated():
return companyUpdated(_that);case _CompanyDeleted():
return companyDeleted(_that);case _CompanyStatusUpdated():
return companyStatusUpdated(_that);case _VerificationStatusUpdated():
return verificationStatusUpdated(_that);case _PlanAssigned():
return planAssigned(_that);case _DocumentUploaded():
return documentUploaded(_that);case _DocumentDeleted():
return documentDeleted(_that);case _Exporting():
return exporting(_that);case _Exported():
return exported(_that);case _WelcomeEmailSent():
return welcomeEmailSent(_that);case _PasswordReset():
return passwordReset(_that);case _Error():
return error(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _Loaded value)?  loaded,TResult? Function( _CompanyDetailLoaded value)?  companyDetailLoaded,TResult? Function( _CompanyCreated value)?  companyCreated,TResult? Function( _CompanyUpdated value)?  companyUpdated,TResult? Function( _CompanyDeleted value)?  companyDeleted,TResult? Function( _CompanyStatusUpdated value)?  companyStatusUpdated,TResult? Function( _VerificationStatusUpdated value)?  verificationStatusUpdated,TResult? Function( _PlanAssigned value)?  planAssigned,TResult? Function( _DocumentUploaded value)?  documentUploaded,TResult? Function( _DocumentDeleted value)?  documentDeleted,TResult? Function( _Exporting value)?  exporting,TResult? Function( _Exported value)?  exported,TResult? Function( _WelcomeEmailSent value)?  welcomeEmailSent,TResult? Function( _PasswordReset value)?  passwordReset,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Loaded() when loaded != null:
return loaded(_that);case _CompanyDetailLoaded() when companyDetailLoaded != null:
return companyDetailLoaded(_that);case _CompanyCreated() when companyCreated != null:
return companyCreated(_that);case _CompanyUpdated() when companyUpdated != null:
return companyUpdated(_that);case _CompanyDeleted() when companyDeleted != null:
return companyDeleted(_that);case _CompanyStatusUpdated() when companyStatusUpdated != null:
return companyStatusUpdated(_that);case _VerificationStatusUpdated() when verificationStatusUpdated != null:
return verificationStatusUpdated(_that);case _PlanAssigned() when planAssigned != null:
return planAssigned(_that);case _DocumentUploaded() when documentUploaded != null:
return documentUploaded(_that);case _DocumentDeleted() when documentDeleted != null:
return documentDeleted(_that);case _Exporting() when exporting != null:
return exporting(_that);case _Exported() when exported != null:
return exported(_that);case _WelcomeEmailSent() when welcomeEmailSent != null:
return welcomeEmailSent(_that);case _PasswordReset() when passwordReset != null:
return passwordReset(_that);case _Error() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<Company> companies,  int total,  int page,  int perPage,  int totalPages,  String search,  String? status,  String? verificationStatus,  String? country,  String? planType,  String sortBy,  String sortOrder,  CompanyStatistics? statistics,  CompanyFilterOptions filterOptions)?  loaded,TResult Function( Company company,  CompanyUsageStats usageStats,  List<SubscriptionPlan> availablePlans,  CompanyFilterOptions filterOptions)?  companyDetailLoaded,TResult Function( Company company,  String message)?  companyCreated,TResult Function( Company company,  String message)?  companyUpdated,TResult Function( String companyId,  String message)?  companyDeleted,TResult Function( String companyId,  String status,  String message)?  companyStatusUpdated,TResult Function( String companyId,  String verificationStatus,  String message)?  verificationStatusUpdated,TResult Function( String companyId,  SubscriptionPlan plan,  String message)?  planAssigned,TResult Function( String companyId,  CompanyDocument document,  String message)?  documentUploaded,TResult Function( String companyId,  String documentId,  String message)?  documentDeleted,TResult Function()?  exporting,TResult Function( String filePath,  String message)?  exported,TResult Function( String companyId,  String message)?  welcomeEmailSent,TResult Function( String companyId,  String message)?  passwordReset,TResult Function( String message,  bool isNetworkError,  bool isServerError,  bool isValidationError,  StackTrace? stackTrace)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Loaded() when loaded != null:
return loaded(_that.companies,_that.total,_that.page,_that.perPage,_that.totalPages,_that.search,_that.status,_that.verificationStatus,_that.country,_that.planType,_that.sortBy,_that.sortOrder,_that.statistics,_that.filterOptions);case _CompanyDetailLoaded() when companyDetailLoaded != null:
return companyDetailLoaded(_that.company,_that.usageStats,_that.availablePlans,_that.filterOptions);case _CompanyCreated() when companyCreated != null:
return companyCreated(_that.company,_that.message);case _CompanyUpdated() when companyUpdated != null:
return companyUpdated(_that.company,_that.message);case _CompanyDeleted() when companyDeleted != null:
return companyDeleted(_that.companyId,_that.message);case _CompanyStatusUpdated() when companyStatusUpdated != null:
return companyStatusUpdated(_that.companyId,_that.status,_that.message);case _VerificationStatusUpdated() when verificationStatusUpdated != null:
return verificationStatusUpdated(_that.companyId,_that.verificationStatus,_that.message);case _PlanAssigned() when planAssigned != null:
return planAssigned(_that.companyId,_that.plan,_that.message);case _DocumentUploaded() when documentUploaded != null:
return documentUploaded(_that.companyId,_that.document,_that.message);case _DocumentDeleted() when documentDeleted != null:
return documentDeleted(_that.companyId,_that.documentId,_that.message);case _Exporting() when exporting != null:
return exporting();case _Exported() when exported != null:
return exported(_that.filePath,_that.message);case _WelcomeEmailSent() when welcomeEmailSent != null:
return welcomeEmailSent(_that.companyId,_that.message);case _PasswordReset() when passwordReset != null:
return passwordReset(_that.companyId,_that.message);case _Error() when error != null:
return error(_that.message,_that.isNetworkError,_that.isServerError,_that.isValidationError,_that.stackTrace);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<Company> companies,  int total,  int page,  int perPage,  int totalPages,  String search,  String? status,  String? verificationStatus,  String? country,  String? planType,  String sortBy,  String sortOrder,  CompanyStatistics? statistics,  CompanyFilterOptions filterOptions)  loaded,required TResult Function( Company company,  CompanyUsageStats usageStats,  List<SubscriptionPlan> availablePlans,  CompanyFilterOptions filterOptions)  companyDetailLoaded,required TResult Function( Company company,  String message)  companyCreated,required TResult Function( Company company,  String message)  companyUpdated,required TResult Function( String companyId,  String message)  companyDeleted,required TResult Function( String companyId,  String status,  String message)  companyStatusUpdated,required TResult Function( String companyId,  String verificationStatus,  String message)  verificationStatusUpdated,required TResult Function( String companyId,  SubscriptionPlan plan,  String message)  planAssigned,required TResult Function( String companyId,  CompanyDocument document,  String message)  documentUploaded,required TResult Function( String companyId,  String documentId,  String message)  documentDeleted,required TResult Function()  exporting,required TResult Function( String filePath,  String message)  exported,required TResult Function( String companyId,  String message)  welcomeEmailSent,required TResult Function( String companyId,  String message)  passwordReset,required TResult Function( String message,  bool isNetworkError,  bool isServerError,  bool isValidationError,  StackTrace? stackTrace)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _Loaded():
return loaded(_that.companies,_that.total,_that.page,_that.perPage,_that.totalPages,_that.search,_that.status,_that.verificationStatus,_that.country,_that.planType,_that.sortBy,_that.sortOrder,_that.statistics,_that.filterOptions);case _CompanyDetailLoaded():
return companyDetailLoaded(_that.company,_that.usageStats,_that.availablePlans,_that.filterOptions);case _CompanyCreated():
return companyCreated(_that.company,_that.message);case _CompanyUpdated():
return companyUpdated(_that.company,_that.message);case _CompanyDeleted():
return companyDeleted(_that.companyId,_that.message);case _CompanyStatusUpdated():
return companyStatusUpdated(_that.companyId,_that.status,_that.message);case _VerificationStatusUpdated():
return verificationStatusUpdated(_that.companyId,_that.verificationStatus,_that.message);case _PlanAssigned():
return planAssigned(_that.companyId,_that.plan,_that.message);case _DocumentUploaded():
return documentUploaded(_that.companyId,_that.document,_that.message);case _DocumentDeleted():
return documentDeleted(_that.companyId,_that.documentId,_that.message);case _Exporting():
return exporting();case _Exported():
return exported(_that.filePath,_that.message);case _WelcomeEmailSent():
return welcomeEmailSent(_that.companyId,_that.message);case _PasswordReset():
return passwordReset(_that.companyId,_that.message);case _Error():
return error(_that.message,_that.isNetworkError,_that.isServerError,_that.isValidationError,_that.stackTrace);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<Company> companies,  int total,  int page,  int perPage,  int totalPages,  String search,  String? status,  String? verificationStatus,  String? country,  String? planType,  String sortBy,  String sortOrder,  CompanyStatistics? statistics,  CompanyFilterOptions filterOptions)?  loaded,TResult? Function( Company company,  CompanyUsageStats usageStats,  List<SubscriptionPlan> availablePlans,  CompanyFilterOptions filterOptions)?  companyDetailLoaded,TResult? Function( Company company,  String message)?  companyCreated,TResult? Function( Company company,  String message)?  companyUpdated,TResult? Function( String companyId,  String message)?  companyDeleted,TResult? Function( String companyId,  String status,  String message)?  companyStatusUpdated,TResult? Function( String companyId,  String verificationStatus,  String message)?  verificationStatusUpdated,TResult? Function( String companyId,  SubscriptionPlan plan,  String message)?  planAssigned,TResult? Function( String companyId,  CompanyDocument document,  String message)?  documentUploaded,TResult? Function( String companyId,  String documentId,  String message)?  documentDeleted,TResult? Function()?  exporting,TResult? Function( String filePath,  String message)?  exported,TResult? Function( String companyId,  String message)?  welcomeEmailSent,TResult? Function( String companyId,  String message)?  passwordReset,TResult? Function( String message,  bool isNetworkError,  bool isServerError,  bool isValidationError,  StackTrace? stackTrace)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Loaded() when loaded != null:
return loaded(_that.companies,_that.total,_that.page,_that.perPage,_that.totalPages,_that.search,_that.status,_that.verificationStatus,_that.country,_that.planType,_that.sortBy,_that.sortOrder,_that.statistics,_that.filterOptions);case _CompanyDetailLoaded() when companyDetailLoaded != null:
return companyDetailLoaded(_that.company,_that.usageStats,_that.availablePlans,_that.filterOptions);case _CompanyCreated() when companyCreated != null:
return companyCreated(_that.company,_that.message);case _CompanyUpdated() when companyUpdated != null:
return companyUpdated(_that.company,_that.message);case _CompanyDeleted() when companyDeleted != null:
return companyDeleted(_that.companyId,_that.message);case _CompanyStatusUpdated() when companyStatusUpdated != null:
return companyStatusUpdated(_that.companyId,_that.status,_that.message);case _VerificationStatusUpdated() when verificationStatusUpdated != null:
return verificationStatusUpdated(_that.companyId,_that.verificationStatus,_that.message);case _PlanAssigned() when planAssigned != null:
return planAssigned(_that.companyId,_that.plan,_that.message);case _DocumentUploaded() when documentUploaded != null:
return documentUploaded(_that.companyId,_that.document,_that.message);case _DocumentDeleted() when documentDeleted != null:
return documentDeleted(_that.companyId,_that.documentId,_that.message);case _Exporting() when exporting != null:
return exporting();case _Exported() when exported != null:
return exported(_that.filePath,_that.message);case _WelcomeEmailSent() when welcomeEmailSent != null:
return welcomeEmailSent(_that.companyId,_that.message);case _PasswordReset() when passwordReset != null:
return passwordReset(_that.companyId,_that.message);case _Error() when error != null:
return error(_that.message,_that.isNetworkError,_that.isServerError,_that.isValidationError,_that.stackTrace);case _:
  return null;

}
}

}

/// @nodoc


class _Initial with DiagnosticableTreeMixin implements CompanyManagementState {
  const _Initial();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CompanyManagementState.initial'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CompanyManagementState.initial()';
}


}




/// @nodoc


class _Loading with DiagnosticableTreeMixin implements CompanyManagementState {
  const _Loading();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CompanyManagementState.loading'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CompanyManagementState.loading()';
}


}




/// @nodoc


class _Loaded with DiagnosticableTreeMixin implements CompanyManagementState {
  const _Loaded({required final  List<Company> companies, required this.total, required this.page, required this.perPage, required this.totalPages, required this.search, this.status, this.verificationStatus, this.country, this.planType, required this.sortBy, required this.sortOrder, required this.statistics, required this.filterOptions}): _companies = companies;
  

 final  List<Company> _companies;
 List<Company> get companies {
  if (_companies is EqualUnmodifiableListView) return _companies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_companies);
}

 final  int total;
 final  int page;
 final  int perPage;
 final  int totalPages;
 final  String search;
 final  String? status;
 final  String? verificationStatus;
 final  String? country;
 final  String? planType;
 final  String sortBy;
 final  String sortOrder;
 final  CompanyStatistics? statistics;
 final  CompanyFilterOptions filterOptions;

/// Create a copy of CompanyManagementState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadedCopyWith<_Loaded> get copyWith => __$LoadedCopyWithImpl<_Loaded>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CompanyManagementState.loaded'))
    ..add(DiagnosticsProperty('companies', companies))..add(DiagnosticsProperty('total', total))..add(DiagnosticsProperty('page', page))..add(DiagnosticsProperty('perPage', perPage))..add(DiagnosticsProperty('totalPages', totalPages))..add(DiagnosticsProperty('search', search))..add(DiagnosticsProperty('status', status))..add(DiagnosticsProperty('verificationStatus', verificationStatus))..add(DiagnosticsProperty('country', country))..add(DiagnosticsProperty('planType', planType))..add(DiagnosticsProperty('sortBy', sortBy))..add(DiagnosticsProperty('sortOrder', sortOrder))..add(DiagnosticsProperty('statistics', statistics))..add(DiagnosticsProperty('filterOptions', filterOptions));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loaded&&const DeepCollectionEquality().equals(other._companies, _companies)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.perPage, perPage) || other.perPage == perPage)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.search, search) || other.search == search)&&(identical(other.status, status) || other.status == status)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.country, country) || other.country == country)&&(identical(other.planType, planType) || other.planType == planType)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.statistics, statistics) || other.statistics == statistics)&&(identical(other.filterOptions, filterOptions) || other.filterOptions == filterOptions));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_companies),total,page,perPage,totalPages,search,status,verificationStatus,country,planType,sortBy,sortOrder,statistics,filterOptions);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CompanyManagementState.loaded(companies: $companies, total: $total, page: $page, perPage: $perPage, totalPages: $totalPages, search: $search, status: $status, verificationStatus: $verificationStatus, country: $country, planType: $planType, sortBy: $sortBy, sortOrder: $sortOrder, statistics: $statistics, filterOptions: $filterOptions)';
}


}

/// @nodoc
abstract mixin class _$LoadedCopyWith<$Res> implements $CompanyManagementStateCopyWith<$Res> {
  factory _$LoadedCopyWith(_Loaded value, $Res Function(_Loaded) _then) = __$LoadedCopyWithImpl;
@useResult
$Res call({
 List<Company> companies, int total, int page, int perPage, int totalPages, String search, String? status, String? verificationStatus, String? country, String? planType, String sortBy, String sortOrder, CompanyStatistics? statistics, CompanyFilterOptions filterOptions
});




}
/// @nodoc
class __$LoadedCopyWithImpl<$Res>
    implements _$LoadedCopyWith<$Res> {
  __$LoadedCopyWithImpl(this._self, this._then);

  final _Loaded _self;
  final $Res Function(_Loaded) _then;

/// Create a copy of CompanyManagementState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? companies = null,Object? total = null,Object? page = null,Object? perPage = null,Object? totalPages = null,Object? search = null,Object? status = freezed,Object? verificationStatus = freezed,Object? country = freezed,Object? planType = freezed,Object? sortBy = null,Object? sortOrder = null,Object? statistics = freezed,Object? filterOptions = null,}) {
  return _then(_Loaded(
companies: null == companies ? _self._companies : companies // ignore: cast_nullable_to_non_nullable
as List<Company>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,perPage: null == perPage ? _self.perPage : perPage // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,verificationStatus: freezed == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,planType: freezed == planType ? _self.planType : planType // ignore: cast_nullable_to_non_nullable
as String?,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as String,statistics: freezed == statistics ? _self.statistics : statistics // ignore: cast_nullable_to_non_nullable
as CompanyStatistics?,filterOptions: null == filterOptions ? _self.filterOptions : filterOptions // ignore: cast_nullable_to_non_nullable
as CompanyFilterOptions,
  ));
}


}

/// @nodoc


class _CompanyDetailLoaded with DiagnosticableTreeMixin implements CompanyManagementState {
  const _CompanyDetailLoaded({required this.company, required this.usageStats, required final  List<SubscriptionPlan> availablePlans, required this.filterOptions}): _availablePlans = availablePlans;
  

 final  Company company;
 final  CompanyUsageStats usageStats;
 final  List<SubscriptionPlan> _availablePlans;
 List<SubscriptionPlan> get availablePlans {
  if (_availablePlans is EqualUnmodifiableListView) return _availablePlans;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_availablePlans);
}

 final  CompanyFilterOptions filterOptions;

/// Create a copy of CompanyManagementState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompanyDetailLoadedCopyWith<_CompanyDetailLoaded> get copyWith => __$CompanyDetailLoadedCopyWithImpl<_CompanyDetailLoaded>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CompanyManagementState.companyDetailLoaded'))
    ..add(DiagnosticsProperty('company', company))..add(DiagnosticsProperty('usageStats', usageStats))..add(DiagnosticsProperty('availablePlans', availablePlans))..add(DiagnosticsProperty('filterOptions', filterOptions));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompanyDetailLoaded&&(identical(other.company, company) || other.company == company)&&(identical(other.usageStats, usageStats) || other.usageStats == usageStats)&&const DeepCollectionEquality().equals(other._availablePlans, _availablePlans)&&(identical(other.filterOptions, filterOptions) || other.filterOptions == filterOptions));
}


@override
int get hashCode => Object.hash(runtimeType,company,usageStats,const DeepCollectionEquality().hash(_availablePlans),filterOptions);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CompanyManagementState.companyDetailLoaded(company: $company, usageStats: $usageStats, availablePlans: $availablePlans, filterOptions: $filterOptions)';
}


}

/// @nodoc
abstract mixin class _$CompanyDetailLoadedCopyWith<$Res> implements $CompanyManagementStateCopyWith<$Res> {
  factory _$CompanyDetailLoadedCopyWith(_CompanyDetailLoaded value, $Res Function(_CompanyDetailLoaded) _then) = __$CompanyDetailLoadedCopyWithImpl;
@useResult
$Res call({
 Company company, CompanyUsageStats usageStats, List<SubscriptionPlan> availablePlans, CompanyFilterOptions filterOptions
});


$CompanyCopyWith<$Res> get company;$CompanyUsageStatsCopyWith<$Res> get usageStats;

}
/// @nodoc
class __$CompanyDetailLoadedCopyWithImpl<$Res>
    implements _$CompanyDetailLoadedCopyWith<$Res> {
  __$CompanyDetailLoadedCopyWithImpl(this._self, this._then);

  final _CompanyDetailLoaded _self;
  final $Res Function(_CompanyDetailLoaded) _then;

/// Create a copy of CompanyManagementState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? company = null,Object? usageStats = null,Object? availablePlans = null,Object? filterOptions = null,}) {
  return _then(_CompanyDetailLoaded(
company: null == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as Company,usageStats: null == usageStats ? _self.usageStats : usageStats // ignore: cast_nullable_to_non_nullable
as CompanyUsageStats,availablePlans: null == availablePlans ? _self._availablePlans : availablePlans // ignore: cast_nullable_to_non_nullable
as List<SubscriptionPlan>,filterOptions: null == filterOptions ? _self.filterOptions : filterOptions // ignore: cast_nullable_to_non_nullable
as CompanyFilterOptions,
  ));
}

/// Create a copy of CompanyManagementState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompanyCopyWith<$Res> get company {
  
  return $CompanyCopyWith<$Res>(_self.company, (value) {
    return _then(_self.copyWith(company: value));
  });
}/// Create a copy of CompanyManagementState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompanyUsageStatsCopyWith<$Res> get usageStats {
  
  return $CompanyUsageStatsCopyWith<$Res>(_self.usageStats, (value) {
    return _then(_self.copyWith(usageStats: value));
  });
}
}

/// @nodoc


class _CompanyCreated with DiagnosticableTreeMixin implements CompanyManagementState {
  const _CompanyCreated({required this.company, required this.message});
  

 final  Company company;
 final  String message;

/// Create a copy of CompanyManagementState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompanyCreatedCopyWith<_CompanyCreated> get copyWith => __$CompanyCreatedCopyWithImpl<_CompanyCreated>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CompanyManagementState.companyCreated'))
    ..add(DiagnosticsProperty('company', company))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompanyCreated&&(identical(other.company, company) || other.company == company)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,company,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CompanyManagementState.companyCreated(company: $company, message: $message)';
}


}

/// @nodoc
abstract mixin class _$CompanyCreatedCopyWith<$Res> implements $CompanyManagementStateCopyWith<$Res> {
  factory _$CompanyCreatedCopyWith(_CompanyCreated value, $Res Function(_CompanyCreated) _then) = __$CompanyCreatedCopyWithImpl;
@useResult
$Res call({
 Company company, String message
});


$CompanyCopyWith<$Res> get company;

}
/// @nodoc
class __$CompanyCreatedCopyWithImpl<$Res>
    implements _$CompanyCreatedCopyWith<$Res> {
  __$CompanyCreatedCopyWithImpl(this._self, this._then);

  final _CompanyCreated _self;
  final $Res Function(_CompanyCreated) _then;

/// Create a copy of CompanyManagementState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? company = null,Object? message = null,}) {
  return _then(_CompanyCreated(
company: null == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as Company,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of CompanyManagementState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompanyCopyWith<$Res> get company {
  
  return $CompanyCopyWith<$Res>(_self.company, (value) {
    return _then(_self.copyWith(company: value));
  });
}
}

/// @nodoc


class _CompanyUpdated with DiagnosticableTreeMixin implements CompanyManagementState {
  const _CompanyUpdated({required this.company, required this.message});
  

 final  Company company;
 final  String message;

/// Create a copy of CompanyManagementState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompanyUpdatedCopyWith<_CompanyUpdated> get copyWith => __$CompanyUpdatedCopyWithImpl<_CompanyUpdated>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CompanyManagementState.companyUpdated'))
    ..add(DiagnosticsProperty('company', company))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompanyUpdated&&(identical(other.company, company) || other.company == company)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,company,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CompanyManagementState.companyUpdated(company: $company, message: $message)';
}


}

/// @nodoc
abstract mixin class _$CompanyUpdatedCopyWith<$Res> implements $CompanyManagementStateCopyWith<$Res> {
  factory _$CompanyUpdatedCopyWith(_CompanyUpdated value, $Res Function(_CompanyUpdated) _then) = __$CompanyUpdatedCopyWithImpl;
@useResult
$Res call({
 Company company, String message
});


$CompanyCopyWith<$Res> get company;

}
/// @nodoc
class __$CompanyUpdatedCopyWithImpl<$Res>
    implements _$CompanyUpdatedCopyWith<$Res> {
  __$CompanyUpdatedCopyWithImpl(this._self, this._then);

  final _CompanyUpdated _self;
  final $Res Function(_CompanyUpdated) _then;

/// Create a copy of CompanyManagementState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? company = null,Object? message = null,}) {
  return _then(_CompanyUpdated(
company: null == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as Company,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of CompanyManagementState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompanyCopyWith<$Res> get company {
  
  return $CompanyCopyWith<$Res>(_self.company, (value) {
    return _then(_self.copyWith(company: value));
  });
}
}

/// @nodoc


class _CompanyDeleted with DiagnosticableTreeMixin implements CompanyManagementState {
  const _CompanyDeleted({required this.companyId, required this.message});
  

 final  String companyId;
 final  String message;

/// Create a copy of CompanyManagementState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompanyDeletedCopyWith<_CompanyDeleted> get copyWith => __$CompanyDeletedCopyWithImpl<_CompanyDeleted>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CompanyManagementState.companyDeleted'))
    ..add(DiagnosticsProperty('companyId', companyId))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompanyDeleted&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,companyId,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CompanyManagementState.companyDeleted(companyId: $companyId, message: $message)';
}


}

/// @nodoc
abstract mixin class _$CompanyDeletedCopyWith<$Res> implements $CompanyManagementStateCopyWith<$Res> {
  factory _$CompanyDeletedCopyWith(_CompanyDeleted value, $Res Function(_CompanyDeleted) _then) = __$CompanyDeletedCopyWithImpl;
@useResult
$Res call({
 String companyId, String message
});




}
/// @nodoc
class __$CompanyDeletedCopyWithImpl<$Res>
    implements _$CompanyDeletedCopyWith<$Res> {
  __$CompanyDeletedCopyWithImpl(this._self, this._then);

  final _CompanyDeleted _self;
  final $Res Function(_CompanyDeleted) _then;

/// Create a copy of CompanyManagementState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? companyId = null,Object? message = null,}) {
  return _then(_CompanyDeleted(
companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _CompanyStatusUpdated with DiagnosticableTreeMixin implements CompanyManagementState {
  const _CompanyStatusUpdated({required this.companyId, required this.status, required this.message});
  

 final  String companyId;
 final  String status;
 final  String message;

/// Create a copy of CompanyManagementState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompanyStatusUpdatedCopyWith<_CompanyStatusUpdated> get copyWith => __$CompanyStatusUpdatedCopyWithImpl<_CompanyStatusUpdated>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CompanyManagementState.companyStatusUpdated'))
    ..add(DiagnosticsProperty('companyId', companyId))..add(DiagnosticsProperty('status', status))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompanyStatusUpdated&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.status, status) || other.status == status)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,companyId,status,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CompanyManagementState.companyStatusUpdated(companyId: $companyId, status: $status, message: $message)';
}


}

/// @nodoc
abstract mixin class _$CompanyStatusUpdatedCopyWith<$Res> implements $CompanyManagementStateCopyWith<$Res> {
  factory _$CompanyStatusUpdatedCopyWith(_CompanyStatusUpdated value, $Res Function(_CompanyStatusUpdated) _then) = __$CompanyStatusUpdatedCopyWithImpl;
@useResult
$Res call({
 String companyId, String status, String message
});




}
/// @nodoc
class __$CompanyStatusUpdatedCopyWithImpl<$Res>
    implements _$CompanyStatusUpdatedCopyWith<$Res> {
  __$CompanyStatusUpdatedCopyWithImpl(this._self, this._then);

  final _CompanyStatusUpdated _self;
  final $Res Function(_CompanyStatusUpdated) _then;

/// Create a copy of CompanyManagementState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? companyId = null,Object? status = null,Object? message = null,}) {
  return _then(_CompanyStatusUpdated(
companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _VerificationStatusUpdated with DiagnosticableTreeMixin implements CompanyManagementState {
  const _VerificationStatusUpdated({required this.companyId, required this.verificationStatus, required this.message});
  

 final  String companyId;
 final  String verificationStatus;
 final  String message;

/// Create a copy of CompanyManagementState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerificationStatusUpdatedCopyWith<_VerificationStatusUpdated> get copyWith => __$VerificationStatusUpdatedCopyWithImpl<_VerificationStatusUpdated>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CompanyManagementState.verificationStatusUpdated'))
    ..add(DiagnosticsProperty('companyId', companyId))..add(DiagnosticsProperty('verificationStatus', verificationStatus))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerificationStatusUpdated&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,companyId,verificationStatus,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CompanyManagementState.verificationStatusUpdated(companyId: $companyId, verificationStatus: $verificationStatus, message: $message)';
}


}

/// @nodoc
abstract mixin class _$VerificationStatusUpdatedCopyWith<$Res> implements $CompanyManagementStateCopyWith<$Res> {
  factory _$VerificationStatusUpdatedCopyWith(_VerificationStatusUpdated value, $Res Function(_VerificationStatusUpdated) _then) = __$VerificationStatusUpdatedCopyWithImpl;
@useResult
$Res call({
 String companyId, String verificationStatus, String message
});




}
/// @nodoc
class __$VerificationStatusUpdatedCopyWithImpl<$Res>
    implements _$VerificationStatusUpdatedCopyWith<$Res> {
  __$VerificationStatusUpdatedCopyWithImpl(this._self, this._then);

  final _VerificationStatusUpdated _self;
  final $Res Function(_VerificationStatusUpdated) _then;

/// Create a copy of CompanyManagementState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? companyId = null,Object? verificationStatus = null,Object? message = null,}) {
  return _then(_VerificationStatusUpdated(
companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _PlanAssigned with DiagnosticableTreeMixin implements CompanyManagementState {
  const _PlanAssigned({required this.companyId, required this.plan, required this.message});
  

 final  String companyId;
 final  SubscriptionPlan plan;
 final  String message;

/// Create a copy of CompanyManagementState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlanAssignedCopyWith<_PlanAssigned> get copyWith => __$PlanAssignedCopyWithImpl<_PlanAssigned>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CompanyManagementState.planAssigned'))
    ..add(DiagnosticsProperty('companyId', companyId))..add(DiagnosticsProperty('plan', plan))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlanAssigned&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,companyId,plan,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CompanyManagementState.planAssigned(companyId: $companyId, plan: $plan, message: $message)';
}


}

/// @nodoc
abstract mixin class _$PlanAssignedCopyWith<$Res> implements $CompanyManagementStateCopyWith<$Res> {
  factory _$PlanAssignedCopyWith(_PlanAssigned value, $Res Function(_PlanAssigned) _then) = __$PlanAssignedCopyWithImpl;
@useResult
$Res call({
 String companyId, SubscriptionPlan plan, String message
});




}
/// @nodoc
class __$PlanAssignedCopyWithImpl<$Res>
    implements _$PlanAssignedCopyWith<$Res> {
  __$PlanAssignedCopyWithImpl(this._self, this._then);

  final _PlanAssigned _self;
  final $Res Function(_PlanAssigned) _then;

/// Create a copy of CompanyManagementState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? companyId = null,Object? plan = null,Object? message = null,}) {
  return _then(_PlanAssigned(
companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as SubscriptionPlan,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _DocumentUploaded with DiagnosticableTreeMixin implements CompanyManagementState {
  const _DocumentUploaded({required this.companyId, required this.document, required this.message});
  

 final  String companyId;
 final  CompanyDocument document;
 final  String message;

/// Create a copy of CompanyManagementState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentUploadedCopyWith<_DocumentUploaded> get copyWith => __$DocumentUploadedCopyWithImpl<_DocumentUploaded>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CompanyManagementState.documentUploaded'))
    ..add(DiagnosticsProperty('companyId', companyId))..add(DiagnosticsProperty('document', document))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentUploaded&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.document, document) || other.document == document)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,companyId,document,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CompanyManagementState.documentUploaded(companyId: $companyId, document: $document, message: $message)';
}


}

/// @nodoc
abstract mixin class _$DocumentUploadedCopyWith<$Res> implements $CompanyManagementStateCopyWith<$Res> {
  factory _$DocumentUploadedCopyWith(_DocumentUploaded value, $Res Function(_DocumentUploaded) _then) = __$DocumentUploadedCopyWithImpl;
@useResult
$Res call({
 String companyId, CompanyDocument document, String message
});


$CompanyDocumentCopyWith<$Res> get document;

}
/// @nodoc
class __$DocumentUploadedCopyWithImpl<$Res>
    implements _$DocumentUploadedCopyWith<$Res> {
  __$DocumentUploadedCopyWithImpl(this._self, this._then);

  final _DocumentUploaded _self;
  final $Res Function(_DocumentUploaded) _then;

/// Create a copy of CompanyManagementState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? companyId = null,Object? document = null,Object? message = null,}) {
  return _then(_DocumentUploaded(
companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,document: null == document ? _self.document : document // ignore: cast_nullable_to_non_nullable
as CompanyDocument,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of CompanyManagementState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompanyDocumentCopyWith<$Res> get document {
  
  return $CompanyDocumentCopyWith<$Res>(_self.document, (value) {
    return _then(_self.copyWith(document: value));
  });
}
}

/// @nodoc


class _DocumentDeleted with DiagnosticableTreeMixin implements CompanyManagementState {
  const _DocumentDeleted({required this.companyId, required this.documentId, required this.message});
  

 final  String companyId;
 final  String documentId;
 final  String message;

/// Create a copy of CompanyManagementState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentDeletedCopyWith<_DocumentDeleted> get copyWith => __$DocumentDeletedCopyWithImpl<_DocumentDeleted>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CompanyManagementState.documentDeleted'))
    ..add(DiagnosticsProperty('companyId', companyId))..add(DiagnosticsProperty('documentId', documentId))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentDeleted&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,companyId,documentId,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CompanyManagementState.documentDeleted(companyId: $companyId, documentId: $documentId, message: $message)';
}


}

/// @nodoc
abstract mixin class _$DocumentDeletedCopyWith<$Res> implements $CompanyManagementStateCopyWith<$Res> {
  factory _$DocumentDeletedCopyWith(_DocumentDeleted value, $Res Function(_DocumentDeleted) _then) = __$DocumentDeletedCopyWithImpl;
@useResult
$Res call({
 String companyId, String documentId, String message
});




}
/// @nodoc
class __$DocumentDeletedCopyWithImpl<$Res>
    implements _$DocumentDeletedCopyWith<$Res> {
  __$DocumentDeletedCopyWithImpl(this._self, this._then);

  final _DocumentDeleted _self;
  final $Res Function(_DocumentDeleted) _then;

/// Create a copy of CompanyManagementState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? companyId = null,Object? documentId = null,Object? message = null,}) {
  return _then(_DocumentDeleted(
companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _Exporting with DiagnosticableTreeMixin implements CompanyManagementState {
  const _Exporting();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CompanyManagementState.exporting'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Exporting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CompanyManagementState.exporting()';
}


}




/// @nodoc


class _Exported with DiagnosticableTreeMixin implements CompanyManagementState {
  const _Exported({required this.filePath, required this.message});
  

 final  String filePath;
 final  String message;

/// Create a copy of CompanyManagementState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExportedCopyWith<_Exported> get copyWith => __$ExportedCopyWithImpl<_Exported>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CompanyManagementState.exported'))
    ..add(DiagnosticsProperty('filePath', filePath))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Exported&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,filePath,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CompanyManagementState.exported(filePath: $filePath, message: $message)';
}


}

/// @nodoc
abstract mixin class _$ExportedCopyWith<$Res> implements $CompanyManagementStateCopyWith<$Res> {
  factory _$ExportedCopyWith(_Exported value, $Res Function(_Exported) _then) = __$ExportedCopyWithImpl;
@useResult
$Res call({
 String filePath, String message
});




}
/// @nodoc
class __$ExportedCopyWithImpl<$Res>
    implements _$ExportedCopyWith<$Res> {
  __$ExportedCopyWithImpl(this._self, this._then);

  final _Exported _self;
  final $Res Function(_Exported) _then;

/// Create a copy of CompanyManagementState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? filePath = null,Object? message = null,}) {
  return _then(_Exported(
filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _WelcomeEmailSent with DiagnosticableTreeMixin implements CompanyManagementState {
  const _WelcomeEmailSent({required this.companyId, required this.message});
  

 final  String companyId;
 final  String message;

/// Create a copy of CompanyManagementState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WelcomeEmailSentCopyWith<_WelcomeEmailSent> get copyWith => __$WelcomeEmailSentCopyWithImpl<_WelcomeEmailSent>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CompanyManagementState.welcomeEmailSent'))
    ..add(DiagnosticsProperty('companyId', companyId))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WelcomeEmailSent&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,companyId,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CompanyManagementState.welcomeEmailSent(companyId: $companyId, message: $message)';
}


}

/// @nodoc
abstract mixin class _$WelcomeEmailSentCopyWith<$Res> implements $CompanyManagementStateCopyWith<$Res> {
  factory _$WelcomeEmailSentCopyWith(_WelcomeEmailSent value, $Res Function(_WelcomeEmailSent) _then) = __$WelcomeEmailSentCopyWithImpl;
@useResult
$Res call({
 String companyId, String message
});




}
/// @nodoc
class __$WelcomeEmailSentCopyWithImpl<$Res>
    implements _$WelcomeEmailSentCopyWith<$Res> {
  __$WelcomeEmailSentCopyWithImpl(this._self, this._then);

  final _WelcomeEmailSent _self;
  final $Res Function(_WelcomeEmailSent) _then;

/// Create a copy of CompanyManagementState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? companyId = null,Object? message = null,}) {
  return _then(_WelcomeEmailSent(
companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _PasswordReset with DiagnosticableTreeMixin implements CompanyManagementState {
  const _PasswordReset({required this.companyId, required this.message});
  

 final  String companyId;
 final  String message;

/// Create a copy of CompanyManagementState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PasswordResetCopyWith<_PasswordReset> get copyWith => __$PasswordResetCopyWithImpl<_PasswordReset>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CompanyManagementState.passwordReset'))
    ..add(DiagnosticsProperty('companyId', companyId))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PasswordReset&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,companyId,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CompanyManagementState.passwordReset(companyId: $companyId, message: $message)';
}


}

/// @nodoc
abstract mixin class _$PasswordResetCopyWith<$Res> implements $CompanyManagementStateCopyWith<$Res> {
  factory _$PasswordResetCopyWith(_PasswordReset value, $Res Function(_PasswordReset) _then) = __$PasswordResetCopyWithImpl;
@useResult
$Res call({
 String companyId, String message
});




}
/// @nodoc
class __$PasswordResetCopyWithImpl<$Res>
    implements _$PasswordResetCopyWith<$Res> {
  __$PasswordResetCopyWithImpl(this._self, this._then);

  final _PasswordReset _self;
  final $Res Function(_PasswordReset) _then;

/// Create a copy of CompanyManagementState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? companyId = null,Object? message = null,}) {
  return _then(_PasswordReset(
companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _Error with DiagnosticableTreeMixin implements CompanyManagementState {
  const _Error({required this.message, this.isNetworkError = false, this.isServerError = false, this.isValidationError = false, this.stackTrace});
  

 final  String message;
@JsonKey() final  bool isNetworkError;
@JsonKey() final  bool isServerError;
@JsonKey() final  bool isValidationError;
 final  StackTrace? stackTrace;

/// Create a copy of CompanyManagementState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CompanyManagementState.error'))
    ..add(DiagnosticsProperty('message', message))..add(DiagnosticsProperty('isNetworkError', isNetworkError))..add(DiagnosticsProperty('isServerError', isServerError))..add(DiagnosticsProperty('isValidationError', isValidationError))..add(DiagnosticsProperty('stackTrace', stackTrace));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error&&(identical(other.message, message) || other.message == message)&&(identical(other.isNetworkError, isNetworkError) || other.isNetworkError == isNetworkError)&&(identical(other.isServerError, isServerError) || other.isServerError == isServerError)&&(identical(other.isValidationError, isValidationError) || other.isValidationError == isValidationError)&&(identical(other.stackTrace, stackTrace) || other.stackTrace == stackTrace));
}


@override
int get hashCode => Object.hash(runtimeType,message,isNetworkError,isServerError,isValidationError,stackTrace);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CompanyManagementState.error(message: $message, isNetworkError: $isNetworkError, isServerError: $isServerError, isValidationError: $isValidationError, stackTrace: $stackTrace)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $CompanyManagementStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) = __$ErrorCopyWithImpl;
@useResult
$Res call({
 String message, bool isNetworkError, bool isServerError, bool isValidationError, StackTrace? stackTrace
});




}
/// @nodoc
class __$ErrorCopyWithImpl<$Res>
    implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

/// Create a copy of CompanyManagementState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,Object? isNetworkError = null,Object? isServerError = null,Object? isValidationError = null,Object? stackTrace = freezed,}) {
  return _then(_Error(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,isNetworkError: null == isNetworkError ? _self.isNetworkError : isNetworkError // ignore: cast_nullable_to_non_nullable
as bool,isServerError: null == isServerError ? _self.isServerError : isServerError // ignore: cast_nullable_to_non_nullable
as bool,isValidationError: null == isValidationError ? _self.isValidationError : isValidationError // ignore: cast_nullable_to_non_nullable
as bool,stackTrace: freezed == stackTrace ? _self.stackTrace : stackTrace // ignore: cast_nullable_to_non_nullable
as StackTrace?,
  ));
}


}

// dart format on
